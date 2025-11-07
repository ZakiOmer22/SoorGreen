<%@ Page Title="Collections" Language="C#" MasterPageFile="~/Admin/Site.master" AutoEventWireup="true" CodeFile="Collections.aspx.cs" Inherits="SoorGreen.Admin.Admin.Collections" %>
<%@ Register Assembly="System.Web.Extensions, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35" Namespace="System.Web.UI" TagPrefix="asp" %>

<asp:Content ID="PageTitle" ContentPlaceHolderID="PageTitle" runat="server">
    Waste Collections Management
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <asp:ScriptManager ID="ScriptManager1" runat="server" EnablePageMethods="true"></asp:ScriptManager>
    
    <style>
        .collections-container {
            margin-bottom: 2rem;
        }
        
        .stats-cards {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 1.5rem;
            margin-bottom: 2rem;
        }
        
        .stat-card {
            background: rgba(255, 255, 255, 0.05);
            backdrop-filter: blur(20px);
            border: 1px solid rgba(255, 255, 255, 0.1);
            border-radius: 15px;
            padding: 1.5rem;
            text-align: center;
            transition: all 0.3s ease;
        }
        
        .stat-card:hover {
            transform: translateY(-3px);
            border-color: rgba(0, 212, 170, 0.3);
        }
        
        .stat-value {
            font-size: 2.5rem;
            font-weight: 800;
            color: #ffffff !important;
            margin-bottom: 0.5rem;
        }
        
        .stat-label {
            color: rgba(255, 255, 255, 0.7);
            font-size: 0.9rem;
            font-weight: 600;
        }
        
        .collection-card {
            background: rgba(255, 255, 255, 0.05);
            backdrop-filter: blur(20px);
            border: 1px solid rgba(255, 255, 255, 0.1);
            border-radius: 15px;
            padding: 1.5rem;
            margin-bottom: 1.5rem;
            transition: all 0.3s ease;
        }
        
        .collection-card:hover {
            transform: translateY(-3px);
            border-color: rgba(0, 212, 170, 0.3);
        }
        
        .collection-header {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            margin-bottom: 1rem;
        }
        
        .collection-info {
            flex: 1;
        }
        
        .collection-title {
            font-size: 1.3rem;
            font-weight: 700;
            color: #ffffff !important;
            margin: 0 0 0.5rem 0;
        }
        
        .collection-address {
            color: rgba(255, 255, 255, 0.8) !important;
            margin: 0 0 0.5rem 0;
        }
        
        .collection-actions {
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
        
        .btn-assign {
            background: rgba(13, 110, 253, 0.2);
            border-color: rgba(13, 110, 253, 0.3);
        }
        
        .btn-complete {
            background: rgba(25, 135, 84, 0.2);
            border-color: rgba(25, 135, 84, 0.3);
        }
        
        .btn-cancel {
            background: rgba(220, 53, 69, 0.2);
            border-color: rgba(220, 53, 69, 0.3);
        }
        
        .btn-view {
            background: rgba(108, 117, 125, 0.2);
            border-color: rgba(108, 117, 125, 0.3);
        }
        
        .btn-delete {
            background: rgba(220, 53, 69, 0.2);
            border-color: rgba(220, 53, 69, 0.3);
        }
        
        .btn-delete:hover {
            background: rgba(220, 53, 69, 0.3);
        }
        
        .collection-details {
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
        
        .collection-meta {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding-top: 1rem;
            border-top: 1px solid rgba(255, 255, 255, 0.1);
        }
        
        .collection-status {
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
        
        .status-requested {
            background: rgba(13, 110, 253, 0.2);
            color: #0d6efd;
            border: 1px solid rgba(13, 110, 253, 0.3);
        }
        
        .status-assigned {
            background: rgba(255, 193, 7, 0.2);
            color: #ffc107;
            border: 1px solid rgba(255, 193, 7, 0.3);
        }
        
        .status-completed {
            background: rgba(25, 135, 84, 0.2);
            color: #198754;
            border: 1px solid rgba(25, 135, 84, 0.3);
        }
        
        .status-cancelled {
            background: rgba(220, 53, 69, 0.2);
            color: #dc3545;
            border: 1px solid rgba(220, 53, 69, 0.3);
        }
        
        .table-responsive {
            border-radius: 10px;
            overflow: hidden;
        }
        
        .collections-table {
            width: 100%;
            background: rgba(255, 255, 255, 0.02);
            border-collapse: collapse;
        }
        
        .collections-table th {
            background: rgba(255, 255, 255, 0.1);
            color: #ffffff !important;
            font-weight: 600;
            padding: 1rem;
            text-align: left;
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
        }
        
        .collections-table td {
            padding: 1rem;
            border-bottom: 1px solid rgba(255, 255, 255, 0.05);
            color: rgba(255, 255, 255, 0.8) !important;
        }
        
        .collections-table tr:hover {
            background: rgba(255, 255, 255, 0.03);
        }
        
        .filter-group {
            display: flex;
            gap: 1rem;
            align-items: flex-end;
            flex-wrap: wrap;
            margin-bottom: 2rem;
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
        
        .collections-grid {
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
            max-width: 600px;
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
        
        /* Collection Details Modal Styles */
        .collection-details-container {
            display: flex;
            flex-direction: column;
            gap: 1.5rem;
        }
        
        .collection-info-grid {
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
        
        .collector-avatar {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            background: rgba(255, 255, 255, 0.1);
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: bold;
            color: white;
            overflow: hidden;
        }
        
        .collector-avatar img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }
        
        .collector-info {
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }
        
        .user-avatar {
            width: 35px;
            height: 35px;
            border-radius: 50%;
            background: linear-gradient(135deg, #0d6efd, #0dcaf0);
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: bold;
            color: white;
            font-size: 0.8rem;
        }
        
        .user-avatar.small {
            width: 30px;
            height: 30px;
            font-size: 0.7rem;
        }
        
        @media (max-width: 768px) {
            .collections-grid {
                grid-template-columns: 1fr;
            }
            
            .filter-group {
                flex-direction: column;
            }
            
            .form-group {
                min-width: 100%;
            }
            
            .collection-info-grid {
                grid-template-columns: 1fr;
            }
            
            .stats-cards {
                grid-template-columns: 1fr;
            }
        }
    </style>

    <div class="collections-container">
        <!-- Statistics Cards -->
        <div class="stats-cards">
            <div class="stat-card">
                <div class="stat-value" id="totalCollections">0</div>
                <div class="stat-label">Total Collections</div>
            </div>
            <div class="stat-card">
                <div class="stat-value" id="pendingCollections">0</div>
                <div class="stat-label">Pending</div>
            </div>
            <div class="stat-card">
                <div class="stat-value" id="completedToday">0</div>
                <div class="stat-label">Completed Today</div>
            </div>
            <div class="stat-card">
                <div class="stat-value" id="totalWeight">0kg</div>
                <div class="stat-label">Total Weight</div>
            </div>
        </div>

        <!-- Action Buttons -->
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h2 style="color: #ffffff !important; margin: 0;">Waste Collections</h2>
            <div>
                <button type="button" class="btn-primary me-2" id="generateReportBtn">
                    <i class="fas fa-chart-bar me-2"></i>Generate Report
                </button>
                <button type="button" class="btn-primary" id="addCollectionBtn">
                    <i class="fas fa-plus me-2"></i>Add New Collection
                </button>
            </div>
        </div>

        <div class="filter-card" style="background: rgba(255, 255, 255, 0.05); backdrop-filter: blur(20px); border: 1px solid rgba(255, 255, 255, 0.1); border-radius: 15px; padding: 1.5rem; margin-bottom: 2rem;">
            <h5 class="mb-3" style="color: #ffffff !important;"><i class="fas fa-filter me-2"></i>Filter Collections</h5>
            <div class="filter-group">
                <div class="form-group search-box">
                    <label class="form-label">Search Collections</label>
                    <div class="position-relative">
                        <i class="fas fa-search search-icon"></i>
                        <input type="text" class="form-control search-input" id="searchCollections" placeholder="Search by address, collector, or citizen...">
                    </div>
                </div>
                
                <div class="form-group">
                    <label class="form-label">Status</label>
                    <select class="form-control" id="statusFilter">
                        <option value="all">All Status</option>
                        <option value="requested">Requested</option>
                        <option value="assigned">Assigned</option>
                        <option value="completed">Completed</option>
                        <option value="cancelled">Cancelled</option>
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
                Showing 0 collections
            </div>
        </div>

        <div id="gridView">
            <div class="collections-grid" id="collectionsGrid">
                <!-- Collections will be loaded here -->
            </div>
        </div>

        <div id="tableView" style="display: none;">
            <div class="table-responsive">
                <table class="collections-table" id="collectionsTable">
                    <thead>
                        <tr>
                            <th>Pickup ID</th>
                            <th>Citizen</th>
                            <th>Collector</th>
                            <th>Address</th>
                            <th>Waste Type</th>
                            <th>Weight</th>
                            <th>Status</th>
                            <th>Created</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody id="collectionsTableBody">
                        <!-- Table rows will be loaded here -->
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
                    <!-- Pagination will be generated here -->
                </ul>
            </nav>
        </div>
    </div>

    <!-- View Collection Details Modal -->
    <div class="modal-overlay" id="viewCollectionModal">
        <div class="modal-content" style="max-width: 700px;">
            <div class="modal-header">
                <h3 class="modal-title">Collection Details</h3>
                <button type="button" class="close-modal">&times;</button>
            </div>
            <div class="modal-body">
                <div class="collection-details-container">
                    <div class="collection-info-grid">
                        <div class="info-item">
                            <label>Pickup ID:</label>
                            <span id="viewPickupId">-</span>
                        </div>
                        <div class="info-item">
                            <label>Status:</label>
                            <span id="viewCollectionStatus">-</span>
                        </div>
                        <div class="info-item">
                            <label>Citizen:</label>
                            <div class="collector-info">
                                <div class="user-avatar" id="viewCitizenAvatar">C</div>
                                <span id="viewCitizenName">-</span>
                            </div>
                        </div>
                        <div class="info-item">
                            <label>Collector:</label>
                            <div class="collector-info">
                                <div class="user-avatar" id="viewCollectorAvatar">C</div>
                                <span id="viewCollectorName">-</span>
                            </div>
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
                            <label>Verified Weight:</label>
                            <span id="viewVerifiedWeight">-</span>
                        </div>
                        <div class="info-item">
                            <label>Credits Earned:</label>
                            <span id="viewCreditsEarned">-</span>
                        </div>
                        <div class="info-item full-width">
                            <label>Address:</label>
                            <span id="viewCollectionAddress">-</span>
                        </div>
                        <div class="info-item">
                            <label>Created:</label>
                            <span id="viewCreatedAt">-</span>
                        </div>
                        <div class="info-item">
                            <label>Completed:</label>
                            <span id="viewCompletedAt">-</span>
                        </div>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-action btn-assign" id="assignCollectorBtn">
                    <i class="fas fa-user-plus me-2"></i>Assign Collector
                </button>
                <button type="button" class="btn-action btn-complete" id="completeCollectionBtn">
                    <i class="fas fa-check me-2"></i>Mark Complete
                </button>
                <button type="button" class="btn-action btn-delete" id="deleteCollectionBtn">
                    <i class="fas fa-trash me-2"></i>Delete
                </button>
                <button type="button" class="btn-action" id="closeViewModalBtn">Close</button>
            </div>
        </div>
    </div>

    <!-- Add Collection Modal -->
    <div class="modal-overlay" id="addCollectionModal">
        <div class="modal-content" style="max-width: 600px;">
            <div class="modal-header">
                <h3 class="modal-title">Add New Collection</h3>
                <button type="button" class="close-modal">&times;</button>
            </div>
            <div class="modal-body">
                <div class="add-collection-form">
                    <div class="form-row">
                        <div class="form-half">
                            <label class="form-label">Citizen</label>
                            <select class="form-control" id="addCitizenSelect">
                                <option value="">-- Select Citizen --</option>
                            </select>
                        </div>
                        <div class="form-half">
                            <label class="form-label">Waste Type</label>
                            <select class="form-control" id="addWasteTypeSelect">
                                <option value="">-- Select Waste Type --</option>
                            </select>
                        </div>
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label">Address</label>
                        <input type="text" class="form-control" id="addAddress" placeholder="Enter collection address">
                    </div>
                    
                    <div class="form-row">
                        <div class="form-half">
                            <label class="form-label">Estimated Weight (kg)</label>
                            <input type="number" class="form-control" id="addEstimatedWeight" step="0.01" min="0" placeholder="Enter estimated weight">
                        </div>
                        <div class="form-half">
                            <label class="form-label">Schedule Date</label>
                            <input type="datetime-local" class="form-control" id="addScheduleDate">
                        </div>
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label">Notes (Optional)</label>
                        <textarea class="form-control" id="addNotes" rows="3" placeholder="Any additional notes..."></textarea>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-action" id="cancelAddBtn">Cancel</button>
                <button type="button" class="btn-primary" id="confirmAddBtn">Create Collection</button>
            </div>
        </div>
    </div>

    <!-- Delete Confirmation Modal -->
    <div class="modal-overlay" id="deleteCollectionModal">
        <div class="modal-content" style="max-width: 500px;">
            <div class="modal-header">
                <h3 class="modal-title">Confirm Delete</h3>
                <button type="button" class="close-modal">&times;</button>
            </div>
            <div class="modal-body">
                <p style="color: rgba(255, 255, 255, 0.8) !important;">Are you sure you want to delete this collection? This action cannot be undone.</p>
                <p style="color: rgba(255, 255, 255, 0.6) !important; font-size: 0.9rem;" id="deleteCollectionInfo"></p>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-action" id="cancelDeleteBtn">Cancel</button>
                <button type="button" class="btn-action btn-delete" id="confirmDeleteBtn">Delete Collection</button>
            </div>
        </div>
    </div>

    <!-- Assign Collector Modal -->
    <div class="modal-overlay" id="assignCollectorModal">
        <div class="modal-content" style="max-width: 500px;">
            <div class="modal-header">
                <h3 class="modal-title">Assign Collector</h3>
                <button type="button" class="close-modal">&times;</button>
            </div>
            <div class="modal-body">
                <div class="form-group">
                    <label class="form-label">Select Collector</label>
                    <select class="form-control" id="collectorSelect">
                        <option value="">-- Select Collector --</option>
                    </select>
                </div>
                <div class="form-group">
                    <label class="form-label">Schedule Date & Time</label>
                    <input type="datetime-local" class="form-control" id="scheduleDateTime">
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-action" id="cancelAssignBtn">Cancel</button>
                <button type="button" class="btn-primary" id="confirmAssignBtn">Assign Collector</button>
            </div>
        </div>
    </div>

    <!-- Complete Collection Modal -->
    <div class="modal-overlay" id="completeCollectionModal">
        <div class="modal-content" style="max-width: 500px;">
            <div class="modal-header">
                <h3 class="modal-title">Complete Collection</h3>
                <button type="button" class="close-modal">&times;</button>
            </div>
            <div class="modal-body">
                <div class="form-group">
                    <label class="form-label">Verified Weight (kg)</label>
                    <input type="number" class="form-control" id="verifiedWeight" step="0.01" min="0" placeholder="Enter actual weight collected">
                </div>
                <div class="form-group">
                    <label class="form-label">Material Type</label>
                    <select class="form-control" id="materialTypeSelect">
                        <option value="">-- Select Material --</option>
                    </select>
                </div>
                <div class="form-group">
                    <label class="form-label">Notes (Optional)</label>
                    <textarea class="form-control" id="completionNotes" rows="3" placeholder="Any additional notes..."></textarea>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-action" id="cancelCompleteBtn">Cancel</button>
                <button type="button" class="btn-primary" id="confirmCompleteBtn">Mark as Complete</button>
            </div>
        </div>
    </div>

    <asp:Button ID="btnLoadCollections" runat="server" OnClick="btnLoadCollections_Click" Style="display: none;" />
    <asp:HiddenField ID="hfCollectionsData" runat="server" />
    <asp:HiddenField ID="hfCurrentPage" runat="server" Value="1" />
    <asp:HiddenField ID="hfStatsData" runat="server" />
    <asp:HiddenField ID="hfCollectorsData" runat="server" />
    <asp:HiddenField ID="hfCitizensData" runat="server" />
    <asp:HiddenField ID="hfWasteTypesData" runat="server" />
</asp:Content>

<asp:Content ID="Scripts" ContentPlaceHolderID="Scripts" runat="server">
   <script>
       let currentView = 'grid';
       let currentPage = 1;
       let filteredCollections = [];
       let allCollections = [];
       let allCollectors = [];
       let allCitizens = [];
       let allWasteTypes = [];
       let currentViewCollectionId = null;

       document.addEventListener('DOMContentLoaded', function () {
           loadCollectionsFromServer();
           setupEventListeners();
       });

       function setupEventListeners() {
           // View buttons
           document.querySelectorAll('.view-btn').forEach(btn => {
               btn.addEventListener('click', function () {
                   const view = this.getAttribute('data-view');
                   changeView(view);
               });
           });

           // Filter button
           document.getElementById('applyFiltersBtn').addEventListener('click', function () {
               applyFilters();
           });

           // Search input
           document.getElementById('searchCollections').addEventListener('input', function () {
               applyFilters();
           });

           // Filter dropdowns
           document.getElementById('statusFilter').addEventListener('change', function () {
               applyFilters();
           });

           document.getElementById('dateFilter').addEventListener('change', function () {
               applyFilters();
           });

           // Add collection button
           document.getElementById('addCollectionBtn').addEventListener('click', function () {
               showAddCollectionModal();
           });

           // Close modals
           document.querySelectorAll('.close-modal').forEach(btn => {
               btn.addEventListener('click', function () {
                   this.closest('.modal-overlay').style.display = 'none';
               });
           });

           // Close view modal
           document.getElementById('closeViewModalBtn').addEventListener('click', function () {
               document.getElementById('viewCollectionModal').style.display = 'none';
           });

           // Cancel add collection
           document.getElementById('cancelAddBtn').addEventListener('click', function () {
               document.getElementById('addCollectionModal').style.display = 'none';
           });

           // Add collection
           document.getElementById('confirmAddBtn').addEventListener('click', function () {
               addNewCollection();
           });

           // Assign collector button in view modal
           document.getElementById('assignCollectorBtn').addEventListener('click', function () {
               showAssignCollectorModal();
           });

           // Complete collection button in view modal
           document.getElementById('completeCollectionBtn').addEventListener('click', function () {
               showCompleteCollectionModal();
           });

           // Delete collection button in view modal
           document.getElementById('deleteCollectionBtn').addEventListener('click', function () {
               showDeleteConfirmationModal();
           });

           // Cancel assign collector
           document.getElementById('cancelAssignBtn').addEventListener('click', function () {
               document.getElementById('assignCollectorModal').style.display = 'none';
           });

           // Confirm assign collector
           document.getElementById('confirmAssignBtn').addEventListener('click', function () {
               assignCollector();
           });

           // Cancel complete collection
           document.getElementById('cancelCompleteBtn').addEventListener('click', function () {
               document.getElementById('completeCollectionModal').style.display = 'none';
           });

           // Confirm complete collection
           document.getElementById('confirmCompleteBtn').addEventListener('click', function () {
               completeCollection();
           });

           // Cancel delete
           document.getElementById('cancelDeleteBtn').addEventListener('click', function () {
               document.getElementById('deleteCollectionModal').style.display = 'none';
           });

           // Confirm delete
           document.getElementById('confirmDeleteBtn').addEventListener('click', function () {
               deleteCollection();
           });

           // Generate report
           document.getElementById('generateReportBtn').addEventListener('click', function () {
               generateReport();
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
       }

       function applyFilters() {
           const searchTerm = document.getElementById('searchCollections').value.toLowerCase();
           const statusFilter = document.getElementById('statusFilter').value;
           const dateFilter = document.getElementById('dateFilter').value;

           filteredCollections = allCollections.filter(collection => {
               // Search filter
               const matchesSearch = !searchTerm ||
                   (collection.Address && collection.Address.toLowerCase().includes(searchTerm)) ||
                   (collection.CitizenName && collection.CitizenName.toLowerCase().includes(searchTerm)) ||
                   (collection.CollectorName && collection.CollectorName.toLowerCase().includes(searchTerm)) ||
                   (collection.WasteTypeName && collection.WasteTypeName.toLowerCase().includes(searchTerm));

               // Status filter
               const matchesStatus = statusFilter === 'all' ||
                   (collection.Status && collection.Status.toLowerCase() === statusFilter.toLowerCase());

               // Date filter (simplified)
               let matchesDate = true;
               if (dateFilter !== 'all' && collection.CreatedAt) {
                   const createdDate = new Date(collection.CreatedAt);
                   const today = new Date();

                   if (dateFilter === 'today') {
                       matchesDate = createdDate.toDateString() === today.toDateString();
                   } else if (dateFilter === 'week') {
                       const weekAgo = new Date(today);
                       weekAgo.setDate(today.getDate() - 7);
                       matchesDate = createdDate >= weekAgo;
                   } else if (dateFilter === 'month') {
                       const monthAgo = new Date(today);
                       monthAgo.setMonth(today.getMonth() - 1);
                       matchesDate = createdDate >= monthAgo;
                   }
               }

               return matchesSearch && matchesStatus && matchesDate;
           });

           renderCollections();
       }

       function loadCollectionsFromServer() {
           const collectionsData = document.getElementById('<%= hfCollectionsData.ClientID %>').value;
           const statsData = document.getElementById('<%= hfStatsData.ClientID %>').value;
           const collectorsData = document.getElementById('<%= hfCollectorsData.ClientID %>').value;
           const citizensData = document.getElementById('<%= hfCitizensData.ClientID %>').value;
           const wasteTypesData = document.getElementById('<%= hfWasteTypesData.ClientID %>').value;

           if (collectionsData) {
               allCollections = JSON.parse(collectionsData);
               filteredCollections = allCollections;
           }
           if (collectorsData) allCollectors = JSON.parse(collectorsData);
           if (citizensData) allCitizens = JSON.parse(citizensData);
           if (wasteTypesData) allWasteTypes = JSON.parse(wasteTypesData);
           if (statsData) updateStatistics(JSON.parse(statsData));

           renderCollections();
       }

       function updateStatistics(stats) {
           document.getElementById('totalCollections').textContent = stats.TotalCollections || 0;
           document.getElementById('pendingCollections').textContent = stats.PendingCollections || 0;
           document.getElementById('completedToday').textContent = stats.CompletedToday || 0;
           document.getElementById('totalWeight').textContent = (stats.TotalWeight || 0) + 'kg';
       }

       function renderCollections() {
           const grid = document.getElementById('collectionsGrid');
           const tbody = document.getElementById('collectionsTableBody');

           grid.innerHTML = '';
           tbody.innerHTML = '';

           if (filteredCollections.length === 0) {
               grid.innerHTML = '<div class="col-12 text-center py-5"><i class="fas fa-trash-alt fa-3x mb-3" style="color: rgba(255, 255, 255, 0.5) !important;"></i><h4 style="color: rgba(255, 255, 255, 0.7) !important;">No collections found</h4></div>';
               tbody.innerHTML = '<tr><td colspan="9" class="text-center py-4">No collections found</td></tr>';
               return;
           }

           filteredCollections.forEach(collection => {
               grid.appendChild(createCollectionCard(collection));
               tbody.appendChild(createTableRow(collection));
           });
       }

       function createCollectionCard(collection) {
           const card = document.createElement('div');
           card.className = 'collection-card';
           
           // Get initials for avatar
           const citizenInitial = collection.CitizenName ? collection.CitizenName.charAt(0).toUpperCase() : 'C';
           const collectorInitial = collection.CollectorName ? collection.CollectorName.charAt(0).toUpperCase() : 'N';
           
           card.innerHTML = `
               <div class="collection-header">
                   <div class="collection-info">
                       <h3 class="collection-title">${escapeHtml(collection.WasteTypeName || 'Unknown')}</h3>
                       <p class="collection-address">${escapeHtml(collection.Address || 'No address')}</p>
                   </div>
                   <div class="collection-actions">
                       <button class="btn-action btn-view" data-id="${collection.PickupId}"><i class="fas fa-eye"></i></button>
                       <button class="btn-action btn-assign" data-id="${collection.PickupId}"><i class="fas fa-user-plus"></i></button>
                       <button class="btn-action btn-complete" data-id="${collection.PickupId}"><i class="fas fa-check"></i></button>
                       <button class="btn-action btn-delete" data-id="${collection.PickupId}"><i class="fas fa-trash"></i></button>
                   </div>
               </div>
               <div class="collection-details">
                   <div class="detail-item">
                       <div class="detail-value">${collection.EstimatedKg || 0}kg</div>
                       <div class="detail-label">Estimated Weight</div>
                   </div>
                   <div class="detail-item">
                       <div class="detail-value">${collection.VerifiedKg || '-'}</div>
                       <div class="detail-label">Verified Weight</div>
                   </div>
                   <div class="detail-item">
                       <div class="detail-value">${collection.CreditsEarned || 0}</div>
                       <div class="detail-label">Credits</div>
                   </div>
               </div>
               <div class="collection-meta">
                   <div class="collection-status">
                       <span class="status-badge status-${(collection.Status || 'requested').toLowerCase()}">${collection.Status || 'Requested'}</span>
                       <div class="collector-info">
                           <div class="user-avatar small">${citizenInitial}</div>
                           <span>${escapeHtml(collection.CitizenName || 'Unknown')}</span>
                       </div>
                       ${collection.CollectorName ? `
                       <div class="collector-info">
                           <div class="user-avatar small">${collectorInitial}</div>
                           <span>${escapeHtml(collection.CollectorName)}</span>
                       </div>
                       ` : ''}
                   </div>
                   <span>ID: ${collection.PickupId}</span>
               </div>
           `;

           // Add event listeners to action buttons
           card.querySelector('.btn-view').addEventListener('click', function () {
               viewCollection(this.getAttribute('data-id'));
           });
           card.querySelector('.btn-assign').addEventListener('click', function () {
               currentViewCollectionId = this.getAttribute('data-id');
               showAssignCollectorModal();
           });
           card.querySelector('.btn-complete').addEventListener('click', function () {
               currentViewCollectionId = this.getAttribute('data-id');
               showCompleteCollectionModal();
           });
           card.querySelector('.btn-delete').addEventListener('click', function () {
               currentViewCollectionId = this.getAttribute('data-id');
               showDeleteConfirmationModal();
           });
           
           return card;
       }

       function createTableRow(collection) {
           const row = document.createElement('tr');
           
           // Get initials for avatar
           const citizenInitial = collection.CitizenName ? collection.CitizenName.charAt(0).toUpperCase() : 'C';
           const collectorInitial = collection.CollectorName ? collection.CollectorName.charAt(0).toUpperCase() : 'N';
           
           row.innerHTML = `
               <td>${collection.PickupId}</td>
               <td>
                   <div class="collector-info">
                       <div class="user-avatar small">${citizenInitial}</div>
                       <span>${escapeHtml(collection.CitizenName || 'Unknown')}</span>
                   </div>
               </td>
               <td>
                   ${collection.CollectorName ? `
                   <div class="collector-info">
                       <div class="user-avatar small">${collectorInitial}</div>
                       <span>${escapeHtml(collection.CollectorName)}</span>
                   </div>
                   ` : 'Not assigned'}
               </td>
               <td>${escapeHtml(collection.Address || 'No address')}</td>
               <td>${escapeHtml(collection.WasteTypeName || 'Unknown')}</td>
               <td>${collection.EstimatedKg || 0}kg</td>
               <td><span class="status-badge status-${(collection.Status || 'requested').toLowerCase()}">${collection.Status || 'Requested'}</span></td>
               <td>${collection.CreatedAt ? new Date(collection.CreatedAt).toLocaleDateString() : '-'}</td>
               <td>
                   <button class="btn-action btn-view" data-id="${collection.PickupId}"><i class="fas fa-eye"></i></button>
                   <button class="btn-action btn-assign" data-id="${collection.PickupId}"><i class="fas fa-user-plus"></i></button>
                   <button class="btn-action btn-complete" data-id="${collection.PickupId}"><i class="fas fa-check"></i></button>
                   <button class="btn-action btn-delete" data-id="${collection.PickupId}"><i class="fas fa-trash"></i></button>
               </td>
           `;
           
           // Add event listeners to action buttons
           row.querySelector('.btn-view').addEventListener('click', function () {
               viewCollection(this.getAttribute('data-id'));
           });
           row.querySelector('.btn-assign').addEventListener('click', function () {
               currentViewCollectionId = this.getAttribute('data-id');
               showAssignCollectorModal();
           });
           row.querySelector('.btn-complete').addEventListener('click', function () {
               currentViewCollectionId = this.getAttribute('data-id');
               showCompleteCollectionModal();
           });
           row.querySelector('.btn-delete').addEventListener('click', function () {
               currentViewCollectionId = this.getAttribute('data-id');
               showDeleteConfirmationModal();
           });
           
           return row;
       }

       function viewCollection(id) {
           const collection = allCollections.find(c => c.PickupId === id);
           if (collection) {
               currentViewCollectionId = id;
               
               // Get initials for avatars
               const citizenInitial = collection.CitizenName ? collection.CitizenName.charAt(0).toUpperCase() : 'C';
               const collectorInitial = collection.CollectorName ? collection.CollectorName.charAt(0).toUpperCase() : 'N';
               
               document.getElementById('viewPickupId').textContent = collection.PickupId;
               document.getElementById('viewCollectionStatus').textContent = collection.Status || 'Requested';
               document.getElementById('viewCitizenName').textContent = collection.CitizenName || 'Unknown';
               document.getElementById('viewCitizenAvatar').textContent = citizenInitial;
               document.getElementById('viewCollectorName').textContent = collection.CollectorName || 'Not assigned';
               document.getElementById('viewCollectorAvatar').textContent = collectorInitial;
               document.getElementById('viewWasteType').textContent = collection.WasteTypeName || 'Unknown';
               document.getElementById('viewCollectionAddress').textContent = collection.Address || 'No address';
               document.getElementById('viewEstimatedWeight').textContent = (collection.EstimatedKg || 0) + ' kg';
               document.getElementById('viewVerifiedWeight').textContent = collection.VerifiedKg ? collection.VerifiedKg + ' kg' : '-';
               document.getElementById('viewCreditsEarned').textContent = collection.CreditsEarned || 0;
               document.getElementById('viewCreatedAt').textContent = collection.CreatedAt ? new Date(collection.CreatedAt).toLocaleString() : '-';
               document.getElementById('viewCompletedAt').textContent = collection.CompletedAt ? new Date(collection.CompletedAt).toLocaleString() : '-';
               
               document.getElementById('viewCollectionModal').style.display = 'block';
           }
       }

       function showAddCollectionModal() {
           // Populate citizen dropdown
           const citizenSelect = document.getElementById('addCitizenSelect');
           citizenSelect.innerHTML = '<option value="">-- Select Citizen --</option>';
           allCitizens.forEach(citizen => {
               const option = document.createElement('option');
               option.value = citizen.UserId;
               option.textContent = citizen.FullName;
               citizenSelect.appendChild(option);
           });
           
           // Populate waste type dropdown
           const wasteTypeSelect = document.getElementById('addWasteTypeSelect');
           wasteTypeSelect.innerHTML = '<option value="">-- Select Waste Type --</option>';
           allWasteTypes.forEach(wasteType => {
               const option = document.createElement('option');
               option.value = wasteType.WasteTypeId;
               option.textContent = wasteType.Name;
               wasteTypeSelect.appendChild(option);
           });
           
           document.getElementById('addCollectionModal').style.display = 'block';
       }

       function addNewCollection() {
           const citizenId = document.getElementById('addCitizenSelect').value;
           const wasteTypeId = document.getElementById('addWasteTypeSelect').value;
           const address = document.getElementById('addAddress').value;
           const estimatedWeight = document.getElementById('addEstimatedWeight').value;
           const scheduleDate = document.getElementById('addScheduleDate').value;
           const notes = document.getElementById('addNotes').value;
           
           if (!citizenId || !wasteTypeId || !address || !estimatedWeight) {
               showNotification('Please fill in all required fields', 'error');
               return;
           }
           
           // Call server method to add collection
           PageMethods.AddCollection(citizenId, wasteTypeId, address, estimatedWeight, scheduleDate, notes,
               function (response) {
                   showNotification('Collection added successfully!', 'success');
                   document.getElementById('addCollectionModal').style.display = 'none';
                   // Refresh collections
                   document.getElementById('<%= btnLoadCollections.ClientID %>').click();
               },
               function (error) {
                   showNotification('Error adding collection: ' + error, 'error');
               }
           );
       }

       function showAssignCollectorModal() {
           // Populate collector dropdown
           const collectorSelect = document.getElementById('collectorSelect');
           collectorSelect.innerHTML = '<option value="">-- Select Collector --</option>';
           allCollectors.forEach(collector => {
               const option = document.createElement('option');
               option.value = collector.UserId;
               option.textContent = collector.FullName;
               collectorSelect.appendChild(option);
           });
           
           document.getElementById('assignCollectorModal').style.display = 'block';
       }

       function assignCollector() {
           const collectorId = document.getElementById('collectorSelect').value;
           const scheduleDateTime = document.getElementById('scheduleDateTime').value;
           
           if (!collectorId) {
               showNotification('Please select a collector', 'error');
               return;
           }
           
           // Call server method to assign collector
           PageMethods.AssignCollector(currentViewCollectionId, collectorId, scheduleDateTime,
               function (response) {
                   showNotification('Collector assigned successfully!', 'success');
                   document.getElementById('assignCollectorModal').style.display = 'none';
                   document.getElementById('viewCollectionModal').style.display = 'none';
                   // Refresh collections
                   document.getElementById('<%= btnLoadCollections.ClientID %>').click();
               },
               function (error) {
                   showNotification('Error assigning collector: ' + error, 'error');
               }
           );
       }

       function showCompleteCollectionModal() {
           document.getElementById('completeCollectionModal').style.display = 'block';
       }

       function completeCollection() {
           const verifiedWeight = document.getElementById('verifiedWeight').value;
           const materialType = document.getElementById('materialTypeSelect').value;
           const notes = document.getElementById('completionNotes').value;
           
           if (!verifiedWeight) {
               showNotification('Please enter the verified weight', 'error');
               return;
           }
           
           // Call server method to complete collection
           PageMethods.CompleteCollection(currentViewCollectionId, verifiedWeight, materialType, notes,
               function (response) {
                   showNotification('Collection marked as complete!', 'success');
                   document.getElementById('completeCollectionModal').style.display = 'none';
                   document.getElementById('viewCollectionModal').style.display = 'none';
                   // Refresh collections
                   document.getElementById('<%= btnLoadCollections.ClientID %>').click();
               },
               function (error) {
                   showNotification('Error completing collection: ' + error, 'error');
               }
           );
       }

       function showDeleteConfirmationModal() {
           const collection = allCollections.find(c => c.PickupId === currentViewCollectionId);
           if (collection) {
               document.getElementById('deleteCollectionInfo').textContent = 
                   `Collection ID: ${collection.PickupId} - ${collection.WasteTypeName || 'Unknown'} waste at ${collection.Address || 'Unknown address'}`;
           }
           document.getElementById('deleteCollectionModal').style.display = 'block';
       }

       function deleteCollection() {
           // Call server method to delete collection
           PageMethods.DeleteCollection(currentViewCollectionId,
               function (response) {
                   showNotification('Collection deleted successfully!', 'success');
                   document.getElementById('deleteCollectionModal').style.display = 'none';
                   document.getElementById('viewCollectionModal').style.display = 'none';
                   // Refresh collections
                   document.getElementById('<%= btnLoadCollections.ClientID %>').click();
               },
               function (error) {
                   showNotification('Error deleting collection: ' + error, 'error');
               }
           );
       }

       function generateReport() {
           showNotification('Report generation started. You will be notified when it is ready.', 'info');
           // In a real implementation, this would trigger report generation
       }

       function showNotification(message, type) {
           // Remove any existing notifications
           const existingNotifications = document.querySelectorAll('.custom-notification');
           existingNotifications.forEach(notification => notification.remove());

           const notification = document.createElement('div');
           notification.className = `custom-notification notification-${type}`;
           notification.innerHTML = `
               <i class="fas ${type === 'success' ? 'fa-check-circle' : type === 'error' ? 'fa-exclamation-circle' : 'fa-info-circle'}"></i>
               <span>${message}</span>
               <button onclick="this.parentElement.remove()">&times;</button>
           `;

           document.body.appendChild(notification);

           // Auto remove after 5 seconds
           setTimeout(() => {
               if (notification.parentElement) {
                   notification.remove();
               }
           }, 5000);
       }

       // Escape HTML to prevent text corruption
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