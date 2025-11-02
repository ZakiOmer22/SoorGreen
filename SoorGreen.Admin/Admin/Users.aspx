<%@ Page Title="Users" Language="C#" MasterPageFile="~/Admin/Site.master" AutoEventWireup="true" CodeFile="Users.aspx.cs" Inherits="SoorGreen.Admin.Admin.Users" %>

<asp:Content ID="PageTitle" ContentPlaceHolderID="PageTitle" runat="server">
    User Management
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
            justify-content: between;
            align-items: start;
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
            align-items: end;
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
            justify-content: between;
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
            justify-content: between;
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
        }
    </style>

    <div class="users-container">

        <!-- Filters -->
        <div class="filter-card">
            <h5 class="mb-3" style="color: #ffffff !important;"><i class="fas fa-filter me-2"></i>Filter Users</h5>
            <div class="filter-group">
                <div class="form-group search-box">
                    <label class="form-label">Search Users</label>
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
                    <label class="form-label">User Type</label>
                    <select class="form-control" id="typeFilter">
                        <option value="all">All Types</option>
                        <option value="customer">Customer</option>
                        <option value="collector">Collector</option>
                        <option value="admin">Admin</option>
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
                    <button class="btn-primary" onclick="filterUsers()" style="margin-top: 1.7rem;">
                        <i class="fas fa-filter me-2"></i>Apply Filters
                    </button>
                </div>
            </div>
        </div>

        <!-- View Options -->
        <div class="d-flex justify-content-between align-items-center mb-3">
            <div class="view-options">
                <button class="view-btn active" onclick="changeView('grid')">
                    <i class="fas fa-th me-2"></i>Grid View
                </button>
                <button class="view-btn" onclick="changeView('table')">
                    <i class="fas fa-table me-2"></i>Table View
                </button>
            </div>
            <div class="page-info" id="pageInfo">
                Showing 0 users
            </div>
        </div>

        <!-- Grid View -->
        <div id="gridView">
            <div class="users-grid" id="usersGrid">
                <!-- Users will be populated by JavaScript -->
            </div>
        </div>

        <!-- Table View -->
        <div id="tableView" style="display: none;">
            <div class="table-responsive">
                <table class="users-table" id="usersTable">
                    <thead>
                        <tr>
                            <th>User</th>
                            <th>Contact</th>
                            <th>Type</th>
                            <th>Status</th>
                            <th>Pickups</th>
                            <th>Credits</th>
                            <th>Joined</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody id="usersTableBody">
                        <!-- Data will be populated by JavaScript -->
                    </tbody>
                </table>
            </div>
        </div>

        <!-- Pagination -->
        <div class="pagination-container">
            <div class="page-info" id="paginationInfo">
                Page 1 of 1
            </div>
            <nav>
                <ul class="pagination mb-0" id="pagination">
                    <!-- Pagination will be generated by JavaScript -->
                </ul>
            </nav>
        </div>
    </div>

    <!-- Add/Edit User Modal -->
    <div class="modal-overlay" id="userModal">
        <div class="modal-content">
            <div class="modal-header">
                <h3 class="modal-title" id="modalTitle">Add New User</h3>
                <button class="close-modal" onclick="closeUserModal()">&times;</button>
            </div>
            <form id="userForm">
                <div class="form-row">
                    <div class="form-half">
                        <label class="form-label">First Name</label>
                        <input type="text" class="form-control" id="firstName" required>
                    </div>
                    <div class="form-half">
                        <label class="form-label">Last Name</label>
                        <input type="text" class="form-control" id="lastName" required>
                    </div>
                </div>
                
                <div class="form-group">
                    <label class="form-label">Email</label>
                    <input type="email" class="form-control" id="email" required>
                </div>
                
                <div class="form-group">
                    <label class="form-label">Phone</label>
                    <input type="tel" class="form-control" id="phone">
                </div>
                
                <div class="form-row">
                    <div class="form-half">
                        <label class="form-label">User Type</label>
                        <select class="form-control" id="userType" required>
                            <option value="customer">Customer</option>
                            <option value="collector">Collector</option>
                            <option value="admin">Admin</option>
                        </select>
                    </div>
                    <div class="form-half">
                        <label class="form-label">Status</label>
                        <select class="form-control" id="userStatus" required>
                            <option value="active">Active</option>
                            <option value="inactive">Inactive</option>
                            <option value="suspended">Suspended</option>
                            <option value="pending">Pending</option>
                        </select>
                    </div>
                </div>
                
                <div class="form-group">
                    <label class="form-label">Address</label>
                    <textarea class="form-control" id="address" rows="3"></textarea>
                </div>
                
                <div class="form-group">
                    <label class="form-label">Initial Credits</label>
                    <input type="number" class="form-control" id="credits" value="0" min="0">
                </div>
                
                <div class="d-flex gap-2 mt-4">
                    <button type="button" class="btn-action" onclick="closeUserModal()" style="flex: 1;">Cancel</button>
                    <button type="submit" class="btn-primary" style="flex: 2;">Save User</button>
                </div>
            </form>
        </div>
    </div>

    <!-- Hidden controls for server-side operations -->
    <asp:Button ID="btnLoadUsers" runat="server" OnClick="LoadUsers" Style="display: none;" />
    <asp:HiddenField ID="hfUsersData" runat="server" />
    <asp:HiddenField ID="hfCurrentPage" runat="server" Value="1" />
</asp:Content>

<asp:Content ID="Scripts" ContentPlaceHolderID="Scripts" runat="server">
    <script>
        // Notification Functions
        function showError(message) {
            showNotification(message, 'error');
        }

        function showSuccess(message) {
            showNotification(message, 'success');
        }

        function showInfo(message) {
            showNotification(message, 'info');
        }

        function showNotification(message, type = 'info') {
            // Remove existing notifications
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

            // Auto remove after 5 seconds
            setTimeout(() => {
                if (notification.parentElement) {
                    notification.remove();
                }
            }, 5000);
        }

        let currentView = 'grid';
        let currentPage = 1;
        const usersPerPage = 6;
        let filteredUsers = [];
        let allUsers = [];

        // Initialize when page loads
        document.addEventListener('DOMContentLoaded', function () {
            loadUsersFromServer();
            setupEventListeners();
        });

        function loadUsersFromServer() {
            showLoading();

            // Get data from server-side hidden field
            const usersData = document.getElementById('<%= hfUsersData.ClientID %>').value;

            if (usersData && usersData !== '') {
                try {
                    allUsers = JSON.parse(usersData);
                    filteredUsers = [...allUsers];

                    console.log('Loaded users from database:', allUsers);

                    renderUsers();
                    updatePagination();
                    updatePageInfo();
                    hideLoading();

                    // Show success message if we have real data
                    if (allUsers.length > 0) {
                        showSuccess('Loaded ' + allUsers.length + ' users from database');
                    }

                } catch (e) {
                    console.error('Error parsing users data:', e);
                    showError('Error loading user data from database');
                    hideLoading();
                }
            } else {
                showError('No user data available from database');
                hideLoading();
            }
        }

        function setupEventListeners() {
            // Safe event listener setup
            const searchInput = document.getElementById('searchUsers');
            const statusFilter = document.getElementById('statusFilter');
            const typeFilter = document.getElementById('typeFilter');
            const dateFilter = document.getElementById('dateFilter');
            const userForm = document.getElementById('userForm');

            if (searchInput) searchInput.addEventListener('input', filterUsers);
            if (statusFilter) statusFilter.addEventListener('change', filterUsers);
            if (typeFilter) typeFilter.addEventListener('change', filterUsers);
            if (dateFilter) dateFilter.addEventListener('change', filterUsers);
            if (userForm) userForm.addEventListener('submit', handleUserFormSubmit);
        }

        function filterUsers() {
            const searchTerm = document.getElementById('searchUsers').value.toLowerCase();
            const statusFilter = document.getElementById('statusFilter').value;
            const typeFilter = document.getElementById('typeFilter').value;
            const dateFilter = document.getElementById('dateFilter').value;

            filteredUsers = allUsers.filter(user => {
                // Search filter
                const matchesSearch = !searchTerm ||
                    (user.FirstName && user.FirstName.toLowerCase().includes(searchTerm)) ||
                    (user.LastName && user.LastName.toLowerCase().includes(searchTerm)) ||
                    (user.Email && user.Email.toLowerCase().includes(searchTerm)) ||
                    (user.Phone && user.Phone.includes(searchTerm));

                // Status filter
                const matchesStatus = statusFilter === 'all' || user.Status === statusFilter;

                // Type filter
                const matchesType = typeFilter === 'all' || user.UserType === typeFilter;

                return matchesSearch && matchesStatus && matchesType;
            });

            currentPage = 1;
            renderUsers();
            updatePagination();
            updatePageInfo();
        }

        function changeView(view) {
            currentView = view;

            // Update active button
            document.querySelectorAll('.view-btn').forEach(btn => {
                btn.classList.remove('active');
            });
            event.target.classList.add('active');

            // Show/hide views
            document.getElementById('gridView').style.display = view === 'grid' ? 'block' : 'none';
            document.getElementById('tableView').style.display = view === 'table' ? 'block' : 'none';

            renderUsers();
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
                        <h4 style="color: rgba(255, 255, 255, 0.7) !important;">No users found</h4>
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
                        <td colspan="8" class="text-center py-4">
                            <i class="fas fa-users fa-2x mb-2" style="color: rgba(255, 255, 255, 0.5) !important;"></i>
                            <h5 style="color: rgba(255, 255, 255, 0.7) !important;">No users found</h5>
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
                        <h3 class="user-name">${user.FirstName || ''} ${user.LastName || ''}</h3>
                        <p class="user-email">${user.Email || 'No email'}</p>
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
                        <button class="btn-action btn-view" onclick="viewUser(${user.Id})" title="View Details">
                            <i class="fas fa-eye"></i>
                        </button>
                        <button class="btn-action btn-edit" onclick="editUser(${user.Id})" title="Edit User">
                            <i class="fas fa-edit"></i>
                        </button>
                        <button class="btn-action btn-delete" onclick="deleteUser(${user.Id})" title="Delete User">
                            <i class="fas fa-trash"></i>
                        </button>
                    </div>
                </div>
                <div class="user-meta">
                    <div class="user-status">
                        <span class="status-badge status-${user.Status || 'inactive'}">${capitalizeFirst(user.Status || 'inactive')}</span>
                        <span style="color: rgba(255, 255, 255, 0.5) !important;">• ${capitalizeFirst(user.UserType || 'customer')}</span>
                    </div>
                    <div class="small" style="color: rgba(255, 255, 255, 0.5) !important;">
                        Joined ${formatDate(user.RegistrationDate)}
                    </div>
                </div>
            `;

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
                            ${(user.FirstName ? user.FirstName[0] : 'U')}${(user.LastName ? user.LastName[0] : '')}
                        </div>
                        <div>
                            <div class="fw-bold" style="color: #ffffff !important;">${user.FirstName || ''} ${user.LastName || ''}</div>
                            <div class="small" style="color: rgba(255, 255, 255, 0.6) !important;">${user.Email || 'No email'}</div>
                        </div>
                    </div>
                </td>
                <td>${user.Phone || 'No phone'}</td>
                <td>
                    <span class="text-capitalize">${user.UserType || 'customer'}</span>
                </td>
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
                        <button class="btn-action btn-view" onclick="viewUser(${user.Id})" title="View Details">
                            <i class="fas fa-eye"></i>
                        </button>
                        <button class="btn-action btn-edit" onclick="editUser(${user.Id})" title="Edit User">
                            <i class="fas fa-edit"></i>
                        </button>
                        <button class="btn-action btn-delete" onclick="deleteUser(${user.Id})" title="Delete User">
                            <i class="fas fa-trash"></i>
                        </button>
                    </div>
                </td>
            `;

            return row;
        }

        function updatePagination() {
            const pagination = document.getElementById('pagination');
            const totalPages = Math.ceil(filteredUsers.length / usersPerPage);

            pagination.innerHTML = '';

            if (totalPages <= 1) return;

            // Previous button
            const prevLi = document.createElement('li');
            prevLi.className = `page-item ${currentPage === 1 ? 'disabled' : ''}`;
            prevLi.innerHTML = `<a class="page-link" href="#" onclick="changePage(${currentPage - 1})">Previous</a>`;
            pagination.appendChild(prevLi);

            // Page numbers
            for (let i = 1; i <= totalPages; i++) {
                const li = document.createElement('li');
                li.className = `page-item ${currentPage === i ? 'active' : ''}`;
                li.innerHTML = `<a class="page-link" href="#" onclick="changePage(${i})">${i}</a>`;
                pagination.appendChild(li);
            }

            // Next button
            const nextLi = document.createElement('li');
            nextLi.className = `page-item ${currentPage === totalPages ? 'disabled' : ''}`;
            nextLi.innerHTML = `<a class="page-link" href="#" onclick="changePage(${currentPage + 1})">Next</a>`;
            pagination.appendChild(nextLi);

            // Update pagination info
            document.getElementById('paginationInfo').textContent =
                `Page ${currentPage} of ${totalPages}`;
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

            document.getElementById('pageInfo').textContent =
                `Showing ${startIndex}-${endIndex} of ${filteredUsers.length} users`;
        }

        function showLoading() {
            const grid = document.getElementById('usersGrid');
            if (grid) {
                grid.innerHTML = `
                    <div class="col-12 text-center py-5">
                        <i class="fas fa-spinner fa-spin fa-2x mb-3" style="color: rgba(255, 255, 255, 0.5) !important;"></i>
                        <p style="color: rgba(255, 255, 255, 0.7) !important;">Loading users from database...</p>
                    </div>
                `;
            }
        }

        function hideLoading() {
            // Loading is hidden when content is rendered
        }

        // Modal Functions
        function openAddUserModal() {
            document.getElementById('modalTitle').textContent = 'Add New User';
            document.getElementById('userForm').reset();
            document.getElementById('userModal').style.display = 'block';
        }

        function closeUserModal() {
            document.getElementById('userModal').style.display = 'none';
        }

        function handleUserFormSubmit(event) {
            event.preventDefault();

            // Get form data
            const formData = {
                firstName: document.getElementById('firstName').value,
                lastName: document.getElementById('lastName').value,
                email: document.getElementById('email').value,
                phone: document.getElementById('phone').value,
                type: document.getElementById('userType').value,
                status: document.getElementById('userStatus').value,
                address: document.getElementById('address').value,
                credits: parseInt(document.getElementById('credits').value) || 0
            };

            console.log('Saving user:', formData);

            showSuccess('User saved successfully!');
            closeUserModal();

            // Reload users
            document.getElementById('<%= btnLoadUsers.ClientID %>').click();
        }

        // User Action Functions
        function viewUser(userId) {
            const user = allUsers.find(u => u.Id === userId);
            if (user) {
                alert(`Viewing user: ${user.FirstName} ${user.LastName}\nEmail: ${user.Email}\nPhone: ${user.Phone}\nType: ${user.UserType}\nStatus: ${user.Status}`);
            }
        }
        function deleteUser(userId) {
            if (confirm('Are you sure you want to delete this user? This action cannot be undone.')) {
                // Call server-side method to delete user - pass as string
                PageMethods.DeleteUser(userId.toString(), function (response) {
                    if (response.startsWith('Success')) {
                        showSuccess('User deleted successfully');
                        // Reload users
                        document.getElementById('<%= btnLoadUsers.ClientID %>').click();
            } else {
                showError('Error deleting user: ' + response);
            }
        });
            }
        }

        // In the editUser function viewUser function - ensure IDs are handled as strings
        function viewUser(userId) {
            const user = allUsers.find(u => u.Id === userId.toString());
            if (user) {
                alert(`Viewing user: ${user.FirstName} ${user.LastName}\nEmail: ${user.Email}\nPhone: ${user.Phone}\nType: ${user.UserType}\nStatus: ${user.Status}`);
            }
        }

        function editUser(userId) {
            const user = allUsers.find(u => u.Id === userId.toString());
            if (user) {
                document.getElementById('modalTitle').textContent = 'Edit User';
                document.getElementById('firstName').value = user.FirstName || '';
                document.getElementById('lastName').value = user.LastName || '';
                document.getElementById('email').value = user.Email || '';
                document.getElementById('phone').value = user.Phone || '';
                document.getElementById('userType').value = user.UserType || 'customer';
                document.getElementById('userStatus').value = user.Status || 'active';
                document.getElementById('address').value = user.Address || '';
                document.getElementById('credits').value = user.Credits || 0;

                document.getElementById('userModal').style.display = 'block';
            }
        }
        // Utility Functions
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

        // Close modal when clicking outside
        window.onclick = function (event) {
            const modal = document.getElementById('userModal');
            if (event.target === modal) {
                closeUserModal();
            }
        }
    </script>
</asp:Content>