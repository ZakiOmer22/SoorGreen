<%@ Page Title="Citizens" Language="C#" MasterPageFile="~/Admin/Site.master" AutoEventWireup="true" CodeFile="Citizens.aspx.cs" Inherits="SoorGreen.Admin.Admin.Citizens" %>

<asp:Content ID="PageTitle" ContentPlaceHolderID="PageTitle" runat="server">
    Citizen Management
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <style>
        .users-container {
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
        
        .user-card {
            background: rgba(255, 255, 255, 0.05);
            backdrop-filter: blur(20px);
            border: 1px solid rgba(255, 255, 255, 0.1);
            border-radius: 15px;
            padding: 1.5rem;
            margin-bottom: 1.5rem;
            transition: all 0.3s ease;
        }
        
        .user-card:hover {
            transform: translateY(-3px);
            border-color: rgba(0, 212, 170, 0.3);
        }
        
        .user-header {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            margin-bottom: 1rem;
        }
        
        .user-info {
            flex: 1;
        }
        
        .user-name {
            font-size: 1.3rem;
            font-weight: 700;
            color: #ffffff !important;
            margin: 0 0 0.5rem 0;
        }
        
        .user-email {
            color: rgba(255, 255, 255, 0.8) !important;
            margin: 0 0 0.5rem 0;
        }
        
        .user-actions {
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
        
        .user-stats {
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
        
        .user-meta {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding-top: 1rem;
            border-top: 1px solid rgba(255, 255, 255, 0.1);
        }
        
        .user-status {
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
        
        .table-responsive {
            border-radius: 10px;
            overflow: hidden;
        }
        
        .users-table {
            width: 100%;
            background: rgba(255, 255, 255, 0.02);
            border-collapse: collapse;
        }
        
        .users-table th {
            background: rgba(255, 255, 255, 0.1);
            color: #ffffff !important;
            font-weight: 600;
            padding: 1rem;
            text-align: left;
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
        }
        
        .users-table td {
            padding: 1rem;
            border-bottom: 1px solid rgba(255, 255, 255, 0.05);
            color: rgba(255, 255, 255, 0.8) !important;
        }
        
        .users-table tr:hover {
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
        
        .users-grid {
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
        
        /* User Details Modal Styles */
        .user-details-container {
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 1.5rem;
        }
        
        .user-avatar-large {
            text-align: center;
        }
        
        .user-info-grid {
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
            .users-grid {
                grid-template-columns: 1fr;
            }
            
            .filter-group {
                flex-direction: column;
            }
            
            .form-group {
                min-width: 100%;
            }
            
            .user-info-grid {
                grid-template-columns: 1fr;
            }
        }
    </style>

    <div class="users-container">
        <div class="filter-card">
            <h5 class="mb-3" style="color: #ffffff !important;"><i class="fas fa-filter me-2"></i>Filter Citizens</h5>
            <div class="filter-group">
                <div class="form-group search-box">
                    <label class="form-label">Search Citizens</label>
                    <div class="position-relative">
                        <i class="fas fa-search search-icon"></i>
                        <input type="text" class="form-control search-input" id="searchUsers" placeholder="Search by name, email, or phone...">
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
                Showing 0 citizens
            </div>
        </div>

        <div id="gridView">
            <div class="users-grid" id="usersGrid">
            </div>
        </div>

        <div id="tableView" style="display: none;">
            <div class="table-responsive">
                <table class="users-table" id="usersTable">
                    <thead>
                        <tr>
                            <th>Citizen</th>
                            <th>Contact</th>
                            <th>Status</th>
                            <th>Pickups</th>
                            <th>Credits</th>
                            <th>Joined</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody id="usersTableBody">
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

    <!-- View User Details Modal -->
    <div class="modal-overlay" id="viewUserModal">
        <div class="modal-content" style="max-width: 600px;">
            <div class="modal-header">
                <h3 class="modal-title">Citizen Details</h3>
                <button type="button" class="close-modal">&times;</button>
            </div>
            <div class="modal-body">
                <div class="user-details-container">
                    <div class="user-avatar-large">
                        <div class="user-avatar" style="width: 80px; height: 80px; font-size: 1.5rem;" id="viewUserAvatar">
                            UU
                        </div>
                    </div>
                    <div class="user-info-grid">
                        <div class="info-item">
                            <label>Full Name:</label>
                            <span id="viewUserName">-</span>
                        </div>
                        <div class="info-item">
                            <label>Email:</label>
                            <span id="viewUserEmail">-</span>
                        </div>
                        <div class="info-item">
                            <label>Phone:</label>
                            <span id="viewUserPhone">-</span>
                        </div>
                        <div class="info-item">
                            <label>User Type:</label>
                            <span id="viewUserType">-</span>
                        </div>
                        <div class="info-item">
                            <label>Status:</label>
                            <span id="viewUserStatus">-</span>
                        </div>
                        <div class="info-item">
                            <label>Credits:</label>
                            <span id="viewUserCredits">-</span>
                        </div>
                        <div class="info-item">
                            <label>Registration Date:</label>
                            <span id="viewUserRegDate">-</span>
                        </div>
                        <div class="info-item full-width">
                            <label>Address:</label>
                            <span id="viewUserAddress">-</span>
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
    <div class="modal-overlay" id="deleteUserModal">
        <div class="modal-content" style="max-width: 500px;">
            <div class="modal-header">
                <h3 class="modal-title">Confirm Delete</h3>
                <button type="button" class="close-modal">&times;</button>
            </div>
            <div class="modal-body">
                <div class="text-center">
                    <i class="fas fa-exclamation-triangle fa-3x text-warning mb-3"></i>
                    <h4>Are you sure?</h4>
                    <p>You are about to delete citizen: <strong id="deleteUserName">-</strong></p>
                    <p class="text-muted">This action cannot be undone.</p>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-action" id="cancelDeleteBtn" style="flex: 1;">Cancel</button>
                <button type="button" class="btn-primary" id="confirmDeleteBtn" style="flex: 1;">Delete Citizen</button>
            </div>
        </div>
    </div>

    <asp:Button ID="btnLoadUsers" runat="server" OnClick="LoadUsers" Style="display: none;" />
    <asp:HiddenField ID="hfUsersData" runat="server" />
    <asp:HiddenField ID="hfCurrentPage" runat="server" Value="1" />
</asp:Content>

<asp:Content ID="Scripts" ContentPlaceHolderID="Scripts" runat="server">
   <script>
       // GLOBAL VARIABLES
       let currentView = 'grid';
       let currentPage = 1;
       const usersPerPage = 6;
       let filteredUsers = [];
       let allUsers = [];
       let currentViewUserId = null;
       let currentDeleteUserId = null;

       // INITIALIZE
       document.addEventListener('DOMContentLoaded', function () {
           initializeEventListeners();
           loadUsersFromServer();
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
           document.getElementById('searchUsers').addEventListener('input', function (e) {
               applyFilters();
           });

           // Filter dropdowns
           document.getElementById('statusFilter').addEventListener('change', function (e) {
               applyFilters();
           });

           document.getElementById('dateFilter').addEventListener('change', function (e) {
               applyFilters();
           });

           // Modal close buttons
           document.querySelector('#viewUserModal .close-modal').addEventListener('click', closeViewUserModal);
           document.querySelector('#deleteUserModal .close-modal').addEventListener('click', closeDeleteModal);
           document.getElementById('closeViewModalBtn').addEventListener('click', closeViewUserModal);
           document.getElementById('cancelDeleteBtn').addEventListener('click', closeDeleteModal);
           document.getElementById('confirmDeleteBtn').addEventListener('click', confirmDelete);

           // Close modals when clicking outside
           document.getElementById('viewUserModal').addEventListener('click', function (e) {
               if (e.target === this) closeViewUserModal();
           });
           document.getElementById('deleteUserModal').addEventListener('click', function (e) {
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

           renderUsers();
       }

       function loadUsersFromServer() {
           showLoading();

           const usersData = document.getElementById('<%= hfUsersData.ClientID %>').value;

        if (usersData && usersData !== '') {
            try {
                allUsers = JSON.parse(usersData);
                // Filter to show only citizens/customers
                filteredUsers = allUsers.filter(user => user.UserType === 'customer');

                renderUsers();
                updatePagination();
                updatePageInfo();
                hideLoading();

                if (filteredUsers.length > 0) {
                    showSuccess('Loaded ' + filteredUsers.length + ' citizens from database');
                } else {
                    showInfo('No citizens found in database');
                }

            } catch (e) {
                console.error('Error parsing user data:', e);
                showError('Error loading citizen data from database');
                hideLoading();
            }
        } else {
            showError('No citizen data available from database');
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
        const searchTerm = document.getElementById('searchUsers').value.toLowerCase();
        const statusFilter = document.getElementById('statusFilter').value;

        filteredUsers = allUsers.filter(user => {
            const matchesSearch = !searchTerm ||
                (user.FirstName && user.FirstName.toLowerCase().includes(searchTerm)) ||
                (user.LastName && user.LastName.toLowerCase().includes(searchTerm)) ||
                (user.Email && user.Email.toLowerCase().includes(searchTerm)) ||
                (user.Phone && user.Phone.includes(searchTerm));

            const matchesStatus = statusFilter === 'all' || user.Status === statusFilter;
            const isCitizen = user.UserType === 'customer';

            return matchesSearch && matchesStatus && isCitizen;
        });

        currentPage = 1;
        renderUsers();
        updatePagination();
        updatePageInfo();
    }

    function renderUsers() {
        if (currentView === 'grid') {
            renderGridView();
        } else {
            renderTableView();
        }
    }

    function renderGridView() {
        const grid = document.getElementById('usersGrid');
        const startIndex = (currentPage - 1) * usersPerPage;
        const endIndex = startIndex + usersPerPage;
        const usersToShow = filteredUsers.slice(startIndex, endIndex);

        grid.innerHTML = '';

        if (usersToShow.length === 0) {
            grid.innerHTML = `
                <div class="col-12 text-center py-5">
                    <i class="fas fa-users fa-3x mb-3" style="color: rgba(255, 255, 255, 0.5) !important;"></i>
                    <h4 style="color: rgba(255, 255, 255, 0.7) !important;">No citizens found</h4>
                    <p style="color: rgba(255, 255, 255, 0.5) !important;">Try adjusting your filters or search terms</p>
                </div>
            `;
            return;
        }

        usersToShow.forEach(user => {
            const userCard = createUserCard(user);
            grid.appendChild(userCard);
        });
    }

    function renderTableView() {
        const tbody = document.getElementById('usersTableBody');
        const startIndex = (currentPage - 1) * usersPerPage;
        const endIndex = startIndex + usersPerPage;
        const usersToShow = filteredUsers.slice(startIndex, endIndex);

        tbody.innerHTML = '';

        if (usersToShow.length === 0) {
            tbody.innerHTML = `
                <tr>
                    <td colspan="7" class="text-center py-4">
                        <i class="fas fa-users fa-2x mb-2" style="color: rgba(255, 255, 255, 0.5) !important;"></i>
                        <h5 style="color: rgba(255, 255, 255, 0.7) !important;">No citizens found</h5>
                        <p style="color: rgba(255, 255, 255, 0.5) !important;">Try adjusting your filters or search terms</p>
                    </td>
                </tr>
            `;
            return;
        }

        usersToShow.forEach(user => {
            const row = createTableRow(user);
            tbody.appendChild(row);
        });
    }

    function createUserCard(user) {
        const card = document.createElement('div');
        card.className = 'user-card';

        const completionRate = user.TotalPickups > 0
            ? Math.round((user.CompletedPickups / user.TotalPickups) * 100)
            : 0;

        card.innerHTML = `
            <div class="user-header">
                <div class="user-info">
                    <h3 class="user-name">${escapeHtml(user.FirstName || '')} ${escapeHtml(user.LastName || '')}</h3>
                    <p class="user-email">${escapeHtml(user.Email || 'No email')}</p>
                    <div class="user-stats">
                        <div class="stat-item">
                            <div class="stat-value">${user.TotalPickups || 0}</div>
                            <div class="stat-label">Total Pickups</div>
                        </div>
                        <div class="stat-item">
                            <div class="stat-value">${completionRate}%</div>
                            <div class="stat-label">Completion</div>
                        </div>
                        <div class="stat-item">
                            <div class="stat-value">${user.Credits || 0}</div>
                            <div class="stat-label">Credits</div>
                        </div>
                    </div>
                </div>
                <div class="user-actions">
                    <button class="btn-action btn-view" data-user-id="${user.Id}" title="View Details">
                        <i class="fas fa-eye"></i>
                    </button>
                    <button class="btn-action btn-edit" data-user-id="${user.Id}" title="Edit Citizen">
                        <i class="fas fa-edit"></i>
                    </button>
                    <button class="btn-action btn-delete" data-user-id="${user.Id}" title="Delete Citizen">
                        <i class="fas fa-trash"></i>
                    </button>
                </div>
            </div>
            <div class="user-meta">
                <div class="user-status">
                    <span class="status-badge status-${user.Status || 'inactive'}">${capitalizeFirst(user.Status || 'inactive')}</span>
                    <span style="color: rgba(255, 255, 255, 0.5) !important;">• Citizen</span>
                </div>
                <div class="small" style="color: rgba(255, 255, 255, 0.5) !important;">
                    Joined ${formatDate(user.RegistrationDate)}
                </div>
            </div>
        `;

        // Add event listeners to action buttons
        card.querySelector('.btn-view').addEventListener('click', function() {
            viewUser(this.getAttribute('data-user-id'));
        });
        card.querySelector('.btn-edit').addEventListener('click', function() {
            editUser(this.getAttribute('data-user-id'));
        });
        card.querySelector('.btn-delete').addEventListener('click', function() {
            deleteUser(this.getAttribute('data-user-id'));
        });

        return card;
    }

    function createTableRow(user) {
        const row = document.createElement('tr');
        const completionRate = user.TotalPickups > 0
            ? Math.round((user.CompletedPickups / user.TotalPickups) * 100)
            : 0;

        row.innerHTML = `
            <td>
                <div class="d-flex align-items-center gap-3">
                    <div class="user-avatar">
                        ${escapeHtml((user.FirstName ? user.FirstName[0] : 'U') + (user.LastName ? user.LastName[0] : ''))}
                    </div>
                    <div>
                        <div class="fw-bold" style="color: #ffffff !important;">${escapeHtml(user.FirstName || '')} ${escapeHtml(user.LastName || '')}</div>
                        <div class="small" style="color: rgba(255, 255, 255, 0.6) !important;">${escapeHtml(user.Email || 'No email')}</div>
                    </div>
                </div>
            </td>
            <td>${escapeHtml(user.Phone || 'No phone')}</td>
            <td>
                <span class="status-badge status-${user.Status || 'inactive'}">${capitalizeFirst(user.Status || 'inactive')}</span>
            </td>
            <td>
                <div style="color: #ffffff !important;">${user.CompletedPickups || 0}/${user.TotalPickups || 0}</div>
                <div class="small" style="color: rgba(255, 255, 255, 0.6) !important;">${completionRate}% completed</div>
            </td>
            <td>
                <div class="fw-bold" style="color: #ffffff !important;">${user.Credits || 0}</div>
            </td>
            <td>${formatDate(user.RegistrationDate)}</td>
            <td>
                <div class="user-actions">
                    <button class="btn-action btn-view" data-user-id="${user.Id}" title="View Details">
                        <i class="fas fa-eye"></i>
                    </button>
                    <button class="btn-action btn-edit" data-user-id="${user.Id}" title="Edit Citizen">
                        <i class="fas fa-edit"></i>
                    </button>
                    <button class="btn-action btn-delete" data-user-id="${user.Id}" title="Delete Citizen">
                        <i class="fas fa-trash"></i>
                    </button>
                </div>
            </td>
        `;

        // Add event listeners to action buttons
        row.querySelector('.btn-view').addEventListener('click', function() {
            viewUser(this.getAttribute('data-user-id'));
        });
        row.querySelector('.btn-edit').addEventListener('click', function() {
            editUser(this.getAttribute('data-user-id'));
        });
        row.querySelector('.btn-delete').addEventListener('click', function() {
            deleteUser(this.getAttribute('data-user-id'));
        });

        return row;
    }

    function updatePagination() {
        const pagination = document.getElementById('pagination');
        const totalPages = Math.ceil(filteredUsers.length / usersPerPage);

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
        const totalPages = Math.ceil(filteredUsers.length / usersPerPage);
        if (page >= 1 && page <= totalPages) {
            currentPage = page;
            renderUsers();
            updatePagination();
        }
    }

    function updatePageInfo() {
        const startIndex = (currentPage - 1) * usersPerPage + 1;
        const endIndex = Math.min(currentPage * usersPerPage, filteredUsers.length);
        document.getElementById('pageInfo').textContent = `Showing ${startIndex}-${endIndex} of ${filteredUsers.length} citizens`;
    }

    function showLoading() {
        const grid = document.getElementById('usersGrid');
        if (grid) {
            grid.innerHTML = `
                <div class="col-12 text-center py-5">
                    <i class="fas fa-spinner fa-spin fa-2x mb-3" style="color: rgba(255, 255, 255, 0.5) !important;"></i>
                    <p style="color: rgba(255, 255, 255, 0.7) !important;">Loading citizens from database...</p>
                </div>
            `;
        }
    }

    function hideLoading() { }

    // View User Modal Functions
    function viewUser(userId) {
        const user = allUsers.find(u => u.Id === userId);
        if (user) {
            currentViewUserId = userId;
            
            // Populate modal with user data
            document.getElementById('viewUserAvatar').innerHTML = 
                escapeHtml((user.FirstName ? user.FirstName[0] : 'U') + (user.LastName ? user.LastName[0] : ''));
            document.getElementById('viewUserName').textContent = `${user.FirstName || ''} ${user.LastName || ''}`;
            document.getElementById('viewUserEmail').textContent = user.Email || 'No email';
            document.getElementById('viewUserPhone').textContent = user.Phone || 'No phone';
            document.getElementById('viewUserType').textContent = 'Citizen';
            document.getElementById('viewUserStatus').innerHTML = 
                `<span class="status-badge status-${user.Status || 'inactive'}">${capitalizeFirst(user.Status || 'inactive')}</span>`;
            document.getElementById('viewUserCredits').textContent = user.Credits || 0;
            document.getElementById('viewUserRegDate').textContent = formatDate(user.RegistrationDate);
            document.getElementById('viewUserAddress').textContent = user.Address || 'No address';
            
            // Show modal
            document.getElementById('viewUserModal').style.display = 'block';
        }
    }

    function closeViewUserModal() {
        document.getElementById('viewUserModal').style.display = 'none';
        currentViewUserId = null;
    }

    // Delete Confirmation Modal Functions
    function deleteUser(userId) {
        const user = allUsers.find(u => u.Id === userId);
        if (user) {
            currentDeleteUserId = userId;
            document.getElementById('deleteUserName').textContent = `${user.FirstName || ''} ${user.LastName || ''}`;
            document.getElementById('deleteUserModal').style.display = 'block';
        }
    }

    function closeDeleteModal() {
        document.getElementById('deleteUserModal').style.display = 'none';
        currentDeleteUserId = null;
    }

    function confirmDelete() {
        if (currentDeleteUserId) {
            PageMethods.DeleteUser(currentDeleteUserId, function(response) {
                if (response.startsWith('Success')) {
                    showSuccess('Citizen deleted successfully');
                    document.getElementById('<%= btnLoadUsers.ClientID %>').click();
                } else {
                    showError('Error deleting citizen: ' + response);
                }
                closeDeleteModal();
            });
           }
       }

       function editUser(userId) {
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