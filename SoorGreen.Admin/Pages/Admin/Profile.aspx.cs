using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.Configuration;
using System.Web.Services;
using System.Web.UI;

namespace SoorGreen.Admin.Admin
{
    public partial class UserProfile : System.Web.UI.Page
    {
        private string connectionString = WebConfigurationManager.ConnectionStrings["SoorGreenDBConnectionString"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // Check Session instead of Forms Authentication
                if (Session["UserID"] == null)
                {
                    Response.Redirect("~/Login.aspx");
                    return;
                }
                LoadData();
            }
        }

        protected void btnLoadProfile_Click(object sender, EventArgs e)
        {
            LoadData();
        }

        protected void LoadData()
        {
            try
            {
                string userId = Session["UserID"] != null ? Session["UserID"].ToString() : null;

                if (string.IsNullOrEmpty(userId))
                {
                    Response.Redirect("~/Login.aspx");
                    return;
                }

                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    // Load user profile data
                    string userQuery = @"
                        SELECT 
                            u.UserId, u.FullName, u.Email, u.Phone, r.RoleName,
                            u.TotalLogins, u.LastLogin, u.CreatedDate, u.IsActive,
                            u.TwoFactorEnabled, u.ActiveSessions
                        FROM Users u
                        INNER JOIN Roles r ON u.RoleId = r.RoleId
                        WHERE u.UserId = @UserId";

                    using (SqlCommand cmd = new SqlCommand(userQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@UserId", userId);

                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                var profile = new
                                {
                                    userId = reader["UserId"].ToString(),
                                    fullName = reader["FullName"].ToString(),
                                    email = reader["Email"].ToString(),
                                    phone = reader["Phone"].ToString(),
                                    role = reader["RoleName"].ToString(),
                                    totalLogins = Convert.ToInt32(reader["TotalLogins"]),
                                    lastActive = GetTimeAgo(Convert.ToDateTime(reader["LastLogin"])),
                                    memberSince = GetDaysAgo(Convert.ToDateTime(reader["CreatedDate"])),
                                    status = Convert.ToBoolean(reader["IsActive"]) ? "Active" : "Inactive",
                                    twoFactorEnabled = Convert.ToBoolean(reader["TwoFactorEnabled"]),
                                    activeSessions = Convert.ToInt32(reader["ActiveSessions"])
                                };

                                var serializer = new System.Web.Script.Serialization.JavaScriptSerializer();
                                hfProfileData.Value = serializer.Serialize(profile);
                            }
                        }
                    }

                    // Load recent activities
                    string activityQuery = @"
                        SELECT TOP 5 ActivityType, Description, ActivityDate, IconClass, ActivityClass
                        FROM UserActivities 
                        WHERE UserId = @UserId
                        ORDER BY ActivityDate DESC";

                    using (SqlCommand cmd = new SqlCommand(activityQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@UserId", userId);

                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            var activities = new System.Collections.ArrayList();
                            while (reader.Read())
                            {
                                activities.Add(new
                                {
                                    icon = reader["IconClass"].ToString(),
                                    title = reader["ActivityType"].ToString(),
                                    description = reader["Description"].ToString(),
                                    time = GetTimeAgo(Convert.ToDateTime(reader["ActivityDate"])),
                                    type = reader["ActivityClass"].ToString()
                                });
                            }

                            var serializer = new System.Web.Script.Serialization.JavaScriptSerializer();
                            hfActivityData.Value = serializer.Serialize(activities);
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                hfProfileData.Value = "{}";
                hfActivityData.Value = "[]";
                // Log the error
                System.Diagnostics.Debug.WriteLine("Error loading profile: " + ex.Message);
            }
        }

        [WebMethod]
        public static string UpdateProfile(string fullName, string email, string phone)
        {
            try
            {
                // Get user ID from Session instead of User.Identity
                string userId = System.Web.HttpContext.Current.Session["UserID"] != null ? System.Web.HttpContext.Current.Session["UserID"].ToString() : null;
                if (string.IsNullOrEmpty(userId))
                {
                    return "ERROR: User not authenticated";
                }

                string connectionString = WebConfigurationManager.ConnectionStrings["SoorGreenDBConnectionString"].ConnectionString;

                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    string query = @"
                        UPDATE Users 
                        SET FullName = @FullName, Email = @Email, Phone = @Phone, LastUpdated = GETDATE()
                        WHERE UserId = @UserId";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@FullName", fullName);
                        cmd.Parameters.AddWithValue("@Email", email);
                        cmd.Parameters.AddWithValue("@Phone", phone);
                        cmd.Parameters.AddWithValue("@UserId", userId);

                        int rowsAffected = cmd.ExecuteNonQuery();

                        if (rowsAffected > 0)
                        {
                            // Update session data
                            System.Web.HttpContext.Current.Session["UserName"] = fullName;
                            System.Web.HttpContext.Current.Session["UserEmail"] = email;
                            System.Web.HttpContext.Current.Session["UserPhone"] = phone;

                            // Log the activity
                            LogUserActivity(userId, "Profile Updated", "Updated personal information", "fa-user-edit", "info");
                            return "SUCCESS: Profile updated successfully";
                        }
                        else
                        {
                            return "ERROR: Profile not found or update failed";
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                return "ERROR: " + ex.Message;
            }
        }

        [WebMethod]
        public static string ChangePassword(string currentPassword, string newPassword)
        {
            try
            {
                string userId = System.Web.HttpContext.Current.Session["UserID"] != null ? System.Web.HttpContext.Current.Session["UserID"].ToString() : null;
                if (string.IsNullOrEmpty(userId))
                {
                    return "ERROR: User not authenticated";
                }

                string connectionString = WebConfigurationManager.ConnectionStrings["SoorGreenDBConnectionString"].ConnectionString;

                // First verify current password against database
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();
                    string verifyQuery = "SELECT UserId FROM Users WHERE UserId = @UserId AND Phone = @CurrentPassword";

                    using (SqlCommand cmd = new SqlCommand(verifyQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@UserId", userId);
                        cmd.Parameters.AddWithValue("@CurrentPassword", currentPassword);

                        var result = cmd.ExecuteScalar();
                        if (result == null)
                        {
                            return "ERROR: Current password is incorrect";
                        }
                    }

                    // Update password
                    string updateQuery = "UPDATE Users SET Phone = @NewPassword WHERE UserId = @UserId";
                    using (SqlCommand cmd = new SqlCommand(updateQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@NewPassword", newPassword);
                        cmd.Parameters.AddWithValue("@UserId", userId);

                        int rowsAffected = cmd.ExecuteNonQuery();

                        if (rowsAffected > 0)
                        {
                            LogUserActivity(userId, "Password Changed", "Account password was updated", "fa-shield-alt", "warning");
                            return "SUCCESS: Password changed successfully";
                        }
                        else
                        {
                            return "ERROR: Failed to change password";
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                return "ERROR: " + ex.Message;
            }
        }

        [WebMethod]
        public static string ToggleTwoFactorAuth(bool enable)
        {
            try
            {
                string userId = System.Web.HttpContext.Current.Session["UserID"] != null ? System.Web.HttpContext.Current.Session["UserID"].ToString() : null;
                if (string.IsNullOrEmpty(userId))
                {
                    return "ERROR: User not authenticated";
                }

                string connectionString = WebConfigurationManager.ConnectionStrings["SoorGreenDBConnectionString"].ConnectionString;

                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    string query = "UPDATE Users SET TwoFactorEnabled = @TwoFactorEnabled WHERE UserId = @UserId";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@TwoFactorEnabled", enable);
                        cmd.Parameters.AddWithValue("@UserId", userId);

                        int rowsAffected = cmd.ExecuteNonQuery();

                        if (rowsAffected > 0)
                        {
                            string action = enable ? "enabled" : "disabled";
                            LogUserActivity(userId, "2FA Updated", "Two-factor authentication " + action, "fa-mobile-alt", "info");
                            return "SUCCESS: Two-factor authentication " + action;
                        }
                        else
                        {
                            return "ERROR: Failed to update two-factor authentication settings";
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                return "ERROR: " + ex.Message;
            }
        }

        [WebMethod]
        public static string ExportUserData()
        {
            try
            {
                string userId = System.Web.HttpContext.Current.Session["UserID"] != null ? System.Web.HttpContext.Current.Session["UserID"].ToString() : null;
                if (string.IsNullOrEmpty(userId))
                {
                    return "ERROR: User not authenticated";
                }

                string connectionString = WebConfigurationManager.ConnectionStrings["SoorGreenDBConnectionString"].ConnectionString;

                // Generate export data
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    // Get user data for export
                    string exportQuery = @"
                        SELECT u.UserId, u.FullName, u.Email, u.Phone, u.CreatedDate, u.LastLogin, u.TotalLogins,
                               (SELECT COUNT(*) FROM UserActivities ua WHERE ua.UserId = u.UserId) as TotalActivities
                        FROM Users u
                        WHERE u.UserId = @UserId";

                    using (SqlCommand cmd = new SqlCommand(exportQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@UserId", userId);

                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                // In real scenario, you'd generate a CSV/JSON file and email it
                                // For now, just log the request
                                LogUserActivity(userId, "Data Export", "User requested data export", "fa-download", "info");
                                return "SUCCESS: Data export initiated. You will receive an email when it's ready.";
                            }
                        }
                    }
                }

                return "ERROR: Failed to process data export request";
            }
            catch (Exception ex)
            {
                return "ERROR: " + ex.Message;
            }
        }

        private static void LogUserActivity(string userId, string activityType, string description, string iconClass, string activityClass)
        {
            try
            {
                string connectionString = WebConfigurationManager.ConnectionStrings["SoorGreenDBConnectionString"].ConnectionString;

                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    string query = @"
                        INSERT INTO UserActivities (UserId, ActivityType, Description, ActivityDate, IconClass, ActivityClass)
                        VALUES (@UserId, @ActivityType, @Description, GETDATE(), @IconClass, @ActivityClass)";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@UserId", userId);
                        cmd.Parameters.AddWithValue("@ActivityType", activityType);
                        cmd.Parameters.AddWithValue("@Description", description);
                        cmd.Parameters.AddWithValue("@IconClass", iconClass);
                        cmd.Parameters.AddWithValue("@ActivityClass", activityClass);

                        cmd.ExecuteNonQuery();
                    }
                }
            }
            catch (Exception ex)
            {
                // Log to debug output if database logging fails
                System.Diagnostics.Debug.WriteLine("Failed to log activity: " + ex.Message);
            }
        }

        private string GetTimeAgo(DateTime date)
        {
            TimeSpan span = DateTime.Now - date;

            if (span.Days > 365)
                return (span.Days / 365) + " years ago";
            if (span.Days > 30)
                return (span.Days / 30) + " months ago";
            if (span.Days > 0)
                return span.Days + " days ago";
            if (span.Hours > 0)
                return span.Hours + " hours ago";
            if (span.Minutes > 0)
                return span.Minutes + " minutes ago";

            return "Just now";
        }

        private string GetDaysAgo(DateTime date)
        {
            TimeSpan span = DateTime.Now - date;
            return span.Days.ToString();
        }
    }
}