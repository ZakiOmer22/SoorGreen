<%@ Page Title="Pickups" Language="C#" MasterPageFile="~/Admin/Site.master" AutoEventWireup="true" CodeFile="Pickups.aspx.cs" Inherits="SoorGreen.Admin.Admin.Pickups" %>
<%@ Register Assembly="System.Web.Extensions, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35" Namespace="System.Web.UI" TagPrefix="asp" %>

<asp:Content ID="PageTitle" ContentPlaceHolderID="PageTitle" runat="server">
    Pickup Management
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <asp:ScriptManager ID="ScriptManager1" runat="server" EnablePageMethods="true"></asp:ScriptManager>
    
    <style>
        .pickups-container {
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
        
        .pickup-card {
            background: rgba(255, 255, 255, 0.05);
            backdrop-filter: blur(20px);
            border: 1px solid rgba(255, 255, 255, 0.1);
            border-radius: 15px;
            padding: 1.5rem;
            margin-bottom: 1.5rem;
            transition: all 0.3s ease;
        }
        
        .pickup-card:hover {
            transform: translateY(-3px);
            border-color: rgba(0, 212, 170, 0.3);
        }
        
        .pickup-header {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            margin-bottom: 1rem;
        }
        
        .pickup-info {
            flex: 1;
        }
        
        .pickup-title {
            font-size: 1.3rem;
            font-weight: 700;
            color: #ffffff !important;
            margin: 0 0 0.5rem 0;
        }
        
        .pickup-address {
            color: rgba(255, 255, 255, 0.8) !important;
            margin: 0 0 0.5rem 0;
        }
        
        .pickup-actions {
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
        
        .btn-assign {
            background: rgba(255, 193, 7, 0.2);
            border-color: rgba(255, 193, 7, 0.3);
        }
        
        .btn-complete {
            background: rgba(32, 201, 151, 0.2);
            border-color: rgba(32, 201, 151, 0.3);
        }
        
        .pickup-details {
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
        
        .pickup-meta {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding-top: 1rem;
            border-top: 1px solid rgba(255, 255, 255, 0.1);
        }
        
        .pickup-status {
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
        
        .status-collected {
            background: rgba(25, 135, 84, 0.2);
            color: #198754;
            border: 1px solid rgba(25, 135, 84, 0.3);
        }
        
        .status-cancelled {
            background: rgba(108, 117, 125, 0.2);
            color: #6c757d;
            border: 1px solid rgba(108, 117, 125, 0.3);
        }
        
        .status-completed {
            background: rgba(32, 201, 151, 0.2);
            color: #20c997;
            border: 1px solid rgba(32, 201, 151, 0.3);
        }
        
        .table-responsive {
            border-radius: 10px;
            overflow: hidden;
        }
        
        .pickups-table {
            width: 100%;
            background: rgba(255, 255, 255, 0.02);
            border-collapse: collapse;
        }
        
        .pickups-table th {
            background: rgba(255, 255, 255, 0.1);
            color: #ffffff !important;
            font-weight: 600;
            padding: 1rem;
            text-align: left;
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
        }
        
        .pickups-table td {
            padding: 1rem;
            border-bottom: 1px solid rgba(255, 255, 255, 0.05);
            color: rgba(255, 255, 255, 0.8) !important;
        }
        
        .pickups-table tr:hover {
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
        
        .pickups-grid {
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
        
        /* Pickup Details Modal Styles */
        .pickup-details-container {
            display: flex;
            flex-direction: column;
            gap: 1.5rem;
        }
        
        .pickup-info-grid {
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
        
        @media (max-width: 768px) {
            .pickups-grid {
                grid-template-columns: 1fr;
            }
            
            .filter-group {
                flex-direction: column;
            }
            
            .form-group {
                min-width: 100%;
            }
            
            .pickup-info-grid {
                grid-template-columns: 1fr;
            }
        }
    </style>

    <div class="pickups-container">
        <div class="filter-card">
            <h5 class="mb-3" style="color: #ffffff !important;"><i class="fas fa-filter me-2"></i>Filter Pickups</h5>
            <div class="filter-group">
                <div class="form-group search-box">
                    <label class="form-label">Search Pickups</label>
                    <div class="position-relative">
                        <i class="fas fa-search search-icon"></i>
                        <input type="text" class="form-control search-input" id="searchPickups" placeholder="Search by address, citizen, or collector...">
                    </div>
                </div>
                
                <div class="form-group">
                    <label class="form-label">Status</label>
                    <select class="form-control" id="statusFilter">
                        <option value="all">All Status</option>
                        <option value="Requested">Requested</option>
                        <option value="Assigned">Assigned</option>
                        <option value="Collected">Collected</option>
                        <option value="Completed">Completed</option>
                        <option value="Cancelled">Cancelled</option>
                    </select>
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
            
            <!-- ADD BUTTON HERE -->
            <button type="button" class="btn-add" id="addPickupBtn">
                <i class="fas fa-plus me-2"></i>Add New Pickup
            </button>
            
            <div class="page-info" id="pageInfo">
                Showing 0 pickups
            </div>
        </div>

        <div id="gridView">
            <div class="pickups-grid" id="pickupsGrid">
            </div>
        </div>

        <div id="tableView" style="display: none;">
            <div class="table-responsive">
                <table class="pickups-table" id="pickupsTable">
                    <thead>
                        <tr>
                            <th>Pickup ID</th>
                            <th>Citizen</th>
                            <th>Collector</th>
                            <th>Address</th>
                            <th>Waste Type</th>
                            <th>Weight (kg)</th>
                            <th>Status</th>
                            <th>Requested</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody id="pickupsTableBody">
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

    <!-- View Pickup Details Modal -->
    <div class="modal-overlay" id="viewPickupModal">
        <div class="modal-content" style="max-width: 700px;">
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
                            <label>Status:</label>
                            <span id="viewPickupStatus">-</span>
                        </div>
                        <div class="info-item">
                            <label>Citizen:</label>
                            <span id="viewCitizenName">-</span>
                        </div>
                        <div class="info-item">
                            <label>Collector:</label>
                            <span id="viewCollectorName">-</span>
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
                            <label>Actual Weight:</label>
                            <span id="viewActualWeight">-</span>
                        </div>
                        <div class="info-item">
                            <label>Credits Earned:</label>
                            <span id="viewCreditsEarned">-</span>
                        </div>
                        <div class="info-item">
                            <label>Requested Date:</label>
                            <span id="viewRequestedDate">-</span>
                        </div>
                        <div class="info-item">
                            <label>Scheduled Date:</label>
                            <span id="viewScheduledDate">-</span>
                        </div>
                        <div class="info-item">
                            <label>Completed Date:</label>
                            <span id="viewCompletedDate">-</span>
                        </div>
                        <div class="info-item full-width">
                            <label>Address:</label>
                            <span id="viewPickupAddress">-</span>
                        </div>
                        <div class="info-item full-width">
                            <label>Notes:</label>
                            <span id="viewPickupNotes">-</span>
                        </div>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-action" id="closeViewModalBtn">Close</button>
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
                        <option value="">Select a collector...</option>
                    </select>
                </div>
                <div class="form-group">
                    <label class="form-label">Scheduled Date & Time</label>
                    <input type="datetime-local" class="form-control" id="scheduledDateTime">
                </div>
                <div class="form-group">
                    <label class="form-label">Notes (Optional)</label>
                    <textarea class="form-control" id="assignmentNotes" rows="3" placeholder="Add any special instructions..."></textarea>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-action" id="cancelAssignBtn">Cancel</button>
                <button type="button" class="btn-primary" id="confirmAssignBtn">Assign Collector</button>
            </div>
        </div>
    </div>

    <!-- Complete Pickup Modal -->
    <div class="modal-overlay" id="completePickupModal">
        <div class="modal-content" style="max-width: 500px;">
            <div class="modal-header">
                <h3 class="modal-title">Complete Pickup</h3>
                <button type="button" class="close-modal">&times;</button>
            </div>
            <div class="modal-body">
                <div class="form-group">
                    <label class="form-label">Actual Weight (kg)</label>
                    <input type="number" class="form-control" id="actualWeight" step="0.1" min="0" placeholder="Enter actual weight collected">
                </div>
                <div class="form-group">
                    <label class="form-label">Waste Type Confirmation</label>
                    <select class="form-control" id="confirmedWasteType">
                        <option value="Plastic">Plastic</option>
                        <option value="Paper">Paper</option>
                        <option value="Glass">Glass</option>
                        <option value="Metal">Metal</option>
                        <option value="Organic">Organic</option>
                    </select>
                </div>
                <div class="form-group">
                    <label class="form-label">Completion Notes</label>
                    <textarea class="form-control" id="completionNotes" rows="3" placeholder="Add completion notes..."></textarea>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-action" id="cancelCompleteBtn">Cancel</button>
                <button type="button" class="btn-primary" id="confirmCompleteBtn">Complete Pickup</button>
            </div>
        </div>
    </div>

    <!-- Delete Confirmation Modal -->
    <div class="modal-overlay" id="deletePickupModal">
        <div class="modal-content" style="max-width: 500px;">
            <div class="modal-header">
                <h3 class="modal-title">Confirm Delete</h3>
                <button type="button" class="close-modal">&times;</button>
            </div>
            <div class="modal-body">
                <div class="text-center">
                    <i class="fas fa-exclamation-triangle fa-3x text-warning mb-3"></i>
                    <h4>Are you sure?</h4>
                    <p>You are about to delete pickup: <strong id="deletePickupId">-</strong></p>
                    <p class="text-muted">This action cannot be undone.</p>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-action" id="cancelDeleteBtn" style="flex: 1;">Cancel</button>
                <button type="button" class="btn-primary" id="confirmDeleteBtn" style="flex: 1;">Delete Pickup</button>
            </div>
        </div>
    </div>

    <!-- Add New Pickup Modal -->
    <div class="modal-overlay" id="addPickupModal">
        <div class="modal-content" style="max-width: 600px;">
            <div class="modal-header">
                <h3 class="modal-title">Add New Pickup</h3>
                <button type="button" class="close-modal">&times;</button>
            </div>
            <div class="modal-body">
                <div class="form-group">
                    <label class="form-label">Citizen</label>
                    <select class="form-control" id="citizenSelect">
                        <option value="">Select a citizen...</option>
                    </select>
                </div>
                <div class="form-row">
                    <div class="form-half">
                        <label class="form-label">Waste Type</label>
                        <select class="form-control" id="newWasteType">
                            <option value="Plastic">Plastic</option>
                            <option value="Paper">Paper</option>
                            <option value="Glass">Glass</option>
                            <option value="Metal">Metal</option>
                            <option value="Organic">Organic</option>
                        </select>
                    </div>
                    <div class="form-half">
                        <label class="form-label">Estimated Weight (kg)</label>
                        <input type="number" class="form-control" id="estimatedWeight" step="0.1" min="0" placeholder="Enter estimated weight">
                    </div>
                </div>
                <div class="form-group">
                    <label class="form-label">Address</label>
                    <textarea class="form-control" id="pickupAddress" rows="3" placeholder="Enter pickup address"></textarea>
                </div>
                <div class="form-group">
                    <label class="form-label">Notes (Optional)</label>
                    <textarea class="form-control" id="pickupNotes" rows="3" placeholder="Add any notes..."></textarea>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-action" id="cancelAddBtn">Cancel</button>
                <button type="button" class="btn-primary" id="confirmAddBtn">Create Pickup</button>
            </div>
        </div>
    </div>

    <asp:Button ID="btnLoadPickups" runat="server" OnClick="LoadPickups" Style="display: none;" />
    <asp:HiddenField ID="hfPickupsData" runat="server" />
    <asp:HiddenField ID="hfCurrentPage" runat="server" Value="1" />
    <asp:HiddenField ID="hfCollectorsList" runat="server" />
    <asp:HiddenField ID="hfCitizensList" runat="server" />
</asp:Content>

<asp:Content ID="Scripts" ContentPlaceHolderID="Scripts" runat="server">
   <script>
       // GLOBAL VARIABLES
       let currentView = 'grid';
       let currentPage = 1;
       const pickupsPerPage = 6;
       let filteredPickups = [];
       let allPickups = [];
       let allCollectors = [];
       let allCitizens = [];
       let currentViewPickupId = null;
       let currentDeletePickupId = null;
       let currentAssignPickupId = null;
       let currentCompletePickupId = null;

       // INITIALIZE
       document.addEventListener('DOMContentLoaded', function () {
           initializeEventListeners();
           loadPickupsFromServer();
           loadCollectorsFromServer();
           loadCitizensFromServer();
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
           document.getElementById('searchPickups').addEventListener('input', function (e) {
               applyFilters();
           });

           // Filter dropdowns
           document.getElementById('statusFilter').addEventListener('change', function (e) {
               applyFilters();
           });

           document.getElementById('wasteTypeFilter').addEventListener('change', function (e) {
               applyFilters();
           });

           document.getElementById('dateFilter').addEventListener('change', function (e) {
               applyFilters();
           });

           // Modal close buttons
           document.querySelector('#viewPickupModal .close-modal').addEventListener('click', closeViewPickupModal);
           document.querySelector('#assignCollectorModal .close-modal').addEventListener('click', closeAssignModal);
           document.querySelector('#completePickupModal .close-modal').addEventListener('click', closeCompleteModal);
           document.querySelector('#deletePickupModal .close-modal').addEventListener('click', closeDeleteModal);
           document.querySelector('#addPickupModal .close-modal').addEventListener('click', closeAddModal);

           document.getElementById('closeViewModalBtn').addEventListener('click', closeViewPickupModal);
           document.getElementById('cancelAssignBtn').addEventListener('click', closeAssignModal);
           document.getElementById('cancelCompleteBtn').addEventListener('click', closeCompleteModal);
           document.getElementById('cancelDeleteBtn').addEventListener('click', closeDeleteModal);
           document.getElementById('cancelAddBtn').addEventListener('click', closeAddModal);

           document.getElementById('confirmAssignBtn').addEventListener('click', confirmAssign);
           document.getElementById('confirmCompleteBtn').addEventListener('click', confirmComplete);
           document.getElementById('confirmDeleteBtn').addEventListener('click', confirmDelete);
           document.getElementById('confirmAddBtn').addEventListener('click', confirmAddPickup);

           // Add pickup button
           document.getElementById('addPickupBtn').addEventListener('click', openAddModal);

           // Close modals when clicking outside
           document.getElementById('viewPickupModal').addEventListener('click', function (e) {
               if (e.target === this) closeViewPickupModal();
           });
           document.getElementById('assignCollectorModal').addEventListener('click', function (e) {
               if (e.target === this) closeAssignModal();
           });
           document.getElementById('completePickupModal').addEventListener('click', function (e) {
               if (e.target === this) closeCompleteModal();
           });
           document.getElementById('deletePickupModal').addEventListener('click', function (e) {
               if (e.target === this) closeDeleteModal();
           });
           document.getElementById('addPickupModal').addEventListener('click', function (e) {
               if (e.target === this) closeAddModal();
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

           renderPickups();
       }

       function loadPickupsFromServer() {
           showLoading();

           const pickupsData = document.getElementById('<%= hfPickupsData.ClientID %>').value;

           if (pickupsData && pickupsData !== '') {
               try {
                   allPickups = JSON.parse(pickupsData);
                   filteredPickups = [...allPickups];

                   renderPickups();
                   updatePagination();
                   updatePageInfo();
                   hideLoading();

                   if (filteredPickups.length > 0) {
                       showSuccess('Loaded ' + filteredPickups.length + ' pickups from database');
                   } else {
                       showInfo('No pickups found in database');
                   }

               } catch (e) {
                   console.error('Error parsing pickup data:', e);
                   showError('Error loading pickup data from database');
                   hideLoading();
               }
           } else {
               showError('No pickup data available from database');
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

       function loadCitizensFromServer() {
           const citizensData = document.getElementById('<%= hfCitizensList.ClientID %>').value;
           if (citizensData && citizensData !== '') {
               try {
                   allCitizens = JSON.parse(citizensData);
                   populateCitizenSelect();
               } catch (e) {
                   console.error('Error parsing citizens data:', e);
               }
           }
       }

       function populateCollectorSelect() {
           const select = document.getElementById('collectorSelect');
           select.innerHTML = '<option value="">Select a collector...</option>';

           allCollectors.forEach(collector => {
               const option = document.createElement('option');
               option.value = collector.Id;
               option.textContent = `${collector.FirstName} ${collector.LastName} (${collector.Status})`;
               select.appendChild(option);
           });
       }

       function populateCitizenSelect() {
           const select = document.getElementById('citizenSelect');
           select.innerHTML = '<option value="">Select a citizen...</option>';

           allCitizens.forEach(citizen => {
               const option = document.createElement('option');
               option.value = citizen.Id;
               option.textContent = `${citizen.FirstName} ${citizen.LastName} (${citizen.Phone})`;
               select.appendChild(option);
           });
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
           const searchTerm = document.getElementById('searchPickups').value.toLowerCase();
           const statusFilter = document.getElementById('statusFilter').value;
           const wasteTypeFilter = document.getElementById('wasteTypeFilter').value;

           filteredPickups = allPickups.filter(pickup => {
               const matchesSearch = !searchTerm ||
                   (pickup.Address && pickup.Address.toLowerCase().includes(searchTerm)) ||
                   (pickup.CitizenName && pickup.CitizenName.toLowerCase().includes(searchTerm)) ||
                   (pickup.CollectorName && pickup.CollectorName.toLowerCase().includes(searchTerm));

               const matchesStatus = statusFilter === 'all' || pickup.Status === statusFilter;
               const matchesWasteType = wasteTypeFilter === 'all' || pickup.WasteType === wasteTypeFilter;

               return matchesSearch && matchesStatus && matchesWasteType;
           });

           currentPage = 1;
           renderPickups();
           updatePagination();
           updatePageInfo();
       }

       function renderPickups() {
           if (currentView === 'grid') {
               renderGridView();
           } else {
               renderTableView();
           }
       }

       function renderGridView() {
           const grid = document.getElementById('pickupsGrid');
           const startIndex = (currentPage - 1) * pickupsPerPage;
           const endIndex = startIndex + pickupsPerPage;
           const pickupsToShow = filteredPickups.slice(startIndex, endIndex);

           grid.innerHTML = '';

           if (pickupsToShow.length === 0) {
               grid.innerHTML = `
                <div class="col-12 text-center py-5">
                    <i class="fas fa-truck-loading fa-3x mb-3" style="color: rgba(255, 255, 255, 0.5) !important;"></i>
                    <h4 style="color: rgba(255, 255, 255, 0.7) !important;">No pickups found</h4>
                    <p style="color: rgba(255, 255, 255, 0.5) !important;">Try adjusting your filters or search terms</p>
                </div>
            `;
               return;
           }

           pickupsToShow.forEach(pickup => {
               const pickupCard = createPickupCard(pickup);
               grid.appendChild(pickupCard);
           });
       }

       function renderTableView() {
           const tbody = document.getElementById('pickupsTableBody');
           const startIndex = (currentPage - 1) * pickupsPerPage;
           const endIndex = startIndex + pickupsPerPage;
           const pickupsToShow = filteredPickups.slice(startIndex, endIndex);

           tbody.innerHTML = '';

           if (pickupsToShow.length === 0) {
               tbody.innerHTML = `
                <tr>
                    <td colspan="9" class="text-center py-4">
                        <i class="fas fa-truck-loading fa-2x mb-2" style="color: rgba(255, 255, 255, 0.5) !important;"></i>
                        <h5 style="color: rgba(255, 255, 255, 0.7) !important;">No pickups found</h5>
                        <p style="color: rgba(255, 255, 255, 0.5) !important;">Try adjusting your filters or search terms</p>
                    </td>
                </tr>
            `;
               return;
           }

           pickupsToShow.forEach(pickup => {
               const row = createTableRow(pickup);
               tbody.appendChild(row);
           });
       }

       function createPickupCard(pickup) {
           const card = document.createElement('div');
           card.className = 'pickup-card';

           const creditsEarned = pickup.ActualWeight * (pickup.CreditRate || 5);

           card.innerHTML = `
            <div class="pickup-header">
                <div class="pickup-info">
                    <h3 class="pickup-title">Pickup #${pickup.PickupId}</h3>
                    <p class="pickup-address">${escapeHtml(pickup.Address || 'No address')}</p>
                    <div class="pickup-details">
                        <div class="detail-item">
                            <div class="detail-value">${pickup.EstimatedWeight || 0}kg</div>
                            <div class="detail-label">Estimated</div>
                        </div>
                        <div class="detail-item">
                            <div class="detail-value">${pickup.ActualWeight || 0}kg</div>
                            <div class="detail-label">Actual</div>
                        </div>
                        <div class="detail-item">
                            <div class="detail-value">${creditsEarned.toFixed(0)}</div>
                            <div class="detail-label">Credits</div>
                        </div>
                        <div class="detail-item">
                            <div class="detail-value">${pickup.WasteType || 'Unknown'}</div>
                            <div class="detail-label">Waste Type</div>
                        </div>
                    </div>
                </div>
                <div class="pickup-actions">
                    <button class="btn-action btn-view" data-pickup-id="${pickup.PickupId}" title="View Details">
                        <i class="fas fa-eye"></i>
                    </button>
                    ${pickup.Status === 'Requested' ? `
                        <button class="btn-action btn-assign" data-pickup-id="${pickup.PickupId}" title="Assign Collector">
                            <i class="fas fa-user-check"></i>
                        </button>
                    ` : ''}
                    ${pickup.Status === 'Assigned' ? `
                        <button class="btn-action btn-complete" data-pickup-id="${pickup.PickupId}" title="Complete Pickup">
                            <i class="fas fa-check-circle"></i>
                        </button>
                    ` : ''}
                    <button class="btn-action btn-delete" data-pickup-id="${pickup.PickupId}" title="Delete Pickup">
                        <i class="fas fa-trash"></i>
                    </button>
                </div>
            </div>
            <div class="pickup-meta">
                <div class="pickup-status">
                    <span class="status-badge status-${pickup.Status?.toLowerCase() || 'requested'}">${pickup.Status || 'Requested'}</span>
                    <span style="color: rgba(255, 255, 255, 0.5) !important;">
                        ${pickup.CitizenName || 'Unknown Citizen'} → ${pickup.CollectorName || 'Unassigned'}
                    </span>
                </div>
                <div class="small" style="color: rgba(255, 255, 255, 0.5) !important;">
                    ${formatDate(pickup.RequestedDate)}
                </div>
            </div>
        `;

           // Add event listeners to action buttons
           card.querySelector('.btn-view').addEventListener('click', function () {
               viewPickup(this.getAttribute('data-pickup-id'));
           });

           const assignBtn = card.querySelector('.btn-assign');
           if (assignBtn) {
               assignBtn.addEventListener('click', function () {
                   assignCollector(this.getAttribute('data-pickup-id'));
               });
           }

           const completeBtn = card.querySelector('.btn-complete');
           if (completeBtn) {
               completeBtn.addEventListener('click', function () {
                   completePickup(this.getAttribute('data-pickup-id'));
               });
           }

           card.querySelector('.btn-delete').addEventListener('click', function () {
               deletePickup(this.getAttribute('data-pickup-id'));
           });

           return card;
       }

       function createTableRow(pickup) {
           const row = document.createElement('tr');
           const creditsEarned = pickup.ActualWeight * (pickup.CreditRate || 5);

           row.innerHTML = `
            <td>${pickup.PickupId}</td>
            <td>
                <div class="d-flex align-items-center gap-3">
                    <div class="user-avatar">
                        ${escapeHtml((pickup.CitizenName ? pickup.CitizenName[0] : 'U') + (pickup.CitizenName ? pickup.CitizenName.split(' ')[1]?.[0] || '' : ''))}
                    </div>
                    <div>
                        <div class="fw-bold" style="color: #ffffff !important;">${escapeHtml(pickup.CitizenName || 'Unknown')}</div>
                    </div>
                </div>
            </td>
            <td>
                ${pickup.CollectorName ? `
                    <div class="d-flex align-items-center gap-3">
                        <div class="collector-avatar">
                            ${escapeHtml((pickup.CollectorName ? pickup.CollectorName[0] : 'C') + (pickup.CollectorName ? pickup.CollectorName.split(' ')[1]?.[0] || '' : ''))}
                        </div>
                        <div>
                            <div class="fw-bold" style="color: #ffffff !important;">${escapeHtml(pickup.CollectorName)}</div>
                        </div>
                    </div>
                ` : '<span style="color: rgba(255, 255, 255, 0.5) !important;">Unassigned</span>'}
            </td>
            <td>${escapeHtml(pickup.Address || 'No address')}</td>
            <td>${pickup.WasteType || 'Unknown'}</td>
            <td>
                <div style="color: #ffffff !important;">${pickup.ActualWeight || pickup.EstimatedWeight || 0}kg</div>
                ${pickup.ActualWeight ? `<div class="small" style="color: rgba(255, 255, 255, 0.6) !important;">${creditsEarned.toFixed(0)} credits</div>` : ''}
            </td>
            <td>
                <span class="status-badge status-${pickup.Status?.toLowerCase() || 'requested'}">${pickup.Status || 'Requested'}</span>
            </td>
            <td>${formatDate(pickup.RequestedDate)}</td>
            <td>
                <div class="pickup-actions">
                    <button class="btn-action btn-view" data-pickup-id="${pickup.PickupId}" title="View Details">
                        <i class="fas fa-eye"></i>
                    </button>
                    ${pickup.Status === 'Requested' ? `
                        <button class="btn-action btn-assign" data-pickup-id="${pickup.PickupId}" title="Assign Collector">
                            <i class="fas fa-user-check"></i>
                        </button>
                    ` : ''}
                    ${pickup.Status === 'Assigned' ? `
                        <button class="btn-action btn-complete" data-pickup-id="${pickup.PickupId}" title="Complete Pickup">
                            <i class="fas fa-check-circle"></i>
                        </button>
                    ` : ''}
                    <button class="btn-action btn-delete" data-pickup-id="${pickup.PickupId}" title="Delete Pickup">
                        <i class="fas fa-trash"></i>
                    </button>
                </div>
            </td>
        `;

           // Add event listeners to action buttons
           row.querySelector('.btn-view').addEventListener('click', function () {
               viewPickup(this.getAttribute('data-pickup-id'));
           });

           const assignBtn = row.querySelector('.btn-assign');
           if (assignBtn) {
               assignBtn.addEventListener('click', function () {
                   assignCollector(this.getAttribute('data-pickup-id'));
               });
           }

           const completeBtn = row.querySelector('.btn-complete');
           if (completeBtn) {
               completeBtn.addEventListener('click', function () {
                   completePickup(this.getAttribute('data-pickup-id'));
               });
           }

           row.querySelector('.btn-delete').addEventListener('click', function () {
               deletePickup(this.getAttribute('data-pickup-id'));
           });

           return row;
       }

       function updatePagination() {
           const pagination = document.getElementById('pagination');
           const totalPages = Math.ceil(filteredPickups.length / pickupsPerPage);

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
               link.addEventListener('click', function () {
                   const page = parseInt(this.getAttribute('data-page'));
                   changePage(page);
               });
           });

           document.getElementById('paginationInfo').textContent = `Page ${currentPage} of ${totalPages}`;
       }

       function changePage(page) {
           const totalPages = Math.ceil(filteredPickups.length / pickupsPerPage);
           if (page >= 1 && page <= totalPages) {
               currentPage = page;
               renderPickups();
               updatePagination();
           }
       }

       function updatePageInfo() {
           const startIndex = (currentPage - 1) * pickupsPerPage + 1;
           const endIndex = Math.min(currentPage * pickupsPerPage, filteredPickups.length);
           document.getElementById('pageInfo').textContent = `Showing ${startIndex}-${endIndex} of ${filteredPickups.length} pickups`;
       }

       function showLoading() {
           const grid = document.getElementById('pickupsGrid');
           if (grid) {
               grid.innerHTML = `
                <div class="col-12 text-center py-5">
                    <i class="fas fa-spinner fa-spin fa-2x mb-3" style="color: rgba(255, 255, 255, 0.5) !important;"></i>
                    <p style="color: rgba(255, 255, 255, 0.7) !important;">Loading pickups from database...</p>
                </div>
            `;
           }
       }

       function hideLoading() { }

       // View Pickup Modal Functions
       function viewPickup(pickupId) {
           const pickup = allPickups.find(p => p.PickupId === pickupId);
           if (pickup) {
               currentViewPickupId = pickupId;

               const creditsEarned = pickup.ActualWeight * (pickup.CreditRate || 5);

               // Populate modal with pickup data
               document.getElementById('viewPickupId').textContent = pickup.PickupId;
               document.getElementById('viewPickupStatus').innerHTML =
                   `<span class="status-badge status-${pickup.Status?.toLowerCase() || 'requested'}">${pickup.Status || 'Requested'}</span>`;
               document.getElementById('viewCitizenName').textContent = pickup.CitizenName || 'Unknown';
               document.getElementById('viewCollectorName').textContent = pickup.CollectorName || 'Unassigned';
               document.getElementById('viewWasteType').textContent = pickup.WasteType || 'Unknown';
               document.getElementById('viewEstimatedWeight').textContent = (pickup.EstimatedWeight || 0) + ' kg';
               document.getElementById('viewActualWeight').textContent = (pickup.ActualWeight || 'Not recorded') + (pickup.ActualWeight ? ' kg' : '');
               document.getElementById('viewCreditsEarned').textContent = pickup.ActualWeight ? creditsEarned.toFixed(0) + ' credits' : 'Not applicable';
               document.getElementById('viewRequestedDate').textContent = formatDateTime(pickup.RequestedDate);
               document.getElementById('viewScheduledDate').textContent = pickup.ScheduledDate ? formatDateTime(pickup.ScheduledDate) : 'Not scheduled';
               document.getElementById('viewCompletedDate').textContent = pickup.CompletedDate ? formatDateTime(pickup.CompletedDate) : 'Not completed';
               document.getElementById('viewPickupAddress').textContent = pickup.Address || 'No address';
               document.getElementById('viewPickupNotes').textContent = pickup.Notes || 'No notes';

               // Show modal
               document.getElementById('viewPickupModal').style.display = 'block';
           }
       }

       function closeViewPickupModal() {
           document.getElementById('viewPickupModal').style.display = 'none';
           currentViewPickupId = null;
       }

       // Assign Collector Modal Functions
       function assignCollector(pickupId) {
           currentAssignPickupId = pickupId;
           document.getElementById('assignCollectorModal').style.display = 'block';
       }

       function closeAssignModal() {
           document.getElementById('assignCollectorModal').style.display = 'none';
           currentAssignPickupId = null;
           // Reset form
           document.getElementById('collectorSelect').value = '';
           document.getElementById('scheduledDateTime').value = '';
           document.getElementById('assignmentNotes').value = '';
       }

       function confirmAssign() {
           const collectorId = document.getElementById('collectorSelect').value;
           const scheduledDate = document.getElementById('scheduledDateTime').value;
           const notes = document.getElementById('assignmentNotes').value;

           if (!collectorId) {
               showError('Please select a collector');
               return;
           }

           if (!scheduledDate) {
               showError('Please select a scheduled date and time');
               return;
           }

           const selectedCollector = allCollectors.find(c => c.Id === collectorId);

           // Use PageMethods with proper error handling
           PageMethods.AssignCollector(currentAssignPickupId, collectorId, scheduledDate, notes,
               function (response) {
                   if (response.startsWith('Success')) {
                       showSuccess(`Collector ${selectedCollector.FirstName} ${selectedCollector.LastName} assigned successfully`);
                       closeAssignModal();
                       document.getElementById('<%= btnLoadPickups.ClientID %>').click();
                   } else {
                       showError('Error assigning collector: ' + response);
                   }
               },
               function(error) {
                   showError('Error calling server: ' + error.get_message());
               }
           );
       }

       // Complete Pickup Modal Functions
       function completePickup(pickupId) {
           currentCompletePickupId = pickupId;
           const pickup = allPickups.find(p => p.PickupId === pickupId);
           if (pickup) {
               document.getElementById('confirmedWasteType').value = pickup.WasteType || 'Plastic';
           }
           document.getElementById('completePickupModal').style.display = 'block';
       }

       function closeCompleteModal() {
           document.getElementById('completePickupModal').style.display = 'none';
           currentCompletePickupId = null;
           // Reset form
           document.getElementById('actualWeight').value = '';
           document.getElementById('completionNotes').value = '';
       }

       function confirmComplete() {
           const actualWeight = document.getElementById('actualWeight').value;
           const confirmedWasteType = document.getElementById('confirmedWasteType').value;
           const completionNotes = document.getElementById('completionNotes').value;

           if (!actualWeight || actualWeight <= 0) {
               showError('Please enter a valid actual weight');
               return;
           }

           PageMethods.CompletePickup(currentCompletePickupId, parseFloat(actualWeight), confirmedWasteType, completionNotes,
               function(response) {
                   if (response.startsWith('Success')) {
                       showSuccess('Pickup completed successfully');
                       closeCompleteModal();
                       document.getElementById('<%= btnLoadPickups.ClientID %>').click();
                   } else {
                       showError('Error completing pickup: ' + response);
                   }
               },
               function(error) {
                   showError('Error calling server: ' + error.get_message());
               }
           );
       }

       // Delete Confirmation Modal Functions
       function deletePickup(pickupId) {
           const pickup = allPickups.find(p => p.PickupId === pickupId);
           if (pickup) {
               currentDeletePickupId = pickupId;
               document.getElementById('deletePickupId').textContent = `#${pickup.PickupId}`;
               document.getElementById('deletePickupModal').style.display = 'block';
           }
       }

       function closeDeleteModal() {
           document.getElementById('deletePickupModal').style.display = 'none';
           currentDeletePickupId = null;
       }

       function confirmDelete() {
           if (currentDeletePickupId) {
               PageMethods.DeletePickup(currentDeletePickupId,
                   function(response) {
                       if (response.startsWith('Success')) {
                           showSuccess('Pickup deleted successfully');
                           document.getElementById('<%= btnLoadPickups.ClientID %>').click();
                       } else {
                           showError('Error deleting pickup: ' + response);
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

       // Add New Pickup Modal Functions
       function openAddModal() {
           document.getElementById('addPickupModal').style.display = 'block';
       }

       function closeAddModal() {
           document.getElementById('addPickupModal').style.display = 'none';
           // Reset form
           document.getElementById('citizenSelect').value = '';
           document.getElementById('newWasteType').value = 'Plastic';
           document.getElementById('estimatedWeight').value = '';
           document.getElementById('pickupAddress').value = '';
           document.getElementById('pickupNotes').value = '';
       }

       function confirmAddPickup() {
           const citizenId = document.getElementById('citizenSelect').value;
           const wasteType = document.getElementById('newWasteType').value;
           const estimatedWeight = document.getElementById('estimatedWeight').value;
           const address = document.getElementById('pickupAddress').value;
           const notes = document.getElementById('pickupNotes').value;

           if (!citizenId || !estimatedWeight || !address) {
               showError('Please fill in all required fields');
               return;
           }

           if (estimatedWeight <= 0) {
               showError('Please enter a valid estimated weight');
               return;
           }

           // Call your server-side method to create pickup
           PageMethods.CreatePickup(citizenId, wasteType, parseFloat(estimatedWeight), address, notes,
               function(response) {
                   if (response.startsWith('Success')) {
                       showSuccess('Pickup created successfully');
                       closeAddModal();
                       document.getElementById('<%= btnLoadPickups.ClientID %>').click();
                   } else {
                       showError('Error creating pickup: ' + response);
                   }
               },
               function (error) {
                   showError('Error calling server: ' + error.get_message());
               }
           );
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