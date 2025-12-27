
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

    // FAQ Toggle Functionality
    function toggleFAQ(element) {
            const faqItem = element.parentElement;
    const answer = faqItem.querySelector('.faq-answer');
    const isActive = faqItem.classList.contains('active');

            // Close all other FAQs
            document.querySelectorAll('.faq-item').forEach(item => {
                if (item !== faqItem) {
        item.classList.remove('active');
    item.querySelector('.faq-answer').classList.remove('show');
                }
            });

    // Toggle current FAQ
    if (!isActive) {
        faqItem.classList.add('active');
    answer.classList.add('show');
            } else {
        faqItem.classList.remove('active');
    answer.classList.remove('show');
            }
        }

    // Smooth scrolling to sections
    function scrollToSection(sectionId) {
            const element = document.getElementById(sectionId);
    if (element) {
        element.scrollIntoView({
            behavior: 'smooth',
            block: 'start'
        });
            }
        }

    // Live Chat Simulation
    function startLiveChat() {
        showToast('Live Chat', 'Connecting you with a support agent...', 'info');
            setTimeout(() => {
        showToast('Connected', 'You are now chatting with Support Agent Sarah. How can we help you today?', 'success');
            }, 2000);
        }

    // Form validation
    function validateSupportForm() {
            const fullName = document.getElementById('<%= txtFullName.ClientID %>').value;
    const email = document.getElementById('<%= txtEmail.ClientID %>').value;
    const issueType = document.getElementById('<%= ddlIssueType.ClientID %>').value;
    const description = document.getElementById('<%= txtDescription.ClientID %>').value;

    if (!fullName || fullName.trim() === '') {
        showToast('Validation Error', 'Please enter your full name.', 'error');
    return false;
            }

    if (!email || !isValidEmail(email)) {
        showToast('Validation Error', 'Please enter a valid email address.', 'error');
    return false;
            }

    if (!issueType) {
        showToast('Validation Error', 'Please select an issue type.', 'error');
    return false;
            }

    if (!description || description.trim().length < 10) {
        showToast('Validation Error', 'Please provide a detailed description of your issue (at least 10 characters).', 'error');
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
            const cards = document.querySelectorAll('.help-card, .quick-action-card, .channel-card');
            cards.forEach((card, index) => {
        card.style.opacity = '0';
    card.style.transform = 'translateY(20px)';
                setTimeout(() => {
        card.style.transition = 'all 0.6s ease';
    card.style.opacity = '1';
    card.style.transform = 'translateY(0)';
                }, index * 100);
            });

    // Open first FAQ by default
    const firstFAQ = document.querySelector('.faq-item');
    if (firstFAQ) {
        firstFAQ.classList.add('active');
    firstFAQ.querySelector('.faq-answer').classList.add('show');
            }
        });

    // Attach validation to submit button
    document.getElementById('<%= btnSubmitTicket.ClientID %>').addEventListener('click', function(e) {
            if (!validateSupportForm()) {
        e.preventDefault();
            }
        });