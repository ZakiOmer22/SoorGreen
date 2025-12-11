using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Collections.Generic;

namespace SoorGreen.Admin
{
    public partial class PickupStatus : System.Web.UI.Page
    {
        private string currentUserId;
        private string connectionString = System.Configuration.ConfigurationManager.ConnectionStrings["SoorGreenDBConnectionString"].ConnectionString;

        // Pagination variables
        private int currentPage = 1;
        private int pageSize = 10;
        private int totalItems = 0;

        // Filter variables
        private string statusFilter = "all";
        private string dateFilter = "today";
        private string searchQuery = "";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // Check if user is logged in
                if (Session["UserId"] == null)
                {
                    Response.Redirect("~/Login.aspx");
                    return;
                }

                currentUserId = Session["UserId"].ToString();

                // Load initial data
                LoadPickupStats();
                LoadPickups();

                // REMOVED: LoadPriorities() - No Priority column in table
            }
            else
            {
                // Restore values from session
                if (Session["UserId"] != null)
                {
                    currentUserId = Session["UserId"].ToString();
                }

                if (Session["CurrentPage"] != null)
                {
                    currentPage = (int)Session["CurrentPage"];
                }
            }
        }

        private void LoadPickupStats()
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    // Get pending pickups count
                    string pendingQuery = @"
                        SELECT COUNT(*) 
                        FROM PickupRequests pr
                        INNER JOIN WasteReports wr ON pr.ReportId = wr.ReportId
                        WHERE wr.UserId = @UserId AND pr.Status = 'Requested'";

                    using (SqlCommand cmd = new SqlCommand(pendingQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@UserId", currentUserId);
                        var result = cmd.ExecuteScalar();
                        statPending.InnerText = result != DBNull.Value ? result.ToString() : "0";
                    }

                    // Get scheduled pickups count
                    string scheduledQuery = @"
                        SELECT COUNT(*) 
                        FROM PickupRequests pr
                        INNER JOIN WasteReports wr ON pr.ReportId = wr.ReportId
                        WHERE wr.UserId = @UserId AND pr.Status = 'Scheduled'";

                    using (SqlCommand cmd = new SqlCommand(scheduledQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@UserId", currentUserId);
                        var result = cmd.ExecuteScalar();
                        statScheduled.InnerText = result != DBNull.Value ? result.ToString() : "0";
                    }

                    // Get in-progress pickups count
                    string inProgressQuery = @"
                        SELECT COUNT(*) 
                        FROM PickupRequests pr
                        INNER JOIN WasteReports wr ON pr.ReportId = wr.ReportId
                        WHERE wr.UserId = @UserId AND pr.Status = 'InProgress'";

                    using (SqlCommand cmd = new SqlCommand(inProgressQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@UserId", currentUserId);
                        var result = cmd.ExecuteScalar();
                        statInProgress.InnerText = result != DBNull.Value ? result.ToString() : "0";
                    }

                    // Get completed pickups count
                    string completedQuery = @"
                        SELECT COUNT(*) 
                        FROM PickupRequests pr
                        INNER JOIN WasteReports wr ON pr.ReportId = wr.ReportId
                        WHERE wr.UserId = @UserId AND pr.Status = 'Collected'";

                    using (SqlCommand cmd = new SqlCommand(completedQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@UserId", currentUserId);
                        var result = cmd.ExecuteScalar();
                        statCompleted.InnerText = result != DBNull.Value ? result.ToString() : "0";
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("LoadPickupStats Error: " + ex.Message);
            }
        }

        private void LoadPickups()
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    // Build query with filters
                    string query = BuildPickupQuery();

                    // First, get total count for pagination
                    string countQuery = "SELECT COUNT(*) FROM (" + query + ") AS SubQuery";
                    using (SqlCommand countCmd = new SqlCommand(countQuery, conn))
                    {
                        AddQueryParameters(countCmd);
                        totalItems = Convert.ToInt32(countCmd.ExecuteScalar());
                    }

                    // Now get paginated data
                    query = "SELECT * FROM (" + query + ") AS FilteredPickups ORDER BY ScheduledDate DESC OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        AddQueryParameters(cmd);
                        cmd.Parameters.AddWithValue("@Offset", (currentPage - 1) * pageSize);
                        cmd.Parameters.AddWithValue("@PageSize", pageSize);

                        using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                        {
                            DataTable dt = new DataTable();
                            da.Fill(dt);

                            if (dt.Rows.Count > 0)
                            {
                                rptPickups.DataSource = dt;
                                rptPickups.DataBind();
                                pnlPickupCards.Visible = true;
                                pnlEmptyState.Visible = false;
                            }
                            else
                            {
                                pnlPickupCards.Visible = false;
                                pnlEmptyState.Visible = true;
                            }

                            // Update pagination labels
                            UpdatePaginationLabels();
                            LoadPageNumbers();
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("LoadPickups Error: " + ex.Message);
                pnlPickupCards.Visible = false;
                pnlEmptyState.Visible = true;
            }
        }

        private string BuildPickupQuery()
        {
            // FIXED: Removed Priority column since it doesn't exist in schema
            string baseQuery = @"
                SELECT 
                    pr.PickupId,
                    wr.ReportId,
                    wr.EstimatedKg as Weight,
                    wr.Address,
                    wr.PhotoUrl,
                    wt.Name as WasteType,
                    pr.Status as PickupStatus,
                    pr.ScheduledAt as ScheduledDate,
                    pr.CompletedAt as CompletedDate,
                    c.FullName as CollectorName,
                    c.Phone as CollectorPhone,
                    (wr.EstimatedKg * wt.CreditPerKg) as EstimatedReward,
                    CASE 
                        WHEN pr.Status = 'Requested' THEN 'pending'
                        WHEN pr.Status = 'Scheduled' THEN 'scheduled'
                        WHEN pr.Status = 'InProgress' THEN 'inprogress'
                        WHEN pr.Status = 'Collected' THEN 'completed'
                        WHEN pr.Status = 'Cancelled' THEN 'cancelled'
                        ELSE 'pending'
                    END as StatusDisplay
                FROM PickupRequests pr
                INNER JOIN WasteReports wr ON pr.ReportId = wr.ReportId
                INNER JOIN WasteTypes wt ON wr.WasteTypeId = wt.WasteTypeId
                LEFT JOIN Users c ON pr.CollectorId = c.UserId
                WHERE wr.UserId = @UserId";

            // Apply status filter
            if (!string.IsNullOrEmpty(statusFilter) && statusFilter != "all")
            {
                baseQuery += " AND pr.Status = @StatusFilter";
            }

            // Apply date filter
            if (!string.IsNullOrEmpty(dateFilter))
            {
                switch (dateFilter)
                {
                    case "today":
                        baseQuery += " AND CAST(pr.ScheduledAt AS DATE) = CAST(GETDATE() AS DATE)";
                        break;
                    case "week":
                        baseQuery += " AND pr.ScheduledAt >= DATEADD(DAY, -7, GETDATE())";
                        break;
                    case "month":
                        baseQuery += " AND pr.ScheduledAt >= DATEADD(MONTH, -1, GETDATE())";
                        break;
                    case "year":
                        baseQuery += " AND pr.ScheduledAt >= DATEADD(YEAR, -1, GETDATE())";
                        break;
                    case "upcoming":
                        baseQuery += " AND pr.ScheduledAt >= GETDATE() AND pr.Status IN ('Scheduled', 'InProgress')";
                        break;
                    case "past":
                        baseQuery += " AND pr.ScheduledAt < GETDATE()";
                        break;
                }
            }

            // Apply search filter
            if (!string.IsNullOrEmpty(searchQuery))
            {
                baseQuery += " AND (pr.PickupId LIKE @SearchQuery OR wr.ReportId LIKE @SearchQuery OR wr.Address LIKE @SearchQuery OR c.FullName LIKE @SearchQuery)";
            }

            return baseQuery;
        }

        private void AddQueryParameters(SqlCommand cmd)
        {
            cmd.Parameters.AddWithValue("@UserId", currentUserId);

            if (!string.IsNullOrEmpty(statusFilter) && statusFilter != "all")
            {
                cmd.Parameters.AddWithValue("@StatusFilter", statusFilter);
            }

            if (!string.IsNullOrEmpty(searchQuery))
            {
                cmd.Parameters.AddWithValue("@SearchQuery", "%" + searchQuery + "%");
            }
        }

        private void UpdatePaginationLabels()
        {
            int start = ((currentPage - 1) * pageSize) + 1;
            int end = Math.Min(currentPage * pageSize, totalItems);

            lblStartCount.Text = start.ToString();
            lblEndCount.Text = end.ToString();
            lblTotalCount.Text = totalItems.ToString();

            // Enable/disable navigation buttons
            btnPrevPage.Enabled = currentPage > 1;
            btnNextPage.Enabled = currentPage < Math.Ceiling((double)totalItems / pageSize);
        }

        private void LoadPageNumbers()
        {
            int totalPages = (int)Math.Ceiling((double)totalItems / pageSize);

            // Show max 5 page numbers
            int startPage = Math.Max(1, currentPage - 2);
            int endPage = Math.Min(totalPages, startPage + 4);

            if (endPage - startPage < 4)
            {
                startPage = Math.Max(1, endPage - 4);
            }

            var pageNumbers = new List<dynamic>();
            for (int i = startPage; i <= endPage; i++)
            {
                pageNumbers.Add(new { PageNumber = i, CurrentPage = currentPage });
            }

            rptPageNumbers.DataSource = pageNumbers;
            rptPageNumbers.DataBind();
        }

        protected void ddlStatusFilter_SelectedIndexChanged(object sender, EventArgs e)
        {
            statusFilter = ddlStatusFilter.SelectedValue;
            currentPage = 1;
            Session["CurrentPage"] = currentPage;
            LoadPickups();
        }

        protected void ddlDateFilter_SelectedIndexChanged(object sender, EventArgs e)
        {
            dateFilter = ddlDateFilter.SelectedValue;
            currentPage = 1;
            Session["CurrentPage"] = currentPage;
            LoadPickups();
        }

        protected void txtSearch_TextChanged(object sender, EventArgs e)
        {
            searchQuery = txtSearch.Text.Trim();
            currentPage = 1;
            Session["CurrentPage"] = currentPage;
            LoadPickups();
        }

        protected void btnPrevPage_Click(object sender, EventArgs e)
        {
            if (currentPage > 1)
            {
                currentPage--;
                Session["CurrentPage"] = currentPage;
                LoadPickups();
            }
        }

        protected void btnNextPage_Click(object sender, EventArgs e)
        {
            int totalPages = (int)Math.Ceiling((double)totalItems / pageSize);
            if (currentPage < totalPages)
            {
                currentPage++;
                Session["CurrentPage"] = currentPage;
                LoadPickups();
            }
        }

        protected void btnPage_Click(object sender, EventArgs e)
        {
            LinkButton btn = (LinkButton)sender;
            currentPage = Convert.ToInt32(btn.CommandArgument);
            Session["CurrentPage"] = currentPage;
            LoadPickups();
        }

        protected void rptPickups_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            string pickupId = e.CommandArgument.ToString();

            switch (e.CommandName)
            {
                case "ViewDetails":
                    ViewPickupDetails(pickupId);
                    break;

                case "Reschedule":
                    ReschedulePickup(pickupId);
                    break;

                case "Cancel":
                    CancelPickup(pickupId);
                    break;

                case "ContactCollector":
                    ContactCollector(pickupId);
                    break;
            }
        }

        private void ViewPickupDetails(string pickupId)
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    string query = @"
                        SELECT 
                            pr.*,
                            wr.ReportId,
                            wr.EstimatedKg,
                            wr.Address,
                            wr.PhotoUrl,
                            wt.Name as WasteType,
                            c.FullName as CollectorName,
                            c.Phone as CollectorPhone,
                            c.Email as CollectorEmail,
                            (wr.EstimatedKg * wt.CreditPerKg) as EstimatedReward
                        FROM PickupRequests pr
                        INNER JOIN WasteReports wr ON pr.ReportId = wr.ReportId
                        INNER JOIN WasteTypes wt ON wr.WasteTypeId = wt.WasteTypeId
                        LEFT JOIN Users c ON pr.CollectorId = c.UserId
                        WHERE pr.PickupId = @PickupId AND wr.UserId = @UserId";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@PickupId", pickupId);
                        cmd.Parameters.AddWithValue("@UserId", currentUserId);

                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                string details = "Pickup ID: " + reader["PickupId"] + "\n" +
                                                "Report ID: " + reader["ReportId"] + "\n" +
                                                "Waste Type: " + reader["WasteType"] + "\n" +
                                                "Weight: " + reader["EstimatedKg"] + " kg\n" +
                                                "Address: " + reader["Address"] + "\n" +
                                                "Status: " + reader["Status"] + "\n" +
                                                "Scheduled: " + (reader["ScheduledAt"] != DBNull.Value ? ((DateTime)reader["ScheduledAt"]).ToString("MMM dd, yyyy HH:mm") : "Not Scheduled") + "\n" +
                                                "Collector: " + (reader["CollectorName"] != DBNull.Value ? reader["CollectorName"] + " (" + reader["CollectorPhone"] + ")" : "Not Assigned") + "\n" +
                                                "Estimated Reward: " + reader["EstimatedReward"] + " XP";

                                ShowMessage(details, "info");
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Error loading pickup details: " + ex.Message, "error");
            }
        }

        private void ReschedulePickup(string pickupId)
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    // Check if pickup can be rescheduled
                    string checkQuery = "SELECT Status FROM PickupRequests WHERE PickupId = @PickupId";

                    using (SqlCommand cmd = new SqlCommand(checkQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@PickupId", pickupId);
                        object result = cmd.ExecuteScalar();
                        string status = result != null ? result.ToString() : "";

                        if (status == "Collected" || status == "Cancelled")
                        {
                            ShowMessage("Cannot reschedule a completed or cancelled pickup.", "error");
                            return;
                        }
                    }

                    // Redirect to reschedule page with pickup ID
                    Response.Redirect("~/Pages/Citizen/ReschedulePickup.aspx?pickupId=" + pickupId);
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Error checking pickup status: " + ex.Message, "error");
            }
        }

        private void CancelPickup(string pickupId)
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    // Check if pickup can be cancelled
                    string checkQuery = "SELECT Status FROM PickupRequests WHERE PickupId = @PickupId";

                    using (SqlCommand cmd = new SqlCommand(checkQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@PickupId", pickupId);
                        object result = cmd.ExecuteScalar();
                        string status = result != null ? result.ToString() : "";

                        if (status == "Collected")
                        {
                            ShowMessage("Cannot cancel a completed pickup.", "error");
                            return;
                        }

                        if (status == "Cancelled")
                        {
                            ShowMessage("Pickup is already cancelled.", "info");
                            return;
                        }
                    }

                    // Update pickup status to cancelled
                    string updateQuery = "UPDATE PickupRequests SET Status = 'Cancelled' WHERE PickupId = @PickupId";

                    using (SqlCommand cmd = new SqlCommand(updateQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@PickupId", pickupId);

                        int rowsAffected = cmd.ExecuteNonQuery();

                        if (rowsAffected > 0)
                        {
                            ShowMessage("Pickup cancelled successfully!", "success");
                            LoadPickupStats();
                            LoadPickups();
                        }
                        else
                        {
                            ShowMessage("Failed to cancel pickup.", "error");
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Error cancelling pickup: " + ex.Message, "error");
            }
        }

        private void ContactCollector(string pickupId)
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    string query = @"
                        SELECT c.FullName, c.Phone, c.Email 
                        FROM PickupRequests pr
                        LEFT JOIN Users c ON pr.CollectorId = c.UserId
                        WHERE pr.PickupId = @PickupId";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@PickupId", pickupId);

                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                string collectorName = reader["FullName"] != DBNull.Value ? reader["FullName"].ToString() : "";
                                string collectorPhone = reader["Phone"] != DBNull.Value ? reader["Phone"].ToString() : "";
                                string collectorEmail = reader["Email"] != DBNull.Value ? reader["Email"].ToString() : "";

                                if (!string.IsNullOrEmpty(collectorPhone))
                                {
                                    string message = "Collector: " + collectorName + "\n" +
                                                   "Phone: " + collectorPhone + "\n" +
                                                   "Email: " + collectorEmail + "\n\n" +
                                                   "You can contact them directly for any pickup-related questions.";

                                    ShowMessage(message, "info");
                                }
                                else
                                {
                                    ShowMessage("No collector assigned to this pickup yet.", "info");
                                }
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Error loading collector details: " + ex.Message, "error");
            }
        }

        protected void btnNewPickup_Click(object sender, EventArgs e)
        {
            // Redirect to MyReports page to create a new report first
            Response.Redirect("~/Pages/Citizen/MyReports.aspx");
        }

        protected void btnRefresh_Click(object sender, EventArgs e)
        {
            LoadPickupStats();
            LoadPickups();
            ShowMessage("Data refreshed successfully!", "success");
        }

        protected void btnExportPickups_Click(object sender, EventArgs e)
        {
            ShowMessage("Export feature coming soon!", "info");
        }

        protected void btnViewAll_Click(object sender, EventArgs e)
        {
            // Reset filters to show all
            ddlStatusFilter.SelectedValue = "all";
            ddlDateFilter.SelectedValue = "all";
            txtSearch.Text = "";

            statusFilter = "all";
            dateFilter = "all";
            searchQuery = "";
            currentPage = 1;

            LoadPickups();
        }

        public string GetStatusIcon(string status)
        {
            switch (status.ToLower())
            {
                case "requested":
                case "pending": return "fas fa-clock";
                case "scheduled": return "fas fa-calendar-check";
                case "inprogress": return "fas fa-truck-loading";
                case "collected":
                case "completed": return "fas fa-check-circle";
                case "cancelled": return "fas fa-times-circle";
                default: return "fas fa-question-circle";
            }
        }

        public string GetStatusColor(string status)
        {
            switch (status.ToLower())
            {
                case "requested":
                case "pending": return "warning";
                case "scheduled": return "info";
                case "inprogress": return "primary";
                case "collected":
                case "completed": return "success";
                case "cancelled": return "danger";
                default: return "secondary";
            }
        }

        // REMOVED: GetPriorityIcon() - No Priority column in table

        public bool CanReschedule(string status)
        {
            return status.ToLower() != "collected" && status.ToLower() != "cancelled";
        }

        public bool CanCancel(string status)
        {
            return status.ToLower() != "collected" && status.ToLower() != "cancelled";
        }

        public bool HasCollector(string collectorName)
        {
            return !string.IsNullOrEmpty(collectorName);
        }

        public string FormatDateTime(object date)
        {
            if (date == DBNull.Value || date == null)
                return "Not Scheduled";

            DateTime dt = (DateTime)date;
            return dt.ToString("MMM dd, yyyy HH:mm");
        }

        private void ShowMessage(string message, string type)
        {
            string icon = "exclamation-circle";
            string upperType = type.ToUpper();

            switch (type.ToLower())
            {
                case "success":
                    icon = "check-circle";
                    break;
                case "warning":
                    icon = "exclamation-triangle";
                    break;
                case "error":
                    icon = "exclamation-circle";
                    break;
                case "info":
                    icon = "info-circle";
                    break;
            }

            string script = @"
                var messagePanel = document.querySelector('.message-panel') || (function() {
                    var div = document.createElement('div');
                    div.className = 'message-panel';
                    document.body.appendChild(div);
                    return div;
                })();
                
                messagePanel.innerHTML = `
                    <div class='message-alert " + type + @" show'>
                        <i class='fas fa-" + icon + @"'></i>
                        <div>
                            <strong>" + upperType + @"</strong>
                            <p class='mb-0'>" + message.Replace("'", "\\'") + @"</p>
                        </div>
                    </div>
                `;
                messagePanel.style.display = 'block';
                
                setTimeout(function() {
                    messagePanel.style.display = 'none';
                }, 5000);
            ";

            ScriptManager.RegisterStartupScript(this, GetType(), "ShowMessage_" + Guid.NewGuid().ToString(), script, true);
        }
    }
}