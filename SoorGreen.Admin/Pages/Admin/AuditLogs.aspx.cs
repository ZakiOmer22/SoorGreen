using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Runtime.Remoting.Messaging;
using System.Text;
using System.Web.Configuration;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace SoorGreen.Admin.Admin
{
    public partial class AuditLogs : System.Web.UI.Page
    {
        private string connectionString = WebConfigurationManager.ConnectionStrings["SoorGreenDBConnectionString"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                BindUsersDropdown();
                BindAuditLogs();
            }
        }

        private void BindAuditLogs()
        {
            try
            {
                // Using your existing AuditLogs table structure
                string query = @"SELECT 
                                a.AuditId,
                                a.UserId,
                                ISNULL(u.FullName, 'System') as FullName,
                                ISNULL(r.RoleName, 'System') as RoleName,
                                a.Action,
                                a.Details,
                                a.Timestamp
                                FROM AuditLogs a
                                LEFT JOIN Users u ON a.UserId = u.UserId
                                LEFT JOIN Roles r ON u.RoleId = r.RoleId
                                WHERE 1=1";

                List<SqlParameter> parameters = new List<SqlParameter>();

                // Apply filters
                if (!string.IsNullOrEmpty(txtSearch.Text))
                {
                    query += " AND (a.Action LIKE @search OR a.Details LIKE @search OR u.FullName LIKE @search)";
                    parameters.Add(new SqlParameter("@search", "%" + txtSearch.Text + "%"));
                }

                if (ddlActionType.SelectedValue != "all")
                {
                    query += " AND a.Action LIKE @actionType";
                    parameters.Add(new SqlParameter("@actionType", "%" + ddlActionType.SelectedValue + "%"));
                }

                if (ddlUser.SelectedValue != "all")
                {
                    query += " AND a.UserId = @userId";
                    parameters.Add(new SqlParameter("@userId", ddlUser.SelectedValue));
                }

                if (!string.IsNullOrEmpty(txtDateFrom.Text))
                {
                    query += " AND CONVERT(DATE, a.Timestamp) >= @dateFrom";
                    parameters.Add(new SqlParameter("@dateFrom", txtDateFrom.Text));
                }

                if (!string.IsNullOrEmpty(txtDateTo.Text))
                {
                    query += " AND CONVERT(DATE, a.Timestamp) <= @dateTo";
                    parameters.Add(new SqlParameter("@dateTo", txtDateTo.Text));
                }

                query += " ORDER BY a.Timestamp DESC";

                DataTable dt = GetDataTable(query, parameters.ToArray());

                // Bind data to all views
                rptAuditLogs.DataSource = dt;
                rptAuditLogs.DataBind();

                gvAuditLogs.DataSource = dt;
                gvAuditLogs.DataBind();

                rptTimeline.DataSource = dt;
                rptTimeline.DataBind();

                // Update stats
                UpdateStats(dt);

                // Update log count
                lblLogCount.Text = dt.Rows.Count.ToString();

                // Show message if no data
                if (dt.Rows.Count == 0)
                {
                    ShowMessage("Info", "No audit logs found matching your criteria.", "info");
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Error", "Failed to load audit logs: " + ex.Message, "error");
            }
        }

        private void BindUsersDropdown()
        {
            try
            {
                string query = @"SELECT DISTINCT 
                                u.UserId,
                                u.FullName + ' (' + r.RoleName + ')' as DisplayName
                                FROM Users u
                                JOIN Roles r ON u.RoleId = r.RoleId
                                WHERE EXISTS (SELECT 1 FROM AuditLogs a WHERE a.UserId = u.UserId)
                                ORDER BY u.FullName";

                ddlUser.Items.Clear();
                ddlUser.Items.Add(new ListItem("All Users", "all"));

                DataTable dt = GetDataTable(query);
                foreach (DataRow row in dt.Rows)
                {
                    ddlUser.Items.Add(new ListItem(row["DisplayName"].ToString(), row["UserId"].ToString()));
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Error", "Failed to load users: " + ex.Message, "error");
            }
        }

        private void UpdateStats(DataTable dt)
        {
            int totalLogs = dt.Rows.Count;
            int securityLogs = 0;
            int userActions = 0;
            int errorLogs = 0;

            foreach (DataRow row in dt.Rows)
            {
                string action = row["Action"].ToString().ToLower();

                if (action.Contains("login") || action.Contains("logout") || action.Contains("security"))
                {
                    securityLogs++;
                }
                else if (action.Contains("error") || action.Contains("fail"))
                {
                    errorLogs++;
                }
                else
                {
                    userActions++;
                }
            }

            statTotalLogs.InnerText = totalLogs.ToString();
            statSecurityLogs.InnerText = securityLogs.ToString();
            statUserActions.InnerText = userActions.ToString();
            statErrorLogs.InnerText = errorLogs.ToString();
        }

        protected void btnApplyFilters_Click(object sender, EventArgs e)
        {
            BindAuditLogs();
        }

        protected void btnClearFilters_Click(object sender, EventArgs e)
        {
            txtSearch.Text = "";
            ddlActionType.SelectedValue = "all";
            ddlUser.SelectedValue = "all";
            txtDateFrom.Text = "";
            txtDateTo.Text = "";
            BindAuditLogs();
        }

        protected void btnRefresh_Click(object sender, EventArgs e)
        {
            BindAuditLogs();
        }

        protected void btnGridView_Click(object sender, EventArgs e)
        {
            pnlCardView.Visible = true;
            pnlTableView.Visible = false;
            pnlTimelineView.Visible = false;
            btnGridView.CssClass = "view-btn active";
            btnTableView.CssClass = "view-btn";
            btnTimelineView.CssClass = "view-btn";
        }

        protected void btnTableView_Click(object sender, EventArgs e)
        {
            pnlCardView.Visible = false;
            pnlTableView.Visible = true;
            pnlTimelineView.Visible = false;
            btnGridView.CssClass = "view-btn";
            btnTableView.CssClass = "view-btn active";
            btnTimelineView.CssClass = "view-btn";
        }

        protected void btnTimelineView_Click(object sender, EventArgs e)
        {
            pnlCardView.Visible = false;
            pnlTableView.Visible = false;
            pnlTimelineView.Visible = true;
            btnGridView.CssClass = "view-btn";
            btnTableView.CssClass = "view-btn";
            btnTimelineView.CssClass = "view-btn active";
        }

        // Export Functions
        protected void btnExportCSV_Click(object sender, EventArgs e)
        {
            try
            {
                Response.Clear();
                Response.Buffer = true;
                Response.AddHeader("content-disposition", "attachment;filename=AuditLogs_" + DateTime.Now.ToString("yyyyMMdd_HHmm") + ".csv");
                Response.Charset = "";
                Response.ContentType = "application/text";

                string query = @"SELECT 
                                a.AuditId as 'Log ID',
                                ISNULL(u.FullName, 'System') as 'User',
                                ISNULL(r.RoleName, 'System') as 'Role',
                                a.Action as 'Action Type',
                                a.Details as 'Details',
                                FORMAT(a.Timestamp, 'yyyy-MM-dd HH:mm:ss') as 'Timestamp'
                                FROM AuditLogs a
                                LEFT JOIN Users u ON a.UserId = u.UserId
                                LEFT JOIN Roles r ON u.RoleId = r.RoleId
                                ORDER BY a.Timestamp DESC";

                DataTable dt = GetDataTable(query);

                // Convert to CSV
                StringBuilder sb = new StringBuilder();

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

                Response.Output.Write(sb.ToString());
                Response.Flush();
                Response.End();
            }
            catch (Exception ex)
            {
                ShowMessage("Error", "Failed to export CSV: " + ex.Message, "error");
            }
        }

        // Log Management Functions
        protected void btnClearOldLogs_Click(object sender, EventArgs e)
        {
            try
            {
                int days = Convert.ToInt32(ddlClearDays.SelectedValue);

                string deleteQuery = @"DELETE FROM AuditLogs 
                                     WHERE Timestamp < DATEADD(DAY, -@days, GETDATE())";

                using (SqlConnection conn = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand(deleteQuery, conn))
                {
                    cmd.Parameters.AddWithValue("@days", days);
                    conn.Open();
                    int rowsDeleted = cmd.ExecuteNonQuery();

                    ShowMessage("Success", "Successfully deleted " + rowsDeleted + " logs older than " + days + " days.", "success");
                }

                // Log this action
                LogAction("Clear Old Logs", "Cleared logs older than " + days + " days");

                // Close modal and refresh
                ScriptManager.RegisterStartupScript(this, this.GetType(), "CloseClearModal",
                    "$('#clearLogsModal').modal('hide');", true);

                BindAuditLogs();
            }
            catch (Exception ex)
            {
                ShowMessage("Error", "Failed to clear old logs: " + ex.Message, "error");
            }
        }

        protected void btnPurgeLogs_Click(object sender, EventArgs e)
        {
            try
            {
                if (txtPurgeConfirm.Text != "PURGE")
                {
                    ShowMessage("Error", "Please type 'PURGE' to confirm.", "error");
                    return;
                }

                string deleteQuery = "DELETE FROM AuditLogs";

                using (SqlConnection conn = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand(deleteQuery, conn))
                {
                    conn.Open();
                    int rowsDeleted = cmd.ExecuteNonQuery();

                    ShowMessage("Success", "Successfully purged all " + rowsDeleted + " audit logs.", "success");
                }

                // Log this action (will be the only log left!)
                LogAction("Purge All Logs", "Purged all audit logs from system");

                // Close modal and refresh
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ClosePurgeModal",
                    "$('#purgeLogsModal').modal('hide');", true);

                BindAuditLogs();
            }
            catch (Exception ex)
            {
                ShowMessage("Error", "Failed to purge logs: " + ex.Message, "error");
            }
        }

        private void LogAction(string action, string details)
        {
            try
            {
                string query = @"INSERT INTO AuditLogs (AuditId, UserId, Action, Details, Timestamp)
                               VALUES (@AuditId, @UserId, @Action, @Details, GETDATE())";

                using (SqlConnection conn = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    string auditId = GetNextAuditId();
                    string userId = Session["UserId"] != null ? Session["UserId"].ToString() : "SYS";

                    cmd.Parameters.AddWithValue("@AuditId", auditId);
                    cmd.Parameters.AddWithValue("@UserId", userId);
                    cmd.Parameters.AddWithValue("@Action", action);
                    cmd.Parameters.AddWithValue("@Details", details);

                    conn.Open();
                    cmd.ExecuteNonQuery();
                }
            }
            catch
            {
                // Silently fail if logging fails
            }
        }

        private string GetNextAuditId()
        {
            string query = "SELECT ISNULL(MAX(CAST(SUBSTRING(AuditId, 3, LEN(AuditId)) AS INT)), 0) + 1 FROM AuditLogs WHERE AuditId LIKE 'AL%'";

            using (SqlConnection conn = new SqlConnection(connectionString))
            using (SqlCommand cmd = new SqlCommand(query, conn))
            {
                conn.Open();
                object result = cmd.ExecuteScalar();
                if (result != DBNull.Value && result != null)
                {
                    int nextId = Convert.ToInt32(result);
                    return string.Format("AL{0:D3}", nextId);
                }
                return "AL001";
            }
        }

        // Helper Methods for UI
        public string GetActionIcon(string action)
        {
            action = action.ToLower();

            if (action.Contains("login")) return "fa-sign-in-alt";
            if (action.Contains("logout")) return "fa-sign-out-alt";
            if (action.Contains("create")) return "fa-plus-circle";
            if (action.Contains("update")) return "fa-edit";
            if (action.Contains("delete")) return "fa-trash";
            if (action.Contains("export")) return "fa-file-export";
            if (action.Contains("error")) return "fa-exclamation-triangle";
            if (action.Contains("security")) return "fa-shield-alt";
            if (action.Contains("system")) return "fa-cogs";

            return "fa-file-alt";
        }

        public string GetActionBadgeClass(string action)
        {
            action = action.ToLower();

            if (action.Contains("login") || action.Contains("logout")) return "badge-info";
            if (action.Contains("create")) return "badge-success";
            if (action.Contains("update")) return "badge-primary";
            if (action.Contains("delete")) return "badge-danger";
            if (action.Contains("error")) return "badge-warning";
            if (action.Contains("security")) return "badge-dark";

            return "badge-secondary";
        }

        public string GetLogCardClass(string action)
        {
            action = action.ToLower();

            if (action.Contains("error")) return "audit-error";
            if (action.Contains("delete")) return "audit-warning";
            if (action.Contains("create")) return "audit-success";
            if (action.Contains("security")) return "audit-info";

            return "";
        }

        public string GetTimelineItemClass(string action)
        {
            action = action.ToLower();

            if (action.Contains("error")) return "error";
            if (action.Contains("delete")) return "warning";
            if (action.Contains("create")) return "success";

            return "";
        }

        public string TruncateText(string text, int maxLength)
        {
            if (string.IsNullOrEmpty(text) || text.Length <= maxLength)
                return text;

            return text.Substring(0, maxLength) + "...";
        }

        public string GetFormattedDateTime(object dateTime)
        {
            if (dateTime == DBNull.Value || dateTime == null)
                return "N/A";

            DateTime dt = Convert.ToDateTime(dateTime);
            return dt.ToString("MMM dd, yyyy HH:mm");
        }

        public string GetFormattedDate(object dateTime)
        {
            if (dateTime == DBNull.Value || dateTime == null)
                return "N/A";

            DateTime dt = Convert.ToDateTime(dateTime);
            return dt.ToString("yyyy-MM-dd");
        }

        protected void rptAuditLogs_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            
        }

        // Handle view/delete from JavaScript
        protected void Page_PreRender(object sender, EventArgs e)
        {
            if (Request["__EVENTARGUMENT"] != null)
            {
                string eventArg = Request["__EVENTARGUMENT"];
                if (eventArg.StartsWith("view_"))
                {
                    string logId = eventArg.Substring(5);
                    LoadLogDetails(logId);
                }
                else if (eventArg.StartsWith("delete_"))
                {
                    string logId = eventArg.Substring(7);
                    DeleteLog(logId);
                }
            }
        }

        private void LoadLogDetails(string logId)
        {
            try
            {
                string query = @"SELECT 
                                a.AuditId,
                                ISNULL(u.FullName, 'System') as FullName,
                                ISNULL(r.RoleName, 'System') as RoleName,
                                a.Action,
                                a.Details,
                                a.Timestamp
                                FROM AuditLogs a
                                LEFT JOIN Users u ON a.UserId = u.UserId
                                LEFT JOIN Roles r ON u.RoleId = r.RoleId
                                WHERE a.AuditId = @AuditId";

                using (SqlConnection conn = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@AuditId", logId);
                    conn.Open();

                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            txtLogId.Text = reader["AuditId"].ToString();
                            txtUserName.Text = reader["FullName"].ToString();
                            txtUserRole.Text = reader["RoleName"].ToString();
                            txtActionType.Text = reader["Action"].ToString();
                            txtTimestamp.Text = Convert.ToDateTime(reader["Timestamp"]).ToString("yyyy-MM-dd HH:mm:ss");
                            txtDate.Text = Convert.ToDateTime(reader["Timestamp"]).ToString("yyyy-MM-dd");
                            txtActionDetails.Text = reader["Details"].ToString();
                        }
                    }
                }

                // Show modal via JavaScript
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ShowLogDetailsModal",
                    "$('#logDetailsModal').modal('show');", true);
            }
            catch (Exception ex)
            {
                ShowMessage("Error", "Failed to load log details: " + ex.Message, "error");
            }
        }

        private void DeleteLog(string logId)
        {
            try
            {
                string deleteQuery = "DELETE FROM AuditLogs WHERE AuditId = @AuditId";

                using (SqlConnection conn = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand(deleteQuery, conn))
                {
                    cmd.Parameters.AddWithValue("@AuditId", logId);
                    conn.Open();
                    int rowsAffected = cmd.ExecuteNonQuery();

                    if (rowsAffected > 0)
                    {
                        ShowMessage("Success", "Log entry deleted successfully.", "success");
                        LogAction("Delete Log", "Deleted audit log: " + logId);
                    }
                    else
                    {
                        ShowMessage("Error", "Log entry not found.", "error");
                    }
                }

                BindAuditLogs();
            }
            catch (Exception ex)
            {
                ShowMessage("Error", "Failed to delete log: " + ex.Message, "error");
            }
        }

        // Data Access Helper
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

            // Auto-hide message
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