<%@ Page Title="Rewards System" Language="C#" MasterPageFile="~/Pages/Admin/Site.master" AutoEventWireup="true" Inherits="SoorGreen.Admin.Admin.Rewards" Codebehind="Rewards.aspx.cs" %>

<asp:Content ID="Content3" ContentPlaceHolderID="HeadContent" runat="server">
    <link href='<%= ResolveUrl("~/Content/Pages/Admin/admincitizens.css") %>' rel="stylesheet" />
</asp:Content>

<asp:Content ID="PageTitle" ContentPlaceHolderID="PageTitle" runat="server">
    <div class="d-flex align-items-center">
        <h1 class="h3 mb-0" style="color: var(--text-primary);">Rewards & Credits Management</h1>
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

    <!-- Add Credit Modal -->
    <div class="modal fade" id="addCreditModal" tabindex="-1" role="dialog" aria-hidden="true">
        <div class="modal-dialog" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">
                        <i class="fas fa-plus-circle me-2"></i>Add Manual Credits
                    </h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <asp:HiddenField ID="hdnUserId" runat="server" />
                    
                    <div class="mb-3">
                        <label class="form-label"><i class="fas fa-user me-2"></i>Select User</label>
                        <asp:DropDownList ID="ddlUser" runat="server" CssClass="form-control" required>
                        </asp:DropDownList>
                    </div>
                    
                    <div class="mb-3">
                        <label class="form-label"><i class="fas fa-coins me-2"></i>Amount</label>
                        <div class="input-group">
                            <span class="input-group-text">$</span>
                            <asp:TextBox ID="txtAmount" runat="server" CssClass="form-control" 
                                placeholder="0.00" TextMode="Number" step="0.01" required></asp:TextBox>
                        </div>
                        <small class="form-text text-muted">Enter credit amount to add (positive) or deduct (negative)</small>
                    </div>
                    
                    <div class="mb-3">
                        <label class="form-label"><i class="fas fa-tag me-2"></i>Type</label>
                        <asp:DropDownList ID="ddlCreditType" runat="server" CssClass="form-control">
                            <asp:ListItem Value="Credit">Credit</asp:ListItem>
                            <asp:ListItem Value="Bonus">Bonus</asp:ListItem>
                            <asp:ListItem Value="Penalty">Penalty</asp:ListItem>
                            <asp:ListItem Value="Adjustment">Adjustment</asp:ListItem>
                            <asp:ListItem Value="Referral">Referral Bonus</asp:ListItem>
                        </asp:DropDownList>
                    </div>
                    
                    <div class="mb-3">
                        <label class="form-label"><i class="fas fa-sticky-note me-2"></i>Description/Reference</label>
                        <asp:TextBox ID="txtReference" runat="server" CssClass="form-control" 
                            placeholder="e.g., Manual adjustment, Good behavior, etc."></asp:TextBox>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <asp:Button ID="btnAddCredits" runat="server" CssClass="btn btn-primary" 
                        Text="Add Credits" OnClick="btnAddCredits_Click" />
                </div>
            </div>
        </div>
    </div>

    <!-- Process Redemption Modal -->
    <div class="modal fade" id="processRedemptionModal" tabindex="-1" role="dialog" aria-hidden="true">
        <div class="modal-dialog" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">
                        <i class="fas fa-check-circle me-2"></i>Process Redemption
                    </h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <asp:HiddenField ID="hdnRedemptionId" runat="server" />
                    
                    <div class="mb-3">
                        <label class="form-label"><i class="fas fa-hashtag me-2"></i>Redemption ID</label>
                        <asp:TextBox ID="txtRedemptionId" runat="server" CssClass="form-control" ReadOnly="true"></asp:TextBox>
                    </div>
                    
                    <div class="mb-3">
                        <label class="form-label"><i class="fas fa-user me-2"></i>User</label>
                        <asp:TextBox ID="txtRedemptionUser" runat="server" CssClass="form-control" ReadOnly="true"></asp:TextBox>
                    </div>
                    
                    <div class="mb-3">
                        <label class="form-label"><i class="fas fa-money-bill-wave me-2"></i>Amount</label>
                        <div class="input-group">
                            <span class="input-group-text">$</span>
                            <asp:TextBox ID="txtRedemptionAmount" runat="server" CssClass="form-control" ReadOnly="true"></asp:TextBox>
                        </div>
                    </div>
                    
                    <div class="mb-3">
                        <label class="form-label"><i class="fas fa-wallet me-2"></i>Payment Method</label>
                        <asp:TextBox ID="txtPaymentMethod" runat="server" CssClass="form-control" ReadOnly="true"></asp:TextBox>
                    </div>
                    
                    <div class="mb-3">
                        <label class="form-label"><i class="fas fa-credit-card me-2"></i>Payment Details</label>
                        <asp:TextBox ID="txtPaymentDetails" runat="server" CssClass="form-control" 
                            placeholder="Enter transaction ID, bank details, etc." TextMode="MultiLine" Rows="3"></asp:TextBox>
                    </div>
                    
                    <div class="mb-3">
                        <label class="form-label"><i class="fas fa-sticky-note me-2"></i>Admin Notes</label>
                        <asp:TextBox ID="txtAdminNotes" runat="server" CssClass="form-control" 
                            placeholder="Any notes about this transaction..." TextMode="MultiLine" Rows="2"></asp:TextBox>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <asp:Button ID="btnApproveRedemption" runat="server" CssClass="btn btn-success" 
                        Text="Approve & Pay" OnClick="btnApproveRedemption_Click" />
                    <asp:Button ID="btnRejectRedemption" runat="server" CssClass="btn btn-danger" 
                        Text="Reject" OnClick="btnRejectRedemption_Click" 
                        OnClientClick="return confirm('Are you sure you want to reject this redemption request?');" />
                </div>
            </div>
        </div>
    </div>

    <div class="users-container">
        <!-- Filter Card -->
        <div class="filter-card">
            <h5 class="mb-4"><i class="fas fa-sliders-h me-2"></i>Filter Options</h5>
            <div class="filter-group">
                <div class="form-group search-box">
                    <label class="form-label"><i class="fas fa-search me-2"></i>Search</label>
                    <div class="position-relative">
                        <i class="fas fa-search search-icon"></i>
                        <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control search-input" 
                            placeholder="Search by user name, ID, reference..."></asp:TextBox>
                    </div>
                </div>
                <div class="form-group">
                    <label class="form-label"><i class="fas fa-filter me-2"></i>View</label>
                    <div class="select-with-icon">
                        <asp:DropDownList ID="ddlView" runat="server" CssClass="form-control" AutoPostBack="true" OnSelectedIndexChanged="ddlView_SelectedIndexChanged">
                            <asp:ListItem Value="credits">Credit Transactions</asp:ListItem>
                            <asp:ListItem Value="redemptions">Redemption Requests</asp:ListItem>
                            <asp:ListItem Value="users">User Balances</asp:ListItem>
                        </asp:DropDownList>
                        <i class="fas fa-chevron-down select-arrow"></i>
                    </div>
                </div>
                <div class="form-group">
                    <label class="form-label"><i class="fas fa-calendar-alt me-2"></i>Date Range</label>
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
                    <div class="d-flex gap-2">
                        <button type="button" class="btn btn-primary btn-with-icon" onclick="__doPostBack('ctl00$MainContent$btnApplyFilters', '')">
                            <i class="fas fa-filter me-2"></i>Apply Filters
                        </button>
                        <asp:Button ID="btnApplyFilters" runat="server" style="display:none;" OnClick="btnApplyFilters_Click" />
                        
                        <button type="button" class="btn btn-success btn-with-icon" onclick="showAddCreditModal()">
                            <i class="fas fa-plus-circle me-2"></i>Add Credits
                        </button>
                    </div>
                </div>
            </div>
        </div>

        <!-- Stats Cards -->
        <div class="d-flex gap-3 mb-4 flex-wrap">
            <div class="stats-card users" style="flex: 1; min-width: 200px;">
                <div class="stats-icon">
                    <i class="fas fa-coins"></i>
                </div>
                <div class="stats-number text-success" id="statTotalCredits" runat="server">$0.00</div>
                <div class="stats-label">Total Credits Issued</div>
            </div>
            <div class="stats-card active" style="flex: 1; min-width: 200px;">
                <div class="stats-icon">
                    <i class="fas fa-users"></i>
                </div>
                <div class="stats-number" id="statActiveUsers" runat="server">0</div>
                <div class="stats-label">Users with Credits</div>
            </div>
            <div class="stats-card pickups" style="flex: 1; min-width: 200px;">
                <div class="stats-icon">
                    <i class="fas fa-clock"></i>
                </div>
                <div class="stats-number text-warning" id="statPendingRedemptions" runat="server">0</div>
                <div class="stats-label">Pending Redemptions</div>
            </div>
            <div class="stats-card waste" style="flex: 1; min-width: 200px;">
                <div class="stats-icon">
                    <i class="fas fa-money-check-alt"></i>
                </div>
                <div class="stats-number text-primary" id="statTotalRedeemed" runat="server">$0.00</div>
                <div class="stats-label">Total Redeemed</div>
            </div>
        </div>

        <!-- Quick Summary -->
        <div class="filter-card mb-4">
            <h5 class="mb-4"><i class="fas fa-chart-pie me-2"></i>Credits Summary</h5>
            <div class="row">
                <div class="col-md-3 mb-3">
                    <div class="summary-card">
                        <div class="summary-icon bg-success">
                            <i class="fas fa-arrow-up"></i>
                        </div>
                        <div class="summary-content">
                            <div class="summary-value" id="summaryEarned" runat="server">$0.00</div>
                            <div class="summary-label">Total Earned</div>
                        </div>
                    </div>
                </div>
                <div class="col-md-3 mb-3">
                    <div class="summary-card">
                        <div class="summary-icon bg-warning">
                            <i class="fas fa-arrow-down"></i>
                        </div>
                        <div class="summary-content">
                            <div class="summary-value" id="summaryRedeemed" runat="server">$0.00</div>
                            <div class="summary-label">Total Redeemed</div>
                        </div>
                    </div>
                </div>
                <div class="col-md-3 mb-3">
                    <div class="summary-card">
                        <div class="summary-icon bg-info">
                            <i class="fas fa-balance-scale"></i>
                        </div>
                        <div class="summary-content">
                            <div class="summary-value" id="summaryPending" runat="server">$0.00</div>
                            <div class="summary-label">Pending Redemptions</div>
                        </div>
                    </div>
                </div>
                <div class="col-md-3 mb-3">
                    <div class="summary-card">
                        <div class="summary-icon bg-primary">
                            <i class="fas fa-wallet"></i>
                        </div>
                        <div class="summary-content">
                            <div class="summary-value" id="summaryAvailable" runat="server">$0.00</div>
                            <div class="summary-label">Available Credits</div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- View Controls -->
        <div class="view-controls">
            <div class="d-flex align-items-center gap-3 flex-wrap">
                <div class="view-options">
                    <asp:LinkButton ID="btnCardView" runat="server" CssClass="view-btn active" 
                        OnClick="btnCardView_Click" CausesValidation="false">
                        <i class="fas fa-th-large me-2"></i>Card View
                    </asp:LinkButton>
                    <asp:LinkButton ID="btnTableView" runat="server" CssClass="view-btn" 
                        OnClick="btnTableView_Click" CausesValidation="false">
                        <i class="fas fa-table me-2"></i>Table View
                    </asp:LinkButton>
                </div>
                <div class="page-info">
                    <i class="fas" id="viewIcon" runat="server"></i>
                    Showing <asp:Label ID="lblRecordCount" runat="server" Text="0"></asp:Label> records
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

        <!-- Credits Transactions View -->
        <asp:Panel ID="pnlCreditsView" runat="server">
            <!-- Card View -->
            <asp:Panel ID="pnlCreditsCardView" runat="server" CssClass="users-grid">
                <asp:Repeater ID="rptCreditsGrid" runat="server" 
                    OnItemDataBound="rptCreditsGrid_ItemDataBound">
                    <ItemTemplate>
                        <div class="user-card">
                            <div class="d-flex justify-content-between align-items-start mb-2">
                                <h5>
                                    <i class="fas fa-coins me-2"></i>Transaction
                                </h5>
                                <span class="badge <%# GetTransactionBadgeClass(Eval("Type").ToString()) %>">
                                    <%# Eval("Type") %>
                                </span>
                            </div>
                            
                            <div class="mb-3">
                                <span class="text-muted small">
                                    <i class="fas fa-calendar me-1"></i>
                                    <%# Convert.ToDateTime(Eval("CreatedAt")).ToString("MMM dd, yyyy HH:mm") %>
                                </span>
                            </div>
                            
                            <div class="collection-info">
                                <div class="info-row">
                                    <i class="fas fa-user"></i>
                                    <div>
                                        <span class="label">User</span>
                                        <span class="value"><%# Eval("UserName") %></span>
                                    </div>
                                </div>
                                
                                <div class="info-row">
                                    <i class="fas fa-hashtag"></i>
                                    <div>
                                        <span class="label">Transaction ID</span>
                                        <span class="value"><%# Eval("RewardId") %></span>
                                    </div>
                                </div>
                                
                                <div class="info-row">
                                    <i class="fas fa-money-bill-wave"></i>
                                    <div>
                                        <span class="label">Amount</span>
                                        <span class="value <%# GetAmountColor(Convert.ToDecimal(Eval("Amount"))) %>">
                                            <%# GetAmountDisplay(Convert.ToDecimal(Eval("Amount"))) %>
                                        </span>
                                    </div>
                                </div>
                                
                                <div class="info-row">
                                    <i class="fas fa-sticky-note"></i>
                                    <div>
                                        <span class="label">Reference</span>
                                        <span class="value"><%# Eval("Reference") %></span>
                                    </div>
                                </div>
                            </div>
                            
                            <div class="card-stats">
                                <div class="stat-item">
                                    <span class="stat-value">
                                        <%# Eval("UserBalance") != DBNull.Value ? "$" + Eval("UserBalance") : "$0.00" %>
                                    </span>
                                    <span class="stat-label">Current Balance</span>
                                </div>
                            </div>
                            
                            <div class="action-buttons">
                                <button type="button" class="btn btn-info" onclick='viewUser("<%# Eval("UserId") %>")'>
                                    <i class="fas fa-user me-1"></i>View User
                                </button>
                                <%# GetReverseButton(Eval("RewardId").ToString(), Convert.ToDecimal(Eval("Amount"))) %>
                            </div>
                        </div>
                    </ItemTemplate>
                    <FooterTemplate>
                        <asp:Label ID="lblEmptyGrid" runat="server" Text="No credit transactions found" 
                            Visible='<%# rptCreditsGrid.Items.Count == 0 %>' CssClass="empty-state">
                            <i class="fas fa-coins-slash"></i>
                            <p>No credit transactions found matching your criteria</p>
                        </asp:Label>
                    </FooterTemplate>
                </asp:Repeater>
            </asp:Panel>

            <!-- Table View -->
            <asp:Panel ID="pnlCreditsTableView" runat="server" CssClass="table-container" Visible="false">
                <asp:GridView ID="gvCredits" runat="server" AutoGenerateColumns="False" 
                    CssClass="users-table" 
                    EmptyDataText="No credit transactions found" ShowHeaderWhenEmpty="true">
                    <Columns>
                        <asp:TemplateField HeaderText="Transaction ID">
                            <ItemTemplate>
                                <div class="d-flex align-items-center">
                                    <div class="role-icon transaction">
                                        <i class='fas fa-coins'></i>
                                    </div>
                                    <div>
                                        <strong><%# Eval("RewardId") %></strong><br>
                                        <small class="text-muted"><%# Convert.ToDateTime(Eval("CreatedAt")).ToString("MM/dd/yy") %></small>
                                    </div>
                                </div>
                            </ItemTemplate>
                        </asp:TemplateField>
                        
                        <asp:TemplateField HeaderText="User">
                            <ItemTemplate>
                                <div><strong><%# Eval("UserName") %></strong></div>
                                <small class="text-muted"><%# Eval("UserPhone") %></small>
                            </ItemTemplate>
                        </asp:TemplateField>
                        
                        <asp:TemplateField HeaderText="Amount">
                            <ItemTemplate>
                                <div class="d-flex align-items-center gap-2">
                                    <i class="fas <%# GetAmountIcon(Convert.ToDecimal(Eval("Amount"))) %>"></i>
                                    <div>
                                        <strong class='<%# GetAmountColor(Convert.ToDecimal(Eval("Amount"))) %>'>
                                            <%# GetAmountDisplay(Convert.ToDecimal(Eval("Amount"))) %>
                                        </strong>
                                        <div class="small text-muted"><%# Eval("Type") %></div>
                                    </div>
                                </div>
                            </ItemTemplate>
                        </asp:TemplateField>
                        
                        <asp:TemplateField HeaderText="Details">
                            <ItemTemplate>
                                <small><%# Eval("Reference") %></small><br>
                                <small class="text-muted">Balance: <%# Eval("UserBalance") != DBNull.Value ? "$" + Eval("UserBalance") : "$0.00" %></small>
                            </ItemTemplate>
                        </asp:TemplateField>
                        
                        <asp:TemplateField HeaderText="Date">
                            <ItemTemplate>
                                <small><%# Convert.ToDateTime(Eval("CreatedAt")).ToString("MMM dd, yyyy") %></small><br>
                                <small class="text-muted"><%# Convert.ToDateTime(Eval("CreatedAt")).ToString("HH:mm") %></small>
                            </ItemTemplate>
                        </asp:TemplateField>
                        
                        <asp:TemplateField HeaderText="Actions">
                            <ItemTemplate>
                                <div class="d-flex gap-2">
                                    <button type="button" class="btn btn-info" onclick='viewUser("<%# Eval("UserId") %>")'>
                                        <i class="fas fa-user"></i>
                                    </button>
                                    <%# GetReverseButton(Eval("RewardId").ToString(), Convert.ToDecimal(Eval("Amount"))) %>
                                </div>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                    <EmptyDataTemplate>
                        <div class="empty-state" style="margin: 2rem;">
                            <i class="fas fa-coins-slash"></i>
                            <p>No credit transactions found matching your criteria</p>
                        </div>
                    </EmptyDataTemplate>
                </asp:GridView>
            </asp:Panel>
        </asp:Panel>

        <!-- Redemptions View -->
        <asp:Panel ID="pnlRedemptionsView" runat="server" Visible="false">
            <!-- Card View -->
            <asp:Panel ID="pnlRedemptionsCardView" runat="server" CssClass="users-grid">
                <asp:Repeater ID="rptRedemptionsGrid" runat="server" 
                    OnItemDataBound="rptRedemptionsGrid_ItemDataBound">
                    <ItemTemplate>
                        <div class="user-card">
                            <div class="d-flex justify-content-between align-items-start mb-2">
                                <h5>
                                    <i class="fas fa-money-check-alt me-2"></i>Redemption #<%# Eval("RedemptionId") %>
                                </h5>
                                <span class="badge <%# GetRedemptionStatusBadge(Eval("Status").ToString()) %>">
                                    <%# Eval("Status") %>
                                </span>
                            </div>
                            
                            <div class="mb-3">
                                <span class="text-muted small">
                                    <i class="fas fa-calendar me-1"></i>
                                    Requested: <%# Convert.ToDateTime(Eval("RequestedAt")).ToString("MMM dd, yyyy") %>
                                </span>
                            </div>
                            
                            <div class="collection-info">
                                <div class="info-row">
                                    <i class="fas fa-user"></i>
                                    <div>
                                        <span class="label">User</span>
                                        <span class="value"><%# Eval("UserName") %></span>
                                    </div>
                                </div>
                                
                                <div class="info-row">
                                    <i class="fas fa-money-bill-wave"></i>
                                    <div>
                                        <span class="label">Amount</span>
                                        <span class="value text-warning">
                                            $<%# Eval("Amount", "{0:N2}") %>
                                        </span>
                                    </div>
                                </div>
                                
                                <div class="info-row">
                                    <i class="fas fa-wallet"></i>
                                    <div>
                                        <span class="label">Method</span>
                                        <span class="value"><%# Eval("Method") %></span>
                                    </div>
                                </div>
                                
                                <div class="info-row">
                                    <i class="fas fa-clock"></i>
                                    <div>
                                        <span class="label">Processing</span>
                                        <span class="value">
                                            <%# Eval("ProcessedAt") != DBNull.Value ? Convert.ToDateTime(Eval("ProcessedAt")).ToString("MMM dd") : "Pending" %>
                                        </span>
                                    </div>
                                </div>
                            </div>
                            
                            <div class="card-stats">
                                <div class="stat-item">
                                    <span class="stat-value">
                                        <%# Eval("UserBalance") != DBNull.Value ? "$" + Eval("UserBalance") : "$0.00" %>
                                    </span>
                                    <span class="stat-label">User Balance</span>
                                </div>
                            </div>
                            
                            <div class="action-buttons">
                                <button type="button" class="btn btn-primary" onclick='processRedemption("<%# Eval("RedemptionId") %>")'>
                                    <i class="fas fa-cog me-1"></i>Process
                                </button>
                                <button type="button" class="btn btn-info" onclick='viewUser("<%# Eval("UserId") %>")'>
                                    <i class="fas fa-user me-1"></i>View User
                                </button>
                            </div>
                        </div>
                    </ItemTemplate>
                    <FooterTemplate>
                        <asp:Label ID="lblEmptyGrid" runat="server" Text="No redemption requests found" 
                            Visible='<%# rptRedemptionsGrid.Items.Count == 0 %>' CssClass="empty-state">
                            <i class="fas fa-money-check-slash"></i>
                            <p>No redemption requests found matching your criteria</p>
                        </asp:Label>
                    </FooterTemplate>
                </asp:Repeater>
            </asp:Panel>

            <!-- Table View -->
            <asp:Panel ID="pnlRedemptionsTableView" runat="server" CssClass="table-container" Visible="false">
                <asp:GridView ID="gvRedemptions" runat="server" AutoGenerateColumns="False" 
                    CssClass="users-table" 
                    EmptyDataText="No redemption requests found" ShowHeaderWhenEmpty="true">
                    <Columns>
                        <asp:TemplateField HeaderText="Redemption ID">
                            <ItemTemplate>
                                <div class="d-flex align-items-center">
                                    <div class="role-icon redemption">
                                        <i class='fas fa-money-check-alt'></i>
                                    </div>
                                    <div>
                                        <strong><%# Eval("RedemptionId") %></strong><br>
                                        <small class="text-muted"><%# Convert.ToDateTime(Eval("RequestedAt")).ToString("MM/dd/yy") %></small>
                                    </div>
                                </div>
                            </ItemTemplate>
                        </asp:TemplateField>
                        
                        <asp:TemplateField HeaderText="User">
                            <ItemTemplate>
                                <div><strong><%# Eval("UserName") %></strong></div>
                                <small class="text-muted"><%# Eval("UserPhone") %></small>
                            </ItemTemplate>
                        </asp:TemplateField>
                        
                        <asp:TemplateField HeaderText="Amount & Method">
                            <ItemTemplate>
                                <div class="d-flex align-items-center gap-2">
                                    <i class="fas fa-money-bill-wave text-warning"></i>
                                    <div>
                                        <strong>$<%# Eval("Amount", "{0:N2}") %></strong>
                                        <div class="small text-muted"><%# Eval("Method") %></div>
                                    </div>
                                </div>
                            </ItemTemplate>
                        </asp:TemplateField>
                        
                        <asp:TemplateField HeaderText="Status">
                            <ItemTemplate>
                                <div class="status-indicator">
                                    <span class='status-dot <%# GetRedemptionStatusClass(Eval("Status").ToString()) %>'></span>
                                    <span class='<%# GetRedemptionStatusColor(Eval("Status").ToString()) %>'>
                                        <%# Eval("Status") %>
                                    </span>
                                </div>
                                <small class="text-muted">
                                    <%# Eval("ProcessedAt") != DBNull.Value ? "Processed: " + Convert.ToDateTime(Eval("ProcessedAt")).ToString("MM/dd") : "Awaiting action" %>
                                </small>
                            </ItemTemplate>
                        </asp:TemplateField>
                        
                        <asp:TemplateField HeaderText="Balance">
                            <ItemTemplate>
                                <div class="d-flex align-items-center gap-2">
                                    <i class="fas fa-wallet text-primary"></i>
                                    <div>
                                        <strong><%# Eval("UserBalance") != DBNull.Value ? "$" + Eval("UserBalance") : "$0.00" %></strong>
                                    </div>
                                </div>
                            </ItemTemplate>
                        </asp:TemplateField>
                        
                        <asp:TemplateField HeaderText="Actions">
                            <ItemTemplate>
                                <div class="d-flex gap-2">
                                    <button type="button" class="btn btn-primary" onclick='processRedemption("<%# Eval("RedemptionId") %>")'>
                                        <i class="fas fa-cog"></i>
                                    </button>
                                    <button type="button" class="btn btn-info" onclick='viewUser("<%# Eval("UserId") %>")'>
                                        <i class="fas fa-user"></i>
                                    </button>
                                </div>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                    <EmptyDataTemplate>
                        <div class="empty-state" style="margin: 2rem;">
                            <i class="fas fa-money-check-slash"></i>
                            <p>No redemption requests found matching your criteria</p>
                        </div>
                    </EmptyDataTemplate>
                </asp:GridView>
            </asp:Panel>
        </asp:Panel>

        <!-- User Balances View -->
        <asp:Panel ID="pnlUsersView" runat="server" Visible="false">
            <!-- Card View -->
            <asp:Panel ID="pnlUsersCardView" runat="server" CssClass="users-grid">
                <asp:Repeater ID="rptUsersGrid" runat="server" 
                    OnItemDataBound="rptUsersGrid_ItemDataBound">
                    <ItemTemplate>
                        <div class="user-card">
                            <div class="d-flex justify-content-between align-items-start mb-2">
                                <h5>
                                    <i class="fas fa-user me-2"></i><%# Eval("FullName") %>
                                </h5>
                                <span class="badge <%# GetUserRoleBadge(Eval("RoleName").ToString()) %>">
                                    <%# Eval("RoleName") %>
                                </span>
                            </div>
                            
                            <div class="mb-3">
                                <span class="text-muted small">
                                    <i class="fas fa-phone me-1"></i><%# Eval("Phone") %>
                                </span>
                            </div>
                            
                            <div class="collection-info">
                                <div class="info-row">
                                    <i class="fas fa-coins"></i>
                                    <div>
                                        <span class="label">Current Balance</span>
                                        <span class="value text-success">
                                            $<%# Eval("XP_Credits", "{0:N2}") %>
                                        </span>
                                    </div>
                                </div>
                                
                                <div class="info-row">
                                    <i class="fas fa-arrow-up"></i>
                                    <div>
                                        <span class="label">Total Earned</span>
                                        <span class="value">
                                            $<%# Eval("TotalEarned", "{0:N2}") %>
                                        </span>
                                    </div>
                                </div>
                                
                                <div class="info-row">
                                    <i class="fas fa-arrow-down"></i>
                                    <div>
                                        <span class="label">Total Redeemed</span>
                                        <span class="value">
                                            $<%# Eval("TotalRedeemed", "{0:N2}") %>
                                        </span>
                                    </div>
                                </div>
                                
                                <div class="info-row">
                                    <i class="fas fa-calendar"></i>
                                    <div>
                                        <span class="label">Member Since</span>
                                        <span class="value"><%# Convert.ToDateTime(Eval("CreatedAt")).ToString("MMM dd, yyyy") %></span>
                                    </div>
                                </div>
                            </div>
                            
                            <div class="card-stats">
                                <div class="stat-item">
                                    <span class="stat-value">
                                        <%# Eval("TotalTransactions") %>
                                    </span>
                                    <span class="stat-label">Transactions</span>
                                </div>
                                <div class="stat-item">
                                    <span class="stat-value">
                                        <%# Eval("TotalRedemptions") %>
                                    </span>
                                    <span class="stat-label">Redemptions</span>
                                </div>
                            </div>
                            
                            <div class="action-buttons">
                                <button type="button" class="btn btn-success" onclick='addCreditsToUser("<%# Eval("UserId") %>")'>
                                    <i class="fas fa-plus-circle me-1"></i>Add Credits
                                </button>
                                <button type="button" class="btn btn-info" onclick='viewUser("<%# Eval("UserId") %>")'>
                                    <i class="fas fa-history me-1"></i>View History
                                </button>
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
            <asp:Panel ID="pnlUsersTableView" runat="server" CssClass="table-container" Visible="false">
                <asp:GridView ID="gvUsers" runat="server" AutoGenerateColumns="False" 
                    CssClass="users-table" 
                    EmptyDataText="No users found" ShowHeaderWhenEmpty="true">
                    <Columns>
                        <asp:TemplateField HeaderText="User">
                            <ItemTemplate>
                                <div class="d-flex align-items-center">
                                    <div class="role-icon user">
                                        <i class='fas fa-user'></i>
                                    </div>
                                    <div>
                                        <strong><%# Eval("FullName") %></strong><br>
                                        <small class="text-muted"><%# Eval("Phone") %></small>
                                    </div>
                                </div>
                            </ItemTemplate>
                        </asp:TemplateField>
                        
                        <asp:TemplateField HeaderText="Role">
                            <ItemTemplate>
                                <span class="badge <%# GetUserRoleBadge(Eval("RoleName").ToString()) %>">
                                    <%# Eval("RoleName") %>
                                </span>
                            </ItemTemplate>
                        </asp:TemplateField>
                        
                        <asp:TemplateField HeaderText="Balance">
                            <ItemTemplate>
                                <div class="d-flex align-items-center gap-2">
                                    <i class="fas fa-coins text-warning"></i>
                                    <div>
                                        <strong class='<%# GetBalanceColor(Convert.ToDecimal(Eval("XP_Credits"))) %>'>
                                            $<%# Eval("XP_Credits", "{0:N2}") %>
                                        </strong>
                                        <div class="small text-muted">Current</div>
                                    </div>
                                </div>
                            </ItemTemplate>
                        </asp:TemplateField>
                        
                        <asp:TemplateField HeaderText="Statistics">
                            <ItemTemplate>
                                <small>Earned: <strong>$<%# Eval("TotalEarned", "{0:N2}") %></strong></small><br>
                                <small>Redeemed: <strong>$<%# Eval("TotalRedeemed", "{0:N2}") %></strong></small>
                            </ItemTemplate>
                        </asp:TemplateField>
                        
                        <asp:TemplateField HeaderText="Activity">
                            <ItemTemplate>
                                <small>Transactions: <strong><%# Eval("TotalTransactions") %></strong></small><br>
                                <small>Redemptions: <strong><%# Eval("TotalRedemptions") %></strong></small>
                            </ItemTemplate>
                        </asp:TemplateField>
                        
                        <asp:TemplateField HeaderText="Actions">
                            <ItemTemplate>
                                <div class="d-flex gap-2">
                                    <button type="button" class="btn btn-success" onclick='addCreditsToUser("<%# Eval("UserId") %>")'>
                                        <i class="fas fa-plus-circle"></i>
                                    </button>
                                    <button type="button" class="btn btn-info" onclick='viewUser("<%# Eval("UserId") %>")'>
                                        <i class="fas fa-history"></i>
                                    </button>
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
        </asp:Panel>
    </div>

    <!-- Simple JavaScript functions -->
    <script>
    function showAddCreditModal() {
        // Clear form
        document.getElementById('<%= hdnUserId.ClientID %>').value = '';
        document.getElementById('<%= ddlUser.ClientID %>').selectedIndex = 0;
        document.getElementById('<%= txtAmount.ClientID %>').value = '';
        document.getElementById('<%= ddlCreditType.ClientID %>').selectedIndex = 0;
        document.getElementById('<%= txtReference.ClientID %>').value = '';
        
        // Show modal
        var modal = new bootstrap.Modal(document.getElementById('addCreditModal'));
        modal.show();
    }
    
    function addCreditsToUser(userId) {
        // Set the user ID and select in dropdown
        document.getElementById('<%= hdnUserId.ClientID %>').value = userId;
        
        var dropdown = document.getElementById('<%= ddlUser.ClientID %>');
        for (var i = 0; i < dropdown.options.length; i++) {
            if (dropdown.options[i].value === userId) {
                dropdown.selectedIndex = i;
                break;
            }
        }
        
        // Show modal
        var modal = new bootstrap.Modal(document.getElementById('addCreditModal'));
        modal.show();
    }
    
    function processRedemption(redemptionId) {
        // Set the redemption ID
        document.getElementById('<%= hdnRedemptionId.ClientID %>').value = redemptionId;
        
        // Trigger server-side event to load data
        __doPostBack('ctl00$MainContent$hdnRedemptionId', 'process_' + redemptionId);
    }
    
    function viewUser(userId) {
        // In a real application, you would redirect to user details
        window.location.href = 'Citizens.aspx?id=' + userId;
    }
    
    function reverseTransaction(rewardId) {
        if (confirm('Are you sure you want to reverse this transaction?')) {
            __doPostBack('ctl00$MainContent$btnReverseTransaction', rewardId);
        }
    }
    </script>
</asp:Content>