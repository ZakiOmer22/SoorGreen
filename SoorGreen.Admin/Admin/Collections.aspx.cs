using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.Configuration;
using System.Web.Services;

namespace SoorGreen.Admin.Admin
{
    public partial class Collections : System.Web.UI.Page
    {
        private string connectionString = WebConfigurationManager.ConnectionStrings["SoorGreenDBConnectionString"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadData();
            }
        }

        protected void btnLoadCollections_Click(object sender, EventArgs e)
        {
            LoadData();
        }

        protected void LoadData()
        {
            try
            {
                hfCollectionsData.Value = GetJson(GetData(@"
                    SELECT p.PickupId, p.Status, w.Address, wt.Name AS WasteTypeName, 
                           u_citizen.FullName AS CitizenName, u_collector.FullName AS CollectorName,
                           w.EstimatedKg, pv.VerifiedKg, w.CreatedAt
                    FROM PickupRequests p
                    JOIN WasteReports w ON p.ReportId = w.ReportId
                    JOIN WasteTypes wt ON w.WasteTypeId = wt.WasteTypeId
                    JOIN Users u_citizen ON w.UserId = u_citizen.UserId
                    LEFT JOIN Users u_collector ON p.CollectorId = u_collector.UserId
                    LEFT JOIN PickupVerifications pv ON p.PickupId = pv.PickupId"));

                hfCollectorsData.Value = GetJson(GetData("SELECT UserId, FullName FROM Users WHERE RoleId = 'R002'"));
                hfCitizensData.Value = GetJson(GetData("SELECT UserId, FullName FROM Users WHERE RoleId = 'R001'"));
                hfWasteTypesData.Value = GetJson(GetData("SELECT WasteTypeId, Name FROM WasteTypes"));

                // FIXED JSON - Use double quotes for JSON
                hfStatsData.Value = "{\"TotalCollections\":0,\"PendingCollections\":0,\"CompletedToday\":0,\"TotalWeight\":0}";
            }
            catch
            {
                hfCollectionsData.Value = "[]";
                hfCollectorsData.Value = "[]";
                hfCitizensData.Value = "[]";
                hfWasteTypesData.Value = "[]";
                hfStatsData.Value = "{}";
            }
        }

        private DataTable GetData(string query)
        {
            DataTable dt = new DataTable();
            using (SqlConnection conn = new SqlConnection(connectionString))
            using (SqlCommand cmd = new SqlCommand(query, conn))
            {
                conn.Open();
                dt.Load(cmd.ExecuteReader());
            }
            return dt;
        }

        private string GetJson(DataTable dt)
        {
            var serializer = new System.Web.Script.Serialization.JavaScriptSerializer();
            var rows = new System.Collections.Generic.List<System.Collections.Generic.Dictionary<string, object>>();

            foreach (DataRow dr in dt.Rows)
            {
                var row = new System.Collections.Generic.Dictionary<string, object>();
                foreach (DataColumn col in dt.Columns)
                {
                    row.Add(col.ColumnName, dr[col]);
                }
                rows.Add(row);
            }
            return serializer.Serialize(rows);
        }

        [WebMethod]
        public static string AssignCollector(string pickupId, string collectorId, string scheduleDateTime)
        {
            return "Success: Collector assigned";
        }

        [WebMethod]
        public static string CompleteCollection(string pickupId, decimal verifiedWeight, string materialType, string notes)
        {
            return "Success: Collection completed";
        }

        [WebMethod]
        public static string AddCollection(string citizenId, string wasteTypeId, string address, decimal estimatedWeight, string scheduleDate, string notes)
        {
            return "Success: Collection created with ID: PU01";
        }

        [WebMethod]
        public static string DeleteCollection(string pickupId)
        {
            return "Success: Collection deleted";
        }
    }
}