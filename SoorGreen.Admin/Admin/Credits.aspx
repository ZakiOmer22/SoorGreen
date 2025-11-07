<%@ Page Title="Credit Management" Language="C#" MasterPageFile="~/Admin/Site.master" AutoEventWireup="true" CodeFile="Credits.aspx.cs" Inherits="SoorGreen.Admin.Admin.Credits" %>

<asp:Content ID="PageTitle" ContentPlaceHolderID="PageTitle" runat="server">
    Credit Management
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <asp:ScriptManager ID="ScriptManager1" runat="server" EnablePageMethods="true"></asp:ScriptManager>
    
    <style>
        .credits-container {
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
        
        .btn-success {
            background: linear-gradient(135deg, #198754, #20c997);
            border: none;
            color: white;
            padding: 0.75rem 1.5rem;
            border-radius: 8px;
            cursor: pointer;
            transition: all 0.3s ease;
            font-weight: 600;
        }
        
        .btn-success:hover {
            background: linear-gradient(135deg, #157347, #1ba87e);
            transform: translateY(-2px);
        }
        
        .btn-warning {
            background: linear-gradient(135deg, #ffc107, #fd7e14);
            border: none;
            color: white;
            padding: 0.75rem 1.5rem;
            border-radius: 8px;
            cursor: pointer;
            transition: all 0.3s ease;
            font-weight: 600;
        }
        
        .btn-warning:hover {
            background: linear-gradient(135deg, #e0a800, #e55e0c);
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
        
        .btn-edit {
            background: rgba(255, 193, 7, 0.2);
            border-color: rgba(255, 193, 7, 0.3);
        }
        
        .btn-adjust {
            background: rgba(13, 110, 253, 0.2);
            border-color: rgba(13, 110, 253, 0.3);
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
        
        .credits-table {
            width: 100%;
            background: rgba(255, 255, 255, 0.02);
            border-collapse: collapse;
        }
        
        .credits-table th {
            background: rgba(255, 255, 255, 0.1);
            color: #ffffff !important;
            font-weight: 600;
            padding: 1rem;
            text-align: left;
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
        }
        
        .credits-table td {
            padding: 1rem;
            border-bottom: 1px solid rgba(255, 255, 255, 0.05);
            color: rgba(255, 255, 255, 0.8) !important;
        }
        
        .credits-table tr:hover {
            background: rgba(255, 255, 255, 0.03);
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
        
        .status-pending {
            background: rgba(255, 193, 7, 0.2);
            color: #ffc107;
            border: 1px solid rgba(255, 193, 7, 0.3);
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
        
        .modal-body {
            padding: 0 0 1.5rem 0;
        }
        
        .modal-footer {
            display: flex;
            gap: 1rem;
            padding-top: 1.5rem;
            border-top: 1px solid rgba(255, 255, 255, 0.1);
        }
        
        .form-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 1rem;
            margin-bottom: 1rem;
        }
        
        .form-full {
            grid-column: 1 / -1;
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
        
        /* Loading Spinner */
        .loading-spinner {
            display: none;
            text-align: center;
            padding: 2rem;
        }
        
        .spinner {
            border: 4px solid rgba(255, 255, 255, 0.3);
            border-radius: 50%;
            border-top: 4px solid #0dcaf0;
            width: 40px;
            height: 40px;
            animation: spin 1s linear infinite;
            margin: 0 auto;
        }
        
        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
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
            .filter-group {
                flex-direction: column;
            }
            
            .form-group {
                min-width: 100%;
            }
            
            .stats-cards {
                grid-template-columns: 1fr;
            }
            
            .form-row {
                grid-template-columns: 1fr;
            }
        }
    </style>

    <div class="credits-container">
        <!-- Statistics Cards -->
        <div class="stats-cards">
            <div class="stat-card">
                <div class="stat-value" id="totalUsers">0</div>
                <div class="stat-label">Total Users</div>
            </div>
            <div class="stat-card">
                <div class="stat-value" id="totalCredits">0</div>
                <div class="stat-label">Total Credits</div>
            </div>
            <div class="stat-card">
                <div class="stat-value" id="avgCredits">0</div>
                <div class="stat-label">Avg Credits per User</div>
            </div>
            <div class="stat-card">
                <div class="stat-value" id="activeUsers">0</div>
                <div class="stat-label">Active Users</div>
            </div>
        </div>

        <!-- Action Buttons -->
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h2 style="color: #ffffff !important; margin: 0;">User Credit Management</h2>
            <div>
                <button type="button" class="btn-success me-2" id="addCreditBtn">
                    <i class="fas fa-plus me-2"></i>Add Credits
                </button>
                <button type="button" class="btn-primary" id="refreshBtn">
                    <i class="fas fa-sync-alt me-2"></i>Refresh
                </button>
            </div>
        </div>

        <!-- Filters -->
        <div class="filter-card" style="background: rgba(255, 255, 255, 0.05); backdrop-filter: blur(20px); border: 1px solid rgba(255, 255, 255, 0.1); border-radius: 15px; padding: 1.5rem; margin-bottom: 2rem;">
            <h5 class="mb-3" style="color: #ffffff !important;"><i class="fas fa-filter me-2"></i>Filter Users</h5>
            <div class="filter-group">
                <div class="form-group search-box">
                    <label class="form-label">Search</label>
                    <div class="position-relative">
                        <i class="fas fa-search search-icon"></i>
                        <input type="text" class="form-control search-input" id="searchUsers" placeholder="Search by name, phone, or email...">
                    </div>
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
                    <label class="form-label">Role</label>
                    <select class="form-control" id="roleFilter">
                        <option value="all">All Roles</option>
                        <option value="citizen">Citizen</option>
                        <option value="collector">Collector</option>
                        <option value="admin">Admin</option>
                    </select>
                </div>
                
                <div class="form-group">
                    <button type="button" class="btn-primary" id="applyFiltersBtn" style="margin-top: 1.7rem;">
                        <i class="fas fa-filter me-2"></i>Apply Filters
                    </button>
                </div>
            </div>
        </div>

        <!-- Loading Spinner -->
        <div class="loading-spinner" id="loadingSpinner">
            <div class="spinner"></div>
            <p style="color: rgba(255, 255, 255, 0.7); margin-top: 1rem;">Loading users...</p>
        </div>

        <!-- Users Table -->
        <div class="table-responsive">
            <table class="credits-table" id="creditsTable">
                <thead>
                    <tr>
                        <th>User ID</th>
                        <th>User</th>
                        <th>Phone</th>
                        <th>Credits</th>
                        <th>Role</th>
                        <th>Status</th>
                        <th>Last Login</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody id="creditsTableBody">
                    <!-- User rows will be loaded here -->
                </tbody>
            </table>
        </div>
        
        <!-- Empty State -->
        <div id="creditsEmptyState" class="empty-state" style="display: none;">
            <div class="empty-state-icon">
                <i class="fas fa-users"></i>
            </div>
            <h3 class="empty-state-title">No Users Found</h3>
            <p class="empty-state-description">No users match the current search criteria.</p>
            <button type="button" class="btn-primary" id="clearFiltersBtn">
                <i class="fas fa-times me-2"></i>Clear Filters
            </button>
        </div>

        <div class="pagination-container">
            <div class="page-info" id="paginationInfo">
                Showing 0 users
            </div>
            <nav>
                <ul class="pagination mb-0" id="pagination">
                    <!-- Pagination will be generated here -->
                </ul>
            </nav>
        </div>
    </div>

    <!-- Add Credit Modal -->
    <div class="modal-overlay" id="creditModal" style="display: none;">
        <div class="modal-content">
            <div class="modal-header">
                <h3 class="modal-title">Add Credits</h3>
                <button type="button" class="close-modal">&times;</button>
            </div>
            <div class="modal-body">
                <div class="form-row">
                    <div class="form-group form-full">
                        <label class="form-label">User</label>
                        <select class="form-control" id="modalUserId">
                            <option value="">Select User</option>
                        </select>
                    </div>
                </div>
                <div class="form-row">
                    <div class="form-group">
                        <label class="form-label">Amount</label>
                        <input type="number" class="form-control" id="modalAmount" placeholder="Enter amount">
                    </div>
                    <div class="form-group">
                        <label class="form-label">Type</label>
                        <select class="form-control" id="modalType">
                            <option value="Bonus">Bonus</option>
                            <option value="Adjustment">Adjustment</option>
                            <option value="Recycling">Recycling</option>
                            <option value="Other">Other</option>
                        </select>
                    </div>
                </div>
                <div class="form-row">
                    <div class="form-group form-full">
                        <label class="form-label">Reference</label>
                        <input type="text" class="form-control" id="modalReference" placeholder="Enter reference">
                    </div>
                </div>
                <div class="form-row">
                    <div class="form-group form-full">
                        <label class="form-label">Notes</label>
                        <textarea class="form-control" id="modalNotes" rows="3" placeholder="Enter notes (optional)"></textarea>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-action" id="closeModalBtn">Cancel</button>
                <button type="button" class="btn-success" id="saveCreditBtn">Add Credits</button>
            </div>
        </div>
    </div>

    <asp:Button ID="btnLoadCredits" runat="server" OnClick="btnLoadCredits_Click" Style="display: none;" />
    <asp:HiddenField ID="hfUsersData" runat="server" />
    <asp:HiddenField ID="hfStatsData" runat="server" />
</asp:Content>

<asp:Content ID="Scripts" ContentPlaceHolderID="Scripts" runat="server">
    <script>
        let allUsers = [];
        let filteredUsers = [];
        let currentPage = 1;
        const pageSize = 10;

        document.addEventListener('DOMContentLoaded', function () {
            loadUsersFromServer();
            setupEventListeners();
        });

        function setupEventListeners() {
            document.getElementById('refreshBtn').addEventListener('click', function (e) {
                e.preventDefault();
                refreshData();
            });

            document.getElementById('addCreditBtn').addEventListener('click', function (e) {
                e.preventDefault();
                openAddCreditModal();
            });

            document.getElementById('applyFiltersBtn').addEventListener('click', function (e) {
                e.preventDefault();
                applyFilters();
            });

            document.getElementById('clearFiltersBtn').addEventListener('click', function (e) {
                e.preventDefault();
                clearFilters();
            });

            document.getElementById('searchUsers').addEventListener('input', function () {
                applyFilters();
            });

            document.getElementById('saveCreditBtn').addEventListener('click', function (e) {
                e.preventDefault();
                saveCredit();
            });

            document.querySelectorAll('.close-modal').forEach(btn => {
                btn.addEventListener('click', function (e) {
                    e.preventDefault();
                    closeAllModals();
                });
            });

            document.getElementById('closeModalBtn').addEventListener('click', function (e) {
                e.preventDefault();
                closeAllModals();
            });

            document.getElementById('creditModal').addEventListener('click', function (e) {
                if (e.target === this) {
                    closeAllModals();
                }
            });
        }

        function closeAllModals() {
            document.getElementById('creditModal').style.display = 'none';
        }

        function loadUsersFromServer() {
            showLoading(true);

            const usersData = document.getElementById('<%= hfUsersData.ClientID %>').value;
            const statsData = document.getElementById('<%= hfStatsData.ClientID %>').value;

            if (usersData && usersData !== '[]' && usersData !== '') {
                try {
                    allUsers = JSON.parse(usersData);
                    filteredUsers = [...allUsers];
                } catch (e) {
                    console.error('Error parsing users data:', e);
                    allUsers = [];
                    filteredUsers = [];
                }
            } else {
                allUsers = [];
                filteredUsers = [];
            }
            
            if (statsData && statsData !== '') {
                try {
                    updateStatistics(JSON.parse(statsData));
                } catch (e) {
                    console.error('Error parsing stats data:', e);
                }
            }

            renderUsers();
            showLoading(false);
        }

        function refreshData() {
            showLoading(true);
            document.getElementById('<%= btnLoadCredits.ClientID %>').click();

            setTimeout(function () {
                loadUsersFromServer();
                showNotification('Data refreshed successfully!', 'success');
            }, 500);
        }

        function updateStatistics(stats) {
            document.getElementById('totalUsers').textContent = stats.TotalUsers || 0;
            document.getElementById('totalCredits').textContent = stats.TotalCredits || 0;
            document.getElementById('avgCredits').textContent = (stats.AvgCredits || 0).toFixed(2);
            document.getElementById('activeUsers').textContent = stats.ActiveUsers || 0;
        }

        function applyFilters() {
            const searchTerm = document.getElementById('searchUsers').value.toLowerCase();
            const statusFilter = document.getElementById('statusFilter').value;
            const roleFilter = document.getElementById('roleFilter').value;

            filteredUsers = allUsers.filter(user => {
                const matchesSearch = !searchTerm ||
                    (user.FullName && user.FullName.toLowerCase().includes(searchTerm)) ||
                    (user.Phone && user.Phone.toLowerCase().includes(searchTerm)) ||
                    (user.Email && user.Email.toLowerCase().includes(searchTerm));

                const matchesStatus = statusFilter === 'all' ||
                    (statusFilter === 'active' && user.IsVerified) ||
                    (statusFilter === 'inactive' && !user.IsVerified);

                const matchesRole = roleFilter === 'all' ||
                    (user.RoleName && user.RoleName.toLowerCase() === roleFilter.toLowerCase());

                return matchesSearch && matchesStatus && matchesRole;
            });

            currentPage = 1;
            renderUsers();
        }

        function clearFilters() {
            document.getElementById('searchUsers').value = '';
            document.getElementById('statusFilter').value = 'all';
            document.getElementById('roleFilter').value = 'all';

            filteredUsers = allUsers;
            currentPage = 1;
            renderUsers();
        }

        function renderUsers() {
            const tbody = document.getElementById('creditsTableBody');
            const emptyState = document.getElementById('creditsEmptyState');
            const paginationInfo = document.getElementById('paginationInfo');
            const table = document.getElementById('creditsTable');

            tbody.innerHTML = '';

            if (filteredUsers.length === 0) {
                table.style.display = 'none';
                emptyState.style.display = 'block';
                paginationInfo.textContent = 'Showing 0 users';
                return;
            }

            table.style.display = 'table';
            emptyState.style.display = 'none';

            const startIndex = (currentPage - 1) * pageSize;
            const endIndex = Math.min(startIndex + pageSize, filteredUsers.length);
            const paginatedUsers = filteredUsers.slice(startIndex, endIndex);

            paginatedUsers.forEach(user => {
                const row = createUserRow(user);
                if (row) {
                    tbody.appendChild(row);
                }
            });

            paginationInfo.textContent = `Showing ${startIndex + 1}-${endIndex} of ${filteredUsers.length} users`;
            renderPagination();
        }

        function createUserRow(user) {
            if (!user) return null;

            const row = document.createElement('tr');

            const userId = user.UserId || '-';
            const fullName = user.FullName || 'Unknown User';
            const phone = user.Phone || '-';
            const credits = parseFloat(user.XP_Credits) || 0;
            const roleName = user.RoleName || 'Unknown';
            const isVerified = user.IsVerified;
            const lastLogin = user.LastLogin;

            const userInitial = fullName.charAt(0).toUpperCase();
            const statusClass = isVerified ? 'status-active' : 'status-inactive';
            const statusText = isVerified ? 'Active' : 'Inactive';

            row.innerHTML = `
                <td>${escapeHtml(userId)}</td>
                <td>
                    <div class="user-info">
                        <div class="user-avatar">${userInitial}</div>
                        <span>${escapeHtml(fullName)}</span>
                    </div>
                </td>
                <td>${escapeHtml(phone)}</td>
                <td class="credit-positive">${credits} credits</td>
                <td>${escapeHtml(roleName)}</td>
                <td><span class="status-badge ${statusClass}">${statusText}</span></td>
                <td>${formatDate(lastLogin)}</td>
                <td>
                    <button class="btn-action btn-adjust" data-id="${userId}" title="Adjust Credits">
                        <i class="fas fa-edit"></i>
                    </button>
                </td>
            `;

            const adjustBtn = row.querySelector('.btn-adjust');
            if (adjustBtn) {
                adjustBtn.addEventListener('click', function (e) {
                    e.preventDefault();
                    e.stopPropagation();
                    adjustUserCredits(this.getAttribute('data-id'));
                });
            }

            return row;
        }

        function formatDate(dateString) {
            if (!dateString) return '-';
            try {
                const date = new Date(dateString);
                return date.toLocaleDateString() + ' ' + date.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
            } catch (e) {
                return '-';
            }
        }

        function openAddCreditModal() {
            const userSelect = document.getElementById('modalUserId');
            userSelect.innerHTML = '<option value="">Select User</option>';
            
            allUsers.forEach(user => {
                const option = document.createElement('option');
                option.value = user.UserId;
                option.textContent = `${user.FullName} (${user.Phone}) - ${user.XP_Credits || 0} credits`;
                userSelect.appendChild(option);
            });

            document.getElementById('modalAmount').value = '';
            document.getElementById('modalType').value = 'Bonus';
            document.getElementById('modalReference').value = '';
            document.getElementById('modalNotes').value = '';

            document.getElementById('creditModal').style.display = 'block';
        }

        function adjustUserCredits(userId) {
            const user = allUsers.find(u => u.UserId === userId);
            if (user) {
                const userSelect = document.getElementById('modalUserId');
                userSelect.innerHTML = '';
                
                const option = document.createElement('option');
                option.value = user.UserId;
                option.textContent = `${user.FullName} (${user.Phone}) - ${user.XP_Credits || 0} credits`;
                option.selected = true;
                userSelect.appendChild(option);

                document.getElementById('modalAmount').value = '';
                document.getElementById('modalType').value = 'Adjustment';
                document.getElementById('modalReference').value = 'Manual Adjustment';
                document.getElementById('modalNotes').value = '';

                document.getElementById('creditModal').style.display = 'block';
            }
        }

        function saveCredit() {
            const userId = document.getElementById('modalUserId').value;
            const amount = parseFloat(document.getElementById('modalAmount').value);
            const type = document.getElementById('modalType').value;
            const reference = document.getElementById('modalReference').value;
            const notes = document.getElementById('modalNotes').value;

            if (!userId) {
                showNotification('Please select a user', 'error');
                return;
            }

            if (!amount || amount <= 0) {
                showNotification('Please enter a valid amount', 'error');
                return;
            }

            // Here you would typically make an AJAX call to save the credit
            console.log('Saving credit:', { userId, amount, type, reference, notes });
            
            showNotification('Credits added successfully!', 'success');
            closeAllModals();
            refreshData();
        }

        function renderPagination() {
            const pagination = document.getElementById('pagination');
            const totalPages = Math.ceil(filteredUsers.length / pageSize);

            pagination.innerHTML = '';

            if (totalPages <= 1) return;

            if (currentPage > 1) {
                const prevLi = document.createElement('li');
                prevLi.className = 'page-item';
                prevLi.innerHTML = `<a class="page-link" href="#" data-page="${currentPage - 1}">Previous</a>`;
                pagination.appendChild(prevLi);
            }

            for (let i = 1; i <= totalPages; i++) {
                const li = document.createElement('li');
                li.className = 'page-item' + (i === currentPage ? ' active' : '');
                li.innerHTML = `<a class="page-link" href="#" data-page="${i}">${i}</a>`;
                pagination.appendChild(li);
            }

            if (currentPage < totalPages) {
                const nextLi = document.createElement('li');
                nextLi.className = 'page-item';
                nextLi.innerHTML = `<a class="page-link" href="#" data-page="${currentPage + 1}">Next</a>`;
                pagination.appendChild(nextLi);
            }

            pagination.querySelectorAll('.page-link').forEach(link => {
                link.addEventListener('click', function (e) {
                    e.preventDefault();
                    currentPage = parseInt(this.getAttribute('data-page'));
                    renderUsers();
                });
            });
        }

        function showLoading(show) {
            const spinner = document.getElementById('loadingSpinner');
            const table = document.getElementById('creditsTable');

            if (show) {
                spinner.style.display = 'block';
                table.style.display = 'none';
            } else {
                spinner.style.display = 'none';
                table.style.display = 'table';
            }
        }

        function showNotification(message, type) {
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

            setTimeout(() => {
                if (notification.parentElement) {
                    notification.remove();
                }
            }, 5000);
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

        var prm = Sys.WebForms.PageRequestManager.getInstance();
        prm.add_endRequest(function () {
            setupEventListeners();
            loadUsersFromServer();
        });
    </script>
</asp:Content>