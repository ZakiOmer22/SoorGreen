using SoorGreen.Admin;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Web.Configuration;
using System.Web.UI;
using System.Web.UI.HtmlControls;

namespace SoorGreen.Admin
{
    public partial class ReportWaste : System.Web.UI.Page
    {
        private string connectionString = WebConfigurationManager.ConnectionStrings["SoorGreenDBConnectionString"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (Session["UserID"] == null)
                {
                    Response.Redirect("~/Login.aspx");
                    return;
                }

                LoadUserDashboardStats();
                LoadWasteTypes();
                InitializeForm();
            }
        }

        private void InitializeForm()
        {
            // Add JavaScript event handlers
            txtWeight.Attributes.Add("oninput", "calculateReward()");

            // Initialize photo upload
            if (filePhoto != null)
            {
                filePhoto.Attributes["onchange"] = "handlePhotoUpload(event)";
            }
        }

        protected void btnSubmitReport_Click(object sender, EventArgs e)
        {
            try
            {
                if (Session["UserID"] == null)
                {
                    ShowNotification("Please log in to submit a report", "error");
                    return;
                }

                if (string.IsNullOrEmpty(hdnWasteType.Value))
                {
                    ShowNotification("Please select a waste type", "error");
                    return;
                }

                decimal weight;
                if (string.IsNullOrEmpty(txtWeight.Text) || !decimal.TryParse(txtWeight.Text, out weight) || weight <= 0)
                {
                    ShowNotification("Please enter a valid weight greater than 0", "error");
                    return;
                }

                if (string.IsNullOrEmpty(txtAddress.Text.Trim()))
                {
                    ShowNotification("Please enter collection address", "error");
                    return;
                }

                decimal lat = 0, lng = 0;
                if (!string.IsNullOrEmpty(txtLatitude.Text) && !string.IsNullOrEmpty(txtLongitude.Text))
                {
                    decimal.TryParse(txtLatitude.Text, out lat);
                    decimal.TryParse(txtLongitude.Text, out lng);
                }
                else if (!string.IsNullOrEmpty(hdnLatitude.Value) && !string.IsNullOrEmpty(hdnLongitude.Value))
                {
                    decimal.TryParse(hdnLatitude.Value, out lat);
                    decimal.TryParse(hdnLongitude.Value, out lng);
                }

                string photoUrl = UploadPhoto();

                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();
                    using (SqlCommand cmd = new SqlCommand("sp_SubmitWasteReport", conn))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;

                        cmd.Parameters.AddWithValue("@UserId", Session["UserID"].ToString());
                        cmd.Parameters.AddWithValue("@WasteTypeId", hdnWasteTypeId.Value);
                        cmd.Parameters.AddWithValue("@WasteType", hdnWasteType.Value);
                        cmd.Parameters.AddWithValue("@EstimatedKg", weight);
                        cmd.Parameters.AddWithValue("@Description", txtDescription.Text.Trim());
                        cmd.Parameters.AddWithValue("@Address", txtAddress.Text.Trim());
                        cmd.Parameters.AddWithValue("@Landmark", txtLandmark.Text.Trim());
                        cmd.Parameters.AddWithValue("@ContactPerson", txtContactPerson.Text.Trim());
                        cmd.Parameters.AddWithValue("@Instructions", txtInstructions.Text.Trim());
                        cmd.Parameters.AddWithValue("@Lat", lat > 0 ? (object)lat : DBNull.Value);
                        cmd.Parameters.AddWithValue("@Lng", lng > 0 ? (object)lng : DBNull.Value);
                        cmd.Parameters.AddWithValue("@PhotoUrl", string.IsNullOrEmpty(photoUrl) ? DBNull.Value : (object)photoUrl);

                        // Calculate and add estimated reward
                        decimal estimatedReward = CalculateEstimatedReward(weight, hdnWasteTypeId.Value);
                        cmd.Parameters.AddWithValue("@EstimatedReward", estimatedReward);

                        cmd.ExecuteNonQuery();

                        ShowSuccessMessage();

                        ClearForm();
                        LoadUserDashboardStats();
                    }
                }
            }
            catch (Exception ex)
            {
                ShowNotification("Error submitting report: " + ex.Message, "error");
                LogError("ReportWaste.Submit", ex.Message);
            }
        }

        private decimal CalculateEstimatedReward(decimal weight, string wasteTypeId)
        {
            try
            {
                // Get reward rate from WasteTypes table
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();
                    string query = "SELECT CreditPerKg FROM WasteTypes WHERE WasteTypeId = @WasteTypeId";
                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@WasteTypeId", wasteTypeId);
                        object result = cmd.ExecuteScalar();
                        if (result != null && result != DBNull.Value)
                        {
                            decimal creditPerKg = Convert.ToDecimal(result);
                            return weight * creditPerKg;
                        }
                    }
                }
            }
            catch { }
            return 0;
        }

        private void LoadUserDashboardStats()
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();
                    string userId = Session["UserID"].ToString();

                    string query = @"
                        SELECT 
                            TotalReports,
                            TotalCredits,
                            TotalKgRecycled,
                            CASE WHEN TotalReports > 0 THEN CONVERT(DECIMAL(10,2), (TotalKgRecycled / TotalReports)) ELSE 0 END as AvgWeight,
                            CASE WHEN TotalReports > 0 THEN CONVERT(DECIMAL(10,2), (TotalPickups * 100.0 / TotalReports)) ELSE 100 END as SuccessRate
                        FROM vw_CitizenActivitySummary 
                        WHERE UserId = @UserId";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@UserId", userId);
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                int totalReports = reader.IsDBNull(0) ? 0 : reader.GetInt32(0);
                                decimal totalCredits = reader.IsDBNull(1) ? 0 : reader.GetDecimal(1);
                                decimal totalKgRecycled = reader.IsDBNull(2) ? 0 : reader.GetDecimal(2);
                                decimal avgWeight = reader.IsDBNull(3) ? 0 : reader.GetDecimal(3);
                                decimal successRate = reader.IsDBNull(4) ? 0 : reader.GetDecimal(4);

                                // Update the stats display using JavaScript
                                string script = string.Format(
                                    @"if (document.getElementById('totalReports')) {{
                                        document.getElementById('totalReports').textContent = '{0}';
                                        document.getElementById('totalRewards').textContent = '{1}';
                                        document.getElementById('avgWeight').textContent = '{2}';
                                        document.getElementById('successRate').textContent = '{3}%';
                                    }}
                                    
                                    // Update potential reward with max value
                                    if (document.getElementById('potentialReward')) {{
                                        var maxReward = {1} > 0 ? {1} : 50;
                                        document.getElementById('potentialReward').textContent = maxReward.toFixed(0) + ' XP';
                                    }}",
                                    totalReports,
                                    totalCredits.ToString("F0"),
                                    avgWeight.ToString("F1"),
                                    successRate.ToString("F0")
                                );

                                ScriptManager.RegisterStartupScript(this, this.GetType(), "updateStats", script, true);
                            }
                        }
                    }

                    // Update the potential reward badge via JavaScript
                    string maxRewardQuery = "SELECT MAX(CreditPerKg) * 10 FROM WasteTypes";
                    using (SqlCommand cmd = new SqlCommand(maxRewardQuery, conn))
                    {
                        object result = cmd.ExecuteScalar();
                        decimal maxReward = result != DBNull.Value ? (decimal)result : 50;

                        string updateScript = string.Format(
                            @"if (document.getElementById('potentialReward')) {{
                                document.getElementById('potentialReward').textContent = '{0} XP';
                            }}",
                            maxReward.ToString("F0")
                        );
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "updateMaxReward", updateScript, true);
                    }
                }
            }
            catch (Exception ex)
            {
                LogError("LoadUserDashboardStats", ex.Message);
            }
        }

        private void LoadWasteTypes()
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();
                    string query = "SELECT WasteTypeId, Name, CreditPerKg, CategoryCode FROM WasteTypes WHERE IsActive = 1 ORDER BY DisplayOrder, Name";
                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        var wasteTypes = new List<WasteType>();
                        while (reader.Read())
                        {
                            wasteTypes.Add(new WasteType
                            {
                                WasteTypeId = reader["WasteTypeId"].ToString(),
                                Name = reader["Name"].ToString(),
                                CreditPerKg = Convert.ToDecimal(reader["CreditPerKg"]),
                                CategoryCode = reader["CategoryCode"].ToString()
                            });
                        }

                        // Store in session for potential use
                        Session["WasteTypes"] = wasteTypes;

                        // Pass waste types to JavaScript
                        string jsArray = "var wasteTypes = " + Newtonsoft.Json.JsonConvert.SerializeObject(wasteTypes) + ";";
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "wasteTypesJS", jsArray, true);
                    }
                }
            }
            catch (Exception ex)
            {
                LogError("LoadWasteTypes", ex.Message);
            }
        }

        private string UploadPhoto()
        {
            // Handle HTML file input instead of ASP.NET FileUpload control
            var fileInput = filePhoto as HtmlInputFile;

            if (fileInput == null || fileInput.PostedFile == null || string.IsNullOrEmpty(fileInput.PostedFile.FileName))
            {
                return string.Empty;
            }

            try
            {
                string fileName = fileInput.PostedFile.FileName;
                string fileExtension = System.IO.Path.GetExtension(fileName).ToLower();
                string[] allowedExtensions = { ".jpg", ".jpeg", ".png", ".gif" };

                if (Array.IndexOf(allowedExtensions, fileExtension) == -1)
                {
                    ShowNotification("Only image files (JPG, PNG, GIF) are allowed.", "error");
                    return string.Empty;
                }

                if (fileInput.PostedFile.ContentLength > 5 * 1024 * 1024)
                {
                    ShowNotification("File size must be less than 5MB.", "error");
                    return string.Empty;
                }

                string newFileName = Guid.NewGuid().ToString() + fileExtension;
                string uploadPath = Server.MapPath("~/Uploads/WastePhotos/");

                if (!System.IO.Directory.Exists(uploadPath))
                    System.IO.Directory.CreateDirectory(uploadPath);

                string filePath = System.IO.Path.Combine(uploadPath, newFileName);
                fileInput.PostedFile.SaveAs(filePath);

                return "/Uploads/WastePhotos/" + newFileName;
            }
            catch (Exception ex)
            {
                ShowNotification("Error uploading photo: " + ex.Message, "error");
                return string.Empty;
            }
        }

        private void ShowSuccessMessage()
        {
            string script = @"
                Swal.fire({
                    icon: 'success',
                    title: 'Report Submitted Successfully!',
                    text: 'Your waste report has been submitted. A collector will contact you within 24-48 hours.',
                    confirmButtonText: 'Go to Dashboard',
                    confirmButtonColor: '#10b981',
                    showCancelButton: true,
                    cancelButtonText: 'Submit Another',
                    cancelButtonColor: '#64748b'
                }).then((result) => {
                    if (result.isConfirmed) {
                        window.location.href = 'Dashboard.aspx';
                    } else if (result.dismiss === Swal.DismissReason.cancel) {
                        // Reset form for another submission
                        document.querySelector('.form-wrapper').scrollIntoView({ behavior: 'smooth' });
                    }
                });";

            ScriptManager.RegisterStartupScript(this, this.GetType(), "SuccessMessage", script, true);
        }

        private void ShowNotification(string message, string type)
        {
            string script = "showNotification('" + message.Replace("'", "\\'") + "', '" + type + "');";
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ShowNotification", script, true);
        }

        private void ClearForm()
        {
            // Clear all form fields
            hdnWasteType.Value = string.Empty;
            hdnWasteTypeId.Value = string.Empty;
            txtWeight.Text = string.Empty;
            txtDescription.Text = string.Empty;
            txtAddress.Text = string.Empty;
            txtLandmark.Text = string.Empty;
            txtContactPerson.Text = string.Empty;
            txtInstructions.Text = string.Empty;
            txtLatitude.Text = string.Empty;
            txtLongitude.Text = string.Empty;
            hdnLatitude.Value = string.Empty;
            hdnLongitude.Value = string.Empty;

            // Clear photo preview and reset form steps
            string clearScript = @"
                // Clear photo preview
                var photoPreview = document.getElementById('photoPreview');
                if (photoPreview) {
                    var placeholder = photoPreview.querySelector('.preview-placeholder');
                    if (placeholder) {
                        photoPreview.innerHTML = '';
                        photoPreview.appendChild(placeholder.cloneNode(true));
                    }
                }
                
                // Reset form to step 1
                if (typeof goToStep === 'function') {
                    goToStep(1);
                }
                
                // Clear all category selections
                document.querySelectorAll('.category-card').forEach(card => {
                    card.classList.remove('selected');
                });
                
                // Reset checkboxes
                var chkConfirm = document.getElementById('chkConfirmDetails');
                var chkAgree = document.getElementById('chkAgreeTerms');
                var chkSchedule = document.getElementById('chkSchedulePickup');
                
                if (chkConfirm) chkConfirm.checked = false;
                if (chkAgree) chkAgree.checked = false;
                if (chkSchedule) chkSchedule.checked = false;
                
                // Reset reward display
                var estimatedReward = document.getElementById('estimatedReward');
                var rewardWeight = document.getElementById('rewardWeight');
                var rewardRate = document.getElementById('rewardRate');
                var rewardTotal = document.getElementById('rewardTotal');
                
                if (estimatedReward) estimatedReward.textContent = '0 XP';
                if (rewardWeight) rewardWeight.textContent = '0 kg';
                if (rewardRate) rewardRate.textContent = '0 XP/kg';
                if (rewardTotal) rewardTotal.textContent = '0 XP';
                
                // Clear file input
                var fileInput = document.getElementById('filePhoto');
                if (fileInput) fileInput.value = '';";

            ScriptManager.RegisterStartupScript(this, this.GetType(), "ClearForm", clearScript, true);
        }

        private void LogError(string method, string message)
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();
                    string query = @"
                        INSERT INTO ErrorLogs (ErrorType, Url, Message, UserIP, UserAgent, Referrer, CreatedAt)
                        VALUES (@ErrorType, @Url, @Message, @UserIP, @UserAgent, @Referrer, GETDATE())";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@ErrorType", method);
                        cmd.Parameters.AddWithValue("@Url", Request.Url.ToString());
                        cmd.Parameters.AddWithValue("@Message", message);
                        cmd.Parameters.AddWithValue("@UserIP", GetClientIP());
                        cmd.Parameters.AddWithValue("@UserAgent", Request.UserAgent ?? "Unknown");
                        cmd.Parameters.AddWithValue("@Referrer", Request.UrlReferrer != null ? Request.UrlReferrer.ToString() : "Direct");

                        cmd.ExecuteNonQuery();
                    }
                }
            }
            catch { }
        }

        private string GetClientIP()
        {
            string ip = Request.ServerVariables["HTTP_X_FORWARDED_FOR"];
            if (string.IsNullOrEmpty(ip))
                ip = Request.ServerVariables["REMOTE_ADDR"];
            if (string.IsNullOrEmpty(ip))
                ip = Request.UserHostAddress;
            return ip ?? "Unknown";
        }

        [System.Web.Services.WebMethod]
        public static string GetWasteTypeIdByName(string wasteTypeName)
        {
            try
            {
                string connectionString = WebConfigurationManager.ConnectionStrings["SoorGreenDBConnectionString"].ConnectionString;
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();
                    string query = "SELECT WasteTypeId FROM WasteTypes WHERE LOWER(Name) = @Name";
                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@Name", wasteTypeName.ToLower());
                        object result = cmd.ExecuteScalar();
                        return result != null ? result.ToString() : "WT01";
                    }
                }
            }
            catch { return "WT01"; }
        }
    }

    public class WasteType
    {
        public string WasteTypeId { get; set; }
        public string Name { get; set; }
        public decimal CreditPerKg { get; set; }
        public string CategoryCode { get; set; }
    }
}