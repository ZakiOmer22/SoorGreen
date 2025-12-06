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
    public partial class Credits : System.Web.UI.Page
    {
        private string connectionString = WebConfigurationManager.ConnectionStrings["SoorGreenDBConnectionString"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                BindUsers();
            }

            // Handle events from JavaScript
            if (Request["__EVENTTARGET"] == "ctl00$MainContent$hdnUserId")
            {
                string eventArg = Request["__EVENTARGUMENT"];
                if (eventArg.StartsWith("adjust_"))
                {
                    string userId = eventArg.Substring(7);
                    LoadUserForAdjustment(userId);
                }
                else if (eventArg.StartsWith("verify_"))
                {
                    string[] parts = eventArg.Substring(7).Split('_');
                    if (parts.Length == 2)
                    {
                        string userId = parts[0];
                        string currentStatus = parts[1];
                        ToggleUserVerification(userId, currentStatus);
                    }
                }
            }
        }

        private void BindUsers()
        {
            try
            {
                string query = @"SELECT 
                                u.UserId,
                                u.FullName,
                                u.Phone,
                                u.Email,
                                u.RoleId,
                                u.XP_Credits,
                                u.CreatedAt,
                                u.LastLogin,
                                u.IsVerified,
                                r.RoleName
                                FROM Users u
                                JOIN Roles r ON u.RoleId = r.RoleId
                                WHERE 1=1";

                List<SqlParameter> parameters = new List<SqlParameter>();

                // Apply search filter
                if (!string.IsNullOrEmpty(txtSearch.Text))
                {
                    query += " AND (u.FullName LIKE @search OR u.Phone LIKE @search OR u.Email LIKE @search OR u.UserId LIKE @search)";
                    parameters.Add(new SqlParameter("@search", "%" + txtSearch.Text + "%"));
                }

                // Apply role filter
                if (ddlRoleFilter.SelectedValue != "all")
                {
                    query += " AND u.RoleId = @role";
                    parameters.Add(new SqlParameter("@role", ddlRoleFilter.SelectedValue));
                }

                // Apply balance range filter
                decimal balanceFrom, balanceTo;
                if (decimal.TryParse(txtBalanceFrom.Text, out balanceFrom) && balanceFrom >= 0)
                {
                    query += " AND u.XP_Credits >= @balanceFrom";
                    parameters.Add(new SqlParameter("@balanceFrom", balanceFrom));
                }

                if (decimal.TryParse(txtBalanceTo.Text, out balanceTo) && balanceTo > 0)
                {
                    query += " AND u.XP_Credits <= @balanceTo";
                    parameters.Add(new SqlParameter("@balanceTo", balanceTo));
                }

                // Apply verification status filter
                if (ddlVerificationStatus.SelectedValue != "all")
                {
                    if (ddlVerificationStatus.SelectedValue == "verified")
                    {
                        query += " AND u.IsVerified = 1";
                    }
                    else
                    {
                        query += " AND u.IsVerified = 0";
                    }
                }

                query += " ORDER BY u.XP_Credits DESC, u.CreatedAt DESC";

                // Get data from database
                DataTable dt = GetDataTable(query, parameters.ToArray());

                // Bind to repeater for grid view
                rptUsersGrid.DataSource = dt;
                rptUsersGrid.DataBind();

                // Bind to gridview for table view
                gvUsers.DataSource = dt;
                gvUsers.DataBind();

                // Update stats
                UpdateStats(dt);

                // Update user count
                lblUserCount.Text = dt.Rows.Count.ToString();

                // Show message if no data
                if (dt.Rows.Count == 0)
                {
                    ShowMessage("Info", "No users found matching the criteria.", "info");
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Error", "Failed to load users: " + ex.Message, "error");
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
            int totalUsers = dt.Rows.Count;
            decimal totalCredits = 0;
            int verifiedUsers = 0;
            decimal topBalance = 0;

            foreach (DataRow row in dt.Rows)
            {
                decimal balance = Convert.ToDecimal(row["XP_Credits"]);
                totalCredits += balance;

                if (Convert.ToBoolean(row["IsVerified"]))
                {
                    verifiedUsers++;
                }

                if (balance > topBalance)
                {
                    topBalance = balance;
                }
            }

            statTotalUsers.InnerText = totalUsers.ToString();
            statTotalCredits.InnerText = "$" + totalCredits.ToString("N2");
            statVerifiedUsers.InnerText = verifiedUsers.ToString();
            statTopBalance.InnerText = "$" + topBalance.ToString("N2");
        }

        private void LoadUserForAdjustment(string userId)
        {
            try
            {
                string query = @"SELECT 
                                u.UserId,
                                u.FullName,
                                u.Phone,
                                u.Email,
                                u.XP_Credits,
                                u.CreatedAt,
                                u.LastLogin,
                                u.IsVerified,
                                r.RoleName,
                                (SELECT TOP 1 CreatedAt FROM UserActivities 
                                 WHERE UserId = u.UserId 
                                 ORDER BY Timestamp DESC) as LastActivity
                                FROM Users u
                                JOIN Roles r ON u.RoleId = r.RoleId
                                WHERE u.UserId = @UserId";

                using (SqlConnection conn = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@UserId", userId);
                    conn.Open();

                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            hdnUserId.Value = reader["UserId"].ToString();
                            txtUserId.Text = reader["UserId"].ToString();
                            txtUserName.Text = reader["FullName"].ToString();
                            txtUserPhone.Text = reader["Phone"].ToString();
                            txtUserEmail.Text = reader["Email"] != DBNull.Value ? reader["Email"].ToString() : "No email";
                            txtCurrentBalance.Text = Convert.ToDecimal(reader["XP_Credits"]).ToString("N2");
                            txtUserRole.Text = reader["RoleName"].ToString();
                            txtMemberSince.Text = Convert.ToDateTime(reader["CreatedAt"]).ToString("MMMM dd, yyyy");

                            // Verification status - FIXED: Now using the control that exists in your ASPX
                            txtVerificationStatus.Text = Convert.ToBoolean(reader["IsVerified"]) ? "Verified" : "Unverified";

                            // Last login
                            if (reader["LastLogin"] != DBNull.Value)
                            {
                                DateTime lastLogin = Convert.ToDateTime(reader["LastLogin"]);
                                txtLastActivity.Text = lastLogin.ToString("MMMM dd, yyyy HH:mm");
                            }
                            else
                            {
                                txtLastActivity.Text = "Never logged in";
                            }
                        }
                        else
                        {
                            ShowMessage("Error", "User not found.", "error");
                            return;
                        }
                    }
                }

                // Show modal via JavaScript
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ShowAdjustmentModal",
                    "var modal = new bootstrap.Modal(document.getElementById('adjustCreditsModal')); modal.show();", true);
            }
            catch (Exception ex)
            {
                ShowMessage("Error", "Failed to load user: " + ex.Message, "error");
            }
        }

        private void ToggleUserVerification(string userId, string currentStatus)
        {
            try
            {
                bool newStatus = !(currentStatus.ToLower() == "true");

                string query = @"UPDATE Users 
                                SET IsVerified = @IsVerified 
                                WHERE UserId = @UserId";

                using (SqlConnection conn = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@UserId", userId);
                    cmd.Parameters.AddWithValue("@IsVerified", newStatus);

                    conn.Open();
                    cmd.ExecuteNonQuery();
                }

                ShowMessage("Success",
                    string.Format("User verification status updated to: {0}", newStatus ? "Verified" : "Unverified"),
                    "success");

                BindUsers();
            }
            catch (Exception ex)
            {
                ShowMessage("Error", "Failed to update verification status: " + ex.Message, "error");
            }
        }

        // CRUD Operations
        protected void btnApplyAdjustment_Click(object sender, EventArgs e)
        {
            try
            {
                string userId = hdnUserId.Value;
                string adjustmentType = ddlAdjustmentType.SelectedValue;
                string transactionType = ddlTransactionType.SelectedValue;
                string reason = txtAdjustmentReason.Text;
                decimal amount;

                if (!decimal.TryParse(txtAdjustmentAmount.Text, out amount) || amount <= 0)
                {
                    ShowMessage("Error", "Please enter a valid amount greater than 0.", "error");
                    return;
                }

                decimal currentBalance = GetUserBalance(userId);
                decimal adjustmentAmount = amount;
                string description = reason;

                // Determine actual adjustment based on type
                if (adjustmentType == "Deduct")
                {
                    adjustmentAmount = -amount;

                    // Check if user has enough balance
                    if (currentBalance < amount)
                    {
                        ShowMessage("Error",
                            string.Format("User only has ${0:N2} balance. Cannot deduct ${1:N2}.", currentBalance, amount),
                            "error");
                        return;
                    }
                }
                else if (adjustmentType == "Set")
                {
                    // Calculate difference to reach target balance
                    adjustmentAmount = amount - currentBalance;
                    description = string.Format("Balance set to ${0:N2} (was ${1:N2}) - {2}",
                        amount, currentBalance, reason);
                }
                else
                {
                    // Add credits
                    description = string.Format("Credit added: ${0:N2} - {1}", amount, reason);
                }

                // Generate RewardId
                string rewardId = GetNextRewardId();

                // Insert adjustment transaction
                string transactionQuery = @"INSERT INTO RewardPoints 
                                          (RewardId, UserId, Amount, Type, Reference, CreatedAt)
                                          VALUES (@RewardId, @UserId, @Amount, @Type, @Reference, GETDATE())";

                using (SqlConnection conn = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand(transactionQuery, conn))
                {
                    cmd.Parameters.AddWithValue("@RewardId", rewardId);
                    cmd.Parameters.AddWithValue("@UserId", userId);
                    cmd.Parameters.AddWithValue("@Amount", adjustmentAmount);
                    cmd.Parameters.AddWithValue("@Type", transactionType);
                    cmd.Parameters.AddWithValue("@Reference", description);

                    conn.Open();
                    cmd.ExecuteNonQuery();
                }

                // Update user's XP_Credits
                string updateQuery = @"UPDATE Users 
                                      SET XP_Credits = XP_Credits + @Amount 
                                      WHERE UserId = @UserId";

                using (SqlConnection conn = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand(updateQuery, conn))
                {
                    cmd.Parameters.AddWithValue("@UserId", userId);
                    cmd.Parameters.AddWithValue("@Amount", adjustmentAmount);

                    conn.Open();
                    cmd.ExecuteNonQuery();
                }

                // Record activity
                string activityDescription = string.Format("Credit adjustment: {0} ${1:N2}",
                    adjustmentType, Math.Abs(adjustmentAmount));
                RecordUserActivity(userId, "CreditAdjustment", activityDescription, adjustmentAmount);

                ShowMessage("Success",
                    string.Format("Credit adjustment applied successfully! User's new balance: ${0:N2}",
                        currentBalance + adjustmentAmount),
                    "success");

                // Close modal via JavaScript
                ScriptManager.RegisterStartupScript(this, this.GetType(), "CloseModal",
                    "$('#adjustCreditsModal').modal('hide');", true);

                BindUsers();
            }
            catch (Exception ex)
            {
                ShowMessage("Error", "Failed to apply adjustment: " + ex.Message, "error");
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

        private void RecordUserActivity(string userId, string activityType, string description, decimal points)
        {
            try
            {
                string query = @"INSERT INTO UserActivities 
                                (UserId, ActivityType, Description, Points, Timestamp)
                                VALUES (@UserId, @ActivityType, @Description, @Points, GETDATE())";

                using (SqlConnection conn = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@UserId", userId);
                    cmd.Parameters.AddWithValue("@ActivityType", activityType);
                    cmd.Parameters.AddWithValue("@Description", description);
                    cmd.Parameters.AddWithValue("@Points", points);

                    conn.Open();
                    cmd.ExecuteNonQuery();
                }
            }
            catch (Exception ex)
            {
                // Log error but don't break the main flow
                System.Diagnostics.Debug.WriteLine("Failed to record activity: " + ex.Message);
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
                return string.Format("RP{0:D2}", nextId);
            }
        }

        // UI Helper Methods
        public string GetRoleBadgeClass(string roleName)
        {
            switch (roleName.ToLower())
            {
                case "citizen":
                    return "badge-success citizen";
                case "collector":
                    return "badge-primary collector";
                case "admin":
                    return "badge-danger admin";
                case "company":
                    return "badge-warning company";
                default:
                    return "badge-secondary";
            }
        }

        public string GetRoleIconClass(string roleName)
        {
            switch (roleName.ToLower())
            {
                case "citizen": return "citizen";
                case "collector": return "collector";
                case "admin": return "admin";
                case "company": return "company";
                default: return "citizen";
            }
        }

        public string GetRoleIcon(string roleName)
        {
            switch (roleName.ToLower())
            {
                case "citizen": return "fa-user";
                case "collector": return "fa-truck";
                case "admin": return "fa-user-shield";
                case "company": return "fa-building";
                default: return "fa-user";
            }
        }

        public string GetBalanceColorClass(decimal balance)
        {
            if (balance <= 0)
                return "zero";
            else if (balance < 10)
                return "low";
            else if (balance < 50)
                return "medium";
            else
                return "high";
        }

        public int GetTransactionCount(string userId)
        {
            string query = "SELECT COUNT(*) FROM RewardPoints WHERE UserId = @UserId";

            using (SqlConnection conn = new SqlConnection(connectionString))
            using (SqlCommand cmd = new SqlCommand(query, conn))
            {
                cmd.Parameters.AddWithValue("@UserId", userId);
                conn.Open();

                return (int)cmd.ExecuteScalar();
            }
        }

        public int GetRedemptionCount(string userId)
        {
            string query = "SELECT COUNT(*) FROM RedemptionRequests WHERE UserId = @UserId AND Status = 'Approved'";

            using (SqlConnection conn = new SqlConnection(connectionString))
            using (SqlCommand cmd = new SqlCommand(query, conn))
            {
                cmd.Parameters.AddWithValue("@UserId", userId);
                conn.Open();

                return (int)cmd.ExecuteScalar();
            }
        }

        public int GetWasteReportCount(string userId)
        {
            string query = "SELECT COUNT(*) FROM WasteReports WHERE UserId = @UserId";

            using (SqlConnection conn = new SqlConnection(connectionString))
            using (SqlCommand cmd = new SqlCommand(query, conn))
            {
                cmd.Parameters.AddWithValue("@UserId", userId);
                conn.Open();

                return (int)cmd.ExecuteScalar();
            }
        }

        public string GetLastLoginDisplay(object lastLogin)
        {
            if (lastLogin == DBNull.Value || lastLogin == null)
                return "Never";

            DateTime loginDate = Convert.ToDateTime(lastLogin);
            TimeSpan timeSince = DateTime.Now - loginDate;

            if (timeSince.TotalDays < 1)
            {
                if (timeSince.TotalHours < 1)
                    return "Just now";
                else if (timeSince.TotalHours < 2)
                    return "1 hour ago";
                else
                    return string.Format("{0} hours ago", (int)timeSince.TotalHours);
            }
            else if (timeSince.TotalDays < 7)
            {
                if ((int)timeSince.TotalDays == 1)
                    return "Yesterday";
                else
                    return string.Format("{0} days ago", (int)timeSince.TotalDays);
            }
            else if (timeSince.TotalDays < 30)
            {
                int weeks = (int)(timeSince.TotalDays / 7);
                return string.Format("{0} week{1} ago", weeks, weeks > 1 ? "s" : "");
            }
            else
            {
                return loginDate.ToString("MMM dd, yyyy");
            }
        }

        // Event Handlers
        protected void btnApplyFilters_Click(object sender, EventArgs e)
        {
            BindUsers();
        }

        protected void btnClearFilters_Click(object sender, EventArgs e)
        {
            txtSearch.Text = "";
            ddlRoleFilter.SelectedValue = "all";
            txtBalanceFrom.Text = "";
            txtBalanceTo.Text = "";
            ddlVerificationStatus.SelectedValue = "all";
            BindUsers();
        }

        protected void btnRefresh_Click(object sender, EventArgs e)
        {
            BindUsers();
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
                Response.AddHeader("content-disposition", "attachment;filename=User_Credits_Report_" + DateTime.Now.ToString("yyyyMMdd") + ".csv");
                Response.Charset = "";
                Response.ContentType = "application/text";

                DataTable dt = GetUsersDataForExport();
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

        private DataTable GetUsersDataForExport()
        {
            string query = @"SELECT 
                            u.UserId as 'User ID',
                            u.FullName as 'Full Name',
                            u.Phone as 'Phone',
                            u.Email as 'Email',
                            r.RoleName as 'Role',
                            u.XP_Credits as 'Balance ($)',
                            CASE WHEN u.IsVerified = 1 THEN 'Yes' ELSE 'No' END as 'Verified',
                            FORMAT(u.CreatedAt, 'yyyy-MM-dd') as 'Member Since',
                            FORMAT(u.LastLogin, 'yyyy-MM-dd HH:mm') as 'Last Login',
                            (SELECT COUNT(*) FROM RewardPoints WHERE UserId = u.UserId) as 'Total Transactions',
                            (SELECT COUNT(*) FROM RedemptionRequests WHERE UserId = u.UserId AND Status = 'Approved') as 'Redemptions',
                            (SELECT COUNT(*) FROM WasteReports WHERE UserId = u.UserId) as 'Waste Reports',
                            (SELECT ISNULL(SUM(Amount), 0) FROM RewardPoints WHERE UserId = u.UserId AND Amount > 0) as 'Total Earned',
                            (SELECT ISNULL(SUM(Amount), 0) FROM RewardPoints WHERE UserId = u.UserId AND Amount < 0) as 'Total Spent'
                            FROM Users u
                            JOIN Roles r ON u.RoleId = r.RoleId
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
        protected void rptUsersGrid_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            // You can add item-specific data binding here if needed
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