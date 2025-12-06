<%@ Page Title="Help & Support" Language="C#" MasterPageFile="~/Pages/Citizen/Site.Master" AutoEventWireup="true" CodeFile="Help.aspx.cs" Inherits="SoorGreen.Citizen.Help" %>

<asp:Content ID="Content3" ContentPlaceHolderID="HeadContent" runat="server">
    <link href='<%= ResolveUrl("~/Content/Pages/Citizen/citizenhelp.css") %>' rel="stylesheet" />
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/flatpickr/dist/flatpickr.min.css">
</asp:Content>

<asp:Content ID="Content4" ContentPlaceHolderID="ScriptsContent" runat="server">
    <script src='<%= ResolveUrl("~/Scripts/Pages/Citizen/citizenhelp.js") %>'></script>
    <script src="https://cdn.jsdelivr.net/npm/flatpickr"></script>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    
    <!-- Toaster Container -->
    <div class="toast-container" id="toastContainer"></div>

    <div class="help-container">
        <br />
        <br />
        <br />
        
        <!-- Hero Section -->
        <div class="help-card">
            <div class="hero-section">
                <h1 class="hero-title">How Can We Help You?</h1>
                <p class="hero-subtitle">
                    Get instant help with our comprehensive support resources, FAQs, and direct contact options. 
                    We're here to ensure your SoorGreen experience is seamless and enjoyable.
                </p>
            </div>

            <!-- Quick Actions -->
            <div class="quick-actions-grid">
                <div class="quick-action-card" onclick="scrollToSection('faq')">
                    <div class="action-icon">
                        <i class="fas fa-question-circle"></i>
                    </div>
                    <h3 class="action-title">Browse FAQs</h3>
                    <p class="action-description">Find quick answers to common questions about using SoorGreen</p>
                </div>
                
                <div class="quick-action-card" onclick="scrollToSection('contact')">
                    <div class="action-icon">
                        <i class="fas fa-headset"></i>
                    </div>
                    <h3 class="action-title">Contact Support</h3>
                    <p class="action-description">Get personalized help from our support team</p>
                </div>
                
                <div class="quick-action-card" onclick="showToast('Guide', 'Opening user guide...', 'info')">
                    <div class="action-icon">
                        <i class="fas fa-book"></i>
                    </div>
                    <h3 class="action-title">User Guide</h3>
                    <p class="action-description">Learn how to make the most of SoorGreen features</p>
                </div>
                
                <div class="quick-action-card" onclick="showToast('Status', 'Checking system status...', 'info')">
                    <div class="action-icon">
                        <i class="fas fa-server"></i>
                    </div>
                    <h3 class="action-title">System Status</h3>
                    <p class="action-description">Check current system performance and uptime</p>
                </div>
            </div>
        </div>

        <!-- FAQ Section -->
        <div class="help-card">
            <h2 class="section-title" id="faq">Frequently Asked Questions</h2>
            <div class="faq-list">
                <div class="faq-item">
                    <div class="faq-question" onclick="toggleFAQ(this)">
                        How do I report waste for pickup?
                        <span class="faq-toggle"><i class="fas fa-chevron-down"></i></span>
                    </div>
                    <div class="faq-answer">
                        To report waste for pickup:<br><br>
                        1. Go to the "Report Waste" section in your dashboard<br>
                        2. Select the type of waste (Plastic, Metal, Electronics, etc.)<br>
                        3. Enter the estimated weight in kilograms<br>
                        4. Provide your address and any special instructions<br>
                        5. Upload photos if available<br>
                        6. Submit the report and wait for collector assignment<br><br>
                        You'll receive notifications when a collector is assigned and when pickup is completed.
                    </div>
                </div>
                
                <div class="faq-item">
                    <div class="faq-question" onclick="toggleFAQ(this)">
                        How are reward points calculated?
                        <span class="faq-toggle"><i class="fas fa-chevron-down"></i></span>
                    </div>
                    <div class="faq-answer">
                        Reward points are calculated based on:<br><br>
                        • <strong>Waste Type:</strong> Different materials have different credit rates per kg<br>
                        • <strong>Weight:</strong> Points = Weight (kg) × Credit Rate<br>
                        • <strong>Verification:</strong> Actual weight verified during pickup<br><br>
                        <strong>Current Rates:</strong><br>
                        - Plastic: 2 credits/kg<br>
                        - Metal: 3 credits/kg<br>
                        - Electronics: 5 credits/kg<br>
                        - Glass: 2 credits/kg<br>
                        - Paper: 1 credit/kg
                    </div>
                </div>
                
                <div class="faq-item">
                    <div class="faq-question" onclick="toggleFAQ(this)">
                        How long does pickup take after reporting?
                        <span class="faq-toggle"><i class="fas fa-chevron-down"></i></span>
                    </div>
                    <div class="faq-answer">
                        Pickup timing depends on several factors:<br><br>
                        • <strong>Standard Pickup:</strong> 24-48 hours during weekdays<br>
                        • <strong>Location:</strong> Urban areas typically faster than rural<br>
                        • <strong>Waste Type:</strong> Some materials have specialized collectors<br>
                        • <strong>Availability:</strong> Collector availability in your area<br><br>
                        You can track your pickup status in real-time through the "My Pickups" section.
                    </div>
                </div>
                
                <div class="faq-item">
                    <div class="faq-question" onclick="toggleFAQ(this)">
                        How do I redeem my reward points?
                        <span class="faq-toggle"><i class="fas fa-chevron-down"></i></span>
                    </div>
                    <div class="faq-answer">
                        To redeem your reward points:<br><br>
                        1. Navigate to "Rewards" in your dashboard<br>
                        2. Check your available points balance<br>
                        3. Browse available redemption options<br>
                        4. Select your preferred redemption method<br>
                        5. Enter the amount you wish to redeem<br>
                        6. Submit your redemption request<br><br>
                        <strong>Redemption Options:</strong><br>
                        - Digital gift cards<br>
                        - Eco-friendly products<br>
                        - Utility bill payments<br>
                        - Charity donations<br>
                        - Cash transfers (minimum 500 points)
                    </div>
                </div>
                
                <div class="faq-item">
                    <div class="faq-question" onclick="toggleFAQ(this)">
                        What should I do if my pickup is delayed?
                        <span class="faq-toggle"><i class="fas fa-chevron-down"></i></span>
                    </div>
                    <div class="faq-answer">
                        If your pickup is delayed:<br><br>
                        1. <strong>Check Status:</strong> View pickup status in your dashboard<br>
                        2. <strong>Contact Collector:</strong> Use the messaging system to contact assigned collector<br>
                        3. <strong>Reschedule:</strong> Request rescheduling if needed<br>
                        4. <strong>Support Ticket:</strong> Create a support ticket for extended delays<br>
                        5. <strong>Emergency:</strong> For urgent issues, use the emergency contact<br><br>
                        Most delays are resolved within 24 hours. You'll receive compensation points for significant delays.
                    </div>
                </div>
            </div>
        </div>

        <!-- Support Channels -->
        <div class="help-card">
            <h2 class="section-title">Support Channels</h2>
            <div class="support-channels">
                <div class="channel-card">
                    <div class="channel-icon">
                        <i class="fas fa-comments"></i>
                    </div>
                    <div class="status-indicator status-online">
                        <span class="status-dot"></span>
                        <span>Live Chat Available</span>
                    </div>
                    <h3 class="channel-title">Live Chat</h3>
                    <p class="channel-info">Instant help from our support team. Average response time: 2 minutes</p>
                    <a href="javascript:void(0)" class="channel-action" onclick="startLiveChat()">
                        Start Chat <i class="fas fa-arrow-right"></i>
                    </a>
                </div>
                
                <div class="channel-card">
                    <div class="channel-icon">
                        <i class="fas fa-phone"></i>
                    </div>
                    <div class="status-indicator status-online">
                        <span class="status-dot"></span>
                        <span>Available Now</span>
                    </div>
                    <h3 class="channel-title">Phone Support</h3>
                    <p class="channel-info">Call us directly for immediate assistance</p>
                    <a href="tel:+1234567890" class="channel-action">
                        +1 (234) 567-890 <i class="fas fa-phone"></i>
                    </a>
                </div>
                
                <div class="channel-card">
                    <div class="channel-icon">
                        <i class="fas fa-envelope"></i>
                    </div>
                    <h3 class="channel-title">Email Support</h3>
                    <p class="channel-info">Send us a detailed message and we'll respond within 4 hours</p>
                    <a href="mailto:support@soorgreen.com" class="channel-action">
                        support@soorgreen.com <i class="fas fa-envelope"></i>
                    </a>
                </div>
                
                <div class="channel-card">
                    <div class="channel-icon">
                        <i class="fas fa-file-alt"></i>
                    </div>
                    <h3 class="channel-title">Knowledge Base</h3>
                    <p class="channel-info">Browse our comprehensive documentation and tutorials</p>
                    <a href="javascript:void(0)" class="channel-action" onclick="showToast('Knowledge Base', 'Opening knowledge base...', 'info')">
                        Browse Articles <i class="fas fa-external-link-alt"></i>
                    </a>
                </div>
            </div>
        </div>

        <!-- Contact Form -->
        <div class="help-card">
            <h2 class="section-title" id="contact">Contact Support Team</h2>
            <div class="contact-form">
                <div class="form-group">
                    <label class="form-label">Full Name</label>
                    <asp:TextBox ID="txtFullName" runat="server" CssClass="form-control" placeholder="Enter your full name"></asp:TextBox>
                </div>
                
                <div class="form-group">
                    <label class="form-label">Email Address</label>
                    <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control" TextMode="Email" placeholder="your.email@example.com"></asp:TextBox>
                </div>
                
                <div class="form-group">
                    <label class="form-label">Issue Type</label>
                    <asp:DropDownList ID="ddlIssueType" runat="server" CssClass="form-select">
                        <asp:ListItem Value="">Select issue type</asp:ListItem>
                        <asp:ListItem Value="technical">Technical Issue</asp:ListItem>
                        <asp:ListItem Value="pickup">Pickup Problem</asp:ListItem>
                        <asp:ListItem Value="rewards">Rewards & Points</asp:ListItem>
                        <asp:ListItem Value="account">Account Issue</asp:ListItem>
                        <asp:ListItem Value="feedback">Feedback & Suggestion</asp:ListItem>
                        <asp:ListItem Value="other">Other</asp:ListItem>
                    </asp:DropDownList>
                </div>
                
                <div class="form-group">
                    <label class="form-label">Priority</label>
                    <asp:DropDownList ID="ddlPriority" runat="server" CssClass="form-select">
                        <asp:ListItem Value="low">Low - General Inquiry</asp:ListItem>
                        <asp:ListItem Value="medium">Medium - Need Help</asp:ListItem>
                        <asp:ListItem Value="high">High - Urgent Issue</asp:ListItem>
                        <asp:ListItem Value="critical">Critical - System Down</asp:ListItem>
                    </asp:DropDownList>
                </div>
                
                <div class="form-group">
                    <label class="form-label">Description</label>
                    <asp:TextBox ID="txtDescription" runat="server" CssClass="form-control" TextMode="MultiLine" 
                        Rows="6" placeholder="Please describe your issue in detail. Include any error messages, steps to reproduce, and what you were trying to accomplish."></asp:TextBox>
                </div>
                
                <div class="form-group">
                    <label class="form-label">
                        <asp:CheckBox ID="cbAttachScreenshot" runat="server" /> 
                        I can attach screenshots if needed
                    </label>
                </div>
                
                <asp:Button ID="btnSubmitTicket" runat="server" Text="Submit Support Ticket" CssClass="btn-primary" OnClick="btnSubmitTicket_Click" />
            </div>
        </div>
    </div>

</asp:Content>