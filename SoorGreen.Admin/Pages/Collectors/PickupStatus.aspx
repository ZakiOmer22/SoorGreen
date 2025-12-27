<%@ Page Title="Pickup Status" Language="C#" MasterPageFile="~/Pages/Collectors/Site.Master" 
    AutoEventWireup="true" Inherits="SoorGreen.Collectors.PickupStatus" Codebehind="PickupStatus.aspx.cs" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <link href='<%= ResolveUrl("~/Content/Pages/Collectors/collectorsroute.css") %>' rel="stylesheet" />
    <link href='<%= ResolveUrl("~/Content/Pages/Collectors/PickupStatus.css") %>' rel="stylesheet" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</asp:Content>

<asp:Content ID="TitleContent" ContentPlaceHolderID="TitleContent" runat="server">
    Pickup Status - SoorGreen Collector
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <!-- Hidden fields -->
    <asp:HiddenField ID="hdnSelectedPickupId" runat="server" />
    <asp:HiddenField ID="hdnCurrentPage" runat="server" Value="1" />

    <div class="route-container" id="pageContainer">
        <!-- Page Header -->
        <div class="page-header-glass mb-4">
            <div class="d-flex justify-content-between align-items-center">
                <div>
                    <h1 class="page-title-glass mb-2">
                        <i class="fas fa-truck-loading me-3 text-primary"></i>Pickup Status
                    </h1>
                    <p class="page-subtitle-glass mb-0">Manage and track your waste collection pickups in real-time</p>
                </div>
                <div class="d-flex gap-2">
                    <asp:LinkButton ID="btnRefresh" runat="server" CssClass="action-btn secondary"
                        OnClick="btnRefresh_Click" OnClientClick="showLoading()">
                        <i class="fas fa-sync-alt me-2"></i>Refresh
                    </asp:LinkButton>
                    <asp:LinkButton ID="btnExportPickups" runat="server" CssClass="action-btn secondary"
                        OnClick="btnExportPickups_Click">
                        <i class="fas fa-file-export me-2"></i>Export
                    </asp:LinkButton>
                </div>
            </div>
        </div>

        <!-- Pickup Stats -->
        <div class="stats-grid-improved mb-4">
            <div class="stat-card">
                <div class="stat-icon-large text-primary">
                    <i class="fas fa-tasks"></i>
                </div>
                <div class="stat-number-large">
                    <asp:Label ID="statTotalPickups" runat="server" Text="0"></asp:Label>
                </div>
                <div class="stat-label">Total Pickups</div>
                <small class="text-muted">Assigned to you</small>
            </div>

            <div class="stat-card">
                <div class="stat-icon-large text-warning">
                    <i class="fas fa-spinner"></i>
                </div>
                <div class="stat-number-large">
                    <asp:Label ID="statInProgress" runat="server" Text="0"></asp:Label>
                </div>
                <div class="stat-label">In Progress</div>
                <small class="text-muted">Currently collecting</small>
            </div>

            <div class="stat-card">
                <div class="stat-icon-large text-success">
                    <i class="fas fa-check-circle"></i>
                </div>
                <div class="stat-number-large">
                    <asp:Label ID="statCompletedToday" runat="server" Text="0"></asp:Label>
                </div>
                <div class="stat-label">Completed Today</div>
                <small class="text-muted">Successfully collected</small>
            </div>

            <div class="stat-card">
                <div class="stat-icon-large text-info">
                    <i class="fas fa-clock"></i>
                </div>
                <div class="stat-number-large">
                    <asp:Label ID="statPending" runat="server" Text="0"></asp:Label>
                </div>
                <div class="stat-label">Pending</div>
                <small class="text-muted">Awaiting action</small>
            </div>
        </div>

        <!-- Filters Section -->
        <div class="route-controls-glass mb-4">
            <div class="d-flex justify-content-between align-items-center mb-3">
                <h4 class="mb-0"><i class="fas fa-filter me-2"></i>Filter Pickups</h4>
                <asp:LinkButton ID="btnClearFilters" runat="server" CssClass="action-btn danger small"
                    OnClick="btnClearFilters_Click">
                    <i class="fas fa-times me-1"></i>Clear All
                </asp:LinkButton>
            </div>

            <div class="row g-3">
                <div class="col-md-3">
                    <div class="control-group">
                        <label class="control-label mb-2">
                            <i class="fas fa-calendar me-1"></i> From Date
                        </label>
                        <asp:TextBox ID="txtStartDate" runat="server" CssClass="form-control-glass" TextMode="Date"></asp:TextBox>
                    </div>
                </div>

                <div class="col-md-3">
                    <div class="control-group">
                        <label class="control-label mb-2">
                            <i class="fas fa-calendar me-1"></i> To Date
                        </label>
                        <asp:TextBox ID="txtEndDate" runat="server" CssClass="form-control-glass" TextMode="Date"></asp:TextBox>
                    </div>
                </div>

                <div class="col-md-3">
                    <div class="control-group">
                        <label class="control-label mb-2">
                            <i class="fas fa-tag me-1"></i> Status
                        </label>
                        <asp:DropDownList ID="ddlStatus" runat="server" CssClass="form-control-glass"
                            AutoPostBack="true" OnSelectedIndexChanged="ddlStatus_SelectedIndexChanged">
                        </asp:DropDownList>
                    </div>
                </div>

                <div class="col-md-3">
                    <div class="control-group">
                        <label class="control-label mb-2">
                            <i class="fas fa-search me-1"></i> Search
                        </label>
                        <div class="search-box">
                            <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control-glass"
                                placeholder="Search by ID, address, or name..." AutoPostBack="true"
                                OnTextChanged="txtSearch_TextChanged"></asp:TextBox>
                            <span class="search-icon">
                                <i class="fas fa-search"></i>
                            </span>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Pickups List Table -->
        <div class="modern-table-container mb-4">
            <div class="modern-table-header">
                <div class="modern-table-header-row">
                    <div class="table-col">Pickup ID</div>
                    <div class="table-col">Pickup Details</div>
                    <div class="table-col">Waste Type</div>
                    <div class="table-col">Scheduled</div>
                    <div class="table-col">Completed</div>
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

                <asp:Repeater ID="rptPickups" runat="server" 
                    OnItemDataBound="rptPickups_ItemDataBound"
                    OnItemCommand="rptPickups_ItemCommand">
                    <ItemTemplate>
                        <div class='modern-table-row'>
                            <div class="table-col">
                                <span class="pickup-id fw-bold">
                                    <i class="fas fa-hashtag me-1 text-muted"></i>
                                    <asp:Label ID="lblPickupId" runat="server" Text='<%# Eval("PickupId") %>'></asp:Label>
                                </span>
                                <div class="report-date mt-1">
                                    <i class="fas fa-file-alt me-1 text-muted" style="font-size: 0.75rem;"></i>
                                    <span class="text-muted" style="font-size: 0.75rem;">
                                        <asp:Label ID="lblReportId" runat="server" 
                                            Text='<%# Eval("ReportId") %>'></asp:Label>
                                    </span>
                                </div>
                            </div>

                            <div class="table-col">
                                <div class="pickup-details-table">
                                    <div class="pickup-address">
                                        <i class="fas fa-map-marker-alt me-1 text-danger" style="font-size: 0.8rem;"></i>
                                        <asp:Label ID="lblAddress" runat="server" Text='<%# Eval("Address") %>'></asp:Label>
                                    </div>
                                    <div class="pickup-citizen">
                                        <i class="fas fa-user me-1 text-info" style="font-size: 0.75rem;"></i>
                                        <asp:Label ID="lblCitizenName" runat="server" Text='<%# Eval("CitizenName") %>'></asp:Label>
                                    </div>
                                    <div class="pickup-date">
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
                                <span class="text-muted" style="font-size: 0.85rem;">
                                    <i class="fas fa-calendar me-1"></i>
                                    <asp:Label ID="lblScheduled" runat="server" 
                                        Text='<%# FormatDateTime(Eval("ScheduledAt")) %>'></asp:Label>
                                </span>
                            </div>

                            <div class="table-col">
                                <span class="text-muted" style="font-size: 0.85rem;">
                                    <i class="fas fa-check-circle me-1"></i>
                                    <asp:Label ID="lblCompleted" runat="server" 
                                        Text='<%# FormatDateTime(Eval("CompletedAt")) %>'></asp:Label>
                                </span>
                            </div>

                            <div class="table-col">
                                <span class="weight-estimated fw-bold">
                                    <i class="fas fa-weight-hanging me-1"></i>
                                    <asp:Label ID="lblWeight" runat="server" 
                                        Text='<%# Eval("EstimatedKg", "{0:F1}") %>'></asp:Label>
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
                                        CommandArgument='<%# Eval("PickupId") %>'
                                        CssClass="action-btn-modern secondary"
                                        ToolTip="View Details"
                                        OnClientClick='<%# "showPickupDetailsModal(\"" + Eval("PickupId") + "\"); return false;" %>'>
                                        <i class="fas fa-eye"></i>
                                    </asp:LinkButton>

                                    <asp:LinkButton ID="btnStart" runat="server"
                                        CommandName="StartPickup"
                                        CommandArgument='<%# Eval("PickupId") %>'
                                        CssClass="action-btn-modern warning"
                                        ToolTip="Start Pickup"
                                        Visible="false"
                                        OnClientClick='<%# "return confirmStartPickup(\"" + Eval("PickupId") + "\");" %>'>
                                        <i class="fas fa-play"></i>
                                    </asp:LinkButton>

                                    <asp:LinkButton ID="btnComplete" runat="server"
                                        CommandName="CompletePickup"
                                        CommandArgument='<%# Eval("PickupId") %>'
                                        CssClass="action-btn-modern success"
                                        ToolTip="Mark as Completed"
                                        Visible="false"
                                        OnClientClick='<%# "return confirmCompletePickup(\"" + Eval("PickupId") + "\");" %>'>
                                        <i class="fas fa-check-circle"></i>
                                    </asp:LinkButton>

                                    <asp:LinkButton ID="btnCancel" runat="server"
                                        CommandName="CancelPickup"
                                        CommandArgument='<%# Eval("PickupId") %>'
                                        CssClass="action-btn-modern danger"
                                        ToolTip="Cancel Pickup"
                                        Visible="false"
                                        OnClientClick='<%# "return confirmCancelPickup(\"" + Eval("PickupId") + "\");" %>'>
                                        <i class="fas fa-times"></i>
                                    </asp:LinkButton>

                                    <asp:LinkButton ID="btnViewLocation" runat="server"
                                        CommandName="ViewLocation"
                                        CommandArgument='<%# Eval("PickupId") %>'
                                        CssClass="action-btn-modern info"
                                        ToolTip="View Location">
                                        <i class="fas fa-map-marker-alt"></i>
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
                                    <asp:Label ID="Label1" runat="server" Text='<%# Eval("PickupId") %>'></asp:Label>
                                </span>
                                <div class="report-date mt-1">
                                    <i class="fas fa-file-alt me-1 text-muted" style="font-size: 0.75rem;"></i>
                                    <span class="text-muted" style="font-size: 0.75rem;">
                                        <asp:Label ID="Label2" runat="server" 
                                            Text='<%# Eval("ReportId") %>'></asp:Label>
                                    </span>
                                </div>
                            </div>

                            <div class="table-col">
                                <div class="pickup-details-table">
                                    <div class="pickup-address">
                                        <i class="fas fa-map-marker-alt me-1 text-danger" style="font-size: 0.8rem;"></i>
                                        <asp:Label ID="Label3" runat="server" Text='<%# Eval("Address") %>'></asp:Label>
                                    </div>
                                    <div class="pickup-citizen">
                                        <i class="fas fa-user me-1 text-info" style="font-size: 0.75rem;"></i>
                                        <asp:Label ID="Label4" runat="server" Text='<%# Eval("CitizenName") %>'></asp:Label>
                                    </div>
                                    <div class="pickup-date">
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
                                <span class="text-muted" style="font-size: 0.85rem;">
                                    <i class="fas fa-calendar me-1"></i>
                                    <asp:Label ID="Label7" runat="server" 
                                        Text='<%# FormatDateTime(Eval("ScheduledAt")) %>'></asp:Label>
                                </span>
                            </div>

                            <div class="table-col">
                                <span class="text-muted" style="font-size: 0.85rem;">
                                    <i class="fas fa-check-circle me-1"></i>
                                    <asp:Label ID="Label8" runat="server" 
                                        Text='<%# FormatDateTime(Eval("CompletedAt")) %>'></asp:Label>
                                </span>
                            </div>

                            <div class="table-col">
                                <span class="weight-estimated fw-bold">
                                    <i class="fas fa-weight-hanging me-1"></i>
                                    <asp:Label ID="Label9" runat="server" 
                                        Text='<%# Eval("EstimatedKg", "{0:F1}") %>'></asp:Label>
                                    <span class="text-muted" style="font-size: 0.75rem;">kg</span>
                                </span>
                            </div>

                            <div class="table-col">
                                <span class='<%# GetStatusBadgeClass(Eval("Status").ToString()) %>'>
                                    <i class='<%# BindStatusIcon(Eval("Status").ToString()) %>'></i>
                                    <asp:Label ID="Label10" runat="server" Text='<%# Eval("Status") %>'></asp:Label>
                                </span>
                            </div>

                            <div class="table-col">
                                <div class="action-buttons-container">
                                    <asp:LinkButton ID="LinkButton1" runat="server"
                                        CommandName="ViewDetails"
                                        CommandArgument='<%# Eval("PickupId") %>'
                                        CssClass="action-btn-modern secondary"
                                        ToolTip="View Details"
                                        OnClientClick='<%# "showPickupDetailsModal(\"" + Eval("PickupId") + "\"); return false;" %>'>
                                        <i class="fas fa-eye"></i>
                                    </asp:LinkButton>

                                    <asp:LinkButton ID="LinkButton2" runat="server"
                                        CommandName="StartPickup"
                                        CommandArgument='<%# Eval("PickupId") %>'
                                        CssClass="action-btn-modern warning"
                                        ToolTip="Start Pickup"
                                        Visible="false"
                                        OnClientClick='<%# "return confirmStartPickup(\"" + Eval("PickupId") + "\");" %>'>
                                        <i class="fas fa-play"></i>
                                    </asp:LinkButton>

                                    <asp:LinkButton ID="LinkButton3" runat="server"
                                        CommandName="CompletePickup"
                                        CommandArgument='<%# Eval("PickupId") %>'
                                        CssClass="action-btn-modern success"
                                        ToolTip="Mark as Completed"
                                        Visible="false"
                                        OnClientClick='<%# "return confirmCompletePickup(\"" + Eval("PickupId") + "\");" %>'>
                                        <i class="fas fa-check-circle"></i>
                                    </asp:LinkButton>

                                    <asp:LinkButton ID="LinkButton4" runat="server"
                                        CommandName="CancelPickup"
                                        CommandArgument='<%# Eval("PickupId") %>'
                                        CssClass="action-btn-modern danger"
                                        ToolTip="Cancel Pickup"
                                        Visible="false"
                                        OnClientClick='<%# "return confirmCancelPickup(\"" + Eval("PickupId") + "\");" %>'>
                                        <i class="fas fa-times"></i>
                                    </asp:LinkButton>

                                    <asp:LinkButton ID="LinkButton5" runat="server"
                                        CommandName="ViewLocation"
                                        CommandArgument='<%# Eval("PickupId") %>'
                                        CssClass="action-btn-modern info"
                                        ToolTip="View Location">
                                        <i class="fas fa-map-marker-alt"></i>
                                    </asp:LinkButton>
                                </div>
                            </div>
                        </div>
                    </AlternatingItemTemplate>
                </asp:Repeater>

                <!-- Empty State -->
                <asp:Panel ID="pnlEmptyState" runat="server" CssClass="empty-state-modern" Visible="false">
                    <div class="empty-state-icon-modern">
                        <i class="fas fa-truck-loading"></i>
                    </div>
                    <h4 class="empty-state-title mb-3">No Pickups Found</h4>
                    <p class="empty-state-message text-muted mb-4">
                        No pickups match your search criteria. Check back later for new assignments.
                    </p>
                    <div class="d-flex gap-2 justify-content-center">
                        <asp:LinkButton ID="btnCheckRoutes" runat="server" CssClass="action-btn secondary"
                            OnClick="btnRefresh_Click">
                            <i class="fas fa-sync-alt me-2"></i>Refresh
                        </asp:LinkButton>
                        <asp:LinkButton ID="btnViewSchedule" runat="server" CssClass="action-btn primary"
                            OnClick="btnViewSchedule_Click">
                            <i class="fas fa-calendar-alt me-2"></i>View Schedule
                        </asp:LinkButton>
                    </div>
                </asp:Panel>
            </div>
        </div>

        <!-- Quick Actions -->
        <div class="route-summary-section">
            <div class="summary-card-glass">
                <h4 class="mb-4"><i class="fas fa-bolt me-2"></i>Quick Actions</h4>
                <div class="row g-3">
                    <div class="col-md-3">
                        <asp:LinkButton ID="btnStartAll" runat="server" CssClass="action-btn warning w-100 py-3"
                            OnClick="btnStartAll_Click" OnClientClick="return confirmStartAll();">
                            <i class="fas fa-play-circle me-2 fa-lg"></i>
                            <div class="d-block">Start All</div>
                            <small class="opacity-75">Start all assigned pickups</small>
                        </asp:LinkButton>
                    </div>
                    <div class="col-md-3">
                        <asp:LinkButton ID="btnViewToday" runat="server" CssClass="action-btn primary w-100 py-3"
                            OnClick="btnViewToday_Click">
                            <i class="fas fa-calendar-day me-2 fa-lg"></i>
                            <div class="d-block">Today's Schedule</div>
                            <small class="opacity-75">View today's pickups</small>
                        </asp:LinkButton>
                    </div>
                    <div class="col-md-3">
                        <asp:LinkButton ID="btnRouteOptimizer" runat="server" CssClass="action-btn success w-100 py-3"
                            OnClick="btnRouteOptimizer_Click">
                            <i class="fas fa-route me-2 fa-lg"></i>
                            <div class="d-block">Optimize Route</div>
                            <small class="opacity-75">Plan efficient route</small>
                        </asp:LinkButton>
                    </div>
                    <div class="col-md-3">
                        <asp:LinkButton ID="btnMarkAllComplete" runat="server" CssClass="action-btn info w-100 py-3"
                            OnClick="btnMarkAllComplete_Click" OnClientClick="return confirmMarkAllComplete();">
                            <i class="fas fa-check-double me-2 fa-lg"></i>
                            <div class="d-block">Complete All</div>
                            <small class="opacity-75">Mark all as completed</small>
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
    
    <!-- Pickup Details Modal -->
    <div class="modal fade" id="pickupDetailsModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered modal-lg">
            <div class="modal-content pickup-modal-glass">
                <div class="modal-header-glass">
                    <h5 class="modal-title-glass">
                        <i class="fas fa-truck-loading me-2"></i> Pickup Details
                    </h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body-glass" id="pickupDetailsContent">
                    <!-- Pickup details will be loaded here via JavaScript -->
                </div>
                <div class="modal-footer-glass">
                    <button type="button" class="action-btn secondary" data-bs-dismiss="modal">Close</button>
                    <button type="button" class="action-btn primary" id="btnStartPickupModal">
                        <i class="fas fa-play me-2"></i>Start Pickup
                    </button>
                    <button type="button" class="action-btn success" id="btnCompletePickupModal">
                        <i class="fas fa-check-circle me-2"></i>Complete
                    </button>
                </div>
            </div>
        </div>
    </div>
    
    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    
    <!-- JavaScript -->
    <script type="text/javascript">
        // Toast notification function
        function showToast(message, type) {
            const existingToasts = document.querySelectorAll('.toast-notification');
            existingToasts.forEach(toast => {
                toast.style.animation = 'slideInRight 0.3s ease reverse';
                setTimeout(() => toast.remove(), 300);
            });

            const toast = document.createElement('div');
            toast.className = 'toast-notification toast-' + type;
            toast.innerHTML = '<div class="toast-icon">' +
                                '<i class="' + getToastIcon(type) + '"></i>' +
                              '</div>' +
                              '<div class="toast-message">' + message + '</div>' +
                              '<button class="toast-close" onclick="this.parentElement.remove()">' +
                                '<i class="fas fa-times"></i>' +
                              '</button>';

            document.body.appendChild(toast);

            setTimeout(function() {
                if (toast.parentElement) {
                    toast.style.animation = 'slideInRight 0.3s ease reverse';
                    setTimeout(function() { toast.remove(); }, 300);
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

            // Hide loading spinner after page load
            setTimeout(hideLoading, 500);
        });

        // Show pickup details modal
        function showPickupDetailsModal(pickupId) {
            const modalContent = document.getElementById('pickupDetailsContent');
            modalContent.innerHTML = '<div class="text-center p-4"><div class="spinner"></div><p class="mt-2">Loading pickup details...</p></div>';
            
            const modal = new bootstrap.Modal(document.getElementById('pickupDetailsModal'));
            modal.show();
            
            loadPickupDetails(pickupId);
        }
        
        // Load pickup details via AJAX
        function loadPickupDetails(pickupId) {
            const modalContent = document.getElementById('pickupDetailsContent');
            
            // Simulate API call - replace with actual AJAX call
            setTimeout(function() {
                modalContent.innerHTML = '<div class="pickup-details-full">' +
                    '<div class="row mb-4">' +
                        '<div class="col-md-6">' +
                            '<h6><i class="fas fa-info-circle me-2"></i>Pickup Information</h6>' +
                            '<div class="details-list">' +
                                '<div class="detail-item">' +
                                    '<span class="detail-label">Pickup ID:</span>' +
                                    '<span class="detail-value">' + pickupId + '</span>' +
                                '</div>' +
                                '<div class="detail-item">' +
                                    '<span class="detail-label">Status:</span>' +
                                    '<span class="detail-value"><span class="status-badge status-assigned">Assigned</span></span>' +
                                '</div>' +
                                '<div class="detail-item">' +
                                    '<span class="detail-label">Scheduled Time:</span>' +
                                    '<span class="detail-value">Today, 10:30 AM</span>' +
                                '</div>' +
                            '</div>' +
                        '</div>' +
                        '<div class="col-md-6">' +
                            '<h6><i class="fas fa-user me-2"></i>Citizen Information</h6>' +
                            '<div class="details-list">' +
                                '<div class="detail-item">' +
                                    '<span class="detail-label">Name:</span>' +
                                    '<span class="detail-value">John Doe</span>' +
                                '</div>' +
                                '<div class="detail-item">' +
                                    '<span class="detail-label">Phone:</span>' +
                                    '<span class="detail-value">+1 (555) 123-4567</span>' +
                                '</div>' +
                                '<div class="detail-item">' +
                                    '<span class="detail-label">Address:</span>' +
                                    '<span class="detail-value">123 Green Street, Eco City</span>' +
                                '</div>' +
                            '</div>' +
                        '</div>' +
                    '</div>' +
                    
                    '<div class="pickup-timeline mb-4">' +
                        '<div class="timeline-connector"></div>' +
                        '<div class="timeline-step">' +
                            '<div class="timeline-dot completed"></div>' +
                            '<div class="timeline-label">Requested</div>' +
                        '</div>' +
                        '<div class="timeline-step">' +
                            '<div class="timeline-dot completed"></div>' +
                            '<div class="timeline-label">Assigned</div>' +
                        '</div>' +
                        '<div class="timeline-step">' +
                            '<div class="timeline-dot active"></div>' +
                            '<div class="timeline-label">In Progress</div>' +
                        '</div>' +
                        '<div class="timeline-step">' +
                            '<div class="timeline-dot"></div>' +
                            '<div class="timeline-label">Collected</div>' +
                        '</div>' +
                    '</div>' +
                    
                    '<div class="alert alert-info">' +
                        '<i class="fas fa-info-circle me-2"></i>' +
                        'Detailed pickup information loaded dynamically.' +
                    '</div>' +
                '</div>';
                
                // Set up modal buttons
                document.getElementById('btnStartPickupModal').onclick = function() {
                    __doPostBack('', 'StartPickup:' + pickupId);
                    modal.hide();
                };
                
                document.getElementById('btnCompletePickupModal').onclick = function() {
                    if (confirm('Complete pickup ' + pickupId + '?')) {
                        __doPostBack('', 'CompletePickup:' + pickupId);
                        modal.hide();
                    }
                };
            }, 500);
        }
        
        // Handle search on Enter key
        var searchBox = document.getElementById('<%= txtSearch.ClientID %>');
        if (searchBox) {
            searchBox.addEventListener('keypress', function(e) {
                if (e.key === 'Enter') {
                    e.preventDefault();
                    showLoading();
                    __doPostBack('<%= txtSearch.UniqueID %>', '');
                }
            });
        }

        // Confirmation functions
        function confirmStartPickup(pickupId) {
            return confirm('Start pickup ' + pickupId + '?\n\nThis will change status to "In Progress".');
        }

        function confirmCompletePickup(pickupId) {
            return confirm('Mark pickup ' + pickupId + ' as completed?\n\nThis action will finalize the pickup and award points to the citizen.');
        }

        function confirmCancelPickup(pickupId) {
            return confirm('Cancel pickup ' + pickupId + '?\n\nThis action cannot be undone.');
        }

        function confirmStartAll() {
            return confirm('Start all assigned pickups?\n\nThis will change all "Assigned" pickups to "In Progress".');
        }

        function confirmMarkAllComplete() {
            return confirm('Mark all in-progress pickups as completed?\n\nPlease ensure all pickups are actually completed before proceeding.');
        }

        // Auto-refresh every 30 seconds
        setInterval(function() {
            if (document.visibilityState === 'visible') {
                __doPostBack('<%= btnRefresh.UniqueID %>', '');
            }
        }, 30000);
    </script>
</asp:Content>