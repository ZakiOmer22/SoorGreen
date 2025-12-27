<%@ Page Title="Redemption History" Language="C#" MasterPageFile="~/Pages/Collectors/Site.Master"
    AutoEventWireup="true" Inherits="SoorGreen.Collectors.RedemptionHistory" Codebehind="RedemptionHistory.aspx.cs" %>

<asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
    <link href='<%= ResolveUrl("~/Content/Pages/Collectors/collectorsroute.css") %>' rel="stylesheet" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        /* Improved Table Styles */
        .modern-table-container {
            background: var(--route-glass-bg);
            backdrop-filter: blur(15px);
            border-radius: 16px;
            border: 1px solid var(--route-glass-border);
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
            overflow: hidden;
        }

        .modern-table-header {
            background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(168, 85, 247, 0.1));
            border-bottom: 2px solid var(--primary-color);
            padding: 1.25rem 1.5rem;
        }

        .modern-table-header-row {
            display: grid;
            grid-template-columns: 100px 120px 150px 1fr 120px 150px 100px 120px;
            gap: 1rem;
            align-items: center;
            font-weight: 600;
            color: var(--text-primary);
            font-size: 0.9rem;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .modern-table-body {
            max-height: 500px;
            overflow-y: auto;
        }

        .modern-table-row {
            display: grid;
            grid-template-columns: 100px 120px 150px 1fr 120px 150px 100px 120px;
            gap: 1rem;
            align-items: center;
            padding: 1.25rem 1.5rem;
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
            transition: all 0.3s ease;
            cursor: pointer;
        }

            .modern-table-row:hover {
                background: rgba(59, 130, 246, 0.05);
                transform: translateY(-2px);
                box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
            }

            .modern-table-row.alt {
                background: rgba(0, 0, 0, 0.02);
            }

        /* Improved Status Badges */
        .status-badge-modern {
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            padding: 0.5rem 1rem;
            border-radius: 50px;
            font-size: 0.85rem;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.3px;
        }

        .status-pending {
            background: linear-gradient(135deg, #fbbf24, #f59e0b);
            color: white;
            box-shadow: 0 2px 8px rgba(245, 158, 11, 0.3);
        }

        .status-approved {
            background: linear-gradient(135deg, #10b981, #059669);
            color: white;
            box-shadow: 0 2px 8px rgba(16, 185, 129, 0.3);
        }

        .status-completed {
            background: linear-gradient(135deg, #3b82f6, #1d4ed8);
            color: white;
            box-shadow: 0 2px 8px rgba(59, 130, 246, 0.3);
        }

        .status-rejected {
            background: linear-gradient(135deg, #ef4444, #dc2626);
            color: white;
            box-shadow: 0 2px 8px rgba(239, 68, 68, 0.3);
        }

        /* Payment Method Badges */
        .payment-badge-modern {
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            padding: 0.5rem 1rem;
            border-radius: 50px;
            font-size: 0.85rem;
            font-weight: 600;
            color: white;
        }

        .bank-transfer-badge {
            background: linear-gradient(135deg, #3b82f6, #1d4ed8);
        }

        .mobile-money-badge {
            background: linear-gradient(135deg, #10b981, #059669);
        }

        .cash-pickup-badge {
            background: linear-gradient(135deg, #f59e0b, #d97706);
        }

        .wallet-badge {
            background: linear-gradient(135deg, #8b5cf6, #7c3aed);
        }

        /* Action Buttons */
        .action-buttons-container {
            display: flex;
            gap: 0.5rem;
        }

        .action-btn-modern {
            padding: 0.5rem;
            border: none;
            border-radius: 8px;
            cursor: pointer;
            transition: all 0.3s ease;
            display: flex;
            align-items: center;
            justify-content: center;
            min-width: 36px;
            height: 36px;
        }

            .action-btn-modern.success {
                background: linear-gradient(135deg, #10b981, #059669);
                color: white;
            }

                .action-btn-modern.success:hover {
                    transform: translateY(-2px);
                    box-shadow: 0 4px 12px rgba(16, 185, 129, 0.4);
                }

            .action-btn-modern.primary {
                background: linear-gradient(135deg, #3b82f6, #1d4ed8);
                color: white;
            }

                .action-btn-modern.primary:hover {
                    transform: translateY(-2px);
                    box-shadow: 0 4px 12px rgba(59, 130, 246, 0.4);
                }

            .action-btn-modern.warning {
                background: linear-gradient(135deg, #f59e0b, #d97706);
                color: white;
            }

                .action-btn-modern.warning:hover {
                    transform: translateY(-2px);
                    box-shadow: 0 4px 12px rgba(245, 158, 11, 0.4);
                }

            .action-btn-modern.info {
                background: linear-gradient(135deg, #0ea5e9, #0284c7);
                color: white;
            }

                .action-btn-modern.info:hover {
                    transform: translateY(-2px);
                    box-shadow: 0 4px 12px rgba(14, 165, 233, 0.4);
                }

        /* Improved Stats Cards */
        .stats-grid-improved {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
            gap: 1.5rem;
            margin-top: 1.5rem;
        }

        .stat-card {
            background: var(--route-glass-bg);
            backdrop-filter: blur(15px);
            border-radius: 16px;
            padding: 1.5rem;
            border: 1px solid var(--route-glass-border);
            transition: all 0.3s ease;
            text-align: center;
        }

            .stat-card:hover {
                transform: translateY(-5px);
                box-shadow: 0 12px 24px rgba(0, 0, 0, 0.15);
                border-color: var(--primary-color);
            }

        .stat-icon-large {
            font-size: 2.5rem;
            margin-bottom: 1rem;
            opacity: 0.9;
        }

        .stat-number-large {
            font-size: 2rem;
            font-weight: 700;
            color: var(--text-primary);
            margin-bottom: 0.5rem;
        }

        /* Toast Notification */
        .toast-notification {
            position: fixed;
            top: 20px;
            right: 20px;
            z-index: 9999;
            padding: 1rem 1.5rem;
            border-radius: 10px;
            box-shadow: 0 8px 24px rgba(0, 0, 0, 0.2);
            animation: slideInRight 0.3s ease;
            display: flex;
            align-items: center;
            gap: 1rem;
            max-width: 400px;
            min-width: 300px;
        }

        .toast-success {
            background: linear-gradient(135deg, #10b981, #059669);
            color: white;
        }

        .toast-error {
            background: linear-gradient(135deg, #ef4444, #dc2626);
            color: white;
        }

        .toast-info {
            background: linear-gradient(135deg, #3b82f6, #1d4ed8);
            color: white;
        }

        .toast-icon {
            font-size: 1.25rem;
        }

        .toast-message {
            flex: 1;
            font-size: 0.95rem;
        }

        .toast-close {
            background: none;
            border: none;
            color: white;
            cursor: pointer;
            opacity: 0.8;
            transition: opacity 0.2s;
            padding: 0.25rem;
        }

            .toast-close:hover {
                opacity: 1;
            }

        @keyframes slideInRight {
            from {
                transform: translateX(100%);
                opacity: 0;
            }

            to {
                transform: translateX(0);
                opacity: 1;
            }
        }

        /* Empty State */
        .empty-state-modern {
            text-align: center;
            padding: 4rem 2rem;
        }

        .empty-state-icon-modern {
            font-size: 4rem;
            color: var(--text-secondary);
            margin-bottom: 1.5rem;
            opacity: 0.5;
        }

        /* Responsive Design */
        @media (max-width: 1400px) {
            .modern-table-header-row,
            .modern-table-row {
                grid-template-columns: 80px 100px 130px 1fr 100px 130px 80px 100px;
                gap: 0.75rem;
                font-size: 0.85rem;
            }
        }

        @media (max-width: 1200px) {
            .modern-table-container {
                overflow-x: auto;
            }

            .modern-table-header-row,
            .modern-table-row {
                min-width: 1000px;
            }
        }

        /* Search and Filter Improvements */
        .search-box {
            position: relative;
        }

            .search-box input {
                padding-right: 3rem;
            }

        .search-icon {
            position: absolute;
            right: 1rem;
            top: 50%;
            transform: translateY(-50%);
            color: var(--text-secondary);
        }

        /* Loading Spinner */
        .loading-spinner {
            display: none;
            text-align: center;
            padding: 2rem;
        }

        .spinner {
            width: 40px;
            height: 40px;
            border: 3px solid rgba(59, 130, 246, 0.1);
            border-top: 3px solid #3b82f6;
            border-radius: 50%;
            animation: spin 1s linear infinite;
            margin: 0 auto 1rem;
        }

        @keyframes spin {
            0% {
                transform: rotate(0deg);
            }

            100% {
                transform: rotate(360deg);
            }
        }

        /* Modal Styles */
        .modal-content-glass {
            background: var(--route-glass-bg);
            backdrop-filter: blur(15px);
            border-radius: 16px;
            border: 1px solid var(--route-glass-border);
        }

        .modal-header-glass {
            background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(168, 85, 247, 0.1));
            border-bottom: 1px solid var(--route-glass-border);
            border-radius: 16px 16px 0 0;
        }

        /* Amount Styling */
        .amount-badge {
            font-weight: 700;
            font-size: 1.1rem;
            color: var(--text-primary);
        }

        .amount-currency {
            color: #10b981;
            font-weight: 600;
        }

        /* Timeline */
        .timeline-container {
            position: relative;
            padding-left: 30px;
            margin: 20px 0;
        }

        .timeline-item {
            position: relative;
            padding-bottom: 20px;
        }

            .timeline-item:last-child {
                padding-bottom: 0;
            }

            .timeline-item::before {
                content: '';
                position: absolute;
                left: -30px;
                top: 0;
                width: 12px;
                height: 12px;
                border-radius: 50%;
                background: var(--primary-color);
                border: 2px solid white;
                box-shadow: 0 0 0 3px var(--primary-color);
            }

            .timeline-item::after {
                content: '';
                position: absolute;
                left: -24px;
                top: 12px;
                width: 2px;
                height: calc(100% - 12px);
                background: var(--primary-color);
            }

            .timeline-item:last-child::after {
                display: none;
            }

        .timeline-date {
            font-size: 0.85rem;
            color: var(--text-secondary);
            margin-bottom: 5px;
        }

        .timeline-content {
            background: rgba(255, 255, 255, 0.05);
            padding: 10px 15px;
            border-radius: 8px;
            border-left: 3px solid var(--primary-color);
        }
    </style>
</asp:Content>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Redemption History - Collectors Portal
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <!-- Hidden field to store selected redemption ID -->
    <asp:HiddenField ID="hdnSelectedRedemptionId" runat="server" />

    <div class="route-container" id="pageContainer">
        <!-- Page Header -->
        <div class="page-header-glass mb-4">
            <div class="d-flex justify-content-between align-items-center">
                <div>
                    <h1 class="page-title-glass mb-2">
                        <i class="fas fa-exchange-alt me-3 text-primary"></i>Redemption History
                    </h1>
                    <p class="page-subtitle-glass mb-0">Track and manage credit redemption requests from citizens</p>
                </div>
                <div class="d-flex gap-2">
                    <asp:LinkButton ID="btnRefresh" runat="server" CssClass="action-btn primary"
                        OnClick="btnRefresh_Click" OnClientClick="showLoading()">
                        <i class="fas fa-sync-alt me-2"></i>Refresh
                    </asp:LinkButton>
                    <asp:LinkButton ID="btnExport" runat="server" CssClass="action-btn secondary"
                        OnClick="btnExport_Click">
                        <i class="fas fa-file-export me-2"></i>Export
                    </asp:LinkButton>
                </div>
            </div>
        </div>

        <!-- Redemption Stats -->
        <div class="stats-grid-improved mb-4">
            <div class="stat-card">
                <div class="stat-icon-large text-warning">
                    <i class="fas fa-clock"></i>
                </div>
                <div class="stat-number-large">
                    <asp:Label ID="lblTotalPending" runat="server" Text="0"></asp:Label>
                </div>
                <div class="stat-label">Pending Requests</div>
                <small class="text-muted">Awaiting processing</small>
            </div>

            <div class="stat-card">
                <div class="stat-icon-large text-success">
                    <i class="fas fa-check-circle"></i>
                </div>
                <div class="stat-number-large">
                    <asp:Label ID="lblTotalApproved" runat="server" Text="0"></asp:Label>
                </div>
                <div class="stat-label">Approved Today</div>
                <small class="text-muted">Successful redemptions</small>
            </div>

            <div class="stat-card">
                <div class="stat-icon-large text-primary">
                    <i class="fas fa-coins"></i>
                </div>
                <div class="stat-number-large">
                    <asp:Label ID="lblTotalAmount" runat="server" Text="0"></asp:Label>
                </div>
                <div class="stat-label">Total Redeemed</div>
                <small class="text-muted">Credits processed</small>
            </div>

            <div class="stat-card">
                <div class="stat-icon-large text-info">
                    <i class="fas fa-calendar-week"></i>
                </div>
                <div class="stat-number-large">
                    <asp:Label ID="lblWeeklyRedemptions" runat="server" Text="0"></asp:Label>
                </div>
                <div class="stat-label">This Week</div>
                <small class="text-muted">Weekly redemption count</small>
            </div>
        </div>

        <!-- Filters Section -->
        <div class="route-controls-glass mb-4">
            <div class="d-flex justify-content-between align-items-center mb-3">
                <h4 class="mb-0"><i class="fas fa-filter me-2"></i>Filter & Search</h4>
                <asp:LinkButton ID="btnClearFilters" runat="server" CssClass="action-btn danger small"
                    OnClick="btnClearFilters_Click">
                    <i class="fas fa-times me-1"></i>Clear All
                </asp:LinkButton>
            </div>

            <div class="row g-3">
                <div class="col-md-3">
                    <div class="control-group">
                        <label class="control-label mb-2">
                            <i class="fas fa-tags me-1"></i>Status
                        </label>
                        <asp:DropDownList ID="ddlStatusFilter" runat="server" CssClass="form-control-glass"
                            AutoPostBack="true" OnSelectedIndexChanged="ddlStatusFilter_SelectedIndexChanged">
                            <asp:ListItem Value="all">All Status</asp:ListItem>
                            <asp:ListItem Value="Pending">Pending</asp:ListItem>
                            <asp:ListItem Value="Approved">Approved</asp:ListItem>
                            <asp:ListItem Value="Completed">Completed</asp:ListItem>
                            <asp:ListItem Value="Rejected">Rejected</asp:ListItem>
                        </asp:DropDownList>
                    </div>
                </div>

                <div class="col-md-3">
                    <div class="control-group">
                        <label class="control-label mb-2">
                            <i class="fas fa-money-bill-wave me-1"></i>Payment Method
                        </label>
                        <asp:DropDownList ID="ddlMethodFilter" runat="server" CssClass="form-control-glass"
                            AutoPostBack="true" OnSelectedIndexChanged="ddlMethodFilter_SelectedIndexChanged">
                            <asp:ListItem Value="all">All Methods</asp:ListItem>
                            <asp:ListItem Value="Bank Transfer">Bank Transfer</asp:ListItem>
                            <asp:ListItem Value="Mobile Money">Mobile Money</asp:ListItem>
                            <asp:ListItem Value="Cash Pickup">Cash Pickup</asp:ListItem>
                            <asp:ListItem Value="Wallet">Wallet Transfer</asp:ListItem>
                        </asp:DropDownList>
                    </div>
                </div>

                <div class="col-md-3">
                    <div class="control-group">
                        <label class="control-label mb-2">
                            <i class="fas fa-calendar me-1"></i>Date Range
                        </label>
                        <asp:DropDownList ID="ddlDateRange" runat="server" CssClass="form-control-glass"
                            AutoPostBack="true" OnSelectedIndexChanged="ddlDateRange_SelectedIndexChanged">
                            <asp:ListItem Value="today">Today</asp:ListItem>
                            <asp:ListItem Value="week" Selected="True">This Week</asp:ListItem>
                            <asp:ListItem Value="month">This Month</asp:ListItem>
                            <asp:ListItem Value="quarter">This Quarter</asp:ListItem>
                            <asp:ListItem Value="year">This Year</asp:ListItem>
                            <asp:ListItem Value="all">All Time</asp:ListItem>
                        </asp:DropDownList>
                    </div>
                </div>

                <div class="col-md-2">
                    <div class="control-group">
                        <label class="control-label mb-2">
                            <i class="fas fa-sort me-1"></i>Sort By
                        </label>
                        <asp:DropDownList ID="ddlSortBy" runat="server" CssClass="form-control-glass"
                            AutoPostBack="true" OnSelectedIndexChanged="ddlSortBy_SelectedIndexChanged">
                            <asp:ListItem Value="recent">Most Recent</asp:ListItem>
                            <asp:ListItem Value="amount">Highest Amount</asp:ListItem>
                            <asp:ListItem Value="oldest">Oldest First</asp:ListItem>
                        </asp:DropDownList>
                    </div>
                </div>

                <div class="col-md-1">
                    <div class="control-group">
                        <label class="control-label mb-2">&nbsp;</label>
                        <asp:Button ID="btnSearch" runat="server" CssClass="action-btn success w-100"
                            Text="Apply" OnClick="btnSearch_Click" />
                    </div>
                </div>

                <div class="col-12">
                    <div class="search-box">
                        <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control-glass"
                            placeholder="Search by citizen name, phone, or redemption ID..."></asp:TextBox>
                        <span class="search-icon">
                            <i class="fas fa-search"></i>
                        </span>
                    </div>
                </div>
            </div>
        </div>

        <!-- Redemption History List -->
        <div class="modern-table-container mb-4">
            <div class="modern-table-header">
                <div class="modern-table-header-row">
                    <div class="table-col">Redemption ID</div>
                    <div class="table-col">Request Date</div>
                    <div class="table-col">Citizen</div>
                    <div class="table-col">Payment Details</div>
                    <div class="table-col">Amount</div>
                    <div class="table-col">Status</div>
                    <div class="table-col">Processed Date</div>
                    <div class="table-col">Actions</div>
                </div>
            </div>

            <div class="modern-table-body">
                <!-- Loading Spinner -->
                <div id="loadingSpinner" class="loading-spinner" style="display: none;">
                    <div class="spinner"></div>
                    <p class="text-muted">Loading redemption history...</p>
                </div>

                <asp:Repeater ID="rptRedemptionHistory" runat="server"
                    OnItemDataBound="rptRedemptionHistory_ItemDataBound"
                    OnItemCommand="rptRedemptionHistory_ItemCommand">
                    <ItemTemplate>
                        <div class='modern-table-row'>
                            <div class="table-col">
                                <span class="redemption-id fw-bold">
                                    <i class="fas fa-hashtag me-1 text-muted"></i>
                                    <asp:Label ID="lblRedemptionId" runat="server" Text='<%# Eval("RedemptionId") %>'></asp:Label>
                                </span>
                            </div>

                            <div class="table-col">
                                <span class="text-muted small">
                                    <asp:Label ID="lblRequestedAt" runat="server"
                                        Text='<%# BindDate(Eval("RequestedAt")) %>'></asp:Label>
                                </span>
                            </div>

                            <div class="table-col">
                                <div class="citizen-info">
                                    <div class="citizen-name fw-semibold">
                                        <i class="fas fa-user me-1 text-info"></i>
                                        <asp:Label ID="lblCitizenName" runat="server" Text='<%# Eval("CitizenName") %>'></asp:Label>
                                    </div>
                                    <div class="citizen-phone small text-muted">
                                        <asp:Label ID="lblCitizenPhone" runat="server" Text='<%# Eval("CitizenPhone") %>'></asp:Label>
                                    </div>
                                </div>
                            </div>

                            <div class="table-col">
                                <span class='<%# GetPaymentMethodBadgeClass(Eval("Method").ToString()) %>'>
                                    <i class='<%# BindPaymentMethodIcon(Eval("Method").ToString()) %>'></i>
                                    <asp:Label ID="lblPaymentMethod" runat="server" Text='<%# Eval("Method") %>'></asp:Label>
                                </span>
                                <div class="payment-details small text-muted mt-1">
                                    <asp:Label ID="lblPaymentDetails" runat="server" Text='<%# GetPaymentDetails(Eval("PaymentDetails")) %>'></asp:Label>
                                </div>
                            </div>

                            <div class="table-col">
                                <span class="amount-badge">
                                    <i class="fas fa-coins me-1 text-warning"></i>
                                    <span class="amount-currency">$</span>
                                    <asp:Label ID="lblAmount" runat="server" 
                                        Text='<%# Eval("Amount", "{0:F2}") %>'></asp:Label>
                                </span>
                                <div class="text-muted small">
                                    <asp:Label ID="lblCredits" runat="server" 
                                        Text='<%# GetCreditAmount(Eval("Amount")) %>'></asp:Label> credits
                                </div>
                            </div>

                            <div class="table-col">
                                <span class='<%# GetStatusBadgeClass(Eval("Status").ToString()) %>'>
                                    <i class='<%# BindStatusIcon(Eval("Status").ToString()) %>'></i>
                                    <asp:Label ID="lblStatus" runat="server" Text='<%# Eval("Status") %>'></asp:Label>
                                </span>
                            </div>

                            <div class="table-col">
                                <span class="text-muted small">
                                    <asp:Label ID="lblProcessedAt" runat="server"
                                        Text='<%# BindDate(Eval("ProcessedAt")) %>'></asp:Label>
                                </span>
                            </div>

                            <div class="table-col">
                                <div class="action-buttons-container">
                                    <asp:LinkButton ID="btnViewDetails" runat="server"
                                        CommandName="ViewDetails"
                                        CommandArgument='<%# Eval("RedemptionId") %>'
                                        CssClass="action-btn-modern info"
                                        ToolTip="View Details">
                                        <i class="fas fa-eye"></i>
                                    </asp:LinkButton>

                                    <asp:LinkButton ID="btnApprove" runat="server"
                                        CommandName="Approve"
                                        CommandArgument='<%# Eval("RedemptionId") %>'
                                        CssClass="action-btn-modern success"
                                        ToolTip="Approve"
                                        Visible='<%# IsApprovable(Eval("Status").ToString()) %>'>
                                        <i class="fas fa-check"></i>
                                    </asp:LinkButton>

                                    <asp:LinkButton ID="btnReject" runat="server"
                                        CommandName="Reject"
                                        CommandArgument='<%# Eval("RedemptionId") %>'
                                        CssClass="action-btn-modern warning"
                                        ToolTip="Reject"
                                        Visible='<%# IsRejectable(Eval("Status").ToString()) %>'>
                                        <i class="fas fa-times"></i>
                                    </asp:LinkButton>

                                    <asp:LinkButton ID="btnMarkComplete" runat="server"
                                        CommandName="MarkComplete"
                                        CommandArgument='<%# Eval("RedemptionId") %>'
                                        CssClass="action-btn-modern primary"
                                        ToolTip="Mark as Completed"
                                        Visible='<%# IsCompletable(Eval("Status").ToString()) %>'>
                                        <i class="fas fa-check-double"></i>
                                    </asp:LinkButton>
                                </div>
                            </div>
                        </div>
                    </ItemTemplate>
                    <AlternatingItemTemplate>
                        <div class='modern-table-row alt'>
                            <div class="table-col">
                                <span class="redemption-id fw-bold">
                                    <i class="fas fa-hashtag me-1 text-muted"></i>
                                    <asp:Label ID="lblRedemptionId" runat="server" Text='<%# Eval("RedemptionId") %>'></asp:Label>
                                </span>
                            </div>

                            <div class="table-col">
                                <span class="text-muted small">
                                    <asp:Label ID="lblRequestedAt" runat="server"
                                        Text='<%# BindDate(Eval("RequestedAt")) %>'></asp:Label>
                                </span>
                            </div>

                            <div class="table-col">
                                <div class="citizen-info">
                                    <div class="citizen-name fw-semibold">
                                        <i class="fas fa-user me-1 text-info"></i>
                                        <asp:Label ID="lblCitizenName" runat="server" Text='<%# Eval("CitizenName") %>'></asp:Label>
                                    </div>
                                    <div class="citizen-phone small text-muted">
                                        <asp:Label ID="lblCitizenPhone" runat="server" Text='<%# Eval("CitizenPhone") %>'></asp:Label>
                                    </div>
                                </div>
                            </div>

                            <div class="table-col">
                                <span class='<%# GetPaymentMethodBadgeClass(Eval("Method").ToString()) %>'>
                                    <i class='<%# BindPaymentMethodIcon(Eval("Method").ToString()) %>'></i>
                                    <asp:Label ID="lblPaymentMethod" runat="server" Text='<%# Eval("Method") %>'></asp:Label>
                                </span>
                                <div class="payment-details small text-muted mt-1">
                                    <asp:Label ID="lblPaymentDetails" runat="server" Text='<%# GetPaymentDetails(Eval("PaymentDetails")) %>'></asp:Label>
                                </div>
                            </div>

                            <div class="table-col">
                                <span class="amount-badge">
                                    <i class="fas fa-coins me-1 text-warning"></i>
                                    <span class="amount-currency">$</span>
                                    <asp:Label ID="lblAmount" runat="server" 
                                        Text='<%# Eval("Amount", "{0:F2}") %>'></asp:Label>
                                </span>
                                <div class="text-muted small">
                                    <asp:Label ID="lblCredits" runat="server" 
                                        Text='<%# GetCreditAmount(Eval("Amount")) %>'></asp:Label> credits
                                </div>
                            </div>

                            <div class="table-col">
                                <span class='<%# GetStatusBadgeClass(Eval("Status").ToString()) %>'>
                                    <i class='<%# BindStatusIcon(Eval("Status").ToString()) %>'></i>
                                    <asp:Label ID="lblStatus" runat="server" Text='<%# Eval("Status") %>'></asp:Label>
                                </span>
                            </div>

                            <div class="table-col">
                                <span class="text-muted small">
                                    <asp:Label ID="lblProcessedAt" runat="server"
                                        Text='<%# BindDate(Eval("ProcessedAt")) %>'></asp:Label>
                                </span>
                            </div>

                            <div class="table-col">
                                <div class="action-buttons-container">
                                    <asp:LinkButton ID="btnViewDetails" runat="server"
                                        CommandName="ViewDetails"
                                        CommandArgument='<%# Eval("RedemptionId") %>'
                                        CssClass="action-btn-modern info"
                                        ToolTip="View Details">
                                        <i class="fas fa-eye"></i>
                                    </asp:LinkButton>

                                    <asp:LinkButton ID="btnApprove" runat="server"
                                        CommandName="Approve"
                                        CommandArgument='<%# Eval("RedemptionId") %>'
                                        CssClass="action-btn-modern success"
                                        ToolTip="Approve"
                                        Visible='<%# IsApprovable(Eval("Status").ToString()) %>'>
                                        <i class="fas fa-check"></i>
                                    </asp:LinkButton>

                                    <asp:LinkButton ID="btnReject" runat="server"
                                        CommandName="Reject"
                                        CommandArgument='<%# Eval("RedemptionId") %>'
                                        CssClass="action-btn-modern warning"
                                        ToolTip="Reject"
                                        Visible='<%# IsRejectable(Eval("Status").ToString()) %>'>
                                        <i class="fas fa-times"></i>
                                    </asp:LinkButton>

                                    <asp:LinkButton ID="btnMarkComplete" runat="server"
                                        CommandName="MarkComplete"
                                        CommandArgument='<%# Eval("RedemptionId") %>'
                                        CssClass="action-btn-modern primary"
                                        ToolTip="Mark as Completed"
                                        Visible='<%# IsCompletable(Eval("Status").ToString()) %>'>
                                        <i class="fas fa-check-double"></i>
                                    </asp:LinkButton>
                                </div>
                            </div>
                        </div>
                    </AlternatingItemTemplate>
                </asp:Repeater>

                <!-- Empty State -->
                <asp:Panel ID="pnlNoRedemptions" runat="server" CssClass="empty-state-modern" Visible="false">
                    <div class="empty-state-icon-modern">
                        <i class="fas fa-exchange-alt"></i>
                    </div>
                    <h4 class="empty-state-title mb-3">No Redemption History Found</h4>
                    <p class="empty-state-message text-muted mb-4">
                        There are currently no redemption requests matching your criteria.
                    </p>
                    <asp:Button ID="btnResetFilters" runat="server" CssClass="action-btn primary"
                        Text="Reset Filters" OnClick="btnResetFilters_Click" />
                </asp:Panel>
            </div>
        </div>

        <!-- Quick Actions Panel -->
        <div class="route-summary-section">
            <div class="summary-card-glass">
                <h4 class="mb-4"><i class="fas fa-bolt me-2"></i>Quick Actions</h4>

                <div class="row g-3">
                    <div class="col-md-3">
                        <asp:LinkButton ID="btnProcessPending" runat="server" CssClass="action-btn success w-100 py-3"
                            OnClick="btnProcessPending_Click">
                            <i class="fas fa-cogs me-2 fa-lg"></i>
                            <div class="d-block">Process Pending</div>
                            <small class="opacity-75">Review all pending requests</small>
                        </asp:LinkButton>
                    </div>
                    <div class="col-md-3">
                        <asp:LinkButton ID="btnViewPendingOnly" runat="server" CssClass="action-btn warning w-100 py-3"
                            OnClick="btnViewPendingOnly_Click">
                            <i class="fas fa-clock me-2 fa-lg"></i>
                            <div class="d-block">View Pending Only</div>
                            <small class="opacity-75">Show only pending requests</small>
                        </asp:LinkButton>
                    </div>
                    <div class="col-md-3">
                        <asp:LinkButton ID="btnGenerateReport" runat="server" CssClass="action-btn primary w-100 py-3"
                            OnClick="btnGenerateReport_Click">
                            <i class="fas fa-chart-bar me-2 fa-lg"></i>
                            <div class="d-block">Generate Report</div>
                            <small class="opacity-75">Create redemption report</small>
                        </asp:LinkButton>
                    </div>
                    <div class="col-md-3">
                        <asp:LinkButton ID="btnViewStatistics" runat="server" CssClass="action-btn info w-100 py-3"
                            OnClick="btnViewStatistics_Click">
                            <i class="fas fa-chart-pie me-2 fa-lg"></i>
                            <div class="d-block">View Statistics</div>
                            <small class="opacity-75">See redemption analytics</small>
                        </asp:LinkButton>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- View Details Modal -->
    <div class="modal fade" id="detailsModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-lg modal-dialog-centered">
            <div class="modal-content modal-content-glass">
                <div class="modal-header modal-header-glass">
                    <h5 class="modal-title">
                        <i class="fas fa-file-invoice me-2"></i>
                        Redemption Request Details
                    </h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body modal-body-glass">
                    <asp:Panel ID="pnlDetailsContent" runat="server">
                        <!-- Details will be populated dynamically -->
                    </asp:Panel>
                </div>
                <div class="modal-footer modal-footer-glass">
                    <button type="button" class="action-btn secondary" data-bs-dismiss="modal">Close</button>
                </div>
            </div>
        </div>
    </div>

    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

    <!-- Toast Notification System -->
    <script>
        // Toast notification function
        function showToast(message, type) {
            // Remove existing toasts
            const existingToasts = document.querySelectorAll('.toast-notification');
            existingToasts.forEach(toast => {
                toast.style.animation = 'slideInRight 0.3s ease reverse';
                setTimeout(() => toast.remove(), 300);
            });

            // Create new toast
            const toast = document.createElement('div');
            toast.className = `toast-notification toast-${type}`;
            toast.innerHTML = `
                <div class="toast-icon">
                    <i class="${getToastIcon(type)}"></i>
                </div>
                <div class="toast-message">${message}</div>
                <button class="toast-close" onclick="this.parentElement.remove()">
                    <i class="fas fa-times"></i>
                </button>
            `;

            // Add to body
            document.body.appendChild(toast);

            // Auto remove after 5 seconds
            setTimeout(() => {
                if (toast.parentElement) {
                    toast.style.animation = 'slideInRight 0.3s ease reverse';
                    setTimeout(() => toast.remove(), 300);
                }
            }, 5000);
        }

        function getToastIcon(type) {
            switch (type) {
                case 'success': return 'fas fa-check-circle';
                case 'error': return 'fas fa-exclamation-circle';
                case 'warning': return 'fas fa-exclamation-triangle';
                case 'info': return 'fas fa-info-circle';
                default: return 'fas fa-bell';
            }
        }

        // Loading spinner functions
        function showLoading() {
            const spinner = document.getElementById('loadingSpinner');
            if (spinner) spinner.style.display = 'block';
        }

        function hideLoading() {
            const spinner = document.getElementById('loadingSpinner');
            if (spinner) spinner.style.display = 'none';
        }

        // Show details modal
        function showDetailsModal(detailsHtml) {
            const modalBody = document.querySelector('#detailsModal .modal-body');
            if (modalBody) {
                modalBody.innerHTML = detailsHtml;
                const modal = new bootstrap.Modal(document.getElementById('detailsModal'));
                modal.show();
            }
        }

        // Confirmations for actions
        function confirmApprove(redemptionId) {
            return confirm(`Approve redemption request ${redemptionId}?\n\nThis will approve the request and deduct credits from the user's account.`);
        }

        function confirmReject(redemptionId) {
            return confirm(`Reject redemption request ${redemptionId}?\n\nThis will reject the request and keep the user's credits intact.`);
        }

        function confirmComplete(redemptionId) {
            return confirm(`Mark redemption ${redemptionId} as completed?\n\nThis indicates the payment has been successfully processed.`);
        }

        // Row hover effects
        document.addEventListener('DOMContentLoaded', function () {
            const rows = document.querySelectorAll('.modern-table-row');
            rows.forEach(row => {
                row.addEventListener('mouseenter', function () {
                    this.style.transform = 'translateY(-2px)';
                    this.style.boxShadow = '0 4px 12px rgba(0, 0, 0, 0.1)';
                });

                row.addEventListener('mouseleave', function () {
                    this.style.transform = '';
                    this.style.boxShadow = '';
                });
            });

            // Hide loading spinner after page load
            setTimeout(hideLoading, 500);
        });
    </script>
</asp:Content>