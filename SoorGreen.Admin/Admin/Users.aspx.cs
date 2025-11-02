using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace SoorGreen.Admin.Admin
{
    public partial class Users : System.Web.UI.Page
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
                LoadFromDatabase();
            }
            catch (Exception ex)
            {
                // Log error but don't use dummy data
                System.Diagnostics.Debug.WriteLine(string.Format("Users load error: {0}", ex.Message));
                hfUsersData.Value = "[]"; // Empty array instead of dummy data
                ScriptManager.RegisterStartupScript(this, GetType(), "loadError",
                    "showError('Failed to load users from database. Please try again.');", true);
            }
        }

        private void LoadFromDatabase()
        {
            string connectionString = System.Configuration.ConfigurationManager.ConnectionStrings["SoorGreenDB"].ConnectionString;

            if (string.IsNullOrEmpty(connectionString))
            {
                throw new Exception("Database connection string not found");
            }

            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.Open();

                // FIXED QUERY - Using your actual database schema
                string query = @"
                    SELECT 
                        U.UserId as Id,
                        U.FullName as FirstName,  -- Using FullName as FirstName for compatibility
                        '' as LastName,           -- Empty since you only have FullName
                        U.Email,
                        U.Phone,
                        R.RoleName as UserType,   -- Using RoleName as UserType
                        CASE 
                            WHEN U.IsVerified = 1 THEN 'active'
                            ELSE 'inactive'
                        END as Status,
                        U.CreatedAt as RegistrationDate,
                        '' as Address,            -- Empty since not in your schema
                        ISNULL(U.XP_Credits, 0) as Credits,
                        0 as TotalPickups,        -- Default values since these tables might not exist yet
                        0 as CompletedPickups
                    FROM Users U
                    INNER JOIN Roles R ON U.RoleId = R.RoleId
                    ORDER BY U.CreatedAt DESC";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                using (SqlDataAdapter adapter = new SqlDataAdapter(cmd))
                {
                    DataTable dataTable = new DataTable();
                    adapter.Fill(dataTable);

                    // Debug: Check what data we're getting
                    System.Diagnostics.Debug.WriteLine(string.Format("Loaded {0} users from database", dataTable.Rows.Count));
                    foreach (DataRow row in dataTable.Rows)
                    {
                        System.Diagnostics.Debug.WriteLine(string.Format("User: {0} - {1} - {2}",
                            row["FirstName"], row["Email"], row["Status"]));
                    }

                    // Convert DataTable to JSON for client-side
                    System.Web.Script.Serialization.JavaScriptSerializer serializer =
                        new System.Web.Script.Serialization.JavaScriptSerializer();
                    List<Dictionary<string, object>> rows = new List<Dictionary<string, object>>();

                    foreach (DataRow dr in dataTable.Rows)
                    {
                        Dictionary<string, object> row = new Dictionary<string, object>();
                        foreach (DataColumn col in dataTable.Columns)
                        {
                            // Handle DBNull values
                            if (dr[col] == DBNull.Value)
                            {
                                row.Add(col.ColumnName, null);
                            }
                            else
                            {
                                row.Add(col.ColumnName, dr[col]);
                            }
                        }
                        rows.Add(row);
                    }

                    hfUsersData.Value = serializer.Serialize(rows);

                    // Register script to show success message
                    if (dataTable.Rows.Count > 0)
                    {
                        ScriptManager.RegisterStartupScript(this, GetType(), "dataLoaded",
                            "showSuccess('Loaded " + dataTable.Rows.Count + " users from database');", true);
                    }
                    else
                    {
                        ScriptManager.RegisterStartupScript(this, GetType(), "noUsers",
                            "showInfo('No users found in database');", true);
                    }
                }
            }
        }

        // Method to handle user actions from client-side
        [System.Web.Services.WebMethod]
        public static string DeleteUser(string userId)  // Changed to string to match your CHAR(4) format
        {
            try
            {
                string connectionString = System.Configuration.ConfigurationManager.ConnectionStrings["SoorGreenDB"].ConnectionString;

                if (string.IsNullOrEmpty(connectionString))
                {
                    return "Error: Connection string not found";
                }

                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    string query = "DELETE FROM Users WHERE UserId = @UserId";
                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@UserId", userId);
                        int rowsAffected = cmd.ExecuteNonQuery();

                        if (rowsAffected > 0)
                        {
                            return "Success: User deleted successfully";
                        }
                        else
                        {
                            return "Error: User not found";
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                return "Error: " + ex.Message;
            }
        }

        [System.Web.Services.WebMethod]
        public static string UpdateUserStatus(string userId, string status)  // Changed to string to match your CHAR(4) format
        {
            try
            {
                string connectionString = System.Configuration.ConfigurationManager.ConnectionStrings["SoorGreenDB"].ConnectionString;

                if (string.IsNullOrEmpty(connectionString))
                {
                    return "Error: Connection string not found";
                }

                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    // Convert status to IsVerified bit
                    int isVerified = (status == "active") ? 1 : 0;

                    string query = "UPDATE Users SET IsVerified = @IsVerified WHERE UserId = @UserId";
                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@IsVerified", isVerified);
                        cmd.Parameters.AddWithValue("@UserId", userId);
                        int rowsAffected = cmd.ExecuteNonQuery();

                        if (rowsAffected > 0)
                        {
                            return "Success: User status updated successfully";
                        }
                        else
                        {
                            return "Error: User not found";
                        }
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