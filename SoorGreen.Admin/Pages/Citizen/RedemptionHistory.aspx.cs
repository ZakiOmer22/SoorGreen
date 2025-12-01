using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.Configuration;
using System.Web.Services;
using System.Web.UI;

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
                if (Session["UserId"] == null || Session["UserRole"] == null)
                {
                    Response.Redirect("~/Login.aspx");
                    return;
                }

                if (Session["UserRole"].ToString() != "CITZ" && Session["UserRole"].ToString() != "R001")
                {
                    Response.Redirect("~/Pages/Unauthorized.aspx");
                    return;
                }

                LoadData();
            }
        }

        protected void btnApplyFilters_Click(object sender, EventArgs e)
        {
            LoadData();
        }

        protected void btnRefresh_Click(object sender, EventArgs e)
        {
            LoadData();
        }

        protected void btnBrowseRewards_Click(object sender, EventArgs e)
        {
            Response.Redirect("MyRewards.aspx");
        }

        protected void LoadData()
        {
            try
            {
                string statusFilter = Request.Form["statusFilter"] ?? "all";
                string typeFilter = Request.Form["typeFilter"] ?? "all";
                string dateFrom = Request.Form["dateFrom"] ?? "";
                string dateTo = Request.Form["dateTo"] ?? "";

                // Load redemption history
                string redemptionQuery = @"
                    SELECT 
                        r.RedemptionId,
                        r.Amount as XPCost,
                        r.Method as Type,
                        r.Status,
                        r.RequestedAt as ClaimedDate,
                        DATEADD(DAY, 30, r.RequestedAt) as ExpiryDate,
                        'Reward ' + r.RedemptionId as RewardName,
                        CASE 
                            WHEN r.Method = 'Digital' THEN 'DIG' + r.RedemptionId
                            WHEN r.Method = 'Physical' THEN 'PHY' + r.RedemptionId
                            ELSE 'DSC' + r.RedemptionId
                        END as Code,
                        CASE 
                            WHEN r.Method = 'Digital' THEN 0
                            WHEN r.Method = 'Physical' THEN r.Amount * 0.1
                            ELSE r.Amount * 0.05
                        END as Savings
                    FROM RedemptionRequests r
                    WHERE r.UserId = @UserId";

                // Add filters
                if (statusFilter != "all")
                {
                    redemptionQuery += " AND r.Status = @Status";
                }

                if (typeFilter != "all")
                {
                    redemptionQuery += " AND r.Method = @Type";
                }

                if (!string.IsNullOrEmpty(dateFrom))
                {
                    redemptionQuery += " AND r.RequestedAt >= @DateFrom";
                }

                if (!string.IsNullOrEmpty(dateTo))
                {
                    redemptionQuery += " AND r.RequestedAt <= @DateTo";
                }

                redemptionQuery += " ORDER BY r.RequestedAt DESC";

                DataTable redemptionData = GetData(redemptionQuery, statusFilter, typeFilter, dateFrom, dateTo);

                if (redemptionData.Rows.Count > 0)
                {
                    hfRedemptionData.Value = DataTableToJson(redemptionData);
                }
                else
                {
                    hfRedemptionData.Value = "[]";
                }

                // Load statistics
                var stats = new
                {
                    TotalRedemptions = GetScalarValue("SELECT ISNULL(COUNT(*), 0) FROM RedemptionRequests WHERE UserId = @UserId", statusFilter, typeFilter, dateFrom, dateTo),
                    TotalXPSpent = GetScalarValue("SELECT ISNULL(SUM(Amount), 0) FROM RedemptionRequests WHERE UserId = @UserId", statusFilter, typeFilter, dateFrom, dateTo),
                    ActiveRewards = GetScalarValue("SELECT ISNULL(COUNT(*), 0) FROM RedemptionRequests WHERE UserId = @UserId AND Status IN ('Pending', 'Redeemed')", statusFilter, typeFilter, dateFrom, dateTo),
                    TotalSavings = GetScalarValue(@"
                        SELECT ISNULL(SUM(CASE 
                            WHEN Method = 'Digital' THEN 0
                            WHEN Method = 'Physical' THEN Amount * 0.1
                            ELSE Amount * 0.05
                        END), 0) FROM RedemptionRequests WHERE UserId = @UserId", statusFilter, typeFilter, dateFrom, dateTo)
                };

                var serializer = new System.Web.Script.Serialization.JavaScriptSerializer();
                hfStatsData.Value = serializer.Serialize(stats);

            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error in LoadData: " + ex.Message);
                hfRedemptionData.Value = "[]";
                hfStatsData.Value = "{\"TotalRedemptions\":0,\"TotalXPSpent\":0,\"ActiveRewards\":0,\"TotalSavings\":0}";
            }
        }

        private DataTable GetData(string query, string statusFilter, string typeFilter, string dateFrom, string dateTo)
        {
            DataTable dt = new DataTable();
            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();
                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@UserId", Session["UserId"].ToString() ?? "R001");

                        if (statusFilter != "all")
                        {
                            cmd.Parameters.AddWithValue("@Status", statusFilter);
                        }

                        if (typeFilter != "all")
                        {
                            cmd.Parameters.AddWithValue("@Type", typeFilter);
                        }

                        if (!string.IsNullOrEmpty(dateFrom))
                        {
                            cmd.Parameters.AddWithValue("@DateFrom", DateTime.Parse(dateFrom));
                        }

                        if (!string.IsNullOrEmpty(dateTo))
                        {
                            cmd.Parameters.AddWithValue("@DateTo", DateTime.Parse(dateTo).AddDays(1));
                        }

                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            dt.Load(reader);
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Database error: " + ex.Message);
            }
            return dt;
        }

        private decimal GetScalarValue(string query, string statusFilter, string typeFilter, string dateFrom, string dateTo)
        {
            try
            {
                // Add WHERE conditions to the query
                if (!query.ToUpper().Contains("WHERE"))
                {
                    query += " WHERE UserId = @UserId";
                }
                else
                {
                    query += " AND UserId = @UserId";
                }

                if (statusFilter != "all")
                {
                    query += " AND Status = @Status";
                }

                if (typeFilter != "all")
                {
                    query += " AND Method = @Type";
                }

                if (!string.IsNullOrEmpty(dateFrom))
                {
                    query += " AND RequestedAt >= @DateFrom";
                }

                if (!string.IsNullOrEmpty(dateTo))
                {
                    query += " AND RequestedAt <= @DateTo";
                }

                using (SqlConnection conn = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@UserId", Session["UserId"].ToString() ?? "R001");

                    if (statusFilter != "all")
                    {
                        cmd.Parameters.AddWithValue("@Status", statusFilter);
                    }

                    if (typeFilter != "all")
                    {
                        cmd.Parameters.AddWithValue("@Type", typeFilter);
                    }

                    if (!string.IsNullOrEmpty(dateFrom))
                    {
                        cmd.Parameters.AddWithValue("@DateFrom", DateTime.Parse(dateFrom));
                    }

                    if (!string.IsNullOrEmpty(dateTo))
                    {
                        cmd.Parameters.AddWithValue("@DateTo", DateTime.Parse(dateTo).AddDays(1));
                    }

                    conn.Open();
                    var result = cmd.ExecuteScalar();
                    return result != DBNull.Value ? Convert.ToDecimal(result) : 0;
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Scalar error: " + ex.Message);
                return 0;
            }
        }

        private string DataTableToJson(DataTable dt)
        {
            try
            {
                System.Web.Script.Serialization.JavaScriptSerializer serializer = new System.Web.Script.Serialization.JavaScriptSerializer();
                System.Collections.Generic.List<System.Collections.Generic.Dictionary<string, object>> rows = new System.Collections.Generic.List<System.Collections.Generic.Dictionary<string, object>>();
                System.Collections.Generic.Dictionary<string, object> row;

                foreach (DataRow dr in dt.Rows)
                {
                    row = new System.Collections.Generic.Dictionary<string, object>();
                    foreach (DataColumn col in dt.Columns)
                    {
                        object val = dr[col];
                        if (val == DBNull.Value)
                            val = null;
                        else if (val is DateTime)
                            val = ((DateTime)val).ToString("yyyy-MM-ddTHH:mm:ss");

                        row.Add(col.ColumnName, val);
                    }
                    rows.Add(row);
                }
                return serializer.Serialize(rows);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("JSON error: " + ex.Message);
                return "[]";
            }
        }

        [WebMethod]
        public static string RedeemReward(string redemptionId)
        {
            try
            {
                string connectionString = WebConfigurationManager.ConnectionStrings["SoorGreenDBConnectionString"].ConnectionString;

                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    string query = @"
                        UPDATE RedemptionRequests 
                        SET Status = 'Redeemed', 
                            ProcessedAt = GETDATE()
                        WHERE RedemptionId = @RedemptionId 
                        AND UserId = @UserId
                        AND Status = 'Pending'";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@RedemptionId", redemptionId);
                        cmd.Parameters.AddWithValue("@UserId", System.Web.HttpContext.Current.Session["UserId"].ToString() ?? "R001");

                        int rowsAffected = cmd.ExecuteNonQuery();

                        if (rowsAffected > 0)
                        {
                            return "SUCCESS: Reward redeemed successfully!";
                        }
                        else
                        {
                            return "ERROR: Reward not found or cannot be redeemed";
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                return "ERROR: " + ex.Message;
            }
        }

        [WebMethod]
        public static string CancelRedemption(string redemptionId)
        {
            try
            {
                string connectionString = WebConfigurationManager.ConnectionStrings["SoorGreenDBConnectionString"].ConnectionString;

                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    // First get the amount to refund
                    decimal amountToRefund = 0;
                    string getAmountQuery = "SELECT Amount FROM RedemptionRequests WHERE RedemptionId = @RedemptionId AND UserId = @UserId";

                    using (SqlCommand getAmountCommand = new SqlCommand(getAmountQuery, conn))
                    {
                        getAmountCommand.Parameters.AddWithValue("@RedemptionId", redemptionId);
                        getAmountCommand.Parameters.AddWithValue("@UserId", System.Web.HttpContext.Current.Session["UserId"].ToString() ?? "R001");

                        var result = getAmountCommand.ExecuteScalar();
                        if (result != null && result != DBNull.Value)
                        {
                            amountToRefund = Convert.ToDecimal(result);
                        }
                    }

                    string query = @"
                        UPDATE RedemptionRequests 
                        SET Status = 'Cancelled'
                        WHERE RedemptionId = @RedemptionId 
                        AND UserId = @UserId
                        AND Status = 'Pending'";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@RedemptionId", redemptionId);
                        cmd.Parameters.AddWithValue("@UserId", System.Web.HttpContext.Current.Session["UserId"].ToString() ?? "R001");

                        int rowsAffected = cmd.ExecuteNonQuery();

                        if (rowsAffected > 0 && amountToRefund > 0)
                        {
                            // Refund XP credits to user
                            string refundQuery = @"
                                UPDATE Users 
                                SET XP_Credits = XP_Credits + @Amount
                                WHERE UserId = @UserId";

                            using (SqlCommand refundCommand = new SqlCommand(refundQuery, conn))
                            {
                                refundCommand.Parameters.AddWithValue("@Amount", amountToRefund);
                                refundCommand.Parameters.AddWithValue("@UserId", System.Web.HttpContext.Current.Session["UserId"].ToString() ?? "R001");
                                refundCommand.ExecuteNonQuery();
                            }

                            return "SUCCESS: Redemption cancelled successfully! " + amountToRefund + " XP refunded.";
                        }
                        else
                        {
                            return "ERROR: Redemption not found or cannot be cancelled";
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                return "ERROR: " + ex.Message;
            }
        }
    }
}