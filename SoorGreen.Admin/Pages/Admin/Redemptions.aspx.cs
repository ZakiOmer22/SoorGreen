using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.Configuration;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace SoorGreen.Admin.Admin
{
    public partial class Redemptions : System.Web.UI.Page
    {
        private string connectionString = WebConfigurationManager.ConnectionStrings["SoorGreenDBConnectionString"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                BindRedemptions();
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
                else if (eventArg.StartsWith("view_"))
                {
                    string redemptionId = eventArg.Substring(5);
                    LoadRedemptionForView(redemptionId);
                }
            }
        }

        private void BindRedemptions()
        {
            try
            {
                // Updated query without PaymentDetails and AdminNotes columns
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
                                u.Email as UserEmail,
                                u.XP_Credits as UserBalance,
                                (SELECT COUNT(*) FROM RedemptionRequests WHERE UserId = u.UserId) as TotalRedemptions,
                                (SELECT ISNULL(SUM(Amount), 0) FROM RedemptionRequests WHERE UserId = u.UserId AND Status = 'Approved') as TotalRedeemed
                                FROM RedemptionRequests rr
                                JOIN Users u ON rr.UserId = u.UserId
                                WHERE 1=1";

                List<SqlParameter> parameters = new List<SqlParameter>();

                // Apply search filter
                if (!string.IsNullOrEmpty(txtSearch.Text))
                {
                    query += " AND (u.FullName LIKE @search OR u.Phone LIKE @search OR rr.RedemptionId LIKE @search OR rr.Method LIKE @search)";
                    parameters.Add(new SqlParameter("@search", "%" + txtSearch.Text + "%"));
                }

                // Apply status filter
                if (ddlStatus.SelectedValue != "all")
                {
                    query += " AND rr.Status = @status";
                    parameters.Add(new SqlParameter("@status", ddlStatus.SelectedValue));
                }

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

                // Get data from database
                DataTable dt = GetDataTable(query, parameters.ToArray());

                // Bind to repeater for grid view
                rptRedemptionsGrid.DataSource = dt;
                rptRedemptionsGrid.DataBind();

                // Bind to gridview for table view
                gvRedemptions.DataSource = dt;
                gvRedemptions.DataBind();

                // Update stats
                UpdateStats(dt);

                // Update redemption count
                lblRedemptionCount.Text = dt.Rows.Count.ToString();

                // Show message if no data
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
            int totalRedemptions = dt.Rows.Count;
            int pendingRedemptions = 0;
            int approvedRedemptions = 0;
            decimal totalAmount = 0;

            foreach (DataRow row in dt.Rows)
            {
                string status = row["Status"].ToString();
                if (status == "Pending")
                    pendingRedemptions++;
                else if (status == "Approved")
                    approvedRedemptions++;

                totalAmount += Convert.ToDecimal(row["Amount"]);
            }

            statTotal.InnerText = totalRedemptions.ToString();
            statPending.InnerText = pendingRedemptions.ToString();
            statApproved.InnerText = approvedRedemptions.ToString();
            statTotalAmount.InnerText = "$" + totalAmount.ToString("N2");
        }

        private void LoadRedemptionForProcessing(string redemptionId)
        {
            string query = @"SELECT 
                            rr.RedemptionId,
                            rr.Amount,
                            rr.Method,
                            rr.Status,
                            rr.RequestedAt,
                            u.UserId,
                            u.FullName as UserName,
                            u.Phone as UserPhone,
                            u.Email as UserEmail,
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

                        string userInfo = reader["UserName"].ToString() + "\n";
                        userInfo += "Phone: " + reader["UserPhone"].ToString() + "\n";
                        userInfo += "Email: " + (reader["UserEmail"] != DBNull.Value ? reader["UserEmail"].ToString() : "N/A");
                        txtUserInfo.Text = userInfo;

                        txtAmount.Text = reader["Amount"].ToString();
                        txtPaymentMethod.Text = reader["Method"].ToString();
                        txtRequestDate.Text = Convert.ToDateTime(reader["RequestedAt"]).ToString("MMMM dd, yyyy HH:mm");

                        // Initialize empty fields since columns don't exist
                        txtPaymentDetails.Text = "";
                        txtAdminNotes.Text = "";
                    }
                }
            }

            // Show modal via JavaScript
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ShowRedemptionModal",
                "var modal = new bootstrap.Modal(document.getElementById('processRedemptionModal')); modal.show();", true);
        }

        private void LoadRedemptionForView(string redemptionId)
        {
            LoadRedemptionForProcessing(redemptionId);

            // In a real implementation, you might disable form fields for view-only
            ScriptManager.RegisterStartupScript(this, this.GetType(), "MakeReadOnly",
                "document.getElementById('txtPaymentDetails').readOnly = true; " +
                "document.getElementById('txtAdminNotes').readOnly = true; " +
                "document.getElementById('btnApproveRedemption').style.display = 'none'; " +
                "document.getElementById('btnRejectRedemption').style.display = 'none';", true);
        }

        // CRUD Operations
        protected void btnApproveRedemption_Click(object sender, EventArgs e)
        {
            try
            {
                string redemptionId = hdnRedemptionId.Value;
                string paymentDetails = txtPaymentDetails.Text;
                string adminNotes = txtAdminNotes.Text;

                // Update redemption status (without PaymentDetails and AdminNotes columns)
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

                // Update user's XP_Credits
                string updateUserQuery = @"UPDATE Users 
                                          SET XP_Credits = XP_Credits - @Amount 
                                          WHERE UserId = @UserId";

                using (SqlConnection conn = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand(updateUserQuery, conn))
                {
                    cmd.Parameters.AddWithValue("@UserId", userId);
                    cmd.Parameters.AddWithValue("@Amount", amount);

                    conn.Open();
                    cmd.ExecuteNonQuery();
                }

                ShowMessage("Success", "Redemption approved and processed successfully! User's credits have been deducted.", "success");
                BindRedemptions();

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
                BindRedemptions();

                // Close modal via JavaScript
                ScriptManager.RegisterStartupScript(this, this.GetType(), "CloseModal",
                    "$('#processRedemptionModal').modal('hide');", true);
            }
            catch (Exception ex)
            {
                ShowMessage("Error", "Failed to reject redemption: " + ex.Message, "error");
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
        public string GetStatusBadgeClass(string status)
        {
            switch (status.ToLower())
            {
                case "pending":
                    return "badge-warning";
                case "approved":
                    return "badge-success";
                case "rejected":
                    return "badge-danger";
                case "processing":
                    return "badge-info";
                case "completed":
                    return "badge-primary";
                default:
                    return "badge-secondary";
            }
        }

        public string GetStatusClass(string status)
        {
            switch (status.ToLower())
            {
                case "pending":
                    return "status-pending";
                case "approved":
                    return "status-completed";
                case "rejected":
                    return "status-cancelled";
                case "processing":
                    return "status-inprogress";
                case "completed":
                    return "status-completed";
                default:
                    return "status-pending";
            }
        }

        public string GetStatusColor(string status)
        {
            switch (status.ToLower())
            {
                case "pending":
                    return "text-warning";
                case "approved":
                    return "text-success";
                case "rejected":
                    return "text-danger";
                case "processing":
                    return "text-info";
                case "completed":
                    return "text-primary";
                default:
                    return "text-warning";
            }
        }

        public string GetActionButtons(string status, string redemptionId)
        {
            if (status.ToLower() == "pending")
            {
                return string.Format(
                    "<button type='button' class='btn btn-success' onclick='processRedemption(\"{0}\")'>" +
                    "<i class='fas fa-check me-1'></i>Process</button>",
                    redemptionId);
            }
            else if (status.ToLower() == "processing")
            {
                return string.Format(
                    "<button type='button' class='btn btn-success' onclick='processRedemption(\"{0}\")'>" +
                    "<i class='fas fa-cog me-1'></i>Complete</button>",
                    redemptionId);
            }
            return string.Empty;
        }

        public int GetDaysSinceRequest(object requestedAt)
        {
            if (requestedAt == DBNull.Value || requestedAt == null)
                return 0;

            DateTime requestDate = Convert.ToDateTime(requestedAt);
            TimeSpan timeSince = DateTime.Now - requestDate;
            return (int)timeSince.TotalDays;
        }

        // Updated to handle missing PaymentDetails and AdminNotes
        public string GetPaymentDetailsDisplay(object paymentDetails)
        {
            // Since column doesn't exist, return empty
            return string.Empty;
        }

        public string GetAdminNotesDisplay(object adminNotes)
        {
            // Since column doesn't exist, return "No notes"
            return "No notes";
        }

        // Event Handlers
        protected void btnApplyFilters_Click(object sender, EventArgs e)
        {
            BindRedemptions();
        }

        protected void btnClearFilters_Click(object sender, EventArgs e)
        {
            txtSearch.Text = "";
            ddlStatus.SelectedValue = "all";
            ddlDateFilter.SelectedValue = "all";
            BindRedemptions();
        }

        protected void btnRefresh_Click(object sender, EventArgs e)
        {
            BindRedemptions();
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
                Response.AddHeader("content-disposition", "attachment;filename=Redemptions_Report_" + DateTime.Now.ToString("yyyyMMdd") + ".csv");
                Response.Charset = "";
                Response.ContentType = "application/text";

                DataTable dt = GetRedemptionsDataForExport();
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

        private DataTable GetRedemptionsDataForExport()
        {
            // Updated query without PaymentDetails and AdminNotes columns
            string query = @"SELECT 
                            rr.RedemptionId as 'Redemption ID',
                            u.FullName as 'User Name',
                            u.Phone as 'User Phone',
                            u.Email as 'User Email',
                            rr.Amount as 'Amount ($)',
                            rr.Method as 'Payment Method',
                            rr.Status as 'Status',
                            FORMAT(rr.RequestedAt, 'yyyy-MM-dd HH:mm') as 'Request Date',
                            FORMAT(rr.ProcessedAt, 'yyyy-MM-dd HH:mm') as 'Processed Date',
                            u.XP_Credits as 'User Balance ($)',
                            DATEDIFF(DAY, rr.RequestedAt, GETDATE()) as 'Days Since Request'
                            FROM RedemptionRequests rr
                            JOIN Users u ON rr.UserId = u.UserId
                            ORDER BY rr.RequestedAt DESC";

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
        protected void rptRedemptionsGrid_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
            {
               
            }
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