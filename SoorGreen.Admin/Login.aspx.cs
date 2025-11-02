using System;
using System.Data.SqlClient;
using System.Web.Configuration;

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

                    string query = @"SELECT UserId, FullName, Email, RoleId, IsVerified, Phone
                               FROM Users 
                               WHERE (Email = @Email OR Phone = @Email) AND Phone = @Password";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        string emailValue = "";
                        if (txtEmail != null && txtEmail.Text != null)
                        {
                            emailValue = txtEmail.Text.Trim();
                        }

                        string passwordValue = "";
                        if (txtPassword != null && txtPassword.Text != null)
                        {
                            passwordValue = txtPassword.Text.Trim();
                        }

                        cmd.Parameters.AddWithValue("@Email", emailValue);
                        cmd.Parameters.AddWithValue("@Password", passwordValue);

                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                Session["UserID"] = reader["UserId"].ToString();
                                Session["UserName"] = reader["FullName"].ToString();
                                Session["UserEmail"] = reader["Email"].ToString();
                                Session["UserRole"] = reader["RoleId"].ToString();
                                Session["IsVerified"] = reader["IsVerified"];
                                Session["UserPhone"] = reader["Phone"].ToString();

                                UpdateLastLogin(reader["UserId"].ToString());
                                LogAudit(reader["UserId"].ToString(), "User Login", "Successful login");

                                ShowToast("Welcome back, " + reader["FullName"].ToString() + "!", "success");
                                RedirectToDashboard(reader["RoleId"].ToString());
                            }
                            else
                            {
                                string emailText = "unknown";
                                if (txtEmail != null && txtEmail.Text != null)
                                {
                                    emailText = txtEmail.Text;
                                }
                                LogAudit(null, "Failed Login", "Failed login attempt for email: " + emailText);
                                ShowToast("Invalid email or password. Please try again.", "error");
                            }
                        }
                    }
                }
            }
            catch (SqlException ex)
            {
                LogAudit(null, "Login Error", "Database error: " + ex.Message);
                ShowToast("Login temporarily unavailable. Please try again later.", "error");
            }
            catch (Exception ex)
            {
                LogAudit(null, "Login Error", "System error: " + ex.Message);
                ShowToast("An unexpected error occurred. Please try again.", "error");
            }
        }
    }

    private bool ValidateLogin()
    {
        if (txtEmail == null || string.IsNullOrEmpty(txtEmail.Text))
        {
            ShowToast("Email is required.", "warning");
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
}