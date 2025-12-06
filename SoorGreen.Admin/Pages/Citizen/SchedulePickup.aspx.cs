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

        protected void btnSchedulePickup_Click(object sender, EventArgs e)
        {
            try
            {
                string wasteIds = hfSelectedWasteId.Value;
                string date = hfSelectedDate.Value;
                string time = hfSelectedTime.Value;
                string instructions = txtInstructions.Text;

                if (string.IsNullOrEmpty(wasteIds))
                {
                    ShowNotification("Please select waste for pickup", "error");
                    return;
                }

                if (string.IsNullOrEmpty(date))
                {
                    ShowNotification("Please select a pickup date", "error");
                    return;
                }

                if (string.IsNullOrEmpty(time))
                {
                    ShowNotification("Please select a time slot", "error");
                    return;
                }

                string userId = Session["UserID"].ToString();
                string[] wasteIdArray = wasteIds.Split(',');

                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    foreach (string wasteId in wasteIdArray)
                    {
                        if (string.IsNullOrEmpty(wasteId.Trim())) continue;

                        // Generate pickup ID
                        string pickupId = "PK" + DateTime.Now.ToString("yyyyMMddHHmmss") + "_" + Guid.NewGuid().ToString().Substring(0, 4).ToUpper();

                        // Parse date and time
                        DateTime scheduledDateTime = DateTime.Parse(date + " " + time + ":00");

                        // Insert into PickupRequests table
                        string query = @"INSERT INTO PickupRequests 
                                        (PickupId, ReportId, UserId, ScheduledDate, TimeSlot, 
                                         Instructions, Status, CreatedAt) 
                                        VALUES 
                                        (@PickupId, @ReportId, @UserId, @ScheduledDate, @TimeSlot,
                                         @Instructions, 'Scheduled', GETDATE())";

                        using (SqlCommand cmd = new SqlCommand(query, conn))
                        {
                            cmd.Parameters.AddWithValue("@PickupId", pickupId);
                            cmd.Parameters.AddWithValue("@ReportId", wasteId.Trim());
                            cmd.Parameters.AddWithValue("@UserId", userId);
                            cmd.Parameters.AddWithValue("@ScheduledDate", date);
                            cmd.Parameters.AddWithValue("@TimeSlot", time);
                            cmd.Parameters.AddWithValue("@Instructions", instructions ?? string.Empty);

                            cmd.ExecuteNonQuery();
                        }

                        // Update waste report status
                        string updateQuery = "UPDATE WasteReports SET Status = 'Scheduled' WHERE ReportId = @ReportId";
                        using (SqlCommand updateCmd = new SqlCommand(updateQuery, conn))
                        {
                            updateCmd.Parameters.AddWithValue("@ReportId", wasteId.Trim());
                            updateCmd.ExecuteNonQuery();
                        }
                    }

                    ShowSuccessNotification(wasteIdArray.Length);
                    ClearForm();
                    LoadPageData();

                    // Set JavaScript to show confirmation
                    string script = @"
                        showConfirmation({
                            PickupId: 'PK" + DateTime.Now.ToString("yyyyMMddHHmmss") + @"',
                            Date: '" + DateTime.Parse(date).ToString("MMM dd, yyyy") + @"',
                            Time: '" + time + @"',
                            ItemCount: " + wasteIdArray.Length + @",
                            EstimatedReward: 'Calculating...'
                        });";
                    ScriptManager.RegisterStartupScript(this, GetType(), "ShowConfirmation", script, true);
                }
            }
            catch (Exception ex)
            {
                ShowNotification("Error scheduling pickup: " + ex.Message, "error");
                LogError("SchedulePickup.Submit", ex.Message);
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
                string userId = Session["UserID"].ToString();
                var wasteItems = new List<object>();

                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    string query = @"
                        SELECT wr.ReportId, wt.Name as TypeName, wr.EstimatedKg, 
                               wr.Address, wr.CreatedAt, wr.Description
                        FROM WasteReports wr
                        INNER JOIN WasteTypes wt ON wr.WasteTypeId = wt.WasteTypeId
                        WHERE wr.UserId = @UserId 
                        AND wr.Status = 'Reported'
                        AND wr.ReportId NOT IN (
                            SELECT ReportId FROM PickupRequests 
                            WHERE Status IN ('Scheduled', 'Assigned', 'In Progress')
                        )
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
                                    EstimatedKg = Convert.ToDecimal(reader["EstimatedKg"]).ToString("F1"),
                                    Address = reader["Address"].ToString(),
                                    Description = reader["Description"] != DBNull.Value ? reader["Description"].ToString() : "",
                                    CreatedAt = Convert.ToDateTime(reader["CreatedAt"]),
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
                string userId = Session["UserID"].ToString();
                var pickups = new List<object>();

                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    string query = @"
                        SELECT 
                            pr.PickupId, 
                            wt.Name as WasteType, 
                            wr.EstimatedKg,
                            pr.ScheduledDate,
                            pr.TimeSlot,
                            pr.Status,
                            pr.CreatedAt
                        FROM PickupRequests pr
                        INNER JOIN WasteReports wr ON pr.ReportId = wr.ReportId
                        INNER JOIN WasteTypes wt ON wr.WasteTypeId = wt.WasteTypeId
                        WHERE wr.UserId = @UserId 
                        AND pr.Status IN ('Scheduled', 'Assigned', 'In Progress')
                        ORDER BY pr.ScheduledDate ASC, pr.TimeSlot ASC";

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
                                    EstimatedKg = Convert.ToDecimal(reader["EstimatedKg"]).ToString("F1"),
                                    ScheduledDate = FormatDate(reader["ScheduledDate"]),
                                    TimeSlot = reader["TimeSlot"].ToString(),
                                    Status = reader["Status"].ToString(),
                                    CreatedAt = Convert.ToDateTime(reader["CreatedAt"])
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
                string userId = Session["UserID"].ToString();
                var history = new List<object>();

                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

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
                                    Weight = Convert.ToDecimal(reader["Weight"]).ToString("F1"),
                                    CompletedDate = FormatDate(reader["CompletedDate"]),
                                    Collector = reader["Collector"] != DBNull.Value ? reader["Collector"].ToString() : "N/A",
                                    XPEarned = reader["XPEarned"] != DBNull.Value ? Convert.ToDecimal(reader["XPEarned"]).ToString("F0") : "0",
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
                string userId = Session["UserID"].ToString();
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

            if (timeSince.TotalMinutes < 1) return "Just now";
            if (timeSince.TotalHours < 1) return string.Format("{0} minutes ago", (int)timeSince.TotalMinutes);
            if (timeSince.TotalDays < 1) return string.Format("{0} hours ago", (int)timeSince.TotalHours);
            if (timeSince.TotalDays < 7) return string.Format("{0} days ago", (int)timeSince.TotalDays);
            if (timeSince.TotalDays < 30) return string.Format("{0} weeks ago", (int)(timeSince.TotalDays / 7));

            return string.Format("{0} months ago", (int)(timeSince.TotalDays / 30));
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

        private void ShowSuccessNotification(int itemCount)
        {
            string script = string.Format(@"
                Swal.fire({{
                    icon: 'success',
                    title: 'Pickup Scheduled Successfully!',
                    html: '<p>{0} waste item(s) have been scheduled for pickup.</p><p>You will receive a confirmation email shortly.</p>',
                    confirmButtonText: 'View Schedule',
                    confirmButtonColor: '#10b981',
                    showCancelButton: true,
                    cancelButtonText: 'Schedule Another'
                }}).then((result) => {{
                    if (result.isConfirmed) {{
                        switchTab('upcoming');
                    }} else {{
                        resetScheduleSteps();
                    }}
                }});", itemCount);

            ScriptManager.RegisterStartupScript(this, GetType(), "SuccessNotification", script, true);
        }

        private void ShowNotification(string message, string type)
        {
            string script = string.Format(@"
                Swal.fire({{
                    icon: '{0}',
                    title: '{1}',
                    text: '{2}',
                    confirmButtonText: 'OK',
                    confirmButtonColor: '#{3}'
                }});",
                type,
                type.ToUpper(),
                message.Replace("'", "\\'"),
                type == "error" ? "ef4444" : "3b82f6");

            ScriptManager.RegisterStartupScript(this, GetType(), "ShowNotification", script, true);
        }

        private void ClearForm()
        {
            hfSelectedWasteId.Value = "";
            hfSelectedDate.Value = "";
            hfSelectedTime.Value = "";
            txtInstructions.Text = "";

            // Clear date picker via JavaScript
            ScriptManager.RegisterStartupScript(this, GetType(), "ClearForm",
                @"if (window.resetScheduleSteps) { resetScheduleSteps(); }", true);
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
    }
}