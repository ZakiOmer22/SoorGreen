using System;
using System.Data;
using System.Configuration;
using System.Collections;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using System.Data.SqlClient;
using System.Globalization;

namespace SoorGreen.Citizens
{
    public partial class MyRewards : System.Web.UI.Page
    {
        protected string CurrentUserId = "";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] == null || Session["UserRole"] == null)
            {
                Response.Redirect("~/Login.aspx?returnUrl=" + Server.UrlEncode(Request.Url.AbsolutePath));
                return;
            }

            CurrentUserId = Session["UserID"].ToString();

            if (!IsPostBack)
            {
                hdnUserId.Value = CurrentUserId;

                LoadUserStats();
                LoadRewardsData();
                LoadRecentTransactions();
                LoadAchievements();
                LoadRedemptionHistory();

                lblModalCredits.Text = statTotalCredits.Text;
            }
        }

        private void LoadUserStats()
        {
            string userId = CurrentUserId;

            using (SqlConnection conn = new SqlConnection(ConfigurationManager.ConnectionStrings["SoorGreenDBConnectionString"].ConnectionString))
            {
                conn.Open();
                SqlCommand cmd = new SqlCommand();
                cmd.Connection = conn;

                try
                {
                    // Total credits
                    string creditsQuery = "SELECT ISNULL(SUM(Amount), 0) FROM RewardPoints WHERE UserId = @UserId";
                    cmd.CommandText = creditsQuery;
                    cmd.Parameters.Clear();
                    cmd.Parameters.AddWithValue("@UserId", userId);
                    object creditsResult = cmd.ExecuteScalar();
                    decimal totalCredits = creditsResult == DBNull.Value ? 0 : Convert.ToDecimal(creditsResult);
                    statTotalCredits.Text = totalCredits.ToString("N0");

                    // Total recycled weight
                    string recycledQuery = @"SELECT ISNULL(SUM(pv.VerifiedKg), 0) 
                                           FROM PickupVerifications pv
                                           INNER JOIN PickupRequests pr ON pv.PickupId = pr.PickupId
                                           INNER JOIN WasteReports wr ON pr.ReportId = wr.ReportId
                                           WHERE wr.UserId = @UserId";
                    cmd.CommandText = recycledQuery;
                    cmd.Parameters.Clear();
                    cmd.Parameters.AddWithValue("@UserId", userId);
                    object recycledResult = cmd.ExecuteScalar();
                    decimal totalRecycled = recycledResult == DBNull.Value ? 0 : Convert.ToDecimal(recycledResult);
                    statTotalRecycled.Text = totalRecycled.ToString("N1");

                    // This month credits
                    string monthQuery = @"SELECT ISNULL(SUM(Amount), 0) 
                                        FROM RewardPoints 
                                        WHERE UserId = @UserId 
                                        AND MONTH(CreatedAt) = MONTH(GETDATE()) 
                                        AND YEAR(CreatedAt) = YEAR(GETDATE())
                                        AND Amount > 0";
                    cmd.CommandText = monthQuery;
                    cmd.Parameters.Clear();
                    cmd.Parameters.AddWithValue("@UserId", userId);
                    object monthResult = cmd.ExecuteScalar();
                    decimal monthCredits = monthResult == DBNull.Value ? 0 : Convert.ToDecimal(monthResult);
                    statThisMonth.Text = monthCredits.ToString("N0");

                    // City rank
                    string rankQuery = @"DECLARE @UserCredits DECIMAL(10,2);
                                       SELECT @UserCredits = ISNULL(SUM(Amount), 0) FROM RewardPoints WHERE UserId = @UserId;
                                       
                                       SELECT COUNT(*) + 1 
                                       FROM Users u
                                       WHERE (SELECT ISNULL(SUM(Amount), 0) FROM RewardPoints WHERE UserId = u.UserId) > @UserCredits
                                       AND u.UserId != @UserId";
                    cmd.CommandText = rankQuery;
                    cmd.Parameters.Clear();
                    cmd.Parameters.AddWithValue("@UserId", userId);
                    object rankResult = cmd.ExecuteScalar();
                    if (rankResult != null && rankResult != DBNull.Value)
                    {
                        int rank = Convert.ToInt32(rankResult);
                        statRank.Text = "#" + rank.ToString();
                    }
                    else
                    {
                        statRank.Text = "#1";
                    }
                }
                catch
                {
                    statTotalCredits.Text = "0";
                    statTotalRecycled.Text = "0";
                    statThisMonth.Text = "0";
                    statRank.Text = "#1";
                }
            }
        }

        private void LoadRewardsData()
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(ConfigurationManager.ConnectionStrings["SoorGreenDBConnectionString"].ConnectionString))
                {
                    conn.Open();

                    // Check if Rewards table exists
                    string checkTableQuery = "SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Rewards'";
                    SqlCommand checkCmd = new SqlCommand(checkTableQuery, conn);
                    int tableExists = Convert.ToInt32(checkCmd.ExecuteScalar());

                    if (tableExists == 0)
                    {
                        // Use WasteTypes if no Rewards table
                        string wasteTypesQuery = @"
                        SELECT 
                            WasteTypeId as RewardId,
                            Name as Title,
                            'Recycle ' + Name + ' to earn credits' as Description,
                            CreditPerKg * 100 as Cost,
                            'recycling' as Category,
                            DATEADD(MONTH, 3, GETDATE()) as ValidUntil,
                            9999 as Stock
                        FROM WasteTypes 
                        WHERE CreditPerKg > 0
                        ORDER BY CreditPerKg DESC";

                        SqlCommand cmd = new SqlCommand(wasteTypesQuery, conn);
                        SqlDataAdapter da = new SqlDataAdapter(cmd);
                        DataTable dt = new DataTable();
                        da.Fill(dt);

                        rptRewards.DataSource = dt;
                        rptRewards.DataBind();
                        pnlNoRewards.Visible = dt.Rows.Count == 0;
                    }
                    else
                    {
                        // Load from Rewards table
                        string query = @"
                        SELECT 
                            RewardId,
                            Title,
                            Description,
                            Cost,
                            Category,
                            ValidUntil,
                            Stock
                        FROM Rewards 
                        WHERE IsActive = 1 
                        AND (Stock > 0 OR Stock IS NULL) 
                        AND (ValidUntil >= GETDATE() OR ValidUntil IS NULL)";

                        SqlCommand cmd = new SqlCommand(query, conn);
                        SqlDataAdapter da = new SqlDataAdapter(cmd);
                        DataTable dt = new DataTable();
                        da.Fill(dt);

                        if (ddlRewardCategory.SelectedValue != "all" && dt.Rows.Count > 0)
                        {
                            DataView dv = new DataView(dt);
                            dv.RowFilter = "Category = '" + ddlRewardCategory.SelectedValue + "'";
                            dt = dv.ToTable();
                        }

                        rptRewards.DataSource = dt;
                        rptRewards.DataBind();
                        pnlNoRewards.Visible = dt.Rows.Count == 0;
                    }
                }
            }
            catch
            {
                rptRewards.DataSource = null;
                rptRewards.DataBind();
                pnlNoRewards.Visible = true;
            }
        }

        private void LoadRecentTransactions()
        {
            string userId = CurrentUserId;

            try
            {
                using (SqlConnection conn = new SqlConnection(ConfigurationManager.ConnectionStrings["SoorGreenDBConnectionString"].ConnectionString))
                {
                    conn.Open();

                    string query = @"
                    SELECT TOP 10 
                        CreatedAt,
                        Amount,
                        Type,
                        CASE 
                            WHEN Type = 'Credit' THEN 'Waste Pickup Reward'
                            WHEN Type = 'Redeem' THEN 'Reward Redemption'
                            ELSE Type
                        END as Description,
                        ISNULL(Reference, 'N/A') as Reference,
                        ISNULL((
                            SELECT SUM(Amount) 
                            FROM RewardPoints rp2 
                            WHERE rp2.UserId = @UserId 
                            AND rp2.CreatedAt <= rp.CreatedAt
                        ), 0) as Balance
                    FROM RewardPoints rp
                    WHERE UserId = @UserId
                    ORDER BY CreatedAt DESC";

                    SqlCommand cmd = new SqlCommand(query, conn);
                    cmd.Parameters.AddWithValue("@UserId", userId);

                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    rptTransactions.DataSource = dt;
                    rptTransactions.DataBind();
                    pnlNoTransactions.Visible = dt.Rows.Count == 0;
                }
            }
            catch
            {
                rptTransactions.DataSource = null;
                rptTransactions.DataBind();
                pnlNoTransactions.Visible = true;
            }
        }

        private void LoadAchievements()
        {
            string userId = CurrentUserId;

            try
            {
                using (SqlConnection conn = new SqlConnection(ConfigurationManager.ConnectionStrings["SoorGreenDBConnectionString"].ConnectionString))
                {
                    conn.Open();
                    SqlCommand cmd = new SqlCommand();
                    cmd.Connection = conn;
                    cmd.Parameters.AddWithValue("@UserId", userId);

                    DataTable dt = new DataTable();
                    dt.Columns.Add("Title");
                    dt.Columns.Add("Description");
                    dt.Columns.Add("Reward", typeof(int));
                    dt.Columns.Add("Achieved", typeof(bool));
                    dt.Columns.Add("ProgressPercent", typeof(int));
                    dt.Columns.Add("ProgressText");
                    dt.Columns.Add("Icon");

                    // Achievement 1: First Waste Report
                    cmd.CommandText = "SELECT COUNT(*) FROM WasteReports WHERE UserId = @UserId";
                    int totalReports = Convert.ToInt32(cmd.ExecuteScalar());
                    bool hasFirstReport = totalReports > 0;
                    dt.Rows.Add("First Waste Report", "Submit your first waste report",
                                50, hasFirstReport, hasFirstReport ? 100 : 0,
                                hasFirstReport ? "Completed" : "0/1", "fas fa-star");

                    // Achievement 2: Recycling Veteran (100kg)
                    cmd.CommandText = @"
                    SELECT ISNULL(SUM(pv.VerifiedKg), 0) 
                    FROM PickupVerifications pv
                    INNER JOIN PickupRequests pr ON pv.PickupId = pr.PickupId
                    INNER JOIN WasteReports wr ON pr.ReportId = wr.ReportId
                    WHERE wr.UserId = @UserId";

                    decimal totalRecycled = Convert.ToDecimal(cmd.ExecuteScalar());
                    bool has100kg = totalRecycled >= 100;
                    int progressPercent = (int)Math.Min(100, (totalRecycled / 100) * 100);
                    dt.Rows.Add("Recycling Veteran", "Recycle 100kg of waste",
                                500, has100kg, progressPercent,
                                string.Format("{0:F1}/100 kg", totalRecycled), "fas fa-recycle");

                    // Achievement 3: Points Collector (5000 credits)
                    cmd.CommandText = "SELECT ISNULL(SUM(Amount), 0) FROM RewardPoints WHERE UserId = @UserId AND Amount > 0";
                    decimal totalCredits = Convert.ToDecimal(cmd.ExecuteScalar());
                    bool has5000Credits = totalCredits >= 5000;
                    int creditProgress = (int)Math.Min(100, (totalCredits / 5000) * 100);
                    dt.Rows.Add("Points Collector", "Earn 5000 credits",
                                1000, has5000Credits, creditProgress,
                                string.Format("{0:N0}/5000", totalCredits), "fas fa-trophy");

                    // Achievement 4: Multiple Waste Types
                    cmd.CommandText = "SELECT COUNT(DISTINCT WasteTypeId) FROM WasteReports WHERE UserId = @UserId";
                    int wasteTypeCount = Convert.ToInt32(cmd.ExecuteScalar());
                    bool has3Types = wasteTypeCount >= 3;
                    dt.Rows.Add("Diverse Recycler", "Recycle 3 different waste types",
                                300, has3Types, Math.Min(100, (wasteTypeCount * 33)),
                                string.Format("{0}/3 types", wasteTypeCount), "fas fa-layer-group");

                    // Achievement 5: Recent Activity
                    cmd.CommandText = "SELECT COUNT(*) FROM WasteReports WHERE UserId = @UserId AND CreatedAt >= DATEADD(DAY, -7, GETDATE())";
                    int recentReports = Convert.ToInt32(cmd.ExecuteScalar());
                    bool hasRecentActivity = recentReports >= 3;
                    dt.Rows.Add("Active Recycler", "Submit 3 reports in 7 days",
                                200, hasRecentActivity, Math.Min(100, (recentReports * 33)),
                                string.Format("{0}/3 reports", recentReports), "fas fa-calendar-check");

                    rptAchievements.DataSource = dt;
                    rptAchievements.DataBind();

                    int achievedCount = 0;
                    foreach (DataRow row in dt.Rows)
                    {
                        if (Convert.ToBoolean(row["Achieved"]))
                            achievedCount++;
                    }

                    lblAchievedCount.Text = achievedCount.ToString();
                    lblTotalAchievements.Text = dt.Rows.Count.ToString();
                }
            }
            catch
            {
                rptAchievements.DataSource = null;
                rptAchievements.DataBind();
                lblAchievedCount.Text = "0";
                lblTotalAchievements.Text = "0";
            }
        }

        private void LoadRedemptionHistory()
        {
            string userId = CurrentUserId;
            string period = ddlHistoryPeriod.SelectedValue;

            try
            {
                using (SqlConnection conn = new SqlConnection(ConfigurationManager.ConnectionStrings["SoorGreenDBConnectionString"].ConnectionString))
                {
                    conn.Open();

                    string query = @"
                    SELECT 
                        RedemptionId,
                        Amount,
                        Status,
                        RequestedAt,
                        ProcessedAt,
                        Method,
                        ISNULL(RewardTitle, Method + ' Redemption') as RewardTitle
                    FROM RedemptionRequests 
                    WHERE UserId = @UserId";

                    if (period != "all")
                    {
                        query += " AND RequestedAt >= DATEADD(DAY, -@Period, GETDATE())";
                    }

                    query += " ORDER BY RequestedAt DESC";

                    SqlCommand cmd = new SqlCommand(query, conn);
                    cmd.Parameters.AddWithValue("@UserId", userId);

                    if (period != "all")
                    {
                        cmd.Parameters.AddWithValue("@Period", Convert.ToInt32(period));
                    }

                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    rptRedemptions.DataSource = dt;
                    rptRedemptions.DataBind();
                    pnlNoRedemptions.Visible = dt.Rows.Count == 0;
                }
            }
            catch
            {
                rptRedemptions.DataSource = null;
                rptRedemptions.DataBind();
                pnlNoRedemptions.Visible = true;
            }
        }

        protected void rptRewards_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "Redeem")
            {
                string[] args = e.CommandArgument.ToString().Split('|');
                if (args.Length >= 3)
                {
                    string rewardId = args[0];
                    string rewardTitle = args[1];
                    decimal rewardCost = Convert.ToDecimal(args[2]);
                    string userId = CurrentUserId;

                    decimal userCredits = Convert.ToDecimal(statTotalCredits.Text.Replace(",", ""));

                    if (userCredits >= rewardCost)
                    {
                        try
                        {
                            using (SqlConnection conn = new SqlConnection(ConfigurationManager.ConnectionStrings["SoorGreenDBConnectionString"].ConnectionString))
                            {
                                conn.Open();

                                string redemptionId = "RR" + DateTime.Now.ToString("yyyyMMddHHmmss");
                                string insertQuery = @"INSERT INTO RedemptionRequests 
                                                     (RedemptionId, UserId, Amount, Method, Status, RewardTitle, RequestedAt) 
                                                     VALUES (@RedemptionId, @UserId, @Amount, @Method, 'Pending', @RewardTitle, GETDATE())";

                                SqlCommand cmd = new SqlCommand(insertQuery, conn);
                                cmd.Parameters.AddWithValue("@RedemptionId", redemptionId);
                                cmd.Parameters.AddWithValue("@UserId", userId);
                                cmd.Parameters.AddWithValue("@Amount", rewardCost);
                                cmd.Parameters.AddWithValue("@Method", "voucher");
                                cmd.Parameters.AddWithValue("@RewardTitle", rewardTitle);
                                cmd.ExecuteNonQuery();

                                string deductQuery = @"INSERT INTO RewardPoints (UserId, Amount, Type, Reference, CreatedAt)
                                                     VALUES (@UserId, -@Amount, 'Redeem', @Reference, GETDATE())";
                                cmd.CommandText = deductQuery;
                                cmd.Parameters.Clear();
                                cmd.Parameters.AddWithValue("@UserId", userId);
                                cmd.Parameters.AddWithValue("@Amount", rewardCost);
                                cmd.Parameters.AddWithValue("@Reference", "Redemption: " + redemptionId);
                                cmd.ExecuteNonQuery();

                                string updateStockQuery = "UPDATE Rewards SET Stock = Stock - 1 WHERE RewardId = @RewardId AND Stock > 0";
                                cmd.CommandText = updateStockQuery;
                                cmd.Parameters.Clear();
                                cmd.Parameters.AddWithValue("@RewardId", rewardId);
                                cmd.ExecuteNonQuery();
                            }

                            LoadUserStats();
                            LoadRecentTransactions();
                            LoadRedemptionHistory();
                            LoadRewardsData();

                            ClientScript.RegisterStartupScript(this.GetType(), "SuccessToast",
                                "showRewardToast('Reward redeemed successfully! Check your redemption history.', 'success');", true);
                        }
                        catch (Exception ex)
                        {
                            ClientScript.RegisterStartupScript(this.GetType(), "ErrorToast",
                                "showRewardToast('Error: " + ex.Message.Replace("'", "\\'") + "', 'error');", true);
                        }
                    }
                    else
                    {
                        ClientScript.RegisterStartupScript(this.GetType(), "ErrorToast",
                            "showRewardToast('Insufficient credits! You need " + rewardCost.ToString("N0") + " credits.', 'error');", true);
                    }
                }
            }
        }

        protected void btnRefresh_Click(object sender, EventArgs e)
        {
            LoadUserStats();
            LoadRewardsData();
            LoadRecentTransactions();
            LoadAchievements();
            LoadRedemptionHistory();

            lblModalCredits.Text = statTotalCredits.Text;
        }

        protected void ddlRewardCategory_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadRewardsData();
        }

        protected void ddlHistoryPeriod_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadRedemptionHistory();
        }

        protected void btnSubmitRedemption_Click(object sender, EventArgs e)
        {
            decimal amount;
            if (!string.IsNullOrEmpty(txtRedemptionAmount.Text) &&
                decimal.TryParse(txtRedemptionAmount.Text, out amount))
            {
                decimal userCredits = Convert.ToDecimal(statTotalCredits.Text.Replace(",", ""));

                if (amount >= 100 && amount <= userCredits && !string.IsNullOrEmpty(ddlRedemptionMethod.SelectedValue))
                {
                    try
                    {
                        string userId = CurrentUserId;
                        string methodName = ddlRedemptionMethod.SelectedItem.Text;

                        using (SqlConnection conn = new SqlConnection(ConfigurationManager.ConnectionStrings["SoorGreenDBConnectionString"].ConnectionString))
                        {
                            conn.Open();

                            string redemptionId = "RR" + DateTime.Now.ToString("yyyyMMddHHmmss");
                            string insertQuery = @"INSERT INTO RedemptionRequests 
                                                 (RedemptionId, UserId, Amount, Method, Status, RewardTitle, RequestedAt) 
                                                 VALUES (@RedemptionId, @UserId, @Amount, @Method, 'Pending', @RewardTitle, GETDATE())";

                            SqlCommand cmd = new SqlCommand(insertQuery, conn);
                            cmd.Parameters.AddWithValue("@RedemptionId", redemptionId);
                            cmd.Parameters.AddWithValue("@UserId", userId);
                            cmd.Parameters.AddWithValue("@Amount", amount);
                            cmd.Parameters.AddWithValue("@Method", ddlRedemptionMethod.SelectedValue);
                            cmd.Parameters.AddWithValue("@RewardTitle", methodName + " Redemption");
                            cmd.ExecuteNonQuery();

                            string deductQuery = @"INSERT INTO RewardPoints (UserId, Amount, Type, Reference, CreatedAt)
                                                 VALUES (@UserId, -@Amount, 'Redeem', @Reference, GETDATE())";
                            cmd.CommandText = deductQuery;
                            cmd.Parameters.Clear();
                            cmd.Parameters.AddWithValue("@UserId", userId);
                            cmd.Parameters.AddWithValue("@Amount", amount);
                            cmd.Parameters.AddWithValue("@Reference", "Cash Redemption: " + redemptionId);
                            cmd.ExecuteNonQuery();
                        }

                        LoadUserStats();
                        LoadRecentTransactions();
                        LoadRedemptionHistory();

                        ClientScript.RegisterStartupScript(this.GetType(), "SuccessToast",
                            "showRewardToast('Redemption request submitted successfully! You will receive your funds in 1-2 business days.', 'success');", true);

                        txtRedemptionAmount.Text = "";
                        ddlRedemptionMethod.SelectedIndex = 0;

                        ClientScript.RegisterStartupScript(this.GetType(), "HideModal",
                            "if (window.bootstrap) { var modal = bootstrap.Modal.getInstance(document.getElementById('redemptionModal')); if (modal) modal.hide(); }", true);
                    }
                    catch (Exception ex)
                    {
                        ClientScript.RegisterStartupScript(this.GetType(), "ErrorToast",
                            "showRewardToast('Error processing request: " + ex.Message.Replace("'", "\\'") + "', 'error');", true);
                    }
                }
                else
                {
                    string errorMsg = "Invalid redemption amount! ";
                    if (amount < 100) errorMsg += "Minimum: 100 credits. ";
                    if (amount > userCredits) errorMsg += "Maximum: " + userCredits.ToString("N0") + " credits. ";
                    if (string.IsNullOrEmpty(ddlRedemptionMethod.SelectedValue)) errorMsg += "Please select a method.";

                    ClientScript.RegisterStartupScript(this.GetType(), "ErrorToast",
                        "showRewardToast('" + errorMsg + "', 'error');", true);
                }
            }
            else
            {
                ClientScript.RegisterStartupScript(this.GetType(), "ErrorToast",
                    "showRewardToast('Please enter a valid amount!', 'error');", true);
            }
        }

        protected void rptTransactions_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
            {
                DataRowView row = (DataRowView)e.Item.DataItem;
                string type = "";
                decimal amount = 0;

                if (row["Type"] != DBNull.Value)
                    type = row["Type"].ToString();

                if (row["Amount"] != DBNull.Value)
                    amount = Convert.ToDecimal(row["Amount"]);

                Literal litIcon = (Literal)e.Item.FindControl("litTransactionIcon");
                litIcon.Text = GetTransactionIcon(type);

                Literal litBadge = (Literal)e.Item.FindControl("litTypeBadge");
                litBadge.Text = GetTransactionTypeBadge(type);

                Literal litAmount = (Literal)e.Item.FindControl("litAmount");
                litAmount.Text = string.Format("<span class='{0}'>{1}{2:N2}</span>",
                    GetTransactionAmountClass(type),
                    amount > 0 ? "+" : "",
                    amount);
            }
        }

        protected void rptRedemptions_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
            {
                DataRowView row = (DataRowView)e.Item.DataItem;
                string status = "";
                DateTime requested = DateTime.Now;
                DateTime? processed = null;

                if (row["Status"] != DBNull.Value)
                    status = row["Status"].ToString();

                if (row["RequestedAt"] != DBNull.Value)
                    requested = Convert.ToDateTime(row["RequestedAt"]);

                if (row["ProcessedAt"] != DBNull.Value && row["ProcessedAt"] != null)
                    processed = Convert.ToDateTime(row["ProcessedAt"]);

                Literal litIcon = (Literal)e.Item.FindControl("litRedemptionIcon");
                litIcon.Text = GetRedemptionIcon(status);

                Literal litBadge = (Literal)e.Item.FindControl("litStatusBadge");
                litBadge.Text = GetRedemptionStatusBadge(status);

                Literal litNote = (Literal)e.Item.FindControl("litRedemptionNote");
                string note = "";
                switch (status)
                {
                    case "Pending":
                        note = "<div class='redemption-note'><i class='fas fa-info-circle me-1 text-warning'></i>Processing - Usually takes 1-2 business days</div>";
                        break;
                    case "Completed":
                        note = "<div class='redemption-note'><i class='fas fa-check-circle me-1 text-success'></i>Completed on " + FormatDate(processed) + "</div>";
                        break;
                    case "Rejected":
                        note = "<div class='redemption-note'><i class='fas fa-times-circle me-1 text-danger'></i>Rejected on " + FormatDate(processed) + "</div>";
                        break;
                    default:
                        note = "<div class='redemption-note'><i class='fas fa-info-circle me-1'></i>Status: " + status + "</div>";
                        break;
                }
                litNote.Text = note;
            }
        }

        public string GetRewardBadgeClass(string category)
        {
            if (string.IsNullOrEmpty(category))
                return "badge badge-secondary";

            switch (category.ToLower())
            {
                case "voucher":
                    return "badge badge-voucher";
                case "product":
                    return "badge badge-product";
                case "donation":
                    return "badge badge-donation";
                case "cash":
                    return "badge badge-cash";
                default:
                    return "badge badge-secondary";
            }
        }

        public string GetRewardIcon(string category)
        {
            if (string.IsNullOrEmpty(category))
                return "fas fa-gift";

            switch (category.ToLower())
            {
                case "voucher":
                    return "fas fa-ticket-alt";
                case "product":
                    return "fas fa-box";
                case "donation":
                    return "fas fa-heart";
                case "cash":
                    return "fas fa-money-bill-wave";
                default:
                    return "fas fa-gift";
            }
        }

        public string GetTransactionIcon(string type)
        {
            if (string.IsNullOrEmpty(type))
                return "<i class='fas fa-exchange-alt me-2'></i>";

            switch (type)
            {
                case "Credit":
                    return "<i class='fas fa-plus-circle text-success me-2'></i>";
                case "Redeem":
                    return "<i class='fas fa-minus-circle text-danger me-2'></i>";
                default:
                    return "<i class='fas fa-exchange-alt me-2'></i>";
            }
        }

        public string GetTransactionTypeBadge(string type)
        {
            if (string.IsNullOrEmpty(type))
                return "<span class='badge badge-secondary'>Unknown</span>";

            switch (type)
            {
                case "Credit":
                    return "<span class='badge badge-success'>Credit</span>";
                case "Redeem":
                    return "<span class='badge badge-danger'>Redeem</span>";
                default:
                    return "<span class='badge badge-secondary'>" + type + "</span>";
            }
        }

        public string GetTransactionAmountClass(string type)
        {
            if (string.IsNullOrEmpty(type))
                return "text-muted";

            switch (type)
            {
                case "Credit":
                    return "text-success fw-bold";
                case "Redeem":
                    return "text-danger fw-bold";
                default:
                    return "text-muted";
            }
        }

        public string GetRedemptionIcon(string status)
        {
            if (string.IsNullOrEmpty(status))
                return "<i class='fas fa-info-circle'></i>";

            switch (status)
            {
                case "Pending":
                    return "<i class='fas fa-clock text-warning'></i>";
                case "Completed":
                    return "<i class='fas fa-check-circle text-success'></i>";
                case "Rejected":
                    return "<i class='fas fa-times-circle text-danger'></i>";
                default:
                    return "<i class='fas fa-info-circle'></i>";
            }
        }

        public string GetRedemptionStatusBadge(string status)
        {
            if (string.IsNullOrEmpty(status))
                return "<span class='badge badge-secondary'>Unknown</span>";

            switch (status)
            {
                case "Pending":
                    return "<span class='badge badge-warning'>Pending</span>";
                case "Completed":
                    return "<span class='badge badge-success'>Completed</span>";
                case "Rejected":
                    return "<span class='badge badge-danger'>Rejected</span>";
                default:
                    return "<span class='badge badge-secondary'>" + status + "</span>";
            }
        }

        public string FormatDate(object dateObj)
        {
            if (dateObj == DBNull.Value || dateObj == null)
                return "N/A";

            DateTime date = Convert.ToDateTime(dateObj);
            return date.ToString("MMM dd, yyyy HH:mm");
        }

        public string FormatDateShort(object dateObj)
        {
            if (dateObj == DBNull.Value || dateObj == null)
                return "N/A";

            DateTime date = Convert.ToDateTime(dateObj);
            return date.ToString("MM/dd HH:mm");
        }

        public bool IsRewardAvailable(string costStr, string stockStr)
        {
            decimal cost = 0;
            int stock = 0;

            if (!string.IsNullOrEmpty(costStr))
                decimal.TryParse(costStr, out cost);

            if (!string.IsNullOrEmpty(stockStr))
                int.TryParse(stockStr, out stock);

            decimal userCredits = 0;
            if (!string.IsNullOrEmpty(statTotalCredits.Text))
                decimal.TryParse(statTotalCredits.Text.Replace(",", ""), out userCredits);

            return userCredits >= cost && (stock == 0 || stock > 0);
        }

        public int GetCurrentCredits()
        {
            decimal credits = 0;
            if (decimal.TryParse(statTotalCredits.Text.Replace(",", ""), out credits))
            {
                return (int)credits;
            }
            return 0;
        }

        protected void btnViewVouchers_Click(object sender, EventArgs e)
        {
            ddlRewardCategory.SelectedValue = "voucher";
            LoadRewardsData();

            ClientScript.RegisterStartupScript(this.GetType(), "ScrollToRewards",
                "document.querySelector('.rewards-list-container').scrollIntoView({behavior: 'smooth'});", true);
        }

        protected void btnAchievements_Click(object sender, EventArgs e)
        {
            ClientScript.RegisterStartupScript(this.GetType(), "ScrollToAchievements",
                "document.querySelector('.achievements-section').scrollIntoView({behavior: 'smooth'});", true);
        }
    }
}