<%@ Page Title="My Rewards" Language="C#" MasterPageFile="~/Pages/Citizen/Site.Master" 
    AutoEventWireup="true" Inherits="SoorGreen.Admin.MyRewards" Codebehind="MyRewards.aspx.cs" %>

<asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
    <link href='<%= ResolveUrl("~/Content/Pages/Citizen/citizenmyrewards.css") %>' rel="stylesheet" />
    
    <!-- Add Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    
    <!-- Add Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</asp:Content>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    My Rewards - SoorGreen Citizen
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <div class="rewards-container">
        <!-- Page Header -->
        <div class="page-header-glass">
            <h1 class="page-title-glass">My Rewards</h1>
            <p class="page-subtitle-glass">Track your XP credits and redemption history</p>
            
            <!-- Quick Actions -->
            <div class="d-flex gap-3 mt-4">
                <asp:LinkButton ID="btnRedeemPoints" runat="server" CssClass="action-btn primary"
                    OnClientClick="showRedeemModal(); return false;">
                    <i class="fas fa-exchange-alt me-2"></i> Redeem Points
                </asp:LinkButton>
                
                <asp:LinkButton ID="btnRefresh" runat="server" CssClass="action-btn secondary"
                    OnClick="btnRefresh_Click">
                    <i class="fas fa-sync-alt me-2"></i> Refresh
                </asp:LinkButton>
                
                <asp:LinkButton ID="btnExportRewards" runat="server" CssClass="action-btn secondary"
                    OnClick="btnExportRewards_Click">
                    <i class="fas fa-file-export me-2"></i> Export
                </asp:LinkButton>
            </div>
        </div>

        <!-- Stats Overview -->
        <div class="stats-overview-grid">
            <div class="stat-card-glass total">
                <div class="d-flex align-items-start justify-content-between">
                    <div class="stat-icon-glass">
                        <i class="fas fa-coins"></i>
                    </div>
                    <div class="stat-trend-glass trend-up">
                        <i class="fas fa-arrow-up"></i>
                        <span>25%</span>
                    </div>
                </div>
                <div class="stat-content-glass">
                    <div class="stat-number-glass" id="statTotalCredits" runat="server">0</div>
                    <div class="stat-label-glass">Total Earned</div>
                </div>
            </div>
            
            <div class="stat-card-glass available">
                <div class="d-flex align-items-start justify-content-between">
                    <div class="stat-icon-glass">
                        <i class="fas fa-wallet"></i>
                    </div>
                    <div class="stat-trend-glass trend-up">
                        <i class="fas fa-arrow-up"></i>
                        <span>15%</span>
                    </div>
                </div>
                <div class="stat-content-glass">
                    <div class="stat-number-glass" id="statAvailableCredits" runat="server">0</div>
                    <div class="stat-label-glass">Available</div>
                </div>
            </div>
            
            <div class="stat-card-glass monthly">
                <div class="d-flex align-items-start justify-content-between">
                    <div class="stat-icon-glass">
                        <i class="fas fa-chart-line"></i>
                    </div>
                    <div class="stat-trend-glass trend-up">
                        <i class="fas fa-arrow-up"></i>
                        <span>32%</span>
                    </div>
                </div>
                <div class="stat-content-glass">
                    <div class="stat-number-glass" id="statMonthlyCredits" runat="server">0</div>
                    <div class="stat-label-glass">This Month</div>
                </div>
            </div>
            
            <div class="stat-card-glass pending">
                <div class="d-flex align-items-start justify-content-between">
                    <div class="stat-icon-glass">
                        <i class="fas fa-clock"></i>
                    </div>
                    <div class="stat-trend-glass trend-up">
                        <i class="fas fa-arrow-up"></i>
                        <span>8%</span>
                    </div>
                </div>
                <div class="stat-content-glass">
                    <div class="stat-number-glass" id="statPendingRedemptions" runat="server">0</div>
                    <div class="stat-label-glass">Pending</div>
                </div>
            </div>
        </div>

        <!-- Quick Actions -->
        <div class="quick-actions-glass">
            <div class="quick-actions-header">
                <h3 class="quick-actions-title">Quick Actions</h3>
                <asp:LinkButton ID="btnViewAll" runat="server" CssClass="action-btn secondary small"
                    OnClick="btnViewAll_Click">
                    View All
                </asp:LinkButton>
            </div>
            
            <div class="quick-actions-grid">
                <div class="quick-action-card" onclick="showRedeemModal()">
                    <i class="fas fa-exchange-alt"></i>
                    <h4 class="quick-action-title">Redeem Points</h4>
                    <p class="quick-action-desc">Convert XP credits to cash or vouchers</p>
                </div>
                
                <div class="quick-action-card" onclick="location.href='MyReports.aspx'">
                    <i class="fas fa-trash-alt"></i>
                    <h4 class="quick-action-title">Earn More</h4>
                    <p class="quick-action-desc">Submit waste reports to earn XP</p>
                </div>
                
                <div class="quick-action-card" onclick="location.href='RewardHistory.aspx'">
                    <i class="fas fa-history"></i>
                    <h4 class="quick-action-title">View History</h4>
                    <p class="quick-action-desc">Check your complete reward history</p>
                </div>
                
                <div class="quick-action-card" onclick="location.href='Referral.aspx'">
                    <i class="fas fa-user-friends"></i>
                    <h4 class="quick-action-title">Refer Friends</h4>
                    <p class="quick-action-desc">Earn bonus XP by referring friends</p>
                </div>
            </div>
        </div>

        <!-- Rewards List -->
        <div class="rewards-list-container">
            <div class="rewards-list-header">
                <h3 class="rewards-list-title">Recent Rewards</h3>
                <div class="rewards-filters-glass">
                    <asp:DropDownList ID="ddlTypeFilter" runat="server" CssClass="filter-select-glass"
                        AutoPostBack="true" OnSelectedIndexChanged="ddlTypeFilter_SelectedIndexChanged">
                        <asp:ListItem Value="all">All Types</asp:ListItem>
                        <asp:ListItem Value="pickup">Pickup Rewards</asp:ListItem>
                        <asp:ListItem Value="report">Report Rewards</asp:ListItem>
                        <asp:ListItem Value="referral">Referral Bonus</asp:ListItem>
                        <asp:ListItem Value="bonus">Special Bonus</asp:ListItem>
                    </asp:DropDownList>
                    
                    <asp:DropDownList ID="ddlDateFilter" runat="server" CssClass="filter-select-glass"
                        AutoPostBack="true" OnSelectedIndexChanged="ddlDateFilter_SelectedIndexChanged">
                        <asp:ListItem Value="today">Today</asp:ListItem>
                        <asp:ListItem Value="week">This Week</asp:ListItem>
                        <asp:ListItem Value="month" Selected="True">This Month</asp:ListItem>
                        <asp:ListItem Value="year">This Year</asp:ListItem>
                        <asp:ListItem Value="all">All Time</asp:ListItem>
                    </asp:DropDownList>
                    
                    <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control-glass"
                        placeholder="Search rewards..." AutoPostBack="true"
                        OnTextChanged="txtSearch_TextChanged"></asp:TextBox>
                </div>
            </div>
            
            <!-- Rewards Cards -->
            <asp:Panel ID="pnlRewardCards" runat="server" CssClass="rewards-cards-grid">
                <asp:Repeater ID="rptRewards" runat="server">
                    <ItemTemplate>
                        <div class='reward-card-glass <%# GetTypeColor(Eval("TypeCategory").ToString()) %>'>
                            <div class="reward-card-header">
                                <div class="d-flex justify-content-between align-items-center">
                                    <span class="reward-id"><%# Eval("RewardId") %></span>
                                    <span class="reward-amount text-success">
                                        +<%# FormatAmount(Eval("Amount")) %>
                                    </span>
                                </div>
                                <span class='reward-type-badge <%# GetTypeColor(Eval("TypeCategory").ToString()) %>'>
                                    <i class='<%# GetTypeIcon(Eval("TypeCategory").ToString()) %> me-1'></i>
                                    <%# Eval("TypeCategory") %>
                                </span>
                            </div>
                            
                            <div class="reward-card-body">
                                <div class="reward-details mt-3">
                                    <div class="detail-item">
                                        <span class="detail-label">Reference</span>
                                        <span class="detail-value"><%# Eval("Reference") %></span>
                                    </div>
                                    <div class="detail-item">
                                        <span class="detail-label">Type</span>
                                        <span class="detail-value"><%# Eval("Type") %></span>
                                    </div>
                                    <div class="detail-item">
                                        <span class="detail-label">Amount</span>
                                        <span class="detail-value text-success font-weight-bold">
                                            +<%# FormatAmount(Eval("Amount")) %>
                                        </span>
                                    </div>
                                </div>
                            </div>
                            
                            <div class="reward-card-footer">
                                <div class="reward-time">
                                    <i class="fas fa-calendar"></i>
                                    <span><%# FormatDateTime(Eval("CreatedDate")) %></span>
                                </div>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </asp:Panel>
            
            <!-- Empty State -->
            <asp:Panel ID="pnlEmptyState" runat="server" CssClass="empty-state-glass" Visible="false">
                <div class="empty-state-icon">
                    <i class="fas fa-trophy"></i>
                </div>
                <h4 class="empty-state-title">No Rewards Found</h4>
                <p class="empty-state-message">
                    You haven't earned any XP credits yet. Start by submitting waste reports!
                </p>
                <asp:LinkButton ID="btnEarnFirstReward" runat="server" CssClass="action-btn primary"
                    OnClick="btnEarnFirstReward_Click">
                    <i class="fas fa-plus-circle me-2"></i> Earn Your First Reward
                </asp:LinkButton>
            </asp:Panel>
            
            <!-- Loading State -->
            <asp:Panel ID="pnlLoading" runat="server" CssClass="text-center py-5" Visible="false">
                <div class="loader-glass"></div>
                <p class="text-muted mt-3">Loading rewards...</p>
            </asp:Panel>
        </div>

        <!-- Redemptions Section -->
        <div class="redemptions-container mt-4">
            <div class="redemptions-header">
                <h3 class="redemptions-title">Redemption History</h3>
            </div>
            
            <asp:Panel ID="pnlRedemptions" runat="server" CssClass="redemptions-list">
                <asp:Repeater ID="rptRedemptions" runat="server">
                    <ItemTemplate>
                        <div class='redemption-item <%# GetRedemptionStatusColor(Eval("Status").ToString()) %>'>
                            <div class="redemption-header">
                                <div class="d-flex justify-content-between align-items-center">
                                    <span class="redemption-id"><%# Eval("RedemptionId") %></span>
                                    <span class="redemption-amount">
                                        <%# FormatAmount(Eval("Amount")) %>
                                    </span>
                                </div>
                                <span class='redemption-status-badge <%# GetRedemptionStatusColor(Eval("Status").ToString()) %>'>
                                    <i class='<%# GetRedemptionStatusIcon(Eval("Status").ToString()) %> me-1'></i>
                                    <%# Eval("Status") %>
                                </span>
                            </div>
                            
                            <div class="redemption-body">
                                <div class="redemption-details">
                                    <div class="detail-row">
                                        <span class="detail-label">Method:</span>
                                        <span class="detail-value"><%# Eval("Method") %></span>
                                    </div>
                                    <div class="detail-row">
                                        <span class="detail-label">Requested:</span>
                                        <span class="detail-value"><%# FormatDateTime(Eval("RequestedAt")) %></span>
                                    </div>
                                    <div class="detail-row">
                                        <span class="detail-label">Processed:</span>
                                        <span class="detail-value">
                                            <%# Eval("ProcessedAt") != DBNull.Value ? FormatDateTime(Eval("ProcessedAt")) : "Pending" %>
                                        </span>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </asp:Panel>
            
            <asp:Panel ID="pnlNoRedemptions" runat="server" CssClass="text-center py-4" Visible="false">
                <div class="no-redemptions">
                    <i class="fas fa-exchange-alt fa-3x text-muted mb-3"></i>
                    <h5 class="text-muted">No Redemption History</h5>
                    <p class="text-muted">You haven't made any redemption requests yet.</p>
                </div>
            </asp:Panel>
        </div>
        
        <!-- Pagination -->
        <div class="d-flex justify-content-between align-items-center mt-4">
            <div class="text-muted">
                Showing <asp:Label ID="lblStartCount" runat="server" Text="1"></asp:Label> - 
                <asp:Label ID="lblEndCount" runat="server" Text="10"></asp:Label> of 
                <asp:Label ID="lblTotalCount" runat="server" Text="0"></asp:Label> rewards
            </div>
            
            <div class="d-flex gap-2">
                <asp:LinkButton ID="btnPrevPage" runat="server" CssClass="action-btn secondary small"
                    OnClick="btnPrevPage_Click">
                    <i class="fas fa-chevron-left"></i>
                </asp:LinkButton>
                
                <div class="d-flex gap-1">
                    <asp:Repeater ID="rptPageNumbers" runat="server">
                        <ItemTemplate>
                            <asp:LinkButton ID="btnPage" runat="server" 
                                CssClass='<%# Convert.ToInt32(Eval("PageNumber")) == Convert.ToInt32(Eval("CurrentPage")) ? "action-btn primary small" : "action-btn secondary small" %>'
                                CommandArgument='<%# Eval("PageNumber") %>'
                                OnClick="btnPage_Click"
                                Text='<%# Eval("PageNumber") %>'></asp:LinkButton>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
                
                <asp:LinkButton ID="btnNextPage" runat="server" CssClass="action-btn secondary small"
                    OnClick="btnNextPage_Click">
                    <i class="fas fa-chevron-right"></i>
                </asp:LinkButton>
            </div>
        </div>
    </div>
    
    <!-- Redeem Modal -->
    <div class="modal fade" id="redeemModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered modal-lg">
            <div class="modal-content report-modal-glass">
                <div class="modal-header-glass">
                    <h5 class="modal-title-glass">Redeem XP Credits</h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body-glass">
                    <div class="row">
                        <div class="col-md-6">
                            <div class="form-group-modal mb-4">
                                <label class="form-label-modal">Available Credits</label>
                                <div class="available-credits-display">
                                    <i class="fas fa-wallet text-success me-2"></i>
                                    <span class="credit-amount" id="availableCredits">0</span>
                                    <span class="credit-label">XP</span>
                                </div>
                            </div>
                            
                            <div class="form-group-modal mb-4">
                                <label class="form-label-modal">Redemption Amount (XP)</label>
                                <div class="input-group-modal">
                                    <i class="fas fa-coins input-icon-modal"></i>
                                    <asp:TextBox ID="txtRedemptionAmount" runat="server" CssClass="form-control-modal"
                                        Text="100" TextMode="Number" min="100" step="50"></asp:TextBox>
                                </div>
                                <small class="text-muted">Minimum: 100 XP</small>
                            </div>
                            
                            <div class="form-group-modal mb-4">
                                <label class="form-label-modal">Redemption Method</label>
                                <div class="input-group-modal">
                                    <i class="fas fa-exchange-alt input-icon-modal"></i>
                                    <asp:DropDownList ID="ddlRedemptionMethod" runat="server" CssClass="form-control-modal">
                                        <asp:ListItem Value="bank">Bank Transfer</asp:ListItem>
                                        <asp:ListItem Value="mobile">Mobile Money</asp:ListItem>
                                        <asp:ListItem Value="voucher">E-Voucher</asp:ListItem>
                                        <asp:ListItem Value="gift">Gift Card</asp:ListItem>
                                    </asp:DropDownList>
                                </div>
                            </div>
                        </div>
                        
                        <div class="col-md-6">
                            <div class="info-box-glass">
                                <h6 class="mb-3"><i class="fas fa-info-circle me-2"></i>Redemption Details</h6>
                                <div class="detail-row">
                                    <span class="detail-label">Exchange Rate:</span>
                                    <span class="detail-value">100 XP = ₹10</span>
                                </div>
                                <div class="detail-row">
                                    <span class="detail-label">Processing Time:</span>
                                    <span class="detail-value">24-72 hours</span>
                                </div>
                                <div class="detail-row">
                                    <span class="detail-label">Minimum Amount:</span>
                                    <span class="detail-value">100 XP</span>
                                </div>
                                <div class="detail-row">
                                    <span class="detail-label">Processing Fee:</span>
                                    <span class="detail-value">2%</span>
                                </div>
                                <div class="detail-row">
                                    <span class="detail-label">Estimated Value:</span>
                                    <span class="detail-value text-success" id="estimatedValue">₹0</span>
                                </div>
                            </div>
                            
                            <div class="form-group-modal mb-4">
                                <label class="form-label-modal">Account Details</label>
                                <div class="input-group-modal">
                                    <i class="fas fa-user input-icon-modal"></i>
                                    <asp:TextBox ID="txtAccountName" runat="server" CssClass="form-control-modal"
                                        placeholder="Account Holder Name"></asp:TextBox>
                                </div>
                            </div>
                            
                            <div class="form-group-modal mb-4">
                                <div class="input-group-modal">
                                    <i class="fas fa-id-card input-icon-modal"></i>
                                    <asp:TextBox ID="txtAccountNumber" runat="server" CssClass="form-control-modal"
                                        placeholder="Account/Mobile Number"></asp:TextBox>
                                </div>
                            </div>
                        </div>
                    </div>
                    
                    <div class="form-group-modal mb-4">
                        <label class="form-label-modal">Additional Notes (Optional)</label>
                        <div class="input-group-modal">
                            <i class="fas fa-sticky-note input-icon-modal"></i>
                            <asp:TextBox ID="txtRedemptionNotes" runat="server" CssClass="form-control-modal"
                                TextMode="MultiLine" Rows="2"
                                placeholder="Any special instructions or notes"></asp:TextBox>
                        </div>
                    </div>
                </div>
                <div class="modal-footer-glass">
                    <button type="button" class="action-btn secondary" data-bs-dismiss="modal">Cancel</button>
                    <asp:Button ID="btnRedeem" runat="server" CssClass="action-btn primary"
                        Text="Submit Redemption" OnClick="btnRedeem_Click" />
                </div>
            </div>
        </div>
    </div>
    
    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    
    <!-- JavaScript -->
    <script type="text/javascript">
        // Show redeem modal
        function showRedeemModal() {
            var modal = new bootstrap.Modal(document.getElementById('redeemModal'));
            modal.show();
            
            // Load available credits
            loadAvailableCredits();
            
            // Setup amount calculation
            setupAmountCalculation();
        }
        
        function loadAvailableCredits() {
            // This would typically be an AJAX call to get available credits
            // For now, show from the stat
            var availableCredits = document.getElementById('<%= statAvailableCredits.ClientID %>').innerText;
            document.getElementById('availableCredits').textContent = availableCredits;
        }
        
        function setupAmountCalculation() {
            var amountInput = document.getElementById('<%= txtRedemptionAmount.ClientID %>');
            var estimatedValue = document.getElementById('estimatedValue');
            
            amountInput.addEventListener('input', function() {
                calculateEstimatedValue();
            });
            
            calculateEstimatedValue();
        }
        
        function calculateEstimatedValue() {
            var amountInput = document.getElementById('<%= txtRedemptionAmount.ClientID %>');
            var estimatedValue = document.getElementById('estimatedValue');

            var amount = parseFloat(amountInput.value) || 0;
            var rate = 0.1; // 100 XP = ₹10, so 1 XP = ₹0.1
            var fee = 0.02; // 2% fee

            var grossValue = amount * rate;
            var netValue = grossValue - (grossValue * fee);

            estimatedValue.textContent = '₹' + netValue.toFixed(2);
        }

        // Initialize tooltips
        document.addEventListener('DOMContentLoaded', function () {
            var tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'));
            var tooltipList = tooltipTriggerList.map(function (tooltipTriggerEl) {
                return new bootstrap.Tooltip(tooltipTriggerEl);
            });
        });
    </script>
</asp:Content>