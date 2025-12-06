using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.Configuration;
using System.Web.UI;
using System.Web.Script.Serialization;
using System.Collections.Generic;

namespace SoorGreen.Citizen
{
    public partial class RedemptionHistory : System.Web.UI.Page
    {
        private string connectionString = WebConfigurationManager.ConnectionStrings["SoorGreenDBConnectionString"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // Authentication check
                if (Session["UserID"] == null)
                {
                    Response.Redirect("~/Login.aspx");
                    return;
                }

                // Store userId in hidden field
                hfUserId.Value = Session["UserID"].ToString();

                // Load redemption data
                LoadRedemptionData();

                // Load stats
                LoadStatsData();
            }
        }

        private void LoadRedemptionData()
        {
            try
            {
                string userId = Session["UserID"].ToString();

                string query = @"
                    SELECT 
                        RedemptionId,
                        'Reward Redemption' as RewardTitle,
                        'You redeemed ' + CAST(Amount AS VARCHAR(20)) + ' XP' as Description,
                        Amount,
                        Method,
                        Status,
                        RequestedAt,
                        ProcessedAt,
                        NULL as ExpiryDate,
                        'Redeemed ' + CAST(Amount AS VARCHAR(20)) + ' XP for rewards' as Notes
                    FROM RedemptionRequests 
                    WHERE UserId = @UserId 
                    ORDER BY RequestedAt DESC";

                using (SqlConnection conn = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@UserId", userId);
                    conn.Open();

                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        var redemptions = new List<object>();
                        while (reader.Read())
                        {
                            redemptions.Add(new
                            {
                                RedemptionId = reader["RedemptionId"].ToString(),
                                RewardTitle = reader["RewardTitle"].ToString(),
                                Description = reader["Description"].ToString(),
                                Amount = Convert.ToDecimal(reader["Amount"]),
                                Method = reader["Method"].ToString(),
                                Status = reader["Status"].ToString(),
                                RequestedAt = Convert.ToDateTime(reader["RequestedAt"]).ToString("yyyy-MM-dd HH:mm:ss"),
                                ProcessedAt = reader["ProcessedAt"] != DBNull.Value ?
                                    Convert.ToDateTime(reader["ProcessedAt"]).ToString("yyyy-MM-dd HH:mm:ss") : null,
                                ExpiryDate = reader["ExpiryDate"] != DBNull.Value ?
                                    reader["ExpiryDate"].ToString() : null,
                                Notes = reader["Notes"].ToString()
                            });
                        }

                        // Store in hidden field
                        hfRedemptionData.Value = new JavaScriptSerializer().Serialize(redemptions);
                    }
                }
            }
            catch (Exception ex)
            {
                // Log error
                System.Diagnostics.Debug.WriteLine("Error loading redemption data: " + ex.Message);
                hfRedemptionData.Value = "[]";
            }
        }

        private void LoadStatsData()
        {
            try
            {
                string userId = Session["UserID"].ToString();

                string query = @"
                    SELECT 
                        COUNT(*) as TotalRedemptions,
                        ISNULL(SUM(Amount), 0) as TotalXPSpent,
                        SUM(CASE WHEN Status = 'Completed' THEN 1 ELSE 0 END) as CompletedRedemptions,
                        SUM(CASE WHEN Status = 'Pending' THEN 1 ELSE 0 END) as PendingRedemptions
                    FROM RedemptionRequests 
                    WHERE UserId = @UserId";

                using (SqlConnection conn = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@UserId", userId);
                    conn.Open();

                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            var stats = new
                            {
                                TotalRedemptions = Convert.ToInt32(reader["TotalRedemptions"]),
                                TotalXPSpent = Convert.ToDecimal(reader["TotalXPSpent"]),
                                ActiveRedemptions = Convert.ToInt32(reader["CompletedRedemptions"]),
                                PendingRedemptions = Convert.ToInt32(reader["PendingRedemptions"])
                            };

                            // Store in hidden field
                            hfStatsData.Value = new JavaScriptSerializer().Serialize(stats);
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                // Log error
                System.Diagnostics.Debug.WriteLine("Error loading stats data: " + ex.Message);

                // Set default stats
                var defaultStats = new
                {
                    TotalRedemptions = 0,
                    TotalXPSpent = 0,
                    ActiveRedemptions = 0,
                    PendingRedemptions = 0
                };
                hfStatsData.Value = new JavaScriptSerializer().Serialize(defaultStats);
            }
        }

        protected void btnBrowseRewards_Click(object sender, EventArgs e)
        {
            // Redirect to MyRewards page
            Response.Redirect("MyRewards.aspx");
        }
    }
}