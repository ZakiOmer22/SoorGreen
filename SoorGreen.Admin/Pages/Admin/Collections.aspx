<%@ Page Title="Collections" Language="C#" MasterPageFile="~/Pages/Admin/Site.master" AutoEventWireup="true" CodeFile="Collections.aspx.cs" Inherits="SoorGreen.Admin.Admin.Collections" %>
<%@ Register Assembly="System.Web.Extensions, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35" Namespace="System.Web.UI" TagPrefix="asp" %>
<%@ Import Namespace="System.Web.Optimization" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <%: Styles.Render("~/Content/admincollections") %>
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="ScriptsContent" runat="server">
    <%: Scripts.Render("~/bundles/admincollections") %>
</asp:Content>
<asp:Content ID="PageTitle" ContentPlaceHolderID="PageTitle" runat="server">
    Waste Collections Management
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <asp:ScriptManager ID="ScriptManager1" runat="server" EnablePageMethods="true"></asp:ScriptManager>
    
    
    <div class="collections-container">
        <!-- Statistics Cards -->
        <div class="stats-cards">
            <div class="stat-card">
                <div class="stat-value" id="totalCollections">0</div>
                <div class="stat-label">Total Collections</div>
            </div>
            <div class="stat-card">
                <div class="stat-value" id="pendingCollections">0</div>
                <div class="stat-label">Pending</div>
            </div>
            <div class="stat-card">
                <div class="stat-value" id="completedToday">0</div>
                <div class="stat-label">Completed Today</div>
            </div>
            <div class="stat-card">
                <div class="stat-value" id="totalWeight">0kg</div>
                <div class="stat-label">Total Weight</div>
            </div>
        </div>

        <!-- Action Buttons -->
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h2 style="color: #ffffff !important; margin: 0;">Waste Collections</h2>
            <div>
                <button type="button" class="btn-primary me-2" id="generateReportBtn">
                    <i class="fas fa-chart-bar me-2"></i>Generate Report
                </button>
                <button type="button" class="btn-primary" id="addCollectionBtn">
                    <i class="fas fa-plus me-2"></i>Add New Collection
                </button>
            </div>
        </div>

        <div class="filter-card" style="background: rgba(255, 255, 255, 0.05); backdrop-filter: blur(20px); border: 1px solid rgba(255, 255, 255, 0.1); border-radius: 15px; padding: 1.5rem; margin-bottom: 2rem;">
            <h5 class="mb-3" style="color: #ffffff !important;"><i class="fas fa-filter me-2"></i>Filter Collections</h5>
            <div class="filter-group">
                <div class="form-group search-box">
                    <label class="form-label">Search Collections</label>
                    <div class="position-relative">
                        <i class="fas fa-search search-icon"></i>
                        <input type="text" class="form-control search-input" id="searchCollections" placeholder="Search by address, collector, or citizen...">
                    </div>
                </div>
                
                <div class="form-group">
                    <label class="form-label">Status</label>
                    <select class="form-control" id="statusFilter">
                        <option value="all">All Status</option>
                        <option value="requested">Requested</option>
                        <option value="assigned">Assigned</option>
                        <option value="completed">Completed</option>
                        <option value="cancelled">Cancelled</option>
                    </select>
                </div>
                
                <div class="form-group">
                    <label class="form-label">Date Range</label>
                    <select class="form-control" id="dateFilter">
                        <option value="all">All Time</option>
                        <option value="today">Today</option>
                        <option value="week">This Week</option>
                        <option value="month">This Month</option>
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
                Showing 0 collections
            </div>
        </div>

        <div id="gridView">
            <div class="collections-grid" id="collectionsGrid">
                <!-- Collections will be loaded here -->
            </div>
        </div>

        <div id="tableView" style="display: none;">
            <div class="table-responsive">
                <table class="collections-table" id="collectionsTable">
                    <thead>
                        <tr>
                            <th>Pickup ID</th>
                            <th>Citizen</th>
                            <th>Collector</th>
                            <th>Address</th>
                            <th>Waste Type</th>
                            <th>Weight</th>
                            <th>Status</th>
                            <th>Created</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody id="collectionsTableBody">
                        <!-- Table rows will be loaded here -->
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
                    <!-- Pagination will be generated here -->
                </ul>
            </nav>
        </div>
    </div>

    <!-- View Collection Details Modal -->
    <div class="modal-overlay" id="viewCollectionModal">
        <div class="modal-content" style="max-width: 700px;">
            <div class="modal-header">
                <h3 class="modal-title">Collection Details</h3>
                <button type="button" class="close-modal">&times;</button>
            </div>
            <div class="modal-body">
                <div class="collection-details-container">
                    <div class="collection-info-grid">
                        <div class="info-item">
                            <label>Pickup ID:</label>
                            <span id="viewPickupId">-</span>
                        </div>
                        <div class="info-item">
                            <label>Status:</label>
                            <span id="viewCollectionStatus">-</span>
                        </div>
                        <div class="info-item">
                            <label>Citizen:</label>
                            <div class="collector-info">
                                <div class="user-avatar" id="viewCitizenAvatar">C</div>
                                <span id="viewCitizenName">-</span>
                            </div>
                        </div>
                        <div class="info-item">
                            <label>Collector:</label>
                            <div class="collector-info">
                                <div class="user-avatar" id="viewCollectorAvatar">C</div>
                                <span id="viewCollectorName">-</span>
                            </div>
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
                            <label>Verified Weight:</label>
                            <span id="viewVerifiedWeight">-</span>
                        </div>
                        <div class="info-item">
                            <label>Credits Earned:</label>
                            <span id="viewCreditsEarned">-</span>
                        </div>
                        <div class="info-item full-width">
                            <label>Address:</label>
                            <span id="viewCollectionAddress">-</span>
                        </div>
                        <div class="info-item">
                            <label>Created:</label>
                            <span id="viewCreatedAt">-</span>
                        </div>
                        <div class="info-item">
                            <label>Completed:</label>
                            <span id="viewCompletedAt">-</span>
                        </div>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-action btn-assign" id="assignCollectorBtn">
                    <i class="fas fa-user-plus me-2"></i>Assign Collector
                </button>
                <button type="button" class="btn-action btn-complete" id="completeCollectionBtn">
                    <i class="fas fa-check me-2"></i>Mark Complete
                </button>
                <button type="button" class="btn-action btn-delete" id="deleteCollectionBtn">
                    <i class="fas fa-trash me-2"></i>Delete
                </button>
                <button type="button" class="btn-action" id="closeViewModalBtn">Close</button>
            </div>
        </div>
    </div>

    <!-- Add Collection Modal -->
    <div class="modal-overlay" id="addCollectionModal">
        <div class="modal-content" style="max-width: 600px;">
            <div class="modal-header">
                <h3 class="modal-title">Add New Collection</h3>
                <button type="button" class="close-modal">&times;</button>
            </div>
            <div class="modal-body">
                <div class="add-collection-form">
                    <div class="form-row">
                        <div class="form-half">
                            <label class="form-label">Citizen</label>
                            <select class="form-control" id="addCitizenSelect">
                                <option value="">-- Select Citizen --</option>
                            </select>
                        </div>
                        <div class="form-half">
                            <label class="form-label">Waste Type</label>
                            <select class="form-control" id="addWasteTypeSelect">
                                <option value="">-- Select Waste Type --</option>
                            </select>
                        </div>
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label">Address</label>
                        <input type="text" class="form-control" id="addAddress" placeholder="Enter collection address">
                    </div>
                    
                    <div class="form-row">
                        <div class="form-half">
                            <label class="form-label">Estimated Weight (kg)</label>
                            <input type="number" class="form-control" id="addEstimatedWeight" step="0.01" min="0" placeholder="Enter estimated weight">
                        </div>
                        <div class="form-half">
                            <label class="form-label">Schedule Date</label>
                            <input type="datetime-local" class="form-control" id="addScheduleDate">
                        </div>
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label">Notes (Optional)</label>
                        <textarea class="form-control" id="addNotes" rows="3" placeholder="Any additional notes..."></textarea>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-action" id="cancelAddBtn">Cancel</button>
                <button type="button" class="btn-primary" id="confirmAddBtn">Create Collection</button>
            </div>
        </div>
    </div>

    <!-- Delete Confirmation Modal -->
    <div class="modal-overlay" id="deleteCollectionModal">
        <div class="modal-content" style="max-width: 500px;">
            <div class="modal-header">
                <h3 class="modal-title">Confirm Delete</h3>
                <button type="button" class="close-modal">&times;</button>
            </div>
            <div class="modal-body">
                <p style="color: rgba(255, 255, 255, 0.8) !important;">Are you sure you want to delete this collection? This action cannot be undone.</p>
                <p style="color: rgba(255, 255, 255, 0.6) !important; font-size: 0.9rem;" id="deleteCollectionInfo"></p>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-action" id="cancelDeleteBtn">Cancel</button>
                <button type="button" class="btn-action btn-delete" id="confirmDeleteBtn">Delete Collection</button>
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
                        <option value="">-- Select Collector --</option>
                    </select>
                </div>
                <div class="form-group">
                    <label class="form-label">Schedule Date & Time</label>
                    <input type="datetime-local" class="form-control" id="scheduleDateTime">
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-action" id="cancelAssignBtn">Cancel</button>
                <button type="button" class="btn-primary" id="confirmAssignBtn">Assign Collector</button>
            </div>
        </div>
    </div>

    <!-- Complete Collection Modal -->
    <div class="modal-overlay" id="completeCollectionModal">
        <div class="modal-content" style="max-width: 500px;">
            <div class="modal-header">
                <h3 class="modal-title">Complete Collection</h3>
                <button type="button" class="close-modal">&times;</button>
            </div>
            <div class="modal-body">
                <div class="form-group">
                    <label class="form-label">Verified Weight (kg)</label>
                    <input type="number" class="form-control" id="verifiedWeight" step="0.01" min="0" placeholder="Enter actual weight collected">
                </div>
                <div class="form-group">
                    <label class="form-label">Material Type</label>
                    <select class="form-control" id="materialTypeSelect">
                        <option value="">-- Select Material --</option>
                    </select>
                </div>
                <div class="form-group">
                    <label class="form-label">Notes (Optional)</label>
                    <textarea class="form-control" id="completionNotes" rows="3" placeholder="Any additional notes..."></textarea>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-action" id="cancelCompleteBtn">Cancel</button>
                <button type="button" class="btn-primary" id="confirmCompleteBtn">Mark as Complete</button>
            </div>
        </div>
    </div>

    <asp:Button ID="btnLoadCollections" runat="server" OnClick="btnLoadCollections_Click" Style="display: none;" />
    <asp:HiddenField ID="hfCollectionsData" runat="server" />
    <asp:HiddenField ID="hfCurrentPage" runat="server" Value="1" />
    <asp:HiddenField ID="hfStatsData" runat="server" />
    <asp:HiddenField ID="hfCollectorsData" runat="server" />
    <asp:HiddenField ID="hfCitizensData" runat="server" />
    <asp:HiddenField ID="hfWasteTypesData" runat="server" />
</asp:Content>