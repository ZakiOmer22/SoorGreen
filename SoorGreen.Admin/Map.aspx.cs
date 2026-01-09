using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Linq;

namespace SoorGreen.Admin
{
    public partial class Map : System.Web.UI.Page
    {
        // Current filter values
        protected string CurrentCity = "all";
        protected string CurrentTime = "now";
        protected string CurrentStatus = "all";
        protected string CurrentWaste = "all";
        protected string CurrentSeverity = "all";
        protected string CurrentPriority = "all";
        protected string CurrentMapVersion = "standard";
        protected string CurrentLayer = "reports,dumps,facilities";

        // Statistics - MAKE THESE PUBLIC PROPERTIES
        public int CriticalReports { get; set; }
        public int ActiveCollections { get; set; }
        public int CollectionRate { get; set; }
        public int TotalReports { get; set; }
        public int EmergencyCount { get; set; }

        // Old statistics (keep for compatibility)
        protected int LiveReportsCount = 0;
        protected int ActiveTasksCount = 0;
        protected string ResponseRate = "0%";
        protected string AvgResponseTime = "0m";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // Initialize filters from query string or defaults
                InitializeFilters();

                // Load recent reports
                LoadRecentReports();

                // Load statistics
                LoadStatistics();

                // Set initial values for hidden fields
                SetInitialFilterValues();

                // DataBind to make properties accessible in ASPX
                DataBind();
            }
            else
            {
                // Update filters from view state
                LoadFilterValues();
            }
        }

        private void InitializeFilters()
        {
            // Get filters from query string if available
            if (!string.IsNullOrEmpty(Request.QueryString["city"]))
                CurrentCity = Request.QueryString["city"].ToLower();

            if (!string.IsNullOrEmpty(Request.QueryString["time"]))
                CurrentTime = Request.QueryString["time"].ToLower();

            if (!string.IsNullOrEmpty(Request.QueryString["status"]))
                CurrentStatus = Request.QueryString["status"].ToLower();

            if (!string.IsNullOrEmpty(Request.QueryString["waste"]))
                CurrentWaste = Request.QueryString["waste"].ToLower();

            if (!string.IsNullOrEmpty(Request.QueryString["severity"]))
                CurrentSeverity = Request.QueryString["severity"].ToLower();

            if (!string.IsNullOrEmpty(Request.QueryString["priority"]))
                CurrentPriority = Request.QueryString["priority"].ToLower();

            if (!string.IsNullOrEmpty(Request.QueryString["version"]))
                CurrentMapVersion = Request.QueryString["version"].ToLower();

            if (!string.IsNullOrEmpty(Request.QueryString["layer"]))
                CurrentLayer = Request.QueryString["layer"].ToLower();
        }

        private void SetInitialFilterValues()
        {
            // Set initial values for hidden fields
            if (hdnCurrentCity != null) hdnCurrentCity.Value = CurrentCity;
            if (hdnCurrentTime != null) hdnCurrentTime.Value = CurrentTime;
            if (hdnCurrentStatus != null) hdnCurrentStatus.Value = CurrentStatus;
            if (hdnCurrentWaste != null) hdnCurrentWaste.Value = CurrentWaste;
            if (hdnCurrentSeverity != null) hdnCurrentSeverity.Value = CurrentSeverity;
            if (hdnMapVersion != null) hdnMapVersion.Value = CurrentMapVersion;
            if (hdnActiveLayers != null) hdnActiveLayers.Value = CurrentLayer;
        }

        private void LoadFilterValues()
        {
            // Load filters from hidden fields
            CurrentCity = hdnCurrentCity?.Value ?? "all";
            CurrentTime = hdnCurrentTime?.Value ?? "now";
            CurrentStatus = hdnCurrentStatus?.Value ?? "all";
            CurrentWaste = hdnCurrentWaste?.Value ?? "all";
            CurrentSeverity = hdnCurrentSeverity?.Value ?? "all";
            CurrentMapVersion = hdnMapVersion?.Value ?? "standard";
            CurrentLayer = hdnActiveLayers?.Value ?? "reports,dumps,facilities";
        }

        private void LoadRecentReports()
        {
            try
            {
                // Get sample data
                List<WasteReport> reports = GetSampleReports();

                // Apply filters to sample data
                reports = ApplyFiltersToReports(reports);

                if (reports.Count > 0)
                {
                    rptRecentReports.DataSource = reports;
                    rptRecentReports.DataBind();
                    pnlNoReports.Visible = false;
                }
                else
                {
                    pnlNoReports.Visible = true;
                }

                // Update total reports count for sidebar
                TotalReports = reports.Count;
            }
            catch (Exception ex)
            {
                // Log error
                System.Diagnostics.Debug.WriteLine("Error loading reports: " + ex.Message);
                pnlNoReports.Visible = true;
            }
        }

        private void LoadStatistics()
        {
            try
            {
                // Get all sample reports
                List<WasteReport> allReports = GetSampleReports();

                // Calculate original statistics (for original header)
                LiveReportsCount = allReports.Count;
                ActiveTasksCount = allReports.Count(r => r.Status == "assigned" || r.Status == "in-progress");

                int collectedCount = allReports.Count(r => r.Status == "collected");
                ResponseRate = allReports.Count > 0 ? Math.Round((collectedCount / (double)allReports.Count) * 100) + "%" : "0%";

                // Calculate average response time (simulated)
                AvgResponseTime = allReports.Count > 0 ? Math.Round((allReports.Count * 45.0) / allReports.Count) + "m" : "0m";

                // Calculate enhanced statistics (for new dashboard)
                CriticalReports = allReports.Count(r => r.Severity == "critical" && r.Status != "collected");
                EmergencyCount = allReports.Count(r => r.Priority == "emergency" && r.Status != "collected");
                ActiveCollections = allReports.Count(r => r.Status == "in-progress" || r.Status == "assigned");
                CollectionRate = allReports.Count > 0 ? (int)Math.Round((collectedCount / (double)allReports.Count) * 100) : 0;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error loading statistics: " + ex.Message);
            }
        }

        private List<WasteReport> GetSampleReports()
        {
            // Enhanced sample data for Somaliland with more points
            var reports = new List<WasteReport>
            {
                // Hargeisa - Critical/High Priority
                new WasteReport
                {
                    ReportID = "RPT_CRIT_001",
                    WasteType = "plastic",
                    Severity = "critical",
                    Status = "new",
                    Priority = "emergency",
                    Address = "Main Market Entrance, Hargeisa",
                    ReportedAt = DateTime.Now.AddHours(-2),
                    City = "Hargeisa",
                    ReportedBy = "Ahmed M.",
                    Latitude = 9.560,
                    Longitude = 44.070,
                    HealthRisk = "High",
                    EnvironmentalImpact = "Very High",
                    Quantity = "Large pile (approx 500kg)",
                    Photos = 3,
                    Description = "Large accumulation of plastic bottles and packaging blocking drainage"
                },
                new WasteReport
                {
                    ReportID = "RPT_CRIT_002",
                    WasteType = "hazardous",
                    Severity = "critical",
                    Status = "assigned",
                    Priority = "emergency",
                    Address = "Industrial Area, Hargeisa",
                    ReportedAt = DateTime.Now.AddHours(-3),
                    City = "Hargeisa",
                    ReportedBy = "Fatima A.",
                    Latitude = 9.545,
                    Longitude = 44.040,
                    HealthRisk = "Very High",
                    EnvironmentalImpact = "Very High",
                    Quantity = "Medium (approx 200kg)",
                    Photos = 2,
                    Description = "Chemical containers and medical waste illegally dumped",
                    AssignedTo = "Team Alpha"
                },
                
                // Hargeisa - Medium Priority
                new WasteReport
                {
                    ReportID = "RPT_MED_001",
                    WasteType = "organic",
                    Severity = "medium",
                    Status = "in-progress",
                    Priority = "medium",
                    Address = "Restaurant District",
                    ReportedAt = DateTime.Now.AddHours(-8),
                    City = "Hargeisa",
                    ReportedBy = "Omar S.",
                    Latitude = 9.525,
                    Longitude = 44.090,
                    HealthRisk = "Medium",
                    EnvironmentalImpact = "Medium",
                    Quantity = "Medium (approx 150kg)",
                    Photos = 1,
                    Description = "Food waste overflowing from collection bins",
                    AssignedTo = "Team Beta"
                },
                new WasteReport
                {
                    ReportID = "RPT_MED_002",
                    WasteType = "mixed",
                    Severity = "medium",
                    Status = "assigned",
                    Priority = "medium",
                    Address = "Residential Area Block 5",
                    ReportedAt = DateTime.Now.AddHours(-12),
                    City = "Hargeisa",
                    ReportedBy = "Khadra M.",
                    Latitude = 9.535,
                    Longitude = 44.060,
                    HealthRisk = "Medium",
                    EnvironmentalImpact = "Medium",
                    Quantity = "Large (approx 300kg)",
                    Photos = 0,
                    Description = "Mixed household waste accumulation",
                    AssignedTo = "Team Gamma"
                },
                
                // Burao - Various Priorities
                new WasteReport
                {
                    ReportID = "RPT_HIGH_001",
                    WasteType = "electronics",
                    Severity = "high",
                    Status = "new",
                    Priority = "high",
                    Address = "Burao Market Area",
                    ReportedAt = DateTime.Now.AddMinutes(-30),
                    City = "Burao",
                    ReportedBy = "Abdullahi H.",
                    Latitude = 9.520,
                    Longitude = 45.540,
                    HealthRisk = "High",
                    EnvironmentalImpact = "High",
                    Quantity = "Small (approx 50kg)",
                    Photos = 2,
                    Description = "Discarded electronics and appliances"
                },
                new WasteReport
                {
                    ReportID = "RPT_LOW_001",
                    WasteType = "plastic",
                    Severity = "low",
                    Status = "collected",
                    Priority = "low",
                    Address = "Burao Park Area",
                    ReportedAt = DateTime.Now.AddDays(-2),
                    City = "Burao",
                    ReportedBy = "Maryan A.",
                    Latitude = 9.510,
                    Longitude = 45.550,
                    HealthRisk = "Low",
                    EnvironmentalImpact = "Low",
                    Quantity = "Small (approx 20kg)",
                    Photos = 1,
                    Description = "Scattered plastic bottles in park",
                    AssignedTo = "Team Delta",
                    CollectedAt = DateTime.Now.AddDays(-1)
                },
                
                // Borama - Various Reports
                new WasteReport
                {
                    ReportID = "RPT_MED_003",
                    WasteType = "bulky",
                    Severity = "medium",
                    Status = "in-progress",
                    Priority = "medium",
                    Address = "Borama Main Street",
                    ReportedAt = DateTime.Now.AddHours(-6),
                    City = "Borama",
                    ReportedBy = "Hassan M.",
                    Latitude = 9.945,
                    Longitude = 43.185,
                    HealthRisk = "Medium",
                    EnvironmentalImpact = "Medium",
                    Quantity = "Bulky items (approx 400kg)",
                    Photos = 3,
                    Description = "Discarded furniture and appliances",
                    AssignedTo = "Team Epsilon"
                },
                
                // Berbera - Critical Report
                new WasteReport
                {
                    ReportID = "RPT_CRIT_003",
                    WasteType = "mixed",
                    Severity = "critical",
                    Status = "new",
                    Priority = "emergency",
                    Address = "Berbera Port Entrance",
                    ReportedAt = DateTime.Now.AddMinutes(-15),
                    City = "Berbera",
                    ReportedBy = "Port Authority",
                    Latitude = 10.440,
                    Longitude = 45.020,
                    HealthRisk = "Very High",
                    EnvironmentalImpact = "Critical",
                    Quantity = "Very Large (approx 1000kg)",
                    Photos = 4,
                    Description = "Major waste accumulation blocking port access"
                },
                
                // Additional points for density
                new WasteReport
                {
                    ReportID = "RPT_LOW_002",
                    WasteType = "plastic",
                    Severity = "low",
                    Status = "new",
                    Priority = "low",
                    Address = "Hargeisa University Area",
                    ReportedAt = DateTime.Now.AddHours(-3),
                    City = "Hargeisa",
                    ReportedBy = "Student Union",
                    Latitude = 9.550,
                    Longitude = 44.075,
                    HealthRisk = "Low",
                    EnvironmentalImpact = "Low",
                    Quantity = "Small (approx 15kg)",
                    Photos = 0,
                    Description = "Scattered plastic waste near campus"
                },
                new WasteReport
                {
                    ReportID = "RPT_MED_004",
                    WasteType = "organic",
                    Severity = "medium",
                    Status = "assigned",
                    Priority = "medium",
                    Address = "Burao Vegetable Market",
                    ReportedAt = DateTime.Now.AddHours(-4),
                    City = "Burao",
                    ReportedBy = "Market Trader",
                    Latitude = 9.515,
                    Longitude = 45.545,
                    HealthRisk = "Medium",
                    EnvironmentalImpact = "Medium",
                    Quantity = "Medium (approx 100kg)",
                    Photos = 1,
                    Description = "Vegetable waste accumulation",
                    AssignedTo = "Team Zeta"
                }
            };

            return reports;
        }

        private List<WasteReport> ApplyFiltersToReports(List<WasteReport> reports)
        {
            var filteredReports = reports;

            // Apply city filter
            if (CurrentCity != "all")
            {
                filteredReports = filteredReports.FindAll(r =>
                    r.City.ToLower() == CurrentCity.ToLower());
            }

            // Apply time filter
            if (CurrentTime != "now")
            {
                DateTime cutoffDate = DateTime.Now;
                switch (CurrentTime)
                {
                    case "today":
                        cutoffDate = cutoffDate.AddDays(-1);
                        break;
                    case "week":
                        cutoffDate = cutoffDate.AddDays(-7);
                        break;
                    case "month":
                        cutoffDate = cutoffDate.AddDays(-30);
                        break;
                    case "7d":
                        cutoffDate = cutoffDate.AddDays(-7);
                        break;
                    case "30d":
                        cutoffDate = cutoffDate.AddDays(-30);
                        break;
                }
                filteredReports = filteredReports.FindAll(r => r.ReportedAt >= cutoffDate);
            }

            // Apply status filter
            if (CurrentStatus != "all")
            {
                filteredReports = filteredReports.FindAll(r =>
                    r.Status.ToLower() == CurrentStatus.ToLower());
            }

            // Apply waste type filter
            if (CurrentWaste != "all")
            {
                filteredReports = filteredReports.FindAll(r =>
                    r.WasteType.ToLower() == CurrentWaste.ToLower());
            }

            // Apply severity filter
            if (CurrentSeverity != "all")
            {
                filteredReports = filteredReports.FindAll(r =>
                    r.Severity.ToLower() == CurrentSeverity.ToLower());
            }

            // Apply priority filter
            if (!string.IsNullOrEmpty(CurrentPriority) && CurrentPriority != "all")
            {
                filteredReports = filteredReports.FindAll(r =>
                    r.Priority.ToLower() == CurrentPriority.ToLower());
            }

            // Sort by severity and recency
            filteredReports = filteredReports
                .OrderByDescending(r => GetSeverityWeight(r.Severity))
                .ThenByDescending(r => r.ReportedAt)
                .ToList();

            return filteredReports;
        }

        private int GetSeverityWeight(string severity)
        {
            switch (severity.ToLower())
            {
                case "critical": return 4;
                case "high": return 3;
                case "medium": return 2;
                case "low": return 1;
                default: return 0;
            }
        }

        // Event handlers for filter buttons - MAKE THESE PUBLIC
        public void FilterByCity(object sender, EventArgs e)
        {
            var button = (LinkButton)sender;
            CurrentCity = button.CommandArgument.ToLower();

            // Update hidden field
            if (hdnCurrentCity != null) hdnCurrentCity.Value = CurrentCity;

            LoadRecentReports();
            LoadStatistics();
            DataBind();
        }

        public void FilterByTime(object sender, EventArgs e)
        {
            var button = (LinkButton)sender;
            CurrentTime = button.CommandArgument.ToLower();

            // Update hidden field
            if (hdnCurrentTime != null) hdnCurrentTime.Value = CurrentTime;

            LoadRecentReports();
            LoadStatistics();
            DataBind();
        }

        public void FilterByStatus(object sender, EventArgs e)
        {
            var button = (LinkButton)sender;
            CurrentStatus = button.CommandArgument.ToLower();

            // Update hidden field
            if (hdnCurrentStatus != null) hdnCurrentStatus.Value = CurrentStatus;

            LoadRecentReports();
            LoadStatistics();
            DataBind();
        }

        public void FilterByWaste(object sender, EventArgs e)
        {
            var button = (LinkButton)sender;
            CurrentWaste = button.CommandArgument.ToLower();

            // Update hidden field
            if (hdnCurrentWaste != null) hdnCurrentWaste.Value = CurrentWaste;

            LoadRecentReports();
            LoadStatistics();
            DataBind();
        }

        public void FilterBySeverity(object sender, EventArgs e)
        {
            var button = (LinkButton)sender;
            CurrentSeverity = button.CommandArgument.ToLower();

            // Update hidden field
            if (hdnCurrentSeverity != null) hdnCurrentSeverity.Value = CurrentSeverity;

            LoadRecentReports();
            LoadStatistics();
            DataBind();
        }

        // Helper method to format time ago - MAKE THIS PUBLIC
        public string FormatTimeAgo(DateTime date)
        {
            TimeSpan timeSince = DateTime.Now.Subtract(date);

            if (timeSince.TotalMinutes < 1)
                return "Just now";
            else if (timeSince.TotalMinutes < 60)
                return string.Format("{0} minutes ago", (int)timeSince.TotalMinutes);
            else if (timeSince.TotalHours < 24)
                return string.Format("{0} hours ago", (int)timeSince.TotalHours);
            else if (timeSince.TotalDays < 7)
                return string.Format("{0} days ago", (int)timeSince.TotalDays);
            else if (timeSince.TotalDays < 30)
                return string.Format("{0} weeks ago", (int)(timeSince.TotalDays / 7));
            else
                return string.Format("{0} months ago", (int)(timeSince.TotalDays / 30));
        }

        // Helper method to get CSS class for severity - MAKE THIS PUBLIC
        public string GetSeverityClass(string severity)
        {
            switch (severity.ToLower())
            {
                case "critical": return "critical";
                case "high": return "high";
                case "medium": return "medium";
                case "low": return "low";
                default: return "medium";
            }
        }

        // Helper method to get CSS class for waste type - MAKE THIS PUBLIC
        public string GetWasteTypeClass(string wasteType)
        {
            switch (wasteType.ToLower())
            {
                case "plastic": return "waste-type-plastic";
                case "organic": return "waste-type-organic";
                case "hazardous": return "waste-type-hazardous";
                case "electronics": return "waste-type-electronics";
                case "bulky": return "waste-type-bulky";
                case "mixed": return "waste-type-mixed";
                default: return "waste-type-mixed";
            }
        }

        // Helper method to format status - MAKE THIS PUBLIC
        public string FormatStatus(string status)
        {
            if (string.IsNullOrEmpty(status))
                return "";

            return status.Replace("-", " ");
        }

        // Data classes
        public class WasteReport
        {
            public string ReportID { get; set; }
            public string WasteType { get; set; }
            public string Severity { get; set; }
            public string Status { get; set; }
            public string Priority { get; set; }
            public string Address { get; set; }
            public DateTime ReportedAt { get; set; }
            public string City { get; set; }
            public string ReportedBy { get; set; }
            public double Latitude { get; set; }
            public double Longitude { get; set; }
            public string HealthRisk { get; set; }
            public string EnvironmentalImpact { get; set; }
            public string Quantity { get; set; }
            public string Description { get; set; }
            public int Photos { get; set; }
            public string AssignedTo { get; set; }
            public DateTime? CollectedAt { get; set; }
        }

        public class Facility
        {
            public string ID { get; set; }
            public string Type { get; set; }
            public string Name { get; set; }
            public double Latitude { get; set; }
            public double Longitude { get; set; }
            public string Capacity { get; set; }
            public string Status { get; set; }
        }
    }
}