
        // Toaster Notification System
    function showToast(title, message, type) {
            const toastContainer = document.getElementById('toastContainer');
    const toastId = 'toast-' + Date.now();

    const toast = document.createElement('div');
    toast.className = `toast toast-${type} show`;
    toast.id = toastId;

    const icon = type === 'success' ? 'fa-check-circle' :
    type === 'error' ? 'fa-exclamation-circle' : 'fa-info-circle';

    toast.innerHTML = `
    <div class="toast-icon">
        <i class="fas ${icon}"></i>
    </div>
    <div class="toast-content">
        <div class="toast-title">${title}</div>
        <div class="toast-message">${message}</div>
    </div>
    <button class="toast-close" onclick="closeToast('${toastId}')">
        <i class="fas fa-times"></i>
    </button>
    `;

    toastContainer.appendChild(toast);

            // Auto remove after 5 seconds
            setTimeout(() => {
        closeToast(toastId);
            }, 5000);
        }

    function closeToast(toastId) {
            const toast = document.getElementById(toastId);
    if (toast) {
        toast.style.animation = 'fadeOut 0.3s ease forwards';
                setTimeout(() => {
                    if (toast.parentNode) {
        toast.parentNode.removeChild(toast);
                    }
                }, 300);
            }
        }

    // Password validation
    function validatePasswordChange() {
            const currentPassword = document.getElementById('<%= txtCurrentPassword.ClientID %>').value;
    const newPassword = document.getElementById('<%= txtNewPassword.ClientID %>').value;
    const confirmPassword = document.getElementById('<%= txtConfirmPassword.ClientID %>').value;

    if (!currentPassword) {
        showToast('Validation Error', 'Please enter your current password.', 'error');
    return false;
            }

    if (!newPassword) {
        showToast('Validation Error', 'Please enter a new password.', 'error');
    return false;
            }

    if (newPassword.length < 6) {
        showToast('Validation Error', 'New password must be at least 6 characters long.', 'error');
    return false;
            }

    if (newPassword !== confirmPassword) {
        showToast('Validation Error', 'New passwords do not match.', 'error');
    return false;
            }

    return true;
        }

    // Profile validation
    function validateProfileUpdate() {
            const fullName = document.getElementById('<%= txtFullName.ClientID %>').value;
    const phone = document.getElementById('<%= txtPhone.ClientID %>').value;
    const email = document.getElementById('<%= txtEmail.ClientID %>').value;

    if (!fullName || fullName.trim() === '') {
        showToast('Validation Error', 'Please enter your full name.', 'error');
    return false;
            }

    if (!phone || phone.trim() === '') {
        showToast('Validation Error', 'Please enter your phone number.', 'error');
    return false;
            }

    // Basic email validation
    if (email && !isValidEmail(email)) {
        showToast('Validation Error', 'Please enter a valid email address.', 'error');
    return false;
            }

    return true;
        }

    function isValidEmail(email) {
            const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email);
        }

    // Page load animations
    document.addEventListener('DOMContentLoaded', function() {
            // Animate cards on load
            const cards = document.querySelectorAll('.profile-card, .stat-card');
            cards.forEach((card, index) => {
        card.style.opacity = '0';
    card.style.transform = 'translateY(20px)';
                setTimeout(() => {
        card.style.transition = 'all 0.6s ease';
    card.style.opacity = '1';
    card.style.transform = 'translateY(0)';
                }, index * 100);
            });
        });

    // Attach validation to buttons
    document.getElementById('<%= btnUpdateProfile.ClientID %>').addEventListener('click', function(e) {
            if (!validateProfileUpdate()) {
        e.preventDefault();
            }
        });

    document.getElementById('<%= btnChangePassword.ClientID %>').addEventListener('click', function (e) {
            if (!validatePasswordChange()) {
        e.preventDefault();
            }
        });
