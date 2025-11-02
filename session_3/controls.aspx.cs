using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.UI.WebControls;

namespace uoh_projects.session_3
{
    public partial class controls : System.Web.UI.Page
    {
        // Student class definition
        public class Students
        {
            public int studentID { get; set; }
            public string name { get; set; }
            public int age { get; set; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // Initialize GridView with student data
                List<Students> students = new List<Students>()
                {
                    new Students(){ studentID=1, name="Alice", age=20 },
                    new Students(){ studentID=2, name="Bob", age=22 },
                    new Students(){ studentID=3, name="Charlie", age=21 },
                    new Students(){ studentID=4, name="Diana", age=23 },
                    new Students(){ studentID=5, name="Eve", age=19 }
                };
                GridView1.DataSource = students;
                GridView1.DataBind();

                // Initialize Repeater with sample data
                Repeater1.DataSource = Enumerable.Range(1, 5);
                Repeater1.DataBind();

                // Initialize BulletedList
                BulletedList1.Items.Clear();
                BulletedList1.Items.Add(new ListItem("Page loaded successfully", "1"));

                // Set initial output message
                lblOutput.Text = "Page loaded. Interact with controls to see events in action.";

                // Initialize calendar to today
                Calendar1.SelectedDate = DateTime.Today;

                // Set initial progress bar
                UpdateProgressBar(0);
            }
        }

        // TextBox and Button event
        protected void btnGreet_Click(object sender, EventArgs e)
        {
            string name = txtName.Text.Trim();
            if (!string.IsNullOrEmpty(name))
            {
                lblOutput.Text = $"Hello, {name}! Welcome to ASP.NET Controls Demo.";
                AddBulletedListItem($"Greeting sent to: {name}");
            }
            else
            {
                lblOutput.Text = "Please enter your name first.";
            }
        }

        // DropDownList selection changed event
        protected void DrpCalculationType_SelectedIndexChanged(object sender, EventArgs e)
        {
            string selectedOperation = DrpCalculationType.SelectedValue;
            if (selectedOperation != "Choose a symbol")
            {
                lblOutput.Text = $"Selected operation: {selectedOperation}";
                AddBulletedListItem($"Operation changed to: {selectedOperation}");

                // Demonstrate calculation based on selection
                double result = 0;
                double num1 = 10, num2 = 5;

                switch (selectedOperation)
                {
                    case "Add":
                        result = num1 + num2;
                        break;
                    case "Subtract":
                        result = num1 - num2;
                        break;
                    case "Divide":
                        result = num1 / num2;
                        break;
                    case "Multiply":
                        result = num1 * num2;
                        break;
                }

                lblOutput.Text += $" | Calculation: {num1} {GetOperationSymbol(selectedOperation)} {num2} = {result}";
            }
        }

        // Helper method to get operation symbol
        private string GetOperationSymbol(string operation)
        {
            switch (operation)
            {
                case "Add": return "+";
                case "Subtract": return "-";
                case "Divide": return "/";
                case "Multiply": return "*";
                default: return "";
            }
        }

        // File Upload event
        protected void btnUpload_Click(object sender, EventArgs e)
        {
            if (fileUpload.HasFile)
            {
                string fileName = fileUpload.FileName;
                string fileSize = (fileUpload.PostedFile.ContentLength / 1024.0).ToString("0.00");
                string fileExtension = System.IO.Path.GetExtension(fileName).ToLower();

                lblOutput.Text = $"File uploaded: {fileName} ({fileSize} KB)";
                AddBulletedListItem($"File uploaded: {fileName}");

                // Check file type
                string[] allowedExtensions = { ".txt", ".pdf", ".doc", ".docx", ".jpg", ".png" };
                if (allowedExtensions.Contains(fileExtension))
                {
                    lblOutput.Text += " - Valid file type";
                }
                else
                {
                    lblOutput.Text += " - Warning: Uncommon file type";
                }
            }
            else
            {
                lblOutput.Text = "Please select a file to upload.";
            }
        }

        // Calendar selection changed event
        protected void Calendar1_SelectionChanged(object sender, EventArgs e)
        {
            DateTime selectedDate = Calendar1.SelectedDate;
            lblOutput.Text = $"Selected date: {selectedDate.ToLongDateString()}";
            AddBulletedListItem($"Date selected: {selectedDate.ToShortDateString()}");

            // Highlight weekends
            if (selectedDate.DayOfWeek == DayOfWeek.Saturday || selectedDate.DayOfWeek == DayOfWeek.Sunday)
            {
                lblOutput.Text += " (Weekend)";
            }
        }

        // GridView paging event
        protected void GridView1_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            GridView1.PageIndex = e.NewPageIndex;

            // Rebind data to maintain state
            List<Students> students = new List<Students>()
            {
                new Students(){ studentID=1, name="Alice", age=20 },
                new Students(){ studentID=2, name="Bob", age=22 },
                new Students(){ studentID=3, name="Charlie", age=21 },
                new Students(){ studentID=4, name="Diana", age=23 },
                new Students(){ studentID=5, name="Eve", age=19 }
            };
            GridView1.DataSource = students;
            GridView1.DataBind();

            lblOutput.Text = $"GridView page changed to: {e.NewPageIndex + 1}";
            AddBulletedListItem($"Grid page changed to: {e.NewPageIndex + 1}");
        }

        // Progress bar simulation
        protected void btnStartProgress_Click(object sender, EventArgs e)
        {
            lblOutput.Text = "Progress simulation started...";
            AddBulletedListItem("Progress simulation started");

            // Simulate progress updates
            for (int i = 0; i <= 100; i += 10)
            {
                // Update progress bar
                UpdateProgressBar(i);

                // Force UI update (in real scenario, you'd use AJAX)
                System.Threading.Thread.Sleep(100);
            }

            lblOutput.Text = "Progress simulation completed!";
            AddBulletedListItem("Progress simulation completed");
        }

        // Helper method to update progress bar
        private void UpdateProgressBar(int percentage)
        {
            progressBar.Style["width"] = percentage + "%";
            progressBar.Attributes["aria-valuenow"] = percentage.ToString();

            // Change color based on progress
            if (percentage < 30)
            {
                progressBar.CssClass = "progress-bar progress-bar-striped progress-bar-animated bg-danger";
            }
            else if (percentage < 70)
            {
                progressBar.CssClass = "progress-bar progress-bar-striped progress-bar-animated bg-warning";
            }
            else
            {
                progressBar.CssClass = "progress-bar progress-bar-striped progress-bar-animated bg-success";
            }
        }

        // Helper method to add items to bulleted list
        private void AddBulletedListItem(string text)
        {
            // Keep only last 10 items to prevent overflow
            if (BulletedList1.Items.Count >= 10)
            {
                BulletedList1.Items.RemoveAt(0);
            }

            BulletedList1.Items.Add(new ListItem($"{DateTime.Now:HH:mm:ss} - {text}"));
        }

        // RadioButtonList selection changed (if AutoPostBack is enabled)
        protected void rblOptions_SelectedIndexChanged(object sender, EventArgs e)
        {
            string selectedValue = rblOptions.SelectedValue;
            lblOutput.Text = $"Radio button selected: Option {selectedValue}";
            AddBulletedListItem($"Radio selection: Option {selectedValue}");
        }

        // CheckBoxList selection changed (if AutoPostBack is enabled)
        protected void cblInterests_SelectedIndexChanged(object sender, EventArgs e)
        {
            var selectedInterests = cblInterests.Items.Cast<ListItem>()
                .Where(li => li.Selected)
                .Select(li => li.Text);

            if (selectedInterests.Any())
            {
                lblOutput.Text = $"Selected interests: {string.Join(", ", selectedInterests)}";
                AddBulletedListItem($"Interests updated: {string.Join(", ", selectedInterests)}");
            }
        }

        // MultiView active view changed
        protected void MultiView1_ActiveViewChanged(object sender, EventArgs e)
        {
            lblOutput.Text = $"MultiView changed to: View {MultiView1.ActiveViewIndex + 1}";
            AddBulletedListItem($"MultiView active view: {MultiView1.ActiveViewIndex + 1}");
        }

        // TextBox text changed event
        protected void txtName_TextChanged(object sender, EventArgs e)
        {
            if (!string.IsNullOrEmpty(txtName.Text))
            {
                AddBulletedListItem($"Name field updated: {txtName.Text}");
            }
        }

        // Email text changed event
        protected void txtEmail_TextChanged(object sender, EventArgs e)
        {
            if (!string.IsNullOrEmpty(txtEmail.Text))
            {
                AddBulletedListItem($"Email field updated: {txtEmail.Text}");
            }
        }

        // ========== MISSING EVENT HANDLERS - ADD THESE ==========

        // MultiView navigation buttons
        protected void btnNextView_Click(object sender, EventArgs e)
        {
            MultiView1.ActiveViewIndex = 1;
            lblOutput.Text = "Navigated to View 2";
            AddBulletedListItem("MultiView: Navigated to View 2");
        }

        protected void btnPrevView_Click(object sender, EventArgs e)
        {
            MultiView1.ActiveViewIndex = 0;
            lblOutput.Text = "Navigated to View 1";
            AddBulletedListItem("MultiView: Navigated to View 1");
        }

        // Checkbox setting changed
        protected void chkSetting1_CheckedChanged(object sender, EventArgs e)
        {
            string status = chkSetting1.Checked ? "enabled" : "disabled";
            lblOutput.Text = $"Notifications {status}";
            AddBulletedListItem($"Notifications setting: {status}");
        }

        // Help button event
        protected void btnShowHelp_Click(object sender, EventArgs e)
        {
            lblOutput.Text = "Help: This demo shows ASP.NET Web Forms controls in action. Interact with controls to see events trigger.";
            AddBulletedListItem("Help message displayed");
        }

        // Additional event handlers for better demonstration
        protected void DrpCalculationType_TextChanged(object sender, EventArgs e)
        {
            AddBulletedListItem($"Dropdown text changed: {DrpCalculationType.SelectedValue}");
        }

        protected void fileUpload_DataBinding(object sender, EventArgs e)
        {
            AddBulletedListItem("FileUpload data binding");
        }
    }
}