<%@ Page Title="Rewards" Language="C#" MasterPageFile="~/Pages/Admin/Site.master" AutoEventWireup="true" CodeFile="Rewards.aspx.cs" Inherits="SoorGreen.Admin.Admin.Rewards" %>
<%@ Register Assembly="System.Web.Extensions, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35" Namespace="System.Web.UI" TagPrefix="asp" %>
<%@ Import Namespace="System.Web.Optimization" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <%: Styles.Render("~/Content/adminrewards") %>
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="ScriptsContent" runat="server">
    <%: Scripts.Render("~/bundles/adminrewards") %>
</asp:Content>
<asp:Content ID="PageTitle" ContentPlaceHolderID="PageTitle" runat="server">
    Rewards & Credits Management
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <asp:ScriptManager ID="ScriptManager1" runat="server" EnablePageMethods="true"></asp:ScriptManager>
    

    <div class="rewards-container">
        <!-- Statistics Cards -->
        <div class="stats-cards">
            <div class="stat-card">
                <div class="stat-value" id="totalCredits">0</div>
                <div class="stat-label">Total Credits Issued</div>
            </div>
            <div class="stat-card">
                <div class="stat-value" id="pendingRedemptions">0</div>
                <div class="stat-label">Pending Redemptions</div>
            </div>
            <div class="stat-card">
                <div class="stat-value" id="totalUsers">0</div>
                <div class="stat-label">Active Users</div>
            </div>
            <div class="stat-card">
                <div class="stat-value" id="avgCredits">0</div>
                <div class="stat-label">Avg Credits Per User</div>
            </div>
        </div>

        <!-- Action Buttons -->
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h2 style="color: #ffffff !important; margin: 0;">Rewards & Credits</h2>
            <div>
                <button type="button" class="btn-primary me-2" id="generateReportBtn">
                    <i class="fas fa-chart-bar me-2"></i>Generate Report
                </button>
                <button type="button" class="btn-primary" id="addCreditsBtn">
                    <i class="fas fa-plus me-2"></i>Add Credits
                </button>
            </div>
        </div>

        <!-- Tabs -->
        <div class="tabs">
            <button type="button" class="tab active" data-tab="redemptions">Redemption Requests</button>
            <button type="button" class="tab" data-tab="transactions">Credit Transactions</button>
            <button type="button" class="tab" data-tab="users">User Balances</button>
        </div>

        <!-- Redemptions Tab -->
        <div class="tab-content active" id="redemptionsTab">
            <div class="filter-card" style="background: rgba(255, 255, 255, 0.05); backdrop-filter: blur(20px); border: 1px solid rgba(255, 255, 255, 0.1); border-radius: 15px; padding: 1.5rem; margin-bottom: 2rem;">
                <h5 class="mb-3" style="color: #ffffff !important;"><i class="fas fa-filter me-2"></i>Filter Redemptions</h5>
                <div class="filter-group">
                    <div class="form-group search-box">
                        <label class="form-label">Search Users</label>
                        <div class="position-relative">
                            <i class="fas fa-search search-icon"></i>
                            <input type="text" class="form-control search-input" id="searchRedemptions" placeholder="Search by user name or phone...">
                        </div>
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label">Status</label>
                        <select class="form-control" id="statusFilter">
                            <option value="all">All Status</option>
                            <option value="pending">Pending</option>
                            <option value="approved">Approved</option>
                            <option value="rejected">Rejected</option>
                            <option value="completed">Completed</option>
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

            <div class="table-responsive">
                <table class="rewards-table" id="redemptionsTable">
                    <thead>
                        <tr>
                            <th>Request ID</th>
                            <th>User</th>
                            <th>Amount</th>
                            <th>Method</th>
                            <th>Status</th>
                            <th>Requested</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody id="redemptionsTableBody">
                        <!-- Redemption rows will be loaded here -->
                    </tbody>
                </table>
            </div>
            
            <!-- Empty State for Redemptions -->
            <div id="redemptionsEmptyState" class="empty-state" style="display: none;">
                <div class="empty-state-icon">
                    <i class="fas fa-exchange-alt"></i>
                </div>
                <h3 class="empty-state-title">No Redemption Requests</h3>
                <p class="empty-state-description">There are no redemption requests to display at the moment.</p>
                <button type="button" class="btn-primary" onclick="showAddCreditsModal()">
                    <i class="fas fa-plus me-2"></i>Add Credits to Users
                </button>
            </div>
        </div>

        <!-- Transactions Tab -->
        <div class="tab-content" id="transactionsTab">
            <div class="table-responsive">
                <table class="rewards-table" id="transactionsTable">
                    <thead>
                        <tr>
                            <th>Transaction ID</th>
                            <th>User</th>
                            <th>Amount</th>
                            <th>Type</th>
                            <th>Reference</th>
                            <th>Date</th>
                        </tr>
                    </thead>
                    <tbody id="transactionsTableBody">
                        <!-- Transaction rows will be loaded here -->
                    </tbody>
                </table>
            </div>
            
            <!-- Empty State for Transactions -->
            <div id="transactionsEmptyState" class="empty-state" style="display: none;">
                <div class="empty-state-icon">
                    <i class="fas fa-coins"></i>
                </div>
                <h3 class="empty-state-title">No Credit Transactions</h3>
                <p class="empty-state-description">No credit transactions found.</p>
            </div>
        </div>

        <!-- Users Tab -->
        <div class="tab-content" id="usersTab">
            <div class="table-responsive">
                <table class="rewards-table" id="usersTable">
                    <thead>
                        <tr>
                            <th>User</th>
                            <th>Phone</th>
                            <th>Email</th>
                            <th>Total Credits</th>
                            <th>Joined</th>
                            <th>Status</th>
                        </tr>
                    </thead>
                    <tbody id="usersTableBody">
                        <!-- User rows will be loaded here -->
                    </tbody>
                </table>
            </div>
            
            <!-- Empty State for Users -->
            <div id="usersEmptyState" class="empty-state" style="display: none;">
                <div class="empty-state-icon">
                    <i class="fas fa-users"></i>
                </div>
                <h3 class="empty-state-title">No Users Found</h3>
                <p class="empty-state-description">No users match the current search criteria.</p>
            </div>
        </div>
    </div>

    <!-- View Redemption Details Modal -->
    <div class="modal-overlay" id="viewRedemptionModal">
        <div class="modal-content" style="max-width: 600px;">
            <div class="modal-header">
                <h3 class="modal-title">Redemption Request Details</h3>
                <button type="button" class="close-modal">&times;</button>
            </div>
            <div class="modal-body">
                <div class="info-grid">
                    <div class="info-item">
                        <label>Request ID:</label>
                        <span id="viewRedemptionId">-</span>
                    </div>
                    <div class="info-item">
                        <label>Status:</label>
                        <span id="viewRedemptionStatus">-</span>
                    </div>
                    <div class="info-item">
                        <label>User:</label>
                        <div class="user-info">
                            <div class="user-avatar" id="viewUserAvatar">U</div>
                            <span id="viewUserName">-</span>
                        </div>
                    </div>
                    <div class="info-item">
                        <label>Phone:</label>
                        <span id="viewUserPhone">-</span>
                    </div>
                    <div class="info-item">
                        <label>Amount:</label>
                        <span id="viewRedemptionAmount">-</span>
                    </div>
                    <div class="info-item">
                        <label>Method:</label>
                        <span id="viewRedemptionMethod">-</span>
                    </div>
                    <div class="info-item">
                        <label>Requested:</label>
                        <span id="viewRequestedAt">-</span>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-action btn-approve" id="approveRedemptionBtn">
                    <i class="fas fa-check me-2"></i>Approve
                </button>
                <button type="button" class="btn-action btn-reject" id="rejectRedemptionBtn">
                    <i class="fas fa-times me-2"></i>Reject
                </button>
                <button type="button" class="btn-action" id="closeRedemptionModalBtn">Close</button>
            </div>
        </div>
    </div>

    <!-- Add Credits Modal -->
    <div class="modal-overlay" id="addCreditsModal">
        <div class="modal-content" style="max-width: 500px;">
            <div class="modal-header">
                <h3 class="modal-title">Add Credits to User</h3>
                <button type="button" class="close-modal">&times;</button>
            </div>
            <div class="modal-body">
                <div class="form-group">
                    <label class="form-label">Select User</label>
                    <select class="form-control" id="userSelect">
                        <option value="">-- Select User --</option>
                    </select>
                </div>
                <div class="form-group">
                    <label class="form-label">Amount</label>
                    <input type="number" class="form-control" id="creditAmount" step="0.01" min="0" placeholder="Enter credit amount">
                </div>
                <div class="form-group">
                    <label class="form-label">Reference/Notes</label>
                    <textarea class="form-control" id="creditNotes" rows="3" placeholder="Enter reference or notes..."></textarea>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-action" id="cancelAddCreditsBtn">Cancel</button>
                <button type="button" class="btn-primary" id="confirmAddCreditsBtn">Add Credits</button>
            </div>
        </div>
    </div>

    <!-- Approve/Reject Confirmation Modal -->
    <div class="modal-overlay" id="actionConfirmationModal">
        <div class="modal-content" style="max-width: 500px;">
            <div class="modal-header">
                <h3 class="modal-title" id="actionModalTitle">Confirm Action</h3>
                <button type="button" class="close-modal">&times;</button>
            </div>
            <div class="modal-body">
                <p style="color: rgba(255, 255, 255, 0.8) !important;" id="actionModalMessage">Are you sure you want to perform this action?</p>
                <div class="form-group" id="rejectionReasonContainer" style="display: none;">
                    <label class="form-label">Rejection Reason</label>
                    <textarea class="form-control" id="rejectionReason" rows="3" placeholder="Enter reason for rejection..."></textarea>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-action" id="cancelActionBtn">Cancel</button>
                <button type="button" class="btn-primary" id="confirmActionBtn">Confirm</button>
            </div>
        </div>
    </div>

    <asp:Button ID="btnLoadRewards" runat="server" OnClick="btnLoadRewards_Click" Style="display: none;" />
    <asp:HiddenField ID="hfRedemptionsData" runat="server" />
    <asp:HiddenField ID="hfTransactionsData" runat="server" />
    <asp:HiddenField ID="hfUsersData" runat="server" />
    <asp:HiddenField ID="hfStatsData" runat="server" />
</asp:Content>
