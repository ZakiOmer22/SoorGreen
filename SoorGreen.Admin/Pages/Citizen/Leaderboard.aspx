<%@ Page Title="Leaderboard" Language="C#" MasterPageFile="~/Pages/Citizen/Site.Master" AutoEventWireup="true" CodeFile="Leaderboard.aspx.cs" Inherits="SoorGreen.Citizen.Leaderboard" %>
<%@ Import Namespace="System.Web.Optimization" %>
<asp:Content ID="Content3" ContentPlaceHolderID="HeadContent" runat="server">
    <%: Styles.Render("~/Content/citizenleaderboard") %>
</asp:Content>
<asp:Content ID="Content4" ContentPlaceHolderID="ScriptsContent" runat="server">
    <%: Scripts.Render("~/bundles/citizenleaderboard") %>
</asp:Content>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Leaderboard - SoorGreen Citizen
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    

    <!-- Hidden fields to store server data -->
    <asp:HiddenField ID="hfLeaderboardData" runat="server" Value="[]" />
    <asp:HiddenField ID="hfStatsData" runat="server" Value="{}" />
    <asp:HiddenField ID="hfCurrentTab" runat="server" Value="global" />
    <asp:HiddenField ID="hfCurrentPeriod" runat="server" Value="all" />

    <div class="leaderboard-container">
        <br />
        <br />
        <br />

        <div class="stats-cards">
            <div class="stat-card">
                <div class="stat-value" id="totalUsers">0</div>
                <div class="stat-label">Active Users</div>
            </div>
            <div class="stat-card">
                <div class="stat-value" id="totalXP">0</div>
                <div class="stat-label">Total XP Earned</div>
            </div>
            <div class="stat-card">
                <div class="stat-value" id="totalPickups">0</div>
                <div class="stat-label">Waste Pickups</div>
            </div>
            <div class="stat-card">
                <div class="stat-value" id="co2Reduced">0T</div>
                <div class="stat-label">CO₂ Reduced</div>
            </div>
        </div>

        <div class="section-header">
            <h1 class="section-title">Eco Leaderboard</h1>
            <p class="section-description">Compete with fellow eco-warriors and climb the ranks</p>
        </div>

        <div class="filters-section">
            <div class="filter-group">
                <div class="form-group">
                    <label class="form-label">Leaderboard Type</label>
                    <select class="form-control" id="tabFilter" style="min-width: 150px;">
                        <option value="global">Global Leaderboard</option>
                        <option value="monthly">Monthly Champions</option>
                        <option value="achievements">Top Achievers</option>
                        <option value="friends">Friends Ranking</option>
                    </select>
                </div>

                <div class="form-group">
                    <label class="form-label">Time Period</label>
                    <select class="form-control" id="periodFilter" style="min-width: 150px;">
                        <option value="all">All Time</option>
                        <option value="month">This Month</option>
                        <option value="week">This Week</option>
                        <option value="today">Today</option>
                    </select>
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
                Showing 0 users
            </div>
            <div>
                <asp:Button ID="btnRefresh" runat="server" Text="Refresh" CssClass="btn-primary" OnClick="btnRefresh_Click" />
            </div>
        </div>

        <div class="table-responsive">
            <table class="leaderboard-table">
                <thead>
                    <tr>
                        <th style="width: 80px;">Rank</th>
                        <th>User</th>
                        <th>Level</th>
                        <th>XP</th>
                        <th>Pickups</th>
                        <th>Achievements</th>
                        <th>CO₂ Reduced</th>
                    </tr>
                </thead>
                <tbody id="leaderboardTableBody">
                    <!-- Data will be populated by JavaScript -->
                </tbody>
            </table>
        </div>

        <div id="emptyState" class="empty-state" style="display: none;">
            <div class="empty-state-icon">
                <i class="fas fa-trophy"></i>
            </div>
            <h3 class="empty-state-title">No Leaderboard Data</h3>
            <p class="empty-state-description">Start earning XP to appear on the leaderboard!</p>
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