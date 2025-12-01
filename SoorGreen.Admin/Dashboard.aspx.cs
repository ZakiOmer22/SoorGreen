using System;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;

public partial class Dashboard : System.Web.UI.Page
{
    // REMOVED CONTROL DECLARATIONS

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            // Check if user is logged in
            if (Session["UserID"] == null)
            {
                Response.Redirect("Login.aspx");
                return;
            }

            // Display user information
            DisplayUserInfo();

            // Start the role checking and redirection process
            CheckUserRoleAndRedirect();
        }
    }

    private void DisplayUserInfo()
    {
        // Find controls in the ContentPlaceHolder
        ContentPlaceHolder mainContent = (ContentPlaceHolder)Master.FindControl("MainContent");
        if (mainContent != null)
        {
            HtmlGenericControl userName = (HtmlGenericControl)mainContent.FindControl("userName");
            HtmlGenericControl userEmail = (HtmlGenericControl)mainContent.FindControl("userEmail");
            HtmlGenericControl userRole = (HtmlGenericControl)mainContent.FindControl("userRole");
            HtmlGenericControl userAvatar = (HtmlGenericControl)mainContent.FindControl("userAvatar");

            if (Session["UserName"] != null && userName != null)
            {
                userName.InnerText = Session["UserName"].ToString();
                SetUserAvatar(userAvatar, Session["UserName"].ToString());
            }

            if (Session["UserEmail"] != null && userEmail != null)
            {
                userEmail.InnerText = Session["UserEmail"].ToString();
            }

            if (Session["UserRole"] != null && userRole != null)
            {
                userRole.InnerText = GetRoleDisplayName(Session["UserRole"].ToString());
            }
        }
    }

    private void SetUserAvatar(HtmlGenericControl userAvatar, string fullName)
    {
        if (userAvatar == null) return;

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

    private string GetRoleDisplayName(string roleId)
    {
        switch (roleId)
        {
            case "CITZ":
            case "R001":
                return "Citizen";
            case "COLL":
            case "R002":
                return "Waste Collector";
            case "ADMN":
            case "R004":
                return "Administrator";
            case "COMP":
            case "R003":
                return "Company Partner";
            default:
                return "User";
        }
    }

    private void CheckUserRoleAndRedirect()
    {
        // Get user role from session
        string userRole = "";
        if (Session["UserRole"] != null)
        {
            userRole = Session["UserRole"].ToString();
        }

        if (string.IsNullOrEmpty(userRole))
        {
            // If no role found, redirect to login
            Response.Redirect("Login.aspx");
            return;
        }

        // Determine redirect URL based on role
        string redirectUrl = GetDashboardUrl(userRole);
        string roleName = GetRoleDisplayName(userRole);

        // Create JavaScript for redirection
        string script = string.Format(@"
            setTimeout(function() {{
                // Update final step
                var steps = document.querySelectorAll('.progress-step');
                for (var i = 0; i < steps.length; i++) {{
                    steps[i].classList.remove('active');
                    steps[i].classList.add('completed');
                    var stepIcon = steps[i].querySelector('.step-icon');
                    if (stepIcon) {{
                        stepIcon.innerHTML = '<i class=""fas fa-check""></i>';
                    }}
                }}
                
                // Show success message
                var redirectInfo = document.querySelector('.redirect-info');
                if (redirectInfo) {{
                    redirectInfo.innerHTML = 
                        '<div class=""text-center"">' +
                            '<i class=""fas fa-check-circle text-success fa-2x mb-2""></i>' +
                            '<div><strong>Redirecting to {0} Dashboard</strong></div>' +
                            '<small>Please wait while we take you to your dashboard...</small>' +
                        '</div>';
                }}
                
                // Redirect after short delay
                setTimeout(function() {{
                    window.location.href = '{1}';
                }}, 1000);
            }}, 4000);
        ", roleName, redirectUrl);

        ClientScript.RegisterStartupScript(this.GetType(), "redirectScript", script, true);
    }

    private string GetDashboardUrl(string roleId)
    {
        switch (roleId)
        {
            case "CITZ":
            case "R001":
                return "/Pages/Citizen/Dashboard.aspx";
            case "COLL":
            case "R002":
                return "/Pages/Collector/Dashboard.aspx";
            case "ADMN":
            case "R004":
                return "Pages/Admin/Dashboard.aspx";
            case "COMP":
            case "R003":
                return "Pages/Company/Dashboard.aspx";
            default:
                return "Default.aspx";
        }
    }
}