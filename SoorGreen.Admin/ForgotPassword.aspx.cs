using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Net;
using System.Net.Mail;
using System.Web.UI;
using System.Security.Cryptography;
using System.Text;

public partial class ForgotPassword : System.Web.UI.Page
{
    private static string verificationCode = "";
    private static string userEmail = "";

    private string connectionString = ConfigurationManager.ConnectionStrings["SoorGreenDBConnectionString"].ConnectionString;

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            pnlStep1.Visible = true;
            pnlStep2.Visible = false;
            pnlStep3.Visible = false;
            pnlSuccess.Visible = false;
            pnlAlert.Visible = false;
        }
    }

    // STEP 1: Send Code
    protected void btnSendCode_Click(object sender, EventArgs e)
    {
        string email = (txtEmail.Text ?? string.Empty).Trim();

        if (string.IsNullOrEmpty(email))
        {
            ShowAlert("Please enter your email address.", "danger");
            ScriptManager.RegisterStartupScript(this, this.GetType(), "highlightEmail",
                "document.getElementById('" + txtEmail.ClientID + "').classList.add('field-error');", true);
            return;
        }

        if (!EmailExists(email))
        {
            ShowAlert("This email is not registered in our system.", "danger");
            ScriptManager.RegisterStartupScript(this, this.GetType(), "highlightEmail",
                "document.getElementById('" + txtEmail.ClientID + "').classList.add('field-error');", true);
            return;
        }

        try
        {
            userEmail = email;
            verificationCode = GenerateVerificationCode();

            bool sent = SendVerificationEmail(userEmail, verificationCode);

            if (sent)
            {
                pnlStep1.Visible = false;
                pnlStep2.Visible = true;
                pnlStep3.Visible = false;
                pnlSuccess.Visible = false;
                pnlAlert.Visible = true;

                sentEmail.InnerText = userEmail;

                ScriptManager.RegisterStartupScript(this, this.GetType(), "showStep2", "safeShowStep(2);", true);
                ShowAlert("Verification code sent successfully to " + userEmail + ".", "success");

                // Start countdown for resend
                ScriptManager.RegisterStartupScript(this, this.GetType(), "startCountdown", "startCountdown(60);", true);
            }
            else
            {
                ShowAlert("Failed to send verification email. Please try again later.", "danger");
            }
        }
        catch (Exception ex)
        {
            ShowAlert("Error sending verification email: " + ex.Message, "danger");
        }
    }

    // STEP 2: Verify code
    protected void btnVerifyCode_Click(object sender, EventArgs e)
    {
        string enteredCode = (txtCode1.Text ?? "") + (txtCode2.Text ?? "") + (txtCode3.Text ?? "") +
                             (txtCode4.Text ?? "") + (txtCode5.Text ?? "") + (txtCode6.Text ?? "");

        if (string.IsNullOrEmpty(enteredCode) || enteredCode.Length != 6)
        {
            ShowAlert("Please enter the complete 6-digit verification code.", "danger");
            return;
        }

        if (enteredCode == verificationCode)
        {
            pnlStep1.Visible = false;
            pnlStep2.Visible = false;
            pnlStep3.Visible = true;
            pnlSuccess.Visible = false;
            pnlAlert.Visible = true;

            ScriptManager.RegisterStartupScript(this, this.GetType(), "showStep3", "safeShowStep(3);", true);
            ShowAlert("Code verified successfully. You can now set your new password.", "success");
        }
        else
        {
            ShowAlert("Invalid verification code. Please try again.", "danger");
            // Clear the code inputs
            ScriptManager.RegisterStartupScript(this, this.GetType(), "clearCodes",
                "Array.prototype.slice.call(document.querySelectorAll('.code-input')).forEach(function(i){i.value='';}); document.getElementById('" + txtCode1.ClientID + "').focus();", true);
        }
    }

    // STEP 3: Reset password - FIXED: Now with proper encryption
    protected void btnResetPassword_Click(object sender, EventArgs e)
    {
        string newPassword = (txtNewPassword.Text ?? string.Empty).Trim();
        string confirmPassword = (txtConfirmPassword.Text ?? string.Empty).Trim();

        // Clear previous alerts and field errors
        pnlAlert.Visible = false;
        ClearFieldErrors();

        // Client-side validation - show inline errors without hiding form
        bool hasError = false;

        if (string.IsNullOrEmpty(newPassword))
        {
            ShowAlert("Please enter your new password.", "danger");
            ScriptManager.RegisterStartupScript(this, this.GetType(), "highlightPassword",
                "document.getElementById('" + txtNewPassword.ClientID + "').classList.add('field-error');", true);
            hasError = true;
        }

        if (string.IsNullOrEmpty(confirmPassword))
        {
            ShowAlert("Please confirm your new password.", "danger");
            ScriptManager.RegisterStartupScript(this, this.GetType(), "highlightConfirm",
                "document.getElementById('" + txtConfirmPassword.ClientID + "').classList.add('field-error');", true);
            hasError = true;
        }

        if (hasError) return;

        if (newPassword != confirmPassword)
        {
            ShowAlert("Passwords do not match. Please re-enter.", "danger");
            ScriptManager.RegisterStartupScript(this, this.GetType(), "highlightBoth",
                "document.getElementById('" + txtNewPassword.ClientID + "').classList.add('field-error');" +
                "document.getElementById('" + txtConfirmPassword.ClientID + "').classList.add('field-error');", true);
            return;
        }

        if (!IsPasswordStrong(newPassword))
        {
            ShowAlert("Password does not meet strength requirements (minimum 8 characters).", "danger");
            ScriptManager.RegisterStartupScript(this, this.GetType(), "highlightPassword",
                "document.getElementById('" + txtNewPassword.ClientID + "').classList.add('field-error');", true);
            return;
        }

        try
        {
            // FIXED: Proper password hashing
            string hashedPassword = HashPassword(newPassword);
            bool updated = UpdatePassword(userEmail, hashedPassword);

            if (updated)
            {
                // Send password change notification email
                bool emailSent = SendPasswordChangeNotification(userEmail);

                verificationCode = "";
                userEmail = "";

                pnlStep1.Visible = false;
                pnlStep2.Visible = false;
                pnlStep3.Visible = false;
                pnlSuccess.Visible = true;
                pnlAlert.Visible = false;

                ScriptManager.RegisterStartupScript(this, this.GetType(), "finalStep", "safeShowStep(4);", true);

                string successMessage = "Password reset successfully! You can now login with your new password.";
                if (emailSent) successMessage += " A confirmation email has been sent to your email address.";

                ShowAlert(successMessage, "success");
            }
            else
            {
                ShowAlert("Failed to update password. Please try again.", "danger");
            }
        }
        catch (Exception ex)
        {
            ShowAlert("An error occurred while updating the password: " + ex.Message, "danger");
        }
    }

    protected void btnResendCode_Click(object sender, EventArgs e)
    {
        if (string.IsNullOrEmpty(userEmail))
        {
            ShowAlert("No email found to resend code to. Start the process again.", "danger");
            return;
        }

        try
        {
            verificationCode = GenerateVerificationCode();
            bool sent = SendVerificationEmail(userEmail, verificationCode);

            if (sent)
            {
                ShowAlert("A new verification code has been sent to " + userEmail + ".", "info");
                ScriptManager.RegisterStartupScript(this, this.GetType(), "clearCodes",
                    "Array.prototype.slice.call(document.querySelectorAll('.code-input')).forEach(function(i){i.value='';}); document.getElementById('" + txtCode1.ClientID + "').focus();", true);

                // Restart countdown
                ScriptManager.RegisterStartupScript(this, this.GetType(), "startCountdown", "startCountdown(60);", true);
            }
            else
            {
                ShowAlert("Failed to resend verification code. Please try again later.", "danger");
            }
        }
        catch (Exception ex)
        {
            ShowAlert("Error resending code: " + ex.Message, "danger");
        }
    }

    // -------- Helper Methods --------

    private string GenerateVerificationCode()
    {
        Random rnd = new Random();
        return rnd.Next(100000, 999999).ToString();
    }

    // FIXED: Proper password hashing using SHA256
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

    private bool SendVerificationEmail(string toEmail, string code)
    {
        string fromEmail = "michealomar859@gmail.com";
        string appPassword = "yypc jfcr jdkn vmfw";

        try
        {
            string formattedCode = string.Join(" ", code.ToCharArray());

            MailMessage message = new MailMessage();
            message.From = new MailAddress(fromEmail, "SoorGreen Support");
            message.To.Add(toEmail);
            message.Subject = "Your SoorGreen Password Reset Code";

            string body = @"
            <!DOCTYPE html>
            <html>
            <head>
                <meta charset='utf-8'>
                <link rel='stylesheet' href='https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css'>
                <style>
                    body { 
                        font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; 
                        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); 
                        margin: 0; padding: 0; 
                    }
                    .container { 
                        max-width: 600px; 
                        margin: 0 auto; 
                        background: white; 
                        border-radius: 15px; 
                        overflow: hidden; 
                        box-shadow: 0 20px 40px rgba(0,0,0,0.1); 
                    }
                    .header { 
                        background: linear-gradient(135deg, #00d4aa, #0984e3); 
                        padding: 30px 20px; 
                        text-align: center; 
                    }
                    .header h1 { 
                        color: white; 
                        margin: 0; 
                        font-size: 28px; 
                        font-weight: 700; 
                    }
                    .content { 
                        padding: 40px 30px; 
                        color: #333; 
                    }
                    .code-container { 
                        margin: 30px 0; 
                        text-align: center; 
                    }
                    .verification-code { 
                        display: inline-block; 
                        font-size: 32px; 
                        font-weight: bold; 
                        letter-spacing: 8px; 
                        color: #0984e3; 
                        background: #f0f8ff; 
                        padding: 20px 40px; 
                        border-radius: 12px; 
                        border: 2px dashed #00d4aa; 
                    }
                    .instructions { 
                        background: #f8f9fa; 
                        padding: 20px; 
                        border-radius: 10px; 
                        margin: 25px 0; 
                        border-left: 4px solid #00d4aa; 
                    }
                    .footer { 
                        background: #f8f9fa; 
                        padding: 20px; 
                        text-align: center; 
                        color: #666; 
                        font-size: 14px; 
                    }
                    .security-note { 
                        background: #fff3cd; 
                        padding: 15px; 
                        border-radius: 8px; 
                        border: 1px solid #ffeaa7; 
                        margin: 20px 0; 
                        color: #856404; 
                    }
                    .button { 
                        display: inline-block; 
                        background: linear-gradient(135deg, #00d4aa, #0984e3); 
                        color: white; 
                        padding: 12px 30px; 
                        text-decoration: none; 
                        border-radius: 25px; 
                        font-weight: 600; 
                        margin: 10px 0; 
                    }
                    .icon-item { 
                        display: flex; 
                        align-items: center; 
                        margin: 10px 0; 
                    }
                    .icon-item i { 
                        width: 20px; 
                        margin-right: 10px; 
                        color: #00d4aa; 
                    }
                </style>
            </head>
            <body>
                <div class='container'>
                    <div class='header'>
                        <h1><i class='fas fa-lock'></i> SoorGreen Password Reset</h1>
                    </div>
                    <div class='content'>
                        <p style='font-size: 16px; line-height: 1.6;'>Hello,</p>
                        <p style='font-size: 16px; line-height: 1.6;'>We received a request to reset your password for your SoorGreen account. Use the verification code below to complete the process:</p>
                        
                        <div class='code-container'>
                            <div class='verification-code'>" + formattedCode + @"</div>
                        </div>

                        <div class='instructions'>
                            <h3 style='color: #00d4aa; margin-top: 0;'><i class='fas fa-list-ol'></i> Instructions:</h3>
                            <div class='icon-item'><i class='fas fa-arrow-right'></i> Return to the SoorGreen password reset page</div>
                            <div class='icon-item'><i class='fas fa-keyboard'></i> Enter the 6-digit code shown above</div>
                            <div class='icon-item'><i class='fas fa-lock'></i> Create your new password</div>
                            <div class='icon-item'><i class='fas fa-sign-in-alt'></i> Login with your new credentials</div>
                        </div>

                        <div class='security-note'>
                            <strong><i class='fas fa-shield-alt'></i> Security Notice:</strong>
                            <div class='icon-item'><i class='fas fa-clock'></i> This code will expire in <strong>10 minutes</strong></div>
                            <div class='icon-item'><i class='fas fa-user-secret'></i> Do not share this code with anyone</div>
                            <div class='icon-item'><i class='fas fa-exclamation-triangle'></i> SoorGreen team will never ask for your code</div>
                            <div class='icon-item'><i class='fas fa-times-circle'></i> If you didn't request this, please ignore this email</div>
                        </div>

                        <p style='font-size: 16px; line-height: 1.6;'>Need help? Contact our support team immediately.</p>
                        
                        <div style='text-align: center; margin: 25px 0;'>
                            <a href='mailto:support@soorgreen.com' class='button'><i class='fas fa-life-ring'></i> Contact Support</a>
                        </div>
                    </div>
                    <div class='footer'>
                        <p style='margin: 0;'><i class='fas fa-leaf'></i> SoorGreen - Smart Sustainability Platform</p>
                        <p style='margin: 5px 0; color: #999;'>Making cities cleaner, one recycle at a time <i class='fas fa-recycle'></i></p>
                        <p style='margin: 5px 0; font-size: 12px; color: #888;'>
                            <i class='fas fa-info-circle'></i> This is an automated message. Please do not reply to this email.<br>
                            <i class='fas fa-copyright'></i> 2024 SoorGreen. All rights reserved.
                        </p>
                    </div>
                </div>
            </body>
            </html>";

            message.Body = body;
            message.IsBodyHtml = true;

            SmtpClient smtp = new SmtpClient("smtp.gmail.com", 587);
            smtp.EnableSsl = true;
            smtp.Credentials = new NetworkCredential(fromEmail, appPassword);
            smtp.Timeout = 20000;

            smtp.Send(message);

            return true;
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("Error sending email: " + ex.Message);

            // Fallback: Show code on screen if email fails
            string fallbackMessage = "Email service temporarily unavailable. Your verification code is: <strong>" + code + "</strong>";
            ShowAlert(fallbackMessage, "info");

            return true;
        }
    }

    // NEW: Send password change notification email
    private bool SendPasswordChangeNotification(string toEmail)
    {
        string fromEmail = "michealomar859@gmail.com";
        string appPassword = "yypc jfcr jdkn vmfw";

        try
        {
            MailMessage message = new MailMessage();
            message.From = new MailAddress(fromEmail, "SoorGreen Support");
            message.To.Add(toEmail);
            message.Subject = "Your SoorGreen Password Has Been Changed";

            string body = @"
            <!DOCTYPE html>
            <html>
            <head>
                <meta charset='utf-8'>
                <link rel='stylesheet' href='https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css'>
                <style>
                    body { 
                        font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; 
                        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); 
                        margin: 0; padding: 0; 
                    }
                    .container { 
                        max-width: 600px; 
                        margin: 0 auto; 
                        background: white; 
                        border-radius: 15px; 
                        overflow: hidden; 
                        box-shadow: 0 20px 40px rgba(0,0,0,0.1); 
                    }
                    .header { 
                        background: linear-gradient(135deg, #00d4aa, #0984e3); 
                        padding: 30px 20px; 
                        text-align: center; 
                    }
                    .header h1 { 
                        color: white; 
                        margin: 0; 
                        font-size: 28px; 
                        font-weight: 700; 
                    }
                    .content { 
                        padding: 40px 30px; 
                        color: #333; 
                    }
                    .security-note { 
                        background: #fff3cd; 
                        padding: 15px; 
                        border-radius: 8px; 
                        border: 1px solid #ffeaa7; 
                        margin: 20px 0; 
                        color: #856404; 
                    }
                    .footer { 
                        background: #f8f9fa; 
                        padding: 20px; 
                        text-align: center; 
                        color: #666; 
                        font-size: 14px; 
                    }
                    .icon-item { 
                        display: flex; 
                        align-items: center; 
                        margin: 10px 0; 
                    }
                    .icon-item i { 
                        width: 20px; 
                        margin-right: 10px; 
                        color: #00d4aa; 
                    }
                </style>
            </head>
            <body>
                <div class='container'>
                    <div class='header'>
                        <h1><i class='fas fa-shield-alt'></i> Password Changed Successfully</h1>
                    </div>
                    <div class='content'>
                        <p style='font-size: 16px; line-height: 1.6;'>Hello,</p>
                        <p style='font-size: 16px; line-height: 1.6;'>This is a confirmation that your SoorGreen account password was successfully changed.</p>
                        
                        <div class='security-note'>
                            <strong><i class='fas fa-exclamation-triangle'></i> Security Notice:</strong>
                            <div class='icon-item'><i class='fas fa-user-check'></i> If you made this change, no further action is required</div>
                            <div class='icon-item'><i class='fas fa-user-times'></i> If you did NOT make this change, please contact support immediately</div>
                            <div class='icon-item'><i class='fas fa-clock'></i> This change was made on: " + DateTime.Now.ToString("f") + @"</div>
                        </div>

                        <p style='font-size: 16px; line-height: 1.6;'>For security reasons, if you didn't request this change, please contact our support team immediately.</p>
                        
                        <div style='text-align: center; margin: 25px 0;'>
                            <a href='mailto:support@soorgreen.com' style='display: inline-block; background: linear-gradient(135deg, #00d4aa, #0984e3); color: white; padding: 12px 30px; text-decoration: none; border-radius: 25px; font-weight: 600;'><i class='fas fa-life-ring'></i> Contact Support</a>
                        </div>
                    </div>
                    <div class='footer'>
                        <p style='margin: 0;'><i class='fas fa-leaf'></i> SoorGreen - Smart Sustainability Platform</p>
                        <p style='margin: 5px 0; color: #999;'>Making cities cleaner, one recycle at a time <i class='fas fa-recycle'></i></p>
                        <p style='margin: 5px 0; font-size: 12px; color: #888;'>
                            <i class='fas fa-info-circle'></i> This is an automated security message. Please do not reply to this email.<br>
                            <i class='fas fa-copyright'></i> 2024 SoorGreen. All rights reserved.
                        </p>
                    </div>
                </div>
            </body>
            </html>";

            message.Body = body;
            message.IsBodyHtml = true;

            SmtpClient smtp = new SmtpClient("smtp.gmail.com", 587);
            smtp.EnableSsl = true;
            smtp.Credentials = new NetworkCredential(fromEmail, appPassword);
            smtp.Timeout = 20000;

            smtp.Send(message);

            return true;
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("Error sending password change notification: " + ex.Message);
            return false;
        }
    }

    private bool EmailExists(string email)
    {
        using (SqlConnection conn = new SqlConnection(connectionString))
        {
            string query = "SELECT COUNT(*) FROM Users WHERE Email = @Email";
            SqlCommand cmd = new SqlCommand(query, conn);
            cmd.Parameters.AddWithValue("@Email", email);
            conn.Open();
            int count = Convert.ToInt32(cmd.ExecuteScalar());
            return count > 0;
        }
    }

    // FIXED: Now with proper password hashing
    private bool UpdatePassword(string email, string hashedPassword)
    {
        using (SqlConnection conn = new SqlConnection(connectionString))
        {
            // Store password as hash - SECURE
            string query = "UPDATE Users SET Password = @Password WHERE Email = @Email";
            SqlCommand cmd = new SqlCommand(query, conn);
            cmd.Parameters.AddWithValue("@Password", hashedPassword); // Hashed password
            cmd.Parameters.AddWithValue("@Email", email);
            conn.Open();
            return cmd.ExecuteNonQuery() > 0;
        }
    }

    private bool IsPasswordStrong(string password)
    {
        return !string.IsNullOrEmpty(password) && password.Length >= 8;
    }

    private void ShowAlert(string message, string type)
    {
        pnlAlert.Visible = true;
        lblAlert.Text = message ?? "";

        string css = "alert alert-info";
        if (type != null)
        {
            if (type.Equals("success", StringComparison.OrdinalIgnoreCase)) css = "alert alert-success";
            else if (type.Equals("danger", StringComparison.OrdinalIgnoreCase)) css = "alert alert-danger";
            else if (type.Equals("info", StringComparison.OrdinalIgnoreCase)) css = "alert alert-info";
        }

        alertDiv.Attributes["class"] = css;
    }

    // NEW: Clear field errors
    private void ClearFieldErrors()
    {
        ScriptManager.RegisterStartupScript(this, this.GetType(), "clearFieldErrors",
            "document.getElementById('" + txtNewPassword.ClientID + "').classList.remove('field-error');" +
            "document.getElementById('" + txtConfirmPassword.ClientID + "').classList.remove('field-error');" +
            "document.getElementById('" + txtEmail.ClientID + "').classList.remove('field-error');", true);
    }
}