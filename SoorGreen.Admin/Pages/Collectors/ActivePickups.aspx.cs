using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace SoorGreen.Collectors
{
    public partial class ActivePickups : System.Web.UI.Page
    {
        protected string CurrentUserId = "";
        protected string CurrentUserRole = "";

        protected void Page_Load(object sender, EventArgs e)
        {
            try
            {
                // Check if user is logged in
                if (Session["UserID"] == null)
                {
                    Response.Redirect("~/Login.aspx?returnUrl=" + Server.UrlEncode(Request.Url.AbsolutePath));
                    return;
                }

                // Get session values
                CurrentUserId = Session["UserID"].ToString();
                CurrentUserRole = Session["UserRole"] != null ? Session["UserRole"].ToString() : "";

                // Check if user is a collector
                if (!IsCollectorRole(CurrentUserRole))
                {
                    ShowErrorMessage("Access denied. This page is for waste collectors only.");
                    string script = "setTimeout(function() { window.location.href = '/Default.aspx'; }, 3000);";
                    ScriptManager.RegisterStartupScript(this, GetType(), "redirect", script, true);
                    return;
                }

                // Display collector name in title
                //if (Session["UserName"] != null)
                //{
                //    lblCollectorName.Text = Session["UserName"].ToString();
                //}

                if (!IsPostBack)
                {
                    BindStats();
                    BindActivePickups();
                }
            }
            catch (Exception ex)
            {
                ShowErrorMessage("Error loading page: " + ex.Message);
            }
        }

        private bool IsCollectorRole(string role)
        {
            // Check if role is collector (R002 or COLL)
            return role == "R002" || role == "COLL";
        }

        private bool UserExists(string userId)
        {
            if (string.IsNullOrEmpty(userId)) return false;

            try
            {
                using (SqlConnection conn = new SqlConnection(GetConnectionString()))
                {
                    string query = "SELECT COUNT(*) FROM Users WHERE UserId = @UserId AND (RoleId = 'R002' OR RoleId = 'COLL')";
                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@UserId", userId);
                        conn.Open();
                        int count = Convert.ToInt32(cmd.ExecuteScalar());
                        return count > 0;
                    }
                }
            }
            catch
            {
                return false;
            }
        }

        private void BindStats()
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(GetConnectionString()))
                {
                    conn.Open();

                    // Total pending pickups
                    string pendingQuery = @"
                        SELECT COUNT(*) as TotalPending 
                        FROM PickupRequests 
                        WHERE Status IN ('Requested', 'Assigned')";

                    using (SqlCommand cmd = new SqlCommand(pendingQuery, conn))
                    {
                        object result = cmd.ExecuteScalar();
                        lblTotalPending.Text = (result != null && result != DBNull.Value) ? result.ToString() : "0";
                    }

                    // Pickups assigned to current collector
                    string assignedQuery = @"
                        SELECT COUNT(*) as AssignedToMe 
                        FROM PickupRequests 
                        WHERE Status = 'Assigned' AND CollectorId = @CollectorId";

                    using (SqlCommand cmd = new SqlCommand(assignedQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@CollectorId", CurrentUserId);
                        object result = cmd.ExecuteScalar();
                        lblAssignedPickups.Text = (result != null && result != DBNull.Value) ? result.ToString() : "0";
                    }

                    // Total estimated weight
                    string weightQuery = @"
                        SELECT ISNULL(SUM(wr.EstimatedKg), 0) as TotalWeight
                        FROM PickupRequests pr
                        JOIN WasteReports wr ON pr.ReportId = wr.ReportId
                        WHERE pr.Status IN ('Requested', 'Assigned')";

                    using (SqlCommand cmd = new SqlCommand(weightQuery, conn))
                    {
                        object result = cmd.ExecuteScalar();
                        decimal totalWeight = (result != null && result != DBNull.Value) ? Convert.ToDecimal(result) : 0;
                        lblTotalWeight.Text = totalWeight.ToString("F1");
                    }

                    // Today's pickups
                    string todayQuery = @"
                        SELECT COUNT(*) as TodayPickups
                        FROM PickupRequests pr
                        WHERE CONVERT(DATE, pr.ScheduledAt) = CONVERT(DATE, GETDATE())
                        AND pr.Status IN ('Requested', 'Assigned')";

                    using (SqlCommand cmd = new SqlCommand(todayQuery, conn))
                    {
                        object result = cmd.ExecuteScalar();
                        lblTodayPickups.Text = (result != null && result != DBNull.Value) ? result.ToString() : "0";
                    }

                    // Set current date
                    lblStatsDate.Text = DateTime.Now.ToString("MMMM dd, yyyy");
                }
            }
            catch (Exception ex)
            {
                ShowErrorMessage("Error loading statistics: " + ex.Message);
            }
        }

        private void BindActivePickups()
        {
            try
            {
                string query = @"
                    SELECT 
                        p.PickupId,
                        p.ReportId,
                        p.Status,
                        p.CollectorId,
                        p.ScheduledAt,
                        wr.EstimatedKg,
                        wr.Address,
                        wr.Landmark,
                        wr.CreatedAt,
                        wr.PhotoUrl,
                        wt.Name as WasteType,
                        u.FullName as CitizenName,
                        u.Phone as CitizenPhone,
                        u.Email as CitizenEmail,
                        c.FullName as CollectorName
                    FROM PickupRequests p
                    JOIN WasteReports wr ON p.ReportId = wr.ReportId
                    JOIN WasteTypes wt ON wr.WasteTypeId = wt.WasteTypeId
                    JOIN Users u ON wr.UserId = u.UserId
                    LEFT JOIN Users c ON p.CollectorId = c.UserId
                    WHERE p.Status IN ('Requested', 'Assigned')";

                // Apply filters
                if (ddlWasteTypeFilter.SelectedValue != "all")
                {
                    query += " AND wt.Name = @WasteType";
                }

                if (ddlStatusFilter.SelectedValue != "all")
                {
                    query += " AND p.Status = @Status";
                }

                if (!string.IsNullOrEmpty(txtSearch.Text))
                {
                    query += " AND (wr.Address LIKE @Search OR u.FullName LIKE @Search OR p.PickupId LIKE @Search)";
                }

                // Apply sorting
                if (ddlSortPickups.SelectedValue == "weight")
                {
                    query += " ORDER BY wr.EstimatedKg DESC";
                }
                else
                {
                    query += " ORDER BY wr.CreatedAt DESC";
                }

                using (SqlConnection conn = new SqlConnection(GetConnectionString()))
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    // Add parameters safely
                    if (ddlWasteTypeFilter.SelectedValue != "all")
                    {
                        cmd.Parameters.AddWithValue("@WasteType", ddlWasteTypeFilter.SelectedValue);
                    }

                    if (ddlStatusFilter.SelectedValue != "all")
                    {
                        cmd.Parameters.AddWithValue("@Status", ddlStatusFilter.SelectedValue);
                    }

                    if (!string.IsNullOrEmpty(txtSearch.Text))
                    {
                        cmd.Parameters.AddWithValue("@Search", "%" + txtSearch.Text + "%");
                    }

                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        da.Fill(dt);

                        if (dt.Rows.Count > 0)
                        {
                            rptActivePickups.DataSource = dt;
                            rptActivePickups.DataBind();
                            pnlNoActivePickups.Visible = false;
                        }
                        else
                        {
                            rptActivePickups.DataSource = null;
                            rptActivePickups.DataBind();
                            pnlNoActivePickups.Visible = true;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                ShowErrorMessage("Error loading pickups: " + ex.Message);
                pnlNoActivePickups.Visible = true;
            }
        }

        // Repeater ItemDataBound Event Handler
        protected void rptActivePickups_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
            {
                try
                {
                    DataRowView rowView = (DataRowView)e.Item.DataItem;

                    // Find controls
                    LinkButton btnAssignToMe = (LinkButton)e.Item.FindControl("btnAssignToMe");
                    LinkButton btnStartPickup = (LinkButton)e.Item.FindControl("btnStartPickup");

                    if (btnAssignToMe != null)
                    {
                        string status = rowView["Status"].ToString();
                        btnAssignToMe.Visible = IsAssignable(status);

                        // Set confirmation - FIXED: No string interpolation
                        string pickupId = rowView["PickupId"].ToString();
                        btnAssignToMe.OnClientClick = "return confirmAssign('" + pickupId + "');";
                    }

                    if (btnStartPickup != null)
                    {
                        string status = rowView["Status"].ToString();
                        string collectorId = rowView["CollectorId"] != DBNull.Value ? rowView["CollectorId"].ToString() : "";
                        btnStartPickup.Visible = IsStartable(status, collectorId);

                        // Set confirmation - FIXED: No string interpolation
                        string pickupId = rowView["PickupId"].ToString();
                        btnStartPickup.OnClientClick = "return confirmStart('" + pickupId + "');";
                    }
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Debug.WriteLine("Error in ItemDataBound: " + ex.Message);
                }
            }
        }

        // Repeater ItemCommand Event Handler
        protected void rptActivePickups_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            try
            {
                string pickupId = e.CommandArgument.ToString();

                switch (e.CommandName)
                {
                    case "AssignToMe":
                        AssignPickupToMe(pickupId);
                        break;
                    case "StartPickup":
                        StartPickup(pickupId);
                        break;
                }
            }
            catch (Exception ex)
            {
                ShowErrorMessage("Error processing action: " + ex.Message);
            }
        }

        private void AssignPickupToMe(string pickupId)
        {
            try
            {
                if (string.IsNullOrEmpty(CurrentUserId) || !UserExists(CurrentUserId))
                {
                    ShowErrorMessage("Invalid collector ID. Please log in again.");
                    return;
                }

                using (SqlConnection conn = new SqlConnection(GetConnectionString()))
                {
                    string query = @"
                        UPDATE PickupRequests 
                        SET CollectorId = @CollectorId, 
                            Status = 'Assigned',
                            ScheduledAt = GETDATE()
                        WHERE PickupId = @PickupId 
                        AND Status = 'Requested'";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@CollectorId", CurrentUserId);
                        cmd.Parameters.AddWithValue("@PickupId", pickupId);

                        conn.Open();
                        int rowsAffected = cmd.ExecuteNonQuery();

                        if (rowsAffected > 0)
                        {
                            LogUserActivity(CurrentUserId, "PickupAssigned", "Assigned pickup " + pickupId + " to collector");
                            BindStats();
                            BindActivePickups();
                            ShowSuccessMessage("Pickup " + pickupId + " assigned successfully!");
                        }
                        else
                        {
                            ShowErrorMessage("Pickup " + pickupId + " could not be assigned. It may already be assigned to someone else.");
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                ShowErrorMessage("Error assigning pickup: " + ex.Message);
            }
        }

        private void StartPickup(string pickupId)
        {
            // Redirect to verification page
            Response.Redirect("PickupVerification.aspx?pickupId=" + pickupId);
        }

        // Data Binding Methods (called from ASPX)
        public string BindDate(object date)
        {
            if (date == null || date == DBNull.Value)
                return "N/A";

            DateTime dateTime = Convert.ToDateTime(date);

            // If today, show time, else show date
            if (dateTime.Date == DateTime.Today)
                return dateTime.ToString("HH:mm");
            else if (dateTime.Date == DateTime.Today.AddDays(-1))
                return "Yesterday";
            else
                return dateTime.ToString("MMM dd");
        }

        public string GetStatusBadgeClass(string status)
        {
            switch (status.ToLower())
            {
                case "requested":
                    return "status-badge-modern status-pending";
                case "assigned":
                    return "status-badge-modern status-assigned";
                case "collected":
                    return "status-badge-modern status-completed";
                default:
                    return "status-badge-modern";
            }
        }

        public string BindStatusIcon(string status)
        {
            switch (status.ToLower())
            {
                case "requested":
                    return "fas fa-clock";
                case "assigned":
                    return "fas fa-user-check";
                case "in progress":
                    return "fas fa-play";
                case "collected":
                    return "fas fa-check-circle";
                case "cancelled":
                    return "fas fa-times-circle";
                default:
                    return "fas fa-question-circle";
            }
        }

        public string GetWasteTypeBadgeClass(string wasteType)
        {
            return "waste-type-badge-modern " + wasteType.ToLower() + "-badge";
        }

        public string BindWasteTypeIcon(string wasteType)
        {
            switch (wasteType.ToLower())
            {
                case "plastic":
                    return "fas fa-bottle-water";
                case "paper":
                    return "fas fa-newspaper";
                case "glass":
                    return "fas fa-wine-glass";
                case "metal":
                    return "fas fa-cog";
                case "organic":
                    return "fas fa-leaf";
                case "electronic":
                    return "fas fa-laptop";
                default:
                    return "fas fa-trash";
            }
        }

        public bool IsAssignable(string status)
        {
            return status == "Requested";
        }

        public bool IsStartable(string status, string collectorId)
        {
            return status == "Assigned" && collectorId == CurrentUserId;
        }

        // Filter Event Handlers
        protected void ddlWasteTypeFilter_SelectedIndexChanged(object sender, EventArgs e)
        {
            BindActivePickups();
        }

        protected void ddlStatusFilter_SelectedIndexChanged(object sender, EventArgs e)
        {
            BindActivePickups();
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            BindActivePickups();
        }

        protected void btnClearFilters_Click(object sender, EventArgs e)
        {
            ddlWasteTypeFilter.SelectedValue = "all";
            ddlStatusFilter.SelectedValue = "all";
            txtSearch.Text = "";
            ddlSortPickups.SelectedValue = "recent";
            BindActivePickups();
            ShowInfoMessage("Filters cleared successfully!");
        }

        protected void btnResetFilters_Click(object sender, EventArgs e)
        {
            btnClearFilters_Click(sender, e);
        }

        protected void ddlSortPickups_SelectedIndexChanged(object sender, EventArgs e)
        {
            BindActivePickups();
        }

        // Quick Action Event Handlers
        protected void btnTakeAllPending_Click(object sender, EventArgs e)
        {
            try
            {
                if (string.IsNullOrEmpty(CurrentUserId) || !UserExists(CurrentUserId))
                {
                    ShowErrorMessage("Invalid collector ID.");
                    return;
                }

                using (SqlConnection conn = new SqlConnection(GetConnectionString()))
                {
                    string query = @"
                        UPDATE PickupRequests 
                        SET CollectorId = @CollectorId, 
                            Status = 'Assigned',
                            ScheduledAt = GETDATE()
                        WHERE Status = 'Requested' 
                        AND CollectorId IS NULL";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@CollectorId", CurrentUserId);

                        conn.Open();
                        int rowsAffected = cmd.ExecuteNonQuery();

                        if (rowsAffected > 0)
                        {
                            LogUserActivity(CurrentUserId, "BulkAssign", "Assigned " + rowsAffected + " pickups to collector");
                            BindStats();
                            BindActivePickups();
                            ShowSuccessMessage("Successfully assigned " + rowsAffected + " pending pickups to you!");
                        }
                        else
                        {
                            ShowInfoMessage("No pending pickups available to assign.");
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                ShowErrorMessage("Error taking all pending pickups: " + ex.Message);
            }
        }

        protected void btnViewMyPickups_Click(object sender, EventArgs e)
        {
            ddlStatusFilter.SelectedValue = "Assigned";
            BindActivePickups();
            ShowInfoMessage("Showing only your assigned pickups");
        }

        protected void btnGenerateRoute_Click(object sender, EventArgs e)
        {
            Response.Redirect("MyRoute.aspx");
        }

        protected void btnViewMap_Click(object sender, EventArgs e)
        {
            Response.Redirect("CollectorMap.aspx");
        }

        protected void btnRefreshPickups_Click(object sender, EventArgs e)
        {
            BindStats();
            BindActivePickups();
            ShowSuccessMessage("Pickups list refreshed successfully!");
        }

        protected void btnExportPickups_Click(object sender, EventArgs e)
        {
            ShowInfoMessage("Export functionality would be implemented here.");
        }

        // Helper Methods
        private string GetConnectionString()
        {
            return ConfigurationManager.ConnectionStrings["SoorGreenDBConnectionString"].ConnectionString;
        }

        private void LogUserActivity(string userId, string activityType, string description)
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(GetConnectionString()))
                {
                    string query = @"
                        INSERT INTO UserActivities (UserId, ActivityType, Description, Timestamp)
                        VALUES (@UserId, @ActivityType, @Description, GETDATE())";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@UserId", userId);
                        cmd.Parameters.AddWithValue("@ActivityType", activityType);
                        cmd.Parameters.AddWithValue("@Description", description);

                        conn.Open();
                        cmd.ExecuteNonQuery();
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error logging activity: " + ex.Message);
            }
        }

        // Toast Notification Methods - FIXED: No string interpolation
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