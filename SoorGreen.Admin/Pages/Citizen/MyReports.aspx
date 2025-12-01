<%@ Page Title="My Reports" Language="C#" MasterPageFile="~/Pages/Citizen/Site.Master" AutoEventWireup="true" CodeFile="MyReports.aspx.cs" Inherits="SoorGreen.Admin.MyReports" %>
<%@ Import Namespace="System.Web.Optimization" %>
<asp:Content ID="Content3" ContentPlaceHolderID="HeadContent" runat="server">
    <%: Styles.Render("~/Content/citizenmyreports") %>
</asp:Content>
<asp:Content ID="Content4" ContentPlaceHolderID="ScriptsContent" runat="server">
    <%: Scripts.Render("~/bundles/citizenmyreports") %>
</asp:Content>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    My Reports - SoorGreen Citizen
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <div class="reports-container">
        <br />
        <br />
        <br />
        
        <!-- Statistics Cards -->
        <div class="stats-cards">
            <div class="stat-card">
                <div class="stat-value" id="totalReports">0</div>
                <div class="stat-label">Total Reports</div>
            </div>
            <div class="stat-card">
                <div class="stat-value" id="pendingReports">0</div>
                <div class="stat-label">Pending</div>
            </div>
            <div class="stat-card">
                <div class="stat-value" id="completedReports">0</div>
                <div class="stat-label">Completed</div>
            </div>
            <div class="stat-card">
                <div class="stat-value" id="totalRewards">0</div>
                <div class="stat-label">Total XP Earned</div>
            </div>
        </div>

        <!-- Page Header -->
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h1 style="color: #ffffff !important; margin: 0;">My Waste Reports</h1>
                <p class="text-muted mb-0">Track and manage your waste collection reports</p>
            </div>
            <div>
                <button type="button" class="btn-primary me-2" id="generateReportBtn">
                    <i class="fas fa-chart-bar me-2"></i>Generate Report
                </button>
                <button type="button" class="btn-primary" onclick="window.location.href='ReportWaste.aspx'">
                    <i class="fas fa-plus me-2"></i>New Report
                </button>
            </div>
        </div>

        <!-- Filters -->
        <div class="filter-group">
            <div class="form-group search-box">
                <label class="form-label">Search Reports</label>
                <div class="position-relative">
                    <i class="fas fa-search search-icon"></i>
                    <input type="text" class="form-control search-input" id="searchReports" placeholder="Search by waste type or location...">
                </div>
            </div>
            
            <div class="form-group">
                <label class="form-label">Status</label>
                <select class="form-control" id="statusFilter">
                    <option value="all">All Status</option>
                    <option value="pending">Pending</option>
                    <option value="scheduled">Scheduled</option>
                    <option value="completed">Completed</option>
                    <option value="cancelled">Cancelled</option>
                </select>
            </div>
            
            <div class="form-group">
                <label class="form-label">Waste Type</label>
                <select class="form-control" id="wasteTypeFilter">
                    <option value="all">All Types</option>
                    <option value="plastic">Plastic</option>
                    <option value="paper">Paper</option>
                    <option value="glass">Glass</option>
                    <option value="metal">Metal</option>
                    <option value="ewaste">E-Waste</option>
                    <option value="organic">Organic</option>
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

        <!-- Reports Table -->
        <div class="table-responsive">
            <table class="reports-table" id="reportsTable">
                <thead>
                    <tr>
                        <th>Report ID</th>
                        <th>Waste Type</th>
                        <th>Weight</th>
                        <th>Location</th>
                        <th>Status</th>
                        <th>Reported Date</th>
                        <th>XP Earned</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody id="reportsTableBody">
                    <!-- Reports will be loaded here -->
                </tbody>
            </table>
        </div>
        
        <!-- Empty State -->
        <div id="reportsEmptyState" class="empty-state" style="display: none;">
            <div class="empty-state-icon">
                <i class="fas fa-clipboard-list"></i>
            </div>
            <h3 class="empty-state-title">No Reports Found</h3>
            <p class="empty-state-description">You haven't submitted any waste reports yet.</p>
            <button type="button" class="btn-primary" onclick="window.location.href='ReportWaste.aspx'">
                <i class="fas fa-plus me-2"></i>Submit Your First Report
            </button>
        </div>

        <!-- Pagination -->
        <div class="pagination-container">
            <div class="page-info" id="pageInfo">Showing 0 reports</div>
            <div>
                <button type="button" class="btn-action me-1" id="prevPageBtn" disabled>
                    <i class="fas fa-chevron-left"></i> Previous
                </button>
                <button type="button" class="btn-action" id="nextPageBtn" disabled>
                    Next <i class="fas fa-chevron-right"></i>
                </button>
            </div>
        </div>
    </div>

    <!-- View Report Details Modal -->
    <div class="modal-overlay" id="viewReportModal">
        <div class="modal-content" style="max-width: 600px;">
            <div class="modal-header">
                <h3 class="modal-title">Report Details</h3>
                <button type="button" class="close-modal">&times;</button>
            </div>
            <div class="modal-body">
                <div class="info-grid">
                    <div class="info-item">
                        <label>Report ID:</label>
                        <span id="viewReportId">-</span>
                    </div>
                    <div class="info-item">
                        <label>Status:</label>
                        <span id="viewReportStatus">-</span>
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
                        <label>Location:</label>
                        <span id="viewLocation">-</span>
                    </div>
                    <div class="info-item">
                        <label>Reported Date:</label>
                        <span id="viewReportedDate">-</span>
                    </div>
                    <div class="info-item">
                        <label>XP Earned:</label>
                        <span id="viewXPEarned">-</span>
                    </div>
                    <div class="info-item full-width">
                        <label>Description:</label>
                        <span id="viewDescription">-</span>
                    </div>
                    <div class="info-item full-width">
                        <label>Collection Instructions:</label>
                        <span id="viewInstructions">-</span>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-action" id="closeReportModalBtn">Close</button>
            </div>
        </div>
    </div>

    <!-- Delete Confirmation Modal -->
    <div class="modal-overlay" id="deleteConfirmationModal">
        <div class="modal-content" style="max-width: 500px;">
            <div class="modal-header">
                <h3 class="modal-title">Confirm Deletion</h3>
                <button type="button" class="close-modal">&times;</button>
            </div>
            <div class="modal-body">
                <p style="color: rgba(255, 255, 255, 0.8) !important;" id="deleteModalMessage">
                    Are you sure you want to delete this report? This action cannot be undone.
                </p>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-action" id="cancelDeleteBtn">Cancel</button>
                <button type="button" class="btn-action btn-delete" id="confirmDeleteBtn">Delete Report</button>
            </div>
        </div>
    </div>

    
</asp:Content>