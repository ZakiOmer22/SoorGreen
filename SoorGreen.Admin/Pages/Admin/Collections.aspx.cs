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
    public partial class Collections : System.Web.UI.Page
    {
        private string connectionString = WebConfigurationManager.ConnectionStrings["SoorGreenDBConnectionString"].ConnectionString;
        private Dictionary<string, decimal> wasteTypeRates = new Dictionary<string, decimal>();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadWasteTypeRates();
                BindCollectorDropdown();
                BindCollections();
            }

            // Handle events from JavaScript
            if (Request["__EVENTTARGET"] == "ctl00$MainContent$hdnPickupId")
            {
                string eventArg = Request["__EVENTARGUMENT"];
                if (eventArg.StartsWith("view_"))
                {
                    string pickupId = eventArg.Substring(5);
                    LoadCollectionForView(pickupId, false);
                }
                else if (eventArg.StartsWith("assign_"))
                {
                    string pickupId = eventArg.Substring(7);
                    LoadCollectionForAssignment(pickupId);
                }
                else if (eventArg.StartsWith("verify_"))
                {
                    string pickupId = eventArg.Substring(7);
                    LoadCollectionForVerification(pickupId);
                }
            }
        }

        private void LoadWasteTypeRates()
        {
            try
            {
                string query = "SELECT WasteTypeId, CreditPerKg FROM WasteTypes";
                using (SqlConnection conn = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    conn.Open();
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            wasteTypeRates[reader["WasteTypeId"].ToString()] = Convert.ToDecimal(reader["CreditPerKg"]);
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error loading waste type rates: " + ex.Message);
            }
        }

        private void BindCollectorDropdown()
        {
            string query = "SELECT UserId, FullName FROM Users WHERE RoleId = 'CLCT' OR RoleId = 'R003' ORDER BY FullName";
            ddlCollector.DataSource = GetDataTable(query);
            ddlCollector.DataTextField = "FullName";
            ddlCollector.DataValueField = "UserId";
            ddlCollector.DataBind();
            ddlCollector.Items.Insert(0, new ListItem("-- Select Collector --", ""));
        }

        private void BindCollections()
        {
            try
            {
                string query = @"SELECT 
                                pr.PickupId,
                                pr.Status,
                                pr.ScheduledAt,
                                pr.CompletedAt,
                                pr.CollectorId,
                                wr.EstimatedKg,
                                wr.Address,
                                wr.CreatedAt,
                                wr.Lat,
                                wr.Lng,
                                u.FullName as CitizenName,
                                u.Phone as CitizenPhone,
                                u.UserId as CitizenId,
                                c.FullName as CollectorName,
                                c.Phone as CollectorPhone,
                                c.UserId as CollectorId,
                                wt.Name as WasteTypeName,
                                wt.WasteTypeId,
                                wt.CreditPerKg,
                                pv.VerifiedKg,
                                pv.MaterialType,
                                pv.VerificationMethod,
                                pv.VerifiedAt,
                                (pv.VerifiedKg * wt.CreditPerKg) as CreditsEarned,
                                DATEDIFF(HOUR, wr.CreatedAt, ISNULL(pr.CompletedAt, GETDATE())) as CompletionTime
                                FROM PickupRequests pr
                                JOIN WasteReports wr ON pr.ReportId = wr.ReportId
                                JOIN Users u ON wr.UserId = u.UserId
                                LEFT JOIN Users c ON pr.CollectorId = c.UserId
                                JOIN WasteTypes wt ON wr.WasteTypeId = wt.WasteTypeId
                                LEFT JOIN PickupVerifications pv ON pr.PickupId = pv.PickupId
                                WHERE 1=1";

                List<SqlParameter> parameters = new List<SqlParameter>();

                // Apply search filter
                if (!string.IsNullOrEmpty(txtSearch.Text))
                {
                    query += " AND (pr.PickupId LIKE @search OR u.FullName LIKE @search OR c.FullName LIKE @search OR wr.Address LIKE @search)";
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
                rptCollectionsGrid.DataSource = dt;
                rptCollectionsGrid.DataBind();

                // Bind to gridview for table view
                gvCollections.DataSource = dt;
                gvCollections.DataBind();

                // Update stats
                UpdateStats(dt);

                // Update collection count
                lblCollectionCount.Text = dt.Rows.Count.ToString();

                // Show message if no data
                if (dt.Rows.Count == 0)
                {
                    ShowMessage("Info", "No collections found.", "info");
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Error", "Failed to load collections: " + ex.Message, "error");
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
            int totalCollections = dt.Rows.Count;
            int activeCollections = 0;
            int completedCollections = 0;
            decimal totalWeight = 0;

            foreach (DataRow row in dt.Rows)
            {
                string status = row["Status"].ToString();
                if (status == "Requested" || status == "Assigned" || status == "InProgress")
                    activeCollections++;
                else if (status == "Collected" || status == "Completed")
                    completedCollections++;

                if (row["VerifiedKg"] != DBNull.Value)
                    totalWeight += Convert.ToDecimal(row["VerifiedKg"]);
                else if (row["EstimatedKg"] != DBNull.Value)
                    totalWeight += Convert.ToDecimal(row["EstimatedKg"]);
            }

            statTotal.InnerText = totalCollections.ToString();
            statActive.InnerText = activeCollections.ToString();
            statCompleted.InnerText = completedCollections.ToString();
            statTotalWeight.InnerText = totalWeight.ToString("N1") + " kg";
        }

        // Collection Management Methods
        private void LoadCollectionForView(string pickupId, bool forVerification)
        {
            string query = @"SELECT 
                            pr.PickupId,
                            pr.Status,
                            pr.ScheduledAt,
                            pr.CompletedAt,
                            pr.CollectorId,
                            wr.EstimatedKg,
                            wr.Address,
                            wr.Lat,
                            wr.Lng,
                            u.FullName as CitizenName,
                            u.Phone as CitizenPhone,
                            c.FullName as CollectorName,
                            wt.Name as WasteTypeName,
                            wt.WasteTypeId,
                            wt.CreditPerKg,
                            pv.VerifiedKg,
                            pv.MaterialType,
                            pv.VerificationMethod,
                            pv.Notes,
                            pv.VerificationId
                            FROM PickupRequests pr
                            JOIN WasteReports wr ON pr.ReportId = wr.ReportId
                            JOIN Users u ON wr.UserId = u.UserId
                            LEFT JOIN Users c ON pr.CollectorId = c.UserId
                            JOIN WasteTypes wt ON wr.WasteTypeId = wt.WasteTypeId
                            LEFT JOIN PickupVerifications pv ON pr.PickupId = pv.PickupId
                            WHERE pr.PickupId = @PickupId";

            using (SqlConnection conn = new SqlConnection(connectionString))
            using (SqlCommand cmd = new SqlCommand(query, conn))
            {
                cmd.Parameters.AddWithValue("@PickupId", pickupId);
                conn.Open();

                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    if (reader.Read())
                    {
                        hdnPickupId.Value = reader["PickupId"].ToString();
                        txtPickupId.Text = reader["PickupId"].ToString();
                        txtCitizen.Text = reader["CitizenName"].ToString();
                        txtAddress.Text = reader["Address"].ToString();
                        txtWasteType.Text = reader["WasteTypeName"].ToString();
                        txtEstimatedKg.Text = reader["EstimatedKg"].ToString();

                        string collectorId = reader["CollectorId"] != DBNull.Value ? reader["CollectorId"].ToString() : "";
                        if (!string.IsNullOrEmpty(collectorId))
                        {
                            ListItem item = ddlCollector.Items.FindByValue(collectorId);
                            if (item != null)
                                ddlCollector.SelectedValue = collectorId;
                        }

                        if (forVerification)
                        {
                            litModalTitle.Text = "Verify Collection";
                            btnVerifyCollection.Visible = true;
                            btnUpdateCollection.Visible = false;
                            btnCancelPickup.Visible = true;

                            // Enable editing for verification
                            txtVerifiedKg.Enabled = true;
                            txtMaterialType.Enabled = true;
                            ddlVerificationMethod.Enabled = true;
                            txtNotes.Enabled = true;

                            // Set default values if verification exists
                            if (reader["VerifiedKg"] != DBNull.Value)
                            {
                                txtVerifiedKg.Text = reader["VerifiedKg"].ToString();
                                txtMaterialType.Text = reader["MaterialType"].ToString();

                                string method = reader["VerificationMethod"].ToString();
                                ListItem methodItem = ddlVerificationMethod.Items.FindByValue(method);
                                if (methodItem != null)
                                    ddlVerificationMethod.SelectedValue = method;

                                txtNotes.Text = reader["Notes"] != DBNull.Value ? reader["Notes"].ToString() : "";
                            }

                            // Calculate credits
                            decimal creditRate = Convert.ToDecimal(reader["CreditPerKg"]);
                            decimal estimatedKg = Convert.ToDecimal(reader["EstimatedKg"]);
                            creditsCalculation.InnerText = string.Format("{0} kg × ${1:N2}/kg = ${2:N2}", estimatedKg, creditRate, estimatedKg * creditRate);
                        }
                        else
                        {
                            litModalTitle.Text = "Collection Details";
                            btnVerifyCollection.Visible = false;
                            btnUpdateCollection.Visible = true;
                            btnCancelPickup.Visible = true;

                            // Disable editing for view mode
                            txtVerifiedKg.Enabled = false;
                            txtMaterialType.Enabled = false;
                            ddlVerificationMethod.Enabled = false;
                            txtNotes.Enabled = false;

                            // Load verification data if exists
                            if (reader["VerifiedKg"] != DBNull.Value)
                            {
                                txtVerifiedKg.Text = reader["VerifiedKg"].ToString();
                                txtMaterialType.Text = reader["MaterialType"].ToString();

                                string method = reader["VerificationMethod"].ToString();
                                ListItem methodItem = ddlVerificationMethod.Items.FindByValue(method);
                                if (methodItem != null)
                                    ddlVerificationMethod.SelectedValue = method;

                                txtNotes.Text = reader["Notes"] != DBNull.Value ? reader["Notes"].ToString() : "";
                                hdnVerificationId.Value = reader["VerificationId"].ToString();
                            }
                        }
                    }
                }
            }

            // Show modal via JavaScript
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ShowCollectionModal",
                "var modal = new bootstrap.Modal(document.getElementById('collectionModal')); modal.show();", true);
        }

        private void LoadCollectionForAssignment(string pickupId)
        {
            LoadCollectionForView(pickupId, false);
            litModalTitle.Text = "Assign Collector";
            btnVerifyCollection.Visible = false;
            btnUpdateCollection.Visible = false;
            btnCancelPickup.Visible = false;

            // Enable collector dropdown only
            ddlCollector.Enabled = true;
        }

        private void LoadCollectionForVerification(string pickupId)
        {
            LoadCollectionForView(pickupId, true);
        }

        // Event Handlers for CRUD Operations
        protected void btnVerifyCollection_Click(object sender, EventArgs e)
        {
            try
            {
                string pickupId = hdnPickupId.Value;
                decimal verifiedKg = decimal.Parse(txtVerifiedKg.Text);
                string materialType = txtMaterialType.Text;
                string verificationMethod = ddlVerificationMethod.SelectedValue;
                string notes = txtNotes.Text;

                // Get waste type ID and credit rate
                string wasteTypeQuery = @"SELECT wr.WasteTypeId, wt.CreditPerKg 
                                        FROM WasteReports wr
                                        JOIN WasteTypes wt ON wr.WasteTypeId = wt.WasteTypeId
                                        JOIN PickupRequests pr ON wr.ReportId = pr.ReportId
                                        WHERE pr.PickupId = @PickupId";

                string wasteTypeId = "";
                decimal creditRate = 0;

                using (SqlConnection conn = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand(wasteTypeQuery, conn))
                {
                    cmd.Parameters.AddWithValue("@PickupId", pickupId);
                    conn.Open();

                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            wasteTypeId = reader["WasteTypeId"].ToString();
                            creditRate = Convert.ToDecimal(reader["CreditPerKg"]);
                        }
                    }
                }

                // Get citizen ID
                string citizenQuery = @"SELECT wr.UserId 
                                       FROM WasteReports wr
                                       JOIN PickupRequests pr ON wr.ReportId = pr.ReportId
                                       WHERE pr.PickupId = @PickupId";

                string citizenId = "";

                using (SqlConnection conn = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand(citizenQuery, conn))
                {
                    cmd.Parameters.AddWithValue("@PickupId", pickupId);
                    conn.Open();
                    citizenId = cmd.ExecuteScalar().ToString();
                }

                // Create verification record
                string verificationId = GetNextVerificationId();

                string verificationQuery = @"INSERT INTO PickupVerifications 
                                            (VerificationId, PickupId, VerifiedKg, MaterialType, VerificationMethod, Notes, VerifiedAt)
                                            VALUES (@VerificationId, @PickupId, @VerifiedKg, @MaterialType, @VerificationMethod, @Notes, GETDATE())";

                using (SqlConnection conn = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand(verificationQuery, conn))
                {
                    cmd.Parameters.AddWithValue("@VerificationId", verificationId);
                    cmd.Parameters.AddWithValue("@PickupId", pickupId);
                    cmd.Parameters.AddWithValue("@VerifiedKg", verifiedKg);
                    cmd.Parameters.AddWithValue("@MaterialType", materialType);
                    cmd.Parameters.AddWithValue("@VerificationMethod", verificationMethod);
                    cmd.Parameters.AddWithValue("@Notes", string.IsNullOrEmpty(notes) ? DBNull.Value : (object)notes);

                    conn.Open();
                    cmd.ExecuteNonQuery();
                }

                // Add reward points to citizen
                decimal creditsEarned = verifiedKg * creditRate;
                string rewardId = GetNextRewardId();

                string rewardQuery = @"INSERT INTO RewardPoints 
                                      (RewardId, UserId, Amount, Type, Reference, CreatedAt)
                                      VALUES (@RewardId, @UserId, @Amount, 'Credit', @Reference, GETDATE())";

                using (SqlConnection conn = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand(rewardQuery, conn))
                {
                    cmd.Parameters.AddWithValue("@RewardId", rewardId);
                    cmd.Parameters.AddWithValue("@UserId", citizenId);
                    cmd.Parameters.AddWithValue("@Amount", creditsEarned);
                    cmd.Parameters.AddWithValue("@Reference", "Collection " + pickupId);

                    conn.Open();
                    cmd.ExecuteNonQuery();
                }

                // Update pickup status to Completed
                string updatePickupQuery = @"UPDATE PickupRequests 
                                            SET Status = 'Completed', 
                                                CompletedAt = GETDATE()
                                            WHERE PickupId = @PickupId";

                using (SqlConnection conn = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand(updatePickupQuery, conn))
                {
                    cmd.Parameters.AddWithValue("@PickupId", pickupId);
                    conn.Open();
                    cmd.ExecuteNonQuery();
                }

                ShowMessage("Success", "Collection verified successfully! Citizen earned $" + creditsEarned.ToString("N2") + " credits.", "success");
                BindCollections();

                // Close modal via JavaScript
                ScriptManager.RegisterStartupScript(this, this.GetType(), "CloseModal",
                    "$('#collectionModal').modal('hide');", true);
            }
            catch (Exception ex)
            {
                ShowMessage("Error", "Failed to verify collection: " + ex.Message, "error");
            }
        }

        protected void btnUpdateCollection_Click(object sender, EventArgs e)
        {
            try
            {
                string pickupId = hdnPickupId.Value;
                string collectorId = ddlCollector.SelectedValue;

                if (!string.IsNullOrEmpty(collectorId))
                {
                    // Update collector assignment
                    string updateQuery = @"UPDATE PickupRequests 
                                          SET CollectorId = @CollectorId, 
                                              Status = 'Assigned'
                                          WHERE PickupId = @PickupId";

                    using (SqlConnection conn = new SqlConnection(connectionString))
                    using (SqlCommand cmd = new SqlCommand(updateQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@PickupId", pickupId);
                        cmd.Parameters.AddWithValue("@CollectorId", collectorId);

                        conn.Open();
                        cmd.ExecuteNonQuery();
                    }

                    ShowMessage("Success", "Collector assigned successfully!", "success");
                }

                BindCollections();

                // Close modal via JavaScript
                ScriptManager.RegisterStartupScript(this, this.GetType(), "CloseModal",
                    "$('#collectionModal').modal('hide');", true);
            }
            catch (Exception ex)
            {
                ShowMessage("Error", "Failed to update collection: " + ex.Message, "error");
            }
        }

        protected void btnCancelPickup_Click(object sender, EventArgs e)
        {
            try
            {
                string pickupId = hdnPickupId.Value;

                string updateQuery = @"UPDATE PickupRequests 
                                      SET Status = 'Cancelled'
                                      WHERE PickupId = @PickupId";

                using (SqlConnection conn = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand(updateQuery, conn))
                {
                    cmd.Parameters.AddWithValue("@PickupId", pickupId);
                    conn.Open();
                    cmd.ExecuteNonQuery();
                }

                ShowMessage("Success", "Pickup cancelled successfully!", "success");
                BindCollections();

                // Close modal via JavaScript
                ScriptManager.RegisterStartupScript(this, this.GetType(), "CloseModal",
                    "$('#collectionModal').modal('hide');", true);
            }
            catch (Exception ex)
            {
                ShowMessage("Error", "Failed to cancel pickup: " + ex.Message, "error");
            }
        }

        // Helper Methods
        private string GetNextVerificationId()
        {
            string query = "SELECT ISNULL(MAX(CAST(SUBSTRING(VerificationId, 3, LEN(VerificationId)) AS INT)), 0) + 1 FROM PickupVerifications WHERE VerificationId LIKE 'PV%'";

            using (SqlConnection conn = new SqlConnection(connectionString))
            using (SqlCommand cmd = new SqlCommand(query, conn))
            {
                conn.Open();
                int nextId = (int)cmd.ExecuteScalar();
                return "PV" + nextId.ToString("D2");
            }
        }

        private string GetNextRewardId()
        {
            string query = "SELECT ISNULL(MAX(CAST(SUBSTRING(RewardId, 3, LEN(RewardId)) AS INT)), 0) + 1 FROM RewardPoints WHERE RewardId LIKE 'RP%'";

            using (SqlConnection conn = new SqlConnection(connectionString))
            using (SqlCommand cmd = new SqlCommand(query, conn))
            {
                conn.Open();
                int nextId = (int)cmd.ExecuteScalar();
                return "RP" + nextId.ToString("D2");
            }
        }

        // UI Helper Methods
        public string GetStatusClass(string status)
        {
            switch (status.ToLower())
            {
                case "requested":
                    return "status-pending";
                case "assigned":
                    return "status-assigned";
                case "inprogress":
                    return "status-inprogress";
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
                case "inprogress":
                    return "text-primary";
                case "collected":
                case "completed":
                    return "text-success";
                case "cancelled":
                    return "text-danger";
                default:
                    return "text-warning";
            }
        }

        public string GetStatusBadgeClass(string status)
        {
            switch (status.ToLower())
            {
                case "requested":
                    return "badge-warning";
                case "assigned":
                    return "badge-info";
                case "inprogress":
                    return "badge-primary";
                case "collected":
                case "completed":
                    return "badge-success";
                case "cancelled":
                    return "badge-danger";
                default:
                    return "badge-warning";
            }
        }

        public string GetCreditsColor(object credits)
        {
            if (credits == DBNull.Value || credits == null)
                return "text-muted";

            return "text-success";
        }

        public string GetCompletionTimeClass(object hours)
        {
            if (hours == DBNull.Value || hours == null)
                return "text-muted";

            int completionHours = Convert.ToInt32(hours);
            if (completionHours <= 24)
                return "text-success";
            else if (completionHours <= 72)
                return "text-warning";
            else
                return "text-danger";
        }

        public string GetCompletionTimeDisplay(object hours)
        {
            if (hours == DBNull.Value || hours == null)
                return "-";

            int completionHours = Convert.ToInt32(hours);
            if (completionHours < 24)
                return completionHours.ToString() + "h";
            else
                return (completionHours / 24).ToString() + "d";
        }

        public string GetLocationDisplay(object lat, object lng)
        {
            if (lat == DBNull.Value || lng == DBNull.Value || lat == null || lng == null)
                return "No coordinates";

            return "Has coordinates";
        }

        public string GetActionButton(string status, string pickupId, object collectorId)
        {
            switch (status.ToLower())
            {
                case "requested":
                    return string.Format(
                        "<button type='button' class='btn btn-warning' onclick='assignCollector(\"{0}\")'>" +
                        "<i class='fas fa-user-check me-1'></i>Assign</button>",
                        pickupId);
                case "assigned":
                case "inprogress":
                    return string.Format(
                        "<button type='button' class='btn btn-success' onclick='verifyCollection(\"{0}\")'>" +
                        "<i class='fas fa-check me-1'></i>Verify</button>",
                        pickupId);
                default:
                    return string.Empty;
            }
        }

        // Event Handlers
        protected void btnApplyFilters_Click(object sender, EventArgs e)
        {
            BindCollections();
        }

        protected void btnClearFilters_Click(object sender, EventArgs e)
        {
            txtSearch.Text = "";
            ddlStatus.SelectedValue = "all";
            ddlDateFilter.SelectedValue = "all";
            BindCollections();
        }

        protected void btnRefresh_Click(object sender, EventArgs e)
        {
            BindCollections();
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
                Response.AddHeader("content-disposition", "attachment;filename=Collections_Report_" + DateTime.Now.ToString("yyyyMMdd") + ".csv");
                Response.Charset = "";
                Response.ContentType = "application/text";

                DataTable dt = GetCollectionsDataForExport();
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

        private DataTable GetCollectionsDataForExport()
        {
            string query = @"SELECT 
                            pr.PickupId as 'Collection ID',
                            u.FullName as 'Citizen Name',
                            u.Phone as 'Citizen Phone',
                            c.FullName as 'Collector Name',
                            wt.Name as 'Waste Type',
                            wr.EstimatedKg as 'Estimated Weight (kg)',
                            pv.VerifiedKg as 'Verified Weight (kg)',
                            (pv.VerifiedKg * wt.CreditPerKg) as 'Credits Earned ($)',
                            pr.Status as 'Status',
                            FORMAT(wr.CreatedAt, 'yyyy-MM-dd HH:mm') as 'Request Date',
                            FORMAT(pr.ScheduledAt, 'yyyy-MM-dd HH:mm') as 'Scheduled Date',
                            FORMAT(pr.CompletedAt, 'yyyy-MM-dd HH:mm') as 'Completed Date',
                            wr.Address as 'Address',
                            pv.VerificationMethod as 'Verification Method',
                            DATEDIFF(HOUR, wr.CreatedAt, ISNULL(pr.CompletedAt, GETDATE())) as 'Completion Time (hours)'
                            FROM PickupRequests pr
                            JOIN WasteReports wr ON pr.ReportId = wr.ReportId
                            JOIN Users u ON wr.UserId = u.UserId
                            LEFT JOIN Users c ON pr.CollectorId = c.UserId
                            JOIN WasteTypes wt ON wr.WasteTypeId = wt.WasteTypeId
                            LEFT JOIN PickupVerifications pv ON pr.PickupId = pv.PickupId
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
        protected void rptCollectionsGrid_ItemDataBound(object sender, RepeaterItemEventArgs e)
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