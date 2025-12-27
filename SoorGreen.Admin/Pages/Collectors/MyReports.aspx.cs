using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Collections.Generic;

namespace SoorGreen.Collectors
{
    public partial class MyReports : System.Web.UI.Page
    {
        protected string CurrentUserId = "";
        protected int CurrentPage = 1;
        protected int PageSize = 10;
        protected int TotalRecords = 0;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] == null || Session["UserRole"] == null)
            {
                Response.Redirect("~/Login.aspx?returnUrl=" + Server.UrlEncode(Request.Url.AbsolutePath));
                return;
            }

            CurrentUserId = Session["UserID"].ToString();

            if (!IsPostBack)
            {
                LoadCollectorInfo();
                InitializeFilters();
                LoadWasteTypes();
                LoadReportsSummary();
                LoadReportsData();
            }
            else
            {
                // Get current page from hidden field on postback
                if (!string.IsNullOrEmpty(hdnCurrentPage.Value))
                {
                    CurrentPage = int.Parse(hdnCurrentPage.Value);
                }
            }
        }

        private void LoadCollectorInfo()
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(GetConnectionString()))
                {
                    conn.Open();
                    string query = "SELECT FullName FROM Users WHERE UserId = @UserId";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@UserId", CurrentUserId);
                        var result = cmd.ExecuteScalar();
                        if (result != null)
                        {
                            // Update page title
                            Page.Title = "My Reports - " + result.ToString();
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error loading collector info: " + ex.Message);
            }
        }

        private void InitializeFilters()
        {
            txtStartDate.Text = DateTime.Now.AddDays(-30).ToString("yyyy-MM-dd");
            txtEndDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
        }

        private void LoadWasteTypes()
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(GetConnectionString()))
                {
                    conn.Open();
                    string query = "SELECT DISTINCT Name FROM WasteTypes ORDER BY Name";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                ddlWasteType.Items.Add(new ListItem(reader["Name"].ToString(), reader["Name"].ToString()));
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error loading waste types: " + ex.Message);
            }
        }

        private void LoadReportsSummary()
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(GetConnectionString()))
                {
                    conn.Open();

                    string query = @"
                        SELECT 
                            COUNT(DISTINCT wr.ReportId) as TotalReports,
                            SUM(CASE WHEN pr.Status = 'Completed' THEN 1 ELSE 0 END) as CompletedReports,
                            SUM(CASE WHEN pr.Status IN ('Assigned', 'In Progress', 'Collected') THEN 1 ELSE 0 END) as InProgressReports,
                            ISNULL(SUM(pv.VerifiedKg), 0) as TotalWeight
                        FROM WasteReports wr
                        INNER JOIN PickupRequests pr ON wr.ReportId = pr.ReportId
                        LEFT JOIN PickupVerifications pv ON pr.PickupId = pv.PickupId
                        WHERE pr.CollectorId = @CollectorId
                        AND wr.CreatedAt >= DATEADD(day, -30, GETDATE())";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@CollectorId", CurrentUserId);

                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                statTotalReports.Text = reader["TotalReports"].ToString();
                                statCompletedReports.Text = reader["CompletedReports"].ToString();
                                statInProgressReports.Text = reader["InProgressReports"].ToString();
                                decimal totalWeight = Convert.ToDecimal(reader["TotalWeight"]);
                                statTotalWeight.Text = totalWeight.ToString("F1") + " kg";
                            }
                            else
                            {
                                statTotalReports.Text = "0";
                                statCompletedReports.Text = "0";
                                statInProgressReports.Text = "0";
                                statTotalWeight.Text = "0.0 kg";
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error loading reports summary: " + ex.Message);
                statTotalReports.Text = "0";
                statCompletedReports.Text = "0";
                statInProgressReports.Text = "0";
                statTotalWeight.Text = "0.0 kg";
            }
        }

        private void LoadReportsData()
        {
            try
            {
                DateTime startDate = DateTime.Parse(txtStartDate.Text);
                DateTime endDate = DateTime.Parse(txtEndDate.Text);
                string status = ddlStatus.SelectedValue;
                string wasteType = ddlWasteType.SelectedValue;
                string searchText = txtSearch.Text.Trim();

                int offset = (CurrentPage - 1) * PageSize;

                using (SqlConnection conn = new SqlConnection(GetConnectionString()))
                {
                    conn.Open();

                    // Build dynamic WHERE clause
                    string whereClause = "WHERE pr.CollectorId = @CollectorId ";
                    whereClause += "AND wr.CreatedAt BETWEEN @StartDate AND @EndDate ";

                    if (status != "all")
                        whereClause += "AND pr.Status = @Status ";
                    if (wasteType != "all")
                        whereClause += "AND wt.Name = @WasteType ";
                    if (!string.IsNullOrEmpty(searchText))
                        whereClause += "AND (wr.Address LIKE @SearchText OR wr.ReportId LIKE @SearchText OR u.FullName LIKE @SearchText OR u.Phone LIKE @SearchText) ";

                    string query = @"
                        SELECT 
                            wr.ReportId,
                            wr.CreatedAt as ReportDate,
                            wr.Address,
                            wr.Landmark,
                            wt.Name as WasteType,
                            wr.EstimatedKg,
                            ISNULL(pv.VerifiedKg, 0) as VerifiedKg,
                            ISNULL(pv.VerificationMethod, 'Not Verified') as VerificationMethod,
                            pr.Status,
                            pr.PickupId,
                            u.FullName as CitizenName,
                            u.Phone as CitizenPhone
                        FROM WasteReports wr
                        INNER JOIN PickupRequests pr ON wr.ReportId = pr.ReportId
                        INNER JOIN WasteTypes wt ON wr.WasteTypeId = wt.WasteTypeId
                        INNER JOIN Users u ON wr.UserId = u.UserId
                        LEFT JOIN PickupVerifications pv ON pr.PickupId = pv.PickupId "
                        + whereClause + @"
                        ORDER BY wr.CreatedAt DESC
                        OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY";

                    string countQuery = @"
                        SELECT COUNT(*)
                        FROM WasteReports wr
                        INNER JOIN PickupRequests pr ON wr.ReportId = pr.ReportId
                        INNER JOIN WasteTypes wt ON wr.WasteTypeId = wt.WasteTypeId
                        INNER JOIN Users u ON wr.UserId = u.UserId "
                        + whereClause;

                    using (SqlCommand countCmd = new SqlCommand(countQuery, conn))
                    {
                        countCmd.Parameters.AddWithValue("@CollectorId", CurrentUserId);
                        countCmd.Parameters.AddWithValue("@StartDate", startDate);
                        countCmd.Parameters.AddWithValue("@EndDate", endDate.AddDays(1).AddSeconds(-1));

                        if (status != "all")
                            countCmd.Parameters.AddWithValue("@Status", status);
                        if (wasteType != "all")
                            countCmd.Parameters.AddWithValue("@WasteType", wasteType);
                        if (!string.IsNullOrEmpty(searchText))
                            countCmd.Parameters.AddWithValue("@SearchText", "%" + searchText + "%");

                        TotalRecords = Convert.ToInt32(countCmd.ExecuteScalar());
                        lblTotalRecords.Text = TotalRecords.ToString();
                    }

                    DataTable dt = new DataTable();
                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@CollectorId", CurrentUserId);
                        cmd.Parameters.AddWithValue("@StartDate", startDate);
                        cmd.Parameters.AddWithValue("@EndDate", endDate.AddDays(1).AddSeconds(-1));
                        cmd.Parameters.AddWithValue("@Offset", offset);
                        cmd.Parameters.AddWithValue("@PageSize", PageSize);

                        if (status != "all")
                            cmd.Parameters.AddWithValue("@Status", status);
                        if (wasteType != "all")
                            cmd.Parameters.AddWithValue("@WasteType", wasteType);
                        if (!string.IsNullOrEmpty(searchText))
                            cmd.Parameters.AddWithValue("@SearchText", "%" + searchText + "%");

                        using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                        {
                            da.Fill(dt);
                        }
                    }

                    if (dt.Rows.Count > 0)
                    {
                        int startRecord = offset + 1;
                        int endRecord = offset + dt.Rows.Count;

                        lblStartRecord.Text = startRecord.ToString();
                        lblEndRecord.Text = endRecord.ToString();

                        rptReports.DataSource = dt;
                        rptReports.DataBind();
                        pnlEmptyState.Visible = false;
                    }
                    else
                    {
                        pnlEmptyState.Visible = true;
                        lblStartRecord.Text = "0";
                        lblEndRecord.Text = "0";
                    }

                    SetupPagination();
                }
            }
            catch (Exception ex)
            {
                ShowToast("Error loading reports data: " + ex.Message, "error");
                System.Diagnostics.Debug.WriteLine("Error loading reports data: " + ex.Message);
            }
        }

        private void SetupPagination()
        {
            int totalPages = (int)Math.Ceiling((double)TotalRecords / PageSize);

            btnPrevPage.Enabled = CurrentPage > 1;
            btnNextPage.Enabled = CurrentPage < totalPages;

            List<dynamic> pageNumbers = new List<dynamic>();
            int startPage = Math.Max(1, CurrentPage - 2);
            int endPage = Math.Min(totalPages, CurrentPage + 2);

            for (int i = startPage; i <= endPage; i++)
            {
                pageNumbers.Add(new { PageNumber = i, CurrentPage = CurrentPage });
            }

            rptPageNumbers.DataSource = pageNumbers;
            rptPageNumbers.DataBind();
        }

        // Event Handlers
        protected void btnApplyFilter_Click(object sender, EventArgs e)
        {
            CurrentPage = 1;
            hdnCurrentPage.Value = "1";
            LoadReportsData();
            LoadReportsSummary();
        }

        protected void btnRefresh_Click(object sender, EventArgs e)
        {
            CurrentPage = 1;
            hdnCurrentPage.Value = "1";
            LoadReportsData();
            LoadReportsSummary();
        }

        protected void txtSearch_TextChanged(object sender, EventArgs e)
        {
            CurrentPage = 1;
            hdnCurrentPage.Value = "1";
            LoadReportsData();
        }

        protected void btnCreateReport_Click(object sender, EventArgs e)
        {
            Response.Redirect("~/Pages/Collectors/CreateReport.aspx");
        }

        protected void btnExportReports_Click(object sender, EventArgs e)
        {
            ShowToast("Export feature coming soon!", "info");
        }

        protected void btnViewAll_Click(object sender, EventArgs e)
        {
            // Reset filters and show all
            ddlStatus.SelectedValue = "all";
            ddlWasteType.SelectedValue = "all";
            txtSearch.Text = "";
            CurrentPage = 1;
            hdnCurrentPage.Value = "1";
            LoadReportsData();
        }

        protected void btnPrevPage_Click(object sender, EventArgs e)
        {
            if (CurrentPage > 1)
            {
                CurrentPage--;
                hdnCurrentPage.Value = CurrentPage.ToString();
                LoadReportsData();
            }
        }

        protected void btnNextPage_Click(object sender, EventArgs e)
        {
            int totalPages = (int)Math.Ceiling((double)TotalRecords / PageSize);
            if (CurrentPage < totalPages)
            {
                CurrentPage++;
                hdnCurrentPage.Value = CurrentPage.ToString();
                LoadReportsData();
            }
        }

        protected void btnPage_Click(object sender, EventArgs e)
        {
            LinkButton btn = (LinkButton)sender;
            CurrentPage = int.Parse(btn.CommandArgument);
            hdnCurrentPage.Value = CurrentPage.ToString();
            LoadReportsData();
        }

        protected void btnClearFilters_Click(object sender, EventArgs e)
        {
            // Reset filters
            txtStartDate.Text = DateTime.Now.AddDays(-30).ToString("yyyy-MM-dd");
            txtEndDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
            ddlStatus.SelectedValue = "all";
            ddlWasteType.SelectedValue = "all";
            txtSearch.Text = "";
            CurrentPage = 1;
            hdnCurrentPage.Value = "1";
            LoadReportsData();
        }

        protected void btnResetFilters_Click(object sender, EventArgs e)
        {
            btnClearFilters_Click(sender, e);
        }

        // Quick Actions
        protected void btnViewPerformance_Click(object sender, EventArgs e)
        {
            Response.Redirect("~/Pages/Collectors/CollectorPerformance.aspx");
        }

        protected void btnViewRoutes_Click(object sender, EventArgs e)
        {
            Response.Redirect("~/Pages/Collectors/CollectorRoutes.aspx");
        }

        protected void btnViewSchedule_Click(object sender, EventArgs e)
        {
            Response.Redirect("~/Pages/Collectors/Schedule.aspx");
        }

        protected void rptReports_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
            {
                DataRowView row = (DataRowView)e.Item.DataItem;

                // Find controls
                LinkButton btnEditReport = (LinkButton)e.Item.FindControl("btnEditReport");
                LinkButton btnCompleteReport = (LinkButton)e.Item.FindControl("btnCompleteReport");

                // Set visibility based on status
                string status = row["Status"].ToString();
                if (btnEditReport != null)
                    btnEditReport.Visible = IsEditable(status);
                if (btnCompleteReport != null)
                    btnCompleteReport.Visible = IsCompletable(status);
            }
        }

        // New event handlers for the modern table design
        protected void ddlStatus_SelectedIndexChanged(object sender, EventArgs e)
        {
            CurrentPage = 1;
            hdnCurrentPage.Value = "1";
            LoadReportsData();
        }

        protected void ddlWasteType_SelectedIndexChanged(object sender, EventArgs e)
        {
            CurrentPage = 1;
            hdnCurrentPage.Value = "1";
            LoadReportsData();
        }

        protected void rptReports_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            string reportId = e.CommandArgument.ToString();

            switch (e.CommandName)
            {
                case "ViewDetails":
                    // JavaScript will handle modal
                    break;

                case "EditReport":
                    Response.Redirect("~/Pages/Collectors/EditReport.aspx?reportId=" + reportId);
                    break;

                case "CompleteReport":
                    CompleteReport(reportId);
                    break;
            }
        }

        // Helper Methods
        private void CompleteReport(string reportId)
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(GetConnectionString()))
                {
                    conn.Open();

                    string checkQuery = "SELECT COUNT(*) FROM PickupVerifications WHERE PickupId = (SELECT PickupId FROM PickupRequests WHERE ReportId = @ReportId)";

                    using (SqlCommand checkCmd = new SqlCommand(checkQuery, conn))
                    {
                        checkCmd.Parameters.AddWithValue("@ReportId", reportId);
                        int verificationCount = Convert.ToInt32(checkCmd.ExecuteScalar());

                        if (verificationCount == 0)
                        {
                            ShowToast("Please verify the pickup weight before completing the report.", "warning");
                            return;
                        }
                    }

                    string updateQuery = @"
                        UPDATE PickupRequests 
                        SET Status = 'Completed', 
                            CompletedAt = GETDATE() 
                        WHERE ReportId = @ReportId";

                    using (SqlCommand cmd = new SqlCommand(updateQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@ReportId", reportId);
                        int rowsAffected = cmd.ExecuteNonQuery();

                        if (rowsAffected > 0)
                        {
                            ShowToast("Report marked as completed successfully!", "success");
                            LoadReportsData();
                            LoadReportsSummary();
                        }
                        else
                        {
                            ShowToast("Failed to complete report. Please try again.", "error");
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                ShowToast("Error completing report: " + ex.Message, "error");
            }
        }

        // Helper Methods for Data Binding (used in ASPX file)
        public string BindDate(object date)
        {
            if (date != null && date != DBNull.Value)
            {
                return ((DateTime)date).ToString("MMM dd, yyyy");
            }
            return "N/A";
        }

        public string BindDateTime(object date)
        {
            if (date != null && date != DBNull.Value)
            {
                return ((DateTime)date).ToString("MMM dd, yyyy HH:mm");
            }
            return "N/A";
        }

        public string BindWasteTypeIcon(string wasteType)
        {
            return GetWasteTypeIcon(wasteType);
        }

        public string BindStatusIcon(string status)
        {
            return GetStatusIcon(status);
        }

        public string GetWasteTypeBadgeClass(string wasteType)
        {
            switch (wasteType.ToLower())
            {
                case "plastic": return "waste-type-badge-modern plastic-badge";
                case "paper": return "waste-type-badge-modern paper-badge";
                case "glass": return "waste-type-badge-modern glass-badge";
                case "metal": return "waste-type-badge-modern metal-badge";
                case "organic": return "waste-type-badge-modern organic-badge";
                case "electronic": return "waste-type-badge-modern electronic-badge";
                default: return "waste-type-badge-modern";
            }
        }

        public string GetStatusBadgeClass(string status)
        {
            switch (status.ToLower())
            {
                case "requested": return "status-badge-modern status-pending";
                case "assigned": return "status-badge-modern status-assigned";
                case "in progress": return "status-badge-modern status-inprogress";
                case "collected": return "status-badge-modern status-collected";
                case "completed": return "status-badge-modern status-completed";
                case "cancelled": return "status-badge-modern status-cancelled";
                default: return "status-badge-modern";
            }
        }

        public bool IsEditable(string status)
        {
            return status == "Requested" || status == "Assigned";
        }

        public bool IsCompletable(string status)
        {
            return status == "Assigned" || status == "In Progress" || status == "Collected";
        }

        public string GetWasteTypeIcon(string wasteType)
        {
            switch (wasteType.ToLower())
            {
                case "plastic": return "fas fa-bottle-water";
                case "paper": return "fas fa-newspaper";
                case "glass": return "fas fa-wine-glass";
                case "metal": return "fas fa-cog";
                case "organic": return "fas fa-leaf";
                case "electronic": return "fas fa-laptop";
                case "textile": return "fas fa-tshirt";
                case "cardboard": return "fas fa-box";
                default: return "fas fa-trash";
            }
        }

        public string GetWasteTypeColor(string wasteType)
        {
            switch (wasteType.ToLower())
            {
                case "plastic": return "#3b82f6";
                case "paper": return "#f59e0b";
                case "glass": return "#10b981";
                case "metal": return "#6b7280";
                case "organic": return "#8b5cf6";
                case "electronic": return "#ef4444";
                case "textile": return "#db2777";
                case "cardboard": return "#92400e";
                default: return "#64748b";
            }
        }

        public string GetStatusIcon(string status)
        {
            switch (status.ToLower())
            {
                case "requested": return "fas fa-clock";
                case "assigned": return "fas fa-user-check";
                case "in progress": return "fas fa-spinner";
                case "collected": return "fas fa-check-circle";
                case "completed": return "fas fa-flag-checkered";
                case "cancelled": return "fas fa-times-circle";
                default: return "fas fa-question-circle";
            }
        }

        public string GetStatusClass(string status)
        {
            return status.ToLower().Replace(" ", "");
        }

        public string GetStatusColor(string status)
        {
            return GetStatusClass(status);
        }

        private string GetConnectionString()
        {
            return ConfigurationManager.ConnectionStrings["SoorGreenDBConnectionString"].ConnectionString;
        }

        // New toast notification method
        private void ShowToast(string message, string type)
        {
            string script = string.Format("showToast('{0}', '{1}');",
                message.Replace("'", "\\'").Replace("\n", "\\n"), type);
            ScriptManager.RegisterStartupScript(this, GetType(), "showToast", script, true);
        }
    }
}