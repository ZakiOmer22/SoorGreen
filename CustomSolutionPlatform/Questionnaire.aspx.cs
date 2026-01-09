using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.Script.Serialization;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;

namespace SoorGreen.CustomSolutionPlatform
{
    public partial class Questionnaire : System.Web.UI.Page
    {
        private string connectionString;
        private JavaScriptSerializer jsonSerializer;

        protected void Page_Load(object sender, EventArgs e)
        {
            // Initialize serializers
            jsonSerializer = new JavaScriptSerializer();

            // Initialize connection string
            if (ConfigurationManager.ConnectionStrings["SoorGreenDB"] != null)
            {
                connectionString = ConfigurationManager.ConnectionStrings["SoorGreenDB"].ConnectionString;
            }
            else
            {
                // Fallback connection string for testing
                connectionString = "Data Source=.;Initial Catalog=SoorGreenDB;Integrated Security=True;MultipleActiveResultSets=True";
            }

            if (!IsPostBack)
            {
                InitializeQuestionnaire();
            }
        }

        private void InitializeQuestionnaire()
        {
            try
            {
                // Get user type from query string
                string userType = Request.QueryString["type"] ?? "IT";
                hdnUserType.Value = userType;

                // Set user type badge
                if (userType == "IT")
                {
                    userTypeBadge.InnerText = "IT Professional";
                    userTypeBadge.Attributes["class"] = "user-type-badge badge-it";
                }
                else
                {
                    userTypeBadge.InnerText = "Non-IT Business User";
                    userTypeBadge.Attributes["class"] = "user-type-badge badge-nonit";
                }

                // Create new session
                Guid sessionId = Guid.NewGuid();
                hdnSessionId.Value = sessionId.ToString();

                // Save session to database
                SaveSessionToDatabase(sessionId, userType);

                // Load first question
                LoadQuestion(1, userType);
                UpdateProgress();
            }
            catch (Exception ex)
            {
                // Show error
                errorMessage.Visible = true;
                lblErrorMessage.Text = $"Error initializing questionnaire: {ex.Message}";
            }
        }

        private void SaveSessionToDatabase(Guid sessionId, string userType)
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    string query = @"
                        INSERT INTO QuestionnaireSessions (SessionId, UserTypeId, Status, StartedAt) 
                        VALUES (@SessionId, 
                                (SELECT UserTypeId FROM UserTypes WHERE TypeName LIKE @UserType + '%'), 
                                'InProgress', 
                                GETDATE())";

                    SqlCommand cmd = new SqlCommand(query, conn);
                    cmd.Parameters.AddWithValue("@SessionId", sessionId);
                    cmd.Parameters.AddWithValue("@UserType", userType == "IT" ? "IT Professional" : "Non-IT Business");

                    conn.Open();
                    cmd.ExecuteNonQuery();
                }
            }
            catch (Exception ex)
            {
                // Log error but continue
                System.Diagnostics.Debug.WriteLine($"Error saving session: {ex.Message}");
            }
        }

        private void LoadQuestion(int questionNumber, string userType)
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    string query = @"
                        SELECT TOP 1 q.QuestionId, q.QuestionText, q.QuestionType, q.OptionsJSON, q.HelpText,
                               c.CategoryName
                        FROM QuestionTemplates q
                        LEFT JOIN SolutionCategories c ON q.CategoryId = c.CategoryId
                        WHERE q.UserTypeId = (SELECT UserTypeId FROM UserTypes WHERE TypeName LIKE @UserType + '%')
                        AND q.IsActive = 1
                        AND q.DisplayOrder = @QuestionNumber
                        ORDER BY q.DisplayOrder";

                    SqlCommand cmd = new SqlCommand(query, conn);
                    cmd.Parameters.AddWithValue("@UserType", userType == "IT" ? "IT Professional" : "Non-IT Business");
                    cmd.Parameters.AddWithValue("@QuestionNumber", questionNumber);

                    conn.Open();
                    SqlDataReader reader = cmd.ExecuteReader();

                    if (reader.Read())
                    {
                        int questionId = Convert.ToInt32(reader["QuestionId"]);
                        string questionText = reader["QuestionText"].ToString();
                        string questionType = reader["QuestionType"].ToString();
                        string optionsJson = reader["OptionsJSON"]?.ToString() ?? "[]";
                        string helpText = reader["HelpText"]?.ToString();
                        string category = reader["CategoryName"]?.ToString();

                        // Update display
                        UpdateQuestionDisplay(questionNumber, questionText);
                        hdnCurrentQuestionId.Value = questionId.ToString();
                        hdnQuestionType.Value = questionType;

                        // Load options
                        LoadOptions(optionsJson, questionType);

                        // Update question count
                        hdnQuestionCount.Value = questionNumber.ToString();

                        // Update button text with icons
                        UpdateButtonText(questionNumber);
                    }
                    else
                    {
                        // No more questions
                        questionTextSpan.InnerText = "Questionnaire Complete!";
                        optionsContainer.InnerHtml = "<div class='alert alert-success'><i class='fas fa-check-circle'></i> All questions answered. Click 'Generate Solution' to proceed.</div>";
                        btnNext.Visible = false;
                        btnGenerate.Visible = true;
                        btnGenerate.Text = "<i class='fas fa-magic'></i> Generate Solution";
                    }

                    reader.Close();
                }
            }
            catch (Exception ex)
            {
                // Show demo question if database error
                LoadDemoQuestion(questionNumber, userType);
                errorMessage.Visible = true;
                lblErrorMessage.Text = $"Database connection issue. Using demo questions: {ex.Message}";
            }
        }

        private void UpdateQuestionDisplay(int questionNumber, string questionText)
        {
            // Find or create the question number span
            var questionNumberSpan = FindControlRecursive(questionCard, "questionNumberSpan") as HtmlGenericControl;
            if (questionNumberSpan != null)
            {
                questionNumberSpan.InnerText = questionNumber.ToString();
            }
            else
            {
                // Create it if it doesn't exist
                var span = new HtmlGenericControl("span");
                span.ID = "questionNumberSpan";
                span.InnerText = questionNumber.ToString();
                questionCard.Controls.Add(span);
            }

            // Find or create the question text span
            var questionTextSpan = FindControlRecursive(questionCard, "questionTextSpan") as HtmlGenericControl;
            if (questionTextSpan != null)
            {
                questionTextSpan.InnerText = questionText;
            }
            else
            {
                // Create it if it doesn't exist
                var span = new HtmlGenericControl("span");
                span.ID = "questionTextSpan";
                span.InnerText = questionText;
                questionCard.Controls.Add(span);
            }
        }

        private Control FindControlRecursive(Control root, string id)
        {
            if (root.ID == id)
                return root;

            foreach (Control c in root.Controls)
            {
                Control t = FindControlRecursive(c, id);
                if (t != null)
                    return t;
            }

            return null;
        }

        private void LoadDemoQuestion(int questionNumber, string userType)
        {
            // Demo questions for testing
            string[] demoQuestions = {
                "What is your primary technical expertise?",
                "What is your budget range for this solution?",
                "What is your timeline for implementation?",
                "How many users will use this solution?",
                "What are your key requirements?"
            };

            string[] demoOptions = {
                "Web Development, Mobile Development, Database Management, Cloud Services, Networking",
                "Under $5,000, $5,000 - $20,000, $20,000 - $50,000, Over $50,000",
                "Immediately, Within 1 month, 1-3 months, 3-6 months, Over 6 months",
                "1-10, 11-50, 51-200, 201-1000, Over 1000",
                "Scalability, Security, User-friendly interface, Integration capabilities, Cost-effectiveness"
            };

            int index = Math.Min(questionNumber - 1, demoQuestions.Length - 1);

            UpdateQuestionDisplay(questionNumber, demoQuestions[index]);
            hdnQuestionType.Value = "SingleSelect";

            // Load demo options
            string[] options = demoOptions[index].Split(',');
            LoadOptionsFromArray(options, "SingleSelect");

            // Update question count
            hdnQuestionCount.Value = questionNumber.ToString();
            UpdateButtonText(questionNumber);
        }

        private void LoadOptions(string optionsJson, string questionType)
        {
            try
            {
                List<string> options = jsonSerializer.Deserialize<List<string>>(optionsJson);
                LoadOptionsFromArray(options.ToArray(), questionType);
            }
            catch
            {
                // If JSON parsing fails, create default options
                string[] defaultOptions = { "Option 1", "Option 2", "Option 3", "Option 4" };
                LoadOptionsFromArray(defaultOptions, questionType);
            }
        }

        private void LoadOptionsFromArray(string[] options, string questionType)
        {
            string html = "";
            int optionIndex = 1;

            foreach (string option in options)
            {
                string iconClass = GetOptionIcon(optionIndex);

                html += $@"
                <div class='option-card' data-value='{optionIndex}'>
                    <div class='option-icon'>
                        <i class='{iconClass}'></i>
                    </div>
                    <div class='option-text'>{option.Trim()}</div>
                    <input type='hidden' class='option-value' value='{optionIndex}' />
                </div>";

                optionIndex++;
            }

            optionsContainer.InnerHtml = html;
        }

        private void UpdateButtonText(int questionNumber)
        {
            // Set button text with icons
            if (questionNumber > 1)
            {
                btnPrevious.Visible = true;
                btnPrevious.Text = "<i class='fas fa-arrow-left'></i> Previous";
            }
            else
            {
                btnPrevious.Visible = false;
            }

            if (questionNumber < 10)
            {
                btnNext.Visible = true;
                btnNext.Text = "Next <i class='fas fa-arrow-right'></i>";
            }
            else
            {
                btnNext.Visible = false;
                btnGenerate.Visible = true;
                btnGenerate.Text = "<i class='fas fa-magic'></i> Generate Solution";
            }
        }

        private string GetOptionIcon(int index)
        {
            switch (index)
            {
                case 1: return "fas fa-star";
                case 2: return "fas fa-chart-line";
                case 3: return "fas fa-cogs";
                case 4: return "fas fa-bolt";
                case 5: return "fas fa-users";
                case 6: return "fas fa-shield-alt";
                case 7: return "fas fa-cloud";
                case 8: return "fas fa-mobile-alt";
                default: return "fas fa-circle";
            }
        }

        protected void btnPrevious_Click(object sender, EventArgs e)
        {
            int currentQuestion = Convert.ToInt32(hdnQuestionCount.Value);
            if (currentQuestion > 1)
            {
                // Save current response
                SaveResponse(currentQuestion);

                // Load previous question
                LoadQuestion(currentQuestion - 1, hdnUserType.Value);
                UpdateProgress();
            }
        }

        protected void btnNext_Click(object sender, EventArgs e)
        {
            int currentQuestion = Convert.ToInt32(hdnQuestionCount.Value);

            // Validate selection
            if (!ValidateSelection())
            {
                errorMessage.Visible = true;
                lblErrorMessage.Text = "Please select at least one option to continue.";
                return;
            }

            errorMessage.Visible = false;

            // Save current response
            SaveResponse(currentQuestion);

            // Load next question
            LoadQuestion(currentQuestion + 1, hdnUserType.Value);
            UpdateProgress();
        }

        private bool ValidateSelection()
        {
            string selectedOptions = hdnSelectedOptions.Value;
            if (string.IsNullOrEmpty(selectedOptions) || selectedOptions == "[]")
                return false;

            return true;
        }

        private void SaveResponse(int questionNumber)
        {
            try
            {
                string sessionId = hdnSessionId.Value;
                string questionId = hdnCurrentQuestionId.Value;
                string selectedOptions = hdnSelectedOptions.Value;

                if (string.IsNullOrEmpty(sessionId) || string.IsNullOrEmpty(questionId) || selectedOptions == "[]")
                    return;

                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    string query = @"
                        INSERT INTO QuestionResponses (SessionId, QuestionId, AnswerJSON, ResponseTime) 
                        VALUES (@SessionId, @QuestionId, @AnswerJSON, GETDATE())";

                    SqlCommand cmd = new SqlCommand(query, conn);
                    cmd.Parameters.AddWithValue("@SessionId", Guid.Parse(sessionId));
                    cmd.Parameters.AddWithValue("@QuestionId", questionId);
                    cmd.Parameters.AddWithValue("@AnswerJSON", selectedOptions);

                    conn.Open();
                    cmd.ExecuteNonQuery();
                }
            }
            catch (Exception ex)
            {
                // Log error but continue
                System.Diagnostics.Debug.WriteLine($"Error saving response: {ex.Message}");
            }
        }

        protected void btnGenerate_Click(object sender, EventArgs e)
        {
            try
            {
                // Save final response
                int currentQuestion = Convert.ToInt32(hdnQuestionCount.Value);
                SaveResponse(currentQuestion);

                // Mark session as completed
                CompleteSession();

                // Generate solution
                int solutionId = GenerateSolution();

                // Redirect to solutions page
                Response.Redirect($"Solutions.aspx?sessionId={hdnSessionId.Value}&solutionId={solutionId}");
            }
            catch (Exception ex)
            {
                errorMessage.Visible = true;
                lblErrorMessage.Text = $"Error generating solution: {ex.Message}";
            }
        }

        private void CompleteSession()
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    string query = @"
                        UPDATE QuestionnaireSessions 
                        SET Status = 'Completed', 
                            CompletedAt = GETDATE(),
                            TimeSpent = DATEDIFF(SECOND, StartedAt, GETDATE())
                        WHERE SessionId = @SessionId";

                    SqlCommand cmd = new SqlCommand(query, conn);
                    cmd.Parameters.AddWithValue("@SessionId", Guid.Parse(hdnSessionId.Value));

                    conn.Open();
                    cmd.ExecuteNonQuery();
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error completing session: {ex.Message}");
            }
        }

        private int GenerateSolution()
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    // For demo, return a static solution ID
                    string query = @"
                        DECLARE @TemplateId INT = 1;
                        DECLARE @SolutionId INT;
                        
                        -- Insert generated solution
                        INSERT INTO GeneratedSolutions (SessionId, TemplateId, SolutionTitle, SolutionType, ProposedSolution, GeneratedAt)
                        VALUES (@SessionId, @TemplateId, 
                                'Custom Business Solution', 
                                CASE WHEN @UserType = 'IT' THEN 'IT' ELSE 'Non-IT' END,
                                'This is a generated solution based on your questionnaire responses.', 
                                GETDATE());
                        
                        SELECT SCOPE_IDENTITY() AS NewSolutionId;";

                    SqlCommand cmd = new SqlCommand(query, conn);
                    cmd.Parameters.AddWithValue("@SessionId", Guid.Parse(hdnSessionId.Value));
                    cmd.Parameters.AddWithValue("@UserType", hdnUserType.Value);

                    conn.Open();
                    object result = cmd.ExecuteScalar();

                    return result == null ? 1 : Convert.ToInt32(result);
                }
            }
            catch
            {
                // Return a default solution ID
                return 1;
            }
        }

        private void UpdateProgress()
        {
            try
            {
                int current = Convert.ToInt32(hdnQuestionCount.Value);
                int total = Convert.ToInt32(hdnTotalQuestions.Value);

                int percent = (current * 100) / total;

                progressText.InnerText = $"Question {current} of {total}";
                progressPercent.InnerText = $"{percent}%";
                progressBar.Style["width"] = $"{percent}%";
            }
            catch
            {
                // Default progress
                progressText.InnerText = "Question 1 of 10";
                progressPercent.InnerText = "10%";
                progressBar.Style["width"] = "10%";
            }
        }
    }
}