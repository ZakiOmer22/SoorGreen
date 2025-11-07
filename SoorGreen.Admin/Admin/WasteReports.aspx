<%@ Page Title="Waste Reports" Language="C#" MasterPageFile="~/Admin/Site.master" AutoEventWireup="true" CodeFile="WasteReports.aspx.cs" Inherits="SoorGreen.Admin.Admin.WasteReports" %>
<%@ Register Assembly="System.Web.Extensions, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35" Namespace="System.Web.UI" TagPrefix="asp" %>

<asp:Content ID="PageTitle" ContentPlaceHolderID="PageTitle" runat="server">
    Waste Reports Management
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <asp:ScriptManager ID="ScriptManager1" runat="server" EnablePageMethods="true"></asp:ScriptManager>
    
    <style>
        .waste-reports-container {
            margin-bottom: 2rem;
        }
        
        .filter-card {
            background: rgba(255, 255, 255, 0.05);
            backdrop-filter: blur(20px);
            border: 1px solid rgba(255, 255, 255, 0.1);
            border-radius: 15px;
            padding: 1.5rem;
            margin-bottom: 2rem;
        }
        
        .report-card {
            background: rgba(255, 255, 255, 0.05);
            backdrop-filter: blur(20px);
            border: 1px solid rgba(255, 255, 255, 0.1);
            border-radius: 15px;
            padding: 1.5rem;
            margin-bottom: 1.5rem;
            transition: all 0.3s ease;
        }
        
        .report-card:hover {
            transform: translateY(-3px);
            border-color: rgba(0, 212, 170, 0.3);
        }
        
        .report-header {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            margin-bottom: 1rem;
        }
        
        .report-info {
            flex: 1;
        }
        
        .report-title {
            font-size: 1.3rem;
            font-weight: 700;
            color: #ffffff !important;
            margin: 0 0 0.5rem 0;
        }
        
        .report-address {
            color: rgba(255, 255, 255, 0.8) !important;
            margin: 0 0 0.5rem 0;
        }
        
        .report-actions {
            display: flex;
            gap: 0.5rem;
        }
        
        .btn-action {
            background: rgba(255, 255, 255, 0.1);
            border: 1px solid rgba(255, 255, 255, 0.2);
            color: white;
            padding: 0.5rem 0.8rem;
            border-radius: 6px;
            cursor: pointer;
            transition: all 0.3s ease;
            font-size: 0.8rem;
        }
        
        .btn-action:hover {
            background: rgba(255, 255, 255, 0.2);
        }
        
        .btn-view {
            background: rgba(25, 135, 84, 0.2);
            border-color: rgba(25, 135, 84, 0.3);
        }
        
        .btn-delete {
            background: rgba(220, 53, 69, 0.2);
            border-color: rgba(220, 53, 69, 0.3);
        }
        
        .btn-create-pickup {
            background: rgba(32, 201, 151, 0.2);
            border-color: rgba(32, 201, 151, 0.3);
        }
        
        .report-details {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
            gap: 1rem;
            margin-bottom: 1rem;
        }
        
        .detail-item {
            text-align: center;
            padding: 0.8rem;
            background: rgba(255, 255, 255, 0.03);
            border-radius: 8px;
            border: 1px solid rgba(255, 255, 255, 0.05);
        }
        
        .detail-value {
            font-size: 1.2rem;
            font-weight: 800;
            color: #ffffff !important;
            margin-bottom: 0.3rem;
        }
        
        .detail-label {
            color: rgba(255, 255, 255, 0.6);
            font-size: 0.75rem;
            font-weight: 600;
        }
        
        .report-meta {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding-top: 1rem;
            border-top: 1px solid rgba(255, 255, 255, 0.1);
        }
        
        .report-status {
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }
        
        .status-badge {
            padding: 0.3rem 0.8rem;
            border-radius: 20px;
            font-size: 0.75rem;
            font-weight: 600;
        }
        
        .status-reported {
            background: rgba(13, 110, 253, 0.2);
            color: #0d6efd;
            border: 1px solid rgba(13, 110, 253, 0.3);
        }
        
        .status-pickup-created {
            background: rgba(32, 201, 151, 0.2);
            color: #20c997;
            border: 1px solid rgba(32, 201, 151, 0.3);
        }
        
        .status-collected {
            background: rgba(25, 135, 84, 0.2);
            color: #198754;
            border: 1px solid rgba(25, 135, 84, 0.3);
        }
        
        .table-responsive {
            border-radius: 10px;
            overflow: hidden;
        }
        
        .reports-table {
            width: 100%;
            background: rgba(255, 255, 255, 0.02);
            border-collapse: collapse;
        }
        
        .reports-table th {
            background: rgba(255, 255, 255, 0.1);
            color: #ffffff !important;
            font-weight: 600;
            padding: 1rem;
            text-align: left;
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
        }
        
        .reports-table td {
            padding: 1rem;
            border-bottom: 1px solid rgba(255, 255, 255, 0.05);
            color: rgba(255, 255, 255, 0.8) !important;
        }
        
        .reports-table tr:hover {
            background: rgba(255, 255, 255, 0.03);
        }
        
        .user-avatar {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-weight: 600;
            font-size: 0.9rem;
        }
        
        .filter-group {
            display: flex;
            gap: 1rem;
            align-items: flex-end;
            flex-wrap: wrap;
        }
        
        .form-group {
            flex: 1;
            min-width: 200px;
        }
        
        .form-label {
            color: rgba(255, 255, 255, 0.8) !important;
            font-weight: 600;
            margin-bottom: 0.5rem;
            display: block;
        }
        
        .form-control {
            background: rgba(255, 255, 255, 0.1);
            border: 1px solid rgba(255, 255, 255, 0.2);
            border-radius: 8px;
            color: white !important;
            padding: 0.75rem;
            width: 100%;
            transition: all 0.3s ease;
        }
        
        .form-control:focus {
            outline: none;
            border-color: var(--primary);
            background: rgba(255, 255, 255, 0.15);
        }
        
        .btn-primary {
            background: linear-gradient(135deg, #0d6efd, #0dcaf0);
            border: none;
            color: white;
            padding: 0.75rem 1.5rem;
            border-radius: 8px;
            cursor: pointer;
            transition: all 0.3s ease;
            font-weight: 600;
        }
        
        .btn-primary:hover {
            background: linear-gradient(135deg, #0b5ed7, #0baccc);
            transform: translateY(-2px);
        }
        
        .btn-add {
            background: linear-gradient(135deg, #198754, #20c997);
            border: none;
            color: white;
            padding: 0.75rem 1.5rem;
            border-radius: 8px;
            cursor: pointer;
            transition: all 0.3s ease;
            font-weight: 600;
        }
        
        .btn-add:hover {
            background: linear-gradient(135deg, #157347, #1aa179);
            transform: translateY(-2px);
        }
        
        .search-box {
            position: relative;
            flex: 2;
        }
        
        .search-icon {
            position: absolute;
            left: 0.75rem;
            top: 50%;
            transform: translateY(-50%);
            color: rgba(255, 255, 255, 0.5) !important;
        }
        
        .search-input {
            padding-left: 2.5rem;
        }
        
        .view-options {
            display: flex;
            gap: 0.5rem;
            margin-bottom: 1rem;
        }
        
        .view-btn {
            background: rgba(255, 255, 255, 0.05);
            border: 1px solid rgba(255, 255, 255, 0.1);
            color: rgba(255, 255, 255, 0.7) !important;
            padding: 0.5rem 1rem;
            border-radius: 6px;
            cursor: pointer;
            transition: all 0.3s ease;
        }
        
        .view-btn.active {
            background: rgba(255, 255, 255, 0.1);
            border-color: var(--primary);
            color: #ffffff !important;
        }
        
        .reports-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(400px, 1fr));
            gap: 1.5rem;
        }
        
        .pagination-container {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-top: 2rem;
        }
        
        .page-info {
            color: rgba(255, 255, 255, 0.7) !important;
            font-size: 0.9rem;
        }
        
        /* Modal Styles */
        .modal-overlay {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0, 0, 0, 0.8);
            backdrop-filter: blur(5px);
            z-index: 1000;
        }
        
        .modal-content {
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            background: rgba(255, 255, 255, 0.1);
            backdrop-filter: blur(20px);
            border: 1px solid rgba(255, 255, 255, 0.2);
            border-radius: 15px;
            padding: 2rem;
            width: 90%;
            max-width: 700px;
            max-height: 90vh;
            overflow-y: auto;
        }
        
        .modal-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 1.5rem;
        }
        
        .modal-title {
            font-size: 1.5rem;
            font-weight: 700;
            color: #ffffff !important;
            margin: 0;
        }
        
        .close-modal {
            background: none;
            border: none;
            color: rgba(255, 255, 255, 0.7) !important;
            font-size: 1.5rem;
            cursor: pointer;
            padding: 0;
        }
        
        .form-row {
            display: flex;
            gap: 1rem;
            margin-bottom: 1rem;
        }
        
        .form-half {
            flex: 1;
        }
        
        /* Report Details Modal Styles */
        .report-details-container {
            display: flex;
            flex-direction: column;
            gap: 1.5rem;
        }
        
        .report-info-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 1rem;
            width: 100%;
        }
        
        .info-item {
            display: flex;
            flex-direction: column;
            gap: 0.25rem;
        }
        
        .info-item label {
            font-weight: 600;
            color: rgba(255, 255, 255, 0.7);
            font-size: 0.9rem;
        }
        
        .info-item span {
            color: #ffffff;
            font-size: 1rem;
        }
        
        .info-item.full-width {
            grid-column: 1 / -1;
        }
        
        .modal-body {
            padding: 0 0 1.5rem 0;
        }
        
        .modal-footer {
            display: flex;
            gap: 1rem;
            padding-top: 1.5rem;
            border-top: 1px solid rgba(255, 255, 255, 0.1);
        }
        
        /* Photo Preview */
        .photo-preview {
            max-width: 100%;
            max-height: 300px;
            border-radius: 8px;
            margin-top: 0.5rem;
        }
        
        /* Notification Styles */
        .custom-notification {
            position: fixed;
            top: 20px;
            right: 20px;
            background: rgba(255, 255, 255, 0.95);
            color: #000000 !important;
            padding: 1rem 1.5rem;
            border-radius: 8px;
            border-left: 4px solid #ccc;
            box-shadow: 0 4px 12px rgba(0,0,0,0.15);
            z-index: 10000;
            display: flex;
            align-items: center;
            gap: 0.75rem;
            max-width: 400px;
            animation: slideInRight 0.3s ease;
        }
        .notification-error { border-left-color: #dc3545; }
        .notification-success { border-left-color: #198754; }
        .notification-info { border-left-color: #0dcaf0; }
        .custom-notification button {
            background: none;
            border: none;
            font-size: 1.2rem;
            cursor: pointer;
            color: #666 !important;
        }
        @keyframes slideInRight {
            from { transform: translateX(100%); opacity: 0; }
            to { transform: translateX(0); opacity: 1; }
        }
        
        @media (max-width: 768px) {
            .reports-grid {
                grid-template-columns: 1fr;
            }
            
            .filter-group {
                flex-direction: column;
            }
            
            .form-group {
                min-width: 100%;
            }
            
            .report-info-grid {
                grid-template-columns: 1fr;
            }
        }
    </style>

    <div class="waste-reports-container">
        <div class="filter-card">
            <h5 class="mb-3" style="color: #ffffff !important;"><i class="fas fa-filter me-2"></i>Filter Waste Reports</h5>
            <div class="filter-group">
                <div class="form-group search-box">
                    <label class="form-label">Search Reports</label>
                    <div class="position-relative">
                        <i class="fas fa-search search-icon"></i>
                        <input type="text" class="form-control search-input" id="searchReports" placeholder="Search by address, citizen, or waste type...">
                    </div>
                </div>
                
                <div class="form-group">
                    <label class="form-label">Waste Type</label>
                    <select class="form-control" id="wasteTypeFilter">
                        <option value="all">All Types</option>
                        <option value="Plastic">Plastic</option>
                        <option value="Paper">Paper</option>
                        <option value="Glass">Glass</option>
                        <option value="Metal">Metal</option>
                        <option value="Organic">Organic</option>
                    </select>
                </div>
                
                <div class="form-group">
                    <label class="form-label">Date Range</label>
                    <select class="form-control" id="dateFilter">
                        <option value="all">All Time</option>
                        <option value="today">Today</option>
                        <option value="week">This Week</option>
                        <option value="month">This Month</option>
                        <option value="year">This Year</option>
                    </select>
                </div>
                
                <div class="form-group">
                    <label class="form-label">Has Pickup</label>
                    <select class="form-control" id="pickupFilter">
                        <option value="all">All Reports</option>
                        <option value="with">With Pickup</option>
                        <option value="without">Without Pickup</option>
                    </select>
                </div>
                
                <div class="form-group">
                    <button type="button" class="btn-primary" id="applyFiltersBtn" style="margin-top: 1.7rem;">
                        <i class="fas fa-filter me-2"></i>Apply Filters
                    </button>
                </div>
            </div>
        </div>

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
                Showing 0 reports
            </div>
        </div>

        <div id="gridView">
            <div class="reports-grid" id="reportsGrid">
            </div>
        </div>

        <div id="tableView" style="display: none;">
            <div class="table-responsive">
                <table class="reports-table" id="reportsTable">
                    <thead>
                        <tr>
                            <th>Report ID</th>
                            <th>Citizen</th>
                            <th>Waste Type</th>
                            <th>Weight (kg)</th>
                            <th>Address</th>
                            <th>Date Reported</th>
                            <th>Pickup Status</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody id="reportsTableBody">
                    </tbody>
                </table>
            </div>
        </div>

        <div class="pagination-container">
            <div class="page-info" id="paginationInfo">
                Page 1 of 1
            </div>
            <nav>
                <ul class="pagination mb-0" id="pagination">
                </ul>
            </nav>
        </div>
    </div>

    <!-- View Report Details Modal -->
    <div class="modal-overlay" id="viewReportModal">
        <div class="modal-content" style="max-width: 700px;">
            <div class="modal-header">
                <h3 class="modal-title">Waste Report Details</h3>
                <button type="button" class="close-modal">&times;</button>
            </div>
            <div class="modal-body">
                <div class="report-details-container">
                    <div class="report-info-grid">
                        <div class="info-item">
                            <label>Report ID:</label>
                            <span id="viewReportId">-</span>
                        </div>
                        <div class="info-item">
                            <label>Citizen:</label>
                            <span id="viewCitizenName">-</span>
                        </div>
                        <div class="info-item">
                            <label>Waste Type:</label>
                            <span id="viewWasteType">-</span>
                        </div>
                        <div class="info-item">
                            <label>Estimated Weight:</label>
                            <span id="viewEstimatedWeight">-</span>
                        </div>
                        <div class="info-item">
                            <label>Credits Rate:</label>
                            <span id="viewCreditRate">-</span>
                        </div>
                        <div class="info-item">
                            <label>Date Reported:</label>
                            <span id="viewReportedDate">-</span>
                        </div>
                        <div class="info-item">
                            <label>Pickup Status:</label>
                            <span id="viewPickupStatus">-</span>
                        </div>
                        <div class="info-item">
                            <label>Pickup ID:</label>
                            <span id="viewPickupId">-</span>
                        </div>
                        <div class="info-item full-width">
                            <label>Address:</label>
                            <span id="viewReportAddress">-</span>
                        </div>
                        <div class="info-item full-width">
                            <label>Notes/Photo:</label>
                            <span id="viewReportNotes">-</span>
                        </div>
                        <div class="info-item full-width" id="photoPreviewContainer" style="display: none;">
                            <label>Photo Preview:</label>
                            <img id="photoPreview" class="photo-preview" src="" alt="Report Photo">
                        </div>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-action btn-create-pickup" id="createPickupBtn" style="display: none;">
                    <i class="fas fa-truck me-2"></i>Create Pickup
                </button>
                <button type="button" class="btn-action" id="closeViewModalBtn">Close</button>
            </div>
        </div>
    </div>

    <!-- Create Pickup Modal -->
    <div class="modal-overlay" id="createPickupModal">
        <div class="modal-content" style="max-width: 500px;">
            <div class="modal-header">
                <h3 class="modal-title">Create Pickup Request</h3>
                <button type="button" class="close-modal">&times;</button>
            </div>
            <div class="modal-body">
                <div class="form-group">
                    <label class="form-label">Select Collector</label>
                    <select class="form-control" id="collectorSelect">
                        <option value="">Select a collector...</option>
                    </select>
                </div>
                <div class="form-group">
                    <label class="form-label">Scheduled Date & Time</label>
                    <input type="datetime-local" class="form-control" id="scheduledDateTime">
                </div>
                <div class="form-group">
                    <label class="form-label">Notes (Optional)</label>
                    <textarea class="form-control" id="pickupNotes" rows="3" placeholder="Add any special instructions..."></textarea>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-action" id="cancelCreatePickupBtn">Cancel</button>
                <button type="button" class="btn-primary" id="confirmCreatePickupBtn">Create Pickup</button>
            </div>
        </div>
    </div>

    <!-- Delete Confirmation Modal -->
    <div class="modal-overlay" id="deleteReportModal">
        <div class="modal-content" style="max-width: 500px;">
            <div class="modal-header">
                <h3 class="modal-title">Confirm Delete</h3>
                <button type="button" class="close-modal">&times;</button>
            </div>
            <div class="modal-body">
                <div class="text-center">
                    <i class="fas fa-exclamation-triangle fa-3x text-warning mb-3"></i>
                    <h4>Are you sure?</h4>
                    <p>You are about to delete waste report: <strong id="deleteReportId">-</strong></p>
                    <p class="text-muted">This will also delete any associated pickup requests. This action cannot be undone.</p>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-action" id="cancelDeleteBtn" style="flex: 1;">Cancel</button>
                <button type="button" class="btn-primary" id="confirmDeleteBtn" style="flex: 1;">Delete Report</button>
            </div>
        </div>
    </div>

    <asp:Button ID="btnLoadReports" runat="server" OnClick="LoadReports" Style="display: none;" />
    <asp:HiddenField ID="hfReportsData" runat="server" />
    <asp:HiddenField ID="hfCurrentPage" runat="server" Value="1" />
    <asp:HiddenField ID="hfCollectorsList" runat="server" />
</asp:Content>

<asp:Content ID="Scripts" ContentPlaceHolderID="Scripts" runat="server">
   <script>
       // GLOBAL VARIABLES
       let currentView = 'grid';
       let currentPage = 1;
       const reportsPerPage = 6;
       let filteredReports = [];
       let allReports = [];
       let allCollectors = [];
       let currentViewReportId = null;
       let currentDeleteReportId = null;
       let currentCreatePickupReportId = null;

       // INITIALIZE
       document.addEventListener('DOMContentLoaded', function () {
           initializeEventListeners();
           loadReportsFromServer();
           loadCollectorsFromServer();
       });

       function initializeEventListeners() {
           // View buttons
           document.querySelectorAll('.view-btn').forEach(btn => {
               btn.addEventListener('click', function (e) {
                   e.preventDefault();
                   const view = this.getAttribute('data-view');
                   changeView(view);
               });
           });

           // Filter button
           document.getElementById('applyFiltersBtn').addEventListener('click', function (e) {
               e.preventDefault();
               applyFilters();
           });

           // Search input
           document.getElementById('searchReports').addEventListener('input', function (e) {
               applyFilters();
           });

           // Filter dropdowns
           document.getElementById('wasteTypeFilter').addEventListener('change', function (e) {
               applyFilters();
           });

           document.getElementById('dateFilter').addEventListener('change', function (e) {
               applyFilters();
           });

           document.getElementById('pickupFilter').addEventListener('change', function (e) {
               applyFilters();
           });

           // Modal close buttons
           document.querySelector('#viewReportModal .close-modal').addEventListener('click', closeViewReportModal);
           document.querySelector('#createPickupModal .close-modal').addEventListener('click', closeCreatePickupModal);
           document.querySelector('#deleteReportModal .close-modal').addEventListener('click', closeDeleteModal);

           document.getElementById('closeViewModalBtn').addEventListener('click', closeViewReportModal);
           document.getElementById('cancelCreatePickupBtn').addEventListener('click', closeCreatePickupModal);
           document.getElementById('cancelDeleteBtn').addEventListener('click', closeDeleteModal);

           document.getElementById('createPickupBtn').addEventListener('click', openCreatePickupModal);
           document.getElementById('confirmCreatePickupBtn').addEventListener('click', confirmCreatePickup);
           document.getElementById('confirmDeleteBtn').addEventListener('click', confirmDelete);

           // Close modals when clicking outside
           document.getElementById('viewReportModal').addEventListener('click', function (e) {
               if (e.target === this) closeViewReportModal();
           });
           document.getElementById('createPickupModal').addEventListener('click', function (e) {
               if (e.target === this) closeCreatePickupModal();
           });
           document.getElementById('deleteReportModal').addEventListener('click', function (e) {
               if (e.target === this) closeDeleteModal();
           });
       }

       function changeView(view) {
           currentView = view;

           // Update active button
           document.querySelectorAll('.view-btn').forEach(btn => {
               btn.classList.remove('active');
               if (btn.getAttribute('data-view') === view) {
                   btn.classList.add('active');
               }
           });

           // Show/hide views
           document.getElementById('gridView').style.display = view === 'grid' ? 'block' : 'none';
           document.getElementById('tableView').style.display = view === 'table' ? 'block' : 'none';

           renderReports();
       }

       function loadReportsFromServer() {
           showLoading();

           const reportsData = document.getElementById('<%= hfReportsData.ClientID %>').value;

           if (reportsData && reportsData !== '') {
               try {
                   allReports = JSON.parse(reportsData);
                   filteredReports = [...allReports];

                   renderReports();
                   updatePagination();
                   updatePageInfo();
                   hideLoading();

                   if (filteredReports.length > 0) {
                       showSuccess('Loaded ' + filteredReports.length + ' waste reports from database');
                   } else {
                       showInfo('No waste reports found in database');
                   }

               } catch (e) {
                   console.error('Error parsing report data:', e);
                   showError('Error loading waste report data from database');
                   hideLoading();
               }
           } else {
               showError('No waste report data available from database');
               hideLoading();
           }
       }

       function loadCollectorsFromServer() {
           const collectorsData = document.getElementById('<%= hfCollectorsList.ClientID %>').value;
           if (collectorsData && collectorsData !== '') {
               try {
                   allCollectors = JSON.parse(collectorsData);
                   populateCollectorSelect();
               } catch (e) {
                   console.error('Error parsing collectors data:', e);
               }
           }
       }

       function populateCollectorSelect() {
           const select = document.getElementById('collectorSelect');
           select.innerHTML = '<option value="">Select a collector...</option>';

           allCollectors.forEach(collector => {
               const option = document.createElement('option');
               option.value = collector.Id;
               option.textContent = collector.FirstName + ' ' + collector.LastName + ' (' + collector.Status + ')';
               select.appendChild(option);
           });
       }

       function showNotification(message, type = 'info') {
           const existingNotifications = document.querySelectorAll('.custom-notification');
           existingNotifications.forEach(notif => notif.remove());

           const notification = document.createElement('div');
           notification.className = 'custom-notification notification-' + type;

           const icons = {
               error: 'fas fa-exclamation-circle',
               success: 'fas fa-check-circle',
               info: 'fas fa-info-circle'
           };

           notification.innerHTML = '<i class="' + icons[type] + '"></i><span>' + message + '</span><button onclick="this.parentElement.remove()">&times;</button>';

           document.body.appendChild(notification);

           setTimeout(() => {
               if (notification.parentElement) {
                   notification.remove();
               }
           }, 5000);
       }

       function showError(message) {
           showNotification(message, 'error');
       }

       function showSuccess(message) {
           showNotification(message, 'success');
       }

       function showInfo(message) {
           showNotification(message, 'info');
       }

       function applyFilters() {
           const searchTerm = document.getElementById('searchReports').value.toLowerCase();
           const wasteTypeFilter = document.getElementById('wasteTypeFilter').value;
           const pickupFilter = document.getElementById('pickupFilter').value;

           filteredReports = allReports.filter(report => {
               const matchesSearch = !searchTerm ||
                   (report.Address && report.Address.toLowerCase().includes(searchTerm)) ||
                   (report.CitizenName && report.CitizenName.toLowerCase().includes(searchTerm)) ||
                   (report.WasteType && report.WasteType.toLowerCase().includes(searchTerm));

               const matchesWasteType = wasteTypeFilter === 'all' || report.WasteType === wasteTypeFilter;
               
               const hasPickup = report.PickupId && report.PickupId !== '';
               const matchesPickupFilter = 
                   pickupFilter === 'all' || 
                   (pickupFilter === 'with' && hasPickup) || 
                   (pickupFilter === 'without' && !hasPickup);

               return matchesSearch && matchesWasteType && matchesPickupFilter;
           });

           currentPage = 1;
           renderReports();
           updatePagination();
           updatePageInfo();
       }

       function renderReports() {
           if (currentView === 'grid') {
               renderGridView();
           } else {
               renderTableView();
           }
       }

       function renderGridView() {
           const grid = document.getElementById('reportsGrid');
           const startIndex = (currentPage - 1) * reportsPerPage;
           const endIndex = startIndex + reportsPerPage;
           const reportsToShow = filteredReports.slice(startIndex, endIndex);

           grid.innerHTML = '';

           if (reportsToShow.length === 0) {
               grid.innerHTML = '<div class="col-12 text-center py-5"><i class="fas fa-trash-alt fa-3x mb-3" style="color: rgba(255, 255, 255, 0.5) !important;"></i><h4 style="color: rgba(255, 255, 255, 0.7) !important;">No waste reports found</h4><p style="color: rgba(255, 255, 255, 0.5) !important;">Try adjusting your filters or search terms</p></div>';
               return;
           }

           reportsToShow.forEach(report => {
               const reportCard = createReportCard(report);
               grid.appendChild(reportCard);
           });
       }

       function renderTableView() {
           const tbody = document.getElementById('reportsTableBody');
           const startIndex = (currentPage - 1) * reportsPerPage;
           const endIndex = startIndex + reportsPerPage;
           const reportsToShow = filteredReports.slice(startIndex, endIndex);

           tbody.innerHTML = '';

           if (reportsToShow.length === 0) {
               tbody.innerHTML = '<tr><td colspan="8" class="text-center py-4"><i class="fas fa-trash-alt fa-2x mb-2" style="color: rgba(255, 255, 255, 0.5) !important;"></i><h5 style="color: rgba(255, 255, 255, 0.7) !important;">No waste reports found</h5><p style="color: rgba(255, 255, 255, 0.5) !important;">Try adjusting your filters or search terms</p></td></tr>';
               return;
           }

           reportsToShow.forEach(report => {
               const row = createTableRow(report);
               tbody.appendChild(row);
           });
       }

       function createReportCard(report) {
           const card = document.createElement('div');
           card.className = 'report-card';

           const hasPickup = report.PickupId && report.PickupId !== '';
           const status = hasPickup ? 'Pickup Created' : 'Reported';
           const statusClass = hasPickup ? 'status-pickup-created' : 'status-reported';

           card.innerHTML = '<div class="report-header"><div class="report-info"><h3 class="report-title">Report #' + report.ReportId + '</h3><p class="report-address">' + escapeHtml(report.Address || 'No address') + '</p><div class="report-details"><div class="detail-item"><div class="detail-value">' + (report.EstimatedWeight || 0) + 'kg</div><div class="detail-label">Weight</div></div><div class="detail-item"><div class="detail-value">' + (report.WasteType || 'Unknown') + '</div><div class="detail-label">Waste Type</div></div><div class="detail-item"><div class="detail-value">' + (report.CreditRate || 0) + '</div><div class="detail-label">Credits/kg</div></div></div></div><div class="report-actions"><button class="btn-action btn-view" data-report-id="' + report.ReportId + '" title="View Details"><i class="fas fa-eye"></i></button>' + (!hasPickup ? '<button class="btn-action btn-create-pickup" data-report-id="' + report.ReportId + '" title="Create Pickup"><i class="fas fa-truck"></i></button>' : '') + '<button class="btn-action btn-delete" data-report-id="' + report.ReportId + '" title="Delete Report"><i class="fas fa-trash"></i></button></div></div><div class="report-meta"><div class="report-status"><span class="status-badge ' + statusClass + '">' + status + '</span><span style="color: rgba(255, 255, 255, 0.5) !important;">' + (report.CitizenName || 'Unknown Citizen') + '</span></div><div class="small" style="color: rgba(255, 255, 255, 0.5) !important;">' + formatDate(report.RequestedDate) + '</div></div>';

           // Add event listeners
           card.querySelector('.btn-view').addEventListener('click', function () {
               viewReport(this.getAttribute('data-report-id'));
           });

           if (!hasPickup) {
               card.querySelector('.btn-create-pickup').addEventListener('click', function () {
                   createPickup(this.getAttribute('data-report-id'));
               });
           }

           card.querySelector('.btn-delete').addEventListener('click', function () {
               deleteReport(this.getAttribute('data-report-id'));
           });

           return card;
       }

       function createTableRow(report) {
           const row = document.createElement('tr');
           const hasPickup = report.PickupId && report.PickupId !== '';
           const status = hasPickup ? 'Pickup Created' : 'Reported';
           const statusClass = hasPickup ? 'status-pickup-created' : 'status-reported';

           row.innerHTML = '<td>' + report.ReportId + '</td><td><div class="d-flex align-items-center gap-3"><div class="user-avatar">' + escapeHtml((report.CitizenName ? report.CitizenName[0] : 'U') + (report.CitizenName ? report.CitizenName.split(' ')[1] ? report.CitizenName.split(' ')[1][0] : '' : '')) + '</div><div><div class="fw-bold" style="color: #ffffff !important;">' + escapeHtml(report.CitizenName || 'Unknown') + '</div></div></div></td><td>' + (report.WasteType || 'Unknown') + '</td><td><div style="color: #ffffff !important;">' + (report.EstimatedWeight || 0) + 'kg</div></td><td>' + escapeHtml(report.Address || 'No address') + '</td><td>' + formatDate(report.RequestedDate) + '</td><td><span class="status-badge ' + statusClass + '">' + status + '</span></td><td><div class="report-actions"><button class="btn-action btn-view" data-report-id="' + report.ReportId + '" title="View Details"><i class="fas fa-eye"></i></button>' + (!hasPickup ? '<button class="btn-action btn-create-pickup" data-report-id="' + report.ReportId + '" title="Create Pickup"><i class="fas fa-truck"></i></button>' : '') + '<button class="btn-action btn-delete" data-report-id="' + report.ReportId + '" title="Delete Report"><i class="fas fa-trash"></i></button></div></td>';

           // Add event listeners
           row.querySelector('.btn-view').addEventListener('click', function () {
               viewReport(this.getAttribute('data-report-id'));
           });

           if (!hasPickup) {
               row.querySelector('.btn-create-pickup').addEventListener('click', function () {
                   createPickup(this.getAttribute('data-report-id'));
               });
           }

           row.querySelector('.btn-delete').addEventListener('click', function () {
               deleteReport(this.getAttribute('data-report-id'));
           });

           return row;
       }

       function updatePagination() {
           const pagination = document.getElementById('pagination');
           const totalPages = Math.ceil(filteredReports.length / reportsPerPage);

           pagination.innerHTML = '';

           if (totalPages <= 1) return;

           const prevLi = document.createElement('li');
           prevLi.className = 'page-item ' + (currentPage === 1 ? 'disabled' : '');
           prevLi.innerHTML = '<a class="page-link" href="javascript:void(0)" data-page="' + (currentPage - 1) + '">Previous</a>';
           pagination.appendChild(prevLi);

           for (let i = 1; i <= totalPages; i++) {
               const li = document.createElement('li');
               li.className = 'page-item ' + (currentPage === i ? 'active' : '');
               li.innerHTML = '<a class="page-link" href="javascript:void(0)" data-page="' + i + '">' + i + '</a>';
               pagination.appendChild(li);
           }

           const nextLi = document.createElement('li');
           nextLi.className = 'page-item ' + (currentPage === totalPages ? 'disabled' : '');
           nextLi.innerHTML = '<a class="page-link" href="javascript:void(0)" data-page="' + (currentPage + 1) + '">Next</a>';
           pagination.appendChild(nextLi);

           // Add event listeners to pagination links
           pagination.querySelectorAll('.page-link').forEach(link => {
               link.addEventListener('click', function () {
                   const page = parseInt(this.getAttribute('data-page'));
                   changePage(page);
               });
           });

           document.getElementById('paginationInfo').textContent = 'Page ' + currentPage + ' of ' + totalPages;
       }

       function changePage(page) {
           const totalPages = Math.ceil(filteredReports.length / reportsPerPage);
           if (page >= 1 && page <= totalPages) {
               currentPage = page;
               renderReports();
               updatePagination();
           }
       }

       function updatePageInfo() {
           const startIndex = (currentPage - 1) * reportsPerPage + 1;
           const endIndex = Math.min(currentPage * reportsPerPage, filteredReports.length);
           document.getElementById('pageInfo').textContent = 'Showing ' + startIndex + '-' + endIndex + ' of ' + filteredReports.length + ' reports';
       }

       function showLoading() {
           const grid = document.getElementById('reportsGrid');
           if (grid) {
               grid.innerHTML = '<div class="col-12 text-center py-5"><i class="fas fa-spinner fa-spin fa-2x mb-3" style="color: rgba(255, 255, 255, 0.5) !important;"></i><p style="color: rgba(255, 255, 255, 0.7) !important;">Loading waste reports from database...</p></div>';
           }
       }

       function hideLoading() { }

       // View Report Modal Functions
       function viewReport(reportId) {
           const report = allReports.find(r => r.ReportId === reportId);
           if (report) {
               currentViewReportId = reportId;

               // Populate modal with report data
               document.getElementById('viewReportId').textContent = report.ReportId;
               document.getElementById('viewCitizenName').textContent = report.CitizenName || 'Unknown';
               document.getElementById('viewWasteType').textContent = report.WasteType || 'Unknown';
               document.getElementById('viewEstimatedWeight').textContent = (report.EstimatedWeight || 0) + ' kg';
               document.getElementById('viewCreditRate').textContent = (report.CreditRate || 0) + ' credits/kg';
               document.getElementById('viewReportedDate').textContent = formatDateTime(report.RequestedDate);
               document.getElementById('viewPickupStatus').textContent = (report.PickupId && report.PickupId !== '') ? 'Pickup Created' : 'No Pickup';
               document.getElementById('viewPickupId').textContent = report.PickupId || 'Not assigned';
               document.getElementById('viewReportAddress').textContent = report.Address || 'No address';
               document.getElementById('viewReportNotes').textContent = report.Notes || 'No notes';

               // Handle photo preview
               const photoPreviewContainer = document.getElementById('photoPreviewContainer');
               const photoPreview = document.getElementById('photoPreview');
               if (report.Notes && (report.Notes.startsWith('http') || report.Notes.startsWith('https'))) {
                   photoPreview.src = report.Notes;
                   photoPreviewContainer.style.display = 'block';
               } else {
                   photoPreviewContainer.style.display = 'none';
               }

               // Show/hide create pickup button
               const createPickupBtn = document.getElementById('createPickupBtn');
               if (report.PickupId && report.PickupId !== '') {
                   createPickupBtn.style.display = 'none';
               } else {
                   createPickupBtn.style.display = 'block';
               }

               // Show modal
               document.getElementById('viewReportModal').style.display = 'block';
           }
       }

       function closeViewReportModal() {
           document.getElementById('viewReportModal').style.display = 'none';
           currentViewReportId = null;
       }

       // Create Pickup Modal Functions
       function createPickup(reportId) {
           currentCreatePickupReportId = reportId;
           document.getElementById('createPickupModal').style.display = 'block';
       }

       function openCreatePickupModal() {
           if (currentViewReportId) {
               currentCreatePickupReportId = currentViewReportId;
               document.getElementById('createPickupModal').style.display = 'block';
           }
       }

       function closeCreatePickupModal() {
           document.getElementById('createPickupModal').style.display = 'none';
           currentCreatePickupReportId = null;
           // Reset form
           document.getElementById('collectorSelect').value = '';
           document.getElementById('scheduledDateTime').value = '';
           document.getElementById('pickupNotes').value = '';
       }

       function confirmCreatePickup() {
           const collectorId = document.getElementById('collectorSelect').value;
           const scheduledDate = document.getElementById('scheduledDateTime').value;
           const notes = document.getElementById('pickupNotes').value;

           if (!collectorId) {
               showError('Please select a collector');
               return;
           }

           if (!scheduledDate) {
               showError('Please select a scheduled date and time');
               return;
           }

           const selectedCollector = allCollectors.find(c => c.Id === collectorId);

           PageMethods.CreatePickupFromReport(currentCreatePickupReportId, collectorId, scheduledDate, notes,
               function(response) {
                   if (response.startsWith('Success')) {
                       showSuccess('Pickup created successfully from waste report');
                       closeCreatePickupModal();
                       closeViewReportModal();
                       document.getElementById('<%= btnLoadReports.ClientID %>').click();
                   } else {
                       showError('Error creating pickup: ' + response);
                   }
               },
               function(error) {
                   showError('Error calling server: ' + error.get_message());
               }
           );
       }

       // Delete Confirmation Modal Functions
       function deleteReport(reportId) {
           const report = allReports.find(r => r.ReportId === reportId);
           if (report) {
               currentDeleteReportId = reportId;
               document.getElementById('deleteReportId').textContent = '#' + report.ReportId;
               document.getElementById('deleteReportModal').style.display = 'block';
           }
       }

       function closeDeleteModal() {
           document.getElementById('deleteReportModal').style.display = 'none';
           currentDeleteReportId = null;
       }

       function confirmDelete() {
           if (currentDeleteReportId) {
               PageMethods.DeleteWasteReport(currentDeleteReportId,
                   function(response) {
                       if (response.startsWith('Success')) {
                           showSuccess('Waste report deleted successfully');
                           document.getElementById('<%= btnLoadReports.ClientID %>').click();
                       } else {
                           showError('Error deleting waste report: ' + response);
                       }
                       closeDeleteModal();
                   },
                   function(error) {
                       showError('Error calling server: ' + error.get_message());
                       closeDeleteModal();
                   }
               );
           }
       }

       function formatDate(dateString) {
           if (!dateString) return 'Unknown';
           try {
               return new Date(dateString).toLocaleDateString();
           } catch (e) {
               return dateString;
           }
       }

       function formatDateTime(dateString) {
           if (!dateString) return 'Unknown';
           try {
               return new Date(dateString).toLocaleString();
           } catch (e) {
               return dateString;
           }
       }

       function escapeHtml(unsafe) {
           if (!unsafe) return '';
           return unsafe.toString()
               .replace(/&/g, "&amp;")
               .replace(/</g, "&lt;")
               .replace(/>/g, "&gt;")
               .replace(/"/g, "&quot;")
               .replace(/'/g, "&#039;");
       }
   </script>
</asp:Content>