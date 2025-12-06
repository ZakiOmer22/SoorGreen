using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Runtime.Remoting.Messaging;
using System.Web.Configuration;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml.Linq;

namespace SoorGreen.Admin.Admin
{
    public partial class WasteTypes : System.Web.UI.Page
    {
        private string connectionString = WebConfigurationManager.ConnectionStrings["SoorGreenDBConnectionString"].ConnectionString;
        private Dictionary<string, int> reportCounts = new Dictionary<string, int>();
        private Dictionary<string, decimal> totalWeights = new Dictionary<string, decimal>();
        private Dictionary<string, decimal> totalCredits = new Dictionary<string, decimal>();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                BindWasteTypes();
            }

            // Handle edit request from JavaScript
            if (Request["__EVENTTARGET"] == "ctl00$MainContent$hdnWasteTypeId")
            {
                string eventArg = Request["__EVENTARGUMENT"];
                if (eventArg.StartsWith("edit_"))
                {
                    string wasteTypeId = eventArg.Substring(5);
                    LoadWasteTypeForEdit(wasteTypeId);
                }
            }
        }

        private void BindWasteTypes()
        {
            try
            {
                // First, load usage statistics
                LoadUsageStatistics();

                string query = @"SELECT 
                                WasteTypeId,
                                Name,
                                CreditPerKg,
                                ISNULL(ColorCode, '#6c757d') as ColorCode,
                                ISNULL(Description, '') as Description,
                                ISNULL(Category, 'Other') as Category
                                FROM WasteTypes
                                WHERE 1=1";

                List<SqlParameter> parameters = new List<SqlParameter>();

                // Apply search filter
                if (!string.IsNullOrEmpty(txtSearch.Text))
                {
                    query += " AND (Name LIKE @search OR Description LIKE @search OR Category LIKE @search)";
                    parameters.Add(new SqlParameter("@search", "%" + txtSearch.Text + "%"));
                }

                // Apply category filter
                if (ddlCategoryFilter.SelectedValue != "all")
                {
                    query += " AND Category = @category";
                    parameters.Add(new SqlParameter("@category", ddlCategoryFilter.SelectedValue));
                }

                query += " ORDER BY Name";

                // Get data from database
                DataTable dt = GetDataTable(query, parameters.ToArray());

                // Bind to repeater for card view
                rptWasteTypesGrid.DataSource = dt;
                rptWasteTypesGrid.DataBind();

                // Bind to gridview for table view
                gvWasteTypes.DataSource = dt;
                gvWasteTypes.DataBind();

                // Update stats
                UpdateStats(dt);

                // Update waste type count
                lblWasteTypeCount.Text = dt.Rows.Count.ToString();

                // Show message if no data
                if (dt.Rows.Count == 0)
                {
                    ShowMessage("Info", "No waste types found.", "info");
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Error", "Failed to load waste types: " + ex.Message, "error");
            }
        }

        private void LoadUsageStatistics()
        {
            try
            {
                string query = @"SELECT 
                                wt.WasteTypeId,
                                COUNT(wr.ReportId) as ReportCount,
                                ISNULL(SUM(wr.EstimatedKg), 0) as TotalWeight,
                                ISNULL(SUM(wr.EstimatedKg * wt.CreditPerKg), 0) as TotalCredits
                                FROM WasteTypes wt
                                LEFT JOIN WasteReports wr ON wt.WasteTypeId = wr.WasteTypeId
                                GROUP BY wt.WasteTypeId";

                using (SqlConnection conn = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    conn.Open();
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            string wasteTypeId = reader["WasteTypeId"].ToString();
                            int reportCount = Convert.ToInt32(reader["ReportCount"]);
                            decimal totalWeight = Convert.ToDecimal(reader["TotalWeight"]);
                            decimal totalCredits = Convert.ToDecimal(reader["TotalCredits"]);

                            this.reportCounts[wasteTypeId] = reportCount;
                            this.totalWeights[wasteTypeId] = totalWeight;
                            this.totalCredits[wasteTypeId] = totalCredits;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                // Log error but don't break the page
                System.Diagnostics.Debug.WriteLine("Error loading usage statistics: " + ex.Message);
            }
        }

        public int GetReportCount(string wasteTypeId)
        {
            return reportCounts.ContainsKey(wasteTypeId) ? reportCounts[wasteTypeId] : 0;
        }

        public string GetTotalWeight(string wasteTypeId)
        {
            return totalWeights.ContainsKey(wasteTypeId) ? totalWeights[wasteTypeId].ToString("N1") : "0.0";
        }

        public string GetTotalCredits(string wasteTypeId)
        {
            return totalCredits.ContainsKey(wasteTypeId) ? totalCredits[wasteTypeId].ToString("N2") : "0.00";
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
            int totalTypes = dt.Rows.Count;
            int recyclableCount = 0;
            int organicCount = 0;
            decimal totalCredits = 0;

            foreach (DataRow row in dt.Rows)
            {
                string category = row["Category"].ToString();
                if (category == "Recyclable")
                    recyclableCount++;
                else if (category == "Organic")
                    organicCount++;

                if (row["CreditPerKg"] != DBNull.Value)
                    totalCredits += Convert.ToDecimal(row["CreditPerKg"]);
            }

            decimal avgCredit = totalTypes > 0 ? totalCredits / totalTypes : 0;

            statTotal.InnerText = totalTypes.ToString();
            statRecyclable.InnerText = recyclableCount.ToString();
            statOrganic.InnerText = organicCount.ToString();
            statAvgCredit.InnerText = "$" + avgCredit.ToString("N2");
        }

        // CRUD Operations
        protected void btnSaveWasteType_Click(object sender, EventArgs e)
        {
            try
            {
                string wasteTypeId = hdnWasteTypeId.Value;

                if (string.IsNullOrEmpty(wasteTypeId))
                {
                    // Add new waste type
                    AddNewWasteType();
                }
                else
                {
                    // Update existing waste type
                    UpdateWasteType(wasteTypeId);
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Error", "Failed to save waste type: " + ex.Message, "error");
            }
        }

        private void AddNewWasteType()
        {
            // Generate new WasteTypeId
            string newWasteTypeId = GetNextWasteTypeId();

            string query = @"INSERT INTO WasteTypes 
                            (WasteTypeId, Name, CreditPerKg, ColorCode, Description, Category)
                            VALUES (@WasteTypeId, @Name, @CreditPerKg, @ColorCode, @Description, @Category)";

            using (SqlConnection conn = new SqlConnection(connectionString))
            using (SqlCommand cmd = new SqlCommand(query, conn))
            {
                cmd.Parameters.AddWithValue("@WasteTypeId", newWasteTypeId);
                cmd.Parameters.AddWithValue("@Name", txtName.Text.Trim());
                cmd.Parameters.AddWithValue("@CreditPerKg", decimal.Parse(txtCreditPerKg.Text));
                cmd.Parameters.AddWithValue("@ColorCode", string.IsNullOrEmpty(txtColorCode.Text) ? DBNull.Value : (object)txtColorCode.Text);
                cmd.Parameters.AddWithValue("@Description", string.IsNullOrEmpty(txtDescription.Text) ? DBNull.Value : (object)txtDescription.Text);
                cmd.Parameters.AddWithValue("@Category", ddlCategory.SelectedValue);

                conn.Open();
                cmd.ExecuteNonQuery();
            }

            ShowMessage("Success", "Waste type added successfully!", "success");
            BindWasteTypes();

            // Close modal via JavaScript
            ScriptManager.RegisterStartupScript(this, this.GetType(), "CloseModal",
                "$('#wasteTypeModal').modal('hide');", true);
        }

        private void UpdateWasteType(string wasteTypeId)
        {
            string query = @"UPDATE WasteTypes 
                            SET Name = @Name,
                                CreditPerKg = @CreditPerKg,
                                ColorCode = @ColorCode,
                                Description = @Description,
                                Category = @Category
                            WHERE WasteTypeId = @WasteTypeId";

            using (SqlConnection conn = new SqlConnection(connectionString))
            using (SqlCommand cmd = new SqlCommand(query, conn))
            {
                cmd.Parameters.AddWithValue("@WasteTypeId", wasteTypeId);
                cmd.Parameters.AddWithValue("@Name", txtName.Text.Trim());
                cmd.Parameters.AddWithValue("@CreditPerKg", decimal.Parse(txtCreditPerKg.Text));
                cmd.Parameters.AddWithValue("@ColorCode", string.IsNullOrEmpty(txtColorCode.Text) ? DBNull.Value : (object)txtColorCode.Text);
                cmd.Parameters.AddWithValue("@Description", string.IsNullOrEmpty(txtDescription.Text) ? DBNull.Value : (object)txtDescription.Text);
                cmd.Parameters.AddWithValue("@Category", ddlCategory.SelectedValue);

                conn.Open();
                cmd.ExecuteNonQuery();
            }

            ShowMessage("Success", "Waste type updated successfully!", "success");
            BindWasteTypes();

            // Close modal via JavaScript
            ScriptManager.RegisterStartupScript(this, this.GetType(), "CloseModal",
                "$('#wasteTypeModal').modal('hide');", true);
        }

        protected void btnDeleteWasteType_Click(object sender, EventArgs e)
        {
            try
            {
                string wasteTypeId = hdnWasteTypeId.Value;

                // Check if waste type is being used
                string checkQuery = "SELECT COUNT(*) FROM WasteReports WHERE WasteTypeId = @WasteTypeId";
                using (SqlConnection conn = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand(checkQuery, conn))
                {
                    cmd.Parameters.AddWithValue("@WasteTypeId", wasteTypeId);
                    conn.Open();
                    int usageCount = (int)cmd.ExecuteScalar();

                    if (usageCount > 0)
                    {
                        ShowMessage("Error", "Cannot delete waste type that is being used in waste reports.", "error");
                        return;
                    }
                }

                // Delete waste type
                string deleteQuery = "DELETE FROM WasteTypes WHERE WasteTypeId = @WasteTypeId";
                using (SqlConnection conn = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand(deleteQuery, conn))
                {
                    cmd.Parameters.AddWithValue("@WasteTypeId", wasteTypeId);
                    conn.Open();
                    int rowsAffected = cmd.ExecuteNonQuery();

                    if (rowsAffected > 0)
                    {
                        ShowMessage("Success", "Waste type deleted successfully!", "success");
                        BindWasteTypes();
                    }
                    else
                    {
                        ShowMessage("Error", "Waste type not found.", "error");
                    }
                }

                // Close modal via JavaScript
                ScriptManager.RegisterStartupScript(this, this.GetType(), "CloseModal",
                    "$('#wasteTypeModal').modal('hide');", true);
            }
            catch (Exception ex)
            {
                ShowMessage("Error", "Failed to delete waste type: " + ex.Message, "error");
            }
        }

        private void LoadWasteTypeForEdit(string wasteTypeId)
        {
            string query = @"SELECT * FROM WasteTypes WHERE WasteTypeId = @WasteTypeId";

            using (SqlConnection conn = new SqlConnection(connectionString))
            using (SqlCommand cmd = new SqlCommand(query, conn))
            {
                cmd.Parameters.AddWithValue("@WasteTypeId", wasteTypeId);
                conn.Open();

                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    if (reader.Read())
                    {
                        hdnWasteTypeId.Value = reader["WasteTypeId"].ToString();
                        txtName.Text = reader["Name"].ToString();
                        txtCreditPerKg.Text = reader["CreditPerKg"].ToString();
                        txtColorCode.Text = reader["ColorCode"] != DBNull.Value ? reader["ColorCode"].ToString() : "#007bff";
                        txtDescription.Text = reader["Description"] != DBNull.Value ? reader["Description"].ToString() : "";

                        string category = reader["Category"] != DBNull.Value ? reader["Category"].ToString() : "Other";
                        ListItem item = ddlCategory.Items.FindByValue(category);
                        if (item != null)
                            ddlCategory.SelectedValue = category;
                    }
                }
            }

            // Show modal via JavaScript
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ShowEditModal",
                "var modal = new bootstrap.Modal(document.getElementById('wasteTypeModal')); modal.show();", true);
        }

        private string GetNextWasteTypeId()
        {
            string query = "SELECT ISNULL(MAX(CAST(SUBSTRING(WasteTypeId, 3, LEN(WasteTypeId)) AS INT)), 0) + 1 FROM WasteTypes WHERE WasteTypeId LIKE 'WT%'";

            using (SqlConnection conn = new SqlConnection(connectionString))
            using (SqlCommand cmd = new SqlCommand(query, conn))
            {
                conn.Open();
                int nextId = (int)cmd.ExecuteScalar();
                return "WT" + nextId.ToString("D2");
            }
        }

        // Helper Methods
        public string GetColorCode(object colorCode)
        {
            if (colorCode == null || colorCode == DBNull.Value || string.IsNullOrEmpty(colorCode.ToString()))
                return "#6c757d"; // Default gray

            string code = colorCode.ToString();
            if (!code.StartsWith("#"))
                code = "#" + code;

            return code;
        }

        public string GetCategoryColor(string category)
        {
            switch (category.ToLower())
            {
                case "recyclable":
                    return "#28a745"; // Green
                case "organic":
                    return "#20c997"; // Teal
                case "hazardous":
                    return "#dc3545"; // Red
                case "electronic":
                    return "#6f42c1"; // Purple
                default:
                    return "#6c757d"; // Gray
            }
        }

        public string GetDeleteButton(string wasteTypeId)
        {
            // Only show delete button if not in use
            int reportCount = GetReportCount(wasteTypeId);

            if (reportCount == 0)
            {
                return string.Format(
                    "<button type='button' class='btn btn-danger' onclick='editWasteType(\"{0}\")'>" +
                    "<i class='fas fa-trash me-1'></i>Delete</button>",
                    wasteTypeId);
            }
            return string.Empty;
        }

        // Event Handlers
        protected void btnApplyFilters_Click(object sender, EventArgs e)
        {
            BindWasteTypes();
        }

        protected void btnClearFilters_Click(object sender, EventArgs e)
        {
            txtSearch.Text = "";
            ddlCategoryFilter.SelectedValue = "all";
            BindWasteTypes();
        }

        protected void btnRefresh_Click(object sender, EventArgs e)
        {
            BindWasteTypes();
        }

        protected void btnCardView_Click(object sender, EventArgs e)
        {
            pnlCardView.Visible = true;
            pnlTableView.Visible = false;
            btnCardView.CssClass = "view-btn active";
            btnTableView.CssClass = "view-btn";
        }

        protected void btnTableView_Click(object sender, EventArgs e)
        {
            pnlCardView.Visible = false;
            pnlTableView.Visible = true;
            btnCardView.CssClass = "view-btn";
            btnTableView.CssClass = "view-btn active";
        }

        protected void btnExportCSV_Click(object sender, EventArgs e)
        {
            try
            {
                Response.Clear();
                Response.Buffer = true;
                Response.AddHeader("content-disposition", "attachment;filename=WasteTypes_Export_" + DateTime.Now.ToString("yyyyMMdd") + ".csv");
                Response.Charset = "";
                Response.ContentType = "application/text";

                DataTable dt = GetWasteTypesDataForExport();
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

        private DataTable GetWasteTypesDataForExport()
        {
            string query = @"SELECT 
                            WasteTypeId as 'Waste Type ID',
                            Name as 'Waste Type Name',
                            Category as 'Category',
                            CreditPerKg as 'Credit Per Kg ($)',
                            ISNULL(ColorCode, '') as 'Color Code',
                            ISNULL(Description, '') as 'Description'
                            FROM WasteTypes
                            ORDER BY Name";

            DataTable dt = GetDataTable(query);

            // Add usage statistics to export
            dt.Columns.Add("Total Reports", typeof(int));
            dt.Columns.Add("Total Weight (kg)", typeof(decimal));
            dt.Columns.Add("Total Credits ($)", typeof(decimal));

            foreach (DataRow row in dt.Rows)
            {
                string wasteTypeId = row["Waste Type ID"].ToString();
                row["Total Reports"] = GetReportCount(wasteTypeId);
                row["Total Weight (kg)"] = totalWeights.ContainsKey(wasteTypeId) ? totalWeights[wasteTypeId] : 0;
                row["Total Credits ($)"] = totalCredits.ContainsKey(wasteTypeId) ? totalCredits[wasteTypeId] : 0;
            }

            return dt;
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
        protected void rptWasteTypesGrid_ItemDataBound(object sender, RepeaterItemEventArgs e)
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