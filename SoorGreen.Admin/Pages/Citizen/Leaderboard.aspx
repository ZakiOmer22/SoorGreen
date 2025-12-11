<%@ Page Title="Leaderboard" Language="C#" MasterPageFile="~/Pages/Citizen/Site.Master" 
    AutoEventWireup="true" CodeFile="Leaderboard.aspx.cs" Inherits="SoorGreen.Admin.Leaderboard" %>

<asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
    <link href='<%= ResolveUrl("~/Content/Pages/Citizen/citizenleaderboard.css") %>' rel="stylesheet" />
    
    <!-- Add Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    
    <!-- Add Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</asp:Content>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Leaderboard - SoorGreen Citizen
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <div class="leaderboard-container">
        <!-- Page Header -->
        <div class="page-header-glass">
            <h1 class="page-title-glass">Community Leaderboard</h1>
            <p class="page-subtitle-glass">Track your ranking and compete with other eco-warriors</p>
            
            <!-- Quick Actions -->
            <div class="d-flex gap-3 mt-4">
                <asp:LinkButton ID="btnViewMyStats" runat="server" CssClass="action-btn primary"
                    OnClick="btnViewMyStats_Click">
                    <i class="fas fa-chart-line me-2"></i> My Statistics
                </asp:LinkButton>
                
                <asp:LinkButton ID="btnRefresh" runat="server" CssClass="action-btn secondary"
                    OnClick="btnRefresh_Click">
                    <i class="fas fa-sync-alt me-2"></i> Refresh
                </asp:LinkButton>
                
                <asp:LinkButton ID="btnShare" runat="server" CssClass="action-btn secondary"
                    OnClick="btnShare_Click">
                    <i class="fas fa-share-alt me-2"></i> Share
                </asp:LinkButton>
            </div>
        </div>

        <!-- Current User Stats -->
        <div class="current-user-stats">
            <div class="current-user-card-glass">
                <div class="current-user-header">
                    <div class="user-rank-badge">
                        <span class="rank-number" id="userRank" runat="server">#</span>
                        <span class="rank-label">Your Rank</span>
                    </div>
                    <div class="user-avatar">
                        <img src="~/Content/Images/default-avatar.png" class="avatar-img" alt="User Avatar" />
                    </div>
                </div>
                
                <div class="current-user-details">
                    <h4 class="user-name">
                        <span id="userName" runat="server">Your Name</span>
                    </h4>
                    <p class="user-role">
                        <span id="userRole" runat="server">Citizen</span>
                    </p>
                    
                    <div class="user-stats-grid">
                        <div class="user-stat-item">
                            <div class="stat-icon">
                                <i class="fas fa-trophy text-warning"></i>
                            </div>
                            <div class="stat-content">
                                <div class="stat-number">
                                    <span id="userTotalPoints" runat="server">0</span>
                                </div>
                                <div class="stat-label">Total Points</div>
                            </div>
                        </div>
                        
                        <div class="user-stat-item">
                            <div class="stat-icon">
                                <i class="fas fa-recycle text-success"></i>
                            </div>
                            <div class="stat-content">
                                <div class="stat-number">
                                    <span id="userPickupsCompleted" runat="server">0</span>
                                </div>
                                <div class="stat-label">Pickups</div>
                            </div>
                        </div>
                        
                        <div class="user-stat-item">
                            <div class="stat-icon">
                                <i class="fas fa-leaf text-info"></i>
                            </div>
                            <div class="stat-content">
                                <div class="stat-number">
                                    <span id="userCO2Saved" runat="server">0</span>
                                </div>
                                <div class="stat-label">CO₂ Saved (kg)</div>
                            </div>
                        </div>
                    </div>
                    
                    <div class="progress-container mt-3">
                        <div class="progress-label">
                            <span>Next Level Progress</span>
                            <span class="progress-percentage" id="progressPercentage" runat="server">0%</span>
                        </div>
                        <div class="progress-glass">
                            <div class="progress-bar-glass" id="progressBar" runat="server" style="width: 0%"></div>
                        </div>
                        <div class="progress-info">
                            <span id="currentLevel" runat="server">Beginner</span>
                            <span id="nextLevel" runat="server" class="text-end">Eco Warrior</span>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Leaderboard Filters -->
        <div class="leaderboard-filters-glass">
            <div class="filters-header">
                <h3 class="filters-title">Leaderboard Rankings</h3>
                <div class="timeframe-badges">
                    <asp:LinkButton ID="btnDaily" runat="server" CssClass="timeframe-badge active"
                        OnClick="btnDaily_Click">
                        Daily
                    </asp:LinkButton>
                    <asp:LinkButton ID="btnWeekly" runat="server" CssClass="timeframe-badge"
                        OnClick="btnWeekly_Click">
                        Weekly
                    </asp:LinkButton>
                    <asp:LinkButton ID="btnMonthly" runat="server" CssClass="timeframe-badge"
                        OnClick="btnMonthly_Click">
                        Monthly
                    </asp:LinkButton>
                    <asp:LinkButton ID="btnAllTime" runat="server" CssClass="timeframe-badge"
                        OnClick="btnAllTime_Click">
                        All Time
                    </asp:LinkButton>
                </div>
            </div>
            
            <div class="filters-controls">
                <div class="filter-group">
                    <label class="filter-label">Category:</label>
                    <asp:DropDownList ID="ddlCategory" runat="server" CssClass="filter-select-glass"
                        AutoPostBack="true" OnSelectedIndexChanged="ddlCategory_SelectedIndexChanged">
                        <asp:ListItem Value="points">Points Leaderboard</asp:ListItem>
                        <asp:ListItem Value="pickups">Pickups Leaderboard</asp:ListItem>
                        <asp:ListItem Value="waste">Waste Collected</asp:ListItem>
                        <asp:ListItem Value="reports">Reports Submitted</asp:ListItem>
                        <asp:ListItem Value="recycling">Recycling Rate</asp:ListItem>
                    </asp:DropDownList>
                </div>
                
                <div class="filter-group">
                    <label class="filter-label">Search:</label>
                    <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control-glass"
                        placeholder="Search users..." AutoPostBack="true"
                        OnTextChanged="txtSearch_TextChanged"></asp:TextBox>
                </div>
            </div>
        </div>

        <!-- Top 3 Winners -->
        <div class="top-winners-section">
            <div class="winner-cards">
                <!-- 2nd Place -->
                <asp:Panel ID="pnlSecondPlace" runat="server" CssClass="winner-card silver">
                    <div class="winner-medal">
                        <i class="fas fa-medal"></i>
                        <span class="medal-number">2</span>
                    </div>
                    <div class="winner-avatar">
                        <img src="~/Content/Images/default-avatar.png" class="avatar-img" alt="Second Place" />
                    </div>
                    <div class="winner-details">
                        <h5 class="winner-name">
                            <span id="lblSecondName" runat="server">User Name</span>
                        </h5>
                        <p class="winner-points">
                            <span id="lblSecondPoints" runat="server">0 points</span>
                        </p>
                        <div class="winner-stats">
                            <span class="winner-stat">
                                <i class="fas fa-recycle"></i>
                                <span id="lblSecondPickups" runat="server">0</span>
                            </span>
                            <span class="winner-stat">
                                <i class="fas fa-leaf"></i>
                                <span id="lblSecondCO2" runat="server">0</span>kg
                            </span>
                        </div>
                    </div>
                </asp:Panel>
                
                <!-- 1st Place -->
                <asp:Panel ID="pnlFirstPlace" runat="server" CssClass="winner-card gold">
                    <div class="winner-crown">
                        <i class="fas fa-crown"></i>
                    </div>
                    <div class="winner-medal">
                        <i class="fas fa-medal"></i>
                        <span class="medal-number">1</span>
                    </div>
                    <div class="winner-avatar">
                        <img src="~/Content/Images/default-avatar.png" class="avatar-img" alt="First Place" />
                    </div>
                    <div class="winner-details">
                        <h5 class="winner-name">
                            <span id="lblFirstName" runat="server">User Name</span>
                        </h5>
                        <p class="winner-points">
                            <span id="lblFirstPoints" runat="server">0 points</span>
                        </p>
                        <div class="winner-stats">
                            <span class="winner-stat">
                                <i class="fas fa-recycle"></i>
                                <span id="lblFirstPickups" runat="server">0</span>
                            </span>
                            <span class="winner-stat">
                                <i class="fas fa-leaf"></i>
                                <span id="lblFirstCO2" runat="server">0</span>kg
                            </span>
                        </div>
                    </div>
                </asp:Panel>
                
                <!-- 3rd Place -->
                <asp:Panel ID="pnlThirdPlace" runat="server" CssClass="winner-card bronze">
                    <div class="winner-medal">
                        <i class="fas fa-medal"></i>
                        <span class="medal-number">3</span>
                    </div>
                    <div class="winner-avatar">
                        <img src="~/Content/Images/default-avatar.png" class="avatar-img" alt="Third Place" />
                    </div>
                    <div class="winner-details">
                        <h5 class="winner-name">
                            <span id="lblThirdName" runat="server">User Name</span>
                        </h5>
                        <p class="winner-points">
                            <span id="lblThirdPoints" runat="server">0 points</span>
                        </p>
                        <div class="winner-stats">
                            <span class="winner-stat">
                                <i class="fas fa-recycle"></i>
                                <span id="lblThirdPickups" runat="server">0</span>
                            </span>
                            <span class="winner-stat">
                                <i class="fas fa-leaf"></i>
                                <span id="lblThirdCO2" runat="server">0</span>kg
                            </span>
                        </div>
                    </div>
                </asp:Panel>
            </div>
        </div>

        <!-- Leaderboard Table -->
        <div class="leaderboard-table-container">
            <div class="table-header-glass">
                <div class="table-header-row">
                    <div class="table-col rank-col">Rank</div>
                    <div class="table-col user-col">User</div>
                    <div class="table-col points-col">Points</div>
                    <div class="table-col pickups-col">Pickups</div>
                    <div class="table-col waste-col">Waste (kg)</div>
                    <div class="table-col co2-col">CO₂ Saved</div>
                    <div class="table-col level-col">Level</div>
                    <div class="table-col action-col">Actions</div>
                </div>
            </div>
            
            <div class="table-body-glass">
                <asp:Repeater ID="rptLeaderboard" runat="server" OnItemDataBound="rptLeaderboard_ItemDataBound">
                    <ItemTemplate>
                        <div class='table-row-glass <%# IsCurrentUser(Eval("UserId").ToString()) ? "current-user-row" : "" %>'>
                            <div class="table-col rank-col">
                                <span class='rank-number <%# Convert.ToInt32(Eval("Rank")) <= 3 ? "top-rank" : "" %>'>
                                    <%# Eval("Rank") %>
                                </span>
                            </div>
                            
                            <div class="table-col user-col">
                                <div class="user-info">
                                    <div class="user-avatar-small">
                                        <img src='<%# GetAvatarUrl(Eval("Email")) %>' 
                                            class="avatar-img-small" alt="User Avatar" />
                                    </div>
                                    <div class="user-details">
                                        <h6 class="user-name"><%# Eval("FullName") %></h6>
                                        <span class="user-region"><%# Eval("Email") %></span>
                                    </div>
                                </div>
                            </div>
                            
                            <div class="table-col points-col">
                                <span class="points-value"><%# Eval("TotalPoints", "{0:0}") %></span>
                            </div>
                            
                            <div class="table-col pickups-col">
                                <span class="pickups-value"><%# Eval("PickupsCompleted") %></span>
                            </div>
                            
                            <div class="table-col waste-col">
                                <span class="waste-value"><%# Eval("TotalWasteCollected", "{0:F1}") %> kg</span>
                            </div>
                            
                            <div class="table-col co2-col">
                                <span class="co2-value"><%# Eval("CO2Saved", "{0:F1}") %> kg</span>
                            </div>
                            
                            <div class="table-col level-col">
                                <span class='level-badge <%# GetLevelClass(Eval("UserLevel").ToString()) %>'>
                                    <%# Eval("UserLevel") %>
                                </span>
                            </div>
                            
                            <div class="table-col action-col">
                                <asp:LinkButton ID="btnViewProfile" runat="server" 
                                    CommandName="ViewProfile" 
                                    CommandArgument='<%# Eval("UserId") %>'
                                    CssClass="action-btn secondary small" 
                                    ToolTip="View Profile">
                                    <i class="fas fa-eye"></i>
                                </asp:LinkButton>
                                
                                <asp:LinkButton ID="btnChallenge" runat="server" 
                                    CommandName="Challenge" 
                                    CommandArgument='<%# Eval("UserId") %>'
                                    CssClass="action-btn primary small" 
                                    ToolTip="Send Challenge"
                                    Visible='<%# !IsCurrentUser(Eval("UserId").ToString()) %>'>
                                    <i class="fas fa-trophy"></i>
                                </asp:LinkButton>
                            </div>
                        </div>
                    </ItemTemplate>
                    <AlternatingItemTemplate>
                        <div class='table-row-glass alt <%# IsCurrentUser(Eval("UserId").ToString()) ? "current-user-row" : "" %>'>
                            <div class="table-col rank-col">
                                <span class='rank-number <%# Convert.ToInt32(Eval("Rank")) <= 3 ? "top-rank" : "" %>'>
                                    <%# Eval("Rank") %>
                                </span>
                            </div>
                            
                            <div class="table-col user-col">
                                <div class="user-info">
                                    <div class="user-avatar-small">
                                        <img src='<%# GetAvatarUrl(Eval("Email")) %>' 
                                            class="avatar-img-small" alt="User Avatar" />
                                    </div>
                                    <div class="user-details">
                                        <h6 class="user-name"><%# Eval("FullName") %></h6>
                                        <span class="user-region"><%# Eval("Email") %></span>
                                    </div>
                                </div>
                            </div>
                            
                            <div class="table-col points-col">
                                <span class="points-value"><%# Eval("TotalPoints", "{0:0}") %></span>
                            </div>
                            
                            <div class="table-col pickups-col">
                                <span class="pickups-value"><%# Eval("PickupsCompleted") %></span>
                            </div>
                            
                            <div class="table-col waste-col">
                                <span class="waste-value"><%# Eval("TotalWasteCollected", "{0:F1}") %> kg</span>
                            </div>
                            
                            <div class="table-col co2-col">
                                <span class="co2-value"><%# Eval("CO2Saved", "{0:F1}") %> kg</span>
                            </div>
                            
                            <div class="table-col level-col">
                                <span class='level-badge <%# GetLevelClass(Eval("UserLevel").ToString()) %>'>
                                    <%# Eval("UserLevel") %>
                                </span>
                            </div>
                            
                            <div class="table-col action-col">
                                <asp:LinkButton ID="btnViewProfile" runat="server" 
                                    CommandName="ViewProfile" 
                                    CommandArgument='<%# Eval("UserId") %>'
                                    CssClass="action-btn secondary small" 
                                    ToolTip="View Profile">
                                    <i class="fas fa-eye"></i>
                                </asp:LinkButton>
                                
                                <asp:LinkButton ID="btnChallenge" runat="server" 
                                    CommandName="Challenge" 
                                    CommandArgument='<%# Eval("UserId") %>'
                                    CssClass="action-btn primary small" 
                                    ToolTip="Send Challenge"
                                    Visible='<%# !IsCurrentUser(Eval("UserId").ToString()) %>'>
                                    <i class="fas fa-trophy"></i>
                                </asp:LinkButton>
                            </div>
                        </div>
                    </AlternatingItemTemplate>
                </asp:Repeater>
            </div>
            
            <!-- Empty State -->
            <asp:Panel ID="pnlEmptyState" runat="server" CssClass="empty-state-glass" Visible="false">
                <div class="empty-state-icon">
                    <i class="fas fa-trophy"></i>
                </div>
                <h4 class="empty-state-title">No Rankings Available</h4>
                <p class="empty-state-message">
                    Start recycling to appear on the leaderboard!
                </p>
                <asp:LinkButton ID="btnStartRecycling" runat="server" CssClass="action-btn primary"
                    OnClick="btnStartRecycling_Click">
                    <i class="fas fa-recycle me-2"></i> Start Recycling
                </asp:LinkButton>
            </asp:Panel>
        </div>
        
        <!-- Pagination -->
        <div class="d-flex justify-content-between align-items-center mt-4">
            <div class="text-muted">
                Showing <asp:Label ID="lblStartCount" runat="server" Text="1"></asp:Label> - 
                <asp:Label ID="lblEndCount" runat="server" Text="20"></asp:Label> of 
                <asp:Label ID="lblTotalCount" runat="server" Text="0"></asp:Label> users
            </div>
            
            <div class="d-flex gap-2">
                <asp:LinkButton ID="btnPrevPage" runat="server" CssClass="action-btn secondary small"
                    OnClick="btnPrevPage_Click">
                    <i class="fas fa-chevron-left"></i>
                </asp:LinkButton>
                
                <div class="d-flex gap-1">
                    <asp:Repeater ID="rptPageNumbers" runat="server">
                        <ItemTemplate>
                            <asp:LinkButton ID="btnPage" runat="server" 
                                CssClass='<%# Convert.ToInt32(Eval("PageNumber")) == Convert.ToInt32(Eval("CurrentPage")) ? "action-btn primary small" : "action-btn secondary small" %>'
                                CommandArgument='<%# Eval("PageNumber") %>'
                                OnClick="btnPage_Click"
                                Text='<%# Eval("PageNumber") %>'></asp:LinkButton>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
                
                <asp:LinkButton ID="btnNextPage" runat="server" CssClass="action-btn secondary small"
                    OnClick="btnNextPage_Click">
                    <i class="fas fa-chevron-right"></i>
                </asp:LinkButton>
            </div>
        </div>
        
        <!-- Achievements Section -->
        <div class="achievements-section">
            <div class="section-header">
                <h3 class="section-title">Available Achievements</h3>
                <asp:LinkButton ID="btnViewAllAchievements" runat="server" CssClass="action-btn secondary small"
                    OnClick="btnViewAllAchievements_Click">
                    View All
                </asp:LinkButton>
            </div>
            
            <div class="achievements-grid">
                <asp:Repeater ID="rptAchievements" runat="server">
                    <ItemTemplate>
                        <div class='achievement-card <%# Convert.ToBoolean(Eval("IsUnlocked")) ? "unlocked" : "locked" %>'>
                            <div class="achievement-icon">
                                <i class='<%# Eval("IconClass") %>'></i>
                            </div>
                            <div class="achievement-details">
                                <h5 class="achievement-title"><%# Eval("Title") %></h5>
                                <p class="achievement-desc"><%# Eval("Description") %></p>
                                <div class="achievement-progress">
                                    <div class="progress-glass small">
                                        <div class="progress-bar-glass" style='width: <%# GetAchievementProgress(Eval("Progress"), Eval("Target")) %>'></div>
                                    </div>
                                    <span class="progress-text">
                                        <%# Eval("Progress") %>/<%# Eval("Target") %>
                                    </span>
                                </div>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
        </div>
    </div>
    
    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    
    <!-- JavaScript -->
    <script type="text/javascript">
        // Initialize tooltips
        document.addEventListener('DOMContentLoaded', function () {
            var tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'));
            var tooltipList = tooltipTriggerList.map(function (tooltipTriggerEl) {
                return new bootstrap.Tooltip(tooltipTriggerEl);
            });
        });

        // Scroll to current user in leaderboard
        function scrollToCurrentUser() {
            var currentUserRow = document.querySelector('.current-user-row');
            if (currentUserRow) {
                currentUserRow.scrollIntoView({ behavior: 'smooth', block: 'center' });
            }
        }
    </script>
</asp:Content>