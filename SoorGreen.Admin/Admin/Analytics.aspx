<%@ Page Title="Analytics" Language="C#" MasterPageFile="~/Admin/Site.master" AutoEventWireup="true" CodeFile="Analytics.aspx.cs" Inherits="SoorGreen.Admin.Admin.Analytics" %>

<asp:Content ID="PageTitle" ContentPlaceHolderID="PageTitle" runat="server">
    Analytics Dashboard
</asp:Content>

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
            height: 100%;
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

        .trend-down {
            background: rgba(220, 53, 69, 0.15);
            color: #dc3545;
            border: 1px solid rgba(220, 53, 69, 0.3);
        }

        /* Analytics Grid */
        .analytics-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 1.5rem;
            margin-bottom: 2rem;
        }

        .analytics-card {
            background: rgba(255, 255, 255, 0.05);
            backdrop-filter: blur(20px);
            border: 1px solid rgba(255, 255, 255, 0.1);
            border-radius: 20px;
            padding: 1.5rem;
            position: relative;
            overflow: hidden;
        }

        .analytics-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 1px;
            background: linear-gradient(90deg, transparent, var(--primary), transparent);
        }

        .metric-value {
            font-size: 2rem;
            font-weight: 800;
            color: var(--light);
            margin-bottom: 0.5rem;
        }

        .metric-label {
            color: rgba(255, 255, 255, 0.7);
            font-size: 0.9rem;
            margin-bottom: 1rem;
        }

        .metric-change {
            font-size: 0.8rem;
            font-weight: 600;
        }

        /* Refresh button */
        .btn-refresh {
            background: rgba(255, 255, 255, 0.1);
            border: 1px solid rgba(255, 255, 255, 0.2);
            color: white;
            padding: 0.5rem 1rem;
            border-radius: 8px;
            cursor: pointer;
            transition: all 0.3s ease;
        }

        .btn-refresh:hover {
            background: rgba(255, 255, 255, 0.2);
        }

        /* Demo mode banner styles */
        #demoModeBanner {
            background: linear-gradient(135deg, #ff6b35, #f7931e);
            color: white;
            padding: 12px 20px;
            text-align: center;
            font-weight: 600;
            position: relative;
            border-bottom: 2px solid rgba(255,255,255,0.2);
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            margin-bottom: 1rem;
            border-radius: 8px;
        }

        @keyframes pulse {
            0% { box-shadow: 0 0 0 0 rgba(255, 107, 53, 0.4); }
            70% { box-shadow: 0 0 0 10px rgba(255, 107, 53, 0); }
            100% { box-shadow: 0 0 0 0 rgba(255, 107, 53, 0); }
        }

        .demo-pulse {
            animation: pulse 2s infinite;
        }
    </style>

    <!-- Demo Mode Banner (will be shown via JavaScript) -->
    <div id="demoModeBanner" style="display: none;">
        <div style="display: flex; align-items: center; justify-content: center; gap: 10px;">
            <i class="fas fa-info-circle"></i>
            <span>Demo Mode: Showing simulated data - Database connection unavailable</span>
            <button onclick="closeDemoBanner()" style="background: none; border: none; color: white; margin-left: 15px; cursor: pointer;">
                <i class="fas fa-times"></i>
            </button>
        </div>
    </div>

    <!-- Header with Refresh -->
    <div class="d-flex justify-content-between align-items-center mb-4">
       
        <button class="btn-refresh" onclick="refreshData()">
            <i class="fas fa-sync-alt me-2"></i>Refresh Data
        </button>
    </div>

    <!-- Quick Stats Row -->
    <div class="row quick-stats-row">
        <div class="col-xl-3 col-md-6 mb-4">
            <div class="stat-card">
                <div class="stat-icon users">
                    <i class="fas fa-users"></i>
                </div>
                <div class="stat-number" id="totalUsers" runat="server">0</div>
                <div class="stat-label">Total Users</div>
                <div class="stat-trend trend-up">
                    <i class="fas fa-arrow-up me-1"></i>12.5%
                </div>
            </div>
        </div>
        
        <div class="col-xl-3 col-md-6 mb-4">
            <div class="stat-card">
                <div class="stat-icon pickups">
                    <i class="fas fa-truck-loading"></i>
                </div>
                <div class="stat-number" id="todayPickups" runat="server">0</div>
                <div class="stat-label">Pickups Today</div>
                <div class="stat-trend trend-up">
                    <i class="fas fa-arrow-up me-1"></i>8.3%
                </div>
            </div>
        </div>
        
        <div class="col-xl-3 col-md-6 mb-4">
            <div class="stat-card">
                <div class="stat-icon rewards">
                    <i class="fas fa-coins"></i>
                </div>
                <div class="stat-number" id="totalCredits" runat="server">0</div>
                <div class="stat-label">Credits Distributed</div>
                <div class="stat-trend trend-up">
                    <i class="fas fa-arrow-up me-1"></i>15.2%
                </div>
            </div>
        </div>
        
        <div class="col-xl-3 col-md-6 mb-4">
            <div class="stat-card">
                <div class="stat-icon reports">
                    <i class="fas fa-chart-line"></i>
                </div>
                <div class="stat-number" id="wasteReports" runat="server">0</div>
                <div class="stat-label">Waste Reports (30 days)</div>
                <div class="stat-trend trend-up">
                    <i class="fas fa-arrow-up me-1"></i>22.7%
                </div>
            </div>
        </div>
    </div>

    <!-- Analytics Metrics Row -->
    <div class="row mb-4">
        <div class="col-12">
            <div class="analytics-grid">
                <div class="analytics-card">
                    <div class="metric-value" id="satisfactionRate">94%</div>
                    <div class="metric-label">User Satisfaction Rate</div>
                    <div class="metric-change trend-up">
                        <i class="fas fa-arrow-up me-1"></i>2.1% from last month
                    </div>
                </div>
                
                <div class="analytics-card">
                    <div class="metric-value" id="responseTime">2.3s</div>
                    <div class="metric-label">Avg. Response Time</div>
                    <div class="metric-change trend-down">
                        <i class="fas fa-arrow-down me-1"></i>0.4s improvement
                    </div>
                </div>
                
                <div class="analytics-card">
                    <div class="metric-value" id="completionRate">98%</div>
                    <div class="metric-label">Pickup Completion Rate</div>
                    <div class="metric-change trend-up">
                        <i class="fas fa-arrow-up me-1"></i>1.2% from last week
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Charts Row -->
    <div class="row chart-row">
        <div class="col-xl-8 mb-4">
            <div class="chart-container">
                <h5 class="mb-3"><i class="fas fa-chart-line me-2"></i>Pickup Requests Overview</h5>
                <canvas id="pickupChart" height="250"></canvas>
            </div>
        </div>
        
        <div class="col-xl-4 mb-4">
            <div class="chart-container">
                <h5 class="mb-3"><i class="fas fa-trash-alt me-2"></i>Waste Distribution</h5>
                <canvas id="wasteChart" height="250"></canvas>
            </div>
        </div>
    </div>

    <!-- Additional Charts Row -->
    <div class="row chart-row">
        <div class="col-xl-6 mb-4">
            <div class="chart-container">
                <h5 class="mb-3"><i class="fas fa-user-friends me-2"></i>User Growth</h5>
                <canvas id="userGrowthChart" height="250"></canvas>
            </div>
        </div>
        
        <div class="col-xl-6 mb-4">
            <div class="chart-container">
                <h5 class="mb-3"><i class="fas fa-coins me-2"></i>Rewards Distribution</h5>
                <canvas id="rewardsChart" height="250"></canvas>
            </div>
        </div>
    </div>

    <!-- Second Row -->
    <div class="row">
        <div class="col-xl-6 mb-4">
            <div class="chart-container">
                <h5 class="mb-3"><i class="fas fa-history me-2"></i>Recent Activity</h5>
                <div class="recent-activity" id="recentActivity">
                    <div class="activity-item">
                        <div class="activity-icon info">
                            <i class="fas fa-sync-alt"></i>
                        </div>
                        <div>
                            <div class="fw-bold">Loading analytics data</div>
                            <small class="text-muted">Please wait while we load your dashboard</small>
                            <div class="text-muted small">just now</div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        
        <div class="col-xl-6 mb-4">
            <div class="system-health">
                <h5 class="mb-4 text-white"><i class="fas fa-heartbeat me-2"></i>System Health</h5>
                <div class="row text-center">
                    <div class="col-4">
                        <div class="health-stat">
                            <div class="health-value" id="uptime">99.9%</div>
                            <div>Uptime</div>
                        </div>
                    </div>
                    <div class="col-4">
                        <div class="health-stat">
                            <div class="health-value" id="avgResponse">0.8s</div>
                            <div>Avg Response</div>
                        </div>
                    </div>
                    <div class="col-4">
                        <div class="health-stat">
                            <div class="health-value" id="errorRate">0.02%</div>
                            <div>Error Rate</div>
                        </div>
                    </div>
                </div>
                
                <div class="mt-4">
                    <h6 class="mb-3">Active Services</h6>
                    <div class="d-flex justify-content-between mb-2">
                        <span>User Management</span>
                        <span class="badge bg-success" id="serviceUser">Online</span>
                    </div>
                    <div class="d-flex justify-content-between mb-2">
                        <span>Payment Processing</span>
                        <span class="badge bg-success" id="servicePayment">Online</span>
                    </div>
                    <div class="d-flex justify-content-between mb-2">
                        <span>Notification System</span>
                        <span class="badge bg-success" id="serviceNotification">Online</span>
                    </div>
                    <div class="d-flex justify-content-between mb-2">
                        <span>Analytics Engine</span>
                        <span class="badge bg-success" id="serviceAnalytics">Online</span>
                    </div>
                    <div class="d-flex justify-content-between">
                        <span>API Gateway</span>
                        <span class="badge bg-success" id="serviceAPI">Online</span>
                    </div>
                </div>

                <div class="mt-4">
                    <h6 class="mb-3">Performance Metrics</h6>
                    <div class="progress mb-2" style="height: 8px;">
                        <div class="progress-bar bg-success" style="width: 45%" id="cpuProgress"></div>
                    </div>
                    <small>CPU Usage: <span id="cpuUsage">45%</span></small>
                    
                    <div class="progress mb-2" style="height: 8px;">
                        <div class="progress-bar bg-info" style="width: 68%" id="memoryProgress"></div>
                    </div>
                    <small>Memory: <span id="memoryUsage">68%</span></small>
                    
                    <div class="progress mb-2" style="height: 8px;">
                        <div class="progress-bar bg-warning" style="width: 82%" id="storageProgress"></div>
                    </div>
                    <small>Storage: <span id="storageUsage">82%</span></small>
                </div>
            </div>
        </div>
    </div>

    <!-- Hidden button to trigger server-side refresh -->
    <asp:Button ID="btnRefresh" runat="server" OnClick="RefreshData" Style="display: none;" />
</asp:Content>

<asp:Content ID="Scripts" ContentPlaceHolderID="Scripts" runat="server">
    <!-- Add Chart.js Library -->
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    
    <script>
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
                satisfactionRate: { min: 92, max: 96 },
                responseTime: { min: 2.1, max: 2.8 },
                completionRate: { min: 96, max: 99 },
                uptime: { min: 99.8, max: 99.99 },
                avgResponse: { min: 0.7, max: 1.2 },
                errorRate: { min: 0.01, max: 0.05 },
                cpuUsage: { min: 40, max: 70 },
                memoryUsage: { min: 60, max: 85 },
                storageUsage: { min: 75, max: 90 }
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
                { type: 'success', title: 'New user registration', description: 'John Doe joined the platform', time: '2 minutes ago' },
                { type: 'info', title: 'Pickup completed', description: 'Pickup #12345 has been completed', time: '5 minutes ago' },
                { type: 'warning', title: 'System maintenance', description: 'Scheduled maintenance in 2 hours', time: '15 minutes ago' },
                { type: 'success', title: 'Reward distributed', description: '500 credits awarded to user', time: '30 minutes ago' },
                { type: 'info', title: 'New waste report', description: 'Report submitted for plastic waste', time: '1 hour ago' }
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
    </script>
</asp:Content>