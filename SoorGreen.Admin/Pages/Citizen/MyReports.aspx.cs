using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Collections.Generic;
using System.IO;
using System.Web;

namespace SoorGreen.Admin
{
    public partial class MyReports : System.Web.UI.Page
    {
        private string currentUserId;
        private string connectionString = System.Configuration.ConfigurationManager.ConnectionStrings["SoorGreenDBConnectionString"].ConnectionString;

        // Pagination variables
        private int currentPage = 1;
        private int pageSize = 10;
        private int totalItems = 0;

        // Filter variables
        private string statusFilter = "all";
        private string dateFilter = "today";
        private string wasteTypeFilter = "all";
        private string searchQuery = "";

        // Store waste type mapping
        private Dictionary<string, string> wasteTypeMap = new Dictionary<string, string>();

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

                // Load waste types FIRST
                LoadWasteTypes();

                // Then load data
                LoadUserStats();
                LoadReports();
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

        private void LoadWasteTypes()
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    string query = "SELECT WasteTypeId, Name FROM WasteTypes ORDER BY Name";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            ddlWasteType.Items.Clear();
                            ddlWasteType.Items.Add(new ListItem("-- Select Waste Type --", ""));

                            // Also populate the dictionary
                            wasteTypeMap.Clear();

                            while (reader.Read())
                            {
                                string wasteTypeId = reader["WasteTypeId"].ToString().Trim();
                                string wasteTypeName = reader["Name"].ToString();

                                // Store in dictionary for lookup
                                wasteTypeMap[wasteTypeName.ToLower()] = wasteTypeId;

                                // Add to dropdown
                                ddlWasteType.Items.Add(new ListItem(wasteTypeName, wasteTypeId));
                            }

                            // Debug: Check what waste types are loaded
                            System.Diagnostics.Debug.WriteLine("Loaded " + wasteTypeMap.Count + " waste types");
                            foreach (var kvp in wasteTypeMap)
                            {
                                System.Diagnostics.Debug.WriteLine("Name: " + kvp.Key + " -> ID: " + kvp.Value);
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("LoadWasteTypes Error: " + ex.Message);
                ShowMessage("Error loading waste types: " + ex.Message, "error");
            }
        }

        private void LoadUserStats()
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    // Get all reports count
                    string submittedQuery = "SELECT COUNT(*) FROM WasteReports WHERE UserId = @UserId";
                    using (SqlCommand cmd = new SqlCommand(submittedQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@UserId", currentUserId);
                        var result = cmd.ExecuteScalar();
                        statSubmitted.InnerText = result != DBNull.Value ? result.ToString() : "0";
                    }

                    // Get reports with pickup requests
                    string verifiedQuery = @"
                        SELECT COUNT(DISTINCT wr.ReportId) 
                        FROM WasteReports wr
                        LEFT JOIN PickupRequests pr ON wr.ReportId = pr.ReportId
                        WHERE wr.UserId = @UserId AND pr.ReportId IS NOT NULL";
                    using (SqlCommand cmd = new SqlCommand(verifiedQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@UserId", currentUserId);
                        var result = cmd.ExecuteScalar();
                        statVerified.InnerText = result != DBNull.Value ? result.ToString() : "0";
                    }

                    // Get scheduled reports count
                    string scheduledQuery = @"
                        SELECT COUNT(*) 
                        FROM WasteReports wr
                        INNER JOIN PickupRequests pr ON wr.ReportId = pr.ReportId 
                        WHERE wr.UserId = @UserId AND pr.Status = 'Scheduled'";
                    using (SqlCommand cmd = new SqlCommand(scheduledQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@UserId", currentUserId);
                        var result = cmd.ExecuteScalar();
                        statScheduled.InnerText = result != DBNull.Value ? result.ToString() : "0";
                    }

                    // Get completed reports count
                    string completedQuery = @"
                        SELECT COUNT(*) 
                        FROM WasteReports wr
                        INNER JOIN PickupRequests pr ON wr.ReportId = pr.ReportId 
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

        private void LoadReports()
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    // Build query with filters
                    string query = BuildReportQuery();

                    // First, get total count for pagination
                    string countQuery = "SELECT COUNT(*) FROM (" + query + ") AS SubQuery";
                    using (SqlCommand countCmd = new SqlCommand(countQuery, conn))
                    {
                        AddQueryParameters(countCmd);
                        totalItems = Convert.ToInt32(countCmd.ExecuteScalar());
                    }

                    // Now get paginated data
                    query = "SELECT * FROM (" + query + ") AS FilteredReports ORDER BY ReportDate DESC OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY";

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
                                rptReports.DataSource = dt;
                                rptReports.DataBind();
                                pnlReportCards.Visible = true;
                                pnlEmptyState.Visible = false;
                            }
                            else
                            {
                                pnlReportCards.Visible = false;
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
                System.Diagnostics.Debug.WriteLine("LoadReports Error: " + ex.Message);
                pnlReportCards.Visible = false;
                pnlEmptyState.Visible = true;
            }
        }

        private string BuildReportQuery()
        {
            string baseQuery = @"
                SELECT 
                    wr.ReportId,
                    wr.EstimatedKg as Weight,
                    wr.Address,
                    wr.PhotoUrl,
                    wr.CreatedAt as ReportDate,
                    wt.Name as WasteType,
                    CASE 
                        WHEN pr.ReportId IS NULL THEN 'submitted'
                        WHEN pr.Status = 'Scheduled' THEN 'scheduled'
                        WHEN pr.Status = 'InProgress' THEN 'processing'
                        WHEN pr.Status = 'Collected' THEN 'completed'
                        WHEN pr.Status = 'Cancelled' THEN 'cancelled'
                        ELSE 'submitted'
                    END as StatusDisplay,
                    ISNULL(pr.Status, 'Not Scheduled') as PickupStatus,
                    (wr.EstimatedKg * wt.CreditPerKg) as Reward
                FROM WasteReports wr
                INNER JOIN WasteTypes wt ON wr.WasteTypeId = wt.WasteTypeId
                LEFT JOIN PickupRequests pr ON wr.ReportId = pr.ReportId
                WHERE wr.UserId = @UserId";

            // Apply status filter
            if (!string.IsNullOrEmpty(statusFilter) && statusFilter != "all")
            {
                switch (statusFilter)
                {
                    case "submitted":
                        baseQuery += " AND pr.ReportId IS NULL";
                        break;
                    case "scheduled":
                        baseQuery += " AND pr.Status = 'Scheduled'";
                        break;
                    case "processing":
                        baseQuery += " AND pr.Status = 'InProgress'";
                        break;
                    case "completed":
                        baseQuery += " AND pr.Status = 'Collected'";
                        break;
                    case "cancelled":
                        baseQuery += " AND pr.Status = 'Cancelled'";
                        break;
                }
            }

            // Apply waste type filter
            if (!string.IsNullOrEmpty(wasteTypeFilter) && wasteTypeFilter != "all")
            {
                baseQuery += " AND wt.Name LIKE @WasteTypeFilter";
            }

            // Apply date filter
            if (!string.IsNullOrEmpty(dateFilter))
            {
                switch (dateFilter)
                {
                    case "today":
                        baseQuery += " AND CAST(wr.CreatedAt AS DATE) = CAST(GETDATE() AS DATE)";
                        break;
                    case "week":
                        baseQuery += " AND wr.CreatedAt >= DATEADD(DAY, -7, GETDATE())";
                        break;
                    case "month":
                        baseQuery += " AND wr.CreatedAt >= DATEADD(MONTH, -1, GETDATE())";
                        break;
                    case "year":
                        baseQuery += " AND wr.CreatedAt >= DATEADD(YEAR, -1, GETDATE())";
                        break;
                }
            }

            // Apply search filter
            if (!string.IsNullOrEmpty(searchQuery))
            {
                baseQuery += " AND (wr.ReportId LIKE @SearchQuery OR wr.Address LIKE @SearchQuery OR wt.Name LIKE @SearchQuery)";
            }

            return baseQuery;
        }

        private void AddQueryParameters(SqlCommand cmd)
        {
            cmd.Parameters.AddWithValue("@UserId", currentUserId);

            if (!string.IsNullOrEmpty(wasteTypeFilter) && wasteTypeFilter != "all")
            {
                cmd.Parameters.AddWithValue("@WasteTypeFilter", "%" + wasteTypeFilter + "%");
            }

            if (!string.IsNullOrEmpty(searchQuery))
            {
                cmd.Parameters.AddWithValue("@SearchQuery", "%" + searchQuery + "%");
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

        protected void ddlStatusFilter_SelectedIndexChanged(object sender, EventArgs e)
        {
            statusFilter = ddlStatusFilter.SelectedValue;
            currentPage = 1;
            Session["CurrentPage"] = currentPage;
            LoadReports();
        }

        protected void ddlDateFilter_SelectedIndexChanged(object sender, EventArgs e)
        {
            dateFilter = ddlDateFilter.SelectedValue;
            currentPage = 1;
            Session["CurrentPage"] = currentPage;
            LoadReports();
        }

        protected void ddlWasteTypeFilter_SelectedIndexChanged(object sender, EventArgs e)
        {
            wasteTypeFilter = ddlWasteTypeFilter.SelectedValue;
            currentPage = 1;
            Session["CurrentPage"] = currentPage;
            LoadReports();
        }

        protected void txtSearch_TextChanged(object sender, EventArgs e)
        {
            searchQuery = txtSearch.Text.Trim();
            currentPage = 1;
            Session["CurrentPage"] = currentPage;
            LoadReports();
        }

        protected void btnPrevPage_Click(object sender, EventArgs e)
        {
            if (currentPage > 1)
            {
                currentPage--;
                Session["CurrentPage"] = currentPage;
                LoadReports();
            }
        }

        protected void btnNextPage_Click(object sender, EventArgs e)
        {
            int totalPages = (int)Math.Ceiling((double)totalItems / pageSize);
            if (currentPage < totalPages)
            {
                currentPage++;
                Session["CurrentPage"] = currentPage;
                LoadReports();
            }
        }

        protected void btnPage_Click(object sender, EventArgs e)
        {
            LinkButton btn = (LinkButton)sender;
            currentPage = Convert.ToInt32(btn.CommandArgument);
            Session["CurrentPage"] = currentPage;
            LoadReports();
        }

        protected void rptReports_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            string reportId = e.CommandArgument.ToString();

            switch (e.CommandName)
            {
                case "ViewDetails":
                    ViewReportDetails(reportId);
                    break;

                case "Edit":
                    EditReport(reportId);
                    break;

                case "Schedule":
                    SchedulePickup(reportId);
                    break;

                case "Delete":
                    DeleteReport(reportId);
                    break;
            }
        }

        private void ViewReportDetails(string reportId)
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    string query = @"
                        SELECT wr.*, wt.Name as WasteTypeName, 
                               (wr.EstimatedKg * wt.CreditPerKg) as Reward,
                               pr.Status as PickupStatus,
                               pr.ScheduledAt
                        FROM WasteReports wr
                        INNER JOIN WasteTypes wt ON wr.WasteTypeId = wt.WasteTypeId
                        LEFT JOIN PickupRequests pr ON wr.ReportId = pr.ReportId
                        WHERE wr.ReportId = @ReportId AND wr.UserId = @UserId";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@ReportId", reportId);
                        cmd.Parameters.AddWithValue("@UserId", currentUserId);

                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                string details = "Report ID: " + reader["ReportId"] + "\n" +
                                                "Waste Type: " + reader["WasteTypeName"] + "\n" +
                                                "Weight: " + reader["EstimatedKg"] + " kg\n" +
                                                "Address: " + reader["Address"] + "\n" +
                                                "Estimated Reward: " + reader["Reward"] + " XP\n" +
                                                "Created: " + ((DateTime)reader["CreatedAt"]).ToString("MMM dd, yyyy HH:mm");

                                ShowMessage(details, "info");
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Error loading report details: " + ex.Message, "error");
            }
        }

        private void EditReport(string reportId)
        {
            // Load report data into modal and show
            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    string query = @"
                        SELECT wr.*, wt.Name as WasteType, wt.WasteTypeId
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
                                // Get the waste type ID
                                string wasteTypeId = reader["WasteTypeId"].ToString().Trim();

                                // Find and select the correct item in dropdown
                                ddlWasteType.ClearSelection();
                                foreach (ListItem item in ddlWasteType.Items)
                                {
                                    if (item.Value == wasteTypeId)
                                    {
                                        item.Selected = true;
                                        break;
                                    }
                                }

                                txtWeight.Text = reader["EstimatedKg"].ToString();
                                txtAddress.Text = reader["Address"].ToString();

                                // Set modal title
                                modalTitle.InnerText = "Edit Report - " + reportId;

                                // Store report ID in view state for update
                                ViewState["EditReportId"] = reportId;

                                // Show modal
                                ScriptManager.RegisterStartupScript(this, GetType(), "ShowEditModal", "showNewReportModal();", true);
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Error loading report for edit: " + ex.Message, "error");
            }
        }

        private void SchedulePickup(string reportId)
        {
            // Check if pickup already exists
            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    string checkQuery = "SELECT COUNT(*) FROM PickupRequests WHERE ReportId = @ReportId";
                    using (SqlCommand cmd = new SqlCommand(checkQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@ReportId", reportId);
                        int pickupCount = Convert.ToInt32(cmd.ExecuteScalar());

                        if (pickupCount > 0)
                        {
                            ShowMessage("This report already has a pickup request.", "info");
                            return;
                        }
                    }
                }

                // Redirect to schedule pickup page with report ID
                Response.Redirect("~/Pages/Citizen/SchedulePickup.aspx?reportId=" + reportId);
            }
            catch (Exception ex)
            {
                ShowMessage("Error checking pickup status: " + ex.Message, "error");
            }
        }

        private void DeleteReport(string reportId)
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    // Check if report has associated pickup
                    string checkQuery = "SELECT COUNT(*) FROM PickupRequests WHERE ReportId = @ReportId AND Status NOT IN ('Cancelled', 'Collected')";

                    using (SqlCommand checkCmd = new SqlCommand(checkQuery, conn))
                    {
                        checkCmd.Parameters.AddWithValue("@ReportId", reportId);
                        int pickupCount = Convert.ToInt32(checkCmd.ExecuteScalar());

                        if (pickupCount > 0)
                        {
                            ShowMessage("Cannot delete report with active pickup request.", "error");
                            return;
                        }
                    }

                    // Delete report
                    string deleteQuery = "DELETE FROM WasteReports WHERE ReportId = @ReportId AND UserId = @UserId";

                    using (SqlCommand cmd = new SqlCommand(deleteQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@ReportId", reportId);
                        cmd.Parameters.AddWithValue("@UserId", currentUserId);

                        int rowsAffected = cmd.ExecuteNonQuery();

                        if (rowsAffected > 0)
                        {
                            ShowMessage("Report deleted successfully!", "success");
                            LoadUserStats();
                            LoadReports();
                        }
                        else
                        {
                            ShowMessage("Failed to delete report.", "error");
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Error deleting report: " + ex.Message, "error");
            }
        }

        protected void btnNewReport_Click(object sender, EventArgs e)
        {
            // Reset form
            ddlWasteType.SelectedIndex = 0;
            txtWeight.Text = "";
            txtAddress.Text = "";

            // Clear view state
            ViewState.Remove("EditReportId");

            // Set modal title
            modalTitle.InnerText = "New Waste Report";

            // Show modal
            ScriptManager.RegisterStartupScript(this, GetType(), "ShowNewReportModal", "showNewReportModal();", true);
        }

        protected void btnSubmitReport_Click(object sender, EventArgs e)
        {
            // Validate inputs
            if (string.IsNullOrEmpty(ddlWasteType.SelectedValue))
            {
                ShowMessage("Please select a waste type.", "error");
                return;
            }

            // Validate weight
            decimal weight = 0;
            if (string.IsNullOrEmpty(txtWeight.Text) || !decimal.TryParse(txtWeight.Text, out weight) || weight <= 0)
            {
                ShowMessage("Please enter a valid weight greater than 0.", "error");
                return;
            }

            if (string.IsNullOrEmpty(txtAddress.Text.Trim()))
            {
                ShowMessage("Please enter a collection address.", "error");
                return;
            }

            try
            {
                string wasteTypeId = ddlWasteType.SelectedValue;

                // Debug: Check what waste type ID we're using
                System.Diagnostics.Debug.WriteLine("Selected WasteTypeId: " + wasteTypeId);
                System.Diagnostics.Debug.WriteLine("Selected WasteType Name: " + ddlWasteType.SelectedItem.Text);

                // Ensure WasteTypeId is exactly 4 characters for CHAR(4)
                if (wasteTypeId.Length > 4)
                {
                    wasteTypeId = wasteTypeId.Substring(0, 4);
                }
                else if (wasteTypeId.Length < 4)
                {
                    wasteTypeId = wasteTypeId.PadRight(4);
                }

                System.Diagnostics.Debug.WriteLine("Formatted WasteTypeId: " + wasteTypeId);

                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    using (SqlTransaction transaction = conn.BeginTransaction())
                    {
                        try
                        {
                            string reportId;

                            // Check if editing existing report
                            if (ViewState["EditReportId"] != null)
                            {
                                reportId = ViewState["EditReportId"].ToString();

                                // Update existing report
                                string updateQuery = @"
                                    UPDATE WasteReports 
                                    SET WasteTypeId = @WasteTypeId,
                                        EstimatedKg = @Weight,
                                        Address = @Address
                                    WHERE ReportId = @ReportId AND UserId = @UserId";

                                using (SqlCommand cmd = new SqlCommand(updateQuery, conn, transaction))
                                {
                                    cmd.Parameters.AddWithValue("@ReportId", reportId);
                                    cmd.Parameters.AddWithValue("@UserId", currentUserId);
                                    cmd.Parameters.AddWithValue("@WasteTypeId", wasteTypeId);
                                    cmd.Parameters.AddWithValue("@Weight", weight);
                                    cmd.Parameters.AddWithValue("@Address", txtAddress.Text.Trim());

                                    cmd.ExecuteNonQuery();
                                }

                                ShowMessage("Report updated successfully!", "success");
                            }
                            else
                            {
                                // Generate new Report ID
                                string newReportIdQuery = "SELECT 'WR' + RIGHT('00' + CAST(ISNULL(MAX(CAST(SUBSTRING(ReportId, 3, 2) AS INT)), 0) + 1 AS VARCHAR(2)), 2) FROM WasteReports";

                                using (SqlCommand idCmd = new SqlCommand(newReportIdQuery, conn, transaction))
                                {
                                    reportId = idCmd.ExecuteScalar().ToString();
                                }

                                System.Diagnostics.Debug.WriteLine("Generated ReportId: " + reportId);

                                // Insert new report
                                string insertQuery = @"
                                    INSERT INTO WasteReports (ReportId, UserId, WasteTypeId, EstimatedKg, Address, CreatedAt)
                                    VALUES (@ReportId, @UserId, @WasteTypeId, @Weight, @Address, GETDATE())";

                                using (SqlCommand cmd = new SqlCommand(insertQuery, conn, transaction))
                                {
                                    cmd.Parameters.AddWithValue("@ReportId", reportId);
                                    cmd.Parameters.AddWithValue("@UserId", currentUserId);
                                    cmd.Parameters.AddWithValue("@WasteTypeId", wasteTypeId);
                                    cmd.Parameters.AddWithValue("@Weight", weight);
                                    cmd.Parameters.AddWithValue("@Address", txtAddress.Text.Trim());

                                    int rowsAffected = cmd.ExecuteNonQuery();
                                    System.Diagnostics.Debug.WriteLine("Rows affected: " + rowsAffected);
                                }

                                // Insert notification
                                string notificationQuery = "INSERT INTO Notifications (NotificationId, UserId, Title, Message, CreatedAt) VALUES (@NotificationId, @UserId, @Title, @Message, GETDATE())";

                                using (SqlCommand notifCmd = new SqlCommand(notificationQuery, conn, transaction))
                                {
                                    string notifId = "NT" + DateTime.Now.ToString("MMddHHmmss");

                                    notifCmd.Parameters.AddWithValue("@NotificationId", notifId);
                                    notifCmd.Parameters.AddWithValue("@UserId", currentUserId);
                                    notifCmd.Parameters.AddWithValue("@Title", "Report Submitted");
                                    notifCmd.Parameters.AddWithValue("@Message", "Your waste report " + reportId + " has been submitted successfully.");

                                    notifCmd.ExecuteNonQuery();
                                }

                                ShowMessage("Report submitted successfully! Report ID: " + reportId, "success");
                            }

                            // Handle photo uploads
                            if (fileUploadPhotos.HasFiles)
                            {
                                SaveReportPhotos(reportId, conn, transaction);
                            }

                            transaction.Commit();

                            // Refresh data
                            LoadUserStats();
                            LoadReports();

                            // Close modal
                            ScriptManager.RegisterStartupScript(this, GetType(), "CloseModal", "$('#reportModal').modal('hide');", true);
                        }
                        catch (Exception ex)
                        {
                            transaction.Rollback();
                            ShowMessage("Error saving report: " + ex.Message + "\nWasteTypeId: " + wasteTypeId, "error");
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Error: " + ex.Message, "error");
            }
        }

        private void SaveReportPhotos(string reportId, SqlConnection conn, SqlTransaction transaction)
        {
            // Limit to 5 files
            int fileCount = Math.Min(fileUploadPhotos.PostedFiles.Count, 5);

            for (int i = 0; i < fileCount; i++)
            {
                HttpPostedFile file = fileUploadPhotos.PostedFiles[i];

                // Validate file (max 5MB)
                if (file.ContentLength > 5 * 1024 * 1024)
                {
                    ShowMessage("File " + file.FileName + " exceeds 5MB limit.", "warning");
                    continue;
                }

                // Validate file type
                string fileExtension = Path.GetExtension(file.FileName).ToLower();
                if (!IsImageFile(fileExtension))
                {
                    ShowMessage("File " + file.FileName + " is not a valid image.", "warning");
                    continue;
                }

                try
                {
                    // Generate unique filename
                    string fileName = Guid.NewGuid().ToString() + fileExtension;
                    string uploadPath = Server.MapPath("~/Uploads/ReportPhotos/");

                    // Create directory if it doesn't exist
                    if (!Directory.Exists(uploadPath))
                    {
                        Directory.CreateDirectory(uploadPath);
                    }

                    // Save file
                    string filePath = Path.Combine(uploadPath, fileName);
                    file.SaveAs(filePath);

                    // Save photo URL to database
                    string photoUrl = "~/Uploads/ReportPhotos/" + fileName;

                    // Update report with photo URL (assuming first photo is primary)
                    if (i == 0)
                    {
                        string updatePhotoQuery = "UPDATE WasteReports SET PhotoUrl = @PhotoUrl WHERE ReportId = @ReportId";

                        using (SqlCommand cmd = new SqlCommand(updatePhotoQuery, conn, transaction))
                        {
                            cmd.Parameters.AddWithValue("@ReportId", reportId);
                            cmd.Parameters.AddWithValue("@PhotoUrl", photoUrl);
                            cmd.ExecuteNonQuery();
                        }
                    }
                }
                catch (Exception ex)
                {
                    ShowMessage("Error uploading photo " + file.FileName + ": " + ex.Message, "warning");
                }
            }
        }

        private bool IsImageFile(string extension)
        {
            string[] allowedExtensions = { ".jpg", ".jpeg", ".png", ".gif", ".bmp" };
            foreach (string ext in allowedExtensions)
            {
                if (ext == extension)
                    return true;
            }
            return false;
        }

        protected void btnRefresh_Click(object sender, EventArgs e)
        {
            LoadUserStats();
            LoadReports();
            ShowMessage("Data refreshed successfully!", "success");
        }

        protected void btnExportReports_Click(object sender, EventArgs e)
        {
            ShowMessage("Export feature coming soon!", "info");
        }

        protected void btnViewAll_Click(object sender, EventArgs e)
        {
            // Reset filters to show all
            ddlStatusFilter.SelectedValue = "all";
            ddlDateFilter.SelectedValue = "all";
            ddlWasteTypeFilter.SelectedValue = "all";
            txtSearch.Text = "";

            statusFilter = "all";
            dateFilter = "all";
            wasteTypeFilter = "all";
            searchQuery = "";
            currentPage = 1;

            LoadReports();
        }

        public string GetStatusIcon(string status)
        {
            switch (status.ToLower())
            {
                case "submitted": return "fas fa-paper-plane";
                case "scheduled": return "fas fa-calendar-alt";
                case "processing": return "fas fa-cog";
                case "completed": return "fas fa-check-double";
                case "cancelled": return "fas fa-times-circle";
                default: return "fas fa-question-circle";
            }
        }

        public string GetPickupStatus(string pickupStatus)
        {
            switch (pickupStatus.ToLower())
            {
                case "requested": return "Pending";
                case "scheduled": return "Scheduled";
                case "inprogress": return "In Progress";
                case "collected": return "Completed";
                case "cancelled": return "Cancelled";
                default: return "Not Scheduled";
            }
        }

        public bool IsEditable(string status)
        {
            return status.ToLower() == "submitted";
        }

        public bool IsSchedulable(string reportStatus, string pickupStatus)
        {
            return reportStatus.ToLower() == "submitted" && pickupStatus.ToLower() == "not scheduled";
        }

        public bool IsDeletable(string status)
        {
            return status.ToLower() == "submitted";
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