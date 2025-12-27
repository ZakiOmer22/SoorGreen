<%@ Page Title="Notifications Management" Language="C#" MasterPageFile="~/Pages/Admin/Site.master" AutoEventWireup="true" Inherits="SoorGreen.Admin.Admin.NotificationsMgmt" Codebehind="NotificationsMgmt.aspx.cs" %>

<asp:Content ID="Content3" ContentPlaceHolderID="HeadContent" runat="server">
    <link href='<%= ResolveUrl("~/Content/Pages/Admin/admincitizens.css") %>' rel="stylesheet" />
    <link href='<%= ResolveUrl("~/Content/Pages/Admin/adminnotificationsmgmt.css") %>' rel="stylesheet" />
</asp:Content>

<asp:Content ID="PageTitle" ContentPlaceHolderID="PageTitle" runat="server">
    <div class="d-flex align-items-center">
        <h1 class="h3 mb-0 text-primary">Notifications Management</h1>
        <span class="badge bg-secondary ms-3">System Notifications</span>
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

    <!-- Send Notification Modal -->
    <div class="modal fade" id="sendNotificationModal" tabindex="-1" role="dialog" aria-hidden="true">
        <div class="modal-dialog modal-lg" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title text-primary">
                        <i class="fas fa-bell me-2"></i>
                        Send New Notification
                    </h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <div class="row mb-3">
                        <div class="col-md-6">
                            <div class="mb-3">
                                <label class="form-label text-primary"><i class="fas fa-heading me-2"></i>Title *</label>
                                <asp:TextBox ID="txtNotificationTitle" runat="server" CssClass="form-control" 
                                    placeholder="Enter notification title" MaxLength="200"></asp:TextBox>
                                <asp:RequiredFieldValidator ID="rfvTitle" runat="server" ControlToValidate="txtNotificationTitle"
                                    ErrorMessage="Title is required" CssClass="text-danger small" Display="Dynamic"></asp:RequiredFieldValidator>
                            </div>
                            
                            <div class="mb-3">
                                <label class="form-label text-primary"><i class="fas fa-tag me-2"></i>Type</label>
                                <asp:DropDownList ID="ddlNotificationType" runat="server" CssClass="form-control">
                                    <asp:ListItem Value="Info">Information</asp:ListItem>
                                    <asp:ListItem Value="Success">Success</asp:ListItem>
                                    <asp:ListItem Value="Warning">Warning</asp:ListItem>
                                    <asp:ListItem Value="Error">Error</asp:ListItem>
                                    <asp:ListItem Value="System">System</asp:ListItem>
                                    <asp:ListItem Value="Announcement">Announcement</asp:ListItem>
                                    <asp:ListItem Value="Promotion">Promotion</asp:ListItem>
                                </asp:DropDownList>
                            </div>
                        </div>
                        
                        <div class="col-md-6">
                            <div class="mb-3">
                                <label class="form-label text-primary"><i class="fas fa-users me-2"></i>Recipient Type *</label>
                                <asp:DropDownList ID="ddlRecipientType" runat="server" CssClass="form-control" AutoPostBack="true"
                                    OnSelectedIndexChanged="ddlRecipientType_SelectedIndexChanged">
                                    <asp:ListItem Value="All">All Users</asp:ListItem>
                                    <asp:ListItem Value="Specific">Specific User</asp:ListItem>
                                    <asp:ListItem Value="Role">User Role</asp:ListItem>
                                    <asp:ListItem Value="Unread">Users with Unread</asp:ListItem>
                                </asp:DropDownList>
                            </div>
                            
                            <div class="mb-3" id="specificUserSection" runat="server" visible="false">
                                <label class="form-label text-primary"><i class="fas fa-user me-2"></i>Select User</label>
                                <div class="select-with-icon">
                                    <asp:DropDownList ID="ddlSpecificUser" runat="server" CssClass="form-control">
                                    </asp:DropDownList>
                                    <i class="fas fa-chevron-down select-arrow"></i>
                                </div>
                            </div>
                            
                            <div class="mb-3" id="roleSection" runat="server" visible="false">
                                <label class="form-label text-primary"><i class="fas fa-user-tag me-2"></i>Select Role</label>
                                <div class="select-with-icon">
                                    <asp:DropDownList ID="ddlUserRole" runat="server" CssClass="form-control">
                                    </asp:DropDownList>
                                    <i class="fas fa-chevron-down select-arrow"></i>
                                </div>
                            </div>
                        </div>
                    </div>
                    
                    <!-- Message -->
                    <div class="mb-3">
                        <label class="form-label text-primary"><i class="fas fa-comment me-2"></i>Message *</label>
                        <asp:TextBox ID="txtNotificationMessage" runat="server" CssClass="form-control" 
                            TextMode="MultiLine" Rows="6" placeholder="Enter notification message..."
                            MaxLength="1000"></asp:TextBox>
                        <asp:RequiredFieldValidator ID="rfvMessage" runat="server" ControlToValidate="txtNotificationMessage"
                            ErrorMessage="Message is required" CssClass="text-danger small" Display="Dynamic"></asp:RequiredFieldValidator>
                        <small class="text-muted">Maximum 1000 characters</small>
                    </div>
                    
                    <!-- Additional Options -->
                    <div class="mb-3">
                        <label class="form-label text-primary"><i class="fas fa-cogs me-2"></i>Options</label>
                        <div class="form-check">
                            <asp:CheckBox ID="chkImportant" runat="server" CssClass="form-check-input" />
                            <label class="form-check-label text-primary" for="<%= chkImportant.ClientID %>">
                                Mark as Important
                            </label>
                        </div>
                        <div class="form-check">
                            <asp:CheckBox ID="chkRequireAck" runat="server" CssClass="form-check-input" />
                            <label class="form-check-label text-primary" for="<%= chkRequireAck.ClientID %>">
                                Require Acknowledgment
                            </label>
                        </div>
                        <div class="form-check">
                            <asp:CheckBox ID="chkSendEmail" runat="server" CssClass="form-check-input" />
                            <label class="form-check-label text-primary" for="<%= chkSendEmail.ClientID %>">
                                Send Email Copy
                            </label>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <asp:Button ID="btnSendNotification" runat="server" CssClass="btn btn-primary" 
                        Text="Send Notification" OnClick="btnSendNotification_Click" />
                    <asp:Button ID="btnSaveDraft" runat="server" CssClass="btn btn-outline-primary" 
                        Text="Save as Draft" OnClick="btnSaveDraft_Click" />
                </div>
            </div>
        </div>
    </div>

    <!-- Notification Details Modal -->
    <div class="modal fade" id="notificationDetailsModal" tabindex="-1" role="dialog" aria-hidden="true">
        <div class="modal-dialog modal-lg" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title text-primary">
                        <i class="fas fa-bell me-2"></i>
                        Notification Details
                    </h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <asp:HiddenField ID="hdnNotificationId" runat="server" />
                    
                    <div class="row mb-3">
                        <div class="col-md-6">
                            <div class="mb-3">
                                <label class="form-label text-primary"><i class="fas fa-hashtag me-2"></i>Notification ID</label>
                                <asp:TextBox ID="txtDetailId" runat="server" CssClass="form-control" ReadOnly="true"></asp:TextBox>
                            </div>
                            
                            <div class="mb-3">
                                <label class="form-label text-primary"><i class="fas fa-heading me-2"></i>Title</label>
                                <asp:TextBox ID="txtDetailTitle" runat="server" CssClass="form-control" ReadOnly="true"></asp:TextBox>
                            </div>
                            
                            <div class="mb-3">
                                <label class="form-label text-primary"><i class="fas fa-tag me-2"></i>Type</label>
                                <asp:TextBox ID="txtDetailType" runat="server" CssClass="form-control" ReadOnly="true"></asp:TextBox>
                            </div>
                        </div>
                        
                        <div class="col-md-6">
                            <div class="mb-3">
                                <label class="form-label text-primary"><i class="fas fa-user me-2"></i>Recipient</label>
                                <asp:TextBox ID="txtDetailRecipient" runat="server" CssClass="form-control" ReadOnly="true"></asp:TextBox>
                            </div>
                            
                            <div class="mb-3">
                                <label class="form-label text-primary"><i class="fas fa-eye me-2"></i>Status</label>
                                <asp:TextBox ID="txtDetailStatus" runat="server" CssClass="form-control" ReadOnly="true"></asp:TextBox>
                            </div>
                            
                            <div class="mb-3">
                                <label class="form-label text-primary"><i class="fas fa-calendar me-2"></i>Sent Date</label>
                                <asp:TextBox ID="txtDetailSentDate" runat="server" CssClass="form-control" ReadOnly="true"></asp:TextBox>
                            </div>
                        </div>
                    </div>
                    
                    <!-- Message -->
                    <div class="mb-3">
                        <label class="form-label text-primary"><i class="fas fa-comment me-2"></i>Message</label>
                        <asp:TextBox ID="txtDetailMessage" runat="server" CssClass="form-control" 
                            TextMode="MultiLine" Rows="6" ReadOnly="true"></asp:TextBox>
                    </div>
                    
                    <!-- Read Status -->
                    <div class="mb-3">
                        <label class="form-label text-primary"><i class="fas fa-history me-2"></i>Read Status</label>
                        <asp:GridView ID="gvReadStatus" runat="server" AutoGenerateColumns="False" 
                            CssClass="table table-sm" ShowHeaderWhenEmpty="true" EmptyDataText="No read status available">
                            <Columns>
                                <asp:BoundField DataField="UserName" HeaderText="User" />
                                <asp:BoundField DataField="ReadDate" HeaderText="Read Date" />
                                <asp:BoundField DataField="Acknowledged" HeaderText="Acknowledged" />
                            </Columns>
                        </asp:GridView>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                    <asp:Button ID="btnDeleteNotification" runat="server" CssClass="btn btn-danger" 
                        Text="Delete Notification" OnClick="btnDeleteNotification_Click" 
                        OnClientClick="return confirm('Are you sure you want to delete this notification? This action cannot be undone.');" />
                    <asp:Button ID="btnMarkAllRead" runat="server" CssClass="btn btn-success" 
                        Text="Mark All as Read" OnClick="btnMarkAllRead_Click" />
                </div>
            </div>
        </div>
    </div>

    <div class="users-container">
        <!-- Filter Card -->
        <div class="filter-card">
            <h5 class="mb-4 text-primary"><i class="fas fa-sliders-h me-2"></i>Filter Notifications</h5>
            <div class="filter-group">
                <div class="form-group search-box">
                    <label class="form-label text-primary"><i class="fas fa-search me-2"></i>Search Notifications</label>
                    <div class="position-relative">
                        <i class="fas fa-search search-icon"></i>
                        <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control search-input" 
                            placeholder="Search by title, message, user..."></asp:TextBox>
                    </div>
                </div>
                
                <div class="form-group">
                    <label class="form-label text-primary"><i class="fas fa-tag me-2"></i>Type</label>
                    <div class="select-with-icon">
                        <asp:DropDownList ID="ddlType" runat="server" CssClass="form-control">
                            <asp:ListItem Value="all">All Types</asp:ListItem>
                            <asp:ListItem Value="Info">Information</asp:ListItem>
                            <asp:ListItem Value="Success">Success</asp:ListItem>
                            <asp:ListItem Value="Warning">Warning</asp:ListItem>
                            <asp:ListItem Value="Error">Error</asp:ListItem>
                            <asp:ListItem Value="System">System</asp:ListItem>
                            <asp:ListItem Value="Announcement">Announcement</asp:ListItem>
                            <asp:ListItem Value="Promotion">Promotion</asp:ListItem>
                        </asp:DropDownList>
                        <i class="fas fa-chevron-down select-arrow"></i>
                    </div>
                </div>
                
                <div class="form-group">
                    <label class="form-label text-primary"><i class="fas fa-user me-2"></i>Recipient</label>
                    <div class="select-with-icon">
                        <asp:DropDownList ID="ddlRecipient" runat="server" CssClass="form-control">
                            <asp:ListItem Value="all">All Recipients</asp:ListItem>
                            <asp:ListItem Value="All Users">All Users</asp:ListItem>
                            <asp:ListItem Value="Specific">Specific User</asp:ListItem>
                            <asp:ListItem Value="Role">By Role</asp:ListItem>
                        </asp:DropDownList>
                        <i class="fas fa-chevron-down select-arrow"></i>
                    </div>
                </div>
                
                <div class="form-group">
                    <label class="form-label text-primary"><i class="fas fa-eye me-2"></i>Status</label>
                    <div class="select-with-icon">
                        <asp:DropDownList ID="ddlStatus" runat="server" CssClass="form-control">
                            <asp:ListItem Value="all">All Status</asp:ListItem>
                            <asp:ListItem Value="Unread">Unread</asp:ListItem>
                            <asp:ListItem Value="Read">Read</asp:ListItem>
                            <asp:ListItem Value="Important">Important</asp:ListItem>
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
                    <button type="button" class="action-filter-btn" onclick="filterType('Important')">
                        <i class="fas fa-exclamation-circle"></i> Important
                    </button>
                    <button type="button" class="action-filter-btn" onclick="filterStatus('Unread')">
                        <i class="fas fa-envelope"></i> Unread
                    </button>
                    <button type="button" class="action-filter-btn" onclick="filterType('System')">
                        <i class="fas fa-cogs"></i> System
                    </button>
                    <button type="button" class="action-filter-btn" onclick="showToday()">
                        <i class="fas fa-calendar-day"></i> Today
                    </button>
                    <button type="button" class="action-filter-btn" onclick="showLast7Days()">
                        <i class="fas fa-calendar-week"></i> Last 7 Days
                    </button>
                </div>
            </div>
        </div>

        <!-- Stats Cards -->
        <div class="d-flex gap-3 mb-4 flex-wrap">
            <div class="stats-card users" style="flex: 1; min-width: 200px;">
                <div class="stats-icon">
                    <i class="fas fa-bell"></i>
                </div>
                <div class="stats-number text-primary" id="statTotalNotifications" runat="server">0</div>
                <div class="stats-label text-primary">Total Notifications</div>
            </div>
            <div class="stats-card active" style="flex: 1; min-width: 200px;">
                <div class="stats-icon">
                    <i class="fas fa-envelope"></i>
                </div>
                <div class="stats-number text-warning" id="statUnreadNotifications" runat="server">0</div>
                <div class="stats-label text-primary">Unread</div>
            </div>
            <div class="stats-card pickups" style="flex: 1; min-width: 200px;">
                <div class="stats-icon">
                    <i class="fas fa-exclamation-circle"></i>
                </div>
                <div class="stats-number text-danger" id="statImportantNotifications" runat="server">0</div>
                <div class="stats-label text-primary">Important</div>
            </div>
            <div class="stats-card waste" style="flex: 1; min-width: 200px;">
                <div class="stats-icon">
                    <i class="fas fa-users"></i>
                </div>
                <div class="stats-number text-success" id="statTotalRecipients" runat="server">0</div>
                <div class="stats-label text-primary">Total Recipients</div>
            </div>
        </div>

        <!-- Quick Actions -->
        <div class="filter-card mb-4">
            <h5 class="mb-4 text-primary"><i class="fas fa-cogs me-2"></i>Quick Actions</h5>
            <div class="d-flex flex-wrap gap-3">
                <button type="button" class="btn btn-primary btn-with-icon" onclick="showSendModal()">
                    <i class="fas fa-plus me-2"></i>Send New
                </button>
                <button type="button" class="btn btn-success btn-with-icon" onclick="__doPostBack('ctl00$MainContent$btnMarkAllReadGlobal', '')">
                    <i class="fas fa-eye me-2"></i>Mark All Read
                </button>
                <button type="button" class="btn btn-info btn-with-icon" onclick="__doPostBack('ctl00$MainContent$btnExportCSV', '')">
                    <i class="fas fa-file-export me-2"></i>Export CSV
                </button>
                <button type="button" class="btn btn-warning btn-with-icon" onclick="__doPostBack('ctl00$MainContent$btnRefresh', '')">
                    <i class="fas fa-sync-alt me-2"></i>Refresh
                </button>
                <button type="button" class="btn btn-danger btn-with-icon" onclick="bulkDelete()">
                    <i class="fas fa-trash me-2"></i>Bulk Delete
                </button>
                <asp:Button ID="btnMarkAllReadGlobal" runat="server" Style="display: none;" OnClick="btnMarkAllReadGlobal_Click" />
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
                    <i class="fas fa-bell me-2"></i>
                    Showing <asp:Label ID="lblNotificationCount" runat="server" Text="0" CssClass="text-primary"></asp:Label> notifications
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
            <asp:Repeater ID="rptNotifications" runat="server" OnItemDataBound="rptNotifications_ItemDataBound">
                <ItemTemplate>
                    <div class="notification-card <%# GetTypeCardClass(Eval("Type").ToString()) %>">
                        <div class="d-flex justify-content-between align-items-start mb-2">
                            <div class="d-flex align-items-center">
                                <div class="notification-icon <%# GetTypeIconClass(Eval("Type").ToString()) %>">
                                    <i class="fas <%# GetTypeIcon(Eval("Type").ToString()) %>"></i>
                                </div>
                                <div>
                                    <h6 class="mb-0 text-primary"><%# Eval("Title") %></h6>
                                    <small class="text-muted">
                                        <i class="fas fa-user me-1"></i><%# Eval("FullName") %>
                                        <i class="fas fa-clock ms-2 me-1"></i><%# GetFormattedDateTime(Eval("CreatedAt")) %>
                                    </small>
                                </div>
                            </div>
                            <span class="badge <%# GetStatusBadgeClass(Convert.ToBoolean(Eval("IsRead"))) %>">
                                <%# GetStatusText(Convert.ToBoolean(Eval("IsRead"))) %>
                            </span>
                        </div>
                        
                        <div class="mb-2">
                            <small class="text-muted">
                                <i class="fas fa-hashtag me-1"></i>ID: <%# Eval("NotificationId") %>
                                <i class="fas fa-tag ms-2 me-1"></i><%# Eval("Type") %>
                                <i class="fas fa-users ms-2 me-1"></i><%# Eval("RecipientType") %>
                            </small>
                        </div>
                        
                        <div class="mb-3">
                            <p class="mb-1 text-primary"><strong>Message:</strong></p>
                            <p class="mb-0 text-primary"><%# TruncateText(Eval("Message").ToString(), 120) %></p>
                        </div>
                        
                        <div class="notification-meta">
                            <%# GetImportantIcon(Convert.ToBoolean(Eval("Important"))) %>
                            <%# GetAckIcon(Convert.ToBoolean(Eval("RequireAck"))) %>
                        </div>
                        
                        <div class="d-flex justify-content-between align-items-center mt-3">
                            <div>
                                <small class="text-muted">
                                    <%# GetDaysAgo(Eval("CreatedAt")) %>
                                </small>
                            </div>
                            <div class="action-buttons">
                                <button type="button" class="btn btn-sm btn-info" onclick='viewNotificationDetails("<%# Eval("NotificationId") %>")'>
                                    <i class="fas fa-eye"></i> View
                                </button>
                                <button type="button" class="btn btn-sm btn-success" onclick='markAsRead("<%# Eval("NotificationId") %>")'>
                                    <i class="fas fa-check"></i> Read
                                </button>
                                <button type="button" class="btn btn-sm btn-danger" onclick='deleteNotification("<%# Eval("NotificationId") %>", "<%# Eval("Title") %>")'>
                                    <i class="fas fa-trash"></i> Delete
                                </button>
                            </div>
                        </div>
                    </div>
                </ItemTemplate>
                <FooterTemplate>
                    <asp:Label ID="lblEmptyGrid" runat="server" Text="No notifications found" 
                        Visible='<%# rptNotifications.Items.Count == 0 %>' CssClass="empty-state">
                        <i class="fas fa-bell-slash"></i>
                        <p class="text-primary">No notifications matching your criteria</p>
                    </asp:Label>
                </FooterTemplate>
            </asp:Repeater>
        </asp:Panel>

        <!-- Table View -->
        <asp:Panel ID="pnlTableView" runat="server" CssClass="table-container" Visible="false">
            <div class="table-responsive">
                <asp:GridView ID="gvNotifications" runat="server" AutoGenerateColumns="False" 
                    CssClass="users-table notification-table" 
                    EmptyDataText="No notifications found" ShowHeaderWhenEmpty="true"
                    OnRowCommand="gvNotifications_RowCommand">
                    <Columns>
                        <asp:TemplateField HeaderText="Notification Details">
                            <ItemTemplate>
                                <div class="d-flex align-items-center">
                                    <div class="notification-icon <%# GetTypeIconClass(Eval("Type").ToString()) %> me-2" 
                                         style="width: 30px; height: 30px;">
                                        <i class="fas <%# GetTypeIcon(Eval("Type").ToString()) %>"></i>
                                    </div>
                                    <div>
                                        <strong class="text-primary d-block"><%# Eval("Title") %></strong>
                                        <small class="text-muted d-block">
                                            <i class="fas fa-user me-1"></i><%# Eval("FullName") %>
                                        </small>
                                        <small class="text-muted">
                                            <i class="fas fa-hashtag me-1"></i><%# Eval("NotificationId") %>
                                        </small>
                                    </div>
                                </div>
                            </ItemTemplate>
                        </asp:TemplateField>
                        
                        <asp:TemplateField HeaderText="Type & Status">
                            <ItemTemplate>
                                <div>
                                    <span class="badge <%# GetTypeBadgeClass(Eval("Type").ToString()) %> mb-1">
                                        <%# Eval("Type") %>
                                    </span>
                                    <div class="small">
                                        <span class="<%# GetStatusClass(Convert.ToBoolean(Eval("IsRead"))) %>">
                                            <i class="fas <%# GetStatusIcon(Convert.ToBoolean(Eval("IsRead"))) %> me-1"></i>
                                            <%# GetStatusText(Convert.ToBoolean(Eval("IsRead"))) %>
                                        </span>
                                    </div>
                                    <div class="small text-muted">
                                        <i class="fas fa-users me-1"></i><%# Eval("RecipientType") %>
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
                        
                        <asp:BoundField DataField="CreatedAt" HeaderText="Sent Date" 
                            DataFormatString="{0:MMM dd, yyyy HH:mm}" HtmlEncode="false" />
                        
                        <asp:TemplateField HeaderText="Actions">
                            <ItemTemplate>
                                <div class="d-flex flex-wrap gap-2">
                                    <asp:LinkButton ID="btnView" runat="server" CssClass="btn btn-info btn-sm"
                                        CommandName="View" CommandArgument='<%# Eval("NotificationId") %>'>
                                        <i class="fas fa-eye"></i>
                                    </asp:LinkButton>
                                    <asp:LinkButton ID="btnMarkRead" runat="server" CssClass="btn btn-success btn-sm"
                                        CommandName="MarkRead" CommandArgument='<%# Eval("NotificationId") %>'>
                                        <i class="fas fa-check"></i>
                                    </asp:LinkButton>
                                    <asp:LinkButton ID="btnDelete" runat="server" CssClass="btn btn-danger btn-sm"
                                        CommandName="Delete" CommandArgument='<%# Eval("NotificationId") %>'
                                        OnClientClick="return confirm('Are you sure you want to delete this notification?');">
                                        <i class="fas fa-trash"></i>
                                    </asp:LinkButton>
                                </div>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                    <EmptyDataTemplate>
                        <div class="empty-state" style="margin: 2rem;">
                            <i class="fas fa-bell-slash"></i>
                            <p class="text-primary">No notifications found matching your criteria</p>
                        </div>
                    </EmptyDataTemplate>
                </asp:GridView>
            </div>
        </asp:Panel>
    </div>

    <!-- JavaScript functions -->
    <script>
    function showSendModal() {
        $('#sendNotificationModal').modal('show');
    }
    
    function viewNotificationDetails(notificationId) {
        __doPostBack('ctl00$MainContent$hdnSelectedNotification', 'view_' + notificationId);
    }
    
    function markAsRead(notificationId) {
        if (confirm('Are you sure you want to mark this notification as read?')) {
            __doPostBack('ctl00$MainContent$hdnSelectedNotification', 'read_' + notificationId);
        }
    }
    
    function deleteNotification(notificationId, title) {
        if (confirm('Are you sure you want to delete the notification "' + title + '"? This action cannot be undone.')) {
            __doPostBack('ctl00$MainContent$hdnSelectedNotification', 'delete_' + notificationId);
        }
    }
    
    function filterType(type) {
        document.getElementById('<%= ddlType.ClientID %>').value = type;
        __doPostBack('ctl00$MainContent$btnApplyFilters', '');
    }
    
    function filterStatus(status) {
        document.getElementById('<%= ddlStatus.ClientID %>').value = status;
        __doPostBack('ctl00$MainContent$btnApplyFilters', '');
    }
    
    function showToday() {
        var today = new Date().toISOString().split('T')[0];
        // Add date filter if needed
        __doPostBack('ctl00$MainContent$btnApplyFilters', '');
    }
    
    function showLast7Days() {
        // Add date range filter if needed
        __doPostBack('ctl00$MainContent$btnApplyFilters', '');
    }
    
    function showAllNotifications() {
        document.getElementById('<%= ddlType.ClientID %>').value = 'all';
        document.getElementById('<%= ddlStatus.ClientID %>').value = 'all';
        document.getElementById('<%= ddlRecipient.ClientID %>').value = 'all';
        document.getElementById('<%= txtSearch.ClientID %>').value = '';
        __doPostBack('ctl00$MainContent$btnApplyFilters', '');
    }
    
    function bulkDelete() {
        if (confirm('Are you sure you want to delete selected notifications? This action cannot be undone.')) {
            __doPostBack('ctl00$MainContent$btnBulkDelete', '');
        }
    }
    
    // Initialize modal
    document.addEventListener('DOMContentLoaded', function() {
        // Ensure all text is visible
        document.querySelectorAll('.text-primary, .text-secondary, .text-muted').forEach(el => {
            el.style.color = getComputedStyle(el).color;
        });
    });
    </script>
    
    <asp:HiddenField ID="hdnSelectedNotification" runat="server" />
    <asp:Button ID="btnBulkDelete" runat="server" Style="display: none;" OnClick="btnBulkDelete_Click" />
</asp:Content>