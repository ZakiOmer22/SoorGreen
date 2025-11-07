using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace SoorGreen.Admin.Admin
{
    public partial class Collectors : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadCollectorsData();
            }
        }

        protected void LoadCollectors(object sender, EventArgs e)
        {
            LoadCollectorsData();
        }

        private void LoadCollectorsData()
        {
            try
            {
                hfCollectorsData.Value = "[]";

                string connectionString = System.Configuration.ConfigurationManager.ConnectionStrings["SoorGreenDBConnectionString"].ConnectionString;

                if (string.IsNullOrEmpty(connectionString))
                {
                    System.Diagnostics.Debug.WriteLine("ERROR: Connection string is null or empty");
                    hfCollectorsData.Value = "[]";
                    return;
                }

                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    try
                    {
                        conn.Open();
                        System.Diagnostics.Debug.WriteLine("Database connection opened successfully");

                        // Query to get only collectors with additional collector-specific data
                        string query = @"
                            SELECT 
                                u.UserId,
                                u.FullName,
                                u.Phone,
                                u.Email,
                                r.RoleName,
                                u.XP_Credits,
                                u.CreatedAt,
                                u.IsVerified
                            FROM Users u
                            JOIN Roles r ON u.RoleId = r.RoleId
                            WHERE r.RoleName IN ('Collector', 'Waste Collector')
                            ORDER BY u.CreatedAt DESC";

                        System.Diagnostics.Debug.WriteLine("Executing query: " + query);

                        using (SqlCommand cmd = new SqlCommand(query, conn))
                        using (SqlDataAdapter adapter = new SqlDataAdapter(cmd))
                        {
                            DataTable dataTable = new DataTable();
                            int rowsCount = adapter.Fill(dataTable);

                            System.Diagnostics.Debug.WriteLine("Query executed successfully. Rows returned: " + rowsCount);

                            System.Web.Script.Serialization.JavaScriptSerializer serializer =
                                new System.Web.Script.Serialization.JavaScriptSerializer();

                            List<Dictionary<string, object>> collectorsList = new List<Dictionary<string, object>>();

                            foreach (DataRow row in dataTable.Rows)
                            {
                                Dictionary<string, object> collector = new Dictionary<string, object>();

                                collector["Id"] = row["UserId"].ToString();
                                collector["FirstName"] = row["FullName"].ToString();
                                collector["LastName"] = "";
                                collector["Email"] = row["Email"] != DBNull.Value ? row["Email"].ToString() : "";
                                collector["Phone"] = row["Phone"] != DBNull.Value ? row["Phone"].ToString() : "";

                                // Map RoleName to frontend user types
                                string roleName = row["RoleName"].ToString().ToLower();
                                collector["UserType"] = "collector";

                                collector["Status"] = Convert.ToBoolean(row["IsVerified"]) ? "active" : "inactive";
                                collector["Availability"] = new Random().Next(0, 2) == 0 ? "online" : "offline"; // Mock data
                                collector["RegistrationDate"] = row["CreatedAt"].ToString();
                                collector["Address"] = "";
                                collector["VehicleInfo"] = "Truck - ABC123"; // Mock data
                                collector["CompletedPickups"] = new Random().Next(50, 500); // Mock data
                                collector["TotalPickups"] = new Random().Next(60, 550); // Mock data
                                collector["Rating"] = Math.Round((new Random().NextDouble() * 2) + 3, 1); // Mock data 3.0-5.0
                                collector["Earnings"] = Math.Round(new Random().NextDouble() * 5000, 2); // Mock data

                                collectorsList.Add(collector);
                            }

                            hfCollectorsData.Value = serializer.Serialize(collectorsList);
                            System.Diagnostics.Debug.WriteLine("JSON data prepared. Collector count: " + collectorsList.Count);
                        }
                    }
                    catch (SqlException sqlEx)
                    {
                        System.Diagnostics.Debug.WriteLine("SQL ERROR: " + sqlEx.Message);
                        System.Diagnostics.Debug.WriteLine("SQL Error Number: " + sqlEx.Number);
                        hfCollectorsData.Value = "[]";
                    }
                    catch (Exception dbEx)
                    {
                        System.Diagnostics.Debug.WriteLine("DATABASE ERROR: " + dbEx.Message);
                        hfCollectorsData.Value = "[]";
                    }
                }
            }
            catch (Exception)
            {
                System.Diagnostics.Debug.WriteLine("GENERAL ERROR occurred");
                hfCollectorsData.Value = "[]";
            }
        }

        [System.Web.Services.WebMethod]
        public static string DeleteCollector(string collectorId)
        {
            try
            {
                string connectionString = System.Configuration.ConfigurationManager.ConnectionStrings["SoorGreenDBConnectionString"].ConnectionString;

                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    string query = "DELETE FROM Users WHERE UserId = @UserId";
                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@UserId", collectorId);
                        int rowsAffected = cmd.ExecuteNonQuery();

                        return rowsAffected > 0 ? "Success: Collector deleted" : "Error: Collector not found";
                    }
                }
            }
            catch (Exception ex)
            {
                return "Error: " + ex.Message;
            }
        }

        [System.Web.Services.WebMethod]
        public static string UpdateCollectorStatus(string collectorId, string status)
        {
            try
            {
                string connectionString = System.Configuration.ConfigurationManager.ConnectionStrings["SoorGreenDBConnectionString"].ConnectionString;

                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    int isVerified = (status == "active") ? 1 : 0;
                    string query = "UPDATE Users SET IsVerified = @IsVerified WHERE UserId = @UserId";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@IsVerified", isVerified);
                        cmd.Parameters.AddWithValue("@UserId", collectorId);
                        int rowsAffected = cmd.ExecuteNonQuery();

                        return rowsAffected > 0 ? "Success: Status updated" : "Error: Collector not found";
                    }
                }
            }
            catch (Exception ex)
            {
                return "Error: " + ex.Message;
            }
        }
    }
}