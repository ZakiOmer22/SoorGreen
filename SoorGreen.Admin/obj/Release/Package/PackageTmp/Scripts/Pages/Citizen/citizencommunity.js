
document.addEventListener('DOMContentLoaded', function () {
    initializePage();
});

function initializePage() {
    setupCharacterCounter();
    renderCommunityData();

    const loadingOverlay = document.getElementById('loadingOverlay');
    if (loadingOverlay) loadingOverlay.style.display = 'none';
}

function setupCharacterCounter() {
    const postInput = document.getElementById('MainContent_txtPostContent');
    const charCounter = document.getElementById('charCounter');

    if (postInput && charCounter) {
        postInput.addEventListener('input', function () {
            charCounter.textContent = (500 - this.value.length) + ' characters remaining';
        });
    }
}

function renderCommunityData() {
    try {
        const hfPosts = document.getElementById('MainContent_hfPostsData');
        const hfStats = document.getElementById('MainContent_hfStatsData');
        const hfUsers = document.getElementById('MainContent_hfOnlineUsers');
        const hfEvents = document.getElementById('MainContent_hfEvents');

        // Render stats
        if (hfStats && hfStats.value) {
            try {
                const stats = JSON.parse(hfStats.value);
                renderStats(stats);
            } catch (e) { }
        }

        // Render posts
        if (hfPosts && hfPosts.value) {
            try {
                const posts = JSON.parse(hfPosts.value);
                renderPosts(posts);
            } catch (e) {
                showEmptyPosts();
            }
        } else {
            showEmptyPosts();
        }

        // Render online users
        if (hfUsers && hfUsers.value) {
            try {
                const users = JSON.parse(hfUsers.value);
                renderOnlineUsers(users);
            } catch (e) { }
        }

        // Render events
        if (hfEvents && hfEvents.value) {
            try {
                const events = JSON.parse(hfEvents.value);
                renderEvents(events);
            } catch (e) { }
        }

    } catch (error) { }
}

function showEmptyPosts() {
    const container = document.getElementById('postsContainer');
    const emptyState = document.getElementById('emptyState');

    if (container) {
        container.innerHTML = '<div>No posts yet. Be the first to post!</div>';
    }

    if (emptyState) {
        emptyState.style.display = 'block';
    }
}

function renderStats(stats) {
    const totalMembers = document.getElementById('totalMembers');
    const activeNow = document.getElementById('activeNow');
    const postsToday = document.getElementById('postsToday');
    const eventsThisWeek = document.getElementById('eventsThisWeek');
    const onlineCount = document.getElementById('onlineCount');

    if (totalMembers && stats.TotalMembers !== undefined) totalMembers.textContent = stats.TotalMembers;
    if (activeNow && stats.ActiveNow !== undefined) activeNow.textContent = stats.ActiveNow;
    if (postsToday && stats.PostsToday !== undefined) postsToday.textContent = stats.PostsToday;
    if (eventsThisWeek && stats.EventsThisWeek !== undefined) eventsThisWeek.textContent = stats.EventsThisWeek;
    if (onlineCount && stats.ActiveNow !== undefined) onlineCount.textContent = stats.ActiveNow;
}

function renderPosts(posts) {
    const container = document.getElementById('postsContainer');
    const emptyState = document.getElementById('emptyState');
    const resultsCount = document.getElementById('resultsCount');

    if (!container) return;

    if (!posts || posts.length === 0) {
        showEmptyPosts();
        return;
    }

    if (emptyState) emptyState.style.display = 'none';
    if (resultsCount) resultsCount.textContent = posts.length;

    let html = '';

    posts.forEach(post => {
        const userName = post.UserName || post.FullName || 'Community Member';
        const userAvatar = post.UserAvatar || 'CM';
        const content = post.Content || '';
        const timeAgo = post.TimeAgo || 'Just now';
        const userTitle = post.UserTitle || 'Member';
        const userLevel = post.UserLevel || 1;
        const likes = post.Likes || 0;
        const comments = post.Comments || 0;
        const shares = post.Shares || 0;

        html += `
            <div class="post-card">
                <div class="post-header">
                    <div class="user-avatar">${userAvatar}</div>
                    <div class="user-info">
                        <h4 class="user-name">${userName}</h4>
                        <div class="user-details">
                            <span class="user-title">${userTitle}</span>
                            <span class="user-level">Level ${userLevel}</span>
                            <span class="post-time">${timeAgo}</span>
                        </div>
                    </div>
                </div>
                <div class="post-content">
                    <p>${escapeHtml(content)}</p>
                </div>
                <div class="post-stats">
                    <button class="stat-btn"><i class="fas fa-heart"></i> ${likes}</button>
                    <button class="stat-btn"><i class="fas fa-comment"></i> ${comments}</button>
                    <button class="stat-btn"><i class="fas fa-share-alt"></i> ${shares}</button>
                </div>
            </div>
        `;
    });

    container.innerHTML = html;
}

function renderOnlineUsers(users) {
    const container = document.getElementById('onlineUsersContainer');
    if (!container) return;

    if (!users || users.length === 0) {
        container.innerHTML = '<div class="no-users">No users online</div>';
        return;
    }

    let html = '';

    users.forEach(user => {
        const name = user.Name || 'User';
        const avatar = user.Avatar || 'U';
        const status = user.Status || 'Offline';
        const level = user.Level || 1;

        html += `
            <div class="online-user">
                <div class="user-avatar-small">${avatar}</div>
                <div class="user-info-small">
                    <div class="user-name-small">${name}</div>
                    <div class="user-status">${status}</div>
                    <div class="user-level-small">Level ${level}</div>
                </div>
            </div>
        `;
    });

    container.innerHTML = html;
}

function renderEvents(events) {
    const container = document.getElementById('eventsContainer');
    if (!container) return;

    if (!events || events.length === 0) {
        container.innerHTML = '<div class="no-events">No upcoming events</div>';
        return;
    }

    let html = '';

    events.forEach(event => {
        const title = event.Title || 'Event';
        const description = event.Description || 'Join us!';
        const date = event.Date || 'Coming soon';
        const location = event.Location || 'Online';

        html += `
            <div class="event-card">
                <div class="event-header">
                    <div class="event-icon"><i class="fas fa-calendar"></i></div>
                    <div class="event-info">
                        <h4>${title}</h4>
                        <div class="event-meta">
                            <span><i class="fas fa-calendar"></i> ${date}</span>
                            <span><i class="fas fa-map-marker-alt"></i> ${location}</span>
                        </div>
                    </div>
                </div>
                <div class="event-description">${description}</div>
                <button class="btn-join"><i class="fas fa-user-plus"></i> Join</button>
            </div>
        `;
    });

    container.innerHTML = html;
}

function escapeHtml(text) {
    if (!text) return '';
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
}

function validatePost() {
    const postInput = document.getElementById('MainContent_txtPostContent');
    if (!postInput) return false;

    const content = postInput.value.trim();
    if (!content) {
        alert('Please write something to post!');
        return false;
    }

    if (content.length > 500) {
        alert('Post is too long! Maximum 500 characters.');
        return false;
    }

    return true;
}

function refreshData() {
    __doPostBack('MainContent_btnLoadData', '');
}

// Make functions global
window.focusPostInput = function () {
    const postInput = document.getElementById('MainContent_txtPostContent');
    if (postInput) postInput.focus();
};
window.validatePost = validatePost;
window.refreshData = refreshData;
window.showCreateEventModal = function () { alert('Coming soon!'); };
window.closeEventModal = function () { alert('Coming soon!'); };
window.applyFilters = function () { alert('Coming soon!'); };
window.clearFilters = function () { alert('Coming soon!'); };
window.viewAllUsers = function () { alert('Coming soon!'); };
window.viewAllEvents = function () { alert('Coming soon!'); };
window.startNewGroup = function () { alert('Coming soon!'); };
window.inviteFriends = function () { alert('Coming soon!'); };
window.shareAchievement = function () { alert('Coming soon!'); };
window.askQuestion = function () { alert('Coming soon!'); };
window.attachImage = function () { alert('Coming soon!'); };
window.attachAchievement = function () { alert('Coming soon!'); };
window.attachPoll = function () { alert('Coming soon!'); };
window.attachEvent = function () { alert('Coming soon!'); };