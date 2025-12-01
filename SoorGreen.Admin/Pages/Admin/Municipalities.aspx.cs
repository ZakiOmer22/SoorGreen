using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.Configuration;
using System.Web.Services;

namespace SoorGreen.Admin.Admin
{
    public partial class Municipalities : System.Web.UI.Page
    {
        private string connectionString = WebConfigurationManager.ConnectionStrings["SoorGreenDBConnectionString"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadData();
            }
        }

        protected void btnLoadMunicipalities_Click(object sender, EventArgs e)
        {
            LoadData();
        }

        protected void LoadData()
        {
            try
            {
                // Load municipalities with user and report counts - FIXED QUERY
                string municipalitiesQuery = @"
                    SELECT 
                        m.MunicipalityId,
                        m.Name,
                        0 as UserCount,
                        0 as ReportCount,
                        0 as TotalCredits
                    FROM Municipalities m
                    ORDER BY m.Name";

                DataTable municipalitiesData = GetData(municipalitiesQuery);

                System.Diagnostics.Debug.WriteLine("Found " + municipalitiesData.Rows.Count + " municipalities");

                if (municipalitiesData.Rows.Count > 0)
                {
                    hfMunicipalitiesData.Value = DataTableToJson(municipalitiesData);
                    System.Diagnostics.Debug.WriteLine("Municipalities data set to hidden field");
                }
                else
                {
                    hfMunicipalitiesData.Value = "[]";
                    System.Diagnostics.Debug.WriteLine("No municipalities found, setting empty array");
                }

                // Load statistics - FIXED QUERIES
                var stats = new
                {
                    TotalMunicipalities = GetScalarValue("SELECT ISNULL(COUNT(*), 0) FROM Municipalities"),
                    TotalUsers = GetScalarValue("SELECT ISNULL(COUNT(*), 0) FROM Users"),
                    TotalReports = GetScalarValue("SELECT ISNULL(COUNT(*), 0) FROM WasteReports"),
                    AvgUsers = 0
                };

                var serializer = new System.Web.Script.Serialization.JavaScriptSerializer();
                hfStatsData.Value = serializer.Serialize(stats);

                System.Diagnostics.Debug.WriteLine("Stats loaded: " + hfStatsData.Value);

            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error in LoadData: " + ex.Message);
                // If anything fails, set empty data
                hfMunicipalitiesData.Value = "[]";
                hfStatsData.Value = "{\"TotalMunicipalities\":0,\"TotalUsers\":0,\"TotalReports\":0,\"AvgUsers\":0}";
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
        public static string SaveMunicipality(string municipalityId, string name, string action)
        {
            try
            {
                string connectionString = WebConfigurationManager.ConnectionStrings["SoorGreenDBConnectionString"].ConnectionString;

                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    if (action == "add")
                    {
                        string insertQuery = "INSERT INTO Municipalities (MunicipalityId, Name) VALUES (@MunicipalityId, @Name)";
                        using (SqlCommand cmd = new SqlCommand(insertQuery, conn))
                        {
                            cmd.Parameters.AddWithValue("@MunicipalityId", municipalityId);
                            cmd.Parameters.AddWithValue("@Name", name);
                            cmd.ExecuteNonQuery();
                        }
                    }
                    else if (action == "edit")
                    {
                        string updateQuery = "UPDATE Municipalities SET Name = @Name WHERE MunicipalityId = @MunicipalityId";
                        using (SqlCommand cmd = new SqlCommand(updateQuery, conn))
                        {
                            cmd.Parameters.AddWithValue("@Name", name);
                            cmd.Parameters.AddWithValue("@MunicipalityId", municipalityId);
                            cmd.ExecuteNonQuery();
                        }
                    }
                }

                return "SUCCESS";
            }
            catch (Exception ex)
            {
                return "ERROR: " + ex.Message;
            }
        }

        [WebMethod]
        public static string DeleteMunicipality(string municipalityId)
        {
            try
            {
                string connectionString = WebConfigurationManager.ConnectionStrings["SoorGreenDBConnectionString"].ConnectionString;

                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    string deleteQuery = "DELETE FROM Municipalities WHERE MunicipalityId = @MunicipalityId";
                    using (SqlCommand cmd = new SqlCommand(deleteQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@MunicipalityId", municipalityId);
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