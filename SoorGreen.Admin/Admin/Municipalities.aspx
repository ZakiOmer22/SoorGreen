<%@ Page Title="Municipalities" Language="C#" MasterPageFile="~/Admin/Site.master" AutoEventWireup="true" CodeFile="Municipalities.aspx.cs" Inherits="SoorGreen.Admin.Admin.Municipalities" %>

<asp:Content ID="PageTitle" ContentPlaceHolderID="PageTitle" runat="server">
    Municipalities Management
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <asp:ScriptManager ID="ScriptManager1" runat="server" EnablePageMethods="true"></asp:ScriptManager>
    
    <style>
        .municipalities-container {
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
        
        .btn-delete {
            background: rgba(220, 53, 69, 0.2);
            border-color: rgba(220, 53, 69, 0.3);
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
        
        .municipalities-table {
            width: 100%;
            background: rgba(255, 255, 255, 0.02);
            border-collapse: collapse;
        }
        
        .municipalities-table th {
            background: rgba(255, 255, 255, 0.1);
            color: #ffffff !important;
            font-weight: 600;
            padding: 1rem;
            text-align: left;
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
        }
        
        .municipalities-table td {
            padding: 1rem;
            border-bottom: 1px solid rgba(255, 255, 255, 0.05);
            color: rgba(255, 255, 255, 0.8) !important;
        }
        
        .municipalities-table tr:hover {
            background: rgba(255, 255, 255, 0.03);
        }
        
        .municipality-avatar {
            width: 40px;
            height: 40px;
            border-radius: 8px;
            background: linear-gradient(135deg, #0d6efd, #0dcaf0);
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: bold;
            color: white;
            font-size: 1rem;
        }
        
        .municipality-info {
            display: flex;
            align-items: center;
            gap: 0.75rem;
        }
        
        .user-count {
            background: rgba(25, 135, 84, 0.2);
            color: #198754;
            padding: 0.25rem 0.75rem;
            border-radius: 20px;
            font-size: 0.8rem;
            font-weight: 600;
        }
        
        .report-count {
            background: rgba(13, 110, 253, 0.2);
            color: #0d6efd;
            padding: 0.25rem 0.75rem;
            border-radius: 20px;
            font-size: 0.8rem;
            font-weight: 600;
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
            grid-template-columns: 1fr;
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
            
            .municipality-info {
                flex-direction: column;
                align-items: flex-start;
                gap: 0.5rem;
            }
        }
    </style>

    <div class="municipalities-container">
        <!-- Statistics Cards -->
        <div class="stats-cards">
            <div class="stat-card">
                <div class="stat-value" id="totalMunicipalities">0</div>
                <div class="stat-label">Total Municipalities</div>
            </div>
            <div class="stat-card">
                <div class="stat-value" id="totalUsers">0</div>
                <div class="stat-label">Total Users</div>
            </div>
            <div class="stat-card">
                <div class="stat-value" id="totalReports">0</div>
                <div class="stat-label">Total Reports</div>
            </div>
            <div class="stat-card">
                <div class="stat-value" id="avgUsers">0</div>
                <div class="stat-label">Avg Users per Municipality</div>
            </div>
        </div>

        <!-- Action Buttons -->
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h2 style="color: #ffffff !important; margin: 0;">Municipalities Management</h2>
            <div>
                <button type="button" class="btn-success me-2" id="addMunicipalityBtn">
                    <i class="fas fa-plus me-2"></i>Add Municipality
                </button>
                <button type="button" class="btn-primary" id="refreshBtn">
                    <i class="fas fa-sync-alt me-2"></i>Refresh
                </button>
            </div>
        </div>

        <!-- Filters -->
        <div class="filter-card" style="background: rgba(255, 255, 255, 0.05); backdrop-filter: blur(20px); border: 1px solid rgba(255, 255, 255, 0.1); border-radius: 15px; padding: 1.5rem; margin-bottom: 2rem;">
            <h5 class="mb-3" style="color: #ffffff !important;"><i class="fas fa-filter me-2"></i>Filter Municipalities</h5>
            <div class="filter-group">
                <div class="form-group search-box">
                    <label class="form-label">Search</label>
                    <div class="position-relative">
                        <i class="fas fa-search search-icon"></i>
                        <input type="text" class="form-control search-input" id="searchMunicipalities" placeholder="Search by municipality name...">
                    </div>
                </div>
                
                <div class="form-group">
                    <label class="form-label">Sort By</label>
                    <select class="form-control" id="sortFilter">
                        <option value="name">Name (A-Z)</option>
                        <option value="name_desc">Name (Z-A)</option>
                        <option value="users">Most Users</option>
                        <option value="reports">Most Reports</option>
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
            <p style="color: rgba(255, 255, 255, 0.7); margin-top: 1rem;">Loading municipalities...</p>
        </div>

        <!-- Municipalities Table -->
        <div class="table-responsive">
            <table class="municipalities-table" id="municipalitiesTable">
                <thead>
                    <tr>
                        <th>Municipality</th>
                        <th>Users</th>
                        <th>Reports</th>
                        <th>Total Credits</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody id="municipalitiesTableBody">
                    <!-- Municipality rows will be loaded here -->
                </tbody>
            </table>
        </div>
        
        <!-- Empty State -->
        <div id="municipalitiesEmptyState" class="empty-state" style="display: none;">
            <div class="empty-state-icon">
                <i class="fas fa-city"></i>
            </div>
            <h3 class="empty-state-title">No Municipalities Found</h3>
            <p class="empty-state-description">No municipalities match the current search criteria.</p>
            <button type="button" class="btn-primary" id="clearFiltersBtn">
                <i class="fas fa-times me-2"></i>Clear Filters
            </button>
        </div>

        <div class="pagination-container">
            <div class="page-info" id="paginationInfo">
                Showing 0 municipalities
            </div>
            <nav>
                <ul class="pagination mb-0" id="pagination">
                    <!-- Pagination will be generated here -->
                </ul>
            </nav>
        </div>
    </div>

    <!-- Add/Edit Municipality Modal -->
    <div class="modal-overlay" id="municipalityModal" style="display: none;">
        <div class="modal-content">
            <div class="modal-header">
                <h3 class="modal-title" id="modalTitle">Add Municipality</h3>
                <button type="button" class="close-modal">&times;</button>
            </div>
            <div class="modal-body">
                <div class="form-row">
                    <div class="form-group form-full">
                        <label class="form-label">Municipality ID</label>
                        <input type="text" class="form-control" id="modalMunicipalityId" placeholder="e.g., M001" maxlength="4">
                    </div>
                </div>
                <div class="form-row">
                    <div class="form-group form-full">
                        <label class="form-label">Municipality Name</label>
                        <input type="text" class="form-control" id="modalName" placeholder="Enter municipality name">
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-action" id="closeModalBtn">Cancel</button>
                <button type="button" class="btn-success" id="saveMunicipalityBtn">Save Municipality</button>
            </div>
        </div>
    </div>

    <asp:Button ID="btnLoadMunicipalities" runat="server" OnClick="btnLoadMunicipalities_Click" Style="display: none;" />
    <asp:HiddenField ID="hfMunicipalitiesData" runat="server" />
    <asp:HiddenField ID="hfStatsData" runat="server" />
</asp:Content>

<asp:Content ID="Scripts" ContentPlaceHolderID="Scripts" runat="server">
    <script>
        let allMunicipalities = [];
        let filteredMunicipalities = [];
        let currentPage = 1;
        const pageSize = 10;
        let editingMunicipalityId = null;

        document.addEventListener('DOMContentLoaded', function () {
            loadMunicipalitiesFromServer();
            setupEventListeners();
        });

        function setupEventListeners() {
            document.getElementById('refreshBtn').addEventListener('click', function (e) {
                e.preventDefault();
                refreshData();
            });

            document.getElementById('addMunicipalityBtn').addEventListener('click', function (e) {
                e.preventDefault();
                openAddMunicipalityModal();
            });

            document.getElementById('applyFiltersBtn').addEventListener('click', function (e) {
                e.preventDefault();
                applyFilters();
            });

            document.getElementById('clearFiltersBtn').addEventListener('click', function (e) {
                e.preventDefault();
                clearFilters();
            });

            document.getElementById('searchMunicipalities').addEventListener('input', function () {
                applyFilters();
            });

            document.getElementById('saveMunicipalityBtn').addEventListener('click', function (e) {
                e.preventDefault();
                saveMunicipality();
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

            document.getElementById('municipalityModal').addEventListener('click', function (e) {
                if (e.target === this) {
                    closeAllModals();
                }
            });
        }

        function closeAllModals() {
            document.getElementById('municipalityModal').style.display = 'none';
            editingMunicipalityId = null;
        }

        function loadMunicipalitiesFromServer() {
            showLoading(true);

            const municipalitiesData = document.getElementById('<%= hfMunicipalitiesData.ClientID %>').value;
            const statsData = document.getElementById('<%= hfStatsData.ClientID %>').value;

            console.log('Municipalities data:', municipalitiesData);
            console.log('Stats data:', statsData);

            if (municipalitiesData && municipalitiesData !== '[]' && municipalitiesData !== '') {
                try {
                    allMunicipalities = JSON.parse(municipalitiesData);
                    filteredMunicipalities = [...allMunicipalities];
                    console.log('Loaded municipalities:', allMunicipalities);
                } catch (e) {
                    console.error('Error parsing municipalities data:', e);
                    allMunicipalities = [];
                    filteredMunicipalities = [];
                }
            } else {
                console.log('No municipalities data found');
                allMunicipalities = [];
                filteredMunicipalities = [];
            }
            
            if (statsData && statsData !== '') {
                try {
                    updateStatistics(JSON.parse(statsData));
                } catch (e) {
                    console.error('Error parsing stats data:', e);
                }
            }

            renderMunicipalities();
            showLoading(false);
        }

        function refreshData() {
            showLoading(true);
            console.log('Refreshing data...');
            
            document.getElementById('<%= btnLoadMunicipalities.ClientID %>').click();

            setTimeout(function () {
                loadMunicipalitiesFromServer();
                showNotification('Data refreshed successfully!', 'success');
            }, 500);
        }

        function updateStatistics(stats) {
            document.getElementById('totalMunicipalities').textContent = stats.TotalMunicipalities || 0;
            document.getElementById('totalUsers').textContent = stats.TotalUsers || 0;
            document.getElementById('totalReports').textContent = stats.TotalReports || 0;
            document.getElementById('avgUsers').textContent = (stats.AvgUsers || 0).toFixed(1);
        }

        function applyFilters() {
            const searchTerm = document.getElementById('searchMunicipalities').value.toLowerCase();
            const sortFilter = document.getElementById('sortFilter').value;

            filteredMunicipalities = allMunicipalities.filter(municipality => {
                const matchesSearch = !searchTerm ||
                    (municipality.Name && municipality.Name.toLowerCase().includes(searchTerm));

                return matchesSearch;
            });

            // Apply sorting
            switch (sortFilter) {
                case 'name_desc':
                    filteredMunicipalities.sort((a, b) => b.Name.localeCompare(a.Name));
                    break;
                case 'users':
                    filteredMunicipalities.sort((a, b) => (b.UserCount || 0) - (a.UserCount || 0));
                    break;
                case 'reports':
                    filteredMunicipalities.sort((a, b) => (b.ReportCount || 0) - (a.ReportCount || 0));
                    break;
                default: // 'name'
                    filteredMunicipalities.sort((a, b) => a.Name.localeCompare(b.Name));
                    break;
            }

            currentPage = 1;
            renderMunicipalities();
        }

        function clearFilters() {
            document.getElementById('searchMunicipalities').value = '';
            document.getElementById('sortFilter').value = 'name';

            filteredMunicipalities = allMunicipalities;
            currentPage = 1;
            renderMunicipalities();
        }

        function renderMunicipalities() {
            const tbody = document.getElementById('municipalitiesTableBody');
            const emptyState = document.getElementById('municipalitiesEmptyState');
            const paginationInfo = document.getElementById('paginationInfo');
            const table = document.getElementById('municipalitiesTable');

            tbody.innerHTML = '';

            console.log('Rendering municipalities:', filteredMunicipalities.length);

            if (filteredMunicipalities.length === 0) {
                table.style.display = 'none';
                emptyState.style.display = 'block';
                paginationInfo.textContent = 'Showing 0 municipalities';
                return;
            }

            table.style.display = 'table';
            emptyState.style.display = 'none';

            const startIndex = (currentPage - 1) * pageSize;
            const endIndex = Math.min(startIndex + pageSize, filteredMunicipalities.length);
            const paginatedMunicipalities = filteredMunicipalities.slice(startIndex, endIndex);

            console.log('Creating table rows for:', paginatedMunicipalities.length, 'municipalities');

            paginatedMunicipalities.forEach(municipality => {
                const row = createMunicipalityRow(municipality);
                if (row) {
                    tbody.appendChild(row);
                }
            });

            paginationInfo.textContent = `Showing ${startIndex + 1}-${endIndex} of ${filteredMunicipalities.length} municipalities`;
            renderPagination();
        }

        function createMunicipalityRow(municipality) {
            if (!municipality) return null;

            const row = document.createElement('tr');

            const municipalityId = municipality.MunicipalityId || '-';
            const name = municipality.Name || 'Unknown Municipality';
            const userCount = municipality.UserCount || 0;
            const reportCount = municipality.ReportCount || 0;
            const totalCredits = municipality.TotalCredits || 0;

            const municipalityInitial = name.charAt(0).toUpperCase();

            row.innerHTML = `
                <td>
                    <div class="municipality-info">
                        <div class="municipality-avatar">${municipalityInitial}</div>
                        <div>
                            <div style="font-weight: 600; color: #ffffff !important;">${escapeHtml(name)}</div>
                            <div style="font-size: 0.8rem; color: rgba(255, 255, 255, 0.6) !important;">ID: ${escapeHtml(municipalityId)}</div>
                        </div>
                    </div>
                </td>
                <td>
                    <span class="user-count">${userCount} users</span>
                </td>
                <td>
                    <span class="report-count">${reportCount} reports</span>
                </td>
                <td style="color: #198754 !important; font-weight: 600;">${totalCredits} credits</td>
                <td>
                    <button class="btn-action btn-edit me-1" data-id="${municipalityId}" title="Edit Municipality">
                        <i class="fas fa-edit"></i>
                    </button>
                    <button class="btn-action btn-delete" data-id="${municipalityId}" title="Delete Municipality">
                        <i class="fas fa-trash"></i>
                    </button>
                </td>
            `;

            const editBtn = row.querySelector('.btn-edit');
            if (editBtn) {
                editBtn.addEventListener('click', function (e) {
                    e.preventDefault();
                    e.stopPropagation();
                    editMunicipality(this.getAttribute('data-id'));
                });
            }

            const deleteBtn = row.querySelector('.btn-delete');
            if (deleteBtn) {
                deleteBtn.addEventListener('click', function (e) {
                    e.preventDefault();
                    e.stopPropagation();
                    deleteMunicipality(this.getAttribute('data-id'), name);
                });
            }

            return row;
        }

        function openAddMunicipalityModal() {
            document.getElementById('modalTitle').textContent = 'Add Municipality';
            document.getElementById('modalMunicipalityId').value = '';
            document.getElementById('modalMunicipalityId').disabled = false;
            document.getElementById('modalName').value = '';

            editingMunicipalityId = null;
            document.getElementById('municipalityModal').style.display = 'block';
        }

        function editMunicipality(municipalityId) {
            const municipality = allMunicipalities.find(m => m.MunicipalityId === municipalityId);
            if (municipality) {
                document.getElementById('modalTitle').textContent = 'Edit Municipality';
                document.getElementById('modalMunicipalityId').value = municipality.MunicipalityId || '';
                document.getElementById('modalMunicipalityId').disabled = true;
                document.getElementById('modalName').value = municipality.Name || '';

                editingMunicipalityId = municipalityId;
                document.getElementById('municipalityModal').style.display = 'block';
            }
        }

        function deleteMunicipality(municipalityId, name) {
            if (confirm(`Are you sure you want to delete municipality "${name}"? This action cannot be undone.`)) {
                showNotification('Deleting municipality...', 'info');

                PageMethods.DeleteMunicipality(municipalityId, onMunicipalityDeleted, onMunicipalityError);
            }
        }

        function onMunicipalityDeleted(result) {
            if (result === 'SUCCESS') {
                showNotification('Municipality deleted successfully!', 'success');
                refreshData();
            } else {
                showNotification('Error deleting municipality: ' + result, 'error');
            }
        }

        function saveMunicipality() {
            const municipalityId = document.getElementById('modalMunicipalityId').value.trim();
            const name = document.getElementById('modalName').value.trim();

            if (!municipalityId) {
                showNotification('Please enter a Municipality ID', 'error');
                return;
            }

            if (!name) {
                showNotification('Please enter a Municipality Name', 'error');
                return;
            }

            if (municipalityId.length !== 4) {
                showNotification('Municipality ID must be exactly 4 characters', 'error');
                return;
            }

            const action = editingMunicipalityId ? 'edit' : 'add';

            showNotification('Saving municipality...', 'info');

            PageMethods.SaveMunicipality(municipalityId, name, action, onMunicipalitySaved, onMunicipalityError);
        }

        function onMunicipalitySaved(result) {
            if (result === 'SUCCESS') {
                const action = editingMunicipalityId ? 'updated' : 'added';
                showNotification(`Municipality ${action} successfully!`, 'success');
                closeAllModals();
                refreshData();
            } else {
                showNotification('Error saving municipality: ' + result, 'error');
            }
        }

        function onMunicipalityError(error) {
            showNotification('Error: ' + error.get_message(), 'error');
        }

        function renderPagination() {
            const pagination = document.getElementById('pagination');
            const totalPages = Math.ceil(filteredMunicipalities.length / pageSize);

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
                    renderMunicipalities();
                });
            });
        }

        function showLoading(show) {
            const spinner = document.getElementById('loadingSpinner');
            const table = document.getElementById('municipalitiesTable');

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
            loadMunicipalitiesFromServer();
        });
    </script>
</asp:Content>