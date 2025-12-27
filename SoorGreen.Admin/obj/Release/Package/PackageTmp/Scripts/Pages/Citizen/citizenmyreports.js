// Global variables
let allReports = [];
let filteredReports = [];
let currentPage = 1;
const pageSize = 12;
let currentReportId = null;
let currentView = 'grid';

// Initialize when page loads
document.addEventListener('DOMContentLoaded', function () {
    initializePage();
});

function initializePage() {
    // Initialize date range picker
    initializeDatePicker();

    // Load data
    loadReportsData();

    // Setup event listeners
    setupEventListeners();

    // Initialize view toggle
    initializeViewToggle();
}

// Data Loading
function loadReportsData() {
    try {
        // Parse data from hidden fields
        const reportsData = document.getElementById('<%= hfAllReports.ClientID %>').value;
        const statsData = document.getElementById('<%= hfStats.ClientID %>').value;

        if (reportsData) {
            allReports = JSON.parse(reportsData);
            filteredReports = [...allReports];
        }

        if (statsData) {
            const stats = JSON.parse(statsData);
            updateStats(stats);
        }

        // Render reports
        renderReports();

    } catch (error) {
        console.error('Error loading reports data:', error);
        showNotification('Error loading reports data', 'error');
    }
}

function updateStats(stats) {
    document.getElementById('totalReports').textContent = stats.TotalReports || 0;
    document.getElementById('pendingReports').textContent = stats.PendingReports || 0;
    document.getElementById('completedReports').textContent = stats.CompletedReports || 0;
    document.getElementById('totalRewards').textContent = stats.TotalRewards || 0;
}

// Date Picker
function initializeDatePicker() {
    flatpickr('#dateRangeFilter', {
        mode: 'range',
        dateFormat: 'Y-m-d',
        placeholder: 'Select date range...',
        onChange: function (selectedDates, dateStr, instance) {
            if (selectedDates.length === 2) {
                applyFilters();
            }
        }
    });
}

// View Toggle
function initializeViewToggle() {
    const viewBtns = document.querySelectorAll('.view-btn');
    viewBtns.forEach(btn => {
        btn.addEventListener('click', function () {
            const view = this.getAttribute('data-view');
            switchView(view);
        });
    });
}

function switchView(view) {
    currentView = view;

    // Update active button
    document.querySelectorAll('.view-btn').forEach(btn => {
        btn.classList.remove('active');
        if (btn.getAttribute('data-view') === view) {
            btn.classList.add('active');
        }
    });

    // Show/hide views
    if (view === 'grid') {
        document.getElementById('reportsGridView').style.display = 'grid';
        document.getElementById('reportsListView').style.display = 'none';
    } else {
        document.getElementById('reportsGridView').style.display = 'none';
        document.getElementById('reportsListView').style.display = 'block';
    }

    renderReports();
}

// Filter Functions
function applyFilters() {
    const searchTerm = document.getElementById('searchReports').value.toLowerCase();
    const statusFilter = document.getElementById('statusFilter').value;
    const wasteTypeFilter = document.getElementById('wasteTypeFilter').value;
    const dateRange = document.getElementById('dateRangeFilter').value;

    filteredReports = allReports.filter(report => {
        // Search term filter
        if (searchTerm) {
            const searchFields = [
                report.ReportId?.toLowerCase(),
                report.WasteType?.toLowerCase(),
                report.Location?.toLowerCase(),
                report.Description?.toLowerCase()
            ];
            if (!searchFields.some(field => field?.includes(searchTerm))) {
                return false;
            }
        }

        // Status filter
        if (statusFilter !== 'all' && report.Status !== statusFilter) {
            return false;
        }

        // Waste type filter
        if (wasteTypeFilter !== 'all' && report.WasteType !== wasteTypeFilter) {
            return false;
        }

        // Date range filter
        if (dateRange) {
            const dates = dateRange.split(' to ');
            if (dates.length === 2) {
                const reportDate = new Date(report.ReportedDate);
                const startDate = new Date(dates[0]);
                const endDate = new Date(dates[1]);

                if (reportDate < startDate || reportDate > endDate) {
                    return false;
                }
            }
        }

        return true;
    });

    currentPage = 1;
    renderReports();
}

function clearFilters() {
    document.getElementById('searchReports').value = '';
    document.getElementById('statusFilter').value = 'all';
    document.getElementById('wasteTypeFilter').value = 'all';
    document.getElementById('dateRangeFilter').value = '';

    filteredReports = [...allReports];
    currentPage = 1;
    renderReports();
}

function sortReports() {
    const sortBy = document.getElementById('sortBy').value;

    filteredReports.sort((a, b) => {
        switch (sortBy) {
            case 'newest':
                return new Date(b.ReportedDate) - new Date(a.ReportedDate);
            case 'oldest':
                return new Date(a.ReportedDate) - new Date(b.ReportedDate);
            case 'weight-high':
                return (b.Weight || 0) - (a.Weight || 0);
            case 'weight-low':
                return (a.Weight || 0) - (b.Weight || 0);
            case 'xp-high':
                return (b.XPEarned || 0) - (a.XPEarned || 0);
            case 'xp-low':
                return (a.XPEarned || 0) - (b.XPEarned || 0);
            default:
                return 0;
        }
    });

    renderReports();
}

// Render Functions
function renderReports() {
    if (currentView === 'grid') {
        renderGridView();
    } else {
        renderListView();
    }
    updatePagination();
}

function renderGridView() {
    const grid = document.getElementById('reportsGridView');
    const emptyState = document.getElementById('reportsEmptyState');

    if (!grid) return;

    if (filteredReports.length === 0) {
        grid.style.display = 'none';
        emptyState.style.display = 'block';
        return;
    }

    grid.style.display = 'grid';
    emptyState.style.display = 'none';

    // Calculate pagination
    const startIndex = (currentPage - 1) * pageSize;
    const endIndex = Math.min(startIndex + pageSize, filteredReports.length);
    const pageReports = filteredReports.slice(startIndex, endIndex);

    // Clear existing content
    grid.innerHTML = '';

    // Generate report cards
    pageReports.forEach(report => {
        const card = createReportCard(report);
        grid.appendChild(card);
    });
}

function renderListView() {
    const tbody = document.getElementById('reportsTableBody');
    const emptyState = document.getElementById('reportsEmptyState');

    if (!tbody) return;

    if (filteredReports.length === 0) {
        tbody.innerHTML = '<tr><td colspan="8" class="text-center">No reports found</td></tr>';
        emptyState.style.display = 'block';
        return;
    }

    emptyState.style.display = 'none';

    // Calculate pagination
    const startIndex = (currentPage - 1) * pageSize;
    const endIndex = Math.min(startIndex + pageSize, filteredReports.length);
    const pageReports = filteredReports.slice(startIndex, endIndex);

    // Clear existing content
    tbody.innerHTML = '';

    // Generate table rows
    pageReports.forEach(report => {
        const row = createReportRow(report);
        tbody.appendChild(row);
    });
}

function createReportCard(report) {
    const card = document.createElement('div');
    card.className = `report-card status-${report.Status.toLowerCase().replace(' ', '-')}`;

    const wasteIcon = getWasteIcon(report.WasteType);
    const wasteTypeClass = getWasteTypeClass(report.WasteType);

    card.innerHTML = `
        <div class="report-header">
            <div class="report-id">${report.ReportId}</div>
            <div class="report-status status-${report.Status.toLowerCase().replace(' ', '-')}">
                ${report.Status}
            </div>
        </div>
        
        <div class="report-type">
            <div class="type-icon ${wasteTypeClass}">
                <i class="${wasteIcon}"></i>
            </div>
            <div class="type-name">${report.WasteType}</div>
        </div>
        
        <div class="report-details">
            <div class="report-detail">
                <i class="fas fa-weight-hanging"></i>
                <span>${report.Weight || '0'} kg</span>
            </div>
            <div class="report-detail">
                <i class="fas fa-map-marker-alt"></i>
                <span>${report.Location || 'Not specified'}</span>
            </div>
            <div class="report-detail">
                <i class="fas fa-calendar"></i>
                <span>${formatDate(report.ReportedDate)}</span>
            </div>
        </div>
        
        <div class="report-xp">
            <div>
                <div class="xp-amount">${report.XPEarned || '0'} XP</div>
                <div class="xp-label">Reward Earned</div>
            </div>
        </div>
        
        <div class="report-actions">
            <button class="btn-action view" onclick="viewReport('${report.ReportId}')">
                <i class="fas fa-eye"></i> View
            </button>
            ${(report.Status === 'Pending' || report.Status === 'Scheduled') ? `
                <button class="btn-action edit" onclick="editReport('${report.ReportId}')">
                    <i class="fas fa-edit"></i> Edit
                </button>
                <button class="btn-action delete" onclick="confirmDelete('${report.ReportId}')">
                    <i class="fas fa-trash"></i> Delete
                </button>
            ` : ''}
        </div>
    `;

    return card;
}

function createReportRow(report) {
    const row = document.createElement('tr');

    const wasteIcon = getWasteIcon(report.WasteType);
    const wasteTypeClass = getWasteTypeClass(report.WasteType);

    row.innerHTML = `
        <td>${report.ReportId}</td>
        <td>
            <div class="table-waste-info">
                <div class="type-icon ${wasteTypeClass}" style="width: 30px; height: 30px; font-size: 1rem;">
                    <i class="${wasteIcon}"></i>
                </div>
                <span>${report.WasteType}</span>
            </div>
        </td>
        <td>${report.Weight || '0'} kg</td>
        <td>${report.Location || 'Not specified'}</td>
        <td>
            <span class="report-status status-${report.Status.toLowerCase().replace(' ', '-')}">
                ${report.Status}
            </span>
        </td>
        <td>${formatDate(report.ReportedDate)}</td>
        <td>${report.XPEarned || '0'} XP</td>
        <td>
            <div class="report-actions" style="display: flex; gap: 4px;">
                <button class="btn-action view" onclick="viewReport('${report.ReportId}')" title="View">
                    <i class="fas fa-eye"></i>
                </button>
                ${(report.Status === 'Pending' || report.Status === 'Scheduled') ? `
                    <button class="btn-action edit" onclick="editReport('${report.ReportId}')" title="Edit">
                        <i class="fas fa-edit"></i>
                    </button>
                    <button class="btn-action delete" onclick="confirmDelete('${report.ReportId}')" title="Delete">
                        <i class="fas fa-trash"></i>
                    </button>
                ` : ''}
            </div>
        </td>
    `;

    return row;
}

function getWasteIcon(wasteType) {
    const icons = {
        'Plastic': 'fas fa-wine-bottle',
        'Paper': 'fas fa-newspaper',
        'Glass': 'fas fa-glass-whiskey',
        'Metal': 'fas fa-cogs',
        'E-Waste': 'fas fa-laptop',
        'Organic': 'fas fa-leaf'
    };
    return icons[wasteType] || 'fas fa-trash-alt';
}

function getWasteTypeClass(wasteType) {
    const classes = {
        'Plastic': 'type-plastic',
        'Paper': 'type-paper',
        'Glass': 'type-glass',
        'Metal': 'type-metal',
        'E-Waste': 'type-ewaste',
        'Organic': 'type-organic'
    };
    return classes[wasteType] || 'type-plastic';
}

function formatDate(dateString) {
    if (!dateString) return 'N/A';

    try {
        const date = new Date(dateString);
        return date.toLocaleDateString('en-US', {
            year: 'numeric',
            month: 'short',
            day: 'numeric'
        });
    } catch (error) {
        return 'Invalid Date';
    }
}

// Pagination
function updatePagination() {
    const totalPages = Math.ceil(filteredReports.length / pageSize);
    const startItem = (currentPage - 1) * pageSize + 1;
    const endItem = Math.min(currentPage * pageSize, filteredReports.length);

    // Update pagination info
    document.getElementById('paginationInfo').textContent =
        `Showing ${startItem}-${endItem} of ${filteredReports.length} reports`;

    // Update button states
    document.getElementById('prevPageBtn').disabled = currentPage === 1;
    document.getElementById('nextPageBtn').disabled = currentPage === totalPages || totalPages === 0;

    // Update page numbers
    updatePageNumbers(totalPages);
}

function updatePageNumbers(totalPages) {
    const pageNumbers = document.getElementById('pageNumbers');
    pageNumbers.innerHTML = '';

    // Show max 5 page numbers
    let startPage = Math.max(1, currentPage - 2);
    let endPage = Math.min(totalPages, startPage + 4);

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
    if (page < 1 || page > Math.ceil(filteredReports.length / pageSize)) return;

    currentPage = page;
    renderReports();

    // Scroll to top of reports section
    const reportsSection = document.querySelector('.reports-section');
    reportsSection.scrollIntoView({ behavior: 'smooth', block: 'start' });
}

function prevPage() {
    if (currentPage > 1) {
        currentPage--;
        renderReports();
    }
}

function nextPage() {
    const totalPages = Math.ceil(filteredReports.length / pageSize);
    if (currentPage < totalPages) {
        currentPage++;
        renderReports();
    }
}

// Report Actions
function viewReport(reportId) {
    const report = filteredReports.find(r => r.ReportId === reportId);
    if (!report) return;

    const wasteIcon = getWasteIcon(report.WasteType);
    const wasteTypeClass = getWasteTypeClass(report.WasteType);

    const detailsHTML = `
        <div class="detail-item">
            <div class="detail-label">Report ID</div>
            <div class="detail-value">${report.ReportId}</div>
        </div>
        
        <div class="detail-item">
            <div class="detail-label">Status</div>
            <div class="detail-value status status-${report.Status.toLowerCase().replace(' ', '-')}">
                ${report.Status}
            </div>
        </div>
        
        <div class="detail-item">
            <div class="detail-label">Waste Type</div>
            <div class="detail-value" style="display: flex; align-items: center; gap: 8px;">
                <div class="type-icon ${wasteTypeClass}" style="width: 24px; height: 24px; font-size: 0.8rem;">
                    <i class="${wasteIcon}"></i>
                </div>
                ${report.WasteType}
            </div>
        </div>
        
        <div class="detail-item">
            <div class="detail-label">Weight</div>
            <div class="detail-value">${report.Weight || '0'} kg</div>
        </div>
        
        <div class="detail-item">
            <div class="detail-label">Location</div>
            <div class="detail-value">${report.Location || 'Not specified'}</div>
        </div>
        
        <div class="detail-item">
            <div class="detail-label">Reported Date</div>
            <div class="detail-value">${formatDate(report.ReportedDate)}</div>
        </div>
        
        <div class="detail-item">
            <div class="detail-label">Scheduled Date</div>
            <div class="detail-value">${report.ScheduledDate ? formatDate(report.ScheduledDate) : 'Not scheduled'}</div>
        </div>
        
        <div class="detail-item">
            <div class="detail-label">XP Earned</div>
            <div class="detail-value">${report.XPEarned || '0'} XP</div>
        </div>
        
        <div class="detail-item full-width">
            <div class="detail-label">Description</div>
            <div class="detail-value">${report.Description || 'No description provided'}</div>
        </div>
        
        <div class="detail-item full-width">
            <div class="detail-label">Special Instructions</div>
            <div class="detail-value">${report.Instructions || 'No special instructions'}</div>
        </div>
    `;

    document.getElementById('reportDetailsContent').innerHTML = detailsHTML;

    // Show/hide edit button based on status
    const editBtn = document.getElementById('editReportBtn');
    if (report.Status === 'Pending' || report.Status === 'Scheduled') {
        editBtn.style.display = 'flex';
        editBtn.setAttribute('data-id', reportId);
    } else {
        editBtn.style.display = 'none';
    }

    document.getElementById('reportDetailsModal').style.display = 'flex';
}

function editReport(reportId) {
    showNotification('Edit functionality for report ' + reportId + ' would be implemented here', 'info');
    closeModal();
}

function confirmDelete(reportId) {
    const report = filteredReports.find(r => r.ReportId === reportId);
    if (!report) return;

    currentReportId = reportId;

    document.getElementById('deleteMessage').textContent =
        `Are you sure you want to delete report ${reportId} (${report.WasteType})? This action cannot be undone.`;

    document.getElementById('deleteConfirmationModal').style.display = 'flex';
}

function deleteReport() {
    if (!currentReportId) return;

    // In a real implementation, this would call the server to delete the report
    showNotification('Report ' + currentReportId + ' deleted successfully', 'success');

    // Remove from local arrays
    allReports = allReports.filter(r => r.ReportId !== currentReportId);
    filteredReports = filteredReports.filter(r => r.ReportId !== currentReportId);

    closeDeleteModal();
    renderReports();
}

// Export Functions
function exportReports() {
    document.getElementById('exportModal').style.display = 'flex';
}

function generateExport() {
    const format = document.querySelector('input[name="exportFormat"]:checked').value;
    const dateRange = document.getElementById('exportDateRange').value;

    showNotification(`Generating ${format.toUpperCase()} export... This would download the file.`, 'info');
    closeExportModal();
}

// Modal Functions
function closeModal() {
    document.getElementById('reportDetailsModal').style.display = 'none';
}

function closeDeleteModal() {
    document.getElementById('deleteConfirmationModal').style.display = 'none';
    currentReportId = null;
}

function closeExportModal() {
    document.getElementById('exportModal').style.display = 'none';
}

// Event Listeners
function setupEventListeners() {
    // Search input
    const searchInput = document.getElementById('searchReports');
    let searchTimeout;
    searchInput.addEventListener('input', function () {
        clearTimeout(searchTimeout);
        searchTimeout = setTimeout(() => {
            applyFilters();
        }, 500);
    });

    // Filter select changes
    document.getElementById('statusFilter').addEventListener('change', applyFilters);
    document.getElementById('wasteTypeFilter').addEventListener('change', applyFilters);

    // Close modals when clicking outside
    window.addEventListener('click', function (event) {
        const modals = ['reportDetailsModal', 'deleteConfirmationModal', 'exportModal'];
        modals.forEach(modalId => {
            const modal = document.getElementById(modalId);
            if (event.target === modal) {
                if (modalId === 'reportDetailsModal') closeModal();
                if (modalId === 'deleteConfirmationModal') closeDeleteModal();
                if (modalId === 'exportModal') closeExportModal();
            }
        });
    });
}

// Notification System
function showNotification(message, type) {
    // Remove existing notifications
    const existingNotifications = document.querySelectorAll('.custom-notification');
    existingNotifications.forEach(notif => notif.remove());

    // Create notification element
    const notification = document.createElement('div');
    notification.className = `custom-notification notification-${type}`;
    notification.innerHTML = `
        <div class="notification-content">
            <i class="fas ${type === 'success' ? 'fa-check-circle' :
            type === 'error' ? 'fa-exclamation-circle' :
                type === 'warning' ? 'fa-exclamation-triangle' :
                    'fa-info-circle'}"></i>
            <span>${message}</span>
        </div>
        <button class="notification-close" onclick="this.parentElement.remove()">
            <i class="fas fa-times"></i>
        </button>
    `;

    // Add styles
    notification.style.cssText = `
        position: fixed;
        top: 20px;
        right: 20px;
        padding: 16px;
        background: ${type === 'success' ? '#10b981' :
            type === 'error' ? '#ef4444' :
                type === 'warning' ? '#f59e0b' :
                    '#3b82f6'};
        color: white;
        border-radius: 8px;
        box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
        display: flex;
        align-items: center;
        gap: 12px;
        z-index: 10000;
        animation: slideIn 0.3s ease;
        max-width: 400px;
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

// Add CSS for slide-in animation
const style = document.createElement('style');
style.textContent = `
    @keyframes slideIn {
        from {
            transform: translateX(100%);
            opacity: 0;
        }
        to {
            transform: translateX(0);
            opacity: 1;
        }
    }
    
    .notification-close {
        background: none;
        border: none;
        color: white;
        cursor: pointer;
        padding: 0;
        margin-left: 8px;
    }
    
    .notification-content {
        display: flex;
        align-items: center;
        gap: 8px;
        flex: 1;
    }
`;
document.head.appendChild(style);

// Make functions globally available
window.applyFilters = applyFilters;
window.clearFilters = clearFilters;
window.sortReports = sortReports;
window.switchView = switchView;
window.prevPage = prevPage;
window.nextPage = nextPage;
window.viewReport = viewReport;
window.editReport = editReport;
window.confirmDelete = confirmDelete;
window.deleteReport = deleteReport;
window.exportReports = exportReports;
window.generateExport = generateExport;
window.closeModal = closeModal;
window.closeDeleteModal = closeDeleteModal;
window.closeExportModal = closeExportModal;