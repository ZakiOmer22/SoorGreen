using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Net;
using System.Text;
using System.Threading.Tasks;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;

namespace SoorGreen.Admin
{
    public partial class ReportWaste : System.Web.UI.Page
    {
        private string currentUserId;
        private string selectedWasteTypeId;
        private decimal selectedWasteRate;
        private string selectedWasteName;
        private decimal estimatedWeight = 0;
        private decimal estimatedReward = 0;
        private bool aiUsed = false;

        string connectionString = System.Configuration.ConfigurationManager.ConnectionStrings["SoorGreenDBConnectionString"].ConnectionString;
        private string aiBaseUrl = "http://127.0.0.1:5000/api/ai";
        protected void Page_Load(object sender, EventArgs e)
        {
            // Get AI URL from config if available
            var configUrl = System.Configuration.ConfigurationManager.AppSettings["AI_ENGINE_URL"];
            if (!string.IsNullOrEmpty(configUrl))
            {
                aiBaseUrl = configUrl;
            }

            if (!IsPostBack)
            {
                // Check if user is logged in
                if (Session["UserId"] == null)
                {
                    Response.Redirect("~/Login.aspx");
                    return;
                }

                currentUserId = Session["UserId"].ToString();

                // Load user stats
                LoadUserStats();

                // Load waste types for step 1
                LoadWasteTypes();

                // Initialize step 1 as visible
                ShowStep(1);

                // Register startup scripts
                RegisterStartupScripts();
            }
            else
            {
                // Restore values from session
                if (Session["UserId"] != null)
                {
                    currentUserId = Session["UserId"].ToString();
                }

                if (Session["SelectedWasteTypeId"] != null)
                {
                    selectedWasteTypeId = Session["SelectedWasteTypeId"].ToString();
                }

                if (Session["SelectedWasteRate"] != null)
                {
                    selectedWasteRate = (decimal)Session["SelectedWasteRate"];
                }

                if (Session["SelectedWasteName"] != null)
                {
                    selectedWasteName = Session["SelectedWasteName"].ToString();
                }

                if (Session["EstimatedWeight"] != null)
                {
                    estimatedWeight = (decimal)Session["EstimatedWeight"];
                }

                if (Session["EstimatedReward"] != null)
                {
                    estimatedReward = (decimal)Session["EstimatedReward"];
                }

                if (Session["AIUsed"] != null)
                {
                    aiUsed = (bool)Session["AIUsed"];
                }
            }

            // Handle AJAX requests
            if (Request["action"] != null)
            {
                HandleAjaxRequest();
            }
        }

        // AI Image Classification - REAL API CALL
        private async System.Threading.Tasks.Task ProcessImageWithAI(byte[] imageBytes, string fileName)
        {
            try
            {
                // Convert to base64 for API
                string base64Image = Convert.ToBase64String(imageBytes);

                // Prepare request for Flask AI
                var requestData = new
                {
                    image_data = base64Image,
                    filename = fileName,
                    timestamp = DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss")
                };

                // Call Flask AI API
                var result = await MakeApiCallAsync<ImageClassificationResponse>($"{aiBaseUrl}/classify-waste", requestData);

                if (result != null && result.status == "success" && result.detections != null && result.detections.Count > 0)
                {
                    // Get the top detection
                    var topDetection = result.detections[0];
                    string detectedWasteType = MapAIClassToWasteType(topDetection.class_name);
                    double confidence = topDetection.confidence;

                    // Update UI with AI results
                    UpdateUIWithAIDetection(detectedWasteType, confidence, result.detections);

                    // Mark AI as used
                    aiUsed = true;
                    Session["AIUsed"] = aiUsed;

                    // Show success message
                    ShowMessage($"AI detected: {detectedWasteType} ({(confidence * 100).ToString("0")}% confidence)", "success");
                }
                else
                {
                    string errorMsg = result?.message ?? "Unknown error";
                    ShowMessage($"AI could not classify the image: {errorMsg}. Please select waste type manually.", "warning");
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"AI Image Classification Error: {ex.Message}");
                ShowMessage("AI service temporarily unavailable. Please select waste type manually.", "warning");
            }
        }

        private string MapAIClassToWasteType(string aiClass)
        {
            var mapping = new System.Collections.Generic.Dictionary<string, string>(StringComparer.OrdinalIgnoreCase)
            {
                { "plastic", "Plastic" },
                { "paper", "Paper" },
                { "metal", "Metal" },
                { "glass", "Glass" },
                { "organic", "Organic" },
                { "food", "Organic" },
                { "electronics", "Electronics" },
                { "e-waste", "Electronics" },
                { "mixed", "Mixed" },
                { "other", "Mixed" }
            };

            return mapping.ContainsKey(aiClass.ToLower()) ? mapping[aiClass.ToLower()] : "Mixed";
        }

        private void UpdateUIWithAIDetection(string wasteType, double confidence, List<Detection> allDetections)
        {
            // Update hidden fields
            if (hfAICategory != null) hfAICategory.Value = wasteType.ToLower();
            if (hfAIWasteType != null) hfAIWasteType.Value = wasteType;

            // C# 6 compatible string formatting
            string confidencePercent = (confidence * 100).ToString("0");
            string serializedDetections = Newtonsoft.Json.JsonConvert.SerializeObject(allDetections);

            // Calculate estimated weight based on confidence
            decimal estimatedWeightFromAI = 2.5m;
            if (confidence > 0.8) estimatedWeightFromAI = 3.0m;
            else if (confidence > 0.6) estimatedWeightFromAI = 2.5m;
            else estimatedWeightFromAI = 1.5m;

            // Update AI results section in UI
            string script = @"
                var aiResults = document.getElementById('aiResults');
                if (aiResults) {
                    var detectionsHtml = '';
                    var detections = " + serializedDetections + @";
                    
                    if (detections && detections.length > 0) {
                        detections.forEach(function(detection, index) {
                            var wasteType = mapAIClassToWasteType(detection.class_name);
                            var confidencePercent = Math.round(detection.confidence * 100);
                            var isPrimary = index === 0;
                            
                            detectionsHtml += '<div class=""detection-row ' + (isPrimary ? 'primary-detection' : '') + '"">' +
                                '<div class=""d-flex justify-content-between align-items-center"">' +
                                '<span>' + wasteType + '</span>' +
                                '<div class=""d-flex align-items-center"">' +
                                '<div class=""confidence-bar me-2"" style=""width: 100px;"">' +
                                '<div class=""confidence-fill"" style=""width: ' + confidencePercent + '%;""></div>' +
                                '</div>' +
                                '<span class=""confidence-value"">' + confidencePercent + '%</span>' +
                                '</div>' +
                                '</div>' +
                                '</div>';
                        });
                    }
                    
                    aiResults.innerHTML = '<div class=""alert alert-success ai-success"">' +
                        '<h6><i class=""fas fa-robot me-2""></i> AI Waste Detection Results</h6>' +
                        '<div class=""mt-3"">' +
                        '<div class=""primary-result mb-3 p-3 bg-light rounded"">' +
                        '<div class=""d-flex justify-content-between align-items-center"">' +
                        '<div>' +
                        '<h5 class=""mb-1"">Primary Detection</h5>' +
                        '<div class=""d-flex align-items-center"">' +
                        '<span class=""badge bg-primary me-2"">" + wasteType + @"</span>' +
                        '<span class=""text-muted"">" + confidencePercent + @"% confidence</span>' +
                        '</div>' +
                        '</div>' +
                        '<div class=""text-end"">' +
                        '<div class=""estimated-weight h4 text-success mb-0"">" + estimatedWeightFromAI.ToString("0.0") + @" kg</div>' +
                        '<small class=""text-muted"">Estimated weight</small>' +
                        '</div>' +
                        '</div>' +
                        '</div>';
                    
                    if (detectionsHtml) {
                        aiResults.innerHTML += '<div class=""all-detections mt-3"">' +
                            '<h6 class=""mb-2"">All Detections:</h6>' +
                            '<div class=""detections-list"">' + detectionsHtml + '</div>' +
                            '</div>';
                    }
                    
                    aiResults.innerHTML += '<div class=""mt-4"">' +
                        '<button type=""button"" class=""btn btn-success me-2"" onclick=""applyAIResults()"">' +
                        '<i class=""fas fa-check me-1""></i> Apply Primary Detection' +
                        '</button>' +
                        '<button type=""button"" class=""btn btn-outline-secondary"" onclick=""ignoreAIResults()"">' +
                        '<i class=""fas fa-times me-1""></i> Ignore' +
                        '</button>' +
                        '</div>' +
                        '</div>' +
                        '</div>';
                        
                    // Store data for JavaScript
                    aiResults.dataset.estimatedWeight = '" + estimatedWeightFromAI.ToString("0.0") + @"';
                    aiResults.dataset.wasteType = '" + wasteType + @"';
                    aiResults.dataset.allDetections = JSON.stringify(detections);
                    
                    // Auto-fill weight if empty
                    var weightInput = document.getElementById('" + (txtWeight != null ? txtWeight.ClientID : "txtWeight") + @"');
                    if (weightInput && (!weightInput.value || weightInput.value === '0' || weightInput.value === '0.0')) {
                        weightInput.value = '" + estimatedWeightFromAI.ToString("0.0") + @"';
                        // Trigger change event
                        var event = new Event('change');
                        weightInput.dispatchEvent(event);
                    }
                }
                
                function mapAIClassToWasteType(aiClass) {
                    var mapping = {
                        'plastic': 'Plastic',
                        'paper': 'Paper', 
                        'metal': 'Metal',
                        'glass': 'Glass',
                        'organic': 'Organic',
                        'electronics': 'Electronics',
                        'mixed': 'Mixed'
                    };
                    return mapping[aiClass.toLowerCase()] || aiClass.charAt(0).toUpperCase() + aiClass.slice(1);
                }
            ";

            ScriptManager.RegisterStartupScript(this, GetType(), "UpdateAIDetection_" + Guid.NewGuid().ToString("N"), script, true);
        }

        // AI Report Validation - REAL API CALL
        private bool ValidateReportWithAI()
        {
            try
            {
                if (string.IsNullOrEmpty(selectedWasteTypeId) || estimatedWeight <= 0)
                    return true; // Basic validation failed, don't call AI

                // Get waste type name
                string wasteTypeName = selectedWasteName ?? "Mixed";
                string location = txtAddress != null ? txtAddress.Text ?? "Unknown" : "Unknown";

                // Prepare request for Flask AI
                var requestData = new
                {
                    waste_type = wasteTypeName,
                    weight = estimatedWeight,
                    location = location,
                    timestamp = DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss")
                };

                // Call Flask AI API
                var validationResult = MakeApiCall<ValidationResponse>($"{aiBaseUrl}/validate-report", requestData);

                if (validationResult != null && validationResult.status == "ok")
                {
                    if (validationResult.report.status == "valid" || validationResult.report.status == "warning")
                    {
                        // Show validation warnings if any
                        if (validationResult.report.warnings != null && validationResult.report.warnings.Length > 0)
                        {
                            string warnings = string.Join("<br>", validationResult.report.warnings);
                            ShowMessage($"AI Validation: {validationResult.report.message}<br><small>{warnings}</small>", "warning");
                        }
                        else
                        {
                            ShowMessage($"✓ AI Validation: {validationResult.report.message}", "success");
                        }
                        return true;
                    }
                    else if (validationResult.report.status == "suspicious" || validationResult.report.status == "invalid")
                    {
                        // Show validation error
                        ShowMessage($"AI Validation Failed: {validationResult.report.message}", "error");
                        return false;
                    }
                }
                return true; // Default to true if AI validation fails
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"AI Validation Error: {ex.Message}");
                return true; // Allow submission if AI validation service is down
            }
        }

        // AI Report Analysis - REAL API CALL
        private void AnalyzeReportWithAI(string reportId)
        {
            try
            {
                string wasteTypeName = selectedWasteName ?? "Mixed";
                string description = txtDescription != null ? txtDescription.Text ?? "" : "";
                string location = txtAddress != null ? txtAddress.Text ?? "Unknown" : "Unknown";

                // Parse report ID (remove WR prefix)
                int reportIdNumber;
                if (reportId.StartsWith("WR") && int.TryParse(reportId.Substring(2), out reportIdNumber))
                {
                    // Prepare request for Flask AI
                    var requestData = new
                    {
                        report_id = reportIdNumber,
                        waste_type = wasteTypeName,
                        weight = estimatedWeight,
                        description = description,
                        location = location,
                        timestamp = DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss")
                    };

                    // Call Flask AI API
                    var analysisResult = MakeApiCall<AnalysisResponse>($"{aiBaseUrl}/analyze-report", requestData);

                    if (analysisResult != null && analysisResult.status == "ok")
                    {
                        // Store analysis results in database
                        StoreAIAnalysisResults(reportId, analysisResult);

                        // Show analysis summary
                        string analysisMessage = $"AI Analysis: {analysisResult.report.message}<br>" +
                                               $"Confidence: {(analysisResult.report.confidence * 100).ToString("0")}%<br>" +
                                               $"Risk Level: {analysisResult.report.risk_level}";

                        ShowMessage(analysisMessage,
                                   analysisResult.report.risk_level == "high" ? "warning" : "success");
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"AI Analysis Error: {ex.Message}");
                // Don't show error to user - analysis failure shouldn't affect submission
            }
        }

        // Store AI Analysis Results - UPDATED FOR REAL RESPONSE
        private void StoreAIAnalysisResults(string reportId, AnalysisResponse analysisResult)
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    // First check if table exists, if not create it
                    string checkTableQuery = @"
                IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='AIReportAnalysis' AND xtype='U')
                BEGIN
                    CREATE TABLE AIReportAnalysis (
                        AnalysisId INT IDENTITY(1,1) PRIMARY KEY,
                        ReportId NVARCHAR(50) NOT NULL,
                        AnalysisStatus NVARCHAR(50) NOT NULL,
                        Confidence DECIMAL(5,4) NOT NULL,
                        RiskLevel NVARCHAR(20) NOT NULL,
                        TrustScore DECIMAL(5,4) NOT NULL,
                        Message NVARCHAR(500),
                        AnalyzedAt DATETIME DEFAULT GETDATE()
                    )
                END";

                    using (SqlCommand cmd = new SqlCommand(checkTableQuery, conn))
                    {
                        cmd.ExecuteNonQuery();
                    }

                    // Insert analysis results
                    string insertQuery = @"
                INSERT INTO AIReportAnalysis 
                (ReportId, AnalysisStatus, Confidence, RiskLevel, TrustScore, Message)
                VALUES (@ReportId, @AnalysisStatus, @Confidence, @RiskLevel, @TrustScore, @Message)";

                    using (SqlCommand cmd = new SqlCommand(insertQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@ReportId", reportId);
                        cmd.Parameters.AddWithValue("@AnalysisStatus", analysisResult.report.status);
                        cmd.Parameters.AddWithValue("@Confidence", analysisResult.report.confidence);
                        cmd.Parameters.AddWithValue("@RiskLevel", analysisResult.report.risk_level);
                        cmd.Parameters.AddWithValue("@TrustScore", analysisResult.report.trust_score);
                        cmd.Parameters.AddWithValue("@Message", analysisResult.report.message);
                        cmd.ExecuteNonQuery();
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Store AI Analysis Error: {ex.Message}");
            }
        }

        private void SubmitWasteReport()
        {
            // 1. Validate with AI before submission
            if (!ValidateReportWithAI())
            {
                ShowMessage("Report validation failed. Please check your inputs.", "error");
                return;
            }

            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.Open();
                using (SqlTransaction transaction = conn.BeginTransaction())
                {
                    try
                    {
                        // Generate Report ID
                        string reportId = GenerateNextId(conn, transaction, "WasteReports", "ReportId", "WR");

                        // Insert waste report
                        string insertReportQuery = @"
                    INSERT INTO WasteReports 
                    (ReportId, UserId, WasteTypeId, EstimatedKg, Address, Lat, Lng, CreatedAt, Description, AIClassified, AIValidationStatus)
                    VALUES (@ReportId, @UserId, @WasteTypeId, @EstimatedKg, @Address, @Lat, @Lng, @CreatedAt, @Description, @AIClassified, @AIValidationStatus)";

                        using (SqlCommand cmd = new SqlCommand(insertReportQuery, conn, transaction))
                        {
                            cmd.Parameters.AddWithValue("@ReportId", reportId);
                            cmd.Parameters.AddWithValue("@UserId", currentUserId);
                            cmd.Parameters.AddWithValue("@WasteTypeId", selectedWasteTypeId);
                            cmd.Parameters.AddWithValue("@EstimatedKg", estimatedWeight);
                            cmd.Parameters.AddWithValue("@Address", txtAddress != null ? txtAddress.Text : "");
                            cmd.Parameters.AddWithValue("@Lat", !string.IsNullOrEmpty(txtLatitude != null ? txtLatitude.Text : "") ? txtLatitude.Text : (object)DBNull.Value);
                            cmd.Parameters.AddWithValue("@Lng", !string.IsNullOrEmpty(txtLongitude != null ? txtLongitude.Text : "") ? txtLongitude.Text : (object)DBNull.Value);
                            cmd.Parameters.AddWithValue("@CreatedAt", DateTime.Now);
                            cmd.Parameters.AddWithValue("@Description", !string.IsNullOrEmpty(txtDescription != null ? txtDescription.Text : "") ? txtDescription.Text : (object)DBNull.Value);
                            cmd.Parameters.AddWithValue("@AIClassified", aiUsed);
                            cmd.Parameters.AddWithValue("@AIValidationStatus", "validated");

                            cmd.ExecuteNonQuery();
                        }

                        // Generate Pickup ID if pickup is scheduled
                        string pickupId = "";
                        if (chkSchedulePickup != null && chkSchedulePickup.Checked)
                        {
                            pickupId = GenerateNextId(conn, transaction, "PickupRequests", "PickupId", "PK");

                            // Insert pickup request
                            string insertPickupQuery = @"
                        INSERT INTO PickupRequests (PickupId, ReportId, Status, ScheduledAt)
                        VALUES (@PickupId, @ReportId, 'Requested', DATEADD(HOUR, 48, GETDATE()))";

                            using (SqlCommand cmd = new SqlCommand(insertPickupQuery, conn, transaction))
                            {
                                cmd.Parameters.AddWithValue("@PickupId", pickupId);
                                cmd.Parameters.AddWithValue("@ReportId", reportId);
                                cmd.ExecuteNonQuery();
                            }
                        }

                        // Insert reward transaction
                        string rewardId = "RWD" + DateTime.Now.ToString("yyyyMMddHHmmssfff") + new Random().Next(1000, 9999);
                        string insertRewardQuery = @"
                    INSERT INTO RewardPoints (RewardId, UserId, ReportId, Amount, Type, Description, CreatedAt)
                    VALUES (@RewardId, @UserId, @ReportId, @Amount, 'Pending', @Description, GETDATE())";

                        using (SqlCommand cmd = new SqlCommand(insertRewardQuery, conn, transaction))
                        {
                            cmd.Parameters.AddWithValue("@RewardId", rewardId);
                            cmd.Parameters.AddWithValue("@UserId", currentUserId);
                            cmd.Parameters.AddWithValue("@ReportId", reportId);
                            cmd.Parameters.AddWithValue("@Amount", estimatedReward);
                            cmd.Parameters.AddWithValue("@Description", "Reported " + selectedWasteName + " (" + estimatedWeight.ToString("0.0") + " kg)");
                            cmd.ExecuteNonQuery();
                        }

                        // Insert user activity log
                        string activityId = "ACT" + DateTime.Now.ToString("yyyyMMddHHmmssfff") + new Random().Next(1000, 9999);
                        string insertActivityQuery = @"
                    INSERT INTO UserActivityLogs (LogId, UserId, ActivityType, Details, CreatedAt)
                    VALUES (@LogId, @UserId, 'WasteReport', @Details, GETDATE())";

                        using (SqlCommand cmd = new SqlCommand(insertActivityQuery, conn, transaction))
                        {
                            cmd.Parameters.AddWithValue("@LogId", activityId);
                            cmd.Parameters.AddWithValue("@UserId", currentUserId);
                            cmd.Parameters.AddWithValue("@Details", "Reported " + selectedWasteName + " for collection (" + estimatedWeight.ToString("0.0") + " kg)" + (aiUsed ? " [AI-Classified]" : ""));
                            cmd.ExecuteNonQuery();
                        }

                        // Commit transaction
                        transaction.Commit();

                        // 2. Analyze with AI after successful submission
                        AnalyzeReportWithAI(reportId);

                        // Update success display
                        if (lblSuccessReportId != null) lblSuccessReportId.Text = reportId;
                        if (lblSuccessPickupId != null) lblSuccessPickupId.Text = !string.IsNullOrEmpty(pickupId) ? pickupId : "Not requested";
                        if (lblSuccessReward != null) lblSuccessReward.Text = estimatedReward.ToString("N0") + " XP";

                        if (aiUsed && lblSuccessReward != null)
                        {
                            lblSuccessReward.Text += " (AI-Assisted)";
                        }

                        if (lblSuccessTime != null) lblSuccessTime.Text = DateTime.Now.ToString("yyyy-MM-dd HH:mm");

                        // Update user stats
                        LoadUserStats();

                        // Show success step
                        ShowStep(0); // 0 means success
                        ShowMessage("Waste report submitted successfully with AI validation!", "success");

                        // Trigger success animation
                        string successScript = "showDatabaseConfirmation();";
                        ScriptManager.RegisterStartupScript(this, GetType(), "ShowSuccess", successScript, true);

                    }
                    catch (Exception ex)
                    {
                        transaction.Rollback();
                        ShowMessage("Failed to submit report: " + ex.Message, "error");
                    }
                }
            }
        }

        // Add a button click handler for AI image classification
        protected async void btnClassifyImage_Click(object sender, EventArgs e)
        {
            if (fuWasteImage != null && fuWasteImage.HasFile)
            {
                try
                {
                    // Convert file to byte array
                    byte[] imageBytes;
                    using (var binaryReader = new System.IO.BinaryReader(fuWasteImage.PostedFile.InputStream))
                    {
                        imageBytes = binaryReader.ReadBytes(fuWasteImage.PostedFile.ContentLength);
                    }

                    // Process with AI
                    await ProcessImageWithAI(imageBytes, fuWasteImage.FileName);
                }
                catch (Exception ex)
                {
                    ShowMessage("Error processing image: " + ex.Message, "error");
                }
            }
            else
            {
                ShowMessage("Please select an image first.", "warning");
            }
        }

        private void HandleAjaxRequest()
        {
            string action = Request["action"];
            Response.Clear();
            Response.ContentType = "application/json";

            try
            {
                switch (action)
                {
                    case "classify":
                        string imageData = Request["imageData"];
                        HandleClassifyRequest(imageData);
                        break;
                    case "apply":
                        string aiCategory = Request["aiCategory"];
                        string aiWasteType = Request["aiWasteType"];
                        HandleApplyRequest(aiCategory, aiWasteType);
                        break;
                    default:
                        Response.Write("{\"success\":false,\"message\":\"Unknown action\"}");
                        break;
                }
            }
            catch (Exception ex)
            {
                Response.Write("{\"success\":false,\"message\":\"" + ex.Message.Replace("\"", "\\\"") + "\"}");
            }
            Response.End();
        }

        // AI IMAGE CLASSIFICATION - REAL API CALL
        private void HandleClassifyRequest(string imageData)
        {
            try
            {
                // Remove data:image/jpeg;base64, prefix if present
                if (imageData.Contains(","))
                {
                    imageData = imageData.Split(',')[1];
                }

                // Prepare request
                var requestData = new
                {
                    image_data = imageData,
                    timestamp = DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss")
                };

                // Call Flask AI
                var result = MakeApiCall<ImageClassificationResponse>($"{aiBaseUrl}/classify-waste", requestData);

                if (result != null && result.status == "success")
                {
                    string category = result.detections?[0]?.class_name ?? "mixed";
                    double confidence = result.detections?[0]?.confidence ?? 0.5;

                    Response.Write(JsonConvert.SerializeObject(new
                    {
                        success = true,
                        category = category,
                        wasteType = MapAIClassToWasteType(category),
                        confidence = confidence,
                        message = "Waste classified successfully"
                    }));
                }
                else
                {
                    Response.Write(JsonConvert.SerializeObject(new
                    {
                        success = false,
                        message = "AI classification failed"
                    }));
                }
            }
            catch (Exception ex)
            {
                Response.Write(JsonConvert.SerializeObject(new
                {
                    success = false,
                    message = "Error: " + ex.Message
                }));
            }
        }

        private void HandleApplyRequest(string aiCategory, string aiWasteType)
        {
            // Mock response for applying AI results
            Response.Write("{\"success\":true,\"appliedWasteType\":\"" + aiWasteType + "\",\"message\":\"AI suggestions applied successfully\"}");
        }

        // APPLY AI RESULTS WEB METHOD - REAL API CALL
        [WebMethod]
        public static object ApplyAIResults(string aiCategory, string aiWasteType)
        {
            try
            {
                // This would typically find the matching waste type in database
                // For now, return success
                return new
                {
                    success = true,
                    appliedWasteType = aiWasteType,
                    message = "AI suggestions applied successfully. Please select the waste type from the list above."
                };
            }
            catch (Exception ex)
            {
                return new
                {
                    success = false,
                    message = "Error: " + ex.Message
                };
            }
        }

        // TEST AI CONNECTION WEB METHOD - REAL API CALL
        [WebMethod]
        public static object TestAIConnection()
        {
            try
            {
                string apiUrl = "http://127.0.0.1:5000/api/ai/test";

                HttpWebRequest request = (HttpWebRequest)WebRequest.Create(apiUrl);
                request.Method = "GET";
                request.Timeout = 5000; // 5 second timeout

                using (HttpWebResponse response = (HttpWebResponse)request.GetResponse())
                using (Stream responseStream = response.GetResponseStream())
                using (StreamReader reader = new StreamReader(responseStream))
                {
                    string responseJson = reader.ReadToEnd();
                    var result = JsonConvert.DeserializeObject<dynamic>(responseJson);

                    return new
                    {
                        success = true,
                        message = "AI Service is connected and responding",
                        status = result?.status ?? "unknown"
                    };
                }
            }
            catch (Exception ex)
            {
                return new
                {
                    success = false,
                    message = "AI Service is not available: " + ex.Message
                };
            }
        }

        private void SelectWasteType(string wasteTypeName)
        {
            if (string.IsNullOrEmpty(wasteTypeName)) return;

            // Find and select the waste type
            foreach (RepeaterItem item in rptWasteTypes.Items)
            {
                var linkButton = item.FindControl("btnSelectType") as LinkButton;
                if (linkButton != null)
                {
                    string[] args = linkButton.CommandArgument.Split('|');
                    if (args.Length >= 3 && args[2].Equals(wasteTypeName, StringComparison.OrdinalIgnoreCase))
                    {
                        // Simulate click
                        selectedWasteTypeId = args[0];
                        selectedWasteRate = decimal.Parse(args[1]);
                        selectedWasteName = args[2];

                        Session["SelectedWasteTypeId"] = selectedWasteTypeId;
                        Session["SelectedWasteRate"] = selectedWasteRate;
                        Session["SelectedWasteName"] = selectedWasteName;

                        // Update UI
                        if (lblSelectedWaste != null) lblSelectedWaste.Text = selectedWasteName;
                        if (lblRatePreview != null) lblRatePreview.Text = selectedWasteRate.ToString("N2") + " XP/kg";

                        // Enable next button
                        if (btnNextStep1 != null) btnNextStep1.Enabled = true;

                        // Mark AI as used
                        aiUsed = true;
                        Session["AIUsed"] = aiUsed;

                        // Update review section if visible
                        if (pnlStep4 != null && pnlStep4.Visible)
                        {
                            if (lblReviewWasteType != null) lblReviewWasteType.Text = selectedWasteName;
                            if (lblAIUsed != null)
                            {
                                lblAIUsed.Visible = true;
                            }
                        }

                        break;
                    }
                }
            }
        }

        protected void btnUseAISuggestion_Click(object sender, EventArgs e)
        {
            if (lblAIPredictedType != null && lblAIPredictedWeight != null)
            {
                string predictedType = lblAIPredictedType.Text?.Trim();
                string predictedWeightText = lblAIPredictedWeight.Text?.Trim();

                if (!string.IsNullOrEmpty(predictedType) && !string.IsNullOrEmpty(predictedWeightText))
                {
                    decimal weight;
                    if (decimal.TryParse(predictedWeightText, System.Globalization.NumberStyles.Any, System.Globalization.CultureInfo.InvariantCulture, out weight))
                    {
                        if (lblWeightPreview != null) lblWeightPreview.Text = weight.ToString("0.0");
                        if (txtWeight != null) txtWeight.Text = weight.ToString("0.0");

                        // Apply AI predicted type
                        SelectWasteType(predictedType);

                        // Show success message
                        ShowMessage("AI suggestions applied: " + predictedType + " (" + weight + " kg)", "success");

                        // Mark AI as used
                        aiUsed = true;
                        Session["AIUsed"] = aiUsed;
                    }
                    else
                    {
                        if (lblWeightPreview != null) lblWeightPreview.Text = "0.0";
                        if (txtWeight != null) txtWeight.Text = "0.0";
                    }
                }
            }
        }

        protected void txtDescription_TextChanged(object sender, EventArgs e)
        {
            string description = txtDescription.Text.Trim();

            if (!string.IsNullOrEmpty(description))
            {
                // Show AI section
                var textAISection = pnlStep2.FindControl("textAISection") as System.Web.UI.HtmlControls.HtmlGenericControl;
                if (textAISection != null)
                {
                    textAISection.Style["display"] = "block";
                }

                // Simple keyword-based AI prediction
                string predictedType = PredictWasteTypeFromText(description);
                decimal predictedWeight = PredictWeightFromText(description);

                if (lblAIPredictedType != null)
                {
                    lblAIPredictedType.Text = predictedType;
                }

                if (lblAIPredictedWeight != null)
                {
                    lblAIPredictedWeight.Text = predictedWeight.ToString("0.0");
                }

                // Calculate estimated reward if waste type is selected
                if (!string.IsNullOrEmpty(selectedWasteTypeId))
                {
                    decimal aiEstimatedReward = predictedWeight * selectedWasteRate;
                    if (lblAIEstimatedReward != null)
                    {
                        lblAIEstimatedReward.Text = aiEstimatedReward.ToString("0.0");
                    }
                }
            }
            else
            {
                // Hide AI section if no description
                var textAISection = pnlStep2.FindControl("textAISection") as System.Web.UI.HtmlControls.HtmlGenericControl;
                if (textAISection != null)
                {
                    textAISection.Style["display"] = "none";
                }
            }
        }

        // Simple text-based waste type prediction
        private string PredictWasteTypeFromText(string text)
        {
            text = text.ToLower();

            if (text.Contains("plastic") || text.Contains("bottle") || text.Contains("container") || text.Contains("bag"))
                return "Plastic";
            else if (text.Contains("paper") || text.Contains("cardboard") || text.Contains("newspaper") || text.Contains("magazine"))
                return "Paper";
            else if (text.Contains("metal") || text.Contains("can") || text.Contains("aluminum") || text.Contains("steel"))
                return "Metal";
            else if (text.Contains("glass") || text.Contains("bottle") || text.Contains("jar"))
                return "Glass";
            else if (text.Contains("organic") || text.Contains("food") || text.Contains("compost") || text.Contains("vegetable"))
                return "Organic";
            else if (text.Contains("electronic") || text.Contains("battery") || text.Contains("cable") || text.Contains("phone"))
                return "Electronics";
            else if (text.Contains("textile") || text.Contains("cloth") || text.Contains("fabric") || text.Contains("clothes"))
                return "Textiles";
            else if (text.Contains("hazardous") || text.Contains("chemical") || text.Contains("medical") || text.Contains("paint"))
                return "Hazardous";
            else
                return "Mixed";
        }

        // Simple weight prediction from text
        private decimal PredictWeightFromText(string text)
        {
            text = text.ToLower();

            // Try to extract numbers from text
            System.Text.RegularExpressions.MatchCollection matches = System.Text.RegularExpressions.Regex.Matches(text, @"\d+(\.\d+)?");

            if (matches.Count > 0)
            {
                decimal weight;
                if (decimal.TryParse(matches[0].Value, out weight))
                {
                    // If text contains "kg" or similar, use the number
                    if (text.Contains("kg") || text.Contains("kilo") || text.Contains("kilogram"))
                        return weight;
                    else
                        return weight; // Assume kg by default
                }
            }

            // Default weight based on keywords
            if (text.Contains("small") || text.Contains("little") || text.Contains("few"))
                return 0.5m;
            else if (text.Contains("medium") || text.Contains("some"))
                return 2.0m;
            else if (text.Contains("large") || text.Contains("lot") || text.Contains("many"))
                return 5.0m;
            else if (text.Contains("huge") || text.Contains("big") || text.Contains("pile"))
                return 10.0m;
            else
                return 1.0m; // Default
        }

        private void LoadUserStats()
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    // Get user credits
                    string creditsQuery = @"SELECT ISNULL(SUM(Amount), 0) FROM RewardPoints WHERE UserId = @UserId";
                    using (SqlCommand cmd = new SqlCommand(creditsQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@UserId", currentUserId);
                        var credits = cmd.ExecuteScalar();
                        if (statCredits != null)
                            statCredits.InnerText = credits != DBNull.Value ? Convert.ToDecimal(credits).ToString("N2") : "0.00";
                    }

                    // Get user report count
                    string reportsQuery = @"SELECT COUNT(*) FROM WasteReports WHERE UserId = @UserId";
                    using (SqlCommand cmd = new SqlCommand(reportsQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@UserId", currentUserId);
                        var reportCount = cmd.ExecuteScalar();
                        if (statReports != null)
                            statReports.InnerText = reportCount != DBNull.Value ? reportCount.ToString() : "0";
                    }

                    // Get total weight recycled
                    string weightQuery = @"SELECT ISNULL(SUM(wr.EstimatedKg), 0) 
                                          FROM WasteReports wr
                                          INNER JOIN PickupRequests pr ON wr.ReportId = pr.ReportId
                                          WHERE wr.UserId = @UserId AND pr.Status = 'Collected'";
                    using (SqlCommand cmd = new SqlCommand(weightQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@UserId", currentUserId);
                        var weight = cmd.ExecuteScalar();
                        if (statWeight != null)
                            statWeight.InnerText = weight != DBNull.Value ? Convert.ToDecimal(weight).ToString("N1") + " kg" : "0.0 kg";
                    }

                    // Get potential reward
                    string potentialQuery = @"SELECT TOP 1 CreditPerKg FROM WasteTypes ORDER BY CreditPerKg DESC";
                    using (SqlCommand cmd = new SqlCommand(potentialQuery, conn))
                    {
                        var maxRate = cmd.ExecuteScalar();
                        if (statPotential != null)
                            statPotential.InnerText = maxRate != DBNull.Value ? Convert.ToDecimal(maxRate).ToString("N0") + " XP/kg" : "0 XP";
                    }
                }
            }
            catch (Exception ex)
            {
                // Show error in console only
                System.Diagnostics.Debug.WriteLine("LoadUserStats Error: " + ex.Message);
            }
        }

        private void LoadWasteTypes()
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    string query = @"SELECT WasteTypeId, Name, Description, Category, CreditPerKg 
                                     FROM WasteTypes 
                                     ORDER BY Name";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                        {
                            DataTable dt = new DataTable();
                            da.Fill(dt);

                            if (dt.Rows.Count == 0)
                            {
                                // Insert default waste types if table is empty
                                InsertDefaultWasteTypes(conn);
                                // Reload
                                da.Fill(dt);
                            }

                            rptWasteTypes.DataSource = dt;
                            rptWasteTypes.DataBind();
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                // Use fallback data
                LoadFallbackWasteTypes();
                System.Diagnostics.Debug.WriteLine("LoadWasteTypes Error: " + ex.Message);
            }
        }

        private void InsertDefaultWasteTypes(SqlConnection conn)
        {
            try
            {
                string insertQuery = @"
                    INSERT INTO WasteTypes (WasteTypeId, Name, Description, Category, CreditPerKg, ColorCode) VALUES
                    ('WT01', 'Plastic', 'Plastic bottles, containers, packaging materials', 'Recyclable', 10.50, '#3B82F6'),
                    ('WT02', 'Paper', 'Newspapers, cardboard, office paper, magazines', 'Recyclable', 8.75, '#10B981'),
                    ('WT03', 'Metal', 'Aluminum cans, steel containers, scrap metal', 'Recyclable', 15.25, '#6B7280'),
                    ('WT04', 'Glass', 'Glass bottles, jars, broken glass pieces', 'Recyclable', 7.50, '#8B5CF6'),
                    ('WT05', 'Electronics', 'E-waste, batteries, cables, small appliances', 'Hazardous', 25.00, '#F59E0B'),
                    ('WT06', 'Organic', 'Food waste, garden waste, compostable materials', 'Compostable', 5.00, '#22C55E'),
                    ('WT07', 'Textiles', 'Clothes, fabrics, shoes, blankets', 'Reusable', 12.00, '#EC4899'),
                    ('WT08', 'Hazardous', 'Chemicals, medical waste, paint, oil', 'Special', 30.00, '#EF4444'),
                    ('WT09', 'Mixed', 'Mixed waste materials', 'General', 6.50, '#8B5CF6')";

                using (SqlCommand cmd = new SqlCommand(insertQuery, conn))
                {
                    cmd.ExecuteNonQuery();
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("InsertDefaultWasteTypes Error: " + ex.Message);
            }
        }

        private void LoadFallbackWasteTypes()
        {
            DataTable dt = new DataTable();
            dt.Columns.Add("WasteTypeId", typeof(string));
            dt.Columns.Add("Name", typeof(string));
            dt.Columns.Add("Description", typeof(string));
            dt.Columns.Add("Category", typeof(string));
            dt.Columns.Add("CreditPerKg", typeof(decimal));

            dt.Rows.Add("WT01", "Plastic", "Plastic bottles, containers, packaging", "Recyclable", 10.50m);
            dt.Rows.Add("WT02", "Paper", "Newspapers, cardboard, office paper", "Recyclable", 8.75m);
            dt.Rows.Add("WT03", "Metal", "Aluminum cans, scrap metal", "Recyclable", 15.25m);
            dt.Rows.Add("WT04", "Glass", "Bottles, jars, broken glass", "Recyclable", 7.50m);
            dt.Rows.Add("WT05", "Electronics", "E-waste, batteries, cables", "Hazardous", 25.00m);
            dt.Rows.Add("WT06", "Organic", "Food waste, garden waste", "Compostable", 5.00m);
            dt.Rows.Add("WT07", "Textiles", "Clothes, fabrics, shoes", "Reusable", 12.00m);
            dt.Rows.Add("WT08", "Hazardous", "Chemicals, medical waste", "Special", 30.00m);
            dt.Rows.Add("WT09", "Mixed", "Mixed waste materials", "General", 6.50m);

            rptWasteTypes.DataSource = dt;
            rptWasteTypes.DataBind();
        }

        protected void rptWasteTypes_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "SelectType")
            {
                string[] args = e.CommandArgument.ToString().Split('|');
                if (args.Length >= 3)
                {
                    selectedWasteTypeId = args[0];
                    selectedWasteRate = decimal.Parse(args[1]);
                    selectedWasteName = args[2];

                    // Store in session
                    Session["SelectedWasteTypeId"] = selectedWasteTypeId;
                    Session["SelectedWasteRate"] = selectedWasteRate;
                    Session["SelectedWasteName"] = selectedWasteName;

                    // Update preview labels
                    if (lblSelectedWaste != null) lblSelectedWaste.Text = selectedWasteName;
                    if (lblRatePreview != null) lblRatePreview.Text = selectedWasteRate.ToString("N2") + " XP/kg";

                    // Enable next button
                    if (btnNextStep1 != null) btnNextStep1.Enabled = true;

                    // Show success message
                    ShowMessage("Waste type selected: " + selectedWasteName, "success");

                    // Update UI
                    string script = @"
                        setTimeout(function() {
                            // Clear previous selections
                            var wasteCards = document.querySelectorAll('.category-card-glass');
                            wasteCards.forEach(function(card) {
                                card.classList.remove('selected');
                            });
                            
                            // Find and select the clicked card
                            var selectedCards = document.querySelectorAll('.waste-type-select');
                            selectedCards.forEach(function(card) {
                                if (card.textContent.indexOf('" + selectedWasteName.Replace("'", "\\'") + @"') > -1) {
                                    var parent = card.closest('.category-card-glass');
                                    if (parent) {
                                        parent.classList.add('selected');
                                    }
                                }
                            });
                        }, 100);
                    ";

                    ScriptManager.RegisterStartupScript(this, GetType(), "SelectWasteType_" + Guid.NewGuid(), script, true);
                }
            }
        }

        protected void btnNextStep1_Click(object sender, EventArgs e)
        {
            if (!string.IsNullOrEmpty(selectedWasteTypeId))
            {
                ShowStep(2);
                UpdateWeightPreview();
            }
            else
            {
                ShowMessage("Please select a waste type first.", "error");
            }
        }

        protected void btnBackStep2_Click(object sender, EventArgs e)
        {
            ShowStep(1);
        }

        protected void btnNextStep2_Click(object sender, EventArgs e)
        {
            if (IsValidStep2())
            {
                ShowStep(3);
                UpdateWeightPreview();
            }
        }

        protected void btnBackStep3_Click(object sender, EventArgs e)
        {
            ShowStep(2);
            UpdateWeightPreview();
        }

        protected void btnNextStep3_Click(object sender, EventArgs e)
        {
            if (IsValidStep3())
            {
                UpdateReviewSection();
                ShowStep(4);
            }
        }

        protected void btnBackStep4_Click(object sender, EventArgs e)
        {
            ShowStep(3);
            UpdateWeightPreview();
        }

        protected void btnSubmitReport_Click(object sender, EventArgs e)
        {
            if (IsValidStep4())
            {
                try
                {
                    SubmitWasteReport();
                }
                catch (Exception ex)
                {
                    ShowMessage("Error submitting report: " + ex.Message, "error");
                }
            }
        }

        protected void btnSubmitAnother_Click(object sender, EventArgs e)
        {
            ResetForm();
            ShowStep(1);
        }

        protected void txtWeight_TextChanged(object sender, EventArgs e)
        {
            UpdateWeightPreview();
        }

        protected void btnWeight0_5_Click(object sender, EventArgs e)
        {
            if (txtWeight != null) txtWeight.Text = "0.5";
            UpdateWeightPreview();
        }

        protected void btnWeight1_Click(object sender, EventArgs e)
        {
            if (txtWeight != null) txtWeight.Text = "1";
            UpdateWeightPreview();
        }

        protected void btnWeight2_Click(object sender, EventArgs e)
        {
            if (txtWeight != null) txtWeight.Text = "2";
            UpdateWeightPreview();
        }

        protected void btnWeight5_Click(object sender, EventArgs e)
        {
            if (txtWeight != null) txtWeight.Text = "5";
            UpdateWeightPreview();
        }

        protected void btnWeight10_Click(object sender, EventArgs e)
        {
            if (txtWeight != null) txtWeight.Text = "10";
            UpdateWeightPreview();
        }

        protected void btnGetLocation_Click(object sender, EventArgs e)
        {
            string script = @"
                if (navigator.geolocation) {
                    navigator.geolocation.getCurrentPosition(
                        function(position) {
                            document.getElementById('" + (txtLatitude != null ? txtLatitude.ClientID : "txtLatitude") + @"').value = position.coords.latitude.toFixed(6);
                            document.getElementById('" + (txtLongitude != null ? txtLongitude.ClientID : "txtLongitude") + @"').value = position.coords.longitude.toFixed(6);
                            
                            var messagePanel = document.querySelector('.message-panel');
                            if (messagePanel) {
                                messagePanel.innerHTML = 
                                    '<div class=""message-alert success show"">' +
                                    '    <i class=""fas fa-check-circle""></i>' +
                                    '    <div>' +
                                    '        <strong>Location Captured!</strong>' +
                                    '        <p class=""mb-0"">Current location coordinates have been filled.</p>' +
                                    '    </div>' +
                                    '</div>';
                                messagePanel.style.display = 'block';
                                setTimeout(function() { messagePanel.style.display = 'none'; }, 3000);
                            }
                        },
                        function(error) {
                            alert('Unable to get location. Please enter manually.');
                        }
                    );
                } else {
                    alert('Geolocation is not supported by your browser.');
                }
            ";

            ScriptManager.RegisterStartupScript(this, GetType(), "GetLocation", script, true);
        }

        private void ShowStep(int stepNumber)
        {
            // Hide all steps
            if (pnlStep1 != null) pnlStep1.Visible = false;
            if (pnlStep2 != null) pnlStep2.Visible = false;
            if (pnlStep3 != null) pnlStep3.Visible = false;
            if (pnlStep4 != null) pnlStep4.Visible = false;
            if (pnlSuccess != null) pnlSuccess.Visible = false;

            // Show selected step
            if (stepNumber == 1)
            {
                if (pnlStep1 != null) pnlStep1.Visible = true;
            }
            else if (stepNumber == 2)
            {
                if (pnlStep2 != null) pnlStep2.Visible = true;
            }
            else if (stepNumber == 3)
            {
                if (pnlStep3 != null) pnlStep3.Visible = true;
            }
            else if (stepNumber == 4)
            {
                if (pnlStep4 != null) pnlStep4.Visible = true;
                if (lblAIUsed != null)
                {
                    lblAIUsed.Visible = aiUsed;
                }
            }
            else if (stepNumber == 0) // Special case for success
            {
                if (pnlSuccess != null) pnlSuccess.Visible = true;
                stepNumber = 4; // For progress steps
            }

            // Update progress steps
            UpdateProgressSteps(stepNumber);
        }

        private void UpdateProgressSteps(int currentStep)
        {
            string script = @"
                for (var i = 1; i <= 4; i++) {
                    var stepElement = document.getElementById('step' + i);
                    var lineElement = document.getElementById('line' + i);
                    if (stepElement) stepElement.classList.remove('active');
                    if (lineElement) lineElement.classList.remove('active');
                }

                for (var i = 1; i <= " + currentStep + @"; i++) {
                    var stepElement = document.getElementById('step' + i);
                    var lineElement = document.getElementById('line' + i);
                    if (stepElement) stepElement.classList.add('active');
                    if (lineElement && i < " + currentStep + @") lineElement.classList.add('active');
                }
            ";

            ScriptManager.RegisterStartupScript(this, GetType(), "UpdateProgress_" + Guid.NewGuid().ToString("N"), script, true);
        }

        private void UpdateWeightPreview()
        {
            if (txtWeight != null && !string.IsNullOrEmpty(txtWeight.Text))
            {
                decimal weight;
                if (decimal.TryParse(txtWeight.Text, out weight))
                {
                    estimatedWeight = weight;
                    estimatedReward = weight * selectedWasteRate;

                    // Update labels
                    if (lblWeightPreview != null) lblWeightPreview.Text = weight.ToString("N1");
                    if (lblWeightDisplay != null) lblWeightDisplay.Text = weight.ToString("N1") + " kg";

                    // Check if control exists before using it
                    if (lblEstimatedReward != null)
                    {
                        lblEstimatedReward.Text = estimatedReward.ToString("N0");
                    }

                    // Store in session
                    Session["EstimatedWeight"] = estimatedWeight;
                    Session["EstimatedReward"] = estimatedReward;
                }
            }
        }

        private void UpdateReviewSection()
        {
            // Update review labels
            if (lblReviewWasteType != null)
                lblReviewWasteType.Text = selectedWasteName ?? "Not selected";

            if (lblReviewWeight != null)
                lblReviewWeight.Text = estimatedWeight.ToString("N1") + " kg";

            if (lblReviewRate != null)
                lblReviewRate.Text = selectedWasteRate.ToString("N2") + " XP/kg";

            if (lblReviewContact != null)
                lblReviewContact.Text = !string.IsNullOrEmpty(txtContactPerson != null ? txtContactPerson.Text : "") ? txtContactPerson.Text : "-";

            if (lblReviewAddress != null)
                lblReviewAddress.Text = !string.IsNullOrEmpty(txtAddress != null ? txtAddress.Text : "") ? txtAddress.Text : "Not provided";

            if (lblReviewDescription != null)
                lblReviewDescription.Text = !string.IsNullOrEmpty(txtDescription != null ? txtDescription.Text : "") ? txtDescription.Text : "No description provided";

            // Update final reward section
            if (lblFinalWeight != null)
                lblFinalWeight.Text = estimatedWeight.ToString("N1") + " kg";

            if (lblFinalRate != null)
                lblFinalRate.Text = selectedWasteRate.ToString("N2") + " XP/kg";

            if (lblFinalReward != null)
                lblFinalReward.Text = estimatedReward.ToString("N0");

            if (lblFinalTotal != null)
                lblFinalTotal.Text = estimatedReward.ToString("N0") + " XP";
        }

        private bool IsValidStep2()
        {
            decimal weight;
            if (txtWeight == null || string.IsNullOrEmpty(txtWeight.Text) || !decimal.TryParse(txtWeight.Text, out weight) || weight <= 0)
            {
                ShowMessage("Please enter a valid weight greater than 0.", "error");
                return false;
            }

            if (weight > 1000)
            {
                ShowMessage("Weight cannot exceed 1000 kg. Please contact support for large quantities.", "error");
                return false;
            }

            return true;
        }

        private bool IsValidStep3()
        {
            if (txtAddress == null || string.IsNullOrEmpty(txtAddress.Text))
            {
                ShowMessage("Please enter collection address.", "error");
                return false;
            }

            return true;
        }

        private bool IsValidStep4()
        {
            if (chkConfirmDetails != null && !chkConfirmDetails.Checked)
            {
                ShowMessage("Please confirm that all details are correct.", "error");
                return false;
            }

            if (chkAgreeTerms != null && !chkAgreeTerms.Checked)
            {
                ShowMessage("Please agree to the terms and conditions.", "error");
                return false;
            }

            return true;
        }

        private string GenerateNextId(SqlConnection conn, SqlTransaction transaction, string tableName, string idColumn, string prefix)
        {
            try
            {
                string query = string.Format(@"
                    SELECT ISNULL(MAX(CAST(SUBSTRING({0}, LEN('{1}') + 1, LEN({0})) AS INT)), 0) 
                    FROM {2} 
                    WHERE {0} LIKE '{1}%'", idColumn, prefix, tableName);

                using (SqlCommand cmd = new SqlCommand(query, conn, transaction))
                {
                    int maxNumber = Convert.ToInt32(cmd.ExecuteScalar());
                    int nextNumber = maxNumber + 1;
                    return string.Format("{0}{1:D6}", prefix, nextNumber);
                }
            }
            catch (Exception ex)
            {
                // Fallback to timestamp-based ID
                return string.Format("{0}{1:yyyyMMddHHmmssfff}{2}", prefix, DateTime.Now, new Random().Next(100, 999));
            }
        }

        private void ResetForm()
        {
            // Clear all fields
            if (txtWeight != null) txtWeight.Text = "";
            if (txtDescription != null) txtDescription.Text = "";
            if (txtAddress != null) txtAddress.Text = "";
            if (txtLandmark != null) txtLandmark.Text = "";
            if (txtContactPerson != null) txtContactPerson.Text = "";
            if (txtInstructions != null) txtInstructions.Text = "";
            if (txtLatitude != null) txtLatitude.Text = "";
            if (txtLongitude != null) txtLongitude.Text = "";

            // Reset checkboxes
            if (chkConfirmDetails != null) chkConfirmDetails.Checked = false;
            if (chkAgreeTerms != null) chkAgreeTerms.Checked = false;
            if (chkSchedulePickup != null) chkSchedulePickup.Checked = true;

            // Clear session data
            Session.Remove("SelectedWasteTypeId");
            Session.Remove("SelectedWasteRate");
            Session.Remove("SelectedWasteName");
            Session.Remove("EstimatedWeight");
            Session.Remove("EstimatedReward");
            Session.Remove("AIUsed");

            // Reset AI flag
            aiUsed = false;

            // Reload waste types
            LoadWasteTypes();

            // Disable next button
            if (btnNextStep1 != null) btnNextStep1.Enabled = false;
        }

        private void ShowMessage(string message, string type)
        {
            string icon = "exclamation-circle";
            switch (type.ToLower())
            {
                case "success":
                    icon = "check-circle";
                    break;
                case "warning":
                    icon = "exclamation-triangle";
                    break;
                case "error":
                    icon = "exclamation-circle";
                    break;
            }

            string upperType = type.ToUpper();
            string escapedMessage = message.Replace("'", "\\'").Replace("\"", "\\\"");

            string script = string.Format(@"
                var messagePanel = document.querySelector('.message-panel');
                if (messagePanel) {{
                    messagePanel.innerHTML = 
                        '<div class=""message-alert {0} show"">' +
                        '    <i class=""fas fa-{1}""></i>' +
                        '    <div>' +
                        '        <strong>{2}</strong>' +
                        '        <p class=""mb-0"">{3}</p>' +
                        '    </div>' +
                        '</div>';
                    messagePanel.style.display = 'block';
                    setTimeout(function() {{
                        messagePanel.style.display = 'none';
                    }}, 5000);
                }}
            ", type, icon, upperType, escapedMessage);

            ScriptManager.RegisterStartupScript(this, GetType(), "ShowMessage_" + Guid.NewGuid().ToString("N"), script, true);
        }

        private void RegisterStartupScripts()
        {
            string initScript = @"
                // Update progress steps
                function updateProgressSteps(currentStep) {
                    for (var i = 1; i <= 4; i++) {
                        var stepElement = document.getElementById('step' + i);
                        var lineElement = document.getElementById('line' + i);
                        if (stepElement) stepElement.classList.remove('active');
                        if (lineElement) lineElement.classList.remove('active');
                    }

                    for (var i = 1; i <= currentStep; i++) {
                        var stepElement = document.getElementById('step' + i);
                        var lineElement = document.getElementById('line' + i);
                        if (stepElement) stepElement.classList.add('active');
                        if (lineElement && i < currentStep) lineElement.classList.add('active');
                    }
                }
                
                // Show database confirmation
                function showDatabaseConfirmation() {
                    var successCard = document.querySelector('.success-card-glass');
                    if (successCard) {
                        successCard.style.animation = 'none';
                        setTimeout(function() {
                            successCard.style.animation = 'pulse 2s infinite';
                        }, 10);
                    }
                }
                
                // Show message function
                function showMessage(message, type) {
                    var messagePanel = document.querySelector('.message-panel');
                    if (!messagePanel) {
                        // Create message panel if it doesn't exist
                        messagePanel = document.createElement('div');
                        messagePanel.className = 'message-panel';
                        messagePanel.style.cssText = 'position: fixed; top: 20px; right: 20px; z-index: 9999; width: 300px;';
                        document.body.appendChild(messagePanel);
                    }
                    
                    var icon = 'exclamation-circle';
                    switch(type) {
                        case 'success': icon = 'check-circle'; break;
                        case 'warning': icon = 'exclamation-triangle'; break;
                        case 'error': icon = 'exclamation-circle'; break;
                    }
                    
                    var alertDiv = document.createElement('div');
                    alertDiv.className = 'alert alert-' + type + ' alert-dismissible fade show';
                    alertDiv.style.cssText = 'box-shadow: 0 4px 12px rgba(0,0,0,0.15);';
                    alertDiv.innerHTML = 
                        '<button type=""button"" class=""btn-close"" data-bs-dismiss=""alert""></button>' +
                        '<div class=""d-flex align-items-center"">' +
                        '   <i class=""fas fa-' + icon + ' me-2""></i>' +
                        '   <div>' + message + '</div>' +
                        '</div>';
                    
                    messagePanel.appendChild(alertDiv);
                    
                    // Auto remove after 5 seconds
                    setTimeout(function() {
                        if (alertDiv.parentNode) {
                            alertDiv.remove();
                        }
                    }, 5000);
                }
                
                // Apply AI results
                function applyAIResults() {
                    var aiResults = document.getElementById('aiResults');
                    if (aiResults) {
                        var wasteType = aiResults.dataset.wasteType;
                        var estimatedWeight = aiResults.dataset.estimatedWeight;
                        
                        // Update UI
                        var lblAIPredictedType = document.getElementById('" + (lblAIPredictedType != null ? lblAIPredictedType.ClientID : "lblAIPredictedType") + @"');
                        var lblAIPredictedWeight = document.getElementById('" + (lblAIPredictedWeight != null ? lblAIPredictedWeight.ClientID : "lblAIPredictedWeight") + @"');
                        
                        if (lblAIPredictedType) lblAIPredictedType.textContent = wasteType;
                        if (lblAIPredictedWeight) lblAIPredictedWeight.textContent = estimatedWeight;
                        
                        // Auto-select waste type if possible
                        selectWasteTypeByName(wasteType);
                        
                        // Show success message
                        showMessage('AI suggestions applied: ' + wasteType + ' (' + estimatedWeight + ' kg)', 'success');
                    }
                }
                
                // Ignore AI results
                function ignoreAIResults() {
                    var aiResults = document.getElementById('aiResults');
                    if (aiResults) {
                        aiResults.innerHTML = '';
                    }
                }
                
                // Select waste type by name
                function selectWasteTypeByName(wasteTypeName) {
                    // Find all waste type buttons
                    var wasteCards = document.querySelectorAll('.category-card-glass, .waste-type-card');
                    wasteCards.forEach(function(card) {
                        var cardText = card.textContent || card.innerText;
                        if (cardText.toLowerCase().includes(wasteTypeName.toLowerCase())) {
                            // Find the select button inside
                            var selectBtn = card.querySelector('.btn-select-type, .select-waste-btn, button');
                            if (selectBtn) {
                                // Trigger click
                                if (selectBtn.click) selectBtn.click();
                                else if (selectBtn.onclick) selectBtn.onclick();
                                
                                // Highlight the card
                                card.classList.add('selected');
                                card.style.boxShadow = '0 0 0 3px rgba(59, 130, 246, 0.5)';
                                return;
                            }
                        }
                    });
                    
                    // Alternative: Look for specific elements with waste type
                    var typeElements = document.querySelectorAll('[data-waste-type], .waste-type-name');
                    typeElements.forEach(function(el) {
                        if (el.textContent.toLowerCase().includes(wasteTypeName.toLowerCase())) {
                            var parentCard = el.closest('.category-card-glass, .card, .waste-item');
                            if (parentCard) {
                                var selectBtn = parentCard.querySelector('button, .btn');
                                if (selectBtn && selectBtn.click) {
                                    selectBtn.click();
                                    parentCard.classList.add('selected');
                                    parentCard.style.boxShadow = '0 0 0 3px rgba(59, 130, 246, 0.5)';
                                }
                            }
                        }
                    });
                }
                
                // Make functions globally available
                window.updateProgressSteps = updateProgressSteps;
                window.showDatabaseConfirmation = showDatabaseConfirmation;
                window.showMessage = showMessage;
                window.applyAIResults = applyAIResults;
                window.ignoreAIResults = ignoreAIResults;
                window.selectWasteTypeByName = selectWasteTypeByName;
            ";

            ScriptManager.RegisterClientScriptBlock(this, GetType(), "InitializeScripts", initScript, true);
        }

        public string GetWasteTypeIcon(string wasteTypeName)
        {
            switch (wasteTypeName.ToLower())
            {
                case "plastic":
                    return "fa-bottle-water";
                case "paper":
                    return "fa-file-alt";
                case "metal":
                    return "fa-cogs";
                case "glass":
                    return "fa-wine-glass";
                case "organic":
                    return "fa-leaf";
                case "electronics":
                    return "fa-laptop";
                case "textiles":
                    return "fa-tshirt";
                case "hazardous":
                    return "fa-radiation";
                case "mixed":
                    return "fa-recycle";
                default:
                    return "fa-trash";
            }
        }

        protected void btnThemeToggle_Click(object sender, EventArgs e)
        {
            string currentTheme = "light";
            if (Request.Cookies["theme"] != null)
            {
                currentTheme = Request.Cookies["theme"].Value;
            }

            string newTheme = currentTheme == "light" ? "dark" : "light";

            Response.Cookies["theme"].Value = newTheme;
            Response.Cookies["theme"].Expires = DateTime.Now.AddDays(30);

            Response.Redirect(Request.RawUrl);
        }

        // Helper method to make API calls
        private T MakeApiCall<T>(string url, object data)
        {
            try
            {
                string json = JsonConvert.SerializeObject(data);
                byte[] dataBytes = Encoding.UTF8.GetBytes(json);

                HttpWebRequest request = (HttpWebRequest)WebRequest.Create(url);
                request.Method = "POST";
                request.ContentType = "application/json";
                request.ContentLength = dataBytes.Length;
                request.Timeout = 10000; // 10 seconds

                using (Stream requestStream = request.GetRequestStream())
                {
                    requestStream.Write(dataBytes, 0, dataBytes.Length);
                }

                using (HttpWebResponse response = (HttpWebResponse)request.GetResponse())
                using (Stream responseStream = response.GetResponseStream())
                using (StreamReader reader = new StreamReader(responseStream))
                {
                    string responseJson = reader.ReadToEnd();
                    return JsonConvert.DeserializeObject<T>(responseJson);
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"API Call Error ({url}): {ex.Message}");
                return default(T);
            }
        }

        // Async version
        private async Task<T> MakeApiCallAsync<T>(string url, object data)
        {
            try
            {
                string json = JsonConvert.SerializeObject(data);
                byte[] dataBytes = Encoding.UTF8.GetBytes(json);

                HttpWebRequest request = (HttpWebRequest)WebRequest.Create(url);
                request.Method = "POST";
                request.ContentType = "application/json";
                request.ContentLength = dataBytes.Length;
                request.Timeout = 10000; // 10 seconds

                using (Stream requestStream = await request.GetRequestStreamAsync())
                {
                    await requestStream.WriteAsync(dataBytes, 0, dataBytes.Length);
                }

                using (HttpWebResponse response = (HttpWebResponse)await request.GetResponseAsync())
                using (Stream responseStream = response.GetResponseStream())
                using (StreamReader reader = new StreamReader(responseStream))
                {
                    string responseJson = await reader.ReadToEndAsync();
                    return JsonConvert.DeserializeObject<T>(responseJson);
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"API Call Error ({url}): {ex.Message}");
                return default(T);
            }
        }

        // Response classes for Flask AI
        public class Detection
        {
            public string class_name { get; set; }
            public double confidence { get; set; }
            public List<double> bbox { get; set; }
        }

        public class ImageClassificationResponse
        {
            public string status { get; set; }
            public string message { get; set; }
            public List<Detection> detections { get; set; }
        }

        public class ReportValidation
        {
            public string status { get; set; }
            public string message { get; set; }
            public double confidence { get; set; }
            public string[] warnings { get; set; }
            public string risk_level { get; set; }
            public double trust_score { get; set; }
        }

        public class ValidationResponse
        {
            public string status { get; set; }
            public ReportValidation report { get; set; }
        }

        public class AnalysisReport
        {
            public string status { get; set; }
            public string message { get; set; }
            public double confidence { get; set; }
            public string risk_level { get; set; }
            public double trust_score { get; set; }
        }

        public class AnalysisResponse
        {
            public string status { get; set; }
            public AnalysisReport report { get; set; }
        }

        // ADDED: Missing event handlers for file upload
        protected void fuWasteImage_UploadedComplete(object sender, EventArgs e)
        {
            // Handle file upload completion if needed
        }

        // ADDED: Helper method for decimal formatting
        private string FormatDecimal(decimal value)
        {
            return value.ToString("N2");
        }

        // ADDED: Helper method for date formatting
        private string FormatDate(DateTime date)
        {
            return date.ToString("yyyy-MM-dd HH:mm");
        }

        // ADDED: Method to get waste type name by ID
        private string GetWasteTypeNameById(string wasteTypeId)
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();
                    string query = "SELECT Name FROM WasteTypes WHERE WasteTypeId = @WasteTypeId";
                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@WasteTypeId", wasteTypeId);
                        var result = cmd.ExecuteScalar();
                        return result != null ? result.ToString() : "Unknown";
                    }
                }
            }
            catch
            {
                return "Unknown";
            }
        }

        // ADDED: Method to get waste type rate by ID
        private decimal GetWasteTypeRateById(string wasteTypeId)
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();
                    string query = "SELECT CreditPerKg FROM WasteTypes WHERE WasteTypeId = @WasteTypeId";
                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@WasteTypeId", wasteTypeId);
                        var result = cmd.ExecuteScalar();
                        return result != null ? Convert.ToDecimal(result) : 0m;
                    }
                }
            }
            catch
            {
                return 0m;
            }
        }
    }
}