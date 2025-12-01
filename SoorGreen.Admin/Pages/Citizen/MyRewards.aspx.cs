using SoorGreen.Admin;
using System;
using System.Data;
using System.Data.SqlClient;
using System.Drawing;
using System.Security.Claims;
using System.Text;
using System.Web;
using System.Web.Configuration;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace SoorGreen.Citizen
{
    public partial class MyRewards : System.Web.UI.Page
    {
        private string connectionString = WebConfigurationManager.ConnectionStrings["SoorGreenDBConnectionString"].ConnectionString;
        private string currentTab = "rewards";

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

                LoadPageData();
            }
        }

        protected void btnTab_Click(object sender, EventArgs e)
        {
            Button btn = (Button)sender;
            currentTab = btn.CommandArgument;
            UpdateTabStates();
            LoadPageData();
        }

        protected void btnLoadMoreHistory_Click(object sender, EventArgs e)
        {
            LoadPageData();
            ShowMessage("Loaded more history entries", "success");
        }

        private void LoadPageData()
        {
            LoadUserStats();
            RenderRewardsGrid();
            RenderAchievementsGrid();
            RenderXPHistory();
        }

        private void LoadUserStats()
        {
            try
            {
                string query = @"
                    SELECT 
                        ISNULL(SUM(Amount), 0) as TotalXP,
                        ISNULL((
                            SELECT COUNT(*) 
                            FROM RedemptionRequests 
                            WHERE UserId = @UserId AND Status = 'Redeemed'
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
                    cmd.Parameters.AddWithValue("@UserId", Session["UserId"].ToString() ?? "R001");
                    conn.Open();

                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            int totalXP = reader.GetInt32(0);
                            int rewardsClaimed = reader.GetInt32(1);
                            int availableXP = reader.GetInt32(2);
                            int currentLevel = CalculateLevel(totalXP);
                            int xpToNextLevel = CalculateXPToNextLevel(totalXP, currentLevel);

                            var stats = new
                            {
                                TotalXP = totalXP,
                                CurrentLevel = currentLevel,
                                RewardsClaimed = rewardsClaimed,
                                XPToNextLevel = xpToNextLevel,
                                AvailableXP = availableXP
                            };

                            var serializer = new System.Web.Script.Serialization.JavaScriptSerializer();
                            hfUserStats.Value = serializer.Serialize(stats);
                        }
                        else
                        {
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

        private void RenderRewardsGrid()
        {
            try
            {
                string query = @"
                    SELECT 
                        RewardId,
                        Title,
                        Description,
                        XPCost,
                        StockQuantity,
                        IsFeatured,
                        IconClass
                    FROM Rewards 
                    WHERE IsActive = 1 
                    ORDER BY IsFeatured DESC, XPCost ASC";

                DataTable rewards = GetData(query);

                if (rewards.Rows.Count == 0)
                {
                    featuredRewardsGrid.InnerHtml = "<div class='empty-state'><div class='empty-state-title'>No featured rewards available</div></div>";
                    regularRewardsGrid.InnerHtml = "<div class='empty-state'><div class='empty-state-title'>No rewards available</div></div>";
                    return;
                }

                StringBuilder featuredHtml = new StringBuilder();
                StringBuilder regularHtml = new StringBuilder();

                foreach (DataRow reward in rewards.Rows)
                {
                    int rewardId = Convert.ToInt32(reward["RewardId"]);
                    string title = reward["Title"].ToString();
                    string description = reward["Description"].ToString();
                    int xpCost = Convert.ToInt32(reward["XPCost"]);
                    string stock = reward["StockQuantity"].ToString();
                    bool isFeatured = Convert.ToBoolean(reward["IsFeatured"]);
                    string icon = reward["IconClass"].ToString();

                    string rewardHtml = string.Format(@"
                        <div class='reward-card {0}'>
                            {1}
                            <div class='reward-image'>
                                <i class='fas {2}'></i>
                            </div>
                            <h3 class='reward-title'>{3}</h3>
                            <p class='reward-description'>{4}</p>
                            <div class='reward-meta'>
                                <div class='reward-xp'>
                                    <i class='fas fa-star'></i>
                                    <span>{5} XP</span>
                                </div>
                                <div class='reward-stock'>{6}</div>
                            </div>
                            <button type='button' class='btn-primary' onclick='claimReward({7}, {5}, ""{8}"")'>
                                <i class='fas fa-gift me-2'></i>Claim Reward
                            </button>
                        </div>",
                        isFeatured ? "featured" : "",
                        isFeatured ? "<div class='reward-badge'>Featured</div>" : "",
                        icon,
                        Server.HtmlEncode(title),
                        Server.HtmlEncode(description),
                        xpCost,
                        stock,
                        rewardId,
                        title.Replace("\"", "&quot;"));

                    if (isFeatured)
                    {
                        featuredHtml.Append(rewardHtml);
                    }
                    else
                    {
                        regularHtml.Append(rewardHtml);
                    }
                }

                featuredRewardsGrid.InnerHtml = featuredHtml.Length > 0 ? featuredHtml.ToString() : "<div class='empty-state'><div class='empty-state-title'>No featured rewards</div></div>";
                regularRewardsGrid.InnerHtml = regularHtml.Length > 0 ? regularHtml.ToString() : "<div class='empty-state'><div class='empty-state-title'>No rewards available</div></div>";
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error rendering rewards: " + ex.Message);
                featuredRewardsGrid.InnerHtml = "<div class='empty-state'><div class='empty-state-title'>Error loading rewards</div></div>";
                regularRewardsGrid.InnerHtml = "";
            }
        }

        private void RenderAchievementsGrid()
        {
            try
            {
                EnsureUserAchievements();

                string query = @"
                    SELECT 
                        ua.AchievementId,
                        a.Title,
                        a.Description,
                        a.XPReward,
                        a.IconClass,
                        ua.IsUnlocked,
                        ua.CurrentProgress,
                        a.TargetValue
                    FROM UserAchievements ua
                    INNER JOIN Achievements a ON ua.AchievementId = a.AchievementId
                    WHERE ua.UserId = @UserId
                    ORDER BY ua.IsUnlocked DESC, a.XPReward DESC";

                DataTable achievements = GetData(query, "@UserId", Session["UserId"].ToString() ?? "R001");

                if (achievements.Rows.Count == 0)
                {
                    achievementsGrid.InnerHtml = "<div class='empty-state'><div class='empty-state-title'>No achievements available</div></div>";
                    return;
                }

                StringBuilder html = new StringBuilder();

                foreach (DataRow achievement in achievements.Rows)
                {
                    string title = achievement["Title"].ToString();
                    string description = achievement["Description"].ToString();
                    int xpReward = Convert.ToInt32(achievement["XPReward"]);
                    string icon = achievement["IconClass"].ToString();
                    bool isUnlocked = Convert.ToBoolean(achievement["IsUnlocked"]);
                    int progress = Convert.ToInt32(achievement["CurrentProgress"]);
                    int target = Convert.ToInt32(achievement["TargetValue"]);

                    double progressPercent = target > 0 ? (progress / (double)target) * 100 : 0;

                    string progressHtml = "";
                    if (!isUnlocked && target > 1)
                    {
                        progressHtml = string.Format(@"
                                <div class='progress-bar'>
                                    <div class='progress-fill' style='width: {0}%'></div>
                                </div>
                                <div class='progress-text'>{1}/{2}</div>",
                            progressPercent,
                            progress,
                            target);
                    }

                    string achievementHtml = string.Format(@"
                        <div class='achievement-card {0}'>
                            <div class='achievement-icon'>
                                <i class='fas {1}'></i>
                            </div>
                            <h4 class='achievement-title'>{2}</h4>
                            <p class='achievement-description'>{3}</p>
                            {4}
                            <div class='achievement-xp'>+{5} XP</div>
                        </div>",
                        isUnlocked ? "unlocked" : "",
                        icon,
                        Server.HtmlEncode(title),
                        Server.HtmlEncode(description),
                        progressHtml,
                        xpReward);

                    html.Append(achievementHtml);
                }

                achievementsGrid.InnerHtml = html.ToString();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error rendering achievements: " + ex.Message);
                achievementsGrid.InnerHtml = "<div class='empty-state'><div class='empty-state-title'>Error loading achievements</div></div>";
            }
        }

        private void RenderXPHistory()
        {
            try
            {
                string query = @"
                    SELECT TOP 10
                        Description as Title,
                        FORMAT(CreatedAt, 'MMM dd, yyyy h:mm tt') as Date,
                        Amount as XP
                    FROM RewardPoints 
                    WHERE UserId = @UserId 
                    ORDER BY CreatedAt DESC";

                DataTable history = GetData(query, "@UserId", Session["UserId"].ToString() ?? "R001");

                if (history.Rows.Count == 0)
                {
                    xpHistoryList.InnerHtml = "<div class='empty-state'><div class='empty-state-title'>No transaction history</div></div>";
                    return;
                }

                StringBuilder html = new StringBuilder();

                foreach (DataRow transaction in history.Rows)
                {
                    string title = transaction["Title"].ToString();
                    string date = transaction["Date"].ToString();
                    int xp = Convert.ToInt32(transaction["XP"]);
                    bool isEarned = xp > 0;

                    string transactionHtml = string.Format(@"
                        <div class='transaction-item'>
                            <div class='transaction-info'>
                                <div class='transaction-title'>{0}</div>
                                <div class='transaction-date'>{1}</div>
                            </div>
                            <div class='transaction-xp {2}'>
                                {3}{4} XP
                            </div>
                        </div>",
                        Server.HtmlEncode(title),
                        date,
                        isEarned ? "" : "negative",
                        isEarned ? "+" : "-",
                        Math.Abs(xp));

                    html.Append(transactionHtml);
                }

                xpHistoryList.InnerHtml = html.ToString();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error rendering XP history: " + ex.Message);
                xpHistoryList.InnerHtml = "<div class='empty-state'><div class='empty-state-title'>Error loading history</div></div>";
            }
        }

        [System.Web.Services.WebMethod]
        public static string ClaimReward(int rewardId, int xpCost, string rewardName)
        {
            try
            {
                var page = HttpContext.Current.Handler as MyRewards;
                if (page != null)
                {
                    int availableXP = page.GetAvailableXP();

                    if (availableXP >= xpCost)
                    {
                        using (SqlConnection conn = new SqlConnection(page.connectionString))
                        {
                            conn.Open();

                            using (var transaction = conn.BeginTransaction())
                            {
                                try
                                {
                                    if (!page.IsRewardInStock(rewardId, conn, transaction))
                                    {
                                        return "ERROR:Sorry, this reward is out of stock.";
                                    }

                                    string userId = HttpContext.Current.Session["UserId"].ToString() ?? "R001";

                                    // Create redemption request
                                    string redemptionQuery = @"
                                        INSERT INTO RedemptionRequests (RedemptionId, UserId, Amount, Method, Status, RequestedAt)
                                        VALUES (@RedemptionId, @UserId, @Amount, 'Digital', 'Pending', GETDATE())";

                                    string redemptionId = "RR" + DateTime.Now.ToString("yyyyMMddHHmmss");

                                    using (SqlCommand cmd = new SqlCommand(redemptionQuery, conn, transaction))
                                    {
                                        cmd.Parameters.AddWithValue("@RedemptionId", redemptionId);
                                        cmd.Parameters.AddWithValue("@UserId", userId);
                                        cmd.Parameters.AddWithValue("@Amount", xpCost);
                                        cmd.ExecuteNonQuery();
                                    }

                                    // Update user XP
                                    string updateXPQuery = @"
                                        UPDATE Users 
                                        SET XP_Credits = XP_Credits - @Amount
                                        WHERE UserId = @UserId";

                                    using (SqlCommand cmd = new SqlCommand(updateXPQuery, conn, transaction))
                                    {
                                        cmd.Parameters.AddWithValue("@Amount", xpCost);
                                        cmd.Parameters.AddWithValue("@UserId", userId);
                                        cmd.ExecuteNonQuery();
                                    }

                                    // Add reward points record
                                    string rewardPointsQuery = @"
                                        INSERT INTO RewardPoints (RewardId, UserId, Amount, Type, Reference)
                                        VALUES (@RewardId, @UserId, @Amount, 'Redemption', @Reference)";

                                    using (SqlCommand cmd = new SqlCommand(rewardPointsQuery, conn, transaction))
                                    {
                                        string newRewardId = "RP" + DateTime.Now.ToString("yyyyMMddHHmmss");
                                        cmd.Parameters.AddWithValue("@RewardId", newRewardId);
                                        cmd.Parameters.AddWithValue("@UserId", userId);
                                        cmd.Parameters.AddWithValue("@Amount", -xpCost);
                                        cmd.Parameters.AddWithValue("@Reference", "Claimed reward: " + rewardName);
                                        cmd.ExecuteNonQuery();
                                    }

                                    // Update reward stock
                                    page.UpdateRewardStock(rewardId, conn, transaction);

                                    transaction.Commit();

                                    return "SUCCESS:Successfully claimed " + rewardName + "!";
                                }
                                catch (Exception ex)
                                {
                                    transaction.Rollback();
                                    return "ERROR:Error claiming reward: " + ex.Message;
                                }
                            }
                        }
                    }
                    else
                    {
                        int neededXP = xpCost - availableXP;
                        return "ERROR:Not enough XP to claim " + rewardName + ". You need " + neededXP + " more XP.";
                    }
                }
                return "ERROR:Page context not available.";
            }
            catch (Exception ex)
            {
                return "ERROR:Error claiming reward: " + ex.Message;
            }
        }

        private bool IsRewardInStock(int rewardId, SqlConnection conn, SqlTransaction transaction)
        {
            string query = "SELECT StockQuantity FROM Rewards WHERE RewardId = @RewardId";
            using (SqlCommand cmd = new SqlCommand(query, conn, transaction))
            {
                cmd.Parameters.AddWithValue("@RewardId", rewardId);
                var result = cmd.ExecuteScalar();

                if (result == DBNull.Value || result == null)
                    return true;

                string stock = result.ToString();
                if (stock.ToLower() == "unlimited" || stock.ToLower() == "monthly")
                    return true;

                int remaining;
                if (int.TryParse(stock.Split(' ')[0], out remaining) && remaining > 0)
                    return true;

                return false;
            }
        }

        private void UpdateRewardStock(int rewardId, SqlConnection conn, SqlTransaction transaction)
        {
            string query = "SELECT StockQuantity FROM Rewards WHERE RewardId = @RewardId";
            using (SqlCommand cmd = new SqlCommand(query, conn, transaction))
            {
                cmd.Parameters.AddWithValue("@RewardId", rewardId);
                var result = cmd.ExecuteScalar();

                if (result != DBNull.Value && result != null)
                {
                    string stock = result.ToString();
                    int remaining;
                    if (int.TryParse(stock.Split(' ')[0], out remaining) && remaining > 0)
                    {
                        string updateQuery = @"
                            UPDATE Rewards 
                            SET StockQuantity = @NewStock 
                            WHERE RewardId = @RewardId";

                        using (SqlCommand updateCmd = new SqlCommand(updateQuery, conn, transaction))
                        {
                            updateCmd.Parameters.AddWithValue("@RewardId", rewardId);
                            updateCmd.Parameters.AddWithValue("@NewStock", (remaining - 1) + " left");
                            updateCmd.ExecuteNonQuery();
                        }
                    }
                }
            }
        }

        private int GetAvailableXP()
        {
            try
            {
                string query = "SELECT ISNULL(XP_Credits, 0) FROM Users WHERE UserId = @UserId";
                using (SqlConnection conn = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@UserId", Session["UserId"].ToString() ?? "R001");
                    conn.Open();
                    var result = cmd.ExecuteScalar();
                    return result != DBNull.Value ? Convert.ToInt32(result) : 0;
                }
            }
            catch
            {
                return 0;
            }
        }

        private void EnsureUserAchievements()
        {
            try
            {
                string checkQuery = @"
                    IF NOT EXISTS (SELECT 1 FROM UserAchievements WHERE UserId = @UserId)
                    BEGIN
                        INSERT INTO UserAchievements (UserId, AchievementId, IsUnlocked, CurrentProgress)
                        SELECT @UserId, AchievementId, 0, 0 
                        FROM Achievements
                    END";

                using (SqlConnection conn = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand(checkQuery, conn))
                {
                    cmd.Parameters.AddWithValue("@UserId", Session["UserId"].ToString() ?? "R001");
                    conn.Open();
                    cmd.ExecuteNonQuery();
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error ensuring user achievements: " + ex.Message);
            }
        }

        private void UpdateTabStates()
        {
            btnTabRewards.CssClass = "tab" + (currentTab == "rewards" ? " active" : "");
            btnTabAchievements.CssClass = "tab" + (currentTab == "achievements" ? " active" : "");
            btnTabHistory.CssClass = "tab" + (currentTab == "history" ? " active" : "");

            rewardsTab.Attributes["class"] = "tab-content" + (currentTab == "rewards" ? " active" : "");
            achievementsTab.Attributes["class"] = "tab-content" + (currentTab == "achievements" ? " active" : "");
            historyTab.Attributes["class"] = "tab-content" + (currentTab == "history" ? " active" : "");
        }

        private void ShowMessage(string message, string type)
        {
            string script = string.Format("showNotification('{0}', '{1}');", message.Replace("'", "\\'"), type);
            ClientScript.RegisterStartupScript(this.GetType(), "ShowMessage", script, true);
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
            var serializer = new System.Web.Script.Serialization.JavaScriptSerializer();
            hfUserStats.Value = serializer.Serialize(emptyStats);
        }

        // Helper methods
        private DataTable GetData(string query, params object[] parameters)
        {
            DataTable dt = new DataTable();
            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();
                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        for (int i = 0; i < parameters.Length; i += 2)
                        {
                            if (i + 1 < parameters.Length)
                            {
                                cmd.Parameters.AddWithValue(parameters[i].ToString(), parameters[i + 1]);
                            }
                        }

                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            dt.Load(reader);
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Database error: " + ex.Message);
            }
            return dt;
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