using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.Configuration;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace SoorGreen.Citizen
{
    public partial class Feedback : System.Web.UI.Page
    {
        private string connectionString = WebConfigurationManager.ConnectionStrings["SoorGreenDBConnectionString"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (Session["UserId"] == null || Session["UserRole"] == null)
                {
                    Response.Redirect("~/Login.aspx");
                    return;
                }

                if (Session["UserRole"].ToString() != "CITZ" && Session["UserRole"].ToString() != "R001")
                {
                    Response.Redirect("~/Pages/Unauthorized.aspx");
                    return;
                }

                LoadFeedbackHistory();
            }
        }

        protected void btnSubmit_Click(object sender, EventArgs e)
        {
            string feedbackMessage = txtFeedback.Text.Trim();

            if (string.IsNullOrEmpty(feedbackMessage))
            {
                ShowToast("Oops!", "Please enter your feedback before submitting.", "error");
                return;
            }

            if (feedbackMessage.Length < 10)
            {
                ShowToast("Too Short", "Please provide more detailed feedback (at least 10 characters).", "error");
                return;
            }

            if (SubmitFeedback(feedbackMessage))
            {
                ShowToast("Success!", "Thank you for your feedback! We appreciate your input. 🌟", "success");
                txtFeedback.Text = "";
                LoadFeedbackHistory();
            }
            else
            {
                ShowToast("Error", "Oops! Something went wrong. Please try again.", "error");
            }
        }

        private bool SubmitFeedback(string message)
        {
            try
            {
                string userId = Session["UserId"] != null ? Session["UserId"].ToString() : "R001";

                // Generate FeedbackId
                string feedbackId = GenerateFeedbackId();

                string query = @"
                    INSERT INTO Feedbacks (FeedbackId, UserId, Message, CreatedAt)
                    VALUES (@FeedbackId, @UserId, @Message, GETDATE())";

                using (SqlConnection conn = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@FeedbackId", feedbackId);
                    cmd.Parameters.AddWithValue("@UserId", userId);
                    cmd.Parameters.AddWithValue("@Message", message);

                    conn.Open();
                    int result = cmd.ExecuteNonQuery();
                    return result > 0;
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error submitting feedback: " + ex.Message);
                return false;
            }
        }

        private string GenerateFeedbackId()
        {
            try
            {
                string query = "SELECT ISNULL(MAX(CAST(SUBSTRING(FeedbackId, 3, 2) AS INT)), 0) + 1 FROM Feedbacks WHERE FeedbackId LIKE 'FB%'";

                using (SqlConnection conn = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    conn.Open();
                    int nextId = (int)cmd.ExecuteScalar();
                    return "FB" + nextId.ToString("00");
                }
            }
            catch (Exception)
            {
                return "FB01";
            }
        }

        private void LoadFeedbackHistory()
        {
            try
            {
                string userId = Session["UserId"] != null ? Session["UserId"].ToString() : "R001";

                string query = @"
                    SELECT Message, CreatedAt 
                    FROM Feedbacks 
                    WHERE UserId = @UserId 
                    ORDER BY CreatedAt DESC";

                using (SqlConnection conn = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@UserId", userId);
                    conn.Open();

                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.HasRows)
                        {
                            string html = "";
                            while (reader.Read())
                            {
                                string message = reader["Message"].ToString();
                                DateTime createdAt = Convert.ToDateTime(reader["CreatedAt"]);
                                string timeAgo = GetTimeAgo(createdAt);
                                string encodedMessage = Server.HtmlEncode(message);

                                html += string.Format(@"
                                    <div class='feedback-item'>
                                        <div class='feedback-message'>{0}</div>
                                        <div class='feedback-meta'>
                                            <i class='fas fa-clock'></i>Submitted {1}
                                        </div>
                                    </div>", encodedMessage, timeAgo);
                            }
                            feedbackList.InnerHtml = html;
                        }
                        else
                        {
                            feedbackList.InnerHtml = @"
                                <div class='empty-state'>
                                    <div class='empty-state-icon'>
                                        <i class='fas fa-comments'></i>
                                    </div>
                                    <h4 class='empty-state-title'>No Feedback Yet</h4>
                                    <p class='empty-state-description'>You haven't submitted any feedback yet. Be the first to share your thoughts with us!</p>
                                </div>";
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error loading feedback history: " + ex.Message);
                feedbackList.InnerHtml = "<p class='text-muted'>Error loading feedback history.</p>";
            }
        }

        private string GetTimeAgo(DateTime date)
        {
            TimeSpan timeSince = DateTime.Now - date;

            if (timeSince.TotalMinutes < 1) return "just now";
            if (timeSince.TotalMinutes < 60) return string.Format("{0} minutes ago", (int)timeSince.TotalMinutes);
            if (timeSince.TotalHours < 24) return string.Format("{0} hours ago", (int)timeSince.TotalHours);
            if (timeSince.TotalDays < 7) return string.Format("{0} days ago", (int)timeSince.TotalDays);

            return date.ToString("MMM dd, yyyy");
        }

        private void ShowToast(string title, string message, string type)
        {
            string script = string.Format("showToast('{0}', '{1}', '{2}');",
                title.Replace("'", "\\'"),
                message.Replace("'", "\\'"),
                type);
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ToastScript", script, true);
        }
    }
}