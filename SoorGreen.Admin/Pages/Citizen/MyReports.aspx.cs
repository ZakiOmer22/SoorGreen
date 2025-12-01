using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.Configuration;
using System.Web.UI;

namespace SoorGreen.Admin
{
    public partial class MyReports : System.Web.UI.Page
    {
        private string connectionString = WebConfigurationManager.ConnectionStrings["SoorGreenDBConnectionString"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (Session["UserID"] == null)
                {
                    Response.Redirect("~/Login.aspx");
                    return;
                }

                LoadPageData();
            }
        }

        private void LoadPageData()
        {
            try
            {
                string userId = Session["UserID"].ToString();

                // Load statistics
                LoadStatistics(userId);

            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("LoadPageData Error: " + ex.Message);
            }
        }

        private void LoadStatistics(string userId)
        {
            try
            {
                int totalReports = GetScalarValue("SELECT COUNT(*) FROM WasteReports WHERE UserId = @UserId",
                    new SqlParameter("@UserId", userId));

                int pendingReports = GetScalarValue("SELECT COUNT(*) FROM WasteReports WHERE UserId = @UserId AND Status = 'Pending'",
                    new SqlParameter("@UserId", userId));

                int completedReports = GetScalarValue("SELECT COUNT(*) FROM WasteReports WHERE UserId = @UserId AND Status = 'Completed'",
                    new SqlParameter("@UserId", userId));

                int totalRewards = GetScalarValue("SELECT ISNULL(SUM(Amount), 0) FROM RewardPoints rp INNER JOIN WasteReports wr ON rp.ReferenceId = wr.ReportId WHERE wr.UserId = @UserId",
                    new SqlParameter("@UserId", userId));

                // Update stats using direct JavaScript
                string script = string.Format(@"
                    document.getElementById('totalReports').textContent = {0};
                    document.getElementById('pendingReports').textContent = {1};
                    document.getElementById('completedReports').textContent = {2};
                    document.getElementById('totalRewards').textContent = {3};
                ", totalReports, pendingReports, completedReports, totalRewards);

                ScriptManager.RegisterStartupScript(this, this.GetType(), "UpdateStats", script, true);

            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("LoadStatistics error: " + ex.Message);
            }
        }

        private DataTable GetReportsData(string userId)
        {
            string query = @"
                SELECT wr.ReportId, wt.TypeName as WasteType, wr.EstimatedKg as Weight, 
                       wr.Address as Location, wr.Status, wr.CreatedAt as ReportedDate,
                       wr.Description, wr.Instructions,
                       ISNULL(rp.Amount, 0) as XPEarned
                FROM WasteReports wr
                LEFT JOIN WasteTypes wt ON wr.WasteTypeId = wt.WasteTypeId
                LEFT JOIN RewardPoints rp ON wr.ReportId = rp.ReferenceId AND rp.Type = 'WasteReport'
                WHERE wr.UserId = @UserId
                ORDER BY wr.CreatedAt DESC";

            return GetDataTable(query, new SqlParameter("@UserId", userId));
        }

        private DataTable GetDataTable(string query, params SqlParameter[] parameters)
        {
            DataTable dt = new DataTable();
            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddRange(parameters);
                    conn.Open();
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        dt.Load(reader);
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Database error: " + ex.Message);
            }
            return dt;
        }

        private int GetScalarValue(string query, params SqlParameter[] parameters)
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddRange(parameters);
                    conn.Open();
                    var result = cmd.ExecuteScalar();
                    return result != DBNull.Value ? Convert.ToInt32(result) : 0;
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Scalar error: " + ex.Message);
                return 0;
            }
        }
    }
}