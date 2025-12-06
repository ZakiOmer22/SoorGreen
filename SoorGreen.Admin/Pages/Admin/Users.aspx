<%@ Page Title="Users" Language="C#" MasterPageFile="~/Pages/Admin/Site.master" AutoEventWireup="true" CodeFile="Users.aspx.cs" Inherits="SoorGreen.Admin.Admin.Users" %>

<asp:Content ID="Content3" ContentPlaceHolderID="HeadContent" runat="server">
    <link href='<%= ResolveUrl("~/Content/Pages/Admin/adminusers.css") %>' rel="stylesheet" />
</asp:Content>

<asp:Content ID="PageTitle" ContentPlaceHolderID="PageTitle" runat="server">
    <div class="d-flex align-items-center">
            <h1 class="h3 mb-0" style="color: var(--text-primary);">User Management</h1>
    </div>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <!-- Theme Toggle Button -->
    <button type="button" id="btnThemeToggleClient" class="theme-toggle" onclick="__doPostBack('ctl00$MainContent$btnThemeToggle', '')">
        <i class="fas fa-moon"></i>
    </button>
    <asp:Button ID="btnThemeToggle" runat="server" style="display:none;" OnClick="btnThemeToggle_Click" />

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
                    <label class="form-label"><i class="fas fa-search me-2"></i>Search Users</label>
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
                    <label class="form-label"><i class="fas fa-user-tag me-2"></i>User Type</label>
                    <div class="select-with-icon">
                        <asp:DropDownList ID="ddlType" runat="server" CssClass="form-control">
                            <asp:ListItem Value="all">All Types</asp:ListItem>
                            <asp:ListItem Value="CITZ">Citizen</asp:ListItem>
                            <asp:ListItem Value="R001">Collector</asp:ListItem>
                            <asp:ListItem Value="ADMIN">Admin</asp:ListItem>
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
                <div class="stats-label">Total Users</div>
            </div>
            <div class="stats-card active" style="flex: 1; min-width: 200px;">
                <div class="stats-icon">
                    <i class="fas fa-user-check"></i>
                </div>
                <div class="stats-number text-success" id="statActive" runat="server">0</div>
                <div class="stats-label">Active Users</div>
            </div>
            <div class="stats-card credits" style="flex: 1; min-width: 200px;">
                <div class="stats-icon">
                    <i class="fas fa-coins"></i>
                </div>
                <div class="stats-number text-warning" id="statCredits" runat="server">0.00</div>
                <div class="stats-label">Total Credits</div>
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
                    Showing <asp:Label ID="lblUserCount" runat="server" Text="0"></asp:Label> users
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
            <asp:Repeater ID="rptUsersGrid" runat="server" OnItemCommand="rptUsersGrid_ItemCommand" 
                OnItemDataBound="rptUsersGrid_ItemDataBound">
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
                            <span><i class="fas fa-user-tag me-2"></i>Role:</span>
                            <span class='user-role <%# GetRoleClass(Eval("RoleId").ToString()) %>'>
                                <i class='<%# GetRoleIcon(Eval("RoleId").ToString()) %> me-1'></i>
                                <%# GetRoleDisplayName(Eval("RoleId").ToString()) %>
                            </span>
                        </p>
                        
                        <p>
                            <span><i class="fas fa-calendar-plus me-2"></i>Joined:</span>
                            <span><%# Convert.ToDateTime(Eval("CreatedAt")).ToString("yyyy-MM-dd") %></span>
                        </p>
                        
                        <div class="card-stats">
                            <div class="stat-item">
                                <span class="stat-value"><asp:Label ID="lblReports" runat="server" Text="0"></asp:Label></span>
                                <span class="stat-label">Reports</span>
                            </div>
                            <div class="stat-item">
                                <span class="stat-value"><asp:Label ID="lblPickups" runat="server" Text="0"></asp:Label></span>
                                <span class="stat-label">Pickups</span>
                            </div>
                            <div class="stat-item">
                                <span class="stat-value"><asp:Label ID="lblKg" runat="server" Text="0.0"></asp:Label></span>
                                <span class="stat-label">Kg</span>
                            </div>
                        </div>
                        
                        <div class="action-buttons">
                            <asp:LinkButton ID="btnEdit" runat="server" CssClass="btn btn-edit" 
                                CommandName="Edit" CommandArgument='<%# Eval("UserId") %>'
                                ToolTip="Edit User">
                                <i class="fas fa-edit me-1"></i>Edit
                            </asp:LinkButton>
                            <asp:LinkButton ID="btnResetPassGrid" runat="server" CssClass="btn btn-secondary" 
                                CommandName="ResetPassword" CommandArgument='<%# Eval("UserId") + "|" + Eval("FullName") %>'
                                ToolTip="Reset Password"
                                OnClientClick='<%# "return confirm(\"Reset password for user \\\"" + Eval("FullName") + "\\\"?\")" %>'>
                                <i class="fas fa-key me-1"></i>Reset Pass
                            </asp:LinkButton>
                            <asp:LinkButton ID="btnDelete" runat="server" CssClass="btn btn-delete" 
                                CommandName="Delete" CommandArgument='<%# Eval("UserId") + "|" + Eval("FullName") %>'
                                ToolTip="Delete User"
                                OnClientClick='<%# "return confirm(\"Delete user \\\"" + Eval("FullName") + "\\\"?\")" %>'>
                                <i class="fas fa-trash me-1"></i>Delete
                            </asp:LinkButton>
                        </div>
                    </div>
                </ItemTemplate>
                <FooterTemplate>
                    <asp:Label ID="lblEmptyGrid" runat="server" Text="No users found" 
                        Visible='<%# rptUsersGrid.Items.Count == 0 %>' CssClass="empty-state">
                        <i class="fas fa-users-slash"></i>
                        <p>No users found matching your criteria</p>
                    </asp:Label>
                </FooterTemplate>
            </asp:Repeater>
        </asp:Panel>

        <!-- Table View -->
        <asp:Panel ID="pnlTableView" runat="server" CssClass="table-container" Visible="false">
            <asp:GridView ID="gvUsers" runat="server" AutoGenerateColumns="False" 
                CssClass="users-table" OnRowCommand="gvUsers_RowCommand" 
                EmptyDataText="No users found" ShowHeaderWhenEmpty="true">
                <Columns>
                    <asp:TemplateField HeaderText="ID">
                        <ItemTemplate>
                            <div class="d-flex align-items-center">
                                <div class="role-icon <%# GetRoleClass(Eval("RoleId").ToString()) %>">
                                    <i class='<%# GetRoleIcon(Eval("RoleId").ToString()) %>'></i>
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
                    
                    <asp:TemplateField HeaderText="Role">
                        <ItemTemplate>
                            <span class='user-role <%# GetRoleClass(Eval("RoleId").ToString()) %>'>
                                <i class='<%# GetRoleIcon(Eval("RoleId").ToString()) %> me-1'></i>
                                <%# GetRoleDisplayName(Eval("RoleId").ToString()) %>
                            </span>
                        </ItemTemplate>
                    </asp:TemplateField>
                    
                    <asp:BoundField HeaderText="Joined" DataField="CreatedAt" DataFormatString="{0:yyyy-MM-dd}" />
                    
                    <asp:TemplateField HeaderText="Actions">
                        <ItemTemplate>
                            <div class="d-flex gap-2">
                                <asp:LinkButton ID="btnEditTable" runat="server" CssClass="btn btn-edit" 
                                    CommandName="Edit" CommandArgument='<%# Eval("UserId") %>'
                                    ToolTip="Edit User">
                                    <i class="fas fa-edit"></i>
                                </asp:LinkButton>
                                <asp:LinkButton ID="btnResetPassTable" runat="server" CssClass="btn btn-secondary" 
                                    CommandName="ResetPassword" CommandArgument='<%# Eval("UserId") + "|" + Eval("FullName") %>'
                                    ToolTip="Reset Password"
                                    OnClientClick='<%# "return confirm(\"Reset password for user \\\"" + Eval("FullName") + "\\\"?\")" %>'>
                                    <i class="fas fa-key"></i>
                                </asp:LinkButton>
                                <asp:LinkButton ID="btnDeleteTable" runat="server" CssClass="btn btn-delete" 
                                    CommandName="Delete" CommandArgument='<%# Eval("UserId") + "|" + Eval("FullName") %>'
                                    ToolTip="Delete User"
                                    OnClientClick='<%# "return confirm(\"Delete user \\\"" + Eval("FullName") + "\\\"?\")" %>'>
                                    <i class="fas fa-trash"></i>
                                </asp:LinkButton>
                            </div>
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
                <EmptyDataTemplate>
                    <div class="empty-state" style="margin: 2rem;">
                        <i class="fas fa-users-slash"></i>
                        <p>No users found matching your criteria</p>
                    </div>
                </EmptyDataTemplate>
            </asp:GridView>
        </asp:Panel>
    </div>

    <!-- Edit User Modal -->
    <div id="divModalBackdrop" runat="server" class="modal-backdrop" style="display: none;"></div>
    
    <div id="divEditModal" runat="server" class="modal-dialog" style="display: none;">
        <div class="modal-header">
            <h3><i class="fas fa-user-edit me-2"></i>Edit User</h3>
            <asp:LinkButton ID="btnCloseModal" runat="server" CssClass="modal-close" 
                OnClick="btnCloseModal_Click" CausesValidation="false">
                <i class="fas fa-times"></i>
            </asp:LinkButton>
        </div>
        <div class="modal-body">
            <asp:HiddenField ID="hfModalUserId" runat="server" />
            
            <div class="modal-form-group">
                <label class="modal-label"><i class="fas fa-user me-2"></i>Full Name *</label>
                <asp:TextBox ID="txtEditFullName" runat="server" CssClass="modal-input" 
                    placeholder="Enter full name" required="true"></asp:TextBox>
                <asp:RequiredFieldValidator ID="rfvFullName" runat="server" 
                    ControlToValidate="txtEditFullName" Display="Dynamic"
                    ErrorMessage="Full name is required" 
                    CssClass="text-danger" ValidationGroup="EditUser"></asp:RequiredFieldValidator>
            </div>
            
            <div class="modal-form-group">
                <label class="modal-label"><i class="fas fa-envelope me-2"></i>Email</label>
                <asp:TextBox ID="txtEditEmail" runat="server" CssClass="modal-input" 
                    placeholder="Enter email address" TextMode="Email"></asp:TextBox>
                <asp:RegularExpressionValidator ID="revEmail" runat="server"
                    ControlToValidate="txtEditEmail" Display="Dynamic"
                    ValidationExpression="^\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*$"
                    ErrorMessage="Invalid email format" 
                    CssClass="text-danger" ValidationGroup="EditUser"></asp:RegularExpressionValidator>
            </div>
            
            <div class="modal-form-group">
                <label class="modal-label"><i class="fas fa-phone me-2"></i>Phone *</label>
                <asp:TextBox ID="txtEditPhone" runat="server" CssClass="modal-input" 
                    placeholder="Enter phone number" required="true"></asp:TextBox>
                <asp:RequiredFieldValidator ID="rfvPhone" runat="server" 
                    ControlToValidate="txtEditPhone" Display="Dynamic"
                    ErrorMessage="Phone is required" 
                    CssClass="text-danger" ValidationGroup="EditUser"></asp:RequiredFieldValidator>
            </div>
            
            <div class="modal-form-group">
                <label class="modal-label"><i class="fas fa-coins me-2"></i>Credits</label>
                <asp:TextBox ID="txtEditCredits" runat="server" CssClass="modal-input" 
                    placeholder="Enter credits" TextMode="Number" step="0.01"></asp:TextBox>
                <asp:RangeValidator ID="rvCredits" runat="server" 
                    ControlToValidate="txtEditCredits" Display="Dynamic"
                    Type="Double" MinimumValue="0" MaximumValue="1000000"
                    ErrorMessage="Credits must be between 0 and 1,000,000" 
                    CssClass="text-danger" ValidationGroup="EditUser"></asp:RangeValidator>
            </div>
            
            <div class="modal-form-group">
                <label class="modal-label"><i class="fas fa-user-check me-2"></i>Status</label>
                <asp:DropDownList ID="ddlEditStatus" runat="server" CssClass="modal-input">
                    <asp:ListItem Value="true">Active</asp:ListItem>
                    <asp:ListItem Value="false">Inactive</asp:ListItem>
                </asp:DropDownList>
            </div>
            
            <div class="modal-form-group">
                <label class="modal-label"><i class="fas fa-user-tag me-2"></i>User Type</label>
                <asp:DropDownList ID="ddlEditRole" runat="server" CssClass="modal-input">
                    <asp:ListItem Value="CITZ">Citizen</asp:ListItem>
                    <asp:ListItem Value="R001">Collector</asp:ListItem>
                    <asp:ListItem Value="ADMIN">Admin</asp:ListItem>
                </asp:DropDownList>
            </div>
        </div>
        <div class="modal-footer">
            <asp:LinkButton ID="btnCancelEdit" runat="server" CssClass="btn btn-secondary" 
                OnClick="btnCancelEdit_Click" CausesValidation="false">
                <i class="fas fa-times me-2"></i>Cancel
            </asp:LinkButton>
            
            <button type="button" class="btn btn-secondary btn-with-icon" onclick="__doPostBack('ctl00$MainContent$btnResetPassword', '')">
                <i class="fas fa-key me-2"></i>Reset Password
            </button>
            <asp:Button ID="btnResetPassword" runat="server" style="display:none;" OnClick="btnResetPassword_Click" />
            
            <asp:LinkButton ID="btnSaveEdit" runat="server" CssClass="btn btn-success btn-with-icon" 
                OnClick="btnSaveEdit_Click" ValidationGroup="EditUser">
                <i class="fas fa-save me-2"></i>Save Changes
            </asp:LinkButton>
        </div>
    </div>

    <!-- Hidden Fields -->
    <asp:HiddenField ID="hfCurrentPage" runat="server" Value="1" />
    <asp:HiddenField ID="hfEditUserId" runat="server" />
    <asp:Button ID="btnShowModal" runat="server" OnClick="btnShowModal_Click" 
        style="display:none;" CausesValidation="false" />
</asp:Content>