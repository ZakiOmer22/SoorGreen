using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.Configuration;
using System.Web.UI;

namespace SoorGreen.Admin
{
    public partial class ReportWaste : System.Web.UI.Page
    {
        private string connectionString = WebConfigurationManager.ConnectionStrings["SoorGreenDBConnectionString"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // Check if user is logged in
                if (Session["UserID"] == null)
                {
                    Response.Redirect("~/Login.aspx");
                    return;
                }

                // Set default values or load data if needed
                litMaxReward.Text = "50"; // Maximum possible reward

                // Initialize coordinates with default values
                hdnLatitude.Value = "40.7128";
                hdnLongitude.Value = "-74.0060";
            }
        }

        protected void btnSubmitReport_Click(object sender, EventArgs e)
        {
            try
            {
                if (Session["UserID"] == null)
                {
                    ShowMessage("Please log in to submit a report", "error");
                    return;
                }

                // Validate required fields
                if (string.IsNullOrEmpty(hdnWasteType.Value) || string.IsNullOrEmpty(txtWeight.Text))
                {
                    ShowMessage("Please fill in all required fields", "error");
                    return;
                }

                // Validate weight is a positive number
                decimal weight;
                if (!decimal.TryParse(txtWeight.Text, out weight) || weight <= 0)
                {
                    ShowMessage("Please enter a valid weight greater than 0", "error");
                    return;
                }

                // Validate coordinates
                if (string.IsNullOrEmpty(hdnLatitude.Value) || string.IsNullOrEmpty(hdnLongitude.Value))
                {
                    ShowMessage("Please set a location for collection", "error");
                    return;
                }

                // Validate address
                if (string.IsNullOrEmpty(txtAddress.Text.Trim()))
                {
                    ShowMessage("Please enter collection address", "error");
                    return;
                }

                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    // Check if required tables exist
                    if (!TableExists(conn, "WasteReports"))
                    {
                        CreateWasteReportsTable(conn);
                    }

                    if (!TableExists(conn, "PickupRequests"))
                    {
                        CreatePickupRequestsTable(conn);
                    }

                    // Get WasteTypeId based on selected waste type
                    string wasteTypeId = GetWasteTypeId(hdnWasteType.Value);

                    // Generate Report ID
                    string reportId = GenerateReportId(conn);

                    // Handle photo upload
                    string photoUrl = GetPhotoUrl();

                    // Insert waste report
                    string query = @"INSERT INTO WasteReports (ReportId, UserId, WasteTypeId, EstimatedKg, Description, Address, Landmark, Instructions, Lat, Lng, PhotoUrl, Status, CreatedAt)
                                 VALUES (@ReportId, @UserId, @WasteTypeId, @EstimatedKg, @Description, @Address, @Landmark, @Instructions, @Lat, @Lng, @PhotoUrl, 'Pending', GETDATE())";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@ReportId", reportId);
                        cmd.Parameters.AddWithValue("@UserId", Session["UserID"].ToString());
                        cmd.Parameters.AddWithValue("@WasteTypeId", wasteTypeId);
                        cmd.Parameters.AddWithValue("@EstimatedKg", weight);
                        cmd.Parameters.AddWithValue("@Description", txtDescription.Text.Trim());
                        cmd.Parameters.AddWithValue("@Address", txtAddress.Text.Trim());
                        cmd.Parameters.AddWithValue("@Landmark", txtLandmark.Text.Trim());
                        cmd.Parameters.AddWithValue("@Instructions", txtInstructions.Text.Trim());
                        cmd.Parameters.AddWithValue("@Lat", decimal.Parse(hdnLatitude.Value));
                        cmd.Parameters.AddWithValue("@Lng", decimal.Parse(hdnLongitude.Value));
                        cmd.Parameters.AddWithValue("@PhotoUrl", photoUrl);

                        int result = cmd.ExecuteNonQuery();

                        if (result > 0)
                        {
                            // Create pickup request
                            CreatePickupRequest(conn, reportId);

                            // Log activity
                            LogUserActivity(Session["UserID"].ToString(), "WasteReport",
                                string.Format("Reported {0}kg of {1} for collection", weight, GetWasteTypeName(hdnWasteType.Value)), 5);

                            ShowMessage("Waste report submitted successfully! Report ID: " + reportId + ". A collector will be assigned soon.", "success");
                            ClearForm();

                            // Redirect to dashboard after successful submission
                            ScriptManager.RegisterStartupScript(this, this.GetType(), "redirectScript",
                                "setTimeout(function() { window.location.href = 'Dashboard.aspx'; }, 3000);", true);
                        }
                        else
                        {
                            ShowMessage("Failed to submit waste report. Please try again.", "error");
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Error submitting report: " + ex.Message, "error");
                // Log error
                LogError("ReportWaste", Request.Url.ToString(), ex.Message);
            }
        }

        private bool TableExists(SqlConnection conn, string tableName)
        {
            try
            {
                string query = "SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = @TableName";
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@TableName", tableName);
                    int count = (int)cmd.ExecuteScalar();
                    return count > 0;
                }
            }
            catch
            {
                return false;
            }
        }

        private void CreateWasteReportsTable(SqlConnection conn)
        {
            string query = @"
                CREATE TABLE WasteReports (
                    ReportId NVARCHAR(20) PRIMARY KEY,
                    UserId NVARCHAR(50) NOT NULL,
                    WasteTypeId NVARCHAR(10) NOT NULL,
                    EstimatedKg DECIMAL(10,2) NOT NULL,
                    Description NVARCHAR(500) NULL,
                    Address NVARCHAR(500) NOT NULL,
                    Landmark NVARCHAR(200) NULL,
                    Instructions NVARCHAR(300) NULL,
                    Lat DECIMAL(10,6) NOT NULL,
                    Lng DECIMAL(10,6) NOT NULL,
                    PhotoUrl NVARCHAR(500) NULL,
                    Status NVARCHAR(20) NOT NULL DEFAULT 'Pending',
                    CreatedAt DATETIME NOT NULL,
                    UpdatedAt DATETIME NULL
                )";

            using (SqlCommand cmd = new SqlCommand(query, conn))
            {
                cmd.ExecuteNonQuery();
            }
        }

        private void CreatePickupRequestsTable(SqlConnection conn)
        {
            string query = @"
                CREATE TABLE PickupRequests (
                    PickupId NVARCHAR(20) PRIMARY KEY,
                    ReportId NVARCHAR(20) NOT NULL,
                    Status NVARCHAR(20) NOT NULL DEFAULT 'Requested',
                    ScheduledAt DATETIME NULL,
                    CollectorId NVARCHAR(50) NULL,
                    ActualKg DECIMAL(10,2) NULL,
                    CollectedAt DATETIME NULL,
                    CreatedAt DATETIME NOT NULL,
                    FOREIGN KEY (ReportId) REFERENCES WasteReports(ReportId)
                )";

            using (SqlCommand cmd = new SqlCommand(query, conn))
            {
                cmd.ExecuteNonQuery();
            }
        }

        private string GenerateReportId(SqlConnection conn)
        {
            try
            {
                string query = "SELECT ISNULL(MAX(CAST(SUBSTRING(ReportId, 3, LEN(ReportId)) AS INT)), 0) + 1 FROM WasteReports WHERE ReportId LIKE 'WR%'";
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    object result = cmd.ExecuteScalar();
                    int nextId = result != null ? Convert.ToInt32(result) : 1;
                    return "WR" + nextId.ToString("D6"); // Format as WR000001, WR000002, etc.
                }
            }
            catch
            {
                // Fallback if query fails
                return "WR" + DateTime.Now.ToString("yyyyMMddHHmmss");
            }
        }

        private void CreatePickupRequest(SqlConnection conn, string reportId)
        {
            try
            {
                string pickupId = GeneratePickupId(conn);

                string query = @"INSERT INTO PickupRequests (PickupId, ReportId, Status, ScheduledAt, CreatedAt) 
                             VALUES (@PickupId, @ReportId, 'Requested', DATEADD(DAY, 1, GETDATE()), GETDATE())";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@PickupId", pickupId);
                    cmd.Parameters.AddWithValue("@ReportId", reportId);
                    cmd.ExecuteNonQuery();
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error creating pickup request: " + ex.Message);
                // Continue without pickup request - main report is more important
            }
        }

        private string GeneratePickupId(SqlConnection conn)
        {
            try
            {
                string query = "SELECT ISNULL(MAX(CAST(SUBSTRING(PickupId, 3, LEN(PickupId)) AS INT)), 0) + 1 FROM PickupRequests WHERE PickupId LIKE 'PK%'";
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    object result = cmd.ExecuteScalar();
                    int nextId = result != null ? Convert.ToInt32(result) : 1;
                    return "PK" + nextId.ToString("D6"); // Format as PK000001, PK000002, etc.
                }
            }
            catch
            {
                // Fallback if query fails
                return "PK" + DateTime.Now.ToString("yyyyMMddHHmmss");
            }
        }

        private string GetWasteTypeId(string wasteType)
        {
            // Map waste type names to WasteTypeIds
            switch (wasteType.ToLower())
            {
                case "plastic": return "WT01";
                case "paper": return "WT02";
                case "glass": return "WT03";
                case "metal": return "WT04";
                case "ewaste": return "WT05";
                case "organic": return "WT06";
                default: return "WT01"; // Default to plastic
            }
        }

        private string GetWasteTypeName(string wasteType)
        {
            switch (wasteType.ToLower())
            {
                case "plastic": return "Plastic";
                case "paper": return "Paper";
                case "glass": return "Glass";
                case "metal": return "Metal";
                case "ewaste": return "E-Waste";
                case "organic": return "Organic";
                default: return "Waste";
            }
        }

        private string GetPhotoUrl()
        {
            if (filePhoto.HasFile)
            {
                try
                {
                    // Validate file type and size
                    string fileExtension = System.IO.Path.GetExtension(filePhoto.FileName).ToLower();
                    string[] allowedExtensions = { ".jpg", ".jpeg", ".png", ".gif" };

                    if (Array.IndexOf(allowedExtensions, fileExtension) == -1)
                    {
                        ShowMessage("Only image files (JPG, PNG, GIF) are allowed.", "error");
                        return string.Empty;
                    }

                    if (filePhoto.PostedFile.ContentLength > 5242880) // 5MB
                    {
                        ShowMessage("File size must be less than 5MB.", "error");
                        return string.Empty;
                    }

                    // Save file
                    string fileName = Guid.NewGuid().ToString() + fileExtension;
                    string filePath = Server.MapPath("~/Uploads/WastePhotos/") + fileName;

                    // Create directory if it doesn't exist
                    System.IO.Directory.CreateDirectory(Server.MapPath("~/Uploads/WastePhotos/"));

                    filePhoto.SaveAs(filePath);

                    return "/Uploads/WastePhotos/" + fileName;
                }
                catch (Exception ex)
                {
                    ShowMessage("Error uploading photo: " + ex.Message, "error");
                    return string.Empty;
                }
            }

            return string.Empty;
        }

        private void LogUserActivity(string userId, string activityType, string description, decimal points)
        {
            try
            {
                // Create UserActivities table if it doesn't exist
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    if (!TableExists(conn, "UserActivities"))
                    {
                        string createTableQuery = @"
                            CREATE TABLE UserActivities (
                                ActivityId INT IDENTITY(1,1) PRIMARY KEY,
                                UserId NVARCHAR(50) NOT NULL,
                                ActivityType NVARCHAR(50) NOT NULL,
                                Description NVARCHAR(500) NOT NULL,
                                Points DECIMAL(10,2) NOT NULL,
                                Timestamp DATETIME NOT NULL
                            )";

                        using (SqlCommand cmd = new SqlCommand(createTableQuery, conn))
                        {
                            cmd.ExecuteNonQuery();
                        }
                    }

                    string query = @"INSERT INTO UserActivities (UserId, ActivityType, Description, Points, Timestamp)
                                 VALUES (@UserId, @ActivityType, @Description, @Points, GETDATE())";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@UserId", userId);
                        cmd.Parameters.AddWithValue("@ActivityType", activityType);
                        cmd.Parameters.AddWithValue("@Description", description);
                        cmd.Parameters.AddWithValue("@Points", points);
                        cmd.ExecuteNonQuery();
                    }
                }
            }
            catch (Exception ex)
            {
                // Log error but don't break the main functionality
                System.Diagnostics.Debug.WriteLine("Error logging activity: " + ex.Message);
            }
        }

        private void LogError(string errorType, string url, string message)
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    // Create ErrorLogs table if it doesn't exist
                    if (!TableExists(conn, "ErrorLogs"))
                    {
                        string createTableQuery = @"
                            CREATE TABLE ErrorLogs (
                                LogId INT IDENTITY(1,1) PRIMARY KEY,
                                ErrorType NVARCHAR(100) NOT NULL,
                                Url NVARCHAR(500) NOT NULL,
                                Message NVARCHAR(MAX) NOT NULL,
                                UserIP NVARCHAR(50) NULL,
                                UserAgent NVARCHAR(500) NULL,
                                Referrer NVARCHAR(500) NULL,
                                CreatedAt DATETIME NOT NULL
                            )";

                        using (SqlCommand cmd = new SqlCommand(createTableQuery, conn))
                        {
                            cmd.ExecuteNonQuery();
                        }
                    }

                    string query = @"INSERT INTO ErrorLogs (ErrorType, Url, Message, UserIP, UserAgent, Referrer, CreatedAt)
                                 VALUES (@ErrorType, @Url, @Message, @UserIP, @UserAgent, @Referrer, GETDATE())";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@ErrorType", errorType);
                        cmd.Parameters.AddWithValue("@Url", url);
                        cmd.Parameters.AddWithValue("@Message", message);
                        cmd.Parameters.AddWithValue("@UserIP", GetUserIP());

                        string userAgent = Request.UserAgent;
                        if (string.IsNullOrEmpty(userAgent))
                            userAgent = "Unknown";
                        cmd.Parameters.AddWithValue("@UserAgent", userAgent);

                        string referrer = "Direct";
                        if (Request.UrlReferrer != null)
                            referrer = Request.UrlReferrer.ToString();
                        cmd.Parameters.AddWithValue("@Referrer", referrer);

                        cmd.ExecuteNonQuery();
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error logging error: " + ex.Message);
            }
        }

        private string GetUserIP()
        {
            string ip = Request.ServerVariables["HTTP_X_FORWARDED_FOR"];
            if (string.IsNullOrEmpty(ip))
                ip = Request.ServerVariables["REMOTE_ADDR"];

            if (!string.IsNullOrEmpty(ip))
                return ip;
            else if (!string.IsNullOrEmpty(Request.UserHostAddress))
                return Request.UserHostAddress;
            else
                return "Unknown";
        }

        private void ShowMessage(string message, string type)
        {
            string script = string.Format(@"showNotification('{0}', '{1}');",
                message.Replace("'", "\\'"), type);
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ShowMessage", script, true);
        }

        private void ClearForm()
        {
            hdnWasteType.Value = string.Empty;
            hdnWasteTypeId.Value = string.Empty;
            txtWeight.Text = string.Empty;
            txtDescription.Text = string.Empty;
            txtAddress.Text = string.Empty;
            txtLandmark.Text = string.Empty;
            txtInstructions.Text = string.Empty;
            hdnLatitude.Value = string.Empty;
            hdnLongitude.Value = string.Empty;

            // Clear file upload
            filePhoto.Dispose();
        }
    }
}