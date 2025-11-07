using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace SoorGreen.Admin.Admin
{
    public partial class Citizens : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadUsersData();
            }
        }

        protected void LoadUsers(object sender, EventArgs e)
        {
            LoadUsersData();
        }

        private void LoadUsersData()
        {
            try
            {
                hfUsersData.Value = "[]";

                string connectionString = System.Configuration.ConfigurationManager.ConnectionStrings["SoorGreenDBConnectionString"].ConnectionString;

                if (string.IsNullOrEmpty(connectionString))
                {
                    System.Diagnostics.Debug.WriteLine("ERROR: Connection string is null or empty");
                    hfUsersData.Value = "[]";
                    return;
                }

                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    try
                    {
                        conn.Open();
                        System.Diagnostics.Debug.WriteLine("Database connection opened successfully");

                        // Updated query to get only citizens
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
                            WHERE r.RoleName IN ('Citizen', 'Customer')
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

                            List<Dictionary<string, object>> usersList = new List<Dictionary<string, object>>();

                            foreach (DataRow row in dataTable.Rows)
                            {
                                Dictionary<string, object> user = new Dictionary<string, object>();

                                user["Id"] = row["UserId"].ToString();
                                user["FirstName"] = row["FullName"].ToString();
                                user["LastName"] = "";
                                user["Email"] = row["Email"] != DBNull.Value ? row["Email"].ToString() : "";
                                user["Phone"] = row["Phone"] != DBNull.Value ? row["Phone"].ToString() : "";

                                // Map RoleName to frontend user types
                                string roleName = row["RoleName"].ToString().ToLower();
                                user["UserType"] = "customer"; // Always set as customer for citizens

                                user["Status"] = Convert.ToBoolean(row["IsVerified"]) ? "active" : "inactive";
                                user["RegistrationDate"] = row["CreatedAt"].ToString();
                                user["Address"] = "";
                                user["Credits"] = row["XP_Credits"] != DBNull.Value ? Convert.ToDecimal(row["XP_Credits"]) : 0;
                                user["TotalPickups"] = 0;
                                user["CompletedPickups"] = 0;

                                usersList.Add(user);
                            }

                            hfUsersData.Value = serializer.Serialize(usersList);
                            System.Diagnostics.Debug.WriteLine("JSON data prepared. Citizen count: " + usersList.Count);
                        }
                    }
                    catch (SqlException sqlEx)
                    {
                        System.Diagnostics.Debug.WriteLine("SQL ERROR: " + sqlEx.Message);
                        System.Diagnostics.Debug.WriteLine("SQL Error Number: " + sqlEx.Number);
                        hfUsersData.Value = "[]";
                    }
                    catch (Exception dbEx)
                    {
                        System.Diagnostics.Debug.WriteLine("DATABASE ERROR: " + dbEx.Message);
                        hfUsersData.Value = "[]";
                    }
                }
            }
            catch (Exception)
            {
                System.Diagnostics.Debug.WriteLine("GENERAL ERROR occurred");
                hfUsersData.Value = "[]";
            }
        }

        [System.Web.Services.WebMethod]
        public static string DeleteUser(string userId)
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
                        cmd.Parameters.AddWithValue("@UserId", userId);
                        int rowsAffected = cmd.ExecuteNonQuery();

                        return rowsAffected > 0 ? "Success: Citizen deleted" : "Error: Citizen not found";
                    }
                }
            }
            catch (Exception ex)
            {
                return "Error: " + ex.Message;
            }
        }

        [System.Web.Services.WebMethod]
        public static string UpdateUserStatus(string userId, string status)
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
                        cmd.Parameters.AddWithValue("@UserId", userId);
                        int rowsAffected = cmd.ExecuteNonQuery();

                        return rowsAffected > 0 ? "Success: Status updated" : "Error: Citizen not found";
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