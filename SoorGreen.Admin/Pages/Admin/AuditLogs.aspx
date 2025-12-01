<%@ Page Title="Audit Logs" Language="C#" MasterPageFile="~/Pages/Admin/Site.master" AutoEventWireup="true" CodeFile="AuditLogs.aspx.cs" Inherits="SoorGreen.Admin.Admin.AuditLogs" %>
<%@ Import Namespace="System.Web.Optimization" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <%: Styles.Render("~/Content/adminauditlogs") %>
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="ScriptsContent" runat="server">
    <%: Scripts.Render("~/bundles/adminauditlogs") %>
</asp:Content>
<asp:Content ID="PageTitle" ContentPlaceHolderID="PageTitle" runat="server">
    Audit Logs
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <asp:ScriptManager ID="ScriptManager1" runat="server" EnablePageMethods="true"></asp:ScriptManager>
    
    

    <div class="auditlogs-container">
        <!-- Statistics Cards -->
        <div class="stats-cards">
            <div class="stat-card">
                <div class="stat-value" id="totalLogs">0</div>
                <div class="stat-label">Total Logs</div>
            </div>
            <div class="stat-card">
                <div class="stat-value" id="todayLogs">0</div>
                <div class="stat-label">Today's Logs</div>
            </div>
            <div class="stat-card">
                <div class="stat-value" id="uniqueUsers">0</div>
                <div class="stat-label">Unique Users</div>
            </div>
            <div class="stat-card">
                <div class="stat-value" id="systemActions">0</div>
                <div class="stat-label">System Actions</div>
            </div>
        </div>

        <!-- Action Buttons -->
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h2 style="color: #ffffff !important; margin: 0;">Audit Logs</h2>
            <div>
                <button type="button" class="btn-success me-2" id="exportBtn">
                    <i class="fas fa-download me-2"></i>Export CSV
                </button>
                <button type="button" class="btn-warning me-2" id="clearLogsBtn">
                    <i class="fas fa-trash me-2"></i>Clear Old Logs
                </button>
                <button type="button" class="btn-primary" id="refreshBtn">
                    <i class="fas fa-sync-alt me-2"></i>Refresh
                </button>
            </div>
        </div>

        <!-- Filters -->
        <div class="filter-card" style="background: rgba(255, 255, 255, 0.05); backdrop-filter: blur(20px); border: 1px solid rgba(255, 255, 255, 0.1); border-radius: 15px; padding: 1.5rem; margin-bottom: 2rem;">
            <h5 class="mb-3" style="color: #ffffff !important;"><i class="fas fa-filter me-2"></i>Filter Audit Logs</h5>
            <div class="filter-group">
                <div class="form-group search-box">
                    <label class="form-label">Search</label>
                    <div class="position-relative">
                        <i class="fas fa-search search-icon"></i>
                        <input type="text" class="form-control search-input" id="searchLogs" placeholder="Search by action, user, or details...">
                    </div>
                </div>
                
                <div class="form-group">
                    <label class="form-label">Action Type</label>
                    <select class="form-control" id="actionFilter">
                        <option value="all">All Actions</option>
                        <option value="create">Create</option>
                        <option value="update">Update</option>
                        <option value="delete">Delete</option>
                        <option value="login">Login</option>
                        <option value="system">System</option>
                    </select>
                </div>
                
                <div class="form-group">
                    <label class="form-label">Date From</label>
                    <input type="date" class="form-control" id="dateFrom">
                </div>
                
                <div class="form-group">
                    <label class="form-label">Date To</label>
                    <input type="date" class="form-control" id="dateTo">
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
            <p style="color: rgba(255, 255, 255, 0.7); margin-top: 1rem;">Loading audit logs...</p>
        </div>

        <!-- Audit Logs Table -->
        <div class="table-responsive">
            <table class="auditlogs-table" id="auditlogsTable">
                <thead>
                    <tr>
                        <th>Audit ID</th>
                        <th>User</th>
                        <th>Action</th>
                        <th>Details</th>
                        <th>Timestamp</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody id="auditlogsTableBody">
                    <!-- Audit log rows will be loaded here -->
                </tbody>
            </table>
        </div>
        
        <!-- Empty State -->
        <div id="auditlogsEmptyState" class="empty-state" style="display: none;">
            <div class="empty-state-icon">
                <i class="fas fa-clipboard-list"></i>
            </div>
            <h3 class="empty-state-title">No Audit Logs Found</h3>
            <p class="empty-state-description">No audit logs match the current search criteria.</p>
            <button type="button" class="btn-primary" id="clearFiltersBtn">
                <i class="fas fa-times me-2"></i>Clear Filters
            </button>
        </div>

        <div class="pagination-container">
            <div class="page-info" id="paginationInfo">
                Showing 0 logs
            </div>
            <nav>
                <ul class="pagination mb-0" id="pagination">
                    <!-- Pagination will be generated here -->
                </ul>
            </nav>
        </div>
    </div>

    <!-- Audit Log Details Modal -->
    <div class="modal-overlay" id="auditlogModal" style="display: none;">
        <div class="modal-content">
            <div class="modal-header">
                <h3 class="modal-title">Audit Log Details</h3>
                <button type="button" class="close-modal">&times;</button>
            </div>
            <div class="modal-body">
                <div class="info-grid">
                    <div class="info-item">
                        <label>Audit ID:</label>
                        <span id="modalAuditId">-</span>
                    </div>
                    <div class="info-item">
                        <label>Action:</label>
                        <span id="modalAction">-</span>
                    </div>
                    <div class="info-item">
                        <label>User:</label>
                        <div class="user-info">
                            <div class="user-avatar" id="modalUserAvatar">U</div>
                            <span id="modalUserName">-</span>
                        </div>
                    </div>
                    <div class="info-item">
                        <label>Timestamp:</label>
                        <span id="modalTimestamp">-</span>
                    </div>
                    <div class="info-item full-width">
                        <label>Details:</label>
                        <div class="details-box" id="modalDetails">-</div>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-action" id="closeModalBtn">Close</button>
            </div>
        </div>
    </div>

    <asp:Button ID="btnLoadAuditLogs" runat="server" OnClick="btnLoadAuditLogs_Click" Style="display: none;" />
    <asp:HiddenField ID="hfAuditLogsData" runat="server" />
    <asp:HiddenField ID="hfStatsData" runat="server" />
</asp:Content>
