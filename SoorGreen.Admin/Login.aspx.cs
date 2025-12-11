using System;
using System.Data.SqlClient;
using System.Web.Configuration;
using System.Security.Cryptography;
using System.Text;
using System.Linq; // Add this for LINQ support

public partial class LoginPage : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            if (Session["UserID"] != null)
            {
                Response.Redirect("Default.aspx");
            }

            Session.Clear();
        }
    }

    protected void btnLogin_Click(object sender, EventArgs e)
    {
        if (ValidateLogin())
        {
            try
            {
                string connectionString = WebConfigurationManager.ConnectionStrings["SoorGreenDBConnectionString"].ConnectionString;

                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    // UPDATED: Get user data including password hash
                    string query = @"SELECT UserId, FullName, Email, RoleId, IsVerified, Phone, Password
                           FROM Users 
                           WHERE (Email = @LoginId OR Phone = @LoginId)";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        string loginId = txtEmail.Text.Trim();

                        // For phone numbers, remove any non-digit characters
                        if (IsPhoneNumber(loginId))
                        {
                            loginId = new string(loginId.Where(char.IsDigit).ToArray());
                        }

                        cmd.Parameters.AddWithValue("@LoginId", loginId);

                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                // FIXED: Compare hashed passwords
                                string storedHashedPassword = reader["Password"] != null ? reader["Password"].ToString() : "";
                                string inputPassword = txtPassword.Text.Trim();
                                string inputHashedPassword = HashPassword(inputPassword);

                                if (!string.IsNullOrEmpty(storedHashedPassword) && storedHashedPassword == inputHashedPassword)
                                {
                                    // Login successful
                                    string userId = reader["UserId"].ToString();
                                    string userName = reader["FullName"].ToString();
                                    string userEmail = reader["Email"].ToString();
                                    string userRole = reader["RoleId"].ToString();
                                    object isVerified = reader["IsVerified"];
                                    string userPhone = reader["Phone"] != null ? reader["Phone"].ToString() : "";

                                    // Set session variables
                                    Session["UserID"] = userId;
                                    Session["UserName"] = userName;
                                    Session["UserEmail"] = userEmail;
                                    Session["UserRole"] = userRole;
                                    Session["IsVerified"] = isVerified;
                                    Session["UserPhone"] = userPhone;

                                    UpdateLastLogin(userId);
                                    LogAudit(userId, "User Login", "Successful login");

                                    ShowToast("Welcome back, " + userName + "!", "success");

                                    // Redirect based on role
                                    RedirectToDashboard(userRole);
                                }
                                else
                                {
                                    // Password doesn't match
                                    LogAudit(null, "Failed Login", "Invalid password for: " + loginId);
                                    ShowToast("Invalid email/phone or password. Please try again.", "error");
                                }
                            }
                            else
                            {
                                // User not found
                                LogAudit(null, "Failed Login", "User not found: " + loginId);
                                ShowToast("Invalid email/phone or password. Please try again.", "error");
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                LogAudit(null, "Login Error", "Exception: " + ex.Message);
                ShowToast("An error occurred during login. Please try again.", "error");
            }
        }
    }

    private bool IsPhoneNumber(string input)
    {
        // Check if input is likely a phone number (mostly digits)
        if (string.IsNullOrEmpty(input)) return false;

        int digitCount = input.Count(char.IsDigit);
        int totalChars = input.Length;

        // If more than 60% of characters are digits, treat as phone number
        return (digitCount * 100 / totalChars) > 60;
    }

    // FIXED: Password hashing function
    private string HashPassword(string password)
    {
        using (SHA256 sha256Hash = SHA256.Create())
        {
            byte[] bytes = sha256Hash.ComputeHash(Encoding.UTF8.GetBytes(password));

            StringBuilder builder = new StringBuilder();
            for (int i = 0; i < bytes.Length; i++)
            {
                builder.Append(bytes[i].ToString("x2"));
            }
            return builder.ToString();
        }
    }

    private bool ValidateLogin()
    {
        if (txtEmail == null || string.IsNullOrEmpty(txtEmail.Text.Trim()))
        {
            ShowToast("Email or phone number is required.", "warning");
            return false;
        }

        if (txtPassword == null || string.IsNullOrEmpty(txtPassword.Text.Trim()))
        {
            ShowToast("Password is required.", "warning");
            return false;
        }

        return true;
    }

    private void UpdateLastLogin(string userId)
    {
        try
        {
            string connectionString = WebConfigurationManager.ConnectionStrings["SoorGreenDBConnectionString"].ConnectionString;

            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.Open();
                string query = "UPDATE Users SET LastLogin = GETDATE() WHERE UserId = @UserId";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@UserId", userId);
                    cmd.ExecuteNonQuery();
                }
            }
        }
        catch (Exception ex)
        {
            LogAudit(userId, "Update LastLogin Failed", ex.Message);
        }
    }

    private void RedirectToDashboard(string roleId)
    {
        string dashboardUrl = GetDashboardUrl(roleId);

        // If no specific dashboard, redirect to default
        if (string.IsNullOrEmpty(dashboardUrl))
        {
            dashboardUrl = "Default.aspx";
        }

        // Use JavaScript to redirect after toast is shown
        string script = string.Format(@"
            setTimeout(function() {{
                window.location.href = '{0}';
            }}, 1500);
        ", dashboardUrl);

        ClientScript.RegisterStartupScript(this.GetType(), "redirect", script, true);
    }

    private string GetDashboardUrl(string roleId)
    {
        // Based on your database: R001=Citizen, R002=Collector, R003=Company, R004=Admin
        switch (roleId.ToUpper())
        {
            case "R001": // Citizen
            case "CITZ": // Citizen (alternative)
                return "Dashboard.aspx";

            case "R002": // Collector
            case "COLL": // Collector (alternative)
                return "Dashboard.aspx";

            case "R003": // Company
            case "COMP": // Company (alternative)
                return "Dashboard.aspx";

            case "R004": // Admin
            case "ADMN": // Admin (alternative)
                return "Dashboard.aspx";

            default:
                // Check if there's a default dashboard
                if (System.IO.File.Exists(Server.MapPath("Dashboard.aspx")))
                {
                    return "Dashboard.aspx";
                }
                else
                {
                    return "Default.aspx";
                }
        }
    }

    private void LogAudit(string userId, string action, string details)
    {
        try
        {
            string connectionString = WebConfigurationManager.ConnectionStrings["SoorGreenDBConnectionString"].ConnectionString;

            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.Open();
                string query = @"INSERT INTO AuditLogs (AuditId, UserId, Action, Details, Timestamp) 
                           VALUES (@AuditId, @UserId, @Action, @Details, GETDATE())";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    object userIdParam = DBNull.Value;
                    if (!string.IsNullOrEmpty(userId))
                    {
                        userIdParam = userId;
                    }

                    cmd.Parameters.AddWithValue("@AuditId", GenerateAuditId());
                    cmd.Parameters.AddWithValue("@UserId", userIdParam);
                    cmd.Parameters.AddWithValue("@Action", action);
                    cmd.Parameters.AddWithValue("@Details", details);
                    cmd.ExecuteNonQuery();
                }
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("Audit log failed: " + ex.Message);
        }
    }

    private string GenerateAuditId()
    {
        Random random = new Random();
        return string.Format("A{0}", random.Next(1000, 9999));
    }

    private void ShowToast(string message, string type)
    {
        string escapedMessage = message.Replace("'", "\\'");
        string script = string.Format("showToast('{0}', '{1}');", escapedMessage, type);
        ClientScript.RegisterStartupScript(this.GetType(), "toast", script, true);
    }

    // Method to handle password reset link
    protected void btnForgotPassword_Click(object sender, EventArgs e)
    {
        Response.Redirect("ForgotPassword.aspx");
    }
}