// Global variables for UI state only
let currentTab = 'global';
let currentPeriod = 'all';
let currentCategory = 'all';
let currentPage = 1;

// Initialize when page loads
document.addEventListener('DOMContentLoaded', function () {
    initializeTabSwitching();
    initializeFilters();
    initializeHelpPanel();
    initializePagination();

    // Adjust for master page sidebar
    adjustForMasterPage();
});

// Adjust leaderboard for master page sidebar
function adjustForMasterPage() {
    const sidebar = document.querySelector('.sidebar');
    const mainContent = document.querySelector('.main-content');
    const leaderboardContainer = document.querySelector('.leaderboard-container');

    if (sidebar && leaderboardContainer) {
        // Check if sidebar is collapsed
        const isSidebarCollapsed = sidebar.classList.contains('collapsed');
        const isMobile = window.innerWidth < 992;

        if (!isMobile && leaderboardContainer.parentElement === mainContent) {
            // Add spacing for sidebar
            leaderboardContainer.style.marginLeft = isSidebarCollapsed ? '80px' : '280px';
            leaderboardContainer.style.transition = 'margin-left 0.3s ease';
        }
    }
}

// Listen for sidebar toggle from master page
document.addEventListener('sidebarToggle', function () {
    setTimeout(adjustForMasterPage, 300); // Wait for sidebar animation
});

// Tab Switching Functions - PURE UI
function initializeTabSwitching() {
    const tabs = document.querySelectorAll('.filter-tab');
    tabs.forEach(tab => {
        tab.addEventListener('click', function () {
            const tabName = this.getAttribute('data-tab');
            switchTab(tabName);
        });
    });
}

function switchTab(tabName) {
    currentTab = tabName;
    currentPage = 1;

    // Update active tab UI
    document.querySelectorAll('.filter-tab').forEach(tab => {
        tab.classList.remove('active');
    });
    const activeTab = document.querySelector(`.filter-tab[data-tab="${tabName}"]`);
    if (activeTab) {
        activeTab.classList.add('active');
    }

    // Update filters based on tab (UI only)
    updateFiltersForTab(tabName);

    // Trigger server-side data load
    loadServerData();
}

function updateFiltersForTab(tabName) {
    const periodFilter = document.getElementById('periodFilter');
    const categoryFilter = document.getElementById('categoryFilter');

    if (!periodFilter || !categoryFilter) return;

    switch (tabName) {
        case 'global':
            periodFilter.disabled = false;
            categoryFilter.disabled = false;
            break;
        case 'monthly':
            periodFilter.value = 'month';
            periodFilter.disabled = true;
            categoryFilter.disabled = false;
            break;
        case 'today':
            periodFilter.value = 'today';
            periodFilter.disabled = true;
            categoryFilter.disabled = false;
            break;
        case 'friends':
            periodFilter.disabled = false;
            categoryFilter.disabled = true;
            break;
        case 'local':
            periodFilter.disabled = false;
            categoryFilter.disabled = false;
            break;
    }
}

// Filter Functions - PURE UI
function initializeFilters() {
    const periodFilter = document.getElementById('periodFilter');
    const categoryFilter = document.getElementById('categoryFilter');

    if (periodFilter) {
        periodFilter.addEventListener('change', function () {
            currentPeriod = this.value;
            applyFilters();
        });
    }

    if (categoryFilter) {
        categoryFilter.addEventListener('change', function () {
            currentCategory = this.value;
            applyFilters();
        });
    }
}

function applyFilters() {
    currentPage = 1;
    loadServerData();
}

function refreshLeaderboard() {
    showNotification('Refreshing leaderboard data...', 'info');
    loadServerData();
}

function exportLeaderboard() {
    showNotification('Preparing export...', 'info');
    // Export will be handled by server-side code
}

// Server Data Loading - Minimal wrapper
function loadServerData() {
    // This just triggers the server-side postback or AJAX
    // The actual data will be rendered by ASP.NET
    if (typeof __doPostBack !== 'undefined') {
        __doPostBack('', '');
    }
}

// Pagination Functions - PURE UI
function initializePagination() {
    const prevBtn = document.querySelector('.page-btn.prev');
    const nextBtn = document.querySelector('.page-btn.next');

    if (prevBtn) {
        prevBtn.addEventListener('click', function () {
            if (!this.disabled) changePage(-1);
        });
    }

    if (nextBtn) {
        nextBtn.addEventListener('click', function () {
            if (!this.disabled) changePage(1);
        });
    }
}

function changePage(delta) {
    // Update current page and trigger server load
    const newPage = currentPage + delta;
    changePageTo(newPage);
}

function changePageTo(page) {
    if (page < 1) return;

    currentPage = page;
    loadServerData();

    // Scroll to top of table (UI only)
    const tableContainer = document.querySelector('.leaderboard-table-container');
    if (tableContainer) {
        tableContainer.scrollIntoView({ behavior: 'smooth', block: 'start' });
    }
}

// Help Panel Functions - PURE UI
function initializeHelpPanel() {
    const helpBtn = document.querySelector('.btn-help');
    const closeHelpBtn = document.querySelector('.btn-close-help');
    const helpPanel = document.getElementById('helpPanel');

    if (helpBtn) {
        helpBtn.addEventListener('click', showLeaderboardHelp);
    }

    if (closeHelpBtn) {
        closeHelpBtn.addEventListener('click', hideHelp);
    }

    // Close help panel when clicking outside
    if (helpPanel) {
        document.addEventListener('click', function (event) {
            if (helpPanel.classList.contains('active') &&
                !helpPanel.contains(event.target) &&
                event.target !== helpBtn) {
                hideHelp();
            }
        });
    }
}

function showLeaderboardHelp() {
    const helpPanel = document.getElementById('helpPanel');
    if (helpPanel) {
        helpPanel.classList.add('active');
    }
}

function hideHelp() {
    const helpPanel = document.getElementById('helpPanel');
    if (helpPanel) {
        helpPanel.classList.remove('active');
    }
}

// Notification System - PURE UI (reusable)
function showNotification(message, type) {
    // Remove existing notifications
    const existingNotifications = document.querySelectorAll('.leaderboard-notification');
    existingNotifications.forEach(notif => notif.remove());

    // Create notification element with inline styles to avoid CSS conflicts
    const notification = document.createElement('div');
    notification.className = 'leaderboard-notification';

    // Add notification styles directly to the element
    notification.style.position = 'fixed';
    notification.style.top = '100px'; // Below master page navbar (80px + 20px)
    notification.style.right = '20px';
    notification.style.padding = '16px';
    notification.style.background = type === 'success' ? '#10b981' :
        type === 'error' ? '#ef4444' :
            type === 'warning' ? '#f59e0b' : '#3b82f6';
    notification.style.color = 'white';
    notification.style.borderRadius = '8px';
    notification.style.boxShadow = '0 4px 6px rgba(0, 0, 0, 0.1)';
    notification.style.display = 'flex';
    notification.style.alignItems = 'center';
    notification.style.gap = '12px';
    notification.style.zIndex = '9999'; // Below help panel (10000) but above other content
    notification.style.maxWidth = '400px';
    notification.style.animation = 'notificationSlideIn 0.3s ease';

    notification.innerHTML = `
        <div class="notification-content" style="display: flex; align-items: center; gap: 8px; flex: 1;">
            <i class="fas ${type === 'success' ? 'fa-check-circle' :
            type === 'error' ? 'fa-exclamation-circle' :
                type === 'warning' ? 'fa-exclamation-triangle' : 'fa-info-circle'}"></i>
            <span>${message}</span>
        </div>
        <button class="notification-close" onclick="this.parentElement.remove()" style="background: none; border: none; color: white; cursor: pointer; padding: 0; margin-left: 8px;">
            <i class="fas fa-times"></i>
        </button>
    `;

    // Add to document
    document.body.appendChild(notification);

    // Auto-remove after 5 seconds
    setTimeout(() => {
        if (notification.parentElement) {
            notification.remove();
        }
    }, 5000);
}

// Make functions globally available
window.switchTab = switchTab;
window.applyFilters = applyFilters;
window.refreshLeaderboard = refreshLeaderboard;
window.exportLeaderboard = exportLeaderboard;
window.changePage = changePage;
window.showLeaderboardHelp = showLeaderboardHelp;
window.hideHelp = hideHelp;

// Handle window resize for responsive adjustments
window.addEventListener('resize', adjustForMasterPage);