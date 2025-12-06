<%@ Page Title="Redemption History" Language="C#" MasterPageFile="~/Pages/Citizen/Site.Master" AutoEventWireup="true" CodeFile="RedemptionHistory.aspx.cs" Inherits="SoorGreen.Citizen.RedemptionHistory" %>
<%@ Import Namespace="System.Web.Optimization" %>
<asp:Content ID="Content3" ContentPlaceHolderID="HeadContent" runat="server">
    <link href='<%= ResolveUrl("~/Content/Pages/Citizen/citizenredemptionhistory.css") %>' rel="stylesheet" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
</asp:Content>

<asp:Content ID="Content4" ContentPlaceHolderID="ScriptsContent" runat="server">
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src='<%= ResolveUrl("~/Scripts/Pages/Citizen/citizenredemptionhistory.js") %>' defer></script>
</asp:Content>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Redemption History - SoorGreen Citizen
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <br />
    <br />
    <br />
    <!-- Hidden fields to store server data -->
    <asp:HiddenField ID="hfRedemptionData" runat="server" ClientIDMode="Static" />
    <asp:HiddenField ID="hfStatsData" runat="server" ClientIDMode="Static" />
    <asp:HiddenField ID="hfUserId" runat="server" ClientIDMode="Static" />

    <!-- Loading Overlay -->
    <div class="loading-overlay" id="loadingOverlay">
        <div class="loading-spinner">
            <div class="spinner"></div>
            <p>Loading redemption history...</p>
        </div>
    </div>

    <div class="history-container">
        <div class="page-header">
            <div class="header-content">
                <h1 class="page-title">
                    <i class="fas fa-history"></i> Redemption History
                </h1>
                <p class="page-subtitle">Track your reward claims and redemption status</p>
            </div>
            <div class="header-actions">
                <button type="button" class="btn-outline" onclick="refreshData()">
                    <i class="fas fa-sync-alt"></i> Refresh
                </button>
                <asp:Button ID="btnBrowseRewards" runat="server" Text="Browse Rewards" CssClass="btn-primary" OnClientClick="redirectToRewards(); return false;" />
                <asp:Button ID="btnExport" runat="server" Text="Export CSV" CssClass="btn-primary" OnClientClick="exportHistory(); return false;" />
            </div>
        </div>

        <!-- Stats Cards -->
        <div class="stats-section">
            <div class="stats-cards">
                <div class="stat-card">
                    <div class="stat-icon">
                        <i class="fas fa-gift"></i>
                    </div>
                    <div class="stat-content">
                        <div class="stat-value" id="totalRedemptions">0</div>
                        <div class="stat-label">Total Redemptions</div>
                    </div>
                </div>
                
                <div class="stat-card">
                    <div class="stat-icon">
                        <i class="fas fa-star"></i>
                    </div>
                    <div class="stat-content">
                        <div class="stat-value" id="totalXPSpent">0</div>
                        <div class="stat-label">Total XP Spent</div>
                    </div>
                </div>
                
                <div class="stat-card">
                    <div class="stat-icon">
                        <i class="fas fa-check-circle"></i>
                    </div>
                    <div class="stat-content">
                        <div class="stat-value" id="activeRedemptions">0</div>
                        <div class="stat-label">Completed</div>
                    </div>
                </div>
                
                <div class="stat-card">
                    <div class="stat-icon">
                        <i class="fas fa-clock"></i>
                    </div>
                    <div class="stat-content">
                        <div class="stat-value" id="pendingRedemptions">0</div>
                        <div class="stat-label">Pending</div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Filters Section -->
        <div class="filters-section">
            <div class="filters-header">
                <h3 class="filters-title">
                    <i class="fas fa-filter"></i> Filters
                </h3>
            </div>
            <div class="filter-controls">
                <div class="filter-group">
                    <div class="filter-item">
                        <label class="filter-label">Status</label>
                        <select class="filter-select" id="statusFilter">
                            <option value="all">All Status</option>
                            <option value="Completed">Completed</option>
                            <option value="Pending">Pending</option>
                            <option value="Expired">Expired</option>
                            <option value="Cancelled">Cancelled</option>
                        </select>
                    </div>

                    <div class="filter-item">
                        <label class="filter-label">Date Range</label>
                        <div class="date-range">
                            <input type="date" class="date-input" id="dateFrom" placeholder="From">
                            <span class="date-separator">to</span>
                            <input type="date" class="date-input" id="dateTo" placeholder="To">
                        </div>
                    </div>

                    <div class="filter-item">
                        <label class="filter-label">Search</label>
                        <div class="search-box">
                            <input type="text" class="search-input" id="searchInput" placeholder="Search rewards...">
                            <button type="button" class="search-btn" onclick="searchRedemptions()">
                                <i class="fas fa-search"></i>
                            </button>
                        </div>
                    </div>

                    <div class="filter-item filter-actions">
                        <button type="button" class="btn-apply" onclick="applyFilters()">
                            <i class="fas fa-check"></i> Apply Filters
                        </button>
                        <button type="button" class="btn-clear" onclick="clearFilters()">
                            <i class="fas fa-times"></i> Clear
                        </button>
                    </div>
                </div>
            </div>
        </div>

        <!-- Results Info -->
        <div class="results-info" id="resultsInfo">
            <span id="resultsCount">0</span> redemptions found
        </div>

        <!-- History Table -->
        <div class="table-container">
            <table class="history-table">
                <thead>
                    <tr>
                        <th>Reward Title</th>
                        <th>Description</th>
                        <th>XP Cost</th>
                        <th>Method</th>
                        <th>Requested</th>
                        <th>Status</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody id="historyTableBody">
                    <!-- Data will be populated by JavaScript -->
                </tbody>
            </table>
        </div>

        <!-- Empty State -->
        <div id="emptyState" class="empty-state" style="display: none;">
            <div class="empty-state-icon">
                <i class="fas fa-history"></i>
            </div>
            <h3 class="empty-state-title">No Redemption History</h3>
            <p class="empty-state-description">You haven't claimed any rewards yet.</p>
            <button type="button" class="btn-primary" onclick="redirectToRewards()">
                <i class="fas fa-gift"></i> Browse Rewards
            </button>
        </div>

        <!-- Pagination -->
        <div class="pagination-container" id="paginationContainer" style="display: none;">
            <div class="pagination">
                <button class="page-btn" onclick="changePage(-1)" id="prevPageBtn" disabled>
                    <i class="fas fa-chevron-left"></i>
                </button>
                <div class="page-numbers" id="pageNumbers">
                    <span class="page-number active">1</span>
                </div>
                <button class="page-btn" onclick="changePage(1)" id="nextPageBtn" disabled>
                    <i class="fas fa-chevron-right"></i>
                </button>
            </div>
        </div>
    </div>

    <!-- Redemption Details Modal -->
    <div class="modal-overlay" id="redemptionDetailsModal" style="display: none;">
        <div class="modal-content">
            <div class="modal-header">
                <h2><i class="fas fa-info-circle"></i> Redemption Details</h2>
                <button class="btn-close-modal" onclick="closeDetailsModal()">
                    <i class="fas fa-times"></i>
                </button>
            </div>
            <div class="modal-body" id="redemptionDetailsContent">
                <!-- Details will be populated by JavaScript -->
            </div>
            <div class="modal-actions">
                <button class="btn btn-outline" onclick="closeDetailsModal()">
                    <i class="fas fa-times"></i> Close
                </button>
            </div>
        </div>
    </div>
</asp:Content>