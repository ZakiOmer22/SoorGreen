<%@ Page Title="My Rewards" Language="C#" MasterPageFile="~/Pages/Collectors/Site.Master" 
    AutoEventWireup="true" Inherits="SoorGreen.Citizens.MyRewards" Codebehind="MyRewards.aspx.cs" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <link href='<%= ResolveUrl("~/Content/Pages/Collectors/MyRewards.css") %>' rel="stylesheet" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</asp:Content>

<asp:Content ID="TitleContent" ContentPlaceHolderID="TitleContent" runat="server">
    My Rewards - SoorGreen Citizen
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <!-- Hidden fields -->
    <asp:HiddenField ID="hdnCurrentPage" runat="server" Value="1" />
    <asp:HiddenField ID="hdnUserId" runat="server" />

    <div class="rewards-container" id="pageContainer">
        <!-- Page Header -->
        <div class="page-header-glass mb-4">
            <div class="d-flex justify-content-between align-items-center">
                <div>
                    <h1 class="page-title-glass mb-2">
                        <i class="fas fa-award me-3 text-warning"></i>My Rewards
                    </h1>
                    <p class="page-subtitle-glass mb-0">Track your eco-contributions and redeem your earned credits</p>
                </div>
                <div class="d-flex gap-2">
                    <asp:LinkButton ID="btnRefresh" runat="server" CssClass="action-btn secondary"
                        OnClick="btnRefresh_Click" OnClientClick="showLoading()">
                        <i class="fas fa-sync-alt me-2"></i>Refresh
                    </asp:LinkButton>
                    <asp:LinkButton ID="btnRedeemCredits" runat="server" CssClass="action-btn primary"
                        OnClientClick="showRedemptionModal(); return false;">
                        <i class="fas fa-gift me-2"></i>Redeem Credits
                    </asp:LinkButton>
                </div>
            </div>
        </div>

        <!-- Rewards Overview -->
        <div class="rewards-stats-grid mb-4">
            <div class="rewards-stat-card">
                <div class="stat-icon-large text-warning">
                    <i class="fas fa-coins"></i>
                </div>
                <div class="stat-number-large">
                    <asp:Label ID="statTotalCredits" runat="server" Text="0">0</asp:Label>
                </div>
                <div class="stat-label">Total Credits</div>
                <small class="text-muted">Available for redemption</small>
            </div>

            <div class="rewards-stat-card">
                <div class="stat-icon-large text-success">
                    <i class="fas fa-recycle"></i>
                </div>
                <div class="stat-number-large">
                    <asp:Label ID="statTotalRecycled" runat="server" Text="0">0</asp:Label> kg
                </div>
                <div class="stat-label">Total Recycled</div>
                <small class="text-muted">Waste collected</small>
            </div>

            <div class="rewards-stat-card">
                <div class="stat-icon-large text-info">
                    <i class="fas fa-chart-line"></i>
                </div>
                <div class="stat-number-large">
                    <asp:Label ID="statThisMonth" runat="server" Text="0">0</asp:Label>
                </div>
                <div class="stat-label">This Month</div>
                <small class="text-muted">Credits earned</small>
            </div>

            <div class="rewards-stat-card">
                <div class="stat-icon-large text-primary">
                    <i class="fas fa-trophy"></i>
                </div>
                <div class="stat-number-large">
                    <asp:Label ID="statRank" runat="server" Text="#1">#1</asp:Label>
                </div>
                <div class="stat-label">City Rank</div>
                <small class="text-muted">Among citizens</small>
            </div>
        </div>

        <!-- Quick Actions -->
        <div class="rewards-quick-actions mb-4">
            <div class="quick-action-grid">
                <asp:LinkButton ID="btnViewVouchers" runat="server" CssClass="quick-action-btn"
                    OnClick="btnViewVouchers_Click">
                    <div class="quick-action-icon text-success">
                        <i class="fas fa-ticket-alt"></i>
                    </div>
                    <div class="quick-action-text">View Vouchers</div>
                </asp:LinkButton>

                <asp:HyperLink ID="lnkTransactionHistory" runat="server" CssClass="quick-action-btn"
                    NavigateUrl="~/Pages/Collectors/TransactionHistory.aspx">
                    <div class="quick-action-icon text-info">
                        <i class="fas fa-history"></i>
                    </div>
                    <div class="quick-action-text">Transaction History</div>
                </asp:HyperLink>

                <asp:LinkButton ID="btnAchievements" runat="server" CssClass="quick-action-btn"
                    OnClick="btnAchievements_Click">
                    <div class="quick-action-icon text-warning">
                        <i class="fas fa-medal"></i>
                    </div>
                    <div class="quick-action-text">Achievements</div>
                </asp:LinkButton>

                <asp:HyperLink ID="lnkReferFriends" runat="server" CssClass="quick-action-btn"
                    NavigateUrl="~/Pages/Collectors/Referral.aspx">
                    <div class="quick-action-icon text-primary">
                        <i class="fas fa-user-plus"></i>
                    </div>
                    <div class="quick-action-text">Refer Friends</div>
                </asp:HyperLink>
            </div>
        </div>

        <!-- Rewards List -->
        <div class="rewards-list-container mb-4">
            <div class="rewards-list-header">
                <h4><i class="fas fa-gifts me-2"></i>Available Rewards</h4>
                <div class="rewards-filter">
                    <asp:DropDownList ID="ddlRewardCategory" runat="server" CssClass="form-control-glass small"
                        AutoPostBack="true" OnSelectedIndexChanged="ddlRewardCategory_SelectedIndexChanged">
                        <asp:ListItem Value="all" Selected="True">All Categories</asp:ListItem>
                        <asp:ListItem Value="voucher">Vouchers</asp:ListItem>
                        <asp:ListItem Value="product">Products</asp:ListItem>
                        <asp:ListItem Value="donation">Donations</asp:ListItem>
                        <asp:ListItem Value="cash">Cash Back</asp:ListItem>
                    </asp:DropDownList>
                </div>
            </div>

            <div class="rewards-grid">
                <asp:Repeater ID="rptRewards" runat="server" OnItemCommand="rptRewards_ItemCommand">
                    <ItemTemplate>
                        <div class="reward-card">
                            <div class="reward-card-header">
                                <span class='<%# GetRewardBadgeClass(Eval("Category").ToString()) %>'>
                                    <i class='<%# GetRewardIcon(Eval("Category").ToString()) %> me-1'></i>
                                    <%# Eval("Category") %>
                                </span>
                                <span class="reward-cost">
                                    <i class="fas fa-coins text-warning"></i>
                                    <%# Eval("Cost", "{0:N0}") %>
                                </span>
                            </div>
                            <div class="reward-card-body">
                                <h5><%# Eval("Title") %></h5>
                                <p class="reward-description"><%# Eval("Description") %></p>
                                <div class="reward-validity">
                                    <i class="fas fa-calendar-alt me-1"></i>
                                    Valid until: <%# FormatDate(Eval("ValidUntil")) %>
                                </div>
                                <div class="reward-stock">
                                    <i class="fas fa-box me-1"></i>
                                    <%# Eval("Stock", "{0:N0}") %> available
                                </div>
                            </div>
                            <div class="reward-card-footer">
                                <asp:LinkButton ID="btnRedeemReward" runat="server"
                                    CommandName="Redeem"
                                    CommandArgument='<%# Eval("RewardId") + "|" + Eval("Title") + "|" + Eval("Cost") %>'
                                    CssClass="action-btn primary w-100"
                                    OnClientClick='<%# "return confirmRedeem(\"" + Eval("Title").ToString().Replace("\"", "\\\"") + "\", " + Eval("Cost") + ");" %>'
                                    Enabled='<%# IsRewardAvailable(Eval("Cost").ToString(), Eval("Stock").ToString()) %>'>
                                    <i class="fas fa-gift me-2"></i>
                                    <asp:Literal ID="litButtonText" runat="server" 
                                        Text='<%# IsRewardAvailable(Eval("Cost").ToString(), Eval("Stock").ToString()) ? "Redeem Now" : "Not Enough Credits" %>'></asp:Literal>
                                </asp:LinkButton>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>

                <asp:Panel ID="pnlNoRewards" runat="server" CssClass="empty-rewards" Visible="false">
                    <div class="empty-rewards-icon">
                        <i class="fas fa-gift fa-3x text-muted"></i>
                    </div>
                    <h4 class="mb-3">No Rewards Available</h4>
                    <p class="text-muted">Check back later for new rewards or earn more credits.</p>
                </asp:Panel>
            </div>
        </div>

        <!-- Recent Transactions -->
        <div class="recent-transactions mb-4">
            <div class="transactions-header">
                <h4><i class="fas fa-exchange-alt me-2"></i>Recent Transactions</h4>
                <asp:HyperLink ID="lnkViewAllTransactions" runat="server" CssClass="action-btn secondary small"
                    NavigateUrl="~/Pages/Collectors/TransactionHistory.aspx">
                    View All <i class="fas fa-arrow-right ms-1"></i>
                </asp:HyperLink>
            </div>

            <div class="modern-table-container">
                <div class="modern-table-header">
                    <div class="modern-table-header-row">
                        <div class="table-col">Date</div>
                        <div class="table-col">Transaction</div>
                        <div class="table-col">Type</div>
                        <div class="table-col">Amount</div>
                        <div class="table-col">Balance</div>
                        <div class="table-col">Reference</div>
                    </div>
                </div>

                <div class="modern-table-body">
                    <asp:Repeater ID="rptTransactions" runat="server" OnItemDataBound="rptTransactions_ItemDataBound">
                        <ItemTemplate>
                            <div class='<%# Container.ItemIndex % 2 == 0 ? "modern-table-row" : "modern-table-row alt" %>'>
                                <div class="table-col" data-label="Date">
                                    <span class="text-muted">
                                        <i class="fas fa-calendar me-1"></i>
                                        <%# FormatDateShort(Eval("CreatedAt")) %>
                                    </span>
                                </div>
                                <div class="table-col" data-label="Transaction">
                                    <div class="transaction-description">
                                        <asp:Literal ID="litTransactionIcon" runat="server"></asp:Literal>
                                        <%# Eval("Description") %>
                                    </div>
                                </div>
                                <div class="table-col" data-label="Type">
                                    <asp:Literal ID="litTypeBadge" runat="server"></asp:Literal>
                                </div>
                                <div class="table-col" data-label="Amount">
                                    <asp:Literal ID="litAmount" runat="server"></asp:Literal>
                                </div>
                                <div class="table-col" data-label="Balance">
                                    <span class="fw-bold">
                                        <i class="fas fa-coins text-warning me-1"></i>
                                        <%# Eval("Balance", "{0:N2}") %>
                                    </span>
                                </div>
                                <div class="table-col" data-label="Reference">
                                    <span class="text-muted small">
                                        <%# Eval("Reference") %>
                                    </span>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>

                    <asp:Panel ID="pnlNoTransactions" runat="server" CssClass="empty-transactions" Visible="false">
                        <div class="text-center py-4">
                            <i class="fas fa-exchange-alt fa-3x text-muted mb-3"></i>
                            <p class="text-muted">No transactions yet. Start recycling to earn credits!</p>
                        </div>
                    </asp:Panel>
                </div>
            </div>
        </div>

        <!-- Achievement Progress -->
        <div class="achievements-section mb-4">
            <div class="achievements-header">
                <h4><i class="fas fa-trophy me-2"></i>Achievement Progress</h4>
                <div class="progress-info">
                    <span class="badge badge-glass">
                        <i class="fas fa-star me-1"></i>
                        <asp:Label ID="lblAchievedCount" runat="server" Text="0"></asp:Label>/<asp:Label ID="lblTotalAchievements" runat="server" Text="12"></asp:Label> Achieved
                    </span>
                </div>
            </div>

            <div class="achievements-grid">
                <asp:Repeater ID="rptAchievements" runat="server">
                    <ItemTemplate>
                        <div class="achievement-card <%# Convert.ToBoolean(Eval("Achieved")) ? "achievement-unlocked" : "achievement-locked" %>">
                            <div class="achievement-icon">
                                <i class='<%# Eval("Icon") %>'></i>
                            </div>
                            <div class="achievement-content">
                                <h6><%# Eval("Title") %></h6>
                                <p class="achievement-description"><%# Eval("Description") %></p>
                                <div class="achievement-progress">
                                    <div class="progress">
                                        <div class="progress-bar" style='width: <%# Eval("ProgressPercent") %>%;'></div>
                                    </div>
                                    <small><%# Eval("ProgressText") %></small>
                                </div>
                                <div class="achievement-reward">
                                    <i class="fas fa-coins text-warning me-1"></i>
                                    +<%# Eval("Reward") %> credits
                                </div>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
        </div>

        <!-- Redemption History -->
        <div class="redemption-history">
            <div class="history-header">
                <h4><i class="fas fa-clock me-2"></i>Redemption History</h4>
                <asp:DropDownList ID="ddlHistoryPeriod" runat="server" CssClass="form-control-glass small"
                    AutoPostBack="true" OnSelectedIndexChanged="ddlHistoryPeriod_SelectedIndexChanged">
                    <asp:ListItem Value="30" Selected="True">Last 30 days</asp:ListItem>
                    <asp:ListItem Value="90">Last 90 days</asp:ListItem>
                    <asp:ListItem Value="180">Last 6 months</asp:ListItem>
                    <asp:ListItem Value="365">Last year</asp:ListItem>
                    <asp:ListItem Value="all">All time</asp:ListItem>
                </asp:DropDownList>
            </div>

            <div class="redemption-list">
                <asp:Repeater ID="rptRedemptions" runat="server" OnItemDataBound="rptRedemptions_ItemDataBound">
                    <ItemTemplate>
                        <div class="redemption-item">
                            <div class="redemption-icon">
                                <asp:Literal ID="litRedemptionIcon" runat="server"></asp:Literal>
                            </div>
                            <div class="redemption-details">
                                <div class="redemption-title">
                                    <h6><%# Eval("RewardTitle") %></h6>
                                    <asp:Literal ID="litStatusBadge" runat="server"></asp:Literal>
                                </div>
                                <div class="redemption-info">
                                    <span class="text-muted">
                                        <i class="fas fa-calendar me-1"></i>
                                        <%# FormatDate(Eval("RequestedAt")) %>
                                    </span>
                                    <span class="redemption-cost">
                                        <i class="fas fa-coins text-warning me-1"></i>
                                        <%# Eval("Amount", "{0:N0}") %> credits
                                    </span>
                                </div>
                                <asp:Literal ID="litRedemptionNote" runat="server"></asp:Literal>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>

                <asp:Panel ID="pnlNoRedemptions" runat="server" CssClass="empty-redemptions" Visible="false">
                    <div class="text-center py-4">
                        <i class="fas fa-gift fa-3x text-muted mb-3"></i>
                        <p class="text-muted">No redemption history yet. Redeem your first reward!</p>
                    </div>
                </asp:Panel>
            </div>
        </div>
    </div>
    
    <!-- Redemption Modal -->
    <div class="modal fade" id="redemptionModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content pickup-modal-glass">
                <div class="modal-header-glass">
                    <h5 class="modal-title-glass">
                        <i class="fas fa-gift me-2"></i> Redeem Credits
                    </h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body-glass">
                    <div class="mb-4">
                        <label class="form-label">Available Credits</label>
                        <div class="credits-display">
                            <i class="fas fa-coins text-warning fa-2x me-3"></i>
                            <div>
                                <h3 class="mb-0"><asp:Label ID="lblModalCredits" runat="server" Text="0"></asp:Label></h3>
                                <small class="text-muted">Credits available for redemption</small>
                            </div>
                        </div>
                    </div>
                    
                    <div class="mb-3">
                        <label class="form-label">Redemption Amount <span class="text-danger">*</span></label>
                        <div class="input-group">
                            <span class="input-group-text">
                                <i class="fas fa-coins text-warning"></i>
                            </span>
                            <asp:TextBox ID="txtRedemptionAmount" runat="server" CssClass="form-control-glass"
                                TextMode="Number" min="100" step="50" placeholder="Enter amount to redeem" required="true"></asp:TextBox>
                            <span class="input-group-text">credits</span>
                        </div>
                        <small class="text-muted">Minimum redemption: 100 credits</small>
                    </div>
                    
                    <div class="mb-4">
                        <label class="form-label">Redemption Method <span class="text-danger">*</span></label>
                        <asp:DropDownList ID="ddlRedemptionMethod" runat="server" CssClass="form-control-glass" required="true">
                            <asp:ListItem Value="">Select Method</asp:ListItem>
                            <asp:ListItem Value="bank">Bank Transfer</asp:ListItem>
                            <asp:ListItem Value="mobile">Mobile Money</asp:ListItem>
                            <asp:ListItem Value="voucher">E-Voucher</asp:ListItem>
                            <asp:ListItem Value="charity">Charity Donation</asp:ListItem>
                        </asp:DropDownList>
                    </div>
                    
                    <!-- Dynamic details sections -->
                    <div id="bankDetails" class="redemption-details mb-3" style="display: none;">
                        <h6><i class="fas fa-university me-2"></i>Bank Details</h6>
                        <div class="mb-2">
                            <label class="form-label small">Bank Name</label>
                            <input type="text" class="form-control-glass small" placeholder="e.g., Standard Bank">
                        </div>
                        <div class="mb-2">
                            <label class="form-label small">Account Holder</label>
                            <input type="text" class="form-control-glass small" placeholder="Full name as per bank">
                        </div>
                        <div class="mb-2">
                            <label class="form-label small">Account Number</label>
                            <input type="text" class="form-control-glass small" placeholder="1234567890">
                        </div>
                        <div>
                            <label class="form-label small">Branch Code</label>
                            <input type="text" class="form-control-glass small" placeholder="051001">
                        </div>
                    </div>
                    
                    <div id="mobileDetails" class="redemption-details mb-3" style="display: none;">
                        <h6><i class="fas fa-mobile-alt me-2"></i>Mobile Money Details</h6>
                        <div class="mb-2">
                            <label class="form-label small">Provider</label>
                            <select class="form-control-glass small">
                                <option>M-Pesa</option>
                                <option>Airtel Money</option>
                                <option>MTN Mobile Money</option>
                                <option>Tigo Pesa</option>
                            </select>
                        </div>
                        <div class="mb-2">
                            <label class="form-label small">Phone Number</label>
                            <input type="tel" class="form-control-glass small" placeholder="+255 712 345 678">
                        </div>
                        <div>
                            <label class="form-label small">Account Name</label>
                            <input type="text" class="form-control-glass small" placeholder="Name on mobile money account">
                        </div>
                    </div>
                    
                    <div id="voucherDetails" class="redemption-details mb-3" style="display: none;">
                        <h6><i class="fas fa-ticket-alt me-2"></i>Voucher Details</h6>
                        <div class="alert alert-info small">
                            <i class="fas fa-info-circle me-1"></i>
                            E-voucher will be sent to your registered email address.
                        </div>
                    </div>
                    
                    <div id="charityDetails" class="redemption-details mb-3" style="display: none;">
                        <h6><i class="fas fa-hands-helping me-2"></i>Charity Donation</h6>
                        <div class="mb-2">
                            <label class="form-label small">Select Charity</label>
                            <select class="form-control-glass small">
                                <option>World Wildlife Fund</option>
                                <option>Greenpeace</option>
                                <option>Local Tree Planting Initiative</option>
                                <option>Ocean Cleanup Project</option>
                            </select>
                        </div>
                        <div class="alert alert-success small">
                            <i class="fas fa-seedling me-1"></i>
                            Your donation will be matched by SoorGreen!
                        </div>
                    </div>
                    
                    <div class="alert alert-info">
                        <i class="fas fa-info-circle me-2"></i>
                        Redemption requests are processed within 1-2 business days.
                    </div>
                </div>
                <div class="modal-footer-glass">
                    <button type="button" class="action-btn secondary" data-bs-dismiss="modal">Cancel</button>
                    <asp:Button ID="btnSubmitRedemption" runat="server" Text="Submit Request" 
                        CssClass="action-btn primary" OnClick="btnSubmitRedemption_Click" 
                        OnClientClick="return validateRedemption();" />
                </div>
            </div>
        </div>
    </div>
    
    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    
    <!-- JavaScript -->
    <script type="text/javascript">
        // Store current credits globally
        var currentCredits = <%= GetCurrentCredits() %>;
        
        // Loading spinner functions
        function showLoading() {
            const spinner = document.createElement('div');
            spinner.className = 'loading-overlay';
            spinner.innerHTML = '<div class="spinner"></div><p>Loading rewards...</p>';
            document.getElementById('pageContainer').appendChild(spinner);
        }

        function hideLoading() {
            const spinners = document.querySelectorAll('.loading-overlay');
            spinners.forEach(spinner => spinner.remove());
        }

        // Show redemption modal
        function showRedemptionModal() {
            // Update modal with current credits
            document.getElementById('<%= lblModalCredits.ClientID %>').innerText = currentCredits.toLocaleString();
            
            // Reset form
            document.getElementById('<%= txtRedemptionAmount.ClientID %>').value = '';
            document.getElementById('<%= ddlRedemptionMethod.ClientID %>').selectedIndex = 0;
            
            // Hide all detail sections
            document.querySelectorAll('.redemption-details').forEach(section => {
                section.style.display = 'none';
            });
            
            const modal = new bootstrap.Modal(document.getElementById('redemptionModal'));
            modal.show();
        }

        // Handle method selection in modal
        document.addEventListener('DOMContentLoaded', function () {
            const methodSelect = document.getElementById('<%= ddlRedemptionMethod.ClientID %>');
            if (methodSelect) {
                methodSelect.addEventListener('change', function () {
                    // Hide all detail sections
                    document.querySelectorAll('.redemption-details').forEach(section => {
                        section.style.display = 'none';
                    });
                    
                    // Show selected section
                    const selectedValue = this.value;
                    if (selectedValue) {
                        const selectedSection = document.getElementById(selectedValue + 'Details');
                        if (selectedSection) {
                            selectedSection.style.display = 'block';
                        }
                    }
                });
            }

            // Handle amount input validation
            const amountInput = document.getElementById('<%= txtRedemptionAmount.ClientID %>');
            if (amountInput) {
                amountInput.addEventListener('input', function() {
                    const value = parseInt(this.value) || 0;
                    if (value > currentCredits) {
                        this.style.borderColor = '#ef4444';
                        this.style.boxShadow = '0 0 0 0.2rem rgba(239, 68, 68, 0.25)';
                    } else {
                        this.style.borderColor = '';
                        this.style.boxShadow = '';
                    }
                });
            }

            // Row hover effects for tables
            const rows = document.querySelectorAll('.modern-table-row');
            rows.forEach(function(row) {
                row.addEventListener('mouseenter', function () {
                    this.style.transform = 'translateY(-2px)';
                    this.style.boxShadow = '0 4px 12px rgba(0, 0, 0, 0.1)';
                });

                row.addEventListener('mouseleave', function () {
                    this.style.transform = '';
                    this.style.boxShadow = '';
                });
            });

            // Hide loading after page load
            setTimeout(hideLoading, 500);
            
            // Check for success message in URL
            const urlParams = new URLSearchParams(window.location.search);
            if (urlParams.has('success')) {
                showRewardToast(urlParams.get('success'), 'success');
                // Clean URL
                window.history.replaceState({}, document.title, window.location.pathname);
            }
            if (urlParams.has('error')) {
                showRewardToast(urlParams.get('error'), 'error');
                window.history.replaceState({}, document.title, window.location.pathname);
            }
        });

        // Confirmation for reward redemption
        function confirmRedeem(rewardTitle, cost) {
            return confirm(`Redeem "${rewardTitle}" for ${cost.toLocaleString()} credits?\n\nThis action cannot be undone.`);
        }

        // Validate redemption form
        function validateRedemption() {
            const amountInput = document.getElementById('<%= txtRedemptionAmount.ClientID %>');
            const methodSelect = document.getElementById('<%= ddlRedemptionMethod.ClientID %>');
            const amount = parseInt(amountInput.value) || 0;
            
            if (amount < 100) {
                showRewardToast('Minimum redemption amount is 100 credits', 'error');
                amountInput.focus();
                return false;
            }
            
            if (amount > currentCredits) {
                showRewardToast('Insufficient credits! Available: ' + currentCredits.toLocaleString(), 'error');
                amountInput.focus();
                return false;
            }
            
            if (!methodSelect.value) {
                showRewardToast('Please select a redemption method', 'error');
                methodSelect.focus();
                return false;
            }
            
            return confirm(`Redeem ${amount.toLocaleString()} credits via ${methodSelect.options[methodSelect.selectedIndex].text}?\n\nYou will receive the equivalent value via your selected method.`);
        }

        // Auto-refresh every 30 seconds for real-time updates
        setInterval(function() {
            if (document.visibilityState === 'visible') {
                __doPostBack('<%= btnRefresh.UniqueID %>', '');
            }
        }, 30000);

        // Toast notification function
        function showRewardToast(message, type) {
            // Remove existing toasts
            document.querySelectorAll('.toast-notification').forEach(toast => {
                toast.remove();
            });
            
            const icons = {
                'success': 'fas fa-check-circle',
                'error': 'fas fa-exclamation-circle',
                'warning': 'fas fa-exclamation-triangle',
                'info': 'fas fa-info-circle'
            };
            
            const toast = document.createElement('div');
            toast.className = `toast-notification toast-${type}`;
            toast.innerHTML = `
                <div class="toast-icon">
                    <i class="${icons[type] || 'fas fa-bell'}"></i>
                </div>
                <div class="toast-message">${message}</div>
                <button class="toast-close" onclick="this.parentElement.remove()">
                    <i class="fas fa-times"></i>
                </button>`;
            
            document.body.appendChild(toast);
            
            // Auto remove after 5 seconds
            setTimeout(function() {
                if (toast.parentElement) {
                    toast.remove();
                }
            }, 5000);
        }
        
        // Update current credits when page loads
        window.addEventListener('load', function() {
            const creditsElement = document.getElementById('<%= statTotalCredits.ClientID %>');
            if (creditsElement) {
                const creditsText = creditsElement.innerText.replace(/,/g, '');
                currentCredits = parseInt(creditsText) || 0;
            }
        });
    </script>
</asp:Content>