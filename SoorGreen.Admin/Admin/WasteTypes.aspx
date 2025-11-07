<%@ Page Title="Waste Types" Language="C#" MasterPageFile="~/Admin/Site.master" AutoEventWireup="true" CodeFile="WasteTypes.aspx.cs" Inherits="SoorGreen.Admin.Admin.WasteTypes" %>
<%@ Register Assembly="System.Web.Extensions, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35" Namespace="System.Web.UI" TagPrefix="asp" %>

<asp:Content ID="PageTitle" ContentPlaceHolderID="PageTitle" runat="server">
    Waste Types Management
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <asp:ScriptManager ID="ScriptManager1" runat="server" EnablePageMethods="true"></asp:ScriptManager>
    
    <style>
        .waste-types-container {
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
        
        .type-card {
            background: rgba(255, 255, 255, 0.05);
            backdrop-filter: blur(20px);
            border: 1px solid rgba(255, 255, 255, 0.1);
            border-radius: 15px;
            padding: 1.5rem;
            margin-bottom: 1.5rem;
            transition: all 0.3s ease;
        }
        
        .type-card:hover {
            transform: translateY(-3px);
            border-color: rgba(0, 212, 170, 0.3);
        }
        
        .type-header {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            margin-bottom: 1rem;
        }
        
        .type-info {
            flex: 1;
        }
        
        .type-title {
            font-size: 1.3rem;
            font-weight: 700;
            color: #ffffff !important;
            margin: 0 0 0.5rem 0;
        }
        
        .type-description {
            color: rgba(255, 255, 255, 0.8) !important;
            margin: 0 0 0.5rem 0;
        }
        
        .type-actions {
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
        
        .type-details {
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
        
        .type-meta {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding-top: 1rem;
            border-top: 1px solid rgba(255, 255, 255, 0.1);
        }
        
        .type-status {
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
            background: rgba(32, 201, 151, 0.2);
            color: #20c997;
            border: 1px solid rgba(32, 201, 151, 0.3);
        }
        
        .status-inactive {
            background: rgba(108, 117, 125, 0.2);
            color: #6c757d;
            border: 1px solid rgba(108, 117, 125, 0.3);
        }
        
        .table-responsive {
            border-radius: 10px;
            overflow: hidden;
        }
        
        .types-table {
            width: 100%;
            background: rgba(255, 255, 255, 0.02);
            border-collapse: collapse;
        }
        
        .types-table th {
            background: rgba(255, 255, 255, 0.1);
            color: #ffffff !important;
            font-weight: 600;
            padding: 1rem;
            text-align: left;
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
        }
        
        .types-table td {
            padding: 1rem;
            border-bottom: 1px solid rgba(255, 255, 255, 0.05);
            color: rgba(255, 255, 255, 0.8) !important;
        }
        
        .types-table tr:hover {
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
        
        .types-grid {
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
        
        /* Type Details Modal Styles */
        .type-details-container {
            display: flex;
            flex-direction: column;
            gap: 1.5rem;
        }
        
        .type-info-grid {
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
        
        /* Color indicator */
        .color-indicator {
            width: 20px;
            height: 20px;
            border-radius: 50%;
            display: inline-block;
            margin-right: 0.5rem;
            border: 2px solid rgba(255, 255, 255, 0.3);
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
            .types-grid {
                grid-template-columns: 1fr;
            }
            
            .filter-group {
                flex-direction: column;
            }
            
            .form-group {
                min-width: 100%;
            }
            
            .type-info-grid {
                grid-template-columns: 1fr;
            }
            
            .stats-cards {
                grid-template-columns: 1fr;
            }
        }
    </style>

    <div class="waste-types-container">
        <!-- Statistics Cards -->
        <div class="stats-cards">
            <div class="stat-card">
                <div class="stat-value" id="totalTypes">0</div>
                <div class="stat-label">Total Waste Types</div>
            </div>
            <div class="stat-card">
                <div class="stat-value" id="avgCreditRate">0.00</div>
                <div class="stat-label">Average Credit Rate</div>
            </div>
            <div class="stat-card">
                <div class="stat-value" id="highestCredit">0.00</div>
                <div class="stat-label">Highest Credit Rate</div>
            </div>
            <div class="stat-card">
                <div class="stat-value" id="activeTypes">0</div>
                <div class="stat-label">Active Types</div>
            </div>
        </div>

        <div class="filter-card" style="background: rgba(255, 255, 255, 0.05); backdrop-filter: blur(20px); border: 1px solid rgba(255, 255, 255, 0.1); border-radius: 15px; padding: 1.5rem; margin-bottom: 2rem;">
            <h5 class="mb-3" style="color: #ffffff !important;"><i class="fas fa-filter me-2"></i>Filter Waste Types</h5>
            <div class="filter-group">
                <div class="form-group search-box">
                    <label class="form-label">Search Types</label>
                    <div class="position-relative">
                        <i class="fas fa-search search-icon"></i>
                        <input type="text" class="form-control search-input" id="searchTypes" placeholder="Search by name or description...">
                    </div>
                </div>
                
                <div class="form-group">
                    <label class="form-label">Credit Range</label>
                    <select class="form-control" id="creditFilter">
                        <option value="all">All Credits</option>
                        <option value="low">Low (0-0.25)</option>
                        <option value="medium">Medium (0.26-0.75)</option>
                        <option value="high">High (0.76+)</option>
                    </select>
                </div>
                
                <div class="form-group">
                    <label class="form-label">Status</label>
                    <select class="form-control" id="statusFilter">
                        <option value="all">All Status</option>
                        <option value="active">Active</option>
                        <option value="inactive">Inactive</option>
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
            <button type="button" class="btn-add" id="addTypeBtn">
                <i class="fas fa-plus me-2"></i>Add New Waste Type
            </button>
            
            <div class="page-info" id="pageInfo">
                Showing 0 types
            </div>
        </div>

        <div id="gridView">
            <div class="types-grid" id="typesGrid">
            </div>
        </div>

        <div id="tableView" style="display: none;">
            <div class="table-responsive">
                <table class="types-table" id="typesTable">
                    <thead>
                        <tr>
                            <th>Type ID</th>
                            <th>Name</th>
                            <th>Credit Rate</th>
                            <th>Status</th>
                            <th>Reports Count</th>
                            <th>Total Weight</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody id="typesTableBody">
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

    <!-- View Type Details Modal -->
    <div class="modal-overlay" id="viewTypeModal">
        <div class="modal-content" style="max-width: 700px;">
            <div class="modal-header">
                <h3 class="modal-title">Waste Type Details</h3>
                <button type="button" class="close-modal">&times;</button>
            </div>
            <div class="modal-body">
                <div class="type-details-container">
                    <div class="type-info-grid">
                        <div class="info-item">
                            <label>Type ID:</label>
                            <span id="viewTypeId">-</span>
                        </div>
                        <div class="info-item">
                            <label>Status:</label>
                            <span id="viewTypeStatus">-</span>
                        </div>
                        <div class="info-item">
                            <label>Name:</label>
                            <span id="viewTypeName">-</span>
                        </div>
                        <div class="info-item">
                            <label>Credit Rate:</label>
                            <span id="viewCreditRate">-</span>
                        </div>
                        <div class="info-item">
                            <label>Total Reports:</label>
                            <span id="viewReportsCount">-</span>
                        </div>
                        <div class="info-item">
                            <label>Total Weight:</label>
                            <span id="viewTotalWeight">-</span>
                        </div>
                        <div class="info-item">
                            <label>Average Weight:</label>
                            <span id="viewAvgWeight">-</span>
                        </div>
                        <div class="info-item">
                            <label>Total Credits:</label>
                            <span id="viewTotalCredits">-</span>
                        </div>
                        <div class="info-item full-width">
                            <label>Description:</label>
                            <span id="viewTypeDescription">-</span>
                        </div>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-action btn-edit" id="editTypeBtn">
                    <i class="fas fa-edit me-2"></i>Edit Type
                </button>
                <button type="button" class="btn-action" id="closeViewModalBtn">Close</button>
            </div>
        </div>
    </div>

    <!-- Add/Edit Waste Type Modal -->
    <div class="modal-overlay" id="editTypeModal">
        <div class="modal-content" style="max-width: 600px;">
            <div class="modal-header">
                <h3 class="modal-title" id="editModalTitle">Add New Waste Type</h3>
                <button type="button" class="close-modal">&times;</button>
            </div>
            <div class="modal-body">
                <div class="form-group">
                    <label class="form-label">Waste Type Name</label>
                    <input type="text" class="form-control" id="typeName" placeholder="Enter waste type name">
                </div>
                <div class="form-row">
                    <div class="form-half">
                        <label class="form-label">Credit Rate (per kg)</label>
                        <input type="number" class="form-control" id="creditRate" step="0.01" min="0" placeholder="0.00">
                    </div>
                    <div class="form-half">
                        <label class="form-label">Status</label>
                        <select class="form-control" id="typeStatus">
                            <option value="Active">Active</option>
                            <option value="Inactive">Inactive</option>
                        </select>
                    </div>
                </div>
                <div class="form-group">
                    <label class="form-label">Description (Optional)</label>
                    <textarea class="form-control" id="typeDescription" rows="3" placeholder="Enter description..."></textarea>
                </div>
                <div class="form-group">
                    <label class="form-label">Color Indicator (Optional)</label>
                    <input type="color" class="form-control" id="typeColor" value="#20c997" style="height: 50px;">
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-action" id="cancelEditBtn">Cancel</button>
                <button type="button" class="btn-primary" id="confirmEditBtn">Save Waste Type</button>
            </div>
        </div>
    </div>

    <!-- Delete Confirmation Modal -->
    <div class="modal-overlay" id="deleteTypeModal">
        <div class="modal-content" style="max-width: 500px;">
            <div class="modal-header">
                <h3 class="modal-title">Confirm Delete</h3>
                <button type="button" class="close-modal">&times;</button>
            </div>
            <div class="modal-body">
                <div class="text-center">
                    <i class="fas fa-exclamation-triangle fa-3x text-warning mb-3"></i>
                    <h4>Are you sure?</h4>
                    <p>You are about to delete waste type: <strong id="deleteTypeName">-</strong></p>
                    <p class="text-muted">This action cannot be undone. Associated waste reports will need to be reassigned.</p>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-action" id="cancelDeleteBtn" style="flex: 1;">Cancel</button>
                <button type="button" class="btn-primary" id="confirmDeleteBtn" style="flex: 1;">Delete Type</button>
            </div>
        </div>
    </div>

    <asp:Button ID="btnLoadTypes" runat="server" OnClick="LoadWasteTypes" Style="display: none;" />
    <asp:HiddenField ID="hfTypesData" runat="server" />
    <asp:HiddenField ID="hfCurrentPage" runat="server" Value="1" />
    <asp:HiddenField ID="hfStatsData" runat="server" />
</asp:Content>

<asp:Content ID="Scripts" ContentPlaceHolderID="Scripts" runat="server">
   <script>
       // GLOBAL VARIABLES
       let currentView = 'grid';
       let currentPage = 1;
       const typesPerPage = 6;
       let filteredTypes = [];
       let allTypes = [];
       let currentViewTypeId = null;
       let currentDeleteTypeId = null;
       let currentEditTypeId = null;
       let isEditing = false;

       // INITIALIZE
       document.addEventListener('DOMContentLoaded', function () {
           initializeEventListeners();
           loadTypesFromServer();
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
           document.getElementById('searchTypes').addEventListener('input', function (e) {
               applyFilters();
           });

           // Filter dropdowns
           document.getElementById('creditFilter').addEventListener('change', function (e) {
               applyFilters();
           });

           document.getElementById('statusFilter').addEventListener('change', function (e) {
               applyFilters();
           });

           // Modal close buttons
           document.querySelector('#viewTypeModal .close-modal').addEventListener('click', closeViewTypeModal);
           document.querySelector('#editTypeModal .close-modal').addEventListener('click', closeEditTypeModal);
           document.querySelector('#deleteTypeModal .close-modal').addEventListener('click', closeDeleteModal);

           document.getElementById('closeViewModalBtn').addEventListener('click', closeViewTypeModal);
           document.getElementById('cancelEditBtn').addEventListener('click', closeEditTypeModal);
           document.getElementById('cancelDeleteBtn').addEventListener('click', closeDeleteModal);

           document.getElementById('editTypeBtn').addEventListener('click', openEditTypeModal);
           document.getElementById('confirmEditBtn').addEventListener('click', confirmSaveType);
           document.getElementById('confirmDeleteBtn').addEventListener('click', confirmDelete);

           // Add type button
           document.getElementById('addTypeBtn').addEventListener('click', openAddTypeModal);

           // Close modals when clicking outside
           document.getElementById('viewTypeModal').addEventListener('click', function (e) {
               if (e.target === this) closeViewTypeModal();
           });
           document.getElementById('editTypeModal').addEventListener('click', function (e) {
               if (e.target === this) closeEditTypeModal();
           });
           document.getElementById('deleteTypeModal').addEventListener('click', function (e) {
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

           renderTypes();
       }

       function loadTypesFromServer() {
           showLoading();

           const typesData = document.getElementById('<%= hfTypesData.ClientID %>').value;
           const statsData = document.getElementById('<%= hfStatsData.ClientID %>').value;

           if (typesData && typesData !== '') {
               try {
                   allTypes = JSON.parse(typesData);
                   filteredTypes = [...allTypes];

                   // Update statistics
                   if (statsData && statsData !== '') {
                       const stats = JSON.parse(statsData);
                       updateStatistics(stats);
                   }

                   renderTypes();
                   updatePagination();
                   updatePageInfo();
                   hideLoading();

                   if (filteredTypes.length > 0) {
                       showSuccess('Loaded ' + filteredTypes.length + ' waste types from database');
                   } else {
                       showInfo('No waste types found in database');
                   }

               } catch (e) {
                   console.error('Error parsing type data:', e);
                   showError('Error loading waste type data from database');
                   hideLoading();
               }
           } else {
               showError('No waste type data available from database');
               hideLoading();
           }
       }

       function updateStatistics(stats) {
           document.getElementById('totalTypes').textContent = stats.TotalTypes || 0;
           document.getElementById('avgCreditRate').textContent = (stats.AverageCreditRate || 0).toFixed(2);
           document.getElementById('highestCredit').textContent = (stats.HighestCreditRate || 0).toFixed(2);
           document.getElementById('activeTypes').textContent = stats.ActiveTypes || 0;
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
           const searchTerm = document.getElementById('searchTypes').value.toLowerCase();
           const creditFilter = document.getElementById('creditFilter').value;
           const statusFilter = document.getElementById('statusFilter').value;

           filteredTypes = allTypes.filter(type => {
               const matchesSearch = !searchTerm ||
                   (type.Name && type.Name.toLowerCase().includes(searchTerm)) ||
                   (type.Description && type.Description.toLowerCase().includes(searchTerm));

               const matchesCredit = creditFilter === 'all' || 
                   (creditFilter === 'low' && type.CreditPerKg <= 0.25) ||
                   (creditFilter === 'medium' && type.CreditPerKg > 0.25 && type.CreditPerKg <= 0.75) ||
                   (creditFilter === 'high' && type.CreditPerKg > 0.75);

               const matchesStatus = statusFilter === 'all' || 
                   (statusFilter === 'active' && type.Status === 'Active') ||
                   (statusFilter === 'inactive' && type.Status === 'Inactive');

               return matchesSearch && matchesCredit && matchesStatus;
           });

           currentPage = 1;
           renderTypes();
           updatePagination();
           updatePageInfo();
       }

       function renderTypes() {
           if (currentView === 'grid') {
               renderGridView();
           } else {
               renderTableView();
           }
       }

       function renderGridView() {
           const grid = document.getElementById('typesGrid');
           const startIndex = (currentPage - 1) * typesPerPage;
           const endIndex = startIndex + typesPerPage;
           const typesToShow = filteredTypes.slice(startIndex, endIndex);

           grid.innerHTML = '';

           if (typesToShow.length === 0) {
               grid.innerHTML = '<div class="col-12 text-center py-5"><i class="fas fa-trash-alt fa-3x mb-3" style="color: rgba(255, 255, 255, 0.5) !important;"></i><h4 style="color: rgba(255, 255, 255, 0.7) !important;">No waste types found</h4><p style="color: rgba(255, 255, 255, 0.5) !important;">Try adjusting your filters or search terms</p></div>';
               return;
           }

           typesToShow.forEach(type => {
               const typeCard = createTypeCard(type);
               grid.appendChild(typeCard);
           });
       }

       function renderTableView() {
           const tbody = document.getElementById('typesTableBody');
           const startIndex = (currentPage - 1) * typesPerPage;
           const endIndex = startIndex + typesPerPage;
           const typesToShow = filteredTypes.slice(startIndex, endIndex);

           tbody.innerHTML = '';

           if (typesToShow.length === 0) {
               tbody.innerHTML = '<tr><td colspan="7" class="text-center py-4"><i class="fas fa-trash-alt fa-2x mb-2" style="color: rgba(255, 255, 255, 0.5) !important;"></i><h5 style="color: rgba(255, 255, 255, 0.7) !important;">No waste types found</h5><p style="color: rgba(255, 255, 255, 0.5) !important;">Try adjusting your filters or search terms</p></td></tr>';
               return;
           }

           typesToShow.forEach(type => {
               const row = createTableRow(type);
               tbody.appendChild(row);
           });
       }

       function createTypeCard(type) {
           const card = document.createElement('div');
           card.className = 'type-card';

           const statusClass = type.Status === 'Active' ? 'status-active' : 'status-inactive';
           const totalCredits = (type.TotalWeight || 0) * (type.CreditPerKg || 0);

           card.innerHTML = '<div class="type-header"><div class="type-info"><h3 class="type-title">' + escapeHtml(type.Name || 'Unknown') + '</h3><p class="type-description">' + escapeHtml(type.Description || 'No description available') + '</p><div class="type-details"><div class="detail-item"><div class="detail-value">' + (type.CreditPerKg || 0) + '</div><div class="detail-label">Credits/kg</div></div><div class="detail-item"><div class="detail-value">' + (type.ReportsCount || 0) + '</div><div class="detail-label">Reports</div></div><div class="detail-item"><div class="detail-value">' + (type.TotalWeight || 0) + 'kg</div><div class="detail-label">Total Weight</div></div><div class="detail-item"><div class="detail-value">' + totalCredits.toFixed(0) + '</div><div class="detail-label">Total Credits</div></div></div></div><div class="type-actions"><button class="btn-action btn-view" data-type-id="' + type.WasteTypeId + '" title="View Details"><i class="fas fa-eye"></i></button><button class="btn-action btn-edit" data-type-id="' + type.WasteTypeId + '" title="Edit Type"><i class="fas fa-edit"></i></button><button class="btn-action btn-delete" data-type-id="' + type.WasteTypeId + '" title="Delete Type"><i class="fas fa-trash"></i></button></div></div><div class="type-meta"><div class="type-status"><span class="status-badge ' + statusClass + '">' + (type.Status || 'Active') + '</span><span style="color: rgba(255, 255, 255, 0.5) !important;">ID: ' + type.WasteTypeId + '</span></div><div class="small" style="color: rgba(255, 255, 255, 0.5) !important;">Avg: ' + (type.AverageWeight || 0) + 'kg per report</div></div>';

           // Add event listeners
           card.querySelector('.btn-view').addEventListener('click', function () {
               viewType(this.getAttribute('data-type-id'));
           });

           card.querySelector('.btn-edit').addEventListener('click', function () {
               editType(this.getAttribute('data-type-id'));
           });

           card.querySelector('.btn-delete').addEventListener('click', function () {
               deleteType(this.getAttribute('data-type-id'));
           });

           return card;
       }

       function createTableRow(type) {
           const row = document.createElement('tr');
           const statusClass = type.Status === 'Active' ? 'status-active' : 'status-inactive';
           const totalCredits = (type.TotalWeight || 0) * (type.CreditPerKg || 0);

           row.innerHTML = '<td>' + type.WasteTypeId + '</td><td><div class="fw-bold" style="color: #ffffff !important;">' + escapeHtml(type.Name || 'Unknown') + '</div><div class="small" style="color: rgba(255, 255, 255, 0.6) !important;">' + escapeHtml(type.Description || 'No description') + '</div></td><td><div style="color: #ffffff !important;">' + (type.CreditPerKg || 0) + ' credits/kg</div><div class="small" style="color: rgba(255, 255, 255, 0.6) !important;">Total: ' + totalCredits.toFixed(0) + ' credits</div></td><td><span class="status-badge ' + statusClass + '">' + (type.Status || 'Active') + '</span></td><td>' + (type.ReportsCount || 0) + '</td><td>' + (type.TotalWeight || 0) + ' kg</td><td><div class="type-actions"><button class="btn-action btn-view" data-type-id="' + type.WasteTypeId + '" title="View Details"><i class="fas fa-eye"></i></button><button class="btn-action btn-edit" data-type-id="' + type.WasteTypeId + '" title="Edit Type"><i class="fas fa-edit"></i></button><button class="btn-action btn-delete" data-type-id="' + type.WasteTypeId + '" title="Delete Type"><i class="fas fa-trash"></i></button></div></td>';

           // Add event listeners
           row.querySelector('.btn-view').addEventListener('click', function () {
               viewType(this.getAttribute('data-type-id'));
           });

           row.querySelector('.btn-edit').addEventListener('click', function () {
               editType(this.getAttribute('data-type-id'));
           });

           row.querySelector('.btn-delete').addEventListener('click', function () {
               deleteType(this.getAttribute('data-type-id'));
           });

           return row;
       }

       function updatePagination() {
           const pagination = document.getElementById('pagination');
           const totalPages = Math.ceil(filteredTypes.length / typesPerPage);

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
           const totalPages = Math.ceil(filteredTypes.length / typesPerPage);
           if (page >= 1 && page <= totalPages) {
               currentPage = page;
               renderTypes();
               updatePagination();
           }
       }

       function updatePageInfo() {
           const startIndex = (currentPage - 1) * typesPerPage + 1;
           const endIndex = Math.min(currentPage * typesPerPage, filteredTypes.length);
           document.getElementById('pageInfo').textContent = 'Showing ' + startIndex + '-' + endIndex + ' of ' + filteredTypes.length + ' types';
       }

       function showLoading() {
           const grid = document.getElementById('typesGrid');
           if (grid) {
               grid.innerHTML = '<div class="col-12 text-center py-5"><i class="fas fa-spinner fa-spin fa-2x mb-3" style="color: rgba(255, 255, 255, 0.5) !important;"></i><p style="color: rgba(255, 255, 255, 0.7) !important;">Loading waste types from database...</p></div>';
           }
       }

       function hideLoading() { }

       // View Type Modal Functions
       function viewType(typeId) {
           const type = allTypes.find(t => t.WasteTypeId === typeId);
           if (type) {
               currentViewTypeId = typeId;

               // Populate modal with type data
               document.getElementById('viewTypeId').textContent = type.WasteTypeId;
               document.getElementById('viewTypeName').textContent = type.Name || 'Unknown';
               document.getElementById('viewTypeDescription').textContent = type.Description || 'No description available';
               document.getElementById('viewCreditRate').textContent = (type.CreditPerKg || 0) + ' credits per kg';
               document.getElementById('viewReportsCount').textContent = type.ReportsCount || 0;
               document.getElementById('viewTotalWeight').textContent = (type.TotalWeight || 0) + ' kg';
               document.getElementById('viewAvgWeight').textContent = (type.AverageWeight || 0) + ' kg';
               document.getElementById('viewTotalCredits').textContent = ((type.TotalWeight || 0) * (type.CreditPerKg || 0)).toFixed(0) + ' credits';
               
               const statusElement = document.getElementById('viewTypeStatus');
               statusElement.innerHTML = '<span class="status-badge ' + (type.Status === 'Active' ? 'status-active' : 'status-inactive') + '">' + (type.Status || 'Active') + '</span>';

               // Show modal
               document.getElementById('viewTypeModal').style.display = 'block';
           }
       }

       function closeViewTypeModal() {
           document.getElementById('viewTypeModal').style.display = 'none';
           currentViewTypeId = null;
       }

       // Edit Type Modal Functions
       function openAddTypeModal() {
           isEditing = false;
           currentEditTypeId = null;
           document.getElementById('editModalTitle').textContent = 'Add New Waste Type';
           document.getElementById('typeName').value = '';
           document.getElementById('creditRate').value = '';
           document.getElementById('typeStatus').value = 'Active';
           document.getElementById('typeDescription').value = '';
           document.getElementById('typeColor').value = '#20c997';
           document.getElementById('editTypeModal').style.display = 'block';
       }

       function openEditTypeModal() {
           if (currentViewTypeId) {
               const type = allTypes.find(t => t.WasteTypeId === currentViewTypeId);
               if (type) {
                   isEditing = true;
                   currentEditTypeId = currentViewTypeId;
                   document.getElementById('editModalTitle').textContent = 'Edit Waste Type';
                   document.getElementById('typeName').value = type.Name || '';
                   document.getElementById('creditRate').value = type.CreditPerKg || '';
                   document.getElementById('typeStatus').value = type.Status || 'Active';
                   document.getElementById('typeDescription').value = type.Description || '';
                   document.getElementById('typeColor').value = type.Color || '#20c997';
                   document.getElementById('editTypeModal').style.display = 'block';
                   closeViewTypeModal();
               }
           }
       }

       function editType(typeId) {
           const type = allTypes.find(t => t.WasteTypeId === typeId);
           if (type) {
               isEditing = true;
               currentEditTypeId = typeId;
               document.getElementById('editModalTitle').textContent = 'Edit Waste Type';
               document.getElementById('typeName').value = type.Name || '';
               document.getElementById('creditRate').value = type.CreditPerKg || '';
               document.getElementById('typeStatus').value = type.Status || 'Active';
               document.getElementById('typeDescription').value = type.Description || '';
               document.getElementById('typeColor').value = type.Color || '#20c997';
               document.getElementById('editTypeModal').style.display = 'block';
           }
       }

       function closeEditTypeModal() {
           document.getElementById('editTypeModal').style.display = 'none';
           currentEditTypeId = null;
           isEditing = false;
       }

       function confirmSaveType() {
           const name = document.getElementById('typeName').value;
           const creditRate = document.getElementById('creditRate').value;
           const status = document.getElementById('typeStatus').value;
           const description = document.getElementById('typeDescription').value;
           const color = document.getElementById('typeColor').value;

           if (!name || !creditRate) {
               showError('Please fill in all required fields');
               return;
           }

           if (creditRate <= 0) {
               showError('Please enter a valid credit rate');
               return;
           }

           if (isEditing && currentEditTypeId) {
               // Update existing type
               PageMethods.UpdateWasteType(currentEditTypeId, name, parseFloat(creditRate), status, description, color,
                   function(response) {
                       if (response.startsWith('Success')) {
                           showSuccess('Waste type updated successfully');
                           closeEditTypeModal();
                           document.getElementById('<%= btnLoadTypes.ClientID %>').click();
                       } else {
                           showError('Error updating waste type: ' + response);
                       }
                   },
                   function(error) {
                       showError('Error calling server: ' + error.get_message());
                   }
               );
           } else {
               // Create new type
               PageMethods.CreateWasteType(name, parseFloat(creditRate), status, description, color,
                   function(response) {
                       if (response.startsWith('Success')) {
                           showSuccess('Waste type created successfully');
                           closeEditTypeModal();
                           document.getElementById('<%= btnLoadTypes.ClientID %>').click();
                       } else {
                           showError('Error creating waste type: ' + response);
                       }
                   },
                   function(error) {
                       showError('Error calling server: ' + error.get_message());
                   }
               );
           }
       }

       // Delete Confirmation Modal Functions
       function deleteType(typeId) {
           const type = allTypes.find(t => t.WasteTypeId === typeId);
           if (type) {
               currentDeleteTypeId = typeId;
               document.getElementById('deleteTypeName').textContent = type.Name || 'Unknown';
               document.getElementById('deleteTypeModal').style.display = 'block';
           }
       }

       function closeDeleteModal() {
           document.getElementById('deleteTypeModal').style.display = 'none';
           currentDeleteTypeId = null;
       }

       function confirmDelete() {
           if (currentDeleteTypeId) {
               PageMethods.DeleteWasteType(currentDeleteTypeId,
                   function(response) {
                       if (response.startsWith('Success')) {
                           showSuccess('Waste type deleted successfully');
                           document.getElementById('<%= btnLoadTypes.ClientID %>').click();
                       } else {
                           showError('Error deleting waste type: ' + response);
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