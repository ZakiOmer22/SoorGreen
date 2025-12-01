
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

    // Notification interactions
    function markAsRead(notificationId) {
        // Show loading state
        showToast('Updating', 'Marking notification as read...', 'info');

    // You can implement AJAX call here for real-time updates
    // For now, we'll rely on postback
    return true;
        }

    function deleteNotification(notificationId) {
            if (confirm('Are you sure you want to delete this notification?')) {
        showToast('Deleting', 'Removing notification...', 'info');
    return true;
            }
    return false;
        }

    // Bulk actions visibility
    function updateBulkActions() {
            const checkboxes = document.querySelectorAll('.notification-checkbox input[type="checkbox"]');
    const bulkActions = document.getElementById('bulkActions');
            const anyChecked = Array.from(checkboxes).some(checkbox => checkbox.checked);

    if (anyChecked) {
        bulkActions.classList.remove('hidden');
            } else {
        bulkActions.classList.add('hidden');
            }
        }

    // Page load animations
    document.addEventListener('DOMContentLoaded', function() {
            // Animate notifications on load
            const notifications = document.querySelectorAll('.notification-item');
            notifications.forEach((notification, index) => {
        notification.style.opacity = '0';
    notification.style.transform = 'translateX(-20px)';
                setTimeout(() => {
        notification.style.transition = 'all 0.5s ease';
    notification.style.opacity = '1';
    notification.style.transform = 'translateX(0)';
                }, index * 100);
            });

            // Attach event listeners to checkboxes
            document.querySelectorAll('.notification-checkbox input').forEach(checkbox => {
        checkbox.addEventListener('change', updateBulkActions);
            });
        });

        // Auto-refresh notifications every 30 seconds
        setInterval(() => {
        // You can implement AJAX refresh here
        console.log('Auto-refreshing notifications...');
        }, 30000);