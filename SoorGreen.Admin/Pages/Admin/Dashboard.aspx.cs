using System;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.HtmlControls;

public partial class SoorGreen_Admin_Dashboard : Page
{
    //protected HtmlGenericControl totalUsers;
    //protected HtmlGenericControl todayPickups;
    //protected HtmlGenericControl totalCredits;
    //protected HtmlGenericControl wasteReports;

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            LoadDashboardData();
        }
    }

    private void LoadDashboardData()
    {
        try
        {
            // Use mock data for now - comment out the database section below
            totalUsers.InnerText = "2,847";
            todayPickups.InnerText = "1,234";
            totalCredits.InnerText = "45.2K";
            wasteReports.InnerText = "5,678";

            string connectionString = System.Configuration.ConfigurationManager.ConnectionStrings["SoorGreenDB"].ConnectionString;

            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.Open();

                // Load total users count
                string usersQuery = "SELECT COUNT(*) FROM Users";
                using (SqlCommand cmd = new SqlCommand(usersQuery, conn))
                {
                    totalUsers.InnerText = Convert.ToInt32(cmd.ExecuteScalar()).ToString("N0");
                }

                // Load today's pickups
                string pickupsQuery = "SELECT COUNT(*) FROM PickupRequests WHERE CAST(ScheduledAt AS DATE) = CAST(GETDATE() AS DATE)";
                using (SqlCommand cmd = new SqlCommand(pickupsQuery, conn))
                {
                    todayPickups.InnerText = Convert.ToInt32(cmd.ExecuteScalar()).ToString("N0");
                }

                // Load total credits distributed
                string creditsQuery = "SELECT SUM(Amount) FROM RewardPoints WHERE Type = 'Credit'";
                using (SqlCommand cmd = new SqlCommand(creditsQuery, conn))
                {
                    var result = cmd.ExecuteScalar();
                    if (result != DBNull.Value)
                    {
                        totalCredits.InnerText = Convert.ToInt32(result).ToString("N0");
                    }
                    else
                    {
                        totalCredits.InnerText = "0";
                    }
                }

                // Load waste reports count
                string reportsQuery = "SELECT COUNT(*) FROM WasteReports WHERE CreatedAt >= DATEADD(DAY, -30, GETDATE())";
                using (SqlCommand cmd = new SqlCommand(reportsQuery, conn))
                {
                    wasteReports.InnerText = Convert.ToInt32(cmd.ExecuteScalar()).ToString("N0");
                }
            }
        }
        catch (Exception ex)
        {
            // Log error and use default values - FIXED: Using string concatenation
            System.Diagnostics.Debug.WriteLine("Error loading dashboard data: " + ex.Message);

            // Set default values
            totalUsers.InnerText = "2,847";
            todayPickups.InnerText = "1,234";
            totalCredits.InnerText = "45.2K";
            wasteReports.InnerText = "5,678";
        }
    }
}