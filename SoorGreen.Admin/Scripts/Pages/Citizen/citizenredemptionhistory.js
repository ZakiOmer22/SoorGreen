
        // Load data from hidden fields on page load
    document.addEventListener('DOMContentLoaded', function () {
            const redemptionData = JSON.parse(document.getElementById('<%= hfRedemptionData.ClientID %>').value);
    const statsData = JSON.parse(document.getElementById('<%= hfStatsData.ClientID %>').value);

    updateHistoryTable(redemptionData);
    updateStats(statsData);
    setupEventListeners();
        });

    function setupEventListeners() {
        document.getElementById('statusFilter').addEventListener('change', function () {
            applyFilters();
        });

    document.getElementById('typeFilter').addEventListener('change', function () {
        applyFilters();
            });

    document.getElementById('dateFrom').addEventListener('change', function () {
        applyFilters();
            });

    document.getElementById('dateTo').addEventListener('change', function () {
        applyFilters();
            });
        }

    function updateHistoryTable(data) {
            const tbody = document.getElementById('historyTableBody');

    if (!data || data.length === 0) {
        document.getElementById('emptyState').style.display = 'block';
    document.querySelector('.table-responsive').style.display = 'none';
    document.getElementById('paginationContainer').style.display = 'none';
    document.getElementById('resultsInfo').textContent = 'Showing 0 redemptions';
    return;
            }

    let html = '';

    data.forEach(function (item) {
                const statusClass = getStatusClass(item.Status);
    const typeClass = getTypeClass(item.Type);
    const typeIcon = getTypeIcon(item.Type);

    html += `
    <tr>
        <td>
            <div class="fw-bold text-light">${item.RewardName}</div>
            ${item.Code ? '<div class="text-muted small">Code: ' + item.Code + '</div>' : ''}
        </td>
        <td>
            <span class="reward-type ${typeClass}">
                <i class="fas ${typeIcon}"></i>
                ${item.Type ? item.Type.charAt(0).toUpperCase() + item.Type.slice(1) : 'Unknown'}
            </span>
        </td>
        <td>
            <span class="xp-badge">
                <i class="fas fa-star"></i>
                ${item.XPCost || 0}
            </span>
        </td>
        <td>${formatDate(item.ClaimedDate)}</td>
        <td>${formatDate(item.ExpiryDate)}</td>
        <td>
            <span class="status-badge ${statusClass}">
                ${item.Status ? item.Status.charAt(0).toUpperCase() + item.Status.slice(1) : 'Unknown'}
            </span>
        </td>
        <td>
            <div class="d-flex gap-2">
                ${item.Status === 'redeemed' ? `
                                <button class="action-btn" onclick="viewDetails('${item.RedemptionId}')" title="View Details">
                                    <i class="fas fa-eye"></i>
                                </button>
                            ` : ''}

                ${item.Status === 'pending' ? `
                                <button class="action-btn" onclick="redeemReward('${item.RedemptionId}')" title="Redeem Now">
                                    <i class="fas fa-check"></i>
                                </button>
                            ` : ''}

                ${item.Status !== 'redeemed' && item.Status !== 'expired' ? `
                                <button class="action-btn" onclick="cancelRedemption('${item.RedemptionId}')" title="Cancel">
                                    <i class="fas fa-times"></i>
                                </button>
                            ` : ''}
            </div>
        </td>
    </tr>
    `;
            });

    tbody.innerHTML = html;
    document.getElementById('emptyState').style.display = 'none';
    document.querySelector('.table-responsive').style.display = 'block';
            document.getElementById('paginationContainer').style.display = data.length > 0 ? 'flex' : 'none';
    document.getElementById('resultsInfo').textContent = 'Showing ' + data.length + ' redemptions';
        }

    function updateStats(stats) {
            if (!stats) return;

    document.getElementById('totalRedemptions').textContent = stats.TotalRedemptions || 0;
    document.getElementById('totalXPSpent').textContent = stats.TotalXPSpent || 0;
    document.getElementById('activeRewards').textContent = stats.ActiveRewards || 0;
    document.getElementById('savingsAmount').textContent = '$' + (stats.TotalSavings || 0).toFixed(2);
        }

    function getStatusClass(status) {
            if (!status) return 'status-pending';

    switch (status.toLowerCase()) {
                case 'redeemed': return 'status-redeemed';
    case 'pending': return 'status-pending';
    case 'expired': return 'status-expired';
    case 'cancelled': return 'status-cancelled';
    default: return 'status-pending';
            }
        }

    function getTypeClass(type) {
            if (!type) return '';

    switch (type.toLowerCase()) {
                case 'digital': return 'type-digital';
    case 'physical': return 'type-physical';
    case 'discount': return 'type-discount';
    default: return '';
            }
        }

    function getTypeIcon(type) {
            if (!type) return 'fa-gift';

    switch (type.toLowerCase()) {
                case 'digital': return 'fa-file-download';
    case 'physical': return 'fa-box';
    case 'discount': return 'fa-tag';
    default: return 'fa-gift';
            }
        }

    function formatDate(dateString) {
            if (!dateString) return 'N/A';

    const date = new Date(dateString);
    if (isNaN(date.getTime())) return 'N/A';

    return date.toLocaleDateString('en-US', {
        year: 'numeric',
    month: 'short',
    day: 'numeric'
            });
        }

    function applyFilters() {
        showNotification('Applying filters...', 'info');
    document.getElementById('<%= btnApplyFilters.ClientID %>').click();
        }

    function clearFilters() {
        document.getElementById('statusFilter').value = 'all';
    document.getElementById('typeFilter').value = 'all';
    document.getElementById('dateFrom').value = '';
    document.getElementById('dateTo').value = '';

    applyFilters();
        }

    function changePage(direction) {
        showNotification('Loading page ' + (currentPage + direction) + '...', 'info');
        }

    function viewDetails(redemptionId) {
        showNotification('Loading reward details...', 'info');
    const row = event.target.closest('tr');
    const cells = row.getElementsByTagName('td');
    const rewardName = cells[0].querySelector('.fw-bold').textContent;
    const type = cells[1].querySelector('.reward-type').textContent;
    const xpCost = cells[2].querySelector('.xp-badge').textContent;
    const claimedDate = cells[3].textContent;
    const expiryDate = cells[4].textContent;
    const status = cells[5].querySelector('.status-badge').textContent;

    alert('Reward Details:\n\n' +
    'Name: ' + rewardName + '\n' +
    'Type: ' + type + '\n' +
    'XP Cost: ' + xpCost + '\n' +
    'Status: ' + status + '\n' +
    'Claimed: ' + claimedDate + '\n' +
    'Expires: ' + expiryDate);
        }

    function redeemReward(redemptionId) {
            if (confirm('Are you sure you want to redeem this reward?')) {
        showNotification('Redeeming reward...', 'info');
    PageMethods.RedeemReward(redemptionId, function(response) {
                    if (response.startsWith('SUCCESS')) {
        showNotification('Reward redeemed successfully!', 'success');
    document.getElementById('<%= btnRefresh.ClientID %>').click();
                    } else {
        showNotification('Error: ' + response, 'error');
                    }
                });
            }
        }

    function cancelRedemption(redemptionId) {
            if (confirm('Are you sure you want to cancel this redemption?')) {
        showNotification('Cancelling redemption...', 'info');
    PageMethods.CancelRedemption(redemptionId, function(response) {
                    if (response.startsWith('SUCCESS')) {
        showNotification('Redemption cancelled successfully!', 'success');
    document.getElementById('<%= btnRefresh.ClientID %>').click();
                    } else {
        showNotification('Error: ' + response, 'error');
                    }
                });
            }
        }

    function exportHistory() {
        showNotification('Preparing export...', 'info');

    const data = JSON.parse(document.getElementById('<%= hfRedemptionData.ClientID %>').value);

    let csv = 'Reward Name,Type,XP Cost,Claimed Date,Expiry Date,Status,Code,Savings\n';

    data.forEach(function (item) {
        csv += '"' + (item.RewardName || '') + '",';
    csv += '"' + (item.Type || '') + '",';
    csv += (item.XPCost || 0) + ',';
    csv += '"' + formatDate(item.ClaimedDate) + '",';
    csv += '"' + formatDate(item.ExpiryDate) + '",';
    csv += '"' + (item.Status || '') + '",';
    csv += '"' + (item.Code || 'N/A') + '",';
    csv += '$' + (item.Savings || 0).toFixed(2) + '\n';
            });

    const link = document.createElement('a');
    link.download = 'redemption-history.csv';
    const blob = new Blob([csv], {type: 'text/csv' });
    link.href = window.URL.createObjectURL(blob);
    link.click();

    showNotification('Export completed!', 'success');
        }

    function showNotification(message, type) {
            const existingNotifications = document.querySelectorAll('.custom-notification');
    existingNotifications.forEach(function (notification) {
        notification.remove();
            });

    const notification = document.createElement('div');
    notification.className = 'custom-notification notification-' + type;
    notification.innerHTML = `
    <i class="fas ${type === 'success' ? 'fa-check-circle' : type === 'error' ? 'fa-exclamation-circle' : 'fa-info-circle'}"></i>
    <span>${message}</span>
    <button onclick="this.parentElement.remove()">&times;</button>
    `;

    document.body.appendChild(notification);

    setTimeout(function () {
                if (notification.parentElement) {
        notification.remove();
                }
            }, 5000);
        }
