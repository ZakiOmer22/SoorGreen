using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.Configuration;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;

namespace SoorGreen.Citizen
{
    public partial class UserProfile : System.Web.UI.Page
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

                LoadUserProfile();
                LoadUserStats();
                LoadRecentActivity();
            }
        }

        protected void btnUpdateProfile_Click(object sender, EventArgs e)
        {
            if (UpdateUserProfile())
            {
                ShowToast("Profile Updated", "Your profile information has been updated successfully.", "success");
                LoadUserProfile();
            }
            else
            {
                ShowToast("Update Failed", "Failed to update profile. Please try again.", "error");
            }
        }

        protected void btnCancelEdit_Click(object sender, EventArgs e)
        {
            LoadUserProfile();
            btnCancelEdit.Visible = false;
        }

        protected void btnChangePassword_Click(object sender, EventArgs e)
        {
            if (ChangePassword())
            {
                ShowToast("Password Changed", "Your password has been updated successfully.", "success");
                ClearPasswordFields();
            }
            else
            {
                ShowToast("Password Change Failed", "Failed to change password. Please check your current password.", "error");
            }
        }

        protected void btnExportData_Click(object sender, EventArgs e)
        {
            ShowToast("Export Started", "Your data export has been initiated. You will receive an email shortly.", "info");
        }

        protected void btnDeleteAccount_Click(object sender, EventArgs e)
        {
            ShowToast("Account Deletion", "Account deletion request has been submitted for review.", "info");
        }

        private void LoadUserProfile()
        {
            try
            {
                string userId = Session["UserId"] != null ? Session["UserId"].ToString() : "R001";

                string query = @"
                    SELECT u.UserId, u.FullName, u.Phone, u.Email, u.XP_Credits, u.CreatedAt, u.LastLogin, u.IsVerified, r.RoleName
                    FROM Users u
                    INNER JOIN Roles r ON u.RoleId = r.RoleId
                    WHERE u.UserId = @UserId";

                using (SqlConnection conn = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@UserId", userId);
                    conn.Open();

                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            // Set profile information
                            txtUserId.Text = reader["UserId"].ToString();
                            txtFullName.Text = reader["FullName"].ToString();
                            txtPhone.Text = reader["Phone"].ToString();
                            txtEmail.Text = reader["Email"] != DBNull.Value ? reader["Email"].ToString() : "";

                            // Set display elements
                            userName.InnerText = reader["FullName"].ToString();
                            userRole.InnerText = reader["RoleName"].ToString();

                            // Set avatar initials
                            userAvatar.InnerText = GetInitials(reader["FullName"].ToString());

                            // Format dates
                            DateTime createdAt = Convert.ToDateTime(reader["CreatedAt"]);
                            txtCreatedAt.Text = createdAt.ToString("MMM dd, yyyy");

                            if (reader["LastLogin"] != DBNull.Value)
                            {
                                DateTime lastLogin = Convert.ToDateTime(reader["LastLogin"]);
                                txtLastLogin.Text = lastLogin.ToString("MMM dd, yyyy 'at' hh:mm tt");
                            }
                            else
                            {
                                txtLastLogin.Text = "Never";
                            }

                            // Set verification badge
                            bool isVerified = Convert.ToBoolean(reader["IsVerified"]);
                            if (isVerified)
                            {
                                verificationBadge.InnerHtml = "<i class='fas fa-check-circle'></i>Verified Account";
                                verificationBadge.Attributes["class"] = "verification-badge";
                            }
                            else
                            {
                                verificationBadge.InnerHtml = "<i class='fas fa-times-circle'></i>Unverified Account";
                                verificationBadge.Attributes["class"] = "verification-badge unverified";
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error loading user profile: " + ex.Message);
                ShowToast("Error", "Failed to load profile data.", "error");
            }
        }

        private void LoadUserStats()
        {
            try
            {
                string userId = Session["UserId"] != null ? Session["UserId"].ToString() : "R001";

                string query = @"
                    -- Total waste reports
                    SELECT COUNT(*) AS TotalReports FROM WasteReports WHERE UserId = @UserId;
                    
                    -- Total completed pickups
                    SELECT COUNT(*) AS TotalPickups 
                    FROM PickupRequests pr
                    JOIN WasteReports wr ON pr.ReportId = wr.ReportId
                    WHERE wr.UserId = @UserId AND pr.Status = 'Collected';
                    
                    -- Total kg recycled
                    SELECT ISNULL(SUM(pv.VerifiedKg), 0) AS TotalKg
                    FROM PickupVerifications pv
                    JOIN PickupRequests pr ON pv.PickupId = pr.PickupId
                    JOIN WasteReports wr ON pr.ReportId = wr.ReportId
                    WHERE wr.UserId = @UserId AND pr.Status = 'Collected';";

                using (SqlConnection conn = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@UserId", userId);
                    conn.Open();

                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        // Total Reports
                        if (reader.Read())
                        {
                            // Find the control safely
                            HtmlGenericControl totalReportsControl = FindControl("totalReports") as HtmlGenericControl;
                            if (totalReportsControl != null)
                            {
                                totalReportsControl.InnerText = reader["TotalReports"].ToString();
                            }
                        }

                        // Total Pickups
                        if (reader.NextResult() && reader.Read())
                        {
                            HtmlGenericControl totalPickupsControl = FindControl("totalPickups") as HtmlGenericControl;
                            if (totalPickupsControl != null)
                            {
                                totalPickupsControl.InnerText = reader["TotalPickups"].ToString();
                            }
                        }

                        // Total Kg Recycled
                        if (reader.NextResult() && reader.Read())
                        {
                            HtmlGenericControl kgRecycledControl = FindControl("kgRecycled") as HtmlGenericControl;
                            if (kgRecycledControl != null)
                            {
                                decimal totalKg = Convert.ToDecimal(reader["TotalKg"]);
                                kgRecycledControl.InnerText = totalKg.ToString("N0");
                            }
                        }

                        // XP Credits - Load from user data
                        LoadXPCredits();
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error loading user stats: " + ex.Message);
                SetDefaultStats();
            }
        }

        private void LoadXPCredits()
        {
            try
            {
                string userId = Session["UserId"] != null ? Session["UserId"].ToString() : "R001";

                string query = "SELECT XP_Credits FROM Users WHERE UserId = @UserId";

                using (SqlConnection conn = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@UserId", userId);
                    conn.Open();

                    object result = cmd.ExecuteScalar();
                    if (result != null && result != DBNull.Value)
                    {
                        HtmlGenericControl xpCreditsControl = FindControl("xpCredits") as HtmlGenericControl;
                        if (xpCreditsControl != null)
                        {
                            decimal xpCredits = Convert.ToDecimal(result);
                            xpCreditsControl.InnerText = xpCredits.ToString("N0");
                        }
                    }
                    else
                    {
                        HtmlGenericControl xpCreditsControl = FindControl("xpCredits") as HtmlGenericControl;
                        if (xpCreditsControl != null)
                        {
                            xpCreditsControl.InnerText = "0";
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error loading XP credits: " + ex.Message);
                HtmlGenericControl xpCreditsControl = FindControl("xpCredits") as HtmlGenericControl;
                if (xpCreditsControl != null)
                {
                    xpCreditsControl.InnerText = "0";
                }
            }
        }

        private void SetDefaultStats()
        {
            // Set default values for all stats
            HtmlGenericControl totalReportsControl = FindControl("totalReports") as HtmlGenericControl;
            HtmlGenericControl totalPickupsControl = FindControl("totalPickups") as HtmlGenericControl;
            HtmlGenericControl kgRecycledControl = FindControl("kgRecycled") as HtmlGenericControl;
            HtmlGenericControl xpCreditsControl = FindControl("xpCredits") as HtmlGenericControl;

            if (totalReportsControl != null) totalReportsControl.InnerText = "0";
            if (totalPickupsControl != null) totalPickupsControl.InnerText = "0";
            if (kgRecycledControl != null) kgRecycledControl.InnerText = "0";
            if (xpCreditsControl != null) xpCreditsControl.InnerText = "0";
        }

        private void LoadRecentActivity()
        {
            try
            {
                string userId = Session["UserId"] != null ? Session["UserId"].ToString() : "R001";

                string query = @"
                    SELECT TOP 10 ActivityType, Description, Points, Timestamp
                    FROM UserActivities 
                    WHERE UserId = @UserId 
                    ORDER BY Timestamp DESC";

                using (SqlConnection conn = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@UserId", userId);
                    conn.Open();

                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.HasRows)
                        {
                            string html = "<div class='activity-list'>";
                            while (reader.Read())
                            {
                                string activityType = reader["ActivityType"].ToString();
                                string description = reader["Description"].ToString();
                                decimal points = Convert.ToDecimal(reader["Points"]);
                                DateTime timestamp = Convert.ToDateTime(reader["Timestamp"]);
                                string timeAgo = GetTimeAgo(timestamp);
                                string icon = GetActivityIcon(activityType);

                                html += string.Format(@"
                                    <div class='activity-item'>
                                        <div class='activity-content'>
                                            <i class='{0}'></i> {1}
                                        </div>
                                        <div class='activity-meta'>
                                            <span>{2}</span>
                                            <span class='activity-points'>+{3} credits</span>
                                        </div>
                                    </div>",
                                    icon,
                                    Server.HtmlEncode(description),
                                    timeAgo,
                                    points.ToString("N0"));
                            }
                            html += "</div>";
                            activityList.InnerHtml = html;
                        }
                        else
                        {
                            activityList.InnerHtml = @"
                                <div class='empty-state'>
                                    <div class='empty-state-icon'>
                                        <i class='fas fa-history'></i>
                                    </div>
                                    <h4 class='empty-state-title'>No Activity Yet</h4>
                                    <p class='empty-state-description'>Your recent activities will appear here once you start using the platform.</p>
                                </div>";
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error loading recent activity: " + ex.Message);
                activityList.InnerHtml = "<p class='text-muted'>Error loading activity history.</p>";
            }
        }

        private bool UpdateUserProfile()
        {
            try
            {
                string userId = Session["UserId"] != null ? Session["UserId"].ToString() : "R001";
                string fullName = txtFullName.Text.Trim();
                string phone = txtPhone.Text.Trim();
                string email = txtEmail.Text.Trim();

                string query = @"
                    UPDATE Users 
                    SET FullName = @FullName, Phone = @Phone, Email = @Email
                    WHERE UserId = @UserId";

                using (SqlConnection conn = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@UserId", userId);
                    cmd.Parameters.AddWithValue("@FullName", fullName);
                    cmd.Parameters.AddWithValue("@Phone", phone);
                    cmd.Parameters.AddWithValue("@Email", string.IsNullOrEmpty(email) ? DBNull.Value : (object)email);

                    conn.Open();
                    int result = cmd.ExecuteNonQuery();
                    return result > 0;
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error updating user profile: " + ex.Message);
                return false;
            }
        }

        private bool ChangePassword()
        {
            try
            {
                string userId = Session["UserId"] != null ? Session["UserId"].ToString() : "R001";
                string currentPassword = txtCurrentPassword.Text.Trim();
                string newPassword = txtNewPassword.Text.Trim();

                // First verify current password
                string verifyQuery = "SELECT Password FROM Users WHERE UserId = @UserId";

                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    // Verify current password
                    using (SqlCommand verifyCmd = new SqlCommand(verifyQuery, conn))
                    {
                        verifyCmd.Parameters.AddWithValue("@UserId", userId);
                        object result = verifyCmd.ExecuteScalar();
                        string storedPassword = "";

                        if (result != null && result != DBNull.Value)
                        {
                            storedPassword = result.ToString();
                        }

                        if (storedPassword != currentPassword)
                        {
                            return false; // Current password doesn't match
                        }
                    }

                    // Update password
                    string updateQuery = "UPDATE Users SET Password = @NewPassword WHERE UserId = @UserId";
                    using (SqlCommand updateCmd = new SqlCommand(updateQuery, conn))
                    {
                        updateCmd.Parameters.AddWithValue("@UserId", userId);
                        updateCmd.Parameters.AddWithValue("@NewPassword", newPassword);

                        int result = updateCmd.ExecuteNonQuery();
                        return result > 0;
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error changing password: " + ex.Message);
                return false;
            }
        }

        private string GetInitials(string fullName)
        {
            if (string.IsNullOrEmpty(fullName)) return "SG";

            var names = fullName.Split(' ');
            if (names.Length >= 2)
            {
                return (names[0].Substring(0, 1) + names[1].Substring(0, 1)).ToUpper();
            }
            else if (fullName.Length >= 2)
            {
                return fullName.Substring(0, 2).ToUpper();
            }
            return "SG";
        }

        private string GetTimeAgo(DateTime date)
        {
            TimeSpan timeSince = DateTime.Now - date;

            if (timeSince.TotalMinutes < 1) return "just now";
            if (timeSince.TotalMinutes < 60) return string.Format("{0} minutes ago", (int)timeSince.TotalMinutes);
            if (timeSince.TotalHours < 24) return string.Format("{0} hours ago", (int)timeSince.TotalHours);
            if (timeSince.TotalDays < 7) return string.Format("{0} days ago", (int)timeSince.TotalDays);

            return date.ToString("MMM dd, yyyy");
        }

        private string GetActivityIcon(string activityType)
        {
            switch (activityType.ToLower())
            {
                case "wastereport":
                    return "fas fa-trash-alt";
                case "pickupcomplete":
                    return "fas fa-check-circle";
                case "communitypost":
                    return "fas fa-comment";
                case "rewardpoints":
                    return "fas fa-coins";
                default:
                    return "fas fa-circle";
            }
        }

        private void ClearPasswordFields()
        {
            txtCurrentPassword.Text = "";
            txtNewPassword.Text = "";
            txtConfirmPassword.Text = "";
        }

        private void ShowToast(string title, string message, string type)
        {
            string script = string.Format("showToast('{0}', '{1}', '{2}');",
                title.Replace("'", "\\'"),
                message.Replace("'", "\\'"),
                type);
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ToastScript", script, true);
        }
    }
}