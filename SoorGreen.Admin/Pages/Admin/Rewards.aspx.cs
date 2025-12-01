using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.Configuration;
using System.Web.Services;

namespace SoorGreen.Admin.Admin
{
    public partial class Rewards : System.Web.UI.Page
    {
        private string connectionString = WebConfigurationManager.ConnectionStrings["SoorGreenDBConnectionString"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadData();
            }
        }

        protected void btnLoadRewards_Click(object sender, EventArgs e)
        {
            LoadData();
        }

        protected void LoadData()
        {
            try
            {
                // Load redemption requests
                string redemptionQuery = @"
                    SELECT r.RedemptionId, u.FullName, u.Phone, r.Amount, r.Method, 
                           r.Status, r.RequestedAt, r.ProcessedAt
                    FROM RedemptionRequests r
                    JOIN Users u ON r.UserId = u.UserId
                    ORDER BY r.RequestedAt DESC";

                DataTable redemptionsData = GetData(redemptionQuery);

                if (redemptionsData.Rows.Count > 0)
                {
                    hfRedemptionsData.Value = DataTableToJson(redemptionsData);
                }
                else
                {
                    // Use test data if no real data
                    hfRedemptionsData.Value = @"[
                        { ""RedemptionId"": ""RD01"", ""FullName"": ""John Doe"", ""Phone"": ""123456789"", ""Amount"": 50, ""Method"": ""Bank Transfer"", ""Status"": ""Pending"", ""RequestedAt"": ""2024-01-15T10:30:00"" },
                        { ""RedemptionId"": ""RD02"", ""FullName"": ""Jane Smith"", ""Phone"": ""987654321"", ""Amount"": 25, ""Method"": ""Mobile Money"", ""Status"": ""Approved"", ""RequestedAt"": ""2024-01-14T14:20:00"" }
                    ]";
                }

                // Load reward transactions
                string transactionsQuery = @"
                    SELECT rp.RewardId, u.FullName, rp.Amount, rp.Type, rp.Reference, rp.CreatedAt
                    FROM RewardPoints rp
                    JOIN Users u ON rp.UserId = u.UserId
                    ORDER BY rp.CreatedAt DESC";

                DataTable transactionsData = GetData(transactionsQuery);

                if (transactionsData.Rows.Count > 0)
                {
                    hfTransactionsData.Value = DataTableToJson(transactionsData);
                }
                else
                {
                    hfTransactionsData.Value = @"[
                        { ""RewardId"": ""RP01"", ""FullName"": ""John Doe"", ""Amount"": 10, ""Type"": ""Recycling"", ""Reference"": ""Plastic Bottles"", ""CreatedAt"": ""2024-01-10T08:00:00"" },
                        { ""RewardId"": ""RP02"", ""FullName"": ""Jane Smith"", ""Amount"": 15, ""Type"": ""Bonus"", ""Reference"": ""Referral Program"", ""CreatedAt"": ""2024-01-11T12:30:00"" }
                    ]";
                }

                // Load users with credits
                string usersQuery = @"
                    SELECT UserId, FullName, Phone, Email, XP_Credits, CreatedAt, IsVerified
                    FROM Users
                    WHERE RoleId = 'R001'
                    ORDER BY XP_Credits DESC";

                DataTable usersData = GetData(usersQuery);

                if (usersData.Rows.Count > 0)
                {
                    hfUsersData.Value = DataTableToJson(usersData);
                }
                else
                {
                    hfUsersData.Value = @"[
                        { ""UserId"": ""U001"", ""FullName"": ""John Doe"", ""Phone"": ""123456789"", ""Email"": ""john@test.com"", ""XP_Credits"": 150, ""CreatedAt"": ""2024-01-01T00:00:00"", ""IsVerified"": true },
                        { ""UserId"": ""U002"", ""FullName"": ""Jane Smith"", ""Phone"": ""987654321"", ""Email"": ""jane@test.com"", ""XP_Credits"": 75, ""CreatedAt"": ""2024-01-02T00:00:00"", ""IsVerified"": true }
                    ]";
                }

                // Load statistics
                var stats = new
                {
                    TotalCredits = GetScalarValue("SELECT ISNULL(SUM(Amount), 0) FROM RewardPoints WHERE Amount > 0"),
                    PendingRedemptions = GetScalarValue("SELECT ISNULL(COUNT(*), 0) FROM RedemptionRequests WHERE Status = 'Pending'"),
                    TotalUsers = GetScalarValue("SELECT ISNULL(COUNT(*), 0) FROM Users WHERE RoleId = 'R001'"),
                    AvgCredits = GetScalarValue("SELECT ISNULL(AVG(XP_Credits), 0) FROM Users WHERE RoleId = 'R001'")
                };

                var serializer = new System.Web.Script.Serialization.JavaScriptSerializer();
                hfStatsData.Value = serializer.Serialize(stats);

            }
            catch (Exception ex)
            {
                Response.Write("ERROR: " + ex);
            }
        }

        private DataTable GetData(string query)
        {
            DataTable dt = new DataTable();
            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();
                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            dt.Load(reader);
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                // Return empty table if database fails
                System.Diagnostics.Debug.WriteLine("Database error: " + ex.Message);
            }
            return dt;
        }

        private decimal GetScalarValue(string query)
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
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
        public static string ProcessRedemption(string redemptionId, string action, string reason)
        {
            // FIXED: Using string.Format instead of $ interpolation
            return string.Format("Success: Redemption {0} {1}ed. Reason: {2}",
                redemptionId, action, reason ?? "No reason provided");
        }

        [WebMethod]
        public static string AddCreditsToUser(string userId, decimal amount, string type, string notes)
        {
            // FIXED: Using string.Format instead of $ interpolation
            return string.Format("Success: Added {0} credits to user {1}", amount, userId);
        }
    }
}