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
    public partial class NotificationsMgmt : System.Web.UI.Page
    {
        private string connectionString = WebConfigurationManager.ConnectionStrings["SoorGreenDBConnectionString"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                BindUsersDropdown();
                BindRolesDropdown();
                BindNotifications();
            }
        }

        private void BindNotifications()
        {
            try
            {
                string query = @"SELECT 
                                n.NotificationId,
                                n.UserId,
                                u.FullName,
                                n.Title,
                                n.Message,
                                'Info' as Type, -- Default type since column doesn't exist
                                ISNULL(n.IsRead, 0) as IsRead,
                                n.CreatedAt,
                                'User' as RecipientType, -- Default value
                                CASE 
                                    WHEN n.Title LIKE '%important%' OR n.Title LIKE '%urgent%' THEN 1
                                    ELSE 0 
                                END as Important,
                                CASE 
                                    WHEN n.Title LIKE '%system%' OR n.Title LIKE '%announcement%' THEN 1
                                    ELSE 0 
                                END as RequireAck
                                FROM Notifications n
                                JOIN Users u ON n.UserId = u.UserId
                                WHERE 1=1";

                List<SqlParameter> parameters = new List<SqlParameter>();

                // Apply filters
                if (!string.IsNullOrEmpty(txtSearch.Text))
                {
                    query += " AND (n.Title LIKE @search OR n.Message LIKE @search OR u.FullName LIKE @search)";
                    parameters.Add(new SqlParameter("@search", "%" + txtSearch.Text + "%"));
                }

                if (ddlType.SelectedValue != "all")
                {
                    // Since Type column doesn't exist, we'll filter based on title keywords
                    if (ddlType.SelectedValue == "Info")
                    {
                        query += " AND (n.Title NOT LIKE '%error%' AND n.Title NOT LIKE '%warning%' AND n.Title NOT LIKE '%success%')";
                    }
                    else if (ddlType.SelectedValue == "Error")
                    {
                        query += " AND (n.Title LIKE '%error%' OR n.Title LIKE '%failed%')";
                    }
                    else if (ddlType.SelectedValue == "Warning")
                    {
                        query += " AND (n.Title LIKE '%warning%' OR n.Title LIKE '%alert%')";
                    }
                    else if (ddlType.SelectedValue == "Success")
                    {
                        query += " AND (n.Title LIKE '%success%' OR n.Title LIKE '%completed%')";
                    }
                    else if (ddlType.SelectedValue == "System")
                    {
                        query += " AND (n.Title LIKE '%system%')";
                    }
                    else if (ddlType.SelectedValue == "Announcement")
                    {
                        query += " AND (n.Title LIKE '%announcement%' OR n.Title LIKE '%update%')";
                    }
                }

                if (ddlStatus.SelectedValue != "all")
                {
                    if (ddlStatus.SelectedValue == "Unread")
                    {
                        query += " AND ISNULL(n.IsRead, 0) = 0";
                    }
                    else if (ddlStatus.SelectedValue == "Read")
                    {
                        query += " AND ISNULL(n.IsRead, 0) = 1";
                    }
                    else if (ddlStatus.SelectedValue == "Important")
                    {
                        query += " AND (n.Title LIKE '%important%' OR n.Title LIKE '%urgent%')";
                    }
                }

                query += " ORDER BY n.CreatedAt DESC";

                DataTable dt = GetDataTable(query, parameters.ToArray());

                // Bind data to all views
                rptNotifications.DataSource = dt;
                rptNotifications.DataBind();

                gvNotifications.DataSource = dt;
                gvNotifications.DataBind();

                // Update stats
                UpdateStats(dt);

                // Update notification count
                lblNotificationCount.Text = dt.Rows.Count.ToString();

                // Show message if no data
                if (dt.Rows.Count == 0)
                {
                    ShowMessage("Info", "No notifications found matching your criteria.", "info");
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Error", "Failed to load notifications: " + ex.Message, "error");
            }
        }

        private void BindUsersDropdown()
        {
            try
            {
                string query = @"SELECT 
                                UserId,
                                FullName + ' (' + Phone + ')' as DisplayName
                                FROM Users
                                ORDER BY FullName";

                ddlSpecificUser.Items.Clear();
                ddlSpecificUser.Items.Add(new ListItem("Select User", ""));

                DataTable dt = GetDataTable(query);
                foreach (DataRow row in dt.Rows)
                {
                    ddlSpecificUser.Items.Add(new ListItem(row["DisplayName"].ToString(), row["UserId"].ToString()));
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Error", "Failed to load users: " + ex.Message, "error");
            }
        }

        private void BindRolesDropdown()
        {
            try
            {
                string query = @"SELECT RoleId, RoleName FROM Roles ORDER BY RoleName";

                ddlUserRole.Items.Clear();
                ddlUserRole.Items.Add(new ListItem("Select Role", ""));

                DataTable dt = GetDataTable(query);
                foreach (DataRow row in dt.Rows)
                {
                    ddlUserRole.Items.Add(new ListItem(row["RoleName"].ToString(), row["RoleId"].ToString()));
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Error", "Failed to load roles: " + ex.Message, "error");
            }
        }

        private void UpdateStats(DataTable dt)
        {
            int totalNotifications = dt.Rows.Count;
            int unreadCount = 0;
            int importantCount = 0;
            int totalRecipients = 0;

            foreach (DataRow row in dt.Rows)
            {
                bool isRead = Convert.ToBoolean(row["IsRead"]);
                bool important = Convert.ToBoolean(row["Important"]);

                if (!isRead)
                {
                    unreadCount++;
                }

                if (important)
                {
                    importantCount++;
                }

                // For now, assuming each notification goes to one user
                totalRecipients++;
            }

            statTotalNotifications.InnerText = totalNotifications.ToString();
            statUnreadNotifications.InnerText = unreadCount.ToString();
            statImportantNotifications.InnerText = importantCount.ToString();
            statTotalRecipients.InnerText = totalRecipients.ToString();
        }

        protected void btnApplyFilters_Click(object sender, EventArgs e)
        {
            BindNotifications();
        }

        protected void btnClearFilters_Click(object sender, EventArgs e)
        {
            txtSearch.Text = "";
            ddlType.SelectedValue = "all";
            ddlStatus.SelectedValue = "all";
            ddlRecipient.SelectedValue = "all";
            BindNotifications();
        }

        protected void btnRefresh_Click(object sender, EventArgs e)
        {
            BindNotifications();
        }

        protected void btnGridView_Click(object sender, EventArgs e)
        {
            pnlCardView.Visible = true;
            pnlTableView.Visible = false;
            btnGridView.CssClass = "view-btn active";
            btnTableView.CssClass = "view-btn";
        }

        protected void btnTableView_Click(object sender, EventArgs e)
        {
            pnlCardView.Visible = false;
            pnlTableView.Visible = true;
            btnGridView.CssClass = "view-btn";
            btnTableView.CssClass = "view-btn active";
        }

        protected void ddlRecipientType_SelectedIndexChanged(object sender, EventArgs e)
        {
            specificUserSection.Visible = (ddlRecipientType.SelectedValue == "Specific");
            roleSection.Visible = (ddlRecipientType.SelectedValue == "Role");
        }

        protected void btnSendNotification_Click(object sender, EventArgs e)
        {
            try
            {
                if (!Page.IsValid)
                {
                    ShowMessage("Error", "Please fill all required fields.", "error");
                    return;
                }

                string title = txtNotificationTitle.Text.Trim();
                string message = txtNotificationMessage.Text.Trim();
                string type = ddlNotificationType.SelectedValue;
                string recipientType = ddlRecipientType.SelectedValue;
                bool important = chkImportant.Checked;
                bool requireAck = chkRequireAck.Checked;
                bool sendEmail = chkSendEmail.Checked;

                List<string> userIds = new List<string>();

                // Determine recipients based on type
                if (recipientType == "All")
                {
                    // Send to all users
                    string query = "SELECT UserId FROM Users WHERE IsVerified = 1";
                    DataTable dt = GetDataTable(query);
                    foreach (DataRow row in dt.Rows)
                    {
                        userIds.Add(row["UserId"].ToString());
                    }
                }
                else if (recipientType == "Specific" && !string.IsNullOrEmpty(ddlSpecificUser.SelectedValue))
                {
                    userIds.Add(ddlSpecificUser.SelectedValue);
                }
                else if (recipientType == "Role" && !string.IsNullOrEmpty(ddlUserRole.SelectedValue))
                {
                    string query = "SELECT UserId FROM Users WHERE RoleId = @RoleId AND IsVerified = 1";
                    SqlParameter[] parameters = new SqlParameter[]
                    {
                        new SqlParameter("@RoleId", ddlUserRole.SelectedValue)
                    };
                    DataTable dt = GetDataTable(query, parameters);
                    foreach (DataRow row in dt.Rows)
                    {
                        userIds.Add(row["UserId"].ToString());
                    }
                }
                else if (recipientType == "Unread")
                {
                    // Get users with unread notifications
                    string query = @"SELECT DISTINCT UserId FROM Notifications 
                                   WHERE IsRead = 0 AND CreatedAt >= DATEADD(DAY, -30, GETDATE())";
                    DataTable dt = GetDataTable(query);
                    foreach (DataRow row in dt.Rows)
                    {
                        userIds.Add(row["UserId"].ToString());
                    }
                }

                if (userIds.Count == 0)
                {
                    ShowMessage("Error", "No recipients selected.", "error");
                    return;
                }

                // Insert notifications for each user
                int successCount = 0;
                foreach (string userId in userIds)
                {
                    string notificationId = GetNextNotificationId();

                    // Since Type column doesn't exist, we'll add it to the title or use a default
                    string finalTitle = title;
                    if (type != "Info")
                    {
                        finalTitle = "[" + type + "] " + title;
                    }

                    string insertQuery = @"INSERT INTO Notifications 
                                        (NotificationId, UserId, Title, Message, CreatedAt)
                                        VALUES (@NotificationId, @UserId, @Title, @Message, GETDATE())";

                    using (SqlConnection conn = new SqlConnection(connectionString))
                    using (SqlCommand cmd = new SqlCommand(insertQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@NotificationId", notificationId);
                        cmd.Parameters.AddWithValue("@UserId", userId);
                        cmd.Parameters.AddWithValue("@Title", finalTitle);
                        cmd.Parameters.AddWithValue("@Message", message);

                        conn.Open();
                        if (cmd.ExecuteNonQuery() > 0)
                        {
                            successCount++;

                            // Log activity
                            LogActivity(userId, "NotificationSent", "Received notification: " + title, 0);
                        }
                    }
                }

                ShowMessage("Success", string.Format("Successfully sent {0} notifications.", successCount), "success");

                // Close modal
                ScriptManager.RegisterStartupScript(this, this.GetType(), "CloseSendModal",
                    "$('#sendNotificationModal').modal('hide');", true);

                // Clear form
                ClearSendForm();

                // Refresh list
                BindNotifications();

                // Log admin action
                LogAction("Send Notification", string.Format("Sent {0} notifications: {1}", successCount, title));
            }
            catch (Exception ex)
            {
                ShowMessage("Error", "Failed to send notification: " + ex.Message, "error");
            }
        }

        protected void btnSaveDraft_Click(object sender, EventArgs e)
        {
            // Save draft logic (could save to a draft table or session)
            ShowMessage("Info", "Draft saved successfully.", "info");
        }

        protected void btnMarkAllReadGlobal_Click(object sender, EventArgs e)
        {
            try
            {
                string query = "UPDATE Notifications SET IsRead = 1 WHERE IsRead = 0";

                using (SqlConnection conn = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    conn.Open();
                    int rowsAffected = cmd.ExecuteNonQuery();

                    ShowMessage("Success", string.Format("Marked {0} notifications as read.", rowsAffected), "success");
                    LogAction("Mark All Read", string.Format("Marked {0} notifications as read", rowsAffected));
                }

                BindNotifications();
            }
            catch (Exception ex)
            {
                ShowMessage("Error", "Failed to mark all as read: " + ex.Message, "error");
            }
        }

        protected void btnMarkAllRead_Click(object sender, EventArgs e)
        {
            string notificationId = hdnNotificationId.Value;
            MarkAsRead(notificationId);

            // Close modal
            ScriptManager.RegisterStartupScript(this, this.GetType(), "CloseDetailsModal",
                "$('#notificationDetailsModal').modal('hide');", true);
        }

        protected void btnDeleteNotification_Click(object sender, EventArgs e)
        {
            string notificationId = hdnNotificationId.Value;
            DeleteNotification(notificationId);

            // Close modal
            ScriptManager.RegisterStartupScript(this, this.GetType(), "CloseDetailsModal",
                "$('#notificationDetailsModal').modal('hide');", true);
        }

        protected void btnBulkDelete_Click(object sender, EventArgs e)
        {
            try
            {
                // For bulk delete, you might want to implement checkbox selection
                // This is a simple implementation - you can enhance it
                string query = "DELETE FROM Notifications WHERE CreatedAt < DATEADD(MONTH, -3, GETDATE())";

                using (SqlConnection conn = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    conn.Open();
                    int rowsAffected = cmd.ExecuteNonQuery();

                    ShowMessage("Success", string.Format("Deleted {0} old notifications.", rowsAffected), "success");
                    LogAction("Bulk Delete", string.Format("Deleted {0} old notifications", rowsAffected));
                }

                BindNotifications();
            }
            catch (Exception ex)
            {
                ShowMessage("Error", "Failed to delete notifications: " + ex.Message, "error");
            }
        }

        // Export Functions
        protected void btnExportCSV_Click(object sender, EventArgs e)
        {
            try
            {
                Response.Clear();
                Response.Buffer = true;
                Response.AddHeader("content-disposition", "attachment;filename=Notifications_" + DateTime.Now.ToString("yyyyMMdd_HHmm") + ".csv");
                Response.Charset = "";
                Response.ContentType = "application/text";

                string query = @"SELECT 
                                n.NotificationId as 'Notification ID',
                                u.FullName as 'Recipient',
                                n.Title as 'Title',
                                'Info' as 'Type',
                                n.Message as 'Message',
                                CASE WHEN ISNULL(n.IsRead, 0) = 1 THEN 'Read' ELSE 'Unread' END as 'Status',
                                FORMAT(n.CreatedAt, 'yyyy-MM-dd HH:mm:ss') as 'Sent Date'
                                FROM Notifications n
                                JOIN Users u ON n.UserId = u.UserId
                                ORDER BY n.CreatedAt DESC";

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

        protected void gvNotifications_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            string notificationId = e.CommandArgument.ToString();

            if (e.CommandName == "View")
            {
                LoadNotificationDetails(notificationId);
            }
            else if (e.CommandName == "MarkRead")
            {
                MarkAsRead(notificationId);
                BindNotifications();
            }
            else if (e.CommandName == "Delete")
            {
                DeleteNotification(notificationId);
                BindNotifications();
            }
        }

        // Page_PreRender for handling JavaScript actions
        protected void Page_PreRender(object sender, EventArgs e)
        {
            if (Request["__EVENTARGUMENT"] != null)
            {
                string eventArg = Request["__EVENTARGUMENT"];
                if (eventArg.StartsWith("view_"))
                {
                    string notificationId = eventArg.Substring(5);
                    LoadNotificationDetails(notificationId);
                }
                else if (eventArg.StartsWith("read_"))
                {
                    string notificationId = eventArg.Substring(5);
                    MarkAsRead(notificationId);
                }
                else if (eventArg.StartsWith("delete_"))
                {
                    string notificationId = eventArg.Substring(7);
                    DeleteNotification(notificationId);
                }
            }
        }

        private void LoadNotificationDetails(string notificationId)
        {
            try
            {
                string query = @"SELECT 
                                n.NotificationId,
                                u.FullName,
                                n.Title,
                                n.Message,
                                'Info' as Type,
                                ISNULL(n.IsRead, 0) as IsRead,
                                n.CreatedAt,
                                'User' as RecipientType
                                FROM Notifications n
                                JOIN Users u ON n.UserId = u.UserId
                                WHERE n.NotificationId = @NotificationId";

                using (SqlConnection conn = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@NotificationId", notificationId);
                    conn.Open();

                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            hdnNotificationId.Value = notificationId;
                            txtDetailId.Text = reader["NotificationId"].ToString();

                            // Extract type from title if present
                            string title = reader["Title"].ToString();
                            txtDetailTitle.Text = title;

                            // Try to extract type from title
                            string type = "Info";
                            if (title.StartsWith("[") && title.Contains("]"))
                            {
                                int endIndex = title.IndexOf("]");
                                type = title.Substring(1, endIndex - 1);
                                txtDetailTitle.Text = title.Substring(endIndex + 1).Trim();
                            }
                            txtDetailType.Text = type;

                            txtDetailRecipient.Text = reader["FullName"].ToString();
                            txtDetailMessage.Text = reader["Message"].ToString();
                            txtDetailStatus.Text = Convert.ToBoolean(reader["IsRead"]) ? "Read" : "Unread";

                            if (reader["CreatedAt"] != DBNull.Value)
                            {
                                txtDetailSentDate.Text = Convert.ToDateTime(reader["CreatedAt"]).ToString("yyyy-MM-dd HH:mm:ss");
                            }
                            else
                            {
                                txtDetailSentDate.Text = "N/A";
                            }

                            // Load read status
                            LoadReadStatus(notificationId);
                        }
                    }
                }

                // Show modal via JavaScript
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ShowDetailsModal",
                    "$('#notificationDetailsModal').modal('show');", true);
            }
            catch (Exception ex)
            {
                ShowMessage("Error", "Failed to load notification details: " + ex.Message, "error");
            }
        }

        private void LoadReadStatus(string notificationId)
        {
            try
            {
                // This is a simplified version - you might need a different approach
                // since Notifications table doesn't track multiple recipients
                string query = @"SELECT 
                                u.FullName as UserName,
                                CASE WHEN n.IsRead = 1 THEN 'Yes' ELSE 'No' END as ReadStatus,
                                n.CreatedAt as ReadDate,
                                'No' as Acknowledged
                                FROM Notifications n
                                JOIN Users u ON n.UserId = u.UserId
                                WHERE n.NotificationId = @NotificationId";

                DataTable dt = GetDataTable(query, new SqlParameter[] { new SqlParameter("@NotificationId", notificationId) });
                gvReadStatus.DataSource = dt;
                gvReadStatus.DataBind();
            }
            catch (Exception ex)
            {
                ShowMessage("Error", "Failed to load read status: " + ex.Message, "error");
            }
        }

        private void MarkAsRead(string notificationId)
        {
            try
            {
                string updateQuery = @"UPDATE Notifications SET IsRead = 1 WHERE NotificationId = @NotificationId";

                using (SqlConnection conn = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand(updateQuery, conn))
                {
                    cmd.Parameters.AddWithValue("@NotificationId", notificationId);
                    conn.Open();
                    int rowsAffected = cmd.ExecuteNonQuery();

                    if (rowsAffected > 0)
                    {
                        ShowMessage("Success", "Notification marked as read.", "success");
                        LogAction("Mark Read", string.Format("Marked notification ID: {0} as read", notificationId));
                    }
                }

                BindNotifications();
            }
            catch (Exception ex)
            {
                ShowMessage("Error", "Failed to mark as read: " + ex.Message, "error");
            }
        }

        private void DeleteNotification(string notificationId)
        {
            try
            {
                string deleteQuery = "DELETE FROM Notifications WHERE NotificationId = @NotificationId";

                using (SqlConnection conn = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand(deleteQuery, conn))
                {
                    cmd.Parameters.AddWithValue("@NotificationId", notificationId);
                    conn.Open();
                    int rowsAffected = cmd.ExecuteNonQuery();

                    if (rowsAffected > 0)
                    {
                        ShowMessage("Success", "Notification deleted successfully.", "success");
                        LogAction("Delete Notification", string.Format("Deleted notification ID: {0}", notificationId));
                    }
                    else
                    {
                        ShowMessage("Error", "Notification not found.", "error");
                    }
                }

                BindNotifications();
            }
            catch (Exception ex)
            {
                ShowMessage("Error", "Failed to delete notification: " + ex.Message, "error");
            }
        }

        private void ClearSendForm()
        {
            txtNotificationTitle.Text = "";
            txtNotificationMessage.Text = "";
            ddlNotificationType.SelectedValue = "Info";
            ddlRecipientType.SelectedValue = "All";
            ddlSpecificUser.SelectedIndex = 0;
            ddlUserRole.SelectedIndex = 0;
            chkImportant.Checked = false;
            chkRequireAck.Checked = false;
            chkSendEmail.Checked = false;
        }

        private string GetNextNotificationId()
        {
            string query = "SELECT ISNULL(MAX(CAST(SUBSTRING(NotificationId, 3, LEN(NotificationId)) AS INT)), 0) + 1 FROM Notifications WHERE NotificationId LIKE 'NT%'";

            using (SqlConnection conn = new SqlConnection(connectionString))
            using (SqlCommand cmd = new SqlCommand(query, conn))
            {
                conn.Open();
                object result = cmd.ExecuteScalar();
                if (result != DBNull.Value && result != null)
                {
                    int nextId = Convert.ToInt32(result);
                    return string.Format("NT{0:D3}", nextId);
                }
                return "NT001";
            }
        }

        private void LogActivity(string userId, string activityType, string description, decimal points)
        {
            try
            {
                string query = @"INSERT INTO UserActivities (UserId, ActivityType, Description, Points, Timestamp)
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
            catch
            {
                // Silently fail
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
                // Silently fail
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

        // Helper Methods for UI - Adjusted for no Type column
        public string GetTypeIcon(string type)
        {
            if (string.IsNullOrEmpty(type))
                return "fa-bell";

            type = type.ToLower();

            if (type.Contains("info")) return "fa-info-circle";
            if (type.Contains("success")) return "fa-check-circle";
            if (type.Contains("warning") || type.Contains("important")) return "fa-exclamation-triangle";
            if (type.Contains("error")) return "fa-times-circle";
            if (type.Contains("system")) return "fa-cogs";
            if (type.Contains("announcement")) return "fa-bullhorn";
            if (type.Contains("promotion")) return "fa-gift";

            return "fa-bell";
        }

        public string GetTypeIconClass(string type)
        {
            if (string.IsNullOrEmpty(type))
                return "notification-icon-info";

            type = type.ToLower();

            if (type.Contains("info")) return "notification-icon-info";
            if (type.Contains("success")) return "notification-icon-success";
            if (type.Contains("warning") || type.Contains("important")) return "notification-icon-warning";
            if (type.Contains("error")) return "notification-icon-error";
            if (type.Contains("system")) return "notification-icon-system";
            if (type.Contains("announcement")) return "notification-icon-announcement";
            if (type.Contains("promotion")) return "notification-icon-promotion";

            return "notification-icon-info";
        }

        public string GetTypeCardClass(string type)
        {
            if (string.IsNullOrEmpty(type))
                return "";

            type = type.ToLower();

            if (type.Contains("info")) return "notification-info";
            if (type.Contains("success")) return "notification-success";
            if (type.Contains("warning") || type.Contains("important")) return "notification-warning";
            if (type.Contains("error")) return "notification-error";

            return "";
        }

        public string GetTypeBadgeClass(string type)
        {
            if (string.IsNullOrEmpty(type))
                return "badge-secondary";

            type = type.ToLower();

            if (type.Contains("info")) return "badge-info";
            if (type.Contains("success")) return "badge-success";
            if (type.Contains("warning") || type.Contains("important")) return "badge-warning";
            if (type.Contains("error")) return "badge-danger";
            if (type.Contains("system")) return "badge-dark";
            if (type.Contains("announcement")) return "badge-primary";
            if (type.Contains("promotion")) return "badge-purple";

            return "badge-secondary";
        }

        public string GetStatusBadgeClass(bool isRead)
        {
            return isRead ? "badge-success" : "badge-warning";
        }

        public string GetStatusClass(bool isRead)
        {
            return isRead ? "text-success" : "text-warning";
        }

        public string GetStatusIcon(bool isRead)
        {
            return isRead ? "fa-check-circle" : "fa-envelope";
        }

        public string GetStatusText(bool isRead)
        {
            return isRead ? "Read" : "Unread";
        }

        public string GetImportantIcon(bool isImportant)
        {
            if (isImportant)
            {
                return "<span class='badge badge-danger me-2'><i class='fas fa-exclamation-circle'></i> Important</span>";
            }
            return "";
        }

        public string GetAckIcon(bool requireAck)
        {
            if (requireAck)
            {
                return "<span class='badge badge-info'><i class='fas fa-hand-paper'></i> Requires Ack</span>";
            }
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

            try
            {
                DateTime dt = Convert.ToDateTime(dateTime);
                return dt.ToString("MMM dd, yyyy HH:mm");
            }
            catch
            {
                return "N/A";
            }
        }

        public string GetDaysAgo(object dateTime)
        {
            if (dateTime == DBNull.Value || dateTime == null)
                return "N/A";

            try
            {
                DateTime dt = Convert.ToDateTime(dateTime);
                TimeSpan diff = DateTime.Now - dt;

                if (diff.TotalDays >= 1)
                {
                    return Math.Round(diff.TotalDays) + " days ago";
                }
                else if (diff.TotalHours >= 1)
                {
                    return Math.Round(diff.TotalHours) + " hours ago";
                }
                else
                {
                    return Math.Round(diff.TotalMinutes) + " minutes ago";
                }
            }
            catch
            {
                return "N/A";
            }
        }

        // Helper to extract type from title
        public string ExtractTypeFromTitle(string title)
        {
            if (string.IsNullOrEmpty(title))
                return "Info";

            title = title.ToLower();

            if (title.Contains("[error]") || title.Contains("error") || title.Contains("failed"))
                return "Error";
            if (title.Contains("[warning]") || title.Contains("warning") || title.Contains("alert"))
                return "Warning";
            if (title.Contains("[success]") || title.Contains("success") || title.Contains("completed"))
                return "Success";
            if (title.Contains("[system]") || title.Contains("system"))
                return "System";
            if (title.Contains("[announcement]") || title.Contains("announcement") || title.Contains("update"))
                return "Announcement";
            if (title.Contains("[promotion]") || title.Contains("promotion") || title.Contains("offer"))
                return "Promotion";
            if (title.Contains("[important]") || title.Contains("important") || title.Contains("urgent"))
                return "Important";

            return "Info";
        }

        public string GetCleanTitle(string title)
        {
            if (string.IsNullOrEmpty(title))
                return title;

            // Remove type prefix if present
            if (title.StartsWith("[") && title.Contains("]"))
            {
                int endIndex = title.IndexOf("]");
                if (endIndex > 0)
                {
                    return title.Substring(endIndex + 1).Trim();
                }
            }
            return title;
        }

        protected void rptNotifications_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            
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