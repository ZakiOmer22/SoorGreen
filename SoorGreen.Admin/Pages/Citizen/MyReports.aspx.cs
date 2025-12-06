using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.Configuration;
using System.Web.UI;
using System.Web.Script.Serialization;
using System.Collections.Generic;

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
                LoadReportsData();
            }
        }

        private void LoadReportsData()
        {
            try
            {
                string userId = Session["UserID"].ToString();

                // Load reports
                var reports = LoadUserReports(userId);
                hfAllReports.Value = new JavaScriptSerializer().Serialize(reports);

                // Load stats
                var stats = LoadUserStats(userId);
                hfStats.Value = new JavaScriptSerializer().Serialize(stats);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error loading reports data: " + ex.Message);
                hfAllReports.Value = "[]";
                hfStats.Value = "{\"TotalReports\":0,\"PendingReports\":0,\"CompletedReports\":0,\"TotalRewards\":0}";
            }
        }

        private List<object> LoadUserReports(string userId)
        {
            var reports = new List<object>();

            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.Open();

                string query = @"
                    SELECT 
                        wr.ReportId,
                        wt.Name as WasteType,
                        wr.EstimatedKg as Weight,
                        wr.Address as Location,
                        wr.Status,
                        wr.CreatedAt as ReportedDate,
                        wr.XPEarned,
                        wr.Description,
                        wr.Instructions,
                        pr.ScheduledDate
                    FROM WasteReports wr
                    INNER JOIN WasteTypes wt ON wr.WasteTypeId = wt.WasteTypeId
                    LEFT JOIN PickupRequests pr ON wr.ReportId = pr.ReportId
                    WHERE wr.UserId = @UserId
                    ORDER BY wr.CreatedAt DESC";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@UserId", userId);
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            reports.Add(new
                            {
                                ReportId = reader["ReportId"].ToString(),
                                WasteType = reader["WasteType"].ToString(),
                                Weight = reader["Weight"] != DBNull.Value ? Convert.ToDecimal(reader["Weight"]).ToString("F1") : "0",
                                Location = reader["Location"].ToString(),
                                Status = reader["Status"].ToString(),
                                ReportedDate = Convert.ToDateTime(reader["ReportedDate"]).ToString("yyyy-MM-dd"),
                                XPEarned = reader["XPEarned"] != DBNull.Value ? Convert.ToInt32(reader["XPEarned"]).ToString() : "0",
                                Description = reader["Description"] != DBNull.Value ? reader["Description"].ToString() : "",
                                Instructions = reader["Instructions"] != DBNull.Value ? reader["Instructions"].ToString() : "",
                                ScheduledDate = reader["ScheduledDate"] != DBNull.Value ? Convert.ToDateTime(reader["ScheduledDate"]).ToString("yyyy-MM-dd") : null
                            });
                        }
                    }
                }
            }

            return reports;
        }

        private object LoadUserStats(string userId)
        {
            var stats = new
            {
                TotalReports = 0,
                PendingReports = 0,
                CompletedReports = 0,
                TotalRewards = 0
            };

            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.Open();

                string query = @"
                    SELECT 
                        COUNT(*) as TotalReports,
                        SUM(CASE WHEN Status = 'Pending' THEN 1 ELSE 0 END) as PendingReports,
                        SUM(CASE WHEN Status = 'Completed' THEN 1 ELSE 0 END) as CompletedReports,
                        SUM(ISNULL(XPEarned, 0)) as TotalRewards
                    FROM WasteReports 
                    WHERE UserId = @UserId";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@UserId", userId);
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            stats = new
                            {
                                TotalReports = Convert.ToInt32(reader["TotalReports"]),
                                PendingReports = Convert.ToInt32(reader["PendingReports"]),
                                CompletedReports = Convert.ToInt32(reader["CompletedReports"]),
                                TotalRewards = Convert.ToInt32(reader["TotalRewards"])
                            };
                        }
                    }
                }
            }

            return stats;
        }
    }
}