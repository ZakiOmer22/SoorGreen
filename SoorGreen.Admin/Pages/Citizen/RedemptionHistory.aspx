<%@ Page Title="Redemption History" Language="C#" MasterPageFile="~/Pages/Citizen/Site.Master" AutoEventWireup="true" CodeFile="RedemptionHistory.aspx.cs" Inherits="SoorGreen.Citizen.RedemptionHistory" %>
<%@ Import Namespace="System.Web.Optimization" %>
<asp:Content ID="Content3" ContentPlaceHolderID="HeadContent" runat="server">
    <%: Styles.Render("~/Content/citizenredemptionhistory") %>
</asp:Content>
<asp:Content ID="Content4" ContentPlaceHolderID="ScriptsContent" runat="server">
    <%: Scripts.Render("~/bundles/citizenredemptionhistory") %>
</asp:Content>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Redemption History - SoorGreen Citizen
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    
    <!-- Hidden fields to store server data -->
    <asp:HiddenField ID="hfRedemptionData" runat="server" Value="[]" />
    <asp:HiddenField ID="hfStatsData" runat="server" Value="{}" />

    <div class="history-container">
        <br />
        <br />
        <br />

        <div class="stats-cards">
            <div class="stat-card">
                <div class="stat-value" id="totalRedemptions">0</div>
                <div class="stat-label">Total Redemptions</div>
            </div>
            <div class="stat-card">
                <div class="stat-value" id="totalXPSpent">0</div>
                <div class="stat-label">Total XP Spent</div>
            </div>
            <div class="stat-card">
                <div class="stat-value" id="activeRewards">0</div>
                <div class="stat-label">Active Rewards</div>
            </div>
            <div class="stat-card">
                <div class="stat-value" id="savingsAmount">$0</div>
                <div class="stat-label">Total Savings</div>
            </div>
        </div>

        <div class="section-header">
            <h1 class="section-title">Redemption History</h1>
            <p class="section-description">Track your reward claims and redemption status</p>
        </div>

        <div class="filters-section">
            <div class="filter-group">
                <div class="form-group">
                    <label class="form-label">Status</label>
                    <select class="form-control" id="statusFilter" style="min-width: 150px;">
                        <option value="all">All Status</option>
                        <option value="redeemed">Redeemed</option>
                        <option value="pending">Pending</option>
                        <option value="expired">Expired</option>
                        <option value="cancelled">Cancelled</option>
                    </select>
                </div>

                <div class="form-group">
                    <label class="form-label">Reward Type</label>
                    <select class="form-control" id="typeFilter" style="min-width: 150px;">
                        <option value="all">All Types</option>
                        <option value="digital">Digital</option>
                        <option value="physical">Physical</option>
                        <option value="discount">Discount</option>
                    </select>
                </div>

                <div class="form-group">
                    <label class="form-label">Date From</label>
                    <input type="date" class="form-control" id="dateFrom" style="min-width: 150px;">
                </div>

                <div class="form-group">
                    <label class="form-label">Date To</label>
                    <input type="date" class="form-control" id="dateTo" style="min-width: 150px;">
                </div>

                <div class="form-group">
                    <asp:Button ID="btnApplyFilters" runat="server" Text="Apply Filters" CssClass="btn-primary" OnClick="btnApplyFilters_Click" style="margin-top: 24px;" />
                </div>

                <div class="form-group">
                    <button type="button" class="btn-outline-light" onclick="clearFilters()" style="margin-top: 24px;">
                        Clear Filters
                    </button>
                </div>
            </div>
        </div>

        <div class="d-flex justify-content-between align-items-center mb-3">
            <div class="text-muted" id="resultsInfo">
                Showing 0 redemptions
            </div>
            <div>
                <button type="button" class="btn-outline-light me-2" onclick="exportHistory()">
                    Export CSV
                </button>
                <asp:Button ID="btnRefresh" runat="server" Text="Refresh" CssClass="btn-primary" OnClick="btnRefresh_Click" />
            </div>
        </div>

        <div class="table-responsive">
            <table class="history-table">
                <thead>
                    <tr>
                        <th>Reward</th>
                        <th>Type</th>
                        <th>XP Cost</th>
                        <th>Claimed Date</th>
                        <th>Expiry Date</th>
                        <th>Status</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody id="historyTableBody">
                    <!-- Data will be populated by JavaScript -->
                </tbody>
            </table>
        </div>

        <div id="emptyState" class="empty-state" style="display: none;">
            <div class="empty-state-icon">
                <i class="fas fa-history"></i>
            </div>
            <h3 class="empty-state-title">No Redemption History</h3>
            <p class="empty-state-description">You haven't claimed any rewards yet.</p>
            <asp:Button ID="btnBrowseRewards" runat="server" Text="Browse Rewards" CssClass="btn-primary" OnClick="btnBrowseRewards_Click" />
        </div>

        <div class="pagination" id="paginationContainer" style="display: none;">
            <div class="page-item" onclick="changePage(-1)">
                <i class="fas fa-chevron-left"></i>
            </div>
            <div class="page-item active">1</div>
            <div class="page-item">2</div>
            <div class="page-item">3</div>
            <div class="page-item" onclick="changePage(1)">
                <i class="fas fa-chevron-right"></i>
            </div>
        </div>
    </div>

    
</asp:Content>