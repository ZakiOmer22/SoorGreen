using System;
using System.Web.UI;
using System.Web.UI.HtmlControls;

public partial class Dashboard : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            // Check if user is logged in
            if (Session["UserID"] == null)
            {
                Response.Redirect("~/Login.aspx");
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
        try
        {
            // Display user information in the dashboard
            if (Session["UserName"] != null)
            {
                HtmlGenericControl welcomeMsg = FindControlRecursive(Page, "userName") as HtmlGenericControl;
                if (welcomeMsg != null)
                {
                    welcomeMsg.InnerText = Session["UserName"].ToString();
                }

                HtmlGenericControl userAvatar = FindControlRecursive(Page, "userAvatar") as HtmlGenericControl;
                if (userAvatar != null)
                {
                    SetUserAvatar(userAvatar, Session["UserName"].ToString());
                }
            }

            if (Session["UserEmail"] != null)
            {
                HtmlGenericControl userEmail = FindControlRecursive(Page, "userEmail") as HtmlGenericControl;
                if (userEmail != null)
                {
                    userEmail.InnerText = Session["UserEmail"].ToString();
                }
            }

            if (Session["UserRole"] != null)
            {
                HtmlGenericControl userRole = FindControlRecursive(Page, "userRole") as HtmlGenericControl;
                if (userRole != null)
                {
                    userRole.InnerText = GetRoleDisplayName(Session["UserRole"].ToString());
                }
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("Error displaying user info: " + ex.Message);
        }
    }

    private Control FindControlRecursive(Control root, string id)
    {
        if (root.ID == id) return root;

        foreach (Control c in root.Controls)
        {
            Control t = FindControlRecursive(c, id);
            if (t != null) return t;
        }
        return null;
    }

    private void SetUserAvatar(HtmlGenericControl userAvatar, string fullName)
    {
        if (userAvatar == null) return;

        string initials = "U";
        if (!string.IsNullOrEmpty(fullName))
        {
            string[] nameParts = fullName.Trim().Split(new char[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
            if (nameParts.Length > 0)
            {
                initials = nameParts[0].Substring(0, 1).ToUpper();
                if (nameParts.Length > 1)
                {
                    initials += nameParts[1].Substring(0, 1).ToUpper();
                }
            }
        }

        userAvatar.InnerHtml = initials;
    }

    private string GetRoleDisplayName(string roleId)
    {
        switch (roleId.ToUpper())
        {
            case "R001":
                return "Citizen";
            case "R002":
                return "Waste Collector";
            case "R003":
                return "Company Partner";
            case "R004":
                return "Administrator";
            case "CITZ":
                return "Citizen";
            case "COLL":
                return "Waste Collector";
            case "ADMN":
                return "Administrator";
            case "COMP":
                return "Company Partner";
            default:
                return "User";
        }
    }

    private void CheckUserRoleAndRedirect()
    {
        try
        {
            // Get user role from session
            string userRole = "";
            if (Session["UserRole"] != null)
            {
                userRole = Session["UserRole"].ToString().ToUpper();
            }

            // DEBUG: Show current role
            ShowToast("DEBUG: Your role is: " + userRole, "info");
            System.Diagnostics.Debug.WriteLine("DASHBOARD DEBUG - Session UserRole: " + userRole);

            if (string.IsNullOrEmpty(userRole))
            {
                Response.Redirect("~/Login.aspx");
                return;
            }

            // Determine redirect URL based on role
            string redirectUrl = GetDashboardUrl(userRole);
            string roleName = GetRoleDisplayName(userRole);

            // DEBUG: Show where we're redirecting
            ShowToast("DEBUG: Redirecting to: " + redirectUrl, "info");
            System.Diagnostics.Debug.WriteLine("DASHBOARD DEBUG - Redirect URL: " + redirectUrl);

            // Get current page
            string currentPage = Request.Url.AbsolutePath.ToLower();

            // If we're already on the correct dashboard page, don't redirect
            if (IsOnCorrectDashboard(currentPage, userRole))
            {
                ShowDashboardReadyMessage(roleName);
            }
            else
            {
                // Show redirect with 5 second delay (for testing)
                ShowRedirectMessage(roleName, redirectUrl, 5000);
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("Error in CheckUserRoleAndRedirect: " + ex.Message);
            ShowToast("An error occurred. Please refresh the page.", "error");
        }
    }

    private bool IsOnCorrectDashboard(string currentPage, string userRole)
    {
        switch (userRole)
        {
            case "R001":
            case "CITZ":
                return currentPage.Contains("/pages/citizen/dashboard.aspx");

            case "R002":
            case "COLL":
                return currentPage.Contains("/pages/collectors/dashboard.aspx");

            case "R004":
            case "ADMN":
                return currentPage.Contains("/pages/admin/dashboard.aspx");

            case "R003":
            case "COMP":
                return currentPage.Contains("/pages/company/dashboard.aspx");

            default:
                return false;
        }
    }

    private string GetDashboardUrl(string roleId)
    {
        // Get the full application path
        string appPath = Request.ApplicationPath;
        if (appPath == "/") appPath = "";
        
        switch (roleId.ToUpper())
        {
            case "R001":
            case "CITZ":
                return appPath + "/Pages/Citizen/Dashboard.aspx";

            case "R002":
            case "COLL":
                return appPath + "/Pages/Collectors/Dashboard.aspx";

            case "R004":
            case "ADMN":
                return appPath + "/Pages/Admin/Dashboard.aspx";

            case "R003":
            case "COMP":
                return appPath + "/Pages/Company/Dashboard.aspx";

            default:
                return appPath + "/Default.aspx";
        }
    }

    private void ShowDashboardReadyMessage(string roleName)
    {
        string script = @"
            setTimeout(function() {
                var steps = document.querySelectorAll('.progress-step');
                for (var i = 0; i < steps.length; i++) {
                    steps[i].classList.remove('active');
                    steps[i].classList.add('completed');
                    var stepIcon = steps[i].querySelector('.step-icon');
                    if (stepIcon) {
                        stepIcon.innerHTML = '<i class=""fas fa-check""></i>';
                    }
                }
                
                var redirectInfo = document.querySelector('.redirect-info');
                if (redirectInfo) {
                    redirectInfo.innerHTML = 
                        '<div class=""text-center"">' +
                            '<i class=""fas fa-check-circle text-success fa-2x mb-2""></i>' +
                            '<div><strong>Welcome to your " + roleName + @" Dashboard!</strong></div>' +
                            '<small>Your dashboard is ready and loaded.</small>' +
                        '</div>';
                }
                
                var countdown = document.querySelector('.countdown');
                if (countdown) {
                    countdown.style.display = 'none';
                }
                
                showToast('" + roleName + @" dashboard loaded successfully!', 'success');
            }, 1000);
        ";

        RegisterScript("dashboardReadyScript", script);
    }

    private void ShowRedirectMessage(string roleName, string redirectUrl, int delayMilliseconds)
    {
        int delaySeconds = delayMilliseconds / 1000;
        
        string script = string.Format(@"
            var redirectSeconds = {0};
            var countdownElement = document.getElementById('countdown');
            var redirectInfo = document.querySelector('.redirect-info');
            
            // Update redirect message with countdown
            if (redirectInfo) {{
                redirectInfo.innerHTML = 
                    '<div class=""text-center"">' +
                        '<div class=""spinner-border text-primary mb-3"" style=""width: 3rem; height: 3rem;"" role=""status"">' +
                            '<span class=""visually-hidden"">Loading...</span>' +
                        '</div>' +
                        '<h5>Preparing {1} Dashboard</h5>' +
                        '<p>Setting up your personalized workspace...</p>' +
                        '<div class=""progress mt-3"" style=""height: 8px;"">' +
                            '<div class=""progress-bar progress-bar-striped progress-bar-animated"" ' +
                            'role=""progressbar"" style=""width: 0%"" id=""progressBar""></div>' +
                        '</div>' +
                        '<div class=""mt-2"">' +
                            '<small>Redirecting in: <span id=""countdown"">{0}</span> seconds</small>' +
                        '</div>' +
                    '</div>';
            }}
            
            showToast('Preparing your {1} dashboard...', 'info');
            
            // Start countdown
            var countdownTimer = setInterval(function() {{
                redirectSeconds--;
                
                if (countdownElement) {{
                    countdownElement.textContent = redirectSeconds;
                }}
                
                if (redirectSeconds <= 0) {{
                    clearInterval(countdownTimer);
                    showToast('Redirecting to {1} dashboard!', 'success');
                    
                    // Redirect
                    setTimeout(function() {{
                        window.location.href = '{2}';
                    }}, 1000);
                }}
            }}, 1000);
        ", delaySeconds, roleName, redirectUrl);

        RegisterScript("redirectScript", script);
    }

    private void RegisterScript(string key, string script)
    {
        if (!ClientScript.IsStartupScriptRegistered(key))
        {
            ClientScript.RegisterStartupScript(this.GetType(), key, script, true);
        }
    }

    private void ShowToast(string message, string type)
    {
        string escapedMessage = message.Replace("'", "\\'");
        string script = string.Format("showToast('{0}', '{1}');", escapedMessage, type);
        
        if (!ClientScript.IsStartupScriptRegistered("toastScript"))
        {
            ClientScript.RegisterStartupScript(this.GetType(), "toastScript", script, true);
        }
    }
}