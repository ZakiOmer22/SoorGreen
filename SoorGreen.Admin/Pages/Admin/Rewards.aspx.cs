using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Runtime.Remoting.Messaging;
using System.Web.Configuration;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace SoorGreen.Admin.Admin
{
    public partial class Rewards : System.Web.UI.Page
    {
        private string connectionString = WebConfigurationManager.ConnectionStrings["SoorGreenDBConnectionString"].ConnectionString;
        private string currentView = "credits";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                BindUserDropdown();
                currentView = ddlView.SelectedValue;
                UpdateViewIcon();
                BindData();
            }

            // Handle events from JavaScript
            if (Request["__EVENTTARGET"] == "ctl00$MainContent$hdnRedemptionId")
            {
                string eventArg = Request["__EVENTARGUMENT"];
                if (eventArg.StartsWith("process_"))
                {
                    string redemptionId = eventArg.Substring(8);
                    LoadRedemptionForProcessing(redemptionId);
                }
            }
            else if (Request["__EVENTTARGET"] == "ctl00$MainContent$btnReverseTransaction")
            {
                string rewardId = Request["__EVENTARGUMENT"];
                ReverseTransaction(rewardId);
            }
        }

        private void BindUserDropdown()
        {
            string query = "SELECT UserId, FullName FROM Users WHERE XP_Credits > 0 ORDER BY FullName";
            ddlUser.DataSource = GetDataTable(query);
            ddlUser.DataTextField = "FullName";
            ddlUser.DataValueField = "UserId";
            ddlUser.DataBind();
            ddlUser.Items.Insert(0, new ListItem("-- Select User --", ""));
        }

        private void BindData()
        {
            currentView = ddlView.SelectedValue;

            switch (currentView)
            {
                case "credits":
                    BindCreditsData();
                    break;
                case "redemptions":
                    BindRedemptionsData();
                    break;
                case "users":
                    BindUsersData();
                    break;
            }

            UpdateStats();
            UpdateViewIcon();
        }

        private void BindCreditsData()
        {
            try
            {
                string query = @"SELECT 
                                rp.RewardId,
                                rp.Amount,
                                rp.Type,
                                rp.Reference,
                                rp.CreatedAt,
                                u.UserId,
                                u.FullName as UserName,
                                u.Phone as UserPhone,
                                u.XP_Credits as UserBalance
                                FROM RewardPoints rp
                                JOIN Users u ON rp.UserId = u.UserId
                                WHERE 1=1";

                List<SqlParameter> parameters = new List<SqlParameter>();

                // Apply search filter
                if (!string.IsNullOrEmpty(txtSearch.Text))
                {
                    query += " AND (u.FullName LIKE @search OR rp.Reference LIKE @search OR rp.RewardId LIKE @search)";
                    parameters.Add(new SqlParameter("@search", "%" + txtSearch.Text + "%"));
                }

                // Apply date filter
                if (ddlDateFilter.SelectedValue != "all")
                {
                    switch (ddlDateFilter.SelectedValue)
                    {
                        case "today":
                            query += " AND CONVERT(DATE, rp.CreatedAt) = CONVERT(DATE, GETDATE())";
                            break;
                        case "week":
                            query += " AND rp.CreatedAt >= DATEADD(DAY, -7, GETDATE())";
                            break;
                        case "month":
                            query += " AND rp.CreatedAt >= DATEADD(MONTH, -1, GETDATE())";
                            break;
                        case "year":
                            query += " AND rp.CreatedAt >= DATEADD(YEAR, -1, GETDATE())";
                            break;
                    }
                }

                query += " ORDER BY rp.CreatedAt DESC";

                DataTable dt = GetDataTable(query, parameters.ToArray());

                // Bind to repeater for card view
                rptCreditsGrid.DataSource = dt;
                rptCreditsGrid.DataBind();

                // Bind to gridview for table view
                gvCredits.DataSource = dt;
                gvCredits.DataBind();

                lblRecordCount.Text = dt.Rows.Count.ToString();

                if (dt.Rows.Count == 0)
                {
                    ShowMessage("Info", "No credit transactions found.", "info");
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Error", "Failed to load credit transactions: " + ex.Message, "error");
            }
        }

        private void BindRedemptionsData()
        {
            try
            {
                string query = @"SELECT 
                                rr.RedemptionId,
                                rr.Amount,
                                rr.Method,
                                rr.Status,
                                rr.RequestedAt,
                                rr.ProcessedAt,
                                u.UserId,
                                u.FullName as UserName,
                                u.Phone as UserPhone,
                                u.XP_Credits as UserBalance
                                FROM RedemptionRequests rr
                                JOIN Users u ON rr.UserId = u.UserId
                                WHERE 1=1";

                List<SqlParameter> parameters = new List<SqlParameter>();

                // Apply search filter
                if (!string.IsNullOrEmpty(txtSearch.Text))
                {
                    query += " AND (u.FullName LIKE @search OR rr.RedemptionId LIKE @search)";
                    parameters.Add(new SqlParameter("@search", "%" + txtSearch.Text + "%"));
                }

                // Filter by status for redemptions
                query += " AND rr.Status = @status";
                parameters.Add(new SqlParameter("@status", "Pending"));

                // Apply date filter
                if (ddlDateFilter.SelectedValue != "all")
                {
                    switch (ddlDateFilter.SelectedValue)
                    {
                        case "today":
                            query += " AND CONVERT(DATE, rr.RequestedAt) = CONVERT(DATE, GETDATE())";
                            break;
                        case "week":
                            query += " AND rr.RequestedAt >= DATEADD(DAY, -7, GETDATE())";
                            break;
                        case "month":
                            query += " AND rr.RequestedAt >= DATEADD(MONTH, -1, GETDATE())";
                            break;
                        case "year":
                            query += " AND rr.RequestedAt >= DATEADD(YEAR, -1, GETDATE())";
                            break;
                    }
                }

                query += " ORDER BY rr.RequestedAt DESC";

                DataTable dt = GetDataTable(query, parameters.ToArray());

                // Bind to repeater for card view
                rptRedemptionsGrid.DataSource = dt;
                rptRedemptionsGrid.DataBind();

                // Bind to gridview for table view
                gvRedemptions.DataSource = dt;
                gvRedemptions.DataBind();

                lblRecordCount.Text = dt.Rows.Count.ToString();

                if (dt.Rows.Count == 0)
                {
                    ShowMessage("Info", "No redemption requests found.", "info");
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Error", "Failed to load redemption requests: " + ex.Message, "error");
            }
        }

        private void BindUsersData()
        {
            try
            {
                string query = @"SELECT 
                                u.UserId,
                                u.FullName,
                                u.Phone,
                                u.XP_Credits,
                                u.CreatedAt,
                                r.RoleName,
                                ISNULL((SELECT SUM(Amount) FROM RewardPoints WHERE UserId = u.UserId AND Amount > 0), 0) as TotalEarned,
                                ISNULL((SELECT SUM(Amount) FROM RewardPoints WHERE UserId = u.UserId AND Amount < 0), 0) as TotalRedeemed,
                                (SELECT COUNT(*) FROM RewardPoints WHERE UserId = u.UserId) as TotalTransactions,
                                (SELECT COUNT(*) FROM RedemptionRequests WHERE UserId = u.UserId) as TotalRedemptions
                                FROM Users u
                                JOIN Roles r ON u.RoleId = r.RoleId
                                WHERE u.XP_Credits > 0";

                List<SqlParameter> parameters = new List<SqlParameter>();

                // Apply search filter
                if (!string.IsNullOrEmpty(txtSearch.Text))
                {
                    query += " AND (u.FullName LIKE @search OR u.Phone LIKE @search)";
                    parameters.Add(new SqlParameter("@search", "%" + txtSearch.Text + "%"));
                }

                // Apply date filter
                if (ddlDateFilter.SelectedValue != "all")
                {
                    switch (ddlDateFilter.SelectedValue)
                    {
                        case "today":
                            query += " AND CONVERT(DATE, u.CreatedAt) = CONVERT(DATE, GETDATE())";
                            break;
                        case "week":
                            query += " AND u.CreatedAt >= DATEADD(DAY, -7, GETDATE())";
                            break;
                        case "month":
                            query += " AND u.CreatedAt >= DATEADD(MONTH, -1, GETDATE())";
                            break;
                        case "year":
                            query += " AND u.CreatedAt >= DATEADD(YEAR, -1, GETDATE())";
                            break;
                    }
                }

                query += " ORDER BY u.XP_Credits DESC";

                DataTable dt = GetDataTable(query, parameters.ToArray());

                // Bind to repeater for card view
                rptUsersGrid.DataSource = dt;
                rptUsersGrid.DataBind();

                // Bind to gridview for table view
                gvUsers.DataSource = dt;
                gvUsers.DataBind();

                lblRecordCount.Text = dt.Rows.Count.ToString();

                if (dt.Rows.Count == 0)
                {
                    ShowMessage("Info", "No users with credits found.", "info");
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Error", "Failed to load users data: " + ex.Message, "error");
            }
        }

        private void UpdateStats()
        {
            try
            {
                // Total credits issued
                string creditsQuery = "SELECT ISNULL(SUM(Amount), 0) FROM RewardPoints WHERE Amount > 0";
                decimal totalCredits = GetScalarDecimal(creditsQuery);
                statTotalCredits.InnerText = "$" + totalCredits.ToString("N2");

                // Users with credits
                string usersQuery = "SELECT COUNT(*) FROM Users WHERE XP_Credits > 0";
                int activeUsers = GetScalarInt(usersQuery);
                statActiveUsers.InnerText = activeUsers.ToString();

                // Pending redemptions
                string pendingQuery = "SELECT COUNT(*) FROM RedemptionRequests WHERE Status = 'Pending'";
                int pendingRedemptions = GetScalarInt(pendingQuery);
                statPendingRedemptions.InnerText = pendingRedemptions.ToString();

                // Total redeemed
                string redeemedQuery = "SELECT ISNULL(SUM(Amount), 0) FROM RedemptionRequests WHERE Status = 'Approved'";
                decimal totalRedeemed = GetScalarDecimal(redeemedQuery);
                statTotalRedeemed.InnerText = "$" + totalRedeemed.ToString("N2");

                // Summary stats
                summaryEarned.InnerText = "$" + totalCredits.ToString("N2");
                summaryRedeemed.InnerText = "$" + totalRedeemed.ToString("N2");

                // Pending redemptions amount
                string pendingAmountQuery = "SELECT ISNULL(SUM(Amount), 0) FROM RedemptionRequests WHERE Status = 'Pending'";
                decimal pendingAmount = GetScalarDecimal(pendingAmountQuery);
                summaryPending.InnerText = "$" + pendingAmount.ToString("N2");

                // Available credits (total earned - total approved redemptions)
                decimal availableCredits = totalCredits - totalRedeemed - pendingAmount;
                summaryAvailable.InnerText = "$" + availableCredits.ToString("N2");
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error updating stats: " + ex.Message);
            }
        }

        private void UpdateViewIcon()
        {
            switch (currentView)
            {
                case "credits":
                    viewIcon.Attributes["class"] = "fas fa-coins me-2";
                    break;
                case "redemptions":
                    viewIcon.Attributes["class"] = "fas fa-money-check-alt me-2";
                    break;
                case "users":
                    viewIcon.Attributes["class"] = "fas fa-users me-2";
                    break;
            }
        }

        private DataTable GetDataTable(string query, SqlParameter[] parameters = null)
        {
            DataTable dt = new DataTable();

            using (SqlConnection conn = new SqlConnection(connectionString))
            using (SqlCommand cmd = new SqlCommand(query, conn))
            {
                if (parameters != null)
                {
                    cmd.Parameters.AddRange(parameters);
                }

                conn.Open();
                using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                {
                    da.Fill(dt);
                }
            }

            return dt;
        }

        private decimal GetScalarDecimal(string query)
        {
            using (SqlConnection conn = new SqlConnection(connectionString))
            using (SqlCommand cmd = new SqlCommand(query, conn))
            {
                conn.Open();
                object result = cmd.ExecuteScalar();
                return result != DBNull.Value ? Convert.ToDecimal(result) : 0;
            }
        }

        private int GetScalarInt(string query)
        {
            using (SqlConnection conn = new SqlConnection(connectionString))
            using (SqlCommand cmd = new SqlCommand(query, conn))
            {
                conn.Open();
                object result = cmd.ExecuteScalar();
                return result != DBNull.Value ? Convert.ToInt32(result) : 0;
            }
        }

        // CRUD Operations
        protected void btnAddCredits_Click(object sender, EventArgs e)
        {
            try
            {
                string userId = ddlUser.SelectedValue;
                decimal amount = decimal.Parse(txtAmount.Text);
                string type = ddlCreditType.SelectedValue;
                string reference = txtReference.Text;

                if (string.IsNullOrEmpty(userId))
                {
                    ShowMessage("Error", "Please select a user.", "error");
                    return;
                }

                // Generate reward ID
                string rewardId = GetNextRewardId();

                // Insert reward points
                string query = @"INSERT INTO RewardPoints 
                                (RewardId, UserId, Amount, Type, Reference, CreatedAt)
                                VALUES (@RewardId, @UserId, @Amount, @Type, @Reference, GETDATE())";

                using (SqlConnection conn = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@RewardId", rewardId);
                    cmd.Parameters.AddWithValue("@UserId", userId);
                    cmd.Parameters.AddWithValue("@Amount", amount);
                    cmd.Parameters.AddWithValue("@Type", type);
                    cmd.Parameters.AddWithValue("@Reference", string.IsNullOrEmpty(reference) ? DBNull.Value : (object)reference);

                    conn.Open();
                    cmd.ExecuteNonQuery();
                }

                // Update user's XP_Credits (trigger should handle this, but we'll do it manually too)
                string updateUserQuery = @"UPDATE Users 
                                          SET XP_Credits = XP_Credits + @Amount 
                                          WHERE UserId = @UserId";

                using (SqlConnection conn = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand(updateUserQuery, conn))
                {
                    cmd.Parameters.AddWithValue("@UserId", userId);
                    cmd.Parameters.AddWithValue("@Amount", amount);

                    conn.Open();
                    cmd.ExecuteNonQuery();
                }

                ShowMessage("Success", "Credits added successfully!", "success");
                BindUserDropdown(); // Refresh dropdown
                BindData(); // Refresh current view

                // Close modal via JavaScript
                ScriptManager.RegisterStartupScript(this, this.GetType(), "CloseModal",
                    "$('#addCreditModal').modal('hide');", true);
            }
            catch (Exception ex)
            {
                ShowMessage("Error", "Failed to add credits: " + ex.Message, "error");
            }
        }

        private void LoadRedemptionForProcessing(string redemptionId)
        {
            string query = @"SELECT 
                            rr.RedemptionId,
                            rr.Amount,
                            rr.Method,
                            rr.Status,
                            rr.RequestedAt,
                            u.FullName as UserName,
                            u.XP_Credits as UserBalance
                            FROM RedemptionRequests rr
                            JOIN Users u ON rr.UserId = u.UserId
                            WHERE rr.RedemptionId = @RedemptionId";

            using (SqlConnection conn = new SqlConnection(connectionString))
            using (SqlCommand cmd = new SqlCommand(query, conn))
            {
                cmd.Parameters.AddWithValue("@RedemptionId", redemptionId);
                conn.Open();

                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    if (reader.Read())
                    {
                        hdnRedemptionId.Value = reader["RedemptionId"].ToString();
                        txtRedemptionId.Text = reader["RedemptionId"].ToString();
                        txtRedemptionUser.Text = reader["UserName"].ToString();
                        txtRedemptionAmount.Text = reader["Amount"].ToString();
                        txtPaymentMethod.Text = reader["Method"].ToString();
                    }
                }
            }

            // Show modal via JavaScript
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ShowRedemptionModal",
                "var modal = new bootstrap.Modal(document.getElementById('processRedemptionModal')); modal.show();", true);
        }

        protected void btnApproveRedemption_Click(object sender, EventArgs e)
        {
            try
            {
                string redemptionId = hdnRedemptionId.Value;
                string paymentDetails = txtPaymentDetails.Text;
                string adminNotes = txtAdminNotes.Text;

                // Update redemption status
                string query = @"UPDATE RedemptionRequests 
                                SET Status = 'Approved', 
                                    ProcessedAt = GETDATE()
                                WHERE RedemptionId = @RedemptionId";

                using (SqlConnection conn = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@RedemptionId", redemptionId);
                    conn.Open();
                    cmd.ExecuteNonQuery();
                }

                // Create a negative reward entry to deduct credits
                string rewardId = GetNextRewardId();

                // Get user ID and amount from redemption
                string redemptionQuery = @"SELECT UserId, Amount FROM RedemptionRequests WHERE RedemptionId = @RedemptionId";
                string userId = "";
                decimal amount = 0;

                using (SqlConnection conn = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand(redemptionQuery, conn))
                {
                    cmd.Parameters.AddWithValue("@RedemptionId", redemptionId);
                    conn.Open();

                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            userId = reader["UserId"].ToString();
                            amount = Convert.ToDecimal(reader["Amount"]);
                        }
                    }
                }

                // Insert negative reward for redemption
                string negativeRewardQuery = @"INSERT INTO RewardPoints 
                                              (RewardId, UserId, Amount, Type, Reference, CreatedAt)
                                              VALUES (@RewardId, @UserId, @Amount, 'Redemption', @Reference, GETDATE())";

                using (SqlConnection conn = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand(negativeRewardQuery, conn))
                {
                    cmd.Parameters.AddWithValue("@RewardId", rewardId);
                    cmd.Parameters.AddWithValue("@UserId", userId);
                    cmd.Parameters.AddWithValue("@Amount", -amount); // Negative amount
                    cmd.Parameters.AddWithValue("@Reference", "Redemption processed: " + redemptionId);

                    conn.Open();
                    cmd.ExecuteNonQuery();
                }

                ShowMessage("Success", "Redemption approved and processed successfully!", "success");
                BindData(); // Refresh current view

                // Close modal via JavaScript
                ScriptManager.RegisterStartupScript(this, this.GetType(), "CloseModal",
                    "$('#processRedemptionModal').modal('hide');", true);
            }
            catch (Exception ex)
            {
                ShowMessage("Error", "Failed to approve redemption: " + ex.Message, "error");
            }
        }

        protected void btnRejectRedemption_Click(object sender, EventArgs e)
        {
            try
            {
                string redemptionId = hdnRedemptionId.Value;

                // Update redemption status to rejected
                string query = @"UPDATE RedemptionRequests 
                                SET Status = 'Rejected', 
                                    ProcessedAt = GETDATE()
                                WHERE RedemptionId = @RedemptionId";

                using (SqlConnection conn = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@RedemptionId", redemptionId);
                    conn.Open();
                    cmd.ExecuteNonQuery();
                }

                ShowMessage("Success", "Redemption request rejected.", "success");
                BindData(); // Refresh current view

                // Close modal via JavaScript
                ScriptManager.RegisterStartupScript(this, this.GetType(), "CloseModal",
                    "$('#processRedemptionModal').modal('hide');", true);
            }
            catch (Exception ex)
            {
                ShowMessage("Error", "Failed to reject redemption: " + ex.Message, "error");
            }
        }

        private void ReverseTransaction(string rewardId)
        {
            try
            {
                // Get transaction details
                string getQuery = @"SELECT UserId, Amount FROM RewardPoints WHERE RewardId = @RewardId";
                string userId = "";
                decimal amount = 0;

                using (SqlConnection conn = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand(getQuery, conn))
                {
                    cmd.Parameters.AddWithValue("@RewardId", rewardId);
                    conn.Open();

                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            userId = reader["UserId"].ToString();
                            amount = Convert.ToDecimal(reader["Amount"]);
                        }
                    }
                }

                // Insert reverse transaction
                string reverseId = GetNextRewardId();
                string reverseQuery = @"INSERT INTO RewardPoints 
                                       (RewardId, UserId, Amount, Type, Reference, CreatedAt)
                                       VALUES (@RewardId, @UserId, @Amount, 'Reversal', @Reference, GETDATE())";

                using (SqlConnection conn = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand(reverseQuery, conn))
                {
                    cmd.Parameters.AddWithValue("@RewardId", reverseId);
                    cmd.Parameters.AddWithValue("@UserId", userId);
                    cmd.Parameters.AddWithValue("@Amount", -amount); // Reverse the amount
                    cmd.Parameters.AddWithValue("@Reference", "Reversal of transaction: " + rewardId);

                    conn.Open();
                    cmd.ExecuteNonQuery();
                }

                ShowMessage("Success", "Transaction reversed successfully!", "success");
                BindData(); // Refresh current view
            }
            catch (Exception ex)
            {
                ShowMessage("Error", "Failed to reverse transaction: " + ex.Message, "error");
            }
        }

        private string GetNextRewardId()
        {
            string query = "SELECT ISNULL(MAX(CAST(SUBSTRING(RewardId, 3, LEN(RewardId)) AS INT)), 0) + 1 FROM RewardPoints WHERE RewardId LIKE 'RP%'";

            using (SqlConnection conn = new SqlConnection(connectionString))
            using (SqlCommand cmd = new SqlCommand(query, conn))
            {
                conn.Open();
                int nextId = (int)cmd.ExecuteScalar();
                return "RP" + nextId.ToString("D2");
            }
        }

        // UI Helper Methods
        public string GetTransactionBadgeClass(string type)
        {
            switch (type.ToLower())
            {
                case "credit":
                    return "badge-success";
                case "bonus":
                    return "badge-info";
                case "penalty":
                    return "badge-danger";
                case "adjustment":
                    return "badge-warning";
                case "referral":
                    return "badge-primary";
                default:
                    return "badge-secondary";
            }
        }

        public string GetAmountColor(decimal amount)
        {
            if (amount > 0)
                return "text-success";
            else if (amount < 0)
                return "text-danger";
            else
                return "text-muted";
        }

        public string GetAmountIcon(decimal amount)
        {
            if (amount > 0)
                return "fa-arrow-up text-success";
            else if (amount < 0)
                return "fa-arrow-down text-danger";
            else
                return "fa-minus text-muted";
        }

        public string GetAmountDisplay(decimal amount)
        {
            if (amount >= 0)
                return "$" + amount.ToString("N2");
            else
                return "-$" + Math.Abs(amount).ToString("N2");
        }

        public string GetRedemptionStatusBadge(string status)
        {
            switch (status.ToLower())
            {
                case "pending":
                    return "badge-warning";
                case "approved":
                    return "badge-success";
                case "rejected":
                    return "badge-danger";
                default:
                    return "badge-secondary";
            }
        }

        public string GetRedemptionStatusClass(string status)
        {
            switch (status.ToLower())
            {
                case "pending":
                    return "status-pending";
                case "approved":
                    return "status-completed";
                case "rejected":
                    return "status-cancelled";
                default:
                    return "status-pending";
            }
        }

        public string GetRedemptionStatusColor(string status)
        {
            switch (status.ToLower())
            {
                case "pending":
                    return "text-warning";
                case "approved":
                    return "text-success";
                case "rejected":
                    return "text-danger";
                default:
                    return "text-warning";
            }
        }

        public string GetUserRoleBadge(string roleName)
        {
            switch (roleName.ToLower())
            {
                case "citizen":
                    return "badge-primary";
                case "collector":
                    return "badge-info";
                case "admin":
                    return "badge-danger";
                case "company":
                    return "badge-warning";
                default:
                    return "badge-secondary";
            }
        }

        public string GetBalanceColor(decimal balance)
        {
            if (balance > 100)
                return "text-success";
            else if (balance > 0)
                return "text-warning";
            else
                return "text-muted";
        }

        public string GetReverseButton(string rewardId, decimal amount)
        {
            if (amount > 0) // Only allow reversing positive amounts
            {
                return string.Format(
                    "<button type='button' class='btn btn-danger' onclick='reverseTransaction(\"{0}\")'>" +
                    "<i class='fas fa-undo me-1'></i>Reverse</button>",
                    rewardId);
            }
            return string.Empty;
        }

        // Event Handlers
        protected void ddlView_SelectedIndexChanged(object sender, EventArgs e)
        {
            currentView = ddlView.SelectedValue;

            // Show/hide appropriate panels
            pnlCreditsView.Visible = (currentView == "credits");
            pnlRedemptionsView.Visible = (currentView == "redemptions");
            pnlUsersView.Visible = (currentView == "users");

            BindData();
        }

        protected void btnApplyFilters_Click(object sender, EventArgs e)
        {
            BindData();
        }

        protected void btnClearFilters_Click(object sender, EventArgs e)
        {
            txtSearch.Text = "";
            ddlDateFilter.SelectedValue = "all";
            BindData();
        }

        protected void btnRefresh_Click(object sender, EventArgs e)
        {
            BindData();
        }

        protected void btnCardView_Click(object sender, EventArgs e)
        {
            SetCardView();
        }

        protected void btnTableView_Click(object sender, EventArgs e)
        {
            SetTableView();
        }

        private void SetCardView()
        {
            btnCardView.CssClass = "view-btn active";
            btnTableView.CssClass = "view-btn";

            switch (currentView)
            {
                case "credits":
                    pnlCreditsCardView.Visible = true;
                    pnlCreditsTableView.Visible = false;
                    break;
                case "redemptions":
                    pnlRedemptionsCardView.Visible = true;
                    pnlRedemptionsTableView.Visible = false;
                    break;
                case "users":
                    pnlUsersCardView.Visible = true;
                    pnlUsersTableView.Visible = false;
                    break;
            }
        }

        private void SetTableView()
        {
            btnCardView.CssClass = "view-btn";
            btnTableView.CssClass = "view-btn active";

            switch (currentView)
            {
                case "credits":
                    pnlCreditsCardView.Visible = false;
                    pnlCreditsTableView.Visible = true;
                    break;
                case "redemptions":
                    pnlRedemptionsCardView.Visible = false;
                    pnlRedemptionsTableView.Visible = true;
                    break;
                case "users":
                    pnlUsersCardView.Visible = false;
                    pnlUsersTableView.Visible = true;
                    break;
            }
        }

        protected void btnExportCSV_Click(object sender, EventArgs e)
        {
            try
            {
                Response.Clear();
                Response.Buffer = true;
                Response.AddHeader("content-disposition", "attachment;filename=Rewards_Export_" + DateTime.Now.ToString("yyyyMMdd") + ".csv");
                Response.Charset = "";
                Response.ContentType = "application/text";

                DataTable dt = GetExportData();
                string csv = ConvertDataTableToCSV(dt);
                Response.Output.Write(csv);
                Response.Flush();
                Response.End();
            }
            catch (Exception ex)
            {
                ShowMessage("Error", "Failed to export: " + ex.Message, "error");
            }
        }

        private DataTable GetExportData()
        {
            switch (currentView)
            {
                case "credits":
                    return GetCreditsExportData();
                case "redemptions":
                    return GetRedemptionsExportData();
                case "users":
                    return GetUsersExportData();
                default:
                    return new DataTable();
            }
        }

        private DataTable GetCreditsExportData()
        {
            string query = @"SELECT 
                            rp.RewardId as 'Transaction ID',
                            u.FullName as 'User Name',
                            u.Phone as 'User Phone',
                            rp.Amount as 'Amount ($)',
                            rp.Type as 'Type',
                            rp.Reference as 'Description',
                            FORMAT(rp.CreatedAt, 'yyyy-MM-dd HH:mm') as 'Transaction Date',
                            u.XP_Credits as 'Current Balance ($)'
                            FROM RewardPoints rp
                            JOIN Users u ON rp.UserId = u.UserId
                            ORDER BY rp.CreatedAt DESC";

            return GetDataTable(query);
        }

        private DataTable GetRedemptionsExportData()
        {
            string query = @"SELECT 
                            rr.RedemptionId as 'Redemption ID',
                            u.FullName as 'User Name',
                            u.Phone as 'User Phone',
                            rr.Amount as 'Amount ($)',
                            rr.Method as 'Payment Method',
                            rr.Status as 'Status',
                            FORMAT(rr.RequestedAt, 'yyyy-MM-dd HH:mm') as 'Request Date',
                            FORMAT(rr.ProcessedAt, 'yyyy-MM-dd HH:mm') as 'Processed Date',
                            u.XP_Credits as 'Current Balance ($)'
                            FROM RedemptionRequests rr
                            JOIN Users u ON rr.UserId = u.UserId
                            ORDER BY rr.RequestedAt DESC";

            return GetDataTable(query);
        }

        private DataTable GetUsersExportData()
        {
            string query = @"SELECT 
                            u.FullName as 'User Name',
                            u.Phone as 'Phone',
                            r.RoleName as 'Role',
                            u.XP_Credits as 'Current Balance ($)',
                            ISNULL((SELECT SUM(Amount) FROM RewardPoints WHERE UserId = u.UserId AND Amount > 0), 0) as 'Total Earned ($)',
                            ISNULL((SELECT SUM(Amount) FROM RewardPoints WHERE UserId = u.UserId AND Amount < 0), 0) as 'Total Redeemed ($)',
                            (SELECT COUNT(*) FROM RewardPoints WHERE UserId = u.UserId) as 'Total Transactions',
                            (SELECT COUNT(*) FROM RedemptionRequests WHERE UserId = u.UserId) as 'Total Redemptions',
                            FORMAT(u.CreatedAt, 'yyyy-MM-dd') as 'Join Date'
                            FROM Users u
                            JOIN Roles r ON u.RoleId = r.RoleId
                            WHERE u.XP_Credits > 0
                            ORDER BY u.XP_Credits DESC";

            return GetDataTable(query);
        }

        private string ConvertDataTableToCSV(DataTable dt)
        {
            System.Text.StringBuilder sb = new System.Text.StringBuilder();

            // Add headers
            for (int i = 0; i < dt.Columns.Count; i++)
            {
                sb.Append(dt.Columns[i].ColumnName);
                if (i < dt.Columns.Count - 1)
                    sb.Append(",");
            }
            sb.AppendLine();

            // Add rows
            foreach (DataRow row in dt.Rows)
            {
                for (int i = 0; i < dt.Columns.Count; i++)
                {
                    string value = row[i].ToString().Replace("\"", "\"\"");
                    if (value.Contains(",") || value.Contains("\"") || value.Contains("\n"))
                        value = "\"" + value + "\"";

                    sb.Append(value);
                    if (i < dt.Columns.Count - 1)
                        sb.Append(",");
                }
                sb.AppendLine();
            }

            return sb.ToString();
        }

        // Repeater Item Data Bound
        protected void rptCreditsGrid_ItemDataBound(object sender, RepeaterItemEventArgs e) { }
        protected void rptRedemptionsGrid_ItemDataBound(object sender, RepeaterItemEventArgs e) { }
        protected void rptUsersGrid_ItemDataBound(object sender, RepeaterItemEventArgs e) { }

        // Message Display
        private void ShowMessage(string title, string message, string type)
        {
            pnlMessage.Visible = true;
            litMessageTitle.Text = title;
            litMessageText.Text = message;

            divMessage.Attributes["class"] = "message-alert " + type;
            iconMessage.Attributes["class"] = type == "error" ? "fas fa-exclamation-circle" :
                                            type == "success" ? "fas fa-check-circle" :
                                            "fas fa-info-circle";

            // Auto-hide message after 5 seconds
            string script = "setTimeout(function() {" +
                           "var messagePanel = document.getElementById('" + pnlMessage.ClientID + "');" +
                           "if (messagePanel) {" +
                           "messagePanel.style.display = 'none';" +
                           "}" +
                           "}, 5000);";
            ScriptManager.RegisterStartupScript(this, this.GetType(), "HideMessage", script, true);
        }
    }
}