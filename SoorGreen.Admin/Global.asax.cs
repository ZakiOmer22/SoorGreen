using System;
using System.Web.Optimization;

namespace SoorGreen.Admin
{
    public class Global : System.Web.HttpApplication
    {
        protected void Application_Start(object sender, EventArgs e)
        {
            // Register routes
            RouteConfig.RegisterRoutes(System.Web.Routing.RouteTable.Routes);

            // DEBUG: Force bundle registration
            BundleTable.EnableOptimizations = false; // MUST BE FALSE for debugging

            // Register bundles
            BundleConfig.RegisterBundles(BundleTable.Bundles);

            // DEBUG: Log all bundles
            System.Diagnostics.Debug.WriteLine("=== BUNDLES REGISTERED ===");
            foreach (var bundle in BundleTable.Bundles)
            {
                System.Diagnostics.Debug.WriteLine($"Bundle: {bundle.Path}");
            }
        }
    }
}