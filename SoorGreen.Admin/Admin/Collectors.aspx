<%@ Page Title="Collectors" Language="C#" MasterPageFile="~/Admin/Site.master" AutoEventWireup="true" CodeFile="Collectors.aspx.cs" Inherits="SoorGreen.Admin.Admin.Collectors" %>

<asp:Content ID="PageTitle" ContentPlaceHolderID="PageTitle" runat="server">
    Collector Management
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <style>
        .collectors-container {
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
        
        .collector-card {
            background: rgba(255, 255, 255, 0.05);
            backdrop-filter: blur(20px);
            border: 1px solid rgba(255, 255, 255, 0.1);
            border-radius: 15px;
            padding: 1.5rem;
            margin-bottom: 1.5rem;
            transition: all 0.3s ease;
        }
        
        .collector-card:hover {
            transform: translateY(-3px);
            border-color: rgba(255, 193, 7, 0.3);
        }
        
        .collector-header {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            margin-bottom: 1rem;
        }
        
        .collector-info {
            flex: 1;
        }
        
        .collector-name {
            font-size: 1.3rem;
            font-weight: 700;
            color: #ffffff !important;
            margin: 0 0 0.5rem 0;
        }
        
        .collector-email {
            color: rgba(255, 255, 255, 0.8) !important;
            margin: 0 0 0.5rem 0;
        }
        
        .collector-actions {
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
        
        .btn-edit {
            background: rgba(13, 110, 253, 0.2);
            border-color: rgba(13, 110, 253, 0.3);
        }
        
        .btn-delete {
            background: rgba(220, 53, 69, 0.2);
            border-color: rgba(220, 53, 69, 0.3);
        }
        
        .btn-view {
            background: rgba(25, 135, 84, 0.2);
            border-color: rgba(25, 135, 84, 0.3);
        }
        
        .collector-stats {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(120px, 1fr));
            gap: 1rem;
            margin-bottom: 1rem;
        }
        
        .stat-item {
            text-align: center;
            padding: 0.8rem;
            background: rgba(255, 255, 255, 0.03);
            border-radius: 8px;
            border: 1px solid rgba(255, 255, 255, 0.05);
        }
        
        .stat-value {
            font-size: 1.5rem;
            font-weight: 800;
            color: #ffffff !important;
            margin-bottom: 0.3rem;
        }
        
        .stat-label {
            color: rgba(255, 255, 255, 0.6);
            font-size: 0.75rem;
            font-weight: 600;
        }
        
        .collector-meta {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding-top: 1rem;
            border-top: 1px solid rgba(255, 255, 255, 0.1);
        }
        
        .collector-status {
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
        
        .status-active {
            background: rgba(25, 135, 84, 0.2);
            color: #198754;
            border: 1px solid rgba(25, 135, 84, 0.3);
        }
        
        .status-inactive {
            background: rgba(108, 117, 125, 0.2);
            color: #6c757d;
            border: 1px solid rgba(108, 117, 125, 0.3);
        }
        
        .status-suspended {
            background: rgba(220, 53, 69, 0.2);
            color: #dc3545;
            border: 1px solid rgba(220, 53, 69, 0.3);
        }
        
        .status-pending {
            background: rgba(255, 193, 7, 0.2);
            color: #ffc107;
            border: 1px solid rgba(255, 193, 7, 0.3);
        }
        
        .status-online {
            background: rgba(13, 110, 253, 0.2);
            color: #0d6efd;
            border: 1px solid rgba(13, 110, 253, 0.3);
        }
        
        .status-offline {
            background: rgba(108, 117, 125, 0.2);
            color: #6c757d;
            border: 1px solid rgba(108, 117, 125, 0.3);
        }
        
        .table-responsive {
            border-radius: 10px;
            overflow: hidden;
        }
        
        .collectors-table {
            width: 100%;
            background: rgba(255, 255, 255, 0.02);
            border-collapse: collapse;
        }
        
        .collectors-table th {
            background: rgba(255, 255, 255, 0.1);
            color: #ffffff !important;
            font-weight: 600;
            padding: 1rem;
            text-align: left;
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
        }
        
        .collectors-table td {
            padding: 1rem;
            border-bottom: 1px solid rgba(255, 255, 255, 0.05);
            color: rgba(255, 255, 255, 0.8) !important;
        }
        
        .collectors-table tr:hover {
            background: rgba(255, 255, 255, 0.03);
        }
        
        .collector-avatar {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            background: linear-gradient(135deg, #ffd89b 0%, #19547b 100%);
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
        
        .collectors-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(350px, 1fr));
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
            max-width: 500px;
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
        
        /* Collector Details Modal Styles */
        .collector-details-container {
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 1.5rem;
        }
        
        .collector-avatar-large {
            text-align: center;
        }
        
        .collector-info-grid {
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
        
        /* Performance Metrics */
        .performance-metrics {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
            gap: 1rem;
            margin: 1rem 0;
            padding: 1rem;
            background: rgba(255, 255, 255, 0.03);
            border-radius: 10px;
            border: 1px solid rgba(255, 255, 255, 0.05);
        }
        
        .metric-item {
            text-align: center;
        }
        
        .metric-value {
            font-size: 1.2rem;
            font-weight: 700;
            color: #ffffff !important;
            margin-bottom: 0.25rem;
        }
        
        .metric-label {
            color: rgba(255, 255, 255, 0.6);
            font-size: 0.75rem;
            font-weight: 600;
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
            .collectors-grid {
                grid-template-columns: 1fr;
            }
            
            .filter-group {
                flex-direction: column;
            }
            
            .form-group {
                min-width: 100%;
            }
            
            .collector-info-grid {
                grid-template-columns: 1fr;
            }
            
            .performance-metrics {
                grid-template-columns: repeat(2, 1fr);
            }
        }
    </style>

    <div class="collectors-container">
        <div class="filter-card">
            <h5 class="mb-3" style="color: #ffffff !important;"><i class="fas fa-filter me-2"></i>Filter Collectors</h5>
            <div class="filter-group">
                <div class="form-group search-box">
                    <label class="form-label">Search Collectors</label>
                    <div class="position-relative">
                        <i class="fas fa-search search-icon"></i>
                        <input type="text" class="form-control search-input" id="searchCollectors" placeholder="Search by name, email, or phone...">
                    </div>
                </div>
                
                <div class="form-group">
                    <label class="form-label">Status</label>
                    <select class="form-control" id="statusFilter">
                        <option value="all">All Status</option>
                        <option value="active">Active</option>
                        <option value="inactive">Inactive</option>
                        <option value="suspended">Suspended</option>
                        <option value="pending">Pending</option>
                    </select>
                </div>
                
                <div class="form-group">
                    <label class="form-label">Availability</label>
                    <select class="form-control" id="availabilityFilter">
                        <option value="all">All</option>
                        <option value="online">Online</option>
                        <option value="offline">Offline</option>
                    </select>
                </div>
                
                <div class="form-group">
                    <label class="form-label">Registration Date</label>
                    <select class="form-control" id="dateFilter">
                        <option value="all">All Time</option>
                        <option value="today">Today</option>
                        <option value="week">This Week</option>
                        <option value="month">This Month</option>
                        <option value="year">This Year</option>
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
                Showing 0 collectors
            </div>
        </div>

        <div id="gridView">
            <div class="collectors-grid" id="collectorsGrid">
            </div>
        </div>

        <div id="tableView" style="display: none;">
            <div class="table-responsive">
                <table class="collectors-table" id="collectorsTable">
                    <thead>
                        <tr>
                            <th>Collector</th>
                            <th>Contact</th>
                            <th>Status</th>
                            <th>Availability</th>
                            <th>Completed Pickups</th>
                            <th>Rating</th>
                            <th>Earnings</th>
                            <th>Joined</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody id="collectorsTableBody">
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

    <!-- View Collector Details Modal -->
    <div class="modal-overlay" id="viewCollectorModal">
        <div class="modal-content" style="max-width: 700px;">
            <div class="modal-header">
                <h3 class="modal-title">Collector Details</h3>
                <button type="button" class="close-modal">&times;</button>
            </div>
            <div class="modal-body">
                <div class="collector-details-container">
                    <div class="collector-avatar-large">
                        <div class="collector-avatar" style="width: 80px; height: 80px; font-size: 1.5rem;" id="viewCollectorAvatar">
                            CC
                        </div>
                    </div>
                    
                    <div class="performance-metrics">
                        <div class="metric-item">
                            <div class="metric-value" id="viewTotalPickups">0</div>
                            <div class="metric-label">Total Pickups</div>
                        </div>
                        <div class="metric-item">
                            <div class="metric-value" id="viewSuccessRate">0%</div>
                            <div class="metric-label">Success Rate</div>
                        </div>
                        <div class="metric-item">
                            <div class="metric-value" id="viewAvgRating">0.0</div>
                            <div class="metric-label">Avg Rating</div>
                        </div>
                        <div class="metric-item">
                            <div class="metric-value" id="viewTotalEarnings">$0</div>
                            <div class="metric-label">Total Earnings</div>
                        </div>
                    </div>
                    
                    <div class="collector-info-grid">
                        <div class="info-item">
                            <label>Full Name:</label>
                            <span id="viewCollectorName">-</span>
                        </div>
                        <div class="info-item">
                            <label>Email:</label>
                            <span id="viewCollectorEmail">-</span>
                        </div>
                        <div class="info-item">
                            <label>Phone:</label>
                            <span id="viewCollectorPhone">-</span>
                        </div>
                        <div class="info-item">
                            <label>User Type:</label>
                            <span id="viewCollectorType">-</span>
                        </div>
                        <div class="info-item">
                            <label>Status:</label>
                            <span id="viewCollectorStatus">-</span>
                        </div>
                        <div class="info-item">
                            <label>Availability:</label>
                            <span id="viewCollectorAvailability">-</span>
                        </div>
                        <div class="info-item">
                            <label>Rating:</label>
                            <span id="viewCollectorRating">-</span>
                        </div>
                        <div class="info-item">
                            <label>Registration Date:</label>
                            <span id="viewCollectorRegDate">-</span>
                        </div>
                        <div class="info-item full-width">
                            <label>Address:</label>
                            <span id="viewCollectorAddress">-</span>
                        </div>
                        <div class="info-item full-width">
                            <label>Vehicle Info:</label>
                            <span id="viewCollectorVehicle">-</span>
                        </div>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-action" id="closeViewModalBtn">Close</button>
            </div>
        </div>
    </div>

    <!-- Delete Confirmation Modal -->
    <div class="modal-overlay" id="deleteCollectorModal">
        <div class="modal-content" style="max-width: 500px;">
            <div class="modal-header">
                <h3 class="modal-title">Confirm Delete</h3>
                <button type="button" class="close-modal">&times;</button>
            </div>
            <div class="modal-body">
                <div class="text-center">
                    <i class="fas fa-exclamation-triangle fa-3x text-warning mb-3"></i>
                    <h4>Are you sure?</h4>
                    <p>You are about to delete collector: <strong id="deleteCollectorName">-</strong></p>
                    <p class="text-muted">This action cannot be undone.</p>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-action" id="cancelDeleteBtn" style="flex: 1;">Cancel</button>
                <button type="button" class="btn-primary" id="confirmDeleteBtn" style="flex: 1;">Delete Collector</button>
            </div>
        </div>
    </div>

    <asp:Button ID="btnLoadCollectors" runat="server" OnClick="LoadCollectors" Style="display: none;" />
    <asp:HiddenField ID="hfCollectorsData" runat="server" />
    <asp:HiddenField ID="hfCurrentPage" runat="server" Value="1" />
</asp:Content>

<asp:Content ID="Scripts" ContentPlaceHolderID="Scripts" runat="server">
   <script>
       // GLOBAL VARIABLES
       let currentView = 'grid';
       let currentPage = 1;
       const collectorsPerPage = 6;
       let filteredCollectors = [];
       let allCollectors = [];
       let currentViewCollectorId = null;
       let currentDeleteCollectorId = null;

       // INITIALIZE
       document.addEventListener('DOMContentLoaded', function () {
           initializeEventListeners();
           loadCollectorsFromServer();
       });

       function initializeEventListeners() {
           // View buttons
           document.querySelectorAll('.view-btn').forEach(btn => {
               btn.addEventListener('click', function(e) {
                   e.preventDefault();
                   const view = this.getAttribute('data-view');
                   changeView(view);
               });
           });

           // Filter button
           document.getElementById('applyFiltersBtn').addEventListener('click', function(e) {
               e.preventDefault();
               applyFilters();
           });

           // Search input
           document.getElementById('searchCollectors').addEventListener('input', function(e) {
               applyFilters();
           });

           // Filter dropdowns
           document.getElementById('statusFilter').addEventListener('change', function(e) {
               applyFilters();
           });

           document.getElementById('availabilityFilter').addEventListener('change', function(e) {
               applyFilters();
           });

           document.getElementById('dateFilter').addEventListener('change', function(e) {
               applyFilters();
           });

           // Modal close buttons
           document.querySelector('#viewCollectorModal .close-modal').addEventListener('click', closeViewCollectorModal);
           document.querySelector('#deleteCollectorModal .close-modal').addEventListener('click', closeDeleteModal);
           document.getElementById('closeViewModalBtn').addEventListener('click', closeViewCollectorModal);
           document.getElementById('cancelDeleteBtn').addEventListener('click', closeDeleteModal);
           document.getElementById('confirmDeleteBtn').addEventListener('click', confirmDelete);

           // Close modals when clicking outside
           document.getElementById('viewCollectorModal').addEventListener('click', function(e) {
               if (e.target === this) closeViewCollectorModal();
           });
           document.getElementById('deleteCollectorModal').addEventListener('click', function(e) {
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

           renderCollectors();
       }

       function loadCollectorsFromServer() {
           showLoading();

           const collectorsData = document.getElementById('<%= hfCollectorsData.ClientID %>').value;

        if (collectorsData && collectorsData !== '') {
            try {
                allCollectors = JSON.parse(collectorsData);
                // Filter to show only collectors
                filteredCollectors = allCollectors.filter(collector => collector.UserType === 'collector');

                renderCollectors();
                updatePagination();
                updatePageInfo();
                hideLoading();

                if (filteredCollectors.length > 0) {
                    showSuccess('Loaded ' + filteredCollectors.length + ' collectors from database');
                } else {
                    showInfo('No collectors found in database');
                }

            } catch (e) {
                console.error('Error parsing collector data:', e);
                showError('Error loading collector data from database');
                hideLoading();
            }
        } else {
            showError('No collector data available from database');
            hideLoading();
        }
    }

    function showNotification(message, type = 'info') {
        const existingNotifications = document.querySelectorAll('.custom-notification');
        existingNotifications.forEach(notif => notif.remove());

        const notification = document.createElement('div');
        notification.className = `custom-notification notification-${type}`;

        const icons = {
            error: 'fas fa-exclamation-circle',
            success: 'fas fa-check-circle',
            info: 'fas fa-info-circle'
        };

        notification.innerHTML = `
            <i class="${icons[type]}"></i>
            <span>${message}</span>
            <button onclick="this.parentElement.remove()">&times;</button>
        `;

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
        const searchTerm = document.getElementById('searchCollectors').value.toLowerCase();
        const statusFilter = document.getElementById('statusFilter').value;
        const availabilityFilter = document.getElementById('availabilityFilter').value;

        filteredCollectors = allCollectors.filter(collector => {
            const matchesSearch = !searchTerm ||
                (collector.FirstName && collector.FirstName.toLowerCase().includes(searchTerm)) ||
                (collector.LastName && collector.LastName.toLowerCase().includes(searchTerm)) ||
                (collector.Email && collector.Email.toLowerCase().includes(searchTerm)) ||
                (collector.Phone && collector.Phone.includes(searchTerm));

            const matchesStatus = statusFilter === 'all' || collector.Status === statusFilter;
            const matchesAvailability = availabilityFilter === 'all' || collector.Availability === availabilityFilter;
            const isCollector = collector.UserType === 'collector';

            return matchesSearch && matchesStatus && matchesAvailability && isCollector;
        });

        currentPage = 1;
        renderCollectors();
        updatePagination();
        updatePageInfo();
    }

    function renderCollectors() {
        if (currentView === 'grid') {
            renderGridView();
        } else {
            renderTableView();
        }
    }

    function renderGridView() {
        const grid = document.getElementById('collectorsGrid');
        const startIndex = (currentPage - 1) * collectorsPerPage;
        const endIndex = startIndex + collectorsPerPage;
        const collectorsToShow = filteredCollectors.slice(startIndex, endIndex);

        grid.innerHTML = '';

        if (collectorsToShow.length === 0) {
            grid.innerHTML = `
                <div class="col-12 text-center py-5">
                    <i class="fas fa-truck-loading fa-3x mb-3" style="color: rgba(255, 255, 255, 0.5) !important;"></i>
                    <h4 style="color: rgba(255, 255, 255, 0.7) !important;">No collectors found</h4>
                    <p style="color: rgba(255, 255, 255, 0.5) !important;">Try adjusting your filters or search terms</p>
                </div>
            `;
            return;
        }

        collectorsToShow.forEach(collector => {
            const collectorCard = createCollectorCard(collector);
            grid.appendChild(collectorCard);
        });
    }

    function renderTableView() {
        const tbody = document.getElementById('collectorsTableBody');
        const startIndex = (currentPage - 1) * collectorsPerPage;
        const endIndex = startIndex + collectorsPerPage;
        const collectorsToShow = filteredCollectors.slice(startIndex, endIndex);

        tbody.innerHTML = '';

        if (collectorsToShow.length === 0) {
            tbody.innerHTML = `
                <tr>
                    <td colspan="9" class="text-center py-4">
                        <i class="fas fa-truck-loading fa-2x mb-2" style="color: rgba(255, 255, 255, 0.5) !important;"></i>
                        <h5 style="color: rgba(255, 255, 255, 0.7) !important;">No collectors found</h5>
                        <p style="color: rgba(255, 255, 255, 0.5) !important;">Try adjusting your filters or search terms</p>
                    </td>
                </tr>
            `;
            return;
        }

        collectorsToShow.forEach(collector => {
            const row = createTableRow(collector);
            tbody.appendChild(row);
        });
    }

    function createCollectorCard(collector) {
        const card = document.createElement('div');
        card.className = 'collector-card';

        const successRate = collector.TotalPickups > 0
            ? Math.round((collector.CompletedPickups / collector.TotalPickups) * 100)
            : 0;

        const earnings = collector.Earnings || 0;
        const rating = collector.Rating || 0;

        card.innerHTML = `
            <div class="collector-header">
                <div class="collector-info">
                    <h3 class="collector-name">${escapeHtml(collector.FirstName || '')} ${escapeHtml(collector.LastName || '')}</h3>
                    <p class="collector-email">${escapeHtml(collector.Email || 'No email')}</p>
                    <div class="collector-stats">
                        <div class="stat-item">
                            <div class="stat-value">${collector.CompletedPickups || 0}</div>
                            <div class="stat-label">Completed</div>
                        </div>
                        <div class="stat-item">
                            <div class="stat-value">${successRate}%</div>
                            <div class="stat-label">Success Rate</div>
                        </div>
                        <div class="stat-item">
                            <div class="stat-value">${rating.toFixed(1)}</div>
                            <div class="stat-label">Rating</div>
                        </div>
                    </div>
                </div>
                <div class="collector-actions">
                    <button class="btn-action btn-view" data-collector-id="${collector.Id}" title="View Details">
                        <i class="fas fa-eye"></i>
                    </button>
                    <button class="btn-action btn-edit" data-collector-id="${collector.Id}" title="Edit Collector">
                        <i class="fas fa-edit"></i>
                    </button>
                    <button class="btn-action btn-delete" data-collector-id="${collector.Id}" title="Delete Collector">
                        <i class="fas fa-trash"></i>
                    </button>
                </div>
            </div>
            <div class="collector-meta">
                <div class="collector-status">
                    <span class="status-badge status-${collector.Status || 'inactive'}">${capitalizeFirst(collector.Status || 'inactive')}</span>
                    <span class="status-badge status-${collector.Availability || 'offline'}">${capitalizeFirst(collector.Availability || 'offline')}</span>
                    <span style="color: rgba(255, 255, 255, 0.5) !important;">• $${earnings.toFixed(2)}</span>
                </div>
                <div class="small" style="color: rgba(255, 255, 255, 0.5) !important;">
                    Joined ${formatDate(collector.RegistrationDate)}
                </div>
            </div>
        `;

        // Add event listeners to action buttons
        card.querySelector('.btn-view').addEventListener('click', function() {
            viewCollector(this.getAttribute('data-collector-id'));
        });
        card.querySelector('.btn-edit').addEventListener('click', function() {
            editCollector(this.getAttribute('data-collector-id'));
        });
        card.querySelector('.btn-delete').addEventListener('click', function() {
            deleteCollector(this.getAttribute('data-collector-id'));
        });

        return card;
    }

    function createTableRow(collector) {
        const row = document.createElement('tr');
        const successRate = collector.TotalPickups > 0
            ? Math.round((collector.CompletedPickups / collector.TotalPickups) * 100)
            : 0;

        const earnings = collector.Earnings || 0;
        const rating = collector.Rating || 0;

        row.innerHTML = `
            <td>
                <div class="d-flex align-items-center gap-3">
                    <div class="collector-avatar">
                        ${escapeHtml((collector.FirstName ? collector.FirstName[0] : 'C') + (collector.LastName ? collector.LastName[0] : ''))}
                    </div>
                    <div>
                        <div class="fw-bold" style="color: #ffffff !important;">${escapeHtml(collector.FirstName || '')} ${escapeHtml(collector.LastName || '')}</div>
                        <div class="small" style="color: rgba(255, 255, 255, 0.6) !important;">${escapeHtml(collector.Email || 'No email')}</div>
                    </div>
                </div>
            </td>
            <td>${escapeHtml(collector.Phone || 'No phone')}</td>
            <td>
                <span class="status-badge status-${collector.Status || 'inactive'}">${capitalizeFirst(collector.Status || 'inactive')}</span>
            </td>
            <td>
                <span class="status-badge status-${collector.Availability || 'offline'}">${capitalizeFirst(collector.Availability || 'offline')}</span>
            </td>
            <td>
                <div style="color: #ffffff !important;">${collector.CompletedPickups || 0}</div>
                <div class="small" style="color: rgba(255, 255, 255, 0.6) !important;">${successRate}% success</div>
            </td>
            <td>
                <div class="fw-bold" style="color: #ffffff !important;">${rating.toFixed(1)}/5.0</div>
                <div class="small" style="color: rgba(255, 255, 255, 0.6) !important;">
                    ${'★'.repeat(Math.floor(rating))}${'☆'.repeat(5-Math.floor(rating))}
                </div>
            </td>
            <td>
                <div class="fw-bold" style="color: #ffffff !important;">$${earnings.toFixed(2)}</div>
            </td>
            <td>${formatDate(collector.RegistrationDate)}</td>
            <td>
                <div class="collector-actions">
                    <button class="btn-action btn-view" data-collector-id="${collector.Id}" title="View Details">
                        <i class="fas fa-eye"></i>
                    </button>
                    <button class="btn-action btn-edit" data-collector-id="${collector.Id}" title="Edit Collector">
                        <i class="fas fa-edit"></i>
                    </button>
                    <button class="btn-action btn-delete" data-collector-id="${collector.Id}" title="Delete Collector">
                        <i class="fas fa-trash"></i>
                    </button>
                </div>
            </td>
        `;

        // Add event listeners to action buttons
        row.querySelector('.btn-view').addEventListener('click', function() {
            viewCollector(this.getAttribute('data-collector-id'));
        });
        row.querySelector('.btn-edit').addEventListener('click', function() {
            editCollector(this.getAttribute('data-collector-id'));
        });
        row.querySelector('.btn-delete').addEventListener('click', function() {
            deleteCollector(this.getAttribute('data-collector-id'));
        });

        return row;
    }

    function updatePagination() {
        const pagination = document.getElementById('pagination');
        const totalPages = Math.ceil(filteredCollectors.length / collectorsPerPage);

        pagination.innerHTML = '';

        if (totalPages <= 1) return;

        const prevLi = document.createElement('li');
        prevLi.className = `page-item ${currentPage === 1 ? 'disabled' : ''}`;
        prevLi.innerHTML = `<a class="page-link" href="javascript:void(0)" data-page="${currentPage - 1}">Previous</a>`;
        pagination.appendChild(prevLi);

        for (let i = 1; i <= totalPages; i++) {
            const li = document.createElement('li');
            li.className = `page-item ${currentPage === i ? 'active' : ''}`;
            li.innerHTML = `<a class="page-link" href="javascript:void(0)" data-page="${i}">${i}</a>`;
            pagination.appendChild(li);
        }

        const nextLi = document.createElement('li');
        nextLi.className = `page-item ${currentPage === totalPages ? 'disabled' : ''}`;
        nextLi.innerHTML = `<a class="page-link" href="javascript:void(0)" data-page="${currentPage + 1}">Next</a>`;
        pagination.appendChild(nextLi);

        // Add event listeners to pagination links
        pagination.querySelectorAll('.page-link').forEach(link => {
            link.addEventListener('click', function() {
                const page = parseInt(this.getAttribute('data-page'));
                changePage(page);
            });
        });

        document.getElementById('paginationInfo').textContent = `Page ${currentPage} of ${totalPages}`;
    }

    function changePage(page) {
        const totalPages = Math.ceil(filteredCollectors.length / collectorsPerPage);
        if (page >= 1 && page <= totalPages) {
            currentPage = page;
            renderCollectors();
            updatePagination();
        }
    }

    function updatePageInfo() {
        const startIndex = (currentPage - 1) * collectorsPerPage + 1;
        const endIndex = Math.min(currentPage * collectorsPerPage, filteredCollectors.length);
        document.getElementById('pageInfo').textContent = `Showing ${startIndex}-${endIndex} of ${filteredCollectors.length} collectors`;
    }

    function showLoading() {
        const grid = document.getElementById('collectorsGrid');
        if (grid) {
            grid.innerHTML = `
                <div class="col-12 text-center py-5">
                    <i class="fas fa-spinner fa-spin fa-2x mb-3" style="color: rgba(255, 255, 255, 0.5) !important;"></i>
                    <p style="color: rgba(255, 255, 255, 0.7) !important;">Loading collectors from database...</p>
                </div>
            `;
        }
    }

    function hideLoading() { }

    // View Collector Modal Functions
    function viewCollector(collectorId) {
        const collector = allCollectors.find(c => c.Id === collectorId);
        if (collector) {
            currentViewCollectorId = collectorId;
            
            const successRate = collector.TotalPickups > 0
                ? Math.round((collector.CompletedPickups / collector.TotalPickups) * 100)
                : 0;
            const earnings = collector.Earnings || 0;
            const rating = collector.Rating || 0;

            // Populate modal with collector data
            document.getElementById('viewCollectorAvatar').innerHTML = 
                escapeHtml((collector.FirstName ? collector.FirstName[0] : 'C') + (collector.LastName ? collector.LastName[0] : ''));
            document.getElementById('viewCollectorName').textContent = `${collector.FirstName || ''} ${collector.LastName || ''}`;
            document.getElementById('viewCollectorEmail').textContent = collector.Email || 'No email';
            document.getElementById('viewCollectorPhone').textContent = collector.Phone || 'No phone';
            document.getElementById('viewCollectorType').textContent = 'Collector';
            document.getElementById('viewCollectorStatus').innerHTML = 
                `<span class="status-badge status-${collector.Status || 'inactive'}">${capitalizeFirst(collector.Status || 'inactive')}</span>`;
            document.getElementById('viewCollectorAvailability').innerHTML = 
                `<span class="status-badge status-${collector.Availability || 'offline'}">${capitalizeFirst(collector.Availability || 'offline')}</span>`;
            document.getElementById('viewCollectorRating').textContent = `${rating.toFixed(1)}/5.0`;
            document.getElementById('viewCollectorRegDate').textContent = formatDate(collector.RegistrationDate);
            document.getElementById('viewCollectorAddress').textContent = collector.Address || 'No address';
            document.getElementById('viewCollectorVehicle').textContent = collector.VehicleInfo || 'No vehicle info';

            // Performance metrics
            document.getElementById('viewTotalPickups').textContent = collector.CompletedPickups || 0;
            document.getElementById('viewSuccessRate').textContent = successRate + '%';
            document.getElementById('viewAvgRating').textContent = rating.toFixed(1);
            document.getElementById('viewTotalEarnings').textContent = '$' + earnings.toFixed(2);
            
            // Show modal
            document.getElementById('viewCollectorModal').style.display = 'block';
        }
    }

    function closeViewCollectorModal() {
        document.getElementById('viewCollectorModal').style.display = 'none';
        currentViewCollectorId = null;
    }

    // Delete Confirmation Modal Functions
    function deleteCollector(collectorId) {
        const collector = allCollectors.find(c => c.Id === collectorId);
        if (collector) {
            currentDeleteCollectorId = collectorId;
            document.getElementById('deleteCollectorName').textContent = `${collector.FirstName || ''} ${collector.LastName || ''}`;
            document.getElementById('deleteCollectorModal').style.display = 'block';
        }
    }

    function closeDeleteModal() {
        document.getElementById('deleteCollectorModal').style.display = 'none';
        currentDeleteCollectorId = null;
    }

    function confirmDelete() {
        if (currentDeleteCollectorId) {
            PageMethods.DeleteCollector(currentDeleteCollectorId, function(response) {
                if (response.startsWith('Success')) {
                    showSuccess('Collector deleted successfully');
                    document.getElementById('<%= btnLoadCollectors.ClientID %>').click();
                } else {
                    showError('Error deleting collector: ' + response);
                }
                closeDeleteModal();
            });
        }
    }

    function editCollector(collectorId) {
        showInfo('Edit functionality will be implemented soon');
    }

    function formatDate(dateString) {
        if (!dateString) return 'Unknown';
        try {
            return new Date(dateString).toLocaleDateString();
        } catch (e) {
            return dateString;
        }
    }

    function capitalizeFirst(string) {
        if (!string) return 'Unknown';
        return string.charAt(0).toUpperCase() + string.slice(1);
    }

    function escapeHtml(unsafe) {
        if (!unsafe) return '';
        return unsafe
            .toString()
            .replace(/&/g, "&amp;")
            .replace(/</g, "&lt;")
            .replace(/>/g, "&gt;")
            .replace(/"/g, "&quot;")
            .replace(/'/g, "&#039;");
    }
   </script>
</asp:Content>