using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Collections.Generic;

namespace SoorGreen.Admin
{
    public partial class SchedulePickups : System.Web.UI.Page
    {
        private string currentUserId;
        private DateTime currentMonth;
        private string connectionString = System.Configuration.ConfigurationManager.ConnectionStrings["SoorGreenDBConnectionString"].ConnectionString;

        // Pagination variables
        private int currentPage = 1;
        private int pageSize = 10;
        private int totalItems = 0;

        // Filter variables
        private string statusFilter = "all";
        private string dateFilter = "today";
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

                // Initialize current month
                currentMonth = DateTime.Now;

                // Load initial data
                LoadUserStats();
                LoadCalendar();
                LoadPickups();
                LoadAvailableReports();

                // Update month label
                UpdateMonthLabel();

                // Register startup scripts
                RegisterStartupScripts();
            }
            else
            {
                // Restore values from session
                if (Session["UserId"] != null)
                {
                    currentUserId = Session["UserId"].ToString();
                }

                if (Session["CurrentMonth"] != null)
                {
                    currentMonth = (DateTime)Session["CurrentMonth"];
                }
                else
                {
                    currentMonth = DateTime.Now;
                }

                if (Session["CurrentPage"] != null)
                {
                    currentPage = (int)Session["CurrentPage"];
                }
            }
        }

        private void LoadUserStats()
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    // Get pending pickups count
                    string pendingQuery = @"
                        SELECT COUNT(*) FROM PickupRequests pr
                        INNER JOIN WasteReports wr ON pr.ReportId = wr.ReportId
                        WHERE wr.UserId = @UserId AND pr.Status = 'Requested'";

                    using (SqlCommand cmd = new SqlCommand(pendingQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@UserId", currentUserId);
                        var result = cmd.ExecuteScalar();
                        statPending.InnerText = result != DBNull.Value ? result.ToString() : "0";
                    }

                    // Get scheduled pickups count
                    string scheduledQuery = @"
                        SELECT COUNT(*) FROM PickupRequests pr
                        INNER JOIN WasteReports wr ON pr.ReportId = wr.ReportId
                        WHERE wr.UserId = @UserId AND pr.Status = 'Scheduled'";

                    using (SqlCommand cmd = new SqlCommand(scheduledQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@UserId", currentUserId);
                        var result = cmd.ExecuteScalar();
                        statScheduled.InnerText = result != DBNull.Value ? result.ToString() : "0";
                    }

                    // Get in progress pickups count
                    string inProgressQuery = @"
                        SELECT COUNT(*) FROM PickupRequests pr
                        INNER JOIN WasteReports wr ON pr.ReportId = wr.ReportId
                        WHERE wr.UserId = @UserId AND pr.Status = 'InProgress'";

                    using (SqlCommand cmd = new SqlCommand(inProgressQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@UserId", currentUserId);
                        var result = cmd.ExecuteScalar();
                        statInProgress.InnerText = result != DBNull.Value ? result.ToString() : "0";
                    }

                    // Get completed pickups count
                    string completedQuery = @"
                        SELECT COUNT(*) FROM PickupRequests pr
                        INNER JOIN WasteReports wr ON pr.ReportId = wr.ReportId
                        WHERE wr.UserId = @UserId AND pr.Status = 'Collected'";

                    using (SqlCommand cmd = new SqlCommand(completedQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@UserId", currentUserId);
                        var result = cmd.ExecuteScalar();
                        statCompleted.InnerText = result != DBNull.Value ? result.ToString() : "0";
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("LoadUserStats Error: " + ex.Message);
            }
        }

        private void LoadCalendar()
        {
            try
            {
                // Get first day of month
                DateTime firstDay = new DateTime(currentMonth.Year, currentMonth.Month, 1);
                DateTime lastDay = firstDay.AddMonths(1).AddDays(-1);

                // Get day of week for first day (0 = Sunday, 6 = Saturday)
                int startDay = (int)firstDay.DayOfWeek;

                // Calculate total days to display (including previous/next month days)
                int totalCells = 42; // 6 weeks * 7 days

                // Create calendar data
                DataTable calendarData = new DataTable();
                calendarData.Columns.Add("Date", typeof(DateTime));
                calendarData.Columns.Add("Day", typeof(string));
                calendarData.Columns.Add("CssClass", typeof(string));
                calendarData.Columns.Add("PickupCounts", typeof(Dictionary<string, int>));

                // Fill calendar with days
                DateTime currentDate = firstDay.AddDays(-startDay);

                for (int i = 0; i < totalCells; i++)
                {
                    DataRow row = calendarData.NewRow();
                    row["Date"] = currentDate;
                    row["Day"] = currentDate.Day.ToString();

                    // Determine CSS class
                    string cssClass = "";
                    if (currentDate.Month != currentMonth.Month)
                    {
                        cssClass = "other-month";
                    }
                    else if (currentDate.Date == DateTime.Now.Date)
                    {
                        cssClass = "today";
                    }

                    row["CssClass"] = cssClass;

                    // Get pickup counts for this day
                    row["PickupCounts"] = GetPickupCountsForDate(currentDate);

                    calendarData.Rows.Add(row);
                    currentDate = currentDate.AddDays(1);
                }

                // Bind to repeater
                rptCalendarDays.DataSource = calendarData;
                rptCalendarDays.DataBind();

                // Store current month in session
                Session["CurrentMonth"] = currentMonth;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("LoadCalendar Error: " + ex.Message);
            }
        }

        private Dictionary<string, int> GetPickupCountsForDate(DateTime date)
        {
            var counts = new Dictionary<string, int>
            {
                { "pending", 0 },
                { "scheduled", 0 },
                { "inprogress", 0 },
                { "completed", 0 },
                { "cancelled", 0 }
            };

            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    string query = @"
                        SELECT pr.Status, COUNT(*) as Count
                        FROM PickupRequests pr
                        INNER JOIN WasteReports wr ON pr.ReportId = wr.ReportId
                        WHERE wr.UserId = @UserId 
                        AND CAST(pr.ScheduledAt AS DATE) = @Date
                        GROUP BY pr.Status";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@UserId", currentUserId);
                        cmd.Parameters.AddWithValue("@Date", date.Date);

                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                string status = reader["Status"].ToString().ToLower();
                                int count = Convert.ToInt32(reader["Count"]);

                                if (counts.ContainsKey(status))
                                {
                                    counts[status] = count;
                                }
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("GetPickupCountsForDate Error: " + ex.Message);
            }

            return counts;
        }

        public string GetPickupDots(object pickupCountsObj)
        {
            if (pickupCountsObj == null) return "";

            var pickupCounts = pickupCountsObj as Dictionary<string, int>;
            if (pickupCounts == null) return "";

            string dotsHtml = "";
            int totalPickups = 0;

            // Create dots for each status with pickups
            foreach (var kvp in pickupCounts)
            {
                if (kvp.Value > 0)
                {
                    for (int i = 0; i < Math.Min(kvp.Value, 3); i++) // Max 3 dots per status
                    {
                        // Fixed: Using string concatenation instead of string interpolation
                        dotsHtml += "<div class='pickup-dot " + kvp.Key + "'></div>";
                        totalPickups++;

                        if (totalPickups >= 5) break; // Max 5 total dots
                    }
                }

                if (totalPickups >= 5) break;
            }

            return dotsHtml;
        }

        private void LoadPickups()
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    // Build query with filters
                    string query = BuildPickupQuery();

                    // First, get total count for pagination
                    string countQuery = "SELECT COUNT(*) FROM (" + query + ") AS SubQuery";
                    using (SqlCommand countCmd = new SqlCommand(countQuery, conn))
                    {
                        AddQueryParameters(countCmd);
                        totalItems = Convert.ToInt32(countCmd.ExecuteScalar());
                    }

                    // Now get paginated data
                    query = @"
                        SELECT * FROM (
                            " + query + @"
                        ) AS FilteredPickups
                        ORDER BY ScheduledAt DESC
                        OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        AddQueryParameters(cmd);
                        cmd.Parameters.AddWithValue("@Offset", (currentPage - 1) * pageSize);
                        cmd.Parameters.AddWithValue("@PageSize", pageSize);

                        using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                        {
                            DataTable dt = new DataTable();
                            da.Fill(dt);

                            if (dt.Rows.Count > 0)
                            {
                                rptPickups.DataSource = dt;
                                rptPickups.DataBind();
                                pnlPickupCards.Visible = true;
                                pnlEmptyState.Visible = false;
                            }
                            else
                            {
                                pnlPickupCards.Visible = false;
                                pnlEmptyState.Visible = true;
                            }

                            // Update pagination labels
                            UpdatePaginationLabels();
                            LoadPageNumbers();
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("LoadPickups Error: " + ex.Message);
                pnlPickupCards.Visible = false;
                pnlEmptyState.Visible = true;
            }
        }

        private string BuildPickupQuery()
        {
            string baseQuery = @"
                SELECT 
                    pr.PickupId,
                    pr.ReportId,
                    pr.Status,
                    CASE 
                        WHEN pr.Status = 'Requested' THEN 'pending'
                        WHEN pr.Status = 'Scheduled' THEN 'scheduled'
                        WHEN pr.Status = 'InProgress' THEN 'inprogress'
                        WHEN pr.Status = 'Collected' THEN 'completed'
                        WHEN pr.Status = 'Cancelled' THEN 'cancelled'
                        ELSE 'pending'
                    END as StatusDisplay,
                    pr.ScheduledAt,
                    FORMAT(pr.ScheduledAt, 'hh:mm tt') as ScheduledTime,
                    wr.EstimatedKg as Weight,
                    wr.Address,
                    wt.Name as WasteType,
                    (wr.EstimatedKg * wt.CreditPerKg) as Reward
                FROM PickupRequests pr
                INNER JOIN WasteReports wr ON pr.ReportId = wr.ReportId
                INNER JOIN WasteTypes wt ON wr.WasteTypeId = wt.WasteTypeId
                WHERE wr.UserId = @UserId";

            // Apply status filter
            if (!string.IsNullOrEmpty(statusFilter) && statusFilter != "all")
            {
                string statusValue = GetStatusDatabaseValue(statusFilter);
                baseQuery += " AND pr.Status = @StatusFilter";
            }

            // Apply date filter
            if (!string.IsNullOrEmpty(dateFilter))
            {
                switch (dateFilter)
                {
                    case "today":
                        baseQuery += " AND CAST(pr.ScheduledAt AS DATE) = CAST(GETDATE() AS DATE)";
                        break;
                    case "week":
                        baseQuery += " AND pr.ScheduledAt >= DATEADD(DAY, -7, GETDATE())";
                        break;
                    case "month":
                        baseQuery += " AND pr.ScheduledAt >= DATEADD(MONTH, -1, GETDATE())";
                        break;
                    case "upcoming":
                        baseQuery += " AND pr.ScheduledAt > GETDATE()";
                        break;
                    case "past":
                        baseQuery += " AND pr.ScheduledAt < GETDATE()";
                        break;
                }
            }

            // Apply search filter
            if (!string.IsNullOrEmpty(searchQuery))
            {
                baseQuery += @" AND (
                    pr.PickupId LIKE @SearchQuery OR
                    pr.ReportId LIKE @SearchQuery OR
                    wr.Address LIKE @SearchQuery OR
                    wt.Name LIKE @SearchQuery
                )";
            }

            return baseQuery;
        }

        private void AddQueryParameters(SqlCommand cmd)
        {
            cmd.Parameters.AddWithValue("@UserId", currentUserId);

            if (!string.IsNullOrEmpty(statusFilter) && statusFilter != "all")
            {
                cmd.Parameters.AddWithValue("@StatusFilter", GetStatusDatabaseValue(statusFilter));
            }

            if (!string.IsNullOrEmpty(searchQuery))
            {
                cmd.Parameters.AddWithValue("@SearchQuery", "%" + searchQuery + "%");
            }
        }

        private string GetStatusDatabaseValue(string displayStatus)
        {
            switch (displayStatus)
            {
                case "pending": return "Requested";
                case "scheduled": return "Scheduled";
                case "inprogress": return "InProgress";
                case "completed": return "Collected";
                case "cancelled": return "Cancelled";
                default: return "Requested";
            }
        }

        private void UpdatePaginationLabels()
        {
            int start = ((currentPage - 1) * pageSize) + 1;
            int end = Math.Min(currentPage * pageSize, totalItems);

            lblStartCount.Text = start.ToString();
            lblEndCount.Text = end.ToString();
            lblTotalCount.Text = totalItems.ToString();

            // Enable/disable navigation buttons
            btnPrevPage.Enabled = currentPage > 1;
            btnNextPage.Enabled = currentPage < Math.Ceiling((double)totalItems / pageSize);
        }

        private void LoadPageNumbers()
        {
            int totalPages = (int)Math.Ceiling((double)totalItems / pageSize);

            // Show max 5 page numbers
            int startPage = Math.Max(1, currentPage - 2);
            int endPage = Math.Min(totalPages, startPage + 4);

            if (endPage - startPage < 4)
            {
                startPage = Math.Max(1, endPage - 4);
            }

            var pageNumbers = new List<dynamic>();
            for (int i = startPage; i <= endPage; i++)
            {
                pageNumbers.Add(new { PageNumber = i, CurrentPage = currentPage });
            }

            rptPageNumbers.DataSource = pageNumbers;
            rptPageNumbers.DataBind();
        }

        private void LoadAvailableReports()
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    string query = @"
                        SELECT wr.ReportId, wr.EstimatedKg, wt.Name as WasteType, wr.Address,
                               (wr.EstimatedKg * wt.CreditPerKg) as Reward
                        FROM WasteReports wr
                        INNER JOIN WasteTypes wt ON wr.WasteTypeId = wt.WasteTypeId
                        LEFT JOIN PickupRequests pr ON wr.ReportId = pr.ReportId
                        WHERE wr.UserId = @UserId 
                        AND (pr.PickupId IS NULL OR pr.Status = 'Cancelled')
                        ORDER BY wr.CreatedAt DESC";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@UserId", currentUserId);

                        using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                        {
                            DataTable dt = new DataTable();
                            da.Fill(dt);

                            ddlReports.DataSource = dt;
                            ddlReports.DataTextField = "ReportId";
                            ddlReports.DataValueField = "ReportId";
                            ddlReports.DataBind();

                            if (dt.Rows.Count > 0)
                            {
                                ddlReports.Items.Insert(0, new ListItem("-- Select Report --", ""));
                            }
                            else
                            {
                                ddlReports.Items.Clear();
                                ddlReports.Items.Add(new ListItem("No available reports", ""));
                                ddlReports.Enabled = false;
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("LoadAvailableReports Error: " + ex.Message);
            }
        }

        protected void btnPrevMonth_Click(object sender, EventArgs e)
        {
            currentMonth = currentMonth.AddMonths(-1);
            LoadCalendar();
            UpdateMonthLabel();
        }

        protected void btnNextMonth_Click(object sender, EventArgs e)
        {
            currentMonth = currentMonth.AddMonths(1);
            LoadCalendar();
            UpdateMonthLabel();
        }

        protected void btnToday_Click(object sender, EventArgs e)
        {
            currentMonth = DateTime.Now;
            LoadCalendar();
            UpdateMonthLabel();
        }

        private void UpdateMonthLabel()
        {
            lblCurrentMonth.Text = currentMonth.ToString("MMMM yyyy");
        }

        protected void ddlStatusFilter_SelectedIndexChanged(object sender, EventArgs e)
        {
            statusFilter = ddlStatusFilter.SelectedValue;
            currentPage = 1;
            Session["CurrentPage"] = currentPage;
            LoadPickups();
        }

        protected void ddlDateFilter_SelectedIndexChanged(object sender, EventArgs e)
        {
            dateFilter = ddlDateFilter.SelectedValue;
            currentPage = 1;
            Session["CurrentPage"] = currentPage;
            LoadPickups();
        }

        protected void txtSearch_TextChanged(object sender, EventArgs e)
        {
            searchQuery = txtSearch.Text.Trim();
            currentPage = 1;
            Session["CurrentPage"] = currentPage;
            LoadPickups();
        }

        protected void btnPrevPage_Click(object sender, EventArgs e)
        {
            if (currentPage > 1)
            {
                currentPage--;
                Session["CurrentPage"] = currentPage;
                LoadPickups();
            }
        }

        protected void btnNextPage_Click(object sender, EventArgs e)
        {
            int totalPages = (int)Math.Ceiling((double)totalItems / pageSize);
            if (currentPage < totalPages)
            {
                currentPage++;
                Session["CurrentPage"] = currentPage;
                LoadPickups();
            }
        }

        protected void btnPage_Click(object sender, EventArgs e)
        {
            LinkButton btn = (LinkButton)sender;
            currentPage = Convert.ToInt32(btn.CommandArgument);
            Session["CurrentPage"] = currentPage;
            LoadPickups();
        }

        protected void rptPickups_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            string pickupId = e.CommandArgument.ToString();

            switch (e.CommandName)
            {
                case "ViewDetails":
                    ViewPickupDetails(pickupId);
                    break;

                case "Reschedule":
                    ReschedulePickup(pickupId);
                    break;

                case "Cancel":
                    CancelPickup(pickupId);
                    break;
            }
        }

        private void ViewPickupDetails(string pickupId)
        {
            ShowMessage("Viewing details for pickup: " + pickupId, "info");
        }

        private void ReschedulePickup(string pickupId)
        {
            ShowMessage("Rescheduling pickup: " + pickupId, "info");
            ScriptManager.RegisterStartupScript(this, GetType(), "ShowRescheduleModal",
                "openScheduleModal();", true);
        }

        private void CancelPickup(string pickupId)
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    string query = @"
                        UPDATE PickupRequests 
                        SET Status = 'Cancelled', 
                            CompletedAt = GETDATE()
                        WHERE PickupId = @PickupId";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@PickupId", pickupId);
                        int rowsAffected = cmd.ExecuteNonQuery();

                        if (rowsAffected > 0)
                        {
                            ShowMessage("Pickup cancelled successfully!", "success");
                            LoadUserStats();
                            LoadPickups();
                            LoadCalendar();
                        }
                        else
                        {
                            ShowMessage("Failed to cancel pickup.", "error");
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Error cancelling pickup: " + ex.Message, "error");
            }
        }

        protected void btnScheduleNew_Click(object sender, EventArgs e)
        {
            txtPickupDate.Text = DateTime.Now.AddDays(1).ToString("yyyy-MM-dd");
            ddlTimeSlot.SelectedIndex = 0;
            txtInstructions.Text = "";

            ScriptManager.RegisterStartupScript(this, GetType(), "ShowScheduleModal",
                "openScheduleModal();", true);
        }

        protected void ddlReports_SelectedIndexChanged(object sender, EventArgs e)
        {
            string reportId = ddlReports.SelectedValue;

            if (!string.IsNullOrEmpty(reportId))
            {
                LoadReportDetails(reportId);
            }
            else
            {
                pnlReportDetails.Visible = false;
                pnlNoReport.Visible = true;
            }
        }

        private void LoadReportDetails(string reportId)
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    string query = @"
                        SELECT wr.ReportId, wr.EstimatedKg, wt.Name as WasteType, 
                               wr.Address, (wr.EstimatedKg * wt.CreditPerKg) as Reward
                        FROM WasteReports wr
                        INNER JOIN WasteTypes wt ON wr.WasteTypeId = wt.WasteTypeId
                        WHERE wr.ReportId = @ReportId AND wr.UserId = @UserId";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@ReportId", reportId);
                        cmd.Parameters.AddWithValue("@UserId", currentUserId);

                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                detailReportId.InnerText = reader["ReportId"].ToString();
                                detailWasteType.InnerText = reader["WasteType"].ToString();
                                detailWeight.InnerText = reader["EstimatedKg"].ToString() + " kg";
                                detailAddress.InnerText = reader["Address"].ToString();
                                detailReward.InnerText = reader["Reward"].ToString() + " XP";

                                pnlReportDetails.Visible = true;
                                pnlNoReport.Visible = false;
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("LoadReportDetails Error: " + ex.Message);
            }
        }

        protected void btnSubmitSchedule_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(ddlReports.SelectedValue))
            {
                ShowMessage("Please select a report to schedule.", "error");
                return;
            }

            if (string.IsNullOrEmpty(txtPickupDate.Text))
            {
                ShowMessage("Please select a pickup date.", "error");
                return;
            }

            try
            {
                DateTime pickupDate = DateTime.Parse(txtPickupDate.Text);
                TimeSpan timeSlot = GetTimeSlot(ddlTimeSlot.SelectedValue);
                DateTime scheduledDateTime = pickupDate.Add(timeSlot);

                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    using (SqlTransaction transaction = conn.BeginTransaction())
                    {
                        try
                        {
                            // Check if pickup already exists for this report
                            string checkQuery = @"
                                SELECT COUNT(*) FROM PickupRequests 
                                WHERE ReportId = @ReportId AND Status NOT IN ('Cancelled', 'Collected')";

                            using (SqlCommand checkCmd = new SqlCommand(checkQuery, conn, transaction))
                            {
                                checkCmd.Parameters.AddWithValue("@ReportId", ddlReports.SelectedValue);
                                int existingCount = Convert.ToInt32(checkCmd.ExecuteScalar());

                                if (existingCount > 0)
                                {
                                    ShowMessage("This report already has an active pickup scheduled.", "error");
                                    transaction.Rollback();
                                    return;
                                }
                            }

                            // Generate new Pickup ID
                            string pickupId = GeneratePickupId(conn, transaction);

                            // Insert pickup request
                            string insertQuery = @"
                                INSERT INTO PickupRequests (PickupId, ReportId, Status, ScheduledAt, CreatedAt)
                                VALUES (@PickupId, @ReportId, 'Scheduled', @ScheduledAt, GETDATE())";

                            using (SqlCommand cmd = new SqlCommand(insertQuery, conn, transaction))
                            {
                                cmd.Parameters.AddWithValue("@PickupId", pickupId);
                                cmd.Parameters.AddWithValue("@ReportId", ddlReports.SelectedValue);
                                cmd.Parameters.AddWithValue("@ScheduledAt", scheduledDateTime);

                                cmd.ExecuteNonQuery();
                            }

                            // Insert notification
                            string notificationQuery = @"
                                INSERT INTO Notifications (NotificationId, UserId, Title, Message, CreatedAt)
                                VALUES (@NotificationId, @UserId, @Title, @Message, GETDATE())";

                            using (SqlCommand notifCmd = new SqlCommand(notificationQuery, conn, transaction))
                            {
                                string notifId = "NT" + DateTime.Now.ToString("MMddHHmmss");

                                notifCmd.Parameters.AddWithValue("@NotificationId", notifId);
                                notifCmd.Parameters.AddWithValue("@UserId", currentUserId);
                                notifCmd.Parameters.AddWithValue("@Title", "Pickup Scheduled");
                                notifCmd.Parameters.AddWithValue("@Message",
                                    "Your waste pickup has been scheduled for " + scheduledDateTime.ToString("MMM dd, yyyy hh:mm tt"));

                                notifCmd.ExecuteNonQuery();
                            }

                            transaction.Commit();

                            ShowMessage("Pickup scheduled successfully!", "success");

                            // Refresh data
                            LoadUserStats();
                            LoadPickups();
                            LoadCalendar();
                            LoadAvailableReports();

                            // Close modal
                            ScriptManager.RegisterStartupScript(this, GetType(), "CloseModal",
                                "$('#scheduleModal').modal('hide');", true);
                        }
                        catch (Exception ex)
                        {
                            transaction.Rollback();
                            ShowMessage("Error scheduling pickup: " + ex.Message, "error");
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Error: " + ex.Message, "error");
            }
        }

        private TimeSpan GetTimeSlot(string timeSlotValue)
        {
            switch (timeSlotValue)
            {
                case "morning": return new TimeSpan(8, 0, 0); // 8 AM
                case "afternoon": return new TimeSpan(12, 0, 0); // 12 PM
                case "evening": return new TimeSpan(16, 0, 0); // 4 PM
                default: return new TimeSpan(10, 0, 0); // Default 10 AM
            }
        }

        private string GeneratePickupId(SqlConnection conn, SqlTransaction transaction)
        {
            string query = @"
                SELECT 'PK' + RIGHT('000' + CAST(ISNULL(MAX(CAST(SUBSTRING(PickupId, 3, LEN(PickupId)) AS INT)), 0) + 1 AS VARCHAR(10)), 3)
                FROM PickupRequests 
                WHERE PickupId LIKE 'PK%'";

            using (SqlCommand cmd = new SqlCommand(query, conn, transaction))
            {
                return cmd.ExecuteScalar().ToString();
            }
        }

        protected void btnRefresh_Click(object sender, EventArgs e)
        {
            LoadUserStats();
            LoadPickups();
            LoadCalendar();
            ShowMessage("Data refreshed successfully!", "success");
        }

        protected void btnExport_Click(object sender, EventArgs e)
        {
            ShowMessage("Export feature coming soon!", "info");
        }

        public string GetStatusIcon(string status)
        {
            switch (status.ToLower())
            {
                case "pending": return "fas fa-clock";
                case "scheduled": return "fas fa-calendar-check";
                case "inprogress": return "fas fa-truck-loading";
                case "completed": return "fas fa-check-circle";
                case "cancelled": return "fas fa-times-circle";
                default: return "fas fa-question-circle";
            }
        }

        private void ShowMessage(string message, string type)
        {
            string icon = "exclamation-circle";
            string upperType = type.ToUpper();

            switch (type.ToLower())
            {
                case "success": icon = "check-circle"; break;
                case "warning": icon = "exclamation-triangle"; break;
                case "error": icon = "exclamation-circle"; break;
                case "info": icon = "info-circle"; break;
            }

            // Fixed: Using string concatenation instead of string interpolation
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

            ScriptManager.RegisterStartupScript(this, GetType(), "ShowMessage_" + Guid.NewGuid(), script, true);
        }

        private void RegisterStartupScripts()
        {
            string script = @"
                // Make functions globally available
                window.openScheduleModal = function() {
                    var modal = new bootstrap.Modal(document.getElementById('scheduleModal'));
                    modal.show();
                };
                
                // Initialize calendar interactions
                document.addEventListener('DOMContentLoaded', function() {
                    // Calendar day selection
                    var calendarDays = document.querySelectorAll('.calendar-day-cell');
                    calendarDays.forEach(function(day) {
                        day.addEventListener('click', function() {
                            // Remove previous selections
                            calendarDays.forEach(function(d) {
                                d.classList.remove('selected');
                            });
                            // Add selection to clicked day
                            this.classList.add('selected');
                            
                            // Trigger filtering by date (optional)
                            var date = this.getAttribute('data-date');
                            if (date) {
                                console.log('Selected date:', date);
                                // You could trigger a postback here if needed
                            }
                        });
                    });
                    
                    // Auto-refresh every 30 seconds
                    setInterval(function() {
                        // Check for updates
                        console.log('Checking for updates...');
                        // You could trigger a partial postback here
                    }, 30000);
                });
            ";

            ScriptManager.RegisterClientScriptBlock(this, GetType(), "InitializeScripts", script, true);
        }
    }
}