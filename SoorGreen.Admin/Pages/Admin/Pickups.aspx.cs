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
    public partial class Pickups : System.Web.UI.Page
    {
        private string connectionString = WebConfigurationManager.ConnectionStrings["SoorGreenDBConnectionString"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                BindPickupRequests();
            }
        }

        private void BindPickupRequests()
        {
            try
            {
                string query = @"SELECT 
                                pr.PickupId,
                                pr.Status,
                                pr.ScheduledAt,
                                pr.CompletedAt,
                                wr.EstimatedKg,
                                wr.Address,
                                uc.FullName as CitizenName,
                                uc.Phone as CitizenPhone,
                                uc.Email as CitizenEmail,
                                uc.UserId as CitizenId,
                                uc2.FullName as CollectorName,
                                uc2.UserId as CollectorId,
                                wr.CreatedAt
                                FROM PickupRequests pr
                                JOIN WasteReports wr ON pr.ReportId = wr.ReportId
                                JOIN Users uc ON wr.UserId = uc.UserId
                                LEFT JOIN Users uc2 ON pr.CollectorId = uc2.UserId
                                WHERE 1=1";

                List<SqlParameter> parameters = new List<SqlParameter>();

                // Apply search filter
                if (!string.IsNullOrEmpty(txtSearch.Text))
                {
                    query += " AND (pr.PickupId LIKE @search OR uc.FullName LIKE @search OR uc2.FullName LIKE @search OR wr.Address LIKE @search)";
                    parameters.Add(new SqlParameter("@search", "%" + txtSearch.Text + "%"));
                }

                // Apply status filter
                if (ddlStatus.SelectedValue != "all")
                {
                    query += " AND pr.Status = @status";
                    parameters.Add(new SqlParameter("@status", ddlStatus.SelectedValue));
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
                rptPickupsGrid.DataSource = dt;
                rptPickupsGrid.DataBind();

                // Bind to gridview for table view
                gvPickups.DataSource = dt;
                gvPickups.DataBind();

                // Update stats
                UpdateStats(dt);

                // Update pickup count
                lblPickupCount.Text = dt.Rows.Count.ToString();

                // Show message if no data
                if (dt.Rows.Count == 0)
                {
                    ShowMessage("Info", "No pickup requests found.", "info");
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Error", "Failed to load pickup requests: " + ex.Message, "error");
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
            int totalPickups = dt.Rows.Count;
            int pendingPickups = 0;
            int completedPickups = 0;
            decimal totalWaste = 0;

            foreach (DataRow row in dt.Rows)
            {
                string status = row["Status"].ToString();
                if (status == "Requested" || status == "Assigned")
                    pendingPickups++;
                else if (status == "Collected" || status == "Completed")
                    completedPickups++;

                if (row["EstimatedKg"] != DBNull.Value)
                    totalWaste += Convert.ToDecimal(row["EstimatedKg"]);
            }

            statTotal.InnerText = totalPickups.ToString();
            statPending.InnerText = pendingPickups.ToString();
            statCompleted.InnerText = completedPickups.ToString();
            statWaste.InnerText = totalWaste.ToString("N1") + " kg";
        }

        // Status Helper Methods
        public string GetStatusClass(string status)
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

        public string GetStatusColor(string status)
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
                    return "text-warning";
            }
        }

        // Event Handlers
        protected void btnApplyFilters_Click(object sender, EventArgs e)
        {
            BindPickupRequests();
        }

        protected void btnClearFilters_Click(object sender, EventArgs e)
        {
            txtSearch.Text = "";
            ddlStatus.SelectedValue = "all";
            ddlDateFilter.SelectedValue = "all";
            BindPickupRequests();
        }

        protected void btnRefresh_Click(object sender, EventArgs e)
        {
            BindPickupRequests();
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
                Response.AddHeader("content-disposition", "attachment;filename=PickupRequests_Export_" + DateTime.Now.ToString("yyyyMMdd") + ".csv");
                Response.Charset = "";
                Response.ContentType = "application/text";

                DataTable dt = GetPickupRequestsDataForExport();
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

        private DataTable GetPickupRequestsDataForExport()
        {
            string query = @"SELECT 
                            pr.PickupId as 'Pickup ID',
                            uc.FullName as 'Citizen Name',
                            uc.Phone as 'Citizen Phone',
                            uc.Email as 'Citizen Email',
                            uc2.FullName as 'Collector Name',
                            wr.Address as 'Address',
                            wr.EstimatedKg as 'Estimated Weight (kg)',
                            pr.Status as 'Status',
                            FORMAT(wr.CreatedAt, 'yyyy-MM-dd HH:mm') as 'Request Date',
                            FORMAT(pr.ScheduledAt, 'yyyy-MM-dd HH:mm') as 'Scheduled Date',
                            FORMAT(pr.CompletedAt, 'yyyy-MM-dd HH:mm') as 'Completed Date'
                            FROM PickupRequests pr
                            JOIN WasteReports wr ON pr.ReportId = wr.ReportId
                            JOIN Users uc ON wr.UserId = uc.UserId
                            LEFT JOIN Users uc2 ON pr.CollectorId = uc2.UserId
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
        protected void rptPickupsGrid_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
            {
                // Add any specific data binding if needed
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