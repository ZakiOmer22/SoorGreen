using System;
using System.Data.SqlClient;
using System.Web.Configuration;
using System.Web.UI.WebControls;

public partial class RegistrationForm : System.Web.UI.Page
{
    // We'll find controls dynamically to avoid compilation issues
    //private TextBox txtFullName => (TextBox)FindControl("txtFullName");
    //private TextBox txtPhone => (TextBox)FindControl("txtPhone");
    //private TextBox txtEmail => (TextBox)FindControl("txtEmail");
    //private TextBox txtPassword => (TextBox)FindControl("txtPassword");
    //private TextBox txtConfirmPassword => (TextBox)FindControl("txtConfirmPassword");
    //private TextBox txtAddress => (TextBox)FindControl("txtAddress");
    //private TextBox txtCompany => (TextBox)FindControl("txtCompany");
    //private DropDownList ddlMunicipality => (DropDownList)FindControl("ddlMunicipality");
    //private CheckBox cbTerms => (CheckBox)FindControl("cbTerms");
    //private CheckBox cbNewsletter => (CheckBox)FindControl("cbNewsletter");
    //private Label lblRole => (Label)FindControl("lblRole");
    //private Label lblRoleName => (Label)FindControl("lblRoleName");
    //private Panel pnlCitizenFields => (Panel)FindControl("pnlCitizenFields");
    //private Panel pnlCollectorFields => (Panel)FindControl("pnlCollectorFields");

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

                    // Generate UserId
                    string userId = GenerateUserId();
                    string roleId = Session["SelectedRoleId"] as string ?? "CITZ";

                    string query = @"INSERT INTO Users (UserId, FullName, Phone, Email, RoleId, IsVerified, CreatedAt, XP_Credits) 
                                   VALUES (@UserId, @FullName, @Phone, @Email, @RoleId, 1, GETDATE(), 0)";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@UserId", userId);
                        cmd.Parameters.AddWithValue("@FullName", txtFullName.Text.Trim());
                        cmd.Parameters.AddWithValue("@Phone", txtPhone.Text.Trim()); // FIXED: Use actual phone field
                        cmd.Parameters.AddWithValue("@Email", txtEmail.Text.Trim());
                        cmd.Parameters.AddWithValue("@RoleId", MapRoleId(roleId)); // Use mapped role ID

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
                            AddWelcomeReward(userId);

                            // Log the registration
                            // Using string.Format()
                            LogAudit(userId, "User Registration", string.Format("New {0} registered: {1}", GetRoleName(roleId), txtFullName.Text));

                            // Using string concatenation
                            //LogAudit(userId, "User Registration", "New " + GetRoleName(roleId) + " registered: " + txtFullName.Text);
                            // Show success toast
                            ShowToast("Welcome to SoorGreen " + txtFullName.Text.Trim() + "! Your account has been created successfully.", "success");

                            // Redirect based on role
                            if (roleId == "ADMN")
                            {
                                Response.Redirect("AdminDashboard.aspx");
                            }
                            else
                            {
                                // Show success step for other roles
                                ShowStep(3);
                            }
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
                if (ex.Number == 2627) // Unique constraint violation
                {
                    ShowToast("Email or phone number already exists. Please use different credentials.", "error");
                }
                else
                {
                    ShowToast("Database error occurred: " + ex.Message + "Please try again.", "error");
                    LogAudit(null, "Registration Error", "Database error: " + ex.Message);
                }
            }
            catch (Exception ex)
            {
                ShowToast("An unexpected error occurred: " + ex.Message, "error");
                LogAudit(null, "Registration Error", "System error "+ ex.Message);
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

    private string GenerateUserId()
    {
        string prefix = Session["SelectedRoleId"] as string ?? "CITZ";
        Random random = new Random();
        // Generate exactly 4 characters as per your schema
        return prefix.Substring(0, 2) + random.Next(10, 99);
    }

    // Map role IDs to match your database
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

    private void AddWelcomeReward(string userId)
    {
        try
        {
            string connectionString = WebConfigurationManager.ConnectionStrings["SoorGreenDBConnectionString"].ConnectionString;

            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.Open();
                string query = @"INSERT INTO RewardPoints (RewardId, UserId, Amount, Type, Reference, CreatedAt) 
                           VALUES (@RewardId, @UserId, 100, 'Welcome Bonus', 'New User Registration', GETDATE())";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@RewardId", GenerateRewardId());
                    cmd.Parameters.AddWithValue("@UserId", userId);
                    cmd.ExecuteNonQuery();
                }
            }
        }
        catch (Exception ex)
        {
            LogAudit(userId, "Welcome Reward Failed", ex.Message);
        }
    }

    private string GenerateRewardId()
    {
        Random random = new Random();
        return "R" + random.Next(100, 999);
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
                    cmd.Parameters.AddWithValue("@AuditId", GenerateAuditId());
                    cmd.Parameters.AddWithValue("@UserId", userId ?? (object)DBNull.Value);
                    cmd.Parameters.AddWithValue("@Action", action);
                    cmd.Parameters.AddWithValue("@Details", details);
                    cmd.ExecuteNonQuery();
                }
            }
        }
        catch (Exception ex)
        {
            // Log audit failure but don't break registration
            System.Diagnostics.Debug.WriteLine("Audit log failed: " + ex.Message);
        }
    }

    private string GenerateAuditId()
    {
        Random random = new Random();
        return "A" + random.Next(100, 999);
    }

    private void ShowToast(string message, string type)
    {
        string script = @"showToast('" + message.Replace("'", "\\'") + "', '" + type + "');";
        ClientScript.RegisterStartupScript(this.GetType(), "toast", script, true);
    }

    private void ShowStep(int stepNumber)
    {
        string script = string.Format(@"showStep({0});", stepNumber);
        ClientScript.RegisterStartupScript(this.GetType(), "showStep", script, true);
    }
}