using System.Web.Optimization;
using System.Web.UI;

namespace SoorGreen.Admin
{
    public class BundleConfig
    {
        // For more information on Bundling, visit https://go.microsoft.com/fwlink/?LinkID=303951
        public static void RegisterBundles(BundleCollection bundles)
        {
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

            // Order is very important for these files to work, they have explicit dependencies
            bundles.Add(new ScriptBundle("~/bundles/MsAjaxJs").Include(
                    "~/Scripts/WebForms/MsAjax/MicrosoftAjax.js",
                    "~/Scripts/WebForms/MsAjax/MicrosoftAjaxApplicationServices.js",
                    "~/Scripts/WebForms/MsAjax/MicrosoftAjaxTimer.js",
                    "~/Scripts/WebForms/MsAjax/MicrosoftAjaxWebForms.js"));

            // Use the Development version of Modernizr to develop with and learn from. Then, when you’re
            // ready for production, use the build tool at https://modernizr.com to pick only the tests you need
            bundles.Add(new ScriptBundle("~/bundles/modernizr").Include(
                            "~/Scripts/modernizr-*"));

            // ==========================================
            //   GENERAL PAGES BUNDLES (Root Level)
            // ==========================================

            // Default/Home Page
            bundles.Add(new StyleBundle("~/Content/default").Include(
                "~/Content/bootstrap.css",
                "~/Content/Site.css",
                "~/Styles/main.css",
                "~/Styles/Style.css",
                "~/Content/Pages/Default.css"));

            bundles.Add(new ScriptBundle("~/bundles/default").Include(
                "~/Scripts/jquery-3.7.0.js",
                "~/Scripts/bootstrap.js",
                "~/Scripts/modernizr-2.8.3.js",
                "~/Scripts/Pages/Default.js"));

            // About Page
            bundles.Add(new StyleBundle("~/Content/about").Include(
                "~/Styles/About.css",
                "~/Content/Pages/About.css"));

            bundles.Add(new ScriptBundle("~/bundles/about").Include(
                "~/Scripts/Pages/About.js"));

            // Contact Page
            bundles.Add(new StyleBundle("~/Content/contact").Include(
                "~/Content/Pages/Contact.css"));

            bundles.Add(new ScriptBundle("~/bundles/contact").Include(
                "~/Scripts/Pages/Contact.js"));

            // Services Page
            bundles.Add(new StyleBundle("~/Content/services").Include(
                "~/Content/Pages/Services.css"));

            bundles.Add(new ScriptBundle("~/bundles/services").Include(
                "~/Scripts/Pages/Services.js"));

            // How It Works Page
            bundles.Add(new StyleBundle("~/Content/howitworks").Include(
                "~/Content/Pages/HowITWorks.css"));

            bundles.Add(new ScriptBundle("~/bundles/howitworks").Include(
                "~/Scripts/Pages/HowITWorks.js"));

            // Waste Collection Page
            bundles.Add(new StyleBundle("~/Content/wastecollection").Include(
                "~/Content/Pages/WasteCollection.css"));

            bundles.Add(new ScriptBundle("~/bundles/wastecollection").Include(
                "~/Scripts/Pages/WasteCollection.js"));

            // 404 Error Page
            bundles.Add(new StyleBundle("~/Content/404").Include(
                "~/Content/Pages/404.css"));

            bundles.Add(new ScriptBundle("~/bundles/404").Include(
                "~/Scripts/Pages/404.js"));

            // ==========================================
            //   AUTHENTICATION PAGES BUNDLES
            // ==========================================

            // Login Page
            bundles.Add(new StyleBundle("~/Content/login").Include(
                "~/Content/Pages/Login.css"));

            bundles.Add(new ScriptBundle("~/bundles/login").Include(
                "~/Scripts/Pages/Login.js"));

            // Register Page
            bundles.Add(new StyleBundle("~/Content/register").Include(
                "~/Content/Pages/Register.css"));

            bundles.Add(new ScriptBundle("~/bundles/register").Include(
                "~/Scripts/Pages/Register.js"));

            // Registration Form Page
            bundles.Add(new StyleBundle("~/Content/registrationform").Include(
                "~/Content/Pages/RegistrationForm.css"));

            bundles.Add(new ScriptBundle("~/bundles/registrationform").Include(
                "~/Scripts/Pages/RegistrationForm.js"));

            // Forgot Password Page
            bundles.Add(new StyleBundle("~/Content/forgotpassword").Include(
                "~/Content/Pages/ForgotPassword.css"));

            bundles.Add(new ScriptBundle("~/bundles/forgotpassword").Include(
                "~/Scripts/Pages/ForgotPassword.js"));

            // ==========================================
            //   ADMIN DASHBOARD PAGES BUNDLES
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
                "~/Content/Pages/Admin/Users.css"));

            bundles.Add(new ScriptBundle("~/bundles/adminusers").Include(
                "~/Scripts/Pages/Admin/Users.js"));

            // Admin Citizens
            bundles.Add(new StyleBundle("~/Content/admincitizens").Include(
                "~/Content/Pages/Admin/Citizens.css"));

            bundles.Add(new ScriptBundle("~/bundles/admincitizens").Include(
                "~/Scripts/Pages/Admin/Citizens.js"));

            // Admin Audit Logs
            bundles.Add(new StyleBundle("~/Content/adminauditlogs").Include(
                "~/Content/Pages/Admin/AuditLogs.css"));

            bundles.Add(new ScriptBundle("~/bundles/adminauditlogs").Include(
                "~/Scripts/Pages/Admin/AuditLogs.js"));

            // Admin Collections
            bundles.Add(new StyleBundle("~/Content/admincollections").Include(
                "~/Content/Pages/Admin/Collections.css"));

            bundles.Add(new ScriptBundle("~/bundles/admincollections").Include(
                "~/Scripts/Pages/Admin/Collections.js"));

            // Admin Collectors
            bundles.Add(new StyleBundle("~/Content/admincollectors").Include(
                "~/Content/Pages/Admin/Collectors.css"));

            bundles.Add(new ScriptBundle("~/bundles/admincollectors").Include(
                "~/Scripts/Pages/Admin/Collectors.js"));

            // Admin Credits
            bundles.Add(new StyleBundle("~/Content/admincredits").Include(
                "~/Content/Pages/Admin/Credits.css"));

            bundles.Add(new ScriptBundle("~/bundles/admincredits").Include(
                "~/Scripts/Pages/Admin/Credits.js"));

            // Admin Feedbacks
            bundles.Add(new StyleBundle("~/Content/adminfeedbacks").Include(
                "~/Content/Pages/Admin/Feedbacks.css"));

            bundles.Add(new ScriptBundle("~/bundles/adminfeedbacks").Include(
                "~/Scripts/Pages/Admin/Feedbacks.js"));

            // Admin Municipalities
            bundles.Add(new StyleBundle("~/Content/adminmunicipalities").Include(
                "~/Content/Pages/Admin/Municipalities.css"));

            bundles.Add(new ScriptBundle("~/bundles/adminmunicipalities").Include(
                "~/Scripts/Pages/Admin/Municipalities.js"));

            // Admin Notifications Management
            bundles.Add(new StyleBundle("~/Content/adminnotificationsmgmt").Include(
                "~/Content/Pages/Admin/NotificationsMgmt.css"));

            bundles.Add(new ScriptBundle("~/bundles/adminnotificationsmgmt").Include(
                "~/Scripts/Pages/Admin/NotificationsMgmt.js"));

            // Admin Pickups
            bundles.Add(new StyleBundle("~/Content/adminpickups").Include(
                "~/Content/Pages/Admin/Pickups.css"));

            bundles.Add(new ScriptBundle("~/bundles/adminpickups").Include(
                "~/Scripts/Pages/Admin/Pickups.js"));

            // Admin Profile
            bundles.Add(new StyleBundle("~/Content/adminprofile").Include(
                "~/Content/Pages/Admin/Profile.css"));

            bundles.Add(new ScriptBundle("~/bundles/adminprofile").Include(
                "~/Scripts/Pages/Admin/Profile.js"));

            // Admin Redemptions
            bundles.Add(new StyleBundle("~/Content/adminredemptions").Include(
                "~/Content/Pages/Admin/Redemptions.css"));

            bundles.Add(new ScriptBundle("~/bundles/adminredemptions").Include(
                "~/Scripts/Pages/Admin/Redemptions.js"));

            // Admin Reports
            bundles.Add(new StyleBundle("~/Content/adminreports").Include(
                "~/Content/Pages/Admin/Reports.css"));

            bundles.Add(new ScriptBundle("~/bundles/adminreports").Include(
                "~/Scripts/Pages/Admin/Reports.js"));

            // Admin Rewards
            bundles.Add(new StyleBundle("~/Content/adminrewards").Include(
                "~/Content/Pages/Admin/Rewards.css"));

            bundles.Add(new ScriptBundle("~/bundles/adminrewards").Include(
                "~/Scripts/Pages/Admin/Rewards.js"));

            // Admin Settings
            bundles.Add(new StyleBundle("~/Content/adminsettings").Include(
                "~/Content/Pages/Admin/Settings.css"));

            bundles.Add(new ScriptBundle("~/bundles/adminsettings").Include(
                "~/Scripts/Pages/Admin/Settings.js"));

            // Admin Transactions
            bundles.Add(new StyleBundle("~/Content/admintransactions").Include(
                "~/Content/Pages/Admin/Transactions.css"));

            bundles.Add(new ScriptBundle("~/bundles/admintransactions").Include(
                "~/Scripts/Pages/Admin/Transactions.js"));

            // Admin Waste Reports
            bundles.Add(new StyleBundle("~/Content/adminwastereports").Include(
                "~/Content/Pages/Admin/WasteReports.css"));

            bundles.Add(new ScriptBundle("~/bundles/adminwastereports").Include(
                "~/Scripts/Pages/Admin/WasteReports.js"));

            // Admin Waste Types
            bundles.Add(new StyleBundle("~/Content/adminwastetypes").Include(
                "~/Content/Pages/Admin/WasteTypes.css"));

            bundles.Add(new ScriptBundle("~/bundles/adminwastetypes").Include(
                "~/Scripts/Pages/Admin/WasteTypes.js"));

            // ==========================================
            //   CITIZEN PAGES BUNDLES
            // ==========================================

            // Citizen Dashboard
            bundles.Add(new StyleBundle("~/Content/citizendashboard").Include(
                "~/Content/Pages/Citizen/Dashboard.css"));

            bundles.Add(new ScriptBundle("~/bundles/citizendashboard").Include(
                "~/Scripts/Pages/Citizen/Dashboard.js"));

            // Citizen Community
            bundles.Add(new StyleBundle("~/Content/citizencommunity").Include(
                "~/Content/Pages/Citizen/Community.css"));

            bundles.Add(new ScriptBundle("~/bundles/citizencommunity").Include(
                "~/Scripts/Pages/Citizen/Community.js"));

            // Citizen Feedback
            bundles.Add(new StyleBundle("~/Content/citizenfeedback").Include(
                "~/Content/Pages/Citizen/Feedback.css"));

            bundles.Add(new ScriptBundle("~/bundles/citizenfeedback").Include(
                "~/Scripts/Pages/Citizen/Feedback.js"));

            // Citizen Help
            bundles.Add(new StyleBundle("~/Content/citizenhelp").Include(
                "~/Content/Pages/Citizen/Help.css"));

            bundles.Add(new ScriptBundle("~/bundles/citizenhelp").Include(
                "~/Scripts/Pages/Citizen/Help.js"));

            // Citizen Leaderboard
            bundles.Add(new StyleBundle("~/Content/citizenleaderboard").Include(
                "~/Content/Pages/Citizen/Leaderboard.css"));

            bundles.Add(new ScriptBundle("~/bundles/citizenleaderboard").Include(
                "~/Scripts/Pages/Citizen/Leaderboard.js"));

            // Citizen My Reports
            bundles.Add(new StyleBundle("~/Content/citizenmyreports").Include(
                "~/Content/Pages/Citizen/MyReports.css"));

            bundles.Add(new ScriptBundle("~/bundles/citizenmyreports").Include(
                "~/Scripts/Pages/Citizen/MyReports.js"));

            // Citizen My Rewards
            bundles.Add(new StyleBundle("~/Content/citizenmyrewards").Include(
                "~/Content/Pages/Citizen/MyRewards.css"));

            bundles.Add(new ScriptBundle("~/bundles/citizenmyrewards").Include(
                "~/Scripts/Pages/Citizen/MyRewards.js"));

            // Citizen Notifications
            bundles.Add(new StyleBundle("~/Content/citizennotifications").Include(
                "~/Content/Pages/Citizen/Notifications.css"));

            bundles.Add(new ScriptBundle("~/bundles/citizennotifications").Include(
                "~/Scripts/Pages/Citizen/Notifications.js"));

            // Citizen Pickup Status
            bundles.Add(new StyleBundle("~/Content/citizenpickupstatus").Include(
                "~/Content/Pages/Citizen/PickupStatus.css"));

            bundles.Add(new ScriptBundle("~/bundles/citizenpickupstatus").Include(
                "~/Scripts/Pages/Citizen/PickupStatus.js"));

            // Citizen Redemption History
            bundles.Add(new StyleBundle("~/Content/citizenredemptionhistory").Include(
                "~/Content/Pages/Citizen/RedemptionHistory.css"));

            bundles.Add(new ScriptBundle("~/bundles/citizenredemptionhistory").Include(
                "~/Scripts/Pages/Citizen/RedemptionHistory.js"));

            // Citizen Report Waste
            bundles.Add(new StyleBundle("~/Content/citizenreportwaste").Include(
                "~/Content/Pages/Citizen/ReportWaste.css"));

            bundles.Add(new ScriptBundle("~/bundles/citizenreportwaste").Include(
                "~/Scripts/Pages/Citizen/ReportWaste.js"));

            // Citizen Schedule Pickup
            bundles.Add(new StyleBundle("~/Content/citizenschedulepickup").Include(
                "~/Content/Pages/Citizen/SchedulePickup.css"));

            bundles.Add(new ScriptBundle("~/bundles/citizenschedulepickup").Include(
                "~/Scripts/Pages/Citizen/SchedulePickup.js"));

            // Citizen User Profile
            bundles.Add(new StyleBundle("~/Content/citizenuserprofile").Include(
                "~/Content/Pages/Citizen/UserProfile.css"));

            bundles.Add(new ScriptBundle("~/bundles/citizenuserprofile").Include(
                "~/Scripts/Pages/Citizen/UserProfile.js"));

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