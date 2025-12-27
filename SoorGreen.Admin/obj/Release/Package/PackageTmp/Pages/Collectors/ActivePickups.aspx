<%@ Page Title="Active Pickups" Language="C#" MasterPageFile="~/Pages/Collectors/Site.Master"
    AutoEventWireup="true" Inherits="SoorGreen.Collectors.ActivePickups" Codebehind="ActivePickups.aspx.cs" %>

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
            background: linear-gradient(135deg, rgba(16, 185, 129, 0.1), rgba(59, 130, 246, 0.1));
            border-bottom: 2px solid var(--primary-color);
            padding: 1.25rem 1.5rem;
        }

        .modern-table-header-row {
            display: grid;
            grid-template-columns: 100px 120px 1fr 180px 120px 120px 120px 120px;
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
            grid-template-columns: 100px 120px 1fr 180px 120px 120px 120px 120px;
            gap: 1rem;
            align-items: center;
            padding: 1.25rem 1.5rem;
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
            transition: all 0.3s ease;
            cursor: pointer;
        }

            .modern-table-row:hover {
                background: rgba(16, 185, 129, 0.05);
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

        .status-assigned {
            background: linear-gradient(135deg, #3b82f6, #1d4ed8);
            color: white;
            box-shadow: 0 2px 8px rgba(59, 130, 246, 0.3);
        }

        .status-completed {
            background: linear-gradient(135deg, #10b981, #059669);
            color: white;
            box-shadow: 0 2px 8px rgba(16, 185, 129, 0.3);
        }

        /* Improved Waste Type Badges */
        .waste-type-badge-modern {
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            padding: 0.5rem 1rem;
            border-radius: 50px;
            font-size: 0.85rem;
            font-weight: 600;
            color: white;
        }

        .plastic-badge {
            background: linear-gradient(135deg, #3b82f6, #1d4ed8);
        }

        .paper-badge {
            background: linear-gradient(135deg, #f59e0b, #d97706);
        }

        .glass-badge {
            background: linear-gradient(135deg, #10b981, #059669);
        }

        .metal-badge {
            background: linear-gradient(135deg, #6b7280, #4b5563);
        }

        .organic-badge {
            background: linear-gradient(135deg, #8b5cf6, #7c3aed);
        }

        .electronic-badge {
            background: linear-gradient(135deg, #ef4444, #dc2626);
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
                grid-template-columns: 80px 100px 1fr 150px 100px 100px 100px 100px;
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
            border: 3px solid rgba(16, 185, 129, 0.1);
            border-top: 3px solid #10b981;
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
    </style>
</asp:Content>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Active Pickups - Collectors Portal
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <!-- Hidden field to store selected pickup ID -->
    <asp:HiddenField ID="hdnSelectedPickupId" runat="server" />

    <div class="route-container" id="pageContainer">
        <!-- Page Header -->
        <div class="page-header-glass mb-4">
            <div class="d-flex justify-content-between align-items-center">
                <div>
                    <h1 class="page-title-glass mb-2">
                        <i class="fas fa-trash-restore me-3 text-success"></i>Active Pickup Management
                    </h1>
                    <p class="page-subtitle-glass mb-0">Manage and assign pending waste collection requests</p>
                </div>
                <div class="d-flex gap-2">
                    <asp:LinkButton ID="btnRefreshPickups" runat="server" CssClass="action-btn primary"
                        OnClick="btnRefreshPickups_Click" OnClientClick="showLoading()">
                        <i class="fas fa-sync-alt me-2"></i>Refresh
                    </asp:LinkButton>
                    <asp:LinkButton ID="btnExportPickups" runat="server" CssClass="action-btn secondary"
                        OnClick="btnExportPickups_Click">
                        <i class="fas fa-file-export me-2"></i>Export
                    </asp:LinkButton>
                </div>
            </div>
        </div>

        <!-- Active Pickups Stats -->
        <div class="stats-grid-improved mb-4">
            <div class="stat-card">
                <div class="stat-icon-large text-warning">
                    <i class="fas fa-clock"></i>
                </div>
                <div class="stat-number-large">
                    <asp:Label ID="lblTotalPending" runat="server" Text="0"></asp:Label>
                </div>
                <div class="stat-label">Pending Requests</div>
                <small class="text-muted">Awaiting assignment</small>
            </div>

            <div class="stat-card">
                <div class="stat-icon-large text-info">
                    <i class="fas fa-user-check"></i>
                </div>
                <div class="stat-number-large">
                    <asp:Label ID="lblAssignedPickups" runat="server" Text="0"></asp:Label>
                </div>
                <div class="stat-label">Assigned to Me</div>
                <small class="text-muted">Your active pickups</small>
            </div>

            <div class="stat-card">
                <div class="stat-icon-large text-primary">
                    <i class="fas fa-weight-hanging"></i>
                </div>
                <div class="stat-number-large">
                    <asp:Label ID="lblTotalWeight" runat="server" Text="0"></asp:Label>
                    kg
                </div>
                <div class="stat-label">Total Waste</div>
                <small class="text-muted">Estimated weight</small>
            </div>

            <div class="stat-card">
                <div class="stat-icon-large text-success">
                    <i class="fas fa-calendar-day"></i>
                </div>
                <div class="stat-number-large">
                    <asp:Label ID="lblTodayPickups" runat="server" Text="0"></asp:Label>
                </div>
                <div class="stat-label">Today's Requests</div>
                <small class="text-muted">
                    <asp:Label ID="lblStatsDate" runat="server"></asp:Label></small>
            </div>
        </div>

        <!-- Filters Section -->
        <div class="route-controls-glass mb-4">
            <div class="d-flex justify-content-between align-items-center mb-3">
                <h4 class="mb-0"><i class="fas fa-search me-2"></i>Filter & Search</h4>
                <asp:LinkButton ID="btnClearFilters" runat="server" CssClass="action-btn danger small"
                    OnClick="btnClearFilters_Click">
                    <i class="fas fa-times me-1"></i>Clear All
                </asp:LinkButton>
            </div>

            <div class="row g-3">
                <div class="col-md-3">
                    <div class="control-group">
                        <label class="control-label mb-2">
                            <i class="fas fa-trash me-1"></i>Waste Type
                        </label>
                        <asp:DropDownList ID="ddlWasteTypeFilter" runat="server" CssClass="form-control-glass"
                            AutoPostBack="true" OnSelectedIndexChanged="ddlWasteTypeFilter_SelectedIndexChanged">
                            <asp:ListItem Value="all">All Waste Types</asp:ListItem>
                            <asp:ListItem Value="Plastic">Plastic</asp:ListItem>
                            <asp:ListItem Value="Paper">Paper</asp:ListItem>
                            <asp:ListItem Value="Glass">Glass</asp:ListItem>
                            <asp:ListItem Value="Metal">Metal</asp:ListItem>
                            <asp:ListItem Value="Organic">Organic</asp:ListItem>
                            <asp:ListItem Value="Electronic">Electronic</asp:ListItem>
                        </asp:DropDownList>
                    </div>
                </div>

                <div class="col-md-3">
                    <div class="control-group">
                        <label class="control-label mb-2">
                            <i class="fas fa-tags me-1"></i>Status
                        </label>
                        <asp:DropDownList ID="ddlStatusFilter" runat="server" CssClass="form-control-glass"
                            AutoPostBack="true" OnSelectedIndexChanged="ddlStatusFilter_SelectedIndexChanged">
                            <asp:ListItem Value="all">All Status</asp:ListItem>
                            <asp:ListItem Value="Requested">Requested</asp:ListItem>
                            <asp:ListItem Value="Assigned">Assigned</asp:ListItem>
                        </asp:DropDownList>
                    </div>
                </div>

                <div class="col-md-4">
                    <div class="control-group">
                        <label class="control-label mb-2">
                            <i class="fas fa-sort me-1"></i>Sort By
                        </label>
                        <asp:DropDownList ID="ddlSortPickups" runat="server" CssClass="form-control-glass"
                            AutoPostBack="true" OnSelectedIndexChanged="ddlSortPickups_SelectedIndexChanged">
                            <asp:ListItem Value="recent">Most Recent</asp:ListItem>
                            <asp:ListItem Value="weight">Highest Weight</asp:ListItem>
                            <asp:ListItem Value="priority">Priority</asp:ListItem>
                        </asp:DropDownList>
                    </div>
                </div>

                <div class="col-md-2">
                    <div class="control-group">
                        <label class="control-label mb-2">&nbsp;</label>
                        <asp:Button ID="btnSearch" runat="server" CssClass="action-btn success w-100"
                            Text="Apply Filters" OnClick="btnSearch_Click" />
                    </div>
                </div>

                <div class="col-12">
                    <div class="search-box">
                        <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control-glass"
                            placeholder="Search by address, citizen, or pickup ID..."></asp:TextBox>
                        <span class="search-icon">
                            <i class="fas fa-search"></i>
                        </span>
                    </div>
                </div>
            </div>
        </div>

        <!-- Active Pickups List -->
        <div class="modern-table-container mb-4">
            <div class="modern-table-header">
                <div class="modern-table-header-row">
                    <div class="table-col">Pickup ID</div>
                    <div class="table-col">Request Date</div>
                    <div class="table-col">Location</div>
                    <div class="table-col">Citizen</div>
                    <div class="table-col">Waste Type</div>
                    <div class="table-col">Weight</div>
                    <div class="table-col">Status</div>
                    <div class="table-col">Actions</div>
                </div>
            </div>

            <div class="modern-table-body">
                <!-- Loading Spinner -->
                <div id="loadingSpinner" class="loading-spinner" style="display: none;">
                    <div class="spinner"></div>
                    <p class="text-muted">Loading pickups...</p>
                </div>

                <asp:Repeater ID="rptActivePickups" runat="server"
                    OnItemDataBound="rptActivePickups_ItemDataBound"
                    OnItemCommand="rptActivePickups_ItemCommand">
                    <ItemTemplate>
                        <div class='modern-table-row'>
                            <div class="table-col">
                                <span class="pickup-id fw-bold">
                                    <i class="fas fa-hashtag me-1 text-muted"></i>
                                    <asp:Label ID="lblPickupId" runat="server" Text='<%# Eval("PickupId") %>'></asp:Label>
                                </span>
                            </div>

                            <div class="table-col">
                                <span class="text-muted small">
                                    <asp:Label ID="lblCreatedAt" runat="server"
                                        Text='<%# BindDate(Eval("CreatedAt")) %>'></asp:Label>
                                </span>
                            </div>

                            <div class="table-col">
                                <div class="address-info">
                                    <div class="address-title fw-semibold">
                                        <i class="fas fa-map-marker-alt me-1 text-danger"></i>
                                        <asp:Label ID="lblAddress" runat="server" Text='<%# Eval("Address") %>'></asp:Label>
                                    </div>
                                    <div class="address-subtitle small text-muted">
                                        <asp:Label ID="lblLandmark" runat="server" Text='<%# Eval("Landmark") %>'></asp:Label>
                                    </div>
                                </div>
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
                                <span class='<%# GetWasteTypeBadgeClass(Eval("WasteType").ToString()) %>'>
                                    <i class='<%# BindWasteTypeIcon(Eval("WasteType").ToString()) %>'></i>
                                    <asp:Label ID="lblWasteType" runat="server" Text='<%# Eval("WasteType") %>'></asp:Label>
                                </span>
                            </div>

                            <div class="table-col">
                                <span class="weight-value fw-bold">
                                    <i class="fas fa-weight me-1 text-primary"></i>
                                    <asp:Label ID="lblEstimatedKg" runat="server" Text='<%# Eval("EstimatedKg", "{0:F1}") %>'></asp:Label>
                                    <span class="text-muted small">kg</span>
                                </span>
                            </div>

                            <div class="table-col">
                                <span class='<%# GetStatusBadgeClass(Eval("Status").ToString()) %>'>
                                    <i class='<%# BindStatusIcon(Eval("Status").ToString()) %>'></i>
                                    <asp:Label ID="lblStatus" runat="server" Text='<%# Eval("Status") %>'></asp:Label>
                                </span>
                            </div>

                            <div class="table-col">
                                <div class="action-buttons-container">
                                    <asp:LinkButton ID="btnAssignToMe" runat="server"
                                        CommandName="AssignToMe"
                                        CommandArgument='<%# Eval("PickupId") %>'
                                        CssClass="action-btn-modern success"
                                        ToolTip="Assign to Me"
                                        Visible='<%# IsAssignable(Eval("Status").ToString()) %>'>
                                        <i class="fas fa-user-check"></i>
                                    </asp:LinkButton>

                                    <asp:LinkButton ID="btnStartPickup" runat="server"
                                        CommandName="StartPickup"
                                        CommandArgument='<%# Eval("PickupId") %>'
                                        CssClass="action-btn-modern primary"
                                        ToolTip="Start Pickup"
                                        Visible='<%# IsStartable(Eval("Status").ToString(), Eval("CollectorId") != DBNull.Value ? Eval("CollectorId").ToString() : "") %>'>
                                        <i class="fas fa-play"></i>
                                    </asp:LinkButton>
                                </div>
                            </div>
                        </div>
                    </ItemTemplate>
                    <AlternatingItemTemplate>
                        <div class='modern-table-row alt'>
                            <div class="table-col">
                                <span class="pickup-id fw-bold">
                                    <i class="fas fa-hashtag me-1 text-muted"></i>
                                    <asp:Label ID="lblPickupId" runat="server" Text='<%# Eval("PickupId") %>'></asp:Label>
                                </span>
                            </div>

                            <div class="table-col">
                                <span class="text-muted small">
                                    <asp:Label ID="lblCreatedAt" runat="server"
                                        Text='<%# BindDate(Eval("CreatedAt")) %>'></asp:Label>
                                </span>
                            </div>

                            <div class="table-col">
                                <div class="address-info">
                                    <div class="address-title fw-semibold">
                                        <i class="fas fa-map-marker-alt me-1 text-danger"></i>
                                        <asp:Label ID="lblAddress" runat="server" Text='<%# Eval("Address") %>'></asp:Label>
                                    </div>
                                    <div class="address-subtitle small text-muted">
                                        <asp:Label ID="lblLandmark" runat="server" Text='<%# Eval("Landmark") %>'></asp:Label>
                                    </div>
                                </div>
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
                                <span class='<%# GetWasteTypeBadgeClass(Eval("WasteType").ToString()) %>'>
                                    <i class='<%# BindWasteTypeIcon(Eval("WasteType").ToString()) %>'></i>
                                    <asp:Label ID="lblWasteType" runat="server" Text='<%# Eval("WasteType") %>'></asp:Label>
                                </span>
                            </div>

                            <div class="table-col">
                                <span class="weight-value fw-bold">
                                    <i class="fas fa-weight me-1 text-primary"></i>
                                    <asp:Label ID="lblEstimatedKg" runat="server" Text='<%# Eval("EstimatedKg", "{0:F1}") %>'></asp:Label>
                                    <span class="text-muted small">kg</span>
                                </span>
                            </div>

                            <div class="table-col">
                                <span class='<%# GetStatusBadgeClass(Eval("Status").ToString()) %>'>
                                    <i class='<%# BindStatusIcon(Eval("Status").ToString()) %>'></i>
                                    <asp:Label ID="lblStatus" runat="server" Text='<%# Eval("Status") %>'></asp:Label>
                                </span>
                            </div>

                            <div class="table-col">
                                <div class="action-buttons-container">
                                    <asp:LinkButton ID="btnAssignToMe" runat="server"
                                        CommandName="AssignToMe"
                                        CommandArgument='<%# Eval("PickupId") %>'
                                        CssClass="action-btn-modern success"
                                        ToolTip="Assign to Me"
                                        Visible='<%# IsAssignable(Eval("Status").ToString()) %>'>
                                        <i class="fas fa-user-check"></i>
                                    </asp:LinkButton>

                                    <asp:LinkButton ID="btnStartPickup" runat="server"
                                        CommandName="StartPickup"
                                        CommandArgument='<%# Eval("PickupId") %>'
                                        CssClass="action-btn-modern primary"
                                        ToolTip="Start Pickup"
                                        Visible='<%# IsStartable(Eval("Status").ToString(), Eval("CollectorId") != DBNull.Value ? Eval("CollectorId").ToString() : "") %>'>
                                        <i class="fas fa-play"></i>
                                    </asp:LinkButton>
                                </div>
                            </div>
                        </div>
                    </AlternatingItemTemplate>
                </asp:Repeater>

                <!-- Empty State -->
                <asp:Panel ID="pnlNoActivePickups" runat="server" CssClass="empty-state-modern" Visible="false">
                    <div class="empty-state-icon-modern">
                        <i class="fas fa-clipboard-list"></i>
                    </div>
                    <h4 class="empty-state-title mb-3">No Active Pickups Found</h4>
                    <p class="empty-state-message text-muted mb-4">
                        There are currently no active pickup requests matching your criteria.
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
                        <asp:LinkButton ID="btnTakeAllPending" runat="server" CssClass="action-btn success w-100 py-3"
                            OnClick="btnTakeAllPending_Click">
                            <i class="fas fa-hand-paper me-2 fa-lg"></i>
                            <div class="d-block">Take All Pending</div>
                            <small class="opacity-75">Assign all available pickups</small>
                        </asp:LinkButton>
                    </div>
                    <div class="col-md-3">
                        <asp:LinkButton ID="btnViewMyPickups" runat="server" CssClass="action-btn primary w-100 py-3"
                            OnClick="btnViewMyPickups_Click">
                            <i class="fas fa-list me-2 fa-lg"></i>
                            <div class="d-block">View My Pickups</div>
                            <small class="opacity-75">Show only my assignments</small>
                        </asp:LinkButton>
                    </div>
                    <div class="col-md-3">
                        <asp:LinkButton ID="btnGenerateRoute" runat="server" CssClass="action-btn secondary w-100 py-3"
                            OnClick="btnGenerateRoute_Click">
                            <i class="fas fa-route me-2 fa-lg"></i>
                            <div class="d-block">Generate Route</div>
                            <small class="opacity-75">Optimize collection path</small>
                        </asp:LinkButton>
                    </div>
                    <div class="col-md-3">
                        <asp:LinkButton ID="btnViewMap" runat="server" CssClass="action-btn info w-100 py-3"
                            OnClick="btnViewMap_Click">
                            <i class="fas fa-map me-2 fa-lg"></i>
                            <div class="d-block">View on Map</div>
                            <small class="opacity-75">See locations visually</small>
                        </asp:LinkButton>
                    </div>
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

        // Confirmations for actions
        function confirmAssign(pickupId) {
            return confirm(`Assign pickup ${pickupId} to you?\n\nThis pickup will be marked as assigned to you.`);
        }

        function confirmStart(pickupId) {
            return confirm(`Start pickup ${pickupId}?\n\nYou will be redirected to the verification page to complete this pickup.`);
        }
    </script>
</asp:Content>
