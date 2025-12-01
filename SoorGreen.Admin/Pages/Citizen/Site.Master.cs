using SoorGreen.Admin;
using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;

namespace SoorGreen.Admin
{
    public partial class SiteMaster : MasterPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                CheckUserLoginStatus();
                LoadUserStats();
            }
        }

        private void CheckUserLoginStatus()
        {
            if (Session["UserID"] != null && Session["UserName"] != null)
            {
                // User is logged in
                pnlLoggedInUser.Visible = true;
                pnlGuestUser.Visible = false;

                // Set user information
                userName.InnerText = Session["UserName"].ToString();
                sidebarUserName.InnerText = Session["UserName"].ToString();

                string userRoleValue = Session["UserRole"] != null ? Session["UserRole"].ToString() : null;
                userRole.InnerText = GetRoleDisplayName(userRoleValue);
                sidebarUserRole.InnerText = GetRoleDisplayName(userRoleValue);

                // Set user avatars with initials
                SetUserAvatar(Session["UserName"].ToString());
            }
            else
            {
                // User is not logged in
                pnlLoggedInUser.Visible = false;
                pnlGuestUser.Visible = true;
            }
        }

        private void LoadUserStats()
        {
            if (Session["UserID"] != null)
            {
                string userId = Session["UserID"].ToString();

                try
                {
                    using (SqlConnection conn = new SqlConnection(GetConnectionString()))
                    {
                        conn.Open();

                        // Get user credits and XP
                        string query = @"SELECT XP_Credits FROM Users WHERE UserId = @UserId";
                        using (SqlCommand cmd = new SqlCommand(query, conn))
                        {
                            cmd.Parameters.AddWithValue("@UserId", userId);
                            using (SqlDataReader reader = cmd.ExecuteReader())
                            {
                                if (reader.Read())
                                {
                                    decimal credits = reader["XP_Credits"] != DBNull.Value ? Convert.ToDecimal(reader["XP_Credits"]) : 0;
                                    userCredits.InnerText = credits.ToString("0");
                                    userXP.InnerText = credits.ToString("0");
                                }
                            }
                        }

                        // Get pending pickups count
                        string pickupQuery = @"SELECT COUNT(*) FROM PickupRequests pr 
                                            JOIN WasteReports wr ON pr.ReportId = wr.ReportId 
                                            WHERE wr.UserId = @UserId AND pr.Status IN ('Requested', 'Assigned')";
                        using (SqlCommand cmd = new SqlCommand(pickupQuery, conn))
                        {
                            cmd.Parameters.AddWithValue("@UserId", userId);
                            int pendingCount = (int)cmd.ExecuteScalar();
                            pendingPickups.InnerText = pendingCount.ToString();
                        }

                        // Get unread notifications count
                        string notifQuery = "SELECT COUNT(*) FROM Notifications WHERE UserId = @UserId AND IsRead = 0";
                        using (SqlCommand cmd = new SqlCommand(notifQuery, conn))
                        {
                            cmd.Parameters.AddWithValue("@UserId", userId);
                            int unreadCount = (int)cmd.ExecuteScalar();
                            unreadNotifications.InnerText = unreadCount.ToString();
                        }
                    }
                }
                catch (Exception ex)
                {
                    // Log error but don't break the page
                    System.Diagnostics.Debug.WriteLine("Error loading user stats: " + ex.Message);
                }
            }
        }

        private string GetConnectionString()
        {
            return System.Configuration.ConfigurationManager.ConnectionStrings["SoorGreenDBConnection"].ConnectionString;
        }

        private string GetRoleDisplayName(string roleId)
        {
            if (string.IsNullOrEmpty(roleId))
                return "User";

            switch (roleId)
            {
                case "CITZ":
                case "R001":
                    return "Citizen";
                case "COLL":
                case "R002":
                    return "Collector";
                case "ADMN":
                case "R004":
                    return "Administrator";
                case "COMP":
                case "R003":
                    return "Company";
                default:
                    return "User";
            }
        }

        private void SetUserAvatar(string fullName)
        {
            // Get initials from full name
            string initials = "U";
            if (!string.IsNullOrEmpty(fullName))
            {
                string[] nameParts = fullName.Split(' ');
                if (nameParts.Length > 0)
                {
                    initials = nameParts[0].Substring(0, 1).ToUpper();
                    if (nameParts.Length > 1)
                    {
                        initials += nameParts[1].Substring(0, 1).ToUpper();
                    }
                }
            }

            // Set the avatar text
            userAvatar.InnerHtml = initials;
            sidebarUserAvatar.InnerHtml = initials;
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            // Clear all session variables
            Session.Clear();
            Session.Abandon();

            // Redirect to home page
            Response.Redirect("Default.aspx");
        }
    }
}