<%@ Page Title="Waste Types" Language="C#" MasterPageFile="~/Pages/Admin/Site.master" AutoEventWireup="true" CodeFile="WasteTypes.aspx.cs" Inherits="SoorGreen.Admin.Admin.WasteTypes" %>
<%@ Register Assembly="System.Web.Extensions, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35" Namespace="System.Web.UI" TagPrefix="asp" %>
<%@ Import Namespace="System.Web.Optimization" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <%: Styles.Render("~/Content/adminwastetypes") %>
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="ScriptsContent" runat="server">
    <%: Scripts.Render("~/bundles/adminwastetypes") %>
</asp:Content>
<asp:Content ID="PageTitle" ContentPlaceHolderID="PageTitle" runat="server">
    Waste Types Management
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <asp:ScriptManager ID="ScriptManager1" runat="server" EnablePageMethods="true"></asp:ScriptManager>
    
   

    <div class="waste-types-container">
        <!-- Statistics Cards -->
        <div class="stats-cards">
            <div class="stat-card">
                <div class="stat-value" id="totalTypes">0</div>
                <div class="stat-label">Total Waste Types</div>
            </div>
            <div class="stat-card">
                <div class="stat-value" id="avgCreditRate">0.00</div>
                <div class="stat-label">Average Credit Rate</div>
            </div>
            <div class="stat-card">
                <div class="stat-value" id="highestCredit">0.00</div>
                <div class="stat-label">Highest Credit Rate</div>
            </div>
            <div class="stat-card">
                <div class="stat-value" id="activeTypes">0</div>
                <div class="stat-label">Active Types</div>
            </div>
        </div>

        <div class="filter-card" style="background: rgba(255, 255, 255, 0.05); backdrop-filter: blur(20px); border: 1px solid rgba(255, 255, 255, 0.1); border-radius: 15px; padding: 1.5rem; margin-bottom: 2rem;">
            <h5 class="mb-3" style="color: #ffffff !important;"><i class="fas fa-filter me-2"></i>Filter Waste Types</h5>
            <div class="filter-group">
                <div class="form-group search-box">
                    <label class="form-label">Search Types</label>
                    <div class="position-relative">
                        <i class="fas fa-search search-icon"></i>
                        <input type="text" class="form-control search-input" id="searchTypes" placeholder="Search by name or description...">
                    </div>
                </div>
                
                <div class="form-group">
                    <label class="form-label">Credit Range</label>
                    <select class="form-control" id="creditFilter">
                        <option value="all">All Credits</option>
                        <option value="low">Low (0-0.25)</option>
                        <option value="medium">Medium (0.26-0.75)</option>
                        <option value="high">High (0.76+)</option>
                    </select>
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
            <button type="button" class="btn-add" id="addTypeBtn">
                <i class="fas fa-plus me-2"></i>Add New Waste Type
            </button>
            
            <div class="page-info" id="pageInfo">
                Showing 0 types
            </div>
        </div>

        <div id="gridView">
            <div class="types-grid" id="typesGrid">
            </div>
        </div>

        <div id="tableView" style="display: none;">
            <div class="table-responsive">
                <table class="types-table" id="typesTable">
                    <thead>
                        <tr>
                            <th>Type ID</th>
                            <th>Name</th>
                            <th>Credit Rate</th>
                            <th>Status</th>
                            <th>Reports Count</th>
                            <th>Total Weight</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody id="typesTableBody">
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

    <!-- View Type Details Modal -->
    <div class="modal-overlay" id="viewTypeModal">
        <div class="modal-content" style="max-width: 700px;">
            <div class="modal-header">
                <h3 class="modal-title">Waste Type Details</h3>
                <button type="button" class="close-modal">&times;</button>
            </div>
            <div class="modal-body">
                <div class="type-details-container">
                    <div class="type-info-grid">
                        <div class="info-item">
                            <label>Type ID:</label>
                            <span id="viewTypeId">-</span>
                        </div>
                        <div class="info-item">
                            <label>Status:</label>
                            <span id="viewTypeStatus">-</span>
                        </div>
                        <div class="info-item">
                            <label>Name:</label>
                            <span id="viewTypeName">-</span>
                        </div>
                        <div class="info-item">
                            <label>Credit Rate:</label>
                            <span id="viewCreditRate">-</span>
                        </div>
                        <div class="info-item">
                            <label>Total Reports:</label>
                            <span id="viewReportsCount">-</span>
                        </div>
                        <div class="info-item">
                            <label>Total Weight:</label>
                            <span id="viewTotalWeight">-</span>
                        </div>
                        <div class="info-item">
                            <label>Average Weight:</label>
                            <span id="viewAvgWeight">-</span>
                        </div>
                        <div class="info-item">
                            <label>Total Credits:</label>
                            <span id="viewTotalCredits">-</span>
                        </div>
                        <div class="info-item full-width">
                            <label>Description:</label>
                            <span id="viewTypeDescription">-</span>
                        </div>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-action btn-edit" id="editTypeBtn">
                    <i class="fas fa-edit me-2"></i>Edit Type
                </button>
                <button type="button" class="btn-action" id="closeViewModalBtn">Close</button>
            </div>
        </div>
    </div>

    <!-- Add/Edit Waste Type Modal -->
    <div class="modal-overlay" id="editTypeModal">
        <div class="modal-content" style="max-width: 600px;">
            <div class="modal-header">
                <h3 class="modal-title" id="editModalTitle">Add New Waste Type</h3>
                <button type="button" class="close-modal">&times;</button>
            </div>
            <div class="modal-body">
                <div class="form-group">
                    <label class="form-label">Waste Type Name</label>
                    <input type="text" class="form-control" id="typeName" placeholder="Enter waste type name">
                </div>
                <div class="form-row">
                    <div class="form-half">
                        <label class="form-label">Credit Rate (per kg)</label>
                        <input type="number" class="form-control" id="creditRate" step="0.01" min="0" placeholder="0.00">
                    </div>
                    <div class="form-half">
                        <label class="form-label">Status</label>
                        <select class="form-control" id="typeStatus">
                            <option value="Active">Active</option>
                            <option value="Inactive">Inactive</option>
                        </select>
                    </div>
                </div>
                <div class="form-group">
                    <label class="form-label">Description (Optional)</label>
                    <textarea class="form-control" id="typeDescription" rows="3" placeholder="Enter description..."></textarea>
                </div>
                <div class="form-group">
                    <label class="form-label">Color Indicator (Optional)</label>
                    <input type="color" class="form-control" id="typeColor" value="#20c997" style="height: 50px;">
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-action" id="cancelEditBtn">Cancel</button>
                <button type="button" class="btn-primary" id="confirmEditBtn">Save Waste Type</button>
            </div>
        </div>
    </div>

    <!-- Delete Confirmation Modal -->
    <div class="modal-overlay" id="deleteTypeModal">
        <div class="modal-content" style="max-width: 500px;">
            <div class="modal-header">
                <h3 class="modal-title">Confirm Delete</h3>
                <button type="button" class="close-modal">&times;</button>
            </div>
            <div class="modal-body">
                <div class="text-center">
                    <i class="fas fa-exclamation-triangle fa-3x text-warning mb-3"></i>
                    <h4>Are you sure?</h4>
                    <p>You are about to delete waste type: <strong id="deleteTypeName">-</strong></p>
                    <p class="text-muted">This action cannot be undone. Associated waste reports will need to be reassigned.</p>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-action" id="cancelDeleteBtn" style="flex: 1;">Cancel</button>
                <button type="button" class="btn-primary" id="confirmDeleteBtn" style="flex: 1;">Delete Type</button>
            </div>
        </div>
    </div>

    <asp:Button ID="btnLoadTypes" runat="server" OnClick="LoadWasteTypes" Style="display: none;" />
    <asp:HiddenField ID="hfTypesData" runat="server" />
    <asp:HiddenField ID="hfCurrentPage" runat="server" Value="1" />
    <asp:HiddenField ID="hfStatsData" runat="server" />
</asp:Content>
