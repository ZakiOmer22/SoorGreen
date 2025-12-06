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
    public partial class Feedbacks : System.Web.UI.Page
    {
        private string connectionString = WebConfigurationManager.ConnectionStrings["SoorGreenDBConnectionString"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                BindUsersDropdown();
                BindFeedbacks();
            }
        }

        private void BindFeedbacks()
        {
            try
            {
                // Using your actual Feedbacks table structure (no Status column)
                string query = @"SELECT 
                                f.FeedbackId,
                                f.UserId,
                                u.FullName,
                                ISNULL(f.Category, 'General') as Category,
                                ISNULL(f.Priority, 'Medium') as Priority,
                                ISNULL(f.Subject, 'No Subject') as Subject,
                                ISNULL(f.Rating, 0) as Rating,
                                ISNULL(f.Message, '') as Message,
                                f.CreatedAt,
                                ISNULL(f.FollowUp, 0) as FollowUp
                                FROM Feedbacks f
                                JOIN Users u ON f.UserId = u.UserId
                                WHERE 1=1";

                List<SqlParameter> parameters = new List<SqlParameter>();

                // Apply filters
                if (!string.IsNullOrEmpty(txtSearch.Text))
                {
                    query += " AND (f.Subject LIKE @search OR f.Message LIKE @search OR u.FullName LIKE @search)";
                    parameters.Add(new SqlParameter("@search", "%" + txtSearch.Text + "%"));
                }

                if (ddlCategory.SelectedValue != "all")
                {
                    query += " AND ISNULL(f.Category, 'General') = @category";
                    parameters.Add(new SqlParameter("@category", ddlCategory.SelectedValue));
                }

                if (ddlPriority.SelectedValue != "all")
                {
                    query += " AND ISNULL(f.Priority, 'Medium') = @priority";
                    parameters.Add(new SqlParameter("@priority", ddlPriority.SelectedValue));
                }

                if (ddlUser.SelectedValue != "all")
                {
                    query += " AND f.UserId = @userId";
                    parameters.Add(new SqlParameter("@userId", ddlUser.SelectedValue));
                }

                query += " ORDER BY f.CreatedAt DESC";

                DataTable dt = GetDataTable(query, parameters.ToArray());

                // Bind data to all views
                rptFeedbacks.DataSource = dt;
                rptFeedbacks.DataBind();

                gvFeedbacks.DataSource = dt;
                gvFeedbacks.DataBind();

                // Update stats
                UpdateStats(dt);

                // Update feedback count
                lblFeedbackCount.Text = dt.Rows.Count.ToString();

                // Show message if no data
                if (dt.Rows.Count == 0)
                {
                    ShowMessage("Info", "No feedback found matching your criteria.", "info");
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Error", "Failed to load feedback: " + ex.Message, "error");
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
                                WHERE EXISTS (SELECT 1 FROM Feedbacks f WHERE f.UserId = u.UserId)
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
            int totalFeedbacks = dt.Rows.Count;
            int highPriority = 0;
            int followUpRequired = 0;
            decimal totalRating = 0;
            int ratedFeedbacks = 0;

            foreach (DataRow row in dt.Rows)
            {
                string priority = row["Priority"].ToString();
                bool followUp = Convert.ToBoolean(row["FollowUp"]);
                int rating = Convert.ToInt32(row["Rating"]);

                if (priority == "High")
                {
                    highPriority++;
                }

                if (followUp)
                {
                    followUpRequired++;
                }

                if (rating > 0)
                {
                    totalRating += rating;
                    ratedFeedbacks++;
                }
            }

            statTotalFeedbacks.InnerText = totalFeedbacks.ToString();
            statHighPriority.InnerText = highPriority.ToString();
            statOpenFeedbacks.InnerText = followUpRequired.ToString(); // Using FollowUp as "Open" indicator

            decimal avgRating = ratedFeedbacks > 0 ? totalRating / ratedFeedbacks : 0;
            statAvgRating.InnerText = avgRating.ToString("F1");
        }

        protected void btnApplyFilters_Click(object sender, EventArgs e)
        {
            BindFeedbacks();
        }

        protected void btnClearFilters_Click(object sender, EventArgs e)
        {
            txtSearch.Text = "";
            ddlCategory.SelectedValue = "all";
            ddlPriority.SelectedValue = "all";
            ddlUser.SelectedValue = "all";
            BindFeedbacks();
        }

        protected void btnRefresh_Click(object sender, EventArgs e)
        {
            BindFeedbacks();
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

        // Export Functions
        protected void btnExportCSV_Click(object sender, EventArgs e)
        {
            try
            {
                Response.Clear();
                Response.Buffer = true;
                Response.AddHeader("content-disposition", "attachment;filename=Feedbacks_" + DateTime.Now.ToString("yyyyMMdd_HHmm") + ".csv");
                Response.Charset = "";
                Response.ContentType = "application/text";

                string query = @"SELECT 
                                f.FeedbackId as 'Feedback ID',
                                u.FullName as 'Submitted By',
                                ISNULL(f.Category, 'General') as 'Category',
                                ISNULL(f.Priority, 'Medium') as 'Priority',
                                ISNULL(f.Subject, 'No Subject') as 'Subject',
                                ISNULL(f.Rating, 0) as 'Rating',
                                ISNULL(f.Message, '') as 'Message',
                                FORMAT(f.CreatedAt, 'yyyy-MM-dd HH:mm:ss') as 'Submitted Date',
                                CASE WHEN ISNULL(f.FollowUp, 0) = 1 THEN 'Yes' ELSE 'No' END as 'Follow Up Required'
                                FROM Feedbacks f
                                JOIN Users u ON f.UserId = u.UserId
                                ORDER BY f.CreatedAt DESC";

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

        // Feedback Management Functions
        protected void btnSaveResponse_Click(object sender, EventArgs e)
        {
            try
            {
                string feedbackId = hdnFeedbackId.Value;
                string response = txtAdminResponse.Text.Trim();
                bool followUp = ddlStatus.SelectedValue != "Closed"; // Using status dropdown for follow-up

                if (string.IsNullOrEmpty(feedbackId))
                {
                    ShowMessage("Error", "No feedback selected.", "error");
                    return;
                }

                // Update feedback with follow-up status (since no Status column)
                string updateQuery = @"UPDATE Feedbacks SET 
                                     FollowUp = @FollowUp
                                     WHERE FeedbackId = @FeedbackId";

                using (SqlConnection conn = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand(updateQuery, conn))
                {
                    cmd.Parameters.AddWithValue("@FeedbackId", feedbackId);
                    cmd.Parameters.AddWithValue("@FollowUp", followUp);

                    conn.Open();
                    int rowsAffected = cmd.ExecuteNonQuery();

                    if (rowsAffected > 0)
                    {
                        ShowMessage("Success", "Feedback updated successfully.", "success");

                        // Log this action
                        LogAction("Update Feedback", "Updated feedback ID: " + feedbackId + " with follow-up: " + followUp);

                        if (!string.IsNullOrEmpty(response))
                        {
                            // Save response to another table or add to message
                            LogAction("Admin Response", "Response to feedback ID: " + feedbackId + " - " + response);
                        }
                    }
                    else
                    {
                        ShowMessage("Error", "Feedback not found.", "error");
                    }
                }

                // Close modal and refresh
                ScriptManager.RegisterStartupScript(this, this.GetType(), "CloseFeedbackModal",
                    "$('#feedbackDetailsModal').modal('hide');", true);

                BindFeedbacks();
            }
            catch (Exception ex)
            {
                ShowMessage("Error", "Failed to save response: " + ex.Message, "error");
            }
        }

        protected void btnDeleteFeedback_Click(object sender, EventArgs e)
        {
            string feedbackId = hdnFeedbackId.Value;
            DeleteFeedback(feedbackId);

            // Close modal
            ScriptManager.RegisterStartupScript(this, this.GetType(), "CloseFeedbackModal",
                "$('#feedbackDetailsModal').modal('hide');", true);
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

        // Helper Methods for UI - Adjusted for no Status column
        public string GetCategoryIcon(string category)
        {
            if (string.IsNullOrEmpty(category))
                return "fa-comment";

            category = category.ToLower();

            if (category.Contains("bug")) return "fa-bug";
            if (category.Contains("technical")) return "fa-cogs";
            if (category.Contains("feature")) return "fa-lightbulb";
            if (category.Contains("complaint")) return "fa-exclamation-circle";
            if (category.Contains("suggestion")) return "fa-comment-dots";

            return "fa-comment";
        }

        public string GetPriorityBadgeClass(string priority)
        {
            if (string.IsNullOrEmpty(priority))
                return "badge-secondary";

            priority = priority.ToLower();

            if (priority.Contains("high")) return "badge-danger";
            if (priority.Contains("medium")) return "badge-warning";
            if (priority.Contains("low")) return "badge-success";

            return "badge-secondary";
        }

        public string GetPriorityCardClass(string priority)
        {
            if (string.IsNullOrEmpty(priority))
                return "";

            priority = priority.ToLower();

            if (priority.Contains("high")) return "feedback-high";
            if (priority.Contains("medium")) return "feedback-medium";
            if (priority.Contains("low")) return "feedback-low";

            return "";
        }

        // Since no Status column, we'll use FollowUp to determine "status"
        public string GetStatusClass(object followUpObj)
        {
            if (followUpObj == DBNull.Value || followUpObj == null)
                return "status-closed";

            try
            {
                bool followUp = Convert.ToBoolean(followUpObj);
                return followUp ? "status-open" : "status-closed";
            }
            catch
            {
                return "status-closed";
            }
        }

        public string GetStatusText(object followUpObj)
        {
            if (followUpObj == DBNull.Value || followUpObj == null)
                return "Closed";

            try
            {
                bool followUp = Convert.ToBoolean(followUpObj);
                return followUp ? "Open" : "Closed";
            }
            catch
            {
                return "Closed";
            }
        }

        public string GetRatingStars(int rating)
        {
            if (rating <= 0) rating = 0;

            string stars = "";
            for (int i = 1; i <= 5; i++)
            {
                if (i <= rating)
                {
                    stars += "<i class='fas fa-star'></i>";
                }
                else
                {
                    stars += "<i class='far fa-star'></i>";
                }
            }
            return stars;
        }

        public string GetFollowUpIcon(object followUpObj)
        {
            if (followUpObj == DBNull.Value || followUpObj == null)
                return "fa-bell-slash";

            try
            {
                bool followUp = Convert.ToBoolean(followUpObj);
                return followUp ? "fa-bell" : "fa-bell-slash";
            }
            catch
            {
                return "fa-bell-slash";
            }
        }

        public string GetFollowUpText(object followUpObj)
        {
            if (followUpObj == DBNull.Value || followUpObj == null)
                return "No follow-up";

            try
            {
                bool followUp = Convert.ToBoolean(followUpObj);
                return followUp ? "Follow-up required" : "No follow-up";
            }
            catch
            {
                return "No follow-up";
            }
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

        public string GetFormattedDate(object dateTime)
        {
            if (dateTime == DBNull.Value || dateTime == null)
                return "N/A";

            try
            {
                DateTime dt = Convert.ToDateTime(dateTime);
                return dt.ToString("yyyy-MM-dd");
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

        protected void rptFeedbacks_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            // Can be used to manipulate individual feedback items if needed
        }

        // Handle view/resolve/delete from JavaScript
        protected void Page_PreRender(object sender, EventArgs e)
        {
            if (Request["__EVENTARGUMENT"] != null)
            {
                string eventArg = Request["__EVENTARGUMENT"];
                if (eventArg.StartsWith("view_"))
                {
                    string feedbackId = eventArg.Substring(5);
                    LoadFeedbackDetails(feedbackId);
                }
                else if (eventArg.StartsWith("resolve_"))
                {
                    string feedbackId = eventArg.Substring(8);
                    MarkAsResolved(feedbackId);
                }
                else if (eventArg.StartsWith("delete_"))
                {
                    string feedbackId = eventArg.Substring(7);
                    DeleteFeedback(feedbackId);
                }
            }
        }

        private void LoadFeedbackDetails(string feedbackId)
        {
            try
            {
                string query = @"SELECT 
                                f.FeedbackId,
                                u.FullName,
                                ISNULL(f.Category, 'General') as Category,
                                ISNULL(f.Priority, 'Medium') as Priority,
                                ISNULL(f.Subject, 'No Subject') as Subject,
                                ISNULL(f.Rating, 0) as Rating,
                                ISNULL(f.Message, '') as Message,
                                f.CreatedAt,
                                ISNULL(f.FollowUp, 0) as FollowUp
                                FROM Feedbacks f
                                JOIN Users u ON f.UserId = u.UserId
                                WHERE f.FeedbackId = @FeedbackId";

                using (SqlConnection conn = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@FeedbackId", feedbackId);
                    conn.Open();

                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            hdnFeedbackId.Value = feedbackId;
                            txtFeedbackId.Text = reader["FeedbackId"].ToString();
                            txtUserName.Text = reader["FullName"].ToString();
                            txtCategory.Text = reader["Category"].ToString();
                            txtPriority.Text = reader["Priority"].ToString();
                            txtSubject.Text = reader["Subject"].ToString();
                            txtRating.Text = reader["Rating"].ToString();
                            txtMessage.Text = reader["Message"].ToString();

                            if (reader["CreatedAt"] != DBNull.Value)
                            {
                                txtSubmittedDate.Text = Convert.ToDateTime(reader["CreatedAt"]).ToString("yyyy-MM-dd HH:mm:ss");
                            }
                            else
                            {
                                txtSubmittedDate.Text = "N/A";
                            }

                            // Set status dropdown based on FollowUp (since no Status column)
                            bool followUp = Convert.ToBoolean(reader["FollowUp"]);
                            ddlStatus.SelectedValue = followUp ? "Open" : "Closed";

                            // Show admin buttons
                            btnSaveResponse.Visible = true;
                            btnDeleteFeedback.Visible = true;
                        }
                    }
                }

                // Show modal via JavaScript
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ShowFeedbackModal",
                    "$('#feedbackDetailsModal').modal('show');", true);
            }
            catch (Exception ex)
            {
                ShowMessage("Error", "Failed to load feedback details: " + ex.Message, "error");
            }
        }

        private void MarkAsResolved(string feedbackId)
        {
            try
            {
                // Update feedback to mark as no follow-up needed (since no Status column)
                string updateQuery = @"UPDATE Feedbacks SET 
                                     FollowUp = 0
                                     WHERE FeedbackId = @FeedbackId";

                using (SqlConnection conn = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand(updateQuery, conn))
                {
                    cmd.Parameters.AddWithValue("@FeedbackId", feedbackId);
                    conn.Open();
                    int rowsAffected = cmd.ExecuteNonQuery();

                    if (rowsAffected > 0)
                    {
                        ShowMessage("Success", "Feedback marked as resolved.", "success");
                        LogAction("Resolve Feedback", "Marked feedback ID: " + feedbackId + " as resolved");
                    }
                    else
                    {
                        ShowMessage("Error", "Feedback not found.", "error");
                    }
                }

                BindFeedbacks();
            }
            catch (Exception ex)
            {
                ShowMessage("Error", "Failed to resolve feedback: " + ex.Message, "error");
            }
        }

        private void DeleteFeedback(string feedbackId)
        {
            try
            {
                string deleteQuery = "DELETE FROM Feedbacks WHERE FeedbackId = @FeedbackId";

                using (SqlConnection conn = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand(deleteQuery, conn))
                {
                    cmd.Parameters.AddWithValue("@FeedbackId", feedbackId);
                    conn.Open();
                    int rowsAffected = cmd.ExecuteNonQuery();

                    if (rowsAffected > 0)
                    {
                        ShowMessage("Success", "Feedback deleted successfully.", "success");
                        LogAction("Delete Feedback", "Deleted feedback ID: " + feedbackId);
                    }
                    else
                    {
                        ShowMessage("Error", "Feedback not found.", "error");
                    }
                }

                BindFeedbacks();
            }
            catch (Exception ex)
            {
                ShowMessage("Error", "Failed to delete feedback: " + ex.Message, "error");
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