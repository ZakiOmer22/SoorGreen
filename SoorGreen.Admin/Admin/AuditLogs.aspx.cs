using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.Configuration;
using System.Web.Services;

namespace SoorGreen.Admin.Admin
{
    public partial class AuditLogs : System.Web.UI.Page
    {
        private string connectionString = WebConfigurationManager.ConnectionStrings["SoorGreenDBConnectionString"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadData();
            }
        }

        protected void btnLoadAuditLogs_Click(object sender, EventArgs e)
        {
            LoadData();
        }

        protected void LoadData()
        {
            try
            {
                // Load audit logs with user information
                string auditLogsQuery = @"
                    SELECT 
                        a.AuditId,
                        u.FullName,
                        a.Action,
                        a.Details,
                        a.Timestamp
                    FROM AuditLogs a
                    LEFT JOIN Users u ON a.UserId = u.UserId
                    ORDER BY a.Timestamp DESC";

                DataTable auditLogsData = GetData(auditLogsQuery);

                System.Diagnostics.Debug.WriteLine("Found " + auditLogsData.Rows.Count + " audit logs");

                if (auditLogsData.Rows.Count > 0)
                {
                    hfAuditLogsData.Value = DataTableToJson(auditLogsData);
                    System.Diagnostics.Debug.WriteLine("Audit logs data set to hidden field");
                }
                else
                {
                    hfAuditLogsData.Value = "[]";
                    System.Diagnostics.Debug.WriteLine("No audit logs found, setting empty array");
                }

                // Load statistics
                var stats = new
                {
                    TotalLogs = GetScalarValue("SELECT ISNULL(COUNT(*), 0) FROM AuditLogs"),
                    TodayLogs = GetScalarValue("SELECT ISNULL(COUNT(*), 0) FROM AuditLogs WHERE CAST(Timestamp AS DATE) = CAST(GETDATE() AS DATE)"),
                    UniqueUsers = GetScalarValue("SELECT ISNULL(COUNT(DISTINCT UserId), 0) FROM AuditLogs WHERE UserId IS NOT NULL"),
                    SystemActions = GetScalarValue("SELECT ISNULL(COUNT(*), 0) FROM AuditLogs WHERE UserId IS NULL")
                };

                var serializer = new System.Web.Script.Serialization.JavaScriptSerializer();
                hfStatsData.Value = serializer.Serialize(stats);

                System.Diagnostics.Debug.WriteLine("Stats loaded: " + hfStatsData.Value);

            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error in LoadData: " + ex.Message);
                // If anything fails, set empty data
                hfAuditLogsData.Value = "[]";
                hfStatsData.Value = "{\"TotalLogs\":0,\"TodayLogs\":0,\"UniqueUsers\":0,\"SystemActions\":0}";
            }
        }

        private DataTable GetData(string query)
        {
            DataTable dt = new DataTable();
            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    System.Diagnostics.Debug.WriteLine("Opening database connection...");
                    conn.Open();
                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            dt.Load(reader);
                        }
                    }
                }
                System.Diagnostics.Debug.WriteLine("Database query returned " + dt.Rows.Count + " rows");
            }
            catch (Exception ex)
            {
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
        public static string ClearOldLogs()
        {
            try
            {
                string connectionString = WebConfigurationManager.ConnectionStrings["SoorGreenDBConnectionString"].ConnectionString;

                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    string deleteQuery = "DELETE FROM AuditLogs WHERE Timestamp < DATEADD(day, -30, GETDATE())";
                    using (SqlCommand cmd = new SqlCommand(deleteQuery, conn))
                    {
                        int rowsAffected = cmd.ExecuteNonQuery();
                        return "SUCCESS: " + rowsAffected + " logs cleared";
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