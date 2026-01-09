using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;

namespace SoorGreen
{
    public partial class SiteMaster : System.Web.UI.MasterPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadUserData();
                UpdateMenuVisibility();
                LoadNotificationCounts();
            }
        }

        private void LoadUserData()
        {
            if (Session["UserId"] != null && Session["UserRole"] != null)
            {
                string userId = Session["UserId"].ToString();
                string userRoleId = Session["UserRole"].ToString();

                // Show logged in user panel
                pnlLoggedInUser.Visible = true;
                pnlGuestUser.Visible = false;

                using (SqlConnection conn = new SqlConnection(GetConnectionString()))
                {
                    conn.Open();

                    // Get user details
                    string query = @"SELECT FullName, Phone, Email, RoleId, XP_Credits 
                                   FROM Users WHERE UserId = @UserId";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@UserId", userId);

                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                string fullName = reader["FullName"].ToString();
                                string roleId = reader["RoleId"].ToString();
                                decimal credits = 0;

                                // Safely parse credits
                                if (reader["XP_Credits"] != DBNull.Value)
                                {
                                    decimal.TryParse(reader["XP_Credits"].ToString(), out credits);
                                }

                                // Set user name - Check if controls exist first
                                if (userName != null)
                                    userName.InnerText = fullName;

                                if (sidebarUserName != null)
                                    sidebarUserName.InnerText = fullName;

                                // Get role name
                                string roleName = GetRoleName(roleId);

                                // Set role - Check if controls exist first
                                if (userRole != null)
                                    userRole.InnerText = roleName;

                                if (sidebarUserRole != null)
                                    sidebarUserRole.InnerText = roleName;

                                // Set credits
                                if (userCredits != null)
                                    userCredits.InnerText = credits.ToString("0");

                                // Get initials for avatar
                                string initials = GetInitials(fullName);

                                if (lblAvatarInitials != null)
                                    lblAvatarInitials.Text = initials;

                                if (lblSidebarAvatar != null)
                                    lblSidebarAvatar.Text = initials;

                                // Set appropriate dashboard link based on role
                                if (lnkDashboard != null && lnkMainDashboard != null)
                                {
                                    if (roleId == "COLL" || roleId == "R002")
                                    {
                                        lnkDashboard.NavigateUrl = "Dashboard.aspx";
                                        lnkMainDashboard.NavigateUrl = "Dashboard.aspx";
                                    }
                                    else
                                    {
                                        lnkDashboard.NavigateUrl = "Dashboard.aspx";
                                        lnkMainDashboard.NavigateUrl = "Dashboard.aspx";
                                    }
                                }
                            }
                        }
                    }
                }
            }
            else
            {
                // Guest user
                pnlLoggedInUser.Visible = false;
                pnlGuestUser.Visible = true;

                if (sidebarUserName != null)
                    sidebarUserName.InnerText = "Guest User";

                if (sidebarUserRole != null)
                    sidebarUserRole.InnerText = "Guest";

                if (lblSidebarAvatar != null)
                    lblSidebarAvatar.Text = "G";
            }
        }

        private void UpdateMenuVisibility()
        {
            if (Session["UserRole"] != null)
            {
                string role = Session["UserRole"].ToString();

                // Show collector menu for collectors
                if (pnlCollectorMenu != null)
                    pnlCollectorMenu.Visible = (role == "COLL" || role == "R002");
            }
            else
            {
                if (pnlCollectorMenu != null)
                    pnlCollectorMenu.Visible = false;
            }
        }

        private void LoadNotificationCounts()
        {
            if (Session["UserId"] != null)
            {
                string userId = Session["UserId"].ToString();
                string userRole = Session["UserRole"] != null ? Session["UserRole"].ToString() : "";

                using (SqlConnection conn = new SqlConnection(GetConnectionString()))
                {
                    conn.Open();

                    // Get unread notifications count
                    string query = @"SELECT COUNT(*) FROM Notifications 
                                   WHERE UserId = @UserId AND IsRead = 0";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@UserId", userId);
                        object result = cmd.ExecuteScalar();
                        int notificationCount = result != null ? Convert.ToInt32(result) : 0;

                        if (unreadNotifications != null)
                            unreadNotifications.InnerText = notificationCount.ToString();
                    }

                    // Get pending pickups count (for citizens)
                    if ((userRole == "CITZ" || userRole == "R001") && pendingPickups != null)
                    {
                        query = @"SELECT COUNT(*) FROM PickupRequests pr
                                JOIN WasteReports wr ON pr.ReportId = wr.ReportId
                                WHERE wr.UserId = @UserId 
                                AND pr.Status IN ('Requested', 'Assigned')";

                        using (SqlCommand cmd = new SqlCommand(query, conn))
                        {
                            cmd.Parameters.AddWithValue("@UserId", userId);
                            object result = cmd.ExecuteScalar();
                            int pendingCount = result != null ? Convert.ToInt32(result) : 0;
                            pendingPickups.InnerText = pendingCount.ToString();
                        }
                    }

                    // Get active pickups count (for collectors)
                    if ((userRole == "COLL" || userRole == "R002") && activePickupsBadge != null)
                    {
                        query = @"SELECT COUNT(*) FROM PickupRequests 
                                WHERE CollectorId = @UserId 
                                AND Status IN ('Assigned', 'In Progress')";

                        using (SqlCommand cmd = new SqlCommand(query, conn))
                        {
                            cmd.Parameters.AddWithValue("@UserId", userId);
                            object result = cmd.ExecuteScalar();
                            int activeCount = result != null ? Convert.ToInt32(result) : 0;
                            activePickupsBadge.InnerText = activeCount.ToString();
                        }
                    }
                }
            }
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            // Clear all session variables
            Session.Clear();
            Session.Abandon();

            // Clear authentication cookie
            if (Request.Cookies["ASP.NET_SessionId"] != null)
            {
                Response.Cookies["ASP.NET_SessionId"].Value = string.Empty;
                Response.Cookies["ASP.NET_SessionId"].Expires = DateTime.Now.AddMonths(-20);
            }

            // Redirect to login page
            Response.Redirect("~/Login.aspx");
        }

        // Helper Methods
        private string GetRoleName(string roleId)
        {
            switch (roleId)
            {
                case "CITZ":
                case "R001":
                    return "Citizen";
                case "COLL":
                case "R002":
                    return "Collector";
                case "ADMN":
                case "R003":
                    return "Administrator";
                case "MUNC":
                case "R004":
                    return "Municipality";
                default:
                    return "User";
            }
        }

        private string GetInitials(string fullName)
        {
            if (string.IsNullOrWhiteSpace(fullName))
                return "?";

            string[] names = fullName.Split(' ');
            if (names.Length >= 2)
            {
                return string.Format("{0}{1}",
                    names[0][0].ToString().ToUpper(),
                    names[1][0].ToString().ToUpper());
            }
            else if (names.Length == 1 && names[0].Length >= 2)
            {
                return names[0].Substring(0, 2).ToUpper();
            }
            else
            {
                return "U";
            }
        }

        private string GetConnectionString()
        {
            return System.Configuration.ConfigurationManager.ConnectionStrings["SoorGreenDB"] != null
                ? System.Configuration.ConfigurationManager.ConnectionStrings["SoorGreenDB"].ConnectionString
                : "Server=localhost;Database=SoorGreenDB;Integrated Security=True;";
        }

        // Public methods that can be accessed from content pages
        public void UpdateSidebarStats(decimal credits, decimal xp)
        {
            if (userCredits != null)
                userCredits.InnerText = credits.ToString("0");
        }

        public void ShowSuccessMessage(string message)
        {
            string script = string.Format(@"<script>
                showNotification('{0}', 'success');
            </script>", message.Replace("'", "\\'"));
            ScriptManager.RegisterStartupScript(this, GetType(), "ShowSuccess", script, false);
        }

        public void ShowErrorMessage(string message)
        {
            string script = string.Format(@"<script>
                showNotification('{0}', 'error');
            </script>", message.Replace("'", "\\'"));
            ScriptManager.RegisterStartupScript(this, GetType(), "ShowError", script, false);
        }
    }
}