
        // GLOBAL VARIABLES
    let userProfile = { };
    let pendingAction = null;

    // INITIALIZE
    document.addEventListener('DOMContentLoaded', function () {
        initializeEventListeners();
    loadProfileFromServer();
        });

    function initializeEventListeners() {
        // Save buttons
        document.getElementById('savePersonalBtn').addEventListener('click', function (e) {
            e.preventDefault();
            savePersonalInfo();
        });

    document.getElementById('changePasswordBtn').addEventListener('click', function (e) {
        e.preventDefault();
    openPasswordModal();
            });

    document.getElementById('enable2FABtn').addEventListener('click', function (e) {
        e.preventDefault();
    enableTwoFactorAuth();
            });

    // Account management buttons
    document.getElementById('viewSessionsBtn').addEventListener('click', function (e) {
        e.preventDefault();
    viewSessions();
            });

    document.getElementById('exportDataBtn').addEventListener('click', function (e) {
        e.preventDefault();
    exportData();
            });

    document.getElementById('deleteAccountBtn').addEventListener('click', function (e) {
        e.preventDefault();
    showConfirmation(
    'Delete Account',
    'Are you sure you want to delete your account?',
    'This will permanently delete your account and all associated data. This action cannot be undone.',
    'deleteAccount'
    );
            });

            // Modal buttons
            document.querySelectorAll('.close-modal').forEach(btn => {
        btn.addEventListener('click', function (e) {
            e.preventDefault();
            closeAllModals();
        });
            });

    document.getElementById('cancelPasswordBtn').addEventListener('click', function (e) {
        e.preventDefault();
    closeAllModals();
            });

    document.getElementById('confirmPasswordBtn').addEventListener('click', function (e) {
        e.preventDefault();
    changePassword();
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
    document.getElementById('passwordModal').addEventListener('click', function (e) {
                if (e.target === this) closeAllModals();
            });

    document.getElementById('confirmationModal').addEventListener('click', function (e) {
                if (e.target === this) closeAllModals();
            });
        }

    function loadProfileFromServer() {
        showLoading(true);

    const profileData = document.getElementById('<%= hfProfileData.ClientID %>').value;
    const activityData = document.getElementById('<%= hfActivityData.ClientID %>').value;

    if (profileData && profileData !== '{ }' && profileData !== '') {
                try {
        userProfile = JSON.parse(profileData);
    populateProfileForm();
                } catch (e) {
        userProfile = getDefaultProfile();
                }
            } else {
        userProfile = getDefaultProfile();
            }

    if (activityData && activityData !== '[]' && activityData !== '') {
                try {
        populateActivityList(JSON.parse(activityData));
                } catch (e) {
        populateActivityList(getDefaultActivities());
                }
            } else {
        populateActivityList(getDefaultActivities());
            }

    showLoading(false);
        }

    function getDefaultProfile() {
            return {
        userId: "U009",
    fullName: "Admin User",
    email: "admin@soorgreen.com",
    phone: "+1-555-0123",
    role: "Administrator",
    totalLogins: 156,
    lastActive: "2 hours ago",
    memberSince: "45 days",
    status: "Active",
    twoFactorEnabled: false,
    activeSessions: 1
            };
        }

    function getDefaultActivities() {
            return [
    {
        icon: "fa-sign-in-alt",
    title: "Login Successful",
    description: "Logged in from Chrome on Windows",
    time: "2 hours ago",
    type: "success"
                },
    {
        icon: "fa-user-edit",
    title: "Profile Updated",
    description: "Updated personal information",
    time: "1 day ago",
    type: "info"
                },
    {
        icon: "fa-shield-alt",
    title: "Password Changed",
    description: "Account password was updated",
    time: "3 days ago",
    type: "warning"
                },
    {
        icon: "fa-users",
    title: "User Management",
    description: "Modified user permissions",
    time: "1 week ago",
    type: "info"
                },
    {
        icon: "fa-bell",
    title: "Notification Sent",
    description: "Sent system notification to all users",
    time: "1 week ago",
    type: "info"
                }
    ];
        }

    function populateProfileForm() {
        // Personal Information
        document.getElementById('profileAvatar').textContent = userProfile.fullName.charAt(0);
    document.getElementById('profileName').textContent = userProfile.fullName;
    document.getElementById('profileRole').textContent = userProfile.role;
    document.getElementById('fullName').value = userProfile.fullName;
    document.getElementById('email').value = userProfile.email;
    document.getElementById('phone').value = userProfile.phone;
    document.getElementById('userId').value = userProfile.userId;
    document.getElementById('role').value = userProfile.role;

    // Statistics
    document.getElementById('totalLogins').textContent = userProfile.totalLogins;
    document.getElementById('lastActive').textContent = userProfile.lastActive;
    document.getElementById('memberSince').textContent = userProfile.memberSince;
    document.getElementById('accountStatus').textContent = userProfile.status;

    // Security
    document.getElementById('twoFactorStatus').textContent = userProfile.twoFactorEnabled ? "Enabled" : "Disabled";
    document.getElementById('twoFactorStatus').className = userProfile.twoFactorEnabled ? "badge badge-success" : "badge badge-warning";
    document.getElementById('enable2FABtn').textContent = userProfile.twoFactorEnabled ? "Disable 2FA" : "Enable 2FA";
    document.getElementById('activeSessions').textContent = userProfile.activeSessions;
        }

    function populateActivityList(activities) {
            const activityList = document.getElementById('activityList');
    activityList.innerHTML = '';

            activities.forEach(activity => {
                const activityItem = document.createElement('div');
    activityItem.className = 'activity-item';

    activityItem.innerHTML = `
    <div class="activity-icon">
        <i class="fas ${activity.icon}"></i>
    </div>
    <div class="activity-content">
        <div class="activity-title">${escapeHtml(activity.title)}</div>
        <div class="activity-description">${escapeHtml(activity.description)}</div>
        <div class="activity-time">${escapeHtml(activity.time)}</div>
    </div>
    <span class="badge badge-${activity.type}">${activity.type}</span>
    `;

    activityList.appendChild(activityItem);
            });
        }

    function savePersonalInfo() {
            const fullName = document.getElementById('fullName').value.trim();
    const email = document.getElementById('email').value.trim();
    const phone = document.getElementById('phone').value.trim();

    if (!fullName || !email) {
        showNotification('Please fill in all required fields', 'error');
    return;
            }

    if (!isValidEmail(email)) {
        showNotification('Please enter a valid email address', 'error');
    return;
            }

    showLoading(true);

            // Simulate API call
            setTimeout(() => {
        userProfile.fullName = fullName;
    userProfile.email = email;
    userProfile.phone = phone;

    // Update display
    document.getElementById('profileAvatar').textContent = fullName.charAt(0);
    document.getElementById('profileName').textContent = fullName;

    showNotification('Personal information updated successfully!', 'success');
    showLoading(false);
            }, 800);
        }

    function openPasswordModal() {
        document.getElementById('passwordModal').style.display = 'block';

    // Clear form
    document.getElementById('modalCurrentPassword').value = '';
    document.getElementById('modalNewPassword').value = '';
    document.getElementById('modalConfirmPassword').value = '';
        }

    function changePassword() {
            const currentPassword = document.getElementById('modalCurrentPassword').value;
    const newPassword = document.getElementById('modalNewPassword').value;
    const confirmPassword = document.getElementById('modalConfirmPassword').value;

    if (!currentPassword || !newPassword || !confirmPassword) {
        showNotification('Please fill in all password fields', 'error');
    return;
            }

    if (newPassword !== confirmPassword) {
        showNotification('New passwords do not match', 'error');
    return;
            }

    if (newPassword.length < 8) {
        showNotification('Password must be at least 8 characters long', 'error');
    return;
            }

    showLoading(true);

            // Simulate API call
            setTimeout(() => {
        showNotification('Password changed successfully!', 'success');
    closeAllModals();
    showLoading(false);
            }, 800);
        }

    function enableTwoFactorAuth() {
        showLoading(true);

            // Simulate API call
            setTimeout(() => {
        userProfile.twoFactorEnabled = !userProfile.twoFactorEnabled;
    document.getElementById('twoFactorStatus').textContent = userProfile.twoFactorEnabled ? "Enabled" : "Disabled";
    document.getElementById('twoFactorStatus').className = userProfile.twoFactorEnabled ? "badge badge-success" : "badge badge-warning";
    document.getElementById('enable2FABtn').textContent = userProfile.twoFactorEnabled ? "Disable 2FA" : "Enable 2FA";

    showNotification(`Two-factor authentication ${userProfile.twoFactorEnabled ? 'enabled' : 'disabled'} successfully!`, 'success');
    showLoading(false);
            }, 800);
        }

    function viewSessions() {
        showNotification('Opening session management...', 'info');
            // In a real app, this would open a sessions modal
        }

    function exportData() {
        showLoading(true);

            // Simulate API call
            setTimeout(() => {
        showNotification('Your data export has been prepared and will be sent to your email.', 'success');
    showLoading(false);
            }, 1500);
        }

    function showConfirmation(title, message, details, action) {
        document.getElementById('confirmationTitle').textContent = title;
    document.getElementById('confirmationMessage').textContent = message;
    document.getElementById('confirmationDetails').textContent = details;

    pendingAction = action;
    document.getElementById('confirmationModal').style.display = 'block';
        }

    function executePendingAction() {
        showLoading(true);

    let message = '';

    switch (pendingAction) {
                case 'deleteAccount':
    message = 'Your account has been scheduled for deletion. You will receive a confirmation email.';
    break;
            }

            setTimeout(() => {
        showNotification(message, 'success');
    closeAllModals();
    showLoading(false);
    pendingAction = null;
            }, 1500);
        }

    function closeAllModals() {
        document.getElementById('passwordModal').style.display = 'none';
    document.getElementById('confirmationModal').style.display = 'none';
    pendingAction = null;
        }

    function isValidEmail(email) {
            const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email);
        }

    function showLoading(show) {
            const spinner = document.getElementById('loadingSpinner');
    const profileContainer = document.querySelector('.profile-container');

    if (show) {
        spinner.style.display = 'block';
    profileContainer.style.display = 'none';
            } else {
        spinner.style.display = 'none';
    profileContainer.style.display = 'block';
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

    function escapeHtml(unsafe) {
            if (!unsafe) return '';
    return unsafe.toString()
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
                .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&#039;");
        }

// ASP.NET AJAX support
var prm = Sys.WebForms.PageRequestManager.getInstance();
prm.add_endRequest(function () {
    initializeEventListeners();
    loadProfileFromServer();
});