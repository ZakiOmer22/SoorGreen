<%@ Page Title="Notifications" Language="C#" MasterPageFile="~/Pages/Admin/Site.master" AutoEventWireup="true" CodeFile="NotificationsMgmt.aspx.cs" Inherits="SoorGreen.Admin.Admin.NotificationsMgmt" %>
<%@ Import Namespace="System.Web.Optimization" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <%: Styles.Render("~/Content/adminnotificationsmgmt") %>
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="ScriptsContent" runat="server">
    <%: Scripts.Render("~/bundles/adminnotificationsmgmt") %>
</asp:Content>
<asp:Content ID="PageTitle" ContentPlaceHolderID="PageTitle" runat="server">
    Notifications Management
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <asp:ScriptManager ID="ScriptManager1" runat="server" EnablePageMethods="true"></asp:ScriptManager>
    <div class="container-fluid">
        <div class="page-header">
            <h1 class="page-title">Notifications Management</h1>
            <p class="page-subtitle">Manage and send notifications to users</p>
        </div>

        <div class="notifications-container">
            <!-- Statistics Cards -->
            <div class="stats-cards">
                <div class="stat-card">
                    <div class="stat-value" id="totalNotifications">0</div>
                    <div class="stat-label">Total Notifications</div>
                </div>
                <div class="stat-card">
                    <div class="stat-value" id="unreadNotifications">0</div>
                    <div class="stat-label">Unread</div>
                </div>
                <div class="stat-card">
                    <div class="stat-value" id="todayNotifications">0</div>
                    <div class="stat-label">Today</div>
                </div>
                <div class="stat-card">
                    <div class="stat-value" id="sentThisWeek">0</div>
                    <div class="stat-label">This Week</div>
                </div>
            </div>

            <!-- Action Buttons -->
            <div class="d-flex justify-content-between align-items-center mb-4">
                <h2 style="color: #ffffff !important; margin: 0;">User Notifications</h2>
                <div>
                    <button type="button" class="btn-success me-2" id="sendNotificationBtn">
                        <i class="fas fa-bell me-2"></i>Send Notification
                    </button>
                    <button type="button" class="btn-warning me-2" id="markAllReadBtn">
                        <i class="fas fa-check-double me-2"></i>Mark All Read
                    </button>
                    <button type="button" class="btn-primary" id="refreshBtn">
                        <i class="fas fa-sync-alt me-2"></i>Refresh
                    </button>
                </div>
            </div>

            <!-- Filters -->
            <div class="filter-card">
                <h5 class="mb-3" style="color: #ffffff !important;"><i class="fas fa-filter me-2"></i>Filter Notifications</h5>
                <div class="filter-group">
                    <div class="form-group search-box">
                        <label class="form-label">Search Notifications</label>
                        <div class="position-relative">
                            <i class="fas fa-search search-icon"></i>
                            <input type="text" class="form-control search-input" id="searchNotifications" placeholder="Search by title, message, or user...">
                        </div>
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label">Status</label>
                        <select class="form-control" id="statusFilter">
                            <option value="all">All Status</option>
                            <option value="unread">Unread</option>
                            <option value="read">Read</option>
                        </select>
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label">Type</label>
                        <select class="form-control" id="typeFilter">
                            <option value="all">All Types</option>
                            <option value="system">System</option>
                            <option value="pickup">Pickup</option>
                            <option value="reward">Reward</option>
                            <option value="alert">Alert</option>
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

            <!-- View Options -->
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
                    Showing 0 notifications
                </div>
            </div>

            <!-- Loading Spinner -->
            <div class="loading-spinner" id="loadingSpinner">
                <div class="spinner"></div>
                <p style="color: rgba(255, 255, 255, 0.7); margin-top: 1rem;">Loading notifications...</p>
            </div>

            <!-- Grid View -->
            <div id="gridView">
                <div class="notifications-grid" id="notificationsGrid">
                    <!-- Grid content will be populated by JavaScript -->
                </div>
            </div>

            <!-- Table View -->
            <div id="tableView" style="display: none;">
                <div class="table-responsive">
                    <table class="notifications-table" id="notificationsTable">
                        <thead>
                            <tr>
                                <th>Notification ID</th>
                                <th>User</th>
                                <th>Title</th>
                                <th>Type</th>
                                <th>Status</th>
                                <th>Sent</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody id="notificationsTableBody">
                            <!-- Table content will be populated by JavaScript -->
                        </tbody>
                    </table>
                </div>
            </div>
            
            <!-- Empty State -->
            <div id="notificationsEmptyState" class="empty-state" style="display: none;">
                <div class="empty-state-icon">
                    <i class="fas fa-bell-slash"></i>
                </div>
                <h3 class="empty-state-title">No Notifications Found</h3>
                <p class="empty-state-description">No notifications match the current search criteria.</p>
                <button type="button" class="btn-primary" id="clearFiltersBtn">
                    <i class="fas fa-times me-2"></i>Clear Filters
                </button>
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

        <!-- Notification Details Modal -->
        <div class="modal-overlay" id="notificationModal">
            <div class="modal-content">
                <div class="modal-header">
                    <h3 class="modal-title">Notification Details</h3>
                    <button type="button" class="close-modal">&times;</button>
                </div>
                <div class="modal-body">
                    <div class="notification-details-container">
                        <div class="info-grid">
                            <div class="info-item">
                                <label>Notification ID:</label>
                                <span id="modalNotificationId">-</span>
                            </div>
                            <div class="info-item">
                                <label>Status:</label>
                                <span id="modalStatus">-</span>
                            </div>
                            <div class="info-item">
                                <label>User:</label>
                                <div class="user-info">
                                    <div class="user-avatar" id="modalUserAvatar">U</div>
                                    <span id="modalUserName">-</span>
                                </div>
                            </div>
                            <div class="info-item">
                                <label>Type:</label>
                                <span id="modalType">-</span>
                            </div>
                            <div class="info-item">
                                <label>Sent:</label>
                                <span id="modalSentDate">-</span>
                            </div>
                            <div class="info-item">
                                <label>Read:</label>
                                <span id="modalReadStatus">-</span>
                            </div>
                            <div class="info-item full-width">
                                <label>Title:</label>
                                <span id="modalTitle">-</span>
                            </div>
                            <div class="info-item full-width">
                                <label>Message:</label>
                                <div class="message-box" id="modalMessage">-</div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn-action" id="closeModalBtn">Close</button>
                    <button type="button" class="btn-action btn-mark-read" id="markAsReadBtn">Mark as Read</button>
                    <button type="button" class="btn-action btn-delete" id="deleteNotificationBtn">Delete</button>
                </div>
            </div>
        </div>

        <!-- Send Notification Modal -->
        <div class="modal-overlay" id="sendNotificationModal">
            <div class="modal-content">
                <div class="modal-header">
                    <h3 class="modal-title">Send New Notification</h3>
                    <button type="button" class="close-modal">&times;</button>
                </div>
                <div class="modal-body">
                    <div class="form-group">
                        <label class="form-label">Select User</label>
                        <select class="form-control" id="userSelect">
                            <option value="all">All Users</option>
                            <!-- Users will be populated dynamically -->
                        </select>
                    </div>
                    <div class="form-group">
                        <label class="form-label">Notification Type</label>
                        <select class="form-control" id="notificationType">
                            <option value="system">System</option>
                            <option value="pickup">Pickup Update</option>
                            <option value="reward">Reward</option>
                            <option value="alert">Alert</option>
                            <option value="info">Information</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label class="form-label">Title</label>
                        <input type="text" class="form-control" id="notificationTitle" placeholder="Enter notification title">
                    </div>
                    <div class="form-group">
                        <label class="form-label">Message</label>
                        <textarea class="form-control" id="notificationMessage" rows="4" placeholder="Enter notification message"></textarea>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn-action" id="cancelSendBtn">Cancel</button>
                    <button type="button" class="btn-primary" id="sendNowBtn">Send Notification</button>
                </div>
            </div>
        </div>

        <!-- Delete Confirmation Modal -->
        <div class="modal-overlay" id="deleteModal">
            <div class="modal-content" style="max-width: 500px;">
                <div class="modal-header">
                    <h3 class="modal-title">Confirm Delete</h3>
                    <button type="button" class="close-modal">&times;</button>
                </div>
                <div class="modal-body">
                    <div class="text-center">
                        <i class="fas fa-exclamation-triangle fa-3x text-warning mb-3"></i>
                        <h4>Are you sure?</h4>
                        <p>You are about to delete notification: <strong id="deleteNotificationId">-</strong></p>
                        <p class="text-muted">This action cannot be undone.</p>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn-action" id="cancelDeleteBtn" style="flex: 1;">Cancel</button>
                    <button type="button" class="btn-danger" id="confirmDeleteBtn" style="flex: 1;">Delete Notification</button>
                </div>
            </div>
        </div>
    </div>

    <asp:Button ID="btnLoadNotifications" runat="server" OnClick="btnLoadNotifications_Click" Style="display: none;" />
    <asp:HiddenField ID="hfNotificationsData" runat="server" />
    <asp:HiddenField ID="hfStatsData" runat="server" />
    <asp:HiddenField ID="hfUsersData" runat="server" />
</asp:Content>