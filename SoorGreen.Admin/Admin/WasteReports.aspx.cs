using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.Configuration;
using System.Web.Services;
using System.Web.UI;

namespace SoorGreen.Admin.Admin
{
    public partial class WasteReports : System.Web.UI.Page
    {
        private string connectionString = WebConfigurationManager.ConnectionStrings["SoorGreenDBConnectionString"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadReports();
                LoadCollectors();
            }
        }

        protected void LoadReports(object sender, EventArgs e)
        {
            LoadReports();
        }

        protected void LoadReports()
        {
            try
            {
                DataTable reportsData = GetWasteReportsFromDatabase();
                hfReportsData.Value = SerializeToJson(reportsData);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error loading waste reports: " + ex.Message);
                hfReportsData.Value = "[]";
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

        [WebMethod]
        public static string CreatePickupFromReport(string reportId, string collectorId, string scheduledDate, string notes)
        {
            try
            {
                WasteReports page = new WasteReports();
                return page.CreatePickupFromReportInDatabase(reportId, collectorId, scheduledDate, notes);
            }
            catch (Exception ex)
            {
                return "Error: " + ex.Message;
            }
        }

        [WebMethod]
        public static string DeleteWasteReport(string reportId)
        {
            try
            {
                WasteReports page = new WasteReports();
                return page.DeleteWasteReportInDatabase(reportId);
            }
            catch (Exception ex)
            {
                return "Error: " + ex.Message;
            }
        }

        // Database methods
        private DataTable GetWasteReportsFromDatabase()
        {
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                string query = @"
                    SELECT 
                        w.ReportId,
                        u.FullName AS CitizenName,
                        w.Address,
                        wt.Name AS WasteType,
                        w.EstimatedKg AS EstimatedWeight,
                        w.CreatedAt AS RequestedDate,
                        ISNULL(w.PhotoUrl, '') AS Notes,
                        wt.CreditPerKg AS CreditRate,
                        p.PickupId,
                        p.Status AS PickupStatus
                    FROM WasteReports w
                    INNER JOIN Users u ON w.UserId = u.UserId
                    INNER JOIN WasteTypes wt ON w.WasteTypeId = wt.WasteTypeId
                    LEFT JOIN PickupRequests p ON w.ReportId = p.ReportId
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

        private string CreatePickupFromReportInDatabase(string reportId, string collectorId, string scheduledDate, string notes)
        {
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.Open();

                // Generate new PickupId
                string pickupId = GenerateNewId("P", "PickupRequests", "PickupId", conn);

                // Insert into PickupRequests
                string insertPickupQuery = @"
                    INSERT INTO PickupRequests (PickupId, ReportId, CollectorId, Status, ScheduledAt)
                    VALUES (@PickupId, @ReportId, @CollectorId, 'Assigned', @ScheduledDate)";

                using (SqlCommand cmd = new SqlCommand(insertPickupQuery, conn))
                {
                    cmd.Parameters.AddWithValue("@PickupId", pickupId);
                    cmd.Parameters.AddWithValue("@ReportId", reportId);
                    cmd.Parameters.AddWithValue("@CollectorId", collectorId);
                    cmd.Parameters.AddWithValue("@ScheduledDate", DateTime.Parse(scheduledDate));

                    cmd.ExecuteNonQuery();
                }

                // Log to AuditLogs
                string auditId = GenerateNewId("AL", "AuditLogs", "AuditId", conn);
                string auditQuery = @"
                    INSERT INTO AuditLogs (AuditId, UserId, Action, Details)
                    VALUES (@AuditId, @UserId, @Action, @Details)";

                // Get UserId from the waste report
                string getUserIdQuery = "SELECT UserId FROM WasteReports WHERE ReportId = @ReportId";
                string userId = "";

                using (SqlCommand userCmd = new SqlCommand(getUserIdQuery, conn))
                {
                    userCmd.Parameters.AddWithValue("@ReportId", reportId);
                    var result = userCmd.ExecuteScalar();
                    if (result != null)
                    {
                        userId = result.ToString();
                    }
                }

                using (SqlCommand auditCmd = new SqlCommand(auditQuery, conn))
                {
                    auditCmd.Parameters.AddWithValue("@AuditId", auditId);
                    auditCmd.Parameters.AddWithValue("@UserId", userId);
                    auditCmd.Parameters.AddWithValue("@Action", "Pickup Created from Report");
                    auditCmd.Parameters.AddWithValue("@Details", "Pickup ID: " + pickupId + " created from Report ID: " + reportId);
                    auditCmd.ExecuteNonQuery();
                }

                return "Success: Pickup created successfully. ID: " + pickupId;
            }
        }

        private string DeleteWasteReportInDatabase(string reportId)
        {
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.Open();

                // Get UserId for audit logging
                string getUserIdQuery = "SELECT UserId FROM WasteReports WHERE ReportId = @ReportId";
                string userId = "";

                using (SqlCommand userCmd = new SqlCommand(getUserIdQuery, conn))
                {
                    userCmd.Parameters.AddWithValue("@ReportId", reportId);
                    var result = userCmd.ExecuteScalar();
                    if (result != null)
                    {
                        userId = result.ToString();
                    }
                }

                // Delete from PickupVerifications first (if exists)
                string deleteVerificationsQuery = @"
                    DELETE FROM PickupVerifications 
                    WHERE PickupId IN (SELECT PickupId FROM PickupRequests WHERE ReportId = @ReportId)";
                using (SqlCommand cmd = new SqlCommand(deleteVerificationsQuery, conn))
                {
                    cmd.Parameters.AddWithValue("@ReportId", reportId);
                    cmd.ExecuteNonQuery();
                }

                // Delete from PickupRequests
                string deletePickupQuery = "DELETE FROM PickupRequests WHERE ReportId = @ReportId";
                using (SqlCommand cmd = new SqlCommand(deletePickupQuery, conn))
                {
                    cmd.Parameters.AddWithValue("@ReportId", reportId);
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
                            auditCmd.Parameters.AddWithValue("@Action", "Waste Report Deleted");
                            auditCmd.Parameters.AddWithValue("@Details", "Report ID: " + reportId + " deleted");
                            auditCmd.ExecuteNonQuery();
                        }

                        return "Success: Waste report deleted successfully";
                    }
                    else
                    {
                        return "Error: Failed to delete waste report";
                    }
                }
            }
        }

        private string GenerateNewId(string prefix, string tableName, string idColumn, SqlConnection conn)
        {
            string query = "SELECT ISNULL(MAX(CAST(SUBSTRING(" + idColumn + ", " + (prefix.Length + 1) + ", LEN(" + idColumn + ")) AS INT)), 0) + 1 FROM " + tableName + " WHERE " + idColumn + " LIKE '" + prefix + "%'";

            using (SqlCommand cmd = new SqlCommand(query, conn))
            {
                int nextId = Convert.ToInt32(cmd.ExecuteScalar());

                if (prefix.Length == 2)
                {
                    return prefix + nextId.ToString("D2");
                }
                else if (prefix.Length == 1)
                {
                    return prefix + nextId.ToString("D3");
                }
                else
                {
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