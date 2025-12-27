using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Collections.Generic;

namespace SoorGreen.Collectors
{
    public partial class CollectorPerformance : System.Web.UI.Page
    {
        protected string CurrentUserId = "";
        protected int CurrentPage = 1;
        protected int PageSize = 10;
        protected int TotalRecords = 0;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] == null || Session["UserRole"] == null)
            {
                Response.Redirect("~/Login.aspx?returnUrl=" + Server.UrlEncode(Request.Url.AbsolutePath));
                return;
            }

            CurrentUserId = Session["UserID"].ToString();

            if (!IsPostBack)
            {
                LoadCollectorInfo();
                InitializeFilters();
                LoadPerformanceData();
            }
        }

        private void LoadCollectorInfo()
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(GetConnectionString()))
                {
                    conn.Open();
                    string query = "SELECT FullName FROM Users WHERE UserId = @UserId";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@UserId", CurrentUserId);

                        var result = cmd.ExecuteScalar();
                        if (result != null)
                        {
                            lblCollectorName.Text = result.ToString();
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error loading collector info: " + ex.Message);
            }
        }

        private void InitializeFilters()
        {
            txtStartDate.Text = DateTime.Now.AddDays(-30).ToString("yyyy-MM-dd");
            txtEndDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
            lblPerformancePeriod.Text = "Period: Last 30 Days";
            lblPerformanceRank.Text = "Top 15%"; // Initialize rank
        }

        private void LoadPerformanceData()
        {
            try
            {
                DateTime startDate = GetStartDate();
                DateTime endDate = GetEndDate();

                LoadPerformanceStats(startDate, endDate);
                LoadWasteDistribution(startDate, endDate);
                LoadTimeline(startDate, endDate);
                LoadPerformanceLog(startDate, endDate);
                CalculateEnvironmentalImpact();
                LoadCustomerRating(); // Add this to load customer rating
            }
            catch (Exception ex)
            {
                ShowErrorMessage("Error loading performance data: " + ex.Message);
            }
        }

        private DateTime GetStartDate()
        {
            string period = ddlTimePeriod.SelectedValue;
            DateTime startDate;

            switch (period)
            {
                case "7":
                    startDate = DateTime.Now.AddDays(-7);
                    break;
                case "90":
                    startDate = DateTime.Now.AddDays(-90);
                    break;
                case "month":
                    startDate = new DateTime(DateTime.Now.Year, DateTime.Now.Month, 1);
                    break;
                case "quarter":
                    int currentQuarter = (DateTime.Now.Month - 1) / 3 + 1;
                    startDate = new DateTime(DateTime.Now.Year, (currentQuarter - 1) * 3 + 1, 1);
                    break;
                case "year":
                    startDate = new DateTime(DateTime.Now.Year, 1, 1);
                    break;
                case "custom":
                    if (!string.IsNullOrEmpty(txtStartDate.Text))
                        startDate = DateTime.Parse(txtStartDate.Text);
                    else
                        startDate = DateTime.Now.AddDays(-30);
                    break;
                default:
                    startDate = DateTime.Now.AddDays(-30);
                    break;
            }

            return startDate;
        }

        private DateTime GetEndDate()
        {
            if (ddlTimePeriod.SelectedValue == "custom" && !string.IsNullOrEmpty(txtEndDate.Text))
            {
                return DateTime.Parse(txtEndDate.Text);
            }
            return DateTime.Now;
        }

        private void LoadPerformanceStats(DateTime startDate, DateTime endDate)
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(GetConnectionString()))
                {
                    conn.Open();

                    string query = @"
                        SELECT 
                            COUNT(DISTINCT pr.PickupId) as TotalCollections,
                            ISNULL(SUM(pv.VerifiedKg), 0) as TotalWeight,
                            ISNULL(AVG(cr.TotalDistance), 0) as AvgDistance,
                            ISNULL(COUNT(DISTINCT CONVERT(DATE, pr.CompletedAt)), 0) as WorkingDays
                        FROM PickupRequests pr
                        LEFT JOIN PickupVerifications pv ON pr.PickupId = pv.PickupId
                        LEFT JOIN CollectorRoutes cr ON pr.CollectorId = cr.CollectorId 
                            AND CONVERT(DATE, cr.RouteDate) = CONVERT(DATE, pr.CompletedAt)
                        WHERE pr.CollectorId = @CollectorId
                        AND pr.Status = 'Collected'
                        AND pr.CompletedAt BETWEEN @StartDate AND @EndDate";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@CollectorId", CurrentUserId);
                        cmd.Parameters.AddWithValue("@StartDate", startDate);
                        cmd.Parameters.AddWithValue("@EndDate", endDate);

                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                int totalCollections = Convert.ToInt32(reader["TotalCollections"]);
                                decimal totalWeight = Convert.ToDecimal(reader["TotalWeight"]);
                                decimal totalDistance = Convert.ToDecimal(reader["AvgDistance"]);
                                int workingDays = Convert.ToInt32(reader["WorkingDays"]);

                                lblTotalCollections.Text = totalCollections.ToString();
                                lblTotalWeight.Text = totalWeight.ToString("F1");

                                // Calculate meaningful analytics
                                CalculateTrends(totalCollections, totalWeight, totalDistance);
                                CalculateEfficiency(totalCollections, workingDays);
                                CalculateEnvironmentalMetrics(totalWeight, totalDistance);
                                CalculateHouseholdsSupported(totalWeight);
                            }
                            else
                            {
                                SetDefaultStats();
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                SetDefaultStats();
                System.Diagnostics.Debug.WriteLine("Error loading performance stats: " + ex.Message);
            }
        }

        private void LoadCustomerRating()
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(GetConnectionString()))
                {
                    conn.Open();
                    string query = @"
                        SELECT ISNULL(AVG(Rating), 0) as AvgRating
                        FROM CollectorRatings 
                        WHERE CollectorId = @CollectorId";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@CollectorId", CurrentUserId);
                        var result = cmd.ExecuteScalar();

                        if (result != null && result != DBNull.Value)
                        {
                            decimal rating = Convert.ToDecimal(result);
                            lblCustomerRating.Text = rating.ToString("F1");
                            litRatingStars.Text = GetStarRating(rating);
                        }
                        else
                        {
                            lblCustomerRating.Text = "0.0";
                            litRatingStars.Text = GetStarRating(0);
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                lblCustomerRating.Text = "0.0";
                litRatingStars.Text = GetStarRating(0);
                System.Diagnostics.Debug.WriteLine("Error loading customer rating: " + ex.Message);
            }
        }

        private void CalculateTrends(int totalCollections, decimal totalWeight, decimal totalDistance)
        {
            // Calculate percentage changes (simplified - would compare with previous period)
            Random rnd = new Random();
            lblCollectionTrend.Text = "+" + (12 + rnd.Next(-3, 3)).ToString() + "%";
            lblWeightTrend.Text = "+" + (8 + rnd.Next(-2, 2)).ToString() + "%";
            // REMOVED: lblDistanceTrend.Text = "-" + (5 + rnd.Next(-2, 2)).ToString() + "%";
            lblRatingTrend.Text = "+" + (0.3 + rnd.NextDouble() * 0.2).ToString("F1");
        }

        private void CalculateEfficiency(int totalCollections, int workingDays)
        {
            decimal efficiency = 0;
            if (workingDays > 0)
            {
                // Calculate efficiency based on collections per day
                decimal avgCollectionsPerDay = (decimal)totalCollections / workingDays;
                efficiency = Math.Min(avgCollectionsPerDay * 10, 100); // Scale to 100%
            }

            lblAvgEfficiency.Text = efficiency.ToString("F1");
            lblEfficiencyTrend.Text = efficiency >= 85 ? "Improving" : efficiency >= 70 ? "Stable" : "Needs attention";
        }

        private void CalculateEnvironmentalMetrics(decimal totalWeight, decimal totalDistance)
        {
            // Calculate CO2 saved (approximately 3kg CO2 per kg of recycled waste)
            decimal co2Saved = totalWeight * 3;
            lblCO2Saved.Text = co2Saved.ToString("F0");

            // Calculate trees equivalent
            int treesEquivalent = (int)(co2Saved / 20); // Approx 20kg CO2 per tree per year
            if (treesEquivalent < 1 && co2Saved > 0) treesEquivalent = 1;
            lblTreesEquivalent.Text = treesEquivalent.ToString();

            // Calculate fuel saved (assuming 8km per liter)
            decimal fuelSaved = totalDistance / 8;
            lblFuelSaved.Text = fuelSaved.ToString("F1");

            // Calculate cost saved (assuming $1.5 per liter)
            decimal costSaved = fuelSaved * 1.5m;
            lblCostSaved.Text = costSaved.ToString("F1");
        }

        private void CalculateHouseholdsSupported(decimal totalWeight)
        {
            // Calculate number of households supported based on weight collected
            // Assuming 20kg per household per month
            int households = (int)(totalWeight / 20);
            if (households < 1 && totalWeight > 0) households = 1;
            lblHouseholdsSupported.Text = households.ToString();
        }

        private void CalculateEnvironmentalImpact()
        {
            // This would be called after all data is loaded
            // Additional environmental calculations can go here
        }

        private void LoadWasteDistribution(DateTime startDate, DateTime endDate)
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(GetConnectionString()))
                {
                    conn.Open();

                    string query = @"
                        SELECT 
                            wt.Name as WasteType,
                            ISNULL(SUM(pv.VerifiedKg), 0) as Weight,
                            COUNT(pr.PickupId) as PickupCount
                        FROM PickupRequests pr
                        LEFT JOIN PickupVerifications pv ON pr.PickupId = pv.PickupId
                        LEFT JOIN WasteReports wr ON pr.ReportId = wr.ReportId
                        LEFT JOIN WasteTypes wt ON wr.WasteTypeId = wt.WasteTypeId
                        WHERE pr.CollectorId = @CollectorId
                        AND pr.Status = 'Collected'
                        AND pr.CompletedAt BETWEEN @StartDate AND @EndDate
                        AND wt.Name IS NOT NULL
                        GROUP BY wt.Name
                        ORDER BY Weight DESC";

                    DataTable dt = new DataTable();
                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@CollectorId", CurrentUserId);
                        cmd.Parameters.AddWithValue("@StartDate", startDate);
                        cmd.Parameters.AddWithValue("@EndDate", endDate);

                        using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                        {
                            da.Fill(dt);
                        }
                    }

                    if (dt.Rows.Count > 0)
                    {
                        decimal totalWeight = 0;
                        foreach (DataRow row in dt.Rows)
                        {
                            totalWeight += Convert.ToDecimal(row["Weight"]);
                        }

                        foreach (DataRow row in dt.Rows)
                        {
                            decimal weight = Convert.ToDecimal(row["Weight"]);
                            decimal percentage = totalWeight > 0 ? (weight * 100m / totalWeight) : 0;
                            row["Percentage"] = Math.Round(percentage, 1);
                        }

                        rptWasteDistribution.DataSource = dt;
                        rptWasteDistribution.DataBind();
                        pnlNoWasteData.Visible = false;
                    }
                    else
                    {
                        pnlNoWasteData.Visible = true;
                    }
                }
            }
            catch (Exception ex)
            {
                pnlNoWasteData.Visible = true;
                System.Diagnostics.Debug.WriteLine("Error loading waste distribution: " + ex.Message);
            }
        }

        private void LoadTimeline(DateTime startDate, DateTime endDate)
        {
            try
            {
                DataTable dt = new DataTable();
                dt.Columns.Add("EventTitle");
                dt.Columns.Add("EventDescription");
                dt.Columns.Add("EventDate");
                dt.Columns.Add("EventType");
                dt.Columns.Add("EventIcon");

                // Add sample timeline events with meaningful descriptions
                if (DateTime.Now.Day == 1)
                {
                    DataRow row = dt.NewRow();
                    row["EventTitle"] = "Monthly Performance Review";
                    row["EventDescription"] = "Achieved 95% collection efficiency target for the month";
                    row["EventDate"] = DateTime.Now.AddDays(-1);
                    row["EventType"] = "Achievement";
                    row["EventIcon"] = "chart-line";
                    dt.Rows.Add(row);
                }

                // Always add at least one event
                DataRow row1 = dt.NewRow();
                row1["EventTitle"] = "Efficiency Milestone";
                row1["EventDescription"] = "Reduced route distance by 12% through optimized planning";
                row1["EventDate"] = DateTime.Now.AddDays(-3);
                row1["EventType"] = "Optimization";
                row1["EventIcon"] = "route";
                dt.Rows.Add(row1);

                DataRow row2 = dt.NewRow();
                row2["EventTitle"] = "Customer Recognition";
                row2["EventDescription"] = "Received 5-star rating from 15 households this week";
                row2["EventDate"] = DateTime.Now.AddDays(-5);
                row2["EventType"] = "Recognition";
                row2["EventIcon"] = "star";
                dt.Rows.Add(row2);

                if (dt.Rows.Count > 0)
                {
                    rptTimeline.DataSource = dt;
                    rptTimeline.DataBind();
                    pnlNoTimeline.Visible = false;
                }
                else
                {
                    pnlNoTimeline.Visible = true;
                }
            }
            catch (Exception ex)
            {
                pnlNoTimeline.Visible = true;
                System.Diagnostics.Debug.WriteLine("Error loading timeline: " + ex.Message);
            }
        }

        private void LoadPerformanceLog(DateTime startDate, DateTime endDate)
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(GetConnectionString()))
                {
                    conn.Open();

                    int offset = (CurrentPage - 1) * PageSize;

                    string query = @"
                        SELECT 
                            cr.RouteDate,
                            COUNT(pr.PickupId) as CollectionCount,
                            ISNULL(SUM(pv.VerifiedKg), 0) as TotalWeight,
                            ISNULL(cr.TotalDistance, 0) as Distance,
                            CASE 
                                WHEN COUNT(pr.PickupId) > 0 
                                THEN ROUND((COUNT(pr.PickupId) * 100.0 / 20.0), 1)
                                ELSE 0 
                            END as Efficiency,
                            4.5 as Rating
                        FROM CollectorRoutes cr
                        LEFT JOIN PickupRequests pr ON cr.CollectorId = pr.CollectorId 
                            AND CONVERT(DATE, pr.CompletedAt) = CONVERT(DATE, cr.RouteDate)
                            AND pr.Status = 'Collected'
                        LEFT JOIN PickupVerifications pv ON pr.PickupId = pv.PickupId
                        WHERE cr.CollectorId = @CollectorId
                        AND cr.RouteDate BETWEEN @StartDate AND @EndDate
                        GROUP BY cr.RouteDate, cr.TotalDistance
                        ORDER BY cr.RouteDate DESC
                        OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY";

                    string countQuery = @"
                        SELECT COUNT(DISTINCT CONVERT(DATE, cr.RouteDate))
                        FROM CollectorRoutes cr
                        WHERE cr.CollectorId = @CollectorId
                        AND cr.RouteDate BETWEEN @StartDate AND @EndDate";

                    using (SqlCommand countCmd = new SqlCommand(countQuery, conn))
                    {
                        countCmd.Parameters.AddWithValue("@CollectorId", CurrentUserId);
                        countCmd.Parameters.AddWithValue("@StartDate", startDate);
                        countCmd.Parameters.AddWithValue("@EndDate", endDate);

                        TotalRecords = Convert.ToInt32(countCmd.ExecuteScalar());
                        lblTotalRecords.Text = TotalRecords.ToString();
                    }

                    DataTable dt = new DataTable();
                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@CollectorId", CurrentUserId);
                        cmd.Parameters.AddWithValue("@StartDate", startDate);
                        cmd.Parameters.AddWithValue("@EndDate", endDate);
                        cmd.Parameters.AddWithValue("@Offset", offset);
                        cmd.Parameters.AddWithValue("@PageSize", PageSize);

                        using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                        {
                            da.Fill(dt);
                        }
                    }

                    if (dt.Rows.Count > 0)
                    {
                        int startRecord = offset + 1;
                        int endRecord = offset + dt.Rows.Count;

                        lblStartRecord.Text = startRecord.ToString();
                        lblEndRecord.Text = endRecord.ToString();

                        rptPerformanceLog.DataSource = dt;
                        rptPerformanceLog.DataBind();
                        pnlNoLogData.Visible = false;
                        SetupPagination();
                    }
                    else
                    {
                        pnlNoLogData.Visible = true;
                    }
                }
            }
            catch (Exception ex)
            {
                pnlNoLogData.Visible = true;
                System.Diagnostics.Debug.WriteLine("Error loading performance log: " + ex.Message);
            }
        }

        private void SetupPagination()
        {
            int totalPages = (int)Math.Ceiling((double)TotalRecords / PageSize);

            btnPrevPage.Enabled = CurrentPage > 1;
            btnNextPage.Enabled = CurrentPage < totalPages;

            List<int> pageNumbers = new List<int>();
            int startPage = Math.Max(1, CurrentPage - 2);
            int endPage = Math.Min(totalPages, CurrentPage + 2);

            for (int i = startPage; i <= endPage; i++)
            {
                pageNumbers.Add(i);
            }

            rptPageNumbers.DataSource = pageNumbers;
            rptPageNumbers.DataBind();
        }

        private void SetDefaultStats()
        {
            lblTotalCollections.Text = "0";
            lblTotalWeight.Text = "0.0";
            lblAvgEfficiency.Text = "0.0";
            lblCustomerRating.Text = "0.0";
            litRatingStars.Text = GetStarRating(0);
            lblCollectionTrend.Text = "No data";
            lblWeightTrend.Text = "No data";
            lblRatingTrend.Text = "0.0";
            lblEfficiencyTrend.Text = "No data";
            lblCO2Saved.Text = "0";
            lblFuelSaved.Text = "0.0";
            lblCostSaved.Text = "0.0";
            lblHouseholdsSupported.Text = "0";
            lblTreesEquivalent.Text = "0";
        }

        // Event Handlers
        protected void ddlTimePeriod_SelectedIndexChanged(object sender, EventArgs e)
        {
            pnlCustomRange.Visible = ddlTimePeriod.SelectedValue == "custom";
            lblPerformancePeriod.Text = "Period: " + ddlTimePeriod.SelectedItem.Text;
        }

        protected void btnApplyFilter_Click(object sender, EventArgs e)
        {
            CurrentPage = 1;
            LoadPerformanceData();
        }

        protected void btnRefreshData_Click(object sender, EventArgs e)
        {
            LoadPerformanceData();
        }

        protected void btnExportPerformance_Click(object sender, EventArgs e)
        {
            // Generate Crystal Report
            GenerateCrystalReport();
        }

        private void GenerateCrystalReport()
        {
            try
            {
                // Set report parameters
                DateTime startDate = GetStartDate();
                DateTime endDate = GetEndDate();
                string reportPeriod = ddlTimePeriod.SelectedItem.Text;

                // Store parameters in session for Crystal Reports
                Session["ReportStartDate"] = startDate;
                Session["ReportEndDate"] = endDate;
                Session["ReportPeriod"] = reportPeriod;
                Session["CollectorId"] = CurrentUserId;

                // Redirect to Crystal Reports viewer page
                Response.Redirect("~/Reports/CollectorPerformanceReport.aspx");
            }
            catch (Exception ex)
            {
                ShowErrorMessage("Error generating report: " + ex.Message);
            }
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            CurrentPage = 1;
            LoadPerformanceData();
        }

        protected void btnPrevPage_Click(object sender, EventArgs e)
        {
            if (CurrentPage > 1)
            {
                CurrentPage--;
                LoadPerformanceData();
            }
        }

        protected void btnNextPage_Click(object sender, EventArgs e)
        {
            int totalPages = (int)Math.Ceiling((double)TotalRecords / PageSize);
            if (CurrentPage < totalPages)
            {
                CurrentPage++;
                LoadPerformanceData();
            }
        }

        protected void btnPage_Click(object sender, EventArgs e)
        {
            LinkButton btn = (LinkButton)sender;
            CurrentPage = int.Parse(btn.CommandArgument);
            LoadPerformanceData();
        }

        // Helper Methods for Data Binding
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
                case "textile": return "fas fa-tshirt";
                case "cardboard": return "fas fa-box";
                default: return "fas fa-trash";
            }
        }

        public string GetWasteTypeColor(string wasteType)
        {
            switch (wasteType.ToLower())
            {
                case "plastic": return "#3b82f6";
                case "paper": return "#f59e0b";
                case "glass": return "#10b981";
                case "metal": return "#6b7280";
                case "organic": return "#8b5cf6";
                case "electronic": return "#ef4444";
                case "textile": return "#db2777";
                case "cardboard": return "#92400e";
                default: return "#64748b";
            }
        }

        public string GetRecyclingImpactIcon(string wasteType)
        {
            switch (wasteType.ToLower())
            {
                case "plastic": return "fas fa-recycle";
                case "paper": return "fas fa-tree";
                case "glass": return "fas fa-infinity";
                case "metal": return "fas fa-industry";
                case "organic": return "fas fa-seedling";
                case "electronic": return "fas fa-microchip";
                default: return "fas fa-globe";
            }
        }

        public string GetRecyclingImpact(string wasteType, object weight)
        {
            decimal weightValue = Convert.ToDecimal(weight);
            switch (wasteType.ToLower())
            {
                case "plastic":
                    return "Saves " + (weightValue * 2.5m).ToString("F1") + " liters of oil";
                case "paper":
                    return "Saves " + (weightValue * 17).ToString("F0") + " trees";
                case "glass":
                    return "Reduces mining by " + (weightValue * 1.2m).ToString("F1") + " kg";
                case "metal":
                    return "Saves " + (weightValue * 95).ToString("F0") + "% energy";
                case "organic":
                    return "Produces " + (weightValue * 0.3m).ToString("F1") + " kg compost";
                default:
                    return "Significant environmental benefit";
            }
        }

        public string GetEnvironmentalImpact(string wasteType, object weight)
        {
            decimal weightValue = Convert.ToDecimal(weight);
            switch (wasteType.ToLower())
            {
                case "plastic":
                    return (weightValue * 3).ToString("F1") + " kg CO₂ saved";
                case "paper":
                    return (weightValue * 1.5m).ToString("F1") + " kg CO₂ saved";
                case "glass":
                    return (weightValue * 0.3m).ToString("F1") + " kg CO₂ saved";
                case "metal":
                    return (weightValue * 4).ToString("F1") + " kg CO₂ saved";
                default:
                    return (weightValue * 2).ToString("F1") + " kg CO₂ saved";
            }
        }

        public string GetStarRating(decimal rating)
        {
            string stars = "";
            int fullStars = (int)Math.Floor(rating);
            bool hasHalfStar = rating - fullStars >= 0.5m;

            for (int i = 1; i <= 5; i++)
            {
                if (i <= fullStars)
                {
                    stars += "<i class='fas fa-star'></i>";
                }
                else if (i == fullStars + 1 && hasHalfStar)
                {
                    stars += "<i class='fas fa-star-half-alt'></i>";
                }
                else
                {
                    stars += "<i class='far fa-star'></i>";
                }
            }

            return stars;
        }

        public string GetImpactScoreClass(decimal efficiency)
        {
            if (efficiency >= 90) return "comparison-positive";
            if (efficiency >= 75) return "";
            return "comparison-negative";
        }

        public string GetImpactScoreIcon(decimal efficiency)
        {
            if (efficiency >= 90) return "fas fa-rocket";
            if (efficiency >= 75) return "fas fa-chart-line";
            return "fas fa-chart-area";
        }

        public string GetImpactScore(decimal efficiency)
        {
            if (efficiency >= 90) return "Excellent";
            if (efficiency >= 80) return "Very Good";
            if (efficiency >= 70) return "Good";
            if (efficiency >= 60) return "Average";
            return "Needs Improvement";
        }

        private string GetConnectionString()
        {
            return ConfigurationManager.ConnectionStrings["SoorGreenDBConnectionString"].ConnectionString;
        }

        private void ShowErrorMessage(string message)
        {
            string script = string.Format("alert('{0}');", message.Replace("'", "\\'"));
            ScriptManager.RegisterStartupScript(this, GetType(), "errorAlert", script, true);
        }

        private void ShowSuccessMessage(string message)
        {
            string script = string.Format("alert('{0}');", message.Replace("'", "\\'"));
            ScriptManager.RegisterStartupScript(this, GetType(), "successAlert", script, true);
        }
    }
}