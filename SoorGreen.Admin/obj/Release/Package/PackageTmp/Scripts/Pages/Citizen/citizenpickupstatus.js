// Global variables
let activePickups = [];
let pickupHistory = [];
let filteredActive = [];
let filteredHistory = [];
let currentActivePage = 1;
let currentHistoryPage = 1;
const pageSize = 12;
let currentPickupId = null;
let currentView = 'grid';
let currentTab = 'active';

// Initialize when page loads
document.addEventListener('DOMContentLoaded', function () {
    initializePage();
});

function initializePage() {
    // Initialize date range picker
    initializeDatePicker();

    // Setup event listeners
    setupEventListeners();

    // Initialize view toggle
    initializeViewToggle();

    // Try to load data immediately
    tryLoadPickupsData();

    // Also try again after a delay
    setTimeout(tryLoadPickupsData, 500);
}

// Try to load data with multiple attempts
function tryLoadPickupsData(attempt = 1) {
    if (attempt > 3) {
        console.error('Failed to load data after 3 attempts');
        showNotification('Failed to load data. Please refresh the page.', 'error');
        showEmptyStates();
        return;
    }

    // Look for hidden fields with different possible IDs
    let activeDataElement = document.getElementById('hfActivePickups');
    let historyDataElement = document.getElementById('hfPickupHistory');
    let statsDataElement = document.getElementById('hfStatsData');

    // If not found, try other possible ID formats
    if (!activeDataElement) {
        // Try finding by name or other attributes
        activeDataElement = document.querySelector('input[type="hidden"][id*="ActivePickups"]');
    }
    if (!historyDataElement) {
        historyDataElement = document.querySelector('input[type="hidden"][id*="PickupHistory"]');
    }
    if (!statsDataElement) {
        statsDataElement = document.querySelector('input[type="hidden"][id*="StatsData"]');
    }

    console.log('Attempt', attempt, 'to find hidden fields:');
    console.log('Active:', activeDataElement);
    console.log('History:', historyDataElement);
    console.log('Stats:', statsDataElement);

    if (activeDataElement && historyDataElement && statsDataElement) {
        console.log('All hidden fields found! Loading data...');
        loadPickupsData(activeDataElement, historyDataElement, statsDataElement);
    } else {
        console.log('Some hidden fields not found, retrying...');
        setTimeout(() => tryLoadPickupsData(attempt + 1), 500);
    }
}

// Data Loading
function loadPickupsData(activeElement, historyElement, statsElement) {
    try {
        const activeData = activeElement.value;
        const historyData = historyElement.value;
        const statsData = statsElement.value;

        console.log('Active data:', activeData);
        console.log('History data:', historyData);
        console.log('Stats data:', statsData);

        if (activeData && activeData !== '[]') {
            activePickups = JSON.parse(activeData);
            filteredActive = [...activePickups];
        }

        if (historyData && historyData !== '[]') {
            pickupHistory = JSON.parse(historyData);
            filteredHistory = [...pickupHistory];
        }

        if (statsData && statsData !== '{}') {
            const stats = JSON.parse(statsData);
            updateStats(stats);
        }

        // Update tab badges
        const activeTabBadge = document.getElementById('activeTabBadge');
        const historyTabBadge = document.getElementById('historyTabBadge');

        if (activeTabBadge) activeTabBadge.textContent = activePickups.length;
        if (historyTabBadge) historyTabBadge.textContent = pickupHistory.length;

        // Render pickups
        renderActivePickups();
        renderHistoryPickups();

        console.log('Data loaded successfully!');
        console.log('Active pickups:', activePickups.length);
        console.log('History pickups:', pickupHistory.length);

    } catch (error) {
        console.error('Error loading pickups data:', error);
        showNotification('Error loading pickups data: ' + error.message, 'error');

        // Show empty states as fallback
        showEmptyStates();
    }
}

function showEmptyStates() {
    const activeEmptyState = document.getElementById('activeEmptyState');
    const historyEmptyState = document.getElementById('historyEmptyState');

    if (activeEmptyState) activeEmptyState.style.display = 'block';
    if (historyEmptyState) historyEmptyState.style.display = 'block';

    // Hide loading states
    const loadingStates = document.querySelectorAll('.loading-state');
    loadingStates.forEach(state => state.style.display = 'none');
}

function updateStats(stats) {
    const totalPickupsElement = document.getElementById('totalPickups');
    const activePickupsElement = document.getElementById('activePickups');
    const completedPickupsElement = document.getElementById('completedPickups');
    const successRateElement = document.getElementById('successRate');
    const totalXPElement = document.getElementById('totalXP');

    if (totalPickupsElement) totalPickupsElement.textContent = stats.TotalPickups || 0;
    if (activePickupsElement) activePickupsElement.textContent = stats.ActivePickups || 0;
    if (completedPickupsElement) completedPickupsElement.textContent = stats.CompletedPickups || 0;
    if (successRateElement) successRateElement.textContent = stats.SuccessRate || '0%';
    if (totalXPElement) totalXPElement.textContent = (stats.TotalXP || 0) + ' XP';
}

// Date Picker
function initializeDatePicker() {
    const dateRangeInput = document.getElementById('dateRangeFilter');
    if (dateRangeInput) {
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
}

// Tab Switching
function switchTab(tab) {
    currentTab = tab;

    // Update active tab
    document.querySelectorAll('.tab').forEach(t => {
        t.classList.remove('active');
        if (t.getAttribute('data-tab') === tab) {
            t.classList.add('active');
        }
    });

    // Show/hide tab content
    document.querySelectorAll('.tab-content').forEach(content => {
        content.style.display = 'none';
        content.classList.remove('active');
    });

    const activeTabContent = document.getElementById(tab + 'TabContent');
    if (activeTabContent) {
        activeTabContent.style.display = 'block';
        activeTabContent.classList.add('active');
    }
}

// View Toggle
function initializeViewToggle() {
    const viewBtns = document.querySelectorAll('.view-btn');
    viewBtns.forEach(btn => {
        btn.addEventListener('click', function () {
            const view = this.getAttribute('data-view');
            const tabContent = this.closest('.tab-content');
            if (tabContent && tabContent.id === 'activeTabContent') {
                switchView(view);
            } else {
                switchHistoryView(view);
            }
        });
    });
}

function switchView(view) {
    currentView = view;

    // Update active button
    const activeTabContent = document.getElementById('activeTabContent');
    if (activeTabContent) {
        activeTabContent.querySelectorAll('.view-btn').forEach(btn => {
            btn.classList.remove('active');
            if (btn.getAttribute('data-view') === view) {
                btn.classList.add('active');
            }
        });

        // Show/hide views
        const gridView = document.getElementById('activeGridView');
        const listView = document.getElementById('activeListView');

        if (gridView && listView) {
            if (view === 'grid') {
                gridView.style.display = 'grid';
                listView.style.display = 'none';
            } else {
                gridView.style.display = 'none';
                listView.style.display = 'block';
            }
        }

        renderActivePickups();
    }
}

function switchHistoryView(view) {
    const historyTabContent = document.getElementById('historyTabContent');
    if (historyTabContent) {
        // Update active button
        historyTabContent.querySelectorAll('.view-btn').forEach(btn => {
            btn.classList.remove('active');
            if (btn.getAttribute('data-view') === view) {
                btn.classList.add('active');
            }
        });

        // Show/hide views
        const gridView = document.getElementById('historyGridView');
        const listView = document.getElementById('historyListView');

        if (gridView && listView) {
            if (view === 'grid') {
                gridView.style.display = 'grid';
                listView.style.display = 'none';
            } else {
                gridView.style.display = 'none';
                listView.style.display = 'block';
            }
        }

        renderHistoryPickups();
    }
}

// Filter Functions
function applyFilters() {
    const searchTerm = document.getElementById('searchPickups')?.value.toLowerCase() || '';
    const statusFilter = document.getElementById('statusFilter')?.value || 'all';
    const wasteTypeFilter = document.getElementById('wasteTypeFilter')?.value || 'all';
    const dateRange = document.getElementById('dateRangeFilter')?.value || '';

    // Filter active pickups
    filteredActive = activePickups.filter(pickup => {
        if (searchTerm) {
            const searchFields = [
                pickup.PickupId?.toLowerCase(),
                pickup.WasteType?.toLowerCase(),
                pickup.Address?.toLowerCase(),
                pickup.CollectorName?.toLowerCase()
            ];
            if (!searchFields.some(field => field && field.includes(searchTerm))) {
                return false;
            }
        }

        if (statusFilter !== 'all' && pickup.Status !== statusFilter) {
            return false;
        }

        if (wasteTypeFilter !== 'all' && pickup.WasteType !== wasteTypeFilter) {
            return false;
        }

        if (dateRange) {
            const dates = dateRange.split(' to ');
            if (dates.length === 2) {
                const pickupDate = new Date(pickup.ScheduledDate || pickup.CreatedDate);
                const startDate = new Date(dates[0]);
                const endDate = new Date(dates[1]);

                if (pickupDate < startDate || pickupDate > endDate) {
                    return false;
                }
            }
        }

        return true;
    });

    // Filter history pickups
    filteredHistory = pickupHistory.filter(pickup => {
        if (searchTerm) {
            const searchFields = [
                pickup.PickupId?.toLowerCase(),
                pickup.WasteType?.toLowerCase(),
                pickup.Address?.toLowerCase(),
                pickup.CollectorName?.toLowerCase()
            ];
            if (!searchFields.some(field => field && field.includes(searchTerm))) {
                return false;
            }
        }

        if (statusFilter !== 'all' && pickup.Status !== statusFilter) {
            return false;
        }

        if (wasteTypeFilter !== 'all' && pickup.WasteType !== wasteTypeFilter) {
            return false;
        }

        if (dateRange) {
            const dates = dateRange.split(' to ');
            if (dates.length === 2) {
                const pickupDate = new Date(pickup.CompletedDate || pickup.ScheduledDate);
                const startDate = new Date(dates[0]);
                const endDate = new Date(dates[1]);

                if (pickupDate < startDate || pickupDate > endDate) {
                    return false;
                }
            }
        }

        return true;
    });

    currentActivePage = 1;
    currentHistoryPage = 1;
    renderActivePickups();
    renderHistoryPickups();
}

function clearFilters() {
    const searchInput = document.getElementById('searchPickups');
    const statusFilter = document.getElementById('statusFilter');
    const wasteTypeFilter = document.getElementById('wasteTypeFilter');
    const dateRangeFilter = document.getElementById('dateRangeFilter');

    if (searchInput) searchInput.value = '';
    if (statusFilter) statusFilter.value = 'all';
    if (wasteTypeFilter) wasteTypeFilter.value = 'all';
    if (dateRangeFilter) dateRangeFilter.value = '';

    filteredActive = [...activePickups];
    filteredHistory = [...pickupHistory];
    currentActivePage = 1;
    currentHistoryPage = 1;
    renderActivePickups();
    renderHistoryPickups();
}

function sortPickups() {
    const sortByElement = document.getElementById('sortBy');
    if (!sortByElement) return;

    const sortBy = sortByElement.value;

    filteredActive.sort((a, b) => {
        switch (sortBy) {
            case 'date-newest':
                return new Date(b.ScheduledDate || b.CreatedDate) - new Date(a.ScheduledDate || a.CreatedDate);
            case 'date-oldest':
                return new Date(a.ScheduledDate || a.CreatedDate) - new Date(b.ScheduledDate || b.CreatedDate);
            case 'weight-high':
                return (parseFloat(b.Weight) || 0) - (parseFloat(a.Weight) || 0);
            case 'status':
                return a.Status.localeCompare(b.Status);
            default:
                return 0;
        }
    });

    renderActivePickups();
}

function sortHistory() {
    const historySortByElement = document.getElementById('historySortBy');
    if (!historySortByElement) return;

    const sortBy = historySortByElement.value;

    filteredHistory.sort((a, b) => {
        switch (sortBy) {
            case 'date-newest':
                return new Date(b.CompletedDate || b.ScheduledDate) - new Date(a.CompletedDate || a.ScheduledDate);
            case 'date-oldest':
                return new Date(a.CompletedDate || a.ScheduledDate) - new Date(b.CompletedDate || b.ScheduledDate);
            case 'xp-high':
                return (parseInt(b.XPEarned) || 0) - (parseInt(a.XPEarned) || 0);
            case 'weight-high':
                return (parseFloat(b.Weight) || 0) - (parseFloat(a.Weight) || 0);
            default:
                return 0;
        }
    });

    renderHistoryPickups();
}

// Render Functions
function renderActivePickups() {
    const gridView = document.getElementById('activeGridView');
    const listView = document.getElementById('activeListView');
    const emptyState = document.getElementById('activeEmptyState');

    if (!gridView || !listView || !emptyState) return;

    if (filteredActive.length === 0) {
        gridView.style.display = 'none';
        listView.style.display = 'none';
        emptyState.style.display = 'block';
        updatePagination('active');
        return;
    }

    emptyState.style.display = 'none';

    if (currentView === 'grid') {
        renderGridView('active');
    } else {
        renderListView('active');
    }
    updatePagination('active');
}

function renderHistoryPickups() {
    const gridView = document.getElementById('historyGridView');
    const listView = document.getElementById('historyListView');
    const emptyState = document.getElementById('historyEmptyState');

    if (!gridView || !listView || !emptyState) return;

    const view = document.querySelector('#historyTabContent .view-btn.active')?.getAttribute('data-view') || 'grid';

    if (filteredHistory.length === 0) {
        gridView.style.display = 'none';
        listView.style.display = 'none';
        emptyState.style.display = 'block';
        updatePagination('history');
        return;
    }

    emptyState.style.display = 'none';

    if (view === 'grid') {
        renderGridView('history');
    } else {
        renderListView('history');
    }
    updatePagination('history');
}

function renderGridView(type) {
    const containerId = type === 'active' ? 'activeGridView' : 'historyGridView';
    const container = document.getElementById(containerId);
    const pickups = type === 'active' ? filteredActive : filteredHistory;
    const currentPage = type === 'active' ? currentActivePage : currentHistoryPage;

    if (!container) return;

    // Calculate pagination
    const startIndex = (currentPage - 1) * pageSize;
    const endIndex = Math.min(startIndex + pageSize, pickups.length);
    const pagePickups = pickups.slice(startIndex, endIndex);

    // Clear existing content
    container.innerHTML = '';

    // Generate pickup cards
    pagePickups.forEach(pickup => {
        const card = createPickupCard(pickup, type);
        container.appendChild(card);
    });
}

function renderListView(type) {
    const tbodyId = type === 'active' ? 'activeTableBody' : 'historyTableBody';
    const tbody = document.getElementById(tbodyId);
    const pickups = type === 'active' ? filteredActive : filteredHistory;
    const currentPage = type === 'active' ? currentActivePage : currentHistoryPage;

    if (!tbody) return;

    // Calculate pagination
    const startIndex = (currentPage - 1) * pageSize;
    const endIndex = Math.min(startIndex + pageSize, pickups.length);
    const pagePickups = pickups.slice(startIndex, endIndex);

    // Clear existing content
    tbody.innerHTML = '';

    // Generate table rows
    pagePickups.forEach(pickup => {
        const row = createPickupRow(pickup, type);
        tbody.appendChild(row);
    });
}

function createPickupCard(pickup, type) {
    const card = document.createElement('div');
    card.className = `pickup-card status-${pickup.Status.toLowerCase().replace(' ', '-')}`;

    const wasteIcon = getWasteIcon(pickup.WasteType);
    const wasteTypeClass = getWasteTypeClass(pickup.WasteType);
    const isHistory = type === 'history';

    card.innerHTML = `
        <div class="pickup-header">
            <div class="pickup-id">${escapeHtml(pickup.PickupId)}</div>
            <div class="pickup-status status-${pickup.Status.toLowerCase().replace(' ', '-')}">
                ${escapeHtml(pickup.Status)}
            </div>
        </div>
        
        <div class="pickup-type">
            <div class="type-icon ${wasteTypeClass}">
                <i class="${wasteIcon}"></i>
            </div>
            <div class="type-name">${escapeHtml(pickup.WasteType)}</div>
        </div>
        
        <div class="pickup-details">
            <div class="pickup-detail">
                <i class="fas fa-weight-hanging"></i>
                <span>${escapeHtml(pickup.Weight || '0')} kg</span>
            </div>
            <div class="pickup-detail">
                <i class="fas fa-map-marker-alt"></i>
                <span>${escapeHtml(pickup.Address || 'Not specified')}</span>
            </div>
            <div class="pickup-detail">
                <i class="fas fa-calendar"></i>
                <span>${isHistory ? formatDate(pickup.CompletedDate) : formatDate(pickup.ScheduledDate)}</span>
            </div>
            ${pickup.CollectorName ? `
            <div class="pickup-detail">
                <i class="fas fa-user"></i>
                <span>${escapeHtml(pickup.CollectorName)}</span>
            </div>` : ''}
        </div>
        
        ${isHistory ? `
        <div class="pickup-xp">
            <div>
                <div class="xp-amount">${escapeHtml(pickup.XPEarned || '0')} XP</div>
                <div class="xp-label">Reward Earned</div>
            </div>
        </div>` : ''}
        
        <div class="pickup-actions">
            <button class="btn-action view" onclick="viewPickup('${escapeHtml(pickup.PickupId)}')">
                <i class="fas fa-eye"></i> View
            </button>
            ${!isHistory && (pickup.Status === 'Requested' || pickup.Status === 'Scheduled') ? `
                <button class="btn-action edit" onclick="reschedulePickup('${escapeHtml(pickup.PickupId)}')">
                    <i class="fas fa-calendar-alt"></i> Reschedule
                </button>
                <button class="btn-action delete" onclick="confirmCancel('${escapeHtml(pickup.PickupId)}')">
                    <i class="fas fa-times-circle"></i> Cancel
                </button>
            ` : ''}
        </div>
    `;

    return card;
}

function createPickupRow(pickup, type) {
    const row = document.createElement('tr');
    const wasteIcon = getWasteIcon(pickup.WasteType);
    const wasteTypeClass = getWasteTypeClass(pickup.WasteType);
    const isHistory = type === 'history';

    row.innerHTML = `
        <td>${escapeHtml(pickup.PickupId)}</td>
        <td>
            <div style="display: flex; align-items: center; gap: 8px;">
                <div class="type-icon ${wasteTypeClass}" style="width: 24px; height: 24px; font-size: 0.8rem; border-radius: 6px;">
                    <i class="${wasteIcon}"></i>
                </div>
                ${escapeHtml(pickup.WasteType)}
            </div>
        </td>
        <td>${escapeHtml(pickup.Weight || '0')} kg</td>
        <td>${escapeHtml(pickup.Address || 'Not specified')}</td>
        <td>${isHistory ? formatDate(pickup.CompletedDate) : formatDate(pickup.ScheduledDate)}</td>
        <td>${escapeHtml(pickup.CollectorName || 'Not assigned')}</td>
        ${isHistory ? `<td>${escapeHtml(pickup.XPEarned || '0')} XP</td>` : ''}
        <td>
            <span class="pickup-status status-${pickup.Status.toLowerCase().replace(' ', '-')}">
                ${escapeHtml(pickup.Status)}
            </span>
        </td>
        <td>
            <div class="pickup-actions" style="display: flex; gap: 4px;">
                <button class="btn-action view" onclick="viewPickup('${escapeHtml(pickup.PickupId)}')" title="View">
                    <i class="fas fa-eye"></i>
                </button>
                ${!isHistory && (pickup.Status === 'Requested' || pickup.Status === 'Scheduled') ? `
                    <button class="btn-action edit" onclick="reschedulePickup('${escapeHtml(pickup.PickupId)}')" title="Reschedule">
                        <i class="fas fa-calendar-alt"></i>
                    </button>
                    <button class="btn-action delete" onclick="confirmCancel('${escapeHtml(pickup.PickupId)}')" title="Cancel">
                        <i class="fas fa-times-circle"></i>
                    </button>
                ` : ''}
            </div>
        </td>
    `;

    return row;
}

// Helper Functions
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
    if (!dateString || dateString === 'null' || dateString === 'undefined') return 'Not scheduled';

    try {
        const date = new Date(dateString);
        return date.toLocaleDateString('en-US', {
            year: 'numeric',
            month: 'short',
            day: 'numeric',
            hour: '2-digit',
            minute: '2-digit'
        });
    } catch (error) {
        console.error('Error formatting date:', dateString, error);
        return 'Invalid Date';
    }
}

function escapeHtml(text) {
    if (!text) return '';
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
}

// Pagination
function updatePagination(type) {
    const pickups = type === 'active' ? filteredActive : filteredHistory;
    const currentPage = type === 'active' ? currentActivePage : currentHistoryPage;
    const totalPages = Math.ceil(pickups.length / pageSize);
    const startItem = (currentPage - 1) * pageSize + 1;
    const endItem = Math.min(currentPage * pageSize, pickups.length);

    // Update pagination info
    const infoId = type === 'active' ? 'activePaginationInfo' : 'historyPaginationInfo';
    const infoElement = document.getElementById(infoId);
    if (infoElement) {
        infoElement.textContent = `Showing ${startItem}-${endItem} of ${pickups.length} ${type === 'active' ? 'active' : 'historical'} pickups`;
    }

    // Update button states
    const prevBtnId = type === 'active' ? 'activePrevPageBtn' : 'historyPrevPageBtn';
    const nextBtnId = type === 'active' ? 'activeNextPageBtn' : 'historyNextPageBtn';

    const prevBtn = document.getElementById(prevBtnId);
    const nextBtn = document.getElementById(nextBtnId);

    if (prevBtn) prevBtn.disabled = currentPage === 1;
    if (nextBtn) nextBtn.disabled = currentPage === totalPages || totalPages === 0;

    // Update page numbers
    updatePageNumbers(type, totalPages);
}

function updatePageNumbers(type, totalPages) {
    const pageNumbersId = type === 'active' ? 'activePageNumbers' : 'historyPageNumbers';
    const pageNumbers = document.getElementById(pageNumbersId);
    const currentPage = type === 'active' ? currentActivePage : currentHistoryPage;

    if (!pageNumbers) return;

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
        pageNumber.onclick = () => goToPage(i, type);
        pageNumbers.appendChild(pageNumber);
    }
}

function goToPage(page, type) {
    if (type === 'active') {
        const totalPages = Math.ceil(filteredActive.length / pageSize);
        if (page < 1 || page > totalPages) return;
        currentActivePage = page;
        renderActivePickups();
    } else {
        const totalPages = Math.ceil(filteredHistory.length / pageSize);
        if (page < 1 || page > totalPages) return;
        currentHistoryPage = page;
        renderHistoryPickups();
    }
}

function prevPage(type) {
    if (type === 'active') {
        if (currentActivePage > 1) {
            currentActivePage--;
            renderActivePickups();
        }
    } else {
        if (currentHistoryPage > 1) {
            currentHistoryPage--;
            renderHistoryPickups();
        }
    }
}

function nextPage(type) {
    if (type === 'active') {
        const totalPages = Math.ceil(filteredActive.length / pageSize);
        if (currentActivePage < totalPages) {
            currentActivePage++;
            renderActivePickups();
        }
    } else {
        const totalPages = Math.ceil(filteredHistory.length / pageSize);
        if (currentHistoryPage < totalPages) {
            currentHistoryPage++;
            renderHistoryPickups();
        }
    }
}

// Pickup Actions
function viewPickup(pickupId) {
    let pickup;
    if (currentTab === 'active') {
        pickup = filteredActive.find(p => p.PickupId === pickupId) ||
            activePickups.find(p => p.PickupId === pickupId);
    } else {
        pickup = filteredHistory.find(p => p.PickupId === pickupId) ||
            pickupHistory.find(p => p.PickupId === pickupId);
    }

    if (!pickup) {
        showNotification('Pickup not found', 'error');
        return;
    }

    const wasteIcon = getWasteIcon(pickup.WasteType);
    const wasteTypeClass = getWasteTypeClass(pickup.WasteType);

    const detailsHTML = `
        <div class="detail-item">
            <div class="detail-label">Pickup ID</div>
            <div class="detail-value">${escapeHtml(pickup.PickupId)}</div>
        </div>
        
        <div class="detail-item">
            <div class="detail-label">Status</div>
            <div class="detail-value status status-${pickup.Status.toLowerCase().replace(' ', '-')}">
                ${escapeHtml(pickup.Status)}
            </div>
        </div>
        
        <div class="detail-item">
            <div class="detail-label">Waste Type</div>
            <div class="detail-value">
                <div style="display: flex; align-items: center; gap: 8px;">
                    <div class="type-icon ${wasteTypeClass}" style="width: 24px; height: 24px; font-size: 0.8rem; border-radius: 6px;">
                        <i class="${wasteIcon}"></i>
                    </div>
                    ${escapeHtml(pickup.WasteType)}
                </div>
            </div>
        </div>
        
        <div class="detail-item">
            <div class="detail-label">Weight</div>
            <div class="detail-value">${escapeHtml(pickup.Weight || '0')} kg</div>
        </div>
        
        <div class="detail-item full-width">
            <div class="detail-label">Address</div>
            <div class="detail-value">${escapeHtml(pickup.Address || 'Not specified')}</div>
        </div>
        
        <div class="detail-item">
            <div class="detail-label">Scheduled Date</div>
            <div class="detail-value">${formatDate(pickup.ScheduledDate)}</div>
        </div>
        
        ${pickup.CollectorName ? `
        <div class="detail-item">
            <div class="detail-label">Collector</div>
            <div class="detail-value">${escapeHtml(pickup.CollectorName)}</div>
        </div>` : ''}
        
        ${pickup.XPEarned && pickup.XPEarned !== '0' ? `
        <div class="detail-item">
            <div class="detail-label">XP Earned</div>
            <div class="detail-value">${escapeHtml(pickup.XPEarned)} XP</div>
        </div>` : ''}
        
        <div class="detail-item">
            <div class="detail-label">Created Date</div>
            <div class="detail-value">${formatDate(pickup.CreatedDate)}</div>
        </div>
        
        ${pickup.CompletedDate ? `
        <div class="detail-item">
            <div class="detail-label">Completed Date</div>
            <div class="detail-value">${formatDate(pickup.CompletedDate)}</div>
        </div>` : ''}
        
        ${pickup.Description ? `
        <div class="detail-item full-width">
            <div class="detail-label">Description</div>
            <div class="detail-value">${escapeHtml(pickup.Description)}</div>
        </div>` : ''}
        
        ${pickup.Instructions ? `
        <div class="detail-item full-width">
            <div class="detail-label">Special Instructions</div>
            <div class="detail-value">${escapeHtml(pickup.Instructions)}</div>
        </div>` : ''}
    `;

    const pickupDetailsContent = document.getElementById('pickupDetailsContent');
    if (pickupDetailsContent) {
        pickupDetailsContent.innerHTML = detailsHTML;
    }

    // Show/hide action buttons based on status
    const cancelBtn = document.getElementById('cancelPickupBtn');
    const rescheduleBtn = document.getElementById('reschedulePickupBtn');

    if (cancelBtn && rescheduleBtn) {
        if (pickup.Status === 'Requested' || pickup.Status === 'Scheduled') {
            cancelBtn.style.display = 'flex';
            rescheduleBtn.style.display = 'flex';
            cancelBtn.setAttribute('data-id', pickupId);
            rescheduleBtn.setAttribute('data-id', pickupId);
        } else {
            cancelBtn.style.display = 'none';
            rescheduleBtn.style.display = 'none';
        }
    }

    const pickupDetailsModal = document.getElementById('pickupDetailsModal');
    if (pickupDetailsModal) {
        pickupDetailsModal.style.display = 'flex';
    }
}

function reschedulePickup(pickupId = null) {
    const rescheduleBtn = document.getElementById('reschedulePickupBtn');
    const id = pickupId || rescheduleBtn?.getAttribute('data-id');
    if (id) {
        showNotification('Reschedule functionality for pickup ' + id + ' would be implemented here', 'info');
        closeModal();
    }
}

function confirmCancel(pickupId) {
    const pickup = [...activePickups, ...pickupHistory].find(p => p.PickupId === pickupId);
    if (!pickup) {
        showNotification('Pickup not found', 'error');
        return;
    }

    currentPickupId = pickupId;

    const cancelMessage = document.getElementById('cancelMessage');
    if (cancelMessage) {
        cancelMessage.textContent =
            `Are you sure you want to cancel pickup ${pickupId} (${pickup.WasteType})? This action cannot be undone.`;
    }

    const cancelConfirmationModal = document.getElementById('cancelConfirmationModal');
    if (cancelConfirmationModal) {
        cancelConfirmationModal.style.display = 'flex';
    }
}

function cancelPickup() {
    if (!currentPickupId) {
        showNotification('No pickup selected', 'error');
        return;
    }

    // In a real implementation, this would call the server to cancel the pickup
    showNotification('Pickup ' + currentPickupId + ' cancelled successfully', 'success');

    // Remove from active pickups and move to history
    const pickupIndex = activePickups.findIndex(p => p.PickupId === currentPickupId);
    if (pickupIndex > -1) {
        const cancelledPickup = activePickups[pickupIndex];
        cancelledPickup.Status = 'Cancelled';
        cancelledPickup.CompletedDate = new Date().toISOString();

        // Move to history
        pickupHistory.unshift(cancelledPickup);
        activePickups.splice(pickupIndex, 1);
    }

    // Update filtered arrays
    filteredActive = activePickups.filter(p => p.PickupId !== currentPickupId);
    filteredHistory = [...pickupHistory];

    // Update stats and badges
    updateStats({
        TotalPickups: activePickups.length + pickupHistory.length,
        ActivePickups: activePickups.length,
        CompletedPickups: pickupHistory.filter(p => p.Status === 'Completed').length,
        SuccessRate: '0%',
        TotalXP: pickupHistory.reduce((sum, p) => sum + (parseInt(p.XPEarned) || 0), 0)
    });

    const activeTabBadge = document.getElementById('activeTabBadge');
    const historyTabBadge = document.getElementById('historyTabBadge');

    if (activeTabBadge) activeTabBadge.textContent = activePickups.length;
    if (historyTabBadge) historyTabBadge.textContent = pickupHistory.length;

    closeCancelModal();
    closeModal();
    renderActivePickups();
    renderHistoryPickups();
}

function showCancelConfirmation() {
    const cancelBtn = document.getElementById('cancelPickupBtn');
    const pickupId = cancelBtn?.getAttribute('data-id');
    if (pickupId) {
        confirmCancel(pickupId);
    }
}

// Export Functions
function exportPickups() {
    const exportModal = document.getElementById('exportModal');
    if (exportModal) {
        exportModal.style.display = 'flex';
    }
}

function generateExport() {
    const format = document.querySelector('input[name="exportFormat"]:checked')?.value;
    const dateRange = document.getElementById('exportDateRange')?.value;

    showNotification(`Generating ${format?.toUpperCase() || 'PDF'} export... This would download the file.`, 'info');
    closeExportModal();
}

// Modal Functions
function closeModal() {
    const pickupDetailsModal = document.getElementById('pickupDetailsModal');
    if (pickupDetailsModal) {
        pickupDetailsModal.style.display = 'none';
    }
}

function closeCancelModal() {
    const cancelConfirmationModal = document.getElementById('cancelConfirmationModal');
    if (cancelConfirmationModal) {
        cancelConfirmationModal.style.display = 'none';
    }
    currentPickupId = null;
}

function closeExportModal() {
    const exportModal = document.getElementById('exportModal');
    if (exportModal) {
        exportModal.style.display = 'none';
    }
}

// Event Listeners
function setupEventListeners() {
    // Search input
    const searchInput = document.getElementById('searchPickups');
    let searchTimeout;
    if (searchInput) {
        searchInput.addEventListener('input', function () {
            clearTimeout(searchTimeout);
            searchTimeout = setTimeout(() => {
                applyFilters();
            }, 500);
        });
    }

    // Filter select changes
    const statusFilter = document.getElementById('statusFilter');
    const wasteTypeFilter = document.getElementById('wasteTypeFilter');

    if (statusFilter) {
        statusFilter.addEventListener('change', applyFilters);
    }

    if (wasteTypeFilter) {
        wasteTypeFilter.addEventListener('change', applyFilters);
    }

    // Close modals when clicking outside
    window.addEventListener('click', function (event) {
        const modals = ['pickupDetailsModal', 'cancelConfirmationModal', 'exportModal'];
        modals.forEach(modalId => {
            const modal = document.getElementById(modalId);
            if (event.target === modal) {
                if (modalId === 'pickupDetailsModal') closeModal();
                if (modalId === 'cancelConfirmationModal') closeCancelModal();
                if (modalId === 'exportModal') closeExportModal();
            }
        });
    });

    // Keyboard shortcuts
    document.addEventListener('keydown', function (event) {
        if (event.key === 'Escape') {
            closeModal();
            closeCancelModal();
            closeExportModal();
        }
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

    const icon = type === 'success' ? 'fa-check-circle' :
        type === 'error' ? 'fa-exclamation-circle' :
            type === 'warning' ? 'fa-exclamation-triangle' : 'fa-info-circle';

    notification.innerHTML = `
        <div class="notification-content">
            <i class="fas ${icon}"></i>
            <span>${escapeHtml(message)}</span>
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
        padding: 16px 20px;
        background: ${type === 'success' ? '#10b981' :
            type === 'error' ? '#ef4444' :
                type === 'warning' ? '#f59e0b' : '#3b82f6'};
        color: white;
        border-radius: 8px;
        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
        display: flex;
        align-items: center;
        gap: 12px;
        z-index: 9999;
        animation: slideIn 0.3s ease;
        max-width: 400px;
        font-family: 'Inter', sans-serif;
        font-size: 14px;
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
if (!document.querySelector('#notification-styles')) {
    const style = document.createElement('style');
    style.id = 'notification-styles';
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
            display: flex;
            align-items: center;
            justify-content: center;
            width: 24px;
            height: 24px;
            border-radius: 4px;
            transition: background-color 0.2s;
        }
        
        .notification-close:hover {
            background: rgba(255, 255, 255, 0.1);
        }
        
        .notification-content {
            display: flex;
            align-items: center;
            gap: 8px;
            flex: 1;
        }
    `;
    document.head.appendChild(style);
}

// Debug function to inspect hidden fields
function debugHiddenFields() {
    console.log('=== DEBUG: All Hidden Fields ===');
    const allHiddenFields = document.querySelectorAll('input[type="hidden"]');
    allHiddenFields.forEach(field => {
        console.log('ID:', field.id, 'Name:', field.name, 'Value:', field.value);
    });
    console.log('=== END DEBUG ===');
}

// Call debug on page load
setTimeout(debugHiddenFields, 1000);

// Make functions globally available
window.applyFilters = applyFilters;
window.clearFilters = clearFilters;
window.sortPickups = sortPickups;
window.sortHistory = sortHistory;
window.switchView = switchView;
window.switchHistoryView = switchHistoryView;
window.switchTab = switchTab;
window.prevPage = prevPage;
window.nextPage = nextPage;
window.viewPickup = viewPickup;
window.reschedulePickup = reschedulePickup;
window.confirmCancel = confirmCancel;
window.cancelPickup = cancelPickup;
window.showCancelConfirmation = showCancelConfirmation;
window.exportPickups = exportPickups;
window.generateExport = generateExport;
window.closeModal = closeModal;
window.closeCancelModal = closeCancelModal;
window.closeExportModal = closeExportModal;