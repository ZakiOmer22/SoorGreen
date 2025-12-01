<%@ Page Title="Credit Management" Language="C#" MasterPageFile="~/Pages/Admin/Site.master" AutoEventWireup="true" CodeFile="Credits.aspx.cs" Inherits="SoorGreen.Admin.Admin.Credits" %>
<%@ Import Namespace="System.Web.Optimization" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <%: Styles.Render("~/Content/admincredits") %>
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="ScriptsContent" runat="server">
    <%: Scripts.Render("~/bundles/admincredits") %>
</asp:Content>
<asp:Content ID="PageTitle" ContentPlaceHolderID="PageTitle" runat="server">
    Credit Management
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <asp:ScriptManager ID="ScriptManager1" runat="server" EnablePageMethods="true"></asp:ScriptManager>
    
   

    <div class="credits-container">
        <!-- Statistics Cards -->
        <div class="stats-cards">
            <div class="stat-card">
                <div class="stat-value" id="totalUsers">0</div>
                <div class="stat-label">Total Users</div>
            </div>
            <div class="stat-card">
                <div class="stat-value" id="totalCredits">0</div>
                <div class="stat-label">Total Credits</div>
            </div>
            <div class="stat-card">
                <div class="stat-value" id="avgCredits">0</div>
                <div class="stat-label">Avg Credits per User</div>
            </div>
            <div class="stat-card">
                <div class="stat-value" id="activeUsers">0</div>
                <div class="stat-label">Active Users</div>
            </div>
        </div>

        <!-- Action Buttons -->
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h2 style="color: #ffffff !important; margin: 0;">User Credit Management</h2>
            <div>
                <button type="button" class="btn-success me-2" id="addCreditBtn">
                    <i class="fas fa-plus me-2"></i>Add Credits
                </button>
                <button type="button" class="btn-primary" id="refreshBtn">
                    <i class="fas fa-sync-alt me-2"></i>Refresh
                </button>
            </div>
        </div>

        <!-- Filters -->
        <div class="filter-card" style="background: rgba(255, 255, 255, 0.05); backdrop-filter: blur(20px); border: 1px solid rgba(255, 255, 255, 0.1); border-radius: 15px; padding: 1.5rem; margin-bottom: 2rem;">
            <h5 class="mb-3" style="color: #ffffff !important;"><i class="fas fa-filter me-2"></i>Filter Users</h5>
            <div class="filter-group">
                <div class="form-group search-box">
                    <label class="form-label">Search</label>
                    <div class="position-relative">
                        <i class="fas fa-search search-icon"></i>
                        <input type="text" class="form-control search-input" id="searchUsers" placeholder="Search by name, phone, or email...">
                    </div>
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
                    <label class="form-label">Role</label>
                    <select class="form-control" id="roleFilter">
                        <option value="all">All Roles</option>
                        <option value="citizen">Citizen</option>
                        <option value="collector">Collector</option>
                        <option value="admin">Admin</option>
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
            <p style="color: rgba(255, 255, 255, 0.7); margin-top: 1rem;">Loading users...</p>
        </div>

        <!-- Users Table -->
        <div class="table-responsive">
            <table class="credits-table" id="creditsTable">
                <thead>
                    <tr>
                        <th>User ID</th>
                        <th>User</th>
                        <th>Phone</th>
                        <th>Credits</th>
                        <th>Role</th>
                        <th>Status</th>
                        <th>Last Login</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody id="creditsTableBody">
                    <!-- User rows will be loaded here -->
                </tbody>
            </table>
        </div>
        
        <!-- Empty State -->
        <div id="creditsEmptyState" class="empty-state" style="display: none;">
            <div class="empty-state-icon">
                <i class="fas fa-users"></i>
            </div>
            <h3 class="empty-state-title">No Users Found</h3>
            <p class="empty-state-description">No users match the current search criteria.</p>
            <button type="button" class="btn-primary" id="clearFiltersBtn">
                <i class="fas fa-times me-2"></i>Clear Filters
            </button>
        </div>

        <div class="pagination-container">
            <div class="page-info" id="paginationInfo">
                Showing 0 users
            </div>
            <nav>
                <ul class="pagination mb-0" id="pagination">
                    <!-- Pagination will be generated here -->
                </ul>
            </nav>
        </div>
    </div>

    <!-- Add Credit Modal -->
    <div class="modal-overlay" id="creditModal" style="display: none;">
        <div class="modal-content">
            <div class="modal-header">
                <h3 class="modal-title">Add Credits</h3>
                <button type="button" class="close-modal">&times;</button>
            </div>
            <div class="modal-body">
                <div class="form-row">
                    <div class="form-group form-full">
                        <label class="form-label">User</label>
                        <select class="form-control" id="modalUserId">
                            <option value="">Select User</option>
                        </select>
                    </div>
                </div>
                <div class="form-row">
                    <div class="form-group">
                        <label class="form-label">Amount</label>
                        <input type="number" class="form-control" id="modalAmount" placeholder="Enter amount">
                    </div>
                    <div class="form-group">
                        <label class="form-label">Type</label>
                        <select class="form-control" id="modalType">
                            <option value="Bonus">Bonus</option>
                            <option value="Adjustment">Adjustment</option>
                            <option value="Recycling">Recycling</option>
                            <option value="Other">Other</option>
                        </select>
                    </div>
                </div>
                <div class="form-row">
                    <div class="form-group form-full">
                        <label class="form-label">Reference</label>
                        <input type="text" class="form-control" id="modalReference" placeholder="Enter reference">
                    </div>
                </div>
                <div class="form-row">
                    <div class="form-group form-full">
                        <label class="form-label">Notes</label>
                        <textarea class="form-control" id="modalNotes" rows="3" placeholder="Enter notes (optional)"></textarea>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-action" id="closeModalBtn">Cancel</button>
                <button type="button" class="btn-success" id="saveCreditBtn">Add Credits</button>
            </div>
        </div>
    </div>

    <asp:Button ID="btnLoadCredits" runat="server" OnClick="btnLoadCredits_Click" Style="display: none;" />
    <asp:HiddenField ID="hfUsersData" runat="server" />
    <asp:HiddenField ID="hfStatsData" runat="server" />
</asp:Content>
