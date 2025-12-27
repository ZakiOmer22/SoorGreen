<%@ Page Title="Reports" Language="C#" MasterPageFile="~/Pages/Admin/Site.master" AutoEventWireup="true" Inherits="SoorGreen.Admin.Admin.Reports" Codebehind="Reports.aspx.cs" %>
<%@ Import Namespace="System.Web.Optimization" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <%: Styles.Render("~/Content/adminreports") %>
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="ScriptsContent" runat="server">
    <%: Scripts.Render("~/bundles/adminreports") %>
</asp:Content>
<asp:Content ID="PageTitle" ContentPlaceHolderID="PageTitle" runat="server">
    Reports & Analytics
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
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
    
</asp:Content>