
        // Rating System
    document.addEventListener('DOMContentLoaded', function () {
            const stars = document.querySelectorAll('.rating-star');
    const ratingLabel = document.getElementById('ratingLabel');
    const ratingInput = document.getElementById('<%= hfRating.ClientID %>');

    const ratingLabels = {
        0: 'Click to rate',
    1: 'Poor',
    2: 'Fair',
    3: 'Good',
    4: 'Very Good',
    5: 'Excellent'
            };

            stars.forEach(star => {
        star.addEventListener('click', function () {
            const rating = parseInt(this.getAttribute('data-rating'));
            ratingInput.value = rating;
            ratingLabel.textContent = ratingLabels[rating];

            // Update star display
            stars.forEach((s, index) => {
                if (index < rating) {
                    s.classList.add('active');
                } else {
                    s.classList.remove('active');
                }
            });
        });

    star.addEventListener('mouseover', function () {
                    const rating = parseInt(this.getAttribute('data-rating'));
    ratingLabel.textContent = ratingLabels[rating];
                });

    star.addEventListener('mouseout', function () {
                    const currentRating = parseInt(ratingInput.value);
    ratingLabel.textContent = ratingLabels[currentRating];
                });
            });
        });

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

    // Form validation
    function validateFeedback() {
            const category = document.getElementById('<%= ddlCategory.ClientID %>').value;
    const priority = document.getElementById('<%= ddlPriority.ClientID %>').value;
    const subject = document.getElementById('<%= txtSubject.ClientID %>').value;
    const feedback = document.getElementById('<%= txtFeedback.ClientID %>').value;
    const rating = document.getElementById('<%= hfRating.ClientID %>').value;

    if (!category) {
        showToast('Required Field', 'Please select a feedback category.', 'error');
    return false;
            }

    if (!priority) {
        showToast('Required Field', 'Please select a priority level.', 'error');
    return false;
            }

    if (!subject || subject.trim() === '') {
        showToast('Required Field', 'Please enter a subject for your feedback.', 'error');
    return false;
            }

    if (!feedback || feedback.trim() === '') {
        showToast('Required Field', 'Please provide detailed feedback.', 'error');
    return false;
            }

    if (feedback.length < 20) {
        showToast('Insufficient Detail', 'Please provide more detailed feedback (at least 20 characters).', 'error');
    return false;
            }

    if (rating === '0') {
        showToast('Rating Required', 'Please provide an overall satisfaction rating.', 'error');
    return false;
            }

    return true;
        }