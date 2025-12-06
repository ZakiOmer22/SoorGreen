using System;
using System.Data;
using System.Data.SqlClient;
using System.Collections.Generic;
using System.Web.Configuration;
using System.Web.UI;
using System.Web.Script.Serialization;
using System.Diagnostics;

namespace SoorGreen.Citizen
{
    public partial class Community : System.Web.UI.Page
    {
        private string connectionString = WebConfigurationManager.ConnectionStrings["SoorGreenDBConnectionString"].ConnectionString;
        private string userId = string.Empty;
        private string userRole = string.Empty;
        private string userFullName = string.Empty;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (!ValidateUserSession())
                    return;

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

            if (string.IsNullOrWhiteSpace(postContent))
            {
                ShowAlert("Please write something to post!");
                return;
            }

            if (postContent.Length > 500)
            {
                ShowAlert("Post is too long! Maximum 500 characters.");
                return;
            }

            if (CreatePost(postContent))
            {
                ShowAlert("Post created successfully!");
                txtPostContent.Text = "";
                LoadData();
            }
            else
            {
                ShowAlert("Error creating post. Please try again.");
            }
        }

        private void LoadData()
        {
            try
            {
                LoadPostsData();
                LoadStatsData();
                LoadOnlineUsersData();
                LoadEventsData();

                // Initialize JavaScript
                ClientScript.RegisterStartupScript(this.GetType(), "Init",
                    "<script>setTimeout(function(){ if(typeof initializePage==='function') initializePage(); }, 100);</script>",
                    false);
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.Message);
            }
        }

        private void LoadPostsData()
        {
            try
            {
                var posts = LoadCommunityPosts();
                hfPostsData.Value = DataTableToJson(posts);
            }
            catch
            {
                hfPostsData.Value = "[]";
            }
        }

        private void LoadStatsData()
        {
            try
            {
                var stats = new
                {
                    TotalMembers = GetTotalMembers(),
                    ActiveNow = GetActiveUsersCount(),
                    PostsToday = GetPostsTodayCount(),
                    EventsThisWeek = GetEventsThisWeekCount(),
                    TotalPosts = GetTotalPosts(),
                    EngagementRate = 0
                };

                hfStatsData.Value = new JavaScriptSerializer().Serialize(stats);
            }
            catch
            {
                hfStatsData.Value = "{\"TotalMembers\":0,\"ActiveNow\":0,\"PostsToday\":0,\"EventsThisWeek\":0,\"TotalPosts\":0,\"EngagementRate\":0}";
            }
        }

        private void LoadOnlineUsersData()
        {
            try
            {
                var onlineUsers = LoadOnlineUsers();
                hfOnlineUsers.Value = new JavaScriptSerializer().Serialize(onlineUsers);
            }
            catch
            {
                hfOnlineUsers.Value = "[]";
            }
        }

        private void LoadEventsData()
        {
            try
            {
                var events = LoadCommunityEvents();
                hfEvents.Value = new JavaScriptSerializer().Serialize(events);
            }
            catch
            {
                hfEvents.Value = "[]";
            }
        }

        private DataTable LoadCommunityPosts()
        {
            DataTable dt = new DataTable();

            try
            {
                string query = @"
                    SELECT 
                        ua.ActivityId as PostId,
                        ua.UserId,
                        u.FullName,
                        ua.Description as Content,
                        ua.ActivityType as PostType,
                        ua.Timestamp as CreatedAt,
                        ISNULL(u.XP_Credits, 0) as UserXP
                    FROM UserActivities ua
                    INNER JOIN Users u ON ua.UserId = u.UserId
                    WHERE ua.ActivityType = 'CommunityPost'
                    ORDER BY ua.Timestamp DESC";

                using (SqlConnection conn = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    conn.Open();
                    using (SqlDataAdapter adapter = new SqlDataAdapter(cmd))
                    {
                        adapter.Fill(dt);
                    }
                }

                // Add display columns
                dt.Columns.Add("UserName", typeof(string));
                dt.Columns.Add("UserAvatar", typeof(string));
                dt.Columns.Add("UserTitle", typeof(string));
                dt.Columns.Add("UserLevel", typeof(int));
                dt.Columns.Add("TimeAgo", typeof(string));
                dt.Columns.Add("Likes", typeof(int));
                dt.Columns.Add("Comments", typeof(int));
                dt.Columns.Add("Shares", typeof(int));
                dt.Columns.Add("IsLiked", typeof(bool));
                dt.Columns.Add("IsPinned", typeof(bool));

                foreach (DataRow row in dt.Rows)
                {
                    string fullName = row["FullName"] != DBNull.Value ? row["FullName"].ToString() : "Community Member";
                    DateTime createdAt = row["CreatedAt"] != DBNull.Value ? Convert.ToDateTime(row["CreatedAt"]) : DateTime.Now;
                    decimal userXP = row["UserXP"] != DBNull.Value ? Convert.ToDecimal(row["UserXP"]) : 0;

                    row["UserName"] = FormatUserName(fullName);
                    row["UserAvatar"] = GetUserInitials(fullName);
                    row["UserTitle"] = GetUserTitle(userXP);
                    row["UserLevel"] = CalculateUserLevel(userXP);
                    row["TimeAgo"] = GetTimeAgo(createdAt);

                    row["Likes"] = 0;
                    row["Comments"] = 0;
                    row["Shares"] = 0;
                    row["IsLiked"] = false;
                    row["IsPinned"] = false;
                }
            }
            catch
            {
                CreateEmptyPostsTable(dt);
            }

            return dt;
        }

        private bool CreatePost(string content)
        {
            try
            {
                string query = @"
                    INSERT INTO UserActivities 
                    (UserId, ActivityType, Description, Timestamp)
                    VALUES 
                    (@UserId, 'CommunityPost', @Content, GETDATE());
                    
                    UPDATE Users 
                    SET XP_Credits = ISNULL(XP_Credits, 0) + 5
                    WHERE UserId = @UserId;";

                using (SqlConnection conn = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@UserId", userId);
                    cmd.Parameters.AddWithValue("@Content", content);

                    conn.Open();
                    return cmd.ExecuteNonQuery() > 0;
                }
            }
            catch
            {
                return false;
            }
        }

        private List<OnlineUser> LoadOnlineUsers()
        {
            var onlineUsers = new List<OnlineUser>();

            try
            {
                string query = @"
                    SELECT TOP 8 
                        u.UserId,
                        u.FullName,
                        u.LastLogin,
                        ISNULL(u.XP_Credits, 0) as XP_Credits,
                        DATEDIFF(MINUTE, u.LastLogin, GETDATE()) as MinutesSinceLogin
                    FROM Users u
                    WHERE u.RoleId IN ('CITZ', 'R001')
                    AND u.LastLogin IS NOT NULL
                    ORDER BY u.LastLogin DESC";

                using (SqlConnection conn = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    conn.Open();
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            string fullName = reader["FullName"] != DBNull.Value ? reader["FullName"].ToString() : "User";
                            int minutesSinceLogin = reader["MinutesSinceLogin"] != DBNull.Value ? Convert.ToInt32(reader["MinutesSinceLogin"]) : 0;
                            decimal xpCredits = reader["XP_Credits"] != DBNull.Value ? Convert.ToDecimal(reader["XP_Credits"]) : 0;

                            string status = GetOnlineStatus(minutesSinceLogin);

                            var user = new OnlineUser
                            {
                                UserId = reader["UserId"] != DBNull.Value ? reader["UserId"].ToString() : "",
                                Name = FormatUserName(fullName),
                                Avatar = GetUserInitials(fullName),
                                Status = status,
                                XP = xpCredits,
                                Level = CalculateUserLevel(xpCredits),
                                IsActive = minutesSinceLogin <= 15
                            };

                            onlineUsers.Add(user);
                        }
                    }
                }
            }
            catch
            {
                // Return empty list on error
            }

            return onlineUsers;
        }

        private List<CommunityEvent> LoadCommunityEvents()
        {
            var events = new List<CommunityEvent>();

            try
            {
                string checkTableQuery = "SELECT CASE WHEN OBJECT_ID('CommunityEvents', 'U') IS NOT NULL THEN 1 ELSE 0 END";

                using (SqlConnection conn = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand(checkTableQuery, conn))
                {
                    conn.Open();
                    object result = cmd.ExecuteScalar();
                    bool tableExists = result != null && Convert.ToInt32(result) == 1;

                    if (tableExists)
                    {
                        string query = @"
                            SELECT TOP 5 
                                EventId,
                                Title,
                                Description,
                                EventDate,
                                Location,
                                ISNULL(MaxParticipants, 0) as MaxParticipants,
                                ISNULL(CurrentParticipants, 0) as CurrentParticipants
                            FROM CommunityEvents 
                            WHERE EventDate >= GETDATE()
                            ORDER BY EventDate ASC";

                        using (SqlCommand eventCmd = new SqlCommand(query, conn))
                        using (SqlDataReader reader = eventCmd.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                var eventItem = new CommunityEvent
                                {
                                    EventId = reader["EventId"] != DBNull.Value ? reader["EventId"].ToString() : Guid.NewGuid().ToString(),
                                    Title = reader["Title"] != DBNull.Value ? reader["Title"].ToString() : "Community Event",
                                    Description = reader["Description"] != DBNull.Value ? reader["Description"].ToString() : "Join us!",
                                    Date = reader["EventDate"] != DBNull.Value ? FormatEventDate(Convert.ToDateTime(reader["EventDate"])) : "Coming Soon",
                                    Location = reader["Location"] != DBNull.Value ? reader["Location"].ToString() : "Online",
                                    EventType = "Event",
                                    Participants = reader["CurrentParticipants"] != DBNull.Value ? Convert.ToInt32(reader["CurrentParticipants"]) : 0,
                                    MaxParticipants = reader["MaxParticipants"] != DBNull.Value ? Convert.ToInt32(reader["MaxParticipants"]) : 0
                                };
                                events.Add(eventItem);
                            }
                        }
                    }
                }
            }
            catch
            {
                // Return empty list on error
            }

            return events;
        }

        private bool ValidateUserSession()
        {
            if (Session["UserId"] == null || Session["UserRole"] == null)
            {
                Response.Redirect("~/Login.aspx");
                return false;
            }

            userId = Session["UserId"].ToString();
            userRole = Session["UserRole"].ToString();
            userFullName = Session["FullName"] != null ? Session["FullName"].ToString() : "User";

            return userRole == "CITZ" || userRole == "R001";
        }

        private string FormatUserName(string fullName)
        {
            if (string.IsNullOrWhiteSpace(fullName))
                return "Community Member";

            var parts = fullName.Split(' ');
            return parts.Length > 0 ? parts[0] : fullName;
        }

        private string GetUserInitials(string fullName)
        {
            if (string.IsNullOrWhiteSpace(fullName))
                return "CM";

            var parts = fullName.Split(new char[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
            if (parts.Length >= 2)
                return (parts[0][0].ToString() + parts[1][0].ToString()).ToUpper();
            else if (fullName.Length >= 2)
                return fullName.Substring(0, 2).ToUpper();
            else
                return fullName.ToUpper();
        }

        private string GetUserTitle(decimal xpCredits)
        {
            if (xpCredits >= 1000) return "Eco Champion";
            if (xpCredits >= 500) return "Green Warrior";
            if (xpCredits >= 200) return "Sustainability Expert";
            if (xpCredits >= 100) return "Eco Enthusiast";
            return "Eco Beginner";
        }

        private int CalculateUserLevel(decimal xpCredits)
        {
            return (int)Math.Floor(xpCredits / 100) + 1;
        }

        private string GetTimeAgo(DateTime date)
        {
            var timeSpan = DateTime.Now - date;

            if (timeSpan.TotalMinutes < 1)
                return "Just now";
            else if (timeSpan.TotalMinutes < 60)
                return ((int)timeSpan.TotalMinutes).ToString() + "m ago";
            else if (timeSpan.TotalHours < 24)
                return ((int)timeSpan.TotalHours).ToString() + "h ago";
            else if (timeSpan.TotalDays < 7)
                return ((int)timeSpan.TotalDays).ToString() + "d ago";
            else if (timeSpan.TotalDays < 30)
                return (((int)timeSpan.TotalDays / 7).ToString()) + "w ago";
            else
                return date.ToString("MMM dd, yyyy");
        }

        private string GetOnlineStatus(int minutesSinceLogin)
        {
            if (minutesSinceLogin <= 5)
                return "Online now";
            else if (minutesSinceLogin <= 15)
                return "Active recently";
            else if (minutesSinceLogin <= 60)
                return "Away";
            else
                return "Offline";
        }

        private string FormatEventDate(DateTime eventDate)
        {
            if (eventDate.Date == DateTime.Today)
                return "Today, " + eventDate.ToString("h:mm tt");
            else if (eventDate.Date == DateTime.Today.AddDays(1))
                return "Tomorrow, " + eventDate.ToString("h:mm tt");
            else if (eventDate.Date <= DateTime.Today.AddDays(7))
                return eventDate.ToString("ddd, h:mm tt");
            else
                return eventDate.ToString("MMM dd, h:mm tt");
        }

        private int GetTotalMembers()
        {
            try
            {
                string query = "SELECT COUNT(*) FROM Users WHERE RoleId IN ('CITZ', 'R001')";
                using (SqlConnection conn = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    conn.Open();
                    object result = cmd.ExecuteScalar();
                    return result != DBNull.Value && result != null ? Convert.ToInt32(result) : 0;
                }
            }
            catch
            {
                return 0;
            }
        }

        private int GetActiveUsersCount()
        {
            try
            {
                string query = "SELECT COUNT(*) FROM Users WHERE LastLogin >= DATEADD(HOUR, -1, GETDATE()) AND RoleId IN ('CITZ', 'R001')";
                using (SqlConnection conn = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    conn.Open();
                    object result = cmd.ExecuteScalar();
                    return result != DBNull.Value && result != null ? Convert.ToInt32(result) : 0;
                }
            }
            catch
            {
                return 0;
            }
        }

        private int GetPostsTodayCount()
        {
            try
            {
                string query = "SELECT COUNT(*) FROM UserActivities WHERE ActivityType = 'CommunityPost' AND CAST(Timestamp AS DATE) = CAST(GETDATE() AS DATE)";
                using (SqlConnection conn = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    conn.Open();
                    object result = cmd.ExecuteScalar();
                    return result != DBNull.Value && result != null ? Convert.ToInt32(result) : 0;
                }
            }
            catch
            {
                return 0;
            }
        }

        private int GetEventsThisWeekCount()
        {
            try
            {
                string query = "SELECT COUNT(*) FROM CommunityEvents WHERE EventDate >= CAST(GETDATE() AS DATE) AND EventDate <= DATEADD(DAY, 7, CAST(GETDATE() AS DATE))";
                using (SqlConnection conn = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    conn.Open();
                    object result = cmd.ExecuteScalar();
                    return result != DBNull.Value && result != null ? Convert.ToInt32(result) : 0;
                }
            }
            catch
            {
                return 0;
            }
        }

        private int GetTotalPosts()
        {
            try
            {
                string query = "SELECT COUNT(*) FROM UserActivities WHERE ActivityType = 'CommunityPost'";
                using (SqlConnection conn = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    conn.Open();
                    object result = cmd.ExecuteScalar();
                    return result != DBNull.Value && result != null ? Convert.ToInt32(result) : 0;
                }
            }
            catch
            {
                return 0;
            }
        }

        private string DataTableToJson(DataTable dt)
        {
            try
            {
                var rows = new List<Dictionary<string, object>>();

                foreach (DataRow dr in dt.Rows)
                {
                    var row = new Dictionary<string, object>();
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
            catch
            {
                return "[]";
            }
        }

        private void CreateEmptyPostsTable(DataTable dt)
        {
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
            dt.Columns.Add("IsLiked", typeof(bool));
            dt.Columns.Add("UserName", typeof(string));
            dt.Columns.Add("UserAvatar", typeof(string));
            dt.Columns.Add("UserTitle", typeof(string));
            dt.Columns.Add("UserLevel", typeof(int));
            dt.Columns.Add("TimeAgo", typeof(string));
            dt.Columns.Add("IsPinned", typeof(bool));
        }

        private void SetDefaultData()
        {
            hfPostsData.Value = "[]";
            hfStatsData.Value = "{\"TotalMembers\":0,\"ActiveNow\":0,\"PostsToday\":0,\"EventsThisWeek\":0,\"TotalPosts\":0,\"EngagementRate\":0}";
            hfOnlineUsers.Value = "[]";
            hfEvents.Value = "[]";
        }

        private void ShowAlert(string message)
        {
            string script = string.Format(@"
                <script>
                    alert('{0}');
                </script>",
                message.Replace("'", "\\'"));

            ClientScript.RegisterStartupScript(this.GetType(), "ShowAlert", script, false);
        }
    }

    public class OnlineUser
    {
        public string UserId { get; set; }
        public string Name { get; set; }
        public string Avatar { get; set; }
        public string Status { get; set; }
        public decimal XP { get; set; }
        public int Level { get; set; }
        public bool IsActive { get; set; }
    }

    public class CommunityEvent
    {
        public string EventId { get; set; }
        public string Title { get; set; }
        public string Description { get; set; }
        public string Date { get; set; }
        public string Location { get; set; }
        public string EventType { get; set; }
        public int Participants { get; set; }
        public int MaxParticipants { get; set; }
    }
}