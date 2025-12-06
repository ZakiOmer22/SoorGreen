<%@ Page Title="Audit Logs" Language="C#" MasterPageFile="~/Pages/Admin/Site.master" AutoEventWireup="true" CodeFile="AuditLogs.aspx.cs" Inherits="SoorGreen.Admin.Admin.AuditLogs" %>

<asp:Content ID="Content3" ContentPlaceHolderID="HeadContent" runat="server">
    <link href='<%= ResolveUrl("~/Content/Pages/Admin/admincitizens.css") %>' rel="stylesheet" />
    <link href='<%= ResolveUrl("~/Content/Pages/Admin/adminauditlogs.css") %>' rel="stylesheet" />
</asp:Content>

<asp:Content ID="PageTitle" ContentPlaceHolderID="PageTitle" runat="server">
    <div class="d-flex align-items-center">
        <h1 class="h3 mb-0" style="color: var(--text-primary);">Audit Logs</h1>
        <span class="badge bg-secondary ms-3">System Activity Tracker</span>
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

    <!-- Log Details Modal -->
    <div class="modal fade" id="logDetailsModal" tabindex="-1" role="dialog" aria-hidden="true">
        <div class="modal-dialog modal-lg" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">
                        <i class="fas fa-file-alt me-2"></i>
                        <span id="modalTitle">Log Details</span>
                    </h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <div class="row mb-3">
                        <div class="col-md-6">
                            <div class="mb-3">
                                <label class="form-label"><i class="fas fa-hashtag me-2"></i>Log ID</label>
                                <asp:TextBox ID="txtLogId" runat="server" CssClass="form-control" ReadOnly="true"></asp:TextBox>
                            </div>
                            
                            <div class="mb-3">
                                <label class="form-label"><i class="fas fa-user me-2"></i>User</label>
                                <asp:TextBox ID="txtUserName" runat="server" CssClass="form-control" ReadOnly="true"></asp:TextBox>
                            </div>
                            
                            <div class="mb-3">
                                <label class="form-label"><i class="fas fa-bolt me-2"></i>Action Type</label>
                                <asp:TextBox ID="txtActionType" runat="server" CssClass="form-control" ReadOnly="true"></asp:TextBox>
                            </div>
                        </div>
                        
                        <div class="col-md-6">
                            <div class="mb-3">
                                <label class="form-label"><i class="fas fa-clock me-2"></i>Timestamp</label>
                                <asp:TextBox ID="txtTimestamp" runat="server" CssClass="form-control" ReadOnly="true"></asp:TextBox>
                            </div>
                            
                            <div class="mb-3">
                                <label class="form-label"><i class="fas fa-user-tag me-2"></i>User Role</label>
                                <asp:TextBox ID="txtUserRole" runat="server" CssClass="form-control" ReadOnly="true"></asp:TextBox>
                            </div>
                            
                            <div class="mb-3">
                                <label class="form-label"><i class="fas fa-calendar me-2"></i>Date</label>
                                <asp:TextBox ID="txtDate" runat="server" CssClass="form-control" ReadOnly="true"></asp:TextBox>
                            </div>
                        </div>
                    </div>
                    
                    <!-- Action Details -->
                    <div class="mb-3">
                        <label class="form-label"><i class="fas fa-info-circle me-2"></i>Action Details</label>
                        <asp:TextBox ID="txtActionDetails" runat="server" CssClass="form-control" 
                            TextMode="MultiLine" Rows="8" ReadOnly="true"></asp:TextBox>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                </div>
            </div>
        </div>
    </div>

    <div class="users-container">
        <!-- Filter Card -->
        <div class="filter-card">
            <h5 class="mb-4"><i class="fas fa-sliders-h me-2"></i>Filter Logs</h5>
            <div class="filter-group">
                <div class="form-group search-box">
                    <label class="form-label"><i class="fas fa-search me-2"></i>Search Logs</label>
                    <div class="position-relative">
                        <i class="fas fa-search search-icon"></i>
                        <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control search-input" 
                            placeholder="Search by user, action, details..."></asp:TextBox>
                    </div>
                </div>
                
                <div class="form-group">
                    <label class="form-label"><i class="fas fa-filter me-2"></i>Action Type</label>
                    <div class="select-with-icon">
                        <asp:DropDownList ID="ddlActionType" runat="server" CssClass="form-control">
                            <asp:ListItem Value="all">All Actions</asp:ListItem>
                            <asp:ListItem Value="Login">Login</asp:ListItem>
                            <asp:ListItem Value="Logout">Logout</asp:ListItem>
                            <asp:ListItem Value="Create">Create</asp:ListItem>
                            <asp:ListItem Value="Update">Update</asp:ListItem>
                            <asp:ListItem Value="Delete">Delete</asp:ListItem>
                            <asp:ListItem Value="Export">Export</asp:ListItem>
                            <asp:ListItem Value="System">System Event</asp:ListItem>
                            <asp:ListItem Value="Security">Security</asp:ListItem>
                            <asp:ListItem Value="Error">Error</asp:ListItem>
                        </asp:DropDownList>
                        <i class="fas fa-chevron-down select-arrow"></i>
                    </div>
                </div>
                
                <div class="form-group">
                    <label class="form-label"><i class="fas fa-user me-2"></i>User</label>
                    <div class="select-with-icon">
                        <asp:DropDownList ID="ddlUser" runat="server" CssClass="form-control">
                            <asp:ListItem Value="all">All Users</asp:ListItem>
                        </asp:DropDownList>
                        <i class="fas fa-chevron-down select-arrow"></i>
                    </div>
                </div>
                
                <div class="form-group">
                    <label class="form-label"><i class="fas fa-calendar me-2"></i>Date Range</label>
                    <div class="row g-2">
                        <div class="col">
                            <asp:TextBox ID="txtDateFrom" runat="server" CssClass="form-control" 
                                TextMode="Date"></asp:TextBox>
                        </div>
                        <div class="col">
                            <asp:TextBox ID="txtDateTo" runat="server" CssClass="form-control" 
                                TextMode="Date"></asp:TextBox>
                        </div>
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
            
            <!-- Quick Action Filters -->
            <div class="mt-4">
                <h6 class="mb-3"><i class="fas fa-bolt me-2"></i>Quick Filters</h6>
                <div class="d-flex flex-wrap gap-2">
                    <button type="button" class="action-filter-btn" onclick="filterAction('Login')">
                        <i class="fas fa-sign-in-alt"></i> Logins
                    </button>
                    <button type="button" class="action-filter-btn" onclick="filterAction('Error')">
                        <i class="fas fa-exclamation-triangle"></i> Errors
                    </button>
                    <button type="button" class="action-filter-btn" onclick="filterAction('Delete')">
                        <i class="fas fa-trash"></i> Deletes
                    </button>
                    <button type="button" class="action-filter-btn" onclick="filterAction('Security')">
                        <i class="fas fa-shield-alt"></i> Security
                    </button>
                    <button type="button" class="action-filter-btn" onclick="filterToday()">
                        <i class="fas fa-calendar-day"></i> Today
                    </button>
                </div>
            </div>
        </div>

        <!-- Stats Cards -->
        <div class="d-flex gap-3 mb-4 flex-wrap">
            <div class="stats-card users" style="flex: 1; min-width: 200px;">
                <div class="stats-icon">
                    <i class="fas fa-file-alt"></i>
                </div>
                <div class="stats-number" id="statTotalLogs" runat="server">0</div>
                <div class="stats-label">Total Logs</div>
            </div>
            <div class="stats-card active" style="flex: 1; min-width: 200px;">
                <div class="stats-icon">
                    <i class="fas fa-user-shield"></i>
                </div>
                <div class="stats-number text-success" id="statSecurityLogs" runat="server">0</div>
                <div class="stats-label">Security Events</div>
            </div>
            <div class="stats-card pickups" style="flex: 1; min-width: 200px;">
                <div class="stats-icon">
                    <i class="fas fa-users"></i>
                </div>
                <div class="stats-number text-primary" id="statUserActions" runat="server">0</div>
                <div class="stats-label">User Actions</div>
            </div>
            <div class="stats-card waste" style="flex: 1; min-width: 200px;">
                <div class="stats-icon">
                    <i class="fas fa-exclamation-triangle"></i>
                </div>
                <div class="stats-number text-warning" id="statErrorLogs" runat="server">0</div>
                <div class="stats-label">Error Logs</div>
            </div>
        </div>

        <!-- Quick Actions -->
        <div class="filter-card mb-4">
            <h5 class="mb-4"><i class="fas fa-cogs me-2"></i>Log Management</h5>
            <div class="d-flex flex-wrap gap-3">
                <button type="button" class="btn btn-primary btn-with-icon" onclick="__doPostBack('ctl00$MainContent$btnExportCSV', '')">
                    <i class="fas fa-file-export me-2"></i>Export CSV
                </button>
                <button type="button" class="btn btn-warning btn-with-icon" onclick="showClearLogsModal()">
                    <i class="fas fa-broom me-2"></i>Clear Old Logs
                </button>
                <button type="button" class="btn btn-danger btn-with-icon" onclick="showPurgeModal()">
                    <i class="fas fa-trash-alt me-2"></i>Purge All Logs
                </button>
                <button type="button" class="btn btn-success btn-with-icon" onclick="__doPostBack('ctl00$MainContent$btnRefresh', '')">
                    <i class="fas fa-sync-alt me-2"></i>Refresh Logs
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
                    <asp:LinkButton ID="btnTimelineView" runat="server" CssClass="view-btn" 
                        OnClick="btnTimelineView_Click" CausesValidation="false">
                        <i class="fas fa-stream me-2"></i>Timeline
                    </asp:LinkButton>
                </div>
                <div class="page-info">
                    <i class="fas fa-file-alt me-2"></i>
                    Showing <asp:Label ID="lblLogCount" runat="server" Text="0"></asp:Label> log entries
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
            <asp:Repeater ID="rptAuditLogs" runat="server" OnItemDataBound="rptAuditLogs_ItemDataBound">
                <ItemTemplate>
                    <div class="audit-card <%# GetLogCardClass(Eval("Action").ToString()) %>">
                        <div class="d-flex justify-content-between align-items-start mb-2">
                            <div class="d-flex align-items-center">
                                <div class="audit-icon bg-primary text-white">
                                    <i class="fas <%# GetActionIcon(Eval("Action").ToString()) %>"></i>
                                </div>
                                <div>
                                    <h6 class="mb-0"><%# Eval("Action") %></h6>
                                    <small class="text-muted">
                                        <i class="fas fa-user me-1"></i><%# Eval("FullName", "{0}") %>
                                        <i class="fas fa-clock ms-2 me-1"></i><%# GetFormattedDateTime(Eval("Timestamp")) %>
                                    </small>
                                </div>
                            </div>
                            <span class="badge <%# GetActionBadgeClass(Eval("Action").ToString()) %> log-badge">
                                <%# Eval("Action") %>
                            </span>
                        </div>
                        
                        <div class="mb-2">
                            <small class="text-muted">
                                <i class="fas fa-hashtag me-1"></i>Log ID: <%# Eval("AuditId") %>
                                <i class="fas fa-user-tag ms-2 me-1"></i>Role: <%# Eval("RoleName", "{0}") %>
                            </small>
                        </div>
                        
                        <div class="mb-3">
                            <p class="mb-1"><strong>Details:</strong></p>
                            <p class="mb-0"><%# TruncateText(Eval("Details").ToString(), 150) %></p>
                        </div>
                        
                        <div class="audit-details">
                            <small><%# Eval("Details") %></small>
                        </div>
                        
                        <div class="d-flex justify-content-between align-items-center mt-3">
                            <div>
                                <small class="text-muted">
                                    <i class="fas fa-calendar me-1"></i>
                                    <%# GetFormattedDate(Eval("Timestamp")) %>
                                </small>
                            </div>
                            <div class="action-buttons">
                                <button type="button" class="btn btn-sm btn-info" onclick='viewLogDetails("<%# Eval("AuditId") %>")'>
                                    <i class="fas fa-eye"></i> Details
                                </button>
                                <button type="button" class="btn btn-sm btn-danger" onclick='deleteSingleLog("<%# Eval("AuditId") %>")'>
                                    <i class="fas fa-trash"></i> Delete
                                </button>
                            </div>
                        </div>
                    </div>
                </ItemTemplate>
                <FooterTemplate>
                    <asp:Label ID="lblEmptyGrid" runat="server" Text="No audit logs found" 
                        Visible='<%# rptAuditLogs.Items.Count == 0 %>' CssClass="empty-state">
                        <i class="fas fa-file-alt"></i>
                        <p>No audit logs matching your criteria</p>
                    </asp:Label>
                </FooterTemplate>
            </asp:Repeater>
        </asp:Panel>

        <!-- Table View -->
        <asp:Panel ID="pnlTableView" runat="server" CssClass="table-container" Visible="false">
            <div class="table-responsive">
                <asp:GridView ID="gvAuditLogs" runat="server" AutoGenerateColumns="False" 
                    CssClass="users-table" 
                    EmptyDataText="No audit logs found" ShowHeaderWhenEmpty="true">
                    <Columns>
                        <asp:TemplateField HeaderText="Log ID">
                            <ItemTemplate>
                                <div class="d-flex align-items-center">
                                    <div class="audit-icon bg-primary text-white me-2" style="width: 30px; height: 30px;">
                                        <i class="fas <%# GetActionIcon(Eval("Action").ToString()) %>"></i>
                                    </div>
                                    <div>
                                        <strong><%# Eval("AuditId") %></strong>
                                    </div>
                                </div>
                            </ItemTemplate>
                        </asp:TemplateField>
                        
                        <asp:TemplateField HeaderText="Action & User">
                            <ItemTemplate>
                                <div>
                                    <strong><%# Eval("Action") %></strong><br>
                                    <small class="text-muted">
                                        <i class="fas fa-user me-1"></i><%# Eval("FullName", "{0}") %>
                                    </small><br>
                                    <small class="text-muted">
                                        <i class="fas fa-user-tag me-1"></i><%# Eval("RoleName", "{0}") %>
                                    </small>
                                </div>
                            </ItemTemplate>
                        </asp:TemplateField>
                        
                        <asp:TemplateField HeaderText="Details">
                            <ItemTemplate>
                                <div class="truncate-text" style="max-height: 80px; overflow: hidden;">
                                    <%# TruncateText(Eval("Details").ToString(), 100) %>
                                </div>
                            </ItemTemplate>
                        </asp:TemplateField>
                        
                        <asp:TemplateField HeaderText="Timestamp">
                            <ItemTemplate>
                                <div class="small">
                                    <i class="fas fa-clock me-1"></i>
                                    <%# GetFormattedDateTime(Eval("Timestamp")) %><br>
                                    <small class="text-muted">
                                        <i class="fas fa-calendar me-1"></i>
                                        <%# GetFormattedDate(Eval("Timestamp")) %>
                                    </small>
                                </div>
                            </ItemTemplate>
                        </asp:TemplateField>
                        
                        <asp:TemplateField HeaderText="Actions">
                            <ItemTemplate>
                                <div class="d-flex flex-wrap gap-2">
                                    <button type="button" class="btn btn-info btn-sm" onclick='viewLogDetails("<%# Eval("AuditId") %>")'>
                                        <i class="fas fa-eye"></i>
                                    </button>
                                    <button type="button" class="btn btn-danger btn-sm" onclick='deleteSingleLog("<%# Eval("AuditId") %>")'>
                                        <i class="fas fa-trash"></i>
                                    </button>
                                </div>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                    <EmptyDataTemplate>
                        <div class="empty-state" style="margin: 2rem;">
                            <i class="fas fa-file-alt"></i>
                            <p>No audit logs found matching your criteria</p>
                        </div>
                    </EmptyDataTemplate>
                </asp:GridView>
            </div>
        </asp:Panel>

        <!-- Timeline View -->
        <asp:Panel ID="pnlTimelineView" runat="server" CssClass="table-container" Visible="false">
            <div class="audit-timeline">
                <asp:Repeater ID="rptTimeline" runat="server">
                    <ItemTemplate>
                        <div class="timeline-item <%# GetTimelineItemClass(Eval("Action").ToString()) %>">
                            <div class="audit-card">
                                <div class="d-flex justify-content-between align-items-start mb-2">
                                    <div class="d-flex align-items-center">
                                        <div class="audit-icon bg-primary text-white me-2">
                                            <i class="fas <%# GetActionIcon(Eval("Action").ToString()) %>"></i>
                                        </div>
                                        <div>
                                            <h6 class="mb-0"><%# Eval("Action") %></h6>
                                            <small class="text-muted">
                                                <i class="fas fa-user me-1"></i><%# Eval("FullName", "{0}") %>
                                            </small>
                                        </div>
                                    </div>
                                    <div class="text-end">
                                        <small class="text-muted d-block">
                                            <i class="fas fa-clock me-1"></i>
                                            <%# GetFormattedDateTime(Eval("Timestamp")) %>
                                        </small>
                                        <span class="badge <%# GetActionBadgeClass(Eval("Action").ToString()) %> log-badge">
                                            <%# Eval("Action") %>
                                        </span>
                                    </div>
                                </div>
                                
                                <div class="mb-2">
                                    <p class="mb-1"><strong>Details:</strong></p>
                                    <p class="mb-0"><%# TruncateText(Eval("Details").ToString(), 120) %></p>
                                </div>
                                
                                <div class="d-flex justify-content-between align-items-center mt-2">
                                    <small class="text-muted">
                                        <i class="fas fa-hashtag me-1"></i><%# Eval("AuditId") %>
                                        <i class="fas fa-calendar ms-2 me-1"></i><%# GetFormattedDate(Eval("Timestamp")) %>
                                    </small>
                                    <div>
                                        <button type="button" class="btn btn-sm btn-info" onclick='viewLogDetails("<%# Eval("AuditId") %>")'>
                                            <i class="fas fa-eye me-1"></i>View
                                        </button>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </ItemTemplate>
                    <FooterTemplate>
                        <asp:Label ID="lblEmptyTimeline" runat="server" Text="No audit logs found" 
                            Visible='<%# rptTimeline.Items.Count == 0 %>' CssClass="empty-state">
                            <i class="fas fa-file-alt"></i>
                            <p>No audit logs matching your criteria</p>
                        </asp:Label>
                    </FooterTemplate>
                </asp:Repeater>
            </div>
        </asp:Panel>
    </div>

    <!-- Clear Logs Modal -->
    <div class="modal fade" id="clearLogsModal" tabindex="-1" role="dialog" aria-hidden="true">
        <div class="modal-dialog" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">
                        <i class="fas fa-broom me-2"></i>Clear Old Logs
                    </h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <div class="mb-3">
                        <label class="form-label">Delete logs older than:</label>
                        <asp:DropDownList ID="ddlClearDays" runat="server" CssClass="form-control">
                            <asp:ListItem Value="30">30 days</asp:ListItem>
                            <asp:ListItem Value="60">60 days</asp:ListItem>
                            <asp:ListItem Value="90">90 days</asp:ListItem>
                            <asp:ListItem Value="180">180 days</asp:ListItem>
                            <asp:ListItem Value="365">1 year</asp:ListItem>
                        </asp:DropDownList>
                    </div>
                    <div class="alert alert-warning">
                        <i class="fas fa-exclamation-triangle me-2"></i>
                        This action will permanently delete all audit logs older than the selected period.
                        This action cannot be undone.
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <asp:Button ID="btnClearOldLogs" runat="server" CssClass="btn btn-warning" 
                        Text="Clear Old Logs" OnClick="btnClearOldLogs_Click" 
                        OnClientClick="return confirm('Are you sure you want to clear old logs? This action cannot be undone.');" />
                </div>
            </div>
        </div>
    </div>

    <!-- Purge Logs Modal -->
    <div class="modal fade" id="purgeLogsModal" tabindex="-1" role="dialog" aria-hidden="true">
        <div class="modal-dialog" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title text-danger">
                        <i class="fas fa-trash-alt me-2"></i>Purge All Logs
                    </h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <div class="alert alert-danger">
                        <i class="fas fa-exclamation-triangle me-2"></i>
                        <strong>WARNING:</strong> This action will permanently delete ALL audit logs from the system.
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Confirm by typing "PURGE" below:</label>
                        <asp:TextBox ID="txtPurgeConfirm" runat="server" CssClass="form-control" 
                            placeholder="Type PURGE to confirm"></asp:TextBox>
                    </div>
                    <div class="alert alert-info">
                        <i class="fas fa-info-circle me-2"></i>
                        This action cannot be undone. Consider exporting logs before purging.
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <asp:Button ID="btnPurgeLogs" runat="server" CssClass="btn btn-danger" 
                        Text="Purge All Logs" OnClick="btnPurgeLogs_Click" Enabled="false" />
                </div>
            </div>
        </div>
    </div>

    <!-- JavaScript functions -->
    <script>
    function viewLogDetails(logId) {
        __doPostBack('ctl00$MainContent$hdnSelectedLog', 'view_' + logId);
    }
    
    function deleteSingleLog(logId) {
        if (confirm('Are you sure you want to delete this log entry? This action cannot be undone.')) {
            __doPostBack('ctl00$MainContent$hdnSelectedLog', 'delete_' + logId);
        }
    }
    
    function showClearLogsModal() {
        var modal = new bootstrap.Modal(document.getElementById('clearLogsModal'));
        modal.show();
    }
    
    function showPurgeModal() {
        var modal = new bootstrap.Modal(document.getElementById('purgeLogsModal'));
        modal.show();
    }
    
    function filterAction(actionType) {
        document.getElementById('<%= ddlActionType.ClientID %>').value = actionType;
        __doPostBack('ctl00$MainContent$btnApplyFilters', '');
        
        // Update active filter button
        document.querySelectorAll('.action-filter-btn').forEach(btn => {
            btn.classList.remove('active');
        });
        event.target.classList.add('active');
    }
    
    function filterToday() {
        var today = new Date().toISOString().split('T')[0];
        document.getElementById('<%= txtDateFrom.ClientID %>').value = today;
        document.getElementById('<%= txtDateTo.ClientID %>').value = today;
        __doPostBack('ctl00$MainContent$btnApplyFilters', '');
    }
    
    // Enable purge button when confirmation text matches
    document.getElementById('<%= txtPurgeConfirm.ClientID %>')?.addEventListener('input', function() {
        var purgeButton = document.getElementById('<%= btnPurgeLogs.ClientID %>');
        if (purgeButton) {
            purgeButton.disabled = this.value !== 'PURGE';
        }
    });
    
    // Initialize date fields with default range
    document.addEventListener('DOMContentLoaded', function() {
        var dateFrom = document.getElementById('<%= txtDateFrom.ClientID %>');
        var dateTo = document.getElementById('<%= txtDateTo.ClientID %>');

        if (dateFrom && !dateFrom.value) {
            var weekAgo = new Date();
            weekAgo.setDate(weekAgo.getDate() - 7);
            dateFrom.value = weekAgo.toISOString().split('T')[0];
        }

        if (dateTo && !dateTo.value) {
            var today = new Date().toISOString().split('T')[0];
            dateTo.value = today;
        }
    });
    </script>
    
    <asp:HiddenField ID="hdnSelectedLog" runat="server" />
</asp:Content>