<%@ Page Title="Dashboard" Language="C#" MasterPageFile="~/Pages/Citizen/Site.Master" AutoEventWireup="true" CodeFile="Dashboard.aspx.cs" Inherits="SoorGreen.Admin.Dashboard" %>
<%@ Import Namespace="System.Web.Optimization" %>
<asp:Content ID="Content3" ContentPlaceHolderID="HeadContent" runat="server">
    <%: Styles.Render("~/Content/citizendashboard") %>
</asp:Content>
<asp:Content ID="Content4" ContentPlaceHolderID="ScriptsContent" runat="server">
    <%: Scripts.Render("~/bundles/citizendashboard") %>
</asp:Content>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Citizen Dashboard - SoorGreen Citizen
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    

    <!-- Welcome Section -->
    <br />
    <br />
    <br />
    <div class="dashboard-container">
        <div class="welcome-section">
            <div class="row align-items-center">
                <div class="col-md-8">
                    <h1 class="welcome-title">Welcome back, <asp:Literal ID="litUserName" runat="server" />! 👋</h1>
                    <p class="welcome-subtitle">Here's your recycling impact summary for today</p>
                </div>
                <div class="col-md-4 text-end">
                    <div class="badge bg-white text-dark px-3 py-2 rounded-pill">
                        <i class="fas fa-leaf me-2"></i>
                        <asp:Literal ID="litUserLevel" runat="server" Text="Eco Warrior" />
                    </div>
                </div>
            </div>
        </div>

        <div class="row g-4">
            <!-- Main Stats Section -->
            <div class="col-xl-8">
                <!-- Enhanced Stats Cards -->
                <div class="row g-4">
                    <!-- Total Recycled -->
                    <div class="col-md-3">
                        <div class="stat-card">
                            <div class="stat-icon primary">
                                <i class="fas fa-weight-hanging"></i>
                            </div>
                            <div class="stat-number"><asp:Literal ID="litTotalRecycled" runat="server" Text="0" /> kg</div>
                            <div class="stat-label">Total Recycled</div>
                            <div class="text-success small mt-2">
                                <i class="fas fa-arrow-up me-1"></i>
                                <asp:Literal ID="litRecyclingTrend" runat="server" Text="0" />% this month
                            </div>
                        </div>
                    </div>

                    <!-- XP Points -->
                    <div class="col-md-3">
                        <div class="stat-card">
                            <div class="stat-icon success">
                                <i class="fas fa-star"></i>
                            </div>
                            <div class="stat-number"><asp:Literal ID="litXPPoints" runat="server" Text="0" /></div>
                            <div class="stat-label">XP Points</div>
                            <div class="text-warning small mt-2">
                                <i class="fas fa-trophy me-1"></i>
                                <asp:Literal ID="litNextLevel" runat="server" Text="0" /> to next level
                            </div>
                        </div>
                    </div>

                    <!-- Pickups Completed -->
                    <div class="col-md-3">
                        <div class="stat-card">
                            <div class="stat-icon warning">
                                <i class="fas fa-truck"></i>
                            </div>
                            <div class="stat-number"><asp:Literal ID="litPickupsCompleted" runat="server" Text="0" /></div>
                            <div class="stat-label">Pickups Completed</div>
                            <div class="text-info small mt-2">
                                <i class="fas fa-check-circle me-1"></i>
                                <asp:Literal ID="litSuccessRate" runat="server" Text="0" />% success rate
                            </div>
                        </div>
                    </div>

                    <!-- Carbon Saved -->
                    <div class="col-md-3">
                        <div class="stat-card">
                            <div class="stat-icon info">
                                <i class="fas fa-cloud"></i>
                            </div>
                            <div class="stat-number"><asp:Literal ID="litCarbonSaved" runat="server" Text="0" /> kg</div>
                            <div class="stat-label">CO₂ Saved</div>
                            <div class="text-success small mt-2">
                                <i class="fas fa-tree me-1"></i>
                                Equivalent to <asp:Literal ID="litTreesEquivalent" runat="server" Text="0" /> trees
                            </div>
                        </div>
                    </div>

                    <!-- New Additional Cards -->
                    <!-- Money Saved -->
                    <div class="col-md-3">
                        <div class="stat-card">
                            <div class="stat-icon" style="background: rgba(34, 197, 94, 0.1); color: #22c55e;">
                                <i class="fas fa-money-bill-wave"></i>
                            </div>
                            <div class="stat-number">$<asp:Literal ID="litMoneySaved" runat="server" Text="0" /></div>
                            <div class="stat-label">Money Saved</div>
                            <div class="text-success small mt-2">
                                <i class="fas fa-piggy-bank me-1"></i>
                                From recycling
                            </div>
                        </div>
                    </div>

                    <!-- Current Streak -->
                    <div class="col-md-3">
                        <div class="stat-card">
                            <div class="stat-icon" style="background: rgba(245, 158, 11, 0.1); color: #f59e0b;">
                                <i class="fas fa-fire"></i>
                            </div>
                            <div class="stat-number"><asp:Literal ID="litCurrentStreak" runat="server" Text="0" /> days</div>
                            <div class="stat-label">Current Streak</div>
                            <div class="text-warning small mt-2">
                                <i class="fas fa-calendar me-1"></i>
                                Keep it up!
                            </div>
                        </div>
                    </div>

                    <!-- Community Rank -->
                    <div class="col-md-3">
                        <div class="stat-card">
                            <div class="stat-icon" style="background: rgba(168, 85, 247, 0.1); color: #a855f7;">
                                <i class="fas fa-medal"></i>
                            </div>
                            <div class="stat-number">#<asp:Literal ID="litCommunityRank" runat="server" Text="0" /></div>
                            <div class="stat-label">Community Rank</div>
                            <div class="text-purple small mt-2">
                                <i class="fas fa-users me-1"></i>
                                Top recycler
                            </div>
                        </div>
                    </div>

                    <!-- Waste Reports -->
                    <div class="col-md-3">
                        <div class="stat-card">
                            <div class="stat-icon" style="background: rgba(239, 68, 68, 0.1); color: #ef4444;">
                                <i class="fas fa-clipboard-list"></i>
                            </div>
                            <div class="stat-number"><asp:Literal ID="litTotalReports" runat="server" Text="0" /></div>
                            <div class="stat-label">Total Reports</div>
                            <div class="text-danger small mt-2">
                                <i class="fas fa-chart-bar me-1"></i>
                                All time reports
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Quick Actions Section -->
                <div class="row g-3 mt-4 quick-actions-section">
                    <div class="col-12">
                        <h4 class="fw-bold mb-3 text-light section-title">Quick Actions</h4>
                    </div>
                    <div class="col-md-3">
                        <div class="quick-action" onclick="location.href='SchedulePickup.aspx'">
                            <div class="action-icon">
                                <i class="fas fa-calendar-plus"></i>
                            </div>
                            <h6 class="text-light">Schedule Pickup</h6>
                            <p class="text-muted small mb-0">Request waste collection</p>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="quick-action" onclick="location.href='MyRewards.aspx'">
                            <div class="action-icon">
                                <i class="fas fa-gift"></i>
                            </div>
                            <h6 class="text-light">Redeem Rewards</h6>
                            <p class="text-muted small mb-0">Use your XP points</p>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="quick-action" onclick="location.href='ReportWaste.aspx'">
                            <div class="action-icon">
                                <i class="fas fa-plus-circle"></i>
                            </div>
                            <h6 class="text-light">Report Waste</h6>
                            <p class="text-muted small mb-0">New waste report</p>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="quick-action" onclick="location.href='UserProfile.aspx'">
                            <div class="action-icon">
                                <i class="fas fa-chart-line"></i>
                            </div>
                            <h6 class="text-light">View Analytics</h6>
                            <p class="text-muted small mb-0">See your impact</p>
                        </div>
                    </div>
                    <!-- Additional Quick Actions -->
                    <div class="col-md-3">
                        <div class="quick-action" onclick="location.href='Leaderboard.aspx'">
                            <div class="action-icon">
                                <i class="fas fa-trophy"></i>
                            </div>
                            <h6 class="text-light">Leaderboard</h6>
                            <p class="text-muted small mb-0">Community ranking</p>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="quick-action" onclick="location.href='Notifications.aspx'">
                            <div class="action-icon">
                                <i class="fas fa-bell"></i>
                            </div>
                            <h6 class="text-light">Notifications</h6>
                            <p class="text-muted small mb-0">View alerts</p>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="quick-action" onclick="location.href='Feedback.aspx'">
                            <div class="action-icon">
                                <i class="fas fa-comment-dots"></i>
                            </div>
                            <h6 class="text-light">Feedback</h6>
                            <p class="text-muted small mb-0">Share suggestions</p>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="quick-action" onclick="location.href='Help.aspx'">
                            <div class="action-icon">
                                <i class="fas fa-question-circle"></i>
                            </div>
                            <h6 class="text-light">Help Center</h6>
                            <p class="text-muted small mb-0">Get support</p>
                        </div>
                    </div>
                </div>

                <!-- Waste Types Section -->
                <div class="row mt-4">
                    <div class="col-12">
                        <div class="stat-card">
                            <h4 class="fw-bold mb-4 text-light section-title">Waste Types Recycled</h4>
                            <div class="row text-center">
                                <div class="col-md-2">
                                    <div class="waste-type-card">
                                        <i class="fas fa-wine-bottle fa-2x text-primary mb-2"></i>
                                        <h6 class="fw-bold text-light mb-1">Plastic</h6>
                                        <div class="stat-number small"><asp:Literal ID="litPlasticKg" runat="server" Text="0" />kg</div>
                                    </div>
                                </div>
                                <div class="col-md-2">
                                    <div class="waste-type-card">
                                        <i class="fas fa-newspaper fa-2x text-warning mb-2"></i>
                                        <h6 class="fw-bold text-light mb-1">Paper</h6>
                                        <div class="stat-number small"><asp:Literal ID="litPaperKg" runat="server" Text="0" />kg</div>
                                    </div>
                                </div>
                                <div class="col-md-2">
                                    <div class="waste-type-card">
                                        <i class="fas fa-wine-bottle fa-2x text-success mb-2"></i>
                                        <h6 class="fw-bold text-light mb-1">Glass</h6>
                                        <div class="stat-number small"><asp:Literal ID="litGlassKg" runat="server" Text="0" />kg</div>
                                    </div>
                                </div>
                                <div class="col-md-2">
                                    <div class="waste-type-card">
                                        <i class="fas fa-cube fa-2x text-info mb-2"></i>
                                        <h6 class="fw-bold text-light mb-1">Metal</h6>
                                        <div class="stat-number small"><asp:Literal ID="litMetalKg" runat="server" Text="0" />kg</div>
                                    </div>
                                </div>
                                <div class="col-md-2">
                                    <div class="waste-type-card">
                                        <i class="fas fa-laptop fa-2x text-danger mb-2"></i>
                                        <h6 class="fw-bold text-light mb-1">E-Waste</h6>
                                        <div class="stat-number small"><asp:Literal ID="litEWasteKg" runat="server" Text="0" />kg</div>
                                    </div>
                                </div>
                                <div class="col-md-2">
                                    <div class="waste-type-card">
                                        <i class="fas fa-leaf fa-2x text-success mb-2"></i>
                                        <h6 class="fw-bold text-light mb-1">Organic</h6>
                                        <div class="stat-number small"><asp:Literal ID="litOrganicKg" runat="server" Text="0" />kg</div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Right Side Section -->
            <div class="col-xl-4 monthly-progress-section">
                <!-- Monthly Progress -->
                <div class="stat-card progress-card mb-4">
                    <h5 class="fw-bold mb-3 text-light section-title">Monthly Progress</h5>
                    <div class="text-center">
                        <div class="progress-ring">
                            <svg width="120" height="120" viewBox="0 0 120 120">
                                <circle cx="60" cy="60" r="54" fill="none" stroke="rgba(255,255,255,0.1)" stroke-width="8"/>
                                <circle cx="60" cy="60" r="54" fill="none" stroke="url(#progressGradient)" 
                                        stroke-width="8" stroke-linecap="round" 
                                        stroke-dasharray="339.292" 
                                        stroke-dashoffset="<%= GetProgressOffset() %>" class="progress-ring-circle"/>
                                <defs>
                                    <linearGradient id="progressGradient" x1="0%" y1="0%" x2="100%" y2="0%">
                                        <stop offset="0%" stop-color="#00d4aa"/>
                                        <stop offset="100%" stop-color="#0984e3"/>
                                    </linearGradient>
                                </defs>
                            </svg>
                            <div class="progress-text">
                                <div class="progress-number"><asp:Literal ID="litProgressPercent" runat="server" />%</div>
                                <div class="progress-label">Monthly Goal</div>
                            </div>
                        </div>
                        <p class="text-muted mb-0">
                            <asp:Literal ID="litProgressText" runat="server" Text="You're on track!" />
                        </p>
                        <small class="text-muted">
                            Goal: 20kg • Current: <asp:Literal ID="litCurrentMonth" runat="server" Text="0" />kg
                        </small>
                    </div>
                </div>

                <!-- Upcoming Pickups -->
                <div class="stat-card mb-4">
                    <h5 class="fw-bold mb-3 text-light section-title">Upcoming Pickups</h5>
                    <asp:Repeater ID="rptUpcomingPickups" runat="server">
                        <ItemTemplate>
                            <div class="upcoming-pickup">
                                <div class="pickup-icon">
                                    <i class="fas fa-truck"></i>
                                </div>
                                <div class="flex-grow-1">
                                    <div class="fw-bold text-light"><%# Eval("WasteType") %></div>
                                    <div class="text-muted small"><%# Eval("ScheduleDate") %></div>
                                </div>
                                <div class="badge bg-primary"><%# Eval("Status") %></div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                    <asp:Panel ID="pnlNoUpcomingPickups" runat="server" Visible="false" class="text-center py-3">
                        <i class="fas fa-truck fa-2x text-muted mb-2"></i>
                        <p class="text-muted mb-0">No upcoming pickups</p>
                        <small class="text-muted">Schedule a pickup to get started</small>
                    </asp:Panel>
                </div>

                <!-- Community Stats -->
                <div class="stat-card">
                    <h5 class="fw-bold mb-3 text-light section-title">Community Impact</h5>
                    <div class="community-stats">
                        <div class="community-stat">
                            <div class="stat-number text-primary"><asp:Literal ID="litTotalUsers" runat="server" Text="0" /></div>
                            <div class="stat-label">Active Users</div>
                        </div>
                        <div class="community-stat">
                            <div class="stat-number text-success"><asp:Literal ID="litTotalRecycledCommunity" runat="server" Text="0" />kg</div>
                            <div class="stat-label">Total Recycled</div>
                        </div>
                        <div class="community-stat">
                            <div class="stat-number text-warning"><asp:Literal ID="litTreesSavedCommunity" runat="server" Text="0" /></div>
                            <div class="stat-label">Trees Saved</div>
                        </div>
                        <div class="community-stat">
                            <div class="stat-number text-info"><asp:Literal ID="litCO2SavedCommunity" runat="server" Text="0" />kg</div>
                            <div class="stat-label">CO₂ Reduced</div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Environmental Impact -->
        <div class="row mt-4">
            <div class="col-12">
                <div class="stat-card">
                    <h4 class="fw-bold mb-4 text-light section-title">Your Environmental Impact</h4>
                    <div class="row text-center">
                        <div class="col-md-3">
                            <div class="impact-item">
                                <i class="fas fa-bottle-water fa-2x text-primary mb-2"></i>
                                <h5 class="fw-bold text-light"><asp:Literal ID="litPlasticBottles" runat="server" Text="0" /></h5>
                                <p class="text-muted mb-0">Plastic Bottles Saved</p>
                            </div>
                        </div>
                        <div class="col-md-3">
                            <div class="impact-item">
                                <i class="fas fa-bolt fa-2x text-warning mb-2"></i>
                                <h5 class="fw-bold text-light"><asp:Literal ID="litEnergySaved" runat="server" Text="0" /> kWh</h5>
                                <p class="text-muted mb-0">Energy Saved</p>
                            </div>
                        </div>
                        <div class="col-md-3">
                            <div class="impact-item">
                                <i class="fas fa-tint fa-2x text-info mb-2"></i>
                                <h5 class="fw-bold text-light"><asp:Literal ID="litWaterSaved" runat="server" Text="0" /> L</h5>
                                <p class="text-muted mb-0">Water Conserved</p>
                            </div>
                        </div>
                        <div class="col-md-3">
                            <div class="impact-item">
                                <i class="fas fa-gas-pump fa-2x text-danger mb-2"></i>
                                <h5 class="fw-bold text-light"><asp:Literal ID="litFuelSaved" runat="server" Text="0" /> L</h5>
                                <p class="text-muted mb-0">Fuel Saved</p>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Add Chart.js Library -->
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
</asp:Content>