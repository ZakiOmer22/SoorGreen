<%@ Page Title="Collector Performance" Language="C#" MasterPageFile="~/Pages/Collectors/Site.Master" 
    AutoEventWireup="true" Inherits="SoorGreen.Collectors.CollectorPerformance" Codebehind="CollectorPerformance.aspx.cs" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href='<%= ResolveUrl("~/Content/Pages/Collectors/CollectorPerformance.css") %>' rel="stylesheet" />
</asp:Content>

<asp:Content ID="TitleContent" ContentPlaceHolderID="TitleContent" runat="server">
    <div class="d-flex align-items-center justify-content-between py-2">
        <div>
            <h4 class="mb-0 fw-bold">Collector Performance</h4>
            <small class="text-muted">Track metrics and optimize your collection efficiency</small>
        </div>
        <div class="d-flex align-items-center gap-3">
            <div class="bg-light rounded-pill px-3 py-1 d-flex align-items-center gap-2">
                <i class="fas fa-calendar-alt text-primary fs-6"></i>
                <asp:Label ID="lblPerformancePeriod" runat="server" CssClass="fw-medium"></asp:Label>
            </div>
            <div class="position-relative">
                <i class="fas fa-user-circle text-primary fs-3"></i>
            </div>
        </div>
    </div>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <!-- Loading Overlay -->
    <div class="loading-overlay" id="loadingOverlay">
        <div class="spinner-modern"></div>
        <div class="text-white mt-3 fw-medium">Generating Report...</div>
    </div>

    <div class="performance-dashboard">
        <!-- Dashboard Header -->
        <div class="dashboard-header">
            <div class="dashboard-header-content">
                <div class="row align-items-center">
                    <div class="col-lg-8">
                        <h1 class="display-6 mb-3 text-white fw-bold">
                            <i class="fas fa-chart-line me-3"></i>Performance Analytics
                        </h1>
                        <p class="mb-0 opacity-90 text-white fs-5">
                            <i class="fas fa-user-check me-2"></i>
                            Welcome back, <asp:Label ID="lblCollectorName" runat="server" CssClass="fw-bold"></asp:Label>
                        </p>
                        <p class="text-white opacity-75 mt-2">
                            Analyze your collection metrics and environmental impact
                        </p>
                    </div>
                    <div class="col-lg-4 text-lg-end text-start mt-3 mt-lg-0">
                        <div class="bg-white bg-opacity-20 rounded-pill px-4 py-2 d-inline-block">
                            <div class="d-flex align-items-center gap-2">
                                <i class="fas fa-trophy text-warning"></i>
                                <div>
                                    <div class="text-white fw-bold"><asp:Label ID="lblPerformanceRank" runat="server" Text="Top 15%"></asp:Label></div>
                                    <small class="text-white opacity-75">Performance Rank</small>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Filter Panel -->
        <div class="filter-panel">
            <div class="filter-header">
                <div>
                    <h5 class="mb-1 fw-bold">
                        <i class="fas fa-filter me-2 text-primary"></i>Filter Analytics
                    </h5>
                    <small class="text-muted">Select period for detailed analysis</small>
                </div>
                <div class="d-flex gap-2">
                    <asp:LinkButton ID="btnExportPerformance" runat="server" CssClass="btn-modern btn-primary-modern" 
                        OnClick="btnExportPerformance_Click" OnClientClick="showLoading()">
                        <i class="fas fa-file-pdf me-2"></i>Generate Report
                    </asp:LinkButton>
                    <asp:LinkButton ID="btnRefreshData" runat="server" CssClass="btn-modern btn-secondary-modern" 
                        OnClick="btnRefreshData_Click">
                        <i class="fas fa-sync-alt me-2"></i>Refresh
                    </asp:LinkButton>
                </div>
            </div>
            
            <div class="filter-group">
                <div>
                    <label class="form-label mb-2 fw-medium">Time Period</label>
                    <asp:DropDownList ID="ddlTimePeriod" runat="server" CssClass="form-control-modern" 
                        AutoPostBack="true" OnSelectedIndexChanged="ddlTimePeriod_SelectedIndexChanged">
                        <asp:ListItem Text="Last 7 Days" Value="7"></asp:ListItem>
                        <asp:ListItem Text="Last 30 Days" Value="30" Selected="True"></asp:ListItem>
                        <asp:ListItem Text="Last 90 Days" Value="90"></asp:ListItem>
                        <asp:ListItem Text="This Month" Value="month"></asp:ListItem>
                        <asp:ListItem Text="This Quarter" Value="quarter"></asp:ListItem>
                        <asp:ListItem Text="This Year" Value="year"></asp:ListItem>
                        <asp:ListItem Text="Custom Range" Value="custom"></asp:ListItem>
                    </asp:DropDownList>
                </div>
                
                <asp:Panel ID="pnlCustomRange" runat="server" Visible="false" CssClass="d-flex gap-2">
                    <div class="flex-grow-1">
                        <label class="form-label mb-2 fw-medium">Start Date</label>
                        <asp:TextBox ID="txtStartDate" runat="server" CssClass="form-control-modern" 
                            TextMode="Date"></asp:TextBox>
                    </div>
                    <div class="flex-grow-1">
                        <label class="form-label mb-2 fw-medium">End Date</label>
                        <asp:TextBox ID="txtEndDate" runat="server" CssClass="form-control-modern" 
                            TextMode="Date"></asp:TextBox>
                    </div>
                </asp:Panel>
                
                <div>
                    <label class="form-label mb-2">&nbsp;</label>
                    <asp:Button ID="btnApplyFilter" runat="server" Text="Apply Filters" 
                        CssClass="btn-modern btn-primary-modern w-100"
                        OnClick="btnApplyFilter_Click" />
                </div>
            </div>
        </div>

        <!-- Key Performance Indicators -->
        <div class="stats-grid">
            <!-- Collections Card -->
            <div class="stat-card">
                <div class="stat-card-header">
                    <div class="stat-icon-wrapper" style="background: var(--gradient-primary);">
                        <i class="fas fa-truck-loading"></i>
                    </div>
                    <div class="stat-title">
                        <div class="stat-label">Successful Collections</div>
                        <div class="stat-description">Total pickups completed</div>
                    </div>
                </div>
                <div class="stat-value">
                    <asp:Label ID="lblTotalCollections" runat="server" Text="0"></asp:Label>
                </div>
                <div class="stat-metrics">
                    <span class="trend-badge trend-up">
                        <i class="fas fa-arrow-up"></i>
                        <asp:Label ID="lblCollectionTrend" runat="server" Text="+12%"></asp:Label>
                    </span>
                    <span class="comparison-badge">
                        <i class="fas fa-chart-line"></i> Above average
                    </span>
                </div>
            </div>

            <!-- Weight Card -->
            <div class="stat-card">
                <div class="stat-card-header">
                    <div class="stat-icon-wrapper" style="background: var(--gradient-success);">
                        <i class="fas fa-weight-hanging"></i>
                    </div>
                    <div class="stat-title">
                        <div class="stat-label">Waste Collected</div>
                        <div class="stat-description">Total weight diverted from landfill</div>
                    </div>
                </div>
                <div class="stat-value">
                    <asp:Label ID="lblTotalWeight" runat="server" Text="0"></asp:Label> kg
                </div>
                <div class="stat-metrics">
                    <span class="trend-badge trend-up">
                        <i class="fas fa-arrow-up"></i>
                        <asp:Label ID="lblWeightTrend" runat="server" Text="+8%"></asp:Label>
                    </span>
                    <span class="comparison-badge">
                        <i class="fas fa-leaf"></i> Environmental impact
                    </span>
                </div>
            </div>

            <!-- Efficiency Card -->
            <div class="stat-card">
                <div class="stat-card-header">
                    <div class="stat-icon-wrapper" style="background: var(--gradient-warning);">
                        <i class="fas fa-bolt"></i>
                    </div>
                    <div class="stat-title">
                        <div class="stat-label">Operational Efficiency</div>
                        <div class="stat-description">Performance score based on metrics</div>
                    </div>
                </div>
                <div class="stat-value">
                    <asp:Label ID="lblAvgEfficiency" runat="server" Text="0"></asp:Label>%
                </div>
                <div class="stat-metrics">
                    <span class="trend-badge trend-neutral">
                        <i class="fas fa-minus"></i>
                        <asp:Label ID="lblEfficiencyTrend" runat="server" Text="Stable"></asp:Label>
                    </span>
                    <span class="comparison-badge">
                        <i class="fas fa-check-circle"></i> Meeting target
                    </span>
                </div>
            </div>

            <!-- Rating Card -->
            <div class="stat-card">
                <div class="stat-card-header">
                    <div class="stat-icon-wrapper" style="background: var(--gradient-purple);">
                        <i class="fas fa-star"></i>
                    </div>
                    <div class="stat-title">
                        <div class="stat-label">Customer Rating</div>
                        <div class="stat-description">Average satisfaction score</div>
                    </div>
                </div>
                <div class="stat-value">
                    <asp:Label ID="lblCustomerRating" runat="server" Text="0.0"></asp:Label>
                </div>
                <div class="stat-metrics">
                    <span class="trend-badge trend-up">
                        <i class="fas fa-arrow-up"></i>
                        <asp:Label ID="lblRatingTrend" runat="server" Text="+0.4"></asp:Label>
                    </span>
                    <div class="rating-stars fs-5">
                        <asp:Literal ID="litRatingStars" runat="server"></asp:Literal>
                    </div>
                </div>
            </div>
        </div>

        <!-- Environmental Impact Section -->
        <div class="environmental-impact">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <h4 class="fw-bold mb-0">
                    <i class="fas fa-leaf me-2 text-success"></i>Environmental Impact
                </h4>
            </div>
            
            <div class="impact-cards">
                <div class="impact-card">
                    <div class="impact-icon" style="background: var(--gradient-success);">
                        <i class="fas fa-cloud"></i>
                    </div>
                    <div class="impact-value">
                        <asp:Label ID="lblCO2Saved" runat="server" Text="0"></asp:Label> kg
                    </div>
                    <div class="impact-label">CO₂ Emissions Saved</div>
                    <div class="impact-description">
                        Equivalent to planting <asp:Label ID="lblTreesEquivalent" runat="server" Text="8"></asp:Label> mature trees
                    </div>
                </div>
                
                <div class="impact-card">
                    <div class="impact-icon" style="background: var(--gradient-primary);">
                        <i class="fas fa-gas-pump"></i>
                    </div>
                    <div class="impact-value">
                        <asp:Label ID="lblFuelSaved" runat="server" Text="0"></asp:Label> L
                    </div>
                    <div class="impact-label">Fuel Savings</div>
                    <div class="impact-description">
                        Reduced consumption through optimized routes
                    </div>
                </div>
                
                <div class="impact-card">
                    <div class="impact-icon" style="background: var(--gradient-warning);">
                        <i class="fas fa-hand-holding-usd"></i>
                    </div>
                    <div class="impact-value">
                        $<asp:Label ID="lblCostSaved" runat="server" Text="0"></asp:Label>
                    </div>
                    <div class="impact-label">Operational Savings</div>
                    <div class="impact-description">
                        Reduced fuel and maintenance costs
                    </div>
                </div>
                
                <div class="impact-card">
                    <div class="impact-icon" style="background: var(--gradient-purple);">
                        <i class="fas fa-home"></i>
                    </div>
                    <div class="impact-value">
                        <asp:Label ID="lblHouseholdsSupported" runat="server" Text="0"></asp:Label>
                    </div>
                    <div class="impact-label">Households Supported</div>
                    <div class="impact-description">
                        Families earning sustainable income
                    </div>
                </div>
            </div>
        </div>

        <!-- Analytics Grid -->
        <div class="analytics-grid">
            <!-- Waste Distribution -->
            <div class="analytics-card">
                <div class="card-header">
                    <div class="card-title">
                        <div class="card-icon">
                            <i class="fas fa-recycle"></i>
                        </div>
                        <div>
                            <h5 class="fw-bold mb-0">Waste Composition</h5>
                            <small class="text-muted">Material type distribution</small>
                        </div>
                    </div>
                </div>
                
                <asp:Repeater ID="rptWasteDistribution" runat="server">
                    <ItemTemplate>
                        <div class="mb-3">
                            <div class="d-flex justify-content-between align-items-center mb-2">
                                <div class="d-flex align-items-center gap-2">
                                    <i class='<%# GetWasteTypeIcon(Eval("WasteType").ToString()) %>' 
                                       style='color: <%# GetWasteTypeColor(Eval("WasteType").ToString()) %>; font-size: 1.1rem;'></i>
                                    <span class="fw-medium"><%# Eval("WasteType") %></span>
                                </div>
                                <div>
                                    <span class="fw-bold"><%# Eval("Percentage", "{0:F1}") %>%</span>
                                    <small class="text-muted ms-2">(<%# Eval("Weight", "{0:F1}") %> kg)</small>
                                </div>
                            </div>
                            <div class="performance-meter">
                                <div class="performance-fill" style='width: <%# Eval("Percentage") %>%; 
                                    background: <%# GetWasteTypeColor(Eval("WasteType").ToString()) %>;'></div>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
                
                <asp:Panel ID="pnlNoWasteData" runat="server" CssClass="empty-state" Visible="false">
                    <div class="empty-state-icon">
                        <i class="fas fa-recycle"></i>
                    </div>
                    <h5>No Waste Data</h5>
                    <p class="text-muted">Complete collections to see waste distribution</p>
                </asp:Panel>
            </div>

            <!-- Performance Timeline -->
            <div class="analytics-card">
                <div class="card-header">
                    <div class="card-title">
                        <div class="card-icon">
                            <i class="fas fa-history"></i>
                        </div>
                        <div>
                            <h5 class="fw-bold mb-0">Performance Timeline</h5>
                            <small class="text-muted">Recent milestones and achievements</small>
                        </div>
                    </div>
                </div>
                
                <div class="performance-timeline">
                    <asp:Repeater ID="rptTimeline" runat="server">
                        <ItemTemplate>
                            <div class="timeline-event">
                                <div class="d-flex justify-content-between align-items-start mb-2">
                                    <h6 class="fw-bold mb-0"><%# Eval("EventTitle") %></h6>
                                    <small class="text-muted"><%# Eval("EventDate", "{0:MMM dd}") %></small>
                                </div>
                                <p class="text-muted small mb-2"><%# Eval("EventDescription") %></p>
                                <div class="d-inline-flex align-items-center gap-1">
                                    <i class="fas fa-<%# Eval("EventIcon") %> text-primary small"></i>
                                    <small class="text-muted"><%# Eval("EventType") %></small>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
                
                <asp:Panel ID="pnlNoTimeline" runat="server" CssClass="empty-state" Visible="false">
                    <div class="empty-state-icon">
                        <i class="fas fa-history"></i>
                    </div>
                    <h5>No Timeline Events</h5>
                    <p class="text-muted">Complete tasks to build your timeline</p>
                </asp:Panel>
            </div>
        </div>

        <!-- Performance Log -->
        <div class="analytics-card mt-4">
            <div class="card-header">
                <div class="card-title">
                    <div class="card-icon">
                        <i class="fas fa-table"></i>
                    </div>
                    <div>
                        <h5 class="fw-bold mb-0">Performance Log</h5>
                        <small class="text-muted">Detailed daily performance metrics</small>
                    </div>
                </div>
                <div class="d-flex gap-2">
                    <asp:TextBox ID="txtSearchLog" runat="server" CssClass="form-control-modern" 
                        placeholder="Search dates..." Width="200"></asp:TextBox>
                    <asp:Button ID="btnSearch" runat="server" Text="Search" 
                        CssClass="btn-modern btn-primary-modern" OnClick="btnSearch_Click" />
                </div>
            </div>

            <div class="performance-table-container">
                <div class="table-responsive">
                    <table class="performance-table">
                        <thead>
                            <tr>
                                <th>Date</th>
                                <th>Collections</th>
                                <th>Weight (kg)</th>
                                <th>Distance</th>
                                <th>Efficiency</th>
                                <th>Rating</th>
                                <th>Status</th>
                            </tr>
                        </thead>
                        <tbody>
                            <asp:Repeater ID="rptPerformanceLog" runat="server">
                                <ItemTemplate>
                                    <tr>
                                        <td class="fw-medium">
                                            <i class="fas fa-calendar-day me-2 text-primary"></i>
                                            <%# Eval("RouteDate", "{0:MMM dd, yyyy}") %>
                                        </td>
                                        <td>
                                            <span class="badge bg-primary rounded-pill px-3">
                                                <%# Eval("CollectionCount") %>
                                            </span>
                                        </td>
                                        <td class="fw-medium"><%# Eval("TotalWeight", "{0:F1}") %></td>
                                        <td><%# Eval("Distance", "{0:F1}") %> km</td>
                                        <td>
                                            <div class="d-flex align-items-center gap-2">
                                                <span class="fw-medium"><%# Eval("Efficiency", "{0:F1}") %>%</span>
                                                <div class="performance-meter" style="width: 80px;">
                                                    <div class="performance-fill" style='width: <%# Eval("Efficiency") %>%;'></div>
                                                </div>
                                            </div>
                                        </td>
                                        <td>
                                            <div class="rating-stars">
                                                <%# GetStarRating((decimal)Eval("Rating")) %>
                                            </div>
                                        </td>
                                        <td>
                                            <span class='badge rounded-pill px-3 py-1 <%# GetImpactScoreClass((decimal)Eval("Efficiency")) %>'>
                                                <%# GetImpactScore((decimal)Eval("Efficiency")) %>
                                            </span>
                                        </td>
                                    </tr>
                                </ItemTemplate>
                            </asp:Repeater>
                        </tbody>
                    </table>
                </div>
                
                <asp:Panel ID="pnlNoLogData" runat="server" CssClass="empty-state" Visible="false">
                    <div class="empty-state-icon">
                        <i class="fas fa-table"></i>
                    </div>
                    <h5>No Performance Data</h5>
                    <p class="text-muted">Submit daily reports to build your history</p>
                </asp:Panel>

                <!-- Pagination -->
                <div class="pagination">
                    <div class="page-info">
                        <i class="fas fa-chart-bar me-2"></i>
                        Showing <span class="fw-bold"><asp:Label ID="lblStartRecord" runat="server" Text="1"></asp:Label></span>
                        to <span class="fw-bold"><asp:Label ID="lblEndRecord" runat="server" Text="10"></asp:Label></span>
                        of <span class="fw-bold"><asp:Label ID="lblTotalRecords" runat="server" Text="0"></asp:Label></span> records
                    </div>
                    <div class="page-numbers">
                        <asp:LinkButton ID="btnPrevPage" runat="server" CssClass="page-link" 
                            OnClick="btnPrevPage_Click" Enabled="false">
                            <i class="fas fa-chevron-left"></i>
                        </asp:LinkButton>
                        
                        <asp:Repeater ID="rptPageNumbers" runat="server">
                            <ItemTemplate>
                                <asp:LinkButton ID="btnPage" runat="server" CssClass='<%# (Container.ItemIndex + 1) == CurrentPage ? "page-link active" : "page-link" %>'
                                    CommandArgument='<%# Container.ItemIndex + 1 %>' OnClick="btnPage_Click">
                                    <%# Container.ItemIndex + 1 %>
                                </asp:LinkButton>
                            </ItemTemplate>
                        </asp:Repeater>
                        
                        <asp:LinkButton ID="btnNextPage" runat="server" CssClass="page-link" 
                            OnClick="btnNextPage_Click" Enabled="false">
                            <i class="fas fa-chevron-right"></i>
                        </asp:LinkButton>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- JavaScript -->
    <script>
        // Loading Functions
        function showLoading() {
            document.getElementById('loadingOverlay').style.display = 'flex';
        }
        
        function hideLoading() {
            document.getElementById('loadingOverlay').style.display = 'none';
        }
        
        // Filter Panel Toggle
        document.addEventListener('DOMContentLoaded', function() {
            const timePeriodSelect = document.getElementById('<%= ddlTimePeriod.ClientID %>');
            const customRangePanel = document.getElementById('<%= pnlCustomRange.ClientID %>');

            if (timePeriodSelect && customRangePanel) {
                timePeriodSelect.addEventListener('change', function () {
                    customRangePanel.style.display = this.value === 'custom' ? 'flex' : 'none';
                });
            }

            // Initialize tooltips
            const tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'));
            tooltipTriggerList.map(function (tooltipTriggerEl) {
                return new bootstrap.Tooltip(tooltipTriggerEl);
            });
        });

        // Crystal Reports Integration
        function openCrystalReport() {
            showLoading();
            // The report will open via the button click handler in code-behind
        }
    </script>
</asp:Content>