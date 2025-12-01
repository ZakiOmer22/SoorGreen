using System;
using System.Web.UI;

public partial class Error404 : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        // Set response status code to 404
        Response.StatusCode = 404;
        Response.StatusDescription = "Page Not Found";
        Response.TrySkipIisCustomErrors = true;

        // Get the original missing page
        string originalPath = Request.QueryString["aspxerrorpath"];

        if (string.IsNullOrEmpty(originalPath))
        {
            originalPath = Request.RawUrl ?? "Unknown page";
        }

        // Show what was missing
        if (!string.IsNullOrEmpty(originalPath) && originalPath != "Unknown page")
        {
            litRequestedPath.Text = $@"
            <div class='alert alert-dark mt-3' style='background: rgba(255,255,255,0.05); border: 1px solid rgba(255,255,255,0.1);'>
                <small class='text-muted'>Missing page:</small><br/>
                <code class='text-warning'>{Server.HtmlEncode(originalPath)}</code>
            </div>";
        }
        else
        {
            litRequestedPath.Text = string.Empty;
        }
    }

    protected void btnGoBack_ServerClick(object sender, EventArgs e)
    {
        if (Request.UrlReferrer != null)
        {
            Response.Redirect(Request.UrlReferrer.ToString());
        }
        else
        {
            Response.Redirect("Default.aspx");
        }
    }
}