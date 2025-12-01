<%@ Page Title="Pickup Status" Language="C#" MasterPageFile="~/Pages/Citizen/Site.Master" AutoEventWireup="true" CodeFile="PickupStatus.aspx.cs" Inherits="SoorGreen.Admin.PickupStatus" %>
<%@ Import Namespace="System.Web.Optimization" %>
<asp:Content ID="Content3" ContentPlaceHolderID="HeadContent" runat="server">
    <%: Styles.Render("~/Content/citizenpickupstatus") %>
</asp:Content>
<asp:Content ID="Content4" ContentPlaceHolderID="ScriptsContent" runat="server">
    <%: Scripts.Render("~/bundles/citizenpickupstatus") %>
</asp:Content>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Pickup Status - SoorGreen Citizen
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <!-- Hidden Fields for Data Storage -->
    <asp:HiddenField ID="hfActivePickups" runat="server" />
    <asp:HiddenField ID="hfPickupHistory" runat="server" />
    <asp:HiddenField ID="hfStatsData" runat="server" />
    
   
    <div class="pickups-container">
        <br />
        <br />
        <br />
        
        <!-- STATISTICS -->
        <div class="stats-grid">
            <div class="stat-card" onclick="switchTab('active')">
                <div class="stat-icon">
                    <i class="fas fa-truck-loading"></i>
                </div>
                <div class="stat-value" id="totalPickups">0</div>
                <div class="stat-label">Total Pickups</div>
            </div>
            <div class="stat-card" onclick="switchTab('active')">
                <div class="stat-icon">
                    <i class="fas fa-spinner"></i>
                </div>
                <div class="stat-value" id="activePickups">0</div>
                <div class="stat-label">Active Pickups</div>
            </div>
            <div class="stat-card" onclick="switchTab('history')">
                <div class="stat-icon">
                    <i class="fas fa-check-circle"></i>
                </div>
                <div class="stat-value" id="completedPickups">0</div>
                <div class="stat-label">Completed</div>
            </div>
            <div class="stat-card" onclick="switchTab('history')">
                <div class="stat-icon">
                    <i class="fas fa-chart-line"></i>
                </div>
                <div class="stat-value" id="successRate">0%</div>
                <div class="stat-label">Success Rate</div>
            </div>
            <div class="stat-card">
                <div class="stat-icon">
                    <i class="fas fa-star"></i>
                </div>
                <div class="stat-value" id="totalXP">0 XP</div>
                <div class="stat-label">Total XP Earned</div>
            </div>
        </div>

        <!-- HEADER -->
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h1 style="color: #ffffff !important; margin: 0;">Pickup Status</h1>
                <p class="text-muted mb-0">Track and manage your waste collection requests</p>
            </div>
            <div>
                <asp:Button ID="btnRefresh" runat="server" Text="Refresh Data" 
                    CssClass="btn-primary me-2" OnClick="btnLoadData_Click" />
                <button type="button" class="btn-outline-light" onclick="window.location.href='SchedulePickup.aspx'">
                    <i class="fas fa-plus me-2"></i>Schedule New Pickup
                </button>
            </div>
        </div>

        <!-- TABS -->
        <div class="tabs mb-4" style="display: flex; gap: 0.5rem; border-bottom: 1px solid rgba(255, 255, 255, 0.1); padding-bottom: 0.5rem;">
            <button type="button" class="tab active" data-tab="active" style="background: rgba(255, 255, 255, 0.05); border: 1px solid rgba(255, 255, 255, 0.1); color: rgba(255, 255, 255, 0.7) !important; padding: 0.75rem 1.5rem; border-radius: 8px 8px 0 0; cursor: pointer; transition: all 0.3s ease; font-weight: 600;">
                Active Pickups
            </button>
            <button type="button" class="tab" data-tab="history" style="background: rgba(255, 255, 255, 0.05); border: 1px solid rgba(255, 255, 255, 0.1); color: rgba(255, 255, 255, 0.7) !important; padding: 0.75rem 1.5rem; border-radius: 8px 8px 0 0; cursor: pointer; transition: all 0.3s ease; font-weight: 600;">
                Pickup History
            </button>
        </div>

        <!-- ACTIVE PICKUPS TAB -->
        <div class="tab-content active" id="activeTab">
            <!-- FILTER CARD -->
            <div class="filter-card">
                <h5 class="mb-3" style="color: #ffffff !important;"><i class="fas fa-filter me-2"></i>Filter Pickups</h5>
                <div class="filter-group">
                    <div class="form-group search-box">
                        <label class="form-label">Search Pickups</label>
                        <div class="position-relative">
                            <i class="fas fa-search search-icon"></i>
                            <input type="text" class="form-control search-input" id="searchPickups" placeholder="Search by ID, waste type, or address...">
                        </div>
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label">Status</label>
                        <select class="form-control" id="statusFilter">
                            <option value="all">All Status</option>
                            <option value="requested">Requested</option>
                            <option value="scheduled">Scheduled</option>
                            <option value="assigned">Assigned</option>
                        </select>
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label">Date Range</label>
                        <select class="form-control" id="dateFilter">
                            <option value="all">All Time</option>
                            <option value="today">Today</option>
                            <option value="week">This Week</option>
                            <option value="month">This Month</option>
                        </select>
                    </div>
                    
                    <div class="form-group">
                        <button type="button" class="btn-primary" id="applyFiltersBtn" style="margin-top: 1.7rem;">
                            <i class="fas fa-filter me-2"></i>Apply Filters
                        </button>
                    </div>
                </div>
            </div>

            <!-- VIEW OPTIONS -->
            <div class="d-flex justify-content-between align-items-center mb-3">
                <div class="view-options">
                    <button type="button" class="view-btn active" data-view="grid">
                        <i class="fas fa-th me-2"></i>Grid View
                    </button>
                    <button type="button" class="view-btn" data-view="table">
                        <i class="fas fa-table me-2"></i>Table View
                    </button>
                </div>
                <div class="page-info" id="pageInfo">
                    Showing 0 pickups
                </div>
            </div>

            <!-- GRID VIEW -->
            <div id="gridView">
                <div class="pickups-grid" id="activePickupsGrid">
                    <div class="loading-spinner">
                        <i class="fas fa-spinner fa-spin"></i>
                        <p>Loading active pickups...</p>
                    </div>
                </div>
            </div>

            <!-- TABLE VIEW -->
            <div id="tableView" style="display: none;">
                <div class="table-responsive">
                    <table class="pickups-table" id="activePickupsTable">
                        <thead>
                            <tr>
                                <th>Pickup ID</th>
                                <th>Waste Type</th>
                                <th>Weight</th>
                                <th>Address</th>
                                <th>Scheduled Date</th>
                                <th>Collector</th>
                                <th>Status</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody id="activePickupsTableBody">
                            <tr>
                                <td colspan="8" class="text-center">Loading active pickups...</td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- PAGINATION -->
            <div class="pagination-container">
                <div class="page-info" id="paginationInfo">
                    Page 1 of 1
                </div>
                <nav>
                    <ul class="pagination mb-0" id="pagination">
                    </ul>
                </nav>
            </div>

            <!-- EMPTY STATE -->
            <div id="noActiveEmptyState" class="empty-state" style="display: none;">
                <div class="empty-state-icon">
                    <i class="fas fa-calendar-check"></i>
                </div>
                <h3 class="empty-state-title">No Active Pickups</h3>
                <p class="empty-state-description">You don't have any active pickups at the moment.</p>
                <button type="button" class="btn-primary" onclick="window.location.href='SchedulePickup.aspx'">
                    <i class="fas fa-plus me-2"></i>Schedule a Pickup
                </button>
            </div>
        </div>

        <!-- HISTORY TAB -->
        <div class="tab-content" id="historyTab" style="display: none;">
            <!-- VIEW OPTIONS -->
            <div class="d-flex justify-content-between align-items-center mb-3">
                <div class="view-options">
                    <button type="button" class="view-btn active" data-view="table" data-section="history">
                        <i class="fas fa-table me-2"></i>Table View
                    </button>
                    <button type="button" class="view-btn" data-view="grid" data-section="history">
                        <i class="fas fa-th me-2"></i>Grid View
                    </button>
                </div>
                <div class="page-info" id="historyPageInfo">
                    Showing 0 historical pickups
                </div>
            </div>

            <!-- TABLE VIEW -->
            <div id="historyTableView">
                <div class="table-responsive">
                    <table class="pickups-table" id="historyTable">
                        <thead>
                            <tr>
                                <th>Pickup ID</th>
                                <th>Waste Type</th>
                                <th>Weight</th>
                                <th>Address</th>
                                <th>Completed Date</th>
                                <th>Collector</th>
                                <th>XP Earned</th>
                                <th>Status</th>
                            </tr>
                        </thead>
                        <tbody id="historyTableBody">
                            <tr>
                                <td colspan="8" class="text-center">Loading pickup history...</td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- GRID VIEW -->
            <div id="historyGridView" style="display: none;">
                <div class="pickups-grid" id="historyPickupsGrid">
                    <div class="loading-spinner">
                        <i class="fas fa-spinner fa-spin"></i>
                        <p>Loading pickup history...</p>
                    </div>
                </div>
            </div>

            <!-- PAGINATION -->
            <div class="pagination-container">
                <div class="page-info" id="historyPaginationInfo">
                    Page 1 of 1
                </div>
                <nav>
                    <ul class="pagination mb-0" id="historyPagination">
                    </ul>
                </nav>
            </div>

            <!-- EMPTY STATE -->
            <div id="historyEmptyState" class="empty-state" style="display: none;">
                <div class="empty-state-icon">
                    <i class="fas fa-history"></i>
                </div>
                <h3 class="empty-state-title">No Pickup History</h3>
                <p class="empty-state-description">You haven't completed any pickups yet.</p>
            </div>
        </div>
    </div>

    <!-- PICKUP DETAILS MODAL -->
    <div class="modal-overlay" id="viewPickupModal">
        <div class="modal-content" style="max-width: 600px;">
            <div class="modal-header">
                <h3 class="modal-title">Pickup Details</h3>
                <button type="button" class="close-modal">&times;</button>
            </div>
            <div class="modal-body">
                <div class="pickup-details-container">
                    <div class="pickup-info-grid">
                        <div class="info-item">
                            <label>Pickup ID:</label>
                            <span id="viewPickupId">-</span>
                        </div>
                        <div class="info-item">
                            <label>Waste Type:</label>
                            <span id="viewWasteType">-</span>
                        </div>
                        <div class="info-item">
                            <label>Weight:</label>
                            <span id="viewWeight">-</span>
                        </div>
                        <div class="info-item">
                            <label>Status:</label>
                            <span id="viewStatus">-</span>
                        </div>
                        <div class="info-item">
                            <label>Scheduled Date:</label>
                            <span id="viewScheduledDate">-</span>
                        </div>
                        <div class="info-item">
                            <label>Collector:</label>
                            <span id="viewCollector">-</span>
                        </div>
                        <div class="info-item full-width">
                            <label>Address:</label>
                            <span id="viewAddress">-</span>
                        </div>
                        <div class="info-item full-width">
                            <label>XP Earned:</label>
                            <span id="viewXPEarned">-</span>
                        </div>
                        <div class="info-item">
                            <label>Created Date:</label>
                            <span id="viewCreatedDate">-</span>
                        </div>
                        <div class="info-item">
                            <label>Completed Date:</label>
                            <span id="viewCompletedDate">-</span>
                        </div>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-action" id="closePickupModalBtn">Close</button>
            </div>
        </div>
    </div>

    <!-- CANCEL CONFIRMATION MODAL -->
    <div class="modal-overlay" id="cancelPickupModal">
        <div class="modal-content" style="max-width: 500px;">
            <div class="modal-header">
                <h3 class="modal-title">Confirm Cancellation</h3>
                <button type="button" class="close-modal">&times;</button>
            </div>
            <div class="modal-body">
                <div class="text-center">
                    <i class="fas fa-exclamation-triangle fa-3x text-warning mb-3"></i>
                    <h4>Are you sure?</h4>
                    <p>You are about to cancel pickup: <strong id="cancelPickupId">-</strong></p>
                    <p class="text-muted">This action cannot be undone.</p>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-action" id="cancelCancelBtn" style="flex: 1;">Cancel</button>
                <button type="button" class="btn-primary" id="confirmCancelBtn" style="flex: 1;">Cancel Pickup</button>
            </div>
        </div>
    </div>

        
</asp:Content>