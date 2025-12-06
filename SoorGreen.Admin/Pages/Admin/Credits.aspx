<%@ Page Title="Credits Management" Language="C#" MasterPageFile="~/Pages/Admin/Site.master" AutoEventWireup="true" CodeFile="Credits.aspx.cs" Inherits="SoorGreen.Admin.Admin.Credits" %>

<asp:Content ID="Content3" ContentPlaceHolderID="HeadContent" runat="server">
    <link href='<%= ResolveUrl("~/Content/Pages/Admin/admincitizens.css") %>' rel="stylesheet" />
</asp:Content>

<asp:Content ID="PageTitle" ContentPlaceHolderID="PageTitle" runat="server">
    <div class="d-flex align-items-center">
        <h1 class="h3 mb-0" style="color: var(--text-primary);">Credits Management</h1>
    </div>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <!-- Message Panel -->
    <asp:Panel ID="pnlMessage" runat="server" CssClass="message-panel" Visible="false">
        <div class='message-alert' id="divMessage" runat="server">
            <i class='fas' id="iconMessage" runat="server"></i>
            <div>
                <strong>
                    <asp:Literal ID="litMessageTitle" runat="server"></asp:Literal></strong>
                <p class="mb-0">
                    <asp:Literal ID="litMessageText" runat="server"></asp:Literal></p>
            </div>
        </div>
    </asp:Panel>

    <!-- Adjust Credits Modal -->
    <div class="modal fade" id="adjustCreditsModal" tabindex="-1" role="dialog" aria-hidden="true">
        <div class="modal-dialog modal-lg" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">
                        <i class="fas fa-coins me-2"></i>Adjust User Credits
                    </h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <asp:HiddenField ID="hdnUserId" runat="server" />

                    <div class="row">
                        <div class="col-md-6">
                            <h6 class="mb-3 border-bottom pb-2"><i class="fas fa-user me-2"></i>User Information</h6>

                            <div class="mb-3">
                                <label class="form-label"><i class="fas fa-id-card me-2"></i>User ID</label>
                                <asp:TextBox ID="txtUserId" runat="server" CssClass="form-control" ReadOnly="true"></asp:TextBox>
                            </div>

                            <div class="mb-3">
                                <label class="form-label"><i class="fas fa-user-circle me-2"></i>Full Name</label>
                                <asp:TextBox ID="txtUserName" runat="server" CssClass="form-control" ReadOnly="true"></asp:TextBox>
                            </div>

                            <div class="mb-3">
                                <label class="form-label"><i class="fas fa-phone me-2"></i>Phone Number</label>
                                <asp:TextBox ID="txtUserPhone" runat="server" CssClass="form-control" ReadOnly="true"></asp:TextBox>
                            </div>

                            <div class="mb-3">
                                <label class="form-label"><i class="fas fa-envelope me-2"></i>Email Address</label>
                                <asp:TextBox ID="txtUserEmail" runat="server" CssClass="form-control" ReadOnly="true"></asp:TextBox>
                            </div>
                        </div>

                        <div class="col-md-6">
                            <h6 class="mb-3 border-bottom pb-2"><i class="fas fa-wallet me-2"></i>Current Balance</h6>

                            <div class="mb-3">
                                <label class="form-label"><i class="fas fa-coins me-2"></i>Current Credits</label>
                                <div class="input-group">
                                    <span class="input-group-text">$</span>
                                    <asp:TextBox ID="txtCurrentBalance" runat="server" CssClass="form-control" ReadOnly="true"></asp:TextBox>
                                </div>
                            </div>

                            <div class="mb-3">
                                <label class="form-label"><i class="fas fa-calendar-alt me-2"></i>Last Activity</label>
                                <asp:TextBox ID="txtLastActivity" runat="server" CssClass="form-control" ReadOnly="true"></asp:TextBox>
                            </div>

                            <div class="mb-3">
                                <label class="form-label"><i class="fas fa-calendar me-2"></i>Member Since</label>
                                <asp:TextBox ID="txtMemberSince" runat="server" CssClass="form-control" ReadOnly="true"></asp:TextBox>
                            </div>

                            <div class="mb-3">
                                <label class="form-label"><i class="fas fa-check-circle me-2"></i>Verification Status</label>
                                <asp:TextBox ID="txtVerificationStatus" runat="server" CssClass="form-control" ReadOnly="true"></asp:TextBox>
                            </div>

                            <div class="mb-3">
                                <label class="form-label"><i class="fas fa-star me-2"></i>Role</label>
                                <asp:TextBox ID="txtUserRole" runat="server" CssClass="form-control" ReadOnly="true"></asp:TextBox>
                            </div>
                        </div>
                    </div>

                    <!-- Adjustment Section -->
                    <div class="mt-4">
                        <h6 class="mb-3 border-bottom pb-2"><i class="fas fa-sliders-h me-2"></i>Credit Adjustment</h6>

                        <div class="row">
                            <div class="col-md-4">
                                <div class="mb-3">
                                    <label class="form-label"><i class="fas fa-exchange-alt me-2"></i>Adjustment Type</label>
                                    <asp:DropDownList ID="ddlAdjustmentType" runat="server" CssClass="form-control">
                                        <asp:ListItem Value="Add">Add Credits</asp:ListItem>
                                        <asp:ListItem Value="Deduct">Deduct Credits</asp:ListItem>
                                        <asp:ListItem Value="Set">Set Balance To</asp:ListItem>
                                    </asp:DropDownList>
                                </div>
                            </div>

                            <div class="col-md-4">
                                <div class="mb-3">
                                    <label class="form-label"><i class="fas fa-money-bill-wave me-2"></i>Amount</label>
                                    <div class="input-group">
                                        <span class="input-group-text">$</span>
                                        <asp:TextBox ID="txtAdjustmentAmount" runat="server" CssClass="form-control"
                                            placeholder="0.00" TextMode="Number" step="0.01"></asp:TextBox>
                                    </div>
                                </div>
                            </div>

                            <div class="col-md-4">
                                <div class="mb-3">
                                    <label class="form-label"><i class="fas fa-project-diagram me-2"></i>Transaction Type</label>
                                    <asp:DropDownList ID="ddlTransactionType" runat="server" CssClass="form-control">
                                        <asp:ListItem Value="Adjustment">Manual Adjustment</asp:ListItem>
                                        <asp:ListItem Value="Bonus">Bonus</asp:ListItem>
                                        <asp:ListItem Value="Penalty">Penalty</asp:ListItem>
                                        <asp:ListItem Value="Correction">Correction</asp:ListItem>
                                        <asp:ListItem Value="Refund">Refund</asp:ListItem>
                                    </asp:DropDownList>
                                </div>
                            </div>
                        </div>

                        <div class="mb-3">
                            <label class="form-label"><i class="fas fa-sticky-note me-2"></i>Reason for Adjustment</label>
                            <asp:TextBox ID="txtAdjustmentReason" runat="server" CssClass="form-control"
                                placeholder="Enter reason for this credit adjustment..."
                                TextMode="MultiLine" Rows="3"></asp:TextBox>
                            <small class="form-text text-muted">This will be recorded in the transaction history</small>
                        </div>

                        <!-- Preview of new balance -->
                        <div class="alert alert-info" id="balancePreview" style="display: none;">
                            <i class="fas fa-calculator me-2"></i>
                            <strong>Balance Preview:</strong>
                            <span id="newBalanceText">New balance will be calculated after entering amount</span>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <asp:Button ID="btnApplyAdjustment" runat="server" CssClass="btn btn-primary"
                        Text="Apply Adjustment" OnClick="btnApplyAdjustment_Click"
                        OnClientClick="return validateAdjustment();" />
                </div>
            </div>
        </div>
    </div>

    <div class="users-container">
        <!-- Filter Card -->
        <div class="filter-card">
            <h5 class="mb-4"><i class="fas fa-sliders-h me-2"></i>Filter Users</h5>
            <div class="filter-group">
                <div class="form-group search-box">
                    <label class="form-label"><i class="fas fa-search me-2"></i>Search Users</label>
                    <div class="position-relative">
                        <i class="fas fa-search search-icon"></i>
                        <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control search-input"
                            placeholder="Search by name, phone, email, user ID..."></asp:TextBox>
                    </div>
                </div>
                <div class="form-group">
                    <label class="form-label"><i class="fas fa-star me-2"></i>Role</label>
                    <div class="select-with-icon">
                        <asp:DropDownList ID="ddlRoleFilter" runat="server" CssClass="form-control">
                            <asp:ListItem Value="all">All Roles</asp:ListItem>
                            <asp:ListItem Value="CITZ">Citizen</asp:ListItem>
                            <asp:ListItem Value="R001">Collector</asp:ListItem>
                            <asp:ListItem Value="ADM1">Admin</asp:ListItem>
                            <asp:ListItem Value="C001">Company</asp:ListItem>
                        </asp:DropDownList>
                        <i class="fas fa-chevron-down select-arrow"></i>
                    </div>
                </div>
                <div class="form-group">
                    <label class="form-label"><i class="fas fa-filter me-2"></i>Balance Range</label>
                    <div class="row g-2">
                        <div class="col">
                            <asp:TextBox ID="txtBalanceFrom" runat="server" CssClass="form-control"
                                placeholder="Min $" TextMode="Number" step="0.01"></asp:TextBox>
                        </div>
                        <div class="col">
                            <asp:TextBox ID="txtBalanceTo" runat="server" CssClass="form-control"
                                placeholder="Max $" TextMode="Number" step="0.01"></asp:TextBox>
                        </div>
                    </div>
                </div>
                <div class="form-group">
                    <label class="form-label"><i class="fas fa-check-circle me-2"></i>Verification Status</label>
                    <div class="select-with-icon">
                        <asp:DropDownList ID="ddlVerificationStatus" runat="server" CssClass="form-control">
                            <asp:ListItem Value="all">All Status</asp:ListItem>
                            <asp:ListItem Value="verified">Verified Only</asp:ListItem>
                            <asp:ListItem Value="unverified">Unverified Only</asp:ListItem>
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
        </div>

        <!-- Stats Cards -->
        <div class="d-flex gap-3 mb-4 flex-wrap">
            <div class="stats-card users" style="flex: 1; min-width: 200px;">
                <div class="stats-icon">
                    <i class="fas fa-users"></i>
                </div>
                <div class="stats-number" id="statTotalUsers" runat="server">0</div>
                <div class="stats-label">Total Users</div>
            </div>
            <div class="stats-card active" style="flex: 1; min-width: 200px;">
                <div class="stats-icon">
                    <i class="fas fa-coins"></i>
                </div>
                <div class="stats-number text-success" id="statTotalCredits" runat="server">$0.00</div>
                <div class="stats-label">Total Credits</div>
            </div>
            <div class="stats-card pickups" style="flex: 1; min-width: 200px;">
                <div class="stats-icon">
                    <i class="fas fa-user-check"></i>
                </div>
                <div class="stats-number text-primary" id="statVerifiedUsers" runat="server">0</div>
                <div class="stats-label">Verified Users</div>
            </div>
            <div class="stats-card waste" style="flex: 1; min-width: 200px;">
                <div class="stats-icon">
                    <i class="fas fa-crown"></i>
                </div>
                <div class="stats-number text-warning" id="statTopBalance" runat="server">$0.00</div>
                <div class="stats-label">Highest Balance</div>
            </div>
        </div>

        <!-- Quick Actions -->
        <div class="filter-card mb-4">
            <h5 class="mb-4"><i class="fas fa-bolt me-2"></i>Quick Actions</h5>
            <div class="d-flex flex-wrap gap-3">
                <button type="button" class="btn btn-warning btn-with-icon" onclick="showLowBalanceUsers()">
                    <i class="fas fa-exclamation-triangle me-2"></i>Low Balance (< $10)
                </button>
                <button type="button" class="btn btn-success btn-with-icon" onclick="showHighBalanceUsers()">
                    <i class="fas fa-crown me-2"></i>Top Balances (> $100)
                </button>
                <button type="button" class="btn btn-info btn-with-icon" onclick="showUnverifiedUsers()">
                    <i class="fas fa-user-times me-2"></i>Unverified Users
                </button>
                <button type="button" class="btn btn-primary btn-with-icon" onclick="__doPostBack('ctl00$MainContent$btnExportCSV', '')">
                    <i class="fas fa-file-export me-2"></i>Export Report
                </button>
                <button type="button" class="btn btn-secondary btn-with-icon" onclick="bulkCreditAction()">
                    <i class="fas fa-users-cog me-2"></i>Bulk Credit Action
                </button>
                <asp:Button ID="btnExportCSV" runat="server" Style="display: none;" OnClick="btnExportCSV_Click" />
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
                    Showing
                    <asp:Label ID="lblUserCount" runat="server" Text="0"></asp:Label>
                    users
                </div>
            </div>
            <div class="d-flex gap-2">
                <button type="button" class="btn btn-secondary btn-with-icon" onclick="__doPostBack('ctl00$MainContent$btnRefresh', '')">
                    <i class="fas fa-sync-alt me-2"></i>Refresh
                </button>
                <asp:Button ID="btnRefresh" runat="server" Style="display: none;" OnClick="btnRefresh_Click" />

                <button type="button" class="btn btn-secondary btn-with-icon" onclick="__doPostBack('ctl00$MainContent$btnClearFilters', '')">
                    <i class="fas fa-times me-2"></i>Clear Filters
                </button>
                <asp:Button ID="btnClearFilters" runat="server" Style="display: none;" OnClick="btnClearFilters_Click" />
            </div>
        </div>

        <!-- Grid View -->
        <asp:Panel ID="pnlGridView" runat="server" CssClass="users-grid">
            <asp:Repeater ID="rptUsersGrid" runat="server"
                OnItemDataBound="rptUsersGrid_ItemDataBound">
                <ItemTemplate>
                    <div class="user-card credit-card">
                        <div class="d-flex justify-content-between align-items-start mb-2">
                            <h5>
                                <i class="fas fa-user-circle me-2"></i><%# Eval("FullName") %>
                            </h5>
                            <span class="badge role-badge <%# GetRoleBadgeClass(Eval("RoleName").ToString()) %>">
                                <%# Eval("RoleName") %>
                            </span>
                        </div>

                        <div class="mb-3">
                            <span class="text-muted small">
                                <i class="fas fa-phone me-1"></i><%# Eval("Phone") %>
                                <i class="fas fa-envelope ms-2 me-1"></i>
                                <%# string.IsNullOrEmpty(Eval("Email").ToString()) ? "No email" : Eval("Email") %>
                            </span>
                        </div>

                        <div class="balance-info">
                            <div class="balance-amount <%# GetBalanceColorClass(Convert.ToDecimal(Eval("XP_Credits"))) %>">
                                <i class="fas fa-wallet me-2"></i>
                                <span class="balance-value">$<%# Convert.ToDecimal(Eval("XP_Credits")).ToString("N2") %></span>
                            </div>
                            <div class="balance-stats">
                                <div class="stat">
                                    <span class="stat-label">Transactions</span>
                                    <span class="stat-value"><%# GetTransactionCount(Eval("UserId").ToString()) %></span>
                                </div>
                                <div class="stat">
                                    <span class="stat-label">Redemptions</span>
                                    <span class="stat-value"><%# GetRedemptionCount(Eval("UserId").ToString()) %></span>
                                </div>
                                <div class="stat">
                                    <span class="stat-label">Reports</span>
                                    <span class="stat-value"><%# GetWasteReportCount(Eval("UserId").ToString()) %></span>
                                </div>
                            </div>
                        </div>

                        <div class="user-meta">
                            <div class="meta-item">
                                <i class="fas fa-calendar-alt"></i>
                                <span>Member since <%# Convert.ToDateTime(Eval("CreatedAt")).ToString("MMM yyyy") %></span>
                            </div>
                            <div class="meta-item">
                                <i class="fas fa-clock"></i>
                                <span>Last login: <%# GetLastLoginDisplay(Eval("LastLogin")) %></span>
                            </div>
                            <div class="meta-item">
                                <i class="fas fa-check-circle"></i>
                                <span class="<%# Convert.ToBoolean(Eval("IsVerified")) ? "text-success" : "text-warning" %>">
                                    <%# Convert.ToBoolean(Eval("IsVerified")) ? "Verified" : "Unverified" %>
                                </span>
                            </div>
                        </div>

                        <div class="action-buttons">
                            <button type="button" class="btn btn-primary" onclick='adjustUserCredits("<%# Eval("UserId") %>")'>
                                <i class="fas fa-sliders-h me-1"></i>Adjust Credits
                            </button>
                            <button type="button" class="btn btn-info" onclick='viewUserTransactions("<%# Eval("UserId") %>")'>
                                <i class="fas fa-history me-1"></i>History
                            </button>
                            <button type="button" class="btn btn-secondary" onclick='viewUserDetails("<%# Eval("UserId") %>")'>
                                <i class="fas fa-eye me-1"></i>Details
                            </button>
                        </div>
                    </div>
                </ItemTemplate>
                <FooterTemplate>
                    <asp:Label ID="lblEmptyGrid" runat="server" Text="No users found"
                        Visible='<%# rptUsersGrid.Items.Count == 0 %>' CssClass="empty-state">
                        <i class="fas fa-user-slash"></i>
                        <p>No users found matching your criteria</p>
                    </asp:Label>
                </FooterTemplate>
            </asp:Repeater>
        </asp:Panel>

        <!-- Table View -->
        <asp:Panel ID="pnlTableView" runat="server" CssClass="table-container" Visible="false">
            <asp:GridView ID="gvUsers" runat="server" AutoGenerateColumns="False"
                CssClass="users-table"
                EmptyDataText="No users found" ShowHeaderWhenEmpty="true">
                <Columns>
                    <asp:TemplateField HeaderText="User Information">
                        <ItemTemplate>
                            <div class="d-flex align-items-center">
                                <div class="role-icon <%# GetRoleIconClass(Eval("RoleName").ToString()) %>">
                                    <i class='<%# GetRoleIcon(Eval("RoleName").ToString()) %>'></i>
                                </div>
                                <div>
                                    <strong><%# Eval("FullName") %></strong><br>
                                    <small class="text-muted"><%# Eval("Phone") %></small><br>
                                    <small class="text-muted"><%# Eval("Email") %></small>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="Role & Status">
                        <ItemTemplate>
                            <span class='badge <%# GetRoleBadgeClass(Eval("RoleName").ToString()) %>'>
                                <%# Eval("RoleName") %>
                            </span>
                            <div class="small mt-1">
                                <span class='<%# Convert.ToBoolean(Eval("IsVerified")) ? "text-success" : "text-warning" %>'>
                                    <i class='fas <%# Convert.ToBoolean(Eval("IsVerified")) ? "fa-check-circle" : "fa-times-circle" %>'></i>
                                    <%# Convert.ToBoolean(Eval("IsVerified")) ? "Verified" : "Unverified" %>
                                </span>
                            </div>
                            <small class="text-muted">
                                <%# Convert.ToDateTime(Eval("CreatedAt")).ToString("MM/dd/yyyy") %>
                            </small>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="Balance">
                        <ItemTemplate>
                            <div class='balance-display <%# GetBalanceColorClass(Convert.ToDecimal(Eval("XP_Credits"))) %>'>
                                <i class="fas fa-coins me-1"></i>
                                <strong>$<%# Convert.ToDecimal(Eval("XP_Credits")).ToString("N2") %></strong>
                            </div>
                            <div class="small text-muted mt-1">
                                Last login: <%# GetLastLoginDisplay(Eval("LastLogin")) %>
                            </div>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="Activity Stats">
                        <ItemTemplate>
                            <div class="d-flex flex-wrap gap-2">
                                <span class="badge badge-light">
                                    <i class="fas fa-exchange-alt"></i>
                                    <%# GetTransactionCount(Eval("UserId").ToString()) %> trans
                                </span>
                                <span class="badge badge-light">
                                    <i class="fas fa-money-check-alt"></i>
                                    <%# GetRedemptionCount(Eval("UserId").ToString()) %> redeems
                                </span>
                                <span class="badge badge-light">
                                    <i class="fas fa-trash"></i>
                                    <%# GetWasteReportCount(Eval("UserId").ToString()) %> reports
                                </span>
                            </div>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="Actions">
                        <ItemTemplate>
                            <div class="d-flex flex-wrap gap-2">
                                <button type="button" class="btn btn-primary btn-sm" onclick='adjustUserCredits("<%# Eval("UserId") %>")'>
                                    <i class="fas fa-sliders-h"></i>
                                </button>
                                <button type="button" class="btn btn-info btn-sm" onclick='viewUserTransactions("<%# Eval("UserId") %>")'>
                                    <i class="fas fa-history"></i>
                                </button>
                                <button type="button" class="btn btn-secondary btn-sm" onclick='viewUserDetails("<%# Eval("UserId") %>")'>
                                    <i class="fas fa-eye"></i>
                                </button>
                                <button type="button" class="btn btn-warning btn-sm" onclick='toggleVerification("<%# Eval("UserId") %>", <%# Convert.ToBoolean(Eval("IsVerified")) ? "true" : "false" %>)'>
                                    <i class='fas <%# Convert.ToBoolean(Eval("IsVerified")) ? "fa-user-times" : "fa-user-check" %>'></i>
                                </button>
                            </div>
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
                <EmptyDataTemplate>
                    <div class="empty-state" style="margin: 2rem;">
                        <i class="fas fa-user-slash"></i>
                        <p>No users found matching your criteria</p>
                    </div>
                </EmptyDataTemplate>
            </asp:GridView>
        </asp:Panel>
    </div>

    <!-- JavaScript functions -->
    <script>
        function adjustUserCredits(userId) {
            document.getElementById('<%= hdnUserId.ClientID %>').value = userId;
            __doPostBack('ctl00$MainContent$hdnUserId', 'adjust_' + userId);
        }

        function viewUserTransactions(userId) {
            window.location.href = 'Transactions.aspx?userId=' + userId;
        }

        function viewUserDetails(userId) {
            window.location.href = 'Citizens.aspx?userId=' + userId;
        }

        function toggleVerification(userId, isVerified) {
            if (confirm('Are you sure you want to ' + (isVerified === 'true' ? 'unverify' : 'verify') + ' this user?')) {
                __doPostBack('ctl00$MainContent$hdnUserId', 'verify_' + userId + '_' + isVerified);
            }
        }

        function showLowBalanceUsers() {
            document.getElementById('<%= txtBalanceFrom.ClientID %>').value = '';
        document.getElementById('<%= txtBalanceTo.ClientID %>').value = '10';
            __doPostBack('ctl00$MainContent$btnApplyFilters', '');
        }

        function showHighBalanceUsers() {
            document.getElementById('<%= txtBalanceFrom.ClientID %>').value = '100';
        document.getElementById('<%= txtBalanceTo.ClientID %>').value = '';
            __doPostBack('ctl00$MainContent$btnApplyFilters', '');
        }

        function showUnverifiedUsers() {
            document.getElementById('<%= ddlVerificationStatus.ClientID %>').value = 'unverified';
            __doPostBack('ctl00$MainContent$btnApplyFilters', '');
        }

        function bulkCreditAction() {
            alert('Bulk credit action functionality would open a new interface for selecting multiple users.');
            // This would open a modal for selecting multiple users and applying bulk actions
        }

        function validateAdjustment() {
            var amount = document.getElementById('<%= txtAdjustmentAmount.ClientID %>').value;
            if (!amount || amount <= 0) {
                alert('Please enter a valid amount greater than 0.');
                return false;
            }
            return confirm('Are you sure you want to apply this credit adjustment?');
        }

        // Real-time balance preview
        document.getElementById('<%= txtAdjustmentAmount.ClientID %>')?.addEventListener('input', function () {
            updateBalancePreview();
        });

        document.getElementById('<%= ddlAdjustmentType.ClientID %>')?.addEventListener('change', function () {
            updateBalancePreview();
        });

        function updateBalancePreview() {
            var currentBalance = parseFloat(document.getElementById('<%= txtCurrentBalance.ClientID %>')?.value.replace('$', '') || 0);
        var adjustmentType = document.getElementById('<%= ddlAdjustmentType.ClientID %>')?.value;
        var amount = parseFloat(document.getElementById('<%= txtAdjustmentAmount.ClientID %>')?.value || 0);

            if (amount > 0) {
                var newBalance = currentBalance;
                if (adjustmentType === 'Add') {
                    newBalance = currentBalance + amount;
                } else if (adjustmentType === 'Deduct') {
                    newBalance = currentBalance - amount;
                } else if (adjustmentType === 'Set') {
                    newBalance = amount;
                }

                var preview = document.getElementById('balancePreview');
                var text = document.getElementById('newBalanceText');

                text.innerHTML = 'Current: $' + currentBalance.toFixed(2) +
                    ' → New: $' + newBalance.toFixed(2) +
                    ' (Change: ' + (newBalance - currentBalance > 0 ? '+' : '') +
                    (newBalance - currentBalance).toFixed(2) + ')';
                preview.style.display = 'block';
            }
        }

        // Run on page load
        document.addEventListener('DOMContentLoaded', function () {
            // Ensure text visibility
            document.querySelectorAll('.credit-card *').forEach(element => {
                element.style.overflow = 'visible';
                element.style.whiteSpace = 'normal';
                element.style.wordWrap = 'break-word';
            });

            document.querySelectorAll('.users-table td, .users-table th').forEach(cell => {
                cell.style.whiteSpace = 'normal';
                cell.style.wordWrap = 'break-word';
                cell.style.maxWidth = 'none';
            });
        });
    </script>
</asp:Content>
