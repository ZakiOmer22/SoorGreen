<%@ Page Title="My Rewards" Language="C#" MasterPageFile="~/Pages/Citizen/Site.Master" AutoEventWireup="true" CodeFile="MyRewards.aspx.cs" Inherits="SoorGreen.Citizen.MyRewards" %>
<%@ Import Namespace="System.Web.Optimization" %>
<asp:Content ID="Content3" ContentPlaceHolderID="HeadContent" runat="server">
    <%: Styles.Render("~/Content/citizenmyrewards") %>
</asp:Content>
<asp:Content ID="Content4" ContentPlaceHolderID="ScriptsContent" runat="server">
    <%: Scripts.Render("~/bundles/citizenmyrewards") %>
</asp:Content>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    My Rewards - SoorGreen Citizen
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
   
    <!-- Hidden field for user stats only -->
    <asp:HiddenField ID="hfUserStats" runat="server" Value="{}" />

    <div class="rewards-container">
        <br />
        <br />
        <br />

        <div class="stats-cards">
            <div class="stat-card">
                <div class="stat-value" id="totalXP">0</div>
                <div class="stat-label">Total XP</div>
            </div>
            <div class="stat-card">
                <div class="stat-value" id="currentLevel">1</div>
                <div class="stat-label">Current Level</div>
            </div>
            <div class="stat-card">
                <div class="stat-value" id="rewardsClaimed">0</div>
                <div class="stat-label">Rewards Claimed</div>
            </div>
            <div class="stat-card">
                <div class="stat-value" id="nextLevelXP">100</div>
                <div class="stat-label">XP to Next Level</div>
            </div>
        </div>

        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h1 class="text-light mb-2">My Rewards</h1>
                <p class="text-muted mb-0">Earn XP and unlock amazing rewards for your eco-friendly actions</p>
            </div>
            <div class="xp-badge">
                <i class="fas fa-star me-2"></i>
                <span id="userXP">0</span> XP Available
            </div>
        </div>

        <div class="tabs">
            <asp:Button ID="btnTabRewards" runat="server" Text="Available Rewards" CssClass="tab active" CommandArgument="rewards" OnClick="btnTab_Click" />
            <asp:Button ID="btnTabAchievements" runat="server" Text="Achievements" CssClass="tab" CommandArgument="achievements" OnClick="btnTab_Click" />
            <asp:Button ID="btnTabHistory" runat="server" Text="XP History" CssClass="tab" CommandArgument="history" OnClick="btnTab_Click" />
        </div>

        <!-- Rewards Tab -->
        <div id="rewardsTab" class="tab-content active" runat="server">
            <div class="section-header">
                <h3 class="section-title">Featured Rewards</h3>
                <p class="section-description">Special rewards with exclusive benefits</p>
            </div>
            <div class="rewards-grid" id="featuredRewardsGrid" runat="server">
                <!-- Featured rewards populated server-side -->
            </div>

            <div class="section-header">
                <h3 class="section-title">All Rewards</h3>
                <p class="section-description">Browse all available rewards</p>
            </div>
            <div class="rewards-grid" id="regularRewardsGrid" runat="server">
                <!-- Regular rewards populated server-side -->
            </div>
        </div>

        <!-- Achievements Tab -->
        <div id="achievementsTab" class="tab-content" runat="server">
            <div class="section-header">
                <h3 class="section-title">Your Achievements</h3>
                <p class="section-description">Complete challenges and earn bonus XP</p>
            </div>
            <div class="achievements-grid" id="achievementsGrid" runat="server">
                <!-- Achievements populated server-side -->
            </div>
        </div>

        <!-- History Tab -->
        <div id="historyTab" class="tab-content" runat="server">
            <div class="section-header">
                <h3 class="section-title">XP Transaction History</h3>
                <p class="section-description">Track your XP earnings and redemptions</p>
            </div>
            <div class="transaction-history">
                <div id="xpHistoryList" runat="server">
                    <!-- XP History populated server-side -->
                </div>
            </div>

            <div class="text-center">
                <asp:Button ID="btnLoadMoreHistory" runat="server" Text="Load More History" CssClass="btn-outline-light" OnClick="btnLoadMoreHistory_Click" />
            </div>
        </div>
    </div>

    
</asp:Content>