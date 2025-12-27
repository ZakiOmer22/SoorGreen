<%@ Page Title="Transactions" Language="C#" MasterPageFile="~/Pages/Admin/Site.master" AutoEventWireup="true" Inherits="SoorGreen.Admin.Admin.Transactions" Codebehind="Transactions.aspx.cs" %>

<asp:Content ID="Content3" ContentPlaceHolderID="HeadContent" runat="server">
    <link href='<%= ResolveUrl("~/Content/Pages/Admin/admincitizens.css") %>' rel="stylesheet" />
</asp:Content>

<asp:Content ID="PageTitle" ContentPlaceHolderID="PageTitle" runat="server">
    <div class="d-flex align-items-center">
        <h1 class="h3 mb-0" style="color: var(--text-primary);">Transactions Management</h1>
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

    <!-- Transaction Details Modal -->
    <div class="modal fade" id="transactionDetailsModal" tabindex="-1" role="dialog" aria-hidden="true">
        <div class="modal-dialog modal-lg" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">
                        <i class="fas fa-receipt me-2"></i>Transaction Details
                    </h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <asp:HiddenField ID="hdnTransactionId" runat="server" />
                    
                    <div class="row">
                        <div class="col-md-6">
                            <h6 class="mb-3 border-bottom pb-2"><i class="fas fa-info-circle me-2"></i>Transaction Information</h6>
                            
                            <div class="mb-3">
                                <label class="form-label"><i class="fas fa-hashtag me-2"></i>Transaction ID</label>
                                <asp:TextBox ID="txtTransactionId" runat="server" CssClass="form-control" ReadOnly="true"></asp:TextBox>
                            </div>
                            
                            <div class="mb-3">
                                <label class="form-label"><i class="fas fa-user me-2"></i>User Information</label>
                                <asp:TextBox ID="txtUserInfo" runat="server" CssClass="form-control" ReadOnly="true" TextMode="MultiLine" Rows="2"></asp:TextBox>
                            </div>
                            
                            <div class="mb-3">
                                <label class="form-label"><i class="fas fa-exchange-alt me-2"></i>Transaction Type</label>
                                <asp:TextBox ID="txtTransactionType" runat="server" CssClass="form-control" ReadOnly="true"></asp:TextBox>
                            </div>
                            
                            <div class="mb-3">
                                <label class="form-label"><i class="fas fa-tag me-2"></i>Reference/Description</label>
                                <asp:TextBox ID="txtReference" runat="server" CssClass="form-control" ReadOnly="true"></asp:TextBox>
                            </div>
                        </div>
                        
                        <div class="col-md-6">
                            <h6 class="mb-3 border-bottom pb-2"><i class="fas fa-money-bill-wave me-2"></i>Amount Details</h6>
                            
                            <div class="mb-3">
                                <label class="form-label"><i class="fas fa-coins me-2"></i>Amount</label>
                                <div class="input-group">
                                    <span class="input-group-text">$</span>
                                    <asp:TextBox ID="txtAmount" runat="server" CssClass="form-control" ReadOnly="true"></asp:TextBox>
                                </div>
                            </div>
                            
                            <div class="mb-3">
                                <label class="form-label"><i class="fas fa-wallet me-2"></i>Balance After</label>
                                <div class="input-group">
                                    <span class="input-group-text">$</span>
                                    <asp:TextBox ID="txtBalanceAfter" runat="server" CssClass="form-control" ReadOnly="true"></asp:TextBox>
                                </div>
                            </div>
                            
                            <div class="mb-3">
                                <label class="form-label"><i class="fas fa-calendar-alt me-2"></i>Transaction Date</label>
                                <asp:TextBox ID="txtTransactionDate" runat="server" CssClass="form-control" ReadOnly="true"></asp:TextBox>
                            </div>
                            
                            <div class="mb-3">
                                <label class="form-label"><i class="fas fa-code me-2"></i>Reward ID (if applicable)</label>
                                <asp:TextBox ID="txtRewardId" runat="server" CssClass="form-control" ReadOnly="true"></asp:TextBox>
                            </div>
                        </div>
                    </div>
                    
                    <!-- Additional Information -->
                    <div class="mt-4">
                        <h6 class="mb-3 border-bottom pb-2"><i class="fas fa-sticky-note me-2"></i>Additional Information</h6>
                        <div class="mb-3">
                            <label class="form-label"><i class="fas fa-info-circle me-2"></i>Status</label>
                            <asp:TextBox ID="txtStatus" runat="server" CssClass="form-control" ReadOnly="true"></asp:TextBox>
                        </div>
                        
                        <div class="mb-3">
                            <label class="form-label"><i class="fas fa-comment me-2"></i>Admin Notes</label>
                            <asp:TextBox ID="txtAdminNotes" runat="server" CssClass="form-control" 
                                placeholder="Add any notes about this transaction..." 
                                TextMode="MultiLine" Rows="3"></asp:TextBox>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                    <asp:Button ID="btnSaveNotes" runat="server" CssClass="btn btn-primary" 
                        Text="Save Notes" OnClick="btnSaveNotes_Click" />
                    <asp:Button ID="btnReverseTransaction" runat="server" CssClass="btn btn-danger" 
                        Text="Reverse Transaction" OnClick="btnReverseTransaction_Click" 
                        OnClientClick="return confirm('WARNING: Are you sure you want to reverse this transaction? This action cannot be undone.');" />
                </div>
            </div>
        </div>
    </div>

    <div class="users-container">
        <!-- Filter Card -->
        <div class="filter-card">
            <h5 class="mb-4"><i class="fas fa-sliders-h me-2"></i>Filter Transactions</h5>
            <div class="filter-group">
                <div class="form-group search-box">
                    <label class="form-label"><i class="fas fa-search me-2"></i>Search Transactions</label>
                    <div class="position-relative">
                        <i class="fas fa-search search-icon"></i>
                        <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control search-input" 
                            placeholder="Search by ID, user name, phone, reference..."></asp:TextBox>
                    </div>
                </div>
                <div class="form-group">
                    <label class="form-label"><i class="fas fa-exchange-alt me-2"></i>Transaction Type</label>
                    <div class="select-with-icon">
                        <asp:DropDownList ID="ddlTransactionType" runat="server" CssClass="form-control">
                            <asp:ListItem Value="all">All Types</asp:ListItem>
                            <asp:ListItem Value="Credit">Credits Earned</asp:ListItem>
                            <asp:ListItem Value="Redemption">Redemptions</asp:ListItem>
                            <asp:ListItem Value="Adjustment">Manual Adjustments</asp:ListItem>
                            <asp:ListItem Value="Bonus">Bonus</asp:ListItem>
                            <asp:ListItem Value="Penalty">Penalty</asp:ListItem>
                        </asp:DropDownList>
                        <i class="fas fa-chevron-down select-arrow"></i>
                    </div>
                </div>
                <div class="form-group">
                    <label class="form-label"><i class="fas fa-filter me-2"></i>Amount Range</label>
                    <div class="row g-2">
                        <div class="col">
                            <asp:TextBox ID="txtAmountFrom" runat="server" CssClass="form-control" 
                                placeholder="Min $" TextMode="Number" step="0.01"></asp:TextBox>
                        </div>
                        <div class="col">
                            <asp:TextBox ID="txtAmountTo" runat="server" CssClass="form-control" 
                                placeholder="Max $" TextMode="Number" step="0.01"></asp:TextBox>
                        </div>
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
                            <asp:ListItem Value="custom">Custom Range</asp:ListItem>
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
            
            <!-- Custom Date Range (hidden by default) -->
            <div id="customDateRange" class="row g-2 mt-2" style="display: none;">
                <div class="col">
                    <label class="form-label small">From Date</label>
                    <asp:TextBox ID="txtDateFrom" runat="server" CssClass="form-control" TextMode="Date"></asp:TextBox>
                </div>
                <div class="col">
                    <label class="form-label small">To Date</label>
                    <asp:TextBox ID="txtDateTo" runat="server" CssClass="form-control" TextMode="Date"></asp:TextBox>
                </div>
            </div>
        </div>

        <!-- Stats Cards -->
        <div class="d-flex gap-3 mb-4 flex-wrap">
            <div class="stats-card users" style="flex: 1; min-width: 200px;">
                <div class="stats-icon">
                    <i class="fas fa-exchange-alt"></i>
                </div>
                <div class="stats-number" id="statTotalTransactions" runat="server">0</div>
                <div class="stats-label">Total Transactions</div>
            </div>
            <div class="stats-card active" style="flex: 1; min-width: 200px;">
                <div class="stats-icon">
                    <i class="fas fa-plus-circle"></i>
                </div>
                <div class="stats-number text-success" id="statTotalCredits" runat="server">$0.00</div>
                <div class="stats-label">Total Credits Issued</div>
            </div>
            <div class="stats-card pickups" style="flex: 1; min-width: 200px;">
                <div class="stats-icon">
                    <i class="fas fa-minus-circle"></i>
                </div>
                <div class="stats-number text-danger" id="statTotalRedemptions" runat="server">$0.00</div>
                <div class="stats-label">Total Redemptions</div>
            </div>
            <div class="stats-card waste" style="flex: 1; min-width: 200px;">
                <div class="stats-icon">
                    <i class="fas fa-chart-line"></i>
                </div>
                <div class="stats-number text-primary" id="statNetFlow" runat="server">$0.00</div>
                <div class="stats-label">Net Credit Flow</div>
            </div>
        </div>

        <!-- Quick Actions -->
        <div class="filter-card mb-4">
            <h5 class="mb-4"><i class="fas fa-bolt me-2"></i>Quick Actions</h5>
            <div class="d-flex flex-wrap gap-3">
                <button type="button" class="btn btn-success btn-with-icon" onclick="showTodayTransactions()">
                    <i class="fas fa-calendar-day me-2"></i>Today's Transactions
                </button>
                <button type="button" class="btn btn-warning btn-with-icon" onclick="showLargeTransactions()">
                    <i class="fas fa-money-bill-wave me-2"></i>Large Transactions (>$50)
                </button>
                <button type="button" class="btn btn-info btn-with-icon" onclick="showManualAdjustments()">
                    <i class="fas fa-user-cog me-2"></i>Manual Adjustments
                </button>
                <button type="button" class="btn btn-primary btn-with-icon" onclick="__doPostBack('ctl00$MainContent$btnExportCSV', '')">
                    <i class="fas fa-file-export me-2"></i>Export Report
                </button>
                <button type="button" class="btn btn-secondary btn-with-icon" onclick="openManualCreditForm()">
                    <i class="fas fa-hand-holding-usd me-2"></i>Manual Credit Adjustment
                </button>
                <asp:Button ID="btnExportCSV" runat="server" style="display:none;" OnClick="btnExportCSV_Click" />
            </div>
        </div>

        <!-- Manual Credit Adjustment Form (hidden by default) -->
        <div id="manualCreditForm" class="filter-card mb-4" style="display: none;">
            <h5 class="mb-4"><i class="fas fa-hand-holding-usd me-2"></i>Manual Credit Adjustment</h5>
            <div class="row g-3">
                <div class="col-md-4">
                    <label class="form-label"><i class="fas fa-user me-2"></i>Select User</label>
                    <asp:DropDownList ID="ddlUsers" runat="server" CssClass="form-control" 
                        DataTextField="FullName" DataValueField="UserId">
                    </asp:DropDownList>
                </div>
                <div class="col-md-3">
                    <label class="form-label"><i class="fas fa-exchange-alt me-2"></i>Adjustment Type</label>
                    <asp:DropDownList ID="ddlAdjustmentType" runat="server" CssClass="form-control">
                        <asp:ListItem Value="Add">Add Credits</asp:ListItem>
                        <asp:ListItem Value="Deduct">Deduct Credits</asp:ListItem>
                        <asp:ListItem Value="Set">Set Balance</asp:ListItem>
                    </asp:DropDownList>
                </div>
                <div class="col-md-3">
                    <label class="form-label"><i class="fas fa-coins me-2"></i>Amount</label>
                    <div class="input-group">
                        <span class="input-group-text">$</span>
                        <asp:TextBox ID="txtAdjustmentAmount" runat="server" CssClass="form-control" 
                            TextMode="Number" step="0.01" placeholder="0.00"></asp:TextBox>
                    </div>
                </div>
                <div class="col-md-2 d-flex align-items-end">
                    <asp:Button ID="btnApplyAdjustment" runat="server" CssClass="btn btn-success" 
                        Text="Apply" OnClick="btnApplyAdjustment_Click" />
                </div>
                <div class="col-12">
                    <label class="form-label"><i class="fas fa-sticky-note me-2"></i>Reason/Notes</label>
                    <asp:TextBox ID="txtAdjustmentReason" runat="server" CssClass="form-control" 
                        placeholder="Enter reason for this adjustment..." TextMode="MultiLine" Rows="2"></asp:TextBox>
                </div>
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
                    <i class="fas fa-exchange-alt me-2"></i>
                    Showing <asp:Label ID="lblTransactionCount" runat="server" Text="0"></asp:Label> transactions
                </div>
            </div>
            <div class="d-flex gap-2">
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
            <asp:Repeater ID="rptTransactionsGrid" runat="server" 
                OnItemDataBound="rptTransactionsGrid_ItemDataBound">
                <ItemTemplate>
                    <div class="user-card transaction-card">
                        <div class="d-flex justify-content-between align-items-start mb-2">
                            <h5>
                                <i class="fas fa-exchange-alt me-2"></i>Transaction #<%# Eval("RewardId") %>
                            </h5>
                            <span class="badge amount-badge <%# GetAmountBadgeClass(Convert.ToDecimal(Eval("Amount"))) %>">
                                $<%# Math.Abs(Convert.ToDecimal(Eval("Amount"))).ToString("N2") %>
                                <i class='fas <%# Convert.ToDecimal(Eval("Amount")) >= 0 ? "fa-arrow-up" : "fa-arrow-down" %> ms-1'></i>
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
                                    <span class="label">User Information</span>
                                    <span class="value">
                                        <strong><%# Eval("UserName") %></strong><br>
                                        <small class="text-muted"><%# Eval("UserPhone") %></small>
                                    </span>
                                </div>
                            </div>
                            
                            <div class="info-row">
                                <i class="fas fa-tag"></i>
                                <div>
                                    <span class="label">Transaction Type</span>
                                    <span class="value">
                                        <span class="badge badge-sm <%# GetTypeBadgeClass(Eval("Type").ToString()) %>">
                                            <%# Eval("Type") %>
                                        </span>
                                    </span>
                                </div>
                            </div>
                           
                            <div class="info-row">
                                <i class="fas fa-file-alt"></i>
                                <div>
                                    <span class="label">Reference</span>
                                    <span class="value">
                                        <%# Eval("Reference") %>
                                    </span>
                                </div>
                            </div>
                            
                            <div class="info-row">
                                <i class="fas fa-wallet"></i>
                                <div>
                                    <span class="label">User Balance</span>
                                    <span class="value">
                                        $<%# GetUserBalanceAfterTransaction(Eval("UserId"), Eval("CreatedAt")) %>
                                    </span>
                                </div>
                            </div>
                        </div>
                        
                        <div class="card-stats">
                            <div class="stat-item">
                                <span class="stat-value">
                                    <%# GetTransactionCountForUser(Eval("UserId")) %>
                                </span>
                                <span class="stat-label">User Transactions</span>
                            </div>
                            <div class="stat-item">
                                <span class="stat-value">
                                    $<%# GetTotalUserCredits(Eval("UserId")) %>
                                </span>
                                <span class="stat-label">Total Earned</span>
                            </div>
                            <div class="stat-item">
                                <span class="stat-value">
                                    <%# GetDaysAgo(Eval("CreatedAt")) %>d ago
                                </span>
                                <span class="stat-label">Days Ago</span>
                            </div>
                        </div>
                        
                        <div class="action-buttons">
                            <button type="button" class="btn btn-info" onclick='viewTransactionDetails("<%# Eval("RewardId") %>")'>
                                <i class="fas fa-eye me-1"></i>View Details
                            </button>
                            <button type="button" class="btn btn-secondary" onclick='viewUserTransactions("<%# Eval("UserId") %>")'>
                                <i class="fas fa-history me-1"></i>User History
                            </button>
                            <%# GetActionButtons(Eval("Type").ToString(), Eval("RewardId").ToString()) %>
                        </div>
                    </div>
                </ItemTemplate>
                <FooterTemplate>
                    <asp:Label ID="lblEmptyGrid" runat="server" Text="No transactions found" 
                        Visible='<%# rptTransactionsGrid.Items.Count == 0 %>' CssClass="empty-state">
                        <i class="fas fa-exchange-alt-slash"></i>
                        <p>No transactions found matching your criteria</p>
                    </asp:Label>
                </FooterTemplate>
            </asp:Repeater>
        </asp:Panel>

        <!-- Table View -->
        <asp:Panel ID="pnlTableView" runat="server" CssClass="table-container" Visible="false">
            <asp:GridView ID="gvTransactions" runat="server" AutoGenerateColumns="False" 
                CssClass="users-table" 
                EmptyDataText="No transactions found" ShowHeaderWhenEmpty="true">
                <Columns>
                    <asp:TemplateField HeaderText="Transaction ID">
                        <ItemTemplate>
                            <div class="d-flex align-items-center">
                                <div class="role-icon <%# GetTypeIconClass(Eval("Type").ToString()) %>">
                                    <i class='<%# GetTypeIcon(Eval("Type").ToString()) %>'></i>
                                </div>
                                <div>
                                    <strong><%# Eval("RewardId") %></strong><br>
                                    <small class="text-muted"><%# Convert.ToDateTime(Eval("CreatedAt")).ToString("MM/dd/yy HH:mm") %></small>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:TemplateField>
                    
                    <asp:TemplateField HeaderText="User Information">
                        <ItemTemplate>
                            <div><strong><%# Eval("UserName") %></strong></div>
                            <small class="text-muted"><%# Eval("UserPhone") %></small>
                        </ItemTemplate>
                    </asp:TemplateField>
                    
                    <asp:TemplateField HeaderText="Amount & Type">
                        <ItemTemplate>
                            <div class="d-flex align-items-center gap-2">
                                <i class='fas <%# Convert.ToDecimal(Eval("Amount")) >= 0 ? "fa-plus-circle text-success" : "fa-minus-circle text-danger" %>'></i>
                                <div>
                                    <strong class='<%# Convert.ToDecimal(Eval("Amount")) >= 0 ? "text-success" : "text-danger" %>'>
                                        $<%# Math.Abs(Convert.ToDecimal(Eval("Amount"))).ToString("N2") %>
                                    </strong>
                                    <div class="small">
                                        <span class='badge badge-sm <%# GetTypeBadgeClass(Eval("Type").ToString()) %>'>
                                            <%# Eval("Type") %>
                                        </span>
                                    </div>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:TemplateField>
                    
                    <asp:TemplateField HeaderText="Reference">
                        <ItemTemplate>
                            <div class="truncate-text" style="max-width: 200px;">
                                <%# Eval("Reference") %>
                            </div>
                            <small class="text-muted">
                                <%# GetDaysAgo(Eval("CreatedAt")) %> days ago
                            </small>
                        </ItemTemplate>
                    </asp:TemplateField>
                    
                    <asp:TemplateField HeaderText="Balance Info">
                        <ItemTemplate>
                            <div class="small">
                                Balance After: $<%# GetUserBalanceAfterTransaction(Eval("UserId"), Eval("CreatedAt")) %><br>
                                Current Balance: $<%# GetCurrentUserBalance(Eval("UserId")) %>
                            </div>
                        </ItemTemplate>
                    </asp:TemplateField>
                    
                    <asp:TemplateField HeaderText="Actions">
                        <ItemTemplate>
                            <div class="d-flex flex-wrap gap-2">
                                <button type="button" class="btn btn-info btn-sm" onclick='viewTransactionDetails("<%# Eval("RewardId") %>")'>
                                    <i class="fas fa-eye"></i>
                                </button>
                                <button type="button" class="btn btn-secondary btn-sm" onclick='viewUserTransactions("<%# Eval("UserId") %>")'>
                                    <i class="fas fa-history"></i>
                                </button>
                                <%# GetActionButtons(Eval("Type").ToString(), Eval("RewardId").ToString()) %>
                            </div>
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
                <EmptyDataTemplate>
                    <div class="empty-state" style="margin: 2rem;">
                        <i class="fas fa-exchange-alt-slash"></i>
                        <p>No transactions found matching your criteria</p>
                    </div>
                </EmptyDataTemplate>
            </asp:GridView>
        </asp:Panel>
    </div>

    <!-- Simple JavaScript functions -->
    <script>
    function viewTransactionDetails(transactionId) {
        document.getElementById('<%= hdnTransactionId.ClientID %>').value = transactionId;
        __doPostBack('ctl00$MainContent$hdnTransactionId', 'view_' + transactionId);
    }
    
    function viewUserTransactions(userId) {
        window.location.href = 'Transactions.aspx?userId=' + userId;
    }
    
    function openManualCreditForm() {
        var form = document.getElementById('manualCreditForm');
        form.style.display = form.style.display === 'none' ? 'block' : 'none';
        if (form.style.display === 'block') {
            __doPostBack('ctl00$MainContent$ddlUsers', 'load');
        }
    }
    
    function showTodayTransactions() {
        document.getElementById('<%= ddlDateFilter.ClientID %>').value = 'today';
        __doPostBack('ctl00$MainContent$btnApplyFilters', '');
    }
    
    function showLargeTransactions() {
        document.getElementById('<%= txtAmountFrom.ClientID %>').value = '50';
        __doPostBack('ctl00$MainContent$btnApplyFilters', '');
    }
    
    function showManualAdjustments() {
        document.getElementById('<%= ddlTransactionType.ClientID %>').value = 'Adjustment';
        __doPostBack('ctl00$MainContent$btnApplyFilters', '');
    }
    
    // Show/hide custom date range
    document.getElementById('<%= ddlDateFilter.ClientID %>').addEventListener('change', function() {
        var customRange = document.getElementById('customDateRange');
        if (this.value === 'custom') {
            customRange.style.display = 'block';
        } else {
            customRange.style.display = 'none';
        }
    });
    
    // Ensure text visibility on page load
    function ensureTextVisibility() {
        document.querySelectorAll('.transaction-card *').forEach(element => {
            element.style.overflow = 'visible';
            element.style.whiteSpace = 'normal';
            element.style.wordWrap = 'break-word';
        });
        
        document.querySelectorAll('.users-table td, .users-table th').forEach(cell => {
            cell.style.whiteSpace = 'normal';
            cell.style.wordWrap = 'break-word';
            cell.style.maxWidth = 'none';
        });
    }
    
    document.addEventListener('DOMContentLoaded', ensureTextVisibility);
    </script>
</asp:Content>