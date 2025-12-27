using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace SoorGreen.Collectors
{
    public partial class Community : System.Web.UI.Page
    {
        // Class variables
        protected string CurrentUserId = "";
        protected string CurrentUserName = "";
        protected string CurrentFilter = "all";
        protected int PageSize = 10;
        protected int CurrentPage = 1;

        protected void Page_Load(object sender, EventArgs e)
        {
            // Check if user is logged in
            if (Session["UserID"] == null)
            {
                Response.Redirect("~/Login.aspx?returnUrl=" + Server.UrlEncode(Request.Url.AbsolutePath));
                return;
            }

            // Get current user info from session
            CurrentUserId = Session["UserID"].ToString();
            CurrentUserName = Session["FullName"] != null ? Session["FullName"].ToString() : "Collector";

            // Only load data on first page load (not on postbacks)
            if (!IsPostBack)
            {
                LoadCommunityStats();
                LoadTopContributors();
                LoadCommunityPosts();
                UpdateActiveTab(CurrentFilter);
            }
        }

        private void LoadCommunityStats()
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(GetConnectionString()))
                {
                    conn.Open();

                    // Total Members (Collectors - Role R002)
                    string membersQuery = "SELECT COUNT(*) FROM Users WHERE RoleId = 'R002' AND IsDeleted = 0";
                    using (SqlCommand cmd = new SqlCommand(membersQuery, conn))
                    {
                        object result = cmd.ExecuteScalar();
                        lblTotalMembers.Text = result != null ? result.ToString() : "0";
                    }

                    // Total Waste Reports
                    string postsQuery = "SELECT COUNT(*) FROM WasteReports WHERE IsDeleted = 0";
                    using (SqlCommand cmd = new SqlCommand(postsQuery, conn))
                    {
                        object result = cmd.ExecuteScalar();
                        lblTotalPosts.Text = result != null ? result.ToString() : "0";
                    }

                    // Total Recycled KG
                    string kgQuery = @"SELECT ISNULL(SUM(pv.VerifiedKg), 0) 
                                       FROM PickupVerifications pv 
                                       JOIN PickupRequests pr ON pv.PickupId = pr.PickupId 
                                       WHERE pr.Status = 'Collected'";
                    using (SqlCommand cmd = new SqlCommand(kgQuery, conn))
                    {
                        object result = cmd.ExecuteScalar();
                        lblTotalComments.Text = result != null ? Math.Round(Convert.ToDecimal(result), 2).ToString() + " kg" : "0 kg";
                    }

                    // Total Credits Earned
                    string creditsQuery = "SELECT ISNULL(SUM(Amount), 0) FROM RewardPoints";
                    using (SqlCommand cmd = new SqlCommand(creditsQuery, conn))
                    {
                        object result = cmd.ExecuteScalar();
                        lblTotalLikes.Text = result != null ? Math.Round(Convert.ToDecimal(result), 2).ToString() + " XP" : "0 XP";
                    }
                }
            }
            catch (Exception ex)
            {
                // Show zeros on error
                lblTotalMembers.Text = "0";
                lblTotalPosts.Text = "0";
                lblTotalComments.Text = "0 kg";
                lblTotalLikes.Text = "0 XP";

                // Log error
                System.Diagnostics.Debug.WriteLine("Error in LoadCommunityStats: " + ex.Message);
            }
        }

        private void LoadTopContributors()
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(GetConnectionString()))
                {
                    // Get top collectors based on waste reports
                    string query = @"SELECT TOP 5 
                            u.UserId,
                            u.FullName,
                            COUNT(DISTINCT wr.ReportId) as ReportCount,
                            ISNULL(SUM(rp.Amount), 0) as TotalCredits,
                            u.XP_Credits
                        FROM Users u
                        LEFT JOIN WasteReports wr ON u.UserId = wr.UserId AND wr.IsDeleted = 0
                        LEFT JOIN RewardPoints rp ON u.UserId = rp.UserId
                        WHERE u.RoleId = 'R002' AND u.IsDeleted = 0
                        GROUP BY u.UserId, u.FullName, u.XP_Credits
                        ORDER BY ReportCount DESC, TotalCredits DESC, u.XP_Credits DESC";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        DataTable dt = new DataTable();
                        using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                        {
                            da.Fill(dt);
                            rptTopContributors.DataSource = dt;
                            rptTopContributors.DataBind();
                        }
                    }
                }
            }
            catch (Exception)
            {
                // Show empty on error
                DataTable dt = new DataTable();
                rptTopContributors.DataSource = dt;
                rptTopContributors.DataBind();
            }
        }

        private void LoadCommunityPosts()
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(GetConnectionString()))
                {
                    // Use waste reports as community posts
                    string query = @"SELECT 
                            wr.ReportId as PostId,
                            wr.UserId,
                            u.FullName as AuthorName,
                            u.IsVerified,
                            'Reported ' + wt.Name + ' (' + CONVERT(VARCHAR, wr.EstimatedKg) + ' kg) at ' + wr.Address as Content,
                            'Waste Report' as PostType,
                            wr.PhotoUrl as ImageUrl,
                            wr.CreatedAt,
                            (SELECT COUNT(*) FROM UserActivities ua WHERE ua.UserId = wr.UserId AND ua.ActivityType = 'WasteReport') as LikeCount,
                            (SELECT COUNT(*) FROM PickupRequests pr WHERE pr.ReportId = wr.ReportId) as CommentCount,
                            0 as IsSaved
                        FROM WasteReports wr
                        JOIN Users u ON wr.UserId = u.UserId
                        JOIN WasteTypes wt ON wr.WasteTypeId = wt.WasteTypeId
                        WHERE wr.IsDeleted = 0 AND u.RoleId = 'R002'
                        ORDER BY wr.CreatedAt DESC";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        DataTable dt = new DataTable();
                        using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                        {
                            da.Fill(dt);

                            rptCommunityPosts.DataSource = dt;
                            rptCommunityPosts.DataBind();
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                // Show empty on error
                DataTable dt = new DataTable();
                rptCommunityPosts.DataSource = dt;
                rptCommunityPosts.DataBind();

                // Log error
                System.Diagnostics.Debug.WriteLine("Error in LoadCommunityPosts: " + ex.Message);
            }
        }

        protected void rptCommunityPosts_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
            {
                DataRowView rowView = (DataRowView)e.Item.DataItem;
                string authorId = rowView["UserId"].ToString();

                // Set author avatar
                Label lblAuthorInitials = (Label)e.Item.FindControl("lblAuthorInitials");
                if (lblAuthorInitials != null)
                {
                    lblAuthorInitials.Text = GetInitials(rowView["AuthorName"].ToString());
                }

                // Show delete button only for own posts
                LinkButton btnDelete = (LinkButton)e.Item.FindControl("btnDelete");
                if (btnDelete != null)
                {
                    btnDelete.Visible = (authorId == CurrentUserId);
                }
            }
            else if (e.Item.ItemType == ListItemType.Footer)
            {
                // Show message if no data
                if (rptCommunityPosts.DataSource != null)
                {
                    DataTable dt = (DataTable)rptCommunityPosts.DataSource;
                    if (dt.Rows.Count == 0)
                    {
                        Label lblNoPosts = (Label)e.Item.FindControl("lblNoPosts");
                        if (lblNoPosts != null)
                        {
                            lblNoPosts.Visible = true;
                            lblNoPosts.Text = "No waste reports found. Be the first to create a report!";
                        }
                    }
                }
            }
        }

        protected void CommunityTab_Command(object sender, CommandEventArgs e)
        {
            CurrentFilter = e.CommandArgument.ToString();
            CurrentPage = 1;
            UpdateActiveTab(CurrentFilter);
            LoadCommunityPosts();
        }

        private void UpdateActiveTab(string filter)
        {
            // Update tab styling
            if (btnTabAll != null) btnTabAll.CssClass = "community-tab" + (filter == "all" ? " active" : "");
            if (btnTabPopular != null) btnTabPopular.CssClass = "community-tab" + (filter == "popular" ? " active" : "");
            if (btnTabTips != null) btnTabTips.CssClass = "community-tab" + (filter == "tips" ? " active" : "");
            if (btnTabQuestions != null) btnTabQuestions.CssClass = "community-tab" + (filter == "questions" ? " active" : "");
            if (btnTabUpdates != null) btnTabUpdates.CssClass = "community-tab" + (filter == "updates" ? " active" : "");
        }

        protected void PostAction_Command(object sender, CommandEventArgs e)
        {
            string action = e.CommandName;
            string postId = e.CommandArgument.ToString();

            switch (action)
            {
                case "Save":
                    ShowInfoMessage("Save feature requires SavedPosts table");
                    break;
                case "Delete":
                    DeleteWasteReport(postId);
                    break;
                case "Comment":
                    ShowInfoMessage("Comments feature requires CommunityComments table");
                    break;
            }
        }

        private void DeleteWasteReport(string reportId)
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(GetConnectionString()))
                {
                    string query = "UPDATE WasteReports SET IsDeleted = 1, DeletedAt = GETDATE(), DeletedBy = @UserId WHERE ReportId = @ReportId AND UserId = @UserId";
                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@ReportId", reportId);
                        cmd.Parameters.AddWithValue("@UserId", CurrentUserId);
                        conn.Open();
                        int rows = cmd.ExecuteNonQuery();

                        if (rows > 0)
                        {
                            ShowSuccessMessage("Report deleted successfully");
                            LoadCommunityStats();
                            LoadCommunityPosts();
                        }
                        else
                        {
                            ShowErrorMessage("Failed to delete report");
                        }
                    }
                }
            }
            catch (Exception)
            {
                ShowErrorMessage("Failed to delete report");
            }
        }

        protected void btnSubmitPost_Click(object sender, EventArgs e)
        {
            // Redirect to waste report page
            Response.Redirect("~/Pages/Collectors/WasteReports.aspx");
        }

        protected void btnRefresh_Click(object sender, EventArgs e)
        {
            LoadCommunityStats();
            LoadTopContributors();
            LoadCommunityPosts();
            ShowSuccessMessage("Community page refreshed");
        }

        protected void btnLoadMore_Click(object sender, EventArgs e)
        {
            CurrentPage++;
            LoadCommunityPosts();
        }

        protected void btnReportIssue_Click(object sender, EventArgs e)
        {
            Response.Redirect("~/Pages/Collectors/Support.aspx");
        }

        // Event handling methods (for ASPX page requirements)
        protected void EventAction_Command(object sender, CommandEventArgs e)
        {
            ShowInfoMessage("Events feature requires CommunityEvents table");
        }

        protected void btnViewAllEvents_Click(object sender, EventArgs e)
        {
            ShowInfoMessage("Events feature requires CommunityEvents table");
        }

        // PUBLIC METHODS - These can be called from ASPX file
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

        public string GetRelativeTime(DateTime date)
        {
            TimeSpan ts = DateTime.Now - date;

            if (ts.TotalMinutes < 1)
                return "just now";
            if (ts.TotalHours < 1)
                return ((int)ts.TotalMinutes).ToString() + "m ago";
            if (ts.TotalDays < 1)
                return ((int)ts.TotalHours).ToString() + "h ago";
            if (ts.TotalDays < 7)
                return ((int)ts.TotalDays).ToString() + "d ago";
            if (ts.TotalDays < 30)
                return ((int)(ts.TotalDays / 7)).ToString() + "w ago";

            return date.ToString("MMM d, yyyy");
        }

        private string GetConnectionString()
        {
            return ConfigurationManager.ConnectionStrings["SoorGreenDBConnectionString"].ConnectionString;
        }

        private void ShowSuccessMessage(string message)
        {
            string script = "alert('" + message.Replace("'", "\\'") + "');";
            ScriptManager.RegisterStartupScript(this, GetType(), "successAlert", script, true);
        }

        private void ShowErrorMessage(string message)
        {
            string script = "alert('" + message.Replace("'", "\\'") + "');";
            ScriptManager.RegisterStartupScript(this, GetType(), "errorAlert", script, true);
        }

        private void ShowInfoMessage(string message)
        {
            string script = "alert('" + message.Replace("'", "\\'") + "');";
            ScriptManager.RegisterStartupScript(this, GetType(), "infoAlert", script, true);
        }
    }
}