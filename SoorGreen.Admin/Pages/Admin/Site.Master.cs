using System;
using System.Web.UI;

public partial class SiteMaster : MasterPage
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            CheckUserLoginStatus();
            CheckAdminAuthorization();
            UpdateUserDisplay();
        }
    }

    private void CheckUserLoginStatus()
    {
        if (Session["UserID"] != null && Session["UserName"] != null)
        {
            // User is logged in
            pnlLoggedInUser.Visible = true;
            pnlGuestUser.Visible = false;
        }
        else
        {
            // User is not logged in
            pnlLoggedInUser.Visible = false;
            pnlGuestUser.Visible = true;
        }
    }

    private void CheckAdminAuthorization()
    {
        // Check if user has admin role
        if (Session["UserRole"] != null)
        {
            string userRole = Session["UserRole"].ToString();
            if (!IsAdminRole(userRole))
            {
                // Redirect non-admin users to access denied page
                Response.Redirect("Login.aspx");
            }
        }
        else
        {
            // No role found, redirect to login
            Response.Redirect("Login.aspx");
        }
    }

    private void UpdateUserDisplay()
    {
        if (Session["UserID"] != null && Session["UserName"] != null)
        {
            // FIX: Use different variable names to avoid conflicts
            string sessionUserName = Session["UserName"].ToString();
            string sessionUserRole = Session["UserRole"] != null ? Session["UserRole"].ToString() : "User";

            // Update navbar user info - FIXED: Use HTML elements with different variable names
            userName.InnerText = sessionUserName;
            userRole.InnerText = GetRoleDisplayName(sessionUserRole);

            // Update sidebar user info
            litUserName.Text = sessionUserName;
            litUserRole.Text = GetRoleDisplayName(sessionUserRole);
            litWelcomeUser.Text = sessionUserName;

            // Set user avatar with initials
            SetUserAvatar(sessionUserName);
        }
        else
        {
            // Set default values for guest users
            litUserName.Text = "Guest";
            litUserRole.Text = "User";
            litWelcomeUser.Text = "Guest";
        }
    }

    private bool IsAdminRole(string roleId)
    {
        string[] adminRoles = { "ADMN", "R004" };
        foreach (string role in adminRoles)
        {
            if (role.Equals(roleId, StringComparison.OrdinalIgnoreCase))
                return true;
        }
        return false;
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
        string initials = "AD";
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
        litUserAvatar.Text = initials;
    }

    protected void btnLogout_Click(object sender, EventArgs e)
    {
        // Clear all session variables
        Session.Clear();
        Session.Abandon();

        // Clear authentication cookie if exists
        if (Request.Cookies["ASP.NET_SessionId"] != null)
        {
            Response.Cookies["ASP.NET_SessionId"].Value = string.Empty;
            Response.Cookies["ASP.NET_SessionId"].Expires = DateTime.Now.AddMonths(-20);
        }

        // Redirect to home page
        Response.Redirect("Default.aspx");
    }
}