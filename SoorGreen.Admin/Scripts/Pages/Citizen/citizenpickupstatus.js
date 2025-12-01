
            // GLOBAL VARIABLES
            let currentTab = 'active';
            let currentView = 'grid';
            let currentPage = 1;
            let historyPage = 1;
            const pickupsPerPage = 6;
            let filteredPickups = [];
            let allActivePickups = [];
            let filteredHistory = [];
            let allHistory = [];
            let currentPickupId = null;
            let currentCancelPickupId = null;

            // DEBUG: Check on page load
            console.log('=== DEBUG: Page loaded ===');
            console.log('DEBUG: hfActivePickups element:', document.getElementById('<%= hfActivePickups.ClientID %>'));
            console.log('DEBUG: hfActivePickups value:', document.getElementById('<%= hfActivePickups.ClientID %>') ? document.getElementById('<%= hfActivePickups.ClientID %>').value : 'Element not found');
            console.log('DEBUG: hfStatsData value:', document.getElementById('<%= hfStatsData.ClientID %>') ? document.getElementById('<%= hfStatsData.ClientID %>').value : 'Element not found');

        // INITIALIZE
        document.addEventListener('DOMContentLoaded', function () {
            console.log('=== DEBUG: DOM Content Loaded ===');
            initializeEventListeners();
            loadPageData();
        });

        function initializeEventListeners() {
            // Tab switching
            document.querySelectorAll('.tab').forEach(tab => {
                tab.addEventListener('click', function (e) {
                    e.preventDefault();
                    const tabName = this.getAttribute('data-tab');
                    switchTab(tabName);
                });
            });

            // View buttons for active pickups
            document.querySelectorAll('.view-btn:not([data-section="history"])').forEach(btn => {
                btn.addEventListener('click', function (e) {
                    e.preventDefault();
                    const view = this.getAttribute('data-view');
                    changeView(view);
                });
            });

            // View buttons for history
            document.querySelectorAll('.view-btn[data-section="history"]').forEach(btn => {
                btn.addEventListener('click', function (e) {
                    e.preventDefault();
                    const view = this.getAttribute('data-view');
                    changeHistoryView(view);
                });
            });

            // Filter button
            document.getElementById('applyFiltersBtn').addEventListener('click', function (e) {
                e.preventDefault();
                applyFilters();
            });

            // Search input
            document.getElementById('searchPickups').addEventListener('input', function (e) {
                applyFilters();
            });

            // Filter dropdowns
            document.getElementById('statusFilter').addEventListener('change', function (e) {
                applyFilters();
            });

            document.getElementById('dateFilter').addEventListener('change', function (e) {
                applyFilters();
            });

            // Modal close buttons
            document.querySelector('#viewPickupModal .close-modal').addEventListener('click', closeViewPickupModal);
            document.querySelector('#cancelPickupModal .close-modal').addEventListener('click', closeCancelModal);
            document.getElementById('closePickupModalBtn').addEventListener('click', closeViewPickupModal);
            document.getElementById('cancelCancelBtn').addEventListener('click', closeCancelModal);
            document.getElementById('confirmCancelBtn').addEventListener('click', confirmCancelPickup);

            // Close modals when clicking outside
            document.getElementById('viewPickupModal').addEventListener('click', function (e) {
                if (e.target === this) closeViewPickupModal();
            });
            document.getElementById('cancelPickupModal').addEventListener('click', function (e) {
                if (e.target === this) closeCancelModal();
            });
        }

        function switchTab(tabName) {
            currentTab = tabName;
            
            // Update tab buttons
            document.querySelectorAll('.tab').forEach(tab => {
                tab.classList.remove('active');
                if (tab.getAttribute('data-tab') === tabName) {
                    tab.classList.add('active');
                }
            });
            
            // Show/hide tab content
            document.querySelectorAll('.tab-content').forEach(content => {
                content.style.display = 'none';
                if (content.id === tabName + 'Tab') {
                    content.style.display = 'block';
                }
            });
            
            // Reset to first page when switching tabs
            if (tabName === 'active') {
                currentPage = 1;
                renderActivePickups();
                updatePagination();
            } else if (tabName === 'history') {
                historyPage = 1;
                renderPickupHistory();
                updateHistoryPagination();
            }
        }

        function changeView(view) {
            currentView = view;

            // Update active button
            document.querySelectorAll('.view-btn:not([data-section="history"])').forEach(btn => {
                btn.classList.remove('active');
                if (btn.getAttribute('data-view') === view) {
                    btn.classList.add('active');
                }
            });

            // Show/hide views
            document.getElementById('gridView').style.display = view === 'grid' ? 'block' : 'none';
            document.getElementById('tableView').style.display = view === 'table' ? 'block' : 'none';

            renderActivePickups();
        }

        function changeHistoryView(view) {
            // Update active button
            document.querySelectorAll('.view-btn[data-section="history"]').forEach(btn => {
                btn.classList.remove('active');
                if (btn.getAttribute('data-view') === view) {
                    btn.classList.add('active');
                }
            });

            // Show/hide views
            document.getElementById('historyTableView').style.display = view === 'table' ? 'block' : 'none';
            document.getElementById('historyGridView').style.display = view === 'grid' ? 'block' : 'none';

            if (view === 'grid') {
                renderHistoryGridView();
            }
        }

        function loadPageData() {
            console.log('=== DEBUG: Loading page data ===');
            loadActivePickups();
            loadPickupHistory();
            loadStats();
        }

        function loadActivePickups() {
            try {
                console.log('=== DEBUG: START loadActivePickups ===');
                
                const hiddenField = document.getElementById('<%= hfActivePickups.ClientID %>');
                if (!hiddenField) {
                    console.error('DEBUG: Hidden field not found!');
                    return;
                }
                
                const jsonData = hiddenField.value || '[]';
                console.log('DEBUG: Raw JSON data:', jsonData);
                console.log('DEBUG: JSON data length:', jsonData.length);
                
                if (jsonData === '[]') {
                    console.log('DEBUG: Empty array found in hidden field');
                    showNoActiveState();
                    return;
                }
                
                const pickupsData = JSON.parse(jsonData);
                console.log('DEBUG: Parsed data:', pickupsData);
                console.log('DEBUG: Number of pickups:', pickupsData.length);
                
                if (pickupsData.length === 0) {
                    console.log('DEBUG: No pickups in data array');
                    showNoActiveState();
                    return;
                }
                
                console.log('DEBUG: First pickup sample:', pickupsData[0]);
                
                allActivePickups = pickupsData;
                filteredPickups = [...allActivePickups];

                renderActivePickups();
                updatePagination();
                updatePageInfo();
                
                console.log('=== DEBUG: END loadActivePickups ===');

            } catch (error) {
                console.error('DEBUG: Error in loadActivePickups:', error);
                console.error('DEBUG: Stack trace:', error.stack);
                document.getElementById('activePickupsGrid').innerHTML =
                    '<div class="text-center text-danger">Error loading pickup data: ' + error.message + '</div>';
                showError('Error loading active pickups from database');
            }
        }

        function loadPickupHistory() {
            try {
                console.log('=== DEBUG: START loadPickupHistory ===');
                
                const historyData = JSON.parse(document.getElementById('<%= hfPickupHistory.ClientID %>').value || '[]');
                console.log('DEBUG: History data:', historyData);
                console.log('DEBUG: Number of history records:', historyData.length);
                
                allHistory = historyData;
                filteredHistory = [...allHistory];

                if (historyData.length === 0) {
                    console.log('DEBUG: No history found, showing empty state');
                    showNoHistoryState();
                    return;
                }

                renderPickupHistory();
                updateHistoryPagination();
                updateHistoryPageInfo();
                
                console.log('=== DEBUG: END loadPickupHistory ===');

            } catch (error) {
                console.error('Error loading pickup history:', error);
                document.getElementById('historyTableBody').innerHTML =
                    '<tr><td colspan="8" class="text-center text-danger">Error loading data</td></tr>';
            }
        }

        function loadStats() {
            try {
                console.log('=== DEBUG: START loadStats ===');
                
                const statsData = JSON.parse(document.getElementById('<%= hfStatsData.ClientID %>').value || '{}');
                console.log('DEBUG: Stats data:', statsData);
                
                updateStats(statsData);
                
                console.log('=== DEBUG: END loadStats ===');
            } catch (error) {
                console.error('Error loading stats:', error);
            }
        }

        function applyFilters() {
            const searchTerm = document.getElementById('searchPickups').value.toLowerCase();
            const statusFilter = document.getElementById('statusFilter').value;
            const dateFilter = document.getElementById('dateFilter').value;

            filteredPickups = allActivePickups.filter(pickup => {
                const matchesSearch = !searchTerm ||
                    (pickup.PickupId && pickup.PickupId.toLowerCase().includes(searchTerm)) ||
                    (pickup.WasteType && pickup.WasteType.toLowerCase().includes(searchTerm)) ||
                    (pickup.Address && pickup.Address.toLowerCase().includes(searchTerm));

                const matchesStatus = statusFilter === 'all' || pickup.Status.toLowerCase() === statusFilter.toLowerCase();

                // Date filtering logic
                let matchesDate = true;
                if (dateFilter !== 'all' && pickup.ScheduledDate) {
                    const pickupDate = new Date(pickup.ScheduledDate);
                    const today = new Date();
                    
                    switch(dateFilter) {
                        case 'today':
                            matchesDate = pickupDate.toDateString() === today.toDateString();
                            break;
                        case 'week':
                            const weekAgo = new Date();
                            weekAgo.setDate(today.getDate() - 7);
                            matchesDate = pickupDate >= weekAgo;
                            break;
                        case 'month':
                            const monthAgo = new Date();
                            monthAgo.setMonth(today.getMonth() - 1);
                            matchesDate = pickupDate >= monthAgo;
                            break;
                    }
                }

                return matchesSearch && matchesStatus && matchesDate;
            });

            currentPage = 1;
            renderActivePickups();
            updatePagination();
            updatePageInfo();
        }

        function renderActivePickups() {
            console.log('DEBUG: Rendering active pickups, currentView:', currentView);
            console.log('DEBUG: filteredPickups length:', filteredPickups.length);
            
            if (currentView === 'grid') {
                renderGridView();
            } else {
                renderTableView();
            }
        }

        function renderGridView() {
            const grid = document.getElementById('activePickupsGrid');
            const startIndex = (currentPage - 1) * pickupsPerPage;
            const endIndex = startIndex + pickupsPerPage;
            const pickupsToShow = filteredPickups.slice(startIndex, endIndex);

            console.log('DEBUG: Grid view - pickupsToShow:', pickupsToShow.length);
            
            grid.innerHTML = '';

            if (pickupsToShow.length === 0) {
                grid.innerHTML = `
                    <div class="col-12 text-center py-5">
                        <i class="fas fa-truck fa-3x mb-3" style="color: rgba(255, 255, 255, 0.5) !important;"></i>
                        <h4 style="color: rgba(255, 255, 255, 0.7) !important;">No pickups found</h4>
                        <p style="color: rgba(255, 255, 255, 0.5) !important;">Try adjusting your filters or search terms</p>
                    </div>
                `;
                return;
            }

            pickupsToShow.forEach(pickup => {
                const pickupCard = createPickupCard(pickup);
                grid.appendChild(pickupCard);
            });
        }

        function renderTableView() {
            const tbody = document.getElementById('activePickupsTableBody');
            const startIndex = (currentPage - 1) * pickupsPerPage;
            const endIndex = startIndex + pickupsPerPage;
            const pickupsToShow = filteredPickups.slice(startIndex, endIndex);

            console.log('DEBUG: Table view - pickupsToShow:', pickupsToShow.length);
            
            tbody.innerHTML = '';

            if (pickupsToShow.length === 0) {
                tbody.innerHTML = `
                    <tr>
                        <td colspan="8" class="text-center py-4">
                            <i class="fas fa-truck fa-2x mb-2" style="color: rgba(255, 255, 255, 0.5) !important;"></i>
                            <h5 style="color: rgba(255, 255, 255, 0.7) !important;">No pickups found</h5>
                            <p style="color: rgba(255, 255, 255, 0.5) !important;">Try adjusting your filters or search terms</p>
                        </td>
                    </tr>
                `;
                return;
            }

            pickupsToShow.forEach(pickup => {
                const row = createTableRow(pickup);
                tbody.appendChild(row);
            });
        }

        function createPickupCard(pickup) {
            const card = document.createElement('div');
            card.className = 'pickup-card';

            const collectorInitials = getInitials(pickup.Collector);
            const statusClass = pickup.Status.toLowerCase();

            card.innerHTML = `
                <div class="pickup-header">
                    <div class="pickup-info">
                        <h3 class="pickup-id">${escapeHtml(pickup.PickupId)}</h3>
                        <p class="waste-type">${escapeHtml(pickup.WasteType)} • ${escapeHtml(pickup.Weight)}</p>
                        <div class="pickup-stats">
                            <div class="stat-item">
                                <div class="stat-value">${escapeHtml(pickup.Weight.split(' ')[0])}</div>
                                <div class="stat-label">Weight</div>
                            </div>
                            <div class="stat-item">
                                <div class="stat-value">${escapeHtml(pickup.ScheduledDate.split(' ')[0])}</div>
                                <div class="stat-label">Scheduled</div>
                            </div>
                        </div>
                    </div>
                    <div class="pickup-actions">
                        <button class="btn-action btn-details" data-pickup-id="${pickup.PickupId}" title="View Details">
                            <i class="fas fa-eye"></i>
                        </button>
                        ${pickup.Status === 'Scheduled' || pickup.Status === 'Requested' ? `
                            <button class="btn-action btn-cancel" data-pickup-id="${pickup.PickupId}" title="Cancel Pickup">
                                <i class="fas fa-times"></i>
                            </button>
                        ` : ''}
                        ${pickup.Status === 'Assigned' ? `
                            <button class="btn-action btn-track" data-pickup-id="${pickup.PickupId}" title="Track Pickup">
                                <i class="fas fa-map-marker-alt"></i>
                            </button>
                        ` : ''}
                    </div>
                </div>
                <div class="pickup-meta">
                    <div class="pickup-status">
                        <span class="status-badge status-${statusClass}">${escapeHtml(pickup.Status)}</span>
                        <span style="color: rgba(255, 255, 255, 0.5) !important;">• ${escapeHtml(truncateText(pickup.Address, 30))}</span>
                    </div>
                    <div class="small" style="color: rgba(255, 255, 255, 0.5) !important;">
                        <i class="fas fa-user me-1"></i>${escapeHtml(pickup.Collector)}
                    </div>
                </div>
            `;

            // Add event listeners to action buttons
            card.querySelector('.btn-details').addEventListener('click', function() {
                viewPickup(this.getAttribute('data-pickup-id'));
            });
            
            const cancelBtn = card.querySelector('.btn-cancel');
            if (cancelBtn) {
                cancelBtn.addEventListener('click', function() {
                    cancelPickup(this.getAttribute('data-pickup-id'));
                });
            }
            
            const trackBtn = card.querySelector('.btn-track');
            if (trackBtn) {
                trackBtn.addEventListener('click', function() {
                    trackPickup(this.getAttribute('data-pickup-id'));
                });
            }

            return card;
        }

        function createTableRow(pickup) {
            const row = document.createElement('tr');
            const statusClass = pickup.Status.toLowerCase();
            const collectorInitials = getInitials(pickup.Collector);

            row.innerHTML = `
                <td>
                    <div class="fw-bold" style="color: #ffffff !important;">${escapeHtml(pickup.PickupId)}</div>
                </td>
                <td class="text-light">${escapeHtml(pickup.WasteType)}</td>
                <td class="text-light">${escapeHtml(pickup.Weight)}</td>
                <td class="text-light">${escapeHtml(truncateText(pickup.Address, 25))}</td>
                <td class="text-light">${escapeHtml(pickup.ScheduledDate)}</td>
                <td>
                    <div class="d-flex align-items-center gap-2">
                        <div class="collector-avatar">${collectorInitials}</div>
                        <div class="small" style="color: rgba(255, 255, 255, 0.8) !important;">${escapeHtml(pickup.Collector)}</div>
                    </div>
                </td>
                <td>
                    <span class="status-badge status-${statusClass}">${escapeHtml(pickup.Status)}</span>
                </td>
                <td>
                    <div class="pickup-actions">
                        <button class="btn-action btn-details" data-pickup-id="${pickup.PickupId}" title="View Details">
                            <i class="fas fa-eye"></i>
                        </button>
                        ${pickup.Status === 'Scheduled' || pickup.Status === 'Requested' ? `
                            <button class="btn-action btn-cancel" data-pickup-id="${pickup.PickupId}" title="Cancel Pickup">
                                <i class="fas fa-times"></i>
                            </button>
                        ` : ''}
                    </div>
                </td>
            `;

            // Add event listeners to action buttons
            row.querySelector('.btn-details').addEventListener('click', function() {
                viewPickup(this.getAttribute('data-pickup-id'));
            });
            
            const cancelBtn = row.querySelector('.btn-cancel');
            if (cancelBtn) {
                cancelBtn.addEventListener('click', function() {
                    cancelPickup(this.getAttribute('data-pickup-id'));
                });
            }

            return row;
        }

        function renderPickupHistory() {
            const tbody = document.getElementById('historyTableBody');
            const startIndex = (historyPage - 1) * pickupsPerPage;
            const endIndex = startIndex + pickupsPerPage;
            const historyToShow = filteredHistory.slice(startIndex, endIndex);

            tbody.innerHTML = '';

            if (historyToShow.length === 0) {
                tbody.innerHTML = `
                    <tr>
                        <td colspan="8" class="text-center py-4">
                            <i class="fas fa-history fa-2x mb-2" style="color: rgba(255, 255, 255, 0.5) !important;"></i>
                            <h5 style="color: rgba(255, 255, 255, 0.7) !important;">No history found</h5>
                            <p style="color: rgba(255, 255, 255, 0.5) !important;">Try adjusting your filters or search terms</p>
                        </td>
                    </tr>
                `;
                return;
            }

            historyToShow.forEach(pickup => {
                const row = createHistoryTableRow(pickup);
                tbody.appendChild(row);
            });
        }

        function renderHistoryGridView() {
            const grid = document.getElementById('historyPickupsGrid');
            const startIndex = (historyPage - 1) * pickupsPerPage;
            const endIndex = startIndex + pickupsPerPage;
            const historyToShow = filteredHistory.slice(startIndex, endIndex);

            grid.innerHTML = '';

            if (historyToShow.length === 0) {
                grid.innerHTML = `
                    <div class="col-12 text-center py-5">
                        <i class="fas fa-history fa-3x mb-3" style="color: rgba(255, 255, 255, 0.5) !important;"></i>
                        <h4 style="color: rgba(255, 255, 255, 0.7) !important;">No history found</h4>
                        <p style="color: rgba(255, 255, 255, 0.5) !important;">Try adjusting your filters or search terms</p>
                    </div>
                `;
                return;
            }

            historyToShow.forEach(pickup => {
                const historyCard = createHistoryCard(pickup);
                grid.appendChild(historyCard);
            });
        }

        function createHistoryTableRow(pickup) {
            const row = document.createElement('tr');
            const statusClass = pickup.Status.toLowerCase();
            const isCollected = pickup.Status === 'Collected';
            const collectorInitials = getInitials(pickup.Collector);

            row.innerHTML = `
                <td>
                    <div class="fw-bold" style="color: #ffffff !important;">${escapeHtml(pickup.PickupId)}</div>
                </td>
                <td class="text-light">${escapeHtml(pickup.WasteType)}</td>
                <td class="text-light">${escapeHtml(pickup.Weight)}</td>
                <td class="text-light">${escapeHtml(truncateText(pickup.Address, 25))}</td>
                <td class="text-light">${escapeHtml(pickup.CompletedDate)}</td>
                <td>
                    <div class="d-flex align-items-center gap-2">
                        <div class="collector-avatar">${collectorInitials}</div>
                        <div class="small" style="color: rgba(255, 255, 255, 0.8) !important;">${escapeHtml(pickup.Collector)}</div>
                    </div>
                </td>
                <td>
                    ${isCollected ? `<span class="xp-badge">${escapeHtml(pickup.XPEarned)}</span>` : '0 XP'}
                </td>
                <td>
                    <span class="status-badge status-${statusClass}">${escapeHtml(pickup.Status)}</span>
                </td>
            `;

            row.addEventListener('click', function() {
                viewPickup(pickup.PickupId);
            });

            return row;
        }

        function createHistoryCard(pickup) {
            const card = document.createElement('div');
            card.className = 'pickup-card';
            
            const statusClass = pickup.Status.toLowerCase();
            const isCollected = pickup.Status === 'Collected';
            const collectorInitials = getInitials(pickup.Collector);

            card.innerHTML = `
                <div class="pickup-header">
                    <div class="pickup-info">
                        <h3 class="pickup-id">${escapeHtml(pickup.PickupId)}</h3>
                        <p class="waste-type">${escapeHtml(pickup.WasteType)} • ${escapeHtml(pickup.Weight)}</p>
                        <div class="pickup-stats">
                            <div class="stat-item">
                                <div class="stat-value">${escapeHtml(pickup.Weight.split(' ')[0])}</div>
                                <div class="stat-label">Weight</div>
                            </div>
                            <div class="stat-item">
                                <div class="stat-value">${escapeHtml(pickup.CompletedDate.split(' ')[0])}</div>
                                <div class="stat-label">Completed</div>
                            </div>
                            ${isCollected ? `
                                <div class="stat-item">
                                    <div class="stat-value">${escapeHtml(pickup.XPEarned.split(' ')[0])}</div>
                                    <div class="stat-label">XP Earned</div>
                                </div>
                            ` : ''}
                        </div>
                    </div>
                    <div class="pickup-actions">
                        <button class="btn-action btn-details" data-pickup-id="${pickup.PickupId}" title="View Details">
                            <i class="fas fa-eye"></i>
                        </button>
                    </div>
                </div>
                <div class="pickup-meta">
                    <div class="pickup-status">
                        <span class="status-badge status-${statusClass}">${escapeHtml(pickup.Status)}</span>
                        <span style="color: rgba(255, 255, 255, 0.5) !important;">• ${escapeHtml(truncateText(pickup.Address, 30))}</span>
                    </div>
                    <div class="small" style="color: rgba(255, 255, 255, 0.5) !important;">
                        <i class="fas fa-user me-1"></i>${escapeHtml(pickup.Collector)}
                    </div>
                </div>
            `;

            card.querySelector('.btn-details').addEventListener('click', function() {
                viewPickup(this.getAttribute('data-pickup-id'));
            });

            return card;
        }

        function updatePagination() {
            const pagination = document.getElementById('pagination');
            const totalPages = Math.ceil(filteredPickups.length / pickupsPerPage);

            pagination.innerHTML = '';

            if (totalPages <= 1) return;

            const prevLi = document.createElement('li');
            prevLi.className = `page-item ${currentPage === 1 ? 'disabled' : ''}`;
            prevLi.innerHTML = `<a class="page-link" href="javascript:void(0)" data-page="${currentPage - 1}">Previous</a>`;
            pagination.appendChild(prevLi);

            for (let i = 1; i <= totalPages; i++) {
                const li = document.createElement('li');
                li.className = `page-item ${currentPage === i ? 'active' : ''}`;
                li.innerHTML = `<a class="page-link" href="javascript:void(0)" data-page="${i}">${i}</a>`;
                pagination.appendChild(li);
            }

            const nextLi = document.createElement('li');
            nextLi.className = `page-item ${currentPage === totalPages ? 'disabled' : ''}`;
            nextLi.innerHTML = `<a class="page-link" href="javascript:void(0)" data-page="${currentPage + 1}">Next</a>`;
            pagination.appendChild(nextLi);

            // Add event listeners to pagination links
            pagination.querySelectorAll('.page-link').forEach(link => {
                link.addEventListener('click', function() {
                    const page = parseInt(this.getAttribute('data-page'));
                    changePage(page);
                });
            });

            document.getElementById('paginationInfo').textContent = `Page ${currentPage} of ${totalPages}`;
        }

        function updateHistoryPagination() {
            const pagination = document.getElementById('historyPagination');
            const totalPages = Math.ceil(filteredHistory.length / pickupsPerPage);

            pagination.innerHTML = '';

            if (totalPages <= 1) return;

            const prevLi = document.createElement('li');
            prevLi.className = `page-item ${historyPage === 1 ? 'disabled' : ''}`;
            prevLi.innerHTML = `<a class="page-link" href="javascript:void(0)" data-page="${historyPage - 1}">Previous</a>`;
            pagination.appendChild(prevLi);

            for (let i = 1; i <= totalPages; i++) {
                const li = document.createElement('li');
                li.className = `page-item ${historyPage === i ? 'active' : ''}`;
                li.innerHTML = `<a class="page-link" href="javascript:void(0)" data-page="${i}">${i}</a>`;
                pagination.appendChild(li);
            }

            const nextLi = document.createElement('li');
            nextLi.className = `page-item ${historyPage === totalPages ? 'disabled' : ''}`;
            nextLi.innerHTML = `<a class="page-link" href="javascript:void(0)" data-page="${historyPage + 1}">Next</a>`;
            pagination.appendChild(nextLi);

            // Add event listeners to pagination links
            pagination.querySelectorAll('.page-link').forEach(link => {
                link.addEventListener('click', function() {
                    const page = parseInt(this.getAttribute('data-page'));
                    changeHistoryPage(page);
                });
            });

            document.getElementById('historyPaginationInfo').textContent = `Page ${historyPage} of ${totalPages}`;
        }

        function changePage(page) {
            const totalPages = Math.ceil(filteredPickups.length / pickupsPerPage);
            if (page >= 1 && page <= totalPages) {
                currentPage = page;
                renderActivePickups();
                updatePagination();
            }
        }

        function changeHistoryPage(page) {
            const totalPages = Math.ceil(filteredHistory.length / pickupsPerPage);
            if (page >= 1 && page <= totalPages) {
                historyPage = page;
                renderPickupHistory();
                updateHistoryPagination();
            }
        }

        function updatePageInfo() {
            const startIndex = (currentPage - 1) * pickupsPerPage + 1;
            const endIndex = Math.min(currentPage * pickupsPerPage, filteredPickups.length);
            document.getElementById('pageInfo').textContent = `Showing ${startIndex}-${endIndex} of ${filteredPickups.length} pickups`;
        }

        function updateHistoryPageInfo() {
            const startIndex = (historyPage - 1) * pickupsPerPage + 1;
            const endIndex = Math.min(historyPage * pickupsPerPage, filteredHistory.length);
            document.getElementById('historyPageInfo').textContent = `Showing ${startIndex}-${endIndex} of ${filteredHistory.length} pickups`;
        }

        function updateStats(stats) {
            console.log('DEBUG: Updating stats with:', stats);
            document.getElementById('totalPickups').textContent = stats.TotalPickups || '0';
            document.getElementById('activePickups').textContent = stats.ActivePickups || '0';
            document.getElementById('completedPickups').textContent = stats.CompletedPickups || '0';
            document.getElementById('successRate').textContent = stats.SuccessRate || '0%';
            document.getElementById('totalXP').textContent = stats.TotalXP || '0 XP';
        }

        function viewPickup(pickupId) {
            // Find pickup in both active and history data
            let pickup = null;
            
            // Search in active pickups
            pickup = allActivePickups.find(p => p.PickupId === pickupId);
            
            // If not found in active, search in history
            if (!pickup) {
                pickup = allHistory.find(p => p.PickupId === pickupId);
            }
            
            if (!pickup) {
                showError('Pickup not found');
                return;
            }
            
            // Populate modal with pickup details
            document.getElementById('viewPickupId').textContent = pickup.PickupId || '-';
            document.getElementById('viewWasteType').textContent = pickup.WasteType || '-';
            document.getElementById('viewWeight').textContent = pickup.Weight || '-';
            document.getElementById('viewStatus').innerHTML = `
                <span class="status-badge status-${pickup.Status.toLowerCase()}">${pickup.Status}</span>
            `;
            document.getElementById('viewScheduledDate').textContent = pickup.ScheduledDate || '-';
            document.getElementById('viewCollector').textContent = pickup.Collector || 'Not Assigned';
            document.getElementById('viewAddress').textContent = pickup.Address || '-';
            document.getElementById('viewXPEarned').textContent = pickup.XPEarned || '0 XP';
            document.getElementById('viewCreatedDate').textContent = pickup.CreatedAt || '-';
            document.getElementById('viewCompletedDate').textContent = pickup.CompletedDate || '-';
            
            // Show modal
            document.getElementById('viewPickupModal').style.display = 'block';
            currentPickupId = pickupId;
        }

        function closeViewPickupModal() {
            document.getElementById('viewPickupModal').style.display = 'none';
            currentPickupId = null;
        }

        function cancelPickup(pickupId) {
            currentCancelPickupId = pickupId;
            document.getElementById('cancelPickupId').textContent = pickupId;
            document.getElementById('cancelPickupModal').style.display = 'block';
        }

        function closeCancelModal() {
            document.getElementById('cancelPickupModal').style.display = 'none';
            currentCancelPickupId = null;
        }

        function confirmCancelPickup() {
            if (!currentCancelPickupId) return;
            
            // Show loading state
            const confirmBtn = document.getElementById('confirmCancelBtn');
            const originalText = confirmBtn.innerHTML;
            confirmBtn.innerHTML = '<i class="fas fa-spinner fa-spin me-2"></i>Cancelling...';
            confirmBtn.disabled = true;
            
            // Call server-side method using PageMethods
            PageMethods.CancelPickup(currentCancelPickupId, onCancelSuccess, onCancelFailure);
        }

        function onCancelSuccess(result) {
            const confirmBtn = document.getElementById('confirmCancelBtn');
            confirmBtn.innerHTML = 'Cancel Pickup';
            confirmBtn.disabled = false;
            
            closeCancelModal();
            
            if (result.startsWith('Success:')) {
                showSuccess('Pickup cancelled successfully');
                
                // Refresh the page data
                setTimeout(() => {
                    // Trigger a postback to refresh data
                    __doPostBack('<%= btnRefresh.ClientID %>', '');
                }, 1500);
                } else {
                    showError(result.replace('Error:', ''));
                }
            }

            function onCancelFailure(error) {
                const confirmBtn = document.getElementById('confirmCancelBtn');
                confirmBtn.innerHTML = 'Cancel Pickup';
                confirmBtn.disabled = false;

                showError('Failed to cancel pickup. Please try again.');
                console.error('Cancel pickup error:', error);
            }

            function trackPickup(pickupId) {
                showInfo('Tracking feature coming soon!');
            }

            function showNoActiveState() {
                console.log('DEBUG: Showing no active state');
                document.getElementById('noActiveEmptyState').style.display = 'block';
                document.getElementById('gridView').style.display = 'none';
                document.getElementById('tableView').style.display = 'none';
                document.querySelector('.pagination-container').style.display = 'none';
            }

            function showNoHistoryState() {
                document.getElementById('historyEmptyState').style.display = 'block';
                document.getElementById('historyTableView').style.display = 'none';
                document.getElementById('historyGridView').style.display = 'none';
                document.querySelectorAll('.pagination-container')[1].style.display = 'none';
            }

            // HELPER FUNCTIONS
            function getInitials(name) {
                if (!name || name === 'Not Assigned' || name === 'Not Available') return 'NA';
                return name.split(' ').map(n => n[0]).join('').toUpperCase().substring(0, 2);
            }

            function truncateText(text, maxLength) {
                if (!text) return '';
                if (text.length <= maxLength) return text;
                return text.substring(0, maxLength) + '...';
            }

            function escapeHtml(text) {
                if (!text) return '';
                const div = document.createElement('div');
                div.textContent = text;
                return div.innerHTML;
            }

            function showNotification(message, type = 'info') {
                // Remove existing notifications
                const existingNotifications = document.querySelectorAll('.custom-notification');
                existingNotifications.forEach(notification => notification.remove());

                // Create notification element
                const notification = document.createElement('div');
                notification.className = `custom-notification notification-${type}`;

                let icon = 'fa-info-circle';
                if (type === 'success') icon = 'fa-check-circle';
                if (type === 'error') icon = 'fa-exclamation-circle';

                notification.innerHTML = `
                <i class="fas ${icon} me-2"></i>
                <span>${escapeHtml(message)}</span>
                <button onclick="this.parentElement.remove()" style="margin-left: auto;">&times;</button>
            `;

                document.body.appendChild(notification);

                // Auto-remove after 5 seconds
                setTimeout(() => {
                    if (notification.parentElement) {
                        notification.remove();
                    }
                }, 5000);
            }

            function showSuccess(message) {
                showNotification(message, 'success');
            }

            function showError(message) {
                showNotification(message, 'error');
            }

            function showInfo(message) {
                showNotification(message, 'info');
            }
