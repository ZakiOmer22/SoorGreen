// Global variables
let redemptionData = [];
let filteredData = [];
let currentPage = 1;
let itemsPerPage = 10;
let currentFilters = {
    status: 'all',
    dateFrom: '',
    dateTo: '',
    search: ''
};

// Initialize when page loads
document.addEventListener('DOMContentLoaded', function () {
    console.log('Redemption History page loaded');
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

    // Load redemption data
    const redemptionField = document.getElementById('hfRedemptionData');
    if (redemptionField && redemptionField.value) {
        try {
            redemptionData = JSON.parse(redemptionField.value);
            console.log('Loaded ' + redemptionData.length + ' redemptions');

            // Set filtered data to all data initially
            filteredData = [...redemptionData];

            // Update stats
            updateStats();

            // Render table
            renderTable();

        } catch (e) {
            console.error('Error parsing redemption data:', e);
            showEmptyState();
        }
    } else {
        console.log('No redemption data found');
        showEmptyState();
    }

    // Load stats data
    const statsField = document.getElementById('hfStatsData');
    if (statsField && statsField.value) {
        try {
            const stats = JSON.parse(statsField.value);
            updateStatsDisplay(stats);
            console.log('Stats data loaded');
        } catch (e) {
            console.error('Error parsing stats data:', e);
        }
    }

    // Hide loading overlay
    setTimeout(() => {
        hideLoadingOverlay();
    }, 500);
}

function updateStats() {
    if (!redemptionData || redemptionData.length === 0) return;

    // Calculate stats from redemption data
    const stats = {
        totalRedemptions: redemptionData.length,
        totalXPSpent: redemptionData.reduce((sum, item) => sum + (parseFloat(item.Amount) || 0), 0),
        activeRedemptions: redemptionData.filter(item => item.Status === 'Completed').length,
        pendingRedemptions: redemptionData.filter(item => item.Status === 'Pending').length
    };

    updateStatsDisplay(stats);
}

function updateStatsDisplay(stats) {
    const totalRedemptionsElement = document.getElementById('totalRedemptions');
    const totalXPSpentElement = document.getElementById('totalXPSpent');
    const activeRedemptionsElement = document.getElementById('activeRedemptions');
    const pendingRedemptionsElement = document.getElementById('pendingRedemptions');

    if (totalRedemptionsElement) totalRedemptionsElement.textContent = stats.totalRedemptions || 0;
    if (totalXPSpentElement) totalXPSpentElement.textContent = formatNumber(stats.totalXPSpent || 0);
    if (activeRedemptionsElement) activeRedemptionsElement.textContent = stats.activeRedemptions || 0;
    if (pendingRedemptionsElement) pendingRedemptionsElement.textContent = stats.pendingRedemptions || 0;
}

function renderTable() {
    const tableBody = document.getElementById('historyTableBody');
    const emptyState = document.getElementById('emptyState');
    const paginationContainer = document.getElementById('paginationContainer');
    const resultsInfo = document.getElementById('resultsInfo');
    const resultsCount = document.getElementById('resultsCount');

    if (!tableBody) return;

    // Clear table
    tableBody.innerHTML = '';

    if (!filteredData || filteredData.length === 0) {
        showEmptyState();
        if (resultsInfo) resultsInfo.textContent = '0 redemptions found';
        return;
    }

    // Hide empty state
    if (emptyState) emptyState.style.display = 'none';

    // Calculate pagination
    const totalPages = Math.ceil(filteredData.length / itemsPerPage);
    const startIndex = (currentPage - 1) * itemsPerPage;
    const endIndex = Math.min(startIndex + itemsPerPage, filteredData.length);
    const pageData = filteredData.slice(startIndex, endIndex);

    // Update results info
    if (resultsInfo) {
        resultsInfo.textContent = `Showing ${startIndex + 1}-${endIndex} of ${filteredData.length} redemptions`;
    }
    if (resultsCount) {
        resultsCount.textContent = filteredData.length;
    }

    // Render table rows
    pageData.forEach((redemption, index) => {
        const row = createTableRow(redemption);
        tableBody.appendChild(row);
    });

    // Update pagination
    updatePagination(totalPages);

    // Show pagination if needed
    if (paginationContainer) {
        paginationContainer.style.display = filteredData.length > itemsPerPage ? 'block' : 'none';
    }
}

function createTableRow(redemption) {
    const row = document.createElement('tr');

    // Format dates
    const requestedDate = redemption.RequestedAt ? formatDate(redemption.RequestedAt) : 'N/A';

    // Get status class
    const statusClass = getStatusClass(redemption.Status);
    const statusText = getStatusText(redemption.Status);

    // Format XP amount
    const xpAmount = parseFloat(redemption.Amount || 0);
    const formattedXP = xpAmount % 1 === 0 ? xpAmount : xpAmount.toFixed(2);

    row.innerHTML = `
        <td>
            <div class="reward-title">${escapeHtml(redemption.RewardTitle || 'Reward Redemption')}</div>
        </td>
        <td>
            <div class="reward-description">${escapeHtml(redemption.Description || 'Redemption request')}</div>
        </td>
        <td>
            <div class="xp-cost">
                <i class="fas fa-star"></i>
                <span>${formattedXP} XP</span>
            </div>
        </td>
        <td>
            <div class="method-cell">${escapeHtml(redemption.Method || 'Digital')}</div>
        </td>
        <td>
            <div class="date-cell">${requestedDate}</div>
        </td>
        <td>
            <span class="status-badge ${statusClass}">${statusText}</span>
        </td>
        <td>
            <div class="action-buttons">
                <button class="btn-view" onclick="viewRedemptionDetails('${escapeHtml(redemption.RedemptionId)}')">
                    <i class="fas fa-eye"></i> View
                </button>
                ${redemption.Status === 'Completed' ? `
                <button class="btn-download" onclick="downloadReceipt('${escapeHtml(redemption.RedemptionId)}')">
                    <i class="fas fa-download"></i> Receipt
                </button>
                ` : ''}
            </div>
        </td>
    `;

    return row;
}

function getStatusClass(status) {
    if (!status) return 'status-pending';
    switch (status.toLowerCase()) {
        case 'completed': return 'status-completed';
        case 'pending': return 'status-pending';
        case 'expired': return 'status-expired';
        case 'cancelled': return 'status-cancelled';
        default: return 'status-pending';
    }
}

function getStatusText(status) {
    if (!status) return 'Pending';
    switch (status.toLowerCase()) {
        case 'completed': return 'Completed';
        case 'pending': return 'Pending';
        case 'expired': return 'Expired';
        case 'cancelled': return 'Cancelled';
        default: return status;
    }
}

function updatePagination(totalPages) {
    const pageNumbers = document.getElementById('pageNumbers');
    const prevBtn = document.getElementById('prevPageBtn');
    const nextBtn = document.getElementById('nextPageBtn');

    if (!pageNumbers || !prevBtn || !nextBtn) return;

    // Clear existing page numbers
    pageNumbers.innerHTML = '';

    // Update button states
    prevBtn.disabled = currentPage === 1;
    nextBtn.disabled = currentPage === totalPages || totalPages === 0;

    // Generate page numbers (show max 5 pages)
    let startPage = Math.max(1, currentPage - 2);
    let endPage = Math.min(totalPages, startPage + 4);

    // Adjust start page if we're near the end
    if (endPage - startPage < 4) {
        startPage = Math.max(1, endPage - 4);
    }

    for (let i = startPage; i <= endPage; i++) {
        const pageNumber = document.createElement('span');
        pageNumber.className = `page-number ${i === currentPage ? 'active' : ''}`;
        pageNumber.textContent = i;
        pageNumber.onclick = () => goToPage(i);
        pageNumbers.appendChild(pageNumber);
    }
}

function goToPage(page) {
    if (page < 1 || page > Math.ceil(filteredData.length / itemsPerPage)) return;

    currentPage = page;
    renderTable();

    // Scroll to top of table
    const tableContainer = document.querySelector('.table-container');
    if (tableContainer) {
        tableContainer.scrollIntoView({ behavior: 'smooth', block: 'start' });
    }
}

function changePage(direction) {
    goToPage(currentPage + direction);
}

function applyFilters() {
    const statusFilter = document.getElementById('statusFilter');
    const dateFrom = document.getElementById('dateFrom');
    const dateTo = document.getElementById('dateTo');
    const searchInput = document.getElementById('searchInput');

    if (!statusFilter || !dateFrom || !dateTo || !searchInput) return;

    // Update current filters
    currentFilters.status = statusFilter.value;
    currentFilters.dateFrom = dateFrom.value;
    currentFilters.dateTo = dateTo.value;
    currentFilters.search = searchInput.value.toLowerCase().trim();

    // Apply filters
    filterData();

    // Reset to first page
    currentPage = 1;

    // Re-render table
    renderTable();
}

function filterData() {
    filteredData = redemptionData.filter(redemption => {
        // Status filter
        if (currentFilters.status !== 'all' && redemption.Status !== currentFilters.status) {
            return false;
        }

        // Date range filter
        const requestedDate = new Date(redemption.RequestedAt);
        if (currentFilters.dateFrom) {
            const fromDate = new Date(currentFilters.dateFrom);
            fromDate.setHours(0, 0, 0, 0);
            if (requestedDate < fromDate) return false;
        }

        if (currentFilters.dateTo) {
            const toDate = new Date(currentFilters.dateTo);
            toDate.setHours(23, 59, 59, 999);
            if (requestedDate > toDate) return false;
        }

        // Search filter
        if (currentFilters.search) {
            const searchText = currentFilters.search;
            const rewardTitle = (redemption.RewardTitle || '').toLowerCase();
            const description = (redemption.Description || '').toLowerCase();
            const redemptionId = (redemption.RedemptionId || '').toLowerCase();

            if (!rewardTitle.includes(searchText) &&
                !description.includes(searchText) &&
                !redemptionId.includes(searchText)) {
                return false;
            }
        }

        return true;
    });
}

function clearFilters() {
    const statusFilter = document.getElementById('statusFilter');
    const dateFrom = document.getElementById('dateFrom');
    const dateTo = document.getElementById('dateTo');
    const searchInput = document.getElementById('searchInput');

    if (statusFilter) statusFilter.value = 'all';
    if (dateFrom) dateFrom.value = '';
    if (dateTo) dateTo.value = '';
    if (searchInput) searchInput.value = '';

    // Reset filters
    currentFilters = {
        status: 'all',
        dateFrom: '',
        dateTo: '',
        search: ''
    };

    // Reset filtered data
    filteredData = [...redemptionData];

    // Reset to first page
    currentPage = 1;

    // Re-render table
    renderTable();
}

function searchRedemptions() {
    applyFilters();
}

function viewRedemptionDetails(redemptionId) {
    const redemption = redemptionData.find(r => r.RedemptionId === redemptionId);
    if (!redemption) return;

    const modalContent = document.getElementById('redemptionDetailsContent');
    const modal = document.getElementById('redemptionDetailsModal');

    if (!modalContent || !modal) return;

    // Format dates
    const requestedDate = formatDate(redemption.RequestedAt);
    const processedDate = redemption.ProcessedAt ? formatDate(redemption.ProcessedAt) : 'Not processed';
    const expiryDate = redemption.ExpiryDate ? formatDate(redemption.ExpiryDate) : 'Not set';

    // Format XP amount
    const xpAmount = parseFloat(redemption.Amount || 0);
    const formattedXP = xpAmount % 1 === 0 ? xpAmount : xpAmount.toFixed(2);

    modalContent.innerHTML = `
        <div class="details-grid">
            <div class="detail-item">
                <span class="detail-label">Redemption ID:</span>
                <span class="detail-value">${escapeHtml(redemption.RedemptionId)}</span>
            </div>
            <div class="detail-item">
                <span class="detail-label">Reward Title:</span>
                <span class="detail-value">${escapeHtml(redemption.RewardTitle || 'Reward Redemption')}</span>
            </div>
            <div class="detail-item">
                <span class="detail-label">Description:</span>
                <span class="detail-value">${escapeHtml(redemption.Description || 'Redemption request')}</span>
            </div>
            <div class="detail-item">
                <span class="detail-label">XP Amount:</span>
                <span class="detail-value">${formattedXP} XP</span>
            </div>
            <div class="detail-item">
                <span class="detail-label">Method:</span>
                <span class="detail-value">${escapeHtml(redemption.Method || 'Digital')}</span>
            </div>
            <div class="detail-item">
                <span class="detail-label">Status:</span>
                <span class="detail-value"><span class="status-badge ${getStatusClass(redemption.Status)}">${getStatusText(redemption.Status)}</span></span>
            </div>
            <div class="detail-item">
                <span class="detail-label">Requested Date:</span>
                <span class="detail-value">${requestedDate}</span>
            </div>
            <div class="detail-item">
                <span class="detail-label">Processed Date:</span>
                <span class="detail-value">${processedDate}</span>
            </div>
            <div class="detail-item">
                <span class="detail-label">Expiry Date:</span>
                <span class="detail-value">${expiryDate}</span>
            </div>
            ${redemption.Notes ? `
            <div class="detail-item">
                <span class="detail-label">Notes:</span>
                <span class="detail-value">${escapeHtml(redemption.Notes)}</span>
            </div>
            ` : ''}
        </div>
    `;

    modal.style.display = 'flex';
}

function closeDetailsModal() {
    const modal = document.getElementById('redemptionDetailsModal');
    if (modal) {
        modal.style.display = 'none';
    }
}

function downloadReceipt(redemptionId) {
    const redemption = redemptionData.find(r => r.RedemptionId === redemptionId);
    if (!redemption) return;

    // Create receipt content
    const receiptContent = `
        SoorGreen - Redemption Receipt
        ==============================
        
        Redemption ID: ${redemption.RedemptionId}
        Date: ${formatDate(redemption.RequestedAt)}
        
        Reward: ${redemption.RewardTitle || 'Reward Redemption'}
        Description: ${redemption.Description || 'Redemption request'}
        
        XP Amount: ${parseFloat(redemption.Amount || 0)} XP
        Status: ${redemption.Status}
        Method: ${redemption.Method || 'Digital'}
        
        Thank you for using SoorGreen!
        ==============================
    `;

    // Create blob and download
    const blob = new Blob([receiptContent], { type: 'text/plain' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `soorgreen-receipt-${redemption.RedemptionId}.txt`;
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
    URL.revokeObjectURL(url);

    showNotification('Receipt downloaded successfully!', 'success');
}

function refreshData() {
    // Show loading overlay
    showLoadingOverlay();

    // Reload the page after a short delay
    setTimeout(() => {
        window.location.reload();
    }, 1000);
}

function exportHistory() {
    if (!filteredData || filteredData.length === 0) {
        showNotification('No data to export', 'warning');
        return;
    }

    // Convert data to CSV
    const headers = ['Redemption ID', 'Reward Title', 'Description', 'XP Amount', 'Method', 'Status', 'Requested Date', 'Processed Date'];
    const csvRows = [
        headers.join(','),
        ...filteredData.map(item => [
            `"${item.RedemptionId || ''}"`,
            `"${item.RewardTitle || 'Reward Redemption'}"`,
            `"${(item.Description || 'Redemption request').replace(/"/g, '""')}"`,
            parseFloat(item.Amount || 0),
            `"${item.Method || 'Digital'}"`,
            `"${item.Status || 'Pending'}"`,
            `"${formatDate(item.RequestedAt)}"`,
            `"${item.ProcessedAt ? formatDate(item.ProcessedAt) : ''}"`
        ].join(','))
    ];

    const csvContent = csvRows.join('\n');

    // Create blob and download
    const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `redemption-history-${new Date().toISOString().split('T')[0]}.csv`;
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
    URL.revokeObjectURL(url);

    showNotification('History exported successfully!', 'success');
}

function redirectToRewards() {
    window.location.href = 'MyRewards.aspx';
}

function showEmptyState() {
    const emptyState = document.getElementById('emptyState');
    const tableContainer = document.querySelector('.table-container');
    const paginationContainer = document.getElementById('paginationContainer');
    const resultsInfo = document.getElementById('resultsInfo');

    if (emptyState) emptyState.style.display = 'block';
    if (tableContainer) tableContainer.style.display = 'none';
    if (paginationContainer) paginationContainer.style.display = 'none';
    if (resultsInfo) resultsInfo.textContent = '0 redemptions found';
}

// Helper functions
function escapeHtml(text) {
    if (!text) return '';
    var div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
}

function formatDate(dateString) {
    if (!dateString) return 'N/A';

    try {
        const date = new Date(dateString);
        return date.toLocaleDateString('en-US', {
            year: 'numeric',
            month: 'short',
            day: 'numeric',
            hour: '2-digit',
            minute: '2-digit'
        });
    } catch (e) {
        return dateString;
    }
}

function formatNumber(num) {
    return num.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
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
        const modal = document.getElementById('redemptionDetailsModal');
        if (event.target === modal) {
            closeDetailsModal();
        }
    });

    // Search on Enter key
    const searchInput = document.getElementById('searchInput');
    if (searchInput) {
        searchInput.addEventListener('keypress', function (e) {
            if (e.key === 'Enter') {
                searchRedemptions();
            }
        });
    }

    // Date inputs - set max date to today
    const dateFrom = document.getElementById('dateFrom');
    const dateTo = document.getElementById('dateTo');
    const today = new Date().toISOString().split('T')[0];

    if (dateFrom) {
        dateFrom.max = today;
        dateFrom.addEventListener('change', function () {
            if (dateTo) {
                dateTo.min = this.value;
            }
        });
    }

    if (dateTo) {
        dateTo.max = today;
    }

    // Theme detection
    const theme = localStorage.getItem('theme') || 'light';
    document.documentElement.setAttribute('data-theme', theme);
}

// Make functions globally available
window.applyFilters = applyFilters;
window.clearFilters = clearFilters;
window.searchRedemptions = searchRedemptions;
window.viewRedemptionDetails = viewRedemptionDetails;
window.closeDetailsModal = closeDetailsModal;
window.downloadReceipt = downloadReceipt;
window.refreshData = refreshData;
window.exportHistory = exportHistory;
window.changePage = changePage;
window.goToPage = goToPage;
window.redirectToRewards = redirectToRewards;