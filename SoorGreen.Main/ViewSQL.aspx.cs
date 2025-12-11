using System;
using System.Web.UI;

namespace SoorGreen.Main
{
    public partial class ViewSQL : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadSQLScript();
            }
        }

        private void LoadSQLScript()
        {
            if (Session["FullSQLScript"] != null)
            {
                sqlCode.InnerText = Session["FullSQLScript"].ToString();
            }
            else
            {
                sqlCode.InnerText = "-- No SQL script found. Please return to the home page.";
            }
        }

        protected void btnDownload_Click(object sender, EventArgs e)
        {
            string sqlContent = sqlCode.InnerText;

            Response.Clear();
            Response.ContentType = "text/plain";
            Response.AppendHeader("Content-Disposition", "attachment; filename=SoorGreenDB_Complete.sql");
            Response.Write(sqlContent);
            Response.Flush();
            Response.End();
        }

        protected void btnCopy_Click(object sender, EventArgs e)
        {
            // JavaScript will handle the copy functionality
            ClientScript.RegisterStartupScript(GetType(), "CopyScript",
                "copyToClipboard();", true);
        }
    }
}