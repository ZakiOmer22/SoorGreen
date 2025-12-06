using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.Configuration;
using System.Web.UI;
using System.Web.Script.Serialization;
using System.Collections.Generic;
using System.Web.Services;

namespace SoorGreen.Admin
{
    public partial class PickupStatus : System.Web.UI.Page
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

                // Debug: Check Session
                System.Diagnostics.Debug.WriteLine("=== PAGE LOAD DEBUG ===");
                System.Diagnostics.Debug.WriteLine("Session UserID: " + Session["UserID"]);
                System.Diagnostics.Debug.WriteLine("Session Count: " + Session.Count);

                // Store user ID in hidden field for JavaScript
                hfUserId.Value = Session["UserID"].ToString();
                System.Diagnostics.Debug.WriteLine("UserID stored in hidden field: " + hfUserId.Value);

                // Load data
                LoadPickupsData();

                System.Diagnostics.Debug.WriteLine("=== END PAGE LOAD ===");
            }
        }

        private void LoadPickupsData()
        {
            try
            {
                if (Session["UserID"] == null)
                {
                    System.Diagnostics.Debug.WriteLine("Session UserID is null in LoadPickupsData!");
                    hfActivePickups.Value = "[]";
                    hfPickupHistory.Value = "[]";
                    hfStatsData.Value = "{\"TotalPickups\":0,\"ActivePickups\":0,\"CompletedPickups\":0,\"SuccessRate\":\"0%\",\"TotalXP\":0}";
                    return;
                }

                string userId = Session["UserID"].ToString();
                System.Diagnostics.Debug.WriteLine("=== LOADING PICKUP DATA ===");
                System.Diagnostics.Debug.WriteLine("UserID from Session: " + userId);
                System.Diagnostics.Debug.WriteLine("UserID Type: " + userId.GetType().Name);
                System.Diagnostics.Debug.WriteLine("UserID Length: " + userId.Length);

                // Check if userId is valid
                if (string.IsNullOrEmpty(userId))
                {
                    System.Diagnostics.Debug.WriteLine("UserID is null or empty!");
                    hfActivePickups.Value = "[]";
                    hfPickupHistory.Value = "[]";
                    hfStatsData.Value = "{\"TotalPickups\":0,\"ActivePickups\":0,\"CompletedPickups\":0,\"SuccessRate\":\"0%\",\"TotalXP\":0}";
                    return;
                }

                // Load active pickups
                var activePickups = LoadActivePickups(userId);
                System.Diagnostics.Debug.WriteLine("Active pickups count from DB: " + activePickups.Count);

                // Load pickup history
                var pickupHistory = LoadPickupHistory(userId);
                System.Diagnostics.Debug.WriteLine("Pickup history count from DB: " + pickupHistory.Count);

                // Load stats
                var stats = LoadPickupStats(userId);
                System.Diagnostics.Debug.WriteLine("Stats loaded: " + new JavaScriptSerializer().Serialize(stats));

                // TEMPORARY: Add sample data for testing UI
                if (activePickups.Count == 0)
                {
                    System.Diagnostics.Debug.WriteLine("Adding sample active pickup for testing UI...");
                    activePickups.Add(new
                    {
                        PickupId = "PU-" + Guid.NewGuid().ToString().Substring(0, 8).ToUpper(),
                        WasteType = "Plastic",
                        Weight = "5.0",
                        Address = "123 Green Street, Eco City",
                        Status = "Scheduled",
                        ScheduledDate = DateTime.Now.AddDays(1).ToString("yyyy-MM-dd HH:mm"),
                        CreatedDate = DateTime.Now.ToString("yyyy-MM-dd HH:mm"),
                        CollectorName = "John Collector",
                        XPEarned = "50",
                        Description = "Plastic bottles and containers",
                        Instructions = "Please separate PET bottles from other plastics"
                    });
                }

                if (pickupHistory.Count == 0)
                {
                    System.Diagnostics.Debug.WriteLine("Adding sample history pickup for testing UI...");
                    pickupHistory.Add(new
                    {
                        PickupId = "PU-" + Guid.NewGuid().ToString().Substring(0, 8).ToUpper(),
                        WasteType = "Paper",
                        Weight = "3.5",
                        Address = "456 Recycling Avenue, Green Town",
                        Status = "Completed",
                        ScheduledDate = DateTime.Now.AddDays(-2).ToString("yyyy-MM-dd HH:mm"),
                        CompletedDate = DateTime.Now.AddDays(-1).ToString("yyyy-MM-dd HH:mm"),
                        CreatedDate = DateTime.Now.AddDays(-3).ToString("yyyy-MM-dd HH:mm"),
                        CollectorName = "Jane Collector",
                        XPEarned = "35",
                        Description = "Office paper and cardboard",
                        Instructions = "Keep dry and bundled"
                    });
                }

                // Serialize data to hidden fields
                hfActivePickups.Value = new JavaScriptSerializer().Serialize(activePickups);
                hfPickupHistory.Value = new JavaScriptSerializer().Serialize(pickupHistory);
                hfStatsData.Value = new JavaScriptSerializer().Serialize(stats);

                // Debug output
                System.Diagnostics.Debug.WriteLine("Active Pickups JSON: " + hfActivePickups.Value);
                System.Diagnostics.Debug.WriteLine("Pickup History JSON: " + hfPickupHistory.Value);
                System.Diagnostics.Debug.WriteLine("Stats JSON: " + hfStatsData.Value);
                System.Diagnostics.Debug.WriteLine("=== DATA LOADED SUCCESSFULLY ===");
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("=== ERROR IN LOADPICKUPSDATA ===");
                System.Diagnostics.Debug.WriteLine("Error loading pickups data: " + ex.Message);
                System.Diagnostics.Debug.WriteLine("Stack Trace: " + ex.StackTrace);
                System.Diagnostics.Debug.WriteLine("=== END ERROR ===");

                // Set empty data for error case
                hfActivePickups.Value = "[]";
                hfPickupHistory.Value = "[]";
                hfStatsData.Value = "{\"TotalPickups\":0,\"ActivePickups\":0,\"CompletedPickups\":0,\"SuccessRate\":\"0%\",\"TotalXP\":0}";
            }
        }

        private void CheckDatabaseStructure(string userId)
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    // Check if tables have correct columns
                    string checkQuery = @"
                        -- Check columns in PickupRequests
                        SELECT 'PickupRequests' as TableName, COLUMN_NAME, DATA_TYPE 
                        FROM INFORMATION_SCHEMA.COLUMNS 
                        WHERE TABLE_NAME = 'PickupRequests'
                        
                        UNION ALL
                        
                        -- Check columns in WasteReports
                        SELECT 'WasteReports' as TableName, COLUMN_NAME, DATA_TYPE 
                        FROM INFORMATION_SCHEMA.COLUMNS 
                        WHERE TABLE_NAME = 'WasteReports'
                        
                        UNION ALL
                        
                        -- Check if user exists
                        SELECT 'Users' as TableName, 'UserCount' as COLUMN_NAME, CAST(COUNT(*) as VARCHAR) as DATA_TYPE
                        FROM Users WHERE UserId = @UserId";

                    using (SqlCommand cmd = new SqlCommand(checkQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@UserId", userId);
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                System.Diagnostics.Debug.WriteLine("Table: " + reader["TableName"] + ", Column: " + reader["COLUMN_NAME"] + ", Type: " + reader["DATA_TYPE"]);
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error checking database structure: " + ex.Message);
            }
        }

        private List<object> LoadActivePickups(string userId)
        {
            var pickups = new List<object>();

            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                try
                {
                    conn.Open();
                    System.Diagnostics.Debug.WriteLine(string.Format("Database connection opened for user: {0}", userId));

                    // First, let's test with a simpler query
                    string testQuery = "SELECT TOP 1 UserId FROM Users WHERE UserId = @UserId";
                    using (SqlCommand testCmd = new SqlCommand(testQuery, conn))
                    {
                        testCmd.Parameters.AddWithValue("@UserId", userId);
                        var testResult = testCmd.ExecuteScalar();
                        System.Diagnostics.Debug.WriteLine("Test query result: " + (testResult != null ? testResult.ToString() : "null"));
                    }

                    string query = @"
                        SELECT 
                            pr.PickupId,
                            wt.Name as WasteType,
                            wr.EstimatedKg as Weight,
                            wr.Address,
                            pr.Status,
                            pr.ScheduledDate,
                            pr.CreatedAt as CreatedDate,
                            u.Name as CollectorName,
                            wr.XPEarned,
                            wr.Description,
                            wr.Instructions
                        FROM PickupRequests pr
                        INNER JOIN WasteReports wr ON pr.ReportId = wr.ReportId
                        INNER JOIN WasteTypes wt ON wr.WasteTypeId = wt.WasteTypeId
                        LEFT JOIN Users u ON pr.CollectorId = u.UserId
                        WHERE wr.UserId = @UserId 
                        AND pr.Status IN ('Requested', 'Scheduled', 'Assigned', 'In Progress')
                        ORDER BY pr.ScheduledDate ASC";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@UserId", userId);

                        System.Diagnostics.Debug.WriteLine(string.Format("Executing query for active pickups"));
                        System.Diagnostics.Debug.WriteLine(string.Format("User ID parameter: {0}", userId));

                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            int recordCount = 0;
                            while (reader.Read())
                            {
                                recordCount++;

                                // Safely handle null values
                                object weight = reader["Weight"];
                                object scheduledDate = reader["ScheduledDate"];
                                object collectorName = reader["CollectorName"];
                                object xpEarned = reader["XPEarned"];
                                object description = reader["Description"];
                                object instructions = reader["Instructions"];

                                pickups.Add(new
                                {
                                    PickupId = reader["PickupId"].ToString(),
                                    WasteType = reader["WasteType"].ToString(),
                                    Weight = weight != DBNull.Value ? Convert.ToDecimal(weight).ToString("F1") : "0",
                                    Address = reader["Address"].ToString(),
                                    Status = reader["Status"].ToString(),
                                    ScheduledDate = scheduledDate != DBNull.Value ? Convert.ToDateTime(scheduledDate).ToString("yyyy-MM-dd HH:mm") : null,
                                    CreatedDate = Convert.ToDateTime(reader["CreatedDate"]).ToString("yyyy-MM-dd HH:mm"),
                                    CollectorName = collectorName != DBNull.Value ? collectorName.ToString() : null,
                                    XPEarned = xpEarned != DBNull.Value ? Convert.ToInt32(xpEarned).ToString() : "0",
                                    Description = description != DBNull.Value ? description.ToString() : "",
                                    Instructions = instructions != DBNull.Value ? instructions.ToString() : ""
                                });

                                System.Diagnostics.Debug.WriteLine(string.Format("Record {0}: PickupId={1}, WasteType={2}, Status={3}",
                                    recordCount, reader["PickupId"], reader["WasteType"], reader["Status"]));
                            }
                            System.Diagnostics.Debug.WriteLine(string.Format("Total active pickups loaded: {0}", recordCount));

                            if (recordCount == 0)
                            {
                                System.Diagnostics.Debug.WriteLine("No active pickups found in database for user: " + userId);

                                // Try a simpler query to see if there's any data
                                string simpleQuery = "SELECT COUNT(*) FROM WasteReports WHERE UserId = @UserId";
                                using (SqlCommand simpleCmd = new SqlCommand(simpleQuery, conn))
                                {
                                    simpleCmd.Parameters.AddWithValue("@UserId", userId);
                                    int wasteReports = Convert.ToInt32(simpleCmd.ExecuteScalar());
                                    System.Diagnostics.Debug.WriteLine("Total WasteReports for user: " + wasteReports);
                                }
                            }
                        }
                    }
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Debug.WriteLine(string.Format("Error in LoadActivePickups: {0}", ex.Message));
                    System.Diagnostics.Debug.WriteLine(string.Format("Stack Trace: {0}", ex.StackTrace));

                    // Log detailed error using old syntax
                    SqlException sqlEx = ex as SqlException;
                    if (sqlEx != null)
                    {
                        System.Diagnostics.Debug.WriteLine("SQL Error Number: " + sqlEx.Number);
                        System.Diagnostics.Debug.WriteLine("SQL Procedure: " + sqlEx.Procedure);
                        System.Diagnostics.Debug.WriteLine("SQL Line Number: " + sqlEx.LineNumber);
                    }
                }
            }

            return pickups;
        }

        private List<object> LoadPickupHistory(string userId)
        {
            var pickups = new List<object>();

            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                try
                {
                    conn.Open();
                    System.Diagnostics.Debug.WriteLine(string.Format("Database connection opened for history for user: {0}", userId));

                    string query = @"
                        SELECT 
                            pr.PickupId,
                            wt.Name as WasteType,
                            wr.EstimatedKg as Weight,
                            wr.Address,
                            pr.Status,
                            pr.ScheduledDate,
                            pr.CompletedDate,
                            pr.CreatedAt as CreatedDate,
                            u.Name as CollectorName,
                            wr.XPEarned,
                            wr.Description,
                            wr.Instructions
                        FROM PickupRequests pr
                        INNER JOIN WasteReports wr ON pr.ReportId = wr.ReportId
                        INNER JOIN WasteTypes wt ON wr.WasteTypeId = wt.WasteTypeId
                        LEFT JOIN Users u ON pr.CollectorId = u.UserId
                        WHERE wr.UserId = @UserId 
                        AND pr.Status IN ('Completed', 'Cancelled')
                        ORDER BY pr.CompletedDate DESC";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@UserId", userId);

                        System.Diagnostics.Debug.WriteLine(string.Format("Executing query for pickup history"));
                        System.Diagnostics.Debug.WriteLine(string.Format("User ID parameter: {0}", userId));

                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            int recordCount = 0;
                            while (reader.Read())
                            {
                                recordCount++;

                                // Safely handle null values
                                object weight = reader["Weight"];
                                object scheduledDate = reader["ScheduledDate"];
                                object completedDate = reader["CompletedDate"];
                                object collectorName = reader["CollectorName"];
                                object xpEarned = reader["XPEarned"];
                                object description = reader["Description"];
                                object instructions = reader["Instructions"];

                                pickups.Add(new
                                {
                                    PickupId = reader["PickupId"].ToString(),
                                    WasteType = reader["WasteType"].ToString(),
                                    Weight = weight != DBNull.Value ? Convert.ToDecimal(weight).ToString("F1") : "0",
                                    Address = reader["Address"].ToString(),
                                    Status = reader["Status"].ToString(),
                                    ScheduledDate = scheduledDate != DBNull.Value ? Convert.ToDateTime(scheduledDate).ToString("yyyy-MM-dd HH:mm") : null,
                                    CompletedDate = completedDate != DBNull.Value ? Convert.ToDateTime(completedDate).ToString("yyyy-MM-dd HH:mm") : null,
                                    CreatedDate = Convert.ToDateTime(reader["CreatedDate"]).ToString("yyyy-MM-dd HH:mm"),
                                    CollectorName = collectorName != DBNull.Value ? collectorName.ToString() : null,
                                    XPEarned = xpEarned != DBNull.Value ? Convert.ToInt32(xpEarned).ToString() : "0",
                                    Description = description != DBNull.Value ? description.ToString() : "",
                                    Instructions = instructions != DBNull.Value ? instructions.ToString() : ""
                                });

                                System.Diagnostics.Debug.WriteLine(string.Format("Record {0}: PickupId={1}, Status={2}, CompletedDate={3}",
                                    recordCount, reader["PickupId"], reader["Status"],
                                    completedDate != DBNull.Value ? Convert.ToDateTime(completedDate).ToString("yyyy-MM-dd HH:mm") : "null"));
                            }
                            System.Diagnostics.Debug.WriteLine(string.Format("Total history pickups loaded: {0}", recordCount));

                            if (recordCount == 0)
                            {
                                System.Diagnostics.Debug.WriteLine("No history pickups found in database for user: " + userId);
                            }
                        }
                    }
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Debug.WriteLine(string.Format("Error in LoadPickupHistory: {0}", ex.Message));
                    System.Diagnostics.Debug.WriteLine(string.Format("Stack Trace: {0}", ex.StackTrace));

                    // Log detailed error using old syntax
                    SqlException sqlEx = ex as SqlException;
                    if (sqlEx != null)
                    {
                        System.Diagnostics.Debug.WriteLine("SQL Error Number: " + sqlEx.Number);
                        System.Diagnostics.Debug.WriteLine("SQL Procedure: " + sqlEx.Procedure);
                        System.Diagnostics.Debug.WriteLine("SQL Line Number: " + sqlEx.LineNumber);
                    }
                }
            }

            return pickups;
        }

        private object LoadPickupStats(string userId)
        {
            var stats = new
            {
                TotalPickups = 0,
                ActivePickups = 0,
                CompletedPickups = 0,
                SuccessRate = "0%",
                TotalXP = 0
            };

            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                try
                {
                    conn.Open();
                    System.Diagnostics.Debug.WriteLine(string.Format("Database connection opened for stats for user: {0}", userId));

                    string query = @"
                        WITH PickupSummary AS (
                            SELECT 
                                pr.Status,
                                wr.XPEarned,
                                CASE WHEN pr.Status = 'Completed' THEN 1 ELSE 0 END as IsSuccessful
                            FROM PickupRequests pr
                            INNER JOIN WasteReports wr ON pr.ReportId = wr.ReportId
                            WHERE wr.UserId = @UserId
                        )
                        SELECT 
                            COUNT(*) as TotalPickups,
                            SUM(CASE WHEN Status IN ('Requested', 'Scheduled', 'Assigned', 'In Progress') THEN 1 ELSE 0 END) as ActivePickups,
                            SUM(CASE WHEN Status = 'Completed' THEN 1 ELSE 0 END) as CompletedPickups,
                            CASE 
                                WHEN COUNT(*) > 0 THEN 
                                    CONVERT(VARCHAR(10), (SUM(IsSuccessful) * 100.0 / COUNT(*))) + '%'
                                ELSE '0%' 
                            END as SuccessRate,
                            SUM(ISNULL(XPEarned, 0)) as TotalXP
                        FROM PickupSummary";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@UserId", userId);

                        System.Diagnostics.Debug.WriteLine(string.Format("Executing query for stats"));
                        System.Diagnostics.Debug.WriteLine(string.Format("User ID parameter: {0}", userId));

                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                // Safely handle null values
                                object totalPickups = reader["TotalPickups"];
                                object activePickups = reader["ActivePickups"];
                                object completedPickups = reader["CompletedPickups"];
                                object successRate = reader["SuccessRate"];
                                object totalXP = reader["TotalXP"];

                                stats = new
                                {
                                    TotalPickups = totalPickups != DBNull.Value ? Convert.ToInt32(totalPickups) : 0,
                                    ActivePickups = activePickups != DBNull.Value ? Convert.ToInt32(activePickups) : 0,
                                    CompletedPickups = completedPickups != DBNull.Value ? Convert.ToInt32(completedPickups) : 0,
                                    SuccessRate = successRate != DBNull.Value ? successRate.ToString() : "0%",
                                    TotalXP = totalXP != DBNull.Value ? Convert.ToInt32(totalXP) : 0
                                };

                                System.Diagnostics.Debug.WriteLine(string.Format(
                                    "Stats loaded: TotalPickups={0}, ActivePickups={1}, CompletedPickups={2}, SuccessRate={3}, TotalXP={4}",
                                    stats.TotalPickups, stats.ActivePickups, stats.CompletedPickups, stats.SuccessRate, stats.TotalXP));
                            }
                            else
                            {
                                System.Diagnostics.Debug.WriteLine("No stats data found for user: " + userId);
                            }
                        }
                    }
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Debug.WriteLine(string.Format("Error in LoadPickupStats: {0}", ex.Message));
                    System.Diagnostics.Debug.WriteLine(string.Format("Stack Trace: {0}", ex.StackTrace));

                    // Log detailed error using old syntax
                    SqlException sqlEx = ex as SqlException;
                    if (sqlEx != null)
                    {
                        System.Diagnostics.Debug.WriteLine("SQL Error Number: " + sqlEx.Number);
                        System.Diagnostics.Debug.WriteLine("SQL Procedure: " + sqlEx.Procedure);
                        System.Diagnostics.Debug.WriteLine("SQL Line Number: " + sqlEx.LineNumber);
                    }
                }
            }

            return stats;
        }

        // WebMethod for AJAX calls
        [WebMethod]
        public static string RefreshPickupData(string userId)
        {
            try
            {
                var connectionString = WebConfigurationManager.ConnectionStrings["SoorGreenDBConnectionString"].ConnectionString;
                var js = new JavaScriptSerializer();

                // Load data using static helper methods
                var activePickups = LoadActivePickupsStatic(userId, connectionString);
                var pickupHistory = LoadPickupHistoryStatic(userId, connectionString);
                var stats = LoadPickupStatsStatic(userId, connectionString);

                var result = new
                {
                    ActivePickups = activePickups,
                    PickupHistory = pickupHistory,
                    Stats = stats,
                    Success = true
                };

                return js.Serialize(result);
            }
            catch (Exception ex)
            {
                return "{\"Success\":false,\"error\":\"" + ex.Message.Replace("\"", "'") + "\"}";
            }
        }

        // Static helper methods for WebMethod
        private static List<object> LoadActivePickupsStatic(string userId, string connectionString)
        {
            var pickups = new List<object>();

            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                try
                {
                    conn.Open();

                    string query = @"
                    SELECT 
                        pr.PickupId,
                        wt.Name as WasteType,
                        wr.EstimatedKg as Weight,
                        wr.Address,
                        pr.Status,
                        pr.ScheduledDate,
                        pr.CreatedAt as CreatedDate,
                        u.Name as CollectorName,
                        wr.XPEarned,
                        wr.Description,
                        wr.Instructions
                    FROM PickupRequests pr
                    INNER JOIN WasteReports wr ON pr.ReportId = wr.ReportId
                    INNER JOIN WasteTypes wt ON wr.WasteTypeId = wt.WasteTypeId
                    LEFT JOIN Users u ON pr.CollectorId = u.UserId
                    WHERE wr.UserId = @UserId 
                    AND pr.Status IN ('Requested', 'Scheduled', 'Assigned', 'In Progress')
                    ORDER BY pr.ScheduledDate ASC";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@UserId", userId);

                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                pickups.Add(new
                                {
                                    PickupId = reader["PickupId"].ToString(),
                                    WasteType = reader["WasteType"].ToString(),
                                    Weight = reader["Weight"] != DBNull.Value ? Convert.ToDecimal(reader["Weight"]).ToString("F1") : "0",
                                    Address = reader["Address"].ToString(),
                                    Status = reader["Status"].ToString(),
                                    ScheduledDate = reader["ScheduledDate"] != DBNull.Value ? Convert.ToDateTime(reader["ScheduledDate"]).ToString("yyyy-MM-dd HH:mm") : null,
                                    CreatedDate = Convert.ToDateTime(reader["CreatedDate"]).ToString("yyyy-MM-dd HH:mm"),
                                    CollectorName = reader["CollectorName"] != DBNull.Value ? reader["CollectorName"].ToString() : null,
                                    XPEarned = reader["XPEarned"] != DBNull.Value ? Convert.ToInt32(reader["XPEarned"]).ToString() : "0",
                                    Description = reader["Description"] != DBNull.Value ? reader["Description"].ToString() : "",
                                    Instructions = reader["Instructions"] != DBNull.Value ? reader["Instructions"].ToString() : ""
                                });
                            }
                        }
                    }
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Debug.WriteLine("Error in LoadActivePickupsStatic: " + ex.Message);
                    // Return empty list on error
                }
            }

            return pickups;
        }

        private static List<object> LoadPickupHistoryStatic(string userId, string connectionString)
        {
            var pickups = new List<object>();

            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                try
                {
                    conn.Open();

                    string query = @"
                    SELECT 
                        pr.PickupId,
                        wt.Name as WasteType,
                        wr.EstimatedKg as Weight,
                        wr.Address,
                        pr.Status,
                        pr.ScheduledDate,
                        pr.CompletedDate,
                        pr.CreatedAt as CreatedDate,
                        u.Name as CollectorName,
                        wr.XPEarned,
                        wr.Description,
                        wr.Instructions
                    FROM PickupRequests pr
                    INNER JOIN WasteReports wr ON pr.ReportId = wr.ReportId
                    INNER JOIN WasteTypes wt ON wr.WasteTypeId = wt.WasteTypeId
                    LEFT JOIN Users u ON pr.CollectorId = u.UserId
                    WHERE wr.UserId = @UserId 
                    AND pr.Status IN ('Completed', 'Cancelled')
                    ORDER BY pr.CompletedDate DESC";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@UserId", userId);

                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                pickups.Add(new
                                {
                                    PickupId = reader["PickupId"].ToString(),
                                    WasteType = reader["WasteType"].ToString(),
                                    Weight = reader["Weight"] != DBNull.Value ? Convert.ToDecimal(reader["Weight"]).ToString("F1") : "0",
                                    Address = reader["Address"].ToString(),
                                    Status = reader["Status"].ToString(),
                                    ScheduledDate = reader["ScheduledDate"] != DBNull.Value ? Convert.ToDateTime(reader["ScheduledDate"]).ToString("yyyy-MM-dd HH:mm") : null,
                                    CompletedDate = reader["CompletedDate"] != DBNull.Value ? Convert.ToDateTime(reader["CompletedDate"]).ToString("yyyy-MM-dd HH:mm") : null,
                                    CreatedDate = Convert.ToDateTime(reader["CreatedDate"]).ToString("yyyy-MM-dd HH:mm"),
                                    CollectorName = reader["CollectorName"] != DBNull.Value ? reader["CollectorName"].ToString() : null,
                                    XPEarned = reader["XPEarned"] != DBNull.Value ? Convert.ToInt32(reader["XPEarned"]).ToString() : "0",
                                    Description = reader["Description"] != DBNull.Value ? reader["Description"].ToString() : "",
                                    Instructions = reader["Instructions"] != DBNull.Value ? reader["Instructions"].ToString() : ""
                                });
                            }
                        }
                    }
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Debug.WriteLine("Error in LoadPickupHistoryStatic: " + ex.Message);
                    // Return empty list on error
                }
            }

            return pickups;
        }

        private static object LoadPickupStatsStatic(string userId, string connectionString)
        {
            var stats = new
            {
                TotalPickups = 0,
                ActivePickups = 0,
                CompletedPickups = 0,
                SuccessRate = "0%",
                TotalXP = 0
            };

            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                try
                {
                    conn.Open();

                    string query = @"
                    WITH PickupSummary AS (
                        SELECT 
                            pr.Status,
                            wr.XPEarned,
                            CASE WHEN pr.Status = 'Completed' THEN 1 ELSE 0 END as IsSuccessful
                        FROM PickupRequests pr
                        INNER JOIN WasteReports wr ON pr.ReportId = wr.ReportId
                        WHERE wr.UserId = @UserId
                    )
                    SELECT 
                        COUNT(*) as TotalPickups,
                        SUM(CASE WHEN Status IN ('Requested', 'Scheduled', 'Assigned', 'In Progress') THEN 1 ELSE 0 END) as ActivePickups,
                        SUM(CASE WHEN Status = 'Completed' THEN 1 ELSE 0 END) as CompletedPickups,
                        CASE 
                            WHEN COUNT(*) > 0 THEN 
                                CONVERT(VARCHAR(10), (SUM(IsSuccessful) * 100.0 / COUNT(*))) + '%'
                            ELSE '0%' 
                        END as SuccessRate,
                        SUM(ISNULL(XPEarned, 0)) as TotalXP
                    FROM PickupSummary";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@UserId", userId);

                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                stats = new
                                {
                                    TotalPickups = reader["TotalPickups"] != DBNull.Value ? Convert.ToInt32(reader["TotalPickups"]) : 0,
                                    ActivePickups = reader["ActivePickups"] != DBNull.Value ? Convert.ToInt32(reader["ActivePickups"]) : 0,
                                    CompletedPickups = reader["CompletedPickups"] != DBNull.Value ? Convert.ToInt32(reader["CompletedPickups"]) : 0,
                                    SuccessRate = reader["SuccessRate"] != DBNull.Value ? reader["SuccessRate"].ToString() : "0%",
                                    TotalXP = reader["TotalXP"] != DBNull.Value ? Convert.ToInt32(reader["TotalXP"]) : 0
                                };
                            }
                        }
                    }
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Debug.WriteLine("Error in LoadPickupStatsStatic: " + ex.Message);
                    // Return default stats on error
                }
            }

            return stats;
        }
    }
}