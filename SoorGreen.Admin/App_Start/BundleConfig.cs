using System.Web.Optimization;
using System.Web.UI;

namespace SoorGreen.Admin
{
    public class BundleConfig
    {
        public static void RegisterBundles(BundleCollection bundles)
        {
            // IMPORTANT: Clear all bundles first
            bundles.Clear();

            RegisterJQueryScriptManager();

            bundles.Add(new ScriptBundle("~/bundles/WebFormsJs").Include(
                            "~/Scripts/WebForms/WebForms.js",
                            "~/Scripts/WebForms/WebUIValidation.js",
                            "~/Scripts/WebForms/MenuStandards.js",
                            "~/Scripts/WebForms/Focus.js",
                            "~/Scripts/WebForms/GridView.js",
                            "~/Scripts/WebForms/DetailsView.js",
                            "~/Scripts/WebForms/TreeView.js",
                            "~/Scripts/WebForms/WebParts.js"));

            bundles.Add(new ScriptBundle("~/bundles/MsAjaxJs").Include(
                    "~/Scripts/WebForms/MsAjax/MicrosoftAjax.js",
                    "~/Scripts/WebForms/MsAjax/MicrosoftAjaxApplicationServices.js",
                    "~/Scripts/WebForms/MsAjax/MicrosoftAjaxTimer.js",
                    "~/Scripts/WebForms/MsAjax/MicrosoftAjaxWebForms.js"));

            bundles.Add(new ScriptBundle("~/bundles/modernizr").Include(
                            "~/Scripts/modernizr-*"));

            // ==========================================
            //   GENERAL PAGES BUNDLES
            // ==========================================

            bundles.Add(new StyleBundle("~/bundles/Content/default").Include(
                "~/Content/bootstrap.css",
                "~/Content/Site.css",
                "~/Styles/main.css",
                "~/Styles/Style.css"));

            bundles.Add(new ScriptBundle("~/bundles/Scripts/default").Include(
                "~/Scripts/jquery-3.7.0.js",
                "~/Scripts/bootstrap.js",
                "~/Scripts/modernizr-2.8.3.js"));

            // About Page
            bundles.Add(new StyleBundle("~/bundles/Content/about").Include(
                "~/Styles/About.css",
                "~/Content/Pages/about.css"));

            bundles.Add(new ScriptBundle("~/bundles/Scripts/about").Include(
                "~/Scripts/Pages/about.js"));

            // ==========================================
            //   CITIZEN PAGES BUNDLES - CORRECT PATHS
            // ==========================================

            // Citizen Report Waste - THIS IS THE IMPORTANT ONE
            bundles.Add(new StyleBundle("~/Content/citizenreportwaste").Include(
                "~/Content/Pages/Citizen/citizenreportwaste.css"));

            bundles.Add(new ScriptBundle("~/bundles/citizenreportwaste").Include(
                "~/Scripts/Pages/Citizen/citizenreportwaste.js"));

            // Citizen Dashboard
            bundles.Add(new StyleBundle("~/Content/citizendashboard").Include(
                "~/Content/Pages/Citizen/citizendashboard.css"));

            bundles.Add(new ScriptBundle("~/bundles/citizendashboard").Include(
                "~/Scripts/Pages/Citizen/citizendashboard.js"));

            // Citizen Community
            bundles.Add(new StyleBundle("~/Content/citizencommunity").Include(
                "~/Content/Pages/Citizen/citizencommunity.css"));

            bundles.Add(new ScriptBundle("~/bundles/citizencommunity").Include(
                "~/Scripts/Pages/Citizen/citizencommunity.js"));

            // Citizen Feedback
            bundles.Add(new StyleBundle("~/Content/citizenfeedback").Include(
                "~/Content/Pages/Citizen/citizenfeedback.css"));

            bundles.Add(new ScriptBundle("~/bundles/citizenfeedback").Include(
                "~/Scripts/Pages/Citizen/citizenfeedback.js"));

            // Citizen Help
            bundles.Add(new StyleBundle("~/Content/citizenhelp").Include(
                "~/Content/Pages/Citizen/citizenhelp.css"));

            bundles.Add(new ScriptBundle("~/bundles/citizenhelp").Include(
                "~/Scripts/Pages/Citizen/citizenhelp.js"));

            // Citizen Leaderboard
            bundles.Add(new StyleBundle("~/Content/citizenleaderboard").Include(
                "~/Content/Pages/Citizen/citizenleaderboard.css"));

            bundles.Add(new ScriptBundle("~/bundles/citizenleaderboard").Include(
                "~/Scripts/Pages/Citizen/citizenleaderboard.js"));

            // Citizen My Reports
            bundles.Add(new StyleBundle("~/Content/citizenmyreports").Include(
                "~/Content/Pages/Citizen/citizenmyreports.css"));

            bundles.Add(new ScriptBundle("~/bundles/citizenmyreports").Include(
                "~/Scripts/Pages/Citizen/citizenmyreports.js"));

            // Citizen My Rewards
            bundles.Add(new StyleBundle("~/Content/citizenmyrewards").Include(
                "~/Content/Pages/Citizen/citizenmyrewards.css"));

            bundles.Add(new ScriptBundle("~/bundles/citizenmyrewards").Include(
                "~/Scripts/Pages/Citizen/citizenmyrewards.js"));

            // Citizen Notifications
            bundles.Add(new StyleBundle("~/Content/citizennotifications").Include(
                "~/Content/Pages/Citizen/citizennotifications.css"));

            bundles.Add(new ScriptBundle("~/bundles/citizennotifications").Include(
                "~/Scripts/Pages/Citizen/citizennotifications.js"));

            // Citizen Pickup Status
            bundles.Add(new StyleBundle("~/Content/citizenpickupstatus").Include(
                "~/Content/Pages/Citizen/citizenpickupstatus.css"));

            bundles.Add(new ScriptBundle("~/bundles/citizenpickupstatus").Include(
                "~/Scripts/Pages/Citizen/citizenpickupstatus.js"));

            // Citizen Redemption History
            bundles.Add(new StyleBundle("~/Content/citizenredemptionhistory").Include(
                "~/Content/Pages/Citizen/citizenredemptionhistory.css"));

            bundles.Add(new ScriptBundle("~/bundles/citizenredemptionhistory").Include(
                "~/Scripts/Pages/Citizen/citizenredemptionhistory.js"));

            // Citizen Schedule Pickup
            bundles.Add(new StyleBundle("~/Content/citizenschedulepickup").Include(
                "~/Content/Pages/Citizen/citizenschedulepickup.css"));

            bundles.Add(new ScriptBundle("~/bundles/citizenschedulepickup").Include(
                "~/Scripts/Pages/Citizen/citizenschedulepickup.js"));

            // Citizen User Profile
            bundles.Add(new StyleBundle("~/Content/citizenuserprofile").Include(
                "~/Content/Pages/Citizen/citizenuserprofile.css"));

            bundles.Add(new ScriptBundle("~/bundles/citizenuserprofile").Include(
                "~/Scripts/Pages/Citizen/citizenuserprofile.js"));

            // ==========================================
            //   ADMIN PAGES BUNDLES
            // ==========================================

            // Admin Dashboard
            bundles.Add(new StyleBundle("~/Content/admindashboard").Include(
                "~/Content/Pages/Admin/Dashboard.css"));

            bundles.Add(new ScriptBundle("~/bundles/admindashboard").Include(
                "~/Scripts/Pages/Admin/Dashboard.js"));

            // Admin Analytics
            bundles.Add(new StyleBundle("~/Content/analytics").Include(
                "~/Content/Pages/Analytics.css"));

            bundles.Add(new ScriptBundle("~/bundles/analytics").Include(
                "~/Scripts/Pages/Analytics.js"));

            // Admin Users
            bundles.Add(new StyleBundle("~/Content/adminusers").Include(
                "~/Content/Pages/Admin/adminusers.css"));

            bundles.Add(new ScriptBundle("~/bundles/adminusers").Include(
                "~/Scripts/Pages/Admin/adminusers.js"));

            // Admin Citizens
            bundles.Add(new StyleBundle("~/Content/admincitizens").Include(
                "~/Content/Pages/Admin/admincitizens.css"));

            bundles.Add(new ScriptBundle("~/bundles/admincitizens").Include(
                "~/Scripts/Pages/Admin/admincitizens.js"));

            // Admin Audit Logs
            bundles.Add(new StyleBundle("~/Content/adminauditlogs").Include(
                "~/Content/Pages/Admin/adminauditlogs.css"));

            bundles.Add(new ScriptBundle("~/bundles/adminauditlogs").Include(
                "~/Scripts/Pages/Admin/adminauditlogs.js"));

            // Admin Collections
            bundles.Add(new StyleBundle("~/Content/admincollections").Include(
                "~/Content/Pages/Admin/admincollections.css"));

            bundles.Add(new ScriptBundle("~/bundles/admincollections").Include(
                "~/Scripts/Pages/Admin/admincollections.js"));

            // Admin Collectors
            bundles.Add(new StyleBundle("~/Content/admincollectors").Include(
                "~/Content/Pages/Admin/admincollectors.css"));

            bundles.Add(new ScriptBundle("~/bundles/admincollectors").Include(
                "~/Scripts/Pages/Admin/admincollectors.js"));

            // Admin Credits
            bundles.Add(new StyleBundle("~/Content/admincredits").Include(
                "~/Content/Pages/Admin/admincredits.css"));

            bundles.Add(new ScriptBundle("~/bundles/admincredits").Include(
                "~/Scripts/Pages/Admin/admincredits.js"));

            // Admin Feedbacks
            bundles.Add(new StyleBundle("~/Content/adminfeedbacks").Include(
                "~/Content/Pages/Admin/adminfeedbacks.css"));

            bundles.Add(new ScriptBundle("~/bundles/adminfeedbacks").Include(
                "~/Scripts/Pages/Admin/adminfeedbacks.js"));

            // Admin Municipalities
            bundles.Add(new StyleBundle("~/Content/adminmunicipalities").Include(
                "~/Content/Pages/Admin/adminmunicipalities.css"));

            bundles.Add(new ScriptBundle("~/bundles/adminmunicipalities").Include(
                "~/Scripts/Pages/Admin/adminmunicipalities.js"));

            // Admin Notifications Management
            bundles.Add(new StyleBundle("~/Content/adminnotificationsmgmt").Include(
                "~/Content/Pages/Admin/adminnotificationsmgmt.css"));

            bundles.Add(new ScriptBundle("~/bundles/adminnotificationsmgmt").Include(
                "~/Scripts/Pages/Admin/adminnotificationsmgmt.js"));

            // Admin Pickups
            bundles.Add(new StyleBundle("~/Content/adminpickups").Include(
                "~/Content/Pages/Admin/adminpickups.css"));

            bundles.Add(new ScriptBundle("~/bundles/adminpickups").Include(
                "~/Scripts/Pages/Admin/adminpickups.js"));

            // Admin Profile
            bundles.Add(new StyleBundle("~/Content/adminprofile").Include(
                "~/Content/Pages/Admin/adminprofile.css"));

            bundles.Add(new ScriptBundle("~/bundles/adminprofile").Include(
                "~/Scripts/Pages/Admin/adminprofile.js"));

            // Admin Redemptions
            bundles.Add(new StyleBundle("~/Content/adminredemptions").Include(
                "~/Content/Pages/Admin/adminredemptions.css"));

            bundles.Add(new ScriptBundle("~/bundles/adminredemptions").Include(
                "~/Scripts/Pages/Admin/adminredemptions.js"));

            // Admin Reports
            bundles.Add(new StyleBundle("~/Content/adminreports").Include(
                "~/Content/Pages/Admin/adminreports.css"));

            bundles.Add(new ScriptBundle("~/bundles/adminreports").Include(
                "~/Scripts/Pages/Admin/adminreports.js"));

            // Admin Rewards
            bundles.Add(new StyleBundle("~/Content/adminrewards").Include(
                "~/Content/Pages/Admin/adminrewards.css"));

            bundles.Add(new ScriptBundle("~/bundles/adminrewards").Include(
                "~/Scripts/Pages/Admin/adminrewards.js"));

            // Admin Settings
            bundles.Add(new StyleBundle("~/Content/adminsettings").Include(
                "~/Content/Pages/Admin/adminsettings.css"));

            bundles.Add(new ScriptBundle("~/bundles/adminsettings").Include(
                "~/Scripts/Pages/Admin/adminsettings.js"));

            // Admin Transactions
            bundles.Add(new StyleBundle("~/Content/admintransactions").Include(
                "~/Content/Pages/Admin/admintransactions.css"));

            bundles.Add(new ScriptBundle("~/bundles/admintransactions").Include(
                "~/Scripts/Pages/Admin/admintransactions.js"));

            // Admin Waste Reports
            bundles.Add(new StyleBundle("~/Content/adminwastereports").Include(
                "~/Content/Pages/Admin/adminwastereports.css"));

            bundles.Add(new ScriptBundle("~/bundles/adminwastereports").Include(
                "~/Scripts/Pages/Admin/adminwastereports.js"));

            // Admin Waste Types
            bundles.Add(new StyleBundle("~/Content/adminwastetypes").Include(
                "~/Content/Pages/Admin/adminwastetypes.css"));
            bundles.Add(new ScriptBundle("~/bundles/adminwastetypes").Include(
                "~/Scripts/Pages/Admin/adminwastetypes.js"));


            // ==========================================
            //   COLLECTORS PAGES BUNDLES
            // ==========================================

            // Collector Dashboard
            bundles.Add(new StyleBundle("~/Content/dashboard").Include(
                "~/Content/Pages/Collectors/dashboard.css"));

            // Schedule Pickup
            bundles.Add(new StyleBundle("~/Content/schedulepickup").Include(
                "~/Content/Pages/Collectors/schedulepickup.css"));

            // My Reports (Collector version)
            bundles.Add(new StyleBundle("~/Content/collectorreports").Include(
                "~/Content/Pages/Collectors/collectorreports.css"));

            // Pickup Status (for collectors to track their pickups)
            bundles.Add(new StyleBundle("~/Content/pickupstatus").Include(
                "~/Content/Pages/Collectors/pickupstatus.css"));

            // My Rewards (Collector version)
            bundles.Add(new StyleBundle("~/Content/myrewards").Include(
                "~/Content/Pages/Collectors/myrewards.css"));

            // Redemption History
            bundles.Add(new StyleBundle("~/Content/redemptionhistory").Include(
                "~/Content/Pages/Collectors/redemptionhistory.css"));

            // Leaderboard (Collectors see their ranking)
            bundles.Add(new StyleBundle("~/Content/leaderboard").Include(
                "~/Content/Pages/Collectors/leaderboard.css"));

            // Community (Collector-specific community)
            bundles.Add(new StyleBundle("~/Content/community").Include(
                "~/Content/Pages/Collectors/community.css"));

            // Feedback (Collector feedback system)
            bundles.Add(new StyleBundle("~/Content/feedback").Include(
                "~/Content/Pages/Collectors/feedback.css"));

            // User Profile (Collector profile settings)
            bundles.Add(new StyleBundle("~/Content/userprofile").Include(
                "~/Content/Pages/Collectors/userprofile.css"));

            // Notifications
            bundles.Add(new StyleBundle("~/Content/notifications").Include(
                "~/Content/Pages/Collectors/notifications.css"));

            // Help & Support
            bundles.Add(new StyleBundle("~/Content/help").Include(
                "~/Content/Pages/Collectors/help.css"));

            // ==========================================
            //   COLLECTOR-SPECIFIC FEATURES
            // ==========================================

            // Collector Performance Analytics
            bundles.Add(new StyleBundle("~/Content/performance").Include(
                "~/Content/Pages/Collectors/performance.css"));

            // Collector Routes & Navigation
            bundles.Add(new StyleBundle("~/Content/routes").Include(
                "~/Content/Pages/Collectors/routes.css"));

            // Collector Map View
            bundles.Add(new StyleBundle("~/Content/map").Include(
                "~/Content/Pages/Collectors/map.css"));

            // Waste Collection Verification
            bundles.Add(new StyleBundle("~/Content/verification").Include(
                "~/Content/Pages/Collectors/verification.css"));

            // Daily Collection Log
            bundles.Add(new StyleBundle("~/Content/collectionlog").Include(
                "~/Content/Pages/Collectors/collectionlog.css"));

            // Vehicle Management (if collectors have vehicles assigned)
            bundles.Add(new StyleBundle("~/Content/vehicles").Include(
                "~/Content/Pages/Collectors/vehicles.css"));

            // Inventory Management
            bundles.Add(new StyleBundle("~/Content/inventory").Include(
                "~/Content/Pages/Collectors/inventory.css"));

            // Earnings Report
            bundles.Add(new StyleBundle("~/Content/earnings").Include(
                "~/Content/Pages/Collectors/earnings.css"));
        }

        public static void RegisterJQueryScriptManager()
        {
            ScriptManager.ScriptResourceMapping.AddDefinition("jquery",
                new ScriptResourceDefinition
                {
                    Path = "~/scripts/jquery-3.7.0.min.js",
                    DebugPath = "~/scripts/jquery-3.7.0.js",
                    CdnPath = "http://ajax.aspnetcdn.com/ajax/jQuery/jquery-3.7.0.min.js",
                    CdnDebugPath = "http://ajax.aspnetcdn.com/ajax/jQuery/jquery-3.7.0.js"
                });
        }
    }
}
