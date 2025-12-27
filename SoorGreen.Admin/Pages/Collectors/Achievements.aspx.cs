using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace SoorGreen.Collectors
{
    public partial class Achievements : System.Web.UI.Page
    {
        protected string CurrentUserId = "";
        protected string CurrentUserRole = "";
        protected string CurrentCategory = "all";

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
                LoadCollectorInfo();
                LoadStats();
                LoadAchievements();
                LoadMilestones();
            }
        }

        private void LoadCollectorInfo()
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
                                lblCollectorName.Text = reader["FullName"].ToString();
                                decimal totalXP = Convert.ToDecimal(reader["XP_Credits"]);
                                lblTotalXP.Text = totalXP.ToString("F0");

                                int level = CalculateLevel(totalXP);
                                lblCurrentLevel.Text = level.ToString();
                                lblLevelNumber.Text = level.ToString();

                                int currentLevelXP = GetXPForLevel(level);
                                int nextLevelXP = GetXPForLevel(level + 1);
                                int currentXPInLevel = (int)(totalXP - currentLevelXP);
                                int xpNeeded = nextLevelXP - currentLevelXP;

                                lblCurrentXP.Text = currentXPInLevel.ToString();
                                lblNextLevelXP.Text = xpNeeded.ToString();
                                lblXPToNext.Text = (xpNeeded - currentXPInLevel).ToString();

                                int percentage = (int)((double)currentXPInLevel / xpNeeded * 100);
                                xpFill.Style["width"] = percentage + "%";
                            }
                        }
                    }
                }
            }
            catch
            {
                lblCollectorName.Text = "Collector";
                lblTotalXP.Text = "0";
                lblCurrentLevel.Text = "1";
                lblLevelNumber.Text = "1";
                lblCurrentXP.Text = "0";
                lblNextLevelXP.Text = "100";
                lblXPToNext.Text = "100";
                xpFill.Style["width"] = "0%";
            }
        }

        private int CalculateLevel(decimal xp)
        {
            return (int)(xp / 100) + 1;
        }

        private int GetXPForLevel(int level)
        {
            return (level - 1) * 100;
        }

        private void LoadStats()
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(GetConnectionString()))
                {
                    conn.Open();

                    string pickupsQuery = "SELECT COUNT(*) FROM PickupRequests WHERE CollectorId = @CollectorId AND Status = 'Collected'";
                    using (SqlCommand cmd = new SqlCommand(pickupsQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@CollectorId", CurrentUserId);
                        object result = cmd.ExecuteScalar();
                        lblTotalPickups.Text = result.ToString();
                    }

                    string weightQuery = "SELECT ISNULL(SUM(pv.VerifiedKg), 0) FROM PickupRequests pr JOIN PickupVerifications pv ON pr.PickupId = pv.PickupId WHERE pr.CollectorId = @CollectorId AND pr.Status = 'Collected'";
                    using (SqlCommand cmd = new SqlCommand(weightQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@CollectorId", CurrentUserId);
                        object result = cmd.ExecuteScalar();
                        decimal totalWeight = Convert.ToDecimal(result);
                        lblTotalWeight.Text = totalWeight.ToString("F0");
                    }

                    string completionQuery = "SELECT CASE WHEN COUNT(*) = 0 THEN 0 ELSE (SUM(CASE WHEN Status = 'Collected' THEN 1 ELSE 0 END) * 100.0 / COUNT(*)) END FROM PickupRequests WHERE CollectorId = @CollectorId AND ScheduledAt >= DATEADD(DAY, -30, GETDATE())";
                    using (SqlCommand cmd = new SqlCommand(completionQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@CollectorId", CurrentUserId);
                        object result = cmd.ExecuteScalar();
                        decimal completionRate = Convert.ToDecimal(result);
                        lblCompletionRate.Text = completionRate.ToString("F0") + "%";
                    }

                    string streakQuery = "SELECT TOP 1 DATEDIFF(DAY, ScheduledAt, GETDATE()) FROM PickupRequests WHERE CollectorId = @CollectorId AND Status = 'Collected' ORDER BY ScheduledAt DESC";
                    using (SqlCommand cmd = new SqlCommand(streakQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@CollectorId", CurrentUserId);
                        object result = cmd.ExecuteScalar();
                        int streakDays = result != null ? Convert.ToInt32(result) : 0;
                        lblStreakDays.Text = streakDays.ToString();
                    }
                }
            }
            catch
            {
                lblTotalPickups.Text = "0";
                lblTotalWeight.Text = "0";
                lblCompletionRate.Text = "0%";
                lblStreakDays.Text = "0";
            }
        }

        private void LoadAchievements()
        {
            DataTable dt = new DataTable();
            dt.Columns.Add("Title", typeof(string));
            dt.Columns.Add("Description", typeof(string));
            dt.Columns.Add("CurrentProgress", typeof(int));
            dt.Columns.Add("Target", typeof(int));
            dt.Columns.Add("RewardXP", typeof(int));
            dt.Columns.Add("Status", typeof(string));

            try
            {
                using (SqlConnection conn = new SqlConnection(GetConnectionString()))
                {
                    conn.Open();

                    // Get actual collector stats
                    string statsQuery = @"
                        SELECT 
                            COUNT(pr.PickupId) as TotalPickups,
                            ISNULL(SUM(pv.VerifiedKg), 0) as TotalWeight
                        FROM PickupRequests pr
                        LEFT JOIN PickupVerifications pv ON pr.PickupId = pv.PickupId
                        WHERE pr.CollectorId = @CollectorId 
                        AND pr.Status = 'Collected'";

                    int totalPickups = 0;
                    decimal totalWeight = 0;

                    using (SqlCommand cmd = new SqlCommand(statsQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@CollectorId", CurrentUserId);
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                totalPickups = Convert.ToInt32(reader["TotalPickups"]);
                                totalWeight = Convert.ToDecimal(reader["TotalWeight"]);
                            }
                        }
                    }

                    // Create achievements based on real stats
                    if (totalPickups >= 1)
                    {
                        dt.Rows.Add("First Pickup", "Complete your first waste collection", 1, 1, 50, "completed");
                    }
                    else
                    {
                        dt.Rows.Add("First Pickup", "Complete your first waste collection", 0, 1, 50, "locked");
                    }

                    if (totalPickups >= 50)
                    {
                        dt.Rows.Add("Waste Warrior", "Complete 50 pickups", 50, 50, 200, "completed");
                    }
                    else
                    {
                        dt.Rows.Add("Waste Warrior", "Complete 50 pickups", totalPickups, 50, 200, "in-progress");
                    }

                    if (totalPickups >= 200)
                    {
                        dt.Rows.Add("Master Collector", "Complete 200 pickups", 200, 200, 500, "completed");
                    }
                    else
                    {
                        dt.Rows.Add("Master Collector", "Complete 200 pickups", totalPickups, 200, 500, "in-progress");
                    }

                    if (totalWeight >= 1000)
                    {
                        dt.Rows.Add("Weight Lifter", "Collect 1000kg of waste", 1000, 1000, 100, "completed");
                    }
                    else
                    {
                        dt.Rows.Add("Weight Lifter", "Collect 1000kg of waste", (int)totalWeight, 1000, 100, "in-progress");
                    }

                    if (totalWeight >= 5000)
                    {
                        dt.Rows.Add("Tonnage Titan", "Collect 5000kg of waste", 5000, 5000, 300, "completed");
                    }
                    else
                    {
                        dt.Rows.Add("Tonnage Titan", "Collect 5000kg of waste", (int)totalWeight, 5000, 300, "in-progress");
                    }

                    // Get plastic waste stats
                    string plasticQuery = @"
                        SELECT ISNULL(SUM(pv.VerifiedKg), 0) as PlasticWeight
                        FROM PickupRequests pr
                        JOIN PickupVerifications pv ON pr.PickupId = pv.PickupId
                        JOIN WasteReports wr ON pr.ReportId = wr.ReportId
                        JOIN WasteTypes wt ON wr.WasteTypeId = wt.WasteTypeId
                        WHERE pr.CollectorId = @CollectorId 
                        AND pr.Status = 'Collected'
                        AND wt.Name LIKE '%plastic%'";

                    decimal plasticWeight = 0;
                    using (SqlCommand cmd = new SqlCommand(plasticQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@CollectorId", CurrentUserId);
                        object result = cmd.ExecuteScalar();
                        plasticWeight = Convert.ToDecimal(result);
                    }

                    if (plasticWeight >= 500)
                    {
                        dt.Rows.Add("Plastic Pioneer", "Collect 500kg of plastic waste", 500, 500, 200, "completed");
                    }
                    else
                    {
                        dt.Rows.Add("Plastic Pioneer", "Collect 500kg of plastic waste", (int)plasticWeight, 500, 200, "in-progress");
                    }

                    // Get unique waste types collected
                    string typesQuery = @"
                        SELECT COUNT(DISTINCT wt.Name) as UniqueTypes
                        FROM PickupRequests pr
                        JOIN WasteReports wr ON pr.ReportId = wr.ReportId
                        JOIN WasteTypes wt ON wr.WasteTypeId = wt.WasteTypeId
                        WHERE pr.CollectorId = @CollectorId 
                        AND pr.Status = 'Collected'";

                    int uniqueTypes = 0;
                    using (SqlCommand cmd = new SqlCommand(typesQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@CollectorId", CurrentUserId);
                        object result = cmd.ExecuteScalar();
                        uniqueTypes = Convert.ToInt32(result);
                    }

                    // Get total waste types available
                    string totalTypesQuery = "SELECT COUNT(*) FROM WasteTypes";
                    int totalTypes = 0;
                    using (SqlCommand cmd = new SqlCommand(totalTypesQuery, conn))
                    {
                        object result = cmd.ExecuteScalar();
                        totalTypes = Convert.ToInt32(result);
                    }

                    if (uniqueTypes >= totalTypes)
                    {
                        dt.Rows.Add("All-Rounder", "Collect all types of waste", uniqueTypes, totalTypes, 400, "completed");
                    }
                    else
                    {
                        dt.Rows.Add("All-Rounder", "Collect all types of waste", uniqueTypes, totalTypes, 400, "in-progress");
                    }
                }
            }
            catch
            {
                // If error, show basic achievements
                dt.Rows.Add("First Pickup", "Complete your first waste collection", 0, 1, 50, "locked");
                dt.Rows.Add("Waste Warrior", "Complete 50 pickups", 0, 50, 200, "locked");
                dt.Rows.Add("Weight Lifter", "Collect 1000kg of waste", 0, 1000, 100, "locked");
            }

            rptAchievements.DataSource = dt;
            rptAchievements.DataBind();
        }

        private void LoadMilestones()
        {
            DataTable dt = new DataTable();
            dt.Columns.Add("Title", typeof(string));
            dt.Columns.Add("Description", typeof(string));
            dt.Columns.Add("IsCompleted", typeof(bool));

            try
            {
                using (SqlConnection conn = new SqlConnection(GetConnectionString()))
                {
                    string query = @"
                        SELECT TOP 5
                            CASE 
                                WHEN pv.VerifiedKg >= 100 THEN '100kg Collected'
                                WHEN pr.Status = 'Collected' THEN 'Pickup Completed'
                                ELSE 'Activity'
                            END as Title,
                            CASE 
                                WHEN pv.VerifiedKg >= 100 THEN 'Reached 100kg milestone'
                                WHEN pr.Status = 'Collected' THEN 'Waste collection completed'
                                ELSE 'Collection activity'
                            END as Description,
                            1 as IsCompleted,
                            pr.ScheduledAt
                        FROM PickupRequests pr
                        LEFT JOIN PickupVerifications pv ON pr.PickupId = pv.PickupId
                        WHERE pr.CollectorId = @CollectorId
                        AND pr.Status = 'Collected'
                        ORDER BY pr.ScheduledAt DESC";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@CollectorId", CurrentUserId);
                        using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                        {
                            da.Fill(dt);
                        }
                    }

                    // If no pickups, show starting milestone
                    if (dt.Rows.Count == 0)
                    {
                        dt.Rows.Add("Get Started", "Complete your first pickup", false);
                        dt.Rows.Add("Learn the Ropes", "Complete pickup training", false);
                        dt.Rows.Add("First Week", "Work for 7 days", false);
                    }
                }
            }
            catch
            {
                dt.Rows.Add("Get Started", "Complete your first pickup", false);
                dt.Rows.Add("Learn the Ropes", "Complete pickup training", false);
            }

            rptMilestones.DataSource = dt;
            rptMilestones.DataBind();
        }

        protected void rptAchievements_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
            {
                DataRowView rowView = (DataRowView)e.Item.DataItem;
                string status = rowView["Status"].ToString();

                // Set achievement card class
                Panel achievementCard = (Panel)e.Item.FindControl("achievementCard");
                if (achievementCard != null)
                {
                    achievementCard.CssClass = "achievement-card " + status;
                }

                // Set achievement badge
                Panel achievementBadge = (Panel)e.Item.FindControl("achievementBadge");
                if (achievementBadge != null)
                {
                    achievementBadge.CssClass = "achievement-badge " + (status == "completed" ? "completed" : status == "in-progress" ? "in-progress" : "");
                }

                // Set achievement icon
                Label lblAchievementIcon = (Label)e.Item.FindControl("lblAchievementIcon");
                if (lblAchievementIcon != null)
                {
                    string title = rowView["Title"].ToString().ToLower();
                    if (title.Contains("pickup")) lblAchievementIcon.Text = "fas fa-trash-restore";
                    else if (title.Contains("weight") || title.Contains("kg")) lblAchievementIcon.Text = "fas fa-weight-hanging";
                    else if (title.Contains("plastic")) lblAchievementIcon.Text = "fas fa-bottle-water";
                    else if (title.Contains("all-rounder")) lblAchievementIcon.Text = "fas fa-star";
                    else lblAchievementIcon.Text = "fas fa-award";
                }
            }
        }

        public string GetProgressPercentage(object current, object target)
        {
            if (current == null || target == null) return "0";

            int currentVal = Convert.ToInt32(current);
            int targetVal = Convert.ToInt32(target);

            if (targetVal == 0) return "0";

            double percentage = (double)currentVal / targetVal * 100;
            return Math.Min(percentage, 100).ToString("F0");
        }

        protected void CategoryTab_Command(object sender, CommandEventArgs e)
        {
            CurrentCategory = e.CommandArgument.ToString();
            UpdateActiveTab(CurrentCategory);
            LoadAchievements();
        }

        private void UpdateActiveTab(string category)
        {
            btnTabAll.CssClass = "category-tab" + (category == "all" ? " active" : "");
            btnTabCollection.CssClass = "category-tab" + (category == "collection" ? " active" : "");
            btnTabEfficiency.CssClass = "category-tab" + (category == "efficiency" ? " active" : "");
            btnTabConsistency.CssClass = "category-tab" + (category == "consistency" ? " active" : "");
            btnTabSpecial.CssClass = "category-tab" + (category == "special" ? " active" : "");
        }

        protected void btnRefresh_Click(object sender, EventArgs e)
        {
            LoadCollectorInfo();
            LoadStats();
            LoadAchievements();
            LoadMilestones();
            ShowSuccessMessage("Achievements refreshed!");
        }

        protected void btnViewLeaderboard_Click(object sender, EventArgs e)
        {
            Response.Redirect("Leaderboard.aspx");
        }

        protected void btnViewCertificates_Click(object sender, EventArgs e)
        {
            ShowInfoMessage("Certificate view would be implemented here.");
        }

        protected void btnShareAchievements_Click(object sender, EventArgs e)
        {
            ShowInfoMessage("Share functionality would be implemented here.");
        }

        protected void btnSetGoals_Click(object sender, EventArgs e)
        {
            ShowInfoMessage("Goal setting would be implemented here.");
        }

        protected void btnViewHistory_Click(object sender, EventArgs e)
        {
            ShowInfoMessage("Progress history would be implemented here.");
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
        public string GetAchievementBadgeIcon(string status)
        {
            if (status == "completed") return "fas fa-check";
            if (status == "in-progress") return "fas fa-spinner";
            return "fas fa-lock";
        }
        public string GetAchievementIcon(string title)
        {
            if (string.IsNullOrEmpty(title)) return "fas fa-star";

            title = title.ToLower();

            if (title.Contains("pickup") || title.Contains("collector") || title.Contains("warrior"))
                return "fas fa-trash-restore";

            if (title.Contains("weight") || title.Contains("kg") || title.Contains("tonnage"))
                return "fas fa-weight-hanging";

            if (title.Contains("plastic"))
                return "fas fa-bottle-water";

            if (title.Contains("all-rounder") || title.Contains("special"))
                return "fas fa-star";

            if (title.Contains("first"))
                return "fas fa-flag";

            if (title.Contains("master"))
                return "fas fa-crown";

            return "fas fa-award";
        }
        public string GetMilestoneIcon(string title)
        {
            if (string.IsNullOrEmpty(title)) return "fas fa-circle text-muted";

            title = title.ToLower();

            if (title.Contains("pickup") || title.Contains("completed")) return "fas fa-check-circle text-success";
            if (title.Contains("kg") || title.Contains("weight")) return "fas fa-weight-hanging text-warning";
            if (title.Contains("started") || title.Contains("start")) return "fas fa-flag text-primary";
            if (title.Contains("week") || title.Contains("day")) return "fas fa-calendar-alt text-info";
            if (title.Contains("training") || title.Contains("learn")) return "fas fa-graduation-cap text-purple";

            return "fas fa-award text-muted";
        }
    }
}