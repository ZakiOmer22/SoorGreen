
    document.addEventListener('DOMContentLoaded', function () {
            // Load user stats from hidden field
            const userStats = JSON.parse(document.getElementById('<%= hfUserStats.ClientID %>').value || '{ }');

    // Update UI with loaded data
    updateUserStats(userStats);
    updateRewardButtons();
        });

    function updateUserStats(stats) {
            if (!stats) return;

    document.getElementById('totalXP').textContent = stats.TotalXP || 0;
    document.getElementById('currentLevel').textContent = stats.CurrentLevel || 1;
    document.getElementById('rewardsClaimed').textContent = stats.RewardsClaimed || 0;
    document.getElementById('nextLevelXP').textContent = stats.XPToNextLevel || 100;
    document.getElementById('userXP').textContent = stats.AvailableXP || 0;
        }

    function updateRewardButtons() {
            const availableXP = parseInt(document.getElementById('userXP').textContent) || 0;
    const buttons = document.querySelectorAll('.btn-primary');

            buttons.forEach(button => {
                const xpText = button.closest('.reward-card').querySelector('.reward-xp span').textContent;
    const xpCost = parseInt(xpText.replace(' XP', ''));

    if (availableXP < xpCost) {
        button.disabled = true;
    button.innerHTML = '<i class="fas fa-lock me-2"></i>Need More XP';
                } else {
        button.disabled = false;
    button.innerHTML = '<i class="fas fa-gift me-2"></i>Claim Reward';
                }
            });
        }

    function claimReward(rewardId, xpCost, rewardTitle) {
            const availableXP = parseInt(document.getElementById('userXP').textContent) || 0;

    if (availableXP < xpCost) {
        showNotification(`Not enough XP to claim ${rewardTitle}. You need ${xpCost - availableXP} more XP.`, 'error');
    return false;
            }

    if (confirm(`Are you sure you want to claim "${rewardTitle}" for ${xpCost} XP?`)) {
                // Show loading state
                const button = event.target;
    const originalText = button.innerHTML;
    button.innerHTML = '<i class="fas fa-spinner fa-spin me-2"></i>Claiming...';
    button.disabled = true;

    // Call server-side method via PageMethods
    PageMethods.ClaimReward(rewardId, xpCost, rewardTitle, onClaimSuccess, onClaimError);

    function onClaimSuccess(result) {
                    const [type, message] = result.split(':');
    showNotification(message, type.toLowerCase());

    if (type === 'SUCCESS') {
        // Reload the page to refresh data
        setTimeout(() => {
            window.location.reload();
        }, 2000);
                    } else {
        // Reset button state on error
        button.innerHTML = originalText;
    button.disabled = false;
                    }
                }

    function onClaimError(error) {
        showNotification('Error claiming reward. Please try again.', 'error');
    button.innerHTML = originalText;
    button.disabled = false;
                }
            }
    return false;
        }

    function showNotification(message, type) {
            const existingNotifications = document.querySelectorAll('.custom-notification');
            existingNotifications.forEach(notification => notification.remove());

    const notification = document.createElement('div');
    notification.className = `custom-notification notification-${type}`;
    notification.innerHTML = `
    <i class="fas ${type === 'success' ? 'fa-check-circle' : type === 'error' ? 'fa-exclamation-circle' : 'fa-info-circle'}"></i>
    <span>${message}</span>
    <button onclick="this.parentElement.remove()">&times;</button>
    `;

    document.body.appendChild(notification);

            setTimeout(() => {
                if (notification.parentElement) {
        notification.remove();
                }
            }, 5000);
        }