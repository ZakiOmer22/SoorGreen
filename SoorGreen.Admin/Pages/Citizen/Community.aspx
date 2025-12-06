<%@ Page Title="Community" Language="C#" MasterPageFile="~/Pages/Citizen/Site.Master" AutoEventWireup="true" CodeFile="Community.aspx.cs" Inherits="SoorGreen.Citizen.Community" %>

<asp:Content ID="Content3" ContentPlaceHolderID="HeadContent" runat="server">
    <link href='<%= ResolveUrl("~/Content/Pages/Citizen/citizencommunity.css") %>' rel="stylesheet" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
</asp:Content>

<asp:Content ID="Content4" ContentPlaceHolderID="ScriptsContent" runat="server">
    <script src='<%= ResolveUrl("~/Scripts/Pages/Citizen/citizencommunity.js") %>' defer></script>
</asp:Content>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Community Hub - SoorGreen Citizen
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <br />
    <br />
    <br />
    <!-- Hidden fields for server data -->
    <asp:HiddenField ID="hfPostsData" runat="server" />
    <asp:HiddenField ID="hfStatsData" runat="server" />
    <asp:HiddenField ID="hfOnlineUsers" runat="server" />
    <asp:HiddenField ID="hfEvents" runat="server" />

    <!-- Loading Overlay -->
    <div class="loading-overlay" id="loadingOverlay">
        <div class="loading-spinner">
            <div class="spinner"></div>
            <p>Loading community...</p>
        </div>
    </div>

    <div class="community-container">
        <!-- Page Header -->
        <div class="page-header">
            <div class="header-content">
                <h1 class="page-title">
                    <i class="fas fa-users"></i>Community Hub
                </h1>
                <p class="page-subtitle">Connect with eco-warriors, share tips, and grow together</p>
            </div>
            <div class="header-actions">
                <button type="button" class="btn-refresh" onclick="refreshData()">
                    <i class="fas fa-sync-alt"></i>Refresh
                </button>
                <button type="button" class="btn-primary" onclick="showCreateEventModal()">
                    <i class="fas fa-calendar-plus"></i>Create Event
                </button>
            </div>
        </div>

        <!-- Stats Cards -->
        <div class="stats-section">
            <div class="stats-cards">
                <div class="stat-card">
                    <div class="stat-icon">
                        <i class="fas fa-users"></i>
                    </div>
                    <div class="stat-content">
                        <div class="stat-value" id="totalMembers">0</div>
                        <div class="stat-label">Members</div>
                        <div class="stat-change" id="membersChange">
                            <i class="fas fa-arrow-up"></i>0% this month
                        </div>
                    </div>
                </div>

                <div class="stat-card">
                    <div class="stat-icon">
                        <i class="fas fa-signal"></i>
                    </div>
                    <div class="stat-content">
                        <div class="stat-value" id="activeNow">0</div>
                        <div class="stat-label">Online Now</div>
                        <div class="stat-change" id="onlineChange">
                            <i class="fas fa-circle"></i>Active
                        </div>
                    </div>
                </div>

                <div class="stat-card">
                    <div class="stat-icon">
                        <i class="fas fa-comments"></i>
                    </div>
                    <div class="stat-content">
                        <div class="stat-value" id="postsToday">0</div>
                        <div class="stat-label">Posts Today</div>
                        <div class="stat-change" id="postsChange">
                            <i class="fas fa-arrow-up"></i>0%
                        </div>
                    </div>
                </div>

                <div class="stat-card">
                    <div class="stat-icon">
                        <i class="fas fa-calendar"></i>
                    </div>
                    <div class="stat-content">
                        <div class="stat-value" id="eventsThisWeek">0</div>
                        <div class="stat-label">This Week</div>
                        <div class="stat-change" id="eventsChange">
                            <i class="fas fa-calendar-check"></i>Join now
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Main Content Layout -->
        <div class="main-content-layout">
            <!-- Left Column: Posts -->
            <div class="left-column">
                <!-- Create Post Card -->
                <div class="create-post-card">
                    <div class="post-header">
                        <div class="user-avatar">
                            <i class="fas fa-user-circle"></i>
                        </div>
                        <div class="post-input-container">
                            <asp:TextBox ID="txtPostContent" runat="server" CssClass="post-input" TextMode="MultiLine"
                                Rows="3" placeholder="What's on your mind? Share your eco-friendly journey..."></asp:TextBox>
                            <div class="post-char-counter" id="charCounter">500 characters remaining</div>
                        </div>
                    </div>
                    <div class="post-actions">
                        <div class="media-attachments">
                            <button type="button" class="media-btn" onclick="attachImage()">
                                <i class="fas fa-image"></i>Photo
                            </button>
                            <button type="button" class="media-btn" onclick="attachAchievement()">
                                <i class="fas fa-trophy"></i>Achievement
                            </button>
                            <button type="button" class="media-btn" onclick="attachPoll()">
                                <i class="fas fa-poll"></i>Poll
                            </button>
                            <button type="button" class="media-btn" onclick="attachEvent()">
                                <i class="fas fa-calendar"></i>Event
                            </button>
                        </div>
                        <asp:Button ID="btnCreatePost" runat="server" Text="Post" CssClass="btn-post"
                            OnClick="btnCreatePost_Click" OnClientClick="return validatePost();" />
                    </div>
                </div>

                <!-- Filters Section -->
                <div class="filters-section">
                    <div class="filters-header">
                        <h3 class="filters-title">
                            <i class="fas fa-filter"></i>Filter Posts
                        </h3>
                    </div>
                    <div class="filter-controls">
                        <div class="filter-group">
                            <div class="filter-item">
                                <label class="filter-label">Post Type</label>
                                <asp:DropDownList ID="ddlPostTypeFilter" runat="server" CssClass="filter-select">
                                    <asp:ListItem Value="all" Text="All Posts" Selected="True"></asp:ListItem>
                                    <asp:ListItem Value="achievement" Text="🏆 Achievements"></asp:ListItem>
                                    <asp:ListItem Value="tip" Text="💡 Eco Tips"></asp:ListItem>
                                    <asp:ListItem Value="question" Text="❓ Questions"></asp:ListItem>
                                    <asp:ListItem Value="event" Text="📅 Events"></asp:ListItem>
                                </asp:DropDownList>
                            </div>

                            <div class="filter-item">
                                <label class="filter-label">Sort By</label>
                                <asp:DropDownList ID="ddlSortFilter" runat="server" CssClass="filter-select">
                                    <asp:ListItem Value="recent" Text="Most Recent" Selected="True"></asp:ListItem>
                                    <asp:ListItem Value="popular" Text="Most Popular"></asp:ListItem>
                                    <asp:ListItem Value="trending" Text="Trending"></asp:ListItem>
                                </asp:DropDownList>
                            </div>

                            <div class="filter-item filter-actions">
                                <button type="button" class="btn-apply" onclick="applyFilters()">
                                    <i class="fas fa-check"></i>Apply
                                </button>
                                <button type="button" class="btn-clear" onclick="clearFilters()">
                                    <i class="fas fa-times"></i>Clear
                                </button>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Results Info -->
                <div class="results-info" id="resultsInfo">
                    <span id="resultsCount">0</span> posts found
                </div>

                <!-- Posts Container -->
                <div class="posts-container" id="postsContainer">
                    <!-- Posts will be loaded here -->
                </div>

                <!-- Empty State -->
                <div id="emptyState" class="empty-state" style="display: none;">
                    <div class="empty-state-icon">
                        <i class="fas fa-comments"></i>
                    </div>
                    <h3 class="empty-state-title">No Posts Yet</h3>
                    <p class="empty-state-description">Be the first to share your eco-friendly journey!</p>
                    <button type="button" class="btn-primary" onclick="focusPostInput()">
                        <i class="fas fa-edit"></i>Create First Post
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

            <!-- Right Column: Sidebar -->
            <div class="right-column">
                <!-- Online Users Card -->
                <div class="sidebar-card">
                    <div class="sidebar-card-header">
                        <h3 class="sidebar-title">
                            <i class="fas fa-circle online-dot"></i>Online Now
                        </h3>
                        <span class="badge-online" id="onlineCount">0</span>
                    </div>
                    <div class="online-users" id="onlineUsersContainer">
                        <!-- Online users will be loaded here -->
                    </div>
                    <div class="sidebar-card-footer">
                        <a href="javascript:void(0)" onclick="viewAllUsers()" class="view-all-link">View All Members <i class="fas fa-arrow-right"></i>
                        </a>
                    </div>
                </div>

                <!-- Upcoming Events Card -->
                <div class="sidebar-card">
                    <div class="sidebar-card-header">
                        <h3 class="sidebar-title">
                            <i class="fas fa-calendar-alt"></i>Upcoming Events
                        </h3>
                        <asp:Button ID="btnCreateEvent" runat="server" Text="+" CssClass="btn-add-event"
                            OnClientClick="showCreateEventModal(); return false;" />
                    </div>
                    <div class="community-events" id="eventsContainer">
                        <!-- Events will be loaded here -->
                    </div>
                    <div class="sidebar-card-footer">
                        <a href="javascript:void(0)" onclick="viewAllEvents()" class="view-all-link">View All Events <i class="fas fa-arrow-right"></i>
                        </a>
                    </div>
                </div>

                <!-- Quick Actions Card -->
                <div class="sidebar-card">
                    <div class="sidebar-card-header">
                        <h3 class="sidebar-title">
                            <i class="fas fa-bolt"></i>Quick Actions
                        </h3>
                    </div>
                    <div class="quick-actions">
                        <button class="quick-action-btn" onclick="startNewGroup()">
                            <i class="fas fa-users"></i>
                            <span>Start New Group</span>
                        </button>
                        <button class="quick-action-btn" onclick="inviteFriends()">
                            <i class="fas fa-user-plus"></i>
                            <span>Invite Friends</span>
                        </button>
                        <button class="quick-action-btn" onclick="shareAchievement()">
                            <i class="fas fa-share-alt"></i>
                            <span>Share Achievement</span>
                        </button>
                        <button class="quick-action-btn" onclick="askQuestion()">
                            <i class="fas fa-question-circle"></i>
                            <span>Ask Question</span>
                        </button>
                    </div>
                </div>

                <!-- Trending Topics Card -->
                <div class="sidebar-card">
                    <div class="sidebar-card-header">
                        <h3 class="sidebar-title">
                            <i class="fas fa-fire"></i>Trending Topics
                        </h3>
                    </div>
                    <div class="trending-topics" id="trendingTopics">
                        <div class="trending-topic">
                            <span class="topic-tag">#PlasticFree</span>
                            <span class="topic-count">245 posts</span>
                        </div>
                        <div class="trending-topic">
                            <span class="topic-tag">#Composting</span>
                            <span class="topic-count">189 posts</span>
                        </div>
                        <div class="trending-topic">
                            <span class="topic-tag">#SolarPower</span>
                            <span class="topic-count">156 posts</span>
                        </div>
                        <div class="trending-topic">
                            <span class="topic-tag">#UrbanFarming</span>
                            <span class="topic-count">132 posts</span>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Create Event Modal -->
    <div class="modal-overlay" id="createEventModal" style="display: none;">
        <div class="modal-content">
            <div class="modal-header">
                <h2><i class="fas fa-calendar-plus"></i>Create New Event</h2>
                <button class="btn-close-modal" onclick="closeEventModal()">
                    <i class="fas fa-times"></i>
                </button>
            </div>
            <div class="modal-body">
                <div class="form-group">
                    <label class="form-label">Event Title</label>
                    <input type="text" class="form-input" id="eventTitle" placeholder="Enter event title">
                </div>
                <div class="form-group">
                    <label class="form-label">Date & Time</label>
                    <input type="datetime-local" class="form-input" id="eventDateTime">
                </div>
                <div class="form-group">
                    <label class="form-label">Description</label>
                    <textarea class="form-textarea" id="eventDescription" placeholder="Describe your event..."></textarea>
                </div>
                <div class="form-group">
                    <label class="form-label">Event Type</label>
                    <select class="form-select" id="eventType">
                        <option value="cleanup">Cleanup Drive</option>
                        <option value="workshop">Workshop</option>
                        <option value="meetup">Community Meetup</option>
                        <option value="webinar">Webinar</option>
                    </select>
                </div>
            </div>
            <div class="modal-actions">
                <button class="btn btn-outline" onclick="closeEventModal()">
                    <i class="fas fa-times"></i>Cancel
                </button>
                <button class="btn btn-primary" onclick="createEvent()">
                    <i class="fas fa-calendar-check"></i>Create Event
                </button>
            </div>
        </div>
    </div>

    <!-- Notification Container -->
    <div class="notification-container" id="notificationContainer"></div>
</asp:Content>
