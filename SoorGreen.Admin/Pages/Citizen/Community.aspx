<%@ Page Title="Community" Language="C#" MasterPageFile="~/Pages/Citizen/Site.Master" AutoEventWireup="true" CodeFile="Community.aspx.cs" Inherits="SoorGreen.Citizen.Community" %>
<%@ Import Namespace="System.Web.Optimization" %>
<asp:Content ID="Content3" ContentPlaceHolderID="HeadContent" runat="server">
    <%: Styles.Render("~/Content/citizencommunity") %>
</asp:Content>
<asp:Content ID="Content4" ContentPlaceHolderID="ScriptsContent" runat="server">
    <%: Scripts.Render("~/bundles/citizencommunity") %>
</asp:Content>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Community - SoorGreen Citizen
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <asp:ScriptManager ID="ScriptManager1" runat="server" EnablePageMethods="true"></asp:ScriptManager>

   
    <div class="community-container">
        <br />
        <br />
        <br />

        <!-- Statistics Cards -->
        <div class="stats-cards">
            <div class="stat-card">
                <div class="stat-value" id="totalMembers">0</div>
                <div class="stat-label">Community Members</div>
            </div>
            <div class="stat-card">
                <div class="stat-value" id="activeNow">0</div>
                <div class="stat-label">Online Now</div>
            </div>
            <div class="stat-card">
                <div class="stat-value" id="postsToday">0</div>
                <div class="stat-label">Posts Today</div>
            </div>
            <div class="stat-card">
                <div class="stat-value" id="eventsThisWeek">0</div>
                <div class="stat-label">Events This Week</div>
            </div>
        </div>

        <!-- Action Buttons -->
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h2 style="color: #ffffff !important; margin: 0;">Community Hub</h2>
            <div>
                <button type="button" class="btn-primary" id="refreshBtn">
                    <i class="fas fa-sync-alt me-2"></i>Refresh
                </button>
            </div>
        </div>

        <!-- Filters -->
        <div class="filters-section">
            <div class="filter-group">
                <div class="form-group">
                    <label class="form-label">Post Type</label>
                    <asp:DropDownList ID="ddlPostTypeFilter" runat="server" CssClass="form-control" Style="min-width: 150px;">
                        <asp:ListItem Value="all" Text="All Posts" Selected="True"></asp:ListItem>
                        <asp:ListItem Value="achievement" Text="Achievements"></asp:ListItem>
                        <asp:ListItem Value="tip" Text="Eco Tips"></asp:ListItem>
                        <asp:ListItem Value="question" Text="Questions"></asp:ListItem>
                        <asp:ListItem Value="event" Text="Events"></asp:ListItem>
                    </asp:DropDownList>
                </div>

                <div class="form-group">
                    <label class="form-label">Sort By</label>
                    <asp:DropDownList ID="ddlSortFilter" runat="server" CssClass="form-control" Style="min-width: 150px;">
                        <asp:ListItem Value="recent" Text="Most Recent" Selected="True"></asp:ListItem>
                        <asp:ListItem Value="popular" Text="Most Popular"></asp:ListItem>
                        <asp:ListItem Value="trending" Text="Trending"></asp:ListItem>
                    </asp:DropDownList>
                </div>

                <div class="form-group">
                    <button type="button" class="btn-primary" id="applyFiltersBtn" style="margin-top: 24px;">
                        <i class="fas fa-filter me-2"></i>Apply Filters
                    </button>
                </div>

                <div class="form-group">
                    <button type="button" class="btn-outline-light" id="clearFiltersBtn" style="margin-top: 24px;">
                        <i class="fas fa-times me-2"></i>Clear Filters
                    </button>
                </div>
            </div>
        </div>

        <div class="d-flex justify-content-between align-items-center mb-3">
            <div class="text-muted" id="resultsInfo">
                Showing 0 posts
            </div>
        </div>

        <div class="community-content">
            <!-- Main Posts Section -->
            <div class="posts-section">
                <div class="create-post-card">
                    <asp:TextBox ID="txtPostContent" runat="server" CssClass="post-input" TextMode="MultiLine" Rows="3"
                        placeholder="Share your eco-friendly journey with the community..."></asp:TextBox>
                    <div class="post-actions">
                        <div>
                            <button type="button" class="btn-outline-light me-2" onclick="attachImage()">
                                <i class="fas fa-image me-2"></i>Photo
                            </button>
                            <button type="button" class="btn-outline-light" onclick="attachAchievement()">
                                <i class="fas fa-trophy me-2"></i>Achievement
                            </button>
                        </div>
                        <asp:Button ID="btnCreatePost" runat="server" Text="Post" CssClass="btn-primary" OnClick="btnCreatePost_Click" OnClientClick="return validatePost();" />
                    </div>
                </div>

                <!-- Posts Container -->
                <div id="postsContainer">
                    <!-- Posts will be populated by JavaScript -->
                </div>

                <!-- Empty State -->
                <div id="postsEmptyState" class="empty-state" style="display: none;">
                    <div class="empty-state-icon">
                        <i class="fas fa-comments"></i>
                    </div>
                    <h3 class="empty-state-title">No Posts Yet</h3>
                    <p class="empty-state-description">Be the first to share your eco-friendly journey!</p>
                </div>
            </div>

            <!-- Sidebar -->
            <div class="sidebar-section">
                <div class="sidebar-card">
                    <h4 class="text-light mb-3">Online Now</h4>
                    <div class="online-users" id="onlineUsersContainer">
                        <!-- Online users will be populated by JavaScript -->
                    </div>
                </div>

                <div class="sidebar-card">
                    <h4 class="text-light mb-3">Upcoming Events</h4>
                    <div class="community-events" id="eventsContainer">
                        <!-- Events will be populated by JavaScript -->
                    </div>
                </div>

                <div class="sidebar-card">
                    <h4 class="text-light mb-3">Quick Actions</h4>
                    <div style="display: flex; flex-direction: column; gap: 0.5rem;">
                        <asp:Button ID="btnJoinEvent" runat="server" Text="Join Event" CssClass="btn-outline-light" OnClick="btnJoinEvent_Click" />
                        <asp:Button ID="btnStartGroup" runat="server" Text="Start Group" CssClass="btn-outline-light" OnClick="btnStartGroup_Click" />
                        <asp:Button ID="btnInviteFriends" runat="server" Text="Invite Friends" CssClass="btn-outline-light" OnClick="btnInviteFriends_Click" />
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Hidden fields to store server data -->
    <asp:HiddenField ID="hfPostsData" runat="server" Value="[]" />
    <asp:HiddenField ID="hfStatsData" runat="server" Value="{}" />
    <asp:HiddenField ID="hfOnlineUsers" runat="server" Value="[]" />
    <asp:HiddenField ID="hfEvents" runat="server" Value="[]" />
    <asp:Button ID="btnLoadData" runat="server" OnClick="btnLoadData_Click" Style="display: none;" />
</asp:Content>
