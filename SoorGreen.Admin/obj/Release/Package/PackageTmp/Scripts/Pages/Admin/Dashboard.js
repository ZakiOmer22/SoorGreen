

    document.addEventListener('DOMContentLoaded', function () {
        // Wait a bit to ensure DOM is fully loaded
        setTimeout(initializeCharts, 100);
        });

    function initializeCharts() {
            // Pickup Requests Chart
            const pickupCtx = document.getElementById('pickupChart');
    if (pickupCtx) {
                const pickupChart = new Chart(pickupCtx, {
        type: 'line',
    data: {
        labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul'],
    datasets: [{
        label: 'Pickup Requests',
    data: [1200, 1900, 1500, 2200, 1800, 2500, 2800],
    borderColor: '#198754',
    backgroundColor: 'rgba(25, 135, 84, 0.1)',
    borderWidth: 2,
    fill: true,
    tension: 0.4
                        }, {
        label: 'Completed Pickups',
    data: [800, 1200, 1000, 1500, 1300, 1800, 2100],
    borderColor: '#0dcaf0',
    backgroundColor: 'rgba(13, 202, 240, 0.1)',
    borderWidth: 2,
    fill: true,
    tension: 0.4
                        }]
                    },
    options: {
        responsive: true,
    maintainAspectRatio: false,
    plugins: {
        legend: {
        position: 'top',
    labels: {
        color: 'rgba(255, 255, 255, 0.8)'
                                }
                            }
                        },
    scales: {
        y: {
        beginAtZero: true,
    grid: {
        color: 'rgba(255, 255, 255, 0.1)',
    drawBorder: false
                                },
    ticks: {
        color: 'rgba(255, 255, 255, 0.7)'
                                }
                            },
    x: {
        grid: {
        display: false
                                },
    ticks: {
        color: 'rgba(255, 255, 255, 0.7)'
                                }
                            }
                        }
                    }
                });
            }

    // Waste Distribution Chart
    const wasteCtx = document.getElementById('wasteChart');
    if (wasteCtx) {
                const wasteChart = new Chart(wasteCtx, {
        type: 'doughnut',
    data: {
        labels: ['Plastic', 'Paper', 'Glass', 'E-Waste', 'Metal', 'Organic'],
    datasets: [{
        data: [35, 25, 15, 10, 8, 7],
    backgroundColor: [
    '#198754',
    '#0dcaf0',
    '#ffc107',
    '#dc3545',
    '#6f42c1',
    '#fd7e14'
    ],
    borderWidth: 2,
    borderColor: '#0a192f'
                        }]
                    },
    options: {
        responsive: true,
    maintainAspectRatio: false,
    plugins: {
        legend: {
        position: 'bottom',
    labels: {
        color: 'rgba(255, 255, 255, 0.8)',
    padding: 20
                                }
                            }
                        },
    cutout: '65%'
                    }
                });
            }

    // Auto-update stats every 30 seconds
    setInterval(updateStats, 30000);

    function updateStats() {
                // Simulate real-time data updates
                const stats = document.querySelectorAll('.stat-number');
                stats.forEach(stat => {
                    const current = parseInt(stat.textContent.replace(/[^0-9]/g, ''));
    const change = Math.floor(Math.random() * 50) - 10;
    const newValue = Math.max(0, current + change);
    stat.textContent = newValue.toLocaleString();
                });
            }
        }
