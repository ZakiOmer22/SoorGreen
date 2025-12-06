using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Runtime.Remoting.Messaging;
using System.Web.Configuration;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.Util;

namespace SoorGreen.Admin.Admin
{
    public partial class Transactions : System.Web.UI.Page
    {
        private string connectionString = WebConfigurationManager.ConnectionStrings["SoorGreenDBConnectionString"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                BindUsersDropdown();
                BindTransactions();
            }

            // Handle events from JavaScript
            if (Request["__EVENTTARGET"] == "ctl00$MainContent$hdnTransactionId")
            {
                string eventArg = Request["__EVENTARGUMENT"];
                if (eventArg.StartsWith("view_"))
                {
                    string transactionId = eventArg.Substring(5);
                    LoadTransactionForView(transactionId);
                }
            }
        }

        private void BindTransactions()
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
                                u.Email as UserEmail,
                                u.XP_Credits as UserBalance,
                                (SELECT COUNT(*) FROM RewardPoints WHERE UserId = u.UserId) as TotalTransactions,
                                (SELECT ISNULL(SUM(Amount), 0) FROM RewardPoints WHERE UserId = u.UserId AND Amount > 0) as TotalCredits
                                FROM RewardPoints rp
                                JOIN Users u ON rp.UserId = u.UserId
                                WHERE 1=1";

                List<SqlParameter> parameters = new List<SqlParameter>();

                // Apply search filter
                if (!string.IsNullOrEmpty(txtSearch.Text))
                {
                    query += " AND (u.FullName LIKE @search OR u.Phone LIKE @search OR rp.RewardId LIKE @search OR rp.Reference LIKE @search)";
                    parameters.Add(new SqlParameter("@search", "%" + txtSearch.Text + "%"));
                }

                // Apply transaction type filter
                if (ddlTransactionType.SelectedValue != "all")
                {
                    query += " AND rp.Type = @type";
                    parameters.Add(new SqlParameter("@type", ddlTransactionType.SelectedValue));
                }

                // Apply amount range filter
                decimal amountFrom, amountTo;
                if (decimal.TryParse(txtAmountFrom.Text, out amountFrom) && amountFrom > 0)
                {
                    query += " AND ABS(rp.Amount) >= @amountFrom";
                    parameters.Add(new SqlParameter("@amountFrom", amountFrom));
                }

                if (decimal.TryParse(txtAmountTo.Text, out amountTo) && amountTo > 0)
                {
                    query += " AND ABS(rp.Amount) <= @amountTo";
                    parameters.Add(new SqlParameter("@amountTo", amountTo));
                }

                // Apply date filter
                if (ddlDateFilter.SelectedValue != "all")
                {
                    if (ddlDateFilter.SelectedValue == "custom")
                    {
                        // Custom date range
                        DateTime dateFrom, dateTo;
                        if (DateTime.TryParse(txtDateFrom.Text, out dateFrom))
                        {
                            query += " AND rp.CreatedAt >= @dateFrom";
                            parameters.Add(new SqlParameter("@dateFrom", dateFrom));
                        }

                        if (DateTime.TryParse(txtDateTo.Text, out dateTo))
                        {
                            query += " AND rp.CreatedAt <= @dateTo";
                            parameters.Add(new SqlParameter("@dateTo", dateTo.AddDays(1))); // Include entire end day
                        }
                    }
                    else
                    {
                        // Predefined ranges
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
                }

                // Filter by user if specified in query string
                if (!string.IsNullOrEmpty(Request.QueryString["userId"]))
                {
                    query += " AND u.UserId = @userId";
                    parameters.Add(new SqlParameter("@userId", Request.QueryString["userId"]));
                }

                query += " ORDER BY rp.CreatedAt DESC";

                // Get data from database
                DataTable dt = GetDataTable(query, parameters.ToArray());

                // Bind to repeater for grid view
                rptTransactionsGrid.DataSource = dt;
                rptTransactionsGrid.DataBind();

                // Bind to gridview for table view
                gvTransactions.DataSource = dt;
                gvTransactions.DataBind();

                // Update stats
                UpdateStats(dt);

                // Update transaction count
                lblTransactionCount.Text = dt.Rows.Count.ToString();

                // Show message if no data
                if (dt.Rows.Count == 0)
                {
                    ShowMessage("Info", "No transactions found.", "info");
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Error", "Failed to load transactions: " + ex.Message, "error");
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

        private void UpdateStats(DataTable dt)
        {
            int totalTransactions = dt.Rows.Count;
            decimal totalCredits = 0;
            decimal totalRedemptions = 0;
            decimal netFlow = 0;

            foreach (DataRow row in dt.Rows)
            {
                decimal amount = Convert.ToDecimal(row["Amount"]);
                netFlow += amount;

                if (amount >= 0)
                {
                    totalCredits += amount;
                }
                else
                {
                    totalRedemptions += Math.Abs(amount);
                }
            }

            statTotalTransactions.InnerText = totalTransactions.ToString();
            statTotalCredits.InnerText = "$" + totalCredits.ToString("N2");
            statTotalRedemptions.InnerText = "$" + totalRedemptions.ToString("N2");
            statNetFlow.InnerText = "$" + netFlow.ToString("N2");
        }

        private void BindUsersDropdown()
        {
            try
            {
                string query = "SELECT UserId, FullName + ' (' + Phone + ')' as DisplayName FROM Users ORDER BY FullName";

                using (SqlConnection conn = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    conn.Open();
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        ddlUsers.DataSource = reader;
                        ddlUsers.DataTextField = "DisplayName";
                        ddlUsers.DataValueField = "UserId";
                        ddlUsers.DataBind();

                        // Add default item
                        ddlUsers.Items.Insert(0, new ListItem("-- Select User --", ""));
                    }
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Error", "Failed to load users: " + ex.Message, "error");
            }
        }

        private void LoadTransactionForView(string transactionId)
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
                                u.Email as UserEmail,
                                u.XP_Credits as CurrentBalance
                                FROM RewardPoints rp
                                JOIN Users u ON rp.UserId = u.UserId
                                WHERE rp.RewardId = @RewardId";

                using (SqlConnection conn = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@RewardId", transactionId);
                    conn.Open();

                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            hdnTransactionId.Value = reader["RewardId"].ToString();
                            txtTransactionId.Text = reader["RewardId"].ToString();

                            string userInfo = reader["UserName"].ToString() + "\n";
                            userInfo += "Phone: " + reader["UserPhone"].ToString() + "\n";
                            userInfo += "Email: " + (reader["UserEmail"] != DBNull.Value ? reader["UserEmail"].ToString() : "N/A");
                            txtUserInfo.Text = userInfo;

                            txtTransactionType.Text = reader["Type"].ToString();
                            txtReference.Text = reader["Reference"].ToString();

                            decimal amount = Convert.ToDecimal(reader["Amount"]);
                            txtAmount.Text = amount.ToString("N2");

                            // Calculate balance after transaction
                            decimal currentBalance = Convert.ToDecimal(reader["CurrentBalance"]);
                            decimal balanceAfter = currentBalance - amount; // Since current balance includes this transaction
                            txtBalanceAfter.Text = balanceAfter.ToString("N2");

                            txtTransactionDate.Text = Convert.ToDateTime(reader["CreatedAt"]).ToString("MMMM dd, yyyy HH:mm");
                            txtRewardId.Text = reader["RewardId"].ToString();

                            // Set status based on amount
                            txtStatus.Text = amount >= 0 ? "Credit Added" : "Credit Deducted";

                            // Get admin notes if they exist (you would need to add this field to RewardPoints table)
                            txtAdminNotes.Text = "No notes available"; // Default
                        }
                        else
                        {
                            ShowMessage("Error", "Transaction not found.", "error");
                            return;
                        }
                    }
                }

                // Show modal via JavaScript
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ShowTransactionModal",
                    "var modal = new bootstrap.Modal(document.getElementById('transactionDetailsModal')); modal.show();", true);
            }
            catch (Exception ex)
            {
                ShowMessage("Error", "Failed to load transaction: " + ex.Message, "error");
            }
        }

        // CRUD Operations
        protected void btnSaveNotes_Click(object sender, EventArgs e)
        {
            try
            {
                string transactionId = hdnTransactionId.Value;
                string adminNotes = txtAdminNotes.Text;

                // Note: You would need to add an AdminNotes column to the RewardPoints table
                // string query = @"UPDATE RewardPoints SET AdminNotes = @AdminNotes WHERE RewardId = @RewardId";

                // For now, we'll just show a message
                ShowMessage("Info", "Notes saving functionality would be implemented after adding AdminNotes column to RewardPoints table.", "info");

                // Close modal via JavaScript
                ScriptManager.RegisterStartupScript(this, this.GetType(), "CloseModal",
                    "$('#transactionDetailsModal').modal('hide');", true);
            }
            catch (Exception ex)
            {
                ShowMessage("Error", "Failed to save notes: " + ex.Message, "error");
            }
        }

        protected void btnReverseTransaction_Click(object sender, EventArgs e)
        {
            try
            {
                string transactionId = hdnTransactionId.Value;

                // Get transaction details first
                string getQuery = @"SELECT UserId, Amount, Type, Reference FROM RewardPoints WHERE RewardId = @RewardId";
                string userId = "";
                decimal amount = 0;
                string type = "";
                string reference = "";

                using (SqlConnection conn = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand(getQuery, conn))
                {
                    cmd.Parameters.AddWithValue("@RewardId", transactionId);
                    conn.Open();

                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            userId = reader["UserId"].ToString();
                            amount = Convert.ToDecimal(reader["Amount"]);
                            type = reader["Type"].ToString();
                            reference = reader["Reference"].ToString();
                        }
                        else
                        {
                            ShowMessage("Error", "Transaction not found.", "error");
                            return;
                        }
                    }
                }

                // Generate new RewardId for the reversal
                string newRewardId = GetNextRewardId();

                // Insert reversal transaction (opposite amount)
                string reversalQuery = @"INSERT INTO RewardPoints 
                                        (RewardId, UserId, Amount, Type, Reference, CreatedAt)
                                        VALUES (@RewardId, @UserId, @Amount, @Type, @Reference, GETDATE())";

                using (SqlConnection conn = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand(reversalQuery, conn))
                {
                    cmd.Parameters.AddWithValue("@RewardId", newRewardId);
                    cmd.Parameters.AddWithValue("@UserId", userId);
                    cmd.Parameters.AddWithValue("@Amount", -amount); // Opposite amount
                    cmd.Parameters.AddWithValue("@Type", "Reversal");
                    cmd.Parameters.AddWithValue("@Reference", "Reversal of " + transactionId + " - " + reference);

                    conn.Open();
                    cmd.ExecuteNonQuery();
                }

                // Update user's XP_Credits
                string updateUserQuery = @"UPDATE Users 
                                          SET XP_Credits = XP_Credits - @Amount 
                                          WHERE UserId = @UserId";

                using (SqlConnection conn = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand(updateUserQuery, conn))
                {
                    cmd.Parameters.AddWithValue("@UserId", userId);
                    cmd.Parameters.AddWithValue("@Amount", amount); // Since we're reversing

                    conn.Open();
                    cmd.ExecuteNonQuery();
                }

                ShowMessage("Success", "Transaction reversed successfully! A reversal transaction has been recorded.", "success");
                BindTransactions();

                // Close modal via JavaScript
                ScriptManager.RegisterStartupScript(this, this.GetType(), "CloseModal",
                    "$('#transactionDetailsModal').modal('hide');", true);
            }
            catch (Exception ex)
            {
                ShowMessage("Error", "Failed to reverse transaction: " + ex.Message, "error");
            }
        }

        protected void btnApplyAdjustment_Click(object sender, EventArgs e)
        {
            try
            {
                string userId = ddlUsers.SelectedValue;
                string adjustmentType = ddlAdjustmentType.SelectedValue;
                decimal amount;

                if (string.IsNullOrEmpty(userId))
                {
                    ShowMessage("Error", "Please select a user.", "error");
                    return;
                }

                if (!decimal.TryParse(txtAdjustmentAmount.Text, out amount) || amount <= 0)
                {
                    ShowMessage("Error", "Please enter a valid amount greater than 0.", "error");
                    return;
                }

                decimal finalAmount = amount;
                string description = txtAdjustmentReason.Text;

                // Determine actual amount based on adjustment type
                if (adjustmentType == "Deduct")
                {
                    finalAmount = -amount;
                }
                else if (adjustmentType == "Set")
                {
                    // For Set balance, we need to calculate the difference
                    decimal currentBalance = GetUserBalance(userId);
                    finalAmount = amount - currentBalance; // Difference to reach target
                    description = string.Format("Balance set to ${0:N2} (was ${1:N2}) - {2}",
                        amount, currentBalance, description);
                }

                // Generate RewardId
                string rewardId = GetNextRewardId();

                // Insert adjustment transaction
                string query = @"INSERT INTO RewardPoints 
                        (RewardId, UserId, Amount, Type, Reference, CreatedAt)
                        VALUES (@RewardId, @UserId, @Amount, @Type, @Reference, GETDATE())";

                using (SqlConnection conn = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@RewardId", rewardId);
                    cmd.Parameters.AddWithValue("@UserId", userId);
                    cmd.Parameters.AddWithValue("@Amount", finalAmount);
                    cmd.Parameters.AddWithValue("@Type", "Adjustment");
                    cmd.Parameters.AddWithValue("@Reference", string.Format("Manual Adjustment: {0}", description));

                    conn.Open();
                    cmd.ExecuteNonQuery();
                }

                // Update user's XP_Credits (trigger should handle this, but we'll do it explicitly)
                string updateQuery = @"UPDATE Users 
                              SET XP_Credits = XP_Credits + @Amount 
                              WHERE UserId = @UserId";

                using (SqlConnection conn = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand(updateQuery, conn))
                {
                    cmd.Parameters.AddWithValue("@UserId", userId);
                    cmd.Parameters.AddWithValue("@Amount", finalAmount);

                    conn.Open();
                    cmd.ExecuteNonQuery();
                }

                ShowMessage("Success", string.Format("Adjustment applied successfully! User's balance has been updated."), "success");

                // Clear the form
                txtAdjustmentAmount.Text = "";
                txtAdjustmentReason.Text = "";

                BindTransactions();
            }
            catch (Exception ex)
            {
                ShowMessage("Error", string.Format("Failed to apply adjustment: {0}", ex.Message), "error");
            }
        }

        private decimal GetUserBalance(string userId)
        {
            string query = "SELECT XP_Credits FROM Users WHERE UserId = @UserId";

            using (SqlConnection conn = new SqlConnection(connectionString))
            using (SqlCommand cmd = new SqlCommand(query, conn))
            {
                cmd.Parameters.AddWithValue("@UserId", userId);
                conn.Open();

                object result = cmd.ExecuteScalar();
                if (result != null && result != DBNull.Value)
                {
                    return Convert.ToDecimal(result);
                }
            }

            return 0;
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
        public string GetAmountBadgeClass(decimal amount)
        {
            return amount >= 0 ? "positive" : "negative";
        }

        public string GetTypeBadgeClass(string type)
        {
            switch (type.ToLower())
            {
                case "credit":
                case "bonus":
                    return "badge-success";
                case "redemption":
                case "penalty":
                    return "badge-danger";
                case "adjustment":
                    return "badge-info";
                case "reversal":
                    return "badge-warning";
                default:
                    return "badge-secondary";
            }
        }

        public string GetTypeIconClass(string type)
        {
            switch (type.ToLower())
            {
                case "credit": return "credit";
                case "redemption": return "redemption";
                case "adjustment": return "adjustment";
                case "bonus": return "bonus";
                case "penalty": return "penalty";
                default: return "credit";
            }
        }

        public string GetTypeIcon(string type)
        {
            switch (type.ToLower())
            {
                case "credit": return "fa-plus-circle";
                case "redemption": return "fa-minus-circle";
                case "adjustment": return "fa-user-cog";
                case "bonus": return "fa-gift";
                case "penalty": return "fa-exclamation-circle";
                default: return "fa-exchange-alt";
            }
        }

        public string GetActionButtons(string type, string rewardId)
        {
            // Only show reverse button for non-reversal transactions
            if (type.ToLower() != "reversal")
            {
                return string.Format(
                    "<button type='button' class='btn btn-danger' onclick='viewTransactionDetails(\"{0}\")'>" +
                    "<i class='fas fa-undo me-1'></i>Reverse</button>",
                    rewardId);
            }
            return string.Empty;
        }

        public int GetDaysAgo(object createdAt)
        {
            if (createdAt == DBNull.Value || createdAt == null)
                return 0;

            DateTime creationDate = Convert.ToDateTime(createdAt);
            TimeSpan timeSince = DateTime.Now - creationDate;
            return (int)timeSince.TotalDays;
        }

        public int GetTransactionCountForUser(object userId)
        {
            if (userId == DBNull.Value || userId == null)
                return 0;

            string query = "SELECT COUNT(*) FROM RewardPoints WHERE UserId = @UserId";

            using (SqlConnection conn = new SqlConnection(connectionString))
            using (SqlCommand cmd = new SqlCommand(query, conn))
            {
                cmd.Parameters.AddWithValue("@UserId", userId.ToString());
                conn.Open();

                return (int)cmd.ExecuteScalar();
            }
        }

        public decimal GetTotalUserCredits(object userId)
        {
            if (userId == DBNull.Value || userId == null)
                return 0;

            string query = "SELECT ISNULL(SUM(Amount), 0) FROM RewardPoints WHERE UserId = @UserId AND Amount > 0";

            using (SqlConnection conn = new SqlConnection(connectionString))
            using (SqlCommand cmd = new SqlCommand(query, conn))
            {
                cmd.Parameters.AddWithValue("@UserId", userId.ToString());
                conn.Open();

                object result = cmd.ExecuteScalar();
                if (result != null && result != DBNull.Value)
                {
                    return Convert.ToDecimal(result);
                }
            }

            return 0;
        }

        public string GetUserBalanceAfterTransaction(object userId, object transactionDate)
        {
            if (userId == DBNull.Value || userId == null || transactionDate == DBNull.Value || transactionDate == null)
                return "0.00";

            DateTime date = Convert.ToDateTime(transactionDate);

            string query = @"SELECT ISNULL(SUM(Amount), 0) 
                            FROM RewardPoints 
                            WHERE UserId = @UserId 
                            AND CreatedAt <= @TransactionDate";

            using (SqlConnection conn = new SqlConnection(connectionString))
            using (SqlCommand cmd = new SqlCommand(query, conn))
            {
                cmd.Parameters.AddWithValue("@UserId", userId.ToString());
                cmd.Parameters.AddWithValue("@TransactionDate", date);
                conn.Open();

                object result = cmd.ExecuteScalar();
                if (result != null && result != DBNull.Value)
                {
                    return Convert.ToDecimal(result).ToString("N2");
                }
            }

            return "0.00";
        }

        public string GetCurrentUserBalance(object userId)
        {
            if (userId == DBNull.Value || userId == null)
                return "0.00";

            string query = "SELECT XP_Credits FROM Users WHERE UserId = @UserId";

            using (SqlConnection conn = new SqlConnection(connectionString))
            using (SqlCommand cmd = new SqlCommand(query, conn))
            {
                cmd.Parameters.AddWithValue("@UserId", userId.ToString());
                conn.Open();

                object result = cmd.ExecuteScalar();
                if (result != null && result != DBNull.Value)
                {
                    return Convert.ToDecimal(result).ToString("N2");
                }
            }

            return "0.00";
        }

        // Event Handlers
        protected void btnApplyFilters_Click(object sender, EventArgs e)
        {
            BindTransactions();
        }

        protected void btnClearFilters_Click(object sender, EventArgs e)
        {
            txtSearch.Text = "";
            ddlTransactionType.SelectedValue = "all";
            txtAmountFrom.Text = "";
            txtAmountTo.Text = "";
            ddlDateFilter.SelectedValue = "all";
            txtDateFrom.Text = "";
            txtDateTo.Text = "";
            BindTransactions();
        }

        protected void btnRefresh_Click(object sender, EventArgs e)
        {
            BindTransactions();
        }

        protected void btnGridView_Click(object sender, EventArgs e)
        {
            pnlGridView.Visible = true;
            pnlTableView.Visible = false;
            btnGridView.CssClass = "view-btn active";
            btnTableView.CssClass = "view-btn";
        }

        protected void btnTableView_Click(object sender, EventArgs e)
        {
            pnlGridView.Visible = false;
            pnlTableView.Visible = true;
            btnGridView.CssClass = "view-btn";
            btnTableView.CssClass = "view-btn active";
        }

        protected void btnExportCSV_Click(object sender, EventArgs e)
        {
            try
            {
                Response.Clear();
                Response.Buffer = true;
                Response.AddHeader("content-disposition", "attachment;filename=Transactions_Report_" + DateTime.Now.ToString("yyyyMMdd") + ".csv");
                Response.Charset = "";
                Response.ContentType = "application/text";

                DataTable dt = GetTransactionsDataForExport();
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

        private DataTable GetTransactionsDataForExport()
        {
            string query = @"SELECT 
                            rp.RewardId as 'Transaction ID',
                            u.FullName as 'User Name',
                            u.Phone as 'User Phone',
                            rp.Amount as 'Amount ($)',
                            rp.Type as 'Transaction Type',
                            rp.Reference as 'Description',
                            FORMAT(rp.CreatedAt, 'yyyy-MM-dd HH:mm') as 'Date & Time',
                            u.XP_Credits as 'Current Balance ($)',
                            CASE WHEN rp.Amount >= 0 THEN 'Credit' ELSE 'Debit' END as 'Credit/Debit'
                            FROM RewardPoints rp
                            JOIN Users u ON rp.UserId = u.UserId
                            ORDER BY rp.CreatedAt DESC";

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
        protected void rptTransactionsGrid_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
        }

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