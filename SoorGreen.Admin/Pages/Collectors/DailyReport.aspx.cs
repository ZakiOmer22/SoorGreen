using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace SoorGreen.Collectors
{
    public partial class DailyReport : System.Web.UI.Page
    {
        protected string CurrentUserId = "";
        protected string ReportDate = "";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] == null || Session["UserRole"] == null)
            {
                Response.Redirect("~/Login.aspx?returnUrl=" + Server.UrlEncode(Request.Url.AbsolutePath));
                return;
            }

            CurrentUserId = Session["UserID"].ToString();
            ReportDate = DateTime.Now.ToString("yyyy-MM-dd");

            if (!IsPostBack)
            {
                LoadAutoFilledData();
                SetDefaultValues();
            }
        }

        private void LoadAutoFilledData()
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(GetConnectionString()))
                {
                    conn.Open();

                    string pickupQuery = @"
                        SELECT 
                            COUNT(*) as TotalPickups,
                            ISNULL(SUM(pv.VerifiedKg), 0) as TotalWeight,
                            ISNULL(SUM(rp.Amount), 0) as TotalCredits
                        FROM PickupRequests pr
                        JOIN PickupVerifications pv ON pr.PickupId = pv.PickupId
                        LEFT JOIN RewardPoints rp ON pr.PickupId = rp.Reference
                        WHERE pr.CollectorId = @CollectorId
                        AND pr.Status = 'Collected'
                        AND CONVERT(DATE, pr.CompletedAt) = CONVERT(DATE, @ReportDate)";

                    using (SqlCommand cmd = new SqlCommand(pickupQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@CollectorId", CurrentUserId);
                        cmd.Parameters.AddWithValue("@ReportDate", DateTime.Parse(ReportDate));

                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                lblTotalPickups.Text = reader["TotalPickups"].ToString();
                                lblTotalWeight.Text = Convert.ToDecimal(reader["TotalWeight"]).ToString("F1");
                                lblTotalCredits.Text = Convert.ToDecimal(reader["TotalCredits"]).ToString("F2");
                            }
                            else
                            {
                                lblTotalPickups.Text = "0";
                                lblTotalWeight.Text = "0.0";
                                lblTotalCredits.Text = "0.00";
                            }
                        }
                    }

                    string wasteQuery = @"
                        SELECT 
                            wt.Name as WasteType,
                            COUNT(pr.PickupId) as PickupCount,
                            ISNULL(SUM(pv.VerifiedKg), 0) as Weight,
                            CASE 
                                WHEN (SELECT SUM(pv2.VerifiedKg) 
                                      FROM PickupRequests pr2
                                      JOIN PickupVerifications pv2 ON pr2.PickupId = pv2.PickupId
                                      WHERE pr2.CollectorId = @CollectorId
                                      AND pr2.Status = 'Collected'
                                      AND CONVERT(DATE, pr2.CompletedAt) = CONVERT(DATE, @ReportDate)) > 0
                                THEN ROUND(ISNULL(SUM(pv.VerifiedKg), 0) * 100.0 / 
                                      (SELECT SUM(pv2.VerifiedKg) 
                                       FROM PickupRequests pr2
                                       JOIN PickupVerifications pv2 ON pr2.PickupId = pv2.PickupId
                                       WHERE pr2.CollectorId = @CollectorId
                                       AND pr2.Status = 'Collected'
                                       AND CONVERT(DATE, pr2.CompletedAt) = CONVERT(DATE, @ReportDate)), 1)
                                ELSE 0
                            END as Percentage
                        FROM PickupRequests pr
                        JOIN PickupVerifications pv ON pr.PickupId = pv.PickupId
                        JOIN WasteReports wr ON pr.ReportId = wr.ReportId
                        JOIN WasteTypes wt ON wr.WasteTypeId = wt.WasteTypeId
                        WHERE pr.CollectorId = @CollectorId
                        AND pr.Status = 'Collected'
                        AND CONVERT(DATE, pr.CompletedAt) = CONVERT(DATE, @ReportDate)
                        GROUP BY wt.Name, wt.WasteTypeId
                        ORDER BY Weight DESC";

                    using (SqlCommand cmd = new SqlCommand(wasteQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@CollectorId", CurrentUserId);
                        cmd.Parameters.AddWithValue("@ReportDate", DateTime.Parse(ReportDate));

                        DataTable dt = new DataTable();
                        using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                        {
                            da.Fill(dt);
                        }

                        if (dt.Rows.Count > 0)
                        {
                            rptWasteBreakdown.DataSource = dt;
                            rptWasteBreakdown.DataBind();
                            pnlNoData.Visible = false;
                        }
                        else
                        {
                            rptWasteBreakdown.DataSource = null;
                            rptWasteBreakdown.DataBind();
                            pnlNoData.Visible = true;
                        }
                    }

                    string routeQuery = @"
                        SELECT 
                            ISNULL(TotalDistance, 0) as Distance,
                            ISNULL(TotalWeight, 0) as Weight,
                            CASE 
                                WHEN StartTime IS NOT NULL AND EndTime IS NOT NULL 
                                THEN DATEDIFF(MINUTE, StartTime, EndTime) / 60.0 
                                ELSE 0 
                            END as Hours
                        FROM CollectorRoutes
                        WHERE CollectorId = @CollectorId
                        AND CONVERT(DATE, RouteDate) = CONVERT(DATE, @ReportDate)
                        AND Status = 'Completed'";

                    using (SqlCommand cmd = new SqlCommand(routeQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@CollectorId", CurrentUserId);
                        cmd.Parameters.AddWithValue("@ReportDate", DateTime.Parse(ReportDate));

                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                lblTotalDistance.Text = Convert.ToDecimal(reader["Distance"]).ToString("F1");
                                lblTotalHours.Text = Convert.ToDecimal(reader["Hours"]).ToString("F1");

                                decimal distance = Convert.ToDecimal(reader["Distance"]);
                                if (distance > 0)
                                {
                                    decimal fuelUsed = distance / 8;
                                    lblFuelUsed.Text = fuelUsed.ToString("F1");
                                }
                                else
                                {
                                    lblFuelUsed.Text = "0";
                                }
                            }
                            else
                            {
                                lblTotalDistance.Text = "0";
                                lblTotalHours.Text = "0";
                                lblFuelUsed.Text = "0";
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                ShowErrorMessage("Error loading data: " + ex.Message);
                pnlNoData.Visible = true;
            }
        }

        private void SetDefaultValues()
        {
            txtOdometerStart.Text = "1000.0";
            txtOdometerEnd.Text = "1050.0";
        }

        public string GetWasteTypeIcon(string wasteType)
        {
            switch (wasteType.ToLower())
            {
                case "plastic": return "fas fa-bottle-water";
                case "paper": return "fas fa-newspaper";
                case "glass": return "fas fa-wine-glass";
                case "metal": return "fas fa-cog";
                case "organic": return "fas fa-leaf";
                case "electronic": return "fas fa-laptop";
                default: return "fas fa-trash";
            }
        }

        public string GetWasteTypeColor(string wasteType)
        {
            switch (wasteType.ToLower())
            {
                case "plastic": return "linear-gradient(135deg, #3b82f6, #1d4ed8)";
                case "paper": return "linear-gradient(135deg, #f59e0b, #d97706)";
                case "glass": return "linear-gradient(135deg, #10b981, #059669)";
                case "metal": return "linear-gradient(135deg, #6b7280, #4b5563)";
                case "organic": return "linear-gradient(135deg, #8b5cf6, #7c3aed)";
                case "electronic": return "linear-gradient(135deg, #ef4444, #dc2626)";
                default: return "linear-gradient(135deg, #9ca3af, #6b7280)";
            }
        }

        protected void btnRefreshData_Click(object sender, EventArgs e)
        {
            LoadAutoFilledData();
            ShowSuccessMessage("Data refreshed successfully!");
        }

        protected void btnSubmitReport_Click(object sender, EventArgs e)
        {
            try
            {
                if (!ValidateForm())
                {
                    ShowErrorMessage("Please fill in all required fields.");
                    return;
                }

                using (SqlConnection conn = new SqlConnection(GetConnectionString()))
                {
                    conn.Open();

                    string checkQuery = @"
                        SELECT COUNT(*) FROM CollectorRoutes 
                        WHERE CollectorId = @CollectorId 
                        AND CONVERT(DATE, RouteDate) = CONVERT(DATE, @ReportDate)";

                    using (SqlCommand cmd = new SqlCommand(checkQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@CollectorId", CurrentUserId);
                        cmd.Parameters.AddWithValue("@ReportDate", DateTime.Parse(ReportDate));

                        int existingCount = Convert.ToInt32(cmd.ExecuteScalar());

                        if (existingCount > 0)
                        {
                            UpdateCollectorRoute(conn);
                        }
                        else
                        {
                            InsertCollectorRoute(conn);
                        }
                    }

                    ShowSuccessMessage("Daily report submitted successfully!");
                    lblStatusMessage.Text = "Your daily report has been submitted and is awaiting review.";
                    pnlSubmissionStatus.Visible = true;

                    ClearForm();
                }
            }
            catch (Exception ex)
            {
                ShowErrorMessage("Error submitting report: " + ex.Message);
            }
        }

        protected void btnSaveDraft_Click(object sender, EventArgs e)
        {
            try
            {
                SaveRouteAsDraft();
                ShowInfoMessage("Report saved as draft. You can submit it later.");
                lblStatusMessage.Text = "Report saved as draft.";
                pnlSubmissionStatus.Visible = true;
            }
            catch (Exception ex)
            {
                ShowErrorMessage("Error saving draft: " + ex.Message);
            }
        }

        protected void btnCancel_Click(object sender, EventArgs e)
        {
            Response.Redirect("CollectorDashboard.aspx");
        }

        private void InsertCollectorRoute(SqlConnection conn)
        {
            string query = @"
                INSERT INTO CollectorRoutes (
                    RouteId, CollectorId, RouteDate, TotalDistance, TotalWeight,
                    StartTime, EndTime, Notes, Status, CreatedAt
                ) VALUES (
                    @RouteId, @CollectorId, @RouteDate, @TotalDistance, @TotalWeight,
                    @StartTime, @EndTime, @Notes, 'Completed', GETDATE()
                )";

            using (SqlCommand cmd = new SqlCommand(query, conn))
            {
                AddRouteParameters(cmd);
                cmd.ExecuteNonQuery();
            }
        }

        private void UpdateCollectorRoute(SqlConnection conn)
        {
            string query = @"
                UPDATE CollectorRoutes 
                SET TotalDistance = @TotalDistance,
                    TotalWeight = @TotalWeight,
                    StartTime = @StartTime, 
                    EndTime = @EndTime,
                    Notes = @Notes,
                    Status = 'Completed',
                    LastUpdated = GETDATE()
                WHERE CollectorId = @CollectorId 
                AND CONVERT(DATE, RouteDate) = CONVERT(DATE, @ReportDate)";

            using (SqlCommand cmd = new SqlCommand(query, conn))
            {
                AddRouteParameters(cmd);
                cmd.ExecuteNonQuery();
            }
        }

        private void SaveRouteAsDraft()
        {
            using (SqlConnection conn = new SqlConnection(GetConnectionString()))
            {
                conn.Open();

                string query = @"
                    IF EXISTS (SELECT 1 FROM CollectorRoutes 
                              WHERE CollectorId = @CollectorId 
                              AND CONVERT(DATE, RouteDate) = CONVERT(DATE, @ReportDate))
                    BEGIN
                        UPDATE CollectorRoutes 
                        SET Status = 'Draft',
                            LastUpdated = GETDATE()
                        WHERE CollectorId = @CollectorId 
                        AND CONVERT(DATE, RouteDate) = CONVERT(DATE, @ReportDate)
                    END
                    ELSE
                    BEGIN
                        INSERT INTO CollectorRoutes (
                            RouteId, CollectorId, RouteDate, Status, CreatedAt
                        ) VALUES (
                            @RouteId, @CollectorId, @ReportDate, 'Draft', GETDATE()
                        )
                    END";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@CollectorId", CurrentUserId);
                    cmd.Parameters.AddWithValue("@ReportDate", DateTime.Parse(ReportDate));
                    cmd.Parameters.AddWithValue("@RouteId", GenerateRouteId());

                    cmd.ExecuteNonQuery();
                }
            }
        }

        private void AddRouteParameters(SqlCommand cmd)
        {
            cmd.Parameters.AddWithValue("@RouteId", GenerateRouteId());
            cmd.Parameters.AddWithValue("@CollectorId", CurrentUserId);
            cmd.Parameters.AddWithValue("@RouteDate", DateTime.Parse(ReportDate));
            cmd.Parameters.AddWithValue("@TotalDistance", ParseDecimal(lblTotalDistance.Text));
            cmd.Parameters.AddWithValue("@TotalWeight", ParseDecimal(lblTotalWeight.Text));

            // Combine date and time for StartTime and EndTime
            DateTime today = DateTime.Today;
            DateTime startTime = today;
            DateTime endTime = today;

            // FIXED LINE 391: Declare TimeSpan variables BEFORE using out parameter
            TimeSpan startSpan;
            if (TimeSpan.TryParse(txtStartTime.Text, out startSpan))
            {
                startTime = today.Add(startSpan);
            }

            TimeSpan endSpan;
            if (TimeSpan.TryParse(txtEndTime.Text, out endSpan))
            {
                endTime = today.Add(endSpan);
            }

            cmd.Parameters.AddWithValue("@StartTime", startTime);
            cmd.Parameters.AddWithValue("@EndTime", endTime);

            // Build notes with all additional info
            string notes = "Odometer Start: " + txtOdometerStart.Text + " km\n";
            notes += "Odometer End: " + txtOdometerEnd.Text + " km\n";
            notes += "Fuel Purchased: " + txtFuelPurchased.Text + " L\n";
            notes += "Fuel Cost: $" + txtFuelCost.Text + "\n";
            notes += "Signature: " + (string.IsNullOrEmpty(hfSignature.Value) ? "Not provided" : "Provided") + "\n";
            notes += "Additional Notes: " + txtNotes.Text;

            cmd.Parameters.AddWithValue("@Notes", notes);
        }

        private string GenerateRouteId()
        {
            string datePart = DateTime.Now.ToString("yyMMdd");
            string timePart = DateTime.Now.ToString("HHmmss");
            return "RT" + datePart + timePart;
        }

        private bool ValidateForm()
        {
            if (string.IsNullOrEmpty(txtStartTime.Text))
            {
                ShowErrorMessage("Please enter start time.");
                return false;
            }

            if (string.IsNullOrEmpty(txtEndTime.Text))
            {
                ShowErrorMessage("Please enter end time.");
                return false;
            }

            TimeSpan startTime;
            TimeSpan endTime;

            if (!TimeSpan.TryParse(txtStartTime.Text, out startTime))
            {
                ShowErrorMessage("Invalid start time format. Use HH:mm format.");
                return false;
            }

            if (!TimeSpan.TryParse(txtEndTime.Text, out endTime))
            {
                ShowErrorMessage("Invalid end time format. Use HH:mm format.");
                return false;
            }

            if (endTime <= startTime)
            {
                ShowErrorMessage("End time must be after start time.");
                return false;
            }

            if (string.IsNullOrEmpty(txtOdometerStart.Text))
            {
                ShowErrorMessage("Please enter odometer start reading.");
                return false;
            }

            if (string.IsNullOrEmpty(txtOdometerEnd.Text))
            {
                ShowErrorMessage("Please enter odometer end reading.");
                return false;
            }

            decimal startOdo = ParseDecimal(txtOdometerStart.Text);
            decimal endOdo = ParseDecimal(txtOdometerEnd.Text);

            if (endOdo <= startOdo)
            {
                ShowErrorMessage("Odometer end reading must be greater than start reading.");
                return false;
            }

            if (!string.IsNullOrEmpty(txtFuelPurchased.Text))
            {
                decimal fuel;
                if (!decimal.TryParse(txtFuelPurchased.Text, out fuel) || fuel < 0)
                {
                    ShowErrorMessage("Invalid fuel purchased amount.");
                    return false;
                }
            }

            if (!string.IsNullOrEmpty(txtFuelCost.Text))
            {
                decimal cost;
                if (!decimal.TryParse(txtFuelCost.Text, out cost) || cost < 0)
                {
                    ShowErrorMessage("Invalid fuel cost amount.");
                    return false;
                }
            }

            return true;
        }

        private void ClearForm()
        {
            txtStartTime.Text = "";
            txtEndTime.Text = "";
            txtOdometerStart.Text = "";
            txtOdometerEnd.Text = "";
            txtFuelPurchased.Text = "";
            txtFuelCost.Text = "";
            txtNotes.Text = "";
            hfSignature.Value = "";
        }

        private decimal ParseDecimal(string value)
        {
            decimal result;
            if (decimal.TryParse(value, out result))
                return result;
            return 0;
        }

        private int ParseInt(string value)
        {
            int result;
            if (int.TryParse(value, out result))
                return result;
            return 0;
        }

        private string GetConnectionString()
        {
            return ConfigurationManager.ConnectionStrings["SoorGreenDBConnectionString"].ConnectionString;
        }

        private void ShowSuccessMessage(string message)
        {
            string script = "showToast('" + message.Replace("'", "\\'") + "', 'success');";
            ScriptManager.RegisterStartupScript(this, GetType(), "successToast", script, true);
        }

        private void ShowErrorMessage(string message)
        {
            string script = "showToast('" + message.Replace("'", "\\'") + "', 'danger');";
            ScriptManager.RegisterStartupScript(this, GetType(), "errorToast", script, true);
        }

        private void ShowInfoMessage(string message)
        {
            string script = "showToast('" + message.Replace("'", "\\'") + "', 'info');";
            ScriptManager.RegisterStartupScript(this, GetType(), "infoToast", script, true);
        }
    }
}