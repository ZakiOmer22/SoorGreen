using System;
using System.Web.UI.WebControls;

public partial class Register : System.Web.UI.Page
{
    // Define the controls that will be used
    //protected HiddenField selectedRole;
    //protected Button btnContinue;
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            // Page load code if needed
        }
    }

    protected void btnContinue_Click(object sender, EventArgs e)
    {
        string selectedRoleId = selectedRole.Value;

        if (string.IsNullOrEmpty(selectedRoleId))
        {
            Response.Write("<script>alert('Please select a role to continue.');</script>");
            return;
        }

        Session["SelectedRoleId"] = selectedRoleId;

        // Fixed: Using traditional switch statement instead of switch expression
        string roleName;
        switch (selectedRoleId)
        {
            case "CITZ":
                roleName = "Citizen";
                break;
            case "COLL":
                roleName = "Collector";
                break;
            case "ADMN":
                roleName = "Admin";
                break;
            default:
                roleName = "User";
                break;
        }

        Session["SelectedRoleName"] = roleName;
        Response.Redirect(string.Format("~/RegistrationForm.aspx?role={0}", selectedRoleId));
    }
}