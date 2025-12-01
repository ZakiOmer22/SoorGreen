<%@ Page Title="Users" Language="C#" MasterPageFile="~/Pages/Admin/Site.master" AutoEventWireup="true" CodeFile="Users.aspx.cs" Inherits="SoorGreen.Admin.Admin.Users" %>
<%@ Import Namespace="System.Web.Optimization" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <%: Styles.Render("~/Content/adminusers") %>
</asp:Content>
<asp:Content ID="PageTitle" ContentPlaceHolderID="PageTitle" runat="server">
    User Management
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="ScriptsContent" runat="server">
    <%: Scripts.Render("~/bundles/adminusers") %>
</asp:Content>
<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
   

    <div class="users-container">
        <div class="filter-card">
            <h5 class="mb-3" style="color: #ffffff !important;"><i class="fas fa-filter me-2"></i>Filter Users</h5>
            <div class="filter-group">
                <div class="form-group search-box">
                    <label class="form-label">Search Users</label>
                    <div class="position-relative">
                        <i class="fas fa-search search-icon"></i>
                        <input type="text" class="form-control search-input" id="searchUsers" placeholder="Search by name, email, or phone...">
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
                    <label class="form-label">User Type</label>
                    <select class="form-control" id="typeFilter">
                        <option value="all">All Types</option>
                        <option value="customer">Customer</option>
                        <option value="collector">Collector</option>
                        <option value="admin">Admin</option>
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
                    <button class="btn-primary" onclick="applyFilters()" style="margin-top: 1.7rem;">
                        <i class="fas fa-filter me-2"></i>Apply Filters
                    </button>
                </div>
            </div>
        </div>

        <div class="d-flex justify-content-between align-items-center mb-3">
            <div class="view-options">
                <button class="view-btn active" onclick="changeView('grid')">
                    <i class="fas fa-th me-2"></i>Grid View
                </button>
                <button class="view-btn" onclick="changeView('table')">
                    <i class="fas fa-table me-2"></i>Table View
                </button>
            </div>
            <div class="page-info" id="pageInfo">
                Showing 0 users
            </div>
        </div>

        <div id="gridView">
            <div class="users-grid" id="usersGrid">
            </div>
        </div>

        <div id="tableView" style="display: none;">
            <div class="table-responsive">
                <table class="users-table" id="usersTable">
                    <thead>
                        <tr>
                            <th>User</th>
                            <th>Contact</th>
                            <th>Type</th>
                            <th>Status</th>
                            <th>Pickups</th>
                            <th>Credits</th>
                            <th>Joined</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody id="usersTableBody">
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

    <!-- Edit User Modal -->
    <div class="modal-overlay" id="userModal">
        <div class="modal-content">
            <div class="modal-header">
                <h3 class="modal-title" id="modalTitle">Add New User</h3>
                <button class="close-modal" onclick="closeUserModal()">&times;</button>
            </div>
            <form id="userForm">
                <div class="form-row">
                    <div class="form-half">
                        <label class="form-label">First Name</label>
                        <input type="text" class="form-control" id="firstName" required>
                    </div>
                    <div class="form-half">
                        <label class="form-label">Last Name</label>
                        <input type="text" class="form-control" id="lastName" required>
                    </div>
                </div>
                
                <div class="form-group">
                    <label class="form-label">Email</label>
                    <input type="email" class="form-control" id="email" required>
                </div>
                
                <div class="form-group">
                    <label class="form-label">Phone</label>
                    <input type="tel" class="form-control" id="phone">
                </div>
                
                <div class="form-row">
                    <div class="form-half">
                        <label class="form-label">User Type</label>
                        <select class="form-control" id="userType" required>
                            <option value="customer">Customer</option>
                            <option value="collector">Collector</option>
                            <option value="admin">Admin</option>
                        </select>
                    </div>
                    <div class="form-half">
                        <label class="form-label">Status</label>
                        <select class="form-control" id="userStatus" required>
                            <option value="active">Active</option>
                            <option value="inactive">Inactive</option>
                            <option value="suspended">Suspended</option>
                            <option value="pending">Pending</option>
                        </select>
                    </div>
                </div>
                
                <div class="form-group">
                    <label class="form-label">Address</label>
                    <textarea class="form-control" id="address" rows="3"></textarea>
                </div>
                
                <div class="form-group">
                    <label class="form-label">Initial Credits</label>
                    <input type="number" class="form-control" id="credits" value="0" min="0">
                </div>
                
                <div class="d-flex gap-2 mt-4">
                    <button type="button" class="btn-action" onclick="closeUserModal()" style="flex: 1;">Cancel</button>
                    <button type="submit" class="btn-primary" style="flex: 2;">Save User</button>
                </div>
            </form>
        </div>
    </div>

    <!-- View User Details Modal -->
    <div class="modal-overlay" id="viewUserModal">
        <div class="modal-content" style="max-width: 600px;">
            <div class="modal-header">
                <h3 class="modal-title">User Details</h3>
                <button class="close-modal" onclick="closeViewUserModal()">&times;</button>
            </div>
            <div class="modal-body">
                <div class="user-details-container">
                    <div class="user-avatar-large">
                        <div class="user-avatar" style="width: 80px; height: 80px; font-size: 1.5rem;" id="viewUserAvatar">
                            UU
                        </div>
                    </div>
                    <div class="user-info-grid">
                        <div class="info-item">
                            <label>Full Name:</label>
                            <span id="viewUserName">-</span>
                        </div>
                        <div class="info-item">
                            <label>Email:</label>
                            <span id="viewUserEmail">-</span>
                        </div>
                        <div class="info-item">
                            <label>Phone:</label>
                            <span id="viewUserPhone">-</span>
                        </div>
                        <div class="info-item">
                            <label>User Type:</label>
                            <span id="viewUserType">-</span>
                        </div>
                        <div class="info-item">
                            <label>Status:</label>
                            <span id="viewUserStatus">-</span>
                        </div>
                        <div class="info-item">
                            <label>Credits:</label>
                            <span id="viewUserCredits">-</span>
                        </div>
                        <div class="info-item">
                            <label>Registration Date:</label>
                            <span id="viewUserRegDate">-</span>
                        </div>
                        <div class="info-item full-width">
                            <label>Address:</label>
                            <span id="viewUserAddress">-</span>
                        </div>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-action" onclick="closeViewUserModal()">Close</button>
            </div>
        </div>
    </div>

    <!-- Delete Confirmation Modal -->
    <div class="modal-overlay" id="deleteUserModal">
        <div class="modal-content" style="max-width: 500px;">
            <div class="modal-header">
                <h3 class="modal-title">Confirm Delete</h3>
                <button class="close-modal" onclick="closeDeleteModal()">&times;</button>
            </div>
            <div class="modal-body">
                <div class="text-center">
                    <i class="fas fa-exclamation-triangle fa-3x text-warning mb-3"></i>
                    <h4>Are you sure?</h4>
                    <p>You are about to delete user: <strong id="deleteUserName">-</strong></p>
                    <p class="text-muted">This action cannot be undone.</p>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-action" onclick="closeDeleteModal()" style="flex: 1;">Cancel</button>
                <button type="button" class="btn-primary" onclick="confirmDelete()" style="flex: 1;">Delete User</button>
            </div>
        </div>
    </div>

    <asp:Button ID="btnLoadUsers" runat="server" OnClick="LoadUsers" Style="display: none;" />
    <asp:HiddenField ID="hfUsersData" runat="server" />
    <asp:HiddenField ID="hfCurrentPage" runat="server" Value="1" />
</asp:Content>