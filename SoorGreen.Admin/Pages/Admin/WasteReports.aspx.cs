using SoorGreen.Admin;
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
    public partial class WasteReports : System.Web.UI.Page
    {
        private string connectionString = WebConfigurationManager.ConnectionStrings["SoorGreenDBConnectionString"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                BindDropdowns();
                BindWasteReports();
            }

            // Handle edit request from JavaScript
            if (Request["__EVENTTARGET"] == "ctl00$MainContent$hdnReportId")
            {
                string eventArg = Request["__EVENTARGUMENT"];
                if (eventArg.StartsWith("edit_"))
                {
                    string reportId = eventArg.Substring(5);
                    LoadReportForEdit(reportId);
                }
            }
        }

        private void BindDropdowns()
        {
            // Bind citizens dropdown
            string citizenQuery = "SELECT UserId, FullName FROM Users WHERE RoleId = 'CITZ' OR RoleId = 'R001' ORDER BY FullName";
            ddlCitizen.DataSource = GetDataTable(citizenQuery);
            ddlCitizen.DataTextField = "FullName";
            ddlCitizen.DataValueField = "UserId";
            ddlCitizen.DataBind();
            ddlCitizen.Items.Insert(0, new ListItem("-- Select Citizen --", ""));

            // Bind waste types dropdown
            string wasteTypeQuery = "SELECT WasteTypeId, Name FROM WasteTypes ORDER BY Name";
            ddlWasteType.DataSource = GetDataTable(wasteTypeQuery);
            ddlWasteType.DataTextField = "Name";
            ddlWasteType.DataValueField = "WasteTypeId";
            ddlWasteType.DataBind();
            ddlWasteType.Items.Insert(0, new ListItem("-- Select Waste Type --", ""));
        }

        private void BindWasteReports()
        {
            try
            {
                string query = @"SELECT 
                                wr.ReportId,
                                wr.EstimatedKg,
                                wr.Address,
                                wr.Lat,
                                wr.Lng,
                                wr.PhotoUrl,
                                wr.CreatedAt,
                                wt.Name as WasteTypeName,
                                wt.CreditPerKg,
                                (wr.EstimatedKg * wt.CreditPerKg) as Credits,
                                u.FullName as CitizenName,
                                u.Phone as CitizenPhone,
                                u.Email as CitizenEmail,
                                u.UserId as CitizenId,
                                pr.Status as PickupStatus,
                                pr.ScheduledAt as PickupDate,
                                CASE WHEN wr.PhotoUrl IS NOT NULL AND wr.PhotoUrl != '' THEN 1 ELSE 0 END as HasPhoto
                                FROM WasteReports wr
                                JOIN WasteTypes wt ON wr.WasteTypeId = wt.WasteTypeId
                                JOIN Users u ON wr.UserId = u.UserId
                                LEFT JOIN PickupRequests pr ON wr.ReportId = pr.ReportId
                                WHERE 1=1";

                List<SqlParameter> parameters = new List<SqlParameter>();

                // Apply search filter
                if (!string.IsNullOrEmpty(txtSearch.Text))
                {
                    query += " AND (wr.ReportId LIKE @search OR u.FullName LIKE @search OR wr.Address LIKE @search)";
                    parameters.Add(new SqlParameter("@search", "%" + txtSearch.Text + "%"));
                }

                // Apply waste type filter
                if (ddlWasteTypeFilter.SelectedValue != "all")
                {
                    query += " AND wt.Name = @wasteType";
                    parameters.Add(new SqlParameter("@wasteType", ddlWasteTypeFilter.SelectedValue));
                }

                // Apply date filter
                if (ddlDateFilter.SelectedValue != "all")
                {
                    switch (ddlDateFilter.SelectedValue)
                    {
                        case "today":
                            query += " AND CONVERT(DATE, wr.CreatedAt) = CONVERT(DATE, GETDATE())";
                            break;
                        case "week":
                            query += " AND wr.CreatedAt >= DATEADD(DAY, -7, GETDATE())";
                            break;
                        case "month":
                            query += " AND wr.CreatedAt >= DATEADD(MONTH, -1, GETDATE())";
                            break;
                        case "year":
                            query += " AND wr.CreatedAt >= DATEADD(YEAR, -1, GETDATE())";
                            break;
                    }
                }

                query += " ORDER BY wr.CreatedAt DESC";

                // Get data from database
                DataTable dt = GetDataTable(query, parameters.ToArray());

                // Bind to repeater for grid view
                rptReportsGrid.DataSource = dt;
                rptReportsGrid.DataBind();

                // Bind to gridview for table view
                gvReports.DataSource = dt;
                gvReports.DataBind();

                // Update stats
                UpdateStats(dt);

                // Update report count
                lblReportCount.Text = dt.Rows.Count.ToString();

                // Show message if no data
                if (dt.Rows.Count == 0)
                {
                    ShowMessage("Info", "No waste reports found.", "info");
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Error", "Failed to load waste reports: " + ex.Message, "error");
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
            int totalReports = dt.Rows.Count;
            int pendingPickups = 0;
            int collectedPickups = 0;
            decimal totalWeight = 0;

            foreach (DataRow row in dt.Rows)
            {
                string status = row["PickupStatus"].ToString();
                if (status == "Requested" || status == "Assigned")
                    pendingPickups++;
                else if (status == "Collected" || status == "Completed")
                    collectedPickups++;

                if (row["EstimatedKg"] != DBNull.Value)
                    totalWeight += Convert.ToDecimal(row["EstimatedKg"]);
            }

            statTotal.InnerText = totalReports.ToString();
            statPending.InnerText = pendingPickups.ToString();
            statCollected.InnerText = collectedPickups.ToString();
            statTotalWeight.InnerText = totalWeight.ToString("N1") + " kg";
        }

        // CRUD Operations
        protected void btnSaveReport_Click(object sender, EventArgs e)
        {
            try
            {
                string reportId = hdnReportId.Value;

                if (string.IsNullOrEmpty(reportId))
                {
                    // Add new report
                    AddNewReport();
                }
                else
                {
                    // Update existing report
                    UpdateReport(reportId);
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Error", "Failed to save waste report: " + ex.Message, "error");
            }
        }

        private void AddNewReport()
        {
            // Generate new ReportId
            string newReportId = GetNextReportId();

            string query = @"INSERT INTO WasteReports 
                            (ReportId, UserId, WasteTypeId, EstimatedKg, Address, Lat, Lng, PhotoUrl, CreatedAt)
                            VALUES (@ReportId, @UserId, @WasteTypeId, @EstimatedKg, @Address, @Lat, @Lng, @PhotoUrl, GETDATE())";

            using (SqlConnection conn = new SqlConnection(connectionString))
            using (SqlCommand cmd = new SqlCommand(query, conn))
            {
                cmd.Parameters.AddWithValue("@ReportId", newReportId);
                cmd.Parameters.AddWithValue("@UserId", ddlCitizen.SelectedValue);
                cmd.Parameters.AddWithValue("@WasteTypeId", ddlWasteType.SelectedValue);
                cmd.Parameters.AddWithValue("@EstimatedKg", decimal.Parse(txtEstimatedKg.Text));
                cmd.Parameters.AddWithValue("@Address", txtAddress.Text);
                cmd.Parameters.AddWithValue("@Lat", string.IsNullOrEmpty(txtLat.Text) ? DBNull.Value : (object)decimal.Parse(txtLat.Text));
                cmd.Parameters.AddWithValue("@Lng", string.IsNullOrEmpty(txtLng.Text) ? DBNull.Value : (object)decimal.Parse(txtLng.Text));
                cmd.Parameters.AddWithValue("@PhotoUrl", string.IsNullOrEmpty(txtPhotoUrl.Text) ? DBNull.Value : (object)txtPhotoUrl.Text);

                conn.Open();
                cmd.ExecuteNonQuery();
            }

            ShowMessage("Success", "Waste report added successfully!", "success");
            BindWasteReports();

            // Close modal via JavaScript
            ScriptManager.RegisterStartupScript(this, this.GetType(), "CloseModal",
                "$('#reportModal').modal('hide');", true);
        }

        private void UpdateReport(string reportId)
        {
            string query = @"UPDATE WasteReports 
                            SET UserId = @UserId,
                                WasteTypeId = @WasteTypeId,
                                EstimatedKg = @EstimatedKg,
                                Address = @Address,
                                Lat = @Lat,
                                Lng = @Lng,
                                PhotoUrl = @PhotoUrl
                            WHERE ReportId = @ReportId";

            using (SqlConnection conn = new SqlConnection(connectionString))
            using (SqlCommand cmd = new SqlCommand(query, conn))
            {
                cmd.Parameters.AddWithValue("@ReportId", reportId);
                cmd.Parameters.AddWithValue("@UserId", ddlCitizen.SelectedValue);
                cmd.Parameters.AddWithValue("@WasteTypeId", ddlWasteType.SelectedValue);
                cmd.Parameters.AddWithValue("@EstimatedKg", decimal.Parse(txtEstimatedKg.Text));
                cmd.Parameters.AddWithValue("@Address", txtAddress.Text);
                cmd.Parameters.AddWithValue("@Lat", string.IsNullOrEmpty(txtLat.Text) ? DBNull.Value : (object)decimal.Parse(txtLat.Text));
                cmd.Parameters.AddWithValue("@Lng", string.IsNullOrEmpty(txtLng.Text) ? DBNull.Value : (object)decimal.Parse(txtLng.Text));
                cmd.Parameters.AddWithValue("@PhotoUrl", string.IsNullOrEmpty(txtPhotoUrl.Text) ? DBNull.Value : (object)txtPhotoUrl.Text);

                conn.Open();
                cmd.ExecuteNonQuery();
            }

            ShowMessage("Success", "Waste report updated successfully!", "success");
            BindWasteReports();

            // Close modal via JavaScript
            ScriptManager.RegisterStartupScript(this, this.GetType(), "CloseModal",
                "$('#reportModal').modal('hide');", true);
        }

        protected void btnDeleteReport_Click(object sender, EventArgs e)
        {
            try
            {
                string reportId = hdnReportId.Value;

                // Check if report has pickup request
                string checkQuery = "SELECT COUNT(*) FROM PickupRequests WHERE ReportId = @ReportId";
                using (SqlConnection conn = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand(checkQuery, conn))
                {
                    cmd.Parameters.AddWithValue("@ReportId", reportId);
                    conn.Open();
                    int pickupCount = (int)cmd.ExecuteScalar();

                    if (pickupCount > 0)
                    {
                        ShowMessage("Error", "Cannot delete report with active pickup request. Delete the pickup first.", "error");
                        return;
                    }
                }

                // Delete report
                string deleteQuery = "DELETE FROM WasteReports WHERE ReportId = @ReportId";
                using (SqlConnection conn = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand(deleteQuery, conn))
                {
                    cmd.Parameters.AddWithValue("@ReportId", reportId);
                    conn.Open();
                    cmd.ExecuteNonQuery();
                }

                ShowMessage("Success", "Waste report deleted successfully!", "success");
                BindWasteReports();

                // Close modal via JavaScript
                ScriptManager.RegisterStartupScript(this, this.GetType(), "CloseModal",
                    "$('#reportModal').modal('hide');", true);
            }
            catch (Exception ex)
            {
                ShowMessage("Error", "Failed to delete waste report: " + ex.Message, "error");
            }
        }

        private void LoadReportForEdit(string reportId)
        {
            string query = @"SELECT wr.*, u.FullName, wt.Name as WasteTypeName
                            FROM WasteReports wr
                            JOIN Users u ON wr.UserId = u.UserId
                            JOIN WasteTypes wt ON wr.WasteTypeId = wt.WasteTypeId
                            WHERE wr.ReportId = @ReportId";

            using (SqlConnection conn = new SqlConnection(connectionString))
            using (SqlCommand cmd = new SqlCommand(query, conn))
            {
                cmd.Parameters.AddWithValue("@ReportId", reportId);
                conn.Open();

                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    if (reader.Read())
                    {
                        hdnReportId.Value = reader["ReportId"].ToString();
                        ddlCitizen.SelectedValue = reader["UserId"].ToString();
                        ddlWasteType.SelectedValue = reader["WasteTypeId"].ToString();
                        txtEstimatedKg.Text = reader["EstimatedKg"].ToString();
                        txtAddress.Text = reader["Address"].ToString();
                        txtLat.Text = reader["Lat"] != DBNull.Value ? reader["Lat"].ToString() : "";
                        txtLng.Text = reader["Lng"] != DBNull.Value ? reader["Lng"].ToString() : "";
                        txtPhotoUrl.Text = reader["PhotoUrl"] != DBNull.Value ? reader["PhotoUrl"].ToString() : "";
                    }
                }
            }

            // Show modal via JavaScript
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ShowEditModal",
                "var modal = new bootstrap.Modal(document.getElementById('reportModal')); modal.show();", true);
        }

        private string GetNextReportId()
        {
            string query = "SELECT ISNULL(MAX(CAST(SUBSTRING(ReportId, 3, LEN(ReportId)) AS INT)), 0) + 1 FROM WasteReports WHERE ReportId LIKE 'WR%'";

            using (SqlConnection conn = new SqlConnection(connectionString))
            using (SqlCommand cmd = new SqlCommand(query, conn))
            {
                conn.Open();
                int nextId = (int)cmd.ExecuteScalar();
                return "WR" + nextId.ToString("D2");
            }
        }

        // Helper Methods
        public string GetPickupStatusClass(string status)
        {
            switch (status.ToLower())
            {
                case "requested":
                    return "status-pending";
                case "assigned":
                    return "status-assigned";
                case "collected":
                case "completed":
                    return "status-completed";
                case "cancelled":
                    return "status-cancelled";
                default:
                    return "status-pending";
            }
        }

        public string GetPickupStatusColor(string status)
        {
            switch (status.ToLower())
            {
                case "requested":
                    return "text-warning";
                case "assigned":
                    return "text-info";
                case "collected":
                case "completed":
                    return "text-success";
                case "cancelled":
                    return "text-danger";
                default:
                    return "text-muted";
            }
        }

        public string GetCreatePickupButton(string status, string reportId)
        {
            if (string.IsNullOrEmpty(status))
            {
                return string.Format(
                    "<button type='button' class='btn btn-success' onclick='createPickup(\"{0}\")'>" +
                    "<i class='fas fa-truck me-1'></i>Create Pickup</button>",
                    reportId);
            }
            return string.Empty;
        }

        // Event Handlers for Create Pickup
        protected void btnCreatePickup_Click(object sender, EventArgs e)
        {
            string reportId = Request["__EVENTARGUMENT"];

            try
            {
                // Generate pickup ID
                string pickupId = GetNextPickupId();

                string query = @"INSERT INTO PickupRequests (PickupId, ReportId, Status) 
                                VALUES (@PickupId, @ReportId, 'Requested')";

                using (SqlConnection conn = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@PickupId", pickupId);
                    cmd.Parameters.AddWithValue("@ReportId", reportId);

                    conn.Open();
                    cmd.ExecuteNonQuery();
                }

                ShowMessage("Success", "Pickup request created successfully!", "success");
                BindWasteReports();
            }
            catch (Exception ex)
            {
                ShowMessage("Error", "Failed to create pickup request: " + ex.Message, "error");
            }
        }

        private string GetNextPickupId()
        {
            string query = "SELECT ISNULL(MAX(CAST(SUBSTRING(PickupId, 3, LEN(PickupId)) AS INT)), 0) + 1 FROM PickupRequests WHERE PickupId LIKE 'PK%'";

            using (SqlConnection conn = new SqlConnection(connectionString))
            using (SqlCommand cmd = new SqlCommand(query, conn))
            {
                conn.Open();
                int nextId = (int)cmd.ExecuteScalar();
                return "PK" + nextId.ToString("D2");
            }
        }

        // Existing Event Handlers
        protected void btnApplyFilters_Click(object sender, EventArgs e)
        {
            BindWasteReports();
        }

        protected void btnClearFilters_Click(object sender, EventArgs e)
        {
            txtSearch.Text = "";
            ddlWasteTypeFilter.SelectedValue = "all";
            ddlDateFilter.SelectedValue = "all";
            BindWasteReports();
        }

        protected void btnRefresh_Click(object sender, EventArgs e)
        {
            BindWasteReports();
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
                Response.AddHeader("content-disposition", "attachment;filename=WasteReports_Export_" + DateTime.Now.ToString("yyyyMMdd") + ".csv");
                Response.Charset = "";
                Response.ContentType = "application/text";

                DataTable dt = GetWasteReportsDataForExport();
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

        private DataTable GetWasteReportsDataForExport()
        {
            string query = @"SELECT 
                            wr.ReportId as 'Report ID',
                            u.FullName as 'Citizen Name',
                            u.Phone as 'Citizen Phone',
                            u.Email as 'Citizen Email',
                            wt.Name as 'Waste Type',
                            wr.EstimatedKg as 'Estimated Weight (kg)',
                            (wr.EstimatedKg * wt.CreditPerKg) as 'Credits Earned',
                            wr.Address as 'Address',
                            pr.Status as 'Pickup Status',
                            FORMAT(wr.CreatedAt, 'yyyy-MM-dd HH:mm') as 'Report Date',
                            CASE WHEN wr.PhotoUrl IS NOT NULL THEN 'Yes' ELSE 'No' END as 'Has Photo'
                            FROM WasteReports wr
                            JOIN WasteTypes wt ON wr.WasteTypeId = wt.WasteTypeId
                            JOIN Users u ON wr.UserId = u.UserId
                            LEFT JOIN PickupRequests pr ON wr.ReportId = pr.ReportId
                            ORDER BY wr.CreatedAt DESC";

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
        protected void rptReportsGrid_ItemDataBound(object sender, RepeaterItemEventArgs e)
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