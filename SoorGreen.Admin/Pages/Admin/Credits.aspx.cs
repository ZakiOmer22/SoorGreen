using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.Configuration;
using System.Web.Services;

namespace SoorGreen.Admin.Admin
{
    public partial class Credits : System.Web.UI.Page
    {
        private string connectionString = WebConfigurationManager.ConnectionStrings["SoorGreenDBConnectionString"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadData();
            }
        }

        protected void btnLoadCredits_Click(object sender, EventArgs e)
        {
            LoadData();
        }

        protected void LoadData()
        {
            try
            {
                // Load users with their credits and role information
                string usersQuery = @"
                    SELECT 
                        u.UserId,
                        u.FullName,
                        u.Phone,
                        u.Email,
                        u.XP_Credits,
                        r.RoleName,
                        u.IsVerified,
                        u.LastLogin,
                        u.CreatedAt
                    FROM Users u
                    INNER JOIN Roles r ON u.RoleId = r.RoleId
                    ORDER BY u.XP_Credits DESC";

                DataTable usersData = GetData(usersQuery);

                if (usersData.Rows.Count > 0)
                {
                    hfUsersData.Value = DataTableToJson(usersData);
                }
                else
                {
                    hfUsersData.Value = "[]";
                }

                // Load statistics
                var stats = new
                {
                    TotalUsers = GetScalarValue("SELECT ISNULL(COUNT(*), 0) FROM Users"),
                    TotalCredits = GetScalarValue("SELECT ISNULL(SUM(XP_Credits), 0) FROM Users"),
                    AvgCredits = GetScalarValue("SELECT ISNULL(AVG(XP_Credits), 0) FROM Users"),
                    ActiveUsers = GetScalarValue("SELECT ISNULL(COUNT(*), 0) FROM Users WHERE IsVerified = 1")
                };

                var serializer = new System.Web.Script.Serialization.JavaScriptSerializer();
                hfStatsData.Value = serializer.Serialize(stats);
            }
            catch (Exception ex)
            {
                Response.Write(ex);

                // Set empty data on error
                hfUsersData.Value = "[]";
                hfStatsData.Value = "{\"TotalUsers\":0,\"TotalCredits\":0,\"AvgCredits\":0,\"ActiveUsers\":0}";
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
                Response.Write(ex);
                // Return empty table on error
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
            catch
            {
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
                Response.Write(ex);

                return "[]";
            }
        }

        [WebMethod]
        public static string AddUserCredits(string userId, decimal amount, string type, string reference, string notes)
        {
            try
            {
                string connectionString = WebConfigurationManager.ConnectionStrings["SoorGreenDBConnectionString"].ConnectionString;

                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    // Update user's credit balance
                    string updateUserQuery = "UPDATE Users SET XP_Credits = XP_Credits + @Amount WHERE UserId = @UserId";
                    using (SqlCommand cmd = new SqlCommand(updateUserQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@Amount", amount);
                        cmd.Parameters.AddWithValue("@UserId", userId);
                        cmd.ExecuteNonQuery();
                    }

                    // Add to reward points history
                    string insertRewardQuery = @"
                        INSERT INTO RewardPoints (RewardId, UserId, Amount, Type, Reference, Notes, CreatedAt)
                        VALUES (@RewardId, @UserId, @Amount, @Type, @Reference, @Notes, GETDATE())";

                    using (SqlCommand cmd = new SqlCommand(insertRewardQuery, conn))
                    {
                        string rewardId = "RP" + DateTime.Now.ToString("yyyyMMddHHmmss");
                        cmd.Parameters.AddWithValue("@RewardId", rewardId);
                        cmd.Parameters.AddWithValue("@UserId", userId);
                        cmd.Parameters.AddWithValue("@Amount", amount);
                        cmd.Parameters.AddWithValue("@Type", type);
                        cmd.Parameters.AddWithValue("@Reference", reference);
                        cmd.Parameters.AddWithValue("@Notes", notes ?? "");
                        cmd.ExecuteNonQuery();
                    }
                }

                return "SUCCESS";
            }
            catch (Exception ex)
            {
                return "ERROR: " + ex.Message;
            }
        }
    }
}