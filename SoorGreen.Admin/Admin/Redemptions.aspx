<%@ Page Title="Rewards" Language="C#" MasterPageFile="~/Admin/Site.master" AutoEventWireup="true" CodeFile="Redemptions.aspx.cs" Inherits="SoorGreen.Admin.Admin.Redemptions" %>
<%@ Register Assembly="System.Web.Extensions, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35" Namespace="System.Web.UI" TagPrefix="asp" %>

<asp:Content ID="PageTitle" ContentPlaceHolderID="PageTitle" runat="server">
    Redemption & Credits Management
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <asp:ScriptManager ID="ScriptManager1" runat="server" EnablePageMethods="true"></asp:ScriptManager>
    
    <style>
        .rewards-container {
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
        
        .btn-approve {
            background: rgba(25, 135, 84, 0.2);
            border-color: rgba(25, 135, 84, 0.3);
        }
        
        .btn-reject {
            background: rgba(220, 53, 69, 0.2);
            border-color: rgba(220, 53, 69, 0.3);
        }
        
        .btn-view {
            background: rgba(108, 117, 125, 0.2);
            border-color: rgba(108, 117, 125, 0.3);
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
        
        .table-responsive {
            border-radius: 10px;
            overflow: hidden;
        }
        
        .rewards-table {
            width: 100%;
            background: rgba(255, 255, 255, 0.02);
            border-collapse: collapse;
        }
        
        .rewards-table th {
            background: rgba(255, 255, 255, 0.1);
            color: #ffffff !important;
            font-weight: 600;
            padding: 1rem;
            text-align: left;
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
        }
        
        .rewards-table td {
            padding: 1rem;
            border-bottom: 1px solid rgba(255, 255, 255, 0.05);
            color: rgba(255, 255, 255, 0.8) !important;
        }
        
        .rewards-table tr:hover {
            background: rgba(255, 255, 255, 0.03);
        }
        
        .status-badge {
            padding: 0.3rem 0.8rem;
            border-radius: 20px;
            font-size: 0.75rem;
            font-weight: 600;
        }
        
        .status-pending {
            background: rgba(255, 193, 7, 0.2);
            color: #ffc107;
            border: 1px solid rgba(255, 193, 7, 0.3);
        }
        
        .status-approved {
            background: rgba(25, 135, 84, 0.2);
            color: #198754;
            border: 1px solid rgba(25, 135, 84, 0.3);
        }
        
        .status-rejected {
            background: rgba(220, 53, 69, 0.2);
            color: #dc3545;
            border: 1px solid rgba(220, 53, 69, 0.3);
        }
        
        .status-completed {
            background: rgba(13, 110, 253, 0.2);
            color: #0d6efd;
            border: 1px solid rgba(13, 110, 253, 0.3);
        }
        
        .credit-positive {
            color: #198754 !important;
            font-weight: 600;
        }
        
        .credit-negative {
            color: #dc3545 !important;
            font-weight: 600;
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
        
        .user-info {
            display: flex;
            align-items: center;
            gap: 0.5rem;
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
        
        .modal-body {
            padding: 0 0 1.5rem 0;
        }
        
        .modal-footer {
            display: flex;
            gap: 1rem;
            padding-top: 1.5rem;
            border-top: 1px solid rgba(255, 255, 255, 0.1);
        }
        
        .info-grid {
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
        
        .tabs {
            display: flex;
            gap: 0.5rem;
            margin-bottom: 1.5rem;
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
            padding-bottom: 0.5rem;
        }
        
        .tab {
            background: rgba(255, 255, 255, 0.05);
            border: 1px solid rgba(255, 255, 255, 0.1);
            color: rgba(255, 255, 255, 0.7) !important;
            padding: 0.75rem 1.5rem;
            border-radius: 8px 8px 0 0;
            cursor: pointer;
            transition: all 0.3s ease;
            font-weight: 600;
        }
        
        .tab.active {
            background: rgba(255, 255, 255, 0.1);
            border-color: var(--primary);
            color: #ffffff !important;
        }
        
        .tab-content {
            display: none;
        }
        
        .tab-content.active {
            display: block;
        }

        /* Empty State Styles */
        .empty-state {
            text-align: center;
            padding: 3rem 2rem;
            color: rgba(255, 255, 255, 0.7);
        }

        .empty-state-icon {
            font-size: 4rem;
            margin-bottom: 1rem;
            color: rgba(255, 255, 255, 0.3);
        }

        .empty-state-title {
            font-size: 1.5rem;
            margin-bottom: 0.5rem;
            color: rgba(255, 255, 255, 0.8);
        }

        .empty-state-description {
            font-size: 1rem;
            margin-bottom: 1.5rem;
        }
        
        @media (max-width: 768px) {
            .filter-group {
                flex-direction: column;
            }
            
            .form-group {
                min-width: 100%;
            }
            
            .info-grid {
                grid-template-columns: 1fr;
            }
            
            .stats-cards {
                grid-template-columns: 1fr;
            }
            
            .tabs {
                flex-direction: column;
            }
        }
    </style>

    <div class="rewards-container">
        <!-- Statistics Cards -->
        <div class="stats-cards">
            <div class="stat-card">
                <div class="stat-value" id="totalCredits">0</div>
                <div class="stat-label">Total Credits Issued</div>
            </div>
            <div class="stat-card">
                <div class="stat-value" id="pendingRedemptions">0</div>
                <div class="stat-label">Pending Redemptions</div>
            </div>
            <div class="stat-card">
                <div class="stat-value" id="totalUsers">0</div>
                <div class="stat-label">Active Users</div>
            </div>
            <div class="stat-card">
                <div class="stat-value" id="avgCredits">0</div>
                <div class="stat-label">Avg Credits Per User</div>
            </div>
        </div>

        <!-- Action Buttons -->
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h2 style="color: #ffffff !important; margin: 0;">Rewards & Credits</h2>
            <div>
                <button type="button" class="btn-primary me-2" id="generateReportBtn">
                    <i class="fas fa-chart-bar me-2"></i>Generate Report
                </button>
                <button type="button" class="btn-primary" id="addCreditsBtn">
                    <i class="fas fa-plus me-2"></i>Add Credits
                </button>
            </div>
        </div>

        <!-- Tabs -->
        <div class="tabs">
            <button type="button" class="tab active" data-tab="redemptions">Redemption Requests</button>
            <button type="button" class="tab" data-tab="transactions">Credit Transactions</button>
            <button type="button" class="tab" data-tab="users">User Balances</button>
        </div>

        <!-- Redemptions Tab -->
        <div class="tab-content active" id="redemptionsTab">
            <div class="filter-card" style="background: rgba(255, 255, 255, 0.05); backdrop-filter: blur(20px); border: 1px solid rgba(255, 255, 255, 0.1); border-radius: 15px; padding: 1.5rem; margin-bottom: 2rem;">
                <h5 class="mb-3" style="color: #ffffff !important;"><i class="fas fa-filter me-2"></i>Filter Redemptions</h5>
                <div class="filter-group">
                    <div class="form-group search-box">
                        <label class="form-label">Search Users</label>
                        <div class="position-relative">
                            <i class="fas fa-search search-icon"></i>
                            <input type="text" class="form-control search-input" id="searchRedemptions" placeholder="Search by user name or phone...">
                        </div>
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label">Status</label>
                        <select class="form-control" id="statusFilter">
                            <option value="all">All Status</option>
                            <option value="pending">Pending</option>
                            <option value="approved">Approved</option>
                            <option value="rejected">Rejected</option>
                            <option value="completed">Completed</option>
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

            <div class="table-responsive">
                <table class="rewards-table" id="redemptionsTable">
                    <thead>
                        <tr>
                            <th>Request ID</th>
                            <th>User</th>
                            <th>Amount</th>
                            <th>Method</th>
                            <th>Status</th>
                            <th>Requested</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody id="redemptionsTableBody">
                        <!-- Redemption rows will be loaded here -->
                    </tbody>
                </table>
            </div>
            
            <!-- Empty State for Redemptions -->
            <div id="redemptionsEmptyState" class="empty-state" style="display: none;">
                <div class="empty-state-icon">
                    <i class="fas fa-exchange-alt"></i>
                </div>
                <h3 class="empty-state-title">No Redemption Requests</h3>
                <p class="empty-state-description">There are no redemption requests to display at the moment.</p>
                <button type="button" class="btn-primary" onclick="showAddCreditsModal()">
                    <i class="fas fa-plus me-2"></i>Add Credits to Users
                </button>
            </div>
        </div>

        <!-- Transactions Tab -->
        <div class="tab-content" id="transactionsTab">
            <div class="table-responsive">
                <table class="rewards-table" id="transactionsTable">
                    <thead>
                        <tr>
                            <th>Transaction ID</th>
                            <th>User</th>
                            <th>Amount</th>
                            <th>Type</th>
                            <th>Reference</th>
                            <th>Date</th>
                        </tr>
                    </thead>
                    <tbody id="transactionsTableBody">
                        <!-- Transaction rows will be loaded here -->
                    </tbody>
                </table>
            </div>
            
            <!-- Empty State for Transactions -->
            <div id="transactionsEmptyState" class="empty-state" style="display: none;">
                <div class="empty-state-icon">
                    <i class="fas fa-coins"></i>
                </div>
                <h3 class="empty-state-title">No Credit Transactions</h3>
                <p class="empty-state-description">No credit transactions found.</p>
            </div>
        </div>

        <!-- Users Tab -->
        <div class="tab-content" id="usersTab">
            <div class="table-responsive">
                <table class="rewards-table" id="usersTable">
                    <thead>
                        <tr>
                            <th>User</th>
                            <th>Phone</th>
                            <th>Email</th>
                            <th>Total Credits</th>
                            <th>Joined</th>
                            <th>Status</th>
                        </tr>
                    </thead>
                    <tbody id="usersTableBody">
                        <!-- User rows will be loaded here -->
                    </tbody>
                </table>
            </div>
            
            <!-- Empty State for Users -->
            <div id="usersEmptyState" class="empty-state" style="display: none;">
                <div class="empty-state-icon">
                    <i class="fas fa-users"></i>
                </div>
                <h3 class="empty-state-title">No Users Found</h3>
                <p class="empty-state-description">No users match the current search criteria.</p>
            </div>
        </div>
    </div>

    <!-- View Redemption Details Modal -->
    <div class="modal-overlay" id="viewRedemptionModal">
        <div class="modal-content" style="max-width: 600px;">
            <div class="modal-header">
                <h3 class="modal-title">Redemption Request Details</h3>
                <button type="button" class="close-modal">&times;</button>
            </div>
            <div class="modal-body">
                <div class="info-grid">
                    <div class="info-item">
                        <label>Request ID:</label>
                        <span id="viewRedemptionId">-</span>
                    </div>
                    <div class="info-item">
                        <label>Status:</label>
                        <span id="viewRedemptionStatus">-</span>
                    </div>
                    <div class="info-item">
                        <label>User:</label>
                        <div class="user-info">
                            <div class="user-avatar" id="viewUserAvatar">U</div>
                            <span id="viewUserName">-</span>
                        </div>
                    </div>
                    <div class="info-item">
                        <label>Phone:</label>
                        <span id="viewUserPhone">-</span>
                    </div>
                    <div class="info-item">
                        <label>Amount:</label>
                        <span id="viewRedemptionAmount">-</span>
                    </div>
                    <div class="info-item">
                        <label>Method:</label>
                        <span id="viewRedemptionMethod">-</span>
                    </div>
                    <div class="info-item">
                        <label>Requested:</label>
                        <span id="viewRequestedAt">-</span>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-action btn-approve" id="approveRedemptionBtn">
                    <i class="fas fa-check me-2"></i>Approve
                </button>
                <button type="button" class="btn-action btn-reject" id="rejectRedemptionBtn">
                    <i class="fas fa-times me-2"></i>Reject
                </button>
                <button type="button" class="btn-action" id="closeRedemptionModalBtn">Close</button>
            </div>
        </div>
    </div>

    <!-- Add Credits Modal -->
    <div class="modal-overlay" id="addCreditsModal">
        <div class="modal-content" style="max-width: 500px;">
            <div class="modal-header">
                <h3 class="modal-title">Add Credits to User</h3>
                <button type="button" class="close-modal">&times;</button>
            </div>
            <div class="modal-body">
                <div class="form-group">
                    <label class="form-label">Select User</label>
                    <select class="form-control" id="userSelect">
                        <option value="">-- Select User --</option>
                    </select>
                </div>
                <div class="form-group">
                    <label class="form-label">Amount</label>
                    <input type="number" class="form-control" id="creditAmount" step="0.01" min="0" placeholder="Enter credit amount">
                </div>
                <div class="form-group">
                    <label class="form-label">Reference/Notes</label>
                    <textarea class="form-control" id="creditNotes" rows="3" placeholder="Enter reference or notes..."></textarea>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-action" id="cancelAddCreditsBtn">Cancel</button>
                <button type="button" class="btn-primary" id="confirmAddCreditsBtn">Add Credits</button>
            </div>
        </div>
    </div>

    <!-- Approve/Reject Confirmation Modal -->
    <div class="modal-overlay" id="actionConfirmationModal">
        <div class="modal-content" style="max-width: 500px;">
            <div class="modal-header">
                <h3 class="modal-title" id="actionModalTitle">Confirm Action</h3>
                <button type="button" class="close-modal">&times;</button>
            </div>
            <div class="modal-body">
                <p style="color: rgba(255, 255, 255, 0.8) !important;" id="actionModalMessage">Are you sure you want to perform this action?</p>
                <div class="form-group" id="rejectionReasonContainer" style="display: none;">
                    <label class="form-label">Rejection Reason</label>
                    <textarea class="form-control" id="rejectionReason" rows="3" placeholder="Enter reason for rejection..."></textarea>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-action" id="cancelActionBtn">Cancel</button>
                <button type="button" class="btn-primary" id="confirmActionBtn">Confirm</button>
            </div>
        </div>
    </div>

    <asp:Button ID="btnLoadRewards" runat="server" OnClick="btnLoadRewards_Click" Style="display: none;" />
    <asp:HiddenField ID="hfRedemptionsData" runat="server" />
    <asp:HiddenField ID="hfTransactionsData" runat="server" />
    <asp:HiddenField ID="hfUsersData" runat="server" />
    <asp:HiddenField ID="hfStatsData" runat="server" />
</asp:Content>

<asp:Content ID="Scripts" ContentPlaceHolderID="Scripts" runat="server">
   <script>
       let currentTab = 'redemptions';
       let allRedemptions = [];
       let allTransactions = [];
       let allUsers = [];
       let currentAction = null;
       let currentRedemptionId = null;

       document.addEventListener('DOMContentLoaded', function () {
           loadRewardsFromServer();
           setupEventListeners();
       });

       function setupEventListeners() {
           // Tab switching
           document.querySelectorAll('.tab').forEach(tab => {
               tab.addEventListener('click', function (e) {
                   e.preventDefault();
                   const tabName = this.getAttribute('data-tab');
                   switchTab(tabName);
               });
           });

           // Add credits button
           document.getElementById('addCreditsBtn').addEventListener('click', function (e) {
               e.preventDefault();
               showAddCreditsModal();
           });

           // Close modals
           document.querySelectorAll('.close-modal').forEach(btn => {
               btn.addEventListener('click', function (e) {
                   e.preventDefault();
                   this.closest('.modal-overlay').style.display = 'none';
               });
           });

           // Modal close buttons
           document.getElementById('closeRedemptionModalBtn').addEventListener('click', function (e) {
               e.preventDefault();
               document.getElementById('viewRedemptionModal').style.display = 'none';
           });

           document.getElementById('cancelAddCreditsBtn').addEventListener('click', function (e) {
               e.preventDefault();
               document.getElementById('addCreditsModal').style.display = 'none';
           });

           document.getElementById('cancelActionBtn').addEventListener('click', function (e) {
               e.preventDefault();
               document.getElementById('actionConfirmationModal').style.display = 'none';
           });

           // Action buttons
           document.getElementById('approveRedemptionBtn').addEventListener('click', function (e) {
               e.preventDefault();
               showActionConfirmation('approve');
           });

           document.getElementById('rejectRedemptionBtn').addEventListener('click', function (e) {
               e.preventDefault();
               showActionConfirmation('reject');
           });

           // Confirm actions
           document.getElementById('confirmAddCreditsBtn').addEventListener('click', function (e) {
               e.preventDefault();
               addCreditsToUser();
           });

           document.getElementById('confirmActionBtn').addEventListener('click', function (e) {
               e.preventDefault();
               processRedemptionAction();
           });
       }

       function switchTab(tabName) {
           currentTab = tabName;

           // Update active tab
           document.querySelectorAll('.tab').forEach(tab => {
               tab.classList.remove('active');
               if (tab.getAttribute('data-tab') === tabName) {
                   tab.classList.add('active');
               }
           });

           // Show active tab content
           document.querySelectorAll('.tab-content').forEach(content => {
               content.classList.remove('active');
               if (content.id === tabName + 'Tab') {
                   content.classList.add('active');
               }
           });

           // Render appropriate content
           switch (tabName) {
               case 'redemptions':
                   renderRedemptions();
                   break;
               case 'transactions':
                   renderTransactions();
                   break;
               case 'users':
                   renderUsers();
                   break;
           }
       }

       function loadRewardsFromServer() {
           const redemptionsData = document.getElementById('<%= hfRedemptionsData.ClientID %>').value;
           const transactionsData = document.getElementById('<%= hfTransactionsData.ClientID %>').value;
           const usersData = document.getElementById('<%= hfUsersData.ClientID %>').value;
           const statsData = document.getElementById('<%= hfStatsData.ClientID %>').value;

           if (redemptionsData) {
               allRedemptions = JSON.parse(redemptionsData);
           }
           if (transactionsData) {
               allTransactions = JSON.parse(transactionsData);
           }
           if (usersData) {
               allUsers = JSON.parse(usersData);
           }
           if (statsData) updateStatistics(JSON.parse(statsData));

           renderRedemptions();
       }

       function updateStatistics(stats) {
           document.getElementById('totalCredits').textContent = stats.TotalCredits || 0;
           document.getElementById('pendingRedemptions').textContent = stats.PendingRedemptions || 0;
           document.getElementById('totalUsers').textContent = stats.TotalUsers || 0;
           document.getElementById('avgCredits').textContent = stats.AvgCredits || 0;
       }

       function renderRedemptions() {
           const tbody = document.getElementById('redemptionsTableBody');
           const emptyState = document.getElementById('redemptionsEmptyState');
           
           tbody.innerHTML = '';

           if (allRedemptions.length === 0) {
               tbody.style.display = 'none';
               emptyState.style.display = 'block';
               return;
           }

           tbody.style.display = '';
           emptyState.style.display = 'none';

           allRedemptions.forEach(redemption => {
               tbody.appendChild(createRedemptionRow(redemption));
           });
       }

       function renderTransactions() {
           const tbody = document.getElementById('transactionsTableBody');
           const emptyState = document.getElementById('transactionsEmptyState');
           
           tbody.innerHTML = '';

           if (allTransactions.length === 0) {
               tbody.style.display = 'none';
               emptyState.style.display = 'block';
               return;
           }

           tbody.style.display = '';
           emptyState.style.display = 'none';

           allTransactions.forEach(transaction => {
               tbody.appendChild(createTransactionRow(transaction));
           });
       }

       function renderUsers() {
           const tbody = document.getElementById('usersTableBody');
           const emptyState = document.getElementById('usersEmptyState');
           
           tbody.innerHTML = '';

           if (allUsers.length === 0) {
               tbody.style.display = 'none';
               emptyState.style.display = 'block';
               return;
           }

           tbody.style.display = '';
           emptyState.style.display = 'none';

           allUsers.forEach(user => {
               tbody.appendChild(createUserRow(user));
           });
       }

       function createRedemptionRow(redemption) {
           const row = document.createElement('tr');
           const userInitial = redemption.FullName ? redemption.FullName.charAt(0).toUpperCase() : 'U';
           
           row.innerHTML = `
               <td>${redemption.RedemptionId}</td>
               <td>
                   <div class="user-info">
                       <div class="user-avatar">${userInitial}</div>
                       <span>${escapeHtml(redemption.FullName || 'Unknown')}</span>
                   </div>
               </td>
               <td class="credit-negative">-${redemption.Amount || 0} credits</td>
               <td>${escapeHtml(redemption.Method || 'Unknown')}</td>
               <td><span class="status-badge status-${(redemption.Status || 'pending').toLowerCase()}">${redemption.Status || 'Pending'}</span></td>
               <td>${redemption.RequestedAt ? new Date(redemption.RequestedAt).toLocaleDateString() : '-'}</td>
               <td>
                   <button class="btn-action btn-view" data-id="${redemption.RedemptionId}"><i class="fas fa-eye"></i></button>
                   ${redemption.Status === 'Pending' ? `
                   <button class="btn-action btn-approve" data-id="${redemption.RedemptionId}"><i class="fas fa-check"></i></button>
                   <button class="btn-action btn-reject" data-id="${redemption.RedemptionId}"><i class="fas fa-times"></i></button>
                   ` : ''}
               </td>
           `;

           // Add event listeners
           row.querySelector('.btn-view').addEventListener('click', function (e) {
               e.preventDefault();
               viewRedemption(this.getAttribute('data-id'));
           });

           if (redemption.Status === 'Pending') {
               row.querySelector('.btn-approve').addEventListener('click', function (e) {
                   e.preventDefault();
                   currentRedemptionId = this.getAttribute('data-id');
                   showActionConfirmation('approve');
               });

               row.querySelector('.btn-reject').addEventListener('click', function (e) {
                   e.preventDefault();
                   currentRedemptionId = this.getAttribute('data-id');
                   showActionConfirmation('reject');
               });
           }

           return row;
       }

       function createTransactionRow(transaction) {
           const row = document.createElement('tr');
           const userInitial = transaction.FullName ? transaction.FullName.charAt(0).toUpperCase() : 'U';
           const isPositive = transaction.Amount > 0;
           
           row.innerHTML = `
               <td>${transaction.RewardId}</td>
               <td>
                   <div class="user-info">
                       <div class="user-avatar">${userInitial}</div>
                       <span>${escapeHtml(transaction.FullName || 'Unknown')}</span>
                   </div>
               </td>
               <td class="${isPositive ? 'credit-positive' : 'credit-negative'}">
                   ${isPositive ? '+' : ''}${transaction.Amount || 0} credits
               </td>
               <td>${escapeHtml(transaction.Type || 'Unknown')}</td>
               <td>${escapeHtml(transaction.Reference || '-')}</td>
               <td>${transaction.CreatedAt ? new Date(transaction.CreatedAt).toLocaleDateString() : '-'}</td>
           `;

           return row;
       }

       function createUserRow(user) {
           const row = document.createElement('tr');
           const userInitial = user.FullName ? user.FullName.charAt(0).toUpperCase() : 'U';
           const status = user.IsVerified ? 'Verified' : 'Pending';
           
           row.innerHTML = `
               <td>
                   <div class="user-info">
                       <div class="user-avatar">${userInitial}</div>
                       <span>${escapeHtml(user.FullName || 'Unknown')}</span>
                   </div>
               </td>
               <td>${user.Phone || '-'}</td>
               <td>${user.Email || '-'}</td>
               <td class="credit-positive">${user.XP_Credits || 0} credits</td>
               <td>${user.CreatedAt ? new Date(user.CreatedAt).toLocaleDateString() : '-'}</td>
               <td><span class="status-badge status-${status.toLowerCase()}">${status}</span></td>
           `;

           return row;
       }

       function viewRedemption(id) {
           const redemption = allRedemptions.find(r => r.RedemptionId === id);
           if (redemption) {
               currentRedemptionId = id;
               const userInitial = redemption.FullName ? redemption.FullName.charAt(0).toUpperCase() : 'U';
               
               document.getElementById('viewRedemptionId').textContent = redemption.RedemptionId;
               document.getElementById('viewRedemptionStatus').textContent = redemption.Status || 'Pending';
               document.getElementById('viewUserName').textContent = redemption.FullName || 'Unknown';
               document.getElementById('viewUserAvatar').textContent = userInitial;
               document.getElementById('viewUserPhone').textContent = redemption.Phone || '-';
               document.getElementById('viewRedemptionAmount').textContent = (redemption.Amount || 0) + ' credits';
               document.getElementById('viewRedemptionMethod').textContent = redemption.Method || 'Unknown';
               document.getElementById('viewRequestedAt').textContent = redemption.RequestedAt ? new Date(redemption.RequestedAt).toLocaleString() : '-';
               
               // Show/hide action buttons based on status
               const canTakeAction = redemption.Status === 'Pending';
               document.getElementById('approveRedemptionBtn').style.display = canTakeAction ? 'block' : 'none';
               document.getElementById('rejectRedemptionBtn').style.display = canTakeAction ? 'block' : 'none';
               
               document.getElementById('viewRedemptionModal').style.display = 'block';
           }
       }

       function showAddCreditsModal() {
           const userSelect = document.getElementById('userSelect');
           userSelect.innerHTML = '<option value="">-- Select User --</option>';
           
           allUsers.forEach(user => {
               const option = document.createElement('option');
               option.value = user.UserId;
               option.textContent = `${user.FullName} (${user.Phone}) - ${user.XP_Credits || 0} credits`;
               userSelect.appendChild(option);
           });
           
           // Reset form
           document.getElementById('creditAmount').value = '';
           document.getElementById('creditNotes').value = '';
           
           document.getElementById('addCreditsModal').style.display = 'block';
       }

       function addCreditsToUser() {
           const userId = document.getElementById('userSelect').value;
           const amount = parseFloat(document.getElementById('creditAmount').value);
           const notes = document.getElementById('creditNotes').value;
           
           if (!userId || !amount || amount <= 0) {
               showNotification('Please select a user and enter a valid amount', 'error');
               return;
           }
           
           // Call server method to add credits
           PageMethods.AddCreditsToUser(userId, amount, 'bonus', notes,
               function (response) {
                   showNotification('Credits added successfully!', 'success');
                   document.getElementById('addCreditsModal').style.display = 'none';
                   // Refresh data
                   document.getElementById('<%= btnLoadRewards.ClientID %>').click();
               },
               function (error) {
                   showNotification('Error adding credits: ' + error, 'error');
               }
           );
       }

       function showActionConfirmation(action) {
           currentAction = action;
           const redemption = allRedemptions.find(r => r.RedemptionId === currentRedemptionId);
           
           if (redemption) {
               if (action === 'approve') {
                   document.getElementById('actionModalTitle').textContent = 'Approve Redemption';
                   document.getElementById('actionModalMessage').textContent = 
                       `Are you sure you want to approve ${redemption.Amount || 0} credits redemption for ${redemption.FullName || 'this user'}?`;
                   document.getElementById('rejectionReasonContainer').style.display = 'none';
               } else {
                   document.getElementById('actionModalTitle').textContent = 'Reject Redemption';
                   document.getElementById('actionModalMessage').textContent = 
                       `Are you sure you want to reject ${redemption.Amount || 0} credits redemption for ${redemption.FullName || 'this user'}?`;
                   document.getElementById('rejectionReasonContainer').style.display = 'block';
               }
               
               document.getElementById('actionConfirmationModal').style.display = 'block';
           }
       }

       function processRedemptionAction() {
           let rejectionReason = null;
           
           if (currentAction === 'reject') {
               rejectionReason = document.getElementById('rejectionReason').value;
               if (!rejectionReason) {
                   showNotification('Please provide a reason for rejection', 'error');
                   return;
               }
           }
           
           // Call server method to process redemption
           PageMethods.ProcessRedemption(currentRedemptionId, currentAction, rejectionReason,
               function (response) {
                   showNotification(`Redemption ${currentAction === 'approve' ? 'approved' : 'rejected'} successfully!`, 'success');
                   document.getElementById('actionConfirmationModal').style.display = 'none';
                   document.getElementById('viewRedemptionModal').style.display = 'none';
                   // Refresh data
                   document.getElementById('<%= btnLoadRewards.ClientID %>').click();
               },
               function (error) {
                   showNotification(`Error processing redemption: ${error}`, 'error');
               }
           );
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