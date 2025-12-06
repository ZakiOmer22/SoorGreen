<%@ Page Title="Feedback Management" Language="C#" MasterPageFile="~/Pages/Admin/Site.master" AutoEventWireup="true" CodeFile="Feedbacks.aspx.cs" Inherits="SoorGreen.Admin.Admin.Feedbacks" %>

<asp:Content ID="Content3" ContentPlaceHolderID="HeadContent" runat="server">
    <link href='<%= ResolveUrl("~/Content/Pages/Admin/admincitizens.css") %>' rel="stylesheet" />
    <link href='<%= ResolveUrl("~/Content/Pages/Admin/adminfeedbacks.css") %>' rel="stylesheet" />
</asp:Content>

<asp:Content ID="PageTitle" ContentPlaceHolderID="PageTitle" runat="server">
    <div class="d-flex align-items-center">
        <h1 class="h3 mb-0 text-primary">Feedback Management</h1>
        <span class="badge bg-secondary ms-3">Citizen Feedback System</span>
    </div>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <!-- Message Panel -->
    <asp:Panel ID="pnlMessage" runat="server" CssClass="message-panel" Visible="false">
        <div class='message-alert' id="divMessage" runat="server">
            <i class='fas' id="iconMessage" runat="server"></i>
            <div>
                <strong><asp:Literal ID="litMessageTitle" runat="server"></asp:Literal></strong>
                <p class="mb-0"><asp:Literal ID="litMessageText" runat="server"></asp:Literal></p>
            </div>
        </div>
    </asp:Panel>

    <!-- Feedback Details Modal -->
    <div class="modal fade" id="feedbackDetailsModal" tabindex="-1" role="dialog" aria-hidden="true">
        <div class="modal-dialog modal-lg" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title text-primary">
                        <i class="fas fa-comment-dots me-2"></i>
                        <span id="modalTitle">Feedback Details</span>
                    </h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <asp:HiddenField ID="hdnFeedbackId" runat="server" />
                    
                    <div class="row mb-3">
                        <div class="col-md-6">
                            <div class="mb-3">
                                <label class="form-label text-primary"><i class="fas fa-hashtag me-2"></i>Feedback ID</label>
                                <asp:TextBox ID="txtFeedbackId" runat="server" CssClass="form-control" ReadOnly="true"></asp:TextBox>
                            </div>
                            
                            <div class="mb-3">
                                <label class="form-label text-primary"><i class="fas fa-user me-2"></i>Submitted By</label>
                                <asp:TextBox ID="txtUserName" runat="server" CssClass="form-control" ReadOnly="true"></asp:TextBox>
                            </div>
                            
                            <div class="mb-3">
                                <label class="form-label text-primary"><i class="fas fa-tag me-2"></i>Category</label>
                                <asp:TextBox ID="txtCategory" runat="server" CssClass="form-control" ReadOnly="true"></asp:TextBox>
                            </div>
                        </div>
                        
                        <div class="col-md-6">
                            <div class="mb-3">
                                <label class="form-label text-primary"><i class="fas fa-flag me-2"></i>Priority</label>
                                <asp:TextBox ID="txtPriority" runat="server" CssClass="form-control" ReadOnly="true"></asp:TextBox>
                            </div>
                            
                            <div class="mb-3">
                                <label class="form-label text-primary"><i class="fas fa-star me-2"></i>Rating</label>
                                <div class="d-flex align-items-center">
                                    <asp:TextBox ID="txtRating" runat="server" CssClass="form-control me-2" ReadOnly="true" Style="width: auto;"></asp:TextBox>
                                    <div class="rating-stars" id="ratingStars"></div>
                                </div>
                            </div>
                            
                            <div class="mb-3">
                                <label class="form-label text-primary"><i class="fas fa-calendar me-2"></i>Submitted Date</label>
                                <asp:TextBox ID="txtSubmittedDate" runat="server" CssClass="form-control" ReadOnly="true"></asp:TextBox>
                            </div>
                        </div>
                    </div>
                    
                    <!-- Subject -->
                    <div class="mb-3">
                        <label class="form-label text-primary"><i class="fas fa-heading me-2"></i>Subject</label>
                        <asp:TextBox ID="txtSubject" runat="server" CssClass="form-control" ReadOnly="true"></asp:TextBox>
                    </div>
                    
                    <!-- Message -->
                    <div class="mb-3">
                        <label class="form-label text-primary"><i class="fas fa-comment me-2"></i>Message</label>
                        <asp:TextBox ID="txtMessage" runat="server" CssClass="form-control" 
                            TextMode="MultiLine" Rows="6" ReadOnly="true"></asp:TextBox>
                    </div>
                    
                    <!-- Response Section (Admin Only) -->
                    <div class="mb-3" id="responseSection" runat="server">
                        <label class="form-label text-primary"><i class="fas fa-reply me-2"></i>Admin Response</label>
                        <asp:TextBox ID="txtAdminResponse" runat="server" CssClass="form-control" 
                            TextMode="MultiLine" Rows="4" placeholder="Enter your response here..."></asp:TextBox>
                    </div>
                    
                    <!-- Status Update -->
                    <div class="mb-3" id="statusSection" runat="server">
                        <label class="form-label text-primary"><i class="fas fa-sync-alt me-2"></i>Update Status</label>
                        <asp:DropDownList ID="ddlStatus" runat="server" CssClass="form-control">
                            <asp:ListItem Value="Open">Open</asp:ListItem>
                            <asp:ListItem Value="In Progress">In Progress</asp:ListItem>
                            <asp:ListItem Value="Resolved">Resolved</asp:ListItem>
                            <asp:ListItem Value="Closed">Closed</asp:ListItem>
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                    <asp:Button ID="btnSaveResponse" runat="server" CssClass="btn btn-primary" 
                        Text="Save Response" OnClick="btnSaveResponse_Click" Visible="false" />
                    <asp:Button ID="btnDeleteFeedback" runat="server" CssClass="btn btn-danger" 
                        Text="Delete Feedback" OnClick="btnDeleteFeedback_Click" Visible="false"
                        OnClientClick="return confirm('Are you sure you want to delete this feedback? This action cannot be undone.');" />
                </div>
            </div>
        </div>
    </div>

    <div class="users-container">
        <!-- Filter Card -->
        <div class="filter-card">
            <h5 class="mb-4 text-primary"><i class="fas fa-sliders-h me-2"></i>Filter Feedback</h5>
            <div class="filter-group">
                <div class="form-group search-box">
                    <label class="form-label text-primary"><i class="fas fa-search me-2"></i>Search Feedback</label>
                    <div class="position-relative">
                        <i class="fas fa-search search-icon"></i>
                        <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control search-input" 
                            placeholder="Search by subject, message, user..."></asp:TextBox>
                    </div>
                </div>
                
                <div class="form-group">
                    <label class="form-label text-primary"><i class="fas fa-tag me-2"></i>Category</label>
                    <div class="select-with-icon">
                        <asp:DropDownList ID="ddlCategory" runat="server" CssClass="form-control">
                            <asp:ListItem Value="all">All Categories</asp:ListItem>
                            <asp:ListItem Value="General">General</asp:ListItem>
                            <asp:ListItem Value="Technical">Technical</asp:ListItem>
                            <asp:ListItem Value="Feature Request">Feature Request</asp:ListItem>
                            <asp:ListItem Value="Bug Report">Bug Report</asp:ListItem>
                            <asp:ListItem Value="Complaint">Complaint</asp:ListItem>
                            <asp:ListItem Value="Suggestion">Suggestion</asp:ListItem>
                        </asp:DropDownList>
                        <i class="fas fa-chevron-down select-arrow"></i>
                    </div>
                </div>
                
                <div class="form-group">
                    <label class="form-label text-primary"><i class="fas fa-flag me-2"></i>Priority</label>
                    <div class="select-with-icon">
                        <asp:DropDownList ID="ddlPriority" runat="server" CssClass="form-control">
                            <asp:ListItem Value="all">All Priorities</asp:ListItem>
                            <asp:ListItem Value="High">High</asp:ListItem>
                            <asp:ListItem Value="Medium">Medium</asp:ListItem>
                            <asp:ListItem Value="Low">Low</asp:ListItem>
                        </asp:DropDownList>
                        <i class="fas fa-chevron-down select-arrow"></i>
                    </div>
                </div>
                
                <div class="form-group">
                    <label class="form-label text-primary"><i class="fas fa-user me-2"></i>Submitted By</label>
                    <div class="select-with-icon">
                        <asp:DropDownList ID="ddlUser" runat="server" CssClass="form-control">
                            <asp:ListItem Value="all">All Users</asp:ListItem>
                        </asp:DropDownList>
                        <i class="fas fa-chevron-down select-arrow"></i>
                    </div>
                </div>
                
                <div class="form-group">
                    <label class="form-label" style="visibility: hidden;">Action</label>
                    <button type="button" class="btn btn-primary btn-with-icon" onclick="__doPostBack('ctl00$MainContent$btnApplyFilters', '')">
                        <i class="fas fa-filter me-2"></i>Apply Filters
                    </button>
                    <asp:Button ID="btnApplyFilters" runat="server" Style="display: none;" OnClick="btnApplyFilters_Click" />
                </div>
            </div>
            
            <!-- Quick Filters -->
            <div class="mt-4">
                <h6 class="mb-3 text-primary"><i class="fas fa-bolt me-2"></i>Quick Filters</h6>
                <div class="d-flex flex-wrap gap-2">
                    <button type="button" class="action-filter-btn" onclick="filterPriority('High')">
                        <i class="fas fa-exclamation-circle"></i> High Priority
                    </button>
                    <button type="button" class="action-filter-btn" onclick="filterStatus('Open')">
                        <i class="fas fa-clock"></i> Open
                    </button>
                    <button type="button" class="action-filter-btn" onclick="filterCategory('Bug Report')">
                        <i class="fas fa-bug"></i> Bug Reports
                    </button>
                    <button type="button" class="action-filter-btn" onclick="showToday()">
                        <i class="fas fa-calendar-day"></i> Today
                    </button>
                    <button type="button" class="action-filter-btn" onclick="filterRating('5')">
                        <i class="fas fa-star"></i> 5 Stars
                    </button>
                </div>
            </div>
        </div>

        <!-- Stats Cards -->
        <div class="d-flex gap-3 mb-4 flex-wrap">
            <div class="stats-card users" style="flex: 1; min-width: 200px;">
                <div class="stats-icon">
                    <i class="fas fa-comments"></i>
                </div>
                <div class="stats-number text-primary" id="statTotalFeedbacks" runat="server">0</div>
                <div class="stats-label text-primary">Total Feedbacks</div>
            </div>
            <div class="stats-card active" style="flex: 1; min-width: 200px;">
                <div class="stats-icon">
                    <i class="fas fa-exclamation-circle"></i>
                </div>
                <div class="stats-number text-danger" id="statHighPriority" runat="server">0</div>
                <div class="stats-label text-primary">High Priority</div>
            </div>
            <div class="stats-card pickups" style="flex: 1; min-width: 200px;">
                <div class="stats-icon">
                    <i class="fas fa-clock"></i>
                </div>
                <div class="stats-number text-warning" id="statOpenFeedbacks" runat="server">0</div>
                <div class="stats-label text-primary">Open</div>
            </div>
            <div class="stats-card waste" style="flex: 1; min-width: 200px;">
                <div class="stats-icon">
                    <i class="fas fa-star"></i>
                </div>
                <div class="stats-number text-success" id="statAvgRating" runat="server">0.0</div>
                <div class="stats-label text-primary">Avg Rating</div>
            </div>
        </div>

        <!-- Quick Actions -->
        <div class="filter-card mb-4">
            <h5 class="mb-4 text-primary"><i class="fas fa-cogs me-2"></i>Quick Actions</h5>
            <div class="d-flex flex-wrap gap-3">
                <button type="button" class="btn btn-primary btn-with-icon" onclick="__doPostBack('ctl00$MainContent$btnExportCSV', '')">
                    <i class="fas fa-file-export me-2"></i>Export CSV
                </button>
                <button type="button" class="btn btn-success btn-with-icon" onclick="__doPostBack('ctl00$MainContent$btnRefresh', '')">
                    <i class="fas fa-sync-alt me-2"></i>Refresh
                </button>
                <button type="button" class="btn btn-info btn-with-icon" onclick="showAllFeedbacks()">
                    <i class="fas fa-list me-2"></i>View All
                </button>
                <button type="button" class="btn btn-warning btn-with-icon" onclick="showUnresponded()">
                    <i class="fas fa-comment-slash me-2"></i>Unresponded
                </button>
                <asp:Button ID="btnExportCSV" runat="server" Style="display: none;" OnClick="btnExportCSV_Click" />
                <asp:Button ID="btnRefresh" runat="server" Style="display: none;" OnClick="btnRefresh_Click" />
            </div>
        </div>

        <!-- View Controls -->
        <div class="view-controls">
            <div class="d-flex align-items-center gap-3 flex-wrap">
                <div class="view-options">
                    <asp:LinkButton ID="btnGridView" runat="server" CssClass="view-btn active" 
                        OnClick="btnGridView_Click" CausesValidation="false">
                        <i class="fas fa-th-large me-2"></i>Card View
                    </asp:LinkButton>
                    <asp:LinkButton ID="btnTableView" runat="server" CssClass="view-btn" 
                        OnClick="btnTableView_Click" CausesValidation="false">
                        <i class="fas fa-table me-2"></i>Table View
                    </asp:LinkButton>
                </div>
                <div class="page-info">
                    <i class="fas fa-comments me-2"></i>
                    Showing <asp:Label ID="lblFeedbackCount" runat="server" Text="0" CssClass="text-primary"></asp:Label> feedback entries
                </div>
            </div>
            <div class="d-flex gap-2">
                <button type="button" class="btn btn-secondary btn-with-icon" onclick="__doPostBack('ctl00$MainContent$btnClearFilters', '')">
                    <i class="fas fa-times me-2"></i>Clear Filters
                </button>
                <asp:Button ID="btnClearFilters" runat="server" Style="display: none;" OnClick="btnClearFilters_Click" />
            </div>
        </div>

        <!-- Card View -->
        <asp:Panel ID="pnlCardView" runat="server" CssClass="users-grid">
            <asp:Repeater ID="rptFeedbacks" runat="server" OnItemDataBound="rptFeedbacks_ItemDataBound">
                <ItemTemplate>
                    <div class="feedback-card <%# GetPriorityCardClass(Eval("Priority").ToString()) %>">
                        <div class="d-flex justify-content-between align-items-start mb-2">
                            <div class="d-flex align-items-center">
                                <div class="feedback-icon bg-primary text-white">
                                    <i class="fas <%# GetCategoryIcon(Eval("Category").ToString()) %>"></i>
                                </div>
                                <div>
                                    <h6 class="mb-0 text-primary"><%# Eval("Subject") %></h6>
                                    <small class="text-muted">
                                        <i class="fas fa-user me-1"></i><%# Eval("FullName", "{0}") %>
                                        <i class="fas fa-clock ms-2 me-1"></i><%# GetFormattedDateTime(Eval("CreatedAt")) %>
                                    </small>
                                </div>
                            </div>
                            <span class="badge <%# GetPriorityBadgeClass(Eval("Priority").ToString()) %> priority-badge">
                                <%# Eval("Priority") %>
                            </span>
                        </div>
                        
                        <div class="mb-2">
                            <small class="text-muted">
                                <i class="fas fa-hashtag me-1"></i>ID: <%# Eval("FeedbackId") %>
                                <i class="fas fa-tag ms-2 me-1"></i><%# Eval("Category") %>
                                <i class="fas fa-star ms-2 me-1"></i>
                                <span class="rating-stars">
                                    <%# GetRatingStars(Convert.ToInt32(Eval("Rating"))) %>
                                </span>
                            </small>
                        </div>
                        
                        <div class="mb-3">
                            <p class="mb-1 text-primary"><strong>Message:</strong></p>
                            <p class="mb-0 text-primary"><%# TruncateText(Eval("Message").ToString(), 120) %></p>
                        </div>
                        
                        <div class="feedback-details">
                            <p class="mb-0 text-primary"><%# Eval("Message") %></p>
                        </div>
                        
                        <div class="feedback-meta">
                            
                            <div class="meta-item">
                                <i class="fas fa-calendar"></i>
                                <span class="text-muted"><%# GetFormattedDate(Eval("CreatedAt")) %></span>
                            </div>
                            
                        </div>
                        
                        <div class="d-flex justify-content-between align-items-center mt-3">
                            <div>
                                <small class="text-muted">
                                    <%# GetDaysAgo(Eval("CreatedAt")) %>
                                </small>
                            </div>
                            <div class="action-buttons">
                                <button type="button" class="btn btn-sm btn-info" onclick='viewFeedbackDetails("<%# Eval("FeedbackId") %>")'>
                                    <i class="fas fa-eye"></i> View
                                </button>
                                <button type="button" class="btn btn-sm btn-success" onclick='markAsResolved("<%# Eval("FeedbackId") %>")'>
                                    <i class="fas fa-check"></i> Resolve
                                </button>
                                <button type="button" class="btn btn-sm btn-danger" onclick='deleteFeedback("<%# Eval("FeedbackId") %>", "<%# Eval("Subject") %>")'>
                                    <i class="fas fa-trash"></i> Delete
                                </button>
                            </div>
                        </div>
                    </div>
                </ItemTemplate>
                <FooterTemplate>
                    <asp:Label ID="lblEmptyGrid" runat="server" Text="No feedback found" 
                        Visible='<%# rptFeedbacks.Items.Count == 0 %>' CssClass="empty-state">
                        <i class="fas fa-comments"></i>
                        <p class="text-primary">No feedback matching your criteria</p>
                    </asp:Label>
                </FooterTemplate>
            </asp:Repeater>
        </asp:Panel>

        <!-- Table View -->
        <asp:Panel ID="pnlTableView" runat="server" CssClass="table-container" Visible="false">
            <div class="table-responsive">
                <asp:GridView ID="gvFeedbacks" runat="server" AutoGenerateColumns="False" 
                    CssClass="users-table feedback-table" 
                    EmptyDataText="No feedback found" ShowHeaderWhenEmpty="true">
                    <Columns>
                        <asp:TemplateField HeaderText="Feedback Details">
                            <ItemTemplate>
                                <div class="d-flex align-items-center">
                                    <div class="feedback-icon bg-primary text-white me-2" style="width: 30px; height: 30px;">
                                        <i class="fas <%# GetCategoryIcon(Eval("Category").ToString()) %>"></i>
                                    </div>
                                    <div>
                                        <strong class="text-primary d-block"><%# Eval("Subject") %></strong>
                                        <small class="text-muted d-block">
                                            <i class="fas fa-user me-1"></i><%# Eval("FullName", "{0}") %>
                                        </small>
                                        <small class="text-muted">
                                            <i class="fas fa-hashtag me-1"></i><%# Eval("FeedbackId") %>
                                        </small>
                                    </div>
                                </div>
                            </ItemTemplate>
                        </asp:TemplateField>
                        
                        <asp:TemplateField HeaderText="Category & Priority">
                            <ItemTemplate>
                                <div>
                                    <span class="badge <%# GetPriorityBadgeClass(Eval("Priority").ToString()) %> mb-1">
                                        <%# Eval("Priority") %>
                                    </span>
                                    <div class="small text-muted">
                                        <i class="fas fa-tag me-1"></i><%# Eval("Category") %>
                                    </div>
                                    <div class="rating-stars small">
                                        <%# GetRatingStars(Convert.ToInt32(Eval("Rating"))) %>
                                    </div>
                                </div>
                            </ItemTemplate>
                        </asp:TemplateField>
                        
                        <asp:TemplateField HeaderText="Message">
                            <ItemTemplate>
                                <div class="text-primary" style="max-height: 80px; overflow: hidden;">
                                    <%# TruncateText(Eval("Message").ToString(), 80) %>
                                </div>
                            </ItemTemplate>
                        </asp:TemplateField>
                        
                        
                        <asp:TemplateField HeaderText="Actions">
                            <ItemTemplate>
                                <div class="d-flex flex-wrap gap-2">
                                    <button type="button" class="btn btn-info btn-sm" onclick='viewFeedbackDetails("<%# Eval("FeedbackId") %>")'>
                                        <i class="fas fa-eye"></i>
                                    </button>
                                    <button type="button" class="btn btn-success btn-sm" onclick='markAsResolved("<%# Eval("FeedbackId") %>")'>
                                        <i class="fas fa-check"></i>
                                    </button>
                                    <button type="button" class="btn btn-danger btn-sm" onclick='deleteFeedback("<%# Eval("FeedbackId") %>", "<%# Eval("Subject") %>")'>
                                        <i class="fas fa-trash"></i>
                                    </button>
                                </div>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                    <EmptyDataTemplate>
                        <div class="empty-state" style="margin: 2rem;">
                            <i class="fas fa-comments"></i>
                            <p class="text-primary">No feedback found matching your criteria</p>
                        </div>
                    </EmptyDataTemplate>
                </asp:GridView>
            </div>
        </asp:Panel>
    </div>

    <!-- JavaScript functions -->
    <script>
    function viewFeedbackDetails(feedbackId) {
        __doPostBack('ctl00$MainContent$hdnSelectedFeedback', 'view_' + feedbackId);
    }
    
    function markAsResolved(feedbackId) {
        if (confirm('Are you sure you want to mark this feedback as resolved?')) {
            __doPostBack('ctl00$MainContent$hdnSelectedFeedback', 'resolve_' + feedbackId);
        }
    }
    
    function deleteFeedback(feedbackId, subject) {
        if (confirm('Are you sure you want to delete the feedback "' + subject + '"? This action cannot be undone.')) {
            __doPostBack('ctl00$MainContent$hdnSelectedFeedback', 'delete_' + feedbackId);
        }
    }
    
    function filterPriority(priority) {
        document.getElementById('<%= ddlPriority.ClientID %>').value = priority;
        __doPostBack('ctl00$MainContent$btnApplyFilters', '');
        
        // Update active filter button
        document.querySelectorAll('.action-filter-btn').forEach(btn => {
            btn.classList.remove('active');
        });
        event.target.classList.add('active');
    }
    
    function filterStatus(status) {
        // Add status filter if needed
        __doPostBack('ctl00$MainContent$btnApplyFilters', '');
    }
    
    function filterCategory(category) {
        document.getElementById('<%= ddlCategory.ClientID %>').value = category;
        __doPostBack('ctl00$MainContent$btnApplyFilters', '');
        
        // Update active filter button
        document.querySelectorAll('.action-filter-btn').forEach(btn => {
            btn.classList.remove('active');
        });
        event.target.classList.add('active');
    }
    
    function filterRating(rating) {
        // Add rating filter if needed
        __doPostBack('ctl00$MainContent$btnApplyFilters', '');
    }
    
    function showToday() {
        var today = new Date().toISOString().split('T')[0];
        // Add date filter if needed
        __doPostBack('ctl00$MainContent$btnApplyFilters', '');
    }
    
    function showAllFeedbacks() {
        document.getElementById('<%= ddlCategory.ClientID %>').value = 'all';
        document.getElementById('<%= ddlPriority.ClientID %>').value = 'all';
        document.getElementById('<%= ddlUser.ClientID %>').value = 'all';
        document.getElementById('<%= txtSearch.ClientID %>').value = '';
        __doPostBack('ctl00$MainContent$btnApplyFilters', '');
    }
    
    function showUnresponded() {
        // Add unresponded filter if needed
        __doPostBack('ctl00$MainContent$btnApplyFilters', '');
    }
    
    // Update rating stars in modal
    function updateRatingStars(rating) {
        var stars = document.getElementById('ratingStars');
        if (stars) {
            var html = '';
            for (var i = 1; i <= 5; i++) {
                if (i <= rating) {
                    html += '<i class="fas fa-star"></i>';
                } else {
                    html += '<i class="far fa-star"></i>';
                }
            }
            stars.innerHTML = html;
        }
    }
    
    // Initialize date fields with default range
    document.addEventListener('DOMContentLoaded', function() {
        // Ensure all text is visible
        document.querySelectorAll('.text-primary, .text-secondary, .text-muted').forEach(el => {
            el.style.color = getComputedStyle(el).color;
        });
        
        // Set modal rating when shown
        var modal = document.getElementById('feedbackDetailsModal');
        if (modal) {
            modal.addEventListener('shown.bs.modal', function() {
                var rating = document.getElementById('<%= txtRating.ClientID %>').value;
                if (rating) {
                    updateRatingStars(parseInt(rating));
                }
            });
        }
    });
    </script>
    
    <asp:HiddenField ID="hdnSelectedFeedback" runat="server" />
</asp:Content>