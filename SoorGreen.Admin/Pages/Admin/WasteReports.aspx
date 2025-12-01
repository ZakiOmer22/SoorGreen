<%@ Page Title="Waste Reports" Language="C#" MasterPageFile="~/Pages/Admin/Site.master" AutoEventWireup="true" CodeFile="WasteReports.aspx.cs" Inherits="SoorGreen.Admin.Admin.WasteReports" %>
<%@ Register Assembly="System.Web.Extensions, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35" Namespace="System.Web.UI" TagPrefix="asp" %>
<%@ Import Namespace="System.Web.Optimization" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <%: Styles.Render("~/Content/adminwastereports") %>
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="ScriptsContent" runat="server">
    <%: Scripts.Render("~/bundles/adminwastereports") %>
</asp:Content>
<asp:Content ID="PageTitle" ContentPlaceHolderID="PageTitle" runat="server">
    Waste Reports Management
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <asp:ScriptManager ID="ScriptManager1" runat="server" EnablePageMethods="true"></asp:ScriptManager>
   
    <div class="waste-reports-container">
        <div class="filter-card">
            <h5 class="mb-3" style="color: #ffffff !important;"><i class="fas fa-filter me-2"></i>Filter Waste Reports</h5>
            <div class="filter-group">
                <div class="form-group search-box">
                    <label class="form-label">Search Reports</label>
                    <div class="position-relative">
                        <i class="fas fa-search search-icon"></i>
                        <input type="text" class="form-control search-input" id="searchReports" placeholder="Search by address, citizen, or waste type...">
                    </div>
                </div>
                
                <div class="form-group">
                    <label class="form-label">Waste Type</label>
                    <select class="form-control" id="wasteTypeFilter">
                        <option value="all">All Types</option>
                        <option value="Plastic">Plastic</option>
                        <option value="Paper">Paper</option>
                        <option value="Glass">Glass</option>
                        <option value="Metal">Metal</option>
                        <option value="Organic">Organic</option>
                    </select>
                </div>
                
                <div class="form-group">
                    <label class="form-label">Date Range</label>
                    <select class="form-control" id="dateFilter">
                        <option value="all">All Time</option>
                        <option value="today">Today</option>
                        <option value="week">This Week</option>
                        <option value="month">This Month</option>
                        <option value="year">This Year</option>
                    </select>
                </div>
                
                <div class="form-group">
                    <label class="form-label">Has Pickup</label>
                    <select class="form-control" id="pickupFilter">
                        <option value="all">All Reports</option>
                        <option value="with">With Pickup</option>
                        <option value="without">Without Pickup</option>
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
                Showing 0 reports
            </div>
        </div>

        <div id="gridView">
            <div class="reports-grid" id="reportsGrid">
            </div>
        </div>

        <div id="tableView" style="display: none;">
            <div class="table-responsive">
                <table class="reports-table" id="reportsTable">
                    <thead>
                        <tr>
                            <th>Report ID</th>
                            <th>Citizen</th>
                            <th>Waste Type</th>
                            <th>Weight (kg)</th>
                            <th>Address</th>
                            <th>Date Reported</th>
                            <th>Pickup Status</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody id="reportsTableBody">
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

    <!-- View Report Details Modal -->
    <div class="modal-overlay" id="viewReportModal">
        <div class="modal-content" style="max-width: 700px;">
            <div class="modal-header">
                <h3 class="modal-title">Waste Report Details</h3>
                <button type="button" class="close-modal">&times;</button>
            </div>
            <div class="modal-body">
                <div class="report-details-container">
                    <div class="report-info-grid">
                        <div class="info-item">
                            <label>Report ID:</label>
                            <span id="viewReportId">-</span>
                        </div>
                        <div class="info-item">
                            <label>Citizen:</label>
                            <span id="viewCitizenName">-</span>
                        </div>
                        <div class="info-item">
                            <label>Waste Type:</label>
                            <span id="viewWasteType">-</span>
                        </div>
                        <div class="info-item">
                            <label>Estimated Weight:</label>
                            <span id="viewEstimatedWeight">-</span>
                        </div>
                        <div class="info-item">
                            <label>Credits Rate:</label>
                            <span id="viewCreditRate">-</span>
                        </div>
                        <div class="info-item">
                            <label>Date Reported:</label>
                            <span id="viewReportedDate">-</span>
                        </div>
                        <div class="info-item">
                            <label>Pickup Status:</label>
                            <span id="viewPickupStatus">-</span>
                        </div>
                        <div class="info-item">
                            <label>Pickup ID:</label>
                            <span id="viewPickupId">-</span>
                        </div>
                        <div class="info-item full-width">
                            <label>Address:</label>
                            <span id="viewReportAddress">-</span>
                        </div>
                        <div class="info-item full-width">
                            <label>Notes/Photo:</label>
                            <span id="viewReportNotes">-</span>
                        </div>
                        <div class="info-item full-width" id="photoPreviewContainer" style="display: none;">
                            <label>Photo Preview:</label>
                            <img id="photoPreview" class="photo-preview" src="" alt="Report Photo">
                        </div>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-action btn-create-pickup" id="createPickupBtn" style="display: none;">
                    <i class="fas fa-truck me-2"></i>Create Pickup
                </button>
                <button type="button" class="btn-action" id="closeViewModalBtn">Close</button>
            </div>
        </div>
    </div>

    <!-- Create Pickup Modal -->
    <div class="modal-overlay" id="createPickupModal">
        <div class="modal-content" style="max-width: 500px;">
            <div class="modal-header">
                <h3 class="modal-title">Create Pickup Request</h3>
                <button type="button" class="close-modal">&times;</button>
            </div>
            <div class="modal-body">
                <div class="form-group">
                    <label class="form-label">Select Collector</label>
                    <select class="form-control" id="collectorSelect">
                        <option value="">Select a collector...</option>
                    </select>
                </div>
                <div class="form-group">
                    <label class="form-label">Scheduled Date & Time</label>
                    <input type="datetime-local" class="form-control" id="scheduledDateTime">
                </div>
                <div class="form-group">
                    <label class="form-label">Notes (Optional)</label>
                    <textarea class="form-control" id="pickupNotes" rows="3" placeholder="Add any special instructions..."></textarea>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-action" id="cancelCreatePickupBtn">Cancel</button>
                <button type="button" class="btn-primary" id="confirmCreatePickupBtn">Create Pickup</button>
            </div>
        </div>
    </div>

    <!-- Delete Confirmation Modal -->
    <div class="modal-overlay" id="deleteReportModal">
        <div class="modal-content" style="max-width: 500px;">
            <div class="modal-header">
                <h3 class="modal-title">Confirm Delete</h3>
                <button type="button" class="close-modal">&times;</button>
            </div>
            <div class="modal-body">
                <div class="text-center">
                    <i class="fas fa-exclamation-triangle fa-3x text-warning mb-3"></i>
                    <h4>Are you sure?</h4>
                    <p>You are about to delete waste report: <strong id="deleteReportId">-</strong></p>
                    <p class="text-muted">This will also delete any associated pickup requests. This action cannot be undone.</p>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-action" id="cancelDeleteBtn" style="flex: 1;">Cancel</button>
                <button type="button" class="btn-primary" id="confirmDeleteBtn" style="flex: 1;">Delete Report</button>
            </div>
        </div>
    </div>

    <asp:Button ID="btnLoadReports" runat="server" OnClick="LoadReports" Style="display: none;" />
    <asp:HiddenField ID="hfReportsData" runat="server" />
    <asp:HiddenField ID="hfCurrentPage" runat="server" Value="1" />
    <asp:HiddenField ID="hfCollectorsList" runat="server" />
</asp:Content>
