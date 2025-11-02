<%@ Page Title="Reports" Language="C#" MasterPageFile="~/Admin/Site.master" AutoEventWireup="true" CodeFile="Reports.aspx.cs" Inherits="SoorGreen.Admin.Admin.Reports" %>

<asp:Content ID="PageTitle" ContentPlaceHolderID="PageTitle" runat="server">
    Reports & Analytics
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <style>
        .reports-container {
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
        
        .report-card {
            background: rgba(255, 255, 255, 0.05);
            backdrop-filter: blur(20px);
            border: 1px solid rgba(255, 255, 255, 0.1);
            border-radius: 15px;
            padding: 1.5rem;
            margin-bottom: 1.5rem;
            transition: all 0.3s ease;
            height: 100%;
        }
        
        .report-card:hover {
            transform: translateY(-3px);
            border-color: rgba(0, 212, 170, 0.3);
        }
        
        .report-header {
            display: flex;
            justify-content: between;
            align-items: center;
            margin-bottom: 1rem;
        }
        
        .report-title {
            font-size: 1.2rem;
            font-weight: 700;
            color: var(--light);
            margin: 0;
        }
        
        .report-actions {
            display: flex;
            gap: 0.5rem;
        }
        
        .btn-report {
            background: rgba(255, 255, 255, 0.1);
            border: 1px solid rgba(255, 255, 255, 0.2);
            color: white;
            padding: 0.4rem 0.8rem;
            border-radius: 6px;
            cursor: pointer;
            transition: all 0.3s ease;
            font-size: 0.8rem;
        }
        
        .btn-report:hover {
            background: rgba(255, 255, 255, 0.2);
        }
        
        .btn-export {
            background: linear-gradient(135deg, #198754, #20c997);
            border: none;
        }
        
        .btn-export:hover {
            background: linear-gradient(135deg, #157347, #1aa179);
        }
        
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 1rem;
            margin-bottom: 1.5rem;
        }
        
        .stat-item {
            text-align: center;
            padding: 1rem;
            background: rgba(255, 255, 255, 0.03);
            border-radius: 10px;
            border: 1px solid rgba(255, 255, 255, 0.05);
        }
        
        .stat-value {
            font-size: 1.8rem;
            font-weight: 800;
            color: var(--light);
            margin-bottom: 0.5rem;
        }
        
        .stat-label {
            color: rgba(255, 255, 255, 0.7);
            font-size: 0.8rem;
            font-weight: 600;
        }
        
        .table-responsive {
            border-radius: 10px;
            overflow: hidden;
        }
        
        .report-table {
            width: 100%;
            background: rgba(255, 255, 255, 0.02);
            border-collapse: collapse;
        }
        
        .report-table th {
            background: rgba(255, 255, 255, 0.1);
            color: var(--light);
            font-weight: 600;
            padding: 1rem;
            text-align: left;
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
        }
        
        .report-table td {
            padding: 1rem;
            border-bottom: 1px solid rgba(255, 255, 255, 0.05);
            color: rgba(255, 255, 255, 0.8);
        }
        
        .report-table tr:hover {
            background: rgba(255, 255, 255, 0.03);
        }
        
        .status-badge {
            padding: 0.3rem 0.8rem;
            border-radius: 20px;
            font-size: 0.75rem;
            font-weight: 600;
        }
        
        .status-completed {
            background: rgba(25, 135, 84, 0.2);
            color: #198754;
            border: 1px solid rgba(25, 135, 84, 0.3);
        }
        
        .status-pending {
            background: rgba(255, 193, 7, 0.2);
            color: #ffc107;
            border: 1px solid rgba(255, 193, 7, 0.3);
        }
        
        .status-cancelled {
            background: rgba(220, 53, 69, 0.2);
            color: #dc3545;
            border: 1px solid rgba(220, 53, 69, 0.3);
        }
        
        .chart-container {
            background: rgba(255, 255, 255, 0.02);
            border-radius: 10px;
            padding: 1rem;
            margin-bottom: 1rem;
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
            color: rgba(255, 255, 255, 0.8);
            font-weight: 600;
            margin-bottom: 0.5rem;
            display: block;
        }
        
        .form-control {
            background: rgba(255, 255, 255, 0.1);
            border: 1px solid rgba(255, 255, 255, 0.2);
            border-radius: 8px;
            color: white;
            padding: 0.75rem;
            width: 100%;
            transition: all 0.3s ease;
        }
        
        .form-control:focus {
            outline: none;
            border-color: var(--primary);
            background: rgba(255, 255, 255, 0.15);
        }
        
        .btn-generate {
            background: linear-gradient(135deg, #0d6efd, #0dcaf0);
            border: none;
            color: white;
            padding: 0.75rem 1.5rem;
            border-radius: 8px;
            cursor: pointer;
            transition: all 0.3s ease;
            font-weight: 600;
        }
        
        .btn-generate:hover {
            background: linear-gradient(135deg, #0b5ed7, #0baccc);
            transform: translateY(-2px);
        }
        
        .export-options {
            display: flex;
            gap: 0.5rem;
            margin-top: 1rem;
        }
        
        .tab-content {
            margin-top: 1.5rem;
        }
        
        .nav-tabs {
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
            gap: 0.5rem;
        }
        
        .nav-tabs .nav-link {
            background: rgba(255, 255, 255, 0.05);
            border: 1px solid rgba(255, 255, 255, 0.1);
            border-bottom: none;
            color: rgba(255, 255, 255, 0.7);
            padding: 0.75rem 1.5rem;
            border-radius: 8px 8px 0 0;
            transition: all 0.3s ease;
        }
        
        .nav-tabs .nav-link.active {
            background: rgba(255, 255, 255, 0.1);
            border-color: rgba(255, 255, 255, 0.2);
            color: var(--light);
        }
        
        .nav-tabs .nav-link:hover {
            background: rgba(255, 255, 255, 0.08);
            color: var(--light);
        }
    </style>

    <div class="reports-container">
        <!-- Header -->
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h1 class="display-6 fw-bold"></h1>
                <p class="text-muted mb-0"></p>
            </div>
            <div class="export-options">
                <button class="btn-report btn-export" onclick="exportToPDF()">
                    <i class="fas fa-file-pdf me-2"></i>Export PDF
                </button>
                <button class="btn-report btn-export" onclick="exportToExcel()">
                    <i class="fas fa-file-excel me-2"></i>Export Excel
                </button>
            </div>
        </div>

        <!-- Filters -->
        <div class="filter-card">
            <h5 class="mb-3"><i class="fas fa-filter me-2"></i>Report Filters</h5>
            <div class="filter-group">
                <div class="form-group">
                    <label class="form-label">Report Type</label>
                    <select class="form-control" id="reportType">
                        <option value="pickup">Pickup Reports</option>
                        <option value="user">User Reports</option>
                        <option value="waste">Waste Reports</option>
                        <option value="revenue">Revenue Reports</option>
                        <option value="performance">Performance Reports</option>
                    </select>
                </div>
                
                <div class="form-group">
                    <label class="form-label">Date Range</label>
                    <select class="form-control" id="dateRange">
                        <option value="today">Today</option>
                        <option value="yesterday">Yesterday</option>
                        <option value="week">This Week</option>
                        <option value="month" selected>This Month</option>
                        <option value="quarter">This Quarter</option>
                        <option value="year">This Year</option>
                        <option value="custom">Custom Range</option>
                    </select>
                </div>
                
                <div class="form-group" id="customDateRange" style="display: none;">
                    <label class="form-label">Custom Range</label>
                    <div class="d-flex gap-2">
                        <input type="date" class="form-control" id="startDate">
                        <input type="date" class="form-control" id="endDate">
                    </div>
                </div>
                
                <div class="form-group">
                    <label class="form-label">Status</label>
                    <select class="form-control" id="statusFilter">
                        <option value="all">All Status</option>
                        <option value="completed">Completed</option>
                        <option value="pending">Pending</option>
                        <option value="cancelled">Cancelled</option>
                    </select>
                </div>
                
                <div class="form-group">
                    <button class="btn-generate" onclick="generateReport()">
                        <i class="fas fa-chart-bar me-2"></i>Generate Report
                    </button>
                </div>
            </div>
        </div>

        <!-- Tabs -->
        <ul class="nav nav-tabs" id="reportTabs" role="tablist">
            <li class="nav-item" role="presentation">
                <button class="nav-link active" id="summary-tab" data-bs-toggle="tab" data-bs-target="#summary" type="button" role="tab">
                    <i class="fas fa-chart-pie me-2"></i>Summary
                </button>
            </li>
            <li class="nav-item" role="presentation">
                <button class="nav-link" id="detailed-tab" data-bs-toggle="tab" data-bs-target="#detailed" type="button" role="tab">
                    <i class="fas fa-table me-2"></i>Detailed View
                </button>
            </li>
            <li class="nav-item" role="presentation">
                <button class="nav-link" id="charts-tab" data-bs-toggle="tab" data-bs-target="#charts" type="button" role="tab">
                    <i class="fas fa-chart-line me-2"></i>Charts
                </button>
            </li>
        </ul>

        <!-- Tab Content -->
        <div class="tab-content" id="reportTabsContent">
            <!-- Summary Tab -->
            <div class="tab-pane fade show active" id="summary" role="tabpanel">
                <div class="row">
                    <div class="col-12 mb-4">
                        <div class="stats-grid">
                            <div class="stat-item">
                                <div class="stat-value" id="totalPickups">0</div>
                                <div class="stat-label">Total Pickups</div>
                            </div>
                            <div class="stat-item">
                                <div class="stat-value" id="completedPickups">0</div>
                                <div class="stat-label">Completed</div>
                            </div>
                            <div class="stat-item">
                                <div class="stat-value" id="pendingPickups">0</div>
                                <div class="stat-label">Pending</div>
                            </div>
                            <div class="stat-item">
                                <div class="stat-value" id="totalRevenue">$0</div>
                                <div class="stat-label">Total Revenue</div>
                            </div>
                            <div class="stat-item">
                                <div class="stat-value" id="avgRating">0.0</div>
                                <div class="stat-label">Avg Rating</div>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="row">
                    <div class="col-md-6 mb-4">
                        <div class="report-card">
                            <div class="report-header">
                                <h5 class="report-title">Top Waste Categories</h5>
                            </div>
                            <div class="chart-container">
                                <canvas id="wasteCategoryChart" height="250"></canvas>
                            </div>
                        </div>
                    </div>
                    
                    <div class="col-md-6 mb-4">
                        <div class="report-card">
                            <div class="report-header">
                                <h5 class="report-title">Pickup Status Distribution</h5>
                            </div>
                            <div class="chart-container">
                                <canvas id="pickupStatusChart" height="250"></canvas>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Detailed View Tab -->
            <div class="tab-pane fade" id="detailed" role="tabpanel">
                <div class="report-card">
                    <div class="report-header">
                        <h5 class="report-title">Detailed Pickup Report</h5>
                        <div class="report-actions">
                            <button class="btn-report" onclick="exportTableToCSV()">
                                <i class="fas fa-download me-1"></i>CSV
                            </button>
                        </div>
                    </div>
                    <div class="table-responsive">
                        <table class="report-table" id="detailedTable">
                            <thead>
                                <tr>
                                    <th>ID</th>
                                    <th>User</th>
                                    <th>Pickup Date</th>
                                    <th>Waste Type</th>
                                    <th>Weight (kg)</th>
                                    <th>Status</th>
                                    <th>Credits</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody id="reportTableBody">
                                <!-- Data will be populated by JavaScript -->
                            </tbody>
                        </table>
                    </div>
                    <div class="d-flex justify-content-between align-items-center mt-3">
                        <div class="text-muted" id="tableInfo">Showing 0 entries</div>
                        <nav>
                            <ul class="pagination mb-0" id="pagination">
                                <!-- Pagination will be generated by JavaScript -->
                            </ul>
                        </nav>
                    </div>
                </div>
            </div>

            <!-- Charts Tab -->
            <div class="tab-pane fade" id="charts" role="tabpanel">
                <div class="row">
                    <div class="col-lg-8 mb-4">
                        <div class="report-card">
                            <div class="report-header">
                                <h5 class="report-title">Monthly Pickup Trends</h5>
                            </div>
                            <div class="chart-container">
                                <canvas id="monthlyTrendChart" height="300"></canvas>
                            </div>
                        </div>
                    </div>
                    
                    <div class="col-lg-4 mb-4">
                        <div class="report-card">
                            <div class="report-header">
                                <h5 class="report-title">User Distribution</h5>
                            </div>
                            <div class="chart-container">
                                <canvas id="userDistributionChart" height="300"></canvas>
                            </div>
                        </div>
                    </div>
                </div>
                
                <div class="row">
                    <div class="col-lg-6 mb-4">
                        <div class="report-card">
                            <div class="report-header">
                                <h5 class="report-title">Revenue Analysis</h5>
                            </div>
                            <div class="chart-container">
                                <canvas id="revenueChart" height="250"></canvas>
                            </div>
                        </div>
                    </div>
                    
                    <div class="col-lg-6 mb-4">
                        <div class="report-card">
                            <div class="report-header">
                                <h5 class="report-title">Performance Metrics</h5>
                            </div>
                            <div class="chart-container">
                                <canvas id="performanceChart" height="250"></canvas>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Hidden controls for server-side operations -->
    <asp:Button ID="btnGenerateReport" runat="server" OnClick="GenerateReport" Style="display: none;" />
    <asp:HiddenField ID="hfReportData" runat="server" />
</asp:Content>

<asp:Content ID="Scripts" ContentPlaceHolderID="Scripts" runat="server">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    
    <script>
        // Sample data for demonstration
        const sampleData = {
            pickups: [
                { id: 'PK001', user: 'John Doe', date: '2024-01-15', type: 'Plastic', weight: 12.5, status: 'completed', credits: 125 },
                { id: 'PK002', user: 'Jane Smith', date: '2024-01-15', type: 'Paper', weight: 8.2, status: 'completed', credits: 82 },
                { id: 'PK003', user: 'Mike Johnson', date: '2024-01-14', type: 'Glass', weight: 15.8, status: 'pending', credits: 0 },
                { id: 'PK004', user: 'Sarah Wilson', date: '2024-01-14', type: 'Metal', weight: 22.1, status: 'completed', credits: 221 },
                { id: 'PK005', user: 'Tom Brown', date: '2024-01-13', type: 'Plastic', weight: 9.7, status: 'cancelled', credits: 0 },
                { id: 'PK006', user: 'Lisa Davis', date: '2024-01-13', type: 'E-Waste', weight: 5.3, status: 'completed', credits: 106 },
                { id: 'PK007', user: 'Robert Lee', date: '2024-01-12', type: 'Organic', weight: 18.4, status: 'completed', credits: 184 },
                { id: 'PK008', user: 'Emma Garcia', date: '2024-01-12', type: 'Plastic', weight: 11.2, status: 'pending', credits: 0 }
            ],
            summary: {
                totalPickups: 156,
                completedPickups: 128,
                pendingPickups: 25,
                cancelledPickups: 3,
                totalRevenue: 28450,
                avgRating: 4.7
            }
        };

        let currentPage = 1;
        const itemsPerPage = 5;

        // Initialize when page loads
        document.addEventListener('DOMContentLoaded', function () {
            initializeFilters();
            loadReportData();
            initializeCharts();
            setupEventListeners();
        });

        function initializeFilters() {
            // Set default dates
            const today = new Date();
            const lastWeek = new Date(today.getTime() - 7 * 24 * 60 * 60 * 1000);
            
            document.getElementById('startDate').valueAsDate = lastWeek;
            document.getElementById('endDate').valueAsDate = today;
        }

        function setupEventListeners() {
            // Show/hide custom date range
            document.getElementById('dateRange').addEventListener('change', function() {
                const customRange = document.getElementById('customDateRange');
                customRange.style.display = this.value === 'custom' ? 'block' : 'none';
            });

            // Generate report on filter change
            document.getElementById('reportType').addEventListener('change', generateReport);
            document.getElementById('statusFilter').addEventListener('change', generateReport);
        }

        function generateReport() {
            showLoading();
            
            // Simulate API call delay
            setTimeout(() => {
                loadReportData();
                updateCharts();
                hideLoading();
                showSuccess('Report generated successfully!');
            }, 1000);
        }

        function loadReportData() {
            // Update summary stats
            document.getElementById('totalPickups').textContent = sampleData.summary.totalPickups.toLocaleString();
            document.getElementById('completedPickups').textContent = sampleData.summary.completedPickups.toLocaleString();
            document.getElementById('pendingPickups').textContent = sampleData.summary.pendingPickups.toLocaleString();
            document.getElementById('totalRevenue').textContent = '$' + sampleData.summary.totalRevenue.toLocaleString();
            document.getElementById('avgRating').textContent = sampleData.summary.avgRating.toFixed(1);

            // Populate detailed table
            populateTable();
        }

        function populateTable() {
            const tbody = document.getElementById('reportTableBody');
            const statusFilter = document.getElementById('statusFilter').value;
            
            // Filter data based on status
            let filteredData = sampleData.pickups;
            if (statusFilter !== 'all') {
                filteredData = sampleData.pickups.filter(item => item.status === statusFilter);
            }

            // Calculate pagination
            const totalPages = Math.ceil(filteredData.length / itemsPerPage);
            const startIndex = (currentPage - 1) * itemsPerPage;
            const endIndex = startIndex + itemsPerPage;
            const pageData = filteredData.slice(startIndex, endIndex);

            // Clear existing rows
            tbody.innerHTML = '';

            // Populate rows
            pageData.forEach(item => {
                const row = document.createElement('tr');
                row.innerHTML = `
                    <td>${item.id}</td>
                    <td>${item.user}</td>
                    <td>${formatDate(item.date)}</td>
                    <td>${item.type}</td>
                    <td>${item.weight} kg</td>
                    <td><span class="status-badge status-${item.status}">${capitalizeFirst(item.status)}</span></td>
                    <td>${item.credits}</td>
                    <td>
                        <button class="btn-report" onclick="viewDetails('${item.id}')" title="View Details">
                            <i class="fas fa-eye"></i>
                        </button>
                        <button class="btn-report" onclick="editItem('${item.id}')" title="Edit">
                            <i class="fas fa-edit"></i>
                        </button>
                    </td>
                `;
                tbody.appendChild(row);
            });

            // Update pagination
            updatePagination(filteredData.length, totalPages);
            
            // Update table info
            document.getElementById('tableInfo').textContent = 
                `Showing ${startIndex + 1} to ${Math.min(endIndex, filteredData.length)} of ${filteredData.length} entries`;
        }

        function updatePagination(totalItems, totalPages) {
            const pagination = document.getElementById('pagination');
            pagination.innerHTML = '';

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
        }

        function changePage(page) {
            currentPage = page;
            populateTable();
        }

        function initializeCharts() {
            // Waste Category Chart
            const wasteCtx = document.getElementById('wasteCategoryChart').getContext('2d');
            new Chart(wasteCtx, {
                type: 'doughnut',
                data: {
                    labels: ['Plastic', 'Paper', 'Glass', 'Metal', 'Organic', 'E-Waste'],
                    datasets: [{
                        data: [35, 25, 15, 12, 8, 5],
                        backgroundColor: [
                            '#198754', '#0dcaf0', '#ffc107', '#dc3545', '#6f42c1', '#fd7e14'
                        ],
                        borderWidth: 0
                    }]
                },
                options: {
                    responsive: true,
                    plugins: {
                        legend: {
                            position: 'bottom',
                            labels: { color: 'rgba(255, 255, 255, 0.7)' }
                        }
                    }
                }
            });

            // Pickup Status Chart
            const statusCtx = document.getElementById('pickupStatusChart').getContext('2d');
            new Chart(statusCtx, {
                type: 'pie',
                data: {
                    labels: ['Completed', 'Pending', 'Cancelled'],
                    datasets: [{
                        data: [82, 16, 2],
                        backgroundColor: ['#198754', '#ffc107', '#dc3545'],
                        borderWidth: 0
                    }]
                },
                options: {
                    responsive: true,
                    plugins: {
                        legend: {
                            position: 'bottom',
                            labels: { color: 'rgba(255, 255, 255, 0.7)' }
                        }
                    }
                }
            });

            // Initialize other charts
            updateCharts();
        }

        function updateCharts() {
            // Monthly Trend Chart
            const trendCtx = document.getElementById('monthlyTrendChart').getContext('2d');
            new Chart(trendCtx, {
                type: 'line',
                data: {
                    labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'],
                    datasets: [{
                        label: 'Pickup Requests',
                        data: [120, 150, 180, 200, 240, 280, 320, 300, 280, 320, 350, 400],
                        borderColor: '#0dcaf0',
                        backgroundColor: 'rgba(13, 202, 240, 0.1)',
                        borderWidth: 2,
                        fill: true,
                        tension: 0.4
                    }]
                },
                options: {
                    responsive: true,
                    scales: {
                        y: {
                            beginAtZero: true,
                            grid: { color: 'rgba(255, 255, 255, 0.1)' },
                            ticks: { color: 'rgba(255, 255, 255, 0.7)' }
                        },
                        x: {
                            grid: { color: 'rgba(255, 255, 255, 0.1)' },
                            ticks: { color: 'rgba(255, 255, 255, 0.7)' }
                        }
                    }
                }
            });

            // User Distribution Chart
            const userCtx = document.getElementById('userDistributionChart').getContext('2d');
            new Chart(userCtx, {
                type: 'bar',
                data: {
                    labels: ['Residential', 'Commercial', 'Industrial', 'Institutional'],
                    datasets: [{
                        label: 'Users',
                        data: [450, 280, 120, 80],
                        backgroundColor: 'rgba(25, 135, 84, 0.6)',
                        borderColor: '#198754',
                        borderWidth: 1
                    }]
                },
                options: {
                    responsive: true,
                    scales: {
                        y: {
                            beginAtZero: true,
                            grid: { color: 'rgba(255, 255, 255, 0.1)' },
                            ticks: { color: 'rgba(255, 255, 255, 0.7)' }
                        },
                        x: {
                            grid: { color: 'rgba(255, 255, 255, 0.1)' },
                            ticks: { color: 'rgba(255, 255, 255, 0.7)' }
                        }
                    }
                }
            });
        }

        // Utility functions
        function formatDate(dateString) {
            return new Date(dateString).toLocaleDateString();
        }

        function capitalizeFirst(string) {
            return string.charAt(0).toUpperCase() + string.slice(1);
        }

        function showLoading() {
            // Implement loading indicator
            console.log('Loading...');
        }

        function hideLoading() {
            // Hide loading indicator
            console.log('Loading complete');
        }

        function showSuccess(message) {
            // Simple success notification
            alert(message); // Replace with toast notification
        }

        // Action functions
        function viewDetails(id) {
            alert(`View details for ${id}`);
            // Implement detail view modal
        }

        function editItem(id) {
            alert(`Edit item ${id}`);
            // Implement edit functionality
        }

        function exportToPDF() {
            alert('Exporting to PDF...');
            // Implement PDF export
        }

        function exportToExcel() {
            alert('Exporting to Excel...');
            // Implement Excel export
        }

        function exportTableToCSV() {
            alert('Exporting table to CSV...');
            // Implement CSV export
        }
    </script>
</asp:Content>