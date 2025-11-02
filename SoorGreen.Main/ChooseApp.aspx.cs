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
                InitializePage();
            }
        }

        private void InitializePage()
        {
            Page.Title = "SoorGreen - Choose Application";
        }

        // WebForms Admin Panel button
        protected void btnWebForm_Click(object sender, EventArgs e)
        {
            LaunchWithFallback(
                "http://localhost:44381/Default.aspx?force=true",
                "WebForms Admin Panel",
                new[]
                {
                    "http://localhost:44381/Default.aspx",
                    "http://localhost:44381/Home.aspx",
                    "http://localhost:44381/"
                }
            );
        }

        // MVC Citizen Portal button
        protected void btnMVC_Click(object sender, EventArgs e)
        {
            LaunchWithFallback(
                "http://localhost:44305/Home/Index",
                "MVC Citizen Portal",
                new[] {
                    "http://localhost:44305/",
                    "http://localhost:44305/Home",
                    "http://localhost:44305/Home/Index"
                }
            );
        }

        // Modal button handlers
        protected void btnWebFormModal_Click(object sender, EventArgs e) => btnWebForm_Click(sender, e);
        protected void btnMVCModal_Click(object sender, EventArgs e) => btnMVC_Click(sender, e);

        private void LaunchWithFallback(string primaryUrl, string appName, string[] fallbackUrls)
        {
            string joinedFallbacks = string.Join("\\n", fallbackUrls);

            string script = $@"
                (function(){{
                    var urls = ['{primaryUrl}', '{string.Join("','", fallbackUrls)}'];
                    var opened = false;

                    for(var i=0;i<urls.length;i++){{
                        var win = window.open(urls[i].trim(), '_blank');
                        if(win && !win.closed){{
                            console.log('Opened: ' + urls[i]);
                            opened = true;
                            break;
                        }}
                    }}

                    if(!opened){{
                        var message = '{appName} could not be opened.\\n\\n' +
                                      'Possible reasons:\\n' +
                                      '• The project is not running\\n' +
                                      '• IIS Express not started\\n' +
                                      '• Browser blocked popups\\n\\n' +
                                      'Primary URL:\\n' + '{primaryUrl}\\n\\n' +
                                      'Fallback URLs:\\n' + '{joinedFallbacks}';
                        alert(message);
                    }}
                }})();";

            ScriptManager.RegisterStartupScript(this, GetType(), $"Launch{appName.Replace(" ", "")}", script, true);
        }
    }
}
