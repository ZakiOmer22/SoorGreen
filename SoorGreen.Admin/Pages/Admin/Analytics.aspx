<%@ Page Title="Analytics" Language="C#" MasterPageFile="~/Pages/Admin/Site.master" AutoEventWireup="true" CodeFile="Analytics.aspx.cs" Inherits="SoorGreen.Admin.Admin.Analytics" %>
<asp:Content ID="Content3" ContentPlaceHolderID="HeadContent" runat="server">
    <link href='<%= ResolveUrl("~/Content/Pages/Citizen/analytics.css") %>' rel="stylesheet" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
</asp:Content>

<asp:Content ID="Content4" ContentPlaceHolderID="ScriptsContent" runat="server">
    <script src='<%= ResolveUrl("~/Scripts/Pages/Citizen/analytics.js") %>'></script>
</asp:Content>
<asp:Content ID="PageTitle" ContentPlaceHolderID="PageTitle" runat="server">
    Analytics Dashboard
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

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
    <script src="/Scripts/Pages/Analytics.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>


</asp:Content>
