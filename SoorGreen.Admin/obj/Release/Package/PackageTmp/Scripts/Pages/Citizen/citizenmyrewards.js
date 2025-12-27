// Global variables
let rewardsData = [];
let achievementsData = [];
let historyData = [];
let currentTab = 'rewards';
let currentClaimData = null;

// Initialize when page loads
document.addEventListener('DOMContentLoaded', function () {
    console.log('MyRewards page loaded');
    initializePage();
});

function initializePage() {
    console.log('Initializing page...');

    // Show loading overlay
    showLoadingOverlay();

    // Load data from hidden fields
    loadDataFromHiddenFields();

    // Setup event listeners
    setupEventListeners();

    // Set active tab
    switchTab('rewards');

    console.log('Page initialized');
}

function showLoadingOverlay() {
    const overlay = document.getElementById('loadingOverlay');
    if (overlay) {
        overlay.style.display = 'flex';
        overlay.style.opacity = '1';
    }
}

function hideLoadingOverlay() {
    const overlay = document.getElementById('loadingOverlay');
    if (overlay) {
        overlay.style.opacity = '0';
        overlay.style.transition = 'opacity 0.3s ease';

        setTimeout(() => {
            overlay.style.display = 'none';
            overlay.style.opacity = '1';
        }, 300);
    }
}

function loadDataFromHiddenFields() {
    console.log('Loading data from hidden fields...');

    // 1. Load user stats
    const statsField = document.getElementById('hfUserStats');
    if (statsField && statsField.value) {
        try {
            const stats = JSON.parse(statsField.value);
            updateUserStats(stats);
            updateProgressBar(stats);
            console.log('User stats loaded');
        } catch (e) {
            console.error('Error parsing user stats:', e);
        }
    }

    // 2. Load rewards data
    const rewardsField = document.getElementById('hfRewardsData');
    if (rewardsField && rewardsField.value) {
        try {
            rewardsData = JSON.parse(rewardsField.value);
            console.log('Loaded ' + rewardsData.length + ' rewards');

            // Hide skeleton and render
            const featuredGrid = document.getElementById('featuredRewardsGrid');
            const regularGrid = document.getElementById('regularRewardsGrid');

            if (featuredGrid) {
                featuredGrid.innerHTML = '';
                renderFeaturedRewards();
            }
            if (regularGrid) {
                regularGrid.innerHTML = '';
                renderRegularRewards();
            }

            updateRewardButtons();
        } catch (e) {
            console.error('Error parsing rewards data:', e);
            showEmptyState('featuredRewardsGrid', 'Error loading rewards');
            showEmptyState('regularRewardsGrid', 'Error loading rewards');
        }
    } else {
        console.log('No rewards data found');
        showEmptyState('featuredRewardsGrid', 'No rewards available');
        showEmptyState('regularRewardsGrid', 'No rewards available');
    }

    // 3. Load achievements data
    const achievementsField = document.getElementById('hfAchievementsData');
    if (achievementsField && achievementsField.value) {
        try {
            achievementsData = JSON.parse(achievementsField.value);
            console.log('Loaded ' + achievementsData.length + ' achievements');
            updateAchievementsStats();
        } catch (e) {
            console.error('Error parsing achievements data:', e);
        }
    } else {
        console.log('No achievements data found in hidden field');
    }

    // 4. Load history data
    const historyField = document.getElementById('hfXPHistoryData');
    if (historyField && historyField.value) {
        try {
            historyData = JSON.parse(historyField.value);
            console.log('Loaded ' + historyData.length + ' history items');
        } catch (e) {
            console.error('Error parsing history data:', e);
        }
    } else {
        console.log('No history data found in hidden field');
    }

    // Hide loading overlay after data is loaded
    setTimeout(() => {
        hideLoadingOverlay();
    }, 500);
}

function updateUserStats(stats) {
    if (!stats) return;

    const totalXPElement = document.getElementById('totalXP');
    const currentLevelElement = document.getElementById('currentLevel');
    const rewardsClaimedElement = document.getElementById('rewardsClaimed');
    const nextLevelXPElement = document.getElementById('nextLevelXP');
    const userXPElement = document.getElementById('userXP');

    if (totalXPElement) totalXPElement.textContent = stats.TotalXP || 0;
    if (currentLevelElement) currentLevelElement.textContent = stats.CurrentLevel || 1;
    if (rewardsClaimedElement) rewardsClaimedElement.textContent = stats.RewardsClaimed || 0;
    if (nextLevelXPElement) nextLevelXPElement.textContent = stats.XPToNextLevel || 100;
    if (userXPElement) userXPElement.textContent = stats.AvailableXP || 0;
}

function updateProgressBar(stats) {
    const totalXP = stats.TotalXP || 0;
    const currentLevel = stats.CurrentLevel || 1;

    let levelStartXP = 0;
    let levelEndXP = 100;

    if (currentLevel === 1) {
        levelStartXP = 0;
        levelEndXP = 500;
    } else if (currentLevel === 2) {
        levelStartXP = 500;
        levelEndXP = 1000;
    } else if (currentLevel >= 3) {
        levelStartXP = 1000;
        levelEndXP = 1500;
    }

    const levelXP = Math.min(Math.max(totalXP - levelStartXP, 0), levelEndXP - levelStartXP);
    const progressPercent = levelEndXP > levelStartXP ?
        Math.min(Math.round((levelXP / (levelEndXP - levelStartXP)) * 100), 100) : 100;

    const progressFill = document.getElementById('progressFill');
    const progressPercentElement = document.getElementById('progressPercent');
    const currentXPElement = document.getElementById('currentXP');
    const nextLevelXPElement = document.getElementById('nextLevelXP');

    if (progressFill) {
        progressFill.style.width = progressPercent + '%';
    }
    if (progressPercentElement) {
        progressPercentElement.textContent = progressPercent + '%';
    }
    if (currentXPElement) {
        currentXPElement.textContent = levelXP;
    }
    if (nextLevelXPElement) {
        nextLevelXPElement.textContent = levelEndXP - levelStartXP;
    }
}

function renderFeaturedRewards() {
    const container = document.getElementById('featuredRewardsGrid');
    if (!container || !rewardsData) return;

    const featuredRewards = rewardsData.filter(function (r) {
        // Check if reward has featured properties or special status
        return r.IsFeatured || r.Status === 'Completed' || r.IconClass?.includes('star');
    }).slice(0, 3); // Limit to 3 featured rewards

    if (featuredRewards.length === 0) {
        showEmptyState(container, 'No featured rewards', 'Check back later for special offers!');
        return;
    }

    for (var i = 0; i < featuredRewards.length; i++) {
        container.appendChild(createRewardCard(featuredRewards[i]));
    }
}

function renderRegularRewards() {
    const container = document.getElementById('regularRewardsGrid');
    if (!container || !rewardsData) return;

    // Filter out featured rewards for regular display
    const regularRewards = rewardsData.filter(function (r) {
        return !(r.IsFeatured || r.Status === 'Completed' || r.IconClass?.includes('star'));
    });

    if (regularRewards.length === 0) {
        showEmptyState(container, 'No regular rewards', 'More rewards coming soon!');
        return;
    }

    for (var i = 0; i < regularRewards.length; i++) {
        container.appendChild(createRewardCard(regularRewards[i]));
    }
}

function createRewardCard(reward) {
    var card = document.createElement('div');
    card.className = 'reward-card' + (reward.IsFeatured ? ' featured' : '');

    var availableXP = parseFloat(document.getElementById('userXP') ? document.getElementById('userXP').textContent : 0) || 0;
    var xpCost = parseFloat(reward.XPCost || 0);
    var isUnlimited = reward.StockQuantity ? reward.StockQuantity.toLowerCase() === 'unlimited' : false;
    var isOutOfStock = reward.StockQuantity === '0 left';
    var canClaim = availableXP >= xpCost && !isOutOfStock;
    var rewardStatus = reward.Status || 'Available';

    var stockText = isUnlimited ? 'Unlimited Stock' : (reward.StockQuantity || '');
    if (isOutOfStock) stockText = 'Out of Stock';

    // Format XP cost to show decimals if needed
    var formattedXPCost = xpCost % 1 === 0 ? xpCost : xpCost.toFixed(2);

    card.innerHTML =
        (reward.IsFeatured ? '<div class="reward-badge">Featured</div>' : '') +
        (rewardStatus === 'Completed' ? '<div class="reward-status-badge completed">Claimed</div>' : '') +
        '<div class="reward-image">' +
        '<i class="fas ' + (reward.IconClass || 'fa-gift') + '"></i>' +
        '</div>' +
        '<h3 class="reward-title">' + escapeHtml(reward.Title) + '</h3>' +
        '<p class="reward-description">' + escapeHtml(reward.Description) + '</p>' +
        '<div class="reward-meta">' +
        '<div class="reward-xp">' +
        '<i class="fas fa-star"></i>' +
        '<span>' + formattedXPCost + ' XP</span>' +
        '</div>' +
        '<div class="reward-stock">' +
        stockText +
        '</div>' +
        '</div>' +
        '<button class="btn-primary" ' +
        'data-reward-id="' + reward.RewardId + '" ' +
        'data-reward-title="' + escapeHtml(reward.Title) + '" ' +
        'data-xp-cost="' + xpCost + '" ' +
        (canClaim && rewardStatus === 'Available' ? '' : 'disabled') + '>' +
        '<i class="fas ' + (canClaim && rewardStatus === 'Available' ? 'fa-gift' : 'fa-lock') + '"></i>' +
        (rewardStatus === 'Completed' ? 'Already Claimed' :
            rewardStatus === 'Pending' ? 'Pending Approval' :
                canClaim ? 'Claim Now' :
                    (isOutOfStock ? 'Out of Stock' : 'Need More XP')) +
        '</button>';

    var claimBtn = card.querySelector('.btn-primary');
    if (claimBtn && rewardStatus === 'Available') {
        claimBtn.addEventListener('click', function () {
            showClaimConfirmation(this);
        });
    }

    return card;
}

function renderAchievements() {
    const container = document.getElementById('achievementsGrid');
    if (!container) return;

    container.innerHTML = '';

    if (!achievementsData || achievementsData.length === 0) {
        showEmptyState(container, 'No achievements available', 'Complete eco-friendly actions to unlock achievements!');
        return;
    }

    for (var i = 0; i < achievementsData.length; i++) {
        container.appendChild(createAchievementCard(achievementsData[i]));
    }
}

function createAchievementCard(achievement) {
    var card = document.createElement('div');
    card.className = 'achievement-card' + (achievement.IsUnlocked ? ' unlocked' : '');

    var progressHtml = '';
    if (!achievement.IsUnlocked && achievement.TargetValue > 1) {
        var progressPercent = Math.min(Math.round((achievement.CurrentProgress / achievement.TargetValue) * 100), 100);
        progressHtml =
            '<div class="achievement-progress">' +
            '<div class="progress-info">' +
            '<span>Progress</span>' +
            '<span>' + achievement.CurrentProgress + '/' + achievement.TargetValue + '</span>' +
            '</div>' +
            '<div class="progress-bar">' +
            '<div class="progress-fill" style="width: ' + progressPercent + '%"></div>' +
            '</div>' +
            '</div>';
    }

    card.innerHTML =
        '<div class="achievement-icon">' +
        '<i class="fas ' + (achievement.IconClass || 'fa-trophy') + '"></i>' +
        '</div>' +
        '<h4 class="achievement-title">' + escapeHtml(achievement.Title) + '</h4>' +
        '<p class="achievement-description">' + escapeHtml(achievement.Description) + '</p>' +
        progressHtml +
        '<div class="achievement-xp">' +
        '<i class="fas fa-star"></i>' +
        '<span>+' + achievement.XPReward + ' XP</span>' +
        '</div>';

    return card;
}

function renderXPHistory() {
    const container = document.getElementById('xpHistoryList');
    if (!container) return;

    container.innerHTML = '';

    if (!historyData || historyData.length === 0) {
        showEmptyState(container, 'No transaction history', 'Start earning XP to see your history here!');
        return;
    }

    for (var i = 0; i < historyData.length; i++) {
        container.appendChild(createHistoryItem(historyData[i]));
    }
}

function createHistoryItem(transaction) {
    var item = document.createElement('div');
    item.className = 'transaction-item';

    var isEarned = transaction.Type === 'Earned';
    var xpClass = isEarned ? 'positive' : 'negative';
    var xpPrefix = isEarned ? '+' : '−';
    var xpAmount = parseFloat(transaction.XP || 0);

    // Format XP to show decimals if needed
    var formattedXP = xpAmount % 1 === 0 ? Math.abs(xpAmount) : Math.abs(xpAmount).toFixed(2);

    item.innerHTML =
        '<div class="transaction-info">' +
        '<div class="transaction-title">' + escapeHtml(transaction.Title) + '</div>' +
        '<div class="transaction-date">' +
        '<i class="far fa-clock"></i>' +
        escapeHtml(transaction.Date) +
        '</div>' +
        '</div>' +
        '<div class="transaction-xp ' + xpClass + '">' +
        xpPrefix + formattedXP + ' XP' +
        '</div>';

    return item;
}

function updateAchievementsStats() {
    if (!achievementsData || achievementsData.length === 0) return;

    var unlocked = 0;
    var inProgress = 0;
    var total = achievementsData.length;

    for (var i = 0; i < achievementsData.length; i++) {
        if (achievementsData[i].IsUnlocked) {
            unlocked++;
        } else if (achievementsData[i].CurrentProgress > 0) {
            inProgress++;
        }
    }

    var unlockedElement = document.getElementById('achievementsUnlocked');
    var inProgressElement = document.getElementById('achievementsInProgress');
    var totalElement = document.getElementById('achievementsTotal');
    var badge = document.getElementById('achievementsBadge');

    if (unlockedElement) unlockedElement.textContent = unlocked;
    if (inProgressElement) inProgressElement.textContent = inProgress;
    if (totalElement) totalElement.textContent = total;
    if (badge) badge.textContent = unlocked;
}

function updateRewardButtons() {
    var availableXP = parseFloat(document.getElementById('userXP') ? document.getElementById('userXP').textContent : 0) || 0;
    var buttons = document.querySelectorAll('.reward-card .btn-primary');

    for (var i = 0; i < buttons.length; i++) {
        var button = buttons[i];
        var xpCost = parseFloat(button.getAttribute('data-xp-cost')) || 0;
        var isOutOfStock = button.textContent.indexOf('Out of Stock') !== -1;
        var isClaimed = button.textContent.indexOf('Already Claimed') !== -1;
        var isPending = button.textContent.indexOf('Pending Approval') !== -1;

        if (!isClaimed && !isPending && availableXP < xpCost && !isOutOfStock) {
            button.disabled = true;
            button.innerHTML = '<i class="fas fa-lock"></i> Need More XP';
        } else if (!isClaimed && !isPending && !isOutOfStock) {
            button.disabled = false;
            button.innerHTML = '<i class="fas fa-gift"></i> Claim Now';
        }
    }
}

// Tab switching
function switchTab(tab) {
    currentTab = tab;

    // Update active tab
    var tabs = document.querySelectorAll('.tab');
    for (var i = 0; i < tabs.length; i++) {
        if (tabs[i].getAttribute('data-tab') === tab) {
            tabs[i].classList.add('active');
        } else {
            tabs[i].classList.remove('active');
        }
    }

    // Show/hide tab content
    var tabContents = document.querySelectorAll('.tab-content');
    for (var i = 0; i < tabContents.length; i++) {
        if (tabContents[i].id === tab + 'Tab') {
            tabContents[i].style.display = 'block';
            tabContents[i].classList.add('active');

            // Render content for this tab
            if (tab === 'achievements') {
                renderAchievements();
            } else if (tab === 'history') {
                renderXPHistory();
            }
        } else {
            tabContents[i].style.display = 'none';
            tabContents[i].classList.remove('active');
        }
    }
}

// Claim reward functionality
function showClaimConfirmation(button) {
    var rewardId = button.getAttribute('data-reward-id');
    var rewardTitle = button.getAttribute('data-reward-title');
    var xpCost = parseFloat(button.getAttribute('data-xp-cost')) || 0;

    currentClaimData = { rewardId: rewardId, rewardTitle: rewardTitle, xpCost: xpCost };

    var availableXP = parseFloat(document.getElementById('userXP') ? document.getElementById('userXP').textContent : 0) || 0;
    var canAfford = availableXP >= xpCost;

    var message = canAfford
        ? 'Are you sure you want to claim <strong>"' + escapeHtml(rewardTitle) + '"</strong>?'
        : 'You need ' + (xpCost - availableXP).toFixed(2) + ' more XP to claim this reward.';

    var content = document.getElementById('claimConfirmationContent');
    if (content) {
        content.innerHTML =
            '<div class="claim-details">' +
            '<p>' + message + '</p>' +
            '<div class="claim-xp-cost">' +
            '<i class="fas fa-star"></i>' +
            '<span>Cost: ' + (xpCost % 1 === 0 ? xpCost : xpCost.toFixed(2)) + ' XP</span>' +
            '</div>' +
            '<p>' + (canAfford ? 'This action cannot be undone.' : 'Keep earning XP to unlock this reward!') + '</p>' +
            '</div>';
    }

    var confirmBtn = document.getElementById('confirmClaimBtn');
    if (confirmBtn) {
        confirmBtn.disabled = !canAfford;
        confirmBtn.innerHTML = canAfford
            ? '<i class="fas fa-check"></i> Confirm Claim'
            : '<i class="fas fa-lock"></i> Not Enough XP';
    }

    var modal = document.getElementById('claimConfirmationModal');
    if (modal) {
        modal.style.display = 'flex';
    }
}

function confirmClaim() {
    if (!currentClaimData) return;

    var rewardId = currentClaimData.rewardId;
    var rewardTitle = currentClaimData.rewardTitle;
    var xpCost = currentClaimData.xpCost;
    var userId = document.getElementById('hfUserId') ? document.getElementById('hfUserId').value : '';

    if (!userId) {
        showNotification('Please log in to claim rewards', 'error');
        return;
    }

    // Show loading state
    var confirmBtn = document.getElementById('confirmClaimBtn');
    var originalText = confirmBtn.innerHTML;
    confirmBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Processing...';
    confirmBtn.disabled = true;

    // Call WebMethod
    $.ajax({
        type: "POST",
        url: "MyRewards.aspx/ClaimReward",
        data: JSON.stringify({
            rewardId: rewardId,
            userId: userId,
            rewardTitle: rewardTitle,
            xpCost: xpCost
        }),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function (response) {
            try {
                var result = response.d;
                var parts = result.split(':');
                var type = parts[0];
                var message = parts.slice(1).join(':');

                showNotification(message, type.toLowerCase());

                if (type === 'SUCCESS') {
                    // Reload page after 2 seconds
                    setTimeout(function () {
                        window.location.reload();
                    }, 2000);
                }
            } catch (error) {
                showNotification('Error processing response', 'error');
                console.error('Error parsing response:', error);
            }

            // Reset button
            confirmBtn.innerHTML = originalText;
            confirmBtn.disabled = false;
            closeClaimModal();
        },
        error: function (xhr, status, error) {
            showNotification('Error claiming reward: ' + error, 'error');
            confirmBtn.innerHTML = originalText;
            confirmBtn.disabled = false;
            closeClaimModal();
        }
    });
}

function closeClaimModal() {
    var modal = document.getElementById('claimConfirmationModal');
    if (modal) {
        modal.style.display = 'none';
    }
    currentClaimData = null;
}

// Helper functions
function escapeHtml(text) {
    if (!text) return '';
    var div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
}

function showEmptyState(container, title, description) {
    if (typeof container === 'string') {
        container = document.getElementById(container);
    }

    if (!container) return;

    container.innerHTML =
        '<div class="empty-state">' +
        '<div class="empty-state-icon">' +
        '<i class="fas fa-inbox"></i>' +
        '</div>' +
        '<h3 class="empty-state-title">' + escapeHtml(title) + '</h3>' +
        (description ? '<p class="empty-state-description">' + escapeHtml(description) + '</p>' : '') +
        '</div>';
}

// Notification system
function showNotification(message, type) {
    // Remove existing notifications
    var existingNotifications = document.querySelectorAll('.custom-notification');
    for (var i = 0; i < existingNotifications.length; i++) {
        existingNotifications[i].style.animation = 'slideOutRight 0.5s ease forwards';
        setTimeout(function (notif) {
            if (notif.parentElement) notif.remove();
        }, 500, existingNotifications[i]);
    }

    // Create notification element
    var notification = document.createElement('div');
    notification.className = 'custom-notification notification-' + type;

    var icon = 'fa-info-circle';
    if (type === 'success') icon = 'fa-check-circle';
    else if (type === 'error') icon = 'fa-exclamation-circle';
    else if (type === 'warning') icon = 'fa-exclamation-triangle';

    notification.innerHTML =
        '<div class="notification-content">' +
        '<i class="fas ' + icon + '"></i>' +
        '<span>' + escapeHtml(message) + '</span>' +
        '</div>' +
        '<button class="notification-close" onclick="this.parentElement.remove()">' +
        '<i class="fas fa-times"></i>' +
        '</button>';

    document.body.appendChild(notification);

    // Auto-remove after 5 seconds
    setTimeout(function () {
        if (notification.parentElement) {
            notification.style.animation = 'slideOutRight 0.5s ease forwards';
            setTimeout(function () {
                if (notification.parentElement) notification.remove();
            }, 500);
        }
    }, 5000);
}

function setupEventListeners() {
    // Close modals when clicking outside
    window.addEventListener('click', function (event) {
        var modal = document.getElementById('claimConfirmationModal');
        if (event.target === modal) {
            closeClaimModal();
        }
    });

    // Tab switching
    var tabs = document.querySelectorAll('.tab');
    for (var i = 0; i < tabs.length; i++) {
        tabs[i].addEventListener('click', function () {
            var tabName = this.getAttribute('data-tab');
            switchTab(tabName);
        });
    }
}

// Make functions globally available
window.switchTab = switchTab;
window.showClaimConfirmation = showClaimConfirmation;
window.confirmClaim = confirmClaim;
window.closeClaimModal = closeClaimModal;