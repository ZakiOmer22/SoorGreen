using System;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.Web.Configuration;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using System.Net.Mail;

namespace SoorGreen.Citizen
{
    public partial class Help : System.Web.UI.Page
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

                PrefillUserData();
                InitializeForm();
            }
        }

        private void PrefillUserData()
        {
            try
            {
                string userId = Session["UserId"] != null ? Session["UserId"].ToString() : null;

                if (!string.IsNullOrEmpty(userId))
                {
                    string query = @"
                        SELECT FullName, Email 
                        FROM Users 
                        WHERE UserId = @UserId";

                    using (SqlConnection conn = new SqlConnection(connectionString))
                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@UserId", userId);
                        conn.Open();

                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                object fullNameObj = reader["FullName"];
                                object emailObj = reader["Email"];

                                txtFullName.Text = fullNameObj != null ? fullNameObj.ToString() : "";
                                txtEmail.Text = emailObj != null ? emailObj.ToString() : "";
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error prefilling user data: " + ex.Message);
            }
        }

        private void InitializeForm()
        {
            ddlPriority.SelectedValue = "medium";
            ddlIssueType.SelectedIndex = 0;
        }

        protected void btnSubmitTicket_Click(object sender, EventArgs e)
        {
            try
            {
                if (ValidateSupportTicket())
                {
                    string result = CreateSupportTicket();
                    if (result == "success")
                    {
                        SendEmailNotification();
                        SendInternalNotification();
                        ClearForm();

                        ShowToast("Support Ticket Submitted",
                            "Your support ticket has been submitted successfully. Ticket ID: " + GetLastTicketId(),
                            "success");
                    }
                    else
                    {
                        ShowToast("Submission Error",
                            "Failed to create support ticket: " + result,
                            "error");
                    }
                }
            }
            catch (Exception ex)
            {
                ShowToast("System Error",
                    "An unexpected error occurred: " + ex.Message,
                    "error");
                System.Diagnostics.Debug.WriteLine("Error in btnSubmitTicket_Click: " + ex.Message);
            }
        }

        private bool ValidateSupportTicket()
        {
            if (string.IsNullOrWhiteSpace(txtFullName.Text))
            {
                ShowToast("Validation Error", "Please enter your full name.", "error");
                return false;
            }

            if (string.IsNullOrWhiteSpace(txtEmail.Text) || !IsValidEmail(txtEmail.Text))
            {
                ShowToast("Validation Error", "Please enter a valid email address.", "error");
                return false;
            }

            if (string.IsNullOrWhiteSpace(ddlIssueType.SelectedValue))
            {
                ShowToast("Validation Error", "Please select an issue type.", "error");
                return false;
            }

            if (string.IsNullOrWhiteSpace(txtDescription.Text) || txtDescription.Text.Trim().Length < 10)
            {
                ShowToast("Validation Error",
                    "Please provide a detailed description of your issue (at least 10 characters).",
                    "error");
                return false;
            }

            return true;
        }

        private bool IsValidEmail(string email)
        {
            try
            {
                var addr = new MailAddress(email);
                return addr.Address == email;
            }
            catch
            {
                return false;
            }
        }

        private string CreateSupportTicket()
        {
            SqlConnection conn = null;
            try
            {
                // Test database connection first
                conn = new SqlConnection(connectionString);
                conn.Open();

                string userId = Session["UserId"] != null ? Session["UserId"].ToString() : null;
                string ticketId = GenerateTicketId();

                // First, let's check if the SupportTickets table exists and has the right structure
                string checkTableQuery = @"
                    SELECT COUNT(*) 
                    FROM INFORMATION_SCHEMA.TABLES 
                    WHERE TABLE_NAME = 'SupportTickets'";

                using (SqlCommand checkCmd = new SqlCommand(checkTableQuery, conn))
                {
                    int tableExists = (int)checkCmd.ExecuteScalar();
                    if (tableExists == 0)
                    {
                        return "SupportTickets table does not exist. Please create the table first.";
                    }
                }

                // Check if the table has the required columns
                string checkColumnsQuery = @"
                    SELECT COUNT(*) 
                    FROM INFORMATION_SCHEMA.COLUMNS 
                    WHERE TABLE_NAME = 'SupportTickets' 
                    AND COLUMN_NAME IN ('TicketId', 'UserId', 'FullName', 'Email', 'IssueType', 'Priority', 'Description', 'AttachScreenshot', 'Status', 'CreatedDate')";

                using (SqlCommand checkCmd = new SqlCommand(checkColumnsQuery, conn))
                {
                    int columnCount = (int)checkCmd.ExecuteScalar();
                    if (columnCount < 10)
                    {
                        return "SupportTickets table is missing required columns. Please check the table structure.";
                    }
                }

                string query = @"
                    INSERT INTO SupportTickets (
                        TicketId, UserId, FullName, Email, IssueType, Priority, 
                        Description, AttachScreenshot, Status, CreatedDate
                    ) VALUES (
                        @TicketId, @UserId, @FullName, @Email, @IssueType, @Priority,
                        @Description, @AttachScreenshot, 'Open', GETDATE()
                    )";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@TicketId", ticketId);
                    cmd.Parameters.AddWithValue("@UserId", string.IsNullOrEmpty(userId) ? (object)DBNull.Value : userId);
                    cmd.Parameters.AddWithValue("@FullName", txtFullName.Text.Trim());
                    cmd.Parameters.AddWithValue("@Email", txtEmail.Text.Trim());
                    cmd.Parameters.AddWithValue("@IssueType", ddlIssueType.SelectedValue);
                    cmd.Parameters.AddWithValue("@Priority", ddlPriority.SelectedValue);
                    cmd.Parameters.AddWithValue("@Description", txtDescription.Text.Trim());
                    cmd.Parameters.AddWithValue("@AttachScreenshot", cbAttachScreenshot.Checked);

                    int result = cmd.ExecuteNonQuery();

                    if (result > 0)
                    {
                        Session["LastTicketId"] = ticketId;
                        return "success";
                    }
                    else
                    {
                        return "No rows affected - insert failed";
                    }
                }
            }
            catch (SqlException sqlEx)
            {
                string errorMessage = "SQL Error: " + sqlEx.Message;
                if (sqlEx.Number == 8152) // String or binary data would be truncated
                {
                    errorMessage += " - One of the fields is too long for the database column.";
                }
                else if (sqlEx.Number == 547) // Foreign key violation
                {
                    errorMessage += " - Foreign key constraint violation.";
                }
                else if (sqlEx.Number == 2627) // Primary key violation
                {
                    errorMessage += " - Duplicate ticket ID generated.";
                }
                System.Diagnostics.Debug.WriteLine("SQL Error in CreateSupportTicket: " + sqlEx.Message);
                return errorMessage;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error in CreateSupportTicket: " + ex.Message);
                return "General error: " + ex.Message;
            }
            finally
            {
                if (conn != null && conn.State == ConnectionState.Open)
                {
                    conn.Close();
                }
            }
        }

        private string GenerateTicketId()
        {
            return "TKT" + DateTime.Now.ToString("yyyyMMddHHmmss") + new Random().Next(1000, 9999).ToString();
        }

        private string GetLastTicketId()
        {
            return Session["LastTicketId"] != null ? Session["LastTicketId"].ToString() : "Unknown";
        }

        private void SendEmailNotification()
        {
            try
            {
                // Only attempt to send email if SMTP is configured
                if (!string.IsNullOrEmpty(System.Configuration.ConfigurationManager.AppSettings["SMTP.Server"]))
                {
                    using (MailMessage mail = new MailMessage())
                    {
                        mail.From = new MailAddress("noreply@soorgreen.com");
                        mail.To.Add(txtEmail.Text.Trim());
                        mail.Subject = "Support Ticket Received - SoorGreen";
                        mail.IsBodyHtml = true;

                        string body = string.Format(@"
                            <h3>Thank you for contacting SoorGreen Support!</h3>
                            <p>We have received your support ticket and will get back to you within 4 hours.</p>
                            
                            <div style='background: #f8f9fa; padding: 15px; border-radius: 5px; margin: 15px 0;'>
                                <h4>Ticket Details:</h4>
                                <p><strong>Ticket ID:</strong> {0}</p>
                                <p><strong>Issue Type:</strong> {1}</p>
                                <p><strong>Priority:</strong> {2}</p>
                                <p><strong>Description:</strong> {3}</p>
                            </div>
                            
                            <p>You can track your ticket status through your SoorGreen account.</p>
                            <p>Best regards,<br/>SoorGreen Support Team</p>",
                            GetLastTicketId(),
                            ddlIssueType.SelectedItem.Text,
                            ddlPriority.SelectedItem.Text,
                            txtDescription.Text.Trim());

                        mail.Body = body;

                        using (SmtpClient smtp = new SmtpClient())
                        {
                            smtp.Send(mail);
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error sending email notification: " + ex.Message);
                // Don't show error to user for email failures
            }
        }

        private void SendInternalNotification()
        {
            try
            {
                string adminQuery = @"
                    INSERT INTO Notifications (UserId, Title, Message, IsRead, CreatedAt)
                    SELECT UserId, 'New Support Ticket', 
                           'A new support ticket has been submitted: ' + @TicketId, 
                           0, GETDATE()
                    FROM Users 
                    WHERE UserRole IN ('ADMIN', 'SUPPORT')";

                using (SqlConnection conn = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand(adminQuery, conn))
                {
                    cmd.Parameters.AddWithValue("@TicketId", GetLastTicketId());
                    conn.Open();
                    cmd.ExecuteNonQuery();
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error sending internal notification: " + ex.Message);
                // Don't show error to user for notification failures
            }
        }

        private void ClearForm()
        {
            txtDescription.Text = "";
            ddlIssueType.SelectedIndex = 0;
            ddlPriority.SelectedValue = "medium";
            cbAttachScreenshot.Checked = false;
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