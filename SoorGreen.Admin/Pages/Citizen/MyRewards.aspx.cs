using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Collections.Generic;
using System.Drawing;

namespace SoorGreen.Admin
{
    public partial class MyRewards : System.Web.UI.Page
    {
        private string currentUserId;
        private string connectionString = System.Configuration.ConfigurationManager.ConnectionStrings["SoorGreenDBConnectionString"].ConnectionString;

        // Pagination variables
        private int currentPage = 1;
        private int pageSize = 10;
        private int totalItems = 0;

        // Filter variables
        private string typeFilter = "all";
        private string dateFilter = "month";
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
                LoadRewardStats();
                LoadRewards();
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

        // ADD THIS MISSING METHOD
        protected void btnEarnFirstReward_Click(object sender, EventArgs e)
        {
            // Redirect user to start earning rewards
            // You can change this to whatever page makes sense for your application

            // Option 1: Redirect to submit waste report page
            Response.Redirect("~/Pages/Citizen/SubmitReport.aspx");

            // Option 2: Redirect to tasks/rewards earning page
            // Response.Redirect("~/Pages/Citizen/Tasks.aspx");

            // Option 3: Show a modal or guide (if you have one)
            // ScriptManager.RegisterStartupScript(this, GetType(), "ShowEarnGuide", 
            //     "$('#earnGuideModal').modal('show');", true);
        }

        private void LoadRewardStats()
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    // Get total credits
                    string totalCreditsQuery = @"
                        SELECT ISNULL(SUM(Amount), 0) 
                        FROM RewardPoints 
                        WHERE UserId = @UserId";

                    using (SqlCommand cmd = new SqlCommand(totalCreditsQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@UserId", currentUserId);
                        decimal totalCredits = Convert.ToDecimal(cmd.ExecuteScalar());
                        statTotalCredits.InnerText = totalCredits.ToString("N0");
                    }

                    // Get available credits
                    string userQuery = "SELECT XP_Credits FROM Users WHERE UserId = @UserId";
                    using (SqlCommand cmd = new SqlCommand(userQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@UserId", currentUserId);
                        object result = cmd.ExecuteScalar();
                        decimal availableCredits = result != DBNull.Value ? Convert.ToDecimal(result) : 0;
                        statAvailableCredits.InnerText = availableCredits.ToString("N0");
                    }

                    // Get credits earned this month
                    string monthlyQuery = @"
                        SELECT ISNULL(SUM(Amount), 0) 
                        FROM RewardPoints 
                        WHERE UserId = @UserId 
                        AND MONTH(CreatedAt) = MONTH(GETDATE()) 
                        AND YEAR(CreatedAt) = YEAR(GETDATE())";

                    using (SqlCommand cmd = new SqlCommand(monthlyQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@UserId", currentUserId);
                        decimal monthlyCredits = Convert.ToDecimal(cmd.ExecuteScalar());
                        statMonthlyCredits.InnerText = monthlyCredits.ToString("N0");
                    }

                    // Get pending redemptions
                    string pendingQuery = @"
                        SELECT ISNULL(SUM(Amount), 0) 
                        FROM RedemptionRequests 
                        WHERE UserId = @UserId AND Status = 'Pending'";

                    using (SqlCommand cmd = new SqlCommand(pendingQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@UserId", currentUserId);
                        decimal pendingRedemptions = Convert.ToDecimal(cmd.ExecuteScalar());
                        statPendingRedemptions.InnerText = pendingRedemptions.ToString("N0");
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("LoadRewardStats Error: " + ex.Message);
            }
        }

        private void LoadRewards()
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    // Build query with filters
                    string query = BuildRewardQuery();

                    // First, get total count for pagination
                    string countQuery = "SELECT COUNT(*) FROM (" + query + ") AS SubQuery";
                    using (SqlCommand countCmd = new SqlCommand(countQuery, conn))
                    {
                        AddQueryParameters(countCmd);
                        totalItems = Convert.ToInt32(countCmd.ExecuteScalar());
                    }

                    // Now get paginated data
                    query = "SELECT * FROM (" + query + ") AS FilteredRewards ORDER BY CreatedDate DESC OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY";

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
                                rptRewards.DataSource = dt;
                                rptRewards.DataBind();
                                pnlRewardCards.Visible = true;
                                pnlEmptyState.Visible = false;
                            }
                            else
                            {
                                pnlRewardCards.Visible = false;
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
                System.Diagnostics.Debug.WriteLine("LoadRewards Error: " + ex.Message);
                pnlRewardCards.Visible = false;
                pnlEmptyState.Visible = true;
            }
        }

        private void LoadRedemptions()
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    string query = @"
                        SELECT RedemptionId, Amount, Method, Status, RequestedAt, ProcessedAt
                        FROM RedemptionRequests 
                        WHERE UserId = @UserId 
                        ORDER BY RequestedAt DESC";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@UserId", currentUserId);

                        using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                        {
                            DataTable dt = new DataTable();
                            da.Fill(dt);

                            if (dt.Rows.Count > 0)
                            {
                                rptRedemptions.DataSource = dt;
                                rptRedemptions.DataBind();
                                pnlRedemptions.Visible = true;
                            }
                            else
                            {
                                pnlRedemptions.Visible = false;
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("LoadRedemptions Error: " + ex.Message);
                pnlRedemptions.Visible = false;
            }
        }

        private string BuildRewardQuery()
        {
            string baseQuery = @"
                SELECT 
                    RewardId,
                    Amount,
                    Type,
                    Reference,
                    CreatedAt as CreatedDate,
                    CASE 
                        WHEN Type LIKE '%pickup%' THEN 'Pickup'
                        WHEN Type LIKE '%report%' THEN 'Report'
                        WHEN Type LIKE '%referral%' THEN 'Referral'
                        WHEN Type LIKE '%bonus%' THEN 'Bonus'
                        WHEN Type LIKE '%credit%' THEN 'Credit'
                        ELSE 'Other'
                    END as TypeCategory
                FROM RewardPoints 
                WHERE UserId = @UserId";

            // Apply type filter
            if (!string.IsNullOrEmpty(typeFilter) && typeFilter != "all")
            {
                if (typeFilter == "pickup")
                {
                    baseQuery += " AND Type LIKE '%pickup%'";
                }
                else if (typeFilter == "report")
                {
                    baseQuery += " AND Type LIKE '%report%'";
                }
                else if (typeFilter == "referral")
                {
                    baseQuery += " AND Type LIKE '%referral%'";
                }
                else if (typeFilter == "bonus")
                {
                    baseQuery += " AND Type LIKE '%bonus%'";
                }
            }

            // Apply date filter
            if (!string.IsNullOrEmpty(dateFilter))
            {
                switch (dateFilter)
                {
                    case "today":
                        baseQuery += " AND CAST(CreatedAt AS DATE) = CAST(GETDATE() AS DATE)";
                        break;
                    case "week":
                        baseQuery += " AND CreatedAt >= DATEADD(DAY, -7, GETDATE())";
                        break;
                    case "month":
                        baseQuery += " AND CreatedAt >= DATEADD(MONTH, -1, GETDATE())";
                        break;
                    case "year":
                        baseQuery += " AND CreatedAt >= DATEADD(YEAR, -1, GETDATE())";
                        break;
                }
            }

            // Apply search filter
            if (!string.IsNullOrEmpty(searchQuery))
            {
                baseQuery += " AND (RewardId LIKE @SearchQuery OR Reference LIKE @SearchQuery OR Type LIKE @SearchQuery)";
            }

            return baseQuery;
        }

        private void AddQueryParameters(SqlCommand cmd)
        {
            cmd.Parameters.AddWithValue("@UserId", currentUserId);

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

        protected void ddlTypeFilter_SelectedIndexChanged(object sender, EventArgs e)
        {
            typeFilter = ddlTypeFilter.SelectedValue;
            currentPage = 1;
            Session["CurrentPage"] = currentPage;
            LoadRewards();
        }

        protected void ddlDateFilter_SelectedIndexChanged(object sender, EventArgs e)
        {
            dateFilter = ddlDateFilter.SelectedValue;
            currentPage = 1;
            Session["CurrentPage"] = currentPage;
            LoadRewards();
        }

        protected void txtSearch_TextChanged(object sender, EventArgs e)
        {
            searchQuery = txtSearch.Text.Trim();
            currentPage = 1;
            Session["CurrentPage"] = currentPage;
            LoadRewards();
        }

        protected void btnPrevPage_Click(object sender, EventArgs e)
        {
            if (currentPage > 1)
            {
                currentPage--;
                Session["CurrentPage"] = currentPage;
                LoadRewards();
            }
        }

        protected void btnNextPage_Click(object sender, EventArgs e)
        {
            int totalPages = (int)Math.Ceiling((double)totalItems / pageSize);
            if (currentPage < totalPages)
            {
                currentPage++;
                Session["CurrentPage"] = currentPage;
                LoadRewards();
            }
        }

        protected void btnPage_Click(object sender, EventArgs e)
        {
            LinkButton btn = (LinkButton)sender;
            currentPage = Convert.ToInt32(btn.CommandArgument);
            Session["CurrentPage"] = currentPage;
            LoadRewards();
        }

        protected void btnRedeem_Click(object sender, EventArgs e)
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    // Get available credits
                    string userQuery = "SELECT XP_Credits FROM Users WHERE UserId = @UserId";
                    decimal availableCredits = 0;

                    using (SqlCommand cmd = new SqlCommand(userQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@UserId", currentUserId);
                        object result = cmd.ExecuteScalar();
                        availableCredits = result != DBNull.Value ? Convert.ToDecimal(result) : 0;
                    }

                    if (availableCredits < 100)
                    {
                        ShowMessage("Minimum redemption amount is 100 XP. You have " + availableCredits + " XP available.", "warning");
                        return;
                    }

                    // Get redemption method and amount
                    string redemptionMethod = ddlRedemptionMethod.SelectedValue;
                    decimal redemptionAmount = Convert.ToDecimal(txtRedemptionAmount.Text);

                    if (redemptionAmount < 100)
                    {
                        ShowMessage("Minimum redemption amount is 100 XP.", "warning");
                        return;
                    }

                    if (redemptionAmount > availableCredits)
                    {
                        ShowMessage("Insufficient credits. You have " + availableCredits + " XP available.", "error");
                        return;
                    }

                    // Generate redemption ID
                    string redemptionId = "RD" + DateTime.Now.ToString("MMddHHmmss");

                    // Insert redemption request
                    string insertQuery = @"
                        INSERT INTO RedemptionRequests (RedemptionId, UserId, Amount, Method, Status, RequestedAt)
                        VALUES (@RedemptionId, @UserId, @Amount, @Method, 'Pending', GETDATE())";

                    using (SqlCommand cmd = new SqlCommand(insertQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@RedemptionId", redemptionId);
                        cmd.Parameters.AddWithValue("@UserId", currentUserId);
                        cmd.Parameters.AddWithValue("@Amount", redemptionAmount);
                        cmd.Parameters.AddWithValue("@Method", redemptionMethod);

                        cmd.ExecuteNonQuery();
                    }

                    // Update user credits (deduct)
                    string updateQuery = "UPDATE Users SET XP_Credits = XP_Credits - @Amount WHERE UserId = @UserId";

                    using (SqlCommand cmd = new SqlCommand(updateQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@UserId", currentUserId);
                        cmd.Parameters.AddWithValue("@Amount", redemptionAmount);
                        cmd.ExecuteNonQuery();
                    }

                    ShowMessage("Redemption request submitted successfully! Redemption ID: " + redemptionId, "success");

                    // Refresh data
                    LoadRewardStats();
                    LoadRewards();
                    LoadRedemptions();

                    // Reset form
                    txtRedemptionAmount.Text = "100";
                    ddlRedemptionMethod.SelectedIndex = 0;

                    // Close modal
                    ScriptManager.RegisterStartupScript(this, GetType(), "CloseModal", "$('#redeemModal').modal('hide');", true);
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Error submitting redemption: " + ex.Message, "error");
            }
        }

        protected void btnRefresh_Click(object sender, EventArgs e)
        {
            LoadRewardStats();
            LoadRewards();
            LoadRedemptions();
            ShowMessage("Data refreshed successfully!", "success");
        }

        protected void btnExportRewards_Click(object sender, EventArgs e)
        {
            ShowMessage("Export feature coming soon!", "info");
        }

        protected void btnViewAll_Click(object sender, EventArgs e)
        {
            // Reset filters to show all
            ddlTypeFilter.SelectedValue = "all";
            ddlDateFilter.SelectedValue = "all";
            txtSearch.Text = "";

            typeFilter = "all";
            dateFilter = "all";
            searchQuery = "";
            currentPage = 1;

            LoadRewards();
        }

        public string GetTypeIcon(string type)
        {
            switch (type.ToLower())
            {
                case "pickup":
                case "credit": return "fas fa-truck-loading";
                case "report": return "fas fa-file-alt";
                case "referral": return "fas fa-user-friends";
                case "bonus": return "fas fa-gift";
                case "reward": return "fas fa-trophy";
                default: return "fas fa-coins";
            }
        }

        public string GetTypeColor(string type)
        {
            switch (type.ToLower())
            {
                case "pickup":
                case "credit": return "success";
                case "report": return "info";
                case "referral": return "primary";
                case "bonus": return "warning";
                case "reward": return "danger";
                default: return "secondary";
            }
        }

        public string GetRedemptionStatusIcon(string status)
        {
            switch (status.ToLower())
            {
                case "pending": return "fas fa-clock";
                case "approved": return "fas fa-check-circle";
                case "processing": return "fas fa-cog";
                case "completed": return "fas fa-check-double";
                case "rejected": return "fas fa-times-circle";
                default: return "fas fa-question-circle";
            }
        }

        public string GetRedemptionStatusColor(string status)
        {
            switch (status.ToLower())
            {
                case "pending": return "warning";
                case "approved": return "info";
                case "processing": return "primary";
                case "completed": return "success";
                case "rejected": return "danger";
                default: return "secondary";
            }
        }

        public string FormatDateTime(object date)
        {
            if (date == DBNull.Value || date == null)
                return "N/A";

            DateTime dt = (DateTime)date;
            return dt.ToString("MMM dd, yyyy HH:mm");
        }

        public string FormatAmount(object amount)
        {
            if (amount == DBNull.Value || amount == null)
                return "0";

            decimal amt = Convert.ToDecimal(amount);
            return amt.ToString("N0") + " XP";
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