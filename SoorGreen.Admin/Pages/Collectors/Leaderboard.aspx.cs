using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;

namespace SoorGreen.Collectors
{
    public partial class Leaderboard : System.Web.UI.Page
    {
        protected string CurrentUserId = "";
        protected string CurrentUserRole = "";
        protected string CurrentPeriod = "daily";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] == null)
            {
                Response.Redirect("~/Login.aspx?returnUrl=" + Server.UrlEncode(Request.Url.AbsolutePath));
                return;
            }

            CurrentUserId = Session["UserID"].ToString();
            CurrentUserRole = Session["UserRole"] != null ? Session["UserRole"].ToString() : "";

            if (!IsPostBack)
            {
                LoadUserInfo();
                LoadStats();
                LoadTopThree();
                LoadLeaderboard();
                UpdateActivePeriodTab("daily");
            }
        }

        private void LoadUserInfo()
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(GetConnectionString()))
                {
                    string query = "SELECT FullName, XP_Credits FROM Users WHERE UserId = @UserId";
                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@UserId", CurrentUserId);
                        conn.Open();

                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                lblUserName.Text = reader["FullName"].ToString();
                                lblUserLevel.Text = CalculateLevel(Convert.ToDecimal(reader["XP_Credits"])).ToString();
                                lblUserXP.Text = Convert.ToDecimal(reader["XP_Credits"]).ToString("F0");
                            }
                        }
                    }

                    // Get user's pickup stats
                    string statsQuery = "SELECT COUNT(*) as TotalPickups, ISNULL(SUM(pv.VerifiedKg), 0) as TotalWeight FROM PickupRequests pr LEFT JOIN PickupVerifications pv ON pr.PickupId = pv.PickupId WHERE pr.CollectorId = @UserId AND pr.Status = 'Collected'";
                    using (SqlCommand cmd = new SqlCommand(statsQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@UserId", CurrentUserId);
                        object result = cmd.ExecuteScalar();
                        DataTable dt = new DataTable();
                        using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                        {
                            da.Fill(dt);
                            if (dt.Rows.Count > 0)
                            {
                                lblUserPickups.Text = dt.Rows[0]["TotalPickups"].ToString();
                                lblUserWeight.Text = dt.Rows[0]["TotalWeight"].ToString();
                            }
                            else
                            {
                                lblUserPickups.Text = "0";
                                lblUserWeight.Text = "0";
                            }
                        }
                    }
                }
            }
            catch
            {
                lblUserName.Text = "Collector";
                lblUserLevel.Text = "1";
                lblUserPickups.Text = "0";
                lblUserWeight.Text = "0";
                lblUserXP.Text = "0";
            }
        }

        private void LoadStats()
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(GetConnectionString()))
                {
                    conn.Open();

                    string collectorsQuery = "SELECT COUNT(*) FROM Users WHERE RoleId = 'R002'";
                    using (SqlCommand cmd = new SqlCommand(collectorsQuery, conn))
                    {
                        object result = cmd.ExecuteScalar();
                        lblTotalCollectors.Text = result.ToString();
                    }

                    string pickupsQuery = "SELECT COUNT(*) FROM PickupRequests WHERE Status = 'Collected'";
                    using (SqlCommand cmd = new SqlCommand(pickupsQuery, conn))
                    {
                        object result = cmd.ExecuteScalar();
                        lblTotalPickups.Text = result.ToString();
                    }

                    string weightQuery = "SELECT ISNULL(SUM(pv.VerifiedKg), 0) FROM PickupVerifications pv JOIN PickupRequests pr ON pv.PickupId = pr.PickupId WHERE pr.Status = 'Collected'";
                    using (SqlCommand cmd = new SqlCommand(weightQuery, conn))
                    {
                        object result = cmd.ExecuteScalar();
                        lblTotalWeight.Text = result.ToString();
                    }

                    string co2Query = "SELECT ISNULL(SUM(pv.VerifiedKg) * 1.5, 0) FROM PickupVerifications pv JOIN PickupRequests pr ON pv.PickupId = pr.PickupId WHERE pr.Status = 'Collected'";
                    using (SqlCommand cmd = new SqlCommand(co2Query, conn))
                    {
                        object result = cmd.ExecuteScalar();
                        lblCO2Saved.Text = result.ToString();
                    }
                }
            }
            catch
            {
                lblTotalCollectors.Text = "0";
                lblTotalPickups.Text = "0";
                lblTotalWeight.Text = "0";
                lblCO2Saved.Text = "0";
            }
        }

        private void LoadTopThree()
        {
            DataTable topThree = GetTopCollectors(3);

            if (topThree.Rows.Count > 0)
            {
                // Show only the data we have
                for (int i = 0; i < Math.Min(3, topThree.Rows.Count); i++)
                {
                    DataRow row = topThree.Rows[i];
                    string name = row["FullName"].ToString();
                    string pickups = row["TotalPickups"].ToString();
                    string weight = row["TotalWeight"].ToString();

                    switch (i)
                    {
                        case 0:
                            lblFirstName.Text = name;
                            lblFirstInitials.Text = GetInitials(name);
                            lblFirstStats.Text = pickups + " pickups • " + weight + "kg";
                            break;
                        case 1:
                            lblSecondName.Text = name;
                            lblSecondInitials.Text = GetInitials(name);
                            lblSecondStats.Text = pickups + " pickups • " + weight + "kg";
                            break;
                        case 2:
                            lblThirdName.Text = name;
                            lblThirdInitials.Text = GetInitials(name);
                            lblThirdStats.Text = pickups + " pickups • " + weight + "kg";
                            break;
                    }
                }

                // Hide empty positions
                if (topThree.Rows.Count < 3)
                {
                    if (topThree.Rows.Count < 3)
                    {
                        lblThirdName.Visible = false;
                        avatarThird.Visible = false;
                        lblThirdStats.Visible = false;
                    }
                    if (topThree.Rows.Count < 2)
                    {
                        lblSecondName.Visible = false;
                        avatarSecond.Visible = false;
                        lblSecondStats.Visible = false;
                    }
                    if (topThree.Rows.Count < 1)
                    {
                        lblFirstName.Visible = false;
                        avatarFirst.Visible = false;
                        lblFirstStats.Visible = false;
                    }
                }
            }
            else
            {
                // No data - hide all top three controls
                lblFirstName.Visible = false;
                lblSecondName.Visible = false;
                lblThirdName.Visible = false;
                avatarFirst.Visible = false;
                avatarSecond.Visible = false;
                avatarThird.Visible = false;
                lblFirstStats.Visible = false;
                lblSecondStats.Visible = false;
                lblThirdStats.Visible = false;
            }
        }
        private void LoadLeaderboard()
        {
            DataTable leaderboardData = GetLeaderboardData();

            if (leaderboardData.Rows.Count > 0)
            {
                // Find user's rank
                int userRank = 1;
                bool userFound = false;
                foreach (DataRow row in leaderboardData.Rows)
                {
                    if (row["UserId"].ToString() == CurrentUserId)
                    {
                        userFound = true;
                        break;
                    }
                    userRank++;
                }

                if (userFound)
                {
                    lblUserRank.Text = "#" + userRank;
                    lblCurrentRank.Text = "#" + userRank;

                    if (userRank > 1)
                    {
                        lblNextRankPosition.Text = "#" + (userRank - 1);

                        // Calculate XP difference to next rank
                        if (userRank > 1 && leaderboardData.Rows.Count >= userRank - 1)
                        {
                            decimal currentXP = Convert.ToDecimal(leaderboardData.Rows[userRank - 1]["XP_Credits"]);
                            decimal nextXP = Convert.ToDecimal(leaderboardData.Rows[userRank - 2]["XP_Credits"]);
                            decimal xpNeeded = nextXP - currentXP;
                            lblNextRankXP.Text = xpNeeded.ToString("F0");

                            // Calculate progress percentage - FIXED: Check for zero division
                            if (nextXP > 0)
                            {
                                int progress = (int)((currentXP / nextXP) * 100);
                                rankProgressFill.Style["width"] = Math.Min(progress, 100) + "%";
                            }
                            else
                            {
                                // If nextXP is 0, show full progress
                                rankProgressFill.Style["width"] = "100%";
                            }
                        }
                        else
                        {
                            lblNextRankXP.Text = "100";
                            rankProgressFill.Style["width"] = "75%";
                        }
                    }
                    else
                    {
                        lblNextRankPosition.Text = "#1";
                        lblNextRankXP.Text = "0";
                        rankProgressFill.Style["width"] = "100%";
                    }
                }
                else
                {
                    // User not in leaderboard (no pickups yet)
                    lblUserRank.Text = "Not Ranked";
                    lblCurrentRank.Text = "Not Ranked";
                    lblNextRankPosition.Text = "#" + leaderboardData.Rows.Count;
                    lblNextRankXP.Text = "100";
                    rankProgressFill.Style["width"] = "0%";
                }

                rptLeaderboard.DataSource = leaderboardData;
                rptLeaderboard.DataBind();
            }
            else
            {
                // No data at all
                rptLeaderboard.DataSource = null;
                rptLeaderboard.DataBind();
                lblUserRank.Text = "No Data";
                lblCurrentRank.Text = "No Data";
                lblNextRankPosition.Text = "#1";
                lblNextRankXP.Text = "0";
                rankProgressFill.Style["width"] = "0%";
            }
        }
        private DataTable GetLeaderboardData()
        {
            DataTable dt = new DataTable();

            try
            {
                using (SqlConnection conn = new SqlConnection(GetConnectionString()))
                {
                    string query = @"
                        SELECT 
                            u.UserId,
                            u.FullName,
                            u.XP_Credits,
                            u.CreatedAt,
                            ISNULL(pickupStats.TotalPickups, 0) as TotalPickups,
                            ISNULL(pickupStats.TotalWeight, 0) as TotalWeight
                        FROM Users u
                        LEFT JOIN (
                            SELECT 
                                pr.CollectorId,
                                COUNT(pr.PickupId) as TotalPickups,
                                ISNULL(SUM(pv.VerifiedKg), 0) as TotalWeight
                            FROM PickupRequests pr
                            LEFT JOIN PickupVerifications pv ON pr.PickupId = pv.PickupId
                            WHERE pr.Status = 'Collected'
                            GROUP BY pr.CollectorId
                        ) pickupStats ON u.UserId = pickupStats.CollectorId
                        WHERE u.RoleId = 'R002'
                        ORDER BY u.XP_Credits DESC, TotalPickups DESC, TotalWeight DESC";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                        {
                            da.Fill(dt);
                        }
                    }
                }
            }
            catch
            {
                // Return empty table
            }

            return dt;
        }

        private DataTable GetTopCollectors(int count)
        {
            DataTable dt = new DataTable();

            try
            {
                using (SqlConnection conn = new SqlConnection(GetConnectionString()))
                {
                    string query = @"
                        SELECT TOP " + count + @"
                            u.UserId,
                            u.FullName,
                            u.XP_Credits,
                            ISNULL(pickupStats.TotalPickups, 0) as TotalPickups,
                            ISNULL(pickupStats.TotalWeight, 0) as TotalWeight
                        FROM Users u
                        LEFT JOIN (
                            SELECT 
                                pr.CollectorId,
                                COUNT(pr.PickupId) as TotalPickups,
                                ISNULL(SUM(pv.VerifiedKg), 0) as TotalWeight
                            FROM PickupRequests pr
                            LEFT JOIN PickupVerifications pv ON pr.PickupId = pv.PickupId
                            WHERE pr.Status = 'Collected'
                            GROUP BY pr.CollectorId
                        ) pickupStats ON u.UserId = pickupStats.CollectorId
                        WHERE u.RoleId = 'R002'
                        ORDER BY u.XP_Credits DESC, TotalPickups DESC, TotalWeight DESC";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                        {
                            da.Fill(dt);
                        }
                    }
                }
            }
            catch
            {
                // Return empty table
            }

            return dt;
        }

        protected void rptLeaderboard_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
            {
                DataRowView rowView = (DataRowView)e.Item.DataItem;
                string userId = rowView["UserId"].ToString();

                HtmlTableRow row = (HtmlTableRow)e.Item.FindControl("leaderboardRow");
                Label lblYouBadge = (Label)e.Item.FindControl("lblYouBadge");

                if (row != null && userId == CurrentUserId)
                {
                    row.Attributes["class"] = row.Attributes["class"] + " current-user";
                    if (lblYouBadge != null)
                    {
                        lblYouBadge.Visible = true;
                    }
                }
            }
        }

        public string GetRankBadgeClass(int rank)
        {
            if (rank == 1) return "rank-badge rank-1";
            if (rank == 2) return "rank-badge rank-2";
            if (rank == 3) return "rank-badge rank-3";
            if (rank <= 10) return "rank-badge rank-4-10";
            return "rank-badge rank-other";
        }

        public string GetAvatarStyle(string userId)
        {
            if (string.IsNullOrEmpty(userId)) return "background: linear-gradient(135deg, #3b82f6, #1d4ed8)";

            int hash = 0;
            foreach (char c in userId)
            {
                hash = (hash * 31) + c;
            }
            int hue = Math.Abs(hash % 360);
            return "background: linear-gradient(135deg, hsl(" + hue + ", 70%, 50%), hsl(" + ((hue + 30) % 360) + ", 70%, 50%))";
        }

        public string GetInitials(string fullName)
        {
            if (string.IsNullOrEmpty(fullName)) return "??";

            string[] parts = fullName.Split(' ');
            if (parts.Length >= 2)
            {
                return parts[0][0].ToString().ToUpper() + parts[1][0].ToString().ToUpper();
            }
            else if (parts.Length == 1 && parts[0].Length >= 2)
            {
                return parts[0].Substring(0, 2).ToUpper();
            }
            return "??";
        }

        public string GetJoinDate(object createdAt)
        {
            if (createdAt == null || createdAt == DBNull.Value)
                return "Recently";

            DateTime date = Convert.ToDateTime(createdAt);
            return date.ToString("MMM yyyy");
        }

        public int CalculateLevel(decimal xp)
        {
            return (int)(xp / 100) + 1;
        }

        protected void PeriodTab_Command(object sender, CommandEventArgs e)
        {
            string period = e.CommandArgument.ToString();
            CurrentPeriod = period;

            UpdateActivePeriodTab(period);
            LoadLeaderboard();
        }

        private void UpdateActivePeriodTab(string period)
        {
            btnPeriodDaily.CssClass = "period-tab" + (period == "daily" ? " active" : "");
            btnPeriodWeekly.CssClass = "period-tab" + (period == "weekly" ? " active" : "");
            btnPeriodMonthly.CssClass = "period-tab" + (period == "monthly" ? " active" : "");
            btnPeriodAllTime.CssClass = "period-tab" + (period == "alltime" ? " active" : "");
        }

        protected void btnRefresh_Click(object sender, EventArgs e)
        {
            LoadUserInfo();
            LoadStats();
            LoadTopThree();
            LoadLeaderboard();
            ShowSuccessMessage("Leaderboard refreshed!");
        }

        protected void btnViewAchievements_Click(object sender, EventArgs e)
        {
            Response.Redirect("Achievements.aspx");
        }

        protected void btnCompare_Click(object sender, EventArgs e)
        {
            ShowInfoMessage("Comparison functionality would be implemented here.");
        }

        protected void btnDownloadReport_Click(object sender, EventArgs e)
        {
            ShowInfoMessage("Report download would be implemented here.");
        }

        protected void btnViewRewards_Click(object sender, EventArgs e)
        {
            ShowInfoMessage("Rewards view would be implemented here.");
        }

        protected void btnShareRank_Click(object sender, EventArgs e)
        {
            ShowInfoMessage("Share functionality would be implemented here.");
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
            string script = "showToast('" + message.Replace("'", "\\'") + "', 'error');";
            ScriptManager.RegisterStartupScript(this, GetType(), "errorToast", script, true);
        }

        private void ShowInfoMessage(string message)
        {
            string script = "showToast('" + message.Replace("'", "\\'") + "', 'info');";
            ScriptManager.RegisterStartupScript(this, GetType(), "infoToast", script, true);
        }
    }
}