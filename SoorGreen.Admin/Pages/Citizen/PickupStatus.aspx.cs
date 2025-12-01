using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.Configuration;
using System.Web.UI;
using System.Web.Script.Serialization;
using System.Collections.Generic;

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

                System.Diagnostics.Debug.WriteLine("DEBUG: Current UserID from Session: " + Session["UserID"]);

                LoadPageData();
            }
        }

        protected void btnLoadData_Click(object sender, EventArgs e)
        {
            LoadPageData();
        }

        private void LoadPageData()
        {
            LoadActivePickups();
            LoadPickupHistory();
            LoadStats();
        }

        private void LoadActivePickups()
        {
            try
            {
                string userId = Session["UserID"].ToString() ?? "";
                System.Diagnostics.Debug.WriteLine("DEBUG: Loading active pickups for user: " + userId);

                var pickups = new List<Dictionary<string, object>>();

                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    // Use the view vw_ActivePickups as requested
                    string query = @"
                        SELECT 
                            v.PickupId,
                            v.Address,
                            v.CitizenName,
                            v.CollectorName,
                            v.Status,
                            wr.EstimatedKg as Weight,
                            wt.Name as WasteType,
                            pr.ScheduledAt,
                            pr.CreatedAt
                        FROM vw_ActivePickups v
                        INNER JOIN PickupRequests pr ON v.PickupId = pr.PickupId
                        INNER JOIN WasteReports wr ON pr.ReportId = wr.ReportId
                        INNER JOIN WasteTypes wt ON wr.WasteTypeId = wt.WasteTypeId
                        WHERE wr.UserId = @UserId
                        ORDER BY 
                            CASE v.Status
                                WHEN 'Assigned' THEN 1
                                WHEN 'Scheduled' THEN 2
                                WHEN 'Requested' THEN 3
                                ELSE 4
                            END,
                            pr.ScheduledAt ASC";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@UserId", userId);
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            int count = 0;
                            while (reader.Read())
                            {
                                count++;
                                var pickup = new Dictionary<string, object>
                                {
                                    { "PickupId", reader["PickupId"].ToString() },
                                    { "WasteType", reader["WasteType"].ToString() },
                                    { "Weight", reader["Weight"].ToString() + " kg" },
                                    { "Address", reader["Address"].ToString() },
                                    { "ScheduledDate", FormatDate(reader["ScheduledAt"]) },
                                    { "Status", reader["Status"].ToString() },
                                    { "Collector", reader["CollectorName"] != DBNull.Value ? reader["CollectorName"].ToString() : "Not Assigned" },
                                    { "CreatedAt", FormatDate(reader["CreatedAt"]) }
                                };
                                pickups.Add(pickup);

                                System.Diagnostics.Debug.WriteLine(string.Format("DEBUG: Found pickup {0} - Status: {1}", reader["PickupId"], reader["Status"]));
                            }
                            System.Diagnostics.Debug.WriteLine(string.Format("DEBUG: Total active pickups found: {0}", count));

                            // If no active pickups found, check if user has any pickups at all
                            if (count == 0)
                            {
                                System.Diagnostics.Debug.WriteLine("DEBUG: No active pickups found. Checking if user has any pickups...");

                                // Close current reader first
                                reader.Close();

                                string checkQuery = @"
                                    SELECT COUNT(*) as TotalPickups 
                                    FROM PickupRequests pr
                                    INNER JOIN WasteReports wr ON pr.ReportId = wr.ReportId
                                    WHERE wr.UserId = @UserId";

                                using (SqlCommand checkCmd = new SqlCommand(checkQuery, conn))
                                {
                                    checkCmd.Parameters.AddWithValue("@UserId", userId);
                                    int totalPickups = (int)checkCmd.ExecuteScalar();
                                    System.Diagnostics.Debug.WriteLine(string.Format("DEBUG: User has {0} total pickups in database", totalPickups));
                                }
                            }
                        }
                    }
                }

                hfActivePickups.Value = new JavaScriptSerializer().Serialize(pickups);
                System.Diagnostics.Debug.WriteLine(string.Format("DEBUG: Serialized data to hidden field. Length: {0}", hfActivePickups.Value.Length));
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error loading active pickups: " + ex.Message);
                System.Diagnostics.Debug.WriteLine("Stack trace: " + ex.StackTrace);
                hfActivePickups.Value = "[]";
            }
        }

        private void LoadPickupHistory()
        {
            try
            {
                string userId = Session["UserID"].ToString() ?? "";
                var history = new List<Dictionary<string, object>>();

                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    // Query for completed/cancelled pickups
                    string query = @"
                        SELECT 
                            pr.PickupId,
                            wt.Name as WasteType,
                            wr.EstimatedKg as Weight,
                            wr.Address,
                            pr.CompletedAt,
                            pr.Status,
                            u.FullName as Collector,
                            pr.CreatedAt
                        FROM PickupRequests pr
                        INNER JOIN WasteReports wr ON pr.ReportId = wr.ReportId
                        INNER JOIN WasteTypes wt ON wr.WasteTypeId = wt.WasteTypeId
                        LEFT JOIN Users u ON pr.CollectorId = u.UserId
                        WHERE wr.UserId = @UserId 
                        AND pr.Status IN ('Collected', 'Cancelled')
                        ORDER BY ISNULL(pr.CompletedAt, pr.CreatedAt) DESC";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@UserId", userId);
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                var pickup = new Dictionary<string, object>
                                {
                                    { "PickupId", reader["PickupId"].ToString() },
                                    { "WasteType", reader["WasteType"].ToString() },
                                    { "Weight", reader["Weight"].ToString() + " kg" },
                                    { "Address", reader["Address"].ToString() },
                                    { "CompletedDate", FormatDate(reader["CompletedAt"]) },
                                    { "Status", reader["Status"].ToString() },
                                    { "Collector", reader["Collector"] != DBNull.Value ? reader["Collector"].ToString() : "Not Available" },
                                    { "CreatedAt", FormatDate(reader["CreatedAt"]) }
                                };
                                history.Add(pickup);
                            }
                        }
                    }
                }

                hfPickupHistory.Value = new JavaScriptSerializer().Serialize(history);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error loading pickup history: " + ex.Message);
                hfPickupHistory.Value = "[]";
            }
        }

        private void LoadStats()
        {
            try
            {
                string userId = Session["UserID"].ToString() ?? "";
                var stats = new Dictionary<string, object>();

                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    string query = @"
                        SELECT 
                            COUNT(DISTINCT pr.PickupId) as TotalPickups,
                            SUM(CASE WHEN pr.Status IN ('Requested', 'Scheduled', 'Assigned') THEN 1 ELSE 0 END) as ActivePickups,
                            SUM(CASE WHEN pr.Status = 'Collected' THEN 1 ELSE 0 END) as CompletedPickups,
                            SUM(CASE WHEN pr.Status = 'Cancelled' THEN 1 ELSE 0 END) as CancelledPickups,
                            ISNULL(SUM(rp.Amount), 0) as TotalXP
                        FROM PickupRequests pr
                        INNER JOIN WasteReports wr ON pr.ReportId = wr.ReportId
                        LEFT JOIN RewardPoints rp ON rp.UserId = wr.UserId AND rp.Reference LIKE '%' + pr.PickupId + '%'
                        WHERE wr.UserId = @UserId";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@UserId", userId);
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                int total = Convert.ToInt32(reader["TotalPickups"]);
                                int active = Convert.ToInt32(reader["ActivePickups"]);
                                int completed = Convert.ToInt32(reader["CompletedPickups"]);
                                int cancelled = Convert.ToInt32(reader["CancelledPickups"]);
                                decimal totalXP = Convert.ToDecimal(reader["TotalXP"]);

                                int successRate = (total - cancelled) > 0 ?
                                    (completed * 100) / (total - cancelled) : 0;

                                stats.Add("TotalPickups", total);
                                stats.Add("ActivePickups", active);
                                stats.Add("CompletedPickups", completed);
                                stats.Add("CancelledPickups", cancelled);
                                stats.Add("SuccessRate", successRate + "%");
                                stats.Add("TotalXP", totalXP + " XP");

                                System.Diagnostics.Debug.WriteLine(string.Format("DEBUG: Stats - Total: {0}, Active: {1}, Completed: {2}, Cancelled: {3}, XP: {4}", total, active, completed, cancelled, totalXP));
                            }
                        }
                    }
                }

                hfStatsData.Value = new JavaScriptSerializer().Serialize(stats);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error loading stats: " + ex.Message);
                hfStatsData.Value = @"{""TotalPickups"":0,""ActivePickups"":0,""CompletedPickups"":0,""CancelledPickups"":0,""SuccessRate"":""0%"",""TotalXP"":""0 XP""}";
            }
        }

        [System.Web.Services.WebMethod]
        public static string CancelPickup(string pickupId)
        {
            try
            {
                string connectionString = System.Configuration.ConfigurationManager.ConnectionStrings["SoorGreenDBConnectionString"].ConnectionString;

                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    string query = "UPDATE PickupRequests SET Status = 'Cancelled' WHERE PickupId = @PickupId";
                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@PickupId", pickupId);
                        int rowsAffected = cmd.ExecuteNonQuery();

                        return rowsAffected > 0 ? "Success: Pickup cancelled" : "Error: Pickup not found";
                    }
                }
            }
            catch (Exception ex)
            {
                return "Error: " + ex.Message;
            }
        }

        private string FormatDate(object dateObj)
        {
            if (dateObj == DBNull.Value || dateObj == null)
                return "Not set";

            try
            {
                DateTime date = Convert.ToDateTime(dateObj);
                return date.ToString("MMM dd, yyyy");
            }
            catch
            {
                return "Invalid date";
            }
        }

        private void ShowNotification(string message, string type)
        {
            string script = string.Format("showNotification('{0}', '{1}');", message.Replace("'", "\\'"), type);
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ShowNotification", script, true);
        }
    }
}