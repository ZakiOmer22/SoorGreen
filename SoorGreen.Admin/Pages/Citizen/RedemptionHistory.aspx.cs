using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Collections.Generic;
using System.Configuration;

namespace SoorGreen.Admin
{
    public partial class RedemptionHistory : System.Web.UI.Page
    {
        private string currentUserId;
        private string connectionString = ConfigurationManager.ConnectionStrings["SoorGreenDBConnectionString"].ConnectionString;

        // Pagination variables
        private int currentPage = 1;
        private int pageSize = 10;
        private int totalItems = 0;

        // Filter variables
        private string statusFilter = "all";
        private string methodFilter = "all";
        private DateTime? startDate = null;
        private DateTime? endDate = null;
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

                // Set default date range (last 30 days)
                endDate = DateTime.Now;
                startDate = DateTime.Now.AddDays(-30);
                txtStartDate.Text = startDate.Value.ToString("yyyy-MM-dd");
                txtEndDate.Text = endDate.Value.ToString("yyyy-MM-dd");

                // Load initial data
                LoadRedemptionStats();
                LoadRedemptions();
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

        private void LoadRedemptionStats()
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    // Get total redemptions
                    string totalQuery = @"
                        SELECT COUNT(*) 
                        FROM RedemptionRequests 
                        WHERE UserId = @UserId";

                    using (SqlCommand cmd = new SqlCommand(totalQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@UserId", currentUserId);
                        int totalRedemptions = Convert.ToInt32(cmd.ExecuteScalar());
                        statTotalRedemptions.InnerText = totalRedemptions.ToString("N0");
                    }

                    // Get completed redemptions
                    string completedQuery = @"
                        SELECT COUNT(*) 
                        FROM RedemptionRequests 
                        WHERE UserId = @UserId AND Status = 'Completed'";

                    using (SqlCommand cmd = new SqlCommand(completedQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@UserId", currentUserId);
                        int completed = Convert.ToInt32(cmd.ExecuteScalar());
                        statCompleted.InnerText = completed.ToString("N0");
                    }

                    // Get pending redemptions
                    string pendingQuery = @"
                        SELECT COUNT(*) 
                        FROM RedemptionRequests 
                        WHERE UserId = @UserId AND Status = 'Pending'";

                    using (SqlCommand cmd = new SqlCommand(pendingQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@UserId", currentUserId);
                        int pending = Convert.ToInt32(cmd.ExecuteScalar());
                        statPending.InnerText = pending.ToString("N0");
                    }

                    // Get total amount redeemed
                    string amountQuery = @"
                        SELECT ISNULL(SUM(Amount), 0) 
                        FROM RedemptionRequests 
                        WHERE UserId = @UserId AND Status IN ('Completed', 'Processing')";

                    using (SqlCommand cmd = new SqlCommand(amountQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@UserId", currentUserId);
                        decimal totalAmount = Convert.ToDecimal(cmd.ExecuteScalar());
                        statTotalAmount.InnerText = totalAmount.ToString("N0") + " XP";
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("LoadRedemptionStats Error: " + ex.Message);
            }
        }

        private void LoadRedemptions()
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    // Build query with filters - FIXED: Only select columns that exist
                    string query = BuildRedemptionQuery();

                    // First, get total count for pagination
                    string countQuery = "SELECT COUNT(*) FROM (" + query + ") AS SubQuery";
                    using (SqlCommand countCmd = new SqlCommand(countQuery, conn))
                    {
                        AddQueryParameters(countCmd);
                        totalItems = Convert.ToInt32(countCmd.ExecuteScalar());
                    }

                    // Now get paginated data
                    query = "SELECT * FROM (" + query + ") AS FilteredRedemptions ORDER BY RequestedAt DESC OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY";

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
                                rptRedemptions.DataSource = dt;
                                rptRedemptions.DataBind();
                                pnlRedemptionsTable.Visible = true;
                                pnlEmptyState.Visible = false;
                            }
                            else
                            {
                                pnlRedemptionsTable.Visible = false;
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
                System.Diagnostics.Debug.WriteLine("LoadRedemptions Error: " + ex.Message);
                pnlRedemptionsTable.Visible = false;
                pnlEmptyState.Visible = true;
            }
        }

        private string BuildRedemptionQuery()
        {
            // FIXED: Only select columns that exist in your database
            string baseQuery = @"
                SELECT 
                    RedemptionId,
                    Amount,
                    Method,
                    Status,
                    RequestedAt,
                    ProcessedAt
                FROM RedemptionRequests 
                WHERE UserId = @UserId";

            // Apply status filter
            if (!string.IsNullOrEmpty(statusFilter) && statusFilter != "all")
            {
                baseQuery += " AND Status = @Status";
            }

            // Apply method filter
            if (!string.IsNullOrEmpty(methodFilter) && methodFilter != "all")
            {
                baseQuery += " AND Method = @Method";
            }

            // Apply date filter
            if (startDate.HasValue)
            {
                baseQuery += " AND CAST(RequestedAt AS DATE) >= @StartDate";
            }

            if (endDate.HasValue)
            {
                baseQuery += " AND CAST(RequestedAt AS DATE) <= @EndDate";
            }

            // Apply search filter - FIXED: Only search on RedemptionId
            if (!string.IsNullOrEmpty(searchQuery))
            {
                baseQuery += " AND RedemptionId LIKE @SearchQuery";
            }

            return baseQuery;
        }

        private void AddQueryParameters(SqlCommand cmd)
        {
            cmd.Parameters.AddWithValue("@UserId", currentUserId);

            if (!string.IsNullOrEmpty(statusFilter) && statusFilter != "all")
            {
                cmd.Parameters.AddWithValue("@Status", statusFilter);
            }

            if (!string.IsNullOrEmpty(methodFilter) && methodFilter != "all")
            {
                cmd.Parameters.AddWithValue("@Method", methodFilter);
            }

            if (startDate.HasValue)
            {
                cmd.Parameters.AddWithValue("@StartDate", startDate.Value.Date);
            }

            if (endDate.HasValue)
            {
                cmd.Parameters.AddWithValue("@EndDate", endDate.Value.Date);
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

        // Event Handlers
        protected void ddlStatusFilter_SelectedIndexChanged(object sender, EventArgs e)
        {
            statusFilter = ddlStatusFilter.SelectedValue;
            currentPage = 1;
            Session["CurrentPage"] = currentPage;
            LoadRedemptions();
        }

        protected void ddlMethodFilter_SelectedIndexChanged(object sender, EventArgs e)
        {
            methodFilter = ddlMethodFilter.SelectedValue;
            currentPage = 1;
            Session["CurrentPage"] = currentPage;
            LoadRedemptions();
        }

        protected void txtSearch_TextChanged(object sender, EventArgs e)
        {
            searchQuery = txtSearch.Text.Trim();
            currentPage = 1;
            Session["CurrentPage"] = currentPage;
            LoadRedemptions();
        }

        protected void btnApplyFilters_Click(object sender, EventArgs e)
        {
            // Get date values
            if (!string.IsNullOrEmpty(txtStartDate.Text))
            {
                try
                {
                    startDate = DateTime.Parse(txtStartDate.Text);
                }
                catch
                {
                    startDate = null;
                }
            }
            else
            {
                startDate = null;
            }

            if (!string.IsNullOrEmpty(txtEndDate.Text))
            {
                try
                {
                    endDate = DateTime.Parse(txtEndDate.Text);
                }
                catch
                {
                    endDate = null;
                }
            }
            else
            {
                endDate = null;
            }

            currentPage = 1;
            Session["CurrentPage"] = currentPage;
            LoadRedemptions();
        }

        protected void btnClearFilters_Click(object sender, EventArgs e)
        {
            // Reset all filters
            ddlStatusFilter.SelectedValue = "all";
            ddlMethodFilter.SelectedValue = "all";
            txtSearch.Text = "";

            // Reset dates to last 30 days
            endDate = DateTime.Now;
            startDate = DateTime.Now.AddDays(-30);
            txtStartDate.Text = startDate.Value.ToString("yyyy-MM-dd");
            txtEndDate.Text = endDate.Value.ToString("yyyy-MM-dd");

            statusFilter = "all";
            methodFilter = "all";
            searchQuery = "";
            currentPage = 1;

            LoadRedemptions();
        }

        protected void btnPrevPage_Click(object sender, EventArgs e)
        {
            if (currentPage > 1)
            {
                currentPage--;
                Session["CurrentPage"] = currentPage;
                LoadRedemptions();
            }
        }

        protected void btnNextPage_Click(object sender, EventArgs e)
        {
            int totalPages = (int)Math.Ceiling((double)totalItems / pageSize);
            if (currentPage < totalPages)
            {
                currentPage++;
                Session["CurrentPage"] = currentPage;
                LoadRedemptions();
            }
        }

        protected void btnPage_Click(object sender, EventArgs e)
        {
            LinkButton btn = (LinkButton)sender;
            currentPage = Convert.ToInt32(btn.CommandArgument);
            Session["CurrentPage"] = currentPage;
            LoadRedemptions();
        }

        protected void btnNewRedemption_Click(object sender, EventArgs e)
        {
            // Redirect to MyRewards page for new redemption
            Response.Redirect("~/Pages/Citizen/MyRewards.aspx");
        }

        protected void btnStartRedemption_Click(object sender, EventArgs e)
        {
            // Redirect to MyRewards page for new redemption
            Response.Redirect("~/Pages/Citizen/MyRewards.aspx");
        }

        protected void btnRefresh_Click(object sender, EventArgs e)
        {
            LoadRedemptionStats();
            LoadRedemptions();
            ShowMessage("Data refreshed successfully!", "success");
        }

        protected void btnExport_Click(object sender, EventArgs e)
        {
            ShowMessage("Export feature coming soon!", "info");
        }

        // Helper Methods
        public string FormatDate(object date)
        {
            if (date == DBNull.Value || date == null)
                return "N/A";

            DateTime dt = (DateTime)date;
            return dt.ToString("MMM dd, yyyy");
        }

        public string FormatTime(object date)
        {
            if (date == DBNull.Value || date == null)
                return "";

            DateTime dt = (DateTime)date;
            return dt.ToString("hh:mm tt");
        }

        public string FormatAmount(object amount)
        {
            if (amount == DBNull.Value || amount == null)
                return "0";

            decimal amt = Convert.ToDecimal(amount);
            return amt.ToString("N0") + " XP";
        }

        public string GetMethodIcon(string method)
        {
            switch (method.ToLower())
            {
                case "bank":
                case "bank transfer": return "fas fa-university";
                case "mobile":
                case "mobile money": return "fas fa-mobile-alt";
                case "voucher":
                case "e-voucher": return "fas fa-ticket-alt";
                case "gift":
                case "gift card": return "fas fa-gift";
                default: return "fas fa-exchange-alt";
            }
        }

        public bool CanCancel(string status)
        {
            // Only allow cancellation for pending or approved statuses
            return status.ToLower() == "pending" || status.ToLower() == "approved";
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