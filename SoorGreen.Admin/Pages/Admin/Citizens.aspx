<%@ Page Title="Citizens" Language="C#" MasterPageFile="~/Pages/Admin/Site.master" AutoEventWireup="true" CodeFile="Citizens.aspx.cs" Inherits="SoorGreen.Admin.Admin.Citizens" %>

<asp:Content ID="Content3" ContentPlaceHolderID="HeadContent" runat="server">
    <link href='<%= ResolveUrl("~/Content/Pages/Admin/admincitizens.css") %>' rel="stylesheet" />
</asp:Content>

<asp:Content ID="PageTitle" ContentPlaceHolderID="PageTitle" runat="server">
    <div class="d-flex align-items-center">
        <h1 class="h3 mb-0" style="color: var(--text-primary);">Citizen Management</h1>
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

    <div class="users-container">
        <!-- Filter Card -->
        <div class="filter-card">
            <h5 class="mb-4"><i class="fas fa-sliders-h me-2"></i>Advanced Filters</h5>
            <div class="filter-group">
                <div class="form-group search-box">
                    <label class="form-label"><i class="fas fa-search me-2"></i>Search Citizens</label>
                    <div class="position-relative">
                        <i class="fas fa-search search-icon"></i>
                        <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control search-input" 
                            placeholder="Search by name, email, phone or ID..."></asp:TextBox>
                    </div>
                </div>
                <div class="form-group">
                    <label class="form-label"><i class="fas fa-user-check me-2"></i>Status</label>
                    <div class="select-with-icon">
                        <asp:DropDownList ID="ddlStatus" runat="server" CssClass="form-control">
                            <asp:ListItem Value="all">All Status</asp:ListItem>
                            <asp:ListItem Value="active">Active</asp:ListItem>
                            <asp:ListItem Value="inactive">Inactive</asp:ListItem>
                        </asp:DropDownList>
                        <i class="fas fa-chevron-down select-arrow"></i>
                    </div>
                </div>
                <div class="form-group">
                    <label class="form-label"><i class="fas fa-calendar-alt me-2"></i>Registration Date</label>
                    <div class="select-with-icon">
                        <asp:DropDownList ID="ddlDateFilter" runat="server" CssClass="form-control">
                            <asp:ListItem Value="all">All Time</asp:ListItem>
                            <asp:ListItem Value="today">Today</asp:ListItem>
                            <asp:ListItem Value="week">This Week</asp:ListItem>
                            <asp:ListItem Value="month">This Month</asp:ListItem>
                            <asp:ListItem Value="year">This Year</asp:ListItem>
                        </asp:DropDownList>
                        <i class="fas fa-chevron-down select-arrow"></i>
                    </div>
                </div>
                <div class="form-group">
                    <label class="form-label" style="visibility: hidden;">Action</label>
                    <button type="button" class="btn btn-primary btn-with-icon" onclick="__doPostBack('ctl00$MainContent$btnApplyFilters', '')">
                        <i class="fas fa-filter me-2"></i>Apply Filters
                    </button>
                    <asp:Button ID="btnApplyFilters" runat="server" style="display:none;" OnClick="btnApplyFilters_Click" />
                </div>
            </div>
        </div>

        <!-- Stats Cards -->
        <div class="d-flex gap-3 mb-4 flex-wrap">
            <div class="stats-card users" style="flex: 1; min-width: 200px;">
                <div class="stats-icon">
                    <i class="fas fa-users"></i>
                </div>
                <div class="stats-number" id="statTotal" runat="server">0</div>
                <div class="stats-label">Total Citizens</div>
            </div>
            <div class="stats-card active" style="flex: 1; min-width: 200px;">
                <div class="stats-icon">
                    <i class="fas fa-user-check"></i>
                </div>
                <div class="stats-number text-success" id="statActive" runat="server">0</div>
                <div class="stats-label">Active Citizens</div>
            </div>
            <div class="stats-card credits" style="flex: 1; min-width: 200px;">
                <div class="stats-icon">
                    <i class="fas fa-coins"></i>
                </div>
                <div class="stats-number text-warning" id="statCredits" runat="server">0.00</div>
                <div class="stats-label">Total Credits</div>
            </div>
            <div class="stats-card pickups" style="flex: 1; min-width: 200px;">
                <div class="stats-icon">
                    <i class="fas fa-truck-loading"></i>
                </div>
                <div class="stats-number text-info" id="statPickups" runat="server">0</div>
                <div class="stats-label">Total Pickups</div>
            </div>
            <div class="stats-card waste" style="flex: 1; min-width: 200px;">
                <div class="stats-icon">
                    <i class="fas fa-weight-hanging"></i>
                </div>
                <div class="stats-number text-primary" id="statWaste" runat="server">0 kg</div>
                <div class="stats-label">Waste Collected</div>
            </div>
        </div>

        <!-- View Controls -->
        <div class="view-controls">
            <div class="d-flex align-items-center gap-3 flex-wrap">
                <div class="view-options">
                    <asp:LinkButton ID="btnGridView" runat="server" CssClass="view-btn active" 
                        OnClick="btnGridView_Click" CausesValidation="false">
                        <i class="fas fa-th-large me-2"></i>Grid View
                    </asp:LinkButton>
                    <asp:LinkButton ID="btnTableView" runat="server" CssClass="view-btn" 
                        OnClick="btnTableView_Click" CausesValidation="false">
                        <i class="fas fa-table me-2"></i>Table View
                    </asp:LinkButton>
                </div>
                <div class="page-info">
                    <i class="fas fa-users me-2"></i>
                    Showing <asp:Label ID="lblCitizenCount" runat="server" Text="0"></asp:Label> citizens
                </div>
            </div>
            <div class="d-flex gap-2">
                <button type="button" class="btn btn-secondary btn-with-icon" onclick="__doPostBack('ctl00$MainContent$btnExportCSV', '')">
                    <i class="fas fa-file-export me-2"></i>Export CSV
                </button>
                <asp:Button ID="btnExportCSV" runat="server" style="display:none;" OnClick="btnExportCSV_Click" />
                
                <button type="button" class="btn btn-secondary btn-with-icon" onclick="__doPostBack('ctl00$MainContent$btnRefresh', '')">
                    <i class="fas fa-sync-alt me-2"></i>Refresh
                </button>
                <asp:Button ID="btnRefresh" runat="server" style="display:none;" OnClick="btnRefresh_Click" />
                
                <button type="button" class="btn btn-secondary btn-with-icon" onclick="__doPostBack('ctl00$MainContent$btnClearFilters', '')">
                    <i class="fas fa-times me-2"></i>Clear Filters
                </button>
                <asp:Button ID="btnClearFilters" runat="server" style="display:none;" OnClick="btnClearFilters_Click" />
            </div>
        </div>

        <!-- Grid View -->
        <asp:Panel ID="pnlGridView" runat="server" CssClass="users-grid">
            <asp:Repeater ID="rptCitizensGrid" runat="server" 
                OnItemCommand="rptCitizensGrid_ItemCommand"
                OnItemDataBound="rptCitizensGrid_ItemDataBound">
                <ItemTemplate>
                    <div class="user-card">
                        <h5>
                            <i class="fas fa-user-circle me-2"></i><%# Eval("FullName") %>
                            <span class="user-id"><i class="fas fa-id-card me-1"></i><%# Eval("UserId") %></span>
                        </h5>
                        
                        <p>
                            <span><i class="fas fa-envelope me-2"></i>Email:</span>
                            <span><%# Eval("Email") != DBNull.Value ? Eval("Email") : "<i class='fas fa-minus text-muted'></i>" %></span>
                        </p>
                        
                        <p>
                            <span><i class="fas fa-phone me-2"></i>Phone:</span>
                            <span><%# Eval("Phone") %></span>
                        </p>
                        
                        <p>
                            <span><i class="fas fa-coins me-2"></i>Credits:</span>
                            <span class="text-warning"><%# string.Format("{0:N2}", Eval("XP_Credits")) %></span>
                        </p>
                        
                        <p>
                            <span><i class="fas fa-user-check me-2"></i>Status:</span>
                            <span class='<%# Convert.ToBoolean(Eval("IsVerified")) ? "text-success" : "text-danger" %>'>
                                <i class='fas fa-circle status-dot <%# Convert.ToBoolean(Eval("IsVerified")) ? "active" : "inactive" %>'></i>
                                <%# Convert.ToBoolean(Eval("IsVerified")) ? "Active" : "Inactive" %>
                            </span>
                        </p>
                        
                        <p>
                            <span><i class="fas fa-calendar-plus me-2"></i>Joined:</span>
                            <span><%# Convert.ToDateTime(Eval("CreatedAt")).ToString("yyyy-MM-dd") %></span>
                        </p>
                        
                        <div class="card-stats">
                            <div class="stat-item">
                                <span class="stat-value"><asp:Label ID="lblPickups" runat="server" Text="0"></asp:Label></span>
                                <span class="stat-label">Pickups</span>
                            </div>
                            <div class="stat-item">
                                <span class="stat-value"><asp:Label ID="lblKg" runat="server" Text="0.0"></asp:Label></span>
                                <span class="stat-label">Kg Waste</span>
                            </div>
                        </div>
                        
                        <div class="action-buttons">
                            <asp:LinkButton ID="btnView" runat="server" CssClass="btn btn-primary" 
                                CommandName="ViewDetails" CommandArgument='<%# Eval("UserId") %>'
                                ToolTip="View Details">
                                <i class="fas fa-eye me-1"></i>View
                            </asp:LinkButton>
                            <asp:LinkButton ID="btnResetPassGrid" runat="server" CssClass="btn btn-secondary" 
                                CommandName="ResetPassword" CommandArgument='<%# Eval("UserId") + "|" + Eval("FullName") %>'
                                ToolTip="Reset Password"
                                OnClientClick='<%# "return confirm(\"Reset password for citizen \\\"" + Eval("FullName") + "\\\"?\")" %>'>
                                <i class="fas fa-key me-1"></i>Reset Pass
                            </asp:LinkButton>
                            <asp:LinkButton ID="btnToggleStatus" runat="server" CssClass='<%# Convert.ToBoolean(Eval("IsVerified")) ? "btn btn-danger" : "btn btn-success" %>'
                                CommandName="ToggleStatus" CommandArgument='<%# Eval("UserId") + "|" + Eval("FullName") + "|" + (Convert.ToBoolean(Eval("IsVerified")) ? "active" : "inactive") %>'
                                ToolTip='<%# Convert.ToBoolean(Eval("IsVerified")) ? "Deactivate" : "Activate" %>'
                                OnClientClick='<%# "return confirm(\"" + (Convert.ToBoolean(Eval("IsVerified")) ? "Deactivate" : "Activate") + " citizen \\\"" + Eval("FullName") + "\\\"?\")" %>'>
                                <i class='fas <%# Convert.ToBoolean(Eval("IsVerified")) ? "fa-ban me-1" : "fa-check me-1" %>'></i>
                                <%# Convert.ToBoolean(Eval("IsVerified")) ? "Deactivate" : "Activate" %>
                            </asp:LinkButton>
                        </div>
                    </div>
                </ItemTemplate>
                <FooterTemplate>
                    <asp:Label ID="lblEmptyGrid" runat="server" Text="No citizens found" 
                        Visible='<%# rptCitizensGrid.Items.Count == 0 %>' CssClass="empty-state">
                        <i class="fas fa-users-slash"></i>
                        <p>No citizens found matching your criteria</p>
                    </asp:Label>
                </FooterTemplate>
            </asp:Repeater>
        </asp:Panel>

        <!-- Table View -->
        <asp:Panel ID="pnlTableView" runat="server" CssClass="table-container" Visible="false">
            <asp:GridView ID="gvCitizens" runat="server" AutoGenerateColumns="False" 
                CssClass="users-table" OnRowCommand="gvCitizens_RowCommand"
                EmptyDataText="No citizens found" ShowHeaderWhenEmpty="true">
                <Columns>
                    <asp:TemplateField HeaderText="ID">
                        <ItemTemplate>
                            <div class="d-flex align-items-center">
                                <div class="role-icon citizen">
                                    <i class='fas fa-user'></i>
                                </div>
                                <strong><%# Eval("UserId") %></strong>
                            </div>
                        </ItemTemplate>
                    </asp:TemplateField>
                    
                    <asp:BoundField HeaderText="Full Name" DataField="FullName" />
                    
                    <asp:TemplateField HeaderText="Contact">
                        <ItemTemplate>
                            <div class="d-flex flex-column">
                                <small><i class="fas fa-envelope me-1"></i><%# Eval("Email") != DBNull.Value ? Eval("Email") : "N/A" %></small>
                                <small><i class="fas fa-phone me-1"></i><%# Eval("Phone") %></small>
                            </div>
                        </ItemTemplate>
                    </asp:TemplateField>
                    
                    <asp:TemplateField HeaderText="Credits">
                        <ItemTemplate>
                            <div class="d-flex align-items-center">
                                <i class="fas fa-coins me-2 text-warning"></i>
                                <strong><%# string.Format("{0:N2}", Eval("XP_Credits")) %></strong>
                            </div>
                        </ItemTemplate>
                    </asp:TemplateField>
                    
                    <asp:TemplateField HeaderText="Status">
                        <ItemTemplate>
                            <div class="status-indicator">
                                <span class='status-dot <%# Convert.ToBoolean(Eval("IsVerified")) ? "active" : "inactive" %>'></span>
                                <span class='<%# Convert.ToBoolean(Eval("IsVerified")) ? "text-success" : "text-danger" %>'>
                                    <%# Convert.ToBoolean(Eval("IsVerified")) ? "Active" : "Inactive" %>
                                </span>
                            </div>
                        </ItemTemplate>
                    </asp:TemplateField>
                    
                    <asp:BoundField HeaderText="Joined" DataField="CreatedAt" DataFormatString="{0:yyyy-MM-dd}" />
                    
                    <asp:TemplateField HeaderText="Actions">
                        <ItemTemplate>
                            <div class="d-flex gap-2">
                                <asp:LinkButton ID="btnViewTable" runat="server" CssClass="btn btn-primary" 
                                    CommandName="ViewDetails" CommandArgument='<%# Eval("UserId") %>'
                                    ToolTip="View Details">
                                    <i class="fas fa-eye"></i>
                                </asp:LinkButton>
                                <asp:LinkButton ID="btnResetPassTable" runat="server" CssClass="btn btn-secondary" 
                                    CommandName="ResetPassword" CommandArgument='<%# Eval("UserId") + "|" + Eval("FullName") %>'
                                    ToolTip="Reset Password"
                                    OnClientClick='<%# "return confirm(\"Reset password for citizen \\\"" + Eval("FullName") + "\\\"?\")" %>'>
                                    <i class="fas fa-key"></i>
                                </asp:LinkButton>
                                <asp:LinkButton ID="btnToggleTable" runat="server" CssClass='<%# Convert.ToBoolean(Eval("IsVerified")) ? "btn btn-danger" : "btn btn-success" %>'
                                    CommandName="ToggleStatus" CommandArgument='<%# Eval("UserId") + "|" + Eval("FullName") + "|" + (Convert.ToBoolean(Eval("IsVerified")) ? "active" : "inactive") %>'
                                    ToolTip='<%# Convert.ToBoolean(Eval("IsVerified")) ? "Deactivate" : "Activate" %>'>
                                    <i class='fas <%# Convert.ToBoolean(Eval("IsVerified")) ? "fa-ban" : "fa-check" %>'></i>
                                </asp:LinkButton>
                            </div>
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
                <EmptyDataTemplate>
                    <div class="empty-state" style="margin: 2rem;">
                        <i class="fas fa-users-slash"></i>
                        <p>No citizens found matching your criteria</p>
                    </div>
                </EmptyDataTemplate>
            </asp:GridView>
        </asp:Panel>
    </div>

    <!-- View Citizen Modal -->
    <div id="divModalBackdrop" runat="server" class="modal-backdrop" style="display: none;"></div>
    
    <div id="divViewModal" runat="server" class="modal-dialog" style="display: none;">
        <div class="modal-header">
            <h3><i class="fas fa-user me-2"></i>Citizen Details</h3>
            <asp:LinkButton ID="btnCloseModal" runat="server" CssClass="modal-close" 
                OnClick="btnCloseModal_Click" CausesValidation="false">
                <i class="fas fa-times"></i>
            </asp:LinkButton>
        </div>
        <div class="modal-body">
            <div class="modal-form-row">
                <div class="modal-form-group">
                    <label class="modal-label"><i class="fas fa-user me-2"></i>Full Name</label>
                    <div class="modal-input-view"><asp:Literal ID="litViewFullName" runat="server" Text="-"></asp:Literal></div>
                </div>
                
                <div class="modal-form-group">
                    <label class="modal-label"><i class="fas fa-id-card me-2"></i>Citizen ID</label>
                    <div class="modal-input-view"><asp:Literal ID="litViewUserId" runat="server" Text="-"></asp:Literal></div>
                </div>
            </div>
            
            <div class="modal-form-row">
                <div class="modal-form-group">
                    <label class="modal-label"><i class="fas fa-envelope me-2"></i>Email</label>
                    <div class="modal-input-view"><asp:Literal ID="litViewEmail" runat="server" Text="-"></asp:Literal></div>
                </div>
                
                <div class="modal-form-group">
                    <label class="modal-label"><i class="fas fa-phone me-2"></i>Phone</label>
                    <div class="modal-input-view"><asp:Literal ID="litViewPhone" runat="server" Text="-"></asp:Literal></div>
                </div>
            </div>
            
            <div class="modal-form-row">
                <div class="modal-form-group">
                    <label class="modal-label"><i class="fas fa-coins me-2"></i>Credits</label>
                    <div class="modal-input-view badge badge-primary"><asp:Literal ID="litViewCredits" runat="server" Text="-"></asp:Literal></div>
                </div>
                
                <div class="modal-form-group">
                    <label class="modal-label"><i class="fas fa-user-check me-2"></i>Status</label>
                    <div class="modal-input-view">
                        <span class='status-badge <%# GetStatusClass(Convert.ToBoolean(Eval("IsVerified"))) %>'>
                            <asp:Literal ID="litViewStatus" runat="server" Text="-"></asp:Literal>
                        </span>
                    </div>
                </div>
            </div>
            
            <div class="modal-form-row">
                <div class="modal-form-group">
                    <label class="modal-label"><i class="fas fa-calendar-plus me-2"></i>Registration Date</label>
                    <div class="modal-input-view"><asp:Literal ID="litViewRegDate" runat="server" Text="-"></asp:Literal></div>
                </div>
                
                <div class="modal-form-group">
                    <label class="modal-label"><i class="fas fa-truck-loading me-2"></i>Total Pickups</label>
                    <div class="modal-input-view badge badge-info"><asp:Literal ID="litViewPickups" runat="server" Text="-"></asp:Literal></div>
                </div>
            </div>
            
            <div class="modal-form-group full-width">
                <label class="modal-label"><i class="fas fa-weight-hanging me-2"></i>Waste Collected</label>
                <div class="modal-input-view badge badge-success"><asp:Literal ID="litViewTotalWeight" runat="server" Text="-"></asp:Literal></div>
            </div>
            
            
        </div>
        <div class="modal-footer">
            <asp:LinkButton ID="btnCancelView" runat="server" CssClass="btn btn-secondary" 
                OnClick="btnCancelView_Click" CausesValidation="false">
                <i class="fas fa-times me-2"></i>Close
            </asp:LinkButton>
            
            <asp:LinkButton ID="btnResetPassword" runat="server" CssClass="btn btn-secondary" 
                OnClick="btnResetPassword_Click" CausesValidation="false">
                <i class="fas fa-key me-2"></i>Reset Password
            </asp:LinkButton>
        </div>
    </div>

    <!-- Hidden Fields -->
    <asp:HiddenField ID="hfViewUserId" runat="server" />
    <asp:HiddenField ID="hfViewUserName" runat="server" />
</asp:Content>