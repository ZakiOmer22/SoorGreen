using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.Configuration;
using System.Web.Services;
using System.Web.UI;

namespace SoorGreen.Admin.Admin
{
    public partial class WasteTypes : System.Web.UI.Page
    {
        private string connectionString = WebConfigurationManager.ConnectionStrings["SoorGreenDBConnectionString"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadWasteTypes();
            }
        }

        protected void LoadWasteTypes(object sender, EventArgs e)
        {
            LoadWasteTypes();
        }

        protected void LoadWasteTypes()
        {
            try
            {
                DataTable typesData = GetWasteTypesFromDatabase();
                hfTypesData.Value = SerializeToJson(typesData);

                // Load statistics
                var stats = GetWasteTypesStatistics();
                hfStatsData.Value = SerializeToJson(stats);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error loading waste types: " + ex.Message);
                hfTypesData.Value = "[]";
                hfStatsData.Value = "{}";
            }
        }

        [WebMethod]
        public static string CreateWasteType(string name, decimal creditRate, string status, string description, string color)
        {
            try
            {
                WasteTypes page = new WasteTypes();
                return page.CreateWasteTypeInDatabase(name, creditRate, status, description, color);
            }
            catch (Exception ex)
            {
                return "Error: " + ex.Message;
            }
        }

        [WebMethod]
        public static string UpdateWasteType(string typeId, string name, decimal creditRate, string status, string description, string color)
        {
            try
            {
                WasteTypes page = new WasteTypes();
                return page.UpdateWasteTypeInDatabase(typeId, name, creditRate, status, description, color);
            }
            catch (Exception ex)
            {
                return "Error: " + ex.Message;
            }
        }

        [WebMethod]
        public static string DeleteWasteType(string typeId)
        {
            try
            {
                WasteTypes page = new WasteTypes();
                return page.DeleteWasteTypeInDatabase(typeId);
            }
            catch (Exception ex)
            {
                return "Error: " + ex.Message;
            }
        }

        // Database methods
        private DataTable GetWasteTypesFromDatabase()
        {
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                string query = @"
                    SELECT 
                        wt.WasteTypeId,
                        wt.Name,
                        wt.CreditPerKg,
                        'Active' AS Status,
                        '' AS Description,
                        '' AS Color,
                        COUNT(w.ReportId) AS ReportsCount,
                        ISNULL(SUM(w.EstimatedKg), 0) AS TotalWeight,
                        ISNULL(AVG(w.EstimatedKg), 0) AS AverageWeight
                    FROM WasteTypes wt
                    LEFT JOIN WasteReports w ON wt.WasteTypeId = w.WasteTypeId
                    GROUP BY wt.WasteTypeId, wt.Name, wt.CreditPerKg
                    ORDER BY wt.Name";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    conn.Open();

                    DataTable dt = new DataTable();
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        da.Fill(dt);
                    }
                    return dt;
                }
            }
        }

        private object GetWasteTypesStatistics()
        {
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                string query = @"
                    SELECT 
                        COUNT(*) AS TotalTypes,
                        ISNULL(AVG(CreditPerKg), 0) AS AverageCreditRate,
                        ISNULL(MAX(CreditPerKg), 0) AS HighestCreditRate,
                        COUNT(*) AS ActiveTypes
                    FROM WasteTypes";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    conn.Open();

                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            return new
                            {
                                TotalTypes = reader["TotalTypes"],
                                AverageCreditRate = reader["AverageCreditRate"],
                                HighestCreditRate = reader["HighestCreditRate"],
                                ActiveTypes = reader["ActiveTypes"]
                            };
                        }
                    }
                }
            }
            return new
            {
                TotalTypes = 0,
                AverageCreditRate = 0m,
                HighestCreditRate = 0m,
                ActiveTypes = 0
            };
        }

        private string CreateWasteTypeInDatabase(string name, decimal creditRate, string status, string description, string color)
        {
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.Open();

                // Generate new WasteTypeId
                string wasteTypeId = GenerateNewId("WT", "WasteTypes", "WasteTypeId", conn);

                // Insert into WasteTypes
                string insertQuery = @"
                    INSERT INTO WasteTypes (WasteTypeId, Name, CreditPerKg)
                    VALUES (@WasteTypeId, @Name, @CreditPerKg)";

                using (SqlCommand cmd = new SqlCommand(insertQuery, conn))
                {
                    cmd.Parameters.AddWithValue("@WasteTypeId", wasteTypeId);
                    cmd.Parameters.AddWithValue("@Name", name);
                    cmd.Parameters.AddWithValue("@CreditPerKg", creditRate);

                    cmd.ExecuteNonQuery();
                }

                // Log to AuditLogs
                string auditId = GenerateNewId("AL", "AuditLogs", "AuditId", conn);
                string auditQuery = @"
                    INSERT INTO AuditLogs (AuditId, Action, Details)
                    VALUES (@AuditId, @Action, @Details)";

                using (SqlCommand auditCmd = new SqlCommand(auditQuery, conn))
                {
                    auditCmd.Parameters.AddWithValue("@AuditId", auditId);
                    auditCmd.Parameters.AddWithValue("@Action", "Waste Type Created");
                    auditCmd.Parameters.AddWithValue("@Details", "Waste Type ID: " + wasteTypeId + ", Name: " + name + ", Credit Rate: " + creditRate);
                    auditCmd.ExecuteNonQuery();
                }

                return "Success: Waste type created successfully. ID: " + wasteTypeId;
            }
        }

        private string UpdateWasteTypeInDatabase(string typeId, string name, decimal creditRate, string status, string description, string color)
        {
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                string query = @"
                    UPDATE WasteTypes 
                    SET Name = @Name, 
                        CreditPerKg = @CreditPerKg
                    WHERE WasteTypeId = @WasteTypeId";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@WasteTypeId", typeId);
                    cmd.Parameters.AddWithValue("@Name", name);
                    cmd.Parameters.AddWithValue("@CreditPerKg", creditRate);

                    conn.Open();
                    int rowsAffected = cmd.ExecuteNonQuery();

                    if (rowsAffected > 0)
                    {
                        // Log to AuditLogs
                        string auditId = GenerateNewId("AL", "AuditLogs", "AuditId", conn);
                        string auditQuery = @"
                            INSERT INTO AuditLogs (AuditId, Action, Details)
                            VALUES (@AuditId, @Action, @Details)";

                        using (SqlCommand auditCmd = new SqlCommand(auditQuery, conn))
                        {
                            auditCmd.Parameters.AddWithValue("@AuditId", auditId);
                            auditCmd.Parameters.AddWithValue("@Action", "Waste Type Updated");
                            auditCmd.Parameters.AddWithValue("@Details", "Waste Type ID: " + typeId + " updated to Name: " + name + ", Credit Rate: " + creditRate);
                            auditCmd.ExecuteNonQuery();
                        }

                        return "Success: Waste type updated successfully";
                    }
                    else
                    {
                        return "Error: Waste type not found";
                    }
                }
            }
        }

        private string DeleteWasteTypeInDatabase(string typeId)
        {
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.Open();

                // Check if there are any waste reports using this type
                string checkQuery = "SELECT COUNT(*) FROM WasteReports WHERE WasteTypeId = @WasteTypeId";
                using (SqlCommand checkCmd = new SqlCommand(checkQuery, conn))
                {
                    checkCmd.Parameters.AddWithValue("@WasteTypeId", typeId);
                    int reportCount = Convert.ToInt32(checkCmd.ExecuteScalar());

                    if (reportCount > 0)
                    {
                        return "Error: Cannot delete waste type. There are " + reportCount + " waste reports using this type. Please reassign them first.";
                    }
                }

                // Delete from WasteTypes
                string deleteQuery = "DELETE FROM WasteTypes WHERE WasteTypeId = @WasteTypeId";
                using (SqlCommand cmd = new SqlCommand(deleteQuery, conn))
                {
                    cmd.Parameters.AddWithValue("@WasteTypeId", typeId);
                    int rowsAffected = cmd.ExecuteNonQuery();

                    if (rowsAffected > 0)
                    {
                        // Log to AuditLogs
                        string auditId = GenerateNewId("AL", "AuditLogs", "AuditId", conn);
                        string auditQuery = @"
                            INSERT INTO AuditLogs (AuditId, Action, Details)
                            VALUES (@AuditId, @Action, @Details)";

                        using (SqlCommand auditCmd = new SqlCommand(auditQuery, conn))
                        {
                            auditCmd.Parameters.AddWithValue("@AuditId", auditId);
                            auditCmd.Parameters.AddWithValue("@Action", "Waste Type Deleted");
                            auditCmd.Parameters.AddWithValue("@Details", "Waste Type ID: " + typeId + " deleted");
                            auditCmd.ExecuteNonQuery();
                        }

                        return "Success: Waste type deleted successfully";
                    }
                    else
                    {
                        return "Error: Waste type not found";
                    }
                }
            }
        }

        private string GenerateNewId(string prefix, string tableName, string idColumn, SqlConnection conn)
        {
            string query = "SELECT ISNULL(MAX(CAST(SUBSTRING(" + idColumn + ", " + (prefix.Length + 1) + ", LEN(" + idColumn + ")) AS INT)), 0) + 1 FROM " + tableName + " WHERE " + idColumn + " LIKE '" + prefix + "%'";

            using (SqlCommand cmd = new SqlCommand(query, conn))
            {
                int nextId = Convert.ToInt32(cmd.ExecuteScalar());

                if (prefix.Length == 2)
                {
                    return prefix + nextId.ToString("D2");
                }
                else if (prefix.Length == 1)
                {
                    return prefix + nextId.ToString("D3");
                }
                else
                {
                    int numDigits = 4 - prefix.Length;
                    return prefix + nextId.ToString("D" + numDigits);
                }
            }
        }

        private string SerializeToJson(DataTable dataTable)
        {
            try
            {
                System.Web.Script.Serialization.JavaScriptSerializer serializer = new System.Web.Script.Serialization.JavaScriptSerializer();
                System.Collections.Generic.List<System.Collections.Generic.Dictionary<string, object>> rows = new System.Collections.Generic.List<System.Collections.Generic.Dictionary<string, object>>();
                System.Collections.Generic.Dictionary<string, object> row;

                foreach (DataRow dr in dataTable.Rows)
                {
                    row = new System.Collections.Generic.Dictionary<string, object>();
                    foreach (DataColumn col in dataTable.Columns)
                    {
                        row.Add(col.ColumnName, dr[col] == DBNull.Value ? null : dr[col]);
                    }
                    rows.Add(row);
                }
                return serializer.Serialize(rows);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error serializing to JSON: " + ex.Message);
                return "[]";
            }
        }

        private string SerializeToJson(object obj)
        {
            try
            {
                System.Web.Script.Serialization.JavaScriptSerializer serializer = new System.Web.Script.Serialization.JavaScriptSerializer();
                return serializer.Serialize(obj);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error serializing to JSON: " + ex.Message);
                return "{}";
            }
        }
    }
}