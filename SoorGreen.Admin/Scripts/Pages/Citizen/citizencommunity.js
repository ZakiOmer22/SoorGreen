
    let allPosts = [];
    let filteredPosts = [];

    // Define showNotification function first
    function showNotification(message, type) {
            // Remove any existing notifications first
            const existingNotifications = document.querySelectorAll('.custom-notification');
            existingNotifications.forEach(notification => notification.remove());

    // Create new notification
    const notification = document.createElement('div');
    notification.className = 'custom-notification notification-' + type;

    // Set icon based on type
    const iconClass = type === 'success' ? 'fa-check-circle' :
    type === 'error' ? 'fa-exclamation-circle' : 'fa-info-circle';

    notification.innerHTML =
    '<i class="fas ' + iconClass + '"></i>' +
    '<span>' + message + '</span>' +
    '<button onclick="this.parentElement.remove()">&times;</button>';

    // Add to page
    document.body.appendChild(notification);

            // Auto remove after 5 seconds
            setTimeout(() => {
                if (notification.parentElement) {
        notification.remove();
                }
            }, 5000);
        }

    document.addEventListener('DOMContentLoaded', function () {
        loadDataFromServer();
    setupEventListeners();
        });

    function setupEventListeners() {
        document.getElementById('refreshBtn').addEventListener('click', function (e) {
            e.preventDefault();
            refreshData();
        });

    document.getElementById('applyFiltersBtn').addEventListener('click', function (e) {
        e.preventDefault();
    applyFilters();
            });

    document.getElementById('clearFiltersBtn').addEventListener('click', function (e) {
        e.preventDefault();
    clearFilters();
            });
        }

    function loadDataFromServer() {
        console.log('Loading data from server...');

    const postsData = document.getElementById('<%= hfPostsData.ClientID %>').value;
    const statsData = document.getElementById('<%= hfStatsData.ClientID %>').value;
    const onlineUsersData = document.getElementById('<%= hfOnlineUsers.ClientID %>').value;
    const eventsData = document.getElementById('<%= hfEvents.ClientID %>').value;

    console.log('Posts data length:', postsData.length);
    console.log('Stats data:', statsData);

    if (postsData && postsData !== '[]' && postsData !== '') {
                try {
        allPosts = JSON.parse(postsData);
    filteredPosts = [...allPosts];
    console.log('Loaded posts:', allPosts.length);
                } catch (e) {
        console.error('Error parsing posts data:', e);
    allPosts = [];
    filteredPosts = [];
                }
            } else {
        console.log('No posts data found');
    allPosts = [];
    filteredPosts = [];
            }

    if (statsData && statsData !== '') {
                try {
        updateStatistics(JSON.parse(statsData));
    console.log('Stats updated');
                } catch (e) {
        console.error('Error parsing stats data:', e);
                }
            }

    if (onlineUsersData && onlineUsersData !== '[]' && onlineUsersData !== '') {
                try {
        displayOnlineUsers(JSON.parse(onlineUsersData));
                } catch (e) {
        console.error('Error parsing online users data:', e);
                }
            }

    if (eventsData && eventsData !== '[]' && eventsData !== '') {
                try {
        displayEvents(JSON.parse(eventsData));
                } catch (e) {
        console.error('Error parsing events data:', e);
                }
            }

    renderPosts();
        }

    function refreshData() {
        console.log('Refreshing data...');
    document.getElementById('<%= btnLoadData.ClientID %>').click();

    setTimeout(function () {
        loadDataFromServer();
    showNotification('Data refreshed successfully!', 'success');
            }, 500);
        }

    function updateStatistics(stats) {
        document.getElementById('totalMembers').textContent = stats.TotalMembers || 0;
    document.getElementById('activeNow').textContent = stats.ActiveNow || 0;
    document.getElementById('postsToday').textContent = stats.PostsToday || 0;
    document.getElementById('eventsThisWeek').textContent = stats.EventsThisWeek || 0;
        }

    function applyFilters() {
            const postTypeFilter = document.getElementById('<%= ddlPostTypeFilter.ClientID %>').value;
    const sortFilter = document.getElementById('<%= ddlSortFilter.ClientID %>').value;

    console.log('Applying filters - Type:', postTypeFilter, 'Sort:', sortFilter);

            filteredPosts = allPosts.filter(post => {
                if (postTypeFilter === 'all') return true;

    const content = post.Content.toLowerCase();
    switch (postTypeFilter) {
                    case 'achievement':
    return content.includes('achievement') || content.includes('completed') || content.includes('earned');
    case 'tip':
    return content.includes('tip') || content.includes('advice') || content.includes('suggest');
    case 'question':
    return content.includes('?') || content.includes('how to') || content.includes('what');
    case 'event':
    return content.includes('event') || content.includes('join') || content.includes('meet');
    default:
    return true;
                }
            });

    // Apply sorting
    switch (sortFilter) {
                case 'popular':
                    filteredPosts.sort((a, b) => (b.Likes || 0) - (a.Likes || 0));
    break;
    case 'trending':
                    filteredPosts.sort((a, b) => ((b.Likes || 0) + (b.Comments || 0) * 2) - ((a.Likes || 0) + (a.Comments || 0) * 2));
    break;
    default: // 'recent'
                    filteredPosts.sort((a, b) => new Date(b.CreatedAt) - new Date(a.CreatedAt));
    break;
            }

    renderPosts();
        }

    function clearFilters() {
        document.getElementById('<%= ddlPostTypeFilter.ClientID %>').value = 'all';
    document.getElementById('<%= ddlSortFilter.ClientID %>').value = 'recent';

    filteredPosts = allPosts;
    renderPosts();
        }

    function renderPosts() {
            const postsContainer = document.getElementById('postsContainer');
    const emptyState = document.getElementById('postsEmptyState');

    console.log('Rendering posts:', filteredPosts.length);

    if (filteredPosts.length === 0) {
        postsContainer.innerHTML = '';
    emptyState.style.display = 'block';
    document.getElementById('resultsInfo').textContent = 'Showing 0 posts';
    return;
            }

    emptyState.style.display = 'none';
    document.getElementById('resultsInfo').textContent = 'Showing ' + filteredPosts.length + ' posts';

    let html = '';
            filteredPosts.forEach(post => {
                const timeAgo = getTimeAgo(new Date(post.CreatedAt));
    const likedClass = post.IsLiked ? 'liked' : '';

    html += `
    <div class="post-card">
        <div class="post-header">
            <div class="post-avatar">${escapeHtml(post.UserAvatar)}</div>
            <div class="post-user-info">
                <div class="post-user-name">${escapeHtml(post.UserName)}</div>
                <div class="post-time">${timeAgo} • ${escapeHtml(post.UserTitle)}</div>
            </div>
        </div>

        <div class="post-content">
            ${escapeHtml(post.Content).replace(/\n/g, '<br/>')}
        </div>

        <div class="post-stats">
            <div class="post-actions-bar">
                <button class="post-action ${likedClass}" onclick="toggleLike('${post.PostId}')">
                    <i class="fas fa-heart"></i>
                    <span>${post.Likes}</span>
                </button>
                <button class="post-action" onclick="showComments('${post.PostId}')">
                    <i class="fas fa-comment"></i>
                    <span>${post.Comments}</span>
                </button>
                <button class="post-action" onclick="sharePost('${post.PostId}')">
                    <i class="fas fa-share"></i>
                    <span>${post.Shares}</span>
                </button>
            </div>
        </div>
    </div>`;
            });

    postsContainer.innerHTML = html;
        }

    function displayOnlineUsers(users) {
            const container = document.getElementById('onlineUsersContainer');

    if (!users || users.length === 0) {
        container.innerHTML = '<div class="text-muted">No users online</div>';
    return;
            }

    let html = '';
            users.forEach(user => {
        html += `
                <div class="online-user">
                    <div class="online-avatar">
                        ${user.Avatar}
                        <div class="online-status"></div>
                    </div>
                    <div class="online-user-info">
                        <div class="online-user-name">${escapeHtml(user.Name)}</div>
                        <div class="online-user-status">${escapeHtml(user.Status)}</div>
                    </div>
                </div>`;
            });

    container.innerHTML = html;
        }

    function displayEvents(events) {
            const container = document.getElementById('eventsContainer');

    if (!events || events.length === 0) {
        container.innerHTML = '<div class="text-muted">No upcoming events</div>';
    return;
            }

    let html = '';
            events.forEach(event => {
        html += `
                <div class="event-card" onclick="joinEvent('${event.EventId}')">
                    <div class="event-date">${escapeHtml(event.Date)}</div>
                    <div class="event-title">${escapeHtml(event.Title)}</div>
                    <div class="event-description">${escapeHtml(event.Description)}</div>
                </div>`;
            });

    container.innerHTML = html;
        }

    function getTimeAgo(date) {
            const now = new Date();
    const diffMs = now - date;
    const diffMins = Math.floor(diffMs / 60000);
    const diffHours = Math.floor(diffMs / 3600000);
    const diffDays = Math.floor(diffMs / 86400000);

    if (diffMins < 1) return 'Just now';
    if (diffMins < 60) return diffMins + 'm ago';
    if (diffHours < 24) return diffHours + 'h ago';
    if (diffDays < 7) return diffDays + 'd ago';

    return date.toLocaleDateString('en-US', {month: 'short', day: 'numeric' });
        }

    function validatePost() {
            var postContent = document.getElementById('<%= txtPostContent.ClientID %>').value;
    if (!postContent || postContent.trim() === '') {
        showNotification('Please write something to post!', 'error');
    return false;
            }
    return true;
        }

    function attachImage() {
        showNotification('Image attachment feature coming soon!', 'info');
        }

    function attachAchievement() {
        showNotification('Share your achievements with the community!', 'info');
        }

    function toggleLike(postId) {
        showNotification('Liking post...', 'info');
        }

    function showComments(postId) {
        showNotification('Comments feature coming soon!', 'info');
        }

    function sharePost(postId) {
        showNotification('Sharing post...', 'info');
        }

    function joinEvent(eventId) {
        showNotification('Joining event...', 'info');
        }

    function escapeHtml(unsafe) {
            if (!unsafe) return '';
    return unsafe.toString()
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
                .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&#039;");
        }

var prm = Sys.WebForms.PageRequestManager.getInstance();
prm.add_endRequest(function () {
    setupEventListeners();
    loadDataFromServer();
});