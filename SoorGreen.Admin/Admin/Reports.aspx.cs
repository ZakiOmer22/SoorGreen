using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace SoorGreen.Admin.Admin
{
    public partial class Reports : System.Web.UI.Page
    {
        //protected Button btnGenerateReport;
        //protected HiddenField hfReportData;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // Load initial report data
                LoadInitialData();
            }
        }

        protected void GenerateReport(object sender, EventArgs e)
        {
            try
            {
                // Get filter parameters from request
                string reportType = Request.Form["reportType"] ?? "pickup";
                string dateRange = Request.Form["dateRange"] ?? "month";
                string statusFilter = Request.Form["statusFilter"] ?? "all";
                string startDate = Request.Form["startDate"];
                string endDate = Request.Form["endDate"];

                // Generate report based on filters
                GenerateReportData(reportType, dateRange, statusFilter, startDate, endDate);
            }
            catch (Exception ex)
            {
                // Log error and show message - using string.Format instead of $
                System.Diagnostics.Debug.WriteLine(string.Format("Report generation error: {0}", ex.Message));
                ClientScript.RegisterStartupScript(this.GetType(), "alert", "alert('Error generating report. Please try again.');", true);
            }
        }

        private void LoadInitialData()
        {
            // Load default report data
            try
            {
                if (TryLoadFromDatabase())
                {
                    return;
                }

                // If database fails, use simulated data
                UseSimulatedData();
            }
            catch (Exception ex)
            {
                UseSimulatedData();
                System.Diagnostics.Debug.WriteLine(string.Format("Reports load error: {0}", ex.Message));
            }
        }

        private bool TryLoadFromDatabase()
        {
            try
            {
                string connectionString = System.Configuration.ConfigurationManager.ConnectionStrings["SoorGreenDB"].ConnectionString;

                if (string.IsNullOrEmpty(connectionString))
                {
                    return false;
                }

                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    // Load report data from database
                    string query = @"
                        SELECT 
                            COUNT(*) as TotalPickups,
                            SUM(CASE WHEN Status = 'Completed' THEN 1 ELSE 0 END) as CompletedPickups,
                            SUM(CASE WHEN Status = 'Pending' THEN 1 ELSE 0 END) as PendingPickups,
                            SUM(CASE WHEN Status = 'Cancelled' THEN 1 ELSE 0 END) as CancelledPickups
                        FROM PickupRequests 
                        WHERE CAST(ScheduledAt AS DATE) >= DATEADD(DAY, -30, GETDATE())";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            // Process database results
                            int totalPickups = reader.GetInt32(0);
                            int completedPickups = reader.GetInt32(1);
                            int pendingPickups = reader.GetInt32(2);
                            int cancelledPickups = reader.GetInt32(3);

                            // Store data in hidden field or session for client-side use
                            hfReportData.Value = string.Format(
                                "{{\"totalPickups\":{0},\"completedPickups\":{1},\"pendingPickups\":{2},\"cancelledPickups\":{3}}}",
                                totalPickups, completedPickups, pendingPickups, cancelledPickups);
                        }
                    }

                    return true;
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine(string.Format("Database error: {0}", ex.Message));
                return false;
            }
        }

        private void GenerateReportData(string reportType, string dateRange, string statusFilter, string startDate, string endDate)
        {
            try
            {
                // Build query based on filters
                string query = BuildReportQuery(reportType, dateRange, statusFilter, startDate, endDate);

                // Execute query and process results
                DataTable reportData = ExecuteReportQuery(query);

                // Store results for client-side
                StoreReportResults(reportData);

                // Register script to show success message
                ScriptManager.RegisterStartupScript(this, GetType(), "reportGenerated",
                    "showSuccess('Report generated successfully!');", true);
            }
            catch (Exception ex)
            {
                // Use simulated data as fallback
                UseSimulatedData();
                System.Diagnostics.Debug.WriteLine(string.Format("Report generation failed: {0}", ex.Message));

                ScriptManager.RegisterStartupScript(this, GetType(), "reportError",
                    "showError('Failed to generate report. Showing demo data.');", true);
            }
        }

        private string BuildReportQuery(string reportType, string dateRange, string statusFilter, string startDate, string endDate)
        {
            string baseQuery = "";

            switch (reportType)
            {
                case "pickup":
                    baseQuery = @"
                        SELECT 
                            PR.Id,
                            U.Name as UserName,
                            PR.ScheduledAt as PickupDate,
                            PR.WasteType,
                            PR.EstimatedWeight as Weight,
                            PR.Status,
                            PR.CreditsAwarded as Credits
                        FROM PickupRequests PR
                        INNER JOIN Users U ON PR.UserId = U.Id
                        WHERE 1=1";
                    break;

                case "user":
                    baseQuery = @"
                        SELECT 
                            U.Id,
                            U.Name,
                            U.Email,
                            U.Phone,
                            U.RegistrationDate,
                            COUNT(PR.Id) as TotalPickups,
                            SUM(CASE WHEN PR.Status = 'Completed' THEN 1 ELSE 0 END) as CompletedPickups
                        FROM Users U
                        LEFT JOIN PickupRequests PR ON U.Id = PR.UserId
                        GROUP BY U.Id, U.Name, U.Email, U.Phone, U.RegistrationDate";
                    break;

                case "waste":
                    baseQuery = @"
                        SELECT 
                            WasteType,
                            COUNT(*) as TotalPickups,
                            SUM(EstimatedWeight) as TotalWeight,
                            AVG(EstimatedWeight) as AvgWeight
                        FROM PickupRequests
                        GROUP BY WasteType";
                    break;

                default:
                    baseQuery = @"
                        SELECT 
                            PR.Id,
                            U.Name as UserName,
                            PR.ScheduledAt as PickupDate,
                            PR.WasteType,
                            PR.EstimatedWeight as Weight,
                            PR.Status,
                            PR.CreditsAwarded as Credits
                        FROM PickupRequests PR
                        INNER JOIN Users U ON PR.UserId = U.Id
                        WHERE 1=1";
                    break;
            }

            // Add date range filter
            if (!string.IsNullOrEmpty(dateRange) && dateRange != "custom")
            {
                baseQuery += GetDateRangeFilter(dateRange);
            }
            else if (dateRange == "custom" && !string.IsNullOrEmpty(startDate) && !string.IsNullOrEmpty(endDate))
            {
                baseQuery += string.Format(" AND CAST(PR.ScheduledAt AS DATE) BETWEEN '{0}' AND '{1}'", startDate, endDate);
            }

            // Add status filter
            if (statusFilter != "all")
            {
                baseQuery += string.Format(" AND PR.Status = '{0}'", statusFilter);
            }

            return baseQuery + " ORDER BY PR.ScheduledAt DESC";
        }

        private string GetDateRangeFilter(string dateRange)
        {
            switch (dateRange)
            {
                case "today":
                    return " AND CAST(PR.ScheduledAt AS DATE) = CAST(GETDATE() AS DATE)";
                case "yesterday":
                    return " AND CAST(PR.ScheduledAt AS DATE) = CAST(DATEADD(DAY, -1, GETDATE()) AS DATE)";
                case "week":
                    return " AND PR.ScheduledAt >= DATEADD(DAY, -7, GETDATE())";
                case "month":
                    return " AND PR.ScheduledAt >= DATEADD(DAY, -30, GETDATE())";
                case "quarter":
                    return " AND PR.ScheduledAt >= DATEADD(DAY, -90, GETDATE())";
                case "year":
                    return " AND PR.ScheduledAt >= DATEADD(DAY, -365, GETDATE())";
                default:
                    return " AND PR.ScheduledAt >= DATEADD(DAY, -30, GETDATE())";
            }
        }

        private DataTable ExecuteReportQuery(string query)
        {
            DataTable dataTable = new DataTable();

            try
            {
                string connectionString = System.Configuration.ConfigurationManager.ConnectionStrings["SoorGreenDB"].ConnectionString;

                if (string.IsNullOrEmpty(connectionString))
                {
                    return GetSimulatedDataTable();
                }

                using (SqlConnection conn = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand(query, conn))
                using (SqlDataAdapter adapter = new SqlDataAdapter(cmd))
                {
                    conn.Open();
                    adapter.Fill(dataTable);
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine(string.Format("Query execution error: {0}", ex.Message));
                dataTable = GetSimulatedDataTable();
            }

            return dataTable;
        }

        private DataTable GetSimulatedDataTable()
        {
            DataTable dt = new DataTable();
            dt.Columns.Add("Id", typeof(string));
            dt.Columns.Add("UserName", typeof(string));
            dt.Columns.Add("PickupDate", typeof(DateTime));
            dt.Columns.Add("WasteType", typeof(string));
            dt.Columns.Add("Weight", typeof(decimal));
            dt.Columns.Add("Status", typeof(string));
            dt.Columns.Add("Credits", typeof(int));

            // Add sample data
            dt.Rows.Add("PK001", "John Doe", DateTime.Now.AddDays(-1), "Plastic", 12.5m, "Completed", 125);
            dt.Rows.Add("PK002", "Jane Smith", DateTime.Now.AddDays(-2), "Paper", 8.2m, "Completed", 82);
            dt.Rows.Add("PK003", "Mike Johnson", DateTime.Now.AddDays(-3), "Glass", 15.8m, "Pending", 0);
            dt.Rows.Add("PK004", "Sarah Wilson", DateTime.Now.AddDays(-4), "Metal", 22.1m, "Completed", 221);
            dt.Rows.Add("PK005", "Tom Brown", DateTime.Now.AddDays(-5), "Plastic", 9.7m, "Cancelled", 0);

            return dt;
        }

        private void StoreReportResults(DataTable reportData)
        {
            // Convert DataTable to JSON for client-side use
            System.Web.Script.Serialization.JavaScriptSerializer serializer = new System.Web.Script.Serialization.JavaScriptSerializer();
            List<Dictionary<string, object>> rows = new List<Dictionary<string, object>>();
            Dictionary<string, object> row;

            foreach (DataRow dr in reportData.Rows)
            {
                row = new Dictionary<string, object>();
                foreach (DataColumn col in reportData.Columns)
                {
                    row.Add(col.ColumnName, dr[col]);
                }
                rows.Add(row);
            }

            hfReportData.Value = serializer.Serialize(rows);
        }

        private void UseSimulatedData()
        {
            // Set simulated data for demonstration
            var simulatedData = new
            {
                totalPickups = 156,
                completedPickups = 128,
                pendingPickups = 25,
                cancelledPickups = 3,
                totalRevenue = 28450,
                avgRating = 4.7
            };

            System.Web.Script.Serialization.JavaScriptSerializer serializer = new System.Web.Script.Serialization.JavaScriptSerializer();
            hfReportData.Value = serializer.Serialize(simulatedData);

            // Register script to show simulated data warning
            ScriptManager.RegisterStartupScript(this, GetType(), "simulatedData",
                "showDemoModeNotification();", true);
        }
    }
}