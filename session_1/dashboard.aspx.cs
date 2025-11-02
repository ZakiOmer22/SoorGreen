using System;

namespace uoh_projects.session_1
{
    public partial class dashboard : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["Username"] != null)
            {
                lblWelcome.Text = $"Hello, {Session["Username"]}!";
            }
            else
            {
                Response.Redirect("first_page.aspx"); // Not logged in
            }
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Response.Redirect("first_page.aspx");
        }
    }
}