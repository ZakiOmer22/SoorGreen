using System;
using System.Data.SqlClient;
using System.Web.Configuration;
using System.Security.Cryptography;
using System.Text;

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
                           WHERE Email = @Email OR Phone = @Email";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        string emailValue = (txtEmail != null && txtEmail.Text != null) ? txtEmail.Text.Trim() : "";
                        string passwordValue = (txtPassword != null && txtPassword.Text != null) ? txtPassword.Text.Trim() : "";

                        cmd.Parameters.AddWithValue("@Email", emailValue);

                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                // FIXED: Compare hashed passwords - .NET 4.0 compatible
                                string storedHashedPassword = reader["Password"] != null ? reader["Password"].ToString() : "";
                                string inputHashedPassword = HashPassword(passwordValue);

                                if (storedHashedPassword == inputHashedPassword)
                                {
                                    // Login successful
                                    Session["UserID"] = reader["UserId"].ToString();
                                    Session["UserName"] = reader["FullName"].ToString();
                                    Session["UserEmail"] = reader["Email"].ToString();
                                    Session["UserRole"] = reader["RoleId"].ToString();
                                    Session["IsVerified"] = reader["IsVerified"];
                                    Session["UserPhone"] = reader["Phone"] != null ? reader["Phone"].ToString() : "";

                                    UpdateLastLogin(reader["UserId"].ToString());
                                    LogAudit(reader["UserId"].ToString(), "User Login", "Successful login");

                                    ShowToast("Welcome back, " + reader["FullName"].ToString() + "!", "success");
                                    RedirectToDashboard(reader["RoleId"].ToString());
                                }
                                else
                                {
                                    // Password doesn't match
                                    LogAudit(null, "Failed Login", "Invalid password for: " + emailValue);
                                    ShowToast("Invalid email/phone or password. Please try again.", "error");
                                }
                            }
                            else
                            {
                                // User not found
                                LogAudit(null, "Failed Login", "User not found: " + emailValue);
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

    // FIXED: Added password hashing function to match ForgotPassword page
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
        if (txtEmail == null || string.IsNullOrEmpty(txtEmail.Text))
        {
            ShowToast("Email or phone number is required.", "warning");
            return false;
        }

        if (txtPassword == null || string.IsNullOrEmpty(txtPassword.Text))
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

        string script = string.Format(@"
            setTimeout(function() {{
                window.location.href = '{0}';
            }}, 1500);
        ", dashboardUrl);

        ClientScript.RegisterStartupScript(this.GetType(), "redirect", script, true);
    }

    private string GetDashboardUrl(string roleId)
    {
        switch (roleId)
        {
            case "CITZ":
            case "R001":
                return "Dashboard.aspx";
            case "COLL":
            case "R002":
                return "Dashboard.aspx";
            case "ADMN":
            case "R004":
                return "Dashboard.aspx";
            default:
                return "Default.aspx";
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
                    if (userId != null)
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

    // NEW: Method to handle password reset link
    protected void btnForgotPassword_Click(object sender, EventArgs e)
    {
        Response.Redirect("ForgotPassword.aspx");
    }
}