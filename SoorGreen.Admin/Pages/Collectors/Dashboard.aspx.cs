using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace SoorGreen
{
    public partial class Dashboard : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // Check if user is logged in and is a collector
                if (Session["UserId"] == null || Session["UserRole"] == null)
                {
                    Response.Redirect("Login.aspx?redirect=CollectorDashboard.aspx");
                    return;
                }

                string userRole = Session["UserRole"].ToString();
                if (userRole != "COLL" && userRole != "R002")
                {
                    Response.Redirect("AccessDenied.aspx");
                    return;
                }

                LoadCollectorData();
                LoadTodayTasks();
                LoadUpcomingTasks();
                LoadPerformanceStats();
                LoadCollectorStats();
            }
        }

        private void LoadCollectorData()
        {
            string collectorId = Session["UserId"].ToString();

            using (SqlConnection conn = new SqlConnection(GetConnectionString()))
            {
                conn.Open();

                // Get collector name
                string query = @"SELECT FullName FROM Users WHERE UserId = @CollectorId";
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@CollectorId", collectorId);
                    object result = cmd.ExecuteScalar();
                    lblCollectorName.Text = result != null ? result.ToString() : "Collector";
                }

                // Get pending tasks count
                query = @"SELECT COUNT(*) FROM PickupRequests 
                         WHERE CollectorId = @CollectorId AND Status IN ('Assigned', 'In Progress')";
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@CollectorId", collectorId);
                    object result = cmd.ExecuteScalar();
                    string pendingCount = result != null ? result.ToString() : "0";
                    lblPendingTasks.Text = pendingCount;
                    lblPendingCount.Text = pendingCount;
                }

                // Get today's tasks count
                query = @"SELECT COUNT(*) FROM PickupRequests pr
                         JOIN WasteReports wr ON pr.ReportId = wr.ReportId
                         WHERE pr.CollectorId = @CollectorId 
                         AND CONVERT(DATE, pr.ScheduledAt) = CONVERT(DATE, GETDATE())
                         AND pr.Status IN ('Assigned', 'In Progress')";
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@CollectorId", collectorId);
                    object result = cmd.ExecuteScalar();
                    lblTodayTasks.Text = result != null ? result.ToString() : "0";
                }
            }
        }

        private void LoadTodayTasks()
        {
            string collectorId = Session["UserId"].ToString();
            string filter = ddlTaskFilter.SelectedValue;

            using (SqlConnection conn = new SqlConnection(GetConnectionString()))
            {
                conn.Open();

                string query = @"SELECT 
                    pr.PickupId,
                    wr.Address,
                    wr.EstimatedKg,
                    wt.Name as WasteType,
                    pr.Status,
                    FORMAT(pr.ScheduledAt, 'hh:mm tt') as ScheduledTime,
                    CONVERT(VARCHAR, pr.ScheduledAt, 107) as ScheduledDate
                FROM PickupRequests pr
                JOIN WasteReports wr ON pr.ReportId = wr.ReportId
                JOIN WasteTypes wt ON wr.WasteTypeId = wt.WasteTypeId
                WHERE pr.CollectorId = @CollectorId 
                AND CONVERT(DATE, pr.ScheduledAt) = CONVERT(DATE, GETDATE())";

                if (filter != "all")
                {
                    query += " AND pr.Status = @Status";
                }

                query += " ORDER BY pr.ScheduledAt ASC";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@CollectorId", collectorId);
                    if (filter != "all")
                    {
                        cmd.Parameters.AddWithValue("@Status", filter);
                    }

                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        da.Fill(dt);

                        if (dt.Rows.Count == 0)
                        {
                            pnlNoTasks.Visible = true;
                            rptTodayTasks.Visible = false;
                        }
                        else
                        {
                            pnlNoTasks.Visible = false;
                            rptTodayTasks.Visible = true;
                            rptTodayTasks.DataSource = dt;
                            rptTodayTasks.DataBind();
                        }
                    }
                }
            }
        }

        private void LoadUpcomingTasks()
        {
            string collectorId = Session["UserId"].ToString();

            using (SqlConnection conn = new SqlConnection(GetConnectionString()))
            {
                conn.Open();

                string query = @"SELECT TOP 5 
                    wr.Address,
                    wt.Name as WasteType,
                    FORMAT(pr.ScheduledAt, 'MMM dd, yyyy') as ScheduledDate
                FROM PickupRequests pr
                JOIN WasteReports wr ON pr.ReportId = wr.ReportId
                JOIN WasteTypes wt ON wr.WasteTypeId = wt.WasteTypeId
                WHERE pr.CollectorId = @CollectorId 
                AND CONVERT(DATE, pr.ScheduledAt) > CONVERT(DATE, GETDATE())
                AND pr.Status = 'Assigned'
                ORDER BY pr.ScheduledAt ASC";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@CollectorId", collectorId);

                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        da.Fill(dt);

                        if (dt.Rows.Count == 0)
                        {
                            pnlNoUpcoming.Visible = true;
                            rptUpcomingTasks.Visible = false;
                        }
                        else
                        {
                            pnlNoUpcoming.Visible = false;
                            rptUpcomingTasks.Visible = true;
                            rptUpcomingTasks.DataSource = dt;
                            rptUpcomingTasks.DataBind();
                        }
                    }
                }
            }
        }

        private void LoadPerformanceStats()
        {
            string collectorId = Session["UserId"].ToString();

            using (SqlConnection conn = new SqlConnection(GetConnectionString()))
            {
                conn.Open();

                // Weekly completions
                string query = @"SELECT COUNT(*) FROM PickupRequests 
                                WHERE CollectorId = @CollectorId 
                                AND Status = 'Collected'
                                AND DATEPART(WEEK, CompletedAt) = DATEPART(WEEK, GETDATE())";
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@CollectorId", collectorId);
                    object result = cmd.ExecuteScalar();
                    lblWeeklyCompletions.Text = result != null ? result.ToString() : "0";
                }

                // Weekly weight collected
                query = @"SELECT ISNULL(SUM(pv.VerifiedKg), 0) 
                         FROM PickupRequests pr
                         JOIN PickupVerifications pv ON pr.PickupId = pv.PickupId
                         WHERE pr.CollectorId = @CollectorId 
                         AND pr.Status = 'Collected'
                         AND DATEPART(WEEK, pr.CompletedAt) = DATEPART(WEEK, GETDATE())";
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@CollectorId", collectorId);
                    object result = cmd.ExecuteScalar();
                    decimal weight = result != DBNull.Value && result != null ? Convert.ToDecimal(result) : 0;
                    lblWeeklyWeight.Text = weight.ToString("0");
                }

                // Calculate target progress
                int weeklyTarget = 20;
                int completions = 0;
                int.TryParse(lblWeeklyCompletions.Text, out completions);
                int progress = (int)Math.Round((completions / (double)weeklyTarget) * 100);
                lblTargetProgress.Text = progress.ToString();
            }
        }

        private void LoadCollectorStats()
        {
            string collectorId = Session["UserId"].ToString();

            using (SqlConnection conn = new SqlConnection(GetConnectionString()))
            {
                conn.Open();

                // Total assigned tasks
                string query = @"SELECT COUNT(*) FROM PickupRequests 
                                WHERE CollectorId = @CollectorId";
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@CollectorId", collectorId);
                    object result = cmd.ExecuteScalar();
                    lblTotalTasks.Text = result != null ? result.ToString() : "0";
                }

                // Weekly completed tasks
                query = @"SELECT COUNT(*) FROM PickupRequests 
                         WHERE CollectorId = @CollectorId 
                         AND Status = 'Collected'
                         AND DATEPART(WEEK, CompletedAt) = DATEPART(WEEK, GETDATE())";
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@CollectorId", collectorId);
                    object result = cmd.ExecuteScalar();
                    lblCompletedTasks.Text = result != null ? result.ToString() : "0";
                }

                // Total weight collected
                query = @"SELECT ISNULL(SUM(pv.VerifiedKg), 0) 
                         FROM PickupRequests pr
                         JOIN PickupVerifications pv ON pr.PickupId = pv.PickupId
                         WHERE pr.CollectorId = @CollectorId 
                         AND pr.Status = 'Collected'";
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@CollectorId", collectorId);
                    object result = cmd.ExecuteScalar();
                    decimal totalWeight = result != DBNull.Value && result != null ? Convert.ToDecimal(result) : 0;
                    lblTotalWeight.Text = totalWeight.ToString("0");
                }
            }
        }

        protected void btnStartRoute_Click(object sender, EventArgs e)
        {
            pnlMapView.Visible = true;
            ScriptManager.RegisterStartupScript(this, GetType(), "InitializeMap", "initializeMap();", true);
        }

        protected void btnCloseMap_Click(object sender, EventArgs e)
        {
            pnlMapView.Visible = false;
        }

        protected void btnViewRoute_Click(object sender, EventArgs e)
        {
            btnStartRoute_Click(sender, e);
        }

        protected void btnSubmitReport_Click(object sender, EventArgs e)
        {
            Response.Redirect("DailyReport.aspx");
        }

        protected void btnScanWaste_Click(object sender, EventArgs e)
        {
            Response.Redirect("QRScanner.aspx");
        }

        protected void btnViewDetails_Click(object sender, EventArgs e)
        {
            Button btn = (Button)sender;
            string pickupId = btn.CommandArgument;
            Response.Redirect(string.Format("PickupDetails.aspx?id={0}", pickupId));
        }

        protected void btnStartPickup_Click(object sender, EventArgs e)
        {
            Button btn = (Button)sender;
            string pickupId = btn.CommandArgument;

            using (SqlConnection conn = new SqlConnection(GetConnectionString()))
            {
                conn.Open();

                string query = @"UPDATE PickupRequests 
                               SET Status = 'In Progress', 
                                   ScheduledAt = GETDATE()
                               WHERE PickupId = @PickupId";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@PickupId", pickupId);
                    cmd.ExecuteNonQuery();
                }
            }

            LoadTodayTasks();
            ScriptManager.RegisterStartupScript(this, GetType(), "ShowSuccess",
                "showNotification('Pickup started successfully!', 'success');", true);
        }

        protected void btnCompletePickup_Click(object sender, EventArgs e)
        {
            Button btn = (Button)sender;
            string pickupId = btn.CommandArgument;
            Response.Redirect(string.Format("CompletePickup.aspx?id={0}", pickupId));
        }

        protected void ddlTaskFilter_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadTodayTasks();
        }

        protected void rptTodayTasks_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
            {
                DataRowView row = (DataRowView)e.Item.DataItem;
                string status = row["Status"].ToString();

                Button btnStart = (Button)e.Item.FindControl("btnStartPickup");
                Button btnComplete = (Button)e.Item.FindControl("btnCompletePickup");

                if (btnStart != null)
                {
                    btnStart.Visible = (status == "Assigned");
                }

                if (btnComplete != null)
                {
                    btnComplete.Visible = (status == "In Progress");
                }
            }
        }

        // Helper methods for data binding
        public string GetTaskColor(object dataItem)
        {
            if (dataItem is DataRowView)
            {
                DataRowView row = (DataRowView)dataItem;
                string status = row["Status"].ToString();

                switch (status)
                {
                    case "Assigned":
                        return "#3b82f6";    // Blue
                    case "In Progress":
                        return "#f59e0b";    // Orange
                    case "Collected":
                        return "#10b981";    // Green
                    default:
                        return "#94a3b8";    // Gray
                }
            }
            return "#94a3b8";
        }

        public string GetTaskIcon(object dataItem)
        {
            if (dataItem is DataRowView)
            {
                DataRowView row = (DataRowView)dataItem;
                string wasteType = row["WasteType"].ToString().ToLower();

                if (wasteType.Contains("plastic"))
                    return "fas fa-bottle-water";
                else if (wasteType.Contains("paper"))
                    return "fas fa-file-alt";
                else if (wasteType.Contains("glass"))
                    return "fas fa-glass-whiskey";
                else if (wasteType.Contains("metal"))
                    return "fas fa-industry";
                else if (wasteType.Contains("organic"))
                    return "fas fa-leaf";
                else if (wasteType.Contains("electronic"))
                    return "fas fa-plug";
                else
                    return "fas fa-trash";
            }
            return "fas fa-trash";
        }

        public string GetTargetProgress()
        {
            return lblTargetProgress.Text;
        }

        private string GetConnectionString()
        {
            return System.Configuration.ConfigurationManager.ConnectionStrings["SoorGreenDBConnectionString"].ConnectionString;
        }
    }
}