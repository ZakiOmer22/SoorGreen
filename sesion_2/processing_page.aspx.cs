using System;

namespace uoh_projects.session_two
{
    public partial class processing_page : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            lblResult.Text = string.Empty;

        }

        protected void btnCalculate_Click(object sender, EventArgs e)
        {
            if (txtNumberOne.Text == String.Empty && txtNumberTwo.Text == String.Empty)
            {
                lblFail.Text = "Please Enter The Two Numbers";
                return;
            }
            else
            {
                if (DrpCalculationType.SelectedIndex == 0)
                {
                    lblFail.Text = "Please Choose one of the Symbols to calculate";
                }
                // PROCCESING PART
                if (DrpCalculationType.SelectedValue == "Add")
                {

                    int n1 = int.Parse(txtNumberOne.Text);
                    int n2 = int.Parse(txtNumberTwo.Text);
                    int result = n1 + n2;
                    lblResult.Text = result.ToString();
                }
                else if (DrpCalculationType.SelectedValue == "Subtract")
                {
                    int n1 = int.Parse(txtNumberOne.Text);
                    int n2 = int.Parse(txtNumberTwo.Text);
                    int result = n1 - n2;
                    lblResult.Text = result.ToString();
                }
                else if (DrpCalculationType.SelectedValue == "Divide")
                {
                    int n1 = int.Parse(txtNumberOne.Text);
                    int n2 = int.Parse(txtNumberTwo.Text);
                    int result = n1 / n2;
                    lblResult.Text = result.ToString();
                }
                else if (DrpCalculationType.SelectedValue == "Multiply")
                {
                    int n1 = int.Parse(txtNumberOne.Text);
                    int n2 = int.Parse(txtNumberTwo.Text);
                    int result = n1 * n2;
                    lblResult.Text = result.ToString();
                }
            }
        }
    }
}