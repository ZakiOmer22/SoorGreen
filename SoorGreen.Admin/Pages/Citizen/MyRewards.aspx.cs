using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.Configuration;
using System.Web.UI;
using System.Web.Script.Serialization;
using System.Collections.Generic;
using System.Web.Services;

namespace SoorGreen.Citizen
{
    public partial class MyRewards : System.Web.UI.Page
    {
        private string connectionString = WebConfigurationManager.ConnectionStrings["SoorGreenDBConnectionString"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // Authentication check
                if (Session["UserID"] == null)
                {
                    Response.Redirect("~/Login.aspx");
                    return;
                }

                // Store userId in hidden field for JavaScript
                hfUserId.Value = Session["UserID"].ToString();

                // Debug log
                System.Diagnostics.Debug.WriteLine("=== MYREWARDS PAGE LOAD ===");
                System.Diagnostics.Debug.WriteLine("UserID: " + Session["UserID"]);

                // Load all data into hidden fields
                LoadUserStats();
                LoadRewardSummary(); // Changed from LoadRewardsData
                LoadXPHistory();

                System.Diagnostics.Debug.WriteLine("=== DATA LOADED ===");
            }
        }

        private void LoadUserStats()
        {
            try
            {
                string userId = Session["UserID"].ToString();
                System.Diagnostics.Debug.WriteLine("Loading user stats for user: " + userId);

                string query = @"
                    SELECT 
                        ISNULL(SUM(CASE WHEN Type = 'Earned' THEN Amount ELSE 0 END), 0) as TotalXP,
                        ISNULL(SUM(CASE WHEN Type = 'Redeemed' THEN Amount ELSE 0 END), 0) as TotalRedeemed,
                        ISNULL((
                            SELECT COUNT(*) 
                            FROM RedemptionRequests 
                            WHERE UserId = @UserId AND Status = 'Completed'
                        ), 0) as RewardsClaimed,
                        ISNULL((
                            SELECT XP_Credits 
                            FROM Users 
                            WHERE UserId = @UserId
                        ), 0) as AvailableXP
                    FROM RewardPoints 
                    WHERE UserId = @UserId";

                using (SqlConnection conn = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@UserId", userId);
                    conn.Open();

                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            int totalXP = Convert.ToInt32(reader["TotalXP"]);
                            int totalRedeemed = Convert.ToInt32(reader["TotalRedeemed"]);
                            int rewardsClaimed = Convert.ToInt32(reader["RewardsClaimed"]);
                            int availableXP = Convert.ToInt32(reader["AvailableXP"]);

                            // Calculate current level based on earned XP (not including redeemed)
                            int earnedXP = totalXP - totalRedeemed;
                            int currentLevel = CalculateLevel(earnedXP);
                            int xpToNextLevel = CalculateXPToNextLevel(earnedXP, currentLevel);

                            var stats = new
                            {
                                TotalXP = totalXP,
                                CurrentLevel = currentLevel,
                                RewardsClaimed = rewardsClaimed,
                                XPToNextLevel = xpToNextLevel,
                                AvailableXP = availableXP
                            };

                            // Store in hidden field
                            hfUserStats.Value = new JavaScriptSerializer().Serialize(stats);
                            System.Diagnostics.Debug.WriteLine("User stats loaded: " + hfUserStats.Value);
                        }
                        else
                        {
                            System.Diagnostics.Debug.WriteLine("No user stats found - showing default");
                            SetEmptyUserStats();
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error loading user stats: " + ex.Message);
                SetEmptyUserStats();
            }
        }

        private void LoadRewardSummary()
        {
            try
            {
                string userId = Session["UserID"].ToString();
                System.Diagnostics.Debug.WriteLine("Loading reward summary for user: " + userId);

                // Since you don't have Rewards table, we'll use RedemptionRequests as "rewards claimed"
                string query = @"
                    SELECT 
                        RedemptionId as RewardId,
                        'Reward Redemption' as Title,
                        'You claimed ' + CAST(Amount AS VARCHAR) + ' XP' as Description,
                        Amount as XPCost,
                        'Claimed' as Status,
                        'fa-gift' as IconClass,
                        RequestedAt as Date,
                        Status as RewardStatus
                    FROM RedemptionRequests 
                    WHERE UserId = @UserId 
                    AND Status IN ('Completed', 'Pending')
                    ORDER BY RequestedAt DESC";

                using (SqlConnection conn = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@UserId", userId);
                    conn.Open();
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        var rewards = new List<object>();
                        while (reader.Read())
                        {
                            rewards.Add(new
                            {
                                RewardId = reader["RewardId"].ToString(),
                                Title = reader["Title"].ToString(),
                                Description = reader["Description"].ToString(),
                                XPCost = Convert.ToInt32(reader["XPCost"]),
                                Status = reader["Status"].ToString(),
                                IconClass = reader["IconClass"].ToString(),
                                Date = Convert.ToDateTime(reader["Date"]).ToString("MMM dd, yyyy"),
                                RewardStatus = reader["RewardStatus"].ToString()
                            });
                        }

                        // Store in hidden field
                        string rewardsJson = new JavaScriptSerializer().Serialize(rewards);
                        hfRewardsData.Value = rewardsJson;

                        System.Diagnostics.Debug.WriteLine("Loaded " + rewards.Count + " reward redemptions");
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error loading reward summary: " + ex.Message);
                // Set empty array
                hfRewardsData.Value = "[]";
            }
        }

        private void LoadXPHistory()
        {
            try
            {
                string userId = Session["UserID"].ToString();
                System.Diagnostics.Debug.WriteLine("Loading XP history for user: " + userId);

                string query = @"
                    SELECT TOP 20
                        Description as Title,
                        FORMAT(CreatedAt, 'MMM dd, yyyy h:mm tt') as Date,
                        Amount as XP,
                        Type
                    FROM RewardPoints 
                    WHERE UserId = @UserId 
                    ORDER BY CreatedAt DESC";

                using (SqlConnection conn = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@UserId", userId);
                    conn.Open();
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        var history = new List<object>();
                        while (reader.Read())
                        {
                            history.Add(new
                            {
                                Title = reader["Title"].ToString(),
                                Date = reader["Date"].ToString(),
                                XP = Convert.ToInt32(reader["XP"]),
                                Type = reader["Type"].ToString()
                            });
                        }

                        // Store in hidden field
                        string historyJson = new JavaScriptSerializer().Serialize(history);
                        hfXPHistoryData.Value = historyJson;

                        System.Diagnostics.Debug.WriteLine("Loaded " + history.Count + " history items");
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error loading XP history: " + ex.Message);
                // Set empty array
                hfXPHistoryData.Value = "[]";
            }
        }

        [WebMethod]
        public static string ClaimReward(string rewardId, string userId, string rewardTitle, int xpCost)
        {
            try
            {
                var connectionString = WebConfigurationManager.ConnectionStrings["SoorGreenDBConnectionString"].ConnectionString;

                // Since you don't have Rewards table, we'll create a redemption request directly
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    using (var transaction = conn.BeginTransaction())
                    {
                        try
                        {
                            // Check user's available XP
                            string xpQuery = "SELECT XP_Credits FROM Users WHERE UserId = @UserId";
                            int availableXP = 0;
                            using (SqlCommand xpCmd = new SqlCommand(xpQuery, conn, transaction))
                            {
                                xpCmd.Parameters.AddWithValue("@UserId", userId);
                                var xpResult = xpCmd.ExecuteScalar();
                                availableXP = xpResult != DBNull.Value ? Convert.ToInt32(xpResult) : 0;
                            }

                            if (availableXP < xpCost)
                            {
                                transaction.Rollback();
                                return "ERROR:Not enough XP. You need " + (xpCost - availableXP) + " more XP.";
                            }

                            // Generate redemption ID
                            string redemptionId = "RR" + DateTime.Now.ToString("yyyyMMddHHmmss");

                            // Create redemption request
                            string redemptionQuery = @"
                                INSERT INTO RedemptionRequests (RedemptionId, UserId, Amount, Method, Status, RequestedAt)
                                VALUES (@RedemptionId, @UserId, @Amount, 'Digital', 'Pending', GETDATE())";

                            using (SqlCommand redemptionCmd = new SqlCommand(redemptionQuery, conn, transaction))
                            {
                                redemptionCmd.Parameters.AddWithValue("@RedemptionId", redemptionId);
                                redemptionCmd.Parameters.AddWithValue("@UserId", userId);
                                redemptionCmd.Parameters.AddWithValue("@Amount", xpCost);
                                redemptionCmd.ExecuteNonQuery();
                            }

                            // Update user XP
                            string updateXPQuery = @"
                                UPDATE Users 
                                SET XP_Credits = XP_Credits - @Amount
                                WHERE UserId = @UserId";

                            using (SqlCommand updateXPCmd = new SqlCommand(updateXPQuery, conn, transaction))
                            {
                                updateXPCmd.Parameters.AddWithValue("@Amount", xpCost);
                                updateXPCmd.Parameters.AddWithValue("@UserId", userId);
                                updateXPCmd.ExecuteNonQuery();
                            }

                            // Add reward points record (negative for redemption)
                            string rewardPointsId = "RP" + DateTime.Now.ToString("yyyyMMddHHmmss");
                            string rewardPointsQuery = @"
                                INSERT INTO RewardPoints (RewardId, UserId, Amount, Type, Description, CreatedAt)
                                VALUES (@RewardId, @UserId, @Amount, 'Redeemed', @Description, GETDATE())";

                            using (SqlCommand pointsCmd = new SqlCommand(rewardPointsQuery, conn, transaction))
                            {
                                pointsCmd.Parameters.AddWithValue("@RewardId", rewardPointsId);
                                pointsCmd.Parameters.AddWithValue("@UserId", userId);
                                pointsCmd.Parameters.AddWithValue("@Amount", -xpCost);
                                pointsCmd.Parameters.AddWithValue("@Description", "Claimed reward: " + rewardTitle);
                                pointsCmd.ExecuteNonQuery();
                            }

                            transaction.Commit();
                            return "SUCCESS:Successfully claimed " + rewardTitle + "! Your reward request is pending approval.";
                        }
                        catch (Exception ex)
                        {
                            transaction.Rollback();
                            return "ERROR:Error claiming reward: " + ex.Message;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                return "ERROR:Error claiming reward: " + ex.Message;
            }
        }

        private void SetEmptyUserStats()
        {
            var emptyStats = new
            {
                TotalXP = 0,
                CurrentLevel = 1,
                RewardsClaimed = 0,
                XPToNextLevel = 100,
                AvailableXP = 0
            };
            hfUserStats.Value = new JavaScriptSerializer().Serialize(emptyStats);
        }

        private int CalculateLevel(int totalXP)
        {
            if (totalXP >= 1000) return 3;
            if (totalXP >= 500) return 2;
            return 1;
        }

        private int CalculateXPToNextLevel(int totalXP, int currentLevel)
        {
            switch (currentLevel)
            {
                case 1: return Math.Max(500 - totalXP, 0);
                case 2: return Math.Max(1000 - totalXP, 0);
                case 3: return Math.Max(1500 - totalXP, 0);
                default: return 100;
            }
        }
    }
}