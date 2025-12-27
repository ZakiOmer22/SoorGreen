<%@ Page Title="Pickup Status" Language="C#" MasterPageFile="~/Pages/Citizen/Site.Master" 
    AutoEventWireup="true" Inherits="SoorGreen.Admin.PickupStatus" Codebehind="PickupStatus.aspx.cs" %>

<asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
    <link href='<%= ResolveUrl("~/Content/Pages/Citizen/citizenpickupstatus.css") %>' rel="stylesheet" />
    
    <!-- Add Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    
    <!-- Add Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</asp:Content>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Pickup Status - SoorGreen Citizen
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <div class="pickup-container">
        <!-- Page Header -->
        <div class="page-header-glass">
            <h1 class="page-title-glass">Pickup Status</h1>
            <p class="page-subtitle-glass">Track and manage your waste collection requests</p>
            
            <!-- Quick Actions -->
            <div class="d-flex gap-3 mt-4">
                <asp:LinkButton ID="btnNewPickup" runat="server" CssClass="action-btn primary"
                    OnClick="btnNewPickup_Click">
                    <i class="fas fa-plus-circle me-2"></i> New Pickup Request
                </asp:LinkButton>
                
                <asp:LinkButton ID="btnRefresh" runat="server" CssClass="action-btn secondary"
                    OnClick="btnRefresh_Click">
                    <i class="fas fa-sync-alt me-2"></i> Refresh
                </asp:LinkButton>
                
                <asp:LinkButton ID="btnExportPickups" runat="server" CssClass="action-btn secondary"
                    OnClick="btnExportPickups_Click">
                    <i class="fas fa-file-export me-2"></i> Export
                </asp:LinkButton>
            </div>
        </div>

        <!-- Stats Overview -->
        <div class="stats-overview-grid">
            <div class="stat-card-glass pending">
                <div class="d-flex align-items-start justify-content-between">
                    <div class="stat-icon-glass">
                        <i class="fas fa-clock"></i>
                    </div>
                    <div class="stat-trend-glass trend-up">
                        <i class="fas fa-arrow-up"></i>
                        <span>10%</span>
                    </div>
                </div>
                <div class="stat-content-glass">
                    <div class="stat-number-glass" id="statPending" runat="server">0</div>
                    <div class="stat-label-glass">Pending</div>
                </div>
            </div>
            
            <div class="stat-card-glass scheduled">
                <div class="d-flex align-items-start justify-content-between">
                    <div class="stat-icon-glass">
                        <i class="fas fa-calendar-check"></i>
                    </div>
                    <div class="stat-trend-glass trend-up">
                        <i class="fas fa-arrow-up"></i>
                        <span>15%</span>
                    </div>
                </div>
                <div class="stat-content-glass">
                    <div class="stat-number-glass" id="statScheduled" runat="server">0</div>
                    <div class="stat-label-glass">Scheduled</div>
                </div>
            </div>
            
            <div class="stat-card-glass inprogress">
                <div class="d-flex align-items-start justify-content-between">
                    <div class="stat-icon-glass">
                        <i class="fas fa-truck-loading"></i>
                    </div>
                    <div class="stat-trend-glass trend-up">
                        <i class="fas fa-arrow-up"></i>
                        <span>8%</span>
                    </div>
                </div>
                <div class="stat-content-glass">
                    <div class="stat-number-glass" id="statInProgress" runat="server">0</div>
                    <div class="stat-label-glass">In Progress</div>
                </div>
            </div>
            
            <div class="stat-card-glass completed">
                <div class="d-flex align-items-start justify-content-between">
                    <div class="stat-icon-glass">
                        <i class="fas fa-check-circle"></i>
                    </div>
                    <div class="stat-trend-glass trend-up">
                        <i class="fas fa-arrow-up"></i>
                        <span>25%</span>
                    </div>
                </div>
                <div class="stat-content-glass">
                    <div class="stat-number-glass" id="statCompleted" runat="server">0</div>
                    <div class="stat-label-glass">Completed</div>
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
                <div class="quick-action-card" onclick="location.href='MyReports.aspx'">
                    <i class="fas fa-trash-alt"></i>
                    <h4 class="quick-action-title">Create Report</h4>
                    <p class="quick-action-desc">Submit a new waste disposal report</p>
                </div>
                
                <div class="quick-action-card" onclick="showScheduleModal()">
                    <i class="fas fa-calendar-plus"></i>
                    <h4 class="quick-action-title">Schedule Pickup</h4>
                    <p class="quick-action-desc">Schedule collection from your reports</p>
                </div>
                
                <div class="quick-action-card" onclick="location.href='PickupHistory.aspx'">
                    <i class="fas fa-history"></i>
                    <h4 class="quick-action-title">View History</h4>
                    <p class="quick-action-desc">Check your past pickup records</p>
                </div>
                
                <div class="quick-action-card" onclick="location.href='Support.aspx'">
                    <i class="fas fa-headset"></i>
                    <h4 class="quick-action-title">Get Support</h4>
                    <p class="quick-action-desc">Need help with your pickups?</p>
                </div>
            </div>
        </div>

        <!-- Pickups List -->
        <div class="pickups-list-container">
            <div class="pickups-list-header">
                <h3 class="pickups-list-title">Active Pickups</h3>
                <div class="pickups-filters-glass">
                    <asp:DropDownList ID="ddlStatusFilter" runat="server" CssClass="filter-select-glass"
                        AutoPostBack="true" OnSelectedIndexChanged="ddlStatusFilter_SelectedIndexChanged">
                        <asp:ListItem Value="all">All Status</asp:ListItem>
                        <asp:ListItem Value="Requested">Pending</asp:ListItem>
                        <asp:ListItem Value="Scheduled">Scheduled</asp:ListItem>
                        <asp:ListItem Value="InProgress">In Progress</asp:ListItem>
                        <asp:ListItem Value="Collected">Completed</asp:ListItem>
                        <asp:ListItem Value="Cancelled">Cancelled</asp:ListItem>
                    </asp:DropDownList>
                    
                    <asp:DropDownList ID="ddlDateFilter" runat="server" CssClass="filter-select-glass"
                        AutoPostBack="true" OnSelectedIndexChanged="ddlDateFilter_SelectedIndexChanged">
                        <asp:ListItem Value="today">Today</asp:ListItem>
                        <asp:ListItem Value="week">This Week</asp:ListItem>
                        <asp:ListItem Value="month">This Month</asp:ListItem>
                        <asp:ListItem Value="year">This Year</asp:ListItem>
                        <asp:ListItem Value="upcoming">Upcoming</asp:ListItem>
                        <asp:ListItem Value="past">Past</asp:ListItem>
                        <asp:ListItem Value="all">All Time</asp:ListItem>
                    </asp:DropDownList>
                    
                    <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control-glass"
                        placeholder="Search pickups..." AutoPostBack="true"
                        OnTextChanged="txtSearch_TextChanged"></asp:TextBox>
                </div>
            </div>
            
            <!-- Pickup Cards -->
            <asp:Panel ID="pnlPickupCards" runat="server" CssClass="pickups-cards-grid">
                <asp:Repeater ID="rptPickups" runat="server" OnItemCommand="rptPickups_ItemCommand">
                    <ItemTemplate>
                        <div class='pickup-card-glass <%# GetStatusColor(Eval("StatusDisplay").ToString()) %>'>
                            <div class="pickup-card-header">
                                <div class="d-flex justify-content-between align-items-center">
                                    <span class="pickup-id"><%# Eval("PickupId") %></span>
                                    <!-- REMOVED: Priority badge since no Priority column in database -->
                                </div>
                                <span class='pickup-status-badge <%# GetStatusColor(Eval("StatusDisplay").ToString()) %>'>
                                    <i class='<%# GetStatusIcon(Eval("PickupStatus").ToString()) %> me-1'></i>
                                    <%# Eval("PickupStatus") %>
                                </span>
                            </div>
                            
                            <div class="pickup-card-body">
                                <div class="pickup-details-grid">
                                    <div class="detail-item">
                                        <span class="detail-label">Report ID</span>
                                        <span class="detail-value"><%# Eval("ReportId") %></span>
                                    </div>
                                    <div class="detail-item">
                                        <span class="detail-label">Waste Type</span>
                                        <span class="detail-value"><%# Eval("WasteType") %></span>
                                    </div>
                                    <div class="detail-item">
                                        <span class="detail-label">Weight</span>
                                        <span class="detail-value"><%# Eval("Weight") %> kg</span>
                                    </div>
                                    <div class="detail-item">
                                        <span class="detail-label">Reward</span>
                                        <span class="detail-value text-success"><%# Eval("EstimatedReward") %> XP</span>
                                    </div>
                                </div>
                                
                                <div class="pickup-info-grid mt-3">
                                    <div class="info-item">
                                        <i class="fas fa-calendar-alt text-info me-2"></i>
                                        <span class="info-label">Scheduled:</span>
                                        <span class="info-value"><%# FormatDateTime(Eval("ScheduledDate")) %></span>
                                    </div>
                                    <div class="info-item">
                                        <i class="fas fa-user text-primary me-2"></i>
                                        <span class="info-label">Collector:</span>
                                        <span class="info-value">
                                            <%# Eval("CollectorName") != DBNull.Value ? Eval("CollectorName") : "Not Assigned" %>
                                        </span>
                                    </div>
                                    <div class="info-item">
                                        <i class="fas fa-phone text-success me-2"></i>
                                        <span class="info-label">Contact:</span>
                                        <span class="info-value">
                                            <%# Eval("CollectorPhone") != DBNull.Value ? Eval("CollectorPhone") : "N/A" %>
                                        </span>
                                    </div>
                                </div>
                                
                                <div class="pickup-location mt-3">
                                    <div class="location-label">
                                        <i class="fas fa-map-marker-alt"></i>
                                        Pickup Address
                                    </div>
                                    <div class="location-text"><%# Eval("Address") %></div>
                                </div>
                                
                                <asp:Panel ID="pnlPhotoPreview" runat="server" CssClass="pickup-photo-preview mt-3" 
                                    Visible='<%# !string.IsNullOrEmpty(Eval("PhotoUrl").ToString()) %>'>
                                    <div class="photo-label">
                                        <i class="fas fa-camera"></i>
                                        Report Photo
                                    </div>
                                    <img src='<%# Eval("PhotoUrl") %>' alt="Report Photo" 
                                        class="img-thumbnail mt-2" style="width: 100%; height: 120px; object-fit: cover;" />
                                </asp:Panel>
                            </div>
                            
                            <div class="pickup-card-footer">
                                <div class="pickup-time">
                                    <i class="fas fa-clock"></i>
                                    <span>
                                        <%# Eval("CompletedDate") != DBNull.Value ? 
                                            "Completed: " + FormatDateTime(Eval("CompletedDate")) : 
                                            "Created: " + FormatDateTime(Eval("ScheduledDate")) %>
                                    </span>
                                </div>
                                
                                <div class="pickup-actions">
                                    <asp:LinkButton ID="btnViewDetails" runat="server" 
                                        CommandName="ViewDetails" 
                                        CommandArgument='<%# Eval("PickupId") %>'
                                        CssClass="action-btn secondary small" 
                                        ToolTip="View Details">
                                        <i class="fas fa-eye"></i>
                                    </asp:LinkButton>
                                    
                                    <asp:LinkButton ID="btnReschedule" runat="server" 
                                        CommandName="Reschedule" 
                                        CommandArgument='<%# Eval("PickupId") %>'
                                        CssClass="action-btn primary small" 
                                        ToolTip="Reschedule"
                                        Visible='<%# CanReschedule(Eval("PickupStatus").ToString()) %>'>
                                        <i class="fas fa-calendar-alt"></i>
                                    </asp:LinkButton>
                                    
                                    <asp:LinkButton ID="btnCancel" runat="server" 
                                        CommandName="Cancel" 
                                        CommandArgument='<%# Eval("PickupId") %>'
                                        CssClass="action-btn danger small" 
                                        ToolTip="Cancel Pickup"
                                        OnClientClick="return confirm('Are you sure you want to cancel this pickup?');"
                                        Visible='<%# CanCancel(Eval("PickupStatus").ToString()) %>'>
                                        <i class="fas fa-times"></i>
                                    </asp:LinkButton>
                                    
                                    <asp:LinkButton ID="btnContactCollector" runat="server" 
                                        CommandName="ContactCollector" 
                                        CommandArgument='<%# Eval("PickupId") %>'
                                        CssClass="action-btn info small" 
                                        ToolTip="Contact Collector"
                                        Visible='<%# HasCollector(Eval("CollectorName").ToString()) %>'>
                                        <i class="fas fa-phone-alt"></i>
                                    </asp:LinkButton>
                                </div>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </asp:Panel>
            
            <!-- Empty State -->
            <asp:Panel ID="pnlEmptyState" runat="server" CssClass="empty-state-glass" Visible="false">
                <div class="empty-state-icon">
                    <i class="fas fa-truck"></i>
                </div>
                <h4 class="empty-state-title">No Pickups Found</h4>
                <p class="empty-state-message">
                    You don't have any pickup requests yet. Schedule a pickup from your waste reports!
                </p>
                <asp:LinkButton ID="btnCreateFirstPickup" runat="server" CssClass="action-btn primary"
                    OnClick="btnNewPickup_Click">
                    <i class="fas fa-plus-circle me-2"></i> Schedule Your First Pickup
                </asp:LinkButton>
            </asp:Panel>
            
            <!-- Loading State -->
            <asp:Panel ID="pnlLoading" runat="server" CssClass="text-center py-5" Visible="false">
                <div class="loader-glass"></div>
                <p class="text-muted mt-3">Loading pickups...</p>
            </asp:Panel>
        </div>
        
        <!-- Pagination -->
        <div class="d-flex justify-content-between align-items-center mt-4">
            <div class="text-muted">
                Showing <asp:Label ID="lblStartCount" runat="server" Text="1"></asp:Label> - 
                <asp:Label ID="lblEndCount" runat="server" Text="10"></asp:Label> of 
                <asp:Label ID="lblTotalCount" runat="server" Text="0"></asp:Label> pickups
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
    
    <!-- Schedule Pickup Modal -->
    <div class="modal fade" id="scheduleModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered modal-lg">
            <div class="modal-content report-modal-glass">
                <div class="modal-header-glass">
                    <h5 class="modal-title-glass">Schedule New Pickup</h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body-glass">
                    <p class="text-muted mb-4">Select a waste report to schedule pickup for:</p>
                    
                    <!-- Report selection will be loaded here -->
                    <div id="reportsList" class="reports-selection">
                        <!-- Reports will be populated via AJAX -->
                    </div>
                </div>
                <div class="modal-footer-glass">
                    <button type="button" class="action-btn secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="button" class="action-btn primary" onclick="scheduleSelectedReport()">Schedule Pickup</button>
                </div>
            </div>
        </div>
    </div>
    
    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    
    <!-- JavaScript -->
    <script type="text/javascript">
        // Show schedule modal
        function showScheduleModal() {
            var modal = new bootstrap.Modal(document.getElementById('scheduleModal'));
            modal.show();

            // Load available reports
            loadAvailableReports();
        }

        function loadAvailableReports() {
            // This would typically be an AJAX call to load reports without pickups
            // For now, show a message
            document.getElementById('reportsList').innerHTML = `
                <div class="text-center py-4">
                    <i class="fas fa-info-circle fa-3x text-info mb-3"></i>
                    <p>Please go to "My Reports" page to schedule pickups from available reports.</p>
                    <button type="button" class="action-btn primary" onclick="location.href='MyReports.aspx'">
                        <i class="fas fa-external-link-alt me-2"></i> Go to Reports
                    </button>
                </div>
            `;
        }

        function scheduleSelectedReport() {
            alert('Pickup scheduling feature will be implemented soon!');
            var modal = bootstrap.Modal.getInstance(document.getElementById('scheduleModal'));
            modal.hide();
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