// Initialize AOS
AOS.init({
    duration: 1000,
    once: true,
    offset: 100
});

// Theme Toggle Functionality
const themeToggle = document.getElementById('themeToggle');
const htmlElement = document.documentElement;

// Check for saved theme or prefer-color-scheme
const savedTheme = localStorage.getItem('theme') || 'dark';
htmlElement.setAttribute('data-theme', savedTheme);

themeToggle.addEventListener('click', () => {
    const currentTheme = htmlElement.getAttribute('data-theme');
    const newTheme = currentTheme === 'dark' ? 'light' : 'dark';

    htmlElement.setAttribute('data-theme', newTheme);
    localStorage.setItem('theme', newTheme);

    // Animate the toggle
    themeToggle.style.transform = 'rotate(180deg) scale(1.2)';
    setTimeout(() => {
        themeToggle.style.transform = 'rotate(0deg) scale(1)';
    }, 300);
});

// Create particle background
function createParticles() {
    const particlesContainer = document.getElementById('particles');
    const particleCount = 50;

    for (let i = 0; i < particleCount; i++) {
        const particle = document.createElement('div');
        particle.className = 'particle';

        // Random properties
        const size = Math.random() * 5 + 1;
        const left = Math.random() * 100;
        const animationDuration = Math.random() * 20 + 10;
        const animationDelay = Math.random() * 20;

        particle.style.width = `${size}px`;
        particle.style.height = `${size}px`;
        particle.style.left = `${left}%`;
        particle.style.animationDuration = `${animationDuration}s`;
        particle.style.animationDelay = `${animationDelay}s`;
        particle.style.background = `rgba(${Math.random() * 255}, ${Math.random() * 255}, ${Math.random() * 255}, 0.1)`;

        particlesContainer.appendChild(particle);
    }
}

// Add click handlers for card clicks to open modals
document.addEventListener('DOMContentLoaded', function () {
    createParticles();

    const cards = document.querySelectorAll('.app-card');
    cards.forEach(card => {
        card.addEventListener('click', function (e) {
            if (!e.target.closest('.app-button')) {
                const targetModal = this.getAttribute('data-bs-target');
                const modal = new bootstrap.Modal(document.querySelector(targetModal));
                modal.show();
            }
        });
    });

    // Animate stats
    function animateStats() {
        const stats = document.querySelectorAll('.stat-number');
        stats.forEach(stat => {
            const finalValue = stat.textContent;
            let current = 0;
            const increment = parseInt(finalValue) / 50;
            const timer = setInterval(() => {
                current += increment;
                if (current >= parseInt(finalValue)) {
                    stat.textContent = finalValue;
                    clearInterval(timer);
                } else {
                    stat.textContent = Math.floor(current) + '+';
                }
            }, 50);
        });
    }

    // Trigger stats animation when in view
    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                animateStats();
                observer.unobserve(entry.target);
            }
        });
    });

    observer.observe(document.querySelector('.stats-section'));

    // Smooth scrolling for navigation
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function (e) {
            e.preventDefault();
            const target = document.querySelector(this.getAttribute('href'));
            if (target) {
                target.scrollIntoView({
                    behavior: 'smooth',
                    block: 'start'
                });
            }
        });
    });

    // Add loading states to ASP.NET buttons
    const aspNetButtons = document.querySelectorAll('input[type="submit"].app-button');
    aspNetButtons.forEach(button => {
        button.addEventListener('click', function (e) {
            // Add loading class
            this.classList.add('loading');

            // Store original value
            const originalValue = this.value;
            this.value = 'Loading...';

            // Revert after 5 seconds if still on page
            setTimeout(() => {
                if (this.classList.contains('loading')) {
                    this.classList.remove('loading');
                    this.value = originalValue;
                }
            }, 5000);
        });
    });

    // Database schema table hover effect
    const schemaTables = document.querySelectorAll('.schema-table');
    schemaTables.forEach(table => {
        table.addEventListener('mouseenter', function () {
            const tableName = this.getAttribute('data-table');
            schemaTables.forEach(t => {
                if (t !== this) {
                    t.style.opacity = '0.6';
                    t.style.transform = 'scale(0.95)';
                }
            });
        });

        table.addEventListener('mouseleave', function () {
            schemaTables.forEach(t => {
                t.style.opacity = '1';
                t.style.transform = 'scale(1)';
            });
        });
    });

    // Team card interaction
    const teamCards = document.querySelectorAll('.team-card');
    teamCards.forEach(card => {
        card.addEventListener('mouseenter', function () {
            const avatar = this.querySelector('.team-avatar');
            if (avatar) {
                avatar.style.transform = 'scale(1.1) rotate(5deg)';
            }
        });

        card.addEventListener('mouseleave', function () {
            const avatar = this.querySelector('.team-avatar');
            if (avatar) {
                avatar.style.transform = 'scale(1) rotate(0deg)';
            }
        });
    });

    // Tech stack category interaction
    const techCategories = document.querySelectorAll('.tech-stack-category');
    techCategories.forEach(category => {
        category.addEventListener('mouseenter', function () {
            this.style.transform = 'translateY(-5px)';
            this.style.boxShadow = '0 10px 20px rgba(0, 0, 0, 0.2)';
        });

        category.addEventListener('mouseleave', function () {
            this.style.transform = 'translateY(0)';
            this.style.boxShadow = 'none';
        });
    });
});

// Application launch simulation
// Make functions globally available
window.simulateApplicationLaunch = function (appName, teamInfo) {
    console.log(`Launching ${appName}...`);
    console.log(`Team: ${teamInfo}`);

    // Show toast notification
    showToast(`${appName} is launching...`, 'success');

    // Simulate network delay
    setTimeout(() => {
        showToast(`${appName} launched successfully!`, 'success');
    }, 1500);

    return true;
};

window.showToast = function (message, type = 'info') {
    const toast = document.createElement('div');
    toast.className = `toast-notification ${type}`;
    toast.innerHTML = `
        <i class="fas fa-${type === 'success' ? 'check-circle' : 'info-circle'}"></i>
        <span>${message}</span>
    `;

    document.body.appendChild(toast);

    // Animate in
    setTimeout(() => {
        toast.style.transform = 'translateX(0)';
        toast.style.opacity = '1';
    }, 10);

    // Remove after delay
    setTimeout(() => {
        toast.style.transform = 'translateX(100%)';
        toast.style.opacity = '0';
        setTimeout(() => {
            if (toast.parentNode) {
                toast.parentNode.removeChild(toast);
            }
        }, 300);
    }, 3000);
};

// Add toast CSS
const toastStyles = document.createElement('style');
toastStyles.textContent = `
.toast-notification {
    position: fixed;
    top: 20px;
    right: 20px;
    background: var(--card-bg);
    border: 1px solid var(--card-border);
    color: var(--light);
    padding: 1rem 1.5rem;
    border-radius: 10px;
    display: flex;
    align-items: center;
    gap: 0.8rem;
    z-index: 10000;
    transform: translateX(100%);
    opacity: 0;
    transition: all 0.3s ease;
    backdrop-filter: blur(10px);
}

.toast-notification.success {
    border-left: 4px solid var(--success);
}

.toast-notification i {
    color: var(--success);
    font-size: 1.2rem;
}
`;
document.head.appendChild(toastStyles);
