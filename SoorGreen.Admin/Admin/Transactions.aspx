<%@ Page Title="Transactions" Language="C#" MasterPageFile="~/Admin/Site.master" AutoEventWireup="true" CodeFile="Transactions.aspx.cs" Inherits="SoorGreen.Admin.Admin.Transactions" %>
<%@ Register Assembly="System.Web.Extensions, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35" Namespace="System.Web.UI" TagPrefix="asp" %>

<asp:Content ID="PageTitle" ContentPlaceHolderID="PageTitle" runat="server">
    Transaction History
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <asp:ScriptManager ID="ScriptManager1" runat="server" EnablePageMethods="true"></asp:ScriptManager>
    
    <style>
        .transactions-container {
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
        
        .btn-export {
            background: linear-gradient(135deg, #198754, #20c997);
            border: none;
            color: white;
            padding: 0.75rem 1.5rem;
            border-radius: 8px;
            cursor: pointer;
            transition: all 0.3s ease;
            font-weight: 600;
        }
        
        .btn-export:hover {
            background: linear-gradient(135deg, #157347, #1ba87e);
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
        
        .transactions-table {
            width: 100%;
            background: rgba(255, 255, 255, 0.02);
            border-collapse: collapse;
        }
        
        .transactions-table th {
            background: rgba(255, 255, 255, 0.1);
            color: #ffffff !important;
            font-weight: 600;
            padding: 1rem;
            text-align: left;
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
        }
        
        .transactions-table td {
            padding: 1rem;
            border-bottom: 1px solid rgba(255, 255, 255, 0.05);
            color: rgba(255, 255, 255, 0.8) !important;
        }
        
        .transactions-table tr:hover {
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
        
        .type-badge {
            padding: 0.3rem 0.8rem;
            border-radius: 20px;
            font-size: 0.75rem;
            font-weight: 600;
        }
        
        .type-credit {
            background: rgba(25, 135, 84, 0.2);
            color: #198754;
            border: 1px solid rgba(25, 135, 84, 0.3);
        }
        
        .type-bonus {
            background: rgba(255, 193, 7, 0.2);
            color: #ffc107;
            border: 1px solid rgba(255, 193, 7, 0.3);
        }
        
        .type-redemption {
            background: rgba(220, 53, 69, 0.2);
            color: #dc3545;
            border: 1px solid rgba(220, 53, 69, 0.3);
        }
        
        .type-adjustment {
            background: rgba(108, 117, 125, 0.2);
            color: #6c757d;
            border: 1px solid rgba(108, 117, 125, 0.3);
        }
        
        .type-recycling {
            background: rgba(13, 110, 253, 0.2);
            color: #0d6efd;
            border: 1px solid rgba(13, 110, 253, 0.3);
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
            
            .info-grid {
                grid-template-columns: 1fr;
            }
        }
    </style>

    <div class="transactions-container">
        <!-- Statistics Cards -->
        <div class="stats-cards">
            <div class="stat-card">
                <div class="stat-value" id="totalTransactions">0</div>
                <div class="stat-label">Total Transactions</div>
            </div>
            <div class="stat-card">
                <div class="stat-value" id="totalCredits">0</div>
                <div class="stat-label">Total Credits Issued</div>
            </div>
            <div class="stat-card">
                <div class="stat-value" id="avgTransaction">0</div>
                <div class="stat-label">Avg Transaction Value</div>
            </div>
            <div class="stat-card">
                <div class="stat-value" id="todayTransactions">0</div>
                <div class="stat-label">Today's Transactions</div>
            </div>
        </div>

        <!-- Action Buttons -->
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h2 style="color: #ffffff !important; margin: 0;">Transaction History</h2>
            <div>
                <button type="button" class="btn-export me-2" id="exportBtn">
                    <i class="fas fa-download me-2"></i>Export CSV
                </button>
                <button type="button" class="btn-primary" id="refreshBtn">
                    <i class="fas fa-sync-alt me-2"></i>Refresh
                </button>
            </div>
        </div>

        <!-- Filters -->
        <div class="filter-card" style="background: rgba(255, 255, 255, 0.05); backdrop-filter: blur(20px); border: 1px solid rgba(255, 255, 255, 0.1); border-radius: 15px; padding: 1.5rem; margin-bottom: 2rem;">
            <h5 class="mb-3" style="color: #ffffff !important;"><i class="fas fa-filter me-2"></i>Filter Transactions</h5>
            <div class="filter-group">
                <div class="form-group search-box">
                    <label class="form-label">Search</label>
                    <div class="position-relative">
                        <i class="fas fa-search search-icon"></i>
                        <input type="text" class="form-control search-input" id="searchTransactions" placeholder="Search by user, reference, or type...">
                    </div>
                </div>
                
                <div class="form-group">
                    <label class="form-label">Transaction Type</label>
                    <select class="form-control" id="typeFilter">
                        <option value="all">All Types</option>
                        <option value="recycling">Recycling</option>
                        <option value="bonus">Bonus</option>
                        <option value="redemption">Redemption</option>
                        <option value="adjustment">Adjustment</option>
                    </select>
                </div>
                
                <div class="form-group">
                    <label class="form-label">Date From</label>
                    <input type="date" class="form-control" id="dateFrom">
                </div>
                
                <div class="form-group">
                    <label class="form-label">Date To</label>
                    <input type="date" class="form-control" id="dateTo">
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
            <p style="color: rgba(255, 255, 255, 0.7); margin-top: 1rem;">Loading transactions...</p>
        </div>

        <!-- Transactions Table -->
        <div class="table-responsive">
            <table class="transactions-table" id="transactionsTable">
                <thead>
                    <tr>
                        <th>Transaction ID</th>
                        <th>User</th>
                        <th>Amount</th>
                        <th>Type</th>
                        <th>Reference</th>
                        <th>Date</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody id="transactionsTableBody">
                    <!-- Transaction rows will be loaded here -->
                </tbody>
            </table>
        </div>
        
        <!-- Empty State -->
        <div id="transactionsEmptyState" class="empty-state" style="display: none;">
            <div class="empty-state-icon">
                <i class="fas fa-coins"></i>
            </div>
            <h3 class="empty-state-title">No Transactions Found</h3>
            <p class="empty-state-description">No transactions match the current search criteria.</p>
            <button type="button" class="btn-primary" id="clearFiltersBtn">
                <i class="fas fa-times me-2"></i>Clear Filters
            </button>
        </div>

        <div class="pagination-container">
            <div class="page-info" id="paginationInfo">
                Showing 0 transactions
            </div>
            <nav>
                <ul class="pagination mb-0" id="pagination">
                    <!-- Pagination will be generated here -->
                </ul>
            </nav>
        </div>
    </div>

    <!-- Transaction Details Modal -->
    <div class="modal-overlay" id="transactionModal" style="display: none;">
        <div class="modal-content" style="max-width: 600px;">
            <div class="modal-header">
                <h3 class="modal-title">Transaction Details</h3>
                <button type="button" class="close-modal">&times;</button>
            </div>
            <div class="modal-body">
                <div class="info-grid">
                    <div class="info-item">
                        <label>Transaction ID:</label>
                        <span id="modalTransactionId">-</span>
                    </div>
                    <div class="info-item">
                        <label>Type:</label>
                        <span id="modalType">-</span>
                    </div>
                    <div class="info-item">
                        <label>User:</label>
                        <div class="user-info">
                            <div class="user-avatar" id="modalUserAvatar">U</div>
                            <span id="modalUserName">-</span>
                        </div>
                    </div>
                    <div class="info-item">
                        <label>Phone:</label>
                        <span id="modalUserPhone">-</span>
                    </div>
                    <div class="info-item">
                        <label>Amount:</label>
                        <span id="modalAmount">-</span>
                    </div>
                    <div class="info-item">
                        <label>Reference:</label>
                        <span id="modalReference">-</span>
                    </div>
                    <div class="info-item">
                        <label>Date:</label>
                        <span id="modalDate">-</span>
                    </div>
                    <div class="info-item full-width">
                        <label>Notes:</label>
                        <span id="modalNotes">-</span>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-action" id="closeModalBtn">Close</button>
            </div>
        </div>
    </div>

    <asp:Button ID="btnLoadTransactions" runat="server" OnClick="btnLoadTransactions_Click" Style="display: none;" />
    <asp:HiddenField ID="hfTransactionsData" runat="server" />
    <asp:HiddenField ID="hfStatsData" runat="server" />
</asp:Content>


<asp:Content ID="Scripts" ContentPlaceHolderID="Scripts" runat="server">
    <script>
        let allTransactions = [];
        let filteredTransactions = [];
        let currentPage = 1;
        const pageSize = 10;

        document.addEventListener('DOMContentLoaded', function () {
            loadTransactionsFromServer();
            setupEventListeners();
        });

        function setupEventListeners() {
            document.getElementById('refreshBtn').addEventListener('click', function (e) {
                e.preventDefault();
                refreshData();
            });

            document.getElementById('exportBtn').addEventListener('click', function (e) {
                e.preventDefault();
                exportToCSV();
            });

            document.getElementById('applyFiltersBtn').addEventListener('click', function (e) {
                e.preventDefault();
                applyFilters();
            });

            document.getElementById('clearFiltersBtn').addEventListener('click', function (e) {
                e.preventDefault();
                clearFilters();
            });

            document.getElementById('searchTransactions').addEventListener('input', function () {
                applyFilters();
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

            document.getElementById('transactionModal').addEventListener('click', function (e) {
                if (e.target === this) {
                    closeAllModals();
                }
            });
        }

        function closeAllModals() {
            document.getElementById('transactionModal').style.display = 'none';
        }

        function loadTransactionsFromServer() {
            showLoading(true);

            const transactionsData = document.getElementById('<%= hfTransactionsData.ClientID %>').value;
        const statsData = document.getElementById('<%= hfStatsData.ClientID %>').value;

        console.log('Transactions data received:', transactionsData);
        console.log('Stats data received:', statsData);

        if (transactionsData && transactionsData !== '[]' && transactionsData !== '') {
            try {
                allTransactions = JSON.parse(transactionsData);
                filteredTransactions = [...allTransactions];
                console.log('Successfully loaded transactions:', allTransactions.length);
                console.log('Sample transaction:', allTransactions[0]);
            } catch (e) {
                console.error('Error parsing transactions data:', e);
                allTransactions = [];
                filteredTransactions = [];
            }
        } else {
            console.log('No transactions data found');
            allTransactions = [];
            filteredTransactions = [];
        }
        
        if (statsData && statsData !== '') {
            try {
                updateStatistics(JSON.parse(statsData));
            } catch (e) {
                console.error('Error parsing stats data:', e);
            }
        }

        renderTransactions();
        showLoading(false);
    }

    function refreshData() {
        showLoading(true);
        console.log('Refreshing data...');
        
        document.getElementById('<%= btnLoadTransactions.ClientID %>').click();

            setTimeout(function () {
                loadTransactionsFromServer();
                showNotification('Data refreshed successfully!', 'success');
            }, 500);
        }

        function updateStatistics(stats) {
            document.getElementById('totalTransactions').textContent = stats.TotalTransactions || 0;
            document.getElementById('totalCredits').textContent = stats.TotalCredits || 0;
            document.getElementById('avgTransaction').textContent = (stats.AvgTransaction || 0).toFixed(2);
            document.getElementById('todayTransactions').textContent = stats.TodayTransactions || 0;
        }

        function applyFilters() {
            const searchTerm = document.getElementById('searchTransactions').value.toLowerCase();
            const typeFilter = document.getElementById('typeFilter').value;
            const dateFrom = document.getElementById('dateFrom').value;
            const dateTo = document.getElementById('dateTo').value;

            filteredTransactions = allTransactions.filter(transaction => {
                const matchesSearch = !searchTerm ||
                    (transaction.FullName && transaction.FullName.toLowerCase().includes(searchTerm)) ||
                    (transaction.Reference && transaction.Reference.toLowerCase().includes(searchTerm)) ||
                    (transaction.Type && transaction.Type.toLowerCase().includes(searchTerm));

                const matchesType = typeFilter === 'all' ||
                    (transaction.Type && transaction.Type.toLowerCase() === typeFilter.toLowerCase());

                let matchesDate = true;
                if (dateFrom && transaction.CreatedAt) {
                    const transactionDate = new Date(transaction.CreatedAt);
                    const fromDate = new Date(dateFrom);
                    matchesDate = transactionDate >= fromDate;
                }
                if (dateTo && transaction.CreatedAt) {
                    const transactionDate = new Date(transaction.CreatedAt);
                    const toDate = new Date(dateTo);
                    toDate.setDate(toDate.getDate() + 1);
                    matchesDate = matchesDate && transactionDate < toDate;
                }

                return matchesSearch && matchesType && matchesDate;
            });

            currentPage = 1;
            renderTransactions();
        }

        function clearFilters() {
            document.getElementById('searchTransactions').value = '';
            document.getElementById('typeFilter').value = 'all';
            document.getElementById('dateFrom').value = '';
            document.getElementById('dateTo').value = '';

            filteredTransactions = allTransactions;
            currentPage = 1;
            renderTransactions();
        }

        function renderTransactions() {
            const tbody = document.getElementById('transactionsTableBody');
            const emptyState = document.getElementById('transactionsEmptyState');
            const paginationInfo = document.getElementById('paginationInfo');
            const table = document.getElementById('transactionsTable');

            tbody.innerHTML = '';

            console.log('Rendering transactions:', filteredTransactions.length);

            if (filteredTransactions.length === 0) {
                table.style.display = 'none';
                emptyState.style.display = 'block';
                paginationInfo.textContent = 'Showing 0 transactions';
                return;
            }

            table.style.display = 'table';
            emptyState.style.display = 'none';

            const startIndex = (currentPage - 1) * pageSize;
            const endIndex = Math.min(startIndex + pageSize, filteredTransactions.length);
            const paginatedTransactions = filteredTransactions.slice(startIndex, endIndex);

            console.log('Creating table rows for:', paginatedTransactions.length, 'transactions');

            paginatedTransactions.forEach(transaction => {
                const row = createTransactionRow(transaction);
                if (row) {
                    tbody.appendChild(row);
                }
            });

            paginationInfo.textContent = `Showing ${startIndex + 1}-${endIndex} of ${filteredTransactions.length} transactions`;
            renderPagination();
        }

        function createTransactionRow(transaction) {
            if (!transaction) return null;

            const row = document.createElement('tr');

            // Safely extract values with proper fallbacks
            const transactionId = transaction.RewardId || transaction.TransactionId || '-';
            const fullName = transaction.FullName || 'Unknown User';
            const amount = parseFloat(transaction.Amount) || 0;
            const type = transaction.Type || 'Unknown';
            const reference = transaction.Reference || '-';
            const createdAt = transaction.CreatedAt || new Date().toISOString();

            const userInitial = fullName.charAt(0).toUpperCase();
            const isPositive = amount > 0;
            const typeClass = 'type-' + type.toLowerCase().replace(/\s+/g, '-');

            row.innerHTML = `
            <td>${escapeHtml(transactionId)}</td>
            <td>
                <div class="user-info">
                    <div class="user-avatar">${userInitial}</div>
                    <span>${escapeHtml(fullName)}</span>
                </div>
            </td>
            <td class="${isPositive ? 'credit-positive' : 'credit-negative'}">
                ${isPositive ? '+' : ''}${amount} credits
            </td>
            <td><span class="type-badge ${typeClass}">${escapeHtml(type)}</span></td>
            <td>${escapeHtml(reference)}</td>
            <td>${formatDate(createdAt)}</td>
            <td>
                <button class="btn-action btn-view" data-id="${transactionId}" title="View Details">
                    <i class="fas fa-eye"></i>
                </button>
            </td>
        `;

            // Add event listener to view button
            const viewBtn = row.querySelector('.btn-view');
            if (viewBtn) {
                viewBtn.addEventListener('click', function (e) {
                    e.preventDefault();
                    e.stopPropagation();
                    viewTransaction(this.getAttribute('data-id'));
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

        function viewTransaction(id) {
            const transaction = allTransactions.find(t =>
                (t.RewardId === id) || (t.TransactionId === id)
            );

            if (transaction) {
                const userInitial = transaction.FullName ? transaction.FullName.charAt(0).toUpperCase() : 'U';

                document.getElementById('modalTransactionId').textContent = transaction.RewardId || transaction.TransactionId || '-';
                document.getElementById('modalType').textContent = transaction.Type || 'Credit';
                document.getElementById('modalUserName').textContent = transaction.FullName || 'Unknown';
                document.getElementById('modalUserAvatar').textContent = userInitial;
                document.getElementById('modalUserPhone').textContent = transaction.Phone || '-';
                document.getElementById('modalAmount').textContent = (transaction.Amount || 0) + ' credits';
                document.getElementById('modalReference').textContent = transaction.Reference || '-';
                document.getElementById('modalDate').textContent = formatDate(transaction.CreatedAt);
                document.getElementById('modalNotes').textContent = transaction.Notes || 'No additional notes';

                document.getElementById('transactionModal').style.display = 'block';
            }
        }

        function renderPagination() {
            const pagination = document.getElementById('pagination');
            const totalPages = Math.ceil(filteredTransactions.length / pageSize);

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
                    renderTransactions();
                });
            });
        }

        function exportToCSV() {
            if (filteredTransactions.length === 0) {
                showNotification('No transactions to export', 'error');
                return;
            }

            let csv = 'Transaction ID,User,Amount,Type,Reference,Date\n';

            filteredTransactions.forEach(transaction => {
                csv += `"${transaction.RewardId || ''}","${transaction.FullName || ''}",${transaction.Amount || 0},"${transaction.Type || ''}","${transaction.Reference || ''}","${formatDate(transaction.CreatedAt)}"\n`;
            });

            const blob = new Blob([csv], { type: 'text/csv' });
            const url = window.URL.createObjectURL(blob);
            const a = document.createElement('a');
            a.setAttribute('hidden', '');
            a.setAttribute('href', url);
            a.setAttribute('download', `transactions_${new Date().toISOString().split('T')[0]}.csv`);
            document.body.appendChild(a);
            a.click();
            document.body.removeChild(a);

            showNotification('CSV exported successfully!', 'success');
        }

        function showLoading(show) {
            const spinner = document.getElementById('loadingSpinner');
            const table = document.getElementById('transactionsTable');

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
            loadTransactionsFromServer();
        });
    </script>
</asp:Content>