<%@ Page Title="My Rewards" Language="C#" MasterPageFile="~/Pages/Citizen/Site.Master" 
    AutoEventWireup="true" CodeFile="MyRewards.aspx.cs" Inherits="SoorGreen.Citizen.MyRewards" %>
<%@ Import Namespace="System.Web.Optimization" %>
<asp:Content ID="Content5" ContentPlaceHolderID="HeadContent" runat="server">
    <link href='<%= ResolveUrl("~/Content/Pages/Citizen/citizenmyrewards.css") %>' rel="stylesheet" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
</asp:Content>

<asp:Content ID="Content6" ContentPlaceHolderID="ScriptsContent" runat="server">
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src='<%= ResolveUrl("~/Scripts/Pages/Citizen/citizenmyrewards.js") %>' defer></script>
    <script>
        // Global variables accessible to JavaScript
        var currentUserId = '<%= Session["UserID"] != null ? Session["UserID"].ToString() : "" %>';
        var apiBaseUrl = '<%= ResolveUrl("~/") %>';
    </script>
</asp:Content>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    My Rewards - SoorGreen Citizen
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <br />
    <br />
    <br />
    <!-- Hidden fields for data -->
    <asp:HiddenField ID="HiddenField1" runat="server" ClientIDMode="Static" />
    <asp:HiddenField ID="HiddenField2" runat="server" ClientIDMode="Static" />
    <asp:HiddenField ID="hfRewardsData" runat="server" ClientIDMode="Static" />
    <asp:HiddenField ID="hfAchievementsData" runat="server" ClientIDMode="Static" />
    <asp:HiddenField ID="hfXPHistoryData" runat="server" ClientIDMode="Static" />
    <asp:HiddenField ID="hfUserStats" runat="server" ClientIDMode="Static" />
    <asp:HiddenField ID="hfUserId" runat="server" ClientIDMode="Static" Value='<%# Session["UserID"] %>' />
    
    <!-- Loading Overlay -->
    <div class="loading-overlay" id="loadingOverlay">
        <div class="loading-spinner">
            <div class="spinner"></div>
            <p>Loading your rewards...</p>
        </div>
    </div>

    <div class="rewards-container">
        <!-- Stats Cards with progress bar -->
        <div class="stats-section">
            <div class="stats-cards">
                <div class="stat-card">
                    <div class="stat-icon">
                        <i class="fas fa-star"></i>
                    </div>
                    <div class="stat-content">
                        <div class="stat-value" id="totalXP">0</div>
                        <div class="stat-label">Total XP</div>
                    </div>
                </div>
                
                <div class="stat-card">
                    <div class="stat-icon">
                        <i class="fas fa-trophy"></i>
                    </div>
                    <div class="stat-content">
                        <div class="stat-value" id="currentLevel">1</div>
                        <div class="stat-label">Current Level</div>
                    </div>
                </div>
                
                <div class="stat-card">
                    <div class="stat-icon">
                        <i class="fas fa-gift"></i>
                    </div>
                    <div class="stat-content">
                        <div class="stat-value" id="rewardsClaimed">0</div>
                        <div class="stat-label">Rewards Claimed</div>
                    </div>
                </div>
                
                <div class="stat-card progress-card">
                    <div class="stat-content">
                        <div class="progress-header">
                            <span class="stat-label">Level Progress</span>
                            <span class="progress-percent" id="progressPercent">0%</span>
                        </div>
                        <div class="progress-bar-container">
                            <div class="progress-bar">
                                <div class="progress-fill" id="progressFill" style="width: 0%"></div>
                            </div>
                        </div>
                        <div class="progress-text">
                            <span id="currentXP">0</span> / <span id="nextLevelXP">100</span> XP to Level Up
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Main Header with XP Badge -->
        <div class="page-header">
            <div class="header-text">
                <h1 class="page-title">
                    <i class="fas fa-award"></i> My Rewards
                </h1>
                <p class="page-subtitle">Earn XP and unlock amazing rewards for your eco-friendly actions</p>
            </div>
            <div class="xp-badge">
                <div class="xp-badge-icon">
                    <i class="fas fa-bolt"></i>
                </div>
                <div class="xp-badge-content">
                    <div class="xp-label">Available XP</div>
                    <div class="xp-value" id="userXP">0</div>
                </div>
            </div>
        </div>

        <!-- Tabs Navigation -->
        <div class="tabs-container">
            <div class="tabs">
                <button class="tab active" data-tab="rewards" onclick="switchTab('rewards'); return false;">
                    <i class="fas fa-gift"></i>
                    Available Rewards
                </button>
                <button class="tab" data-tab="achievements" onclick="switchTab('achievements'); return false;">
                    <i class="fas fa-trophy"></i>
                    Achievements
                    <span class="badge" id="achievementsBadge">0</span>
                </button>
                <button class="tab" data-tab="history" onclick="switchTab('history'); return false;">
                    <i class="fas fa-history"></i>
                    XP History
                </button>
            </div>
        </div>

        <!-- Rewards Tab -->
        <div class="tab-content active" id="rewardsTab">
            <div class="section-header">
                <div class="header-content">
                    <h3 class="section-title">
                        <i class="fas fa-crown"></i> Featured Rewards
                    </h3>
                    <p class="section-description">Special rewards with exclusive benefits</p>
                </div>
                <div class="header-actions">
                    <div class="filter-dropdown">
                        <select id="rewardFilter" onchange="filterRewards()">
                            <option value="all">All Rewards</option>
                            <option value="featured">Featured Only</option>
                            <option value="affordable">Can Afford</option>
                        </select>
                    </div>
                </div>
            </div>
            
            <div class="rewards-grid" id="featuredRewardsGrid">
                <div class="skeleton-grid">
                    <div class="skeleton-card"></div>
                    <div class="skeleton-card"></div>
                    <div class="skeleton-card"></div>
                </div>
            </div>

            <div class="section-header">
                <div class="header-content">
                    <h3 class="section-title">
                        <i class="fas fa-gifts"></i> All Rewards
                    </h3>
                    <p class="section-description">Browse all available rewards</p>
                </div>
                <div class="sort-dropdown">
                    <select id="rewardSort" onchange="sortRewards()">
                        <option value="xp-asc">XP: Low to High</option>
                        <option value="xp-desc">XP: High to Low</option>
                        <option value="featured">Featured First</option>
                    </select>
                </div>
            </div>
            
            <div class="rewards-grid" id="regularRewardsGrid">
                <div class="skeleton-grid">
                    <div class="skeleton-card"></div>
                    <div class="skeleton-card"></div>
                    <div class="skeleton-card"></div>
                    <div class="skeleton-card"></div>
                </div>
            </div>
        </div>

        <!-- Achievements Tab -->
        <div class="tab-content" id="achievementsTab" style="display: none;">
            <div class="section-header">
                <div class="header-content">
                    <h3 class="section-title">
                        <i class="fas fa-medal"></i> Your Achievements
                    </h3>
                    <p class="section-description">Complete challenges and earn bonus XP</p>
                </div>
            </div>
            
            <div class="achievements-container">
                <div class="achievements-stats">
                    <div class="achievement-stat">
                        <div class="stat-number" id="achievementsUnlocked">0</div>
                        <div class="stat-label">Unlocked</div>
                    </div>
                    <div class="achievement-stat">
                        <div class="stat-number" id="achievementsInProgress">0</div>
                        <div class="stat-label">In Progress</div>
                    </div>
                    <div class="achievement-stat">
                        <div class="stat-number" id="achievementsTotal">0</div>
                        <div class="stat-label">Total Available</div>
                    </div>
                </div>
                
                <div class="achievements-grid" id="achievementsGrid">
                    <div class="skeleton-grid">
                        <div class="skeleton-card"></div>
                        <div class="skeleton-card"></div>
                        <div class="skeleton-card"></div>
                    </div>
                </div>
            </div>
        </div>

        <!-- History Tab -->
        <div class="tab-content" id="historyTab" style="display: none;">
            <div class="section-header">
                <div class="header-content">
                    <h3 class="section-title">
                        <i class="fas fa-chart-line"></i> XP Transaction History
                    </h3>
                    <p class="section-description">Track your XP earnings and redemptions</p>
                </div>
                <div class="date-filter">
                    <input type="text" id="dateRangeFilter" placeholder="Select date range">
                    <button class="btn-filter" onclick="applyDateFilter()">
                        <i class="fas fa-filter"></i>
                    </button>
                </div>
            </div>
            
            <div class="transaction-history" id="xpHistoryList">
                <div class="skeleton-history">
                    <div class="skeleton-item"></div>
                    <div class="skeleton-item"></div>
                    <div class="skeleton-item"></div>
                    <div class="skeleton-item"></div>
                    <div class="skeleton-item"></div>
                </div>
            </div>
            
            <div class="load-more" id="loadMoreHistory" style="display: none;">
                <button class="btn-load-more" onclick="loadMoreHistory()">
                    <i class="fas fa-redo"></i> Load More
                </button>
            </div>
        </div>
    </div>

    <!-- Claim Confirmation Modal -->
    <div class="modal-overlay" id="claimConfirmationModal" style="display: none;">
        <div class="modal-content">
            <div class="modal-header">
                <h2><i class="fas fa-gift"></i> Claim Reward</h2>
                <button class="btn-close-modal" onclick="closeClaimModal(); return false;">
                    <i class="fas fa-times"></i>
                </button>
            </div>
            <div class="modal-body">
                <div id="claimConfirmationContent">
                    <!-- Will be populated by JavaScript -->
                </div>
                <div class="modal-actions">
                    <button class="btn btn-outline" onclick="closeClaimModal(); return false;">
                        <i class="fas fa-times"></i> Cancel
                    </button>
                    <button class="btn btn-primary" id="confirmClaimBtn" onclick="confirmClaim(); return false;">
                        <i class="fas fa-check"></i> Confirm Claim
                    </button>
                </div>
            </div>
        </div>
    </div>
</asp:Content>