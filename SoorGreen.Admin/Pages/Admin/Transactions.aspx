<%@ Page Title="Transactions" Language="C#" MasterPageFile="~/Pages/Admin/Site.master" AutoEventWireup="true" CodeFile="Transactions.aspx.cs" Inherits="SoorGreen.Admin.Admin.Transactions" %>
<%@ Register Assembly="System.Web.Extensions, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35" Namespace="System.Web.UI" TagPrefix="asp" %>
<%@ Import Namespace="System.Web.Optimization" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <%: Styles.Render("~/Content/admintransactions") %>
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="ScriptsContent" runat="server">
    <%: Scripts.Render("~/bundles/admintransactions") %>
</asp:Content>
<asp:Content ID="PageTitle" ContentPlaceHolderID="PageTitle" runat="server">
    Transaction History
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <asp:ScriptManager ID="ScriptManager1" runat="server" EnablePageMethods="true"></asp:ScriptManager>
    
    

    <div class="transactions-container">
        <!-- Statistics Cards -->
        <div class="stats-cards">
            <div class="stat-card">
                <div class="stat-value" id="totalTransactions">0</div>
                <div class="stat-label">Total Transactions</div>
            </div>
            <div class="stat-card">
                <div class="stat-value" id="totalCredits">0</div>
                <div class="stat-label">Total Credits Issued</div>
            </div>
            <div class="stat-card">
                <div class="stat-value" id="avgTransaction">0</div>
                <div class="stat-label">Avg Transaction Value</div>
            </div>
            <div class="stat-card">
                <div class="stat-value" id="todayTransactions">0</div>
                <div class="stat-label">Today's Transactions</div>
            </div>
        </div>

        <!-- Action Buttons -->
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h2 style="color: #ffffff !important; margin: 0;">Transaction History</h2>
            <div>
                <button type="button" class="btn-export me-2" id="exportBtn">
                    <i class="fas fa-download me-2"></i>Export CSV
                </button>
                <button type="button" class="btn-primary" id="refreshBtn">
                    <i class="fas fa-sync-alt me-2"></i>Refresh
                </button>
            </div>
        </div>

        <!-- Filters -->
        <div class="filter-card" style="background: rgba(255, 255, 255, 0.05); backdrop-filter: blur(20px); border: 1px solid rgba(255, 255, 255, 0.1); border-radius: 15px; padding: 1.5rem; margin-bottom: 2rem;">
            <h5 class="mb-3" style="color: #ffffff !important;"><i class="fas fa-filter me-2"></i>Filter Transactions</h5>
            <div class="filter-group">
                <div class="form-group search-box">
                    <label class="form-label">Search</label>
                    <div class="position-relative">
                        <i class="fas fa-search search-icon"></i>
                        <input type="text" class="form-control search-input" id="searchTransactions" placeholder="Search by user, reference, or type...">
                    </div>
                </div>
                
                <div class="form-group">
                    <label class="form-label">Transaction Type</label>
                    <select class="form-control" id="typeFilter">
                        <option value="all">All Types</option>
                        <option value="recycling">Recycling</option>
                        <option value="bonus">Bonus</option>
                        <option value="redemption">Redemption</option>
                        <option value="adjustment">Adjustment</option>
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
            <p style="color: rgba(255, 255, 255, 0.7); margin-top: 1rem;">Loading transactions...</p>
        </div>

        <!-- Transactions Table -->
        <div class="table-responsive">
            <table class="transactions-table" id="transactionsTable">
                <thead>
                    <tr>
                        <th>Transaction ID</th>
                        <th>User</th>
                        <th>Amount</th>
                        <th>Type</th>
                        <th>Reference</th>
                        <th>Date</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody id="transactionsTableBody">
                    <!-- Transaction rows will be loaded here -->
                </tbody>
            </table>
        </div>
        
        <!-- Empty State -->
        <div id="transactionsEmptyState" class="empty-state" style="display: none;">
            <div class="empty-state-icon">
                <i class="fas fa-coins"></i>
            </div>
            <h3 class="empty-state-title">No Transactions Found</h3>
            <p class="empty-state-description">No transactions match the current search criteria.</p>
            <button type="button" class="btn-primary" id="clearFiltersBtn">
                <i class="fas fa-times me-2"></i>Clear Filters
            </button>
        </div>

        <div class="pagination-container">
            <div class="page-info" id="paginationInfo">
                Showing 0 transactions
            </div>
            <nav>
                <ul class="pagination mb-0" id="pagination">
                    <!-- Pagination will be generated here -->
                </ul>
            </nav>
        </div>
    </div>

    <!-- Transaction Details Modal -->
    <div class="modal-overlay" id="transactionModal" style="display: none;">
        <div class="modal-content" style="max-width: 600px;">
            <div class="modal-header">
                <h3 class="modal-title">Transaction Details</h3>
                <button type="button" class="close-modal">&times;</button>
            </div>
            <div class="modal-body">
                <div class="info-grid">
                    <div class="info-item">
                        <label>Transaction ID:</label>
                        <span id="modalTransactionId">-</span>
                    </div>
                    <div class="info-item">
                        <label>Type:</label>
                        <span id="modalType">-</span>
                    </div>
                    <div class="info-item">
                        <label>User:</label>
                        <div class="user-info">
                            <div class="user-avatar" id="modalUserAvatar">U</div>
                            <span id="modalUserName">-</span>
                        </div>
                    </div>
                    <div class="info-item">
                        <label>Phone:</label>
                        <span id="modalUserPhone">-</span>
                    </div>
                    <div class="info-item">
                        <label>Amount:</label>
                        <span id="modalAmount">-</span>
                    </div>
                    <div class="info-item">
                        <label>Reference:</label>
                        <span id="modalReference">-</span>
                    </div>
                    <div class="info-item">
                        <label>Date:</label>
                        <span id="modalDate">-</span>
                    </div>
                    <div class="info-item full-width">
                        <label>Notes:</label>
                        <span id="modalNotes">-</span>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-action" id="closeModalBtn">Close</button>
            </div>
        </div>
    </div>

    <asp:Button ID="btnLoadTransactions" runat="server" OnClick="btnLoadTransactions_Click" Style="display: none;" />
    <asp:HiddenField ID="hfTransactionsData" runat="server" />
    <asp:HiddenField ID="hfStatsData" runat="server" />
</asp:Content>