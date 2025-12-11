using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Collections.Generic;

namespace SoorGreen.Admin
{
    public class Achievement
    {
        public string IconClass { get; set; }
        public string Title { get; set; }
        public string Description { get; set; }
        public int Progress { get; set; }
        public int Target { get; set; }
        public bool IsUnlocked { get; set; }
    }

    public partial class Leaderboard : System.Web.UI.Page
    {
        private string currentUserId;
        private string connectionString = System.Configuration.ConfigurationManager.ConnectionStrings["SoorGreenDBConnectionString"].ConnectionString;

        // Pagination variables
        private int currentPage = 1;
        private int pageSize = 20;
        private int totalItems = 0;

        // Filter variables
        private string category = "points";
        private string searchQuery = "";

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

                // Load initial data
                LoadCurrentUserStats();
                LoadTopWinners();
                LoadLeaderboard();
                LoadAchievements();

                // Set active timeframe
                btnWeekly.CssClass = "timeframe-badge active";
            }
            else
            {
                // Restore values from session
                if (Session["UserId"] != null)
                {
                    currentUserId = Session["UserId"].ToString();
                }

                if (Session["CurrentPage"] != null)
                {
                    currentPage = (int)Session["CurrentPage"];
                }
            }
        }

        private void LoadCurrentUserStats()
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    // SIMPLIFIED QUERY - Just get basic user info first
                    string userQuery = @"
                        SELECT 
                            UserId,
                            FullName,
                            Phone,
                            Email,
                            XP_Credits as TotalPoints
                        FROM Users 
                        WHERE UserId = @UserId";

                    using (SqlCommand cmd = new SqlCommand(userQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@UserId", currentUserId);

                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                // Get references to controls
                                HtmlGenericControl userNameControl = (HtmlGenericControl)FindControl("userName");
                                HtmlGenericControl userRoleControl = (HtmlGenericControl)FindControl("userRole");
                                HtmlGenericControl userTotalPointsControl = (HtmlGenericControl)FindControl("userTotalPoints");
                                HtmlGenericControl userPickupsCompletedControl = (HtmlGenericControl)FindControl("userPickupsCompleted");
                                HtmlGenericControl userCO2SavedControl = (HtmlGenericControl)FindControl("userCO2Saved");

                                if (userNameControl != null) userNameControl.InnerText = reader["FullName"].ToString();
                                if (userRoleControl != null) userRoleControl.InnerText = "Citizen";

                                decimal totalPoints = Convert.ToDecimal(reader["TotalPoints"]);
                                if (userTotalPointsControl != null)
                                    userTotalPointsControl.InnerText = totalPoints.ToString("0");

                                // Get pickup count separately
                                if (userPickupsCompletedControl != null)
                                {
                                    int pickupsCompleted = GetUserPickupsCompleted(currentUserId, conn);
                                    userPickupsCompletedControl.InnerText = pickupsCompleted.ToString();
                                }

                                // Get CO2 saved separately
                                if (userCO2SavedControl != null)
                                {
                                    decimal co2Saved = GetUserCO2Saved(currentUserId, conn);
                                    userCO2SavedControl.InnerText = co2Saved.ToString("F1");
                                }
                            }
                        }
                    }

                    // Get user rank
                    string rankQuery = @"
                        SELECT Rank FROM (
                            SELECT 
                                UserId,
                                FullName,
                                XP_Credits as TotalPoints,
                                ROW_NUMBER() OVER (ORDER BY XP_Credits DESC) as Rank
                            FROM Users
                            WHERE RoleId IN ('CITZ', 'R001')
                        ) AS Rankings
                        WHERE UserId = @UserId";

                    using (SqlCommand cmd = new SqlCommand(rankQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@UserId", currentUserId);
                        object result = cmd.ExecuteScalar();
                        HtmlGenericControl userRankControl = (HtmlGenericControl)FindControl("userRank");
                        if (userRankControl != null)
                        {
                            if (result != null)
                                userRankControl.InnerText = "#" + result.ToString();
                            else
                                userRankControl.InnerText = "#N/A";
                        }
                    }

                    // Calculate level and progress
                    CalculateUserLevel();
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("LoadCurrentUserStats Error: " + ex.Message);
            }
        }

        private int GetUserPickupsCompleted(string userId, SqlConnection conn)
        {
            try
            {
                string query = @"
                    SELECT COUNT(*) as PickupCount
                    FROM PickupRequests pr
                    INNER JOIN WasteReports wr ON pr.ReportId = wr.ReportId
                    WHERE wr.UserId = @UserId AND pr.Status = 'Collected'";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@UserId", userId);
                    object result = cmd.ExecuteScalar();
                    return result != null ? Convert.ToInt32(result) : 0;
                }
            }
            catch
            {
                return 0;
            }
        }

        private decimal GetUserCO2Saved(string userId, SqlConnection conn)
        {
            try
            {
                string query = @"
                    SELECT ISNULL(SUM(wr.EstimatedKg * wt.CreditPerKg), 0) as CO2Saved
                    FROM WasteReports wr
                    INNER JOIN WasteTypes wt ON wr.WasteTypeId = wt.WasteTypeId
                    INNER JOIN PickupRequests pr ON wr.ReportId = pr.ReportId
                    WHERE wr.UserId = @UserId AND pr.Status = 'Collected'";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@UserId", userId);
                    object result = cmd.ExecuteScalar();
                    return result != null ? Convert.ToDecimal(result) : 0;
                }
            }
            catch
            {
                return 0;
            }
        }

        private void CalculateUserLevel()
        {
            try
            {
                HtmlGenericControl userTotalPointsControl = (HtmlGenericControl)FindControl("userTotalPoints");
                HtmlGenericControl currentLevelControl = (HtmlGenericControl)FindControl("currentLevel");
                HtmlGenericControl nextLevelControl = (HtmlGenericControl)FindControl("nextLevel");
                HtmlGenericControl progressPercentageControl = (HtmlGenericControl)FindControl("progressPercentage");
                HtmlGenericControl progressBarControl = (HtmlGenericControl)FindControl("progressBar");

                if (userTotalPointsControl == null) return;

                decimal totalPoints = 0;
                decimal.TryParse(userTotalPointsControl.InnerText, out totalPoints);

                string level = "Beginner";
                string nextLevelValue = "Eco Warrior";
                int progress = 0;

                if (totalPoints >= 10000)
                {
                    level = "Eco Master";
                    nextLevelValue = "Eco Legend";
                    progress = 100;
                }
                else if (totalPoints >= 5000)
                {
                    level = "Eco Warrior";
                    nextLevelValue = "Eco Master";
                    progress = (int)((totalPoints - 5000) / 50m);
                }
                else if (totalPoints >= 1000)
                {
                    level = "Eco Enthusiast";
                    nextLevelValue = "Eco Warrior";
                    progress = (int)((totalPoints - 1000) / 40m);
                }
                else if (totalPoints >= 100)
                {
                    level = "Eco Starter";
                    nextLevelValue = "Eco Enthusiast";
                    progress = (int)((totalPoints - 100) / 9m);
                }
                else
                {
                    nextLevelValue = "Eco Starter";
                    progress = (int)totalPoints;
                }

                if (progress < 0) progress = 0;
                if (progress > 100) progress = 100;

                if (currentLevelControl != null) currentLevelControl.InnerText = level;
                if (nextLevelControl != null) nextLevelControl.InnerText = nextLevelValue;
                if (progressPercentageControl != null) progressPercentageControl.InnerText = progress + "%";
                if (progressBarControl != null) progressBarControl.Style["width"] = progress + "%";
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("CalculateUserLevel Error: " + ex.Message);
            }
        }

        private void LoadTopWinners()
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    // SIMPLIFIED QUERY - Just get users with highest XP
                    string query = @"
                        SELECT TOP 3
                            UserId,
                            FullName,
                            XP_Credits as TotalPoints
                        FROM Users
                        WHERE RoleId IN ('CITZ', 'R001')
                        ORDER BY XP_Credits DESC";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            int rank = 1;
                            while (reader.Read())
                            {
                                string userId = reader["UserId"].ToString();
                                string fullName = reader["FullName"].ToString();
                                decimal totalPoints = Convert.ToDecimal(reader["TotalPoints"]);

                                // Get additional stats for each winner
                                int pickupsCompleted = GetUserPickupsCompleted(userId, conn);
                                decimal co2Saved = GetUserCO2Saved(userId, conn);

                                switch (rank)
                                {
                                    case 1:
                                        SetWinnerControl("lblFirstName", fullName);
                                        SetWinnerControl("lblFirstPoints", totalPoints.ToString("0") + " points");
                                        SetWinnerControl("lblFirstPickups", pickupsCompleted.ToString());
                                        SetWinnerControl("lblFirstCO2", co2Saved.ToString("F1"));
                                        break;

                                    case 2:
                                        SetWinnerControl("lblSecondName", fullName);
                                        SetWinnerControl("lblSecondPoints", totalPoints.ToString("0") + " points");
                                        SetWinnerControl("lblSecondPickups", pickupsCompleted.ToString());
                                        SetWinnerControl("lblSecondCO2", co2Saved.ToString("F1"));
                                        break;

                                    case 3:
                                        SetWinnerControl("lblThirdName", fullName);
                                        SetWinnerControl("lblThirdPoints", totalPoints.ToString("0") + " points");
                                        SetWinnerControl("lblThirdPickups", pickupsCompleted.ToString());
                                        SetWinnerControl("lblThirdCO2", co2Saved.ToString("F1"));
                                        break;
                                }
                                rank++;
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("LoadTopWinners Error: " + ex.Message);
            }
        }

        private void SetWinnerControl(string controlId, string value)
        {
            HtmlGenericControl control = (HtmlGenericControl)FindControl(controlId);
            if (control != null)
            {
                control.InnerText = value;
            }
        }

        private void LoadLeaderboard()
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    // SIMPLIFIED LEADERBOARD QUERY
                    string query = @"
                        SELECT 
                            UserId,
                            FullName,
                            Phone,
                            Email,
                            XP_Credits as TotalPoints,
                            (SELECT COUNT(*) FROM WasteReports wr WHERE wr.UserId = u.UserId) as ReportsSubmitted,
                            (SELECT COUNT(*) FROM PickupRequests pr 
                             INNER JOIN WasteReports wr ON pr.ReportId = wr.ReportId 
                             WHERE wr.UserId = u.UserId AND pr.Status = 'Collected') as PickupsCompleted,
                            (SELECT ISNULL(SUM(wr.EstimatedKg), 0) FROM WasteReports wr WHERE wr.UserId = u.UserId) as TotalWasteCollected,
                            (SELECT ISNULL(SUM(wr.EstimatedKg * wt.CreditPerKg), 0) 
                             FROM WasteReports wr 
                             INNER JOIN WasteTypes wt ON wr.WasteTypeId = wt.WasteTypeId
                             INNER JOIN PickupRequests pr ON wr.ReportId = pr.ReportId
                             WHERE wr.UserId = u.UserId AND pr.Status = 'Collected') as CO2Saved,
                            CASE 
                                WHEN XP_Credits >= 10000 THEN 'Eco Master'
                                WHEN XP_Credits >= 5000 THEN 'Eco Warrior'
                                WHEN XP_Credits >= 1000 THEN 'Eco Enthusiast'
                                WHEN XP_Credits >= 100 THEN 'Eco Starter'
                                ELSE 'Beginner'
                            END as UserLevel,
                            ROW_NUMBER() OVER (ORDER BY XP_Credits DESC) as Rank
                        FROM Users u
                        WHERE RoleId IN ('CITZ', 'R001')";

                    if (!string.IsNullOrEmpty(searchQuery))
                    {
                        query += " AND (FullName LIKE @SearchQuery OR Email LIKE @SearchQuery OR Phone LIKE @SearchQuery)";
                    }

                    // Get total count
                    string countQuery = "SELECT COUNT(*) FROM Users WHERE RoleId IN ('CITZ', 'R001')";
                    if (!string.IsNullOrEmpty(searchQuery))
                    {
                        countQuery += " AND (FullName LIKE @SearchQuery OR Email LIKE @SearchQuery OR Phone LIKE @SearchQuery)";
                    }

                    using (SqlCommand countCmd = new SqlCommand(countQuery, conn))
                    {
                        if (!string.IsNullOrEmpty(searchQuery))
                        {
                            countCmd.Parameters.AddWithValue("@SearchQuery", "%" + searchQuery + "%");
                        }
                        totalItems = Convert.ToInt32(countCmd.ExecuteScalar());
                    }

                    // Add ordering and pagination
                    switch (category.ToLower())
                    {
                        case "pickups":
                            query += " ORDER BY PickupsCompleted DESC";
                            break;
                        case "waste":
                            query += " ORDER BY TotalWasteCollected DESC";
                            break;
                        case "reports":
                            query += " ORDER BY ReportsSubmitted DESC";
                            break;
                        case "recycling":
                            query += " ORDER BY (PickupsCompleted * 1.0 / NULLIF(ReportsSubmitted, 0)) DESC";
                            break;
                        default:
                            query += " ORDER BY TotalPoints DESC";
                            break;
                    }

                    query += " OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        if (!string.IsNullOrEmpty(searchQuery))
                        {
                            cmd.Parameters.AddWithValue("@SearchQuery", "%" + searchQuery + "%");
                        }
                        cmd.Parameters.AddWithValue("@Offset", (currentPage - 1) * pageSize);
                        cmd.Parameters.AddWithValue("@PageSize", pageSize);

                        using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                        {
                            DataTable dt = new DataTable();
                            da.Fill(dt);

                            if (dt.Rows.Count > 0)
                            {
                                rptLeaderboard.DataSource = dt;
                                rptLeaderboard.DataBind();
                                pnlEmptyState.Visible = false;
                            }
                            else
                            {
                                rptLeaderboard.DataSource = null;
                                rptLeaderboard.DataBind();
                                pnlEmptyState.Visible = true;
                            }

                            UpdatePaginationLabels();
                            LoadPageNumbers();
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("LoadLeaderboard Error: " + ex.Message);
                pnlEmptyState.Visible = true;
            }
        }

        private void LoadAchievements()
        {
            try
            {
                HtmlGenericControl userPickupsCompletedControl = (HtmlGenericControl)FindControl("userPickupsCompleted");
                HtmlGenericControl userTotalPointsControl = (HtmlGenericControl)FindControl("userTotalPoints");
                HtmlGenericControl userCO2SavedControl = (HtmlGenericControl)FindControl("userCO2Saved");
                HtmlGenericControl userRankControl = (HtmlGenericControl)FindControl("userRank");

                if (userPickupsCompletedControl == null || userTotalPointsControl == null ||
                    userCO2SavedControl == null || userRankControl == null)
                    return;

                int pickupsCompleted = 0;
                decimal totalPoints = 0;
                decimal co2Saved = 0;
                int rankNumber = 0;

                int.TryParse(userPickupsCompletedControl.InnerText, out pickupsCompleted);
                decimal.TryParse(userTotalPointsControl.InnerText, out totalPoints);
                decimal.TryParse(userCO2SavedControl.InnerText, out co2Saved);

                string rankText = userRankControl.InnerText.Replace("#", "");
                int.TryParse(rankText, out rankNumber);

                var achievements = new List<Achievement>
                {
                    new Achievement {
                        IconClass = "fas fa-recycle",
                        Title = "First Pickup",
                        Description = "Complete your first waste pickup",
                        Progress = pickupsCompleted > 0 ? 1 : 0,
                        Target = 1,
                        IsUnlocked = pickupsCompleted > 0
                    },
                    new Achievement {
                        IconClass = "fas fa-trophy",
                        Title = "Eco Starter",
                        Description = "Reach 100 points",
                        Progress = (int)Math.Min((double)totalPoints, 100.0),
                        Target = 100,
                        IsUnlocked = totalPoints >= 100
                    },
                    new Achievement {
                        IconClass = "fas fa-leaf",
                        Title = "CO₂ Saver",
                        Description = "Save 100kg of CO₂",
                        Progress = (int)Math.Min((double)co2Saved, 100.0),
                        Target = 100,
                        IsUnlocked = co2Saved >= 100
                    },
                    new Achievement {
                        IconClass = "fas fa-medal",
                        Title = "Pickup Pro",
                        Description = "Complete 10 pickups",
                        Progress = Math.Min(pickupsCompleted, 10),
                        Target = 10,
                        IsUnlocked = pickupsCompleted >= 10
                    },
                    new Achievement {
                        IconClass = "fas fa-award",
                        Title = "Weekly Champion",
                        Description = "Top 10 in weekly leaderboard",
                        Progress = rankNumber <= 10 ? 1 : 0,
                        Target = 1,
                        IsUnlocked = rankNumber <= 10
                    }
                };

                rptAchievements.DataSource = achievements;
                rptAchievements.DataBind();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("LoadAchievements Error: " + ex.Message);
            }
        }

        private void UpdatePaginationLabels()
        {
            int start = ((currentPage - 1) * pageSize) + 1;
            int end = Math.Min(currentPage * pageSize, totalItems);

            lblStartCount.Text = start.ToString();
            lblEndCount.Text = end.ToString();
            lblTotalCount.Text = totalItems.ToString();

            btnPrevPage.Enabled = currentPage > 1;
            btnNextPage.Enabled = currentPage < Math.Ceiling((double)totalItems / pageSize);
        }

        private void LoadPageNumbers()
        {
            int totalPages = (int)Math.Ceiling((double)totalItems / pageSize);

            int startPage = Math.Max(1, currentPage - 2);
            int endPage = Math.Min(totalPages, startPage + 4);

            if (endPage - startPage < 4)
            {
                startPage = Math.Max(1, endPage - 4);
            }

            var pageNumbers = new List<object>();
            for (int i = startPage; i <= endPage; i++)
            {
                pageNumbers.Add(new { PageNumber = i, CurrentPage = currentPage });
            }

            rptPageNumbers.DataSource = pageNumbers;
            rptPageNumbers.DataBind();
        }

        // Timeframe buttons
        protected void btnDaily_Click(object sender, EventArgs e)
        {
            SetActiveTimeframe("daily");
            currentPage = 1;
            LoadLeaderboard();
        }

        protected void btnWeekly_Click(object sender, EventArgs e)
        {
            SetActiveTimeframe("weekly");
            currentPage = 1;
            LoadLeaderboard();
        }

        protected void btnMonthly_Click(object sender, EventArgs e)
        {
            SetActiveTimeframe("monthly");
            currentPage = 1;
            LoadLeaderboard();
        }

        protected void btnAllTime_Click(object sender, EventArgs e)
        {
            SetActiveTimeframe("all");
            currentPage = 1;
            LoadLeaderboard();
        }

        private void SetActiveTimeframe(string active)
        {
            btnDaily.CssClass = "timeframe-badge" + (active == "daily" ? " active" : "");
            btnWeekly.CssClass = "timeframe-badge" + (active == "weekly" ? " active" : "");
            btnMonthly.CssClass = "timeframe-badge" + (active == "monthly" ? " active" : "");
            btnAllTime.CssClass = "timeframe-badge" + (active == "all" ? " active" : "");
        }

        protected void ddlCategory_SelectedIndexChanged(object sender, EventArgs e)
        {
            category = ddlCategory.SelectedValue;
            currentPage = 1;
            LoadLeaderboard();
        }

        protected void txtSearch_TextChanged(object sender, EventArgs e)
        {
            searchQuery = txtSearch.Text.Trim();
            currentPage = 1;
            LoadLeaderboard();
        }

        protected void btnPrevPage_Click(object sender, EventArgs e)
        {
            if (currentPage > 1)
            {
                currentPage--;
                LoadLeaderboard();
            }
        }

        protected void btnNextPage_Click(object sender, EventArgs e)
        {
            int totalPages = (int)Math.Ceiling((double)totalItems / pageSize);
            if (currentPage < totalPages)
            {
                currentPage++;
                LoadLeaderboard();
            }
        }

        protected void btnPage_Click(object sender, EventArgs e)
        {
            LinkButton btn = (LinkButton)sender;
            currentPage = Convert.ToInt32(btn.CommandArgument);
            LoadLeaderboard();
        }

        protected void rptLeaderboard_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            // Additional item binding if needed
        }

        protected void btnViewMyStats_Click(object sender, EventArgs e)
        {
            Response.Redirect("~/Pages/Citizen/MyStats.aspx");
        }

        protected void btnRefresh_Click(object sender, EventArgs e)
        {
            LoadCurrentUserStats();
            LoadTopWinners();
            LoadLeaderboard();
            LoadAchievements();
            ShowMessage("Leaderboard refreshed successfully!", "success");
        }

        protected void btnShare_Click(object sender, EventArgs e)
        {
            HtmlGenericControl userRankControl = (HtmlGenericControl)FindControl("userRank");
            HtmlGenericControl userTotalPointsControl = (HtmlGenericControl)FindControl("userTotalPoints");

            if (userRankControl != null && userTotalPointsControl != null)
            {
                string shareText = "I'm ranked " + userRankControl.InnerText + " on SoorGreen Leaderboard with " +
                                   userTotalPointsControl.InnerText + " points! Join me in making the planet greener! #SoorGreen #EcoWarrior";
                ShowMessage("Share feature coming soon! Text: " + shareText, "info");
            }
        }

        protected void btnStartRecycling_Click(object sender, EventArgs e)
        {
            Response.Redirect("~/Pages/Citizen/MyReports.aspx");
        }

        protected void btnViewAllAchievements_Click(object sender, EventArgs e)
        {
            Response.Redirect("~/Pages/Citizen/Achievements.aspx");
        }

        // Helper methods for data binding
        public bool IsCurrentUser(string userId)
        {
            return userId == currentUserId;
        }

        public string GetAvatarUrl(object avatarUrl)
        {
            return ResolveUrl("~/Content/Images/default-avatar.png");
        }

        public string GetLevelClass(string level)
        {
            if (string.IsNullOrEmpty(level))
                return "level-beginner";

            switch (level.ToLower())
            {
                case "eco master":
                    return "level-master";
                case "eco warrior":
                    return "level-warrior";
                case "eco enthusiast":
                    return "level-enthusiast";
                case "eco starter":
                    return "level-starter";
                default:
                    return "level-beginner";
            }
        }

        public string GetAchievementProgress(object progress, object target)
        {
            int p = 0;
            int t = 0;

            if (progress != null)
                int.TryParse(progress.ToString(), out p);

            if (target != null)
                int.TryParse(target.ToString(), out t);

            if (t == 0) return "0%";

            double percentage = (p * 100.0) / t;
            return Math.Min(percentage, 100) + "%";
        }

        private void ShowMessage(string message, string type)
        {
            string icon = "exclamation-circle";
            string upperType = type.ToUpper();

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
                case "info":
                    icon = "info-circle";
                    break;
            }

            string script = @"
                var messagePanel = document.querySelector('.message-panel') || (function() {
                    var div = document.createElement('div');
                    div.className = 'message-panel';
                    document.body.appendChild(div);
                    return div;
                })();
                
                messagePanel.innerHTML = `
                    <div class='message-alert " + type + @" show'>
                        <i class='fas fa-" + icon + @"'></i>
                        <div>
                            <strong>" + upperType + @"</strong>
                            <p class='mb-0'>" + message.Replace("'", "\\'") + @"</p>
                        </div>
                    </div>
                `;
                messagePanel.style.display = 'block';
                
                setTimeout(function() {
                    messagePanel.style.display = 'none';
                }, 5000);
            ";

            ScriptManager.RegisterStartupScript(this, GetType(), "ShowMessage_" + Guid.NewGuid().ToString(), script, true);
        }
    }
}