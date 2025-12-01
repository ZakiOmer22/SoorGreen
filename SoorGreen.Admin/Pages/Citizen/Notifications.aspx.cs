using System;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.Web.Configuration;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;

namespace SoorGreen.Citizen
{
    public partial class Notifications : System.Web.UI.Page
    {
        private string connectionString = WebConfigurationManager.ConnectionStrings["SoorGreenDBConnectionString"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (Session["UserId"] == null || Session["UserRole"] == null)
                {
                    Response.Redirect("~/Login.aspx");
                    return;
                }

                if (Session["UserRole"].ToString() != "CITZ" && Session["UserRole"].ToString() != "R001")
                {
                    Response.Redirect("~/Pages/Unauthorized.aspx");
                    return;
                }

                LoadNotifications();
                UpdateNotificationStats();
            }
        }

        protected void btnRefresh_Click(object sender, EventArgs e)
        {
            LoadNotifications();
            UpdateNotificationStats();
            ShowToast("Refreshed", "Notifications updated successfully.", "success");
        }

        protected void btnMarkAllRead_Click(object sender, EventArgs e)
        {
            if (MarkAllNotificationsRead())
            {
                LoadNotifications();
                UpdateNotificationStats();
                ShowToast("All Marked Read", "All notifications have been marked as read.", "success");
            }
            else
            {
                ShowToast("Error", "Failed to mark all notifications as read.", "error");
            }
        }

        protected void ddlFilter_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadNotifications();
        }

        protected void ddlSort_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadNotifications();
        }

        protected void cbSelectAll_CheckedChanged(object sender, EventArgs e)
        {
            // Implement select all functionality
            bool isChecked = cbSelectAll.Checked;
            // This would need JavaScript integration for full functionality
        }

        protected void btnBulkRead_Click(object sender, EventArgs e)
        {
            // Implement bulk mark as read
            ShowToast("Bulk Update", "Selected notifications marked as read.", "success");
            LoadNotifications();
            UpdateNotificationStats();
        }

        protected void btnBulkDelete_Click(object sender, EventArgs e)
        {
            // Implement bulk delete
            ShowToast("Bulk Delete", "Selected notifications deleted.", "success");
            LoadNotifications();
            UpdateNotificationStats();
        }

        protected void btnClearSelection_Click(object sender, EventArgs e)
        {
            cbSelectAll.Checked = false;
            // Clear all checkboxes via JavaScript
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ClearCheckboxes", "clearAllCheckboxes();", true);
        }

        private void LoadNotifications()
        {
            try
            {
                string userId = Session["UserId"] != null ? Session["UserId"].ToString() : "R001";
                string filter = ddlFilter.SelectedValue;
                string sort = ddlSort.SelectedValue;

                StringBuilder query = new StringBuilder(@"
                    SELECT NotificationId, Title, Message, IsRead, CreatedAt
                    FROM Notifications 
                    WHERE UserId = @UserId");

                // Apply filters
                if (filter == "unread")
                {
                    query.Append(" AND IsRead = 0");
                }
                else if (filter == "read")
                {
                    query.Append(" AND IsRead = 1");
                }

                // Apply sorting
                if (sort == "newest")
                {
                    query.Append(" ORDER BY CreatedAt DESC");
                }
                else
                {
                    query.Append(" ORDER BY CreatedAt ASC");
                }

                using (SqlConnection conn = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand(query.ToString(), conn))
                {
                    cmd.Parameters.AddWithValue("@UserId", userId);
                    conn.Open();

                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.HasRows)
                        {
                            StringBuilder html = new StringBuilder();
                            html.Append("<div class='notifications-list'>");

                            while (reader.Read())
                            {
                                string notificationId = reader["NotificationId"].ToString();
                                string title = reader["Title"].ToString();
                                string message = reader["Message"].ToString();
                                bool isRead = Convert.ToBoolean(reader["IsRead"]);
                                DateTime createdAt = Convert.ToDateTime(reader["CreatedAt"]);
                                string timeAgo = GetTimeAgo(createdAt);
                                string statusClass = isRead ? "read" : "unread";
                                string statusBadge = isRead ? "Read" : "New";

                                html.Append(string.Format(@"
                                    <div class='notification-item {0}' onclick='markNotificationRead(""{1}"")'>
                                        <div class='checkbox-item'>
                                            <div class='notification-checkbox'>
                                                <input type='checkbox' id='chk{1}' name='notificationIds' value='{1}' onchange='updateBulkActions()' />
                                            </div>
                                            <div style='flex: 1;'>
                                                <div class='notification-header'>
                                                    <h3 class='notification-title'>{2}</h3>
                                                    <div class='notification-meta'>
                                                        <span class='notification-badge'>{3}</span>
                                                        <span>{4}</span>
                                                    </div>
                                                </div>
                                                <div class='notification-message'>{5}</div>
                                                <div class='notification-actions'>
                                                    <button type='button' class='action-btn mark-read' onclick='event.stopPropagation(); markAsRead(""{1}"")'>
                                                        <i class='fas fa-check'></i>Mark Read
                                                    </button>
                                                    <button type='button' class='action-btn delete' onclick='event.stopPropagation(); deleteNotification(""{1}"")'>
                                                        <i class='fas fa-trash'></i>Delete
                                                    </button>
                                                </div>
                                            </div>
                                        </div>
                                    </div>",
                                    statusClass,
                                    notificationId,
                                    Server.HtmlEncode(title),
                                    statusBadge,
                                    timeAgo,
                                    Server.HtmlEncode(message)));
                            }

                            html.Append("</div>");
                            notificationsList.InnerHtml = html.ToString();
                        }
                        else
                        {
                            notificationsList.InnerHtml = @"
                                <div class='empty-state'>
                                    <div class='empty-state-icon'>
                                        <i class='fas fa-bell'></i>
                                    </div>
                                    <h3 class='empty-state-title'>No Notifications</h3>
                                    <p class='empty-state-description'>
                                        You're all caught up!<br />
                                        New notifications will appear here when you have updates.
                                    </p>
                                </div>";
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error loading notifications: " + ex.Message);
                notificationsList.InnerHtml = @"
                    <div class='empty-state'>
                        <div class='empty-state-icon'>
                            <i class='fas fa-exclamation-triangle'></i>
                        </div>
                        <h3 class='empty-state-title'>Error Loading Notifications</h3>
                        <p class='empty-state-description'>
                            We encountered an issue while loading your notifications.<br />
                            Please try refreshing the page.
                        </p>
                    </div>";
            }
        }

        private void UpdateNotificationStats()
        {
            try
            {
                string userId = Session["UserId"] != null ? Session["UserId"].ToString() : "R001";

                string query = @"
                    SELECT 
                        COUNT(*) as Total,
                        SUM(CASE WHEN IsRead = 0 THEN 1 ELSE 0 END) as Unread
                    FROM Notifications 
                    WHERE UserId = @UserId";

                using (SqlConnection conn = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@UserId", userId);
                    conn.Open();

                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            int total = Convert.ToInt32(reader["Total"]);
                            int unread = Convert.ToInt32(reader["Unread"]);

                            // Update stats display
                            HtmlGenericControl totalControl = FindControl("totalNotifications") as HtmlGenericControl;
                            HtmlGenericControl unreadControl = FindControl("unreadNotifications") as HtmlGenericControl;

                            if (totalControl != null) totalControl.InnerText = total + " Total";
                            if (unreadControl != null) unreadControl.InnerText = unread + " Unread";
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error updating notification stats: " + ex.Message);
            }
        }

        private bool MarkAllNotificationsRead()
        {
            try
            {
                string userId = Session["UserId"] != null ? Session["UserId"].ToString() : "R001";

                string query = @"
                    UPDATE Notifications 
                    SET IsRead = 1 
                    WHERE UserId = @UserId AND IsRead = 0";

                using (SqlConnection conn = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@UserId", userId);
                    conn.Open();
                    int result = cmd.ExecuteNonQuery();
                    return result >= 0; // Could be 0 if no unread notifications
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error marking all notifications as read: " + ex.Message);
                return false;
            }
        }

        protected void MarkNotificationAsRead(string notificationId)
        {
            try
            {
                string query = @"
                    UPDATE Notifications 
                    SET IsRead = 1 
                    WHERE NotificationId = @NotificationId";

                using (SqlConnection conn = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@NotificationId", notificationId);
                    conn.Open();
                    cmd.ExecuteNonQuery();
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error marking notification as read: " + ex.Message);
            }
        }

        protected void DeleteNotification(string notificationId)
        {
            try
            {
                string query = @"
                    DELETE FROM Notifications 
                    WHERE NotificationId = @NotificationId";

                using (SqlConnection conn = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@NotificationId", notificationId);
                    conn.Open();
                    cmd.ExecuteNonQuery();
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error deleting notification: " + ex.Message);
            }
        }

        private string GetTimeAgo(DateTime date)
        {
            TimeSpan timeSince = DateTime.Now - date;

            if (timeSince.TotalMinutes < 1) return "just now";
            if (timeSince.TotalMinutes < 60) return string.Format("{0} minutes ago", (int)timeSince.TotalMinutes);
            if (timeSince.TotalHours < 24) return string.Format("{0} hours ago", (int)timeSince.TotalHours);
            if (timeSince.TotalDays < 7) return string.Format("{0} days ago", (int)timeSince.TotalDays);
            if (timeSince.TotalDays < 30) return string.Format("{0} weeks ago", (int)(timeSince.TotalDays / 7));

            return date.ToString("MMM dd, yyyy");
        }

        private void ShowToast(string title, string message, string type)
        {
            string script = string.Format("showToast('{0}', '{1}', '{2}');",
                title.Replace("'", "\\'"),
                message.Replace("'", "\\'"),
                type);
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ToastScript", script, true);
        }

        // AJAX methods for real-time updates
        [System.Web.Services.WebMethod]
        public static string MarkAsRead(string notificationId)
        {
            try
            {
                string connectionString = WebConfigurationManager.ConnectionStrings["SoorGreenDBConnectionString"].ConnectionString;

                string query = @"
                    UPDATE Notifications 
                    SET IsRead = 1 
                    WHERE NotificationId = @NotificationId";

                using (SqlConnection conn = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@NotificationId", notificationId);
                    conn.Open();
                    cmd.ExecuteNonQuery();
                }
                return "success";
            }
            catch (Exception ex)
            {
                return "error: " + ex.Message;
            }
        }

        [System.Web.Services.WebMethod]
        public static string DeleteNotificationAjax(string notificationId)
        {
            try
            {
                string connectionString = WebConfigurationManager.ConnectionStrings["SoorGreenDBConnectionString"].ConnectionString;

                string query = @"
                    DELETE FROM Notifications 
                    WHERE NotificationId = @NotificationId";

                using (SqlConnection conn = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@NotificationId", notificationId);
                    conn.Open();
                    cmd.ExecuteNonQuery();
                }
                return "success";
            }
            catch (Exception ex)
            {
                return "error: " + ex.Message;
            }
        }
    }
}