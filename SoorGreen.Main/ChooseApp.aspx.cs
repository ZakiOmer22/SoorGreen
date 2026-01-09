using System;
using System.Web.UI;

namespace SoorGreen.Main
{
    public partial class ChooseApp1 : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Page.Title = "SoorGreen - Smart Waste Management Platform";
            }
        }

        protected void btnWebForms_Click(object sender, EventArgs e)
        {
            // Store in session to show after the window opens
            Session["ShowAlert"] = "webforms";
            Session["AlertMessage"] = "Opening Web Forms Admin Portal...\n\nURL: http://localhost:44381\nTeam: ZACKI ABDULKADIR OMER (Lead)";

            string script = @"
                <script>
                    try {
                        // Open FIRST, then show alert
                        var newWindow = window.open('http://localhost:44381/', '_blank');
                        
                        // Check if popup was blocked
                        if (!newWindow || newWindow.closed || typeof newWindow.closed == 'undefined') {
                            alert('Popup blocked! Please allow popups for this site and try again.');
                        } else {
                            // Wait a moment then show alert in PARENT window
                            setTimeout(function() {
                                alert('Opening Web Forms Admin Portal...\\n\\nURL: http://localhost:44381\\nTeam: ZACKI ABDULKADIR OMER (Lead)');
                            }, 300);
                        }
                    } catch (error) {
                        console.error('Error:', error);
                        alert('Error opening portal. Please check if the URL is accessible.');
                    }
                </script>";
            ScriptManager.RegisterStartupScript(this, GetType(), "OpenWebForms", script, false);
        }

        protected void btnMVC_Click(object sender, EventArgs e)
        {
            string script = @"
                <script>
                    try {
                        // Open FIRST
                        var newWindow = window.open('http://localhost:44305/', '_blank');
                        
                        // Check if popup was blocked
                        if (!newWindow || newWindow.closed || typeof newWindow.closed == 'undefined') {
                            alert('Popup blocked! Please allow popups for this site and try again.');
                        } else {
                            // Show alert AFTER opening
                            setTimeout(function() {
                                alert('Opening MVC Web Portal...\\n\\nURL: http://localhost:44305\\nTeam: ARAFAT OSMAN ADEN (Lead)');
                            }, 300);
                        }
                    } catch (error) {
                        console.error('Error:', error);
                        alert('Error opening portal. Please check if the URL is accessible.');
                    }
                </script>";
            ScriptManager.RegisterStartupScript(this, GetType(), "OpenMVC", script, false);
        }
        protected void btnCustomModal_Click(object sender, EventArgs e)
        {
            string script = @"
                <script>
                    try {
                        // Open FIRST
                        var newWindow = window.open('http://localhost:44306/', '_blank');
                        
                        // Check if popup was blocked
                        if (!newWindow || newWindow.closed || typeof newWindow.closed == 'undefined') {
                            alert('Popup blocked! Please allow popups for this site and try again.');
                        } else {
                            // Show alert AFTER opening
                            setTimeout(function() {
                                alert('Opening Custom SOlution Portal...\\n\\nURL: http://localhost:44306/\\nTeam: ZACKI ABDULKADIR OMER (Lead)');
                            }, 300);
                        }
                    } catch (error) {
                        console.error('Error:', error);
                        alert('Error opening portal. Please check if the URL is accessible.');
                    }
                </script>";
            ScriptManager.RegisterStartupScript(this, GetType(), "OpenMVC", script, false);
        }
        protected void btnAPI_Click(object sender, EventArgs e)
        {
            string script = @"
                <script>
                    alert('Web API Service - NOT FOUND In Your Files\\n\\nCheck if in the correct git Branch.\\n\\nPort: 5000 or 5001\\n\\nPlease Try Again Later');
                </script>";
            ScriptManager.RegisterStartupScript(this, GetType(), "OpenAPI", script, false);
        }

        protected void btnCustom_Click(object sender, EventArgs e) => btnCustomModal_Click(sender, e);
        protected void btnWebFormsModal_Click(object sender, EventArgs e) => btnWebForms_Click(sender, e);
        protected void btnMVCModal_Click(object sender, EventArgs e) => btnMVC_Click(sender, e);
        protected void btnAPIModal_Click(object sender, EventArgs e) => btnAPI_Click(sender, e);
    }
}