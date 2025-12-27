<%@ Page Title="My Reports" Language="C#" MasterPageFile="~/Pages/Collectors/Site.Master" 
    AutoEventWireup="true" Inherits="SoorGreen.Collectors.MyReports" Codebehind="MyReports.aspx.cs" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <link href='<%= ResolveUrl("~/Content/Pages/Collectors/CollectorReports.css") %>' rel="stylesheet" />
    <link href='<%= ResolveUrl("~/Content/Pages/Collectors/collectorsroute.css") %>' rel="stylesheet" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        /* Additional Styles for My Reports Page */
        .modern-table-header-row {
            grid-template-columns: 120px 1fr 120px 120px 120px 120px 140px !important;
        }
        
        .modern-table-row {
            grid-template-columns: 120px 1fr 120px 120px 120px 120px 140px !important;
        }
        
        @media (max-width: 1400px) {
            .modern-table-header-row,
            .modern-table-row {
                grid-template-columns: 100px 1fr 100px 100px 100px 100px 130px !important;
            }
        }
        
        @media (max-width: 1200px) {
            .modern-table-header-row,
            .modern-table-row {
                min-width: 900px !important;
            }
        }
        
        /* Additional Status Badges */
        .status-inprogress {
            background: linear-gradient(135deg, #f97316, #ea580c);
            color: white;
            box-shadow: 0 2px 8px rgba(249, 115, 22, 0.3);
        }
        
        .status-collected {
            background: linear-gradient(135deg, #0ea5e9, #0284c7);
            color: white;
            box-shadow: 0 2px 8px rgba(14, 165, 233, 0.3);
        }
        
        .status-cancelled {
            background: linear-gradient(135deg, #6b7280, #4b5563);
            color: white;
            box-shadow: 0 2px 8px rgba(107, 114, 128, 0.3);
        }
        
        .status-verified {
            background: linear-gradient(135deg, #8b5cf6, #7c3aed);
            color: white;
            box-shadow: 0 2px 8px rgba(139, 92, 246, 0.3);
        }
        
        /* Weight indicators */
        .weight-estimated {
            color: var(--text-primary);
            font-weight: 600;
        }
        
        .weight-verified {
            color: var(--success-color);
            font-weight: 600;
        }
        
        /* Report details in table */
        .report-details-table {
            display: flex;
            flex-direction: column;
            gap: 4px;
        }
        
        .report-address {
            font-weight: 600;
            color: var(--text-primary);
        }
        
        .report-citizen {
            font-size: 0.85rem;
            color: var(--text-secondary);
        }
        
        .report-date {
            font-size: 0.8rem;
            color: var(--text-muted);
        }
    </style>
</asp:Content>

<asp:Content ID="TitleContent" ContentPlaceHolderID="TitleContent" runat="server">
    My Collection Reports - SoorGreen Collector
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <!-- Hidden fields -->
    <asp:HiddenField ID="hdnSelectedReportId" runat="server" />
    <asp:HiddenField ID="hdnCurrentPage" runat="server" Value="1" />

    <div class="route-container" id="pageContainer">
        <!-- Page Header -->
        <div class="page-header-glass mb-4">
            <div class="d-flex justify-content-between align-items-center">
                <div>
                    <h1 class="page-title-glass mb-2">
                        <i class="fas fa-file-alt me-3 text-primary"></i>My Collection Reports
                    </h1>
                    <p class="page-subtitle-glass mb-0">Track and manage your waste collection activities and reports</p>
                </div>
                <div class="d-flex gap-2">
                    <asp:LinkButton ID="btnCreateReport" runat="server" CssClass="action-btn primary"
                        OnClick="btnCreateReport_Click">
                        <i class="fas fa-plus-circle me-2"></i>New Report
                    </asp:LinkButton>
                    <asp:LinkButton ID="btnRefresh" runat="server" CssClass="action-btn secondary"
                        OnClick="btnRefresh_Click" OnClientClick="showLoading()">
                        <i class="fas fa-sync-alt me-2"></i>Refresh
                    </asp:LinkButton>
                    <asp:LinkButton ID="btnExportReports" runat="server" CssClass="action-btn secondary"
                        OnClick="btnExportReports_Click">
                        <i class="fas fa-file-export me-2"></i>Export
                    </asp:LinkButton>
                </div>
            </div>
        </div>

        <!-- Reports Stats -->
        <div class="stats-grid-improved mb-4">
            <div class="stat-card">
                <div class="stat-icon-large text-primary">
                    <i class="fas fa-clipboard-list"></i>
                </div>
                <div class="stat-number-large">
                    <asp:Label ID="statTotalReports" runat="server" Text="0"></asp:Label>
                </div>
                <div class="stat-label">Total Reports</div>
                <small class="text-muted">All time collection reports</small>
            </div>

            <div class="stat-card">
                <div class="stat-icon-large text-success">
                    <i class="fas fa-check-circle"></i>
                </div>
                <div class="stat-number-large">
                    <asp:Label ID="statCompletedReports" runat="server" Text="0"></asp:Label>
                </div>
                <div class="stat-label">Completed</div>
                <small class="text-muted">Successfully collected</small>
            </div>

            <div class="stat-card">
                <div class="stat-icon-large text-warning">
                    <i class="fas fa-hourglass-half"></i>
                </div>
                <div class="stat-number-large">
                    <asp:Label ID="statInProgressReports" runat="server" Text="0"></asp:Label>
                </div>
                <div class="stat-label">In Progress</div>
                <small class="text-muted">Currently being processed</small>
            </div>

            <div class="stat-card">
                <div class="stat-icon-large text-info">
                    <i class="fas fa-weight-hanging"></i>
                </div>
                <div class="stat-number-large">
                    <asp:Label ID="statTotalWeight" runat="server" Text="0"></asp:Label> kg
                </div>
                <div class="stat-label">Total Weight</div>
                <small class="text-muted">Total waste collected</small>
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
                            <i class="fas fa-calendar me-1"></i> Start Date
                        </label>
                        <asp:TextBox ID="txtStartDate" runat="server" CssClass="form-control-glass" TextMode="Date"></asp:TextBox>
                    </div>
                </div>

                <div class="col-md-3">
                    <div class="control-group">
                        <label class="control-label mb-2">
                            <i class="fas fa-calendar me-1"></i> End Date
                        </label>
                        <asp:TextBox ID="txtEndDate" runat="server" CssClass="form-control-glass" TextMode="Date"></asp:TextBox>
                    </div>
                </div>

                <div class="col-md-3">
                    <div class="control-group">
                        <label class="control-label mb-2">
                            <i class="fas fa-tags me-1"></i> Status
                        </label>
                        <asp:DropDownList ID="ddlStatus" runat="server" CssClass="form-control-glass"
                            AutoPostBack="true" OnSelectedIndexChanged="ddlStatus_SelectedIndexChanged">
                            <asp:ListItem Text="All Status" Value="all" Selected="True"></asp:ListItem>
                            <asp:ListItem Text="Requested" Value="Requested"></asp:ListItem>
                            <asp:ListItem Text="Assigned" Value="Assigned"></asp:ListItem>
                            <asp:ListItem Text="In Progress" Value="In Progress"></asp:ListItem>
                            <asp:ListItem Text="Collected" Value="Collected"></asp:ListItem>
                            <asp:ListItem Text="Completed" Value="Completed"></asp:ListItem>
                            <asp:ListItem Text="Cancelled" Value="Cancelled"></asp:ListItem>
                        </asp:DropDownList>
                    </div>
                </div>

                <div class="col-md-3">
                    <div class="control-group">
                        <label class="control-label mb-2">
                            <i class="fas fa-trash me-1"></i> Waste Type
                        </label>
                        <asp:DropDownList ID="ddlWasteType" runat="server" CssClass="form-control-glass"
                            AutoPostBack="true" OnSelectedIndexChanged="ddlWasteType_SelectedIndexChanged">
                            <asp:ListItem Text="All Types" Value="all" Selected="True"></asp:ListItem>
                        </asp:DropDownList>
                    </div>
                </div>

                <div class="col-12">
                    <div class="search-box">
                        <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control-glass"
                            placeholder="Search reports by ID, address, or citizen name..." AutoPostBack="true"
                            OnTextChanged="txtSearch_TextChanged"></asp:TextBox>
                        <span class="search-icon">
                            <i class="fas fa-search"></i>
                        </span>
                    </div>
                </div>
            </div>
        </div>

        <!-- Reports List Table -->
        <div class="modern-table-container mb-4">
            <div class="modern-table-header">
                <div class="modern-table-header-row">
                    <div class="table-col">Report ID</div>
                    <div class="table-col">Details</div>
                    <div class="table-col">Waste Type</div>
                    <div class="table-col">Estimated</div>
                    <div class="table-col">Verified</div>
                    <div class="table-col">Status</div>
                    <div class="table-col">Actions</div>
                </div>
            </div>

            <div class="modern-table-body">
                <!-- Loading Spinner -->
                <div id="loadingSpinner" class="loading-spinner" style="display: none;">
                    <div class="spinner"></div>
                    <p class="text-muted">Loading reports...</p>
                </div>

                <asp:Repeater ID="rptReports" runat="server" 
                    OnItemDataBound="rptReports_ItemDataBound"
                    OnItemCommand="rptReports_ItemCommand">
                    <ItemTemplate>
                        <div class='modern-table-row'>
                            <div class="table-col">
                                <span class="pickup-id fw-bold">
                                    <i class="fas fa-hashtag me-1 text-muted"></i>
                                    <asp:Label ID="lblReportId" runat="server" Text='<%# Eval("ReportId") %>'></asp:Label>
                                </span>
                                <div class="report-date mt-1">
                                    <i class="fas fa-calendar-day me-1 text-muted" style="font-size: 0.75rem;"></i>
                                    <span class="text-muted" style="font-size: 0.75rem;">
                                        <asp:Label ID="lblReportDate" runat="server" 
                                            Text='<%# BindDate(Eval("ReportDate")) %>'></asp:Label>
                                    </span>
                                </div>
                            </div>

                            <div class="table-col">
                                <div class="report-details-table">
                                    <div class="report-address">
                                        <i class="fas fa-map-marker-alt me-1 text-danger" style="font-size: 0.8rem;"></i>
                                        <asp:Label ID="lblAddress" runat="server" Text='<%# Eval("Address") %>'></asp:Label>
                                    </div>
                                    <div class="report-citizen">
                                        <i class="fas fa-user me-1 text-info" style="font-size: 0.75rem;"></i>
                                        <asp:Label ID="lblCitizenName" runat="server" Text='<%# Eval("CitizenName") %>'></asp:Label>
                                    </div>
                                    <div class="report-date">
                                        <i class="fas fa-phone me-1 text-muted" style="font-size: 0.7rem;"></i>
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
                                <span class="weight-estimated">
                                    <i class="fas fa-weight me-1 text-primary"></i>
                                    <asp:Label ID="lblEstimatedKg" runat="server" Text='<%# Eval("EstimatedKg", "{0:F1}") %>'></asp:Label>
                                    <span class="text-muted" style="font-size: 0.75rem;">kg</span>
                                </span>
                            </div>

                            <div class="table-col">
                                <span class="weight-verified">
                                    <i class="fas fa-weight me-1 text-success"></i>
                                    <asp:Label ID="lblVerifiedKg" runat="server" Text='<%# Eval("VerifiedKg", "{0:F1}") %>'></asp:Label>
                                    <span class="text-muted" style="font-size: 0.75rem;">kg</span>
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
                                    <asp:LinkButton ID="btnViewDetails" runat="server"
                                        CommandName="ViewDetails"
                                        CommandArgument='<%# Eval("ReportId") %>'
                                        CssClass="action-btn-modern secondary"
                                        ToolTip="View Details"
                                        OnClientClick='<%# "showReportDetailsModal(\"" + Eval("ReportId") + "\"); return false;" %>'>
                                        <i class="fas fa-eye"></i>
                                    </asp:LinkButton>

                                    <asp:LinkButton ID="btnEditReport" runat="server"
                                        CommandName="EditReport"
                                        CommandArgument='<%# Eval("ReportId") %>'
                                        CssClass="action-btn-modern secondary"
                                        ToolTip="Edit Report"
                                        Visible='<%# IsEditable(Eval("Status").ToString()) %>'>
                                        <i class="fas fa-edit"></i>
                                    </asp:LinkButton>

                                    <asp:LinkButton ID="btnCompleteReport" runat="server"
                                        CommandName="CompleteReport"
                                        CommandArgument='<%# Eval("ReportId") %>'
                                        CssClass="action-btn-modern success"
                                        ToolTip="Mark as Completed"
                                        Visible='<%# IsCompletable(Eval("Status").ToString()) %>'
                                        OnClientClick='<%# "return confirmComplete(\"" + Eval("ReportId") + "\");" %>'>
                                        <i class="fas fa-check-circle"></i>
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
                                    <asp:Label ID="Label1" runat="server" Text='<%# Eval("ReportId") %>'></asp:Label>
                                </span>
                                <div class="report-date mt-1">
                                    <i class="fas fa-calendar-day me-1 text-muted" style="font-size: 0.75rem;"></i>
                                    <span class="text-muted" style="font-size: 0.75rem;">
                                        <asp:Label ID="Label2" runat="server" 
                                            Text='<%# BindDate(Eval("ReportDate")) %>'></asp:Label>
                                    </span>
                                </div>
                            </div>

                            <div class="table-col">
                                <div class="report-details-table">
                                    <div class="report-address">
                                        <i class="fas fa-map-marker-alt me-1 text-danger" style="font-size: 0.8rem;"></i>
                                        <asp:Label ID="Label3" runat="server" Text='<%# Eval("Address") %>'></asp:Label>
                                    </div>
                                    <div class="report-citizen">
                                        <i class="fas fa-user me-1 text-info" style="font-size: 0.75rem;"></i>
                                        <asp:Label ID="Label4" runat="server" Text='<%# Eval("CitizenName") %>'></asp:Label>
                                    </div>
                                    <div class="report-date">
                                        <i class="fas fa-phone me-1 text-muted" style="font-size: 0.7rem;"></i>
                                        <asp:Label ID="Label5" runat="server" Text='<%# Eval("CitizenPhone") %>'></asp:Label>
                                    </div>
                                </div>
                            </div>

                            <div class="table-col">
                                <span class='<%# GetWasteTypeBadgeClass(Eval("WasteType").ToString()) %>'>
                                    <i class='<%# BindWasteTypeIcon(Eval("WasteType").ToString()) %>'></i>
                                    <asp:Label ID="Label6" runat="server" Text='<%# Eval("WasteType") %>'></asp:Label>
                                </span>
                            </div>

                            <div class="table-col">
                                <span class="weight-estimated">
                                    <i class="fas fa-weight me-1 text-primary"></i>
                                    <asp:Label ID="Label7" runat="server" Text='<%# Eval("EstimatedKg", "{0:F1}") %>'></asp:Label>
                                    <span class="text-muted" style="font-size: 0.75rem;">kg</span>
                                </span>
                            </div>

                            <div class="table-col">
                                <span class="weight-verified">
                                    <i class="fas fa-weight me-1 text-success"></i>
                                    <asp:Label ID="Label8" runat="server" Text='<%# Eval("VerifiedKg", "{0:F1}") %>'></asp:Label>
                                    <span class="text-muted" style="font-size: 0.75rem;">kg</span>
                                </span>
                            </div>

                            <div class="table-col">
                                <span class='<%# GetStatusBadgeClass(Eval("Status").ToString()) %>'>
                                    <i class='<%# BindStatusIcon(Eval("Status").ToString()) %>'></i>
                                    <asp:Label ID="Label9" runat="server" Text='<%# Eval("Status") %>'></asp:Label>
                                </span>
                            </div>

                            <div class="table-col">
                                <div class="action-buttons-container">
                                    <asp:LinkButton ID="LinkButton1" runat="server"
                                        CommandName="ViewDetails"
                                        CommandArgument='<%# Eval("ReportId") %>'
                                        CssClass="action-btn-modern secondary"
                                        ToolTip="View Details"
                                        OnClientClick='<%# "showReportDetailsModal(\"" + Eval("ReportId") + "\"); return false;" %>'>
                                        <i class="fas fa-eye"></i>
                                    </asp:LinkButton>

                                    <asp:LinkButton ID="LinkButton2" runat="server"
                                        CommandName="EditReport"
                                        CommandArgument='<%# Eval("ReportId") %>'
                                        CssClass="action-btn-modern secondary"
                                        ToolTip="Edit Report"
                                        Visible='<%# IsEditable(Eval("Status").ToString()) %>'>
                                        <i class="fas fa-edit"></i>
                                    </asp:LinkButton>

                                    <asp:LinkButton ID="LinkButton3" runat="server"
                                        CommandName="CompleteReport"
                                        CommandArgument='<%# Eval("ReportId") %>'
                                        CssClass="action-btn-modern success"
                                        ToolTip="Mark as Completed"
                                        Visible='<%# IsCompletable(Eval("Status").ToString()) %>'
                                        OnClientClick='<%# "return confirmComplete(\"" + Eval("ReportId") + "\");" %>'>
                                        <i class="fas fa-check-circle"></i>
                                    </asp:LinkButton>
                                </div>
                            </div>
                        </div>
                    </AlternatingItemTemplate>
                </asp:Repeater>

                <!-- Empty State -->
                <asp:Panel ID="pnlEmptyState" runat="server" CssClass="empty-state-modern" Visible="false">
                    <div class="empty-state-icon-modern">
                        <i class="fas fa-file-alt"></i>
                    </div>
                    <h4 class="empty-state-title mb-3">No Reports Found</h4>
                    <p class="empty-state-message text-muted mb-4">
                        No collection reports match your search criteria. Try adjusting your filters or create a new report.
                    </p>
                    <asp:LinkButton ID="btnCreateFirstReport" runat="server" CssClass="action-btn primary"
                        OnClick="btnCreateReport_Click">
                        <i class="fas fa-plus-circle me-2"></i>Create Your First Report
                    </asp:LinkButton>
                </asp:Panel>
            </div>
        </div>

        <!-- Quick Actions Panel -->
        <div class="route-summary-section">
            <div class="summary-card-glass">
                <h4 class="mb-4"><i class="fas fa-bolt me-2"></i>Quick Actions</h4>

                <div class="row g-3">
                    <div class="col-md-3">
                        <asp:LinkButton ID="btnCreateNewReport" runat="server" CssClass="action-btn success w-100 py-3"
                            OnClick="btnCreateReport_Click">
                            <i class="fas fa-plus-circle me-2 fa-lg"></i>
                            <div class="d-block">New Report</div>
                            <small class="opacity-75">Create a new collection report</small>
                        </asp:LinkButton>
                    </div>
                    <div class="col-md-3">
                        <asp:LinkButton ID="btnViewPerformance" runat="server" CssClass="action-btn primary w-100 py-3"
                            OnClick="btnViewPerformance_Click">
                            <i class="fas fa-chart-line me-2 fa-lg"></i>
                            <div class="d-block">Performance</div>
                            <small class="opacity-75">View your collection analytics</small>
                        </asp:LinkButton>
                    </div>
                    <div class="col-md-3">
                        <asp:LinkButton ID="btnViewRoutes" runat="server" CssClass="action-btn secondary w-100 py-3"
                            OnClick="btnViewRoutes_Click">
                            <i class="fas fa-route me-2 fa-lg"></i>
                            <div class="d-block">My Routes</div>
                            <small class="opacity-75">Check assigned collection routes</small>
                        </asp:LinkButton>
                    </div>
                    <div class="col-md-3">
                        <asp:LinkButton ID="btnViewSchedule" runat="server" CssClass="action-btn info w-100 py-3"
                            OnClick="btnViewSchedule_Click">
                            <i class="fas fa-calendar-alt me-2 fa-lg"></i>
                            <div class="d-block">Schedule</div>
                            <small class="opacity-75">View collection schedule</small>
                        </asp:LinkButton>
                    </div>
                </div>
            </div>
        </div>
        
        <!-- Pagination -->
        <div class="d-flex justify-content-between align-items-center mt-4">
            <div class="page-info-glass">
                <i class="fas fa-list-alt me-2"></i>
                Showing <asp:Label ID="lblStartRecord" runat="server" Text="1"></asp:Label> - 
                <asp:Label ID="lblEndRecord" runat="server" Text="10"></asp:Label> of 
                <asp:Label ID="lblTotalRecords" runat="server" Text="0"></asp:Label> records
            </div>
            
            <div class="d-flex gap-2">
                <asp:LinkButton ID="btnPrevPage" runat="server" CssClass="action-btn secondary small"
                    OnClick="btnPrevPage_Click">
                    <i class="fas fa-chevron-left"></i> Previous
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
                    Next <i class="fas fa-chevron-right"></i>
                </asp:LinkButton>
            </div>
        </div>
    </div>
    
    <!-- Report Details Modal -->
    <div class="modal fade" id="reportDetailsModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered modal-lg">
            <div class="modal-content report-modal-glass">
                <div class="modal-header-glass">
                    <h5 class="modal-title-glass">
                        <i class="fas fa-file-alt me-2"></i> Report Details
                    </h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body-glass" id="reportDetailsContent">
                    <!-- Report details will be loaded here via JavaScript -->
                </div>
                <div class="modal-footer-glass">
                    <button type="button" class="action-btn secondary" data-bs-dismiss="modal">Close</button>
                    <button type="button" class="action-btn primary" id="btnPrintReportModal">
                        <i class="fas fa-print me-2"></i>Print Report
                    </button>
                </div>
            </div>
        </div>
    </div>
    
    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    
    <!-- JavaScript -->
    <script type="text/javascript">
        // Toast notification function (same as Active Pickups)
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

        // Show report details modal
        function showReportDetailsModal(reportId) {
            // Show loading
            const modalContent = document.getElementById('reportDetailsContent');
            modalContent.innerHTML = '<div class="text-center p-4"><div class="spinner"></div><p class="mt-2">Loading report details...</p></div>';
            
            // Show modal
            const modal = new bootstrap.Modal(document.getElementById('reportDetailsModal'));
            modal.show();
            
            // Load report details via AJAX
            loadReportDetails(reportId);
        }
        
        // Load report details via AJAX
        function loadReportDetails(reportId) {
            // You'll need to implement this based on your backend
            // For now, we'll use a simple example
            const modalContent = document.getElementById('reportDetailsContent');
            
            // Simulate API call
            setTimeout(() => {
                modalContent.innerHTML = `
                    <div class="report-details">
                        <div class="alert alert-info">
                            <i class="fas fa-info-circle me-2"></i>
                            Report details loading functionality needs to be implemented in the code-behind.
                        </div>
                        <p>Report ID: ${reportId}</p>
                        <p>This would show detailed information about the report including:</p>
                        <ul>
                            <li>Report information (ID, date, waste type)</li>
                            <li>Citizen details</li>
                            <li>Collection details</li>
                            <li>Verification information</li>
                            <li>Photos (if available)</li>
                        </ul>
                    </div>
                `;
                
                // Set up print button
                document.getElementById('btnPrintReportModal').onclick = function() {
                    window.open('/Pages/Collectors/PrintReport.aspx?reportId=' + reportId, '_blank');
                };
            }, 500);
        }
        
        // Handle search on Enter key
        document.getElementById('<%= txtSearch.ClientID %>')?.addEventListener('keypress', function(e) {
            if (e.key === 'Enter') {
                e.preventDefault();
                showLoading();
                // Trigger the text changed event
                __doPostBack('<%= txtSearch.UniqueID %>', '');
            }
        });

        // Confirmations for actions
        function confirmComplete(reportId) {
            return confirm(`Mark report ${reportId} as completed?\n\nThis action cannot be undone.`);
        }

        function confirmEdit(reportId) {
            return confirm(`Edit report ${reportId}?\n\nYou will be redirected to the edit page.`);
        }

        // Event handlers for quick actions
        function viewPerformance() {
            window.location.href = 'CollectorPerformance.aspx';
        }

        function viewRoutes() {
            window.location.href = 'CollectorRoutes.aspx';
        }

        function viewSchedule() {
            window.location.href = 'Schedule.aspx';
        }
    </script>
</asp:Content>