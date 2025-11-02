using System;
using System.Web.UI;

namespace SoorGreen.Main
{
    public partial class _Default : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                InitializePage();
            }
        }

        private void InitializePage()
        {
            Page.Title = "SoorGreen - Choose Application";
        }

        // SIMPLE DIRECT REDIRECTS - NO COMPLEX LOGIC
        protected void btnWebForm_Click(object sender, EventArgs e)
        {
            TryRedirect("http://localhost:5020/SoorGreen_WebForm/",
                       "http://localhost:5020/",
                       "/WebForms/Dashboard.aspx");
        }

        protected void btnMVC_Click(object sender, EventArgs e)
        {
            Console.WriteLine("MVC CLICKED");
            Response.Write("MVC Clicked");
            TryRedirect("http://localhost:5030/SoorGreen_MVC/",
                       "http://localhost:5030/",
                       "/MVC/Home/Index");
        }

        protected void btnAPI_Click(object sender, EventArgs e)
        {
            Response.Write("API Clicked");
            TryRedirect("http://localhost:5040/SoorGreen_API/swagger",
                       "http://localhost:5040/swagger",
                       "/API/swagger");
        }

        // Modal button handlers - SAME AS ABOVE
        protected void btnWebFormModal_Click(object sender, EventArgs e)
        {
            Response.Write("WebForm Clicked");
            btnWebForm_Click(sender, e);
        }

        protected void btnMVCModal_Click(object sender, EventArgs e)
        {
            Response.Write("MVC Clicked");
            btnMVC_Click(sender, e);
        }

        protected void btnAPIModal_Click(object sender, EventArgs e)
        {
            Response.Write("API Clicked");
            btnAPI_Click(sender, e);
        }

        private void TryRedirect(string primaryUrl, string fallbackUrl, string localUrl)
        {
            try
            {
                // Try primary URL first
                Response.Redirect(primaryUrl, false);
            }
            catch
            {
                try
                {
                    // Try fallback URL
                    Response.Redirect(fallbackUrl, false);
                }
                catch
                {
                    try
                    {
                        // Try local project URL
                        Response.Redirect(localUrl, false);
                    }
                    catch (Exception ex)
                    {
                        // Show helpful error message
                        string errorMessage = @"
                                                The application you're trying to access is not running. 

                                                To fix this:
                                                1. Make sure the other SoorGreen projects are running in Visual Studio
                                                2. Check that the ports are correct
                                                3. Or the applications may be deployed to different URLs

                                                Error: " + ex.Message;

                        ScriptManager.RegisterStartupScript(this, GetType(), "RedirectError",
                            $"alert('{errorMessage}');", true);
                    }
                }
            }
        }
    }
}