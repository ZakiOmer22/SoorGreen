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
    public partial class Citizens : System.Web.UI.Page
    {
        private string connectionString = WebConfigurationManager.ConnectionStrings["SoorGreenDBConnectionString"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                BindCitizens();
                SetViewMode();
            }
        }

        private void BindCitizens()
        {
            try
            {
                // Users table doesn't have Address - it's in WasteReports table
                string query = @"SELECT u.UserId, u.FullName, u.Email, u.Phone, 
                                u.XP_Credits, u.IsVerified, u.RoleId, u.CreatedAt
                                FROM Users u 
                                WHERE u.RoleId = 'R001'";

                List<SqlParameter> parameters = new List<SqlParameter>();

                // Apply search filter
                if (!string.IsNullOrEmpty(txtSearch.Text))
                {
                    query += " AND (u.FullName LIKE @search OR u.Email LIKE @search OR u.Phone LIKE @search OR u.UserId LIKE @search)";
                    parameters.Add(new SqlParameter("@search", "%" + txtSearch.Text + "%"));
                }

                // Apply status filter
                if (ddlStatus.SelectedValue != "all")
                {
                    string status = ddlStatus.SelectedValue;
                    query += " AND u.IsVerified = @status";
                    parameters.Add(new SqlParameter("@status", status == "active"));
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

                query += " ORDER BY u.CreatedAt DESC";

                // Get data from database
                DataTable dt = GetDataTable(query, parameters.ToArray());

                // Bind to repeater for grid view
                rptCitizensGrid.DataSource = dt;
                rptCitizensGrid.DataBind();

                // Bind to gridview for table view
                gvCitizens.DataSource = dt;
                gvCitizens.DataBind();

                // Update stats
                UpdateStats(dt);

                // Update citizen count
                lblCitizenCount.Text = dt.Rows.Count.ToString();

                // Show message if no data
                if (dt.Rows.Count == 0)
                {
                    ShowMessage("Info", "No citizens found. Make sure you have users with RoleId = 'R001' in your database.", "info");
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Error", "Failed to load citizens: " + ex.Message, "error");
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

        private int ExecuteNonQuery(string query, SqlParameter[] parameters = null)
        {
            using (SqlConnection conn = new SqlConnection(connectionString))
            using (SqlCommand cmd = new SqlCommand(query, conn))
            {
                if (parameters != null)
                {
                    cmd.Parameters.AddRange(parameters);
                }

                conn.Open();
                return cmd.ExecuteNonQuery();
            }
        }

        private void UpdateStats(DataTable dt)
        {
            int totalCitizens = dt.Rows.Count;
            int activeCitizens = 0;
            decimal totalCredits = 0;
            int totalPickups = 0;
            decimal totalWaste = 0;

            foreach (DataRow row in dt.Rows)
            {
                if (row["IsVerified"] != DBNull.Value && Convert.ToBoolean(row["IsVerified"]))
                    activeCitizens++;

                if (row["XP_Credits"] != DBNull.Value)
                    totalCredits += Convert.ToDecimal(row["XP_Credits"]);

                // Get pickup stats for each citizen
                string userId = row["UserId"].ToString();
                var pickupStats = GetCitizenPickupStats(userId);
                totalPickups += pickupStats.Item1;
                totalWaste += pickupStats.Item2;
            }

            statTotal.InnerText = totalCitizens.ToString();
            statActive.InnerText = activeCitizens.ToString();
            statCredits.InnerText = totalCredits.ToString("N2");
            statPickups.InnerText = totalPickups.ToString();
            statWaste.InnerText = totalWaste.ToString("N1") + " kg";
        }

        private Tuple<int, decimal> GetCitizenPickupStats(string userId)
        {
            int pickupCount = 0;
            decimal totalWeight = 0;

            try
            {
                string query = @"SELECT 
                                COUNT(DISTINCT pr.PickupId) as PickupCount,
                                ISNULL(SUM(pv.VerifiedKg), 0) as TotalWeight
                                FROM WasteReports wr
                                JOIN PickupRequests pr ON wr.ReportId = pr.ReportId
                                LEFT JOIN PickupVerifications pv ON pr.PickupId = pv.PickupId
                                WHERE wr.UserId = @userId 
                                AND pr.Status IN ('Collected', 'Completed')";

                using (SqlConnection conn = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@userId", userId);
                    conn.Open();
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            pickupCount = Convert.ToInt32(reader["PickupCount"]);
                            totalWeight = Convert.ToDecimal(reader["TotalWeight"]);
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error in GetCitizenPickupStats for user " + userId + ": " + ex.Message);
            }

            return Tuple.Create(pickupCount, totalWeight);
        }

        // Event Handlers
        protected void btnApplyFilters_Click(object sender, EventArgs e)
        {
            BindCitizens();
        }

        protected void btnClearFilters_Click(object sender, EventArgs e)
        {
            txtSearch.Text = "";
            ddlStatus.SelectedValue = "all";
            ddlDateFilter.SelectedValue = "all";
            BindCitizens();
        }

        protected void btnRefresh_Click(object sender, EventArgs e)
        {
            BindCitizens();
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
                Response.AddHeader("content-disposition", "attachment;filename=Citizens_Export_" + DateTime.Now.ToString("yyyyMMdd") + ".csv");
                Response.Charset = "";
                Response.ContentType = "application/text";

                DataTable dt = GetCitizensDataForExport();
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

        private DataTable GetCitizensDataForExport()
        {
            string query = @"SELECT 
                            u.UserId as 'Citizen ID',
                            u.FullName as 'Full Name',
                            u.Email as 'Email',
                            u.Phone as 'Phone',
                            u.XP_Credits as 'Credits',
                            CASE WHEN u.IsVerified = 1 THEN 'Active' ELSE 'Inactive' END as 'Status',
                            FORMAT(u.CreatedAt, 'yyyy-MM-dd') as 'Registration Date'
                            FROM Users u 
                            WHERE u.RoleId = 'R001'
                            ORDER BY u.CreatedAt DESC";

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
        protected void rptCitizensGrid_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
            {
                DataRowView row = (DataRowView)e.Item.DataItem;
                string userId = row["UserId"].ToString();

                // Get pickup stats
                var pickupStats = GetCitizenPickupStats(userId);
                int pickupCount = pickupStats.Item1;
                decimal totalWeight = pickupStats.Item2;

                // Update labels
                Label lblPickups = (Label)e.Item.FindControl("lblPickups");
                Label lblKg = (Label)e.Item.FindControl("lblKg");

                if (lblPickups != null) lblPickups.Text = pickupCount.ToString();
                if (lblKg != null) lblKg.Text = totalWeight.ToString("N1");
            }
        }

        // Repeater Item Command
        protected void rptCitizensGrid_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "ViewDetails")
            {
                string userId = e.CommandArgument.ToString();
                LoadCitizenDetails(userId);
            }
            else if (e.CommandName == "ResetPassword")
            {
                string[] args = e.CommandArgument.ToString().Split('|');
                string userId = args[0];
                string userName = args[1];
                ResetCitizenPassword(userId, userName);
            }
            else if (e.CommandName == "ToggleStatus")
            {
                string[] args = e.CommandArgument.ToString().Split('|');
                string userId = args[0];
                string userName = args[1];
                string currentStatus = args[2];
                ToggleCitizenStatus(userId, userName, currentStatus);
            }
        }

        // GridView Row Command
        protected void gvCitizens_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "ViewDetails")
            {
                string userId = e.CommandArgument.ToString();
                LoadCitizenDetails(userId);
            }
            else if (e.CommandName == "ResetPassword")
            {
                GridViewRow row = (GridViewRow)((Control)e.CommandSource).NamingContainer;
                string userId = gvCitizens.DataKeys[row.RowIndex].Value.ToString();
                string userName = row.Cells[1].Text; // Full Name column
                ResetCitizenPassword(userId, userName);
            }
            else if (e.CommandName == "ToggleStatus")
            {
                GridViewRow row = (GridViewRow)((Control)e.CommandSource).NamingContainer;
                string userId = gvCitizens.DataKeys[row.RowIndex].Value.ToString();
                string userName = row.Cells[1].Text; // Full Name column
                string currentStatus = row.Cells[3].Text.ToLower().Contains("active") ? "active" : "inactive";
                ToggleCitizenStatus(userId, userName, currentStatus);
            }
        }

        // Load Citizen Details for Modal
        private void LoadCitizenDetails(string userId)
        {
            try
            {
                string query = @"SELECT u.*, 
                                (SELECT COUNT(DISTINCT pr.PickupId)
                                 FROM WasteReports wr
                                 JOIN PickupRequests pr ON wr.ReportId = pr.ReportId
                                 WHERE wr.UserId = u.UserId 
                                 AND pr.Status IN ('Collected', 'Completed')) as TotalPickups,
                                (SELECT ISNULL(SUM(pv.VerifiedKg), 0)
                                 FROM WasteReports wr
                                 JOIN PickupRequests pr ON wr.ReportId = pr.ReportId
                                 LEFT JOIN PickupVerifications pv ON pr.PickupId = pv.PickupId
                                 WHERE wr.UserId = u.UserId 
                                 AND pr.Status IN ('Collected', 'Completed')) as TotalWeight,
                                (SELECT TOP 1 Address 
                                 FROM WasteReports 
                                 WHERE UserId = u.UserId 
                                 ORDER BY CreatedAt DESC) as LastAddress
                                FROM Users u 
                                WHERE u.UserId = @userId AND u.RoleId = 'R001'";

                SqlParameter[] parameters = { new SqlParameter("@userId", userId) };
                DataTable dt = GetDataTable(query, parameters);

                if (dt.Rows.Count > 0)
                {
                    DataRow row = dt.Rows[0];

                    // Populate modal fields
                    litViewUserId.Text = row["UserId"].ToString();
                    litViewFullName.Text = row["FullName"].ToString();
                    litViewEmail.Text = row["Email"] != DBNull.Value ? row["Email"].ToString() : "N/A";
                    litViewPhone.Text = row["Phone"].ToString();
                    litViewCredits.Text = Convert.ToDecimal(row["XP_Credits"]).ToString("N2");
                    litViewStatus.Text = Convert.ToBoolean(row["IsVerified"]) ? "Active" : "Inactive";
                    litViewRegDate.Text = Convert.ToDateTime(row["CreatedAt"]).ToString("yyyy-MM-dd HH:mm");
                    litViewPickups.Text = row["TotalPickups"].ToString();
                    litViewTotalWeight.Text = Convert.ToDecimal(row["TotalWeight"]).ToString("N1") + " kg";

                    // Get address from WasteReports table if exists
                    string lastAddress = row["LastAddress"] != DBNull.Value ? row["LastAddress"].ToString() : "No address reported yet";

                    // REMOVED: litViewAddress.Text = lastAddress; // Remove this line since litViewAddress doesn't exist

                    // Store user info for reset password
                    hfViewUserId.Value = userId;
                    hfViewUserName.Value = row["FullName"].ToString();

                    // Show modal
                    ShowModal();
                }
                else
                {
                    ShowMessage("Error", "Citizen not found or is not a citizen (RoleId should be 'R001')", "error");
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Error", "Failed to load citizen details: " + ex.Message, "error");
            }
        }

        // Reset Password
        private void ResetCitizenPassword(string userId, string userName)
        {
            try
            {
                // Generate random password
                string newPassword = GenerateRandomPassword();

                // Update password in database
                string query = "UPDATE Users SET Password = @password WHERE UserId = @userId";
                SqlParameter[] parameters = {
                    new SqlParameter("@password", newPassword),
                    new SqlParameter("@userId", userId)
                };

                ExecuteNonQuery(query, parameters);

                ShowMessage("Success",
                    "Password reset for " + userName + ". New password: " + newPassword + " (Please inform the citizen)",
                    "success");

                BindCitizens();
            }
            catch (Exception ex)
            {
                ShowMessage("Error", "Failed to reset password: " + ex.Message, "error");
            }
        }

        // Toggle Citizen Status
        private void ToggleCitizenStatus(string userId, string userName, string currentStatus)
        {
            try
            {
                bool newStatus = currentStatus != "active"; // Toggle status
                string statusText = newStatus ? "activated" : "deactivated";

                string query = "UPDATE Users SET IsVerified = @status WHERE UserId = @userId";
                SqlParameter[] parameters = {
                    new SqlParameter("@status", newStatus),
                    new SqlParameter("@userId", userId)
                };

                ExecuteNonQuery(query, parameters);

                ShowMessage("Success", "Citizen " + userName + " has been " + statusText, "success");

                BindCitizens();
            }
            catch (Exception ex)
            {
                ShowMessage("Error", "Failed to update status: " + ex.Message, "error");
            }
        }

        // Reset Password from Modal
        protected void btnResetPassword_Click(object sender, EventArgs e)
        {
            string userId = hfViewUserId.Value;
            string userName = hfViewUserName.Value;

            if (!string.IsNullOrEmpty(userId))
            {
                ResetCitizenPassword(userId, userName);
                CloseModal();
            }
        }

        // Modal Controls
        private void ShowModal()
        {
            divModalBackdrop.Style["display"] = "block";
            divViewModal.Style["display"] = "block";

            // Add active class for animation
            string script = "document.getElementById('" + divModalBackdrop.ClientID + "').classList.add('active');" +
                           "document.getElementById('" + divViewModal.ClientID + "').classList.add('active');";
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ShowModal", script, true);
        }

        protected void btnCloseModal_Click(object sender, EventArgs e)
        {
            CloseModal();
        }

        protected void btnCancelView_Click(object sender, EventArgs e)
        {
            CloseModal();
        }

        private void CloseModal()
        {
            divModalBackdrop.Style["display"] = "none";
            divViewModal.Style["display"] = "none";

            // Remove active class
            string script = "document.getElementById('" + divModalBackdrop.ClientID + "').classList.remove('active');" +
                           "document.getElementById('" + divViewModal.ClientID + "').classList.remove('active');";
            ScriptManager.RegisterStartupScript(this, this.GetType(), "CloseModal", script, true);

            // Clear stored values
            hfViewUserId.Value = "";
            hfViewUserName.Value = "";
        }

        // Helper Methods
        private string GenerateRandomPassword()
        {
            const string chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
            Random random = new Random();
            char[] password = new char[8];

            for (int i = 0; i < password.Length; i++)
            {
                password[i] = chars[random.Next(chars.Length)];
            }

            return new string(password);
        }

        private void SetViewMode()
        {
            string view = Request.QueryString["view"];
            if (!string.IsNullOrEmpty(view))
            {
                if (view == "grid")
                {
                    btnGridView_Click(null, null);
                }
                else if (view == "table")
                {
                    btnTableView_Click(null, null);
                }
            }
        }

        // Status Helper Methods (for CSS classes)
        public string GetStatusClass(bool isVerified)
        {
            return isVerified ? "status-active" : "status-inactive";
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