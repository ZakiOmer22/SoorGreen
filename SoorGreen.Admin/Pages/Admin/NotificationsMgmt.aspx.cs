using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.Configuration;
using System.Web.Services;
using System.Web.UI;

namespace SoorGreen.Admin.Admin
{
    public partial class NotificationsMgmt : System.Web.UI.Page
    {
        private string connectionString = WebConfigurationManager.ConnectionStrings["SoorGreenDBConnectionString"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadData();
            }
        }

        protected void btnLoadNotifications_Click(object sender, EventArgs e)
        {
            LoadData();
        }

        protected void LoadData()
        {
            try
            {
                // Load notifications with user information
                string notificationsQuery = @"
                    SELECT 
                        n.NotificationId,
                        u.FullName,
                        n.Title,
                        n.Message,
                        n.IsRead,
                        n.CreatedAt,
                        'system' as Type  -- Default type since it doesn't exist in your schema
                    FROM Notifications n
                    LEFT JOIN Users u ON n.UserId = u.UserId
                    ORDER BY n.CreatedAt DESC";

                DataTable notificationsData = GetData(notificationsQuery);

                System.Diagnostics.Debug.WriteLine("Found " + notificationsData.Rows.Count + " notifications");

                if (notificationsData.Rows.Count > 0)
                {
                    hfNotificationsData.Value = DataTableToJson(notificationsData);
                    System.Diagnostics.Debug.WriteLine("Notifications data set to hidden field");
                }
                else
                {
                    hfNotificationsData.Value = "[]";
                    System.Diagnostics.Debug.WriteLine("No notifications found, setting empty array");
                }

                // Load statistics
                var stats = new
                {
                    TotalNotifications = GetScalarValue("SELECT ISNULL(COUNT(*), 0) FROM Notifications"),
                    UnreadNotifications = GetScalarValue("SELECT ISNULL(COUNT(*), 0) FROM Notifications WHERE IsRead = 0"),
                    TodayNotifications = GetScalarValue("SELECT ISNULL(COUNT(*), 0) FROM Notifications WHERE CAST(CreatedAt AS DATE) = CAST(GETDATE() AS DATE)"),
                    SentThisWeek = GetScalarValue("SELECT ISNULL(COUNT(*), 0) FROM Notifications WHERE CreatedAt >= DATEADD(day, -7, GETDATE())")
                };

                var serializer = new System.Web.Script.Serialization.JavaScriptSerializer();
                hfStatsData.Value = serializer.Serialize(stats);

                // Load users for dropdown
                string usersQuery = @"
                    SELECT UserId, FullName, Phone 
                    FROM Users 
                    WHERE RoleId IN ('R001', 'R002') 
                    ORDER BY FullName";

                DataTable usersData = GetData(usersQuery);
                hfUsersData.Value = DataTableToJson(usersData);

                System.Diagnostics.Debug.WriteLine("Stats loaded: " + hfStatsData.Value);

            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error in LoadData: " + ex.Message);
                System.Diagnostics.Debug.WriteLine("Stack trace: " + ex.StackTrace);
                // If anything fails, set empty data
                hfNotificationsData.Value = "[]";
                hfStatsData.Value = "{\"TotalNotifications\":0,\"UnreadNotifications\":0,\"TodayNotifications\":0,\"SentThisWeek\":0}";
                hfUsersData.Value = "[]";
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
                System.Diagnostics.Debug.WriteLine("Stack trace: " + ex.StackTrace);
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
                        else if (val is bool)
                            val = (bool)val;

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
        public static string MarkAsRead(string notificationId)
        {
            try
            {
                string connectionString = WebConfigurationManager.ConnectionStrings["SoorGreenDBConnectionString"].ConnectionString;

                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    string updateQuery = "UPDATE Notifications SET IsRead = 1 WHERE NotificationId = @NotificationId";
                    using (SqlCommand cmd = new SqlCommand(updateQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@NotificationId", notificationId);
                        int rowsAffected = cmd.ExecuteNonQuery();

                        if (rowsAffected > 0)
                            return "SUCCESS: Notification marked as read";
                        else
                            return "ERROR: Notification not found";
                    }
                }
            }
            catch (Exception ex)
            {
                return "ERROR: " + ex.Message;
            }
        }

        [WebMethod]
        public static string MarkAllAsRead()
        {
            try
            {
                string connectionString = WebConfigurationManager.ConnectionStrings["SoorGreenDBConnectionString"].ConnectionString;

                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    string updateQuery = "UPDATE Notifications SET IsRead = 1 WHERE IsRead = 0";
                    using (SqlCommand cmd = new SqlCommand(updateQuery, conn))
                    {
                        int rowsAffected = cmd.ExecuteNonQuery();
                        return "SUCCESS: " + rowsAffected + " notifications marked as read";
                    }
                }
            }
            catch (Exception ex)
            {
                return "ERROR: " + ex.Message;
            }
        }

        [WebMethod]
        public static string DeleteNotification(string notificationId)
        {
            try
            {
                string connectionString = WebConfigurationManager.ConnectionStrings["SoorGreenDBConnectionString"].ConnectionString;

                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    string deleteQuery = "DELETE FROM Notifications WHERE NotificationId = @NotificationId";
                    using (SqlCommand cmd = new SqlCommand(deleteQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@NotificationId", notificationId);
                        int rowsAffected = cmd.ExecuteNonQuery();

                        if (rowsAffected > 0)
                            return "SUCCESS: Notification deleted successfully";
                        else
                            return "ERROR: Notification not found";
                    }
                }
            }
            catch (Exception ex)
            {
                return "ERROR: " + ex.Message;
            }
        }

        [WebMethod]
        public static string SendNotification(string userId, string title, string message, string type)
        {
            try
            {
                string connectionString = WebConfigurationManager.ConnectionStrings["SoorGreenDBConnectionString"].ConnectionString;

                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    // Generate new NotificationId
                    string getMaxIdQuery = "SELECT ISNULL(MAX(CAST(SUBSTRING(NotificationId, 3, LEN(NotificationId)) AS INT)), 0) + 1 FROM Notifications WHERE NotificationId LIKE 'NO%'";
                    string newId;

                    using (SqlCommand idCmd = new SqlCommand(getMaxIdQuery, conn))
                    {
                        var result = idCmd.ExecuteScalar();
                        newId = "NO" + Convert.ToInt32(result).ToString("D2");
                    }

                    string insertQuery = @"
                        INSERT INTO Notifications (NotificationId, UserId, Title, Message, IsRead, CreatedAt)
                        VALUES (@NotificationId, @UserId, @Title, @Message, 0, GETDATE())";

                    using (SqlCommand cmd = new SqlCommand(insertQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@NotificationId", newId);
                        cmd.Parameters.AddWithValue("@UserId", userId == "all" ? (object)DBNull.Value : userId);
                        cmd.Parameters.AddWithValue("@Title", title);
                        cmd.Parameters.AddWithValue("@Message", message);

                        int rowsAffected = cmd.ExecuteNonQuery();

                        if (rowsAffected > 0)
                            return "SUCCESS: Notification sent successfully";
                        else
                            return "ERROR: Failed to send notification";
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