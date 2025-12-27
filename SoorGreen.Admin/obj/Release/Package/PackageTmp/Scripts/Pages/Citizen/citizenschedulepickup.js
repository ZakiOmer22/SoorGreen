// Global variables
let currentScheduleStep = 1;
let selectedWasteIds = [];
let availableWaste = [];
let upcomingPickups = [];
let pickupHistory = [];
let statsData = {};
let selectedDate = '';
let selectedTime = '';

// Initialize when page loads
document.addEventListener('DOMContentLoaded', function () {
    initializePage();
});

function initializePage() {
    // Initialize tabs
    initializeTabs();

    // Initialize schedule steps
    initializeScheduleSteps();

    // Load data
    loadAllData();

    // Initialize date picker
    initializeDatePicker();

    // Initialize time slots
    initializeTimeSlots();
}

// Tab Management
function initializeTabs() {
    const tabBtns = document.querySelectorAll('.tab-btn');

    tabBtns.forEach(btn => {
        btn.addEventListener('click', function () {
            const tabId = this.getAttribute('data-tab');
            switchTab(tabId);
        });
    });
}

function switchTab(tabId) {
    // Update active tab button
    document.querySelectorAll('.tab-btn').forEach(btn => {
        btn.classList.remove('active');
    });
    document.querySelector(`.tab-btn[data-tab="${tabId}"]`).classList.add('active');

    // Update active tab content
    document.querySelectorAll('.tab-pane').forEach(pane => {
        pane.classList.remove('active');
    });
    document.getElementById(`${tabId}Tab`).classList.add('active');

    // Reset schedule steps when switching to schedule tab
    if (tabId === 'schedule') {
        resetScheduleSteps();
    }
}

// Schedule Steps Management
function initializeScheduleSteps() {
    // Nothing to initialize here, steps are managed by functions
}

function nextScheduleStep(step) {
    if (validateCurrentScheduleStep()) {
        // Hide all steps
        document.querySelectorAll('.schedule-step').forEach(step => {
            step.classList.remove('active');
        });

        // Show target step
        document.getElementById(`step${step}`).classList.add('active');
        currentScheduleStep = step;

        // If going to step 2, update selected waste preview
        if (step === 2) {
            updateSelectedWastePreview();
        }

        // Scroll to top of schedule container
        const scheduleContainer = document.querySelector('.schedule-step-container');
        scheduleContainer.scrollIntoView({ behavior: 'smooth', block: 'start' });
    }
}

function prevScheduleStep(step) {
    // Hide all steps
    document.querySelectorAll('.schedule-step').forEach(step => {
        step.classList.remove('active');
    });

    // Show target step
    document.getElementById(`step${step}`).classList.add('active');
    currentScheduleStep = step;

    // Scroll to top of schedule container
    const scheduleContainer = document.querySelector('.schedule-step-container');
    scheduleContainer.scrollIntoView({ behavior: 'smooth', block: 'start' });
}

function validateCurrentScheduleStep() {
    switch (currentScheduleStep) {
        case 1:
            if (selectedWasteIds.length === 0) {
                showNotification('Please select at least one waste report for pickup', 'error');
                return false;
            }
            return true;

        case 2:
            if (!selectedDate) {
                showNotification('Please select a pickup date', 'error');
                return false;
            }
            if (!selectedTime) {
                showNotification('Please select a time slot', 'error');
                return false;
            }
            return true;

        default:
            return true;
    }
}

function resetScheduleSteps() {
    // Reset to step 1
    document.querySelectorAll('.schedule-step').forEach(step => {
        step.classList.remove('active');
    });
    document.getElementById('step1').classList.add('active');
    currentScheduleStep = 1;

    // Clear selections
    selectedWasteIds = [];
    selectedDate = '';
    selectedTime = '';

    // Update UI
    updateWasteSelectionUI();
    updateSelectedWastePreview();
    updateTimeSlots();

    // Reset date picker
    const datePicker = document.getElementById('<%= txtPickupDate.ClientID %>');
    if (datePicker) {
        datePicker.value = '';
    }
}

// Data Loading
function loadAllData() {
    // Parse data from hidden fields
    try {
        if (document.getElementById('<%= hfWasteData.ClientID %>').value) {
            availableWaste = JSON.parse(document.getElementById('<%= hfWasteData.ClientID %>').value);
        }
    } catch (e) {
        console.error('Error parsing waste data:', e);
        availableWaste = [];
    }

    try {
        if (document.getElementById('<%= hfUpcomingPickups.ClientID %>').value) {
            upcomingPickups = JSON.parse(document.getElementById('<%= hfUpcomingPickups.ClientID %>').value);
        }
    } catch (e) {
        console.error('Error parsing upcoming pickups:', e);
        upcomingPickups = [];
    }

    try {
        if (document.getElementById('<%= hfPickupHistory.ClientID %>').value) {
            pickupHistory = JSON.parse(document.getElementById('<%= hfPickupHistory.ClientID %>').value);
        }
    } catch (e) {
        console.error('Error parsing pickup history:', e);
        pickupHistory = [];
    }

    try {
        if (document.getElementById('<%= hfStatsData.ClientID %>').value) {
            statsData = JSON.parse(document.getElementById('<%= hfStatsData.ClientID %>').value);
        }
    } catch (e) {
        console.error('Error parsing stats data:', e);
        statsData = {
            TotalPickups: 0,
            ScheduledPickups: 0,
            CompletedPickups: 0,
            SuccessRate: 0
        };
    }

    // Update UI with loaded data
    updateWasteSelectionUI();
    updateUpcomingPickupsUI();
    updatePickupHistoryUI();
    updateStatsUI();
}

// Waste Selection
function updateWasteSelectionUI() {
    const wasteList = document.getElementById('availableWasteList');
    const emptyState = document.getElementById('noWasteEmptyState');

    if (!wasteList) return;

    if (availableWaste.length === 0) {
        wasteList.style.display = 'none';
        emptyState.style.display = 'block';
        return;
    }

    wasteList.style.display = 'grid';
    emptyState.style.display = 'none';

    // Clear existing content
    wasteList.innerHTML = '';

    // Generate waste cards
    availableWaste.forEach(waste => {
        const isSelected = selectedWasteIds.includes(waste.ReportId);
        const wasteCard = document.createElement('div');
        wasteCard.className = `waste-card ${isSelected ? 'selected' : ''}`;
        wasteCard.setAttribute('data-id', waste.ReportId);
        wasteCard.innerHTML = `
            <div class="waste-header">
                <div class="waste-type">
                    <div class="waste-icon">
                        <i class="${getWasteTypeIcon(waste.TypeName)}"></i>
                    </div>
                    <div>
                        <div class="waste-type-name">${waste.TypeName}</div>
                        <div class="waste-id">${waste.ReportId}</div>
                    </div>
                </div>
                <div class="checkbox-container"></div>
            </div>
            
            <div class="waste-details">
                <div class="waste-detail">
                    <i class="fas fa-weight-hanging"></i>
                    <span>${waste.EstimatedKg} kg</span>
                </div>
                <div class="waste-detail">
                    <i class="fas fa-calendar"></i>
                    <span>Reported ${waste.TimeAgo}</span>
                </div>
            </div>
            
            <div class="waste-address">
                <i class="fas fa-map-marker-alt"></i>
                ${waste.Address}
            </div>
            
            <div class="waste-timestamp">
                <div class="timestamp">
                    <i class="fas fa-clock"></i>
                    ${waste.TimeAgo}
                </div>
            </div>
        `;

        // Add click event
        wasteCard.addEventListener('click', function () {
            toggleWasteSelection(waste.ReportId);
        });

        wasteList.appendChild(wasteCard);
    });
}

function toggleWasteSelection(wasteId) {
    const index = selectedWasteIds.indexOf(wasteId);
    if (index === -1) {
        selectedWasteIds.push(wasteId);
    } else {
        selectedWasteIds.splice(index, 1);
    }

    // Update hidden field
    document.getElementById('<%= hfSelectedWasteId.ClientID %>').value = selectedWasteIds.join(',');

    // Update UI
    updateWasteSelectionUI();
}

function getWasteTypeIcon(typeName) {
    const icons = {
        'Plastic': 'fas fa-wine-bottle',
        'Paper': 'fas fa-newspaper',
        'Glass': 'fas fa-glass-whiskey',
        'Metal': 'fas fa-cogs',
        'E-Waste': 'fas fa-laptop',
        'Organic': 'fas fa-leaf'
    };

    return icons[typeName] || 'fas fa-trash-alt';
}

function updateSelectedWastePreview() {
    const preview = document.getElementById('selectedWastePreview');
    if (!preview) return;

    if (selectedWasteIds.length === 0) {
        preview.innerHTML = `
            <h3>No Waste Selected</h3>
            <p>Please go back and select waste for pickup.</p>
        `;
        return;
    }

    const selectedWaste = availableWaste.filter(w => selectedWasteIds.includes(w.ReportId));

    let html = `
        <h3>Selected for Pickup (${selectedWaste.length})</h3>
        <div class="selected-waste-list">
    `;

    selectedWaste.forEach(waste => {
        html += `
            <div class="selected-waste-tag">
                ${waste.TypeName} (${waste.EstimatedKg}kg)
                <button class="remove-waste" onclick="removeSelectedWaste('${waste.ReportId}')">
                    <i class="fas fa-times"></i>
                </button>
            </div>
        `;
    });

    html += '</div>';
    preview.innerHTML = html;
}

function removeSelectedWaste(wasteId) {
    const index = selectedWasteIds.indexOf(wasteId);
    if (index !== -1) {
        selectedWasteIds.splice(index, 1);
        document.getElementById('<%= hfSelectedWasteId.ClientID %>').value = selectedWasteIds.join(',');
        updateWasteSelectionUI();
        updateSelectedWastePreview();
    }
}

// Date Picker
function initializeDatePicker() {
    const datePicker = document.getElementById('<%= txtPickupDate.ClientID %>');
    if (!datePicker) return;

    // Calculate min and max dates (tomorrow to 30 days from now)
    const tomorrow = new Date();
    tomorrow.setDate(tomorrow.getDate() + 1);

    const maxDate = new Date();
    maxDate.setDate(maxDate.getDate() + 30);

    flatpickr(datePicker, {
        minDate: tomorrow,
        maxDate: maxDate,
        dateFormat: 'Y-m-d',
        disable: [
            function (date) {
                // Disable weekends
                return (date.getDay() === 0 || date.getDay() === 6);
            }
        ],
        onChange: function (selectedDates, dateStr) {
            selectedDate = dateStr;
            document.getElementById('<%= hfSelectedDate.ClientID %>').value = dateStr;
            updateTimeSlots();
        }
    });
}

// Time Slots
function initializeTimeSlots() {
    updateTimeSlots();
}

function updateTimeSlots() {
    const timeSlotsGrid = document.getElementById('timeSlotsGrid');
    if (!timeSlotsGrid) return;

    const timeSlots = [
        '08:00', '09:00', '10:00', '11:00', '12:00',
        '13:00', '14:00', '15:00', '16:00', '17:00'
    ];

    timeSlotsGrid.innerHTML = '';

    timeSlots.forEach(slot => {
        const timeSlot = document.createElement('div');
        const isSelected = selectedTime === slot;
        const isDisabled = !selectedDate; // Disable if no date selected

        timeSlot.className = `time-slot ${isSelected ? 'selected' : ''} ${isDisabled ? 'disabled' : ''}`;
        timeSlot.textContent = formatTimeSlot(slot);
        timeSlot.setAttribute('data-time', slot);

        if (!isDisabled) {
            timeSlot.addEventListener('click', function () {
                selectTimeSlot(slot);
            });
        }

        timeSlotsGrid.appendChild(timeSlot);
    });
}

function selectTimeSlot(time) {
    selectedTime = time;
    document.getElementById('<%= hfSelectedTime.ClientID %>').value = time;
    updateTimeSlots();
}

function formatTimeSlot(time) {
    const [hours, minutes] = time.split(':');
    const hour = parseInt(hours);
    const period = hour >= 12 ? 'PM' : 'AM';
    const displayHour = hour > 12 ? hour - 12 : hour;
    return `${displayHour}:${minutes} ${period}`;
}

// Upcoming Pickups
function updateUpcomingPickupsUI() {
    const upcomingGrid = document.getElementById('upcomingGrid');
    const emptyState = document.getElementById('upcomingEmptyState');
    const upcomingCount = document.getElementById('upcomingCount');

    if (!upcomingGrid) return;

    if (upcomingPickups.length === 0) {
        upcomingGrid.style.display = 'none';
        emptyState.style.display = 'block';
        if (upcomingCount) upcomingCount.textContent = '0';
        return;
    }

    upcomingGrid.style.display = 'grid';
    emptyState.style.display = 'none';
    if (upcomingCount) upcomingCount.textContent = upcomingPickups.length.toString();

    // Clear existing content
    upcomingGrid.innerHTML = '';

    // Generate pickup cards
    upcomingPickups.forEach(pickup => {
        const pickupCard = document.createElement('div');
        pickupCard.className = 'pickup-card';
        pickupCard.innerHTML = `
            <div class="pickup-header">
                <div class="pickup-id">${pickup.PickupId}</div>
                <div class="pickup-status status-${pickup.Status.toLowerCase().replace(' ', '-')}">
                    ${pickup.Status}
                </div>
            </div>
            
            <div class="pickup-details">
                <div class="pickup-detail">
                    <i class="fas fa-trash-alt"></i>
                    <span>${pickup.WasteType}</span>
                </div>
                <div class="pickup-detail">
                    <i class="fas fa-weight-hanging"></i>
                    <span>${pickup.EstimatedKg} kg</span>
                </div>
                <div class="pickup-detail">
                    <i class="fas fa-calendar-day"></i>
                    <span>${pickup.ScheduledDate}</span>
                </div>
            </div>
            
            <div class="pickup-actions">
                <button class="btn-action" onclick="viewPickupDetails('${pickup.PickupId}')">
                    <i class="fas fa-eye"></i> View
                </button>
                <button class="btn-action cancel" onclick="cancelPickup('${pickup.PickupId}')">
                    <i class="fas fa-times"></i> Cancel
                </button>
            </div>
        `;

        // Add status class
        const statusElement = pickupCard.querySelector('.pickup-status');
        statusElement.className = `pickup-status status-${getStatusClass(pickup.Status)}`;

        upcomingGrid.appendChild(pickupCard);
    });
}

function getStatusClass(status) {
    const classes = {
        'Scheduled': 'scheduled',
        'Assigned': 'assigned',
        'In Progress': 'in-progress',
        'Completed': 'completed',
        'Cancelled': 'cancelled'
    };
    return classes[status] || 'scheduled';
}

// Pickup History
function updatePickupHistoryUI() {
    const historyBody = document.getElementById('historyTableBody');
    const emptyState = document.getElementById('historyEmptyState');

    if (!historyBody) return;

    if (pickupHistory.length === 0) {
        historyBody.innerHTML = '<tr><td colspan="7" class="text-center">No pickup history found</td></tr>';
        emptyState.style.display = 'block';
        return;
    }

    emptyState.style.display = 'none';

    // Clear existing content
    historyBody.innerHTML = '';

    // Generate history rows
    pickupHistory.forEach(history => {
        const row = document.createElement('tr');
        row.innerHTML = `
            <td>${history.CompletedDate}</td>
            <td>${history.WasteType}</td>
            <td>${history.Weight} kg</td>
            <td>${history.Collector}</td>
            <td>${history.XPEarned} XP</td>
            <td>
                <span class="status-badge status-${history.Status.toLowerCase()}">
                    ${history.Status}
                </span>
            </td>
            <td>
                <button class="btn-action" onclick="viewHistoryDetails('${history.PickupId}')">
                    <i class="fas fa-eye"></i>
                </button>
            </td>
        `;

        historyBody.appendChild(row);
    });
}

function filterHistory() {
    const timeframe = document.getElementById('filterTimeframe').value;
    const status = document.getElementById('filterStatus').value;

    // In a real implementation, this would filter the data
    // For now, we'll just reload the data
    loadAllData();
}

// Stats
function updateStatsUI() {
    document.getElementById('totalPickups').textContent = statsData.TotalPickups || 0;
    document.getElementById('scheduledPickups').textContent = statsData.ScheduledPickups || 0;
    document.getElementById('completedPickups').textContent = statsData.CompletedPickups || 0;
    document.getElementById('successRate').textContent = `${statsData.SuccessRate || 0}%`;
}

// Actions
function quickSchedule() {
    // Auto-select first available waste and schedule for next available slot
    if (availableWaste.length > 0) {
        // Select first waste
        selectedWasteIds = [availableWaste[0].ReportId];
        document.getElementById('<%= hfSelectedWasteId.ClientID %>').value = selectedWasteIds[0];

        // Set date to tomorrow
        const tomorrow = new Date();
        tomorrow.setDate(tomorrow.getDate() + 1);
        selectedDate = tomorrow.toISOString().split('T')[0];
        document.getElementById('<%= hfSelectedDate.ClientID %>').value = selectedDate;

        // Set time to 10:00 AM
        selectedTime = '10:00';
        document.getElementById('<%= hfSelectedTime.ClientID %>').value = selectedTime;

        // Switch to schedule tab and step 2
        switchTab('schedule');
        nextScheduleStep(2);

        showNotification('Quick schedule configured! Please review and confirm.', 'info');
    } else {
        showNotification('No waste available for quick schedule', 'error');
    }
}

function viewPickupDetails(pickupId) {
    // In a real implementation, this would show a modal with pickup details
    showNotification(`Viewing details for pickup ${pickupId}`, 'info');
}

function cancelPickup(pickupId) {
    if (confirm(`Are you sure you want to cancel pickup ${pickupId}?`)) {
        // In a real implementation, this would call the server to cancel the pickup
        showNotification(`Pickup ${pickupId} cancellation requested`, 'warning');
        // Reload data after cancellation
        setTimeout(loadAllData, 1000);
    }
}

function viewHistoryDetails(pickupId) {
    // In a real implementation, this would show a modal with history details
    showNotification(`Viewing history details for pickup ${pickupId}`, 'info');
}

function refreshUpcoming() {
    // Show loading state
    const upcomingGrid = document.getElementById('upcomingGrid');
    if (upcomingGrid) {
        upcomingGrid.innerHTML = '<div class="loading-state"><i class="fas fa-spinner fa-spin"></i><p>Refreshing...</p></div>';
    }

    // In a real implementation, this would reload data from server
    setTimeout(() => {
        loadAllData();
        showNotification('Upcoming pickups refreshed', 'success');
    }, 1000);
}

// Form Validation for Submission
function validateSchedule() {
    if (selectedWasteIds.length === 0) {
        showNotification('Please select waste for pickup', 'error');
        return false;
    }

    if (!selectedDate) {
        showNotification('Please select a pickup date', 'error');
        return false;
    }

    if (!selectedTime) {
        showNotification('Please select a time slot', 'error');
        return false;
    }

    // All validations passed
    return true;
}

// After successful schedule
function showConfirmation(pickupData) {
    // Move to step 3
    document.querySelectorAll('.schedule-step').forEach(step => {
        step.classList.remove('active');
    });
    document.getElementById('step3').classList.add('active');
    currentScheduleStep = 3;

    // Update confirmation details
    const confirmationDetails = document.getElementById('confirmationDetails');
    if (confirmationDetails) {
        confirmationDetails.innerHTML = `
            <div class="detail-row">
                <span class="detail-label">Pickup ID:</span>
                <span class="detail-value">${pickupData.PickupId}</span>
            </div>
            <div class="detail-row">
                <span class="detail-label">Date:</span>
                <span class="detail-value">${pickupData.Date}</span>
            </div>
            <div class="detail-row">
                <span class="detail-label">Time:</span>
                <span class="detail-value">${pickupData.Time}</span>
            </div>
            <div class="detail-row">
                <span class="detail-label">Items:</span>
                <span class="detail-value">${pickupData.ItemCount}</span>
            </div>
            <div class="detail-row">
                <span class="detail-label">Estimated Reward:</span>
                <span class="detail-value">${pickupData.EstimatedReward} XP</span>
            </div>
        `;
    }
}

function scheduleAnother() {
    resetScheduleSteps();
}

function viewUpcoming() {
    switchTab('upcoming');
}

// Notification System
function showNotification(message, type) {
    // Remove existing notifications
    const existingNotifications = document.querySelectorAll('.notification');
    existingNotifications.forEach(notif => notif.remove());

    // Create notification element
    const notification = document.createElement('div');
    notification.className = `notification ${type}`;
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
window.nextScheduleStep = nextScheduleStep;
window.prevScheduleStep = prevScheduleStep;
window.switchTab = switchTab;
window.quickSchedule = quickSchedule;
window.refreshUpcoming = refreshUpcoming;
window.filterHistory = filterHistory;
window.viewPickupDetails = viewPickupDetails;
window.cancelPickup = cancelPickup;
window.viewHistoryDetails = viewHistoryDetails;
window.removeSelectedWaste = removeSelectedWaste;
window.scheduleAnother = scheduleAnother;
window.viewUpcoming = viewUpcoming;
window.validateSchedule = validateSchedule;