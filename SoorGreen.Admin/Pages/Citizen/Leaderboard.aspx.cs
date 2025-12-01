using System;
using System.Data;
using System.Data.SqlClient;
using System.Collections.Generic;
using System.Web.Configuration;
using System.Web.UI;
using System.Web.Script.Serialization;

namespace SoorGreen.Citizen
{
    public partial class Leaderboard : System.Web.UI.Page
    {
        private string connectionString = WebConfigurationManager.ConnectionStrings["SoorGreenDBConnectionString"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // Authentication check
                if (Session["UserId"] == null || Session["UserRole"] == null)
                {
                    Response.Redirect("~/Login.aspx");
                    return;
                }

                if (Session["UserRole"].ToString() != "CITZ" && Session["UserRole"].ToString() != "R001")
                {
                    Response.Redirect("~/Pages/Unauthorized.aspx");
                    return;
                }

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
                string tabFilter = Request.Form["tabFilter"] ?? "global";
                string periodFilter = Request.Form["periodFilter"] ?? "all";

                // Store current filters
                hfCurrentTab.Value = tabFilter;
                hfCurrentPeriod.Value = periodFilter;

                // Load leaderboard data based on filters
                List<LeaderboardUser> leaderboardData;

                switch (tabFilter)
                {
                    case "monthly":
                        leaderboardData = LoadMonthlyLeaderboardData(periodFilter);
                        break;
                    case "achievements":
                        leaderboardData = LoadAchievementsLeaderboardData(periodFilter);
                        break;
                    case "friends":
                        leaderboardData = LoadFriendsLeaderboardData(periodFilter);
                        break;
                    default: // global
                        leaderboardData = LoadGlobalLeaderboardData(periodFilter);
                        break;
                }

                var serializer = new JavaScriptSerializer();
                hfLeaderboardData.Value = serializer.Serialize(leaderboardData);

                // Load statistics
                var stats = new
                {
                    TotalUsers = GetTotalUsers(),
                    TotalXP = GetTotalXP(),
                    TotalPickups = GetTotalPickups(),
                    TotalCO2Reduced = GetTotalCO2Reduced()
                };

                hfStatsData.Value = serializer.Serialize(stats);

            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error in LoadData: " + ex.Message);
                hfLeaderboardData.Value = "[]";
                hfStatsData.Value = "{\"TotalUsers\":0,\"TotalXP\":0,\"TotalPickups\":0,\"TotalCO2Reduced\":0}";
            }
        }

        private List<LeaderboardUser> LoadGlobalLeaderboardData(string periodFilter)
        {
            var leaderboardData = new List<LeaderboardUser>();
            string currentUserId = Session["UserId"] != null ? Session["UserId"].ToString() : "R001";

            string query = @"
                WITH UserStats AS (
                    SELECT 
                        u.UserId,
                        u.FirstName,
                        u.LastName,
                        u.Email,
                        ISNULL(u.XP_Credits, 0) as TotalXP,
                        ISNULL((
                            SELECT COUNT(*) 
                            FROM PickupRequests 
                            WHERE UserId = u.UserId AND Status = 'Completed'
                        ), 0) as TotalPickups,
                        ISNULL((
                            SELECT COUNT(*) 
                            FROM UserAchievements ua 
                            WHERE ua.UserId = u.UserId AND ua.IsUnlocked = 1
                        ), 0) as AchievementsCount,
                        CASE 
                            WHEN ISNULL(u.XP_Credits, 0) >= 1000 THEN 3
                            WHEN ISNULL(u.XP_Credits, 0) >= 500 THEN 2
                            ELSE 1
                        END as UserLevel,
                        (ISNULL(u.XP_Credits, 0) * 0.002) as CO2Reduced
                    FROM Users u
                    WHERE u.Role IN ('CITZ', 'R001')
                    AND u.Status = 'Active'
                ),
                RankedUsers AS (
                    SELECT *,
                        ROW_NUMBER() OVER (ORDER BY TotalXP DESC) as UserRank
                    FROM UserStats
                )
                SELECT TOP 20
                    UserId,
                    FirstName,
                    LastName,
                    Email,
                    TotalXP,
                    TotalPickups,
                    AchievementsCount,
                    UserLevel,
                    CO2Reduced,
                    UserRank
                FROM RankedUsers
                ORDER BY UserRank";

            using (SqlConnection conn = new SqlConnection(connectionString))
            using (SqlCommand cmd = new SqlCommand(query, conn))
            {
                conn.Open();
                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        string userId = reader["UserId"] != null ? reader["UserId"].ToString() : "";
                        string firstName = reader["FirstName"] != null ? reader["FirstName"].ToString() : "";
                        string lastName = reader["LastName"] != null ? reader["LastName"].ToString() : "";
                        string email = reader["Email"] != null ? reader["Email"].ToString() : "";

                        var user = new LeaderboardUser
                        {
                            Id = userId,
                            Name = GetUserName(firstName, lastName, email),
                            Email = email,
                            Rank = reader["UserRank"] != DBNull.Value ? Convert.ToInt32(reader["UserRank"]) : 0,
                            XP = reader["TotalXP"] != DBNull.Value ? Convert.ToInt32(reader["TotalXP"]) : 0,
                            Level = reader["UserLevel"] != DBNull.Value ? Convert.ToInt32(reader["UserLevel"]) : 1,
                            Pickups = reader["TotalPickups"] != DBNull.Value ? Convert.ToInt32(reader["TotalPickups"]) : 0,
                            Achievements = reader["AchievementsCount"] != DBNull.Value ? Convert.ToInt32(reader["AchievementsCount"]) : 0,
                            CO2Reduced = reader["CO2Reduced"] != DBNull.Value ? Convert.ToDecimal(reader["CO2Reduced"]) : 0,
                            IsCurrentUser = userId == currentUserId,
                            Avatar = GetUserInitials(firstName, lastName, email)
                        };

                        leaderboardData.Add(user);
                    }
                }
            }

            return leaderboardData;
        }

        private List<LeaderboardUser> LoadMonthlyLeaderboardData(string periodFilter)
        {
            var leaderboardData = new List<LeaderboardUser>();
            string currentUserId = Session["UserId"] != null ? Session["UserId"].ToString() : "R001";

            string query = @"
                WITH MonthlyStats AS (
                    SELECT 
                        u.UserId,
                        u.FirstName,
                        u.LastName,
                        u.Email,
                        ISNULL((
                            SELECT SUM(Amount) 
                            FROM RewardPoints 
                            WHERE UserId = u.UserId 
                            AND CreatedAt >= DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()), 0)
                        ), 0) as MonthlyXP,
                        ISNULL((
                            SELECT COUNT(*) 
                            FROM PickupRequests 
                            WHERE UserId = u.UserId 
                            AND Status = 'Completed'
                            AND RequestedAt >= DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()), 0)
                        ), 0) as MonthlyPickups,
                        CASE 
                            WHEN ISNULL(u.XP_Credits, 0) >= 1000 THEN 3
                            WHEN ISNULL(u.XP_Credits, 0) >= 500 THEN 2
                            ELSE 1
                        END as UserLevel,
                        (ISNULL(u.XP_Credits, 0) * 0.002) as CO2Reduced,
                        ISNULL((
                            SELECT COUNT(*) 
                            FROM UserAchievements ua 
                            WHERE ua.UserId = u.UserId AND ua.IsUnlocked = 1
                        ), 0) as AchievementsCount
                    FROM Users u
                    WHERE u.Role IN ('CITZ', 'R001')
                    AND u.Status = 'Active'
                ),
                RankedUsers AS (
                    SELECT *,
                        ROW_NUMBER() OVER (ORDER BY MonthlyXP DESC) as UserRank
                    FROM MonthlyStats
                    WHERE MonthlyXP > 0
                )
                SELECT TOP 20
                    UserId,
                    FirstName,
                    LastName,
                    Email,
                    MonthlyXP as TotalXP,
                    MonthlyPickups as TotalPickups,
                    AchievementsCount,
                    UserLevel,
                    CO2Reduced,
                    UserRank
                FROM RankedUsers
                ORDER BY UserRank";

            using (SqlConnection conn = new SqlConnection(connectionString))
            using (SqlCommand cmd = new SqlCommand(query, conn))
            {
                conn.Open();
                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        string userId = reader["UserId"] != null ? reader["UserId"].ToString() : "";
                        string firstName = reader["FirstName"] != null ? reader["FirstName"].ToString() : "";
                        string lastName = reader["LastName"] != null ? reader["LastName"].ToString() : "";
                        string email = reader["Email"] != null ? reader["Email"].ToString() : "";

                        var user = new LeaderboardUser
                        {
                            Id = userId,
                            Name = GetUserName(firstName, lastName, email),
                            Email = email,
                            Rank = reader["UserRank"] != DBNull.Value ? Convert.ToInt32(reader["UserRank"]) : 0,
                            XP = reader["TotalXP"] != DBNull.Value ? Convert.ToInt32(reader["TotalXP"]) : 0,
                            Level = reader["UserLevel"] != DBNull.Value ? Convert.ToInt32(reader["UserLevel"]) : 1,
                            Pickups = reader["TotalPickups"] != DBNull.Value ? Convert.ToInt32(reader["TotalPickups"]) : 0,
                            Achievements = reader["AchievementsCount"] != DBNull.Value ? Convert.ToInt32(reader["AchievementsCount"]) : 0,
                            CO2Reduced = reader["CO2Reduced"] != DBNull.Value ? Convert.ToDecimal(reader["CO2Reduced"]) : 0,
                            IsCurrentUser = userId == currentUserId,
                            Avatar = GetUserInitials(firstName, lastName, email)
                        };

                        leaderboardData.Add(user);
                    }
                }
            }

            return leaderboardData;
        }

        private List<LeaderboardUser> LoadAchievementsLeaderboardData(string periodFilter)
        {
            var leaderboardData = new List<LeaderboardUser>();
            string currentUserId = Session["UserId"] != null ? Session["UserId"].ToString() : "R001";

            string query = @"
                WITH UserAchievementStats AS (
                    SELECT 
                        u.UserId,
                        u.FirstName,
                        u.LastName,
                        u.Email,
                        ISNULL((
                            SELECT COUNT(*) 
                            FROM UserAchievements ua 
                            WHERE ua.UserId = u.UserId AND ua.IsUnlocked = 1
                        ), 0) as AchievementsCount,
                        ISNULL(u.XP_Credits, 0) as TotalXP,
                        ISNULL((
                            SELECT COUNT(*) 
                            FROM PickupRequests 
                            WHERE UserId = u.UserId AND Status = 'Completed'
                        ), 0) as TotalPickups,
                        CASE 
                            WHEN ISNULL(u.XP_Credits, 0) >= 1000 THEN 3
                            WHEN ISNULL(u.XP_Credits, 0) >= 500 THEN 2
                            ELSE 1
                        END as UserLevel,
                        (ISNULL(u.XP_Credits, 0) * 0.002) as CO2Reduced
                    FROM Users u
                    WHERE u.Role IN ('CITZ', 'R001')
                    AND u.Status = 'Active'
                    AND EXISTS (SELECT 1 FROM UserAchievements ua WHERE ua.UserId = u.UserId AND ua.IsUnlocked = 1)
                ),
                RankedUsers AS (
                    SELECT *,
                        ROW_NUMBER() OVER (ORDER BY AchievementsCount DESC, TotalXP DESC) as UserRank
                    FROM UserAchievementStats
                )
                SELECT TOP 20
                    UserId,
                    FirstName,
                    LastName,
                    Email,
                    TotalXP,
                    TotalPickups,
                    AchievementsCount,
                    UserLevel,
                    CO2Reduced,
                    UserRank
                FROM RankedUsers
                ORDER BY UserRank";

            using (SqlConnection conn = new SqlConnection(connectionString))
            using (SqlCommand cmd = new SqlCommand(query, conn))
            {
                conn.Open();
                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        string userId = reader["UserId"] != null ? reader["UserId"].ToString() : "";
                        string firstName = reader["FirstName"] != null ? reader["FirstName"].ToString() : "";
                        string lastName = reader["LastName"] != null ? reader["LastName"].ToString() : "";
                        string email = reader["Email"] != null ? reader["Email"].ToString() : "";

                        var user = new LeaderboardUser
                        {
                            Id = userId,
                            Name = GetUserName(firstName, lastName, email),
                            Email = email,
                            Rank = reader["UserRank"] != DBNull.Value ? Convert.ToInt32(reader["UserRank"]) : 0,
                            XP = reader["TotalXP"] != DBNull.Value ? Convert.ToInt32(reader["TotalXP"]) : 0,
                            Level = reader["UserLevel"] != DBNull.Value ? Convert.ToInt32(reader["UserLevel"]) : 1,
                            Pickups = reader["TotalPickups"] != DBNull.Value ? Convert.ToInt32(reader["TotalPickups"]) : 0,
                            Achievements = reader["AchievementsCount"] != DBNull.Value ? Convert.ToInt32(reader["AchievementsCount"]) : 0,
                            CO2Reduced = reader["CO2Reduced"] != DBNull.Value ? Convert.ToDecimal(reader["CO2Reduced"]) : 0,
                            IsCurrentUser = userId == currentUserId,
                            Avatar = GetUserInitials(firstName, lastName, email)
                        };

                        leaderboardData.Add(user);
                    }
                }
            }

            return leaderboardData;
        }

        private List<LeaderboardUser> LoadFriendsLeaderboardData(string periodFilter)
        {
            // For now, return empty list as friend system might not be implemented
            // This can be extended when friend functionality is added
            return new List<LeaderboardUser>();
        }

        private int GetTotalUsers()
        {
            try
            {
                string query = "SELECT ISNULL(COUNT(*), 0) FROM Users WHERE Role IN ('CITZ', 'R001') AND Status = 'Active'";
                return GetScalarValue(query);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error getting total users: " + ex.Message);
                return 0;
            }
        }

        private int GetTotalXP()
        {
            try
            {
                string query = "SELECT ISNULL(SUM(XP_Credits), 0) FROM Users WHERE Role IN ('CITZ', 'R001') AND Status = 'Active'";
                return GetScalarValue(query);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error getting total XP: " + ex.Message);
                return 0;
            }
        }

        private int GetTotalPickups()
        {
            try
            {
                string query = "SELECT ISNULL(COUNT(*), 0) FROM PickupRequests WHERE Status = 'Completed'";
                return GetScalarValue(query);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error getting total pickups: " + ex.Message);
                return 0;
            }
        }

        private decimal GetTotalCO2Reduced()
        {
            try
            {
                string query = "SELECT ISNULL(SUM(XP_Credits) * 0.002, 0) FROM Users WHERE Role IN ('CITZ', 'R001') AND Status = 'Active'";
                using (SqlConnection conn = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    conn.Open();
                    var result = cmd.ExecuteScalar();
                    return result != DBNull.Value ? Convert.ToDecimal(result) : 0;
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error getting total CO2 reduced: " + ex.Message);
                return 0;
            }
        }

        private int GetScalarValue(string query)
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    conn.Open();
                    var result = cmd.ExecuteScalar();
                    return result != DBNull.Value ? Convert.ToInt32(result) : 0;
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Scalar error: " + ex.Message);
                return 0;
            }
        }

        private string GetUserName(string firstName, string lastName, string email)
        {
            if (!string.IsNullOrEmpty(firstName) && !string.IsNullOrEmpty(lastName))
            {
                return firstName + " " + lastName;
            }
            else if (!string.IsNullOrEmpty(firstName))
            {
                return firstName;
            }
            else if (!string.IsNullOrEmpty(lastName))
            {
                return lastName;
            }
            else if (!string.IsNullOrEmpty(email))
            {
                return email;
            }
            return "Anonymous User";
        }

        private string GetUserInitials(string firstName, string lastName, string email)
        {
            if (!string.IsNullOrEmpty(firstName) && !string.IsNullOrEmpty(lastName))
            {
                return firstName.Substring(0, 1).ToUpper() + lastName.Substring(0, 1).ToUpper();
            }
            else if (!string.IsNullOrEmpty(firstName))
            {
                return firstName.Length >= 2 ? firstName.Substring(0, 2).ToUpper() : firstName.ToUpper();
            }
            else if (!string.IsNullOrEmpty(lastName))
            {
                return lastName.Length >= 2 ? lastName.Substring(0, 2).ToUpper() : lastName.ToUpper();
            }
            else if (!string.IsNullOrEmpty(email))
            {
                return email.Substring(0, 2).ToUpper();
            }
            return "US";
        }
    }

    public class LeaderboardUser
    {
        public string Id { get; set; }
        public string Name { get; set; }
        public string Email { get; set; }
        public int Rank { get; set; }
        public int XP { get; set; }
        public int Level { get; set; }
        public int Pickups { get; set; }
        public int Achievements { get; set; }
        public decimal CO2Reduced { get; set; }
        public bool IsCurrentUser { get; set; }
        public string Avatar { get; set; }
    }
}