using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.Configuration;
using System.Web.UI;
using System.Web.Script.Serialization;
using System.Collections.Generic;

namespace SoorGreen.Admin
{
    public partial class SchedulePickup : System.Web.UI.Page
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
                LoadPageData();
            }
        }

        protected void btnLoadData_Click(object sender, EventArgs e)
        {
            LoadPageData();
        }

        protected void btnSchedulePickup_Click(object sender, EventArgs e)
        {
            try
            {
                string wasteId = hfSelectedWasteId.Value;
                string date = hfSelectedDate.Value;
                string time = hfSelectedTime.Value;

                if (string.IsNullOrEmpty(wasteId))
                {
                    ShowNotification("Please select waste for pickup", "error");
                    return;
                }

                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    // Generate pickup ID
                    string pickupId = "PK" + DateTime.Now.ToString("yyyyMMddHHmmss");

                    // Get user ID
                    string userId = Session["UserID"].ToString();

                    // Get current date
                    string currentDate = DateTime.Now.ToString("yyyy-MM-dd");

                    // Insert into PickupRequests table
                    string query = @"INSERT INTO PickupRequests (PickupId, ReportId, UserId, Status, ScheduledDate, CreatedAt) 
                                     VALUES (@PickupId, @ReportId, @UserId, 'Scheduled', @ScheduledDate, GETDATE())";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@PickupId", pickupId);
                        cmd.Parameters.AddWithValue("@ReportId", wasteId);
                        cmd.Parameters.AddWithValue("@UserId", userId);
                        cmd.Parameters.AddWithValue("@ScheduledDate", currentDate);

                        int result = cmd.ExecuteNonQuery();

                        if (result > 0)
                        {
                            ShowNotification("Pickup scheduled successfully! ID: " + pickupId, "success");
                            ClearForm();
                            LoadPageData();
                        }
                        else
                        {
                            ShowNotification("Failed to schedule pickup", "error");
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                ShowNotification("Error: " + ex.Message, "error");
            }
        }

        private void LoadPageData()
        {
            LoadAvailableWaste();
            LoadUpcomingPickups();
            LoadPickupHistory();
            LoadStats();
        }

        private void LoadAvailableWaste()
        {
            try
            {
                string userId = "";
                if (Session["UserID"] != null)
                {
                    userId = Session["UserID"].ToString();
                }

                var wasteItems = new List<object>();

                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    // Get waste that hasn't been scheduled yet
                    string query = @"
                        SELECT wr.ReportId, wt.Name as TypeName, wr.EstimatedKg, wr.Address, wr.CreatedAt
                        FROM WasteReports wr
                        INNER JOIN WasteTypes wt ON wr.WasteTypeId = wt.WasteTypeId
                        WHERE wr.UserId = @UserId 
                        AND wr.ReportId NOT IN (
                            SELECT ReportId FROM PickupRequests WHERE Status IN ('Scheduled', 'Assigned', 'In Progress')
                        )
                        AND wr.Status = 'Reported'
                        ORDER BY wr.CreatedAt DESC";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@UserId", userId);
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                wasteItems.Add(new
                                {
                                    ReportId = reader["ReportId"].ToString(),
                                    TypeName = reader["TypeName"].ToString(),
                                    EstimatedKg = reader["EstimatedKg"].ToString(),
                                    Address = reader["Address"].ToString(),
                                    TimeAgo = GetTimeAgo(Convert.ToDateTime(reader["CreatedAt"]))
                                });
                            }
                        }
                    }
                }

                hfWasteData.Value = new JavaScriptSerializer().Serialize(wasteItems);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error loading waste: " + ex.Message);
                hfWasteData.Value = "[]";
            }
        }

        private void LoadUpcomingPickups()
        {
            try
            {
                string userId = "";
                if (Session["UserID"] != null)
                {
                    userId = Session["UserID"].ToString();
                }

                var pickups = new List<object>();

                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    // Get upcoming/scheduled pickups
                    string query = @"
                        SELECT 
                            pr.PickupId, 
                            wt.Name as WasteType, 
                            wr.EstimatedKg,
                            pr.ScheduledDate,
                            pr.Status,
                            pr.CreatedAt
                        FROM PickupRequests pr
                        INNER JOIN WasteReports wr ON pr.ReportId = wr.ReportId
                        INNER JOIN WasteTypes wt ON wr.WasteTypeId = wt.WasteTypeId
                        WHERE wr.UserId = @UserId 
                        AND pr.Status IN ('Scheduled', 'Assigned', 'In Progress')
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
                                    EstimatedKg = reader["EstimatedKg"].ToString(),
                                    ScheduledDate = FormatDate(reader["ScheduledDate"]),
                                    Status = reader["Status"].ToString()
                                });
                            }
                        }
                    }
                }

                hfUpcomingPickups.Value = new JavaScriptSerializer().Serialize(pickups);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error loading upcoming pickups: " + ex.Message);
                hfUpcomingPickups.Value = "[]";
            }
        }

        private void LoadPickupHistory()
        {
            try
            {
                string userId = "";
                if (Session["UserID"] != null)
                {
                    userId = Session["UserID"].ToString();
                }

                var history = new List<object>();

                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    // Get completed/cancelled pickups
                    string query = @"
                        SELECT 
                            pr.PickupId, 
                            wt.Name as WasteType, 
                            wr.EstimatedKg as Weight,
                            pr.CompletedDate,
                            u.FullName as Collector,
                            pr.XPEarned,
                            pr.Status
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
                                history.Add(new
                                {
                                    PickupId = reader["PickupId"].ToString(),
                                    WasteType = reader["WasteType"].ToString(),
                                    Weight = reader["Weight"].ToString(),
                                    CompletedDate = FormatDate(reader["CompletedDate"]),
                                    Collector = reader["Collector"] != DBNull.Value ? reader["Collector"].ToString() : "N/A",
                                    XPEarned = reader["XPEarned"] != DBNull.Value ? reader["XPEarned"].ToString() : "0",
                                    Status = reader["Status"].ToString()
                                });
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
                string userId = "";
                if (Session["UserID"] != null)
                {
                    userId = Session["UserID"].ToString();
                }

                var stats = new
                {
                    TotalPickups = 0,
                    ScheduledPickups = 0,
                    CompletedPickups = 0,
                    SuccessRate = 0
                };

                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    // Get statistics
                    string query = @"
                        SELECT 
                            COUNT(*) as TotalPickups,
                            SUM(CASE WHEN Status IN ('Scheduled', 'Assigned', 'In Progress') THEN 1 ELSE 0 END) as ScheduledPickups,
                            SUM(CASE WHEN Status = 'Completed' THEN 1 ELSE 0 END) as CompletedPickups
                        FROM PickupRequests pr
                        INNER JOIN WasteReports wr ON pr.ReportId = wr.ReportId
                        WHERE wr.UserId = @UserId";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@UserId", userId);
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                int totalPickups = Convert.ToInt32(reader["TotalPickups"]);
                                int completedPickups = Convert.ToInt32(reader["CompletedPickups"]);
                                int successRate = totalPickups > 0 ? (completedPickups * 100) / totalPickups : 0;

                                stats = new
                                {
                                    TotalPickups = totalPickups,
                                    ScheduledPickups = Convert.ToInt32(reader["ScheduledPickups"]),
                                    CompletedPickups = completedPickups,
                                    SuccessRate = successRate
                                };
                            }
                        }
                    }
                }

                hfStatsData.Value = new JavaScriptSerializer().Serialize(stats);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error loading stats: " + ex.Message);
                hfStatsData.Value = "{\"TotalPickups\":0,\"ScheduledPickups\":0,\"CompletedPickups\":0,\"SuccessRate\":0}";
            }
        }

        private string GetTimeAgo(DateTime date)
        {
            TimeSpan timeSince = DateTime.Now - date;
            if (timeSince.TotalDays < 1) return "Today";
            if (timeSince.TotalDays < 2) return "Yesterday";
            return ((int)timeSince.TotalDays) + " days ago";
        }

        private string FormatDate(object dateObj)
        {
            if (dateObj == DBNull.Value || dateObj == null)
                return "N/A";

            try
            {
                DateTime date = Convert.ToDateTime(dateObj);
                return date.ToString("MMM dd, yyyy");
            }
            catch
            {
                return "N/A";
            }
        }

        private void ShowNotification(string message, string type)
        {
            string script = string.Format("showNotification('{0}', '{1}');", message.Replace("'", "\\'"), type);
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ShowNotification", script, true);
        }

        private void ClearForm()
        {
            hfSelectedWasteId.Value = "";
            hfSelectedDate.Value = "";
            hfSelectedTime.Value = "";
            txtInstructions.Text = "";
        }
    }
}