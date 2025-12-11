// Theme Toggle
const themeToggle = document.getElementById('themeToggle');
themeToggle.addEventListener('click', () => {
    const currentTheme = document.documentElement.getAttribute('data-theme');
    const newTheme = currentTheme === 'dark' ? 'light' : 'dark';
    document.documentElement.setAttribute('data-theme', newTheme);
    localStorage.setItem('theme', newTheme);
});

// Load saved theme
const savedTheme = localStorage.getItem('theme') || 'dark';
document.documentElement.setAttribute('data-theme', savedTheme);

// Video Intro Functionality
const videoIntro = document.getElementById('videoIntro');
const mainContent = document.getElementById('mainContent');
const skipButtonContainer = document.getElementById('skipButtonContainer');

function skipVideo() {
    videoIntro.classList.add('fade-out');
    skipButtonContainer.style.opacity = '0';
    setTimeout(() => {
        videoIntro.style.display = 'none';
        skipButtonContainer.style.display = 'none';
        mainContent.style.opacity = '1';
    }, 1500);
}

function replayVideo() {
    videoIntro.style.display = 'flex';
    skipButtonContainer.style.display = 'block';
    videoIntro.classList.remove('fade-out');
    skipButtonContainer.style.opacity = '1';
    const video = document.querySelector('.video-intro');
    video.currentTime = 0;
    video.play();
}

// Auto-skip after 10 seconds
setTimeout(skipVideo, 10000);

// Initialize AOS
AOS.init({
    duration: 800,
    once: true,
    offset: 100
});

// Helper functions
function showDatabaseDiagram() {
    alert('Database Schema:\n\n' +
        '1. Users - User accounts & profiles\n' +
        '2. WasteReports - Waste collection requests\n' +
        '3. PickupRequests - Collection assignments\n' +
        '4. RewardPoints - Credit transactions\n' +
        '5. WasteTypes - Waste categories\n' +
        '6. Municipalities - City/zone management\n' +
        '\nFull SQL script available in project docs.');
}

function showQuickGuide() {
    alert('Quick Start Guide:\n\n' +
        '1. Run Web Forms Admin: Port 44381\n' +
        '2. Run MVC Portal: Port 44305\n' +
        '3. Click "Launch Platform"\n' +
        '4. Choose application to open\n' +
        '\nDemo Credentials:\n' +
        '• Admin: admin / admin123\n' +
        '• Citizen: citizen / citizen123');
}

// Navbar scroll effect
window.addEventListener('scroll', function () {
    const navbar = document.querySelector('.navbar');
    if (window.scrollY > 100) {
        navbar.style.background = 'rgba(10, 25, 47, 0.98)';
    } else {
        navbar.style.background = 'rgba(10, 25, 47, 0.95)';
    }
});