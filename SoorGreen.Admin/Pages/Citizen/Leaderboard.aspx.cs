using System;
using System.Data;
using System.Data.SqlClient;
using System.Collections.Generic;
using System.Web.Configuration;
using System.Web.UI;
using System.Web.Script.Serialization;
using System.Web.Services;

namespace SoorGreen.Citizen
{
    public partial class Leaderboard : System.Web.UI.Page
    {
        private string connectionString = WebConfigurationManager.ConnectionStrings["SoorGreenDBConnectionString"].ConnectionString;
        private string currentUserId = "";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (Session["UserId"] == null)
                {
                    Response.Redirect("~/Login.aspx");
                    return;
                }

                currentUserId = Session["UserId"].ToString();
                LoadData();
            }
        }

        protected void btnApplyFilters_Click(object sender, EventArgs e)
        {
            LoadData();
        }

        protected void btnRefresh_Click(object sender, EventArgs e)
        {
            LoadData();
        }

        protected void LoadData()
        {
            try
            {
                // Get leaderboard data
                List<LeaderboardUser> leaderboardData = GetLeaderboardData();

                // Get user stats
                var userStats = GetUserStats();

                // Get achievements
                var achievements = GetAchievements();

                // Store in hidden fields
                var serializer = new JavaScriptSerializer();
                hfLeaderboardData.Value = serializer.Serialize(leaderboardData);
                hfStatsData.Value = serializer.Serialize(userStats);
                hfAchievementsData.Value = serializer.Serialize(achievements);

                // Update UI
                UpdateUI(userStats);

            }
            catch
            {
                // Silent fail
            }
        }

        private List<LeaderboardUser> GetLeaderboardData()
        {
            var list = new List<LeaderboardUser>();

            string query = @"
                SELECT TOP 20
                    UserId,
                    FullName,
                    Phone,
                    ISNULL(XP_Credits, 0) as TotalXP,
                    CreatedAt
                FROM Users
                WHERE RoleId IN ('CITZ', 'R001')
                AND IsVerified = 1
                ORDER BY ISNULL(XP_Credits, 0) DESC";

            using (SqlConnection conn = new SqlConnection(connectionString))
            using (SqlCommand cmd = new SqlCommand(query, conn))
            {
                conn.Open();
                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    int rank = 1;
                    while (reader.Read())
                    {
                        string userId = reader["UserId"].ToString();
                        string fullName = reader["FullName"].ToString();
                        string phone = reader["Phone"].ToString();
                        decimal totalXP = Convert.ToDecimal(reader["TotalXP"]);

                        list.Add(new LeaderboardUser
                        {
                            Id = userId,
                            Name = fullName,
                            Location = phone,
                            Rank = rank,
                            XP = (int)totalXP,
                            Level = (int)(totalXP / 1000) + 1,
                            Pickups = GetUserPickups(userId),
                            CO2Reduced = totalXP * 0.002m,
                            IsCurrentUser = userId == currentUserId,
                            Trend = GetRandomTrend(),
                            MemberSince = Convert.ToDateTime(reader["CreatedAt"])
                        });
                        rank++;
                    }
                }
            }

            return list;
        }

        private int GetUserPickups(string userId)
        {
            try
            {
                string query = @"
                    SELECT ISNULL(COUNT(*), 0) 
                    FROM WasteReports wr
                    JOIN PickupRequests pr ON wr.ReportId = pr.ReportId
                    WHERE wr.UserId = @UserId AND pr.Status = 'Collected'";

                using (SqlConnection conn = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@UserId", userId);
                    conn.Open();
                    return Convert.ToInt32(cmd.ExecuteScalar());
                }
            }
            catch
            {
                return 0;
            }
        }

        private string GetRandomTrend()
        {
            Random rnd = new Random();
            int val = rnd.Next(1, 100);
            if (val <= 40) return "up";
            if (val <= 70) return "down";
            return "neutral";
        }

        private UserStats GetUserStats()
        {
            var stats = new UserStats
            {
                UserId = currentUserId,
                Name = "User",
                Rank = 1,
                XP = 0,
                Level = 1,
                Pickups = 0,
                CO2Reduced = 0,
                TotalUsers = 0,
                TotalXP = 0,
                TotalPickups = 0,
                TotalCO2Reduced = 0
            };

            try
            {
                // Get current user
                string query = "SELECT FullName, ISNULL(XP_Credits, 0) as TotalXP FROM Users WHERE UserId = @UserId";
                using (SqlConnection conn = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@UserId", currentUserId);
                    conn.Open();
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            stats.Name = reader["FullName"].ToString();
                            stats.XP = Convert.ToInt32(reader["TotalXP"]);
                            stats.Level = (int)(stats.XP / 1000) + 1;
                            stats.CO2Reduced = stats.XP * 0.002m;
                            stats.Rank = GetUserRank(currentUserId);
                            stats.Pickups = GetUserPickups(currentUserId);
                        }
                    }
                }

                // Get total stats
                stats.TotalUsers = GetTotalUsers();
                stats.TotalXP = GetTotalXP();
                stats.TotalPickups = GetTotalPickups();
                stats.TotalCO2Reduced = stats.TotalXP * 0.002m;

            }
            catch { }

            return stats;
        }

        private int GetUserRank(string userId)
        {
            try
            {
                string query = @"
                    SELECT COUNT(*) + 1 as Rank
                    FROM Users
                    WHERE ISNULL(XP_Credits, 0) > (SELECT ISNULL(XP_Credits, 0) FROM Users WHERE UserId = @UserId)
                    AND RoleId IN ('CITZ', 'R001')
                    AND IsVerified = 1";

                using (SqlConnection conn = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@UserId", userId);
                    conn.Open();
                    return Convert.ToInt32(cmd.ExecuteScalar());
                }
            }
            catch { return 1; }
        }

        private int GetTotalUsers()
        {
            try
            {
                string query = "SELECT COUNT(*) FROM Users WHERE RoleId IN ('CITZ', 'R001') AND IsVerified = 1";
                using (SqlConnection conn = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    conn.Open();
                    return Convert.ToInt32(cmd.ExecuteScalar());
                }
            }
            catch { return 0; }
        }

        private int GetTotalXP()
        {
            try
            {
                string query = "SELECT ISNULL(SUM(XP_Credits), 0) FROM Users WHERE RoleId IN ('CITZ', 'R001') AND IsVerified = 1";
                using (SqlConnection conn = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    conn.Open();
                    return Convert.ToInt32(cmd.ExecuteScalar());
                }
            }
            catch { return 0; }
        }

        private int GetTotalPickups()
        {
            try
            {
                string query = "SELECT ISNULL(COUNT(*), 0) FROM PickupRequests WHERE Status = 'Collected'";
                using (SqlConnection conn = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    conn.Open();
                    return Convert.ToInt32(cmd.ExecuteScalar());
                }
            }
            catch { return 0; }
        }

        private List<Achievement> GetAchievements()
        {
            var achievements = new List<Achievement>();

            // Add some sample achievements
            achievements.Add(new Achievement
            {
                Icon = "fa-recycle",
                IconBg = "#10b981",
                Title = "Most Waste Collected",
                Description = "Top contributor in waste collection",
                Winner = "ZAKI CABDIQADIR OMER"
            });

            achievements.Add(new Achievement
            {
                Icon = "fa-bolt",
                IconBg = "#f59e0b",
                Title = "Highest XP Earned",
                Description = "Earned the most XP points",
                Winner = "ZAKI CABDIQADIR OMER"
            });

            return achievements;
        }

        private void UpdateUI(UserStats stats)
        {
            // UI is updated via JavaScript
        }

        [WebMethod]
        public static string RefreshLeaderboardData()
        {
            return "{\"Success\":true}";
        }
    }

    public class LeaderboardUser
    {
        public string Id { get; set; }
        public string Name { get; set; }
        public string Location { get; set; }
        public int Rank { get; set; }
        public int XP { get; set; }
        public int Level { get; set; }
        public int Pickups { get; set; }
        public decimal CO2Reduced { get; set; }
        public bool IsCurrentUser { get; set; }
        public string Trend { get; set; }
        public DateTime MemberSince { get; set; }
    }

    public class UserStats
    {
        public string UserId { get; set; }
        public string Name { get; set; }
        public int Rank { get; set; }
        public int XP { get; set; }
        public int Level { get; set; }
        public int Pickups { get; set; }
        public decimal CO2Reduced { get; set; }
        public int TotalUsers { get; set; }
        public int TotalXP { get; set; }
        public int TotalPickups { get; set; }
        public decimal TotalCO2Reduced { get; set; }
    }

    public class Achievement
    {
        public string Icon { get; set; }
        public string IconBg { get; set; }
        public string Title { get; set; }
        public string Description { get; set; }
        public string Winner { get; set; }
    }
}