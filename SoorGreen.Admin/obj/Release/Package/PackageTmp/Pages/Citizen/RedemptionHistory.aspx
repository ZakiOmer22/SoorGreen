<%@ Page Title="Redemption History" Language="C#" MasterPageFile="~/Pages/Citizen/Site.Master" 
    AutoEventWireup="true" Inherits="SoorGreen.Admin.RedemptionHistory" Codebehind="RedemptionHistory.aspx.cs" %>

<asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
    <link href='<%= ResolveUrl("~/Content/Pages/Citizen/citizenredemptionhistory.css") %>' rel="stylesheet" />
    
    <!-- Add Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    
    <!-- Add Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</asp:Content>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Redemption History - SoorGreen Citizen
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <div class="redemption-history-container">
        <!-- Page Header -->
        <div class="page-header-glass">
            <h1 class="page-title-glass">Redemption History</h1>
            <p class="page-subtitle-glass">Track all your redemption requests and their status</p>
            
            <!-- Quick Actions -->
            <div class="d-flex gap-3 mt-4">
                <asp:LinkButton ID="btnNewRedemption" runat="server" CssClass="action-btn primary"
                    OnClick="btnNewRedemption_Click">
                    <i class="fas fa-exchange-alt me-2"></i> New Redemption
                </asp:LinkButton>
                
                <asp:LinkButton ID="btnRefresh" runat="server" CssClass="action-btn secondary"
                    OnClick="btnRefresh_Click">
                    <i class="fas fa-sync-alt me-2"></i> Refresh
                </asp:LinkButton>
                
                <asp:LinkButton ID="btnExport" runat="server" CssClass="action-btn secondary"
                    OnClick="btnExport_Click">
                    <i class="fas fa-file-export me-2"></i> Export History
                </asp:LinkButton>
            </div>
        </div>

        <!-- Stats Overview -->
        <div class="stats-overview-grid">
            <div class="stat-card-glass">
                <div class="d-flex align-items-start justify-content-between">
                    <div class="stat-icon-glass">
                        <i class="fas fa-exchange-alt"></i>
                    </div>
                    <div class="stat-trend trend-up">
                        <i class="fas fa-arrow-up"></i>
                        <span>18%</span>
                    </div>
                </div>
                <div class="stat-content-glass">
                    <div class="stat-number-glass" id="statTotalRedemptions" runat="server">0</div>
                    <div class="stat-label-glass">Total Redemptions</div>
                </div>
            </div>
            
            <div class="stat-card-glass">
                <div class="d-flex align-items-start justify-content-between">
                    <div class="stat-icon-glass">
                        <i class="fas fa-check-circle"></i>
                    </div>
                    <div class="stat-trend trend-up">
                        <i class="fas fa-arrow-up"></i>
                        <span>25%</span>
                    </div>
                </div>
                <div class="stat-content-glass">
                    <div class="stat-number-glass" id="statCompleted" runat="server">0</div>
                    <div class="stat-label-glass">Completed</div>
                </div>
            </div>
            
            <div class="stat-card-glass">
                <div class="d-flex align-items-start justify-content-between">
                    <div class="stat-icon-glass">
                        <i class="fas fa-clock"></i>
                    </div>
                    <div class="stat-trend trend-neutral">
                        <i class="fas fa-minus"></i>
                        <span>12%</span>
                    </div>
                </div>
                <div class="stat-content-glass">
                    <div class="stat-number-glass" id="statPending" runat="server">0</div>
                    <div class="stat-label-glass">Pending</div>
                </div>
            </div>
            
            <div class="stat-card-glass">
                <div class="d-flex align-items-start justify-content-between">
                    <div class="stat-icon-glass">
                        <i class="fas fa-coins"></i>
                    </div>
                    <div class="stat-trend trend-up">
                        <i class="fas fa-arrow-up"></i>
                        <span>32%</span>
                    </div>
                </div>
                <div class="stat-content-glass">
                    <div class="stat-number-glass" id="statTotalAmount" runat="server">0 XP</div>
                    <div class="stat-label-glass">Total Amount</div>
                </div>
            </div>
        </div>

        <!-- Filters Bar -->
        <div class="filters-bar-glass">
            <div class="filter-group">
                <label class="filter-label">Status</label>
                <asp:DropDownList ID="ddlStatusFilter" runat="server" CssClass="filter-select-glass"
                    AutoPostBack="true" OnSelectedIndexChanged="ddlStatusFilter_SelectedIndexChanged">
                    <asp:ListItem Value="all">All Status</asp:ListItem>
                    <asp:ListItem Value="pending">Pending</asp:ListItem>
                    <asp:ListItem Value="approved">Approved</asp:ListItem>
                    <asp:ListItem Value="processing">Processing</asp:ListItem>
                    <asp:ListItem Value="completed">Completed</asp:ListItem>
                    <asp:ListItem Value="rejected">Rejected</asp:ListItem>
                </asp:DropDownList>
            </div>
            
            <div class="filter-group">
                <label class="filter-label">Method</label>
                <asp:DropDownList ID="ddlMethodFilter" runat="server" CssClass="filter-select-glass"
                    AutoPostBack="true" OnSelectedIndexChanged="ddlMethodFilter_SelectedIndexChanged">
                    <asp:ListItem Value="all">All Methods</asp:ListItem>
                    <asp:ListItem Value="bank">Bank Transfer</asp:ListItem>
                    <asp:ListItem Value="mobile">Mobile Money</asp:ListItem>
                    <asp:ListItem Value="voucher">E-Voucher</asp:ListItem>
                    <asp:ListItem Value="gift">Gift Card</asp:ListItem>
                </asp:DropDownList>
            </div>
            
            <div class="filter-group">
                <label class="filter-label">Date Range</label>
                <div class="d-flex gap-2">
                    <asp:TextBox ID="txtStartDate" runat="server" CssClass="date-input-glass"
                        TextMode="Date"></asp:TextBox>
                    <asp:TextBox ID="txtEndDate" runat="server" CssClass="date-input-glass"
                        TextMode="Date"></asp:TextBox>
                </div>
            </div>
            
            <div class="filter-group">
                <label class="filter-label">Search</label>
                <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control-glass"
                    placeholder="Search redemption ID..." AutoPostBack="true"
                    OnTextChanged="txtSearch_TextChanged"></asp:TextBox>
            </div>
            
            <div class="filter-group" style="align-self: flex-end;">
                <asp:LinkButton ID="btnApplyFilters" runat="server" CssClass="action-btn primary"
                    OnClick="btnApplyFilters_Click">
                    <i class="fas fa-filter me-2"></i> Apply Filters
                </asp:LinkButton>
            </div>
        </div>

        <!-- Redemptions Table -->
        <div class="redemptions-table-glass">
            <div class="table-header-glass">
                <h3 class="table-title-glass">Redemption Requests</h3>
                <div class="d-flex gap-2">
                    <asp:LinkButton ID="btnClearFilters" runat="server" CssClass="action-btn secondary small"
                        OnClick="btnClearFilters_Click">
                        <i class="fas fa-times me-1"></i> Clear Filters
                    </asp:LinkButton>
                </div>
            </div>
            
            <div class="table-container">
                <asp:Panel ID="pnlRedemptionsTable" runat="server">
                    <table class="redemptions-table">
                        <thead>
                            <tr>
                                <th>Redemption ID</th>
                                <th>Date</th>
                                <th>Method</th>
                                <th>Amount</th>
                                <th>Status</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <asp:Repeater ID="rptRedemptions" runat="server">
                                <ItemTemplate>
                                    <tr>
                                        <td>
                                            <strong><%# Eval("RedemptionId") %></strong>
                                            <div class="text-muted small"><%# Eval("Method") %></div>
                                        </td>
                                        <td>
                                            <div><%# FormatDate(Eval("RequestedAt")) %></div>
                                            <div class="text-muted small"><%# FormatTime(Eval("RequestedAt")) %></div>
                                        </td>
                                        <td>
                                            <span class='method-badge <%# Eval("Method").ToString().ToLower() %>'>
                                                <i class='<%# GetMethodIcon(Eval("Method").ToString()) %> me-1'></i>
                                                <%# Eval("Method") %>
                                            </span>
                                        </td>
                                        <td>
                                            <strong class="text-success"><%# FormatAmount(Eval("Amount")) %></strong>
                                        </td>
                                        <td>
                                            <span class='status-badge <%# Eval("Status").ToString().ToLower() %>'>
                                                <%# Eval("Status") %>
                                            </span>
                                            <%# Eval("ProcessedAt") != DBNull.Value ? "<div class='text-muted small'>" + FormatDate(Eval("ProcessedAt")) + "</div>" : "" %>
                                        </td>
                                        <td>
                                            <div class="action-buttons">
                                                <button type="button" class="btn btn-view" onclick='showRedemptionDetails("<%# Eval("RedemptionId") %>")'>
                                                    <i class="fas fa-eye"></i> View
                                                </button>
                                                <%# CanCancel(Eval("Status").ToString()) ? 
                                                    "<button type='button' class='btn btn-cancel' onclick='cancelRedemption(\"" + Eval("RedemptionId") + "\")'><i class='fas fa-times'></i> Cancel</button>" : 
                                                    "<button type='button' class='btn btn-cancel btn-disabled' disabled><i class='fas fa-times'></i> Cancel</button>" %>
                                            </div>
                                        </td>
                                    </tr>
                                </ItemTemplate>
                            </asp:Repeater>
                        </tbody>
                    </table>
                </asp:Panel>
            </div>
            
            <!-- Empty State -->
            <asp:Panel ID="pnlEmptyState" runat="server" CssClass="empty-state-glass" Visible="false">
                <div class="empty-state-icon">
                    <i class="fas fa-exchange-alt"></i>
                </div>
                <h4 class="empty-state-title">No Redemptions Found</h4>
                <p class="empty-state-message">
                    You haven't made any redemption requests yet. Start by redeeming your XP credits!
                </p>
                <asp:LinkButton ID="btnStartRedemption" runat="server" CssClass="action-btn primary"
                    OnClick="btnStartRedemption_Click">
                    <i class="fas fa-exchange-alt me-2"></i> Make Your First Redemption
                </asp:LinkButton>
            </asp:Panel>
            
            <!-- Loading State -->
            <asp:Panel ID="pnlLoading" runat="server" CssClass="text-center py-5" Visible="false">
                <div class="loader-glass"></div>
                <p class="text-muted mt-3">Loading redemption history...</p>
            </asp:Panel>
        </div>

        <!-- Pagination -->
        <div class="pagination-glass">
            <div class="pagination-info">
                Showing <asp:Label ID="lblStartCount" runat="server" Text="1"></asp:Label> - 
                <asp:Label ID="lblEndCount" runat="server" Text="10"></asp:Label> of 
                <asp:Label ID="lblTotalCount" runat="server" Text="0"></asp:Label> redemptions
            </div>
            
            <div class="pagination-controls">
                <asp:LinkButton ID="btnPrevPage" runat="server" CssClass="action-btn secondary small"
                    OnClick="btnPrevPage_Click" Enabled="false">
                    <i class="fas fa-chevron-left"></i>
                </asp:LinkButton>
                
                <div class="page-numbers">
                    <asp:Repeater ID="rptPageNumbers" runat="server">
                        <ItemTemplate>
                            <asp:LinkButton ID="btnPage" runat="server" 
                                CssClass='<%# Convert.ToInt32(Eval("PageNumber")) == Convert.ToInt32(Eval("CurrentPage")) ? "page-number active" : "page-number" %>'
                                CommandArgument='<%# Eval("PageNumber") %>'
                                OnClick="btnPage_Click"
                                Text='<%# Eval("PageNumber") %>'></asp:LinkButton>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
                
                <asp:LinkButton ID="btnNextPage" runat="server" CssClass="action-btn secondary small"
                    OnClick="btnNextPage_Click" Enabled="false">
                    <i class="fas fa-chevron-right"></i>
                </asp:LinkButton>
            </div>
        </div>
    </div>
    
    <!-- Redemption Details Modal -->
    <div class="modal fade" id="detailsModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered modal-lg">
            <div class="modal-content details-modal-glass">
                <div class="modal-header-glass">
                    <h5 class="modal-title-glass">Redemption Details</h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body-glass">
                    <div id="modalContent">
                        <!-- Content will be loaded via JavaScript -->
                        <div class="text-center py-4">
                            <div class="loader-glass"></div>
                            <p class="text-muted mt-3">Loading details...</p>
                        </div>
                    </div>
                </div>
                <div class="modal-footer-glass">
                    <button type="button" class="action-btn secondary" data-bs-dismiss="modal">Close</button>
                    <button type="button" class="action-btn primary" id="btnDownloadReceipt" style="display:none;">
                        <i class="fas fa-download me-2"></i> Download Receipt
                    </button>
                </div>
            </div>
        </div>
    </div>
    
    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    
    <!-- JavaScript -->
    <script type="text/javascript">
        // Show redemption details
        function showRedemptionDetails(redemptionId) {
            // Load redemption details
            loadRedemptionDetails(redemptionId);
            
            // Show modal
            var modalElement = document.getElementById('detailsModal');
            var modal = new bootstrap.Modal(modalElement);
            modal.show();
        }
        
        function loadRedemptionDetails(redemptionId) {
            var modalContent = document.getElementById('modalContent');
            
            // Show loading
            modalContent.innerHTML = `
                <div class="text-center py-4">
                    <div class="loader-glass"></div>
                    <p class="text-muted mt-3">Loading details...</p>
                </div>
            `;
            
            // Simulate loading
            setTimeout(function () {
                modalContent.innerHTML = `
                    <div class="details-grid">
                        <div class="detail-item">
                            <span class="detail-label">Redemption ID</span>
                            <span class="detail-value">${redemptionId}</span>
                        </div>
                        <div class="detail-item">
                            <span class="detail-label">Status</span>
                            <span class="detail-value">
                                <span class="status-badge completed">Completed</span>
                            </span>
                        </div>
                        <div class="detail-item">
                            <span class="detail-label">Method</span>
                            <span class="detail-value">
                                <span class="method-badge bank">Bank Transfer</span>
                            </span>
                        </div>
                        <div class="detail-item">
                            <span class="detail-label">Amount</span>
                            <span class="detail-value text-success font-weight-bold">500 XP</span>
                        </div>
                        <div class="detail-item">
                            <span class="detail-label">Requested Date</span>
                            <span class="detail-value">${new Date().toLocaleDateString()}</span>
                        </div>
                        <div class="detail-item">
                            <span class="detail-label">Processed Date</span>
                            <span class="detail-value">${new Date().toLocaleDateString()}</span>
                        </div>
                        <div class="detail-item">
                            <span class="detail-label">Reference Number</span>
                            <span class="detail-value">REF-${redemptionId}</span>
                        </div>
                        <div class="detail-item">
                            <span class="detail-label">Processing Fee</span>
                            <span class="detail-value">10 XP (2%)</span>
                        </div>
                        <div class="detail-item">
                            <span class="detail-label">Net Amount</span>
                            <span class="detail-value text-success font-weight-bold">₹45.00</span>
                        </div>
                    </div>
                `;
                
                // Show download button
                document.getElementById('btnDownloadReceipt').style.display = 'inline-block';
            }, 500);
        }
        
        // Cancel redemption
        function cancelRedemption(redemptionId) {
            if (confirm('Are you sure you want to cancel this redemption request?')) {
                // Show success message
                alert('Redemption request cancelled successfully!');
                
                // Reload page to reflect changes
                window.location.reload();
            }
        }
        
        // Initialize when page loads
        document.addEventListener('DOMContentLoaded', function () {
            // Set default dates (last 30 days)
            var startDateInput = document.getElementById('<%= txtStartDate.ClientID %>');
            var endDateInput = document.getElementById('<%= txtEndDate.ClientID %>');

            if (startDateInput && endDateInput) {
                var end = new Date();
                var start = new Date();
                start.setDate(start.getDate() - 30);

                startDateInput.value = start.toISOString().split('T')[0];
                endDateInput.value = end.toISOString().split('T')[0];
            }

            // Setup download receipt button
            var downloadBtn = document.getElementById('btnDownloadReceipt');
            if (downloadBtn) {
                downloadBtn.addEventListener('click', function () {
                    alert('Receipt download started!');
                });
            }
        });
    </script>
    
    <!-- Inline Styles -->
    <style>
        .timeline {
            position: relative;
            padding-left: 2rem;
        }
        
        .timeline::before {
            content: '';
            position: absolute;
            left: 1rem;
            top: 0;
            bottom: 0;
            width: 2px;
            background: rgba(255, 255, 255, 0.2);
        }
        
        .timeline-item {
            position: relative;
            margin-bottom: 1.5rem;
            display: flex;
            align-items: flex-start;
        }
        
        .timeline-icon {
            position: absolute;
            left: -2rem;
            width: 2rem;
            height: 2rem;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            background: rgba(255, 255, 255, 0.1);
            border: 2px solid;
        }
        
        .timeline-icon.pending {
            color: #f59e0b;
            border-color: #f59e0b;
        }
        
        .timeline-icon.approved {
            color: #3b82f6;
            border-color: #3b82f6;
        }
        
        .timeline-icon.processing {
            color: #8b5cf6;
            border-color: #8b5cf6;
        }
        
        .timeline-icon.completed {
            color: #10b981;
            border-color: #10b981;
        }
        
        .timeline-content {
            margin-left: 1rem;
        }
        
        .stat-trend {
            display: flex;
            align-items: center;
            gap: 0.25rem;
            font-size: 0.85rem;
            font-weight: 600;
            padding: 0.25rem 0.5rem;
            border-radius: 12px;
            background: rgba(255, 255, 255, 0.2);
        }
        
        .trend-up {
            color: #10b981;
        }
        
        .trend-down {
            color: #ef4444;
        }
        
        .trend-neutral {
            color: rgba(255, 255, 255, 0.8);
        }
    </style>
</asp:Content>