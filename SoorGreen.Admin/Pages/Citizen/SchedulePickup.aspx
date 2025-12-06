<%@ Page Title="Schedule Pickup" Language="C#" MasterPageFile="~/Pages/Citizen/Site.Master" 
    AutoEventWireup="true" CodeFile="SchedulePickup.aspx.cs" Inherits="SoorGreen.Admin.SchedulePickup" %>

<asp:Content ID="Content3" ContentPlaceHolderID="HeadContent" runat="server">
    <link href='<%= ResolveUrl("~/Content/Pages/Citizen/citizenschedulepickup.css") %>' rel="stylesheet" />
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/flatpickr/dist/flatpickr.min.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/flatpickr/dist/themes/material_blue.css">
</asp:Content>

<asp:Content ID="Content4" ContentPlaceHolderID="ScriptsContent" runat="server">
    <script src='<%= ResolveUrl("~/Scripts/Pages/Citizen/citizenschedulepickup.js") %>'></script>
    <script src="https://cdn.jsdelivr.net/npm/flatpickr"></script>
</asp:Content>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Schedule Pickup - SoorGreen Citizen
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <br />
    <br />
    <br />
    <!-- Hidden Fields for Data Storage -->
    <asp:HiddenField ID="hfSelectedWasteId" runat="server" />
    <asp:HiddenField ID="hfSelectedDate" runat="server" />
    <asp:HiddenField ID="hfSelectedTime" runat="server" />
    <asp:HiddenField ID="hfWasteData" runat="server" />
    <asp:HiddenField ID="hfUpcomingPickups" runat="server" />
    <asp:HiddenField ID="hfPickupHistory" runat="server" />
    <asp:HiddenField ID="hfStatsData" runat="server" />
    
    <div class="schedule-pickup-container">
        <!-- Header with Stats -->
        <div class="page-header-wrapper">
            <nav class="breadcrumb">
                <a href="Dashboard.aspx"><i class="fas fa-home"></i> Dashboard</a>
                <i class="fas fa-chevron-right"></i>
                <span class="active">Schedule Pickup</span>
            </nav>
            
            <div class="header-main">
                <div class="header-text">
                    <h1 class="page-title">
                        <i class="fas fa-calendar-alt"></i>
                        Schedule Waste Pickup
                    </h1>
                    <p class="page-subtitle">Manage your waste collection appointments and track pickups</p>
                </div>
                
                <div class="header-action">
                    <button class="btn-quick-schedule" onclick="quickSchedule()">
                        <i class="fas fa-bolt"></i>
                        Quick Schedule
                    </button>
                </div>
            </div>
            
            <!-- Stats Cards -->
            <div class="stats-grid">
                <div class="stat-card">
                    <div class="stat-icon">
                        <i class="fas fa-truck"></i>
                    </div>
                    <div class="stat-content">
                        <div class="stat-value" id="totalPickups">0</div>
                        <div class="stat-label">Total Pickups</div>
                    </div>
                </div>
                
                <div class="stat-card">
                    <div class="stat-icon">
                        <i class="fas fa-clock"></i>
                    </div>
                    <div class="stat-content">
                        <div class="stat-value" id="scheduledPickups">0</div>
                        <div class="stat-label">Scheduled</div>
                    </div>
                </div>
                
                <div class="stat-card">
                    <div class="stat-icon">
                        <i class="fas fa-check-circle"></i>
                    </div>
                    <div class="stat-content">
                        <div class="stat-value" id="completedPickups">0</div>
                        <div class="stat-label">Completed</div>
                    </div>
                </div>
                
                <div class="stat-card">
                    <div class="stat-icon">
                        <i class="fas fa-chart-line"></i>
                    </div>
                    <div class="stat-content">
                        <div class="stat-value" id="successRate">0%</div>
                        <div class="stat-label">Success Rate</div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Main Content Tabs -->
        <div class="tabs-container">
            <div class="tabs-nav">
                <button class="tab-btn active" data-tab="schedule">
                    <i class="fas fa-plus-circle"></i>
                    Schedule New
                </button>
                <button class="tab-btn" data-tab="upcoming">
                    <i class="fas fa-calendar"></i>
                    Upcoming
                    <span class="badge" id="upcomingCount">0</span>
                </button>
                <button class="tab-btn" data-tab="history">
                    <i class="fas fa-history"></i>
                    History
                </button>
            </div>
            
            <div class="tabs-content">
                <!-- Schedule New Tab -->
                <div class="tab-pane active" id="scheduleTab">
                    <div class="schedule-step-container">
                        <!-- Step 1: Select Waste -->
                        <div class="schedule-step active" id="step1">
                            <div class="step-header">
                                <h2><span class="step-number">01</span> Select Waste for Pickup</h2>
                                <p>Choose waste reports that need to be collected</p>
                            </div>
                            
                            <div class="waste-selection-container">
                                <div id="availableWasteList" class="waste-grid">
                                    <div class="loading-state">
                                        <i class="fas fa-spinner fa-spin"></i>
                                        <p>Loading available waste...</p>
                                    </div>
                                </div>
                                
                                <div id="noWasteEmptyState" class="empty-state" style="display: none;">
                                    <div class="empty-state-icon">
                                        <i class="fas fa-trash-alt"></i>
                                    </div>
                                    <h3>No Waste Available</h3>
                                    <p>You don't have any waste reports ready for pickup.</p>
                                    <button type="button" class="btn btn-primary" onclick="window.location.href='ReportWaste.aspx'">
                                        <i class="fas fa-plus"></i> Report New Waste
                                    </button>
                                </div>
                            </div>
                            
                            <div class="step-navigation">
                                <button type="button" class="btn btn-next" onclick="nextScheduleStep(2)">
                                    Next: Schedule Date & Time
                                    <i class="fas fa-arrow-right"></i>
                                </button>
                            </div>
                        </div>
                        
                        <!-- Step 2: Schedule Details -->
                        <div class="schedule-step" id="step2">
                            <div class="step-header">
                                <h2><span class="step-number">02</span> Schedule Details</h2>
                                <p>Select preferred date, time, and add any special instructions</p>
                            </div>
                            
                            <div class="schedule-details-container">
                                <div class="selected-waste-preview" id="selectedWastePreview">
                                    <!-- Will be populated by JavaScript -->
                                </div>
                                
                                <div class="schedule-form">
                                    <div class="form-row">
                                        <div class="form-group">
                                            <label><i class="fas fa-calendar-day"></i> Preferred Date</label>
                                            <div class="date-picker-container">
                                                <asp:TextBox ID="txtPickupDate" runat="server" CssClass="form-control date-picker" 
                                                    placeholder="Select date" ReadOnly="true" />
                                            </div>
                                            <small class="form-hint">Pickups available Monday-Friday, 8AM-5PM</small>
                                        </div>
                                        
                                        <div class="form-group">
                                            <label><i class="fas fa-clock"></i> Time Slot</label>
                                            <div class="time-slots-grid" id="timeSlotsGrid">
                                                <!-- Time slots will be populated by JavaScript -->
                                            </div>
                                        </div>
                                    </div>
                                    
                                    <div class="form-group">
                                        <label><i class="fas fa-comment-alt"></i> Special Instructions (Optional)</label>
                                        <asp:TextBox ID="txtInstructions" runat="server" CssClass="form-control" 
                                            placeholder="E.g., 'Call before arrival', 'Leave at back gate', 'Special handling required'"
                                            TextMode="MultiLine" Rows="4" />
                                    </div>
                                    
                                    <div class="form-group">
                                        <label><i class="fas fa-bell"></i> Notification Preferences</label>
                                        <div class="notification-preferences">
                                            <label class="checkbox-label">
                                                <input type="checkbox" id="chkEmailNotification" checked />
                                                <span class="checkmark"></span>
                                                Email reminder 1 hour before pickup
                                            </label>
                                            <label class="checkbox-label">
                                                <input type="checkbox" id="chkSMSNotification" />
                                                <span class="checkmark"></span>
                                                SMS notification when collector is en route
                                            </label>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            
                            <div class="step-navigation">
                                <button type="button" class="btn btn-back" onclick="prevScheduleStep(1)">
                                    <i class="fas fa-arrow-left"></i> Back
                                </button>
                                <asp:Button ID="btnSchedulePickup" runat="server" Text="Confirm & Schedule" 
                                    CssClass="btn btn-submit" OnClick="btnSchedulePickup_Click"
                                    OnClientClick="return validateSchedule();" />
                            </div>
                        </div>
                        
                        <!-- Step 3: Confirmation -->
                        <div class="schedule-step" id="step3">
                            <div class="step-header">
                                <h2><span class="step-number">03</span> Confirmation</h2>
                                <p>Review your pickup details before finalizing</p>
                            </div>
                            
                            <div class="confirmation-container">
                                <div class="confirmation-card success">
                                    <div class="confirmation-icon">
                                        <i class="fas fa-check-circle"></i>
                                    </div>
                                    <div class="confirmation-content">
                                        <h3>Pickup Scheduled Successfully!</h3>
                                        <p>Your waste pickup has been scheduled.</p>
                                        <div class="confirmation-details" id="confirmationDetails">
                                            <!-- Will be populated by JavaScript -->
                                        </div>
                                        <div class="confirmation-actions">
                                            <button type="button" class="btn btn-outline" onclick="scheduleAnother()">
                                                <i class="fas fa-plus"></i> Schedule Another
                                            </button>
                                            <button type="button" class="btn btn-primary" onclick="viewUpcoming()">
                                                <i class="fas fa-calendar"></i> View Upcoming Pickups
                                            </button>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                
                <!-- Upcoming Pickups Tab -->
                <div class="tab-pane" id="upcomingTab">
                    <div class="upcoming-container">
                        <div class="section-header">
                            <h2><i class="fas fa-calendar"></i> Upcoming Pickups</h2>
                            <div class="header-actions">
                                <button class="btn-refresh" onclick="refreshUpcoming()">
                                    <i class="fas fa-sync-alt"></i> Refresh
                                </button>
                            </div>
                        </div>
                        
                        <div class="upcoming-grid" id="upcomingGrid">
                            <div class="loading-state">
                                <i class="fas fa-spinner fa-spin"></i>
                                <p>Loading upcoming pickups...</p>
                            </div>
                        </div>
                        
                        <div id="upcomingEmptyState" class="empty-state" style="display: none;">
                            <div class="empty-state-icon">
                                <i class="fas fa-calendar-check"></i>
                            </div>
                            <h3>No Upcoming Pickups</h3>
                            <p>You don't have any scheduled pickups at the moment.</p>
                            <button type="button" class="btn btn-primary" onclick="switchTab('schedule')">
                                <i class="fas fa-plus"></i> Schedule a Pickup
                            </button>
                        </div>
                    </div>
                </div>
                
                <!-- History Tab -->
                <div class="tab-pane" id="historyTab">
                    <div class="history-container">
                        <div class="section-header">
                            <h2><i class="fas fa-history"></i> Pickup History</h2>
                            <div class="filter-controls">
                                <select id="filterTimeframe" class="form-control" onchange="filterHistory()">
                                    <option value="all">All Time</option>
                                    <option value="month">Last Month</option>
                                    <option value="week">Last Week</option>
                                    <option value="today">Today</option>
                                </select>
                                <select id="filterStatus" class="form-control" onchange="filterHistory()">
                                    <option value="all">All Status</option>
                                    <option value="completed">Completed</option>
                                    <option value="cancelled">Cancelled</option>
                                </select>
                            </div>
                        </div>
                        
                        <div class="history-table-container">
                            <table class="history-table">
                                <thead>
                                    <tr>
                                        <th>Date</th>
                                        <th>Waste Type</th>
                                        <th>Weight</th>
                                        <th>Collector</th>
                                        <th>XP Earned</th>
                                        <th>Status</th>
                                        <th>Actions</th>
                                    </tr>
                                </thead>
                                <tbody id="historyTableBody">
                                    <tr>
                                        <td colspan="7" class="text-center">Loading pickup history...</td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                        
                        <div id="historyEmptyState" class="empty-state" style="display: none;">
                            <div class="empty-state-icon">
                                <i class="fas fa-history"></i>
                            </div>
                            <h3>No Pickup History</h3>
                            <p>You haven't completed any pickups yet.</p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</asp:Content>