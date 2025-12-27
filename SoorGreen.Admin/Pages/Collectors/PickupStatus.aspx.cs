using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace SoorGreen.Collectors
{
    public partial class PickupStatus : System.Web.UI.Page
    {
        private string connectionString = System.Configuration.ConfigurationManager.ConnectionStrings["SoorGreenDBConnectionString"].ConnectionString;
        private int pageSize = 10;
        private int currentPage = 1;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (Session["UserID"] == null || Session["UserRole"] == null)
                {
                    Response.Redirect("~/Login.aspx?returnUrl=" + Server.UrlEncode(Request.Url.AbsolutePath));
                    return;
                }

                // Verify user is a collector
                string userRole = Session["UserRole"].ToString();
                if (userRole != "R003" && userRole != "R002") // Assuming R003=Collector, R002=Admin
                {
                    ShowErrorMessage("Access denied. Collector role required.");
                    Response.Redirect("~/Default.aspx");
                    return;
                }

                LoadStats();
                LoadPickups();
                BindStatusFilters();
            }
        }

        protected void btnRefresh_Click(object sender, EventArgs e)
        {
            LoadStats();
            LoadPickups();
        }

        protected void btnClearFilters_Click(object sender, EventArgs e)
        {
            txtStartDate.Text = "";
            txtEndDate.Text = "";
            ddlStatus.SelectedIndex = 0;
            txtSearch.Text = "";
            LoadPickups();
        }

        protected void ddlStatus_SelectedIndexChanged(object sender, EventArgs e)
        {
            currentPage = 1;
            hdnCurrentPage.Value = "1";
            LoadPickups();
        }

        protected void txtSearch_TextChanged(object sender, EventArgs e)
        {
            currentPage = 1;
            hdnCurrentPage.Value = "1";
            LoadPickups();
        }

        protected void rptPickups_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
            {
                DataRowView rowView = (DataRowView)e.Item.DataItem;
                string status = rowView["Status"].ToString();
                string pickupId = rowView["PickupId"].ToString();

                // Find controls
                LinkButton btnStart = (LinkButton)e.Item.FindControl("btnStart");
                LinkButton btnComplete = (LinkButton)e.Item.FindControl("btnComplete");
                LinkButton btnCancel = (LinkButton)e.Item.FindControl("btnCancel");

                // Show/hide buttons based on status
                if (btnStart != null)
                    btnStart.Visible = (status == "Assigned" || status == "Scheduled");
                if (btnComplete != null)
                    btnComplete.Visible = (status == "In Progress");
                if (btnCancel != null)
                    btnCancel.Visible = (status != "Collected" && status != "Cancelled" && status != "Completed");
            }
        }

        protected void rptPickups_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            string pickupId = e.CommandArgument.ToString();
            hdnSelectedPickupId.Value = pickupId;

            switch (e.CommandName)
            {
                case "ViewDetails":
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ShowPickupModal",
                        string.Format("showPickupDetailsModal('{0}');", pickupId), true);
                    break;

                case "StartPickup":
                    UpdatePickupStatus(pickupId, "In Progress");
                    break;

                case "CompletePickup":
                    CompletePickup(pickupId);
                    break;

                case "CancelPickup":
                    UpdatePickupStatus(pickupId, "Cancelled");
                    break;

                case "ViewLocation":
                    ShowPickupLocation(pickupId);
                    break;
            }
        }

        protected void btnPrevPage_Click(object sender, EventArgs e)
        {
            currentPage = int.Parse(hdnCurrentPage.Value);
            if (currentPage > 1)
            {
                currentPage--;
                hdnCurrentPage.Value = currentPage.ToString();
                LoadPickups();
            }
        }

        protected void btnNextPage_Click(object sender, EventArgs e)
        {
            currentPage = int.Parse(hdnCurrentPage.Value);
            currentPage++;
            hdnCurrentPage.Value = currentPage.ToString();
            LoadPickups();
        }

        protected void btnPage_Click(object sender, EventArgs e)
        {
            LinkButton btn = (LinkButton)sender;
            currentPage = int.Parse(btn.CommandArgument);
            hdnCurrentPage.Value = currentPage.ToString();
            LoadPickups();
        }

        // ========== HELPER METHODS ==========

        private string GetCurrentCollectorId()
        {
            // Use Session["UserID"] instead of Session["CollectorId"]
            if (Session["UserID"] != null)
            {
                return Session["UserID"].ToString();
            }
            else
            {
                // If no user ID in session, redirect to login
                Response.Redirect("~/Login.aspx?returnUrl=" + Server.UrlEncode(Request.Url.AbsolutePath));
                return "";
            }
        }

        private string GetCurrentUserRole()
        {
            if (Session["UserRole"] != null)
            {
                return Session["UserRole"].ToString();
            }
            return "";
        }

        private void LoadStats()
        {
            try
            {
                string collectorId = GetCurrentCollectorId();
                if (string.IsNullOrEmpty(collectorId))
                {
                    ShowErrorMessage("Collector ID not found. Please login again.");
                    return;
                }

                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    // Total Assigned
                    string totalQuery = @"
                        SELECT COUNT(*) AS Total 
                        FROM PickupRequests 
                        WHERE CollectorId = @CollectorId 
                        AND Status NOT IN ('Completed', 'Cancelled')";

                    using (SqlCommand cmd = new SqlCommand(totalQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@CollectorId", collectorId);
                        object result = cmd.ExecuteScalar();
                        statTotalPickups.Text = result != null ? result.ToString() : "0";
                    }

                    // In Progress
                    string inProgressQuery = @"
                        SELECT COUNT(*) AS Total 
                        FROM PickupRequests 
                        WHERE CollectorId = @CollectorId 
                        AND Status = 'In Progress'";

                    using (SqlCommand cmd = new SqlCommand(inProgressQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@CollectorId", collectorId);
                        object result = cmd.ExecuteScalar();
                        statInProgress.Text = result != null ? result.ToString() : "0";
                    }

                    // Completed Today
                    string completedQuery = @"
                        SELECT COUNT(*) AS Total 
                        FROM PickupRequests 
                        WHERE CollectorId = @CollectorId 
                        AND Status = 'Collected' 
                        AND CAST(CompletedAt AS DATE) = CAST(GETDATE() AS DATE)";

                    using (SqlCommand cmd = new SqlCommand(completedQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@CollectorId", collectorId);
                        object result = cmd.ExecuteScalar();
                        statCompletedToday.Text = result != null ? result.ToString() : "0";
                    }

                    // Pending
                    string pendingQuery = @"
                        SELECT COUNT(*) AS Total 
                        FROM PickupRequests 
                        WHERE CollectorId = @CollectorId 
                        AND Status IN ('Assigned', 'Scheduled')";

                    using (SqlCommand cmd = new SqlCommand(pendingQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@CollectorId", collectorId);
                        object result = cmd.ExecuteScalar();
                        statPending.Text = result != null ? result.ToString() : "0";
                    }

                    // Debug: Show collector info
                    ShowSuccessMessage("Stats loaded for Collector: " + collectorId);
                }
            }
            catch (Exception ex)
            {
                ShowErrorMessage("Error loading stats: " + ex.Message);
            }
        }

        private void BindStatusFilters()
        {
            ddlStatus.Items.Clear();
            ddlStatus.Items.Add(new ListItem("All Status", "all"));
            ddlStatus.Items.Add(new ListItem("Requested", "Requested"));
            ddlStatus.Items.Add(new ListItem("Assigned", "Assigned"));
            ddlStatus.Items.Add(new ListItem("Scheduled", "Scheduled"));
            ddlStatus.Items.Add(new ListItem("In Progress", "In Progress"));
            ddlStatus.Items.Add(new ListItem("Collected", "Collected"));
            ddlStatus.Items.Add(new ListItem("Completed", "Completed"));
            ddlStatus.Items.Add(new ListItem("Cancelled", "Cancelled"));
        }

        private void LoadPickups()
        {
            try
            {
                currentPage = int.Parse(hdnCurrentPage.Value);
                string collectorId = GetCurrentCollectorId();

                if (string.IsNullOrEmpty(collectorId))
                {
                    ShowErrorMessage("Please login to view pickups.");
                    pnlEmptyState.Visible = true;
                    return;
                }

                // Build base query
                string baseQuery = @"
                    SELECT 
                        p.PickupId,
                        w.ReportId,
                        u.FullName AS CitizenName,
                        u.Phone AS CitizenPhone,
                        w.Address,
                        wt.Name AS WasteType,
                        w.EstimatedKg,
                        p.ScheduledAt,
                        p.CompletedAt,
                        p.Status,
                        w.PhotoUrl,
                        ROW_NUMBER() OVER (ORDER BY 
                            CASE p.Status
                                WHEN 'In Progress' THEN 1
                                WHEN 'Assigned' THEN 2
                                WHEN 'Scheduled' THEN 3
                                WHEN 'Requested' THEN 4
                                ELSE 5
                            END, 
                            p.ScheduledAt DESC) AS PriorityOrder
                    FROM PickupRequests p
                    JOIN WasteReports w ON p.ReportId = w.ReportId
                    JOIN Users u ON w.UserId = u.UserId
                    JOIN WasteTypes wt ON w.WasteTypeId = wt.WasteTypeId
                    WHERE p.CollectorId = @CollectorId";

                // Add filters
                List<string> filters = new List<string>();
                Dictionary<string, object> parameters = new Dictionary<string, object>();
                parameters.Add("@CollectorId", collectorId);

                // Date filters
                if (!string.IsNullOrEmpty(txtStartDate.Text))
                {
                    filters.Add("p.ScheduledAt >= @StartDate");
                    parameters.Add("@StartDate", DateTime.Parse(txtStartDate.Text));
                }

                if (!string.IsNullOrEmpty(txtEndDate.Text))
                {
                    filters.Add("p.ScheduledAt <= @EndDate");
                    parameters.Add("@EndDate", DateTime.Parse(txtEndDate.Text).AddDays(1));
                }

                // Status filter
                if (ddlStatus.SelectedValue != "all")
                {
                    filters.Add("p.Status = @Status");
                    parameters.Add("@Status", ddlStatus.SelectedValue);
                }

                // Search filter
                if (!string.IsNullOrEmpty(txtSearch.Text))
                {
                    string searchTerm = "%" + txtSearch.Text + "%";
                    filters.Add("(p.PickupId LIKE @Search OR w.Address LIKE @Search OR u.FullName LIKE @Search)");
                    parameters.Add("@Search", searchTerm);
                }

                if (filters.Count > 0)
                {
                    baseQuery += " AND " + string.Join(" AND ", filters);
                }

                // Get total count
                int totalRecords = 0;
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    string countQuery = "SELECT COUNT(*) FROM (" + baseQuery + ") AS CountTable";
                    using (SqlCommand cmd = new SqlCommand(countQuery, conn))
                    {
                        foreach (var param in parameters)
                        {
                            cmd.Parameters.AddWithValue(param.Key, param.Value);
                        }
                        conn.Open();
                        object result = cmd.ExecuteScalar();
                        totalRecords = result != null ? Convert.ToInt32(result) : 0;
                    }
                }

                // Calculate pagination
                int totalPages = (int)Math.Ceiling((double)totalRecords / pageSize);
                int startRecord = ((currentPage - 1) * pageSize) + 1;
                int endRecord = Math.Min(currentPage * pageSize, totalRecords);

                // Update labels
                lblTotalRecords.Text = totalRecords.ToString();
                lblStartRecord.Text = startRecord.ToString();
                lblEndRecord.Text = endRecord.ToString();

                // Get paginated data with priority sorting
                string paginatedQuery = @"
                    WITH PriorityPickups AS (
                        " + baseQuery + @"
                    )
                    SELECT * FROM PriorityPickups 
                    ORDER BY PriorityOrder
                    OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY";

                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    using (SqlCommand cmd = new SqlCommand(paginatedQuery, conn))
                    {
                        foreach (var param in parameters)
                        {
                            cmd.Parameters.AddWithValue(param.Key, param.Value);
                        }
                        cmd.Parameters.AddWithValue("@Offset", (currentPage - 1) * pageSize);
                        cmd.Parameters.AddWithValue("@PageSize", pageSize);

                        conn.Open();
                        DataTable dt = new DataTable();
                        using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                        {
                            da.Fill(dt);
                        }

                        rptPickups.DataSource = dt;
                        rptPickups.DataBind();

                        // Show/hide empty state
                        pnlEmptyState.Visible = totalRecords == 0;

                        // Debug info
                        if (totalRecords == 0)
                        {
                            ShowErrorMessage("No pickups found for Collector ID: " + collectorId + ". Check if pickups are assigned to this collector in the database.");
                        }
                        else
                        {
                            ShowSuccessMessage("Found " + totalRecords + " pickups for Collector: " + collectorId);
                        }
                    }
                }

                // Build pagination
                BuildPagination(totalPages, currentPage);
            }
            catch (Exception ex)
            {
                ShowErrorMessage("Error loading pickups: " + ex.Message);
                pnlEmptyState.Visible = true;
            }
        }

        private void BuildPagination(int totalPages, int currentPage)
        {
            List<PaginationItem> pages = new List<PaginationItem>();
            int startPage = Math.Max(1, currentPage - 2);
            int endPage = Math.Min(totalPages, currentPage + 2);

            for (int i = startPage; i <= endPage; i++)
            {
                pages.Add(new PaginationItem
                {
                    PageNumber = i,
                    CurrentPage = currentPage
                });
            }

            rptPageNumbers.DataSource = pages;
            rptPageNumbers.DataBind();

            // Enable/disable navigation buttons
            btnPrevPage.Enabled = currentPage > 1;
            btnNextPage.Enabled = currentPage < totalPages;
        }

        private void UpdatePickupStatus(string pickupId, string status)
        {
            try
            {
                string collectorId = GetCurrentCollectorId();
                if (string.IsNullOrEmpty(collectorId))
                {
                    ShowErrorMessage("Please login to update pickups.");
                    return;
                }

                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    string query = @"
                        UPDATE PickupRequests 
                        SET Status = @Status,
                            CompletedAt = CASE WHEN @Status = 'Collected' THEN GETDATE() ELSE CompletedAt END
                        WHERE PickupId = @PickupId 
                        AND CollectorId = @CollectorId";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@PickupId", pickupId);
                        cmd.Parameters.AddWithValue("@Status", status);
                        cmd.Parameters.AddWithValue("@CollectorId", collectorId);
                        conn.Open();
                        int rowsAffected = cmd.ExecuteNonQuery();

                        if (rowsAffected > 0)
                        {
                            ShowSuccessMessage(string.Format("Pickup {0} status updated to {1}!", pickupId, status));
                            LoadStats();
                            LoadPickups();
                        }
                        else
                        {
                            ShowErrorMessage("No pickup found with ID: " + pickupId + " assigned to you.");
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                ShowErrorMessage("Error updating pickup: " + ex.Message);
            }
        }

        private void CompletePickup(string pickupId)
        {
            try
            {
                string collectorId = GetCurrentCollectorId();
                if (string.IsNullOrEmpty(collectorId))
                {
                    ShowErrorMessage("Please login to complete pickups.");
                    return;
                }

                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    string query = @"
                        UPDATE PickupRequests 
                        SET Status = 'Collected',
                            CompletedAt = GETDATE()
                        WHERE PickupId = @PickupId 
                        AND CollectorId = @CollectorId";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@PickupId", pickupId);
                        cmd.Parameters.AddWithValue("@CollectorId", collectorId);
                        int rowsAffected = cmd.ExecuteNonQuery();

                        if (rowsAffected > 0)
                        {
                            // Update WasteReport status
                            string updateReportQuery = @"
                                UPDATE WasteReports 
                                SET Status = 'Collected',
                                    StatusUpdatedAt = GETDATE()
                                WHERE ReportId = (
                                    SELECT ReportId FROM PickupRequests WHERE PickupId = @PickupId
                                )";

                            using (SqlCommand cmd2 = new SqlCommand(updateReportQuery, conn))
                            {
                                cmd2.Parameters.AddWithValue("@PickupId", pickupId);
                                cmd2.ExecuteNonQuery();
                            }

                            ShowSuccessMessage(string.Format("Pickup {0} completed successfully!", pickupId));
                            LoadStats();
                            LoadPickups();
                        }
                        else
                        {
                            ShowErrorMessage("Cannot complete pickup " + pickupId + ". It may not be assigned to you.");
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                ShowErrorMessage("Error completing pickup: " + ex.Message);
            }
        }

        private void ShowPickupLocation(string pickupId)
        {
            // Redirect to map page or show modal with map
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ShowLocation",
                string.Format("window.open('PickupMap.aspx?id={0}', '_blank');", pickupId), true);
        }

        private void ExportReportsToExcel()
        {
            try
            {
                // Export functionality here
                ShowSuccessMessage("Export feature coming soon!");
            }
            catch (Exception ex)
            {
                ShowErrorMessage("Error exporting: " + ex.Message);
            }
        }

        private void ShowSuccessMessage(string message)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ShowSuccessToast",
                string.Format("showToast('{0}', 'success');", message.Replace("'", "\\'")), true);
        }

        private void ShowErrorMessage(string message)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ShowErrorToast",
                string.Format("showToast('{0}', 'error');", message.Replace("'", "\\'")), true);
        }

        // ========== PUBLIC METHODS FOR ASHX BINDING ==========

        public string GetStatusBadgeClass(string status)
        {
            switch (status)
            {
                case "Requested": return "status-badge status-requested";
                case "Assigned": return "status-badge status-assigned";
                case "Scheduled": return "status-badge status-scheduled";
                case "In Progress": return "status-badge status-inprogress";
                case "Collected": return "status-badge status-collected";
                case "Completed": return "status-badge status-completed";
                case "Cancelled": return "status-badge status-cancelled";
                default: return "status-badge";
            }
        }

        public string BindStatusIcon(string status)
        {
            switch (status)
            {
                case "Requested": return "fas fa-clock";
                case "Assigned": return "fas fa-user-check";
                case "Scheduled": return "fas fa-calendar-check";
                case "In Progress": return "fas fa-truck-loading";
                case "Collected": return "fas fa-check-circle";
                case "Completed": return "fas fa-flag-checkered";
                case "Cancelled": return "fas fa-times-circle";
                default: return "fas fa-question-circle";
            }
        }

        public string GetWasteTypeBadgeClass(string wasteType)
        {
            switch (wasteType)
            {
                case "Plastic": return "waste-badge plastic";
                case "Paper": return "waste-badge paper";
                case "Metal": return "waste-badge metal";
                case "Glass": return "waste-badge glass";
                case "Organic": return "waste-badge organic";
                case "E-Waste": return "waste-badge ewaste";
                case "Hazardous": return "waste-badge hazardous";
                default: return "waste-badge other";
            }
        }

        public string BindWasteTypeIcon(string wasteType)
        {
            switch (wasteType)
            {
                case "Plastic": return "fas fa-recycle";
                case "Paper": return "fas fa-newspaper";
                case "Metal": return "fas fa-weight";
                case "Glass": return "fas fa-wine-bottle";
                case "Organic": return "fas fa-leaf";
                case "E-Waste": return "fas fa-laptop";
                case "Hazardous": return "fas fa-radiation";
                default: return "fas fa-trash";
            }
        }

        public string FormatDateTime(object dateTime)
        {
            if (dateTime == null || dateTime == DBNull.Value)
                return "Not set";

            DateTime dt;
            if (DateTime.TryParse(dateTime.ToString(), out dt))
            {
                return dt.ToString("MMM dd, yyyy hh:mm tt");
            }
            return dateTime.ToString();
        }

        public string FormatDate(object dateTime)
        {
            if (dateTime == null || dateTime == DBNull.Value)
                return "Not set";

            DateTime dt;
            if (DateTime.TryParse(dateTime.ToString(), out dt))
            {
                return dt.ToString("MMM dd, yyyy");
            }
            return dateTime.ToString();
        }

        // Event handlers for quick action buttons (ASPX buttons)
        protected void btnStartAll_Click(object sender, EventArgs e)
        {
            try
            {
                string collectorId = GetCurrentCollectorId();
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    string query = @"
                        UPDATE PickupRequests 
                        SET Status = 'In Progress'
                        WHERE CollectorId = @CollectorId 
                        AND Status IN ('Assigned', 'Scheduled')";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@CollectorId", collectorId);
                        conn.Open();
                        int rowsAffected = cmd.ExecuteNonQuery();
                        ShowSuccessMessage("Started " + rowsAffected + " pickups.");
                        LoadPickups();
                    }
                }
            }
            catch (Exception ex)
            {
                ShowErrorMessage("Error starting all pickups: " + ex.Message);
            }
        }

        protected void btnExportPickups_Click(object sender, EventArgs e)
        {
            ExportReportsToExcel();
        }

        protected void btnViewToday_Click(object sender, EventArgs e)
        {
            DateTime today = DateTime.Today;
            txtStartDate.Text = today.ToString("yyyy-MM-dd");
            txtEndDate.Text = today.ToString("yyyy-MM-dd");
            LoadPickups();
        }

        protected void btnRouteOptimizer_Click(object sender, EventArgs e)
        {
            Response.Redirect("RouteOptimizer.aspx");
        }

        protected void btnMarkAllComplete_Click(object sender, EventArgs e)
        {
            try
            {
                string collectorId = GetCurrentCollectorId();
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    string query = @"
                        UPDATE PickupRequests 
                        SET Status = 'Collected',
                            CompletedAt = GETDATE()
                        WHERE CollectorId = @CollectorId 
                        AND Status = 'In Progress'";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@CollectorId", collectorId);
                        int rowsAffected = cmd.ExecuteNonQuery();

                        if (rowsAffected > 0)
                        {
                            // Update corresponding WasteReports
                            string updateReportsQuery = @"
                                UPDATE wr
                                SET wr.Status = 'Collected',
                                    wr.StatusUpdatedAt = GETDATE()
                                FROM WasteReports wr
                                INNER JOIN PickupRequests pr ON wr.ReportId = pr.ReportId
                                WHERE pr.CollectorId = @CollectorId 
                                AND pr.Status = 'Collected'
                                AND pr.CompletedAt >= DATEADD(minute, -1, GETDATE())";

                            using (SqlCommand cmd2 = new SqlCommand(updateReportsQuery, conn))
                            {
                                cmd2.Parameters.AddWithValue("@CollectorId", collectorId);
                                cmd2.ExecuteNonQuery();
                            }
                        }

                        ShowSuccessMessage("Marked " + rowsAffected + " pickups as completed.");
                        LoadPickups();
                    }
                }
            }
            catch (Exception ex)
            {
                ShowErrorMessage("Error marking pickups as complete: " + ex.Message);
            }
        }

        protected void btnViewSchedule_Click(object sender, EventArgs e)
        {
            Response.Redirect("Schedule.aspx");
        }
    }

    // Helper class for pagination
    public class PaginationItem
    {
        public int PageNumber { get; set; }
        public int CurrentPage { get; set; }
    }
}