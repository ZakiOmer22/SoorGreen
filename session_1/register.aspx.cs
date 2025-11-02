using System;

namespace uoh_projects.session_1
{
    public partial class register : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        protected void btnRegister_Click(object sender, EventArgs e)
        {
            string businessName = txtBusinessName.Text.Trim();
            string owner = txtOwner.Text.Trim();
            string email = txtEmail.Text.Trim();
            string username = txtUsername.Text.Trim();
            string password = txtPassword.Text.Trim();

            // Normally, you'd save to a database.
            // Here, we simulate registration success.

            lblStatus.Text = "✅ Registration successful! You may now log in.";
            ClearFields();
        }
        private void ClearFields()
        {
            txtBusinessName.Text = "";
            txtOwner.Text = "";
            txtEmail.Text = "";
            txtUsername.Text = "";
            txtPassword.Text = "";
        }
    }
}