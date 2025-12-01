<%@ Page Title="Pickups" Language="C#" MasterPageFile="~/Pages/Admin/Site.master" AutoEventWireup="true" CodeFile="Pickups.aspx.cs" Inherits="SoorGreen.Admin.Admin.Pickups" %>
<%@ Register Assembly="System.Web.Extensions, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35" Namespace="System.Web.UI" TagPrefix="asp" %>
<%@ Import Namespace="System.Web.Optimization" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <%: Styles.Render("~/Content/adminpickups") %>
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="ScriptsContent" runat="server">
    <%: Scripts.Render("~/bundles/adminpickups") %>
</asp:Content>
<asp:Content ID="PageTitle" ContentPlaceHolderID="PageTitle" runat="server">
    Pickup Management
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <asp:ScriptManager ID="ScriptManager1" runat="server" EnablePageMethods="true"></asp:ScriptManager>

    <div class="pickups-container">
        <div class="filter-card">
            <h5 class="mb-3" style="color: #ffffff !important;"><i class="fas fa-filter me-2"></i>Filter Pickups</h5>
            <div class="filter-group">
                <div class="form-group search-box">
                    <label class="form-label">Search Pickups</label>
                    <div class="position-relative">
                        <i class="fas fa-search search-icon"></i>
                        <input type="text" class="form-control search-input" id="searchPickups" placeholder="Search by address, citizen, or collector...">
                    </div>
                </div>
                
                <div class="form-group">
                    <label class="form-label">Status</label>
                    <select class="form-control" id="statusFilter">
                        <option value="all">All Status</option>
                        <option value="Requested">Requested</option>
                        <option value="Assigned">Assigned</option>
                        <option value="Collected">Collected</option>
                        <option value="Completed">Completed</option>
                        <option value="Cancelled">Cancelled</option>
                    </select>
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
            
            <!-- ADD BUTTON HERE -->
            <button type="button" class="btn-add" id="addPickupBtn">
                <i class="fas fa-plus me-2"></i>Add New Pickup
            </button>
            
            <div class="page-info" id="pageInfo">
                Showing 0 pickups
            </div>
        </div>

        <div id="gridView">
            <div class="pickups-grid" id="pickupsGrid">
            </div>
        </div>

        <div id="tableView" style="display: none;">
            <div class="table-responsive">
                <table class="pickups-table" id="pickupsTable">
                    <thead>
                        <tr>
                            <th>Pickup ID</th>
                            <th>Citizen</th>
                            <th>Collector</th>
                            <th>Address</th>
                            <th>Waste Type</th>
                            <th>Weight (kg)</th>
                            <th>Status</th>
                            <th>Requested</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody id="pickupsTableBody">
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

    <!-- View Pickup Details Modal -->
    <div class="modal-overlay" id="viewPickupModal">
        <div class="modal-content" style="max-width: 700px;">
            <div class="modal-header">
                <h3 class="modal-title">Pickup Details</h3>
                <button type="button" class="close-modal">&times;</button>
            </div>
            <div class="modal-body">
                <div class="pickup-details-container">
                    <div class="pickup-info-grid">
                        <div class="info-item">
                            <label>Pickup ID:</label>
                            <span id="viewPickupId">-</span>
                        </div>
                        <div class="info-item">
                            <label>Status:</label>
                            <span id="viewPickupStatus">-</span>
                        </div>
                        <div class="info-item">
                            <label>Citizen:</label>
                            <span id="viewCitizenName">-</span>
                        </div>
                        <div class="info-item">
                            <label>Collector:</label>
                            <span id="viewCollectorName">-</span>
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
                            <label>Actual Weight:</label>
                            <span id="viewActualWeight">-</span>
                        </div>
                        <div class="info-item">
                            <label>Credits Earned:</label>
                            <span id="viewCreditsEarned">-</span>
                        </div>
                        <div class="info-item">
                            <label>Requested Date:</label>
                            <span id="viewRequestedDate">-</span>
                        </div>
                        <div class="info-item">
                            <label>Scheduled Date:</label>
                            <span id="viewScheduledDate">-</span>
                        </div>
                        <div class="info-item">
                            <label>Completed Date:</label>
                            <span id="viewCompletedDate">-</span>
                        </div>
                        <div class="info-item full-width">
                            <label>Address:</label>
                            <span id="viewPickupAddress">-</span>
                        </div>
                        <div class="info-item full-width">
                            <label>Notes:</label>
                            <span id="viewPickupNotes">-</span>
                        </div>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-action" id="closeViewModalBtn">Close</button>
            </div>
        </div>
    </div>

    <!-- Assign Collector Modal -->
    <div class="modal-overlay" id="assignCollectorModal">
        <div class="modal-content" style="max-width: 500px;">
            <div class="modal-header">
                <h3 class="modal-title">Assign Collector</h3>
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
                    <textarea class="form-control" id="assignmentNotes" rows="3" placeholder="Add any special instructions..."></textarea>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-action" id="cancelAssignBtn">Cancel</button>
                <button type="button" class="btn-primary" id="confirmAssignBtn">Assign Collector</button>
            </div>
        </div>
    </div>

    <!-- Complete Pickup Modal -->
    <div class="modal-overlay" id="completePickupModal">
        <div class="modal-content" style="max-width: 500px;">
            <div class="modal-header">
                <h3 class="modal-title">Complete Pickup</h3>
                <button type="button" class="close-modal">&times;</button>
            </div>
            <div class="modal-body">
                <div class="form-group">
                    <label class="form-label">Actual Weight (kg)</label>
                    <input type="number" class="form-control" id="actualWeight" step="0.1" min="0" placeholder="Enter actual weight collected">
                </div>
                <div class="form-group">
                    <label class="form-label">Waste Type Confirmation</label>
                    <select class="form-control" id="confirmedWasteType">
                        <option value="Plastic">Plastic</option>
                        <option value="Paper">Paper</option>
                        <option value="Glass">Glass</option>
                        <option value="Metal">Metal</option>
                        <option value="Organic">Organic</option>
                    </select>
                </div>
                <div class="form-group">
                    <label class="form-label">Completion Notes</label>
                    <textarea class="form-control" id="completionNotes" rows="3" placeholder="Add completion notes..."></textarea>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-action" id="cancelCompleteBtn">Cancel</button>
                <button type="button" class="btn-primary" id="confirmCompleteBtn">Complete Pickup</button>
            </div>
        </div>
    </div>

    <!-- Delete Confirmation Modal -->
    <div class="modal-overlay" id="deletePickupModal">
        <div class="modal-content" style="max-width: 500px;">
            <div class="modal-header">
                <h3 class="modal-title">Confirm Delete</h3>
                <button type="button" class="close-modal">&times;</button>
            </div>
            <div class="modal-body">
                <div class="text-center">
                    <i class="fas fa-exclamation-triangle fa-3x text-warning mb-3"></i>
                    <h4>Are you sure?</h4>
                    <p>You are about to delete pickup: <strong id="deletePickupId">-</strong></p>
                    <p class="text-muted">This action cannot be undone.</p>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-action" id="cancelDeleteBtn" style="flex: 1;">Cancel</button>
                <button type="button" class="btn-primary" id="confirmDeleteBtn" style="flex: 1;">Delete Pickup</button>
            </div>
        </div>
    </div>

    <!-- Add New Pickup Modal -->
    <div class="modal-overlay" id="addPickupModal">
        <div class="modal-content" style="max-width: 600px;">
            <div class="modal-header">
                <h3 class="modal-title">Add New Pickup</h3>
                <button type="button" class="close-modal">&times;</button>
            </div>
            <div class="modal-body">
                <div class="form-group">
                    <label class="form-label">Citizen</label>
                    <select class="form-control" id="citizenSelect">
                        <option value="">Select a citizen...</option>
                    </select>
                </div>
                <div class="form-row">
                    <div class="form-half">
                        <label class="form-label">Waste Type</label>
                        <select class="form-control" id="newWasteType">
                            <option value="Plastic">Plastic</option>
                            <option value="Paper">Paper</option>
                            <option value="Glass">Glass</option>
                            <option value="Metal">Metal</option>
                            <option value="Organic">Organic</option>
                        </select>
                    </div>
                    <div class="form-half">
                        <label class="form-label">Estimated Weight (kg)</label>
                        <input type="number" class="form-control" id="estimatedWeight" step="0.1" min="0" placeholder="Enter estimated weight">
                    </div>
                </div>
                <div class="form-group">
                    <label class="form-label">Address</label>
                    <textarea class="form-control" id="pickupAddress" rows="3" placeholder="Enter pickup address"></textarea>
                </div>
                <div class="form-group">
                    <label class="form-label">Notes (Optional)</label>
                    <textarea class="form-control" id="pickupNotes" rows="3" placeholder="Add any notes..."></textarea>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-action" id="cancelAddBtn">Cancel</button>
                <button type="button" class="btn-primary" id="confirmAddBtn">Create Pickup</button>
            </div>
        </div>
    </div>

    <asp:Button ID="btnLoadPickups" runat="server" OnClick="LoadPickups" Style="display: none;" />
    <asp:HiddenField ID="hfPickupsData" runat="server" />
    <asp:HiddenField ID="hfCurrentPage" runat="server" Value="1" />
    <asp:HiddenField ID="hfCollectorsList" runat="server" />
    <asp:HiddenField ID="hfCitizensList" runat="server" />
</asp:Content>