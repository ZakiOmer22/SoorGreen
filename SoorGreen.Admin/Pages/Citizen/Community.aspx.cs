using System;
using System.Data;
using System.Data.SqlClient;
using System.Collections.Generic;
using System.Web.Configuration;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.Script.Serialization;

namespace SoorGreen.Citizen
{
    public partial class Community : System.Web.UI.Page
    {
        private string connectionString = WebConfigurationManager.ConnectionStrings["SoorGreenDBConnectionString"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (Session["UserId"] == null || Session["UserRole"] == null)
                {
                    Response.Redirect("~/Login.aspx");
                    return;
                }

                if (Session["UserRole"].ToString() != "CITZ" && Session["UserRole"].ToString() != "R001")
                {
                    Response.Redirect("~/Pages/Unauthorized.aspx");
                    return;
                }

                System.Diagnostics.Debug.WriteLine("=== COMMUNITY PAGE LOAD ===");
                System.Diagnostics.Debug.WriteLine("UserID: " + Session["UserId"]);
                System.Diagnostics.Debug.WriteLine("UserRole: " + Session["UserRole"]);

                LoadData();
            }
        }

        protected void btnLoadData_Click(object sender, EventArgs e)
        {
            LoadData();
        }

        protected void btnCreatePost_Click(object sender, EventArgs e)
        {
            string postContent = txtPostContent.Text.Trim();
            System.Diagnostics.Debug.WriteLine("=== CREATING POST ===");
            System.Diagnostics.Debug.WriteLine("Post content: " + postContent);

            if (!string.IsNullOrEmpty(postContent))
            {
                if (CreatePost(postContent))
                {
                    ShowNotification("Post created successfully!", "success");
                    txtPostContent.Text = "";
                    LoadData();
                }
                else
                {
                    ShowNotification("Error creating post. Please try again.", "error");
                }
            }
            else
            {
                ShowNotification("Please write something to post!", "error");
            }
        }
        protected void btnJoinEvent_Click(object sender, EventArgs e)
        {
            ShowNotification("Browse upcoming events to join!", "info");
        }

        protected void btnStartGroup_Click(object sender, EventArgs e)
        {
            ShowNotification("Group creation feature coming soon!", "info");
        }

        protected void btnInviteFriends_Click(object sender, EventArgs e)
        {
            ShowNotification("Invite your friends to join the eco-community!", "info");
        }

        protected void LoadData()
        {
            try
            {
                Console.WriteLine("=== LOAD DATA START ===");

                // Load posts
                var posts = LoadCommunityPosts();
                hfPostsData.Value = DataTableToJson(posts);
                System.Diagnostics.Debug.WriteLine("Posts loaded: " + posts.Rows.Count);

                // Load stats
                var stats = new
                {
                    TotalMembers = GetTotalMembers(),
                    ActiveNow = GetActiveUsersCount(),
                    PostsToday = GetPostsTodayCount(),
                    EventsThisWeek = GetEventsThisWeekCount()
                };
                var serializer = new JavaScriptSerializer();
                hfStatsData.Value = serializer.Serialize(stats);
                System.Diagnostics.Debug.WriteLine("Stats loaded: " + hfStatsData.Value);

                // Load online users
                var onlineUsers = LoadOnlineUsers();
                hfOnlineUsers.Value = serializer.Serialize(onlineUsers);
                System.Diagnostics.Debug.WriteLine("Online users loaded: " + onlineUsers.Count);

                // Load events
                var events = LoadCommunityEvents();
                hfEvents.Value = serializer.Serialize(events);
                System.Diagnostics.Debug.WriteLine("Events loaded: " + events.Count);

                System.Diagnostics.Debug.WriteLine("=== LOAD DATA END ===");

            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error in LoadData: " + ex.Message);
                // Set empty data on error
                hfPostsData.Value = "[]";
                hfStatsData.Value = "{\"TotalMembers\":0,\"ActiveNow\":0,\"PostsToday\":0,\"EventsThisWeek\":0}";
                hfOnlineUsers.Value = "[]";
                hfEvents.Value = "[]";
            }
        }

        private DataTable LoadCommunityPosts()
        {
            DataTable dt = new DataTable();

            try
            {
                System.Diagnostics.Debug.WriteLine("=== LOADING COMMUNITY POSTS ===");

                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    // Fixed query - using FullName since FirstName/LastName don't exist
                    string query = @"
                        SELECT 
                            ua.ActivityId as PostId,
                            ua.UserId,
                            u.FullName,
                            ua.Description as Content,
                            ua.ActivityType as PostType,
                            ua.Timestamp as CreatedAt,
                            5 as Likes,  -- Default values for frontend
                            2 as Comments,
                            1 as Shares,
                            0 as IsLiked
                        FROM UserActivities ua
                        INNER JOIN Users u ON ua.UserId = u.UserId
                        WHERE ua.ActivityType = 'CommunityPost'
                        ORDER BY ua.Timestamp DESC";

                    System.Diagnostics.Debug.WriteLine("Executing posts query...");

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        dt.Load(reader);
                        System.Diagnostics.Debug.WriteLine("Posts loaded from DB: " + dt.Rows.Count);

                        // Debug: Print what we found - FIXED: Using string.Format instead of $
                        foreach (DataRow row in dt.Rows)
                        {
                            System.Diagnostics.Debug.WriteLine(string.Format("Found post: {0} - {1} - {2}",
                                row["PostId"], row["Content"], row["CreatedAt"]));
                        }
                    }
                }

                // Add computed columns for display
                dt.Columns.Add("UserName", typeof(string));
                dt.Columns.Add("UserAvatar", typeof(string));
                dt.Columns.Add("UserTitle", typeof(string));

                foreach (DataRow row in dt.Rows)
                {
                    string fullName = row["FullName"] != DBNull.Value ? row["FullName"].ToString() : "User";
                    string userId = row["UserId"] != DBNull.Value ? row["UserId"].ToString() : "";
                    string content = row["Content"] != DBNull.Value ? row["Content"].ToString() : "";

                    row["UserName"] = GetUserName(fullName);
                    row["UserAvatar"] = GetUserInitials(fullName);
                    row["UserTitle"] = GetUserTitle(GetUserXPCredits(userId));

                    System.Diagnostics.Debug.WriteLine(string.Format("Processed post: {0} - {1}",
                        row["UserName"], content));
                }

                System.Diagnostics.Debug.WriteLine("Final posts count: " + dt.Rows.Count);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error loading community posts: " + ex.Message);
                System.Diagnostics.Debug.WriteLine("Stack trace: " + ex.StackTrace);

                // Create empty table with correct structure
                CreateEmptyPostsTable(dt);
            }

            return dt;
        }

        private bool CreatePost(string content)
        {
            try
            {
                string userId = Session["UserId"] != null ? Session["UserId"].ToString() : "R001";
                System.Diagnostics.Debug.WriteLine("Creating post for user: " + userId);

                string query = @"
                    INSERT INTO UserActivities (UserId, ActivityType, Description, Points, Timestamp)
                    VALUES (@UserId, 'CommunityPost', @Content, 2, GETDATE())";

                using (SqlConnection conn = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@UserId", userId);
                    cmd.Parameters.AddWithValue("@Content", content);
                    conn.Open();
                    int result = cmd.ExecuteNonQuery();
                    System.Diagnostics.Debug.WriteLine("Post creation result: " + result);
                    return result > 0;
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine("Error creating post: " + ex.Message);
                Console.WriteLine("Stack trace: " + ex.StackTrace);
                return false;
            }
        }

        private List<OnlineUser> LoadOnlineUsers()
        {
            var onlineUsers = new List<OnlineUser>();

            try
            {
                string query = @"
                    SELECT TOP 10 
                        u.UserId,
                        u.FullName,
                        u.LastLogin
                    FROM Users u
                    WHERE u.RoleId IN ('CITZ', 'R001')
                    AND u.LastLogin >= DATEADD(HOUR, -4, GETDATE())
                    ORDER BY u.LastLogin DESC";

                using (SqlConnection conn = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    conn.Open();
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            string fullName = reader["FullName"] != null ? reader["FullName"].ToString() : "User";
                            DateTime? lastLogin = reader["LastLogin"] != DBNull.Value ? (DateTime?)reader["LastLogin"] : null;

                            string status = "Away";
                            if (lastLogin.HasValue)
                            {
                                if (lastLogin.Value >= DateTime.Now.AddMinutes(-15))
                                    status = "Active now";
                                else if (lastLogin.Value >= DateTime.Now.AddHours(-1))
                                    status = "Online";
                            }

                            var user = new OnlineUser
                            {
                                UserId = reader["UserId"] != null ? reader["UserId"].ToString() : "",
                                Name = GetUserName(fullName),
                                Avatar = GetUserInitials(fullName),
                                Status = status
                            };

                            onlineUsers.Add(user);
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine("Error loading online users: " + ex.Message);
            }

            return onlineUsers;
        }

        private List<CommunityEvent> LoadCommunityEvents()
        {
            var events = new List<CommunityEvent>();

            try
            {
                // Check if CommunityEvents table exists
                string checkTableQuery = @"
                    SELECT COUNT(*) 
                    FROM INFORMATION_SCHEMA.TABLES 
                    WHERE TABLE_NAME = 'CommunityEvents'";

                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    using (SqlCommand checkCmd = new SqlCommand(checkTableQuery, conn))
                    {
                        int tableExists = (int)checkCmd.ExecuteScalar();

                        if (tableExists > 0)
                        {
                            string query = @"
                                SELECT TOP 5 
                                    EventId,
                                    Title,
                                    Description,
                                    EventDate,
                                    Location
                                FROM CommunityEvents 
                                WHERE EventDate >= GETDATE()
                                ORDER BY EventDate ASC";

                            using (SqlCommand cmd = new SqlCommand(query, conn))
                            using (SqlDataReader reader = cmd.ExecuteReader())
                            {
                                while (reader.Read())
                                {
                                    var eventItem = new CommunityEvent
                                    {
                                        EventId = reader["EventId"] != DBNull.Value ? reader["EventId"].ToString() : "",
                                        Title = reader["Title"] != null ? reader["Title"].ToString() : "",
                                        Description = reader["Description"] != null ? reader["Description"].ToString() : "",
                                        Date = reader["EventDate"] != DBNull.Value ? Convert.ToDateTime(reader["EventDate"]).ToString("MMM dd") : "Soon",
                                        Location = reader["Location"] != null ? reader["Location"].ToString() : ""
                                    };
                                    events.Add(eventItem);
                                }
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine("Error loading events: " + ex.Message);
            }

            return events;
        }

        private string DataTableToJson(DataTable dt)
        {
            try
            {
                System.Collections.Generic.List<System.Collections.Generic.Dictionary<string, object>> rows =
                    new System.Collections.Generic.List<System.Collections.Generic.Dictionary<string, object>>();

                foreach (DataRow dr in dt.Rows)
                {
                    var row = new System.Collections.Generic.Dictionary<string, object>();
                    foreach (DataColumn col in dt.Columns)
                    {
                        object val = dr[col];
                        if (val == DBNull.Value)
                            val = null;
                        row.Add(col.ColumnName, val);
                    }
                    rows.Add(row);
                }
                return new JavaScriptSerializer().Serialize(rows);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("JSON error: " + ex.Message);
                return "[]";
            }
        }

        private int GetTotalMembers()
        {
            try
            {
                string query = "SELECT COUNT(*) FROM Users WHERE RoleId IN ('CITZ', 'R001')";
                return GetScalarValue(query);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error getting total members: " + ex.Message);
                return 42;
            }
        }

        private int GetActiveUsersCount()
        {
            try
            {
                string query = "SELECT COUNT(*) FROM Users WHERE LastLogin >= DATEADD(HOUR, -1, GETDATE()) AND RoleId IN ('CITZ', 'R001')";
                return GetScalarValue(query);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error getting active users: " + ex.Message);
                return 8;
            }
        }

        private int GetPostsTodayCount()
        {
            try
            {
                string query = "SELECT COUNT(*) FROM UserActivities WHERE ActivityType = 'CommunityPost' AND CAST(Timestamp AS DATE) = CAST(GETDATE() AS DATE)";
                return GetScalarValue(query);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error getting posts today: " + ex.Message);
                return 3;
            }
        }

        private int GetEventsThisWeekCount()
        {
            try
            {
                string query = "SELECT COUNT(*) FROM CommunityEvents WHERE EventDate >= CAST(GETDATE() AS DATE) AND EventDate <= DATEADD(DAY, 7, CAST(GETDATE() AS DATE))";
                return GetScalarValue(query);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error getting events count: " + ex.Message);
                return 2;
            }
        }

        private decimal GetUserXPCredits(string userId)
        {
            try
            {
                string query = "SELECT ISNULL(XP_Credits, 0) FROM Users WHERE UserId = @UserId";
                using (SqlConnection conn = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@UserId", userId);
                    conn.Open();
                    var result = cmd.ExecuteScalar();
                    return result != DBNull.Value ? Convert.ToDecimal(result) : 0;
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error getting user XP credits: " + ex.Message);
                return 150;
            }
        }

        private int GetScalarValue(string query)
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    conn.Open();
                    var result = cmd.ExecuteScalar();
                    return result != DBNull.Value ? Convert.ToInt32(result) : 0;
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Scalar error: " + ex.Message);
                return 0;
            }
        }

        private string GetUserName(string fullName)
        {
            if (!string.IsNullOrEmpty(fullName))
                return fullName;
            return "Community Member";
        }

        private string GetUserInitials(string fullName)
        {
            if (!string.IsNullOrEmpty(fullName))
            {
                var parts = fullName.Split(' ');
                if (parts.Length >= 2)
                    return parts[0].Substring(0, 1).ToUpper() + parts[1].Substring(0, 1).ToUpper();
                else if (fullName.Length >= 2)
                    return fullName.Substring(0, 2).ToUpper();
            }
            return "CM";
        }

        private string GetUserTitle(decimal xpCredits)
        {
            if (xpCredits >= 1000) return "Eco Champion";
            if (xpCredits >= 500) return "Green Warrior";
            if (xpCredits >= 200) return "Sustainability Expert";
            if (xpCredits >= 100) return "Eco Enthusiast";
            return "Eco Beginner";
        }

        private void CreateEmptyPostsTable(DataTable dt)
        {
            // Ensure the DataTable has the required columns
            dt.Columns.Clear();
            dt.Columns.Add("PostId", typeof(string));
            dt.Columns.Add("UserId", typeof(string));
            dt.Columns.Add("FullName", typeof(string));
            dt.Columns.Add("Content", typeof(string));
            dt.Columns.Add("PostType", typeof(string));
            dt.Columns.Add("CreatedAt", typeof(DateTime));
            dt.Columns.Add("Likes", typeof(int));
            dt.Columns.Add("Comments", typeof(int));
            dt.Columns.Add("Shares", typeof(int));
            dt.Columns.Add("IsLiked", typeof(int));
            dt.Columns.Add("UserName", typeof(string));
            dt.Columns.Add("UserAvatar", typeof(string));
            dt.Columns.Add("UserTitle", typeof(string));
        }

        private void ShowNotification(string message, string type)
        {
            // Use a simple alert for now, or store in session for page load
            string script = string.Format("setTimeout(function() {{ alert('{0}'); }}, 100);", message.Replace("'", "\\'"));
            ClientScript.RegisterStartupScript(this.GetType(), "ShowAlert", script, true);
        }
    }

    public class OnlineUser
    {
        public string UserId { get; set; }
        public string Name { get; set; }
        public string Avatar { get; set; }
        public string Status { get; set; }
    }

    public class CommunityEvent
    {
        public string EventId { get; set; }
        public string Title { get; set; }
        public string Description { get; set; }
        public string Date { get; set; }
        public string Location { get; set; }
    }
}