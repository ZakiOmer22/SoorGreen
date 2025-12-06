<%@ Page Title="Feedback" Language="C#" MasterPageFile="~/Pages/Citizen/Site.Master" AutoEventWireup="true" CodeFile="Feedback.aspx.cs" Inherits="SoorGreen.Citizen.Feedback" %>

<asp:Content ID="Content3" ContentPlaceHolderID="HeadContent" runat="server">
    <link href='<%= ResolveUrl("~/Content/Pages/Citizen/citizenfeedback.css") %>' rel="stylesheet" />
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/flatpickr/dist/flatpickr.min.css">
</asp:Content>

<asp:Content ID="Content4" ContentPlaceHolderID="ScriptsContent" runat="server">
    <script src='<%= ResolveUrl("~/Scripts/Pages/Citizen/citizenfeedback.js") %>'></script>
    <script src="https://cdn.jsdelivr.net/npm/flatpickr"></script>
</asp:Content>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Feedback - SoorGreen Citizen
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    
    <!-- Toaster Container -->
    <div class="toast-container" id="toastContainer"></div>

    <div class="feedback-container">
        <br />
        <br />
        <br />

        <h1 style="font-size: 2rem; font-weight: 700; margin-bottom: 0.5rem;">Submit Feedback</h1>
        <p class="text-muted" style="margin-bottom: 2rem;">Help us improve SoorGreen by sharing your experience and suggestions.</p>

        <div class="feedback-card">
            <div class="form-row">
                <div class="form-group">
                    <label class="form-label">Feedback Category</label>
                    <asp:DropDownList ID="ddlCategory" runat="server" CssClass="form-select bg-secondary">
                        <asp:ListItem Value="">Select Category</asp:ListItem>
                        <asp:ListItem Value="General">General Feedback</asp:ListItem>
                        <asp:ListItem Value="Feature">Feature Request</asp:ListItem>
                        <asp:ListItem Value="Bug">Bug Report</asp:ListItem>
                        <asp:ListItem Value="UI">User Interface</asp:ListItem>
                        <asp:ListItem Value="Performance">Performance</asp:ListItem>
                        <asp:ListItem Value="Support">Customer Support</asp:ListItem>
                        <asp:ListItem Value="Other">Other</asp:ListItem>
                    </asp:DropDownList>
                </div>

                <div class="form-group">
                    <label class="form-label">Priority Level</label>
                    <asp:DropDownList ID="ddlPriority" runat="server" CssClass="form-select bg-secondary">
                        <asp:ListItem Value="">Select Priority</asp:ListItem>
                        <asp:ListItem Value="Low">Low Priority</asp:ListItem>
                        <asp:ListItem Value="Medium">Medium Priority</asp:ListItem>
                        <asp:ListItem Value="High">High Priority</asp:ListItem>
                        <asp:ListItem Value="Critical">Critical</asp:ListItem>
                    </asp:DropDownList>
                </div>
            </div>

            <div class="form-group">
                <label class="form-label">Overall Satisfaction Rating</label>
                <div class="rating-container">
                    <div class="rating-stars" id="ratingStars">
                        <span class="rating-star" data-rating="1">★</span>
                        <span class="rating-star" data-rating="2">★</span>
                        <span class="rating-star" data-rating="3">★</span>
                        <span class="rating-star" data-rating="4">★</span>
                        <span class="rating-star" data-rating="5">★</span>
                    </div>
                    <span class="rating-label" id="ratingLabel">Click to rate</span>
                </div>
                <asp:HiddenField ID="hfRating" runat="server" Value="0" />
            </div>

            <div class="form-group">
                <label class="form-label">Subject</label>
                <asp:TextBox ID="txtSubject" runat="server" CssClass="form-control"
                    placeholder="Brief summary of your feedback" MaxLength="200"></asp:TextBox>
            </div>

            <div class="form-group">
                <label class="form-label">Detailed Feedback</label>
                <asp:TextBox ID="txtFeedback" runat="server" CssClass="form-control" TextMode="MultiLine"
                    Rows="6" placeholder="Please provide detailed feedback including:
                - What you liked or didn't like
                - Specific issues encountered  
                - Steps to reproduce (if applicable)
                - Suggested improvements
                - Any additional context

                Your detailed feedback helps us improve faster."></asp:TextBox>
            </div>

            <div class="form-group">
                <label class="form-label">
                    <asp:CheckBox ID="cbFollowUp" runat="server" />
                    I'm open to follow-up questions about my feedback
                </label>
            </div>

            <asp:Button ID="btnSubmit" runat="server" Text="Submit Feedback" CssClass="btn-primary"
                OnClick="btnSubmit_Click" OnClientClick="return validateFeedback();" />
        </div>

        <div class="feedback-history">
            <h3 class="section-title">Feedback History</h3>
            <div id="feedbackList" runat="server">
                <!-- Feedback items will be populated here -->
            </div>
        </div>
    </div>

   
</asp:Content>
