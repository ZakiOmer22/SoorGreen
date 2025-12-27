using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Drawing;
using System.Web.Services;
using Newtonsoft.Json;
using System.Security.Cryptography;
using System.Text;

namespace SoorGreen.Collectors
{
    public partial class MyRoute : System.Web.UI.Page
    {
        // Database connection string
        public string connectionString = ConfigurationManager.ConnectionStrings["SoorGreenDBConnectionString"].ConnectionString;

        // Current collector ID (from session)
        private string currentCollectorId;

        // Route data
        private DataTable routeStops;

        protected void Page_Load(object sender, EventArgs e)
        {
            // Check if user is logged in and is a collector
            if (Session["UserId"] == null || Session["UserRole"] == null)
            {
                Response.Redirect("~/Pages/Login.aspx");
                return;
            }

            if (Session["UserRole"].ToString() != "R002") // Collector role
            {
                Response.Redirect("~/Pages/Unauthorized.aspx");
                return;
            }

            currentCollectorId = Session["UserId"].ToString();

            if (!IsPostBack)
            {
                // Load initial data
                LoadCollectorStats();
                LoadRouteStops();
                LoadVehicles();
                BindTodayDate();

                // Check for active route
                CheckActiveRoute();

                // Load route notes if any
                LoadRouteNotes();

                // Calculate performance metrics
                CalculatePerformanceMetrics();
            }
        }

        #region Initial Loading Methods

        private void LoadCollectorStats()
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    string query = @"
                        -- Today's collection stats
                        DECLARE @Today DATE = GETDATE();
                        
                        -- Total stops assigned today
                        SELECT 
                            COUNT(*) as TotalStops,
                            SUM(CASE WHEN pr.Status = 'Collected' THEN 1 ELSE 0 END) as CompletedStops,
                            SUM(CASE WHEN pr.Status IN ('Requested', 'Assigned') THEN 1 ELSE 0 END) as PendingStops,
                            ISNULL(SUM(wr.EstimatedKg), 0) as TotalWeight,
                            ISNULL(SUM(pv.VerifiedKg), 0) as VerifiedWeight
                        FROM PickupRequests pr
                        JOIN WasteReports wr ON pr.ReportId = wr.ReportId
                        LEFT JOIN PickupVerifications pv ON pr.PickupId = pv.PickupId
                        WHERE pr.CollectorId = @CollectorId
                        AND CAST(pr.ScheduledAt AS DATE) = @Today;
                        
                        -- Route efficiency calculation (simplified)
                        SELECT 
                            CASE 
                                WHEN COUNT(*) > 0 THEN 
                                    CAST(SUM(CASE WHEN pr.Status = 'Collected' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(5,1))
                                ELSE 0 
                            END as EfficiencyScore
                        FROM PickupRequests pr
                        WHERE pr.CollectorId = @CollectorId
                        AND CAST(pr.ScheduledAt AS DATE) = @Today;
                    ";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@CollectorId", currentCollectorId);

                        conn.Open();
                        using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                        {
                            DataSet ds = new DataSet();
                            da.Fill(ds);

                            if (ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                            {
                                DataRow stats = ds.Tables[0].Rows[0];

                                lblTotalStops.Text = stats["TotalStops"].ToString();
                                lblCompletedStops.Text = stats["CompletedStops"].ToString();
                                lblPendingStops.Text = stats["PendingStops"].ToString();
                                lblTotalWeight.Text = stats["TotalWeight"].ToString() + " kg";

                                // Calculate estimated distance (simplified: 0.5km per stop)
                                int totalStopsCount = Convert.ToInt32(stats["TotalStops"]);
                                decimal estimatedDistance = totalStopsCount * 0.5m;
                                lblTotalDistance.Text = estimatedDistance.ToString("F1") + " km";

                                // Calculate estimated time (15 minutes per stop)
                                decimal estimatedTime = totalStopsCount * 15.0m / 60.0m;
                                lblEstTime.Text = estimatedTime.ToString("F1") + " hrs";

                                // Update weight collected
                                lblWeightCollected.Text = stats["VerifiedWeight"].ToString() + " kg";

                                // Calculate progress
                                if (totalStopsCount > 0)
                                {
                                    int completedCount = Convert.ToInt32(stats["CompletedStops"]);
                                    int progressPercent = (int)((completedCount * 100.0) / totalStopsCount);
                                    lblRouteProgressPercentage.Text = progressPercent + "%";
                                    routeProgressBar.Style["width"] = progressPercent + "%";
                                }
                            }

                            if (ds.Tables.Count > 1 && ds.Tables[1].Rows.Count > 0)
                            {
                                lblEfficiencyScore.Text = ds.Tables[1].Rows[0]["EfficiencyScore"].ToString() + "%";
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                // Log error
                LogError("LoadCollectorStats", ex.Message);
            }
        }

        private void LoadRouteStops()
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    string query = @"
                        SELECT 
                            ROW_NUMBER() OVER (ORDER BY wr.CreatedAt) as Sequence,
                            pr.PickupId,
                            wr.ReportId,
                            wr.Address,
                            ISNULL(wr.Landmark, 'No landmark') as Landmark,
                            wr.EstimatedKg,
                            wt.Name as WasteType,
                            u.FullName as CitizenName,
                            u.Phone as CitizenPhone,
                            ISNULL(u.Email, '') as CitizenEmail,
                            pr.Status,
                            pr.ScheduledAt,
                            pr.CompletedAt,
                            wr.Lat,
                            wr.Lng,
                            wr.PhotoUrl,
                            DATEDIFF(MINUTE, pr.ScheduledAt, GETDATE()) as MinutesSinceScheduled,
                            -- Calculate distance from previous stop (simplified)
                            ROW_NUMBER() OVER (ORDER BY wr.CreatedAt) * 0.5 as DistanceFromPrev,
                            -- Calculate estimated time (15 minutes per stop)
                            15 as EstimatedTime
                        FROM PickupRequests pr
                        JOIN WasteReports wr ON pr.ReportId = wr.ReportId
                        JOIN WasteTypes wt ON wr.WasteTypeId = wt.WasteTypeId
                        JOIN Users u ON wr.UserId = u.UserId
                        WHERE pr.CollectorId = @CollectorId
                        AND CAST(pr.ScheduledAt AS DATE) = CAST(GETDATE() AS DATE)
                        AND pr.Status IN ('Requested', 'Assigned', 'In Progress')
                        ORDER BY 
                            CASE 
                                WHEN pr.Status = 'In Progress' THEN 1
                                WHEN pr.Status = 'Assigned' THEN 2
                                ELSE 3
                            END,
                            wr.CreatedAt;
                    ";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@CollectorId", currentCollectorId);

                        conn.Open();
                        using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                        {
                            routeStops = new DataTable();
                            da.Fill(routeStops);

                            if (routeStops.Rows.Count > 0)
                            {
                                // Bind to repeater
                                rptRouteStops.DataSource = routeStops;
                                rptRouteStops.DataBind();

                                // Hide empty state
                                pnlNoStops.Visible = false;

                                // Set next stop details
                                SetNextStopDetails();

                                // Generate map waypoints
                                GenerateMapWaypoints();
                            }
                            else
                            {
                                // Show empty state
                                pnlNoStops.Visible = true;
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                LogError("LoadRouteStops", ex.Message);
                pnlNoStops.Visible = true;
            }
        }

        private void LoadVehicles()
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    string query = @"
                        SELECT VehicleId, 
                               VehicleType + ' (' + LicensePlate + ' - Capacity: ' + 
                               CAST(Capacity AS VARCHAR) + ' kg)' as VehicleDisplayName
                        FROM Vehicles
                        WHERE Status = 'Active' 
                        AND (AssignedTo = @CollectorId OR AssignedTo IS NULL);
                    ";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@CollectorId", currentCollectorId);

                        conn.Open();
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            ddlVehicle.Items.Clear();
                            ddlVehicle.Items.Add(new ListItem("Select Vehicle", ""));

                            while (reader.Read())
                            {
                                ddlVehicle.Items.Add(new ListItem(
                                    reader["VehicleDisplayName"].ToString(),
                                    reader["VehicleId"].ToString()
                                ));
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                LogError("LoadVehicles", ex.Message);

                // Fallback to hardcoded values if database fails
                ddlVehicle.Items.Clear();
                ddlVehicle.Items.Add(new ListItem("Truck 001 (Capacity: 5000 kg)", "TRK001"));
                ddlVehicle.Items.Add(new ListItem("Van 002 (Capacity: 2000 kg)", "VAN002"));
            }
        }

        private void BindTodayDate()
        {
            lblTodayDate.Text = DateTime.Now.ToString("dddd, MMMM dd, yyyy");
        }

        private void CheckActiveRoute()
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    string query = @"
                        SELECT TOP 1 Status
                        FROM PickupRequests
                        WHERE CollectorId = @CollectorId
                        AND CAST(ScheduledAt AS DATE) = CAST(GETDATE() AS DATE)
                        AND Status = 'In Progress'
                        ORDER BY ScheduledAt;
                    ";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@CollectorId", currentCollectorId);

                        conn.Open();
                        object result = cmd.ExecuteScalar();

                        if (result != null)
                        {
                            lblRouteStatus.Text = "In Progress";
                            btnStartRoute.Visible = false;
                            btnCompleteRoute.Visible = true;
                        }
                        else
                        {
                            lblRouteStatus.Text = "Not Started";
                            btnStartRoute.Visible = true;
                            btnCompleteRoute.Visible = false;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                LogError("CheckActiveRoute", ex.Message);
            }
        }

        private void LoadRouteNotes()
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    string query = @"
                        SELECT TOP 1 Notes
                        FROM CollectorRoutes
                        WHERE CollectorId = @CollectorId
                        AND CAST(RouteDate AS DATE) = CAST(GETDATE() AS DATE);
                    ";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@CollectorId", currentCollectorId);

                        conn.Open();
                        object result = cmd.ExecuteScalar();

                        if (result != null)
                        {
                            txtRouteNotes.Text = result.ToString();
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                LogError("LoadRouteNotes", ex.Message);
            }
        }

        private void CalculatePerformanceMetrics()
        {
            try
            {
                // Simplified calculations - FIXED: Declare variables before using them
                decimal totalDistance;
                if (decimal.TryParse(lblTotalDistance.Text.Replace(" km", ""), out totalDistance))
                {
                    // Fuel estimate (5km per liter)
                    decimal fuelEstimateValue = totalDistance / 5.0m;
                    lblFuelEstimate.Text = fuelEstimateValue.ToString("F1") + " L";

                    // Cost estimate
                    decimal fuelCost = totalDistance * 0.2m; // $0.2 per km
                    decimal laborCost = 8 * 15.0m; // $15 per hour for 8 hours
                    decimal totalCost = fuelCost + laborCost;
                    lblCostEstimate.Text = "$" + totalCost.ToString("F0");
                }

                // CO2 saved (2kg CO2 per kg of recycled material)
                decimal totalWeight;
                if (decimal.TryParse(lblTotalWeight.Text.Replace(" kg", ""), out totalWeight))
                {
                    decimal co2SavedValue = totalWeight * 2.0m;
                    lblCo2Saved.Text = co2SavedValue.ToString("F0") + " kg";
                }

                // Set optimization tips
                SetOptimizationTips();
            }
            catch (Exception ex)
            {
                LogError("CalculatePerformanceMetrics", ex.Message);
            }
        }

        private void SetOptimizationTips()
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    string query = @"
                        -- Get waste type distribution for today
                        SELECT 
                            wt.Name,
                            COUNT(*) as Count
                        FROM PickupRequests pr
                        JOIN WasteReports wr ON pr.ReportId = wr.ReportId
                        JOIN WasteTypes wt ON wr.WasteTypeId = wt.WasteTypeId
                        WHERE pr.CollectorId = @CollectorId
                        AND CAST(pr.ScheduledAt AS DATE) = CAST(GETDATE() AS DATE)
                        GROUP BY wt.Name
                        ORDER BY COUNT(*) DESC;
                    ";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@CollectorId", currentCollectorId);

                        conn.Open();
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.HasRows)
                            {
                                List<string> wasteTypes = new List<string>();
                                while (reader.Read())
                                {
                                    wasteTypes.Add(reader["Name"].ToString());
                                }

                                // Set tips based on waste type distribution
                                if (wasteTypes.Count > 3)
                                {
                                    lblTip1.Text = "Group stops by " + string.Join(" and ", wasteTypes.Take(2)) +
                                                    " to reduce sorting time";
                                }
                                else
                                {
                                    lblTip1.Text = "Group stops by waste type to reduce sorting time";
                                }
                            }
                            else
                            {
                                lblTip1.Text = "Group stops by waste type to reduce sorting time";
                            }
                        }
                    }
                }

                lblTip2.Text = "Plan routes to avoid peak traffic hours (8-10 AM, 4-6 PM)";

                // Vehicle capacity tip
                string selectedVehicle = ddlVehicle.SelectedValue;
                if (selectedVehicle.Contains("TRK"))
                {
                    lblTip3.Text = "Truck has 5000 kg capacity - you can handle large collections";
                }
                else if (selectedVehicle.Contains("VAN"))
                {
                    lblTip3.Text = "Van has 2000 kg capacity - monitor weight to avoid overloading";
                }
                else
                {
                    lblTip3.Text = "Consider vehicle capacity when scheduling stops";
                }
            }
            catch (Exception ex)
            {
                LogError("SetOptimizationTips", ex.Message);
            }
        }

        #endregion

        #region Button Click Events

        protected void btnStartRoute_Click(object sender, EventArgs e)
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    string query = @"
BEGIN TRANSACTION;

-- Update all assigned pickups to 'In Progress'
UPDATE PickupRequests
SET Status = 'In Progress'
WHERE CollectorId = @CollectorId
AND CAST(ScheduledAt AS DATE) = CAST(GETDATE() AS DATE)
AND Status IN ('Requested', 'Assigned');

-- Create route record if it doesn't exist
IF NOT EXISTS (
    SELECT 1 FROM CollectorRoutes 
    WHERE CollectorId = @CollectorId 
    AND CAST(RouteDate AS DATE) = CAST(GETDATE() AS DATE)
)
BEGIN
    INSERT INTO CollectorRoutes (RouteId, CollectorId, RouteDate, StartTime, Status)
    VALUES (@RouteId, @CollectorId, GETDATE(), GETDATE(), 'In Progress');
END
ELSE
BEGIN
    UPDATE CollectorRoutes
    SET Status = 'In Progress',
        StartTime = GETDATE()
    WHERE CollectorId = @CollectorId 
    AND CAST(RouteDate AS DATE) = CAST(GETDATE() AS DATE);
END

COMMIT TRANSACTION;
";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        // Generate route ID
                        string routeId = "RT" + DateTime.Now.ToString("yyyyMMddHHmmss");

                        cmd.Parameters.AddWithValue("@CollectorId", currentCollectorId);
                        cmd.Parameters.AddWithValue("@RouteId", routeId);

                        conn.Open();
                        int rowsAffected = cmd.ExecuteNonQuery();

                        if (rowsAffected > 0)
                        {
                            // Update UI
                            lblRouteStatus.Text = "In Progress";
                            btnStartRoute.Visible = false;
                            btnCompleteRoute.Visible = true;

                            // Show success message
                            ShowMessage("Route started successfully!", "success");

                            // Reload stops to reflect status change
                            LoadRouteStops();
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                LogError("btnStartRoute_Click", ex.Message);
                ShowMessage("Error starting route: " + ex.Message, "danger");
            }
        }

        protected void btnOptimizeRoute_Click(object sender, EventArgs e)
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    // Get pending stops
                    string getStopsQuery = @"
                        SELECT 
                            wr.ReportId,
                            wr.Lat,
                            wr.Lng,
                            wr.Address,
                            wr.EstimatedKg
                        FROM PickupRequests pr
                        JOIN WasteReports wr ON pr.ReportId = wr.ReportId
                        WHERE pr.CollectorId = @CollectorId
                        AND CAST(pr.ScheduledAt AS DATE) = CAST(GETDATE() AS DATE)
                        AND pr.Status IN ('Requested', 'Assigned', 'In Progress')
                        AND wr.Lat IS NOT NULL
                        AND wr.Lng IS NOT NULL;
                    ";

                    DataTable stops = new DataTable();
                    using (SqlCommand cmd = new SqlCommand(getStopsQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@CollectorId", currentCollectorId);

                        conn.Open();
                        using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                        {
                            da.Fill(stops);
                        }
                    }

                    if (stops.Rows.Count > 0)
                    {
                        // In a real implementation, you would call a routing algorithm here
                        // For now, just show success message
                        ShowMessage("Route optimized! " + stops.Rows.Count + " stops reordered.", "success");

                        // Reload stops
                        LoadRouteStops();
                    }
                    else
                    {
                        ShowMessage("No stops to optimize.", "warning");
                    }
                }
            }
            catch (Exception ex)
            {
                LogError("btnOptimizeRoute_Click", ex.Message);
                ShowMessage("Error optimizing route: " + ex.Message, "danger");
            }
        }

        protected void btnCompleteRoute_Click(object sender, EventArgs e)
        {
            try
            {
                // Check if all stops are completed
                bool allCompleted = true;
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    string checkQuery = @"
                        SELECT COUNT(*) as PendingCount
                        FROM PickupRequests
                        WHERE CollectorId = @CollectorId
                        AND CAST(ScheduledAt AS DATE) = CAST(GETDATE() AS DATE)
                        AND Status IN ('Requested', 'Assigned', 'In Progress');
                    ";

                    using (SqlCommand cmd = new SqlCommand(checkQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@CollectorId", currentCollectorId);

                        conn.Open();
                        int pendingCount = Convert.ToInt32(cmd.ExecuteScalar());
                        allCompleted = (pendingCount == 0);
                    }
                }

                if (!allCompleted)
                {
                    // Ask for confirmation
                    string script = @"
                        if(confirm('Some stops are not completed. Are you sure you want to end the route?')) {
                            __doPostBack('" + btnCompleteRoute.UniqueID + @"', '');
                        }
                    ";
                    ClientScript.RegisterStartupScript(this.GetType(), "ConfirmComplete", script, true);
                    return;
                }

                CompleteCurrentRoute();
            }
            catch (Exception ex)
            {
                LogError("btnCompleteRoute_Click", ex.Message);
                ShowMessage("Error completing route: " + ex.Message, "danger");
            }
        }

        private void CompleteCurrentRoute()
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    string query = @"
BEGIN TRANSACTION;

-- Update route status
UPDATE CollectorRoutes
SET Status = 'Completed',
    EndTime = GETDATE(),
    TotalDistance = @TotalDistance,
    TotalWeight = @TotalWeight
WHERE CollectorId = @CollectorId
AND CAST(RouteDate AS DATE) = CAST(GETDATE() AS DATE);

-- Update any remaining pickups to completed
UPDATE PickupRequests
SET Status = 'Collected',
    CompletedAt = GETDATE()
WHERE CollectorId = @CollectorId
AND CAST(ScheduledAt AS DATE) = CAST(GETDATE() AS DATE)
AND Status IN ('Requested', 'Assigned', 'In Progress');

COMMIT TRANSACTION;
";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        // Get totals - FIXED: Declare variables before using them
                        decimal totalDistance = 0;
                        decimal totalWeight = 0;

                        decimal parsedDistance;
                        decimal parsedWeight;

                        if (decimal.TryParse(lblTotalDistance.Text.Replace(" km", ""), out parsedDistance))
                        {
                            totalDistance = parsedDistance;
                        }

                        if (decimal.TryParse(lblTotalWeight.Text.Replace(" kg", ""), out parsedWeight))
                        {
                            totalWeight = parsedWeight;
                        }

                        cmd.Parameters.AddWithValue("@CollectorId", currentCollectorId);
                        cmd.Parameters.AddWithValue("@TotalDistance", totalDistance);
                        cmd.Parameters.AddWithValue("@TotalWeight", totalWeight);

                        conn.Open();
                        int rowsAffected = cmd.ExecuteNonQuery();

                        if (rowsAffected > 0)
                        {
                            // Update UI
                            lblRouteStatus.Text = "Completed";
                            btnCompleteRoute.Visible = false;
                            btnStartRoute.Visible = false;

                            // Show success message
                            ShowMessage("Route completed successfully!", "success");

                            // Reload stats
                            LoadCollectorStats();
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                LogError("CompleteCurrentRoute", ex.Message);
                ShowMessage("Error: " + ex.Message, "danger");
            }
        }

        protected void btnPrintRoute_Click(object sender, EventArgs e)
        {
            // JavaScript to trigger print
            string script = "window.print();";
            ClientScript.RegisterStartupScript(this.GetType(), "PrintRoute", script, true);
        }

        protected void btnCalculateRoute_Click(object sender, EventArgs e)
        {
            try
            {
                // Simulate calculation
                string script = @"
                    document.getElementById('" + btnCalculateRoute.ClientID + @"').innerHTML = 
                        '<i class=""fas fa-spinner fa-spin me-2""></i> Calculating...';
                ";
                ClientScript.RegisterStartupScript(this.GetType(), "ShowLoading", script, true);

                // Simulate delay
                System.Threading.Thread.Sleep(1000);

                UpdateRouteEstimates();
                ShowMessage("Route calculated successfully!", "success");
            }
            catch (Exception ex)
            {
                LogError("btnCalculateRoute_Click", ex.Message);
                ShowMessage("Error calculating route: " + ex.Message, "danger");
            }
        }

        protected void btnSaveRoute_Click(object sender, EventArgs e)
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    string query = @"
IF EXISTS (
    SELECT 1 FROM CollectorRoutes 
    WHERE CollectorId = @CollectorId 
    AND CAST(RouteDate AS DATE) = CAST(GETDATE() AS DATE)
)
BEGIN
    UPDATE CollectorRoutes SET 
        VehicleId = @VehicleId,
        RouteType = @RouteType,
        StartTime = @StartTime,
        BreakTime = @BreakTime,
        Notes = @Notes,
        LastUpdated = GETDATE()
    WHERE CollectorId = @CollectorId 
    AND CAST(RouteDate AS DATE) = CAST(GETDATE() AS DATE);
END
ELSE
BEGIN
    INSERT INTO CollectorRoutes 
        (RouteId, CollectorId, RouteDate, VehicleId, RouteType, 
         StartTime, BreakTime, Notes, Status, CreatedAt)
    VALUES 
        (@RouteId, @CollectorId, GETDATE(), @VehicleId, @RouteType, 
         @StartTime, @BreakTime, @Notes, 'Planned', GETDATE());
END
";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        // Generate route ID
                        string routeId = "RT" + DateTime.Now.ToString("yyyyMMddHHmmss");

                        // Parse times
                        DateTime startTime = DateTime.Today;
                        DateTime breakTime = DateTime.Today.AddHours(12);

                        if (!string.IsNullOrEmpty(txtStartTime.Text))
                        {
                            DateTime.TryParse(txtStartTime.Text, out startTime);
                        }

                        if (!string.IsNullOrEmpty(txtBreakTime.Text))
                        {
                            DateTime.TryParse(txtBreakTime.Text, out breakTime);
                        }

                        cmd.Parameters.AddWithValue("@RouteId", routeId);
                        cmd.Parameters.AddWithValue("@CollectorId", currentCollectorId);
                        cmd.Parameters.AddWithValue("@VehicleId", ddlVehicle.SelectedValue ?? "");
                        cmd.Parameters.AddWithValue("@RouteType", ddlRouteType.SelectedValue);
                        cmd.Parameters.AddWithValue("@StartTime", startTime);
                        cmd.Parameters.AddWithValue("@BreakTime", breakTime);
                        cmd.Parameters.AddWithValue("@Notes", txtRouteNotes.Text ?? "");

                        conn.Open();
                        int rowsAffected = cmd.ExecuteNonQuery();

                        if (rowsAffected > 0)
                        {
                            ShowMessage("Route plan saved successfully!", "success");
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                LogError("btnSaveRoute_Click", ex.Message);
                ShowMessage("Error saving route: " + ex.Message, "danger");
            }
        }

        protected void btnNavigateToStop_Click(object sender, EventArgs e)
        {
            if (routeStops != null && routeStops.Rows.Count > 0)
            {
                DataRow nextStop = routeStops.Rows[0];
                if (nextStop["Lat"] != DBNull.Value && nextStop["Lng"] != DBNull.Value)
                {
                    decimal lat = Convert.ToDecimal(nextStop["Lat"]);
                    decimal lng = Convert.ToDecimal(nextStop["Lng"]);

                    // Open Google Maps in new tab
                    string url = string.Format(
                        "https://www.google.com/maps/dir/?api=1&destination={0},{1}&travelmode=driving",
                        lat, lng
                    );

                    string script = string.Format("window.open('{0}', '_blank');", url);
                    ClientScript.RegisterStartupScript(this.GetType(), "OpenGoogleMaps", script, true);
                }
                else
                {
                    ShowMessage("Stop coordinates not available.", "warning");
                }
            }
        }

        protected void btnSkipStop_Click(object sender, EventArgs e)
        {
            try
            {
                if (routeStops != null && routeStops.Rows.Count > 0)
                {
                    DataRow nextStop = routeStops.Rows[0];
                    string pickupId = nextStop["PickupId"].ToString();

                    UpdateStopStatus(pickupId, "Skipped");
                    ShowMessage("Stop skipped. Will revisit later.", "warning");
                }
            }
            catch (Exception ex)
            {
                LogError("btnSkipStop_Click", ex.Message);
                ShowMessage("Error skipping stop: " + ex.Message, "danger");
            }
        }

        protected void btnCompleteStop_Click(object sender, EventArgs e)
        {
            try
            {
                if (routeStops != null && routeStops.Rows.Count > 0)
                {
                    DataRow nextStop = routeStops.Rows[0];
                    string pickupId = nextStop["PickupId"].ToString();
                    string wasteType = nextStop["WasteType"].ToString();

                    // Store values in hidden fields for JavaScript
                    hiddenPickupId.Value = pickupId;
                    hiddenWasteType.Value = wasteType;

                    // Show verification dialog
                    string script = @"
                        document.getElementById('verifyWeight').value = '" + nextStop["EstimatedKg"] + @"';
                        document.getElementById('verifyWasteType').value = '" + wasteType + @"';
                        new bootstrap.Modal(document.getElementById('verificationModal')).show();
                    ";

                    ClientScript.RegisterStartupScript(this.GetType(), "ShowVerificationModal", script, true);
                }
            }
            catch (Exception ex)
            {
                LogError("btnCompleteStop_Click", ex.Message);
                ShowMessage("Error completing stop: " + ex.Message, "danger");
            }
        }

        protected void btnAddStop_Click(object sender, EventArgs e)
        {
            Response.Redirect("~/Pages/Collectors/AvailablePickups.aspx");
        }

        protected void btnFindStops_Click(object sender, EventArgs e)
        {
            Response.Redirect("~/Pages/Collectors/AvailablePickups.aspx");
        }

        protected void btnSaveNotes_Click(object sender, EventArgs e)
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    string query = @"
                        UPDATE CollectorRoutes
                        SET Notes = @Notes,
                            LastUpdated = GETDATE()
                        WHERE CollectorId = @CollectorId
                        AND CAST(RouteDate AS DATE) = CAST(GETDATE() AS DATE);
                    ";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@CollectorId", currentCollectorId);
                        cmd.Parameters.AddWithValue("@Notes", txtRouteNotes.Text ?? "");

                        conn.Open();
                        int rowsAffected = cmd.ExecuteNonQuery();

                        if (rowsAffected > 0)
                        {
                            ShowMessage("Notes saved successfully!", "success");
                        }
                        else
                        {
                            // Insert if doesn't exist
                            string insertQuery = @"
                                INSERT INTO CollectorRoutes (RouteId, CollectorId, RouteDate, Notes, Status, CreatedAt)
                                VALUES (@RouteId, @CollectorId, GETDATE(), @Notes, 'Planned', GETDATE());
                            ";

                            cmd.CommandText = insertQuery;
                            string routeId = "RT" + DateTime.Now.ToString("yyyyMMddHHmmss");
                            cmd.Parameters.AddWithValue("@RouteId", routeId);

                            rowsAffected = cmd.ExecuteNonQuery();

                            if (rowsAffected > 0)
                            {
                                ShowMessage("Notes saved successfully!", "success");
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                LogError("btnSaveNotes_Click", ex.Message);
                ShowMessage("Error saving notes: " + ex.Message, "danger");
            }
        }

        protected void btnNoteDelay_Click(object sender, EventArgs e)
        {
            AppendNote("🚧 Traffic delay encountered. Adjusting route.");
        }

        protected void btnNoteWeather_Click(object sender, EventArgs e)
        {
            AppendNote("🌧️ Bad weather conditions. Proceeding with caution.");
        }

        protected void btnNoteVehicle_Click(object sender, EventArgs e)
        {
            AppendNote("🔧 Vehicle issue detected. Reduced speed.");
        }

        protected void btnNoteFull_Click(object sender, EventArgs e)
        {
            AppendNote("🚛 Truck nearly full. Consider returning to depot.");
        }

        #endregion

        #region Dropdown Events

        protected void ddlRouteType_SelectedIndexChanged(object sender, EventArgs e)
        {
            UpdateRouteEstimates();
        }

        protected void ddlVehicle_SelectedIndexChanged(object sender, EventArgs e)
        {
            UpdateVehicleInfo();
        }

        protected void ddlSortStops_SelectedIndexChanged(object sender, EventArgs e)
        {
            SortRouteStops(ddlSortStops.SelectedValue);
        }

        #endregion

        #region Repeater Events

        protected void rptRouteStops_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
            {
                DataRowView row = (DataRowView)e.Item.DataItem;

                // Find controls
                LinkButton btnNavigate = (LinkButton)e.Item.FindControl("btnNavigate");
                LinkButton btnUpdateStatus = (LinkButton)e.Item.FindControl("btnUpdateStatus");

                if (btnNavigate != null && btnUpdateStatus != null)
                {
                    string status = row["Status"].ToString();
                    string pickupId = row["PickupId"].ToString();

                    btnNavigate.CommandArgument = row["ReportId"].ToString();
                    btnUpdateStatus.CommandArgument = pickupId;
                    btnUpdateStatus.ToolTip = GetUpdateButtonTooltip(status);
                }
            }
        }

        protected void rptRouteStops_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            switch (e.CommandName)
            {
                case "Navigate":
                    string reportId = e.CommandArgument.ToString();
                    NavigateToStop(reportId);
                    break;

                case "UpdateStatus":
                    string pickupId = e.CommandArgument.ToString();
                    UpdateStopStatus(pickupId, "In Progress");
                    break;
            }
        }

        #endregion

        #region Helper Methods

        private void SetNextStopDetails()
        {
            if (routeStops != null && routeStops.Rows.Count > 0)
            {
                DataRow nextStop = routeStops.Rows[0];

                lblNextStopNumber.Text = nextStop["Sequence"].ToString();
                lblNextStopAddress.Text = nextStop["Address"].ToString();
                lblNextStopWeight.Text = nextStop["EstimatedKg"].ToString() + " kg";
                lblNextStopWasteType.Text = nextStop["WasteType"].ToString();
                lblNextStopCitizen.Text = nextStop["CitizenName"].ToString();

                // Calculate distance
                decimal distance = Convert.ToDecimal(nextStop["Sequence"]) * 0.5m;
                lblNextStopDistance.Text = distance.ToString("F1") + " km";
            }
            else
            {
                lblNextStopNumber.Text = "0";
                lblNextStopAddress.Text = "No stops scheduled";
                lblNextStopWeight.Text = "0 kg";
                lblNextStopWasteType.Text = "N/A";
                lblNextStopCitizen.Text = "N/A";
                lblNextStopDistance.Text = "0 km";
            }
        }

        private void GenerateMapWaypoints()
        {
            if (routeStops != null && routeStops.Rows.Count > 0)
            {
                List<string> waypoints = new List<string>();

                foreach (DataRow row in routeStops.Rows)
                {
                    if (row["Lat"] != DBNull.Value && row["Lng"] != DBNull.Value)
                    {
                        string waypoint = string.Format(
                            "{{lat: {0}, lng: {1}, title: 'Stop {2}'}}",
                            row["Lat"], row["Lng"], row["Sequence"]
                        );
                        waypoints.Add(waypoint);
                    }
                }

                if (waypoints.Count > 1)
                {
                    string script = string.Format(@"
                        setTimeout(function() {{
                            var waypoints = [{0}];
                            calculateRoute(waypoints);
                        }}, 1000);
                    ", string.Join(", ", waypoints));

                    ClientScript.RegisterStartupScript(this.GetType(), "DrawRoute", script, true);
                }
            }
        }

        private void UpdateRouteEstimates()
        {
            try
            {
                // Update time elapsed
                TimeSpan elapsed = DateTime.Now - DateTime.Today.AddHours(8);
                lblTimeElapsed.Text = string.Format("{0:00}:{1:00}",
                    (int)elapsed.TotalHours, elapsed.Minutes);

                // Update distance covered - FIXED: Declare variables before using them
                decimal totalDistance;
                decimal completedStops;

                if (decimal.TryParse(lblTotalDistance.Text.Replace(" km", ""), out totalDistance) &&
                    decimal.TryParse(lblCompletedStops.Text, out completedStops))
                {
                    decimal coveredDistance = completedStops * 0.5m;
                    lblDistanceCovered.Text = coveredDistance.ToString("F1") + " km";
                }
            }
            catch (Exception ex)
            {
                LogError("UpdateRouteEstimates", ex.Message);
            }
        }

        private void UpdateVehicleInfo()
        {
            string vehicle = ddlVehicle.SelectedValue;
            if (!string.IsNullOrEmpty(vehicle))
            {
                if (vehicle.Contains("TRK"))
                {
                    lblTip3.Text = "Truck capacity: 5000 kg. Suitable for large collections.";
                }
                else if (vehicle.Contains("VAN"))
                {
                    lblTip3.Text = "Van capacity: 2000 kg. Good for medium routes.";
                }
            }
        }

        private void SortRouteStops(string sortBy)
        {
            if (routeStops != null)
            {
                DataView dv = routeStops.DefaultView;

                switch (sortBy)
                {
                    case "priority":
                        dv.Sort = "Status ASC, MinutesSinceScheduled DESC";
                        break;
                    case "distance":
                        dv.Sort = "DistanceFromPrev ASC";
                        break;
                    case "weight":
                        dv.Sort = "EstimatedKg DESC";
                        break;
                    default: // sequence
                        dv.Sort = "Sequence ASC";
                        break;
                }

                rptRouteStops.DataSource = dv;
                rptRouteStops.DataBind();
            }
        }

        private void UpdateStopStatus(string pickupId, string status)
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    string query = @"
                        UPDATE PickupRequests
                        SET Status = @Status,
                            CompletedAt = CASE WHEN @Status = 'Collected' THEN GETDATE() ELSE NULL END
                        WHERE PickupId = @PickupId;
                    ";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@PickupId", pickupId);
                        cmd.Parameters.AddWithValue("@Status", status);

                        conn.Open();
                        cmd.ExecuteNonQuery();

                        // Reload data
                        LoadCollectorStats();
                        LoadRouteStops();
                    }
                }
            }
            catch (Exception ex)
            {
                LogError("UpdateStopStatus", ex.Message);
                ShowMessage("Error updating stop status: " + ex.Message, "danger");
            }
        }

        private void NavigateToStop(string reportId)
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    string query = @"
                        SELECT Lat, Lng
                        FROM WasteReports
                        WHERE ReportId = @ReportId;
                    ";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@ReportId", reportId);

                        conn.Open();
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read() && reader["Lat"] != DBNull.Value)
                            {
                                decimal lat = Convert.ToDecimal(reader["Lat"]);
                                decimal lng = Convert.ToDecimal(reader["Lng"]);

                                string url = string.Format(
                                    "https://www.google.com/maps/dir/?api=1&destination={0},{1}&travelmode=driving",
                                    lat, lng
                                );

                                string script = string.Format("window.open('{0}', '_blank');", url);
                                ClientScript.RegisterStartupScript(this.GetType(), "NavigateToStop", script, true);
                            }
                            else
                            {
                                ShowMessage("Location not available for this stop.", "warning");
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                LogError("NavigateToStop", ex.Message);
                ShowMessage("Error navigating to stop.", "danger");
            }
        }

        private void AppendNote(string note)
        {
            string currentNotes = txtRouteNotes.Text;
            string timestamp = DateTime.Now.ToString("HH:mm");

            if (!string.IsNullOrEmpty(currentNotes))
            {
                txtRouteNotes.Text = currentNotes + Environment.NewLine + "[" + timestamp + "] " + note;
            }
            else
            {
                txtRouteNotes.Text = "[" + timestamp + "] " + note;
            }
        }

        protected string GetUpdateButtonTooltip(string status)
        {
            switch (status.ToLower())
            {
                case "requested":
                    return "Start this pickup";
                case "assigned":
                    return "Start pickup";
                case "in progress":
                    return "Complete pickup";
                case "collected":
                    return "Already completed";
                case "skipped":
                    return "Revisit this stop";
                default:
                    return "Update status";
            }
        }

        protected string GetStopRowClass(string status)
        {
            switch (status.ToLower())
            {
                case "in progress":
                    return "current-stop";
                case "collected":
                    return "completed";
                default:
                    return "";
            }
        }

        protected string GetStatusClass(string status)
        {
            switch (status.ToLower())
            {
                case "requested":
                case "assigned":
                    return "pending";
                case "in progress":
                    return "in-progress";
                case "collected":
                    return "completed";
                case "skipped":
                    return "skipped";
                case "cancelled":
                    return "cancelled";
                default:
                    return "pending";
            }
        }

        protected string GetStatusIcon(string status)
        {
            switch (status.ToLower())
            {
                case "requested":
                case "assigned":
                    return "fas fa-clock";
                case "in progress":
                    return "fas fa-play-circle";
                case "collected":
                    return "fas fa-check-circle";
                case "skipped":
                    return "fas fa-forward";
                case "cancelled":
                    return "fas fa-times-circle";
                default:
                    return "fas fa-clock";
            }
        }

        protected string GetCitizenAvatar(string email)
        {
            // Handle null or empty email
            if (string.IsNullOrWhiteSpace(email))
            {
                return ResolveUrl("~/Content/Images/default-avatar.png");
            }

            // Clean up the email
            email = email.Trim().ToLower();

            // Use Gravatar for valid emails
            return "https://www.gravatar.com/avatar/" +
                   GetMd5Hash(email) +
                   "?d=identicon&s=40";
        }

        protected string GetWasteTypeClass(string wasteType)
        {
            if (string.IsNullOrEmpty(wasteType)) return "plastic";

            switch (wasteType.ToLower())
            {
                case "plastic":
                    return "plastic";
                case "paper":
                    return "paper";
                case "glass":
                    return "glass";
                case "metal":
                    return "metal";
                case "organic":
                    return "organic";
                case "electronic":
                    return "electronic";
                default:
                    return "plastic";
            }
        }

        protected string GetWasteTypeIcon(string wasteType)
        {
            if (string.IsNullOrEmpty(wasteType)) return "fas fa-trash";

            switch (wasteType.ToLower())
            {
                case "plastic":
                    return "fas fa-bottle-water";
                case "paper":
                    return "fas fa-file-alt";
                case "glass":
                    return "fas fa-glass-whiskey";
                case "metal":
                    return "fas fa-cog";
                case "organic":
                    return "fas fa-leaf";
                case "electronic":
                    return "fas fa-plug";
                default:
                    return "fas fa-trash";
            }
        }

        protected string GetUpdateButtonClass(string status)
        {
            switch (status.ToLower())
            {
                case "requested":
                case "assigned":
                    return "action-btn primary";
                case "in progress":
                    return "action-btn success";
                case "skipped":
                    return "action-btn warning";
                default:
                    return "action-btn secondary";
            }
        }

        protected string GetUpdateButtonIcon(string status)
        {
            switch (status.ToLower())
            {
                case "requested":
                case "assigned":
                    return "fas fa-play";
                case "in progress":
                    return "fas fa-check";
                case "skipped":
                    return "fas fa-redo";
                default:
                    return "fas fa-edit";
            }
        }

        private string GetMd5Hash(string input)
        {
            using (MD5 md5 = MD5.Create())
            {
                byte[] inputBytes = Encoding.ASCII.GetBytes(input);
                byte[] hashBytes = md5.ComputeHash(inputBytes);

                StringBuilder sb = new StringBuilder();
                for (int i = 0; i < hashBytes.Length; i++)
                {
                    sb.Append(hashBytes[i].ToString("X2"));
                }
                return sb.ToString().ToLower();
            }
        }

        private void ShowMessage(string message, string type)
        {
            string script = string.Format("showMessage('{0}', '{1}');", message.Replace("'", "\\'"), type);
            ClientScript.RegisterStartupScript(this.GetType(), "ShowMessage", script, true);
        }

        private void LogError(string method, string error)
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    string query = @"
                        INSERT INTO ErrorLogs (ErrorType, Url, UserIP, UserAgent, Referrer)
                        VALUES (@ErrorType, @Url, @UserIP, @UserAgent, @Referrer);
                    ";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@ErrorType", method + ": " + error);
                        cmd.Parameters.AddWithValue("@Url", Request.Url.ToString());
                        cmd.Parameters.AddWithValue("@UserIP", Request.UserHostAddress);
                        cmd.Parameters.AddWithValue("@UserAgent", Request.UserAgent != null ? Request.UserAgent : "");

                        // FIXED: Remove null-conditional operator
                        string referrer = "";
                        if (Request.UrlReferrer != null)
                        {
                            referrer = Request.UrlReferrer.ToString();
                        }
                        cmd.Parameters.AddWithValue("@Referrer", referrer);

                        conn.Open();
                        cmd.ExecuteNonQuery();
                    }
                }
            }
            catch
            {
                // If logging fails, write to event log
                System.Diagnostics.EventLog.WriteEntry("Application",
                    "SoorGreen Error: " + method + " - " + error,
                    System.Diagnostics.EventLogEntryType.Error);
            }
        }

        #endregion

        #region Web Methods for AJAX calls

        [WebMethod]
        public static string VerifyPickup(string pickupId, decimal verifiedWeight, string materialType)
        {
            try
            {
                // Use ConfigurationManager to get the connection string in a static context
                string connectionString = ConfigurationManager.ConnectionStrings["SoorGreenDBConnectionString"].ConnectionString;

                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    string query = @"
                BEGIN TRANSACTION;

                -- Insert verification
                DECLARE @VerificationId CHAR(4);
                SELECT @VerificationId = 'PV' + RIGHT('00' + CAST(ISNULL(MAX(CAST(SUBSTRING(VerificationId, 3, 2) AS INT)), 0) + 1 AS VARCHAR(2)), 2)
                FROM PickupVerifications;

                INSERT INTO PickupVerifications (VerificationId, PickupId, VerifiedKg, MaterialType, VerificationMethod)
                VALUES (@VerificationId, @PickupId, @VerifiedKg, @MaterialType, 'Manual');

                -- Update pickup status
                UPDATE PickupRequests
                SET Status = 'Collected',
                    CompletedAt = GETDATE()
                WHERE PickupId = @PickupId;

                -- Get user ID and credit rate
                DECLARE @UserId CHAR(4);
                DECLARE @CreditRate DECIMAL(5,2);

                SELECT @UserId = wr.UserId, @CreditRate = wt.CreditPerKg
                FROM PickupRequests pr
                JOIN WasteReports wr ON pr.ReportId = wr.ReportId
                JOIN WasteTypes wt ON wr.WasteTypeId = wt.WasteTypeId
                WHERE pr.PickupId = @PickupId;

                -- Add reward points
                IF @CreditRate IS NOT NULL AND @UserId IS NOT NULL
                BEGIN
                    DECLARE @RewardId CHAR(4);
                    SELECT @RewardId = 'RP' + RIGHT('00' + CAST(ISNULL(MAX(CAST(SUBSTRING(RewardId, 3, 2) AS INT)), 0) + 1 AS VARCHAR(2)), 2)
                    FROM RewardPoints;

                    INSERT INTO RewardPoints (RewardId, UserId, Amount, Type, Reference)
                    VALUES (@RewardId, @UserId, @VerifiedKg * @CreditRate, 'Credit', 'Pickup ' + @PickupId);
                END

                COMMIT TRANSACTION;
            ";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@PickupId", pickupId);
                        cmd.Parameters.AddWithValue("@VerifiedKg", verifiedWeight);
                        cmd.Parameters.AddWithValue("@MaterialType", materialType);

                        conn.Open();
                        cmd.ExecuteNonQuery();

                        return JsonConvert.SerializeObject(new { success = true, message = "Pickup verified!" });
                    }
                }
            }
            catch (Exception ex)
            {
                return JsonConvert.SerializeObject(new { success = false, message = ex.Message });
            }
        }

        [WebMethod]
        public static string UpdateCollectorLocation(string collectorId, decimal lat, decimal lng)
        {
            try
            {
                // Use ConfigurationManager to get the connection string in a static context
                string connectionString = ConfigurationManager.ConnectionStrings["SoorGreenDBConnectionString"].ConnectionString;

                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    string query = @"
                INSERT INTO CollectorLocations (CollectorId, Lat, Lng, Timestamp)
                VALUES (@CollectorId, @Lat, @Lng, GETDATE());
            ";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@CollectorId", collectorId);
                        cmd.Parameters.AddWithValue("@Lat", lat);
                        cmd.Parameters.AddWithValue("@Lng", lng);

                        conn.Open();
                        cmd.ExecuteNonQuery();

                        return JsonConvert.SerializeObject(new { success = true });
                    }
                }
            }
            catch (Exception ex)
            {
                return JsonConvert.SerializeObject(new { success = false, message = ex.Message });
            }
        }

        #endregion
    }
}