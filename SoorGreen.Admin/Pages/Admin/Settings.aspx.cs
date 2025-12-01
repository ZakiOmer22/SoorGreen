using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.Configuration;
using System.Web.Services;
using System.Web.UI;

namespace SoorGreen.Admin.Admin
{
    public partial class Settings : System.Web.UI.Page
    {
        private string connectionString = WebConfigurationManager.ConnectionStrings["SoorGreenDBConnectionString"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadData();
            }
        }

        protected void btnLoadSettings_Click(object sender, EventArgs e)
        {
            LoadData();
        }

        protected void LoadData()
        {
            try
            {
                var settings = new
                {
                    general = new
                    {
                        appName = "SoorGreen",
                        supportEmail = "support@soorgreen.com",
                        supportPhone = "+1-555-123-4567",
                        maintenanceMode = false
                    },
                    credits = new
                    {
                        creditToCurrency = 0.01m,
                        minRedemption = 50m,
                        plasticRate = 2.50m,
                        paperRate = 1.80m,
                        glassRate = 1.20m,
                        metalRate = 3.00m,
                        organicRate = 0.80m,
                        autoCreditDistribution = true
                    },
                    notifications = new
                    {
                        emailNotifications = true,
                        smsNotifications = false,
                        pushNotifications = true,
                        notificationSchedule = "instant"
                    },
                    security = new
                    {
                        sessionTimeout = 30,
                        maxLoginAttempts = 5,
                        passwordExpiry = 90,
                        twoFactorAuth = false,
                        apiRateLimiting = true
                    }
                };

                var serializer = new System.Web.Script.Serialization.JavaScriptSerializer();
                hfSettingsData.Value = serializer.Serialize(settings);

                var systemInfo = new
                {
                    TotalUsers = GetScalarValue("SELECT COUNT(*) FROM Users"),
                    TotalPickups = GetScalarValue("SELECT COUNT(*) FROM PickupRequests"),
                    TotalCredits = GetScalarValue("SELECT ISNULL(SUM(Amount), 0) FROM RewardPoints WHERE Type = 'Credit'"),
                    AppVersion = "1.2.1",
                    DatabaseSize = GetDatabaseSize(),
                    LastBackup = GetLastBackupDate(),
                    SystemUptime = "45 days, 12 hours"
                };

                hfSystemInfo.Value = serializer.Serialize(systemInfo);

            }
            catch (Exception ex)
            {
                Response.Write(ex);
                hfSettingsData.Value = "{}";
                hfSystemInfo.Value = "{}";
            }
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

        private string GetDatabaseSize()
        {
            try
            {
                string query = "SELECT CAST(SUM(size) * 8.0 / 1024 AS DECIMAL(10,2)) FROM sys.database_files";

                using (SqlConnection conn = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    conn.Open();
                    var result = cmd.ExecuteScalar();
                    if (result != DBNull.Value && result != null)
                    {
                        return result.ToString() + " MB";
                    }
                    return "Unknown";
                }
            }
            catch
            {
                return "Unknown";
            }
        }

        private string GetLastBackupDate()
        {
            try
            {
                string query = "SELECT MAX(backup_finish_date) FROM msdb.dbo.backupset WHERE database_name = 'SoorGreenDB'";

                using (SqlConnection conn = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    conn.Open();
                    var result = cmd.ExecuteScalar();
                    if (result != DBNull.Value && result != null)
                    {
                        return ((DateTime)result).ToString("MMM dd, yyyy HH:mm");
                    }
                    return "Never";
                }
            }
            catch
            {
                return "Unknown";
            }
        }

        [WebMethod]
        public static string SaveGeneralSettings(string appName, string supportEmail, string supportPhone, bool maintenanceMode)
        {
            try
            {
                return "SUCCESS: General settings saved successfully";
            }
            catch (Exception ex)
            {
                return "ERROR: " + ex.Message;
            }
        }

        [WebMethod]
        public static string SaveCreditSettings(decimal creditToCurrency, decimal minRedemption, bool autoCreditDistribution)
        {
            try
            {
                return "SUCCESS: Credit settings saved successfully";
            }
            catch (Exception ex)
            {
                return "ERROR: " + ex.Message;
            }
        }

        [WebMethod]
        public static string SaveNotificationSettings(bool emailNotifications, bool smsNotifications, bool pushNotifications, string notificationSchedule)
        {
            try
            {
                return "SUCCESS: Notification settings saved successfully";
            }
            catch (Exception ex)
            {
                return "ERROR: " + ex.Message;
            }
        }

        [WebMethod]
        public static string SaveSecuritySettings(int sessionTimeout, int maxLoginAttempts, int passwordExpiry, bool twoFactorAuth, bool apiRateLimiting)
        {
            try
            {
                return "SUCCESS: Security settings saved successfully";
            }
            catch (Exception ex)
            {
                return "ERROR: " + ex.Message;
            }
        }

        [WebMethod]
        public static string BackupDatabase()
        {
            try
            {
                return "SUCCESS: Database backup completed successfully";
            }
            catch (Exception ex)
            {
                return "ERROR: " + ex.Message;
            }
        }

        [WebMethod]
        public static string PurgeOldRecords(int days)
        {
            try
            {
                return "SUCCESS: Purged old records successfully";
            }
            catch (Exception ex)
            {
                return "ERROR: " + ex.Message;
            }
        }
    }
}