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
    public partial class Collectors : System.Web.UI.Page
    {
        private string connectionString = WebConfigurationManager.ConnectionStrings["SoorGreenDBConnectionString"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                BindCollectors();
            }
        }

        private void BindCollectors()
        {
            try
            {
                // Collectors have RoleId = 'R002'
                string query = @"SELECT u.UserId, u.FullName, u.Email, u.Phone, 
                                u.XP_Credits, u.IsVerified, u.RoleId, u.CreatedAt
                                FROM Users u 
                                WHERE u.RoleId = 'R002'";

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
                rptCollectorsGrid.DataSource = dt;
                rptCollectorsGrid.DataBind();

                // Bind to gridview for table view
                gvCollectors.DataSource = dt;
                gvCollectors.DataBind();

                // Update stats
                UpdateStats(dt);

                // Update collector count
                lblCollectorCount.Text = dt.Rows.Count.ToString();

                // Show message if no data
                if (dt.Rows.Count == 0)
                {
                    ShowMessage("Info", "No collectors found. Make sure you have users with RoleId = 'R002' in your database.", "info");
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Error", "Failed to load collectors: " + ex.Message, "error");
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
            int totalCollectors = dt.Rows.Count;
            int activeCollectors = 0;
            int totalPickups = 0;
            decimal totalWaste = 0;

            foreach (DataRow row in dt.Rows)
            {
                if (row["IsVerified"] != DBNull.Value && Convert.ToBoolean(row["IsVerified"]))
                    activeCollectors++;

                // Get pickup stats for each collector
                string userId = row["UserId"].ToString();
                var pickupStats = GetCollectorPickupStats(userId);
                totalPickups += pickupStats.Item1;
                totalWaste += pickupStats.Item2;
            }

            statTotal.InnerText = totalCollectors.ToString();
            statActive.InnerText = activeCollectors.ToString();
            statPickups.InnerText = totalPickups.ToString();
            statWaste.InnerText = totalWaste.ToString("N1") + " kg";
        }

        private Tuple<int, decimal> GetCollectorPickupStats(string userId)
        {
            int pickupCount = 0;
            decimal totalWeight = 0;

            try
            {
                string query = @"SELECT 
                                COUNT(DISTINCT pr.PickupId) as PickupCount,
                                ISNULL(SUM(pv.VerifiedKg), 0) as TotalWeight
                                FROM PickupRequests pr
                                LEFT JOIN PickupVerifications pv ON pr.PickupId = pv.PickupId
                                WHERE pr.CollectorId = @userId 
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
                System.Diagnostics.Debug.WriteLine("Error in GetCollectorPickupStats for collector " + userId + ": " + ex.Message);
            }

            return Tuple.Create(pickupCount, totalWeight);
        }

        // Event Handlers
        protected void btnApplyFilters_Click(object sender, EventArgs e)
        {
            BindCollectors();
        }

        protected void btnClearFilters_Click(object sender, EventArgs e)
        {
            txtSearch.Text = "";
            ddlStatus.SelectedValue = "all";
            ddlDateFilter.SelectedValue = "all";
            BindCollectors();
        }

        protected void btnRefresh_Click(object sender, EventArgs e)
        {
            BindCollectors();
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
                Response.AddHeader("content-disposition", "attachment;filename=Collectors_Export_" + DateTime.Now.ToString("yyyyMMdd") + ".csv");
                Response.Charset = "";
                Response.ContentType = "application/text";

                DataTable dt = GetCollectorsDataForExport();
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

        private DataTable GetCollectorsDataForExport()
        {
            string query = @"SELECT 
                            u.UserId as 'Collector ID',
                            u.FullName as 'Full Name',
                            u.Email as 'Email',
                            u.Phone as 'Phone',
                            CASE WHEN u.IsVerified = 1 THEN 'Active' ELSE 'Inactive' END as 'Status',
                            FORMAT(u.CreatedAt, 'yyyy-MM-dd') as 'Registration Date',
                            (SELECT COUNT(DISTINCT pr.PickupId) 
                             FROM PickupRequests pr
                             WHERE pr.CollectorId = u.UserId 
                             AND pr.Status IN ('Collected', 'Completed')) as 'Completed Pickups',
                            (SELECT ISNULL(SUM(pv.VerifiedKg), 0)
                             FROM PickupRequests pr
                             LEFT JOIN PickupVerifications pv ON pr.PickupId = pv.PickupId
                             WHERE pr.CollectorId = u.UserId 
                             AND pr.Status IN ('Collected', 'Completed')) as 'Total Waste (kg)'
                            FROM Users u 
                            WHERE u.RoleId = 'R002'
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
        protected void rptCollectorsGrid_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
            {
                DataRowView row = (DataRowView)e.Item.DataItem;
                string userId = row["UserId"].ToString();

                // Get pickup stats
                var pickupStats = GetCollectorPickupStats(userId);
                int pickupCount = pickupStats.Item1;
                decimal totalWeight = pickupStats.Item2;

                // Update labels
                Label lblPickups = (Label)e.Item.FindControl("lblPickups");
                Label lblKg = (Label)e.Item.FindControl("lblKg");

                if (lblPickups != null) lblPickups.Text = pickupCount.ToString();
                if (lblKg != null) lblKg.Text = totalWeight.ToString("N1");
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