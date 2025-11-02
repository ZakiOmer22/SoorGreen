<%@ Page Title="Dashboard" Language="C#" MasterPageFile="~/Admin/Site.master" AutoEventWireup="true" CodeFile="Dashboard.aspx.cs" Inherits="SoorGreen_Admin_Dashboard" %>


<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <style>
        .quick-stats-row {
            margin-bottom: 2rem;
        }
        
        .chart-row {
            margin-bottom: 2rem;
        }
        
        .recent-activity {
            max-height: 400px;
            overflow-y: auto;
        }
        
        .system-health {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border-radius: 12px;
            padding: 1.5rem;
        }
        
        .health-stat {
            text-align: center;
            padding: 1rem;
        }
        
        .health-value {
            font-size: 2.5rem;
            font-weight: 700;
            margin-bottom: 0.5rem;
        }

        /* Chart container styles */
        .chart-container {
            background: rgba(255, 255, 255, 0.05);
            backdrop-filter: blur(20px);
            border: 1px solid rgba(255, 255, 255, 0.1);
            border-radius: 20px;
            padding: 2rem;
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.2);
            position: relative;
            overflow: hidden;
        }

        .chart-container::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 1px;
            background: linear-gradient(90deg, transparent, var(--primary), transparent);
        }

        /* Activity item styles */
        .activity-item {
            display: flex;
            align-items: center;
            gap: 1rem;
            padding: 1rem;
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
        }

        .activity-item:last-child {
            border-bottom: none;
        }

        .activity-icon {
            width: 40px;
            height: 40px;
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
        }

        .activity-icon.success {
            background: linear-gradient(135deg, #198754, #20c997);
        }

        .activity-icon.info {
            background: linear-gradient(135deg, #0dcaf0, #0d6efd);
        }

        .activity-icon.warning {
            background: linear-gradient(135deg, #ffc107, #fd7e14);
        }

        /* Stat card styles */
        .stat-card {
            background: rgba(255, 255, 255, 0.05);
            backdrop-filter: blur(20px);
            border: 1px solid rgba(255, 255, 255, 0.1);
            border-radius: 20px;
            padding: 2rem;
            position: relative;
            overflow: hidden;
            transition: all 0.3s ease;
        }

        .stat-card:hover {
            transform: translateY(-5px);
            border-color: rgba(0, 212, 170, 0.3);
        }

        .stat-icon {
            width: 60px;
            height: 60px;
            border-radius: 16px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.5rem;
            margin-bottom: 1rem;
        }

        .stat-icon.users {
            background: rgba(25, 135, 84, 0.1);
            color: #198754;
        }

        .stat-icon.pickups {
            background: rgba(13, 202, 240, 0.1);
            color: #0dcaf0;
        }

        .stat-icon.rewards {
            background: rgba(255, 193, 7, 0.1);
            color: #ffc107;
        }

        .stat-icon.reports {
            background: rgba(220, 53, 69, 0.1);
            color: #dc3545;
        }

        .stat-number {
            font-size: 2.5rem;
            font-weight: 900;
            color: var(--light);
            margin-bottom: 0.5rem;
            background: linear-gradient(135deg, var(--light), var(--primary));
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }

        .stat-label {
            color: rgba(255, 255, 255, 0.8);
            font-weight: 600;
            font-size: 0.9rem;
            margin-bottom: 0.5rem;
        }

        .stat-trend {
            font-size: 0.8rem;
            font-weight: 600;
            padding: 0.4rem 0.8rem;
            border-radius: 20px;
            display: inline-block;
        }

        .trend-up {
            background: rgba(25, 135, 84, 0.15);
            color: #198754;
            border: 1px solid rgba(25, 135, 84, 0.3);
        }
    </style>

    <!-- Quick Stats Row -->
    <div class="row quick-stats-row">
        <div class="col-xl-3 col-md-6 mb-4">
            <div class="stat-card">
                <div class="stat-icon users">
                    <i class="fas fa-users"></i>
                </div>
                <div class="stat-number" id="totalUsers" runat="server">2,847</div>
                <div class="stat-label">Total Users</div>
                <div class="stat-trend trend-up">
                    <i class="fas fa-arrow-up me-1"></i>12.5% increase
                </div>
            </div>
        </div>
        
        <div class="col-xl-3 col-md-6 mb-4">
            <div class="stat-card">
                <div class="stat-icon pickups">
                    <i class="fas fa-truck-loading"></i>
                </div>
                <div class="stat-number" id="todayPickups" runat="server">1,234</div>
                <div class="stat-label">Pickups Today</div>
                <div class="stat-trend trend-up">
                    <i class="fas fa-arrow-up me-1"></i>8.3% increase
                </div>
            </div>
        </div>
        
        <div class="col-xl-3 col-md-6 mb-4">
            <div class="stat-card">
                <div class="stat-icon rewards">
                    <i class="fas fa-coins"></i>
                </div>
                <div class="stat-number" id="totalCredits" runat="server">45.2K</div>
                <div class="stat-label">Credits Distributed</div>
                <div class="stat-trend trend-up">
                    <i class="fas fa-arrow-up me-1"></i>15.7% increase
                </div>
            </div>
        </div>
        
        <div class="col-xl-3 col-md-6 mb-4">
            <div class="stat-card">
                <div class="stat-icon reports">
                    <i class="fas fa-chart-line"></i>
                </div>
                <div class="stat-number" id="wasteReports" runat="server">5,678</div>
                <div class="stat-label">Waste Reports</div>
                <div class="stat-trend trend-up">
                    <i class="fas fa-arrow-up me-1"></i>22.1% increase
                </div>
            </div>
        </div>
    </div>

    <!-- Charts Row -->
    <div class="row chart-row">
        <div class="col-xl-8 mb-4">
            <div class="chart-container">
                <h5 class="mb-3">Pickup Requests Overview</h5>
                <canvas id="pickupChart" height="250"></canvas>
            </div>
        </div>
        
        <div class="col-xl-4 mb-4">
            <div class="chart-container">
                <h5 class="mb-3">Waste Distribution</h5>
                <canvas id="wasteChart" height="250"></canvas>
            </div>
        </div>
    </div>

    <!-- Second Row -->
    <div class="row">
        <div class="col-xl-6 mb-4">
            <div class="chart-container">
                <h5 class="mb-3">Recent Activity</h5>
                <div class="recent-activity">
                    <div class="activity-item">
                        <div class="activity-icon success">
                            <i class="fas fa-check"></i>
                        </div>
                        <div>
                            <div class="fw-bold">New user registration</div>
                            <small class="text-muted">Sarah Johnson joined the platform</small>
                            <div class="text-muted small">2 minutes ago</div>
                        </div>
                    </div>
                    
                    <div class="activity-item">
                        <div class="activity-icon info">
                            <i class="fas fa-truck"></i>
                        </div>
                        <div>
                            <div class="fw-bold">Pickup completed</div>
                            <small class="text-muted">Plastic collection in Green Valley</small>
                            <div class="text-muted small">15 minutes ago</div>
                        </div>
                    </div>
                    
                    <div class="activity-item">
                        <div class="activity-icon warning">
                            <i class="fas fa-exclamation-triangle"></i>
                        </div>
                        <div>
                            <div class="fw-bold">System alert</div>
                            <small class="text-muted">High volume in Downtown area</small>
                            <div class="text-muted small">1 hour ago</div>
                        </div>
                    </div>
                    
                    <div class="activity-item">
                        <div class="activity-icon success">
                            <i class="fas fa-award"></i>
                        </div>
                        <div>
                            <div class="fw-bold">Rewards distributed</div>
                            <small class="text-muted">500 credits to active users</small>
                            <div class="text-muted small">2 hours ago</div>
                        </div>
                    </div>
                    
                    <div class="activity-item">
                        <div class="activity-icon info">
                            <i class="fas fa-user-plus"></i>
                        </div>
                        <div>
                            <div class="fw-bold">New collector verified</div>
                            <small class="text-muted">Mike Chen joined as collector</small>
                            <div class="text-muted small">3 hours ago</div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        
        <div class="col-xl-6 mb-4">
            <div class="system-health">
                <h5 class="mb-4 text-white">System Health</h5>
                <div class="row text-center">
                    <div class="col-4">
                        <div class="health-stat">
                            <div class="health-value">99.8%</div>
                            <div>Uptime</div>
                        </div>
                    </div>
                    <div class="col-4">
                        <div class="health-stat">
                            <div class="health-value">2.3s</div>
                            <div>Avg Response</div>
                        </div>
                    </div>
                    <div class="col-4">
                        <div class="health-stat">
                            <div class="health-value">0.2%</div>
                            <div>Error Rate</div>
                        </div>
                    </div>
                </div>
                
                <div class="mt-4">
                    <h6 class="mb-3">Active Services</h6>
                    <div class="d-flex justify-content-between mb-2">
                        <span>User Management</span>
                        <span class="badge bg-success">Online</span>
                    </div>
                    <div class="d-flex justify-content-between mb-2">
                        <span>Payment Processing</span>
                        <span class="badge bg-success">Online</span>
                    </div>
                    <div class="d-flex justify-content-between mb-2">
                        <span>Notification System</span>
                        <span class="badge bg-success">Online</span>
                    </div>
                    <div class="d-flex justify-content-between">
                        <span>Analytics Engine</span>
                        <span class="badge bg-warning">Maintenance</span>
                    </div>
                </div>
            </div>
        </div>
    </div>
</asp:Content>

<asp:Content ID="Scripts" ContentPlaceHolderID="Scripts" runat="server">
    <!-- Add Chart.js Library -->
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    
    <script>
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
    </script>
</asp:Content>