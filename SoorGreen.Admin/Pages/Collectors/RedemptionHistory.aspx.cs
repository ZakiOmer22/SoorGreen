using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace SoorGreen.Collectors
{
    public partial class RedemptionHistory : System.Web.UI.Page
    {
        protected string CurrentUserId = "";
        protected string CurrentUserRole = "";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] == null)
            {
                Response.Redirect("~/Login.aspx?returnUrl=" + Server.UrlEncode(Request.Url.AbsolutePath));
                return;
            }

            CurrentUserId = Session["UserID"].ToString();
            CurrentUserRole = Session["UserRole"] != null ? Session["UserRole"].ToString() : "";

            if (!IsCollectorRole(CurrentUserRole))
            {
                ShowErrorMessage("Access denied.");
                string script = "setTimeout(function() { window.location.href = '/Default.aspx'; }, 3000);";
                ScriptManager.RegisterStartupScript(this, GetType(), "redirect", script, true);
                return;
            }

            if (!IsPostBack)
            {
                BindStats();
                BindRedemptionHistory();
            }
        }

        private bool IsCollectorRole(string role)
        {
            return role == "R002" || role == "COLL";
        }

        private void BindStats()
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(GetConnectionString()))
                {
                    conn.Open();

                    string pendingQuery = "SELECT COUNT(*) FROM RedemptionRequests WHERE Status = 'Pending'";
                    using (SqlCommand cmd = new SqlCommand(pendingQuery, conn))
                    {
                        object result = cmd.ExecuteScalar();
                        lblTotalPending.Text = (result != null && result != DBNull.Value) ? result.ToString() : "0";
                    }

                    string approvedTodayQuery = "SELECT COUNT(*) FROM RedemptionRequests WHERE Status = 'Approved' AND CONVERT(DATE, ProcessedAt) = CONVERT(DATE, GETDATE())";
                    using (SqlCommand cmd = new SqlCommand(approvedTodayQuery, conn))
                    {
                        object result = cmd.ExecuteScalar();
                        lblTotalApproved.Text = (result != null && result != DBNull.Value) ? result.ToString() : "0";
                    }

                    string totalAmountQuery = "SELECT ISNULL(SUM(Amount), 0) FROM RedemptionRequests WHERE Status IN ('Approved', 'Completed')";
                    using (SqlCommand cmd = new SqlCommand(totalAmountQuery, conn))
                    {
                        object result = cmd.ExecuteScalar();
                        decimal totalAmount = (result != null && result != DBNull.Value) ? Convert.ToDecimal(result) : 0;
                        lblTotalAmount.Text = totalAmount.ToString("F2");
                    }

                    string weeklyQuery = "SELECT COUNT(*) FROM RedemptionRequests WHERE RequestedAt >= DATEADD(DAY, -7, GETDATE()) AND Status IN ('Approved', 'Completed')";
                    using (SqlCommand cmd = new SqlCommand(weeklyQuery, conn))
                    {
                        object result = cmd.ExecuteScalar();
                        lblWeeklyRedemptions.Text = (result != null && result != DBNull.Value) ? result.ToString() : "0";
                    }
                }
            }
            catch
            {
                ShowErrorMessage("Error loading statistics.");
            }
        }

        private void BindRedemptionHistory()
        {
            try
            {
                string query = "SELECT TOP 20 r.RedemptionId, r.UserId, r.Amount, r.Method, r.Status, r.RequestedAt, r.ProcessedAt, u.FullName as CitizenName, u.Phone as CitizenPhone, u.Email as CitizenEmail, u.XP_Credits as CurrentCredits FROM RedemptionRequests r JOIN Users u ON r.UserId = u.UserId ORDER BY r.RequestedAt DESC";
                string dateRange = ddlDateRange.SelectedValue;
                switch (dateRange)
                {
                    case "today":
                        query += " AND CONVERT(DATE, r.RequestedAt) = CONVERT(DATE, GETDATE())";
                        break;
                    case "week":
                        query += " AND r.RequestedAt >= DATEADD(DAY, -7, GETDATE())";
                        break;
                    case "month":
                        query += " AND r.RequestedAt >= DATEADD(MONTH, -1, GETDATE())";
                        break;
                    case "quarter":
                        query += " AND r.RequestedAt >= DATEADD(MONTH, -3, GETDATE())";
                        break;
                    case "year":
                        query += " AND r.RequestedAt >= DATEADD(YEAR, -1, GETDATE())";
                        break;
                }

                if (ddlStatusFilter.SelectedValue != "all")
                {
                    query += " AND r.Status = @Status";
                }

                if (ddlMethodFilter.SelectedValue != "all")
                {
                    query += " AND r.Method = @Method";
                }

                if (!string.IsNullOrEmpty(txtSearch.Text))
                {
                    query += " AND (u.FullName LIKE @Search OR u.Phone LIKE @Search OR r.RedemptionId LIKE @Search)";
                }

                switch (ddlSortBy.SelectedValue)
                {
                    case "amount":
                        query += " ORDER BY r.Amount DESC";
                        break;
                    case "oldest":
                        query += " ORDER BY r.RequestedAt ASC";
                        break;
                    default:
                        query += " ORDER BY r.RequestedAt DESC";
                        break;
                }

                using (SqlConnection conn = new SqlConnection(GetConnectionString()))
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    if (ddlStatusFilter.SelectedValue != "all")
                    {
                        cmd.Parameters.AddWithValue("@Status", ddlStatusFilter.SelectedValue);
                    }

                    if (ddlMethodFilter.SelectedValue != "all")
                    {
                        cmd.Parameters.AddWithValue("@Method", ddlMethodFilter.SelectedValue);
                    }

                    if (!string.IsNullOrEmpty(txtSearch.Text))
                    {
                        cmd.Parameters.AddWithValue("@Search", "%" + txtSearch.Text + "%");
                    }

                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        da.Fill(dt);

                        if (dt.Rows.Count > 0)
                        {
                            rptRedemptionHistory.DataSource = dt;
                            rptRedemptionHistory.DataBind();
                            pnlNoRedemptions.Visible = false;
                        }
                        else
                        {
                            rptRedemptionHistory.DataSource = null;
                            rptRedemptionHistory.DataBind();
                            pnlNoRedemptions.Visible = true;
                        }
                    }
                }
            }
            catch
            {
                ShowErrorMessage("Error loading redemption history.");
                pnlNoRedemptions.Visible = true;
            }
        }

        protected void rptRedemptionHistory_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
            {
                try
                {
                    DataRowView rowView = (DataRowView)e.Item.DataItem;

                    LinkButton btnApprove = (LinkButton)e.Item.FindControl("btnApprove");
                    LinkButton btnReject = (LinkButton)e.Item.FindControl("btnReject");
                    LinkButton btnMarkComplete = (LinkButton)e.Item.FindControl("btnMarkComplete");

                    if (btnApprove != null)
                    {
                        string status = rowView["Status"].ToString();
                        btnApprove.Visible = IsApprovable(status);
                        string redemptionId = rowView["RedemptionId"].ToString();
                        btnApprove.OnClientClick = "return confirmApprove('" + redemptionId + "');";
                    }

                    if (btnReject != null)
                    {
                        string status = rowView["Status"].ToString();
                        btnReject.Visible = IsRejectable(status);
                        string redemptionId = rowView["RedemptionId"].ToString();
                        btnReject.OnClientClick = "return confirmReject('" + redemptionId + "');";
                    }

                    if (btnMarkComplete != null)
                    {
                        string status = rowView["Status"].ToString();
                        btnMarkComplete.Visible = IsCompletable(status);
                        string redemptionId = rowView["RedemptionId"].ToString();
                        btnMarkComplete.OnClientClick = "return confirmComplete('" + redemptionId + "');";
                    }
                }
                catch
                {
                    // Silent catch - no action needed
                }
            }
        }

        protected void rptRedemptionHistory_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            try
            {
                string redemptionId = e.CommandArgument.ToString();
                hdnSelectedRedemptionId.Value = redemptionId;

                switch (e.CommandName)
                {
                    case "ViewDetails":
                        ShowRedemptionDetails(redemptionId);
                        break;
                    case "Approve":
                        ApproveRedemption(redemptionId);
                        break;
                    case "Reject":
                        RejectRedemption(redemptionId);
                        break;
                    case "MarkComplete":
                        MarkRedemptionComplete(redemptionId);
                        break;
                }
            }
            catch
            {
                ShowErrorMessage("Error processing action.");
            }
        }

        private void ShowRedemptionDetails(string redemptionId)
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(GetConnectionString()))
                {
                    string query = "SELECT r.RedemptionId, r.UserId, r.Amount, r.Method, r.Status, r.RequestedAt, r.ProcessedAt, u.FullName as CitizenName, u.Phone as CitizenPhone, u.Email as CitizenEmail, u.XP_Credits as CurrentCredits FROM RedemptionRequests r JOIN Users u ON r.UserId = u.UserId WHERE r.RedemptionId = @RedemptionId";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@RedemptionId", redemptionId);
                        conn.Open();

                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                string redemptionIdValue = reader["RedemptionId"].ToString();
                                string status = reader["Status"].ToString();
                                decimal amount = Convert.ToDecimal(reader["Amount"]);
                                string method = reader["Method"].ToString();
                                string citizenName = reader["CitizenName"].ToString();
                                string citizenPhone = reader["CitizenPhone"].ToString();
                                string citizenEmail = reader["CitizenEmail"].ToString();
                                decimal currentCredits = Convert.ToDecimal(reader["CurrentCredits"]);
                                string requestedAt = BindDate(reader["RequestedAt"]);
                                string processedAt = BindDate(reader["ProcessedAt"]);

                                string statusBadgeClass = GetStatusBadgeClass(status);
                                string paymentBadgeClass = GetPaymentMethodBadgeClass(method);

                                string detailsHtml = @"
                                    <div class='row'>
                                        <div class='col-md-6'>
                                            <h6 class='fw-bold mb-3'><i class='fas fa-info-circle me-2'></i>Basic Information</h6>
                                            <div class='mb-2'>
                                                <small class='text-muted'>Redemption ID:</small>
                                                <div class='fw-bold'>" + redemptionIdValue + @"</div>
                                            </div>
                                            <div class='mb-2'>
                                                <small class='text-muted'>Status:</small>
                                                <div><span class='" + statusBadgeClass + @"'>" + status + @"</span></div>
                                            </div>
                                            <div class='mb-2'>
                                                <small class='text-muted'>Amount:</small>
                                                <div class='fw-bold h5 text-success'>$" + amount.ToString("F2") + @"</div>
                                            </div>
                                            <div class='mb-2'>
                                                <small class='text-muted'>Payment Method:</small>
                                                <div><span class='" + paymentBadgeClass + @"'>" + method + @"</span></div>
                                            </div>
                                        </div>
                                        <div class='col-md-6'>
                                            <h6 class='fw-bold mb-3'><i class='fas fa-user me-2'></i>Citizen Information</h6>
                                            <div class='mb-2'>
                                                <small class='text-muted'>Name:</small>
                                                <div class='fw-bold'>" + citizenName + @"</div>
                                            </div>
                                            <div class='mb-2'>
                                                <small class='text-muted'>Phone:</small>
                                                <div>" + citizenPhone + @"</div>
                                            </div>
                                            <div class='mb-2'>
                                                <small class='text-muted'>Email:</small>
                                                <div>" + citizenEmail + @"</div>
                                            </div>
                                            <div class='mb-2'>
                                                <small class='text-muted'>Current Credits:</small>
                                                <div class='fw-bold'>" + currentCredits.ToString("F0") + @"</div>
                                            </div>
                                        </div>
                                    </div>
                                    <hr>
                                    <div class='row'>
                                        <div class='col-md-6'>
                                            <h6 class='fw-bold mb-3'><i class='fas fa-calendar me-2'></i>Timeline</h6>
                                            <div class='timeline-container'>
                                                <div class='timeline-item'>
                                                    <div class='timeline-date'>Requested: " + requestedAt + @"</div>
                                                    <div class='timeline-content'>
                                                        Redemption request submitted
                                                    </div>
                                                </div>";

                                if (reader["ProcessedAt"] != DBNull.Value)
                                {
                                    detailsHtml += @"
                                                <div class='timeline-item'>
                                                    <div class='timeline-date'>Processed: " + processedAt + @"</div>
                                                    <div class='timeline-content'>
                                                        Request processed - Status: " + status + @"
                                                    </div>
                                                </div>";
                                }

                                detailsHtml += @"
                                            </div>
                                        </div>
                                        <div class='col-md-6'>
                                            <h6 class='fw-bold mb-3'><i class='fas fa-history me-2'></i>Redemption Notes</h6>
                                            <div class='alert alert-info'>
                                                <i class='fas fa-info-circle me-2'></i>
                                                <small>Redemption requests are processed within 24-48 hours.</small>
                                            </div>";

                                if (status == "Pending")
                                {
                                    detailsHtml += @"
                                            <div class='alert alert-warning mt-3'>
                                                <i class='fas fa-exclamation-triangle me-2'></i>
                                                <small>This request is pending approval.</small>
                                            </div>";
                                }

                                detailsHtml += @"
                                        </div>
                                    </div>";

                                string script = "showDetailsModal(`" + detailsHtml.Replace("`", "'").Replace("\r", "").Replace("\n", "") + "`);";
                                ScriptManager.RegisterStartupScript(this, GetType(), "showDetailsModal", script, true);
                            }
                            else
                            {
                                ShowErrorMessage("Redemption request not found.");
                            }
                        }
                    }
                }
            }
            catch
            {
                ShowErrorMessage("Error loading redemption details.");
            }
        }

        private void ApproveRedemption(string redemptionId)
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(GetConnectionString()))
                {
                    string query = "UPDATE RedemptionRequests SET Status = 'Approved', ProcessedAt = GETDATE() WHERE RedemptionId = @RedemptionId AND Status = 'Pending'";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@RedemptionId", redemptionId);

                        conn.Open();
                        int rowsAffected = cmd.ExecuteNonQuery();

                        if (rowsAffected > 0)
                        {
                            LogUserActivity(CurrentUserId, "RedemptionApproved", "Approved redemption " + redemptionId);
                            BindStats();
                            BindRedemptionHistory();
                            ShowSuccessMessage("Redemption request " + redemptionId + " approved successfully!");
                        }
                        else
                        {
                            ShowErrorMessage("Redemption request " + redemptionId + " could not be approved.");
                        }
                    }
                }
            }
            catch
            {
                ShowErrorMessage("Error approving redemption.");
            }
        }

        private void RejectRedemption(string redemptionId)
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(GetConnectionString()))
                {
                    string query = "UPDATE RedemptionRequests SET Status = 'Rejected', ProcessedAt = GETDATE() WHERE RedemptionId = @RedemptionId AND Status = 'Pending'";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@RedemptionId", redemptionId);

                        conn.Open();
                        int rowsAffected = cmd.ExecuteNonQuery();

                        if (rowsAffected > 0)
                        {
                            LogUserActivity(CurrentUserId, "RedemptionRejected", "Rejected redemption " + redemptionId);
                            BindStats();
                            BindRedemptionHistory();
                            ShowSuccessMessage("Redemption request " + redemptionId + " rejected successfully!");
                        }
                        else
                        {
                            ShowErrorMessage("Redemption request " + redemptionId + " could not be rejected.");
                        }
                    }
                }
            }
            catch
            {
                ShowErrorMessage("Error rejecting redemption.");
            }
        }

        private void MarkRedemptionComplete(string redemptionId)
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(GetConnectionString()))
                {
                    string query = "UPDATE RedemptionRequests SET Status = 'Completed' WHERE RedemptionId = @RedemptionId AND Status = 'Approved'";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@RedemptionId", redemptionId);

                        conn.Open();
                        int rowsAffected = cmd.ExecuteNonQuery();

                        if (rowsAffected > 0)
                        {
                            LogUserActivity(CurrentUserId, "RedemptionCompleted", "Marked redemption " + redemptionId + " as completed");
                            BindStats();
                            BindRedemptionHistory();
                            ShowSuccessMessage("Redemption request " + redemptionId + " marked as completed!");
                        }
                        else
                        {
                            ShowErrorMessage("Redemption request " + redemptionId + " could not be marked as completed.");
                        }
                    }
                }
            }
            catch
            {
                ShowErrorMessage("Error marking redemption as complete.");
            }
        }

        public string BindDate(object date)
        {
            if (date == null || date == DBNull.Value)
                return "N/A";

            DateTime dateTime = Convert.ToDateTime(date);

            if (dateTime.Date == DateTime.Today)
                return dateTime.ToString("HH:mm");
            else if (dateTime.Date == DateTime.Today.AddDays(-1))
                return "Yesterday " + dateTime.ToString("HH:mm");
            else
                return dateTime.ToString("MMM dd, yyyy HH:mm");
        }

        public string GetStatusBadgeClass(string status)
        {
            switch (status.ToLower())
            {
                case "pending":
                    return "status-badge-modern status-pending";
                case "approved":
                    return "status-badge-modern status-approved";
                case "completed":
                    return "status-badge-modern status-completed";
                case "rejected":
                    return "status-badge-modern status-rejected";
                default:
                    return "status-badge-modern";
            }
        }

        public string BindStatusIcon(string status)
        {
            switch (status.ToLower())
            {
                case "pending":
                    return "fas fa-clock";
                case "approved":
                    return "fas fa-check";
                case "completed":
                    return "fas fa-check-double";
                case "rejected":
                    return "fas fa-times";
                default:
                    return "fas fa-question-circle";
            }
        }

        public string GetPaymentMethodBadgeClass(string method)
        {
            return "payment-badge-modern " + method.ToLower().Replace(" ", "-") + "-badge";
        }

        public string BindPaymentMethodIcon(string method)
        {
            switch (method.ToLower())
            {
                case "bank transfer":
                    return "fas fa-university";
                case "mobile money":
                    return "fas fa-mobile-alt";
                case "cash pickup":
                    return "fas fa-hand-holding-usd";
                case "wallet":
                    return "fas fa-wallet";
                default:
                    return "fas fa-money-bill-wave";
            }
        }

        public string GetPaymentDetails(object paymentDetails)
        {
            return "Contact citizen for details";
        }

        public string GetCreditAmount(object amount)
        {
            if (amount == null || amount == DBNull.Value)
                return "0";

            decimal amountValue = Convert.ToDecimal(amount);
            return amountValue.ToString("F0");
        }

        public bool IsApprovable(string status)
        {
            return status == "Pending";
        }

        public bool IsRejectable(string status)
        {
            return status == "Pending";
        }

        public bool IsCompletable(string status)
        {
            return status == "Approved";
        }

        protected void ddlStatusFilter_SelectedIndexChanged(object sender, EventArgs e)
        {
            BindRedemptionHistory();
        }

        protected void ddlMethodFilter_SelectedIndexChanged(object sender, EventArgs e)
        {
            BindRedemptionHistory();
        }

        protected void ddlDateRange_SelectedIndexChanged(object sender, EventArgs e)
        {
            BindRedemptionHistory();
        }

        protected void ddlSortBy_SelectedIndexChanged(object sender, EventArgs e)
        {
            BindRedemptionHistory();
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            BindRedemptionHistory();
        }

        protected void btnClearFilters_Click(object sender, EventArgs e)
        {
            ddlStatusFilter.SelectedValue = "all";
            ddlMethodFilter.SelectedValue = "all";
            ddlDateRange.SelectedValue = "week";
            ddlSortBy.SelectedValue = "recent";
            txtSearch.Text = "";
            BindRedemptionHistory();
            ShowInfoMessage("Filters cleared successfully!");
        }

        protected void btnResetFilters_Click(object sender, EventArgs e)
        {
            btnClearFilters_Click(sender, e);
        }

        protected void btnProcessPending_Click(object sender, EventArgs e)
        {
            ddlStatusFilter.SelectedValue = "Pending";
            BindRedemptionHistory();
            ShowInfoMessage("Showing pending redemption requests");
        }

        protected void btnViewPendingOnly_Click(object sender, EventArgs e)
        {
            ddlStatusFilter.SelectedValue = "Pending";
            BindRedemptionHistory();
            ShowInfoMessage("Showing only pending requests");
        }

        protected void btnGenerateReport_Click(object sender, EventArgs e)
        {
            ShowInfoMessage("Report generation functionality would be implemented here.");
        }

        protected void btnViewStatistics_Click(object sender, EventArgs e)
        {
            ShowInfoMessage("Statistics view would show detailed analytics here.");
        }

        protected void btnRefresh_Click(object sender, EventArgs e)
        {
            BindStats();
            BindRedemptionHistory();
            ShowSuccessMessage("Redemption history refreshed successfully!");
        }

        protected void btnExport_Click(object sender, EventArgs e)
        {
            ShowInfoMessage("Export functionality would be implemented here.");
        }

        private string GetConnectionString()
        {
            return ConfigurationManager.ConnectionStrings["SoorGreenDBConnectionString"].ConnectionString;
        }

        private void LogUserActivity(string userId, string activityType, string description)
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(GetConnectionString()))
                {
                    string query = "INSERT INTO UserActivities (UserId, ActivityType, Description, Timestamp) VALUES (@UserId, @ActivityType, @Description, GETDATE())";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@UserId", userId);
                        cmd.Parameters.AddWithValue("@ActivityType", activityType);
                        cmd.Parameters.AddWithValue("@Description", description);

                        conn.Open();
                        cmd.ExecuteNonQuery();
                    }
                }
            }
            catch
            {
                // Silent catch
            }
        }

        private void ShowSuccessMessage(string message)
        {
            string script = "showToast('" + message.Replace("'", "\\'") + "', 'success');";
            ScriptManager.RegisterStartupScript(this, GetType(), "successToast", script, true);
        }

        private void ShowErrorMessage(string message)
        {
            string script = "showToast('" + message.Replace("'", "\\'") + "', 'error');";
            ScriptManager.RegisterStartupScript(this, GetType(), "errorToast", script, true);
        }

        private void ShowInfoMessage(string message)
        {
            string script = "showToast('" + message.Replace("'", "\\'") + "', 'info');";
            ScriptManager.RegisterStartupScript(this, GetType(), "infoToast", script, true);
        }
    }
}