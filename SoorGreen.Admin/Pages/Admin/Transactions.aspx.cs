using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.Configuration;
using System.Web.Services;

namespace SoorGreen.Admin.Admin
{
    public partial class Transactions : System.Web.UI.Page
    {
        private string connectionString = WebConfigurationManager.ConnectionStrings["SoorGreenDBConnectionString"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadData();
            }
        }

        protected void btnLoadTransactions_Click(object sender, EventArgs e)
        {
            LoadData();
        }

        protected void LoadData()
        {
            try
            {
                // SIMPLIFIED QUERY - Only using columns that definitely exist
                string transactionsQuery = @"
                    SELECT 
                        rp.RewardId,
                        u.FullName,
                        rp.Amount,
                        rp.Type,
                        rp.Reference,
                        rp.CreatedAt
                    FROM RewardPoints rp
                    INNER JOIN Users u ON rp.UserId = u.UserId
                    ORDER BY rp.CreatedAt DESC";

                DataTable transactionsData = GetData(transactionsQuery);

                if (transactionsData.Rows.Count > 0)
                {
                    hfTransactionsData.Value = DataTableToJson(transactionsData);
                }
                else
                {
                    hfTransactionsData.Value = "[]";
                }

                // Load statistics
                var stats = new
                {
                    TotalTransactions = GetScalarValue("SELECT ISNULL(COUNT(*), 0) FROM RewardPoints"),
                    TotalCredits = GetScalarValue("SELECT ISNULL(SUM(CASE WHEN Amount > 0 THEN Amount ELSE 0 END), 0) FROM RewardPoints"),
                    AvgTransaction = GetScalarValue("SELECT ISNULL(AVG(ABS(Amount)), 0) FROM RewardPoints WHERE Amount != 0"),
                    TodayTransactions = GetScalarValue("SELECT ISNULL(COUNT(*), 0) FROM RewardPoints WHERE CAST(CreatedAt AS DATE) = CAST(GETDATE() AS DATE)")
                };

                var serializer = new System.Web.Script.Serialization.JavaScriptSerializer();
                hfStatsData.Value = serializer.Serialize(stats);
            }
            catch (Exception ex)
            {
                Response.Write(ex);
                // Set empty data on error
                hfTransactionsData.Value = "[]";
                hfStatsData.Value = "{\"TotalTransactions\":0,\"TotalCredits\":0,\"AvgTransaction\":0,\"TodayTransactions\":0}";
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
        public static string GetTransactionDetails(string transactionId)
        {
            return string.Format("Details for transaction {0}", transactionId);
        }
    }
}