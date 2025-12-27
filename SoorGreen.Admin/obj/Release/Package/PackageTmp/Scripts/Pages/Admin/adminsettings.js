
        // GLOBAL VARIABLES
    let currentSettings = { };
    let pendingAction = null;

    // INITIALIZE
    document.addEventListener('DOMContentLoaded', function () {
        initializeEventListeners();
    loadSettingsFromServer();
        });

    function initializeEventListeners() {
        // Save buttons
        document.getElementById('saveGeneralBtn').addEventListener('click', function (e) {
            e.preventDefault();
            saveGeneralSettings();
        });

    document.getElementById('saveCreditBtn').addEventListener('click', function (e) {
        e.preventDefault();
    saveCreditSettings();
            });

    document.getElementById('saveNotificationBtn').addEventListener('click', function (e) {
        e.preventDefault();
    saveNotificationSettings();
            });

    document.getElementById('saveSecurityBtn').addEventListener('click', function (e) {
        e.preventDefault();
    saveSecuritySettings();
            });

    // System info buttons
    document.getElementById('refreshSystemInfoBtn').addEventListener('click', function (e) {
        e.preventDefault();
    refreshSystemInfo();
            });

    document.getElementById('backupNowBtn').addEventListener('click', function (e) {
        e.preventDefault();
    backupDatabase();
            });

    // Danger zone buttons
    document.getElementById('purgeRecordsBtn').addEventListener('click', function (e) {
        e.preventDefault();
    showConfirmation(
    'Purge Old Records',
    'Are you sure you want to purge records older than ' + document.getElementById('purgeDays').value + ' days?',
    'This will permanently delete pickup records, audit logs, and other data older than the specified days. This action cannot be undone.',
    'purgeRecords'
    );
            });

    document.getElementById('resetSystemBtn').addEventListener('click', function (e) {
        e.preventDefault();
    showConfirmation(
    'Reset System',
    'Are you sure you want to reset the entire system?',
    'This will reset all settings to default values and clear temporary data. User accounts and credits will be preserved.',
    'resetSystem'
    );
            });

    document.getElementById('clearAllDataBtn').addEventListener('click', function (e) {
        e.preventDefault();
    showConfirmation(
    'Clear All Data',
    'ARE YOU ABSOLUTELY SURE?',
    'This will PERMANENTLY DELETE ALL USER DATA, TRANSACTIONS, CREDITS, AND EVERYTHING. This action is irreversible and will destroy all data.',
    'clearAllData'
    );
            });

            // Modal buttons
            document.querySelectorAll('.close-modal').forEach(btn => {
        btn.addEventListener('click', function (e) {
            e.preventDefault();
            closeAllModals();
        });
            });

    document.getElementById('cancelConfirmBtn').addEventListener('click', function (e) {
        e.preventDefault();
    closeAllModals();
            });

    document.getElementById('confirmActionBtn').addEventListener('click', function (e) {
        e.preventDefault();
    executePendingAction();
            });

    // Close modals when clicking outside
    document.getElementById('confirmationModal').addEventListener('click', function (e) {
                if (e.target === this) closeAllModals();
            });
        }

    function loadSettingsFromServer() {
        showLoading(true);

    const settingsData = document.getElementById('<%= hfSettingsData.ClientID %>').value;
    const systemInfo = document.getElementById('<%= hfSystemInfo.ClientID %>').value;

    console.log('Settings data received:', settingsData);

    if (settingsData && settingsData !== '{ }' && settingsData !== '') {
                try {
        currentSettings = JSON.parse(settingsData);
    populateSettingsForm();
    console.log('Successfully loaded settings');
                } catch (e) {
        console.error('Error parsing settings data:', e);
    currentSettings = getDefaultSettings();
                }
            } else {
        console.log('No settings data found, using defaults');
    currentSettings = getDefaultSettings();
            }

    if (systemInfo && systemInfo !== '{ }' && systemInfo !== '') {
                try {
        updateSystemInfo(JSON.parse(systemInfo));
                } catch (e) {
        console.error('Error parsing system info:', e);
                }
            }

    showLoading(false);
        }

    function getDefaultSettings() {
            return {
        general: {
        appName: 'SoorGreen',
    supportEmail: 'support@soorgreen.com',
    supportPhone: '+1-555-123-4567',
    maintenanceMode: false
                },
    credits: {
        creditToCurrency: 0.01,
    minRedemption: 50,
    plasticRate: 2.50,
    paperRate: 1.80,
    glassRate: 1.20,
    metalRate: 3.00,
    organicRate: 0.80,
    autoCreditDistribution: true
                },
    notifications: {
        emailNotifications: true,
    smsNotifications: false,
    pushNotifications: true,
    notificationSchedule: 'instant'
                },
    security: {
        sessionTimeout: 30,
    maxLoginAttempts: 5,
    passwordExpiry: 90,
    twoFactorAuth: false,
    apiRateLimiting: true
                }
            };
        }

    function populateSettingsForm() {
        // General Settings
        document.getElementById('appName').value = currentSettings.general?.appName || 'SoorGreen';
    document.getElementById('supportEmail').value = currentSettings.general?.supportEmail || 'support@soorgreen.com';
    document.getElementById('supportPhone').value = currentSettings.general?.supportPhone || '+1-555-123-4567';
    document.getElementById('maintenanceMode').checked = currentSettings.general?.maintenanceMode || false;

    // Credit Settings
    document.getElementById('creditToCurrency').value = currentSettings.credits?.creditToCurrency || 0.01;
    document.getElementById('minRedemption').value = currentSettings.credits?.minRedemption || 50;
    document.getElementById('plasticRate').textContent = currentSettings.credits?.plasticRate || 2.50;
    document.getElementById('paperRate').textContent = currentSettings.credits?.paperRate || 1.80;
    document.getElementById('glassRate').textContent = currentSettings.credits?.glassRate || 1.20;
    document.getElementById('metalRate').textContent = currentSettings.credits?.metalRate || 3.00;
    document.getElementById('autoCreditDistribution').checked = currentSettings.credits?.autoCreditDistribution || true;

    // Notification Settings
    document.getElementById('emailNotifications').checked = currentSettings.notifications?.emailNotifications || true;
    document.getElementById('smsNotifications').checked = currentSettings.notifications?.smsNotifications || false;
    document.getElementById('pushNotifications').checked = currentSettings.notifications?.pushNotifications || true;
    document.getElementById('notificationSchedule').value = currentSettings.notifications?.notificationSchedule || 'instant';

    // Security Settings
    document.getElementById('sessionTimeout').value = currentSettings.security?.sessionTimeout || 30;
    document.getElementById('maxLoginAttempts').value = currentSettings.security?.maxLoginAttempts || 5;
    document.getElementById('passwordExpiry').value = currentSettings.security?.passwordExpiry || 90;
    document.getElementById('twoFactorAuth').checked = currentSettings.security?.twoFactorAuth || false;
    document.getElementById('apiRateLimiting').checked = currentSettings.security?.apiRateLimiting || true;
        }

    function updateSystemInfo(systemInfo) {
        document.getElementById('totalUsers').textContent = systemInfo.TotalUsers || 0;
    document.getElementById('totalPickups').textContent = systemInfo.TotalPickups || 0;
    document.getElementById('totalCredits').textContent = systemInfo.TotalCredits || 0;
    document.getElementById('appVersion').textContent = systemInfo.AppVersion || '1.0.0';
    document.getElementById('dbSize').value = systemInfo.DatabaseSize || 'Unknown';
    document.getElementById('lastBackup').value = systemInfo.LastBackup || 'Never';
    document.getElementById('systemUptime').value = systemInfo.SystemUptime || 'Unknown';
        }

    function saveGeneralSettings() {
            const settings = {
        appName: document.getElementById('appName').value,
    supportEmail: document.getElementById('supportEmail').value,
    supportPhone: document.getElementById('supportPhone').value,
    maintenanceMode: document.getElementById('maintenanceMode').checked
            };

    if (!settings.appName || !settings.supportEmail) {
        showNotification('Please fill in all required fields', 'error');
    return;
            }

    showLoading(true);

            // Simulate API call
            setTimeout(() => {
                if (!currentSettings.general) currentSettings.general = { };
    Object.assign(currentSettings.general, settings);

    showNotification('General settings saved successfully!', 'success');
    showLoading(false);
            }, 800);
        }

    function saveCreditSettings() {
            const settings = {
        creditToCurrency: parseFloat(document.getElementById('creditToCurrency').value),
    minRedemption: parseInt(document.getElementById('minRedemption').value),
    autoCreditDistribution: document.getElementById('autoCreditDistribution').checked
            };

    if (isNaN(settings.creditToCurrency) || isNaN(settings.minRedemption)) {
        showNotification('Please enter valid numbers for credit settings', 'error');
    return;
            }

    showLoading(true);

            // Simulate API call
            setTimeout(() => {
                if (!currentSettings.credits) currentSettings.credits = { };
    Object.assign(currentSettings.credits, settings);

    showNotification('Credit settings saved successfully!', 'success');
    showLoading(false);
            }, 800);
        }

    function saveNotificationSettings() {
            const settings = {
        emailNotifications: document.getElementById('emailNotifications').checked,
    smsNotifications: document.getElementById('smsNotifications').checked,
    pushNotifications: document.getElementById('pushNotifications').checked,
    notificationSchedule: document.getElementById('notificationSchedule').value
            };

    showLoading(true);

            // Simulate API call
            setTimeout(() => {
                if (!currentSettings.notifications) currentSettings.notifications = { };
    Object.assign(currentSettings.notifications, settings);

    showNotification('Notification settings saved successfully!', 'success');
    showLoading(false);
            }, 800);
        }

    function saveSecuritySettings() {
            const settings = {
        sessionTimeout: parseInt(document.getElementById('sessionTimeout').value),
    maxLoginAttempts: parseInt(document.getElementById('maxLoginAttempts').value),
    passwordExpiry: parseInt(document.getElementById('passwordExpiry').value),
    twoFactorAuth: document.getElementById('twoFactorAuth').checked,
    apiRateLimiting: document.getElementById('apiRateLimiting').checked
            };

    if (isNaN(settings.sessionTimeout) || isNaN(settings.maxLoginAttempts) || isNaN(settings.passwordExpiry)) {
        showNotification('Please enter valid numbers for security settings', 'error');
    return;
            }

    showLoading(true);

            // Simulate API call
            setTimeout(() => {
                if (!currentSettings.security) currentSettings.security = { };
    Object.assign(currentSettings.security, settings);

    showNotification('Security settings saved successfully!', 'success');
    showLoading(false);
            }, 800);
        }

    function refreshSystemInfo() {
        showLoading(true);
    document.getElementById('<%= btnLoadSettings.ClientID %>').click();

    setTimeout(function () {
        loadSettingsFromServer();
    showNotification('System information refreshed!', 'success');
            }, 500);
        }

    function backupDatabase() {
        showLoading(true);

            // Simulate API call
            setTimeout(() => {
                const now = new Date();
    document.getElementById('lastBackup').value = now.toLocaleString();
    showNotification('Database backup completed successfully!', 'success');
    showLoading(false);
            }, 1500);
        }

    function showConfirmation(title, message, details, action) {
        document.getElementById('confirmationTitle').textContent = title;
    document.getElementById('confirmationMessage').textContent = message;
    document.getElementById('confirmationDetails').textContent = details;

    // Change icon based on severity
    const icon = document.getElementById('confirmationIcon');
    if (action === 'clearAllData') {
        icon.className = 'fas fa-skull-crossbones fa-3x text-danger mb-3';
            } else {
        icon.className = 'fas fa-exclamation-triangle fa-3x text-warning mb-3';
            }

    pendingAction = action;
    document.getElementById('confirmationModal').style.display = 'block';
        }

    function executePendingAction() {
        showLoading(true);

    let message = '';

    switch (pendingAction) {
                case 'purgeRecords':
    const days = document.getElementById('purgeDays').value;
    message = `Purged records older than ${days} days successfully!`;
    break;
    case 'resetSystem':
    currentSettings = getDefaultSettings();
    populateSettingsForm();
    message = 'System reset to default settings!';
    break;
    case 'clearAllData':
    message = 'ALL DATA HAS BEEN PERMANENTLY DELETED!';
    // In a real scenario, this would call a dangerous API
    break;
            }
            
            setTimeout(() => {
        showNotification(message, pendingAction === 'clearAllData' ? 'error' : 'success');
    closeAllModals();
    showLoading(false);
    pendingAction = null;
            }, 1500);
        }

    function closeAllModals() {
        document.getElementById('confirmationModal').style.display = 'none';
    pendingAction = null;
        }

    function showLoading(show) {
            const spinner = document.getElementById('loadingSpinner');
    const settingsGrid = document.querySelector('.settings-grid');

    if (show) {
        spinner.style.display = 'block';
    settingsGrid.style.display = 'none';
            } else {
        spinner.style.display = 'none';
    settingsGrid.style.display = 'grid';
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

    // ASP.NET AJAX support
    var prm = Sys.WebForms.PageRequestManager.getInstance();
    prm.add_endRequest(function () {
        initializeEventListeners();
    loadSettingsFromServer();
        });