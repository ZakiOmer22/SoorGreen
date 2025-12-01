using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.Configuration;
using System.Web.UI.WebControls;

namespace SoorGreen.Admin
{
    public partial class Dashboard : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (Session["UserID"] == null || string.IsNullOrEmpty(Session["UserID"].ToString()))
                {
                    Response.Redirect("Login.aspx");
                    return;
                }

                LoadDashboardData();
            }
        }

        private void LoadDashboardData()
        {
            string userId = Session["UserID"].ToString();
            if (string.IsNullOrEmpty(userId))
            {
                Response.Redirect("Login.aspx");
                return;
            }

            if (Session["UserName"] != null)
            {
                litUserName.Text = Session["UserName"].ToString();
            }

            string connectionString = WebConfigurationManager.ConnectionStrings["SoorGreenDBConnectionString"].ConnectionString;

            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.Open();

                var userStats = LoadUserStats(conn, userId);
                SetUserStats(userStats);
                LoadWasteTypes(conn, userId);
                LoadUpcomingPickups(conn, userId);
                LoadCommunityStats(conn);
                LoadEnvironmentalImpact(conn, userId);
            }
        }

        private UserStats LoadUserStats(SqlConnection conn, string userId)
        {
            var stats = new UserStats();

            // Comprehensive query to get all user statistics from database
            string query = @"
                -- Total recycled and basic stats
                SELECT 
                    ISNULL(SUM(CASE WHEN pr.Status = 'Collected' THEN wr.EstimatedKg ELSE 0 END), 0) as TotalRecycled,
                    ISNULL(COUNT(DISTINCT CASE WHEN pr.Status = 'Collected' THEN pr.PickupId END), 0) as PickupsCompleted,
                    ISNULL(SUM(rp.Amount), 0) as TotalXPPoints,
                    COUNT(DISTINCT wr.ReportId) as TotalReports,
                    
                    -- Monthly data for progress
                    ISNULL(SUM(CASE WHEN MONTH(wr.CreatedAt) = MONTH(GETDATE()) 
                                AND YEAR(wr.CreatedAt) = YEAR(GETDATE())
                                AND pr.Status = 'Collected' 
                                THEN wr.EstimatedKg ELSE 0 END), 0) as ThisMonth,
                    ISNULL(SUM(CASE WHEN MONTH(wr.CreatedAt) = MONTH(DATEADD(MONTH, -1, GETDATE())) 
                                AND YEAR(wr.CreatedAt) = YEAR(DATEADD(MONTH, -1, GETDATE()))
                                AND pr.Status = 'Collected'
                                THEN wr.EstimatedKg ELSE 0 END), 0) as LastMonth,
                    
                    -- Success rate calculation
                    (SELECT COUNT(*) FROM PickupRequests pr2 
                     JOIN WasteReports wr2 ON pr2.ReportId = wr2.ReportId 
                     WHERE wr2.UserId = @UserId AND pr2.Status = 'Collected') as TotalCompletedPickups,
                    
                    -- Current streak (days since last recycling activity)
                    ISNULL(DATEDIFF(DAY, 
                        (SELECT MAX(CreatedAt) FROM WasteReports WHERE UserId = @UserId), 
                        GETDATE()), 0) as CurrentStreak,
                    
                    -- Community rank (based on total recycled)
                    (SELECT COUNT(*) + 1 FROM Users u2 
                     WHERE (SELECT ISNULL(SUM(wr2.EstimatedKg), 0) FROM WasteReports wr2 
                            JOIN PickupRequests pr2 ON wr2.ReportId = pr2.ReportId 
                            WHERE wr2.UserId = u2.UserId AND pr2.Status = 'Collected') > 
                           (SELECT ISNULL(SUM(wr3.EstimatedKg), 0) FROM WasteReports wr3 
                            JOIN PickupRequests pr3 ON wr3.ReportId = pr3.ReportId 
                            WHERE wr3.UserId = @UserId AND pr3.Status = 'Collected')) as CommunityRank
                    
                FROM Users u
                LEFT JOIN WasteReports wr ON u.UserId = wr.UserId
                LEFT JOIN PickupRequests pr ON wr.ReportId = pr.ReportId
                LEFT JOIN RewardPoints rp ON u.UserId = rp.UserId
                WHERE u.UserId = @UserId";

            using (SqlCommand cmd = new SqlCommand(query, conn))
            {
                cmd.Parameters.AddWithValue("@UserId", userId);

                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    if (reader.Read())
                    {
                        stats.TotalRecycled = Convert.ToDecimal(reader["TotalRecycled"]);
                        stats.PickupsCompleted = Convert.ToInt32(reader["PickupsCompleted"]);
                        stats.TotalXPPoints = Convert.ToDecimal(reader["TotalXPPoints"]);
                        stats.TotalReports = Convert.ToInt32(reader["TotalReports"]);
                        stats.ThisMonth = Convert.ToDecimal(reader["ThisMonth"]);
                        stats.LastMonth = Convert.ToDecimal(reader["LastMonth"]);
                        stats.TotalCompletedPickups = Convert.ToInt32(reader["TotalCompletedPickups"]);
                        stats.CurrentStreak = Convert.ToInt32(reader["CurrentStreak"]);
                        stats.CommunityRank = Convert.ToInt32(reader["CommunityRank"]);
                    }
                }
            }

            return stats;
        }

        private void SetUserStats(UserStats stats)
        {
            // Set all stats from database
            litTotalRecycled.Text = stats.TotalRecycled.ToString("0.0");
            litPickupsCompleted.Text = stats.PickupsCompleted.ToString();
            litXPPoints.Text = stats.TotalXPPoints.ToString("N0");
            litTotalReports.Text = stats.TotalReports.ToString();

            // Calculate money saved based on actual recycled amount
            decimal moneySaved = stats.TotalRecycled * 0.5m; // $0.5 per kg estimated
            litMoneySaved.Text = moneySaved.ToString("0.00");

            // Use actual streak from database
            litCurrentStreak.Text = stats.CurrentStreak.ToString();

            // Use actual community rank from database
            litCommunityRank.Text = stats.CommunityRank.ToString();

            // Carbon and trees calculations based on actual data
            decimal carbonSaved = stats.TotalRecycled * 2;
            litCarbonSaved.Text = carbonSaved.ToString("0.0");
            int treesEquivalent = stats.TotalRecycled > 0 ? (int)(carbonSaved / 21) : 0;
            litTreesEquivalent.Text = treesEquivalent.ToString();

            // Monthly progress based on actual current month data
            decimal monthlyGoal = 20m;
            decimal progressPercent = stats.ThisMonth > 0 ? (stats.ThisMonth / monthlyGoal) * 100 : 0;
            if (progressPercent > 100) progressPercent = 100;
            litProgressPercent.Text = progressPercent.ToString("0");
            litCurrentMonth.Text = stats.ThisMonth.ToString("0.0");

            // Progress text based on actual progress
            if (progressPercent >= 100) litProgressText.Text = "Goal achieved! 🎉";
            else if (progressPercent >= 75) litProgressText.Text = "Almost there!";
            else if (progressPercent >= 50) litProgressText.Text = "Great progress!";
            else if (progressPercent >= 25) litProgressText.Text = "Good start!";
            else litProgressText.Text = "Let's get started!";

            // User level based on actual XP points
            if (stats.TotalXPPoints >= 1000) litUserLevel.Text = "Eco Champion";
            else if (stats.TotalXPPoints >= 500) litUserLevel.Text = "Green Warrior";
            else if (stats.TotalXPPoints >= 100) litUserLevel.Text = "Eco Friend";
            else litUserLevel.Text = "Eco Beginner";

            // Points to next level based on actual XP
            decimal pointsToNextLevel = 0;
            if (stats.TotalXPPoints < 100) pointsToNextLevel = 100 - stats.TotalXPPoints;
            else if (stats.TotalXPPoints < 500) pointsToNextLevel = 500 - stats.TotalXPPoints;
            else if (stats.TotalXPPoints < 1000) pointsToNextLevel = 1000 - stats.TotalXPPoints;
            litNextLevel.Text = pointsToNextLevel.ToString("N0");

            // Success rate based on actual pickup data
            decimal successRate = stats.TotalCompletedPickups > 0 ? (stats.PickupsCompleted * 100m / stats.TotalCompletedPickups) : 0;
            litSuccessRate.Text = successRate.ToString("0");

            // Recycling trend based on actual monthly data
            decimal trend = 0;
            if (stats.LastMonth > 0 && stats.ThisMonth > 0)
                trend = ((stats.ThisMonth - stats.LastMonth) / stats.LastMonth) * 100;
            else if (stats.ThisMonth > 0 && stats.LastMonth == 0)
                trend = 100;
            litRecyclingTrend.Text = trend.ToString("0");
        }

        private void LoadWasteTypes(SqlConnection conn, string userId)
        {
            // Get actual waste type breakdown from database
            string query = @"
                SELECT 
                    wt.Name as WasteType,
                    ISNULL(SUM(CASE WHEN pr.Status = 'Collected' THEN wr.EstimatedKg ELSE 0 END), 0) as TotalKg
                FROM WasteTypes wt
                LEFT JOIN WasteReports wr ON wt.WasteTypeId = wr.WasteTypeId AND wr.UserId = @UserId
                LEFT JOIN PickupRequests pr ON wr.ReportId = pr.ReportId
                GROUP BY wt.WasteTypeId, wt.Name
                ORDER BY TotalKg DESC";

            using (SqlCommand cmd = new SqlCommand(query, conn))
            {
                cmd.Parameters.AddWithValue("@UserId", userId);

                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    // Reset all values to 0 first
                    litPlasticKg.Text = "0";
                    litPaperKg.Text = "0";
                    litGlassKg.Text = "0";
                    litMetalKg.Text = "0";
                    litEWasteKg.Text = "0";
                    litOrganicKg.Text = "0";

                    while (reader.Read())
                    {
                        string wasteType = reader["WasteType"].ToString();
                        decimal totalKg = Convert.ToDecimal(reader["TotalKg"]);

                        // Map waste types to the correct literals
                        switch (wasteType.ToLower())
                        {
                            case "plastic":
                                litPlasticKg.Text = totalKg.ToString("0.0");
                                break;
                            case "paper":
                                litPaperKg.Text = totalKg.ToString("0.0");
                                break;
                            case "glass":
                                litGlassKg.Text = totalKg.ToString("0.0");
                                break;
                            case "metal":
                                litMetalKg.Text = totalKg.ToString("0.0");
                                break;
                            case "e-waste":
                                litEWasteKg.Text = totalKg.ToString("0.0");
                                break;
                            case "organic":
                                litOrganicKg.Text = totalKg.ToString("0.0");
                                break;
                        }
                    }
                }
            }
        }

        private void LoadUpcomingPickups(SqlConnection conn, string userId)
        {
            // Get actual upcoming pickups from database
            string query = @"
                SELECT TOP 3
                    wt.Name as WasteType,
                    FORMAT(pr.ScheduledAt, 'MMM dd, hh:mm tt') as ScheduleDate,
                    pr.Status
                FROM PickupRequests pr
                JOIN WasteReports wr ON pr.ReportId = wr.ReportId
                JOIN WasteTypes wt ON wr.WasteTypeId = wt.WasteTypeId
                WHERE wr.UserId = @UserId 
                AND pr.Status IN ('Requested', 'Assigned', 'Scheduled')
                AND (pr.ScheduledAt >= GETDATE() OR pr.ScheduledAt IS NULL)
                ORDER BY pr.ScheduledAt ASC";

            using (SqlCommand cmd = new SqlCommand(query, conn))
            {
                cmd.Parameters.AddWithValue("@UserId", userId);

                using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                {
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    if (dt.Rows.Count > 0)
                    {
                        rptUpcomingPickups.DataSource = dt;
                        rptUpcomingPickups.DataBind();
                        pnlNoUpcomingPickups.Visible = false;
                    }
                    else
                    {
                        pnlNoUpcomingPickups.Visible = true;
                    }
                }
            }
        }

        private void LoadCommunityStats(SqlConnection conn)
        {
            // Get actual community statistics from database
            string query = @"
                SELECT 
                    COUNT(*) as TotalUsers,
                    ISNULL(SUM(CASE WHEN pr.Status = 'Collected' THEN wr.EstimatedKg ELSE 0 END), 0) as TotalRecycledCommunity,
                    COUNT(DISTINCT u.UserId) as ActiveUsers
                FROM Users u
                LEFT JOIN WasteReports wr ON u.UserId = wr.UserId
                LEFT JOIN PickupRequests pr ON wr.ReportId = pr.ReportId
                WHERE u.RoleId IN ('CITZ', 'R001')";

            using (SqlCommand cmd = new SqlCommand(query, conn))
            {
                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    if (reader.Read())
                    {
                        int totalUsers = Convert.ToInt32(reader["TotalUsers"]);
                        decimal totalRecycled = Convert.ToDecimal(reader["TotalRecycledCommunity"]);
                        int activeUsers = Convert.ToInt32(reader["ActiveUsers"]);

                        litTotalUsers.Text = totalUsers.ToString("N0");
                        litTotalRecycledCommunity.Text = totalRecycled.ToString("N0");

                        // Calculate community environmental impact
                        decimal communityCO2Saved = totalRecycled * 2;
                        int communityTreesSaved = totalRecycled > 0 ? (int)(communityCO2Saved / 21) : 0;

                        litTreesSavedCommunity.Text = communityTreesSaved.ToString("N0");
                        litCO2SavedCommunity.Text = communityCO2Saved.ToString("N0");
                    }
                }
            }
        }

        private void LoadEnvironmentalImpact(SqlConnection conn, string userId)
        {
            // Get actual recycled amount for environmental impact calculations
            string query = @"SELECT ISNULL(SUM(wr.EstimatedKg), 0) as TotalRecycled 
                           FROM WasteReports wr 
                           LEFT JOIN PickupRequests pr ON wr.ReportId = pr.ReportId 
                           WHERE wr.UserId = @UserId AND (pr.Status = 'Collected' OR pr.Status IS NULL)";

            using (SqlCommand cmd = new SqlCommand(query, conn))
            {
                cmd.Parameters.AddWithValue("@UserId", userId);
                object result = cmd.ExecuteScalar();
                decimal totalRecycled = result != DBNull.Value ? Convert.ToDecimal(result) : 0;

                // Calculate environmental impact based on actual recycled amount
                int plasticBottles = (int)(totalRecycled * 50); // ~50 bottles per kg
                decimal energySaved = totalRecycled * 5; // ~5 kWh per kg
                decimal waterSaved = totalRecycled * 100; // ~100L water per kg
                decimal fuelSaved = totalRecycled * 0.5m; // ~0.5L fuel per kg

                litPlasticBottles.Text = plasticBottles.ToString("N0");
                litEnergySaved.Text = energySaved.ToString("0");
                litWaterSaved.Text = waterSaved.ToString("0");
                litFuelSaved.Text = fuelSaved.ToString("0.0");
            }
        }

        private class UserStats
        {
            public decimal TotalRecycled { get; set; }
            public int PickupsCompleted { get; set; }
            public decimal TotalXPPoints { get; set; }
            public int TotalCompletedPickups { get; set; }
            public decimal ThisMonth { get; set; }
            public decimal LastMonth { get; set; }
            public int TotalReports { get; set; }
            public int CurrentStreak { get; set; }
            public int CommunityRank { get; set; }
        }

        public string GetProgressOffset()
        {
            decimal progressPercent;
            if (decimal.TryParse(litProgressPercent.Text, out progressPercent))
            {
                decimal circumference = 339.292m;
                decimal offset = circumference - (circumference * progressPercent / 100);
                return offset.ToString("0.00");
            }
            return "339.29";
        }
    }
}