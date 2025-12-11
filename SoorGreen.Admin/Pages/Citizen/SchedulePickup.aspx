<%@ Page Title="Schedule Pickups" Language="C#" MasterPageFile="~/Pages/Citizen/Site.Master"
    AutoEventWireup="true" CodeFile="SchedulePickup.aspx.cs" Inherits="SoorGreen.Admin.SchedulePickups" %>

<asp:Content ID="Content3" ContentPlaceHolderID="HeadContent" runat="server">
    <link href='<%= ResolveUrl("~/Content/Pages/Citizen/citizenschedulepickup.css") %>' rel="stylesheet" />
    
    <!-- Add Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    
    <!-- Add Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <div class="schedule-container">
        <!-- Page Header -->
        <div class="page-header-glass">
            <h1 class="page-title-glass">Schedule Pickups</h1>
            <p class="page-subtitle-glass">Manage and schedule your waste collection pickups</p>
            
            <!-- Quick Actions -->
            <div class="d-flex gap-3 mt-4">
                <asp:LinkButton ID="btnScheduleNew" runat="server" CssClass="action-btn primary"
                    OnClick="btnScheduleNew_Click">
                    <i class="fas fa-calendar-plus me-2"></i> Schedule New Pickup
                </asp:LinkButton>
                
                <asp:LinkButton ID="btnRefresh" runat="server" CssClass="action-btn secondary"
                    OnClick="btnRefresh_Click">
                    <i class="fas fa-sync-alt me-2"></i> Refresh
                </asp:LinkButton>
                
                <asp:LinkButton ID="btnExport" runat="server" CssClass="action-btn secondary"
                    OnClick="btnExport_Click">
                    <i class="fas fa-download me-2"></i> Export
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
                        <span>12%</span>
                    </div>
                </div>
                <div class="stat-content-glass">
                    <div class="stat-number-glass" id="statPending" runat="server">0</div>
                    <div class="stat-label-glass">Pending Pickups</div>
                </div>
            </div>
            
            <div class="stat-card-glass scheduled">
                <div class="d-flex align-items-start justify-content-between">
                    <div class="stat-icon-glass">
                        <i class="fas fa-calendar-check"></i>
                    </div>
                    <div class="stat-trend-glass trend-up">
                        <i class="fas fa-arrow-up"></i>
                        <span>8%</span>
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
                        <span>5%</span>
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
                        <span>15%</span>
                    </div>
                </div>
                <div class="stat-content-glass">
                    <div class="stat-number-glass" id="statCompleted" runat="server">0</div>
                    <div class="stat-label-glass">Completed</div>
                </div>
            </div>
        </div>

        <!-- Calendar Section -->
        <div class="calendar-container-glass">
            <div class="calendar-header-glass">
                <h3 class="calendar-title-glass">Pickup Calendar</h3>
                <div class="calendar-nav-glass">
                    <asp:LinkButton ID="btnPrevMonth" runat="server" CssClass="calendar-nav-btn"
                        OnClick="btnPrevMonth_Click">
                        <i class="fas fa-chevron-left"></i>
                    </asp:LinkButton>
                    
                    <div class="calendar-current-month">
                        <asp:Label ID="lblCurrentMonth" runat="server" Text="January 2024"></asp:Label>
                    </div>
                    
                    <asp:LinkButton ID="btnNextMonth" runat="server" CssClass="calendar-nav-btn"
                        OnClick="btnNextMonth_Click">
                        <i class="fas fa-chevron-right"></i>
                    </asp:LinkButton>
                    
                    <asp:Button ID="btnToday" runat="server" CssClass="action-btn secondary"
                        Text="Today" OnClick="btnToday_Click" />
                </div>
            </div>
            
            <div class="calendar-grid-glass">
                <!-- Day Headers -->
                <div class="calendar-day-header">Sun</div>
                <div class="calendar-day-header">Mon</div>
                <div class="calendar-day-header">Tue</div>
                <div class="calendar-day-header">Wed</div>
                <div class="calendar-day-header">Thu</div>
                <div class="calendar-day-header">Fri</div>
                <div class="calendar-day-header">Sat</div>
                
                <!-- Calendar Days will be generated dynamically -->
                <asp:Repeater ID="rptCalendarDays" runat="server">
                    <ItemTemplate>
                        <div class='calendar-day-cell <%# Eval("CssClass") %>' data-date='<%# Eval("Date") %>'>
                            <div class="calendar-day-number"><%# Eval("Day") %></div>
                            <div class="calendar-pickup-indicator">
                                <%# GetPickupDots(Eval("PickupCounts")) %>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
        </div>

        <!-- Pickup List -->
        <div class="pickup-list-container">
            <div class="pickup-list-header">
                <h3 class="pickup-list-title">Scheduled Pickups</h3>
                <div class="pickup-filters-glass">
                    <asp:DropDownList ID="ddlStatusFilter" runat="server" CssClass="filter-select-glass"
                        AutoPostBack="true" OnSelectedIndexChanged="ddlStatusFilter_SelectedIndexChanged">
                        <asp:ListItem Value="all">All Status</asp:ListItem>
                        <asp:ListItem Value="pending">Pending</asp:ListItem>
                        <asp:ListItem Value="scheduled">Scheduled</asp:ListItem>
                        <asp:ListItem Value="inprogress">In Progress</asp:ListItem>
                        <asp:ListItem Value="completed">Completed</asp:ListItem>
                        <asp:ListItem Value="cancelled">Cancelled</asp:ListItem>
                    </asp:DropDownList>
                    
                    <asp:DropDownList ID="ddlDateFilter" runat="server" CssClass="filter-select-glass"
                        AutoPostBack="true" OnSelectedIndexChanged="ddlDateFilter_SelectedIndexChanged">
                        <asp:ListItem Value="today">Today</asp:ListItem>
                        <asp:ListItem Value="week">This Week</asp:ListItem>
                        <asp:ListItem Value="month">This Month</asp:ListItem>
                        <asp:ListItem Value="upcoming">Upcoming</asp:ListItem>
                        <asp:ListItem Value="past">Past Pickups</asp:ListItem>
                    </asp:DropDownList>
                    
                    <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control-glass"
                        placeholder="Search pickups..." AutoPostBack="true"
                        OnTextChanged="txtSearch_TextChanged"></asp:TextBox>
                </div>
            </div>
            
            <!-- Pickup Cards -->
            <asp:Panel ID="pnlPickupCards" runat="server" CssClass="pickup-cards-grid">
                <asp:Repeater ID="rptPickups" runat="server" OnItemCommand="rptPickups_ItemCommand">
                    <ItemTemplate>
                        <div class='pickup-card-glass <%# Eval("StatusDisplay") %>'>
                            <div class="pickup-card-header">
                                <span class="pickup-id"><%# Eval("PickupId") %></span>
                                <span class='pickup-status-badge <%# Eval("StatusDisplay") %>'>
                                    <i class='<%# GetStatusIcon(Eval("StatusDisplay").ToString()) %> me-1'></i>
                                    <%# Eval("StatusDisplay") %>
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
                                        <span class="detail-value text-success"><%# Eval("Reward") %> XP</span>
                                    </div>
                                </div>
                                
                                <div class="pickup-address">
                                    <div class="address-label">
                                        <i class="fas fa-map-marker-alt"></i>
                                        Collection Address
                                    </div>
                                    <div class="address-text"><%# Eval("Address") %></div>
                                </div>
                            </div>
                            
                            <div class="pickup-card-footer">
                                <div class="pickup-time">
                                    <i class="fas fa-calendar-alt"></i>
                                    <span><%# Eval("ScheduledAt", "{0:MMM dd, yyyy}") %></span>
                                    <i class="fas fa-clock ms-3"></i>
                                    <span><%# Eval("ScheduledTime") %></span>
                                </div>
                                
                                <div class="pickup-actions">
                                    <asp:LinkButton ID="btnViewDetails" runat="server" 
                                        CommandName="ViewDetails" 
                                        CommandArgument='<%# Eval("PickupId") %>'
                                        CssClass="action-btn secondary" 
                                        ToolTip="View Details">
                                        <i class="fas fa-eye"></i>
                                    </asp:LinkButton>
                                    
                                    <asp:LinkButton ID="btnReschedule" runat="server" 
                                        CommandName="Reschedule" 
                                        CommandArgument='<%# Eval("PickupId") %>'
                                        CssClass="action-btn primary" 
                                        ToolTip="Reschedule">
                                        <i class="fas fa-calendar-edit"></i>
                                    </asp:LinkButton>
                                    
                                    <asp:LinkButton ID="btnCancel" runat="server" 
                                        CommandName="Cancel" 
                                        CommandArgument='<%# Eval("PickupId") %>'
                                        CssClass="action-btn danger" 
                                        ToolTip="Cancel Pickup"
                                        OnClientClick="return confirm('Are you sure you want to cancel this pickup?');">
                                        <i class="fas fa-times"></i>
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
                    <i class="fas fa-calendar-times"></i>
                </div>
                <h4 class="empty-state-title">No Pickups Found</h4>
                <p class="empty-state-message">
                    You don't have any scheduled pickups yet. Schedule your first pickup to get started!
                </p>
                <asp:LinkButton ID="btnScheduleFirst" runat="server" CssClass="action-btn primary"
                    OnClick="btnScheduleNew_Click">
                    <i class="fas fa-calendar-plus me-2"></i> Schedule Your First Pickup
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
                <asp:LinkButton ID="btnPrevPage" runat="server" CssClass="calendar-nav-btn"
                    OnClick="btnPrevPage_Click">
                    <i class="fas fa-chevron-left"></i>
                </asp:LinkButton>
                
                <div class="d-flex gap-1">
                    <asp:Repeater ID="rptPageNumbers" runat="server">
                        <ItemTemplate>
                            <asp:LinkButton ID="btnPage" runat="server" 
                                CssClass='<%# Convert.ToInt32(Eval("PageNumber")) == Convert.ToInt32(Eval("CurrentPage")) ? "calendar-nav-btn active" : "calendar-nav-btn" %>'
                                CommandArgument='<%# Eval("PageNumber") %>'
                                OnClick="btnPage_Click"
                                Text='<%# Eval("PageNumber") %>'></asp:LinkButton>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
                
                <asp:LinkButton ID="btnNextPage" runat="server" CssClass="calendar-nav-btn"
                    OnClick="btnNextPage_Click">
                    <i class="fas fa-chevron-right"></i>
                </asp:LinkButton>
            </div>
        </div>
    </div>
    
    <!-- Schedule Modal -->
    <div class="modal fade" id="scheduleModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered modal-lg">
            <div class="modal-content schedule-modal-glass">
                <div class="modal-header-glass">
                    <h5 class="modal-title-glass" id="modalTitle" runat="server">Schedule New Pickup</h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body-glass">
                    <div class="row">
                        <div class="col-md-6">
                            <div class="form-group-modal mb-4">
                                <label class="form-label-modal">Select Report</label>
                                <div class="input-group-modal">
                                    <i class="fas fa-file-alt input-icon-modal"></i>
                                    <asp:DropDownList ID="ddlReports" runat="server" CssClass="form-control-modal"
                                        AutoPostBack="true" OnSelectedIndexChanged="ddlReports_SelectedIndexChanged">
                                        <asp:ListItem Value="">-- Select Report --</asp:ListItem>
                                    </asp:DropDownList>
                                </div>
                            </div>
                            
                            <div class="form-group-modal mb-4">
                                <label class="form-label-modal">Pickup Date</label>
                                <div class="input-group-modal">
                                    <i class="fas fa-calendar-day input-icon-modal"></i>
                                    <asp:TextBox ID="txtPickupDate" runat="server" CssClass="form-control-modal"
                                        TextMode="Date" min='<%= DateTime.Now.ToString("yyyy-MM-dd") %>'></asp:TextBox>
                                </div>
                            </div>
                            
                            <div class="form-group-modal mb-4">
                                <label class="form-label-modal">Preferred Time</label>
                                <div class="input-group-modal">
                                    <i class="fas fa-clock input-icon-modal"></i>
                                    <asp:DropDownList ID="ddlTimeSlot" runat="server" CssClass="form-control-modal">
                                        <asp:ListItem Value="morning">Morning (8 AM - 12 PM)</asp:ListItem>
                                        <asp:ListItem Value="afternoon">Afternoon (12 PM - 4 PM)</asp:ListItem>
                                        <asp:ListItem Value="evening">Evening (4 PM - 8 PM)</asp:ListItem>
                                    </asp:DropDownList>
                                </div>
                            </div>
                        </div>
                        
                        <div class="col-md-6">
                            <div class="info-box-glass h-100">
                                <h6 class="mb-3"><i class="fas fa-info-circle me-2"></i>Selected Report Details</h6>
                                
                                <asp:Panel ID="pnlReportDetails" runat="server" Visible="false">
                                    <div class="detail-row">
                                        <span class="detail-label">Report ID:</span>
                                        <span class="detail-value" id="detailReportId" runat="server"></span>
                                    </div>
                                    <div class="detail-row">
                                        <span class="detail-label">Waste Type:</span>
                                        <span class="detail-value" id="detailWasteType" runat="server"></span>
                                    </div>
                                    <div class="detail-row">
                                        <span class="detail-label">Weight:</span>
                                        <span class="detail-value" id="detailWeight" runat="server"></span>
                                    </div>
                                    <div class="detail-row">
                                        <span class="detail-label">Address:</span>
                                        <span class="detail-value small" id="detailAddress" runat="server"></span>
                                    </div>
                                    <div class="detail-row">
                                        <span class="detail-label">Estimated Reward:</span>
                                        <span class="detail-value text-success" id="detailReward" runat="server"></span>
                                    </div>
                                </asp:Panel>
                                
                                <asp:Panel ID="pnlNoReport" runat="server" Visible="true">
                                    <p class="text-muted">Select a report to view details</p>
                                </asp:Panel>
                            </div>
                        </div>
                    </div>
                    
                    <div class="form-group-modal mb-4">
                        <label class="form-label-modal">Special Instructions (Optional)</label>
                        <div class="input-group-modal">
                            <i class="fas fa-clipboard input-icon-modal"></i>
                            <asp:TextBox ID="txtInstructions" runat="server" CssClass="form-control-modal"
                                TextMode="MultiLine" Rows="3"
                                placeholder="Any special instructions for the collector..."></asp:TextBox>
                        </div>
                    </div>
                </div>
                <div class="modal-footer-glass">
                    <button type="button" class="action-btn secondary" data-bs-dismiss="modal">Cancel</button>
                    <asp:Button ID="btnSubmitSchedule" runat="server" CssClass="action-btn primary"
                        Text="Schedule Pickup" OnClick="btnSubmitSchedule_Click" />
                </div>
            </div>
        </div>
    </div>
    
    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    
    <!-- JavaScript -->
    <script type="text/javascript">
        // Initialize calendar day clicks
        document.addEventListener('DOMContentLoaded', function () {
            // Calendar day click handler
            var calendarDays = document.querySelectorAll('.calendar-day-cell');
            calendarDays.forEach(function (day) {
                day.addEventListener('click', function () {
                    var date = this.getAttribute('data-date');
                    if (date) {
                        // Remove previous selection
                        calendarDays.forEach(function (d) {
                            d.classList.remove('selected');
                        });
                        // Add selection to clicked day
                        this.classList.add('selected');

                        // You can trigger filtering by date here
                        console.log('Selected date:', date);
                    }
                });
            });

            // Check if Bootstrap is loaded
            if (typeof bootstrap !== 'undefined') {
                var scheduleModalElement = document.getElementById('scheduleModal');
                if (scheduleModalElement) {
                    var scheduleModal = new bootstrap.Modal(scheduleModalElement);
                    window.showScheduleModal = function () {
                        scheduleModal.show();
                    };
                }
            } else {
                console.warn('Bootstrap not loaded. Modal functionality may not work.');
            }

            // Auto-refresh every 30 seconds for status updates
            setInterval(function () {
                // You can add auto-refresh logic here
            }, 30000);
        });

        // Show message function
        function showMessage(message, type) {
            // You can implement a toast notification system here
            console.log(type + ':', message);
            alert(message);
        }

        // Open schedule modal from button
        function openScheduleModal() {
            var modalElement = document.getElementById('scheduleModal');
            if (modalElement && typeof bootstrap !== 'undefined') {
                var modal = new bootstrap.Modal(modalElement);
                modal.show();
            } else if (modalElement) {
                // Fallback if Bootstrap not available
                modalElement.style.display = 'block';
                modalElement.classList.add('show');
            }
        }
    </script>
</asp:Content>