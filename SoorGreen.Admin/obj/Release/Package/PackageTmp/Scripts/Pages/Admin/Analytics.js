
        // Demo mode notification function
    function showDemoModeNotification() {
            const banner = document.getElementById('demoModeBanner');
    if (banner) {
        banner.style.display = 'block';

    // Add pulse animation to stat cards
    const statCards = document.querySelectorAll('.stat-card');
                statCards.forEach(card => {
        card.classList.add('demo-pulse');
                });
            }
        }

    function closeDemoBanner() {
            const banner = document.getElementById('demoModeBanner');
    if (banner) {
        banner.style.display = 'none';

    // Remove pulse animation
    const statCards = document.querySelectorAll('.stat-card');
                statCards.forEach(card => {
        card.classList.remove('demo-pulse');
                });
            }
        }

    // Initialize everything when page loads
    document.addEventListener('DOMContentLoaded', function () {
        initializeCharts();
    simulateRealTimeData();
    loadActivityFeed();
        });

    function refreshData() {
        // Show loading state
        showLoadingState();

    // Trigger server-side refresh
    document.getElementById('<%= btnRefresh.ClientID %>').click();

            // Simulate data refresh
            setTimeout(() => {
        simulateRealTimeData();
    loadActivityFeed();
    showSuccess('Dashboard refreshed successfully!');
            }, 1000);
        }

    function showLoadingState() {
            const stats = document.querySelectorAll('.stat-number, .metric-value, .health-value');
            stats.forEach(stat => {
                if (!stat.innerHTML.includes('fa-spin')) {
                    const originalContent = stat.innerHTML;
    stat.setAttribute('data-original', originalContent);
    stat.innerHTML = '<i class="fas fa-spinner fa-spin"></i>';
                }
            });
        }

    function restoreLoadingState() {
            const stats = document.querySelectorAll('.stat-number, .metric-value, .health-value');
            stats.forEach(stat => {
                const originalContent = stat.getAttribute('data-original');
    if (originalContent) {
        stat.innerHTML = originalContent;
                }
            });
        }

    function initializeCharts() {
            // Pickup Chart
            const pickupCtx = document.getElementById('pickupChart').getContext('2d');
    const pickupChart = new Chart(pickupCtx, {
        type: 'line',
    data: {
        labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'],
    datasets: [{
        label: 'Pickup Requests',
    data: [120, 150, 180, 200, 240, 280, 320, 300, 280, 320, 350, 400],
    borderColor: '#0dcaf0',
    backgroundColor: 'rgba(13, 202, 240, 0.1)',
    borderWidth: 2,
    fill: true,
    tension: 0.4
                    }]
                },
    options: {
        responsive: true,
    plugins: {
        legend: {
        display: false
                        }
                    },
    scales: {
        y: {
        beginAtZero: true,
    grid: {
        color: 'rgba(255, 255, 255, 0.1)'
                            },
    ticks: {
        color: 'rgba(255, 255, 255, 0.7)'
                            }
                        },
    x: {
        grid: {
        color: 'rgba(255, 255, 255, 0.1)'
                            },
    ticks: {
        color: 'rgba(255, 255, 255, 0.7)'
                            }
                        }
                    }
                }
            });

    // Waste Distribution Chart
    const wasteCtx = document.getElementById('wasteChart').getContext('2d');
    const wasteChart = new Chart(wasteCtx, {
        type: 'doughnut',
    data: {
        labels: ['Plastic', 'Paper', 'Glass', 'Metal', 'Organic', 'E-Waste'],
    datasets: [{
        data: [35, 25, 15, 12, 8, 5],
    backgroundColor: [
    '#198754',
    '#0dcaf0',
    '#ffc107',
    '#dc3545',
    '#6f42c1',
    '#fd7e14'
    ],
    borderWidth: 0
                    }]
                },
    options: {
        responsive: true,
    plugins: {
        legend: {
        position: 'bottom',
    labels: {
        color: 'rgba(255, 255, 255, 0.7)',
    padding: 20
                            }
                        }
                    }
                }
            });

    // User Growth Chart
    const userGrowthCtx = document.getElementById('userGrowthChart').getContext('2d');
    const userGrowthChart = new Chart(userGrowthCtx, {
        type: 'bar',
    data: {
        labels: ['Q1', 'Q2', 'Q3', 'Q4'],
    datasets: [{
        label: 'New Users',
    data: [450, 620, 780, 950],
    backgroundColor: 'rgba(25, 135, 84, 0.6)',
    borderColor: '#198754',
    borderWidth: 1
                    }]
                },
    options: {
        responsive: true,
    plugins: {
        legend: {
        display: false
                        }
                    },
    scales: {
        y: {
        beginAtZero: true,
    grid: {
        color: 'rgba(255, 255, 255, 0.1)'
                            },
    ticks: {
        color: 'rgba(255, 255, 255, 0.7)'
                            }
                        },
    x: {
        grid: {
        color: 'rgba(255, 255, 255, 0.1)'
                            },
    ticks: {
        color: 'rgba(255, 255, 255, 0.7)'
                            }
                        }
                    }
                }
            });

    // Rewards Chart
    const rewardsCtx = document.getElementById('rewardsChart').getContext('2d');
    const rewardsChart = new Chart(rewardsCtx, {
        type: 'pie',
    data: {
        labels: ['Plastic Recycling', 'Paper Recycling', 'Glass Recycling', 'Community Cleanup', 'Referral Bonus'],
    datasets: [{
        data: [40, 25, 15, 12, 8],
    backgroundColor: [
    '#198754',
    '#0dcaf0',
    '#ffc107',
    '#dc3545',
    '#6f42c1'
    ],
    borderWidth: 0
                    }]
                },
    options: {
        responsive: true,
    plugins: {
        legend: {
        position: 'bottom',
    labels: {
        color: 'rgba(255, 255, 255, 0.7)',
    padding: 20
                            }
                        }
                    }
                }
            });
        }

    function simulateRealTimeData() {
            // Update system metrics with random values
            const metrics = {
        satisfactionRate: {min: 92, max: 96 },
    responseTime: {min: 2.1, max: 2.8 },
    completionRate: {min: 96, max: 99 },
    uptime: {min: 99.8, max: 99.99 },
    avgResponse: {min: 0.7, max: 1.2 },
    errorRate: {min: 0.01, max: 0.05 },
    cpuUsage: {min: 40, max: 70 },
    memoryUsage: {min: 60, max: 85 },
    storageUsage: {min: 75, max: 90 }
            };

            Object.keys(metrics).forEach(id => {
                const element = document.getElementById(id);
    if (element) {
                    const range = metrics[id];
    const value = (Math.random() * (range.max - range.min) + range.min).toFixed(id.includes('Rate') || id.includes('uptime') ? 1 : 1);
    element.textContent = id.includes('Rate') || id.includes('uptime') || id.includes('errorRate') ? value + '%' :
    id.includes('Time') || id.includes('Response') ? value + 's' : value;

    // Update progress bars
    if (id.includes('Usage')) {
                        const progressBar = document.getElementById(id + 'Progress');
    if (progressBar) {
        progressBar.style.width = value + '%';
                        }
                    }
                }
            });
        }

    function loadActivityFeed() {
            const activities = [
    {type: 'success', title: 'New user registration', description: 'John Doe joined the platform', time: '2 minutes ago' },
    {type: 'info', title: 'Pickup completed', description: 'Pickup #12345 has been completed', time: '5 minutes ago' },
    {type: 'warning', title: 'System maintenance', description: 'Scheduled maintenance in 2 hours', time: '15 minutes ago' },
    {type: 'success', title: 'Reward distributed', description: '500 credits awarded to user', time: '30 minutes ago' },
    {type: 'info', title: 'New waste report', description: 'Report submitted for plastic waste', time: '1 hour ago' }
    ];

    const activityContainer = document.getElementById('recentActivity');
    if (activityContainer) {
        activityContainer.innerHTML = '';

                activities.forEach(activity => {
                    const activityItem = document.createElement('div');
    activityItem.className = 'activity-item';
    activityItem.innerHTML = `
    <div class="activity-icon ${activity.type}">
        <i class="fas fa-${getActivityIcon(activity.type)}"></i>
    </div>
    <div>
        <div class="fw-bold">${activity.title}</div>
        <small class="text-muted">${activity.description}</small>
        <div class="text-muted small">${activity.time}</div>
    </div>
    `;
    activityContainer.appendChild(activityItem);
                });
            }
        }

    function getActivityIcon(type) {
            switch (type) {
                case 'success': return 'check-circle';
    case 'info': return 'info-circle';
    case 'warning': return 'exclamation-triangle';
    default: return 'info-circle';
            }
        }

    // Success/Error notification functions
    function showSuccess(message) {
        // Simple success notification
        console.log('Success:', message);
        }

    function showError(message) {
        // Simple error notification
        console.error('Error:', message);
        }