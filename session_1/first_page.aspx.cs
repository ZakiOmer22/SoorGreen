using System;

namespace uoh_projects.session_1
{
    public partial class first_page : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        protected void btnLogin_Click(object sender, EventArgs e)
        {
            string username = txtUsername.Text.Trim();
            string password = txtPassword.Text.Trim();

            // Dummy login validation
            if (username == "admin" && password == "admin123")
            {
                Session["Username"] = username;
                Response.Redirect("dashboard.aspx"); // Replace with your actual dashboard
            }
            else
            {
                lblMessage.Text = "Invalid username or password.";
            }
        }

        protected void btnRegisterRedirect_Click(object sender, EventArgs e)
        {
            Response.Redirect("register.aspx");
        }
    }
}