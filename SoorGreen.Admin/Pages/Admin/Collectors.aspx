<%@ Page Title="Collectors" Language="C#" MasterPageFile="~/Pages/Admin/Site.master" AutoEventWireup="true" CodeFile="Collectors.aspx.cs" Inherits="SoorGreen.Admin.Admin.Collectors" %>
<%@ Import Namespace="System.Web.Optimization" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <%: Styles.Render("~/Content/admincollectors") %>
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="ScriptsContent" runat="server">
    <%: Scripts.Render("~/bundles/admincollectors") %>
</asp:Content>
<asp:Content ID="PageTitle" ContentPlaceHolderID="PageTitle" runat="server">
    Collector Management
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    

    <div class="collectors-container">
        <div class="filter-card">
            <h5 class="mb-3" style="color: #ffffff !important;"><i class="fas fa-filter me-2"></i>Filter Collectors</h5>
            <div class="filter-group">
                <div class="form-group search-box">
                    <label class="form-label">Search Collectors</label>
                    <div class="position-relative">
                        <i class="fas fa-search search-icon"></i>
                        <input type="text" class="form-control search-input" id="searchCollectors" placeholder="Search by name, email, or phone...">
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
                    <label class="form-label">Availability</label>
                    <select class="form-control" id="availabilityFilter">
                        <option value="all">All</option>
                        <option value="online">Online</option>
                        <option value="offline">Offline</option>
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
                Showing 0 collectors
            </div>
        </div>

        <div id="gridView">
            <div class="collectors-grid" id="collectorsGrid">
            </div>
        </div>

        <div id="tableView" style="display: none;">
            <div class="table-responsive">
                <table class="collectors-table" id="collectorsTable">
                    <thead>
                        <tr>
                            <th>Collector</th>
                            <th>Contact</th>
                            <th>Status</th>
                            <th>Availability</th>
                            <th>Completed Pickups</th>
                            <th>Rating</th>
                            <th>Earnings</th>
                            <th>Joined</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody id="collectorsTableBody">
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

    <!-- View Collector Details Modal -->
    <div class="modal-overlay" id="viewCollectorModal">
        <div class="modal-content" style="max-width: 700px;">
            <div class="modal-header">
                <h3 class="modal-title">Collector Details</h3>
                <button type="button" class="close-modal">&times;</button>
            </div>
            <div class="modal-body">
                <div class="collector-details-container">
                    <div class="collector-avatar-large">
                        <div class="collector-avatar" style="width: 80px; height: 80px; font-size: 1.5rem;" id="viewCollectorAvatar">
                            CC
                        </div>
                    </div>
                    
                    <div class="performance-metrics">
                        <div class="metric-item">
                            <div class="metric-value" id="viewTotalPickups">0</div>
                            <div class="metric-label">Total Pickups</div>
                        </div>
                        <div class="metric-item">
                            <div class="metric-value" id="viewSuccessRate">0%</div>
                            <div class="metric-label">Success Rate</div>
                        </div>
                        <div class="metric-item">
                            <div class="metric-value" id="viewAvgRating">0.0</div>
                            <div class="metric-label">Avg Rating</div>
                        </div>
                        <div class="metric-item">
                            <div class="metric-value" id="viewTotalEarnings">$0</div>
                            <div class="metric-label">Total Earnings</div>
                        </div>
                    </div>
                    
                    <div class="collector-info-grid">
                        <div class="info-item">
                            <label>Full Name:</label>
                            <span id="viewCollectorName">-</span>
                        </div>
                        <div class="info-item">
                            <label>Email:</label>
                            <span id="viewCollectorEmail">-</span>
                        </div>
                        <div class="info-item">
                            <label>Phone:</label>
                            <span id="viewCollectorPhone">-</span>
                        </div>
                        <div class="info-item">
                            <label>User Type:</label>
                            <span id="viewCollectorType">-</span>
                        </div>
                        <div class="info-item">
                            <label>Status:</label>
                            <span id="viewCollectorStatus">-</span>
                        </div>
                        <div class="info-item">
                            <label>Availability:</label>
                            <span id="viewCollectorAvailability">-</span>
                        </div>
                        <div class="info-item">
                            <label>Rating:</label>
                            <span id="viewCollectorRating">-</span>
                        </div>
                        <div class="info-item">
                            <label>Registration Date:</label>
                            <span id="viewCollectorRegDate">-</span>
                        </div>
                        <div class="info-item full-width">
                            <label>Address:</label>
                            <span id="viewCollectorAddress">-</span>
                        </div>
                        <div class="info-item full-width">
                            <label>Vehicle Info:</label>
                            <span id="viewCollectorVehicle">-</span>
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
    <div class="modal-overlay" id="deleteCollectorModal">
        <div class="modal-content" style="max-width: 500px;">
            <div class="modal-header">
                <h3 class="modal-title">Confirm Delete</h3>
                <button type="button" class="close-modal">&times;</button>
            </div>
            <div class="modal-body">
                <div class="text-center">
                    <i class="fas fa-exclamation-triangle fa-3x text-warning mb-3"></i>
                    <h4>Are you sure?</h4>
                    <p>You are about to delete collector: <strong id="deleteCollectorName">-</strong></p>
                    <p class="text-muted">This action cannot be undone.</p>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-action" id="cancelDeleteBtn" style="flex: 1;">Cancel</button>
                <button type="button" class="btn-primary" id="confirmDeleteBtn" style="flex: 1;">Delete Collector</button>
            </div>
        </div>
    </div>

    <asp:Button ID="btnLoadCollectors" runat="server" OnClick="LoadCollectors" Style="display: none;" />
    <asp:HiddenField ID="hfCollectorsData" runat="server" />
    <asp:HiddenField ID="hfCurrentPage" runat="server" Value="1" />
</asp:Content>