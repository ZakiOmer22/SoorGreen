<%@ Page Title="Municipalities" Language="C#" MasterPageFile="~/Pages/Admin/Site.master" AutoEventWireup="true" CodeFile="Municipalities.aspx.cs" Inherits="SoorGreen.Admin.Admin.Municipalities" %>
<%@ Import Namespace="System.Web.Optimization" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <%: Styles.Render("~/Content/adminmunicipalities") %>
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="ScriptsContent" runat="server">
    <%: Scripts.Render("~/bundles/adminmunicipalities") %>
</asp:Content>
<asp:Content ID="PageTitle" ContentPlaceHolderID="PageTitle" runat="server">
    Municipalities Management
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <asp:ScriptManager ID="ScriptManager1" runat="server" EnablePageMethods="true"></asp:ScriptManager>
    
    

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
