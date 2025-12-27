using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;

namespace SoorGreen.Admin.Admin
{
    public partial class Analytics : System.Web.UI.Page
    {
        // Declare the HTML controls
        //protected HtmlGenericControl totalUsers;
        //protected HtmlGenericControl todayPickups;
        //protected HtmlGenericControl totalCredits;
        //protected HtmlGenericControl wasteReports;
        //protected Button btnRefresh;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadDashboardData();
            }
        }

        protected void RefreshData(object sender, EventArgs e)
        {
            LoadDashboardData();
        }

        private void LoadDashboardData()
        {
            try
            {
                // Try to load from database first
                if (TryLoadFromDatabase())
                {
                    return;
                }

                // If database fails, use simulated data
                UseSimulatedData();
            }
            catch (Exception ex)
            {
                // Use simulated data as fallback
                UseSimulatedData();
                System.Diagnostics.Debug.WriteLine("Analytics load error: " + ex.Message);
            }
        }

        private bool TryLoadFromDatabase()
        {
            try
            {
                string connectionString = System.Configuration.ConfigurationManager.ConnectionStrings["SoorGreenDBConnectionString"].ConnectionString;

                if (string.IsNullOrEmpty(connectionString))
                {
                    return false;
                }

                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    // Load total users count
                    string usersQuery = "SELECT COUNT(*) FROM Users";
                    using (SqlCommand cmd = new SqlCommand(usersQuery, conn))
                    {
                        var result = cmd.ExecuteScalar();
                        if (totalUsers != null)
                            totalUsers.InnerText = result != DBNull.Value ?
                                Convert.ToInt32(result).ToString("N0") : "1,247";
                    }

                    // Load today's pickups
                    string pickupsQuery = @"SELECT COUNT(*) FROM PickupRequests 
                                      WHERE CAST(ScheduledAt AS DATE) = CAST(GETDATE() AS DATE) 
                                      AND Status IN ('Assigned', 'Completed')";
                    using (SqlCommand cmd = new SqlCommand(pickupsQuery, conn))
                    {
                        var result = cmd.ExecuteScalar();
                        if (todayPickups != null)
                            todayPickups.InnerText = result != DBNull.Value ?
                                Convert.ToInt32(result).ToString("N0") : "89";
                    }

                    // Load total credits distributed
                    string creditsQuery = "SELECT SUM(Amount) FROM RewardPoints WHERE Type = 'Credit'";
                    using (SqlCommand cmd = new SqlCommand(creditsQuery, conn))
                    {
                        var result = cmd.ExecuteScalar();
                        if (totalCredits != null)
                        {
                            if (result != DBNull.Value && result != null)
                            {
                                decimal credits = Convert.ToDecimal(result);
                                totalCredits.InnerText = credits >= 1000 ?
                                    (credits / 1000).ToString("0.0") + "K" :
                                    credits.ToString("N0");
                            }
                            else
                            {
                                totalCredits.InnerText = "45.2K";
                            }
                        }
                    }

                    // Load waste reports count (last 30 days)
                    string reportsQuery = @"SELECT COUNT(*) FROM WasteReports 
                                       WHERE CreatedAt >= DATEADD(DAY, -30, GETDATE())";
                    using (SqlCommand cmd = new SqlCommand(reportsQuery, conn))
                    {
                        var result = cmd.ExecuteScalar();
                        if (wasteReports != null)
                            wasteReports.InnerText = result != DBNull.Value ?
                                Convert.ToInt32(result).ToString("N0") : "2,845";
                    }

                    return true;
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Database error: " + ex.Message);
                return false;
            }
        }

        private void UseSimulatedData()
        {
            // Simulated data for demo purposes
            if (totalUsers != null) totalUsers.InnerText = "2,847";
            if (todayPickups != null) todayPickups.InnerText = "156";
            if (totalCredits != null) totalCredits.InnerText = "45.2K";
            if (wasteReports != null) wasteReports.InnerText = "1,234";

            // Register script to show simulated data warning
            ScriptManager.RegisterStartupScript(this, GetType(), "simulatedData",
                "showDemoModeNotification();", true);
        }
    }
}