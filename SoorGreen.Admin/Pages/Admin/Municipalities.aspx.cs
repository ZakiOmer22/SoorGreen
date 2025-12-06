using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Web.Configuration;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace SoorGreen.Admin.Admin
{
    public partial class Municipalities : System.Web.UI.Page
    {
        private string connectionString = WebConfigurationManager.ConnectionStrings["SoorGreenDBConnectionString"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                BindMunicipalities();
            }
        }

        private void BindMunicipalities()
        {
            try
            {
                // SIMPLE QUERY - JUST GET ALL DATA
                string query = @"SELECT 
                                MunicipalityId,
                                Name,
                                ISNULL(Region, 'N/A') as Region,
                                ISNULL(Status, 'Active') as Status,
                                ISNULL(Population, 0) as Population,
                                ISNULL(Area, 0.0) as Area,
                                ISNULL(ContactPerson, 'N/A') as ContactPerson,
                                ISNULL(ContactNumber, 'N/A') as ContactNumber,
                                ISNULL(Email, 'N/A') as Email,
                                ISNULL(Address, 'N/A') as Address,
                                ISNULL(EstablishedDate, GETDATE()) as EstablishedDate,
                                ISNULL(Description, '') as Description
                                FROM Municipalities
                                ORDER BY Name";

                // Get data from database
                DataTable dt = GetDataTable(query);

                // Bind to repeater for grid view
                rptMunicipalitiesGrid.DataSource = dt;
                rptMunicipalitiesGrid.DataBind();

                // Bind to gridview for table view
                gvMunicipalities.DataSource = dt;
                gvMunicipalities.DataBind();

                // Update stats
                UpdateStats(dt);

                // Update municipality count
                lblMunicipalityCount.Text = dt.Rows.Count.ToString();

                // Show message if no data
                if (dt.Rows.Count == 0)
                {
                    ShowMessage("Info", "No municipalities found. Add your first municipality.", "info");
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Error", "Failed to load data: " + ex.Message, "error");
            }
        }

        protected void btnExportCSV_Click(object sender, EventArgs e)
        {
            try
            {
                Response.Clear();
                Response.Buffer = true;
                Response.AddHeader("content-disposition", "attachment;filename=Municipalities_" + DateTime.Now.ToString("yyyyMMdd_HHmm") + ".csv");
                Response.Charset = "";
                Response.ContentType = "application/text";

                // Get all municipalities data
                string query = @"SELECT 
                        MunicipalityId as 'ID',
                        Name as 'Municipality Name',
                        ISNULL(Region, 'N/A') as 'Region',
                        ISNULL(Status, 'Active') as 'Status',
                        ISNULL(Population, 0) as 'Population',
                        ISNULL(Area, 0.0) as 'Area (km²)',
                        ISNULL(ContactPerson, 'N/A') as 'Contact Person',
                        ISNULL(ContactNumber, 'N/A') as 'Contact Number',
                        ISNULL(Email, 'N/A') as 'Email',
                        ISNULL(Address, 'N/A') as 'Address',
                        FORMAT(ISNULL(EstablishedDate, GETDATE()), 'yyyy-MM-dd') as 'Established Date',
                        ISNULL(Description, '') as 'Description'
                        FROM Municipalities
                        ORDER BY Name";

                DataTable dt = GetDataTable(query);

                // Convert to CSV
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

                Response.Output.Write(sb.ToString());
                Response.Flush();
                Response.End();
            }
            catch (Exception ex)
            {
                ShowMessage("Error", "Failed to export CSV: " + ex.Message, "error");
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
            int totalMunicipalities = dt.Rows.Count;
            int activeMunicipalities = 0;
            long totalPopulation = 0;
            decimal totalArea = 0;

            foreach (DataRow row in dt.Rows)
            {
                string status = row["Status"].ToString();
                if (status == "Active")
                {
                    activeMunicipalities++;
                }

                long population = Convert.ToInt64(row["Population"]);
                totalPopulation += population;

                decimal area = Convert.ToDecimal(row["Area"]);
                totalArea += area;
            }

            statTotalMunicipalities.InnerText = totalMunicipalities.ToString();
            statActiveMunicipalities.InnerText = activeMunicipalities.ToString();
            statTotalPopulation.InnerText = FormatNumber(totalPopulation);
            statTotalArea.InnerText = totalArea.ToString("N0") + " km²";
        }

        private void LoadMunicipalityForEdit(string municipalityId)
        {
            try
            {
                string query = @"SELECT 
                                MunicipalityId,
                                Name,
                                ISNULL(Region, '') as Region,
                                ISNULL(Status, 'Active') as Status,
                                ISNULL(Population, 0) as Population,
                                ISNULL(Area, 0.0) as Area,
                                ISNULL(ContactPerson, '') as ContactPerson,
                                ISNULL(ContactNumber, '') as ContactNumber,
                                ISNULL(Email, '') as Email,
                                ISNULL(Address, '') as Address,
                                EstablishedDate,
                                ISNULL(Description, '') as Description
                                FROM Municipalities
                                WHERE MunicipalityId = @MunicipalityId";

                using (SqlConnection conn = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@MunicipalityId", municipalityId);
                    conn.Open();

                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            hdnMunicipalityId.Value = reader["MunicipalityId"].ToString();
                            txtMunicipalityId.Text = reader["MunicipalityId"].ToString();
                            txtMunicipalityName.Text = reader["Name"].ToString();
                            txtRegion.Text = reader["Region"].ToString();
                            txtPopulation.Text = reader["Population"].ToString();
                            txtArea.Text = Convert.ToDecimal(reader["Area"]).ToString("N2");
                            txtContactPerson.Text = reader["ContactPerson"].ToString();
                            txtContactNumber.Text = reader["ContactNumber"].ToString();
                            txtEmail.Text = reader["Email"].ToString();
                            txtAddress.Text = reader["Address"].ToString();
                            txtDescription.Text = reader["Description"].ToString();

                            // Status dropdown
                            string status = reader["Status"].ToString();
                            if (!string.IsNullOrEmpty(status))
                            {
                                ddlStatus.SelectedValue = status;
                            }

                            // Established date
                            if (reader["EstablishedDate"] != DBNull.Value)
                            {
                                DateTime establishedDate = Convert.ToDateTime(reader["EstablishedDate"]);
                                txtEstablishedDate.Text = establishedDate.ToString("yyyy-MM-dd");
                            }
                            else
                            {
                                txtEstablishedDate.Text = "";
                            }

                            // Show delete button for edit mode
                            btnDeleteMunicipality.Visible = true;
                        }
                        else
                        {
                            ShowMessage("Error", "Municipality not found.", "error");
                            return;
                        }
                    }
                }

                // Show modal via JavaScript
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ShowMunicipalityModal",
                    "$('#municipalityModal').modal('show');", true);
            }
            catch (Exception ex)
            {
                ShowMessage("Error", "Failed to load: " + ex.Message, "error");
            }
        }

        private void DeleteMunicipality(string municipalityId)
        {
            try
            {
                // Simple delete - no user checks
                string deleteQuery = "DELETE FROM Municipalities WHERE MunicipalityId = @MunicipalityId";

                using (SqlConnection conn = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand(deleteQuery, conn))
                {
                    cmd.Parameters.AddWithValue("@MunicipalityId", municipalityId);
                    conn.Open();
                    int rowsAffected = cmd.ExecuteNonQuery();

                    if (rowsAffected > 0)
                    {
                        ShowMessage("Success", "Municipality deleted successfully.", "success");
                    }
                    else
                    {
                        ShowMessage("Error", "Municipality not found.", "error");
                    }
                }

                BindMunicipalities();
            }
            catch (Exception ex)
            {
                ShowMessage("Error", "Failed to delete: " + ex.Message, "error");
            }
        }

        // CRUD Operations
        protected void btnSaveMunicipality_Click(object sender, EventArgs e)
        {
            try
            {
                string municipalityId = hdnMunicipalityId.Value;
                string name = txtMunicipalityName.Text.Trim();

                if (string.IsNullOrEmpty(name))
                {
                    ShowMessage("Error", "Please enter municipality name.", "error");
                    return;
                }

                // Parse numbers
                long population = 0;
                if (!string.IsNullOrEmpty(txtPopulation.Text))
                {
                    long.TryParse(txtPopulation.Text, out population);
                }

                decimal area = 0;
                if (!string.IsNullOrEmpty(txtArea.Text))
                {
                    decimal.TryParse(txtArea.Text, out area);
                }

                DateTime? establishedDate = null;
                if (!string.IsNullOrEmpty(txtEstablishedDate.Text))
                {
                    DateTime tempDate;
                    if (DateTime.TryParse(txtEstablishedDate.Text, out tempDate))
                    {
                        establishedDate = tempDate;
                    }
                }

                if (string.IsNullOrEmpty(municipalityId))
                {
                    // Add new municipality
                    municipalityId = GetNextMunicipalityId();

                    string query = @"INSERT INTO Municipalities 
                                    (MunicipalityId, Name, Region, Status, Population, Area, 
                                     ContactPerson, ContactNumber, Email, Address, EstablishedDate, Description)
                                    VALUES (@MunicipalityId, @Name, @Region, @Status, @Population, @Area,
                                            @ContactPerson, @ContactNumber, @Email, @Address, @EstablishedDate, @Description)";

                    using (SqlConnection conn = new SqlConnection(connectionString))
                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@MunicipalityId", municipalityId);
                        cmd.Parameters.AddWithValue("@Name", name);
                        cmd.Parameters.AddWithValue("@Region", txtRegion.Text);
                        cmd.Parameters.AddWithValue("@Status", ddlStatus.SelectedValue);
                        cmd.Parameters.AddWithValue("@Population", population);
                        cmd.Parameters.AddWithValue("@Area", area);
                        cmd.Parameters.AddWithValue("@ContactPerson", txtContactPerson.Text);
                        cmd.Parameters.AddWithValue("@ContactNumber", txtContactNumber.Text);
                        cmd.Parameters.AddWithValue("@Email", txtEmail.Text);
                        cmd.Parameters.AddWithValue("@Address", txtAddress.Text);
                        cmd.Parameters.AddWithValue("@Description", txtDescription.Text);

                        if (establishedDate.HasValue)
                            cmd.Parameters.AddWithValue("@EstablishedDate", establishedDate.Value);
                        else
                            cmd.Parameters.AddWithValue("@EstablishedDate", DBNull.Value);

                        conn.Open();
                        cmd.ExecuteNonQuery();
                    }

                    ShowMessage("Success", "Municipality added successfully.", "success");
                }
                else
                {
                    // Update existing municipality
                    string query = @"UPDATE Municipalities SET
                                    Name = @Name,
                                    Region = @Region,
                                    Status = @Status,
                                    Population = @Population,
                                    Area = @Area,
                                    ContactPerson = @ContactPerson,
                                    ContactNumber = @ContactNumber,
                                    Email = @Email,
                                    Address = @Address,
                                    EstablishedDate = @EstablishedDate,
                                    Description = @Description
                                    WHERE MunicipalityId = @MunicipalityId";

                    using (SqlConnection conn = new SqlConnection(connectionString))
                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@MunicipalityId", municipalityId);
                        cmd.Parameters.AddWithValue("@Name", name);
                        cmd.Parameters.AddWithValue("@Region", txtRegion.Text);
                        cmd.Parameters.AddWithValue("@Status", ddlStatus.SelectedValue);
                        cmd.Parameters.AddWithValue("@Population", population);
                        cmd.Parameters.AddWithValue("@Area", area);
                        cmd.Parameters.AddWithValue("@ContactPerson", txtContactPerson.Text);
                        cmd.Parameters.AddWithValue("@ContactNumber", txtContactNumber.Text);
                        cmd.Parameters.AddWithValue("@Email", txtEmail.Text);
                        cmd.Parameters.AddWithValue("@Address", txtAddress.Text);
                        cmd.Parameters.AddWithValue("@Description", txtDescription.Text);

                        if (establishedDate.HasValue)
                            cmd.Parameters.AddWithValue("@EstablishedDate", establishedDate.Value);
                        else
                            cmd.Parameters.AddWithValue("@EstablishedDate", DBNull.Value);

                        conn.Open();
                        cmd.ExecuteNonQuery();
                    }

                    ShowMessage("Success", "Municipality updated successfully.", "success");
                }

                // Close modal and refresh
                ScriptManager.RegisterStartupScript(this, this.GetType(), "CloseModal",
                    "$('#municipalityModal').modal('hide');", true);

                BindMunicipalities();
            }
            catch (Exception ex)
            {
                ShowMessage("Error", "Failed to save: " + ex.Message, "error");
            }
        }

        protected void btnDeleteMunicipality_Click(object sender, EventArgs e)
        {
            string municipalityId = hdnMunicipalityId.Value;
            DeleteMunicipality(municipalityId);

            // Close modal
            ScriptManager.RegisterStartupScript(this, this.GetType(), "CloseModal",
                "$('#municipalityModal').modal('hide');", true);
        }

        private string GetNextMunicipalityId()
        {
            string query = "SELECT ISNULL(MAX(CAST(SUBSTRING(MunicipalityId, 2, LEN(MunicipalityId)) AS INT)), 0) + 1 FROM Municipalities WHERE MunicipalityId LIKE 'M%'";

            using (SqlConnection conn = new SqlConnection(connectionString))
            using (SqlCommand cmd = new SqlCommand(query, conn))
            {
                conn.Open();
                object result = cmd.ExecuteScalar();
                if (result != DBNull.Value && result != null)
                {
                    int nextId = Convert.ToInt32(result);
                    return string.Format("M{0:D3}", nextId);
                }
                return "M001";
            }
        }

        // Repeater ItemDataBound Event Handler
        protected void rptMunicipalitiesGrid_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            
            if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
            {
                

            }
        }

        // UI Helper Methods
        public string GetStatusBadgeClass(string status)
        {
            if (string.IsNullOrEmpty(status))
                return "badge-secondary";

            switch (status.ToLower())
            {
                case "active":
                    return "badge-success active";
                case "inactive":
                    return "badge-secondary inactive";
                case "under maintenance":
                    return "badge-warning maintenance";
                default:
                    return "badge-secondary";
            }
        }

        public string FormatNumber(object number)
        {
            if (number == DBNull.Value || number == null)
                return "0";

            long num = Convert.ToInt64(number);

            if (num >= 1000000)
            {
                return string.Format("{0:F1}M", num / 1000000.0);
            }
            else if (num >= 1000)
            {
                return string.Format("{0:F1}K", num / 1000.0);
            }
            else
            {
                return num.ToString("N0");
            }
        }

        public int GetUserCount(string municipalityId)
        {
            return 0; // Simple return for UI
        }

        public int GetWasteReportCount(string municipalityId)
        {
            return 0; // Simple return for UI
        }

        public string GetEstablishedYear(object establishedDate)
        {
            if (establishedDate == DBNull.Value || establishedDate == null)
                return "N/A";

            DateTime date = Convert.ToDateTime(establishedDate);
            return date.ToString("yyyy");
        }

        public string GetFormattedDate(object date)
        {
            if (date == DBNull.Value || date == null)
                return "N/A";

            DateTime dt = Convert.ToDateTime(date);
            return dt.ToString("MMM dd, yyyy");
        }

        // Event Handlers
        protected void btnApplyFilters_Click(object sender, EventArgs e)
        {
            try
            {
                string query = @"SELECT 
                                MunicipalityId,
                                Name,
                                ISNULL(Region, 'N/A') as Region,
                                ISNULL(Status, 'Active') as Status,
                                ISNULL(Population, 0) as Population,
                                ISNULL(Area, 0.0) as Area,
                                ISNULL(ContactPerson, 'N/A') as ContactPerson,
                                ISNULL(ContactNumber, 'N/A') as ContactNumber,
                                ISNULL(Email, 'N/A') as Email,
                                ISNULL(Address, 'N/A') as Address,
                                ISNULL(EstablishedDate, GETDATE()) as EstablishedDate,
                                ISNULL(Description, '') as Description
                                FROM Municipalities
                                WHERE 1=1";

                List<SqlParameter> parameters = new List<SqlParameter>();

                // Apply search filter
                if (!string.IsNullOrEmpty(txtSearch.Text))
                {
                    query += " AND (Name LIKE @search OR Region LIKE @search OR ContactPerson LIKE @search)";
                    parameters.Add(new SqlParameter("@search", "%" + txtSearch.Text + "%"));
                }

                // Apply status filter
                if (ddlStatusFilter.SelectedValue != "all")
                {
                    query += " AND Status = @status";
                    parameters.Add(new SqlParameter("@status", ddlStatusFilter.SelectedValue));
                }

                query += " ORDER BY Name";

                DataTable dt = GetDataTable(query, parameters.ToArray());

                // Bind data
                rptMunicipalitiesGrid.DataSource = dt;
                rptMunicipalitiesGrid.DataBind();
                gvMunicipalities.DataSource = dt;
                gvMunicipalities.DataBind();
                UpdateStats(dt);
                lblMunicipalityCount.Text = dt.Rows.Count.ToString();
            }
            catch (Exception ex)
            {
                ShowMessage("Error", "Failed to filter: " + ex.Message, "error");
            }
        }

        protected void btnClearFilters_Click(object sender, EventArgs e)
        {
            txtSearch.Text = "";
            ddlStatusFilter.SelectedValue = "all";
            txtPopulationFrom.Text = "";
            txtPopulationTo.Text = "";
            BindMunicipalities();
        }

        protected void btnRefresh_Click(object sender, EventArgs e)
        {
            BindMunicipalities();
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

        // Handle JavaScript events
        protected void Page_PreRender(object sender, EventArgs e)
        {
            // Handle edit/view/delete from JavaScript
            if (Request["__EVENTARGUMENT"] != null)
            {
                string eventArg = Request["__EVENTARGUMENT"];
                if (eventArg.StartsWith("edit_"))
                {
                    string municipalityId = eventArg.Substring(5);
                    LoadMunicipalityForEdit(municipalityId);
                }
                else if (eventArg.StartsWith("delete_"))
                {
                    string municipalityId = eventArg.Substring(7);
                    DeleteMunicipality(municipalityId);
                }
            }
        }
    }
}