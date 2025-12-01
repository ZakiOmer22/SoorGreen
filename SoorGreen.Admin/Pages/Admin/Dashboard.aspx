<%@ Page Title="Dashboard" Language="C#" MasterPageFile="~/Pages/Admin/Site.master" AutoEventWireup="true" CodeFile="Dashboard.aspx.cs" Inherits="SoorGreen_Admin_Dashboard" %>
<%@ Import Namespace="System.Web.Optimization" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <%: Styles.Render("~/Content/admindashboard") %>
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="ScriptsContent" runat="server">
    <%: Scripts.Render("~/bundles/admindashboard") %>
</asp:Content>
<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    

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
    
   
</asp:Content>