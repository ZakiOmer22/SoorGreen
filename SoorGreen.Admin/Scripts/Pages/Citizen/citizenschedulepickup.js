
        // Global variables
    let currentTab = 'schedule';
    let selectedWasteId = null;
    let selectedDate = '7';
    let selectedTime = '11:00 AM';

    // Initialize when DOM is loaded
    document.addEventListener('DOMContentLoaded', function () {
        setupEventListeners();
    document.getElementById('<%= hfSelectedDate.ClientID %>').value = selectedDate;
    document.getElementById('<%= hfSelectedTime.ClientID %>').value = selectedTime;

    // Load data from server
    loadPageData();
        });

    // Load all page data
    function loadPageData() {
        loadWasteData();
    loadUpcomingPickups();
    loadPickupHistory();
    loadStats();
        }

    // Load waste data from hidden field
    function loadWasteData() {
            try {
                const wasteData = JSON.parse(document.getElementById('<%= hfWasteData.ClientID %>').value || '[]');
    const wasteList = document.getElementById('availableWasteList');

    if (wasteData.length === 0) {
        wasteList.innerHTML = '';
    showNoWasteState();
    return;
                }

    let html = '';
                wasteData.forEach(waste => {
        html += `
                        <div class="pickup-card" data-waste-id="${waste.ReportId}">
                            <div class="d-flex justify-content-between align-items-start mb-2">
                                <div>
                                    <h5 class="fw-bold mb-1 text-light">${escapeHtml(waste.TypeName)}</h5>
                                    <p class="text-muted mb-1">${escapeHtml(waste.Address)}</p>
                                    <small class="text-muted">Reported ${escapeHtml(waste.TimeAgo)}</small>
                                </div>
                                <div class="text-end">
                                    <span class="badge bg-primary fs-6">${escapeHtml(waste.EstimatedKg)} kg</span>
                                </div>
                            </div>
                        </div>
                    `;
                });

    wasteList.innerHTML = html;
    setupWasteCardEvents(); // Re-attach event listeners

            } catch (error) {
        console.error('Error loading waste data:', error);
    document.getElementById('availableWasteList').innerHTML =
    '<div class="text-center text-danger">Error loading waste data</div>';
            }
        }

    // Load upcoming pickups from hidden field
    function loadUpcomingPickups() {
            try {
                const pickupData = JSON.parse(document.getElementById('<%= hfUpcomingPickups.ClientID %>').value || '[]');
    const tableBody = document.getElementById('upcomingTableBody');

    if (pickupData.length === 0) {
        tableBody.innerHTML = '';
    showNoUpcomingState();
    return;
                }

    let html = '';
                pickupData.forEach(pickup => {
        html += `
                        <tr>
                            <td class="text-light">${escapeHtml(pickup.PickupId)}</td>
                            <td class="text-light">${escapeHtml(pickup.WasteType)}</td>
                            <td class="text-light">${escapeHtml(pickup.EstimatedKg)} kg</td>
                            <td class="text-light">${escapeHtml(pickup.ScheduledAt)}</td>
                            <td><span class="status-badge status-scheduled">Scheduled</span></td>
                            <td>
                                <button class="btn btn-sm btn-outline-light me-2" onclick="reschedulePickup('${escapeHtml(pickup.PickupId)}')">
                                    <i class="fas fa-calendar-alt me-1"></i>Reschedule
                                </button>
                                <button class="btn btn-sm btn-outline-danger" onclick="cancelPickup('${escapeHtml(pickup.PickupId)}')">
                                    <i class="fas fa-times me-1"></i>Cancel
                                </button>
                            </td>
                        </tr>
                    `;
                });

    tableBody.innerHTML = html;

            } catch (error) {
        console.error('Error loading upcoming pickups:', error);
    document.getElementById('upcomingTableBody').innerHTML =
    '<tr><td colspan="7" class="text-center text-danger">Error loading data</td></tr>';
            }
        }

    // Load pickup history from hidden field
    function loadPickupHistory() {
            try {
                const historyData = JSON.parse(document.getElementById('<%= hfPickupHistory.ClientID %>').value || '[]');
    const tableBody = document.getElementById('historyTableBody');

    if (historyData.length === 0) {
        tableBody.innerHTML = '';
    showNoHistoryState();
    return;
                }

    let html = '';
                historyData.forEach(history => {
        let statusBadge = '';
    let statusClass = '';

    switch(history.Status) {
                        case 'Completed':
    statusClass = 'status-completed';
    break;
    case 'Cancelled':
    statusClass = 'status-cancelled';
    break;
    default:
    statusClass = 'status-pending';
                    }

    html += `
    <tr>
        <td class="text-light">${escapeHtml(history.PickupId)}</td>
        <td class="text-light">${escapeHtml(history.WasteType)}</td>
        <td class="text-light">${escapeHtml(history.Weight)} kg</td>
        <td class="text-light">${escapeHtml(history.CompletedDate)}</td>
        <td class="text-light">${escapeHtml(history.Collector)}</td>
        <td class="text-light">${escapeHtml(history.XPEarned)} XP</td>
        <td><span class="status-badge ${statusClass}">${escapeHtml(history.Status)}</span></td>
    </tr>
    `;
                });

    tableBody.innerHTML = html;
                
            } catch (error) {
        console.error('Error loading pickup history:', error);
    document.getElementById('historyTableBody').innerHTML =
    '<tr><td colspan="7" class="text-center text-danger">Error loading data</td></tr>';
            }
        }

    // Load stats data
    function loadStats() {
            try {
                const statsData = JSON.parse(document.getElementById('<%= hfStatsData.ClientID %>').value || '{"TotalPickups":0,"ScheduledPickups":0,"CompletedPickups":0,"SuccessRate":0}');
    updateStats(statsData.TotalPickups, statsData.ScheduledPickups, statsData.CompletedPickups, statsData.SuccessRate);
            } catch (error) {
        console.error('Error loading stats:', error);
            }
        }

    function setupWasteCardEvents() {
        // Re-attach event listeners to dynamically loaded waste cards
        document.querySelectorAll('.pickup-card').forEach(card => {
            card.addEventListener('click', function () {
                document.querySelectorAll('.pickup-card').forEach(c => {
                    c.classList.remove('selected');
                });
                this.classList.add('selected');
                selectedWasteId = this.getAttribute('data-waste-id');
                document.getElementById('<%= hfSelectedWasteId.ClientID %>').value = selectedWasteId;
                document.getElementById('datetimeSection').style.display = 'block';
                showNotification('Waste selected! Now choose date and time.', 'info');
            });
        });
        }

    function setupEventListeners() {
        // Tab switching
        document.querySelectorAll('.tab').forEach(tab => {
            tab.addEventListener('click', function (e) {
                e.preventDefault();
                const tabName = this.getAttribute('data-tab');
                switchTab(tabName);
            });
        });

    // Setup waste card events for initially loaded content
    setupWasteCardEvents();

            // Date selection
            document.querySelectorAll('.calendar-day:not(.disabled)').forEach(day => {
        day.addEventListener('click', function () {
            document.querySelectorAll('.calendar-day').forEach(d => {
                d.classList.remove('selected');
            });
            this.classList.add('selected');
            selectedDate = this.textContent;
            document.getElementById('<%= hfSelectedDate.ClientID %>').value = selectedDate;
        });
            });

            // Time slot selection
            document.querySelectorAll('.time-slot').forEach(slot => {
        slot.addEventListener('click', function () {
            document.querySelectorAll('.time-slot').forEach(s => {
                s.classList.remove('selected');
            });
            this.classList.add('selected');
            selectedTime = this.textContent;
            document.getElementById('<%= hfSelectedTime.ClientID %>').value = selectedTime;
        });
            });

    // Quick schedule button
    document.getElementById('quickScheduleBtn').addEventListener('click', function () {
                const availableCards = document.querySelectorAll('.pickup-card');
                if (availableCards.length > 0) {
        availableCards[0].click();
    showNotification('Quick schedule activated! Select date and time.', 'info');
                } else {
        showNotification('No waste available for quick scheduling', 'error');
                }
            });

    // View history button
    document.getElementById('viewHistoryBtn').addEventListener('click', function () {
        switchTab('history');
            });
        }

    function switchTab(tabName) {
        currentTab = tabName;
            document.querySelectorAll('.tab').forEach(tab => {
        tab.classList.remove('active');
    if (tab.getAttribute('data-tab') === tabName) {
        tab.classList.add('active');
                }
            });
            document.querySelectorAll('.tab-content').forEach(content => {
        content.classList.remove('active');
    if (content.id === tabName + 'Tab') {
        content.classList.add('active');
                }
            });
        }

    function cancelSchedule() {
        document.querySelectorAll('.pickup-card').forEach(card => {
            card.classList.remove('selected');
        });
    document.getElementById('datetimeSection').style.display = 'none';
    selectedWasteId = null;
    document.getElementById('<%= hfSelectedWasteId.ClientID %>').value = '';
        }

    function reschedulePickup(pickupId) {
        showNotification(`Rescheduling pickup ${pickupId}...`, 'info');
        }

    function cancelPickup(pickupId) {
            if (confirm('Are you sure you want to cancel this pickup?')) {
        showNotification(`Pickup ${pickupId} cancelled successfully`, 'success');
            }
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

    function showNoWasteState() {
            const element = document.getElementById('noWasteEmptyState');
    if (element) element.style.display = 'block';
        }

    function showNoUpcomingState() {
            const element = document.getElementById('upcomingEmptyState');
    if (element) element.style.display = 'block';
        }

    function showNoHistoryState() {
            const element = document.getElementById('historyEmptyState');
    if (element) element.style.display = 'block';
        }

    function updateStats(total, scheduled, completed, successRate) {
            const totalEl = document.getElementById('totalPickups');
    const scheduledEl = document.getElementById('scheduledPickups');
    const completedEl = document.getElementById('completedPickups');
    const rateEl = document.getElementById('successRate');

    if (totalEl) totalEl.textContent = total;
    if (scheduledEl) scheduledEl.textContent = scheduled;
    if (completedEl) completedEl.textContent = completed;
    if (rateEl) rateEl.textContent = Math.round(successRate) + '%';
        }

    // Utility function to escape HTML
    function escapeHtml(unsafe) {
            if (!unsafe) return '';
    return unsafe
    .toString()
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
                .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&#039;");
        }

// Make functions globally available
window.showNoWasteState = showNoWasteState;
window.showNoUpcomingState = showNoUpcomingState;
window.showNoHistoryState = showNoHistoryState;
window.updateStats = updateStats;
window.setupWasteCardEvents = setupWasteCardEvents;