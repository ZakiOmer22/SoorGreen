<%@ Page Title="My Reports" Language="C#" MasterPageFile="~/Pages/Citizen/Site.Master" 
    AutoEventWireup="true" CodeFile="MyReports.aspx.cs" Inherits="SoorGreen.Admin.MyReports" %>

<asp:Content ID="Content3" ContentPlaceHolderID="HeadContent" runat="server">
    <link href='<%= ResolveUrl("~/Content/Pages/Citizen/citizenmyreports.css") %>' rel="stylesheet" />
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/flatpickr/dist/flatpickr.min.css">
</asp:Content>

<asp:Content ID="Content4" ContentPlaceHolderID="ScriptsContent" runat="server">
    <script src='<%= ResolveUrl("~/Scripts/Pages/Citizen/citizenmyreports.js") %>'></script>
    <script src="https://cdn.jsdelivr.net/npm/flatpickr"></script>
</asp:Content>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    My Waste Reports - SoorGreen Citizen
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <br />
    <br />
    <br />
    <!-- Hidden Fields -->
    <asp:HiddenField ID="hfAllReports" runat="server" />
    <asp:HiddenField ID="hfStats" runat="server" />
    
    <div class="my-reports-container">
        <!-- Header -->
        <div class="page-header-wrapper">
            <nav class="breadcrumb">
                <a href="Dashboard.aspx"><i class="fas fa-home"></i> Dashboard</a>
                <i class="fas fa-chevron-right"></i>
                <span class="active">My Reports</span>
            </nav>
            
            <div class="header-main">
                <div class="header-text">
                    <h1 class="page-title">
                        <i class="fas fa-clipboard-list"></i>
                        My Waste Reports
                    </h1>
                    <p class="page-subtitle">Track, manage, and analyze your waste collection reports</p>
                </div>
                
                <div class="header-action">
                    <button class="btn-export" onclick="exportReports()">
                        <i class="fas fa-file-export"></i>
                        Export Data
                    </button>
                    <button class="btn-new-report" onclick="window.location.href='ReportWaste.aspx'">
                        <i class="fas fa-plus"></i>
                        New Report
                    </button>
                </div>
            </div>
            
            <!-- Stats Grid -->
            <div class="stats-grid">
                <div class="stat-card">
                    <div class="stat-icon">
                        <i class="fas fa-file-alt"></i>
                    </div>
                    <div class="stat-content">
                        <div class="stat-value" id="totalReports">0</div>
                        <div class="stat-label">Total Reports</div>
                    </div>
                </div>
                
                <div class="stat-card">
                    <div class="stat-icon">
                        <i class="fas fa-clock"></i>
                    </div>
                    <div class="stat-content">
                        <div class="stat-value" id="pendingReports">0</div>
                        <div class="stat-label">Pending</div>
                    </div>
                </div>
                
                <div class="stat-card">
                    <div class="stat-icon">
                        <i class="fas fa-check-circle"></i>
                    </div>
                    <div class="stat-content">
                        <div class="stat-value" id="completedReports">0</div>
                        <div class="stat-label">Completed</div>
                    </div>
                </div>
                
                <div class="stat-card">
                    <div class="stat-icon">
                        <i class="fas fa-trophy"></i>
                    </div>
                    <div class="stat-content">
                        <div class="stat-value" id="totalRewards">0</div>
                        <div class="stat-label">Total XP Earned</div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Filters Section -->
        <div class="filters-container">
            <div class="filters-header">
                <h3><i class="fas fa-filter"></i> Filter Reports</h3>
                <button class="btn-clear-filters" onclick="clearFilters()">
                    <i class="fas fa-times"></i> Clear Filters
                </button>
            </div>
            
            <div class="filters-grid">
                <div class="filter-group">
                    <label><i class="fas fa-search"></i> Search</label>
                    <div class="search-box">
                        <input type="text" id="searchReports" placeholder="Search by ID, location, or description..." />
                        <i class="fas fa-search"></i>
                    </div>
                </div>
                
                <div class="filter-group">
                    <label><i class="fas fa-tag"></i> Status</label>
                    <select id="statusFilter" class="form-control">
                        <option value="all">All Status</option>
                        <option value="Pending">Pending</option>
                        <option value="Scheduled">Scheduled</option>
                        <option value="In Progress">In Progress</option>
                        <option value="Completed">Completed</option>
                        <option value="Cancelled">Cancelled</option>
                    </select>
                </div>
                
                <div class="filter-group">
                    <label><i class="fas fa-trash-alt"></i> Waste Type</label>
                    <select id="wasteTypeFilter" class="form-control">
                        <option value="all">All Types</option>
                        <option value="Plastic">Plastic</option>
                        <option value="Paper">Paper</option>
                        <option value="Glass">Glass</option>
                        <option value="Metal">Metal</option>
                        <option value="E-Waste">E-Waste</option>
                        <option value="Organic">Organic</option>
                    </select>
                </div>
                
                <div class="filter-group">
                    <label><i class="fas fa-calendar"></i> Date Range</label>
                    <div class="date-range-picker">
                        <input type="text" id="dateRangeFilter" placeholder="Select date range..." readonly />
                        <i class="fas fa-calendar-alt"></i>
                    </div>
                </div>
            </div>
            
            <div class="filters-actions">
                <button class="btn-apply-filters" onclick="applyFilters()">
                    <i class="fas fa-check"></i> Apply Filters
                </button>
            </div>
        </div>

        <!-- Reports Section -->
        <div class="reports-section">
            <div class="section-header">
                <h2><i class="fas fa-list"></i> Reports List</h2>
                <div class="section-actions">
                    <div class="view-toggle">
                        <button class="view-btn active" data-view="grid" onclick="switchView('grid')">
                            <i class="fas fa-th-large"></i>
                        </button>
                        <button class="view-btn" data-view="list" onclick="switchView('list')">
                            <i class="fas fa-list"></i>
                        </button>
                    </div>
                    <select id="sortBy" class="form-control" onchange="sortReports()">
                        <option value="newest">Newest First</option>
                        <option value="oldest">Oldest First</option>
                        <option value="weight-high">Weight: High to Low</option>
                        <option value="weight-low">Weight: Low to High</option>
                        <option value="xp-high">XP: High to Low</option>
                        <option value="xp-low">XP: Low to High</option>
                    </select>
                </div>
            </div>
            
            <!-- Grid View -->
            <div class="reports-grid" id="reportsGridView">
                <div class="loading-state">
                    <i class="fas fa-spinner fa-spin"></i>
                    <p>Loading reports...</p>
                </div>
            </div>
            
            <!-- List View -->
            <div class="reports-table-container" id="reportsListView" style="display: none;">
                <table class="reports-table">
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
                        <tr>
                            <td colspan="8" class="text-center">Loading reports...</td>
                        </tr>
                    </tbody>
                </table>
            </div>
            
            <!-- Empty State -->
            <div id="reportsEmptyState" class="empty-state" style="display: none;">
                <div class="empty-state-icon">
                    <i class="fas fa-clipboard-list"></i>
                </div>
                <h3>No Reports Found</h3>
                <p>You haven't submitted any waste reports yet.</p>
                <button class="btn btn-primary" onclick="window.location.href='ReportWaste.aspx'">
                    <i class="fas fa-plus"></i> Submit Your First Report
                </button>
            </div>
            
            <!-- Pagination -->
            <div class="pagination-container">
                <div class="pagination-info" id="paginationInfo">Showing 0 reports</div>
                <div class="pagination-controls">
                    <button class="btn-pagination" id="prevPageBtn" onclick="prevPage()" disabled>
                        <i class="fas fa-chevron-left"></i> Previous
                    </button>
                    <div class="page-numbers" id="pageNumbers"></div>
                    <button class="btn-pagination" id="nextPageBtn" onclick="nextPage()" disabled>
                        Next <i class="fas fa-chevron-right"></i>
                    </button>
                </div>
            </div>
        </div>
    </div>

    <!-- Report Details Modal -->
    <div class="modal-overlay" id="reportDetailsModal">
        <div class="modal-content">
            <div class="modal-header">
                <h2><i class="fas fa-file-alt"></i> Report Details</h2>
                <button class="btn-close-modal" onclick="closeModal()">
                    <i class="fas fa-times"></i>
                </button>
            </div>
            
            <div class="modal-body">
                <div class="report-details" id="reportDetailsContent">
                    <!-- Will be populated by JavaScript -->
                </div>
                
                <div class="modal-actions">
                    <button class="btn btn-outline" onclick="closeModal()">
                        <i class="fas fa-times"></i> Close
                    </button>
                    <button class="btn btn-primary" id="editReportBtn" onclick="editReport()">
                        <i class="fas fa-edit"></i> Edit Report
                    </button>
                </div>
            </div>
        </div>
    </div>

    <!-- Delete Confirmation Modal -->
    <div class="modal-overlay" id="deleteConfirmationModal">
        <div class="modal-content">
            <div class="modal-header">
                <h2><i class="fas fa-exclamation-triangle"></i> Confirm Deletion</h2>
                <button class="btn-close-modal" onclick="closeDeleteModal()">
                    <i class="fas fa-times"></i>
                </button>
            </div>
            
            <div class="modal-body">
                <div class="delete-warning">
                    <i class="fas fa-trash-alt"></i>
                    <h3>Delete Report?</h3>
                    <p id="deleteMessage">Are you sure you want to delete this report? This action cannot be undone.</p>
                </div>
                
                <div class="modal-actions">
                    <button class="btn btn-outline" onclick="closeDeleteModal()">
                        <i class="fas fa-times"></i> Cancel
                    </button>
                    <button class="btn btn-danger" id="confirmDeleteBtn" onclick="deleteReport()">
                        <i class="fas fa-trash"></i> Delete Report
                    </button>
                </div>
            </div>
        </div>
    </div>

    <!-- Export Modal -->
    <div class="modal-overlay" id="exportModal">
        <div class="modal-content">
            <div class="modal-header">
                <h2><i class="fas fa-file-export"></i> Export Reports</h2>
                <button class="btn-close-modal" onclick="closeExportModal()">
                    <i class="fas fa-times"></i>
                </button>
            </div>
            
            <div class="modal-body">
                <div class="export-options">
                    <div class="export-option">
                        <input type="radio" id="exportPdf" name="exportFormat" value="pdf" checked />
                        <label for="exportPdf">
                            <i class="fas fa-file-pdf"></i>
                            <div>
                                <h4>PDF Document</h4>
                                <p>Best for printing and sharing</p>
                            </div>
                        </label>
                    </div>
                    
                    <div class="export-option">
                        <input type="radio" id="exportExcel" name="exportFormat" value="excel" />
                        <label for="exportExcel">
                            <i class="fas fa-file-excel"></i>
                            <div>
                                <h4>Excel Spreadsheet</h4>
                                <p>Best for data analysis</p>
                            </div>
                        </label>
                    </div>
                    
                    <div class="export-option">
                        <input type="radio" id="exportCsv" name="exportFormat" value="csv" />
                        <label for="exportCsv">
                            <i class="fas fa-file-csv"></i>
                            <div>
                                <h4>CSV File</h4>
                                <p>Best for importing to other systems</p>
                            </div>
                        </label>
                    </div>
                </div>
                
                <div class="export-settings">
                    <div class="form-group">
                        <label><i class="fas fa-calendar"></i> Date Range</label>
                        <select id="exportDateRange" class="form-control">
                            <option value="all">All Reports</option>
                            <option value="filtered">Current Filter</option>
                            <option value="today">Today</option>
                            <option value="week">This Week</option>
                            <option value="month">This Month</option>
                        </select>
                    </div>
                    
                    <div class="form-group">
                        <label><i class="fas fa-columns"></i> Include Columns</label>
                        <div class="checkbox-group">
                            <label class="checkbox-label">
                                <input type="checkbox" id="includeBasic" checked />
                                <span class="checkmark"></span>
                                Basic Information
                            </label>
                            <label class="checkbox-label">
                                <input type="checkbox" id="includeDetails" checked />
                                <span class="checkmark"></span>
                                Detailed Information
                            </label>
                            <label class="checkbox-label">
                                <input type="checkbox" id="includeStats" />
                                <span class="checkmark"></span>
                                Statistics Summary
                            </label>
                        </div>
                    </div>
                </div>
                
                <div class="modal-actions">
                    <button class="btn btn-outline" onclick="closeExportModal()">
                        <i class="fas fa-times"></i> Cancel
                    </button>
                    <button class="btn btn-primary" onclick="generateExport()">
                        <i class="fas fa-download"></i> Export
                    </button>
                </div>
            </div>
        </div>
    </div>
</asp:Content>