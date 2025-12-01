using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.Configuration;
using System.Web.Services;
using System.Web.UI;

namespace SoorGreen.Admin.Admin
{
    public partial class Pickups : System.Web.UI.Page
    {
        private string connectionString = WebConfigurationManager.ConnectionStrings["SoorGreenDBConnectionString"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadPickups();
                LoadCollectors();
                LoadCitizens();
            }
        }

        protected void LoadPickups(object sender, EventArgs e)
        {
            LoadPickups();
        }

        protected void LoadPickups()
        {
            try
            {
                DataTable pickupsData = GetPickupsFromDatabase();
                hfPickupsData.Value = SerializeToJson(pickupsData);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error loading pickups: " + ex.Message);
                hfPickupsData.Value = "[]";
            }
        }

        protected void LoadCollectors()
        {
            try
            {
                DataTable collectorsData = GetCollectorsFromDatabase();
                hfCollectorsList.Value = SerializeToJson(collectorsData);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error loading collectors: " + ex.Message);
                hfCollectorsList.Value = "[]";
            }
        }

        protected void LoadCitizens()
        {
            try
            {
                DataTable citizensData = GetCitizensFromDatabase();
                hfCitizensList.Value = SerializeToJson(citizensData);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error loading citizens: " + ex.Message);
                hfCitizensList.Value = "[]";
            }
        }

        [WebMethod]
        public static string CreatePickup(string citizenId, string wasteType, decimal estimatedWeight, string address, string notes)
        {
            try
            {
                Pickups page = new Pickups();
                return page.CreatePickupInDatabase(citizenId, wasteType, estimatedWeight, address, notes);
            }
            catch (Exception ex)
            {
                return "Error: " + ex.Message;
            }
        }

        [WebMethod]
        public static string AssignCollector(string pickupId, string collectorId, string scheduledDate, string notes)
        {
            try
            {
                Pickups page = new Pickups();
                return page.AssignCollectorInDatabase(pickupId, collectorId, scheduledDate, notes);
            }
            catch (Exception ex)
            {
                return "Error: " + ex.Message;
            }
        }

        [WebMethod]
        public static string CompletePickup(string pickupId, decimal actualWeight, string confirmedWasteType, string completionNotes)
        {
            try
            {
                Pickups page = new Pickups();
                return page.CompletePickupInDatabase(pickupId, actualWeight, confirmedWasteType, completionNotes);
            }
            catch (Exception ex)
            {
                return "Error: " + ex.Message;
            }
        }

        [WebMethod]
        public static string DeletePickup(string pickupId)
        {
            try
            {
                Pickups page = new Pickups();
                return page.DeletePickupInDatabase(pickupId);
            }
            catch (Exception ex)
            {
                return "Error: " + ex.Message;
            }
        }

        // Database methods
        private DataTable GetPickupsFromDatabase()
        {
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                string query = @"
                    SELECT 
                        p.PickupId,
                        u.FullName AS CitizenName,
                        uc.FullName AS CollectorName,
                        w.Address,
                        wt.Name AS WasteType,
                        w.EstimatedKg AS EstimatedWeight,
                        ISNULL(pv.VerifiedKg, 0) AS ActualWeight,
                        p.Status,
                        w.CreatedAt AS RequestedDate,
                        p.ScheduledAt AS ScheduledDate,
                        p.CompletedAt AS CompletedDate,
                        ISNULL(w.PhotoUrl, '') AS Notes,
                        wt.CreditPerKg AS CreditRate
                    FROM PickupRequests p
                    INNER JOIN WasteReports w ON p.ReportId = w.ReportId
                    INNER JOIN Users u ON w.UserId = u.UserId
                    INNER JOIN WasteTypes wt ON w.WasteTypeId = wt.WasteTypeId
                    LEFT JOIN Users uc ON p.CollectorId = uc.UserId
                    LEFT JOIN PickupVerifications pv ON p.PickupId = pv.PickupId
                    ORDER BY w.CreatedAt DESC";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    conn.Open();

                    DataTable dt = new DataTable();
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        da.Fill(dt);
                    }
                    return dt;
                }
            }
        }

        private DataTable GetCollectorsFromDatabase()
        {
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                string query = @"
                    SELECT 
                        UserId AS Id,
                        FullName AS FirstName,
                        '' AS LastName,
                        Phone,
                        'Active' AS Status
                    FROM Users 
                    WHERE RoleId = 'R002' AND IsVerified = 1
                    ORDER BY FullName";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    conn.Open();

                    DataTable dt = new DataTable();
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        da.Fill(dt);
                    }
                    return dt;
                }
            }
        }

        private DataTable GetCitizensFromDatabase()
        {
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                string query = @"
                    SELECT 
                        UserId AS Id,
                        FullName AS FirstName,
                        '' AS LastName,
                        Phone,
                        Email
                    FROM Users 
                    WHERE RoleId = 'R001' AND IsVerified = 1
                    ORDER BY FullName";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    conn.Open();

                    DataTable dt = new DataTable();
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        da.Fill(dt);
                    }
                    return dt;
                }
            }
        }

        private string CreatePickupInDatabase(string citizenId, string wasteType, decimal estimatedWeight, string address, string notes)
        {
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.Open();

                // First, disable the problematic trigger
                string disableTriggerQuery = "DISABLE TRIGGER trg_LogWasteReport ON WasteReports";
                using (SqlCommand disableCmd = new SqlCommand(disableTriggerQuery, conn))
                {
                    disableCmd.ExecuteNonQuery();
                }

                try
                {
                    // Get WasteTypeId
                    string wasteTypeQuery = "SELECT WasteTypeId FROM WasteTypes WHERE Name = @WasteType";
                    string wasteTypeId;

                    using (SqlCommand wasteCmd = new SqlCommand(wasteTypeQuery, conn))
                    {
                        wasteCmd.Parameters.AddWithValue("@WasteType", wasteType);
                        var result = wasteCmd.ExecuteScalar();
                        if (result == null)
                        {
                            return "Error: Invalid waste type";
                        }
                        wasteTypeId = result.ToString();
                    }

                    if (string.IsNullOrEmpty(wasteTypeId))
                    {
                        return "Error: Invalid waste type";
                    }

                    // Generate new ReportId and PickupId
                    string reportId = GenerateNewId("WR", "WasteReports", "ReportId", conn);
                    string pickupId = GenerateNewId("P", "PickupRequests", "PickupId", conn);

                    // Insert into WasteReports - USING DEFAULT for CreatedAt to let database handle it
                    string insertReportQuery = @"
                        INSERT INTO WasteReports (ReportId, UserId, WasteTypeId, EstimatedKg, Address, PhotoUrl)
                        VALUES (@ReportId, @UserId, @WasteTypeId, @EstimatedKg, @Address, @PhotoUrl)";

                    using (SqlCommand cmd = new SqlCommand(insertReportQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@ReportId", reportId);
                        cmd.Parameters.AddWithValue("@UserId", citizenId);
                        cmd.Parameters.AddWithValue("@WasteTypeId", wasteTypeId);
                        cmd.Parameters.AddWithValue("@EstimatedKg", estimatedWeight);
                        cmd.Parameters.AddWithValue("@Address", address);
                        cmd.Parameters.AddWithValue("@PhotoUrl", notes ?? (object)DBNull.Value);

                        cmd.ExecuteNonQuery();
                    }

                    // Insert into PickupRequests - USING DEFAULT for CreatedAt
                    string insertPickupQuery = @"
                        INSERT INTO PickupRequests (PickupId, ReportId, Status)
                        VALUES (@PickupId, @ReportId, 'Requested')";

                    using (SqlCommand cmd = new SqlCommand(insertPickupQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@PickupId", pickupId);
                        cmd.Parameters.AddWithValue("@ReportId", reportId);
                        cmd.ExecuteNonQuery();
                    }

                    // Manually create audit log with proper ID
                    string auditId = GenerateNewId("AL", "AuditLogs", "AuditId", conn);
                    string auditQuery = @"
                        INSERT INTO AuditLogs (AuditId, UserId, Action, Details)
                        VALUES (@AuditId, @UserId, @Action, @Details)";

                    using (SqlCommand auditCmd = new SqlCommand(auditQuery, conn))
                    {
                        auditCmd.Parameters.AddWithValue("@AuditId", auditId);
                        auditCmd.Parameters.AddWithValue("@UserId", citizenId);
                        auditCmd.Parameters.AddWithValue("@Action", "New Pickup Created");
                        auditCmd.Parameters.AddWithValue("@Details", "Pickup ID: " + pickupId + ", Report ID: " + reportId);
                        auditCmd.ExecuteNonQuery();
                    }

                    return "Success: Pickup created successfully. ID: " + pickupId;
                }
                finally
                {
                    // Re-enable the trigger
                    string enableTriggerQuery = "ENABLE TRIGGER trg_LogWasteReport ON WasteReports";
                    using (SqlCommand enableCmd = new SqlCommand(enableTriggerQuery, conn))
                    {
                        enableCmd.ExecuteNonQuery();
                    }
                }
            }
        }

        private string AssignCollectorInDatabase(string pickupId, string collectorId, string scheduledDate, string notes)
        {
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.Open();

                string query = @"
                    UPDATE PickupRequests 
                    SET CollectorId = @CollectorId, 
                        Status = 'Assigned',
                        ScheduledAt = @ScheduledDate
                    WHERE PickupId = @PickupId";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@PickupId", pickupId);
                    cmd.Parameters.AddWithValue("@CollectorId", collectorId);
                    cmd.Parameters.AddWithValue("@ScheduledDate", DateTime.Parse(scheduledDate));

                    int rowsAffected = cmd.ExecuteNonQuery();

                    if (rowsAffected > 0)
                    {
                        // Log to AuditLogs
                        string auditId = GenerateNewId("AL", "AuditLogs", "AuditId", conn);
                        string auditQuery = @"
                            INSERT INTO AuditLogs (AuditId, UserId, Action, Details)
                            VALUES (@AuditId, @UserId, @Action, @Details)";

                        using (SqlCommand auditCmd = new SqlCommand(auditQuery, conn))
                        {
                            auditCmd.Parameters.AddWithValue("@AuditId", auditId);
                            auditCmd.Parameters.AddWithValue("@UserId", collectorId);
                            auditCmd.Parameters.AddWithValue("@Action", "Collector Assigned");
                            auditCmd.Parameters.AddWithValue("@Details", "Pickup ID: " + pickupId + " assigned to Collector: " + collectorId);
                            auditCmd.ExecuteNonQuery();
                        }

                        return "Success: Collector assigned successfully";
                    }
                    else
                    {
                        return "Error: Pickup not found or already assigned";
                    }
                }
            }
        }

        private string CompletePickupInDatabase(string pickupId, decimal actualWeight, string confirmedWasteType, string completionNotes)
        {
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.Open();

                // Get WasteTypeId for the confirmed waste type
                string wasteTypeQuery = "SELECT WasteTypeId FROM WasteTypes WHERE Name = @WasteType";
                string wasteTypeId;

                using (SqlCommand wasteCmd = new SqlCommand(wasteTypeQuery, conn))
                {
                    wasteCmd.Parameters.AddWithValue("@WasteType", confirmedWasteType);
                    var result = wasteCmd.ExecuteScalar();
                    if (result == null)
                    {
                        return "Error: Invalid waste type";
                    }
                    wasteTypeId = result.ToString();
                }

                if (string.IsNullOrEmpty(wasteTypeId))
                {
                    return "Error: Invalid waste type";
                }

                // Get ReportId and UserId for this pickup
                string getInfoQuery = @"
                    SELECT w.ReportId, w.UserId, wt.CreditPerKg 
                    FROM PickupRequests p
                    INNER JOIN WasteReports w ON p.ReportId = w.ReportId
                    INNER JOIN WasteTypes wt ON w.WasteTypeId = wt.WasteTypeId
                    WHERE p.PickupId = @PickupId";

                string reportId = "", userId = "";
                decimal creditRate = 0;

                using (SqlCommand infoCmd = new SqlCommand(getInfoQuery, conn))
                {
                    infoCmd.Parameters.AddWithValue("@PickupId", pickupId);
                    using (SqlDataReader reader = infoCmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            reportId = reader["ReportId"].ToString();
                            userId = reader["UserId"].ToString();
                            creditRate = Convert.ToDecimal(reader["CreditPerKg"]);
                        }
                        else
                        {
                            return "Error: Pickup not found";
                        }
                    }
                }

                // Generate VerificationId
                string verificationId = GenerateNewId("PV", "PickupVerifications", "VerificationId", conn);

                // Insert into PickupVerifications
                string insertVerificationQuery = @"
                    INSERT INTO PickupVerifications (VerificationId, PickupId, VerifiedKg, MaterialType, VerificationMethod)
                    VALUES (@VerificationId, @PickupId, @VerifiedKg, @MaterialType, 'Manual')";

                using (SqlCommand cmd = new SqlCommand(insertVerificationQuery, conn))
                {
                    cmd.Parameters.AddWithValue("@VerificationId", verificationId);
                    cmd.Parameters.AddWithValue("@PickupId", pickupId);
                    cmd.Parameters.AddWithValue("@VerifiedKg", actualWeight);
                    cmd.Parameters.AddWithValue("@MaterialType", confirmedWasteType);
                    cmd.ExecuteNonQuery();
                }

                // Update PickupRequests status
                string updatePickupQuery = @"
                    UPDATE PickupRequests 
                    SET Status = 'Completed',
                        CompletedAt = GETDATE()
                    WHERE PickupId = @PickupId";

                using (SqlCommand cmd = new SqlCommand(updatePickupQuery, conn))
                {
                    cmd.Parameters.AddWithValue("@PickupId", pickupId);
                    cmd.ExecuteNonQuery();
                }

                // Update WasteReports with actual data
                string updateWasteQuery = @"
                    UPDATE WasteReports 
                    SET WasteTypeId = @WasteTypeId,
                        EstimatedKg = @ActualWeight
                    WHERE ReportId = @ReportId";

                using (SqlCommand cmd = new SqlCommand(updateWasteQuery, conn))
                {
                    cmd.Parameters.AddWithValue("@WasteTypeId", wasteTypeId);
                    cmd.Parameters.AddWithValue("@ActualWeight", actualWeight);
                    cmd.Parameters.AddWithValue("@ReportId", reportId);
                    cmd.ExecuteNonQuery();
                }

                // Calculate and award credits
                decimal creditsEarned = actualWeight * creditRate;

                // Generate RewardId
                string rewardId = GenerateNewId("RP", "RewardPoints", "RewardId", conn);

                // Insert into RewardPoints
                string insertRewardQuery = @"
                    INSERT INTO RewardPoints (RewardId, UserId, Amount, Type, Reference)
                    VALUES (@RewardId, @UserId, @Amount, 'Credit', @Reference)";

                using (SqlCommand cmd = new SqlCommand(insertRewardQuery, conn))
                {
                    cmd.Parameters.AddWithValue("@RewardId", rewardId);
                    cmd.Parameters.AddWithValue("@UserId", userId);
                    cmd.Parameters.AddWithValue("@Amount", creditsEarned);
                    cmd.Parameters.AddWithValue("@Reference", "Pickup " + pickupId);
                    cmd.ExecuteNonQuery();
                }

                // Update user's total credits
                string updateUserQuery = @"
                    UPDATE Users 
                    SET XP_Credits = XP_Credits + @Credits
                    WHERE UserId = @UserId";

                using (SqlCommand cmd = new SqlCommand(updateUserQuery, conn))
                {
                    cmd.Parameters.AddWithValue("@Credits", creditsEarned);
                    cmd.Parameters.AddWithValue("@UserId", userId);
                    cmd.ExecuteNonQuery();
                }

                // Log to AuditLogs
                string auditId = GenerateNewId("AL", "AuditLogs", "AuditId", conn);
                string auditQuery = @"
                    INSERT INTO AuditLogs (AuditId, UserId, Action, Details)
                    VALUES (@AuditId, @UserId, @Action, @Details)";

                using (SqlCommand auditCmd = new SqlCommand(auditQuery, conn))
                {
                    auditCmd.Parameters.AddWithValue("@AuditId", auditId);
                    auditCmd.Parameters.AddWithValue("@UserId", userId);
                    auditCmd.Parameters.AddWithValue("@Action", "Pickup Completed");
                    auditCmd.Parameters.AddWithValue("@Details", "Pickup ID: " + pickupId + " completed. Credits awarded: " + creditsEarned.ToString("0.00"));
                    auditCmd.ExecuteNonQuery();
                }

                return "Success: Pickup completed successfully. " + creditsEarned.ToString("0.00") + " credits awarded";
            }
        }

        private string DeletePickupInDatabase(string pickupId)
        {
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.Open();

                // Get ReportId first
                string getReportIdQuery = "SELECT ReportId FROM PickupRequests WHERE PickupId = @PickupId";
                string reportId = "";

                using (SqlCommand getCmd = new SqlCommand(getReportIdQuery, conn))
                {
                    getCmd.Parameters.AddWithValue("@PickupId", pickupId);
                    var result = getCmd.ExecuteScalar();
                    if (result == null)
                    {
                        return "Error: Pickup not found";
                    }
                    reportId = result.ToString();
                }

                if (string.IsNullOrEmpty(reportId))
                {
                    return "Error: Pickup not found";
                }

                // Get UserId for audit logging
                string getUserIdQuery = "SELECT w.UserId FROM WasteReports w INNER JOIN PickupRequests p ON w.ReportId = p.ReportId WHERE p.PickupId = @PickupId";
                string userId = "";

                using (SqlCommand userCmd = new SqlCommand(getUserIdQuery, conn))
                {
                    userCmd.Parameters.AddWithValue("@PickupId", pickupId);
                    var result = userCmd.ExecuteScalar();
                    if (result != null)
                    {
                        userId = result.ToString();
                    }
                }

                // Delete from PickupVerifications first (if exists)
                string deleteVerificationsQuery = "DELETE FROM PickupVerifications WHERE PickupId = @PickupId";
                using (SqlCommand cmd = new SqlCommand(deleteVerificationsQuery, conn))
                {
                    cmd.Parameters.AddWithValue("@PickupId", pickupId);
                    cmd.ExecuteNonQuery();
                }

                // Delete from PickupRequests
                string deletePickupQuery = "DELETE FROM PickupRequests WHERE PickupId = @PickupId";
                using (SqlCommand cmd = new SqlCommand(deletePickupQuery, conn))
                {
                    cmd.Parameters.AddWithValue("@PickupId", pickupId);
                    cmd.ExecuteNonQuery();
                }

                // Delete from WasteReports
                string deleteWasteQuery = "DELETE FROM WasteReports WHERE ReportId = @ReportId";
                using (SqlCommand cmd = new SqlCommand(deleteWasteQuery, conn))
                {
                    cmd.Parameters.AddWithValue("@ReportId", reportId);
                    int rowsAffected = cmd.ExecuteNonQuery();

                    if (rowsAffected > 0)
                    {
                        // Log to AuditLogs
                        string auditId = GenerateNewId("AL", "AuditLogs", "AuditId", conn);
                        string auditQuery = @"
                            INSERT INTO AuditLogs (AuditId, UserId, Action, Details)
                            VALUES (@AuditId, @UserId, @Action, @Details)";

                        using (SqlCommand auditCmd = new SqlCommand(auditQuery, conn))
                        {
                            auditCmd.Parameters.AddWithValue("@AuditId", auditId);
                            auditCmd.Parameters.AddWithValue("@UserId", userId);
                            auditCmd.Parameters.AddWithValue("@Action", "Pickup Deleted");
                            auditCmd.Parameters.AddWithValue("@Details", "Pickup ID: " + pickupId + " and Report ID: " + reportId + " deleted");
                            auditCmd.ExecuteNonQuery();
                        }

                        return "Success: Pickup deleted successfully";
                    }
                    else
                    {
                        return "Error: Failed to delete pickup";
                    }
                }
            }
        }

        private string GenerateNewId(string prefix, string tableName, string idColumn, SqlConnection conn)
        {
            // FIXED: Proper ID generation that matches database column length
            string query = "SELECT ISNULL(MAX(CAST(SUBSTRING(" + idColumn + ", " + (prefix.Length + 1) + ", LEN(" + idColumn + ")) AS INT)), 0) + 1 FROM " + tableName + " WHERE " + idColumn + " LIKE '" + prefix + "%'";

            using (SqlCommand cmd = new SqlCommand(query, conn))
            {
                int nextId = Convert.ToInt32(cmd.ExecuteScalar());

                // Generate ID based on expected database column length
                // Assuming CHAR(4) columns - adjust if different
                if (prefix.Length == 2)
                {
                    // For 2-character prefix, use 2-digit number: P01, WR01, etc.
                    return prefix + nextId.ToString("D2");
                }
                else if (prefix.Length == 1)
                {
                    // For 1-character prefix, use 3-digit number
                    return prefix + nextId.ToString("D3");
                }
                else
                {
                    // Default: ensure total length is 4 characters
                    int numDigits = 4 - prefix.Length;
                    return prefix + nextId.ToString("D" + numDigits);
                }
            }
        }

        private string SerializeToJson(DataTable dataTable)
        {
            try
            {
                System.Web.Script.Serialization.JavaScriptSerializer serializer = new System.Web.Script.Serialization.JavaScriptSerializer();
                System.Collections.Generic.List<System.Collections.Generic.Dictionary<string, object>> rows = new System.Collections.Generic.List<System.Collections.Generic.Dictionary<string, object>>();
                System.Collections.Generic.Dictionary<string, object> row;

                foreach (DataRow dr in dataTable.Rows)
                {
                    row = new System.Collections.Generic.Dictionary<string, object>();
                    foreach (DataColumn col in dataTable.Columns)
                    {
                        // Handle DBNull values
                        row.Add(col.ColumnName, dr[col] == DBNull.Value ? null : dr[col]);
                    }
                    rows.Add(row);
                }
                return serializer.Serialize(rows);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error serializing to JSON: " + ex.Message);
                return "[]";
            }
        }
    }
}