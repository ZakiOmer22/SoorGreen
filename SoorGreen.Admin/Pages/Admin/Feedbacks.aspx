<%@ Page Title="Feedbacks" Language="C#" MasterPageFile="~/Pages/Admin/Site.master" AutoEventWireup="true" CodeFile="Feedbacks.aspx.cs" Inherits="SoorGreen.Admin.Admin.Feedbacks" %>
<%@ Import Namespace="System.Web.Optimization" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <%: Styles.Render("~/Content/adminfeedbacks") %>
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="ScriptsContent" runat="server">
    <%: Scripts.Render("~/bundles/adminfeedbacks") %>
</asp:Content>
<asp:Content ID="PageTitle" ContentPlaceHolderID="PageTitle" runat="server">
    User Feedbacks
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <asp:ScriptManager ID="ScriptManager1" runat="server" EnablePageMethods="true"></asp:ScriptManager>
    
    

    <div class="container-fluid">
        <div class="page-header">
            <h1 class="page-title">User Feedbacks Management</h1>
            <p class="page-subtitle">Manage and respond to user feedback and reviews</p>
        </div>

        <div class="feedbacks-container">
            <!-- Statistics Cards -->
            <div class="stats-cards">
                <div class="stat-card">
                    <div class="stat-value" id="totalFeedbacks">0</div>
                    <div class="stat-label">Total Feedbacks</div>
                </div>
                <div class="stat-card">
                    <div class="stat-value" id="pendingFeedbacks">0</div>
                    <div class="stat-label">Pending Review</div>
                </div>
                <div class="stat-card">
                    <div class="stat-value" id="averageRating">0.0</div>
                    <div class="stat-label">Average Rating</div>
                </div>
                <div class="stat-card">
                    <div class="stat-value" id="resolvedFeedbacks">0</div>
                    <div class="stat-label">Resolved</div>
                </div>
            </div>

            <!-- Action Buttons -->
            <div class="d-flex justify-content-between align-items-center mb-4">
                <h2 style="color: #ffffff !important; margin: 0;">User Feedbacks</h2>
                <div>
                    <button type="button" class="btn-success me-2" id="exportBtn">
                        <i class="fas fa-download me-2"></i>Export CSV
                    </button>
                    <button type="button" class="btn-warning me-2" id="markAllReviewedBtn">
                        <i class="fas fa-check-double me-2"></i>Mark All Reviewed
                    </button>
                    <button type="button" class="btn-primary" id="refreshBtn">
                        <i class="fas fa-sync-alt me-2"></i>Refresh
                    </button>
                </div>
            </div>

            <!-- Filters -->
            <div class="filter-card">
                <h5 class="mb-3" style="color: #ffffff !important;"><i class="fas fa-filter me-2"></i>Filter Feedbacks</h5>
                <div class="filter-group">
                    <div class="form-group search-box">
                        <label class="form-label">Search Feedbacks</label>
                        <div class="position-relative">
                            <i class="fas fa-search search-icon"></i>
                            <input type="text" class="form-control search-input" id="searchFeedbacks" placeholder="Search by user, message, or subject...">
                        </div>
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label">Status</label>
                        <select class="form-control" id="statusFilter">
                            <option value="all">All Status</option>
                            <option value="Pending">Pending</option>
                            <option value="Reviewed">Reviewed</option>
                            <option value="Resolved">Resolved</option>
                            <option value="Closed">Closed</option>
                        </select>
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label">Rating</label>
                        <select class="form-control" id="ratingFilter">
                            <option value="all">All Ratings</option>
                            <option value="5">5 Stars</option>
                            <option value="4">4 Stars</option>
                            <option value="3">3 Stars</option>
                            <option value="2">2 Stars</option>
                            <option value="1">1 Star</option>
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
                    Showing 0 feedbacks
                </div>
            </div>

            <!-- Loading Spinner -->
            <div class="loading-spinner" id="loadingSpinner">
                <div class="spinner"></div>
                <p style="color: rgba(255, 255, 255, 0.7); margin-top: 1rem;">Loading feedbacks...</p>
            </div>

            <!-- Grid View -->
            <div id="gridView">
                <div class="feedbacks-grid" id="feedbacksGrid">
                    <!-- Grid content will be populated by JavaScript -->
                </div>
            </div>

            <!-- Table View -->
            <div id="tableView" style="display: none;">
                <div class="table-responsive">
                    <table class="feedbacks-table" id="feedbacksTable">
                        <thead>
                            <tr>
                                <th>Feedback ID</th>
                                <th>User</th>
                                <th>Subject</th>
                                <th>Rating</th>
                                <th>Status</th>
                                <th>Submitted</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody id="feedbacksTableBody">
                            <!-- Table content will be populated by JavaScript -->
                        </tbody>
                    </table>
                </div>
            </div>
            
            <!-- Empty State -->
            <div id="feedbacksEmptyState" class="empty-state" style="display: none;">
                <div class="empty-state-icon">
                    <i class="fas fa-comments"></i>
                </div>
                <h3 class="empty-state-title">No Feedbacks Found</h3>
                <p class="empty-state-description">No feedbacks match the current search criteria.</p>
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

        <!-- Feedback Details Modal -->
        <div class="modal-overlay" id="feedbackModal">
            <div class="modal-content">
                <div class="modal-header">
                    <h3 class="modal-title">Feedback Details</h3>
                    <button type="button" class="close-modal">&times;</button>
                </div>
                <div class="modal-body">
                    <div class="feedback-details-container">
                        <div class="info-grid">
                            <div class="info-item">
                                <label>Feedback ID:</label>
                                <span id="modalFeedbackId">-</span>
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
                                <label>Rating:</label>
                                <span id="modalRating">-</span>
                            </div>
                            <div class="info-item">
                                <label>Submitted:</label>
                                <span id="modalSubmittedDate">-</span>
                            </div>
                            <div class="info-item">
                                <label>Category:</label>
                                <span id="modalCategory">-</span>
                            </div>
                            <div class="info-item full-width">
                                <label>Subject:</label>
                                <span id="modalSubject">-</span>
                            </div>
                            <div class="info-item full-width">
                                <label>Message:</label>
                                <div class="message-box" id="modalMessage">-</div>
                            </div>
                        </div>
                        
                        <!-- Admin Reply Section -->
                        <div class="reply-section">
                            <h4 style="color: #ffffff !important; margin-bottom: 1rem;">Admin Response</h4>
                            <div class="form-group">
                                <label class="form-label">Your Response</label>
                                <textarea class="form-control" id="adminReply" rows="4" placeholder="Type your response here..."></textarea>
                            </div>
                            <div class="form-group">
                                <label class="form-label">Update Status</label>
                                <select class="form-control" id="updateStatus">
                                    <option value="Pending">Pending</option>
                                    <option value="Reviewed">Reviewed</option>
                                    <option value="Resolved">Resolved</option>
                                    <option value="Closed">Closed</option>
                                </select>
                            </div>
                        </div>
                        
                        <!-- Previous Replies -->
                        <div id="previousReplies" style="display: none;">
                            <h4 style="color: #ffffff !important; margin-bottom: 1rem;">Previous Responses</h4>
                            <div class="reply-box admin-reply" id="previousReplyContent">
                                <!-- Previous replies will be shown here -->
                            </div>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn-action" id="closeModalBtn">Close</button>
                    <button type="button" class="btn-action btn-delete" id="deleteFeedbackBtn">Delete</button>
                    <button type="button" class="btn-primary" id="saveResponseBtn">Save Response</button>
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
                        <p>You are about to delete feedback: <strong id="deleteFeedbackId">-</strong></p>
                        <p class="text-muted">This action cannot be undone.</p>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn-action" id="cancelDeleteBtn" style="flex: 1;">Cancel</button>
                    <button type="button" class="btn-danger" id="confirmDeleteBtn" style="flex: 1;">Delete Feedback</button>
                </div>
            </div>
        </div>
    </div>

    <asp:Button ID="btnLoadFeedbacks" runat="server" OnClick="btnLoadFeedbacks_Click" Style="display: none;" />
    <asp:HiddenField ID="hfFeedbacksData" runat="server" />
    <asp:HiddenField ID="hfStatsData" runat="server" />
</asp:Content>