using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace SoorGreen.Admin
{
    public partial class ReportWaste : System.Web.UI.Page
    {
        private string currentUserId;
        private string selectedWasteTypeId;
        private decimal selectedWasteRate;
        private string selectedWasteName;
        private decimal estimatedWeight = 0;
        private decimal estimatedReward = 0;

        string connectionString = System.Configuration.ConfigurationManager.ConnectionStrings["SoorGreenDBConnectionString"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // Check if user is logged in
                if (Session["UserId"] == null)
                {
                    Response.Redirect("~/Login.aspx");
                    return;
                }

                currentUserId = Session["UserId"].ToString();

                // Load user stats
                LoadUserStats();

                // Load waste types for step 1
                LoadWasteTypes();

                // Initialize step 1 as visible
                ShowStep(1);

                // Register startup scripts
                RegisterStartupScripts();
            }
            else
            {
                // Restore values from session
                if (Session["UserId"] != null)
                {
                    currentUserId = Session["UserId"].ToString();
                }

                if (Session["SelectedWasteTypeId"] != null)
                {
                    selectedWasteTypeId = Session["SelectedWasteTypeId"].ToString();
                }

                if (Session["SelectedWasteRate"] != null)
                {
                    selectedWasteRate = (decimal)Session["SelectedWasteRate"];
                }

                if (Session["SelectedWasteName"] != null)
                {
                    selectedWasteName = Session["SelectedWasteName"].ToString();
                }

                if (Session["EstimatedWeight"] != null)
                {
                    estimatedWeight = (decimal)Session["EstimatedWeight"];
                }

                if (Session["EstimatedReward"] != null)
                {
                    estimatedReward = (decimal)Session["EstimatedReward"];
                }
            }
        }

        private void LoadUserStats()
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    // Get user credits
                    string creditsQuery = @"SELECT ISNULL(SUM(Amount), 0) FROM RewardPoints WHERE UserId = @UserId";
                    using (SqlCommand cmd = new SqlCommand(creditsQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@UserId", currentUserId);
                        var credits = cmd.ExecuteScalar();
                        statCredits.InnerText = credits != DBNull.Value ? Convert.ToDecimal(credits).ToString("N2") : "0.00";
                    }

                    // Get user report count
                    string reportsQuery = @"SELECT COUNT(*) FROM WasteReports WHERE UserId = @UserId";
                    using (SqlCommand cmd = new SqlCommand(reportsQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@UserId", currentUserId);
                        var reportCount = cmd.ExecuteScalar();
                        statReports.InnerText = reportCount != DBNull.Value ? reportCount.ToString() : "0";
                    }

                    // Get total weight recycled
                    string weightQuery = @"SELECT ISNULL(SUM(wr.EstimatedKg), 0) 
                                          FROM WasteReports wr
                                          INNER JOIN PickupRequests pr ON wr.ReportId = pr.ReportId
                                          WHERE wr.UserId = @UserId AND pr.Status = 'Collected'";
                    using (SqlCommand cmd = new SqlCommand(weightQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@UserId", currentUserId);
                        var weight = cmd.ExecuteScalar();
                        statWeight.InnerText = weight != DBNull.Value ? Convert.ToDecimal(weight).ToString("N1") + " kg" : "0.0 kg";
                    }

                    // Get potential reward
                    string potentialQuery = @"SELECT TOP 1 CreditPerKg FROM WasteTypes ORDER BY CreditPerKg DESC";
                    using (SqlCommand cmd = new SqlCommand(potentialQuery, conn))
                    {
                        var maxRate = cmd.ExecuteScalar();
                        statPotential.InnerText = maxRate != DBNull.Value ? Convert.ToDecimal(maxRate).ToString("N0") + " XP/kg" : "0 XP";
                    }
                }
            }
            catch (Exception ex)
            {
                // Show error in console only
                System.Diagnostics.Debug.WriteLine("LoadUserStats Error: " + ex.Message);
            }
        }

        private void LoadWasteTypes()
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    // SIMPLE QUERY - NO WHERE CLAUSE
                    string query = @"SELECT WasteTypeId, Name, Description, Category, CreditPerKg 
                                     FROM WasteTypes 
                                     ORDER BY Name";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                        {
                            DataTable dt = new DataTable();
                            da.Fill(dt);

                            if (dt.Rows.Count == 0)
                            {
                                // Insert default waste types if table is empty
                                InsertDefaultWasteTypes(conn);
                                // Reload
                                da.Fill(dt);
                            }

                            rptWasteTypes.DataSource = dt;
                            rptWasteTypes.DataBind();
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                // Use fallback data
                LoadFallbackWasteTypes();
                System.Diagnostics.Debug.WriteLine("LoadWasteTypes Error: " + ex.Message);
            }
        }

        private void InsertDefaultWasteTypes(SqlConnection conn)
        {
            try
            {
                string insertQuery = @"
                    INSERT INTO WasteTypes (WasteTypeId, Name, Description, Category, CreditPerKg, ColorCode) VALUES
                    ('WT01', 'Plastic', 'Plastic bottles, containers, packaging materials', 'Recyclable', 10.50, '#3B82F6'),
                    ('WT02', 'Paper', 'Newspapers, cardboard, office paper, magazines', 'Recyclable', 8.75, '#10B981'),
                    ('WT03', 'Metal', 'Aluminum cans, steel containers, scrap metal', 'Recyclable', 15.25, '#6B7280'),
                    ('WT04', 'Glass', 'Glass bottles, jars, broken glass pieces', 'Recyclable', 7.50, '#8B5CF6'),
                    ('WT05', 'Electronics', 'E-waste, batteries, cables, small appliances', 'Hazardous', 25.00, '#F59E0B'),
                    ('WT06', 'Organic', 'Food waste, garden waste, compostable materials', 'Compostable', 5.00, '#22C55E'),
                    ('WT07', 'Textiles', 'Clothes, fabrics, shoes, blankets', 'Reusable', 12.00, '#EC4899'),
                    ('WT08', 'Hazardous', 'Chemicals, medical waste, paint, oil', 'Special', 30.00, '#EF4444')";

                using (SqlCommand cmd = new SqlCommand(insertQuery, conn))
                {
                    cmd.ExecuteNonQuery();
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("InsertDefaultWasteTypes Error: " + ex.Message);
            }
        }

        private void LoadFallbackWasteTypes()
        {
            DataTable dt = new DataTable();
            dt.Columns.Add("WasteTypeId", typeof(string));
            dt.Columns.Add("Name", typeof(string));
            dt.Columns.Add("Description", typeof(string));
            dt.Columns.Add("Category", typeof(string));
            dt.Columns.Add("CreditPerKg", typeof(decimal));

            dt.Rows.Add("WT01", "Plastic", "Plastic bottles, containers, packaging", "Recyclable", 10.50);
            dt.Rows.Add("WT02", "Paper", "Newspapers, cardboard, office paper", "Recyclable", 8.75);
            dt.Rows.Add("WT03", "Metal", "Aluminum cans, scrap metal", "Recyclable", 15.25);
            dt.Rows.Add("WT04", "Glass", "Bottles, jars, broken glass", "Recyclable", 7.50);
            dt.Rows.Add("WT05", "Electronics", "E-waste, batteries, cables", "Hazardous", 25.00);
            dt.Rows.Add("WT06", "Organic", "Food waste, garden waste", "Compostable", 5.00);
            dt.Rows.Add("WT07", "Textiles", "Clothes, fabrics, shoes", "Reusable", 12.00);
            dt.Rows.Add("WT08", "Hazardous", "Chemicals, medical waste", "Special", 30.00);

            rptWasteTypes.DataSource = dt;
            rptWasteTypes.DataBind();
        }

        protected void rptWasteTypes_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "SelectType")
            {
                string[] args = e.CommandArgument.ToString().Split('|');
                if (args.Length >= 3)
                {
                    selectedWasteTypeId = args[0];
                    selectedWasteRate = decimal.Parse(args[1]);
                    selectedWasteName = args[2];

                    // Store in session
                    Session["SelectedWasteTypeId"] = selectedWasteTypeId;
                    Session["SelectedWasteRate"] = selectedWasteRate;
                    Session["SelectedWasteName"] = selectedWasteName;

                    // Update preview labels
                    lblSelectedWaste.Text = selectedWasteName;
                    lblRatePreview.Text = selectedWasteRate.ToString("N2") + " XP/kg";

                    // Enable next button
                    btnNextStep1.Enabled = true;

                    // Show success message
                    ShowMessage("Waste type selected: " + selectedWasteName, "success");

                    // SAFE UI UPDATE - No JavaScript function dependency
                    string script = @"
                        setTimeout(function() {
                            // Clear previous selections
                            var wasteCards = document.querySelectorAll('.category-card-glass');
                            wasteCards.forEach(function(card) {
                                card.classList.remove('selected');
                            });
                            
                            // Find and select the clicked card
                            var selectedCards = document.querySelectorAll('.waste-type-select');
                            selectedCards.forEach(function(card) {
                                if (card.textContent.indexOf('" + selectedWasteName.Replace("'", "\\'") + @"') > -1) {
                                    var parent = card.closest('.category-card-glass');
                                    if (parent) {
                                        parent.classList.add('selected');
                                    }
                                }
                            });
                        }, 100);
                    ";

                    ScriptManager.RegisterStartupScript(this, GetType(), "SelectWasteType_" + Guid.NewGuid(), script, true);
                }
            }
        }

        protected void btnNextStep1_Click(object sender, EventArgs e)
        {
            if (!string.IsNullOrEmpty(selectedWasteTypeId))
            {
                ShowStep(2);
                UpdateWeightPreview();
            }
            else
            {
                ShowMessage("Please select a waste type first.", "error");
            }
        }

        protected void btnBackStep2_Click(object sender, EventArgs e)
        {
            ShowStep(1);
        }

        protected void btnNextStep2_Click(object sender, EventArgs e)
        {
            if (IsValidStep2())
            {
                ShowStep(3);
                UpdateWeightPreview();
            }
        }

        protected void btnBackStep3_Click(object sender, EventArgs e)
        {
            ShowStep(2);
            UpdateWeightPreview();
        }

        protected void btnNextStep3_Click(object sender, EventArgs e)
        {
            if (IsValidStep3())
            {
                UpdateReviewSection();
                ShowStep(4);
            }
        }

        protected void btnBackStep4_Click(object sender, EventArgs e)
        {
            ShowStep(3);
            UpdateWeightPreview();
        }

        protected void btnSubmitReport_Click(object sender, EventArgs e)
        {
            if (IsValidStep4())
            {
                try
                {
                    SubmitWasteReport();
                }
                catch (Exception ex)
                {
                    ShowMessage("Error submitting report: " + ex.Message, "error");
                }
            }
        }

        protected void btnSubmitAnother_Click(object sender, EventArgs e)
        {
            ResetForm();
            ShowStep(1);
        }

        protected void txtWeight_TextChanged(object sender, EventArgs e)
        {
            UpdateWeightPreview();
        }

        protected void btnWeight0_5_Click(object sender, EventArgs e)
        {
            txtWeight.Text = "0.5";
            UpdateWeightPreview();
        }

        protected void btnWeight1_Click(object sender, EventArgs e)
        {
            txtWeight.Text = "1";
            UpdateWeightPreview();
        }

        protected void btnWeight2_Click(object sender, EventArgs e)
        {
            txtWeight.Text = "2";
            UpdateWeightPreview();
        }

        protected void btnWeight5_Click(object sender, EventArgs e)
        {
            txtWeight.Text = "5";
            UpdateWeightPreview();
        }

        protected void btnWeight10_Click(object sender, EventArgs e)
        {
            txtWeight.Text = "10";
            UpdateWeightPreview();
        }

        protected void btnGetLocation_Click(object sender, EventArgs e)
        {
            string script = @"
                if (navigator.geolocation) {
                    navigator.geolocation.getCurrentPosition(
                        function(position) {
                            document.getElementById('" + txtLatitude.ClientID + @"').value = position.coords.latitude.toFixed(6);
                            document.getElementById('" + txtLongitude.ClientID + @"').value = position.coords.longitude.toFixed(6);
                            
                            var messagePanel = document.querySelector('.message-panel');
                            if (messagePanel) {
                                messagePanel.innerHTML = 
                                    '<div class=""message-alert success show"">' +
                                    '    <i class=""fas fa-check-circle""></i>' +
                                    '    <div>' +
                                    '        <strong>Location Captured!</strong>' +
                                    '        <p class=""mb-0"">Current location coordinates have been filled.</p>' +
                                    '    </div>' +
                                    '</div>';
                                messagePanel.style.display = 'block';
                                setTimeout(function() { messagePanel.style.display = 'none'; }, 3000);
                            }
                        },
                        function(error) {
                            alert('Unable to get location. Please enter manually.');
                        }
                    );
                } else {
                    alert('Geolocation is not supported by your browser.');
                }
            ";

            ScriptManager.RegisterStartupScript(this, GetType(), "GetLocation", script, true);
        }

        private void ShowStep(int stepNumber)
        {
            // Hide all steps
            pnlStep1.Visible = false;
            pnlStep2.Visible = false;
            pnlStep3.Visible = false;
            pnlStep4.Visible = false;
            pnlSuccess.Visible = false;

            // Show selected step
            if (stepNumber == 1)
            {
                pnlStep1.Visible = true;
            }
            else if (stepNumber == 2)
            {
                pnlStep2.Visible = true;
            }
            else if (stepNumber == 3)
            {
                pnlStep3.Visible = true;
            }
            else if (stepNumber == 4)
            {
                pnlStep4.Visible = true;
            }
            else if (stepNumber == 0) // Special case for success
            {
                pnlSuccess.Visible = true;
                stepNumber = 4; // For progress steps
            }

            // Update progress steps
            UpdateProgressSteps(stepNumber);
        }

        private void UpdateProgressSteps(int currentStep)
        {
            string script = @"
                for (var i = 1; i <= 4; i++) {
                    var stepElement = document.getElementById('step' + i);
                    var lineElement = document.getElementById('line' + i);
                    if (stepElement) stepElement.classList.remove('active');
                    if (lineElement) lineElement.classList.remove('active');
                }

                for (var i = 1; i <= " + currentStep + @"; i++) {
                    var stepElement = document.getElementById('step' + i);
                    var lineElement = document.getElementById('line' + i);
                    if (stepElement) stepElement.classList.add('active');
                    if (lineElement && i < " + currentStep + @") lineElement.classList.add('active');
                }
            ";

            ScriptManager.RegisterStartupScript(this, GetType(), "UpdateProgress_" + Guid.NewGuid().ToString("N"), script, true);
        }

        private void UpdateWeightPreview()
        {
            decimal weight = 0;
            if (!string.IsNullOrEmpty(txtWeight.Text))
            {
                decimal.TryParse(txtWeight.Text, out weight);
            }

            estimatedWeight = weight;
            estimatedReward = weight * selectedWasteRate;

            // Update labels
            lblWeightPreview.Text = weight.ToString("N1");
            lblWeightDisplay.Text = weight.ToString("N1") + " kg";
            lblEstimatedReward.Text = estimatedReward.ToString("N0");

            // Store in session
            Session["EstimatedWeight"] = estimatedWeight;
            Session["EstimatedReward"] = estimatedReward;
        }

        private void UpdateReviewSection()
        {
            // Update review labels
            lblReviewWasteType.Text = selectedWasteName;
            lblReviewWeight.Text = estimatedWeight.ToString("N1") + " kg";
            lblReviewRate.Text = selectedWasteRate.ToString("N2") + " XP/kg";
            lblReviewContact.Text = !string.IsNullOrEmpty(txtContactPerson.Text) ? txtContactPerson.Text : "-";
            lblReviewAddress.Text = !string.IsNullOrEmpty(txtAddress.Text) ? txtAddress.Text : "Not provided";
            lblReviewDescription.Text = !string.IsNullOrEmpty(txtDescription.Text) ? txtDescription.Text : "No description provided";

            // Update final reward section
            lblFinalWeight.Text = estimatedWeight.ToString("N1") + " kg";
            lblFinalRate.Text = selectedWasteRate.ToString("N2") + " XP/kg";
            lblFinalReward.Text = estimatedReward.ToString("N0");
            lblFinalTotal.Text = estimatedReward.ToString("N0") + " XP";
        }

        private bool IsValidStep2()
        {
            decimal weight;
            if (string.IsNullOrEmpty(txtWeight.Text) || !decimal.TryParse(txtWeight.Text, out weight) || weight <= 0)
            {
                ShowMessage("Please enter a valid weight greater than 0.", "error");
                return false;
            }

            if (weight > 1000)
            {
                ShowMessage("Weight cannot exceed 1000 kg. Please contact support for large quantities.", "error");
                return false;
            }

            return true;
        }

        private bool IsValidStep3()
        {
            if (string.IsNullOrEmpty(txtAddress.Text))
            {
                ShowMessage("Please enter collection address.", "error");
                return false;
            }

            return true;
        }

        private bool IsValidStep4()
        {
            if (!chkConfirmDetails.Checked)
            {
                ShowMessage("Please confirm that all details are correct.", "error");
                return false;
            }

            if (!chkAgreeTerms.Checked)
            {
                ShowMessage("Please agree to the terms and conditions.", "error");
                return false;
            }

            return true;
        }

        private void SubmitWasteReport()
        {
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.Open();

                using (SqlTransaction transaction = conn.BeginTransaction())
                {
                    try
                    {
                        // Generate Report ID
                        string reportId = GenerateNextId(conn, transaction, "WasteReports", "ReportId", "WR");

                        // Insert waste report
                        string insertReportQuery = @"
                            INSERT INTO WasteReports (ReportId, UserId, WasteTypeId, EstimatedKg, Address, Lat, Lng, CreatedAt)
                            VALUES (@ReportId, @UserId, @WasteTypeId, @EstimatedKg, @Address, @Lat, @Lng, @CreatedAt)";

                        using (SqlCommand cmd = new SqlCommand(insertReportQuery, conn, transaction))
                        {
                            cmd.Parameters.AddWithValue("@ReportId", reportId);
                            cmd.Parameters.AddWithValue("@UserId", currentUserId);
                            cmd.Parameters.AddWithValue("@WasteTypeId", selectedWasteTypeId);
                            cmd.Parameters.AddWithValue("@EstimatedKg", estimatedWeight);
                            cmd.Parameters.AddWithValue("@Address", txtAddress.Text);
                            cmd.Parameters.AddWithValue("@Lat", !string.IsNullOrEmpty(txtLatitude.Text) ? txtLatitude.Text : (object)DBNull.Value);
                            cmd.Parameters.AddWithValue("@Lng", !string.IsNullOrEmpty(txtLongitude.Text) ? txtLongitude.Text : (object)DBNull.Value);
                            cmd.Parameters.AddWithValue("@CreatedAt", DateTime.Now);

                            cmd.ExecuteNonQuery();
                        }

                        // Generate Pickup ID
                        string pickupId = GenerateNextId(conn, transaction, "PickupRequests", "PickupId", "PK");

                        // Insert pickup request
                        string insertPickupQuery = @"
                            INSERT INTO PickupRequests (PickupId, ReportId, Status, ScheduledAt)
                            VALUES (@PickupId, @ReportId, 'Requested', DATEADD(HOUR, 48, GETDATE()))";

                        using (SqlCommand cmd = new SqlCommand(insertPickupQuery, conn, transaction))
                        {
                            cmd.Parameters.AddWithValue("@PickupId", pickupId);
                            cmd.Parameters.AddWithValue("@ReportId", reportId);
                            cmd.ExecuteNonQuery();
                        }

                        // Insert user activity
                        string insertActivityQuery = @"
                            INSERT INTO UserActivities (UserId, ActivityType, Description, Points, Timestamp)
                            VALUES (@UserId, 'WasteReport', @Description, 5, @Timestamp)";

                        using (SqlCommand cmd = new SqlCommand(insertActivityQuery, conn, transaction))
                        {
                            cmd.Parameters.AddWithValue("@UserId", currentUserId);
                            cmd.Parameters.AddWithValue("@Description", "Reported " + selectedWasteName + " for collection (" + estimatedWeight.ToString("N1") + " kg)");
                            cmd.Parameters.AddWithValue("@Timestamp", DateTime.Now);
                            cmd.ExecuteNonQuery();
                        }

                        // Commit transaction
                        transaction.Commit();

                        // Update success display
                        lblSuccessReportId.Text = reportId;
                        lblSuccessPickupId.Text = pickupId;
                        lblSuccessReward.Text = estimatedReward.ToString("N0") + " XP";
                        lblSuccessTime.Text = DateTime.Now.ToString("yyyy-MM-dd HH:mm");

                        // Update user stats
                        LoadUserStats();

                        // Show success step
                        ShowStep(0); // 0 means success

                        // Show success message
                        ShowMessage("Waste report submitted successfully! A collector will contact you within 48 hours.", "success");

                        // Trigger success animation
                        string successScript = "showDatabaseConfirmation();";
                        ScriptManager.RegisterStartupScript(this, GetType(), "ShowSuccess", successScript, true);
                    }
                    catch (Exception ex)
                    {
                        transaction.Rollback();
                        ShowMessage("Failed to submit report: " + ex.Message, "error");
                    }
                }
            }
        }

        private string GenerateNextId(SqlConnection conn, SqlTransaction transaction, string tableName, string idColumn, string prefix)
        {
            string query = string.Format(@"
                SELECT ISNULL(MAX(CAST(SUBSTRING({0}, 3, LEN({0})) AS INT)), 0) + 1 
                FROM {1} 
                WHERE {0} LIKE '{2}%'", idColumn, tableName, prefix);

            using (SqlCommand cmd = new SqlCommand(query, conn, transaction))
            {
                int nextNumber = Convert.ToInt32(cmd.ExecuteScalar());
                return prefix + nextNumber.ToString("D2");
            }
        }

        private void ResetForm()
        {
            // Clear all fields
            txtWeight.Text = "";
            txtDescription.Text = "";
            txtAddress.Text = "";
            txtLandmark.Text = "";
            txtContactPerson.Text = "";
            txtInstructions.Text = "";
            txtLatitude.Text = "";
            txtLongitude.Text = "";

            // Reset checkboxes
            chkConfirmDetails.Checked = false;
            chkAgreeTerms.Checked = false;
            chkSchedulePickup.Checked = true;

            // Clear session data
            Session.Remove("SelectedWasteTypeId");
            Session.Remove("SelectedWasteRate");
            Session.Remove("SelectedWasteName");
            Session.Remove("EstimatedWeight");
            Session.Remove("EstimatedReward");

            // Reload waste types
            LoadWasteTypes();

            // Disable next button
            btnNextStep1.Enabled = false;
        }

        private void ShowMessage(string message, string type)
        {
            string icon = "exclamation-circle";
            switch (type.ToLower())
            {
                case "success":
                    icon = "check-circle";
                    break;
                case "warning":
                    icon = "exclamation-triangle";
                    break;
                case "error":
                    icon = "exclamation-circle";
                    break;
            }

            string upperType = type.ToUpper();
            string escapedMessage = message.Replace("'", "\\'").Replace("\"", "\\\"");

            string script = string.Format(@"
                var messagePanel = document.querySelector('.message-panel');
                if (messagePanel) {{
                    messagePanel.innerHTML = 
                        '<div class=""message-alert {0} show"">' +
                        '    <i class=""fas fa-{1}""></i>' +
                        '    <div>' +
                        '        <strong>{2}</strong>' +
                        '        <p class=""mb-0"">{3}</p>' +
                        '    </div>' +
                        '</div>';
                    messagePanel.style.display = 'block';
                    setTimeout(function() {{
                        messagePanel.style.display = 'none';
                    }}, 5000);
                }}
            ", type, icon, upperType, escapedMessage);

            ScriptManager.RegisterStartupScript(this, GetType(), "ShowMessage_" + Guid.NewGuid().ToString("N"), script, true);
        }

        private void RegisterStartupScripts()
        {
            string initScript = @"
                // Update progress steps
                function updateProgressSteps(currentStep) {
                    for (var i = 1; i <= 4; i++) {
                        var stepElement = document.getElementById('step' + i);
                        var lineElement = document.getElementById('line' + i);
                        if (stepElement) stepElement.classList.remove('active');
                        if (lineElement) lineElement.classList.remove('active');
                    }

                    for (var i = 1; i <= currentStep; i++) {
                        var stepElement = document.getElementById('step' + i);
                        var lineElement = document.getElementById('line' + i);
                        if (stepElement) stepElement.classList.add('active');
                        if (lineElement && i < currentStep) lineElement.classList.add('active');
                    }
                }
                
                // Show database confirmation
                function showDatabaseConfirmation() {
                    var successCard = document.querySelector('.success-card-glass');
                    if (successCard) {
                        successCard.style.animation = 'none';
                        setTimeout(function() {
                            successCard.style.animation = 'pulse 2s infinite';
                        }, 10);
                    }
                }
                
                // Make functions globally available
                window.updateProgressSteps = updateProgressSteps;
                window.showDatabaseConfirmation = showDatabaseConfirmation;
            ";

            ScriptManager.RegisterClientScriptBlock(this, GetType(), "InitializeScripts", initScript, true);
        }

        public string GetWasteTypeIcon(string wasteTypeName)
        {
            switch (wasteTypeName.ToLower())
            {
                case "plastic":
                    return "fa-bottle-water";
                case "paper":
                    return "fa-file-alt";
                case "metal":
                    return "fa-cogs";
                case "glass":
                    return "fa-wine-glass";
                case "organic":
                    return "fa-leaf";
                case "electronics":
                    return "fa-laptop";
                case "textiles":
                    return "fa-tshirt";
                case "hazardous":
                    return "fa-radiation";
                default:
                    return "fa-trash";
            }
        }

        protected void btnThemeToggle_Click(object sender, EventArgs e)
        {
            string currentTheme = "light";
            if (Request.Cookies["theme"] != null)
            {
                currentTheme = Request.Cookies["theme"].Value;
            }

            string newTheme = currentTheme == "light" ? "dark" : "light";

            Response.Cookies["theme"].Value = newTheme;
            Response.Cookies["theme"].Expires = DateTime.Now.AddDays(30);

            Response.Redirect(Request.RawUrl);
        }
    }
}