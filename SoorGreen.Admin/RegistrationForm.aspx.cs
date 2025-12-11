using System;
using System.Data.SqlClient;
using System.Web.Configuration;
using System.Web.UI.WebControls;
using System.Security.Cryptography;
using System.Text;

public partial class RegistrationForm : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            string roleId = Request.QueryString["role"];
            if (!string.IsNullOrEmpty(roleId))
            {
                Session["SelectedRoleId"] = roleId;

                // Simple role name mapping
                if (roleId == "CITZ")
                {
                    lblRole.Text = "Citizen";
                    lblRoleName.Text = "Citizen";
                    pnlCitizenFields.Visible = true;
                }
                else if (roleId == "COLL")
                {
                    lblRole.Text = "Waste Collector";
                    lblRoleName.Text = "Waste Collector";
                    pnlCollectorFields.Visible = true;
                }
                else if (roleId == "ADMN")
                {
                    lblRole.Text = "Administrator";
                    lblRoleName.Text = "Administrator";
                }
                else
                {
                    Response.Redirect("Register.aspx");
                }
            }
            else
            {
                Response.Redirect("Register.aspx");
            }
        }
    }

    protected void btnRegister_Click(object sender, EventArgs e)
    {
        if (ValidateRegistration())
        {
            try
            {
                // Get connection string from web.config
                string connectionString = WebConfigurationManager.ConnectionStrings["SoorGreenDBConnectionString"].ConnectionString;

                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    // Check for duplicate email before proceeding
                    if (IsEmailExists(txtEmail.Text.Trim(), conn))
                    {
                        ShowToast("Email already exists. Please use a different email address.", "error");
                        return;
                    }

                    // Check for duplicate phone before proceeding
                    if (IsPhoneExists(txtPhone.Text.Trim(), conn))
                    {
                        ShowToast("Phone number already exists. Please use a different phone number.", "error");
                        return;
                    }

                    // Generate UserId
                    string userId = GenerateUserId(conn);
                    string roleId = Session["SelectedRoleId"] as string ?? "CITZ";

                    // Hash the password
                    string hashedPassword = HashPassword(txtPassword.Text);

                    string query = @"INSERT INTO Users (UserId, FullName, Phone, Email, Password, RoleId, IsVerified, CreatedAt, XP_Credits) 
                                   VALUES (@UserId, @FullName, @Phone, @Email, @Password, @RoleId, 1, GETDATE(), 0)";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@UserId", userId);
                        cmd.Parameters.AddWithValue("@FullName", txtFullName.Text.Trim());
                        cmd.Parameters.AddWithValue("@Phone", txtPhone.Text.Trim());
                        cmd.Parameters.AddWithValue("@Email", txtEmail.Text.Trim());
                        cmd.Parameters.AddWithValue("@Password", hashedPassword);
                        cmd.Parameters.AddWithValue("@RoleId", MapRoleId(roleId));

                        int result = cmd.ExecuteNonQuery();

                        if (result > 0)
                        {
                            // Registration successful
                            Session["UserID"] = userId;
                            Session["UserName"] = txtFullName.Text.Trim();
                            Session["UserEmail"] = txtEmail.Text.Trim();
                            Session["UserRole"] = roleId;
                            Session["IsVerified"] = true;

                            // Add welcome reward points
                            AddWelcomeReward(userId, conn);

                            // Log the registration
                            LogAudit(userId, "User Registration", string.Format("New {0} registered: {1}", GetRoleName(roleId), txtFullName.Text), conn);

                            // Show success toast
                            ShowToast("Welcome to SoorGreen " + txtFullName.Text.Trim() + "! Your account has been created successfully.", "success");

                            // Show success step
                            ShowStep(3);
                        }
                        else
                        {
                            ShowToast("Registration failed. Please try again.", "error");
                        }
                    }
                }
            }
            catch (SqlException ex)
            {
                // Handle duplicate key violations
                if (ex.Number == 2627 || ex.Number == 2601)
                {
                    ShowToast("Email or phone number already exists. Please use different credentials.", "error");
                }
                else
                {
                    ShowToast("An error occurred during registration. Please try again.", "error");
                    LogAudit(null, "Registration Error", "SQL Error: " + ex.Message, null);
                }
            }
            catch (Exception ex)
            {
                ShowToast("An unexpected error occurred. Please try again.", "error");
                LogAudit(null, "Registration Error", "System Error: " + ex.Message, null);
            }
        }
    }

    private bool ValidateRegistration()
    {
        // Server-side validation
        if (string.IsNullOrEmpty(txtFullName.Text.Trim()))
        {
            ShowToast("Full name is required.", "warning");
            return false;
        }

        if (string.IsNullOrEmpty(txtPhone.Text.Trim()))
        {
            ShowToast("Phone number is required.", "warning");
            return false;
        }

        if (string.IsNullOrEmpty(txtEmail.Text.Trim()))
        {
            ShowToast("Email address is required.", "warning");
            return false;
        }

        if (!IsValidEmail(txtEmail.Text.Trim()))
        {
            ShowToast("Please enter a valid email address.", "warning");
            return false;
        }

        if (string.IsNullOrEmpty(txtPassword.Text))
        {
            ShowToast("Password is required.", "warning");
            return false;
        }

        if (txtPassword.Text.Length < 6)
        {
            ShowToast("Password must be at least 6 characters long.", "warning");
            return false;
        }

        if (txtPassword.Text != txtConfirmPassword.Text)
        {
            ShowToast("Passwords do not match.", "warning");
            return false;
        }

        if (!cbTerms.Checked)
        {
            ShowToast("You must accept the terms and conditions.", "warning");
            return false;
        }

        return true;
    }

    private bool IsEmailExists(string email, SqlConnection conn)
    {
        string query = "SELECT COUNT(*) FROM Users WHERE Email = @Email";
        using (SqlCommand cmd = new SqlCommand(query, conn))
        {
            cmd.Parameters.AddWithValue("@Email", email);
            int count = (int)cmd.ExecuteScalar();
            return count > 0;
        }
    }

    private bool IsPhoneExists(string phone, SqlConnection conn)
    {
        string query = "SELECT COUNT(*) FROM Users WHERE Phone = @Phone";
        using (SqlCommand cmd = new SqlCommand(query, conn))
        {
            cmd.Parameters.AddWithValue("@Phone", phone);
            int count = (int)cmd.ExecuteScalar();
            return count > 0;
        }
    }

    private bool IsValidEmail(string email)
    {
        try
        {
            var addr = new System.Net.Mail.MailAddress(email);
            return addr.Address == email;
        }
        catch
        {
            return false;
        }
    }

    private string GenerateUserId(SqlConnection conn)
    {
        string roleId = Session["SelectedRoleId"] as string ?? "CITZ";
        string mappedRoleId = MapRoleId(roleId);

        string prefix = "";
        switch (mappedRoleId)
        {
            case "R001": prefix = "CI"; break; // Citizen
            case "R002": prefix = "CL"; break; // Collector
            case "R004": prefix = "AD"; break; // Admin
            default: prefix = "US"; break;
        }

        // Generate a unique ID
        string query = "SELECT ISNULL(MAX(CAST(SUBSTRING(UserId, 3, LEN(UserId)) AS INT)), 0) + 1 FROM Users WHERE UserId LIKE @Prefix + '%'";
        using (SqlCommand cmd = new SqlCommand(query, conn))
        {
            cmd.Parameters.AddWithValue("@Prefix", prefix);
            int nextId = (int)cmd.ExecuteScalar();
            return prefix + nextId.ToString("D2");
        }
    }

    private string MapRoleId(string roleCode)
    {
        switch (roleCode)
        {
            case "CITZ": return "R001"; // Citizen
            case "COLL": return "R002"; // Collector
            case "ADMN": return "R004"; // Admin
            default: return "R001"; // Default to Citizen
        }
    }

    private string HashPassword(string password)
    {
        using (SHA256 sha256 = SHA256.Create())
        {
            byte[] bytes = sha256.ComputeHash(Encoding.UTF8.GetBytes(password));
            StringBuilder builder = new StringBuilder();
            for (int i = 0; i < bytes.Length; i++)
            {
                builder.Append(bytes[i].ToString("x2"));
            }
            return builder.ToString();
        }
    }

    private void AddWelcomeReward(string userId, SqlConnection conn)
    {
        try
        {
            // Generate reward ID
            string rewardId = "RW" + new Random().Next(100, 999).ToString();

            string query = @"INSERT INTO RewardPoints (RewardId, UserId, Amount, Type, Reference, CreatedAt) 
                           VALUES (@RewardId, @UserId, 100, 'Welcome Bonus', 'New User Registration', GETDATE())";

            using (SqlCommand cmd = new SqlCommand(query, conn))
            {
                cmd.Parameters.AddWithValue("@RewardId", rewardId);
                cmd.Parameters.AddWithValue("@UserId", userId);
                cmd.ExecuteNonQuery();
            }
        }
        catch (Exception ex)
        {
            LogAudit(userId, "Welcome Reward Failed", ex.Message, conn);
        }
    }

    private string GetRoleName(string roleId)
    {
        switch (roleId)
        {
            case "CITZ": return "Citizen";
            case "COLL": return "Waste Collector";
            case "ADMN": return "Administrator";
            default: return "User";
        }
    }

    private void LogAudit(string userId, string action, string details, SqlConnection conn)
    {
        try
        {
            // Generate audit ID
            string auditId = "AL" + new Random().Next(100, 999).ToString();

            string query = @"INSERT INTO AuditLogs (AuditId, UserId, Action, Details, Timestamp) 
                           VALUES (@AuditId, @UserId, @Action, @Details, GETDATE())";

            using (SqlCommand cmd = new SqlCommand(query, conn))
            {
                cmd.Parameters.AddWithValue("@AuditId", auditId);
                cmd.Parameters.AddWithValue("@UserId", string.IsNullOrEmpty(userId) ? (object)DBNull.Value : userId);
                cmd.Parameters.AddWithValue("@Action", action);
                cmd.Parameters.AddWithValue("@Details", details);
                cmd.ExecuteNonQuery();
                Response.Redirect("Login.aspx");
            }
        }
        catch (Exception ex)
        {
            // Log audit failure but don't break registration
            System.Diagnostics.Debug.WriteLine("Audit log failed: " + ex.Message);
        }
    }

    private void ShowToast(string message, string type)
    {
        // Escape single quotes in the message
        string escapedMessage = message.Replace("'", "\\'");
        // Fixed: Using string.Format instead of string interpolation
        string script = string.Format("showToast('{0}', '{1}');", escapedMessage, type);
        ClientScript.RegisterStartupScript(this.GetType(), "toast", script, true);
    }

    private void ShowStep(int stepNumber)
    {
        // Fixed: Using string.Format instead of string interpolation
        string script = string.Format("showStep({0});", stepNumber);
        ClientScript.RegisterStartupScript(this.GetType(), "showStep", script, true);
    }
}