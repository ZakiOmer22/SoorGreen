using System;
using System.Web.UI;

namespace SoorGreen.Admin
{
    public partial class SiteMaster : MasterPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                CheckUserLoginStatus();
            }
        }

        private void CheckUserLoginStatus()
        {
            if (Session["UserID"] != null && Session["UserName"] != null)
            {
                // User is logged in
                pnlLoggedInUser.Visible = true;
                pnlGuestUser.Visible = false;

                // Set user information
                userName.InnerText = Session["UserName"].ToString();

                // FIXED: Replace null-conditional operator with traditional null check
                string userRoleValue = Session["UserRole"] != null ? Session["UserRole"].ToString() : null;
                userRole.InnerText = GetRoleDisplayName(userRoleValue);

                // Set user avatar with initials
                SetUserAvatar(Session["UserName"].ToString());
            }
            else
            {
                // User is not logged in
                pnlLoggedInUser.Visible = false;
                pnlGuestUser.Visible = true;
            }
        }

        private string GetRoleDisplayName(string roleId)
        {
            if (string.IsNullOrEmpty(roleId))
                return "User";

            switch (roleId)
            {
                case "CITZ":
                case "R001":
                    return "Citizen";
                case "COLL":
                case "R002":
                    return "Collector";
                case "ADMN":
                case "R004":
                    return "Administrator";
                case "COMP":
                case "R003":
                    return "Company";
                default:
                    return "User";
            }
        }

        private void SetUserAvatar(string fullName)
        {
            // Get initials from full name
            string initials = "U";
            if (!string.IsNullOrEmpty(fullName))
            {
                string[] nameParts = fullName.Split(' ');
                if (nameParts.Length > 0)
                {
                    initials = nameParts[0].Substring(0, 1).ToUpper();
                    if (nameParts.Length > 1)
                    {
                        initials += nameParts[1].Substring(0, 1).ToUpper();
                    }
                }
            }

            // Set the avatar text
            userAvatar.InnerHtml = initials;
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            // Clear all session variables
            Session.Clear();
            Session.Abandon();

            // Redirect to home page
            Response.Redirect("Default.aspx");
        }
    }
}