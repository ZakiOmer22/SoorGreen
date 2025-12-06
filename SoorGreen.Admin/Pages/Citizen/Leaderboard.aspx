<%@ Page Title="Leaderboard" Language="C#" MasterPageFile="~/Pages/Citizen/Site.Master"
    AutoEventWireup="true" CodeFile="Leaderboard.aspx.cs" Inherits="SoorGreen.Citizen.Leaderboard" %>

<asp:Content ID="Content3" ContentPlaceHolderID="HeadContent" runat="server">
    <link href='<%= ResolveUrl("~/Content/Pages/Citizen/citizenleaderboard.css") %>' rel="stylesheet" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
</asp:Content>

<asp:Content ID="Content4" ContentPlaceHolderID="ScriptsContent" runat="server">
    <script src='<%= ResolveUrl("~/Scripts/Pages/Citizen/citizenleaderboard.js") %>'></script>
</asp:Content>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Leaderboard - SoorGreen Citizen
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <br />
    <br />
    <br />
    <br />
    <asp:HiddenField ID="hfLeaderboardData" runat="server" Value="[]" />
    <asp:HiddenField ID="hfStatsData" runat="server" Value="{}" />
    <asp:HiddenField ID="hfAchievementsData" runat="server" Value="[]" />
    <asp:HiddenField ID="hfCurrentTab" runat="server" Value="global" />
    <asp:HiddenField ID="hfCurrentPeriod" runat="server" Value="all" />
    <asp:Literal ID="litLeaderboardData" runat="server"></asp:Literal>


    <div class="leaderboard-container">
        <!-- Header with Breadcrumbs -->
        <div class="page-header-wrapper">
            <nav class="breadcrumb">
                <a href="Dashboard.aspx"><i class="fas fa-home"></i>Dashboard</a>
                <i class="fas fa-chevron-right"></i>
                <span class="active">Leaderboard</span>
            </nav>

            <div class="page-header">
                <div class="header-text">
                    <h1 class="page-title">
                        <i class="fas fa-trophy"></i>
                         Leaderboard
                    </h1>
                    <p class="page-subtitle">Compete with fellow eco-warriors and climb the ranks</p>
                </div>

                <div class="header-action">
                    <div class="user-ranking">
                        <div class="rank-badge">
                            <i class="fas fa-crown"></i>
                            <div class="rank-info">
                                <span class="rank-label">Your Rank</span>
                                <span class="rank-value" id="userRank">#--</span>
                            </div>
                        </div>
                        <button class="btn-help" onclick="showLeaderboardHelp()">
                            <i class="fas fa-question-circle"></i>
                        </button>
                    </div>
                </div>
            </div>
        </div>

        <!-- Stats Overview Cards -->
        <div class="stats-overview">
            <div class="stat-card">
                <div class="stat-icon">
                    <i class="fas fa-users"></i>
                </div>
                <div class="stat-content">
                    <div class="stat-value" id="totalParticipants">0</div>
                    <div class="stat-label">Active Eco-Warriors</div>
                    <div class="stat-change" id="participantsChange">
                        <i class="fas fa-arrow-up"></i><span>0% this month</span>
                    </div>
                </div>
            </div>

            <div class="stat-card">
                <div class="stat-icon">
                    <i class="fas fa-bolt"></i>
                </div>
                <div class="stat-content">
                    <div class="stat-value" id="totalXP">0 XP</div>
                    <div class="stat-label">Total XP Earned</div>
                    <div class="stat-change" id="xpChange">
                        <i class="fas fa-arrow-up"></i><span>0% increase</span>
                    </div>
                </div>
            </div>

            <div class="stat-card">
                <div class="stat-icon">
                    <i class="fas fa-recycle"></i>
                </div>
                <div class="stat-content">
                    <div class="stat-value" id="totalCollections">0</div>
                    <div class="stat-label">Waste Collections</div>
                    <div class="stat-change" id="collectionsChange">
                        <i class="fas fa-arrow-up"></i><span>0% growth</span>
                    </div>
                </div>
            </div>

            <div class="stat-card">
                <div class="stat-icon">
                    <i class="fas fa-leaf"></i>
                </div>
                <div class="stat-content">
                    <div class="stat-value" id="co2Reduced">0 kg</div>
                    <div class="stat-label">CO₂ Reduced</div>
                    <div class="stat-change" id="co2Change">
                        <i class="fas fa-arrow-up"></i><span>Equivalent to 0 trees</span>
                    </div>
                </div>
            </div>
        </div>

        <!-- Leaderboard Filters -->
        <div class="leaderboard-filters">
            <div class="filter-tabs">
                <button class="filter-tab active" data-tab="global" onclick="switchTab('global')">
                    <i class="fas fa-globe"></i>
                    <span>Global</span>
                </button>
                <button class="filter-tab" data-tab="monthly" onclick="switchTab('monthly')">
                    <i class="fas fa-calendar-alt"></i>
                    <span>Monthly</span>
                </button>
                <button class="filter-tab" data-tab="friends" onclick="switchTab('friends')">
                    <i class="fas fa-user-friends"></i>
                    <span>Friends</span>
                </button>
                <button class="filter-tab" data-tab="local" onclick="switchTab('local')">
                    <i class="fas fa-map-marker-alt"></i>
                    <span>Local</span>
                </button>
            </div>

            <div class="filter-controls">
                <div class="filter-group">
                    <label><i class="fas fa-clock"></i>Time Period</label>
                    <select class="filter-select" id="periodFilter" onchange="applyFilters()">
                        <option value="all">All Time</option>
                        <option value="month">This Month</option>
                        <option value="week">This Week</option>
                        <option value="today">Today</option>
                    </select>
                </div>

                <div class="filter-group">
                    <label><i class="fas fa-filter"></i>Category</label>
                    <select class="filter-select" id="categoryFilter" onchange="applyFilters()">
                        <option value="all">All Categories</option>
                        <option value="xp">By XP Points</option>
                        <option value="collections">By Collections</option>
                        <option value="co2">By CO₂ Reduction</option>
                    </select>
                </div>

                <div class="filter-actions">
                    <button class="btn-refresh" onclick="refreshLeaderboard()">
                        <i class="fas fa-sync-alt"></i>
                        Refresh
                    </button>
                    <button class="btn-export" onclick="exportLeaderboard()">
                        <i class="fas fa-download"></i>
                        Export
                    </button>
                </div>
            </div>
        </div>

        <!-- Leaderboard Content -->
        <div class="leaderboard-content">
            <!-- Current User Rank Highlight -->
            <div class="current-user-highlight" id="currentUserCard">
                <div class="user-rank-badge">
                    <span class="rank-number">#--</span>
                    <div class="rank-medal">
                        <i class="fas fa-user"></i>
                    </div>
                </div>
                <div class="user-info">
                    <div class="user-avatar">
                        <i class="fas fa-user-circle"></i>
                    </div>
                    <div class="user-details">
                        <h4>You</h4>
                        <div class="user-stats">
                            <span class="stat-item">
                                <i class="fas fa-bolt"></i>
                                <span id="userXP">0 XP</span>
                            </span>
                            <span class="stat-item">
                                <i class="fas fa-recycle"></i>
                                <span id="userCollections">0 collections</span>
                            </span>
                            <span class="stat-item">
                                <i class="fas fa-leaf"></i>
                                <span id="userCO2">0 kg CO₂</span>
                            </span>
                        </div>
                    </div>
                </div>
                <div class="user-level">
                    <div class="level-badge">
                        Level <span id="userLevel">1</span>
                    </div>
                    <div class="progress-bar">
                        <div class="progress-fill" id="userProgress" style="width: 0%"></div>
                    </div>
                    <div class="level-text">
                        <span id="currentXP">0</span>/<span id="nextLevelXP">1000</span> XP
                    </div>
                </div>
            </div>

            <!-- Leaderboard Table -->
            <div class="leaderboard-table-container">
                <table class="leaderboard-table">
                    <thead>
                        <tr>
                            <th class="rank-column">Rank</th>
                            <th class="user-column">User</th>
                            <th class="level-column">Level</th>
                            <th class="xp-column">XP</th>
                            <th class="collections-column">Collections</th>
                            <th class="co2-column">CO₂ Reduced</th>
                            <th class="trend-column">Trend</th>
                        </tr>
                    </thead>
                    <tbody id="leaderboardTableBody">
                        <!-- Dynamic content will be inserted here -->
                    </tbody>
                </table>

                <!-- Loading State -->
                <div class="loading-state" id="loadingState">
                    <div class="loading-spinner">
                        <i class="fas fa-spinner fa-spin"></i>
                    </div>
                    <p>Loading leaderboard data...</p>
                </div>

                <!-- Empty State -->
                <div class="empty-state" id="emptyState" style="display: none;">
                    <div class="empty-icon">
                        <i class="fas fa-trophy"></i>
                    </div>
                    <h3>No Leaderboard Data</h3>
                    <p>Start earning XP by reporting waste to appear on the leaderboard!</p>
                    <button class="btn-start-earning" onclick="window.location.href='ReportWaste.aspx'">
                        <i class="fas fa-plus"></i>Report Waste
                    </button>
                </div>
            </div>

            <!-- Pagination -->
            <div class="leaderboard-pagination" id="paginationContainer" style="display: none;">
                <button class="page-btn prev" onclick="changePage(-1)">
                    <i class="fas fa-chevron-left"></i>
                    Previous
                </button>

                <div class="page-numbers">
                    <!-- Page numbers will be generated dynamically -->
                </div>

                <button class="page-btn next" onclick="changePage(1)">
                    Next
                    <i class="fas fa-chevron-right"></i>
                </button>
            </div>
        </div>

        <!-- Achievement Badges Section -->
        <div class="achievements-section">
            <div class="section-header">
                <h2><i class="fas fa-medal"></i>Top Achievements This Month</h2>
                <p>Recognizing outstanding contributions to environmental sustainability</p>
            </div>

            <div class="achievements-grid" id="achievementsGrid">
                <!-- Achievements will be loaded dynamically -->
            </div>
        </div>

        <!-- Tips Section -->
        <div class="tips-section">
            <div class="tips-header">
                <h3><i class="fas fa-lightbulb"></i>Climb the Leaderboard Faster!</h3>
            </div>
            <div class="tips-grid">
                <div class="tip-card">
                    <div class="tip-icon">
                        <i class="fas fa-weight-hanging"></i>
                    </div>
                    <div class="tip-content">
                        <h4>Report Heavier Waste</h4>
                        <p>Report larger quantities to earn more XP per collection</p>
                    </div>
                </div>

                <div class="tip-card">
                    <div class="tip-icon">
                        <i class="fas fa-layer-group"></i>
                    </div>
                    <div class="tip-content">
                        <h4>Mix Waste Types</h4>
                        <p>Different waste categories have different XP multipliers</p>
                    </div>
                </div>

                <div class="tip-card">
                    <div class="tip-icon">
                        <i class="fas fa-calendar-check"></i>
                    </div>
                    <div class="tip-content">
                        <h4>Consistent Reporting</h4>
                        <p>Regular contributions earn bonus streak multipliers</p>
                    </div>
                </div>

                <div class="tip-card">
                    <div class="tip-icon">
                        <i class="fas fa-user-plus"></i>
                    </div>
                    <div class="tip-content">
                        <h4>Refer Friends</h4>
                        <p>Earn referral bonuses when friends join and report waste</p>
                    </div>
                </div>
            </div>
        </div>

        <!-- Help Panel -->
        <div class="help-panel" id="helpPanel">
            <div class="help-header">
                <h3><i class="fas fa-question-circle"></i>Leaderboard Help</h3>
                <button class="btn-close-help" onclick="hideHelp()">
                    <i class="fas fa-times"></i>
                </button>
            </div>
            <div class="help-content">
                <div class="help-item">
                    <h4><i class="fas fa-bolt"></i>XP Points Explained</h4>
                    <p>Earn XP points by reporting waste for collection. Different waste types have different XP rates per kilogram.</p>
                </div>
                <div class="help-item">
                    <h4><i class="fas fa-chart-line"></i>Leaderboard Updates</h4>
                    <p>The leaderboard updates in real-time. Your rank changes as you and others earn more XP.</p>
                </div>
                <div class="help-item">
                    <h4><i class="fas fa-trophy"></i>Ranking System</h4>
                    <p>Ranks are based on total XP earned. Special badges are awarded for monthly achievements.</p>
                </div>
                <div class="help-item">
                    <h4><i class="fas fa-leaf"></i>CO₂ Reduction</h4>
                    <p>Each waste collection contributes to CO₂ reduction based on waste type and quantity.</p>
                </div>
            </div>
        </div>
    </div>
</asp:Content>