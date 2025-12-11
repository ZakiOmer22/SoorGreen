<%@ Page Title="My Route" Language="C#" MasterPageFile="~/Pages/Collectors/Site.Master"
    AutoEventWireup="true" CodeFile="MyRoute.aspx.cs" Inherits="SoorGreen.Collectors.MyRoute" %>

<asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
    <link href='<%= ResolveUrl("~/Content/Pages/Collectors/collectorsroute.css") %>' rel="stylesheet" />

    <!-- Add Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

    <!-- Add Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</asp:Content>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    My Route - SoorGreen Collector
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <!-- Hidden fields for verification - MUST be inside the form -->
    <asp:HiddenField ID="hiddenPickupId" runat="server" />
    <asp:HiddenField ID="hiddenWasteType" runat="server" />

    <div class="route-container">
        <!-- Page Header -->
        <div class="page-header-glass">
            <h1 class="page-title-glass">Collection Route Management</h1>
            <p class="page-subtitle-glass">Manage your daily collection schedule and optimize routes</p>

            <!-- Quick Actions -->
            <div class="d-flex gap-3 mt-4">
                <asp:LinkButton ID="btnStartRoute" runat="server" CssClass="action-btn primary"
                    OnClick="btnStartRoute_Click">
                    <i class="fas fa-play me-2"></i>Start Route
                </asp:LinkButton>

                <asp:LinkButton ID="btnOptimizeRoute" runat="server" CssClass="action-btn secondary"
                    OnClick="btnOptimizeRoute_Click">
                    <i class="fas fa-route me-2"></i>Optimize Route
                </asp:LinkButton>

                <asp:LinkButton ID="btnCompleteRoute" runat="server" CssClass="action-btn success"
                    OnClick="btnCompleteRoute_Click" Visible="false">
                    <i class="fas fa-flag-checkered me-2"></i>Complete Route
                </asp:LinkButton>

                <asp:LinkButton ID="btnPrintRoute" runat="server" CssClass="action-btn secondary"
                    OnClick="btnPrintRoute_Click">
                    <i class="fas fa-print me-2"></i>Print Route
                </asp:LinkButton>
            </div>
        </div>

        <!-- Collector Stats -->
        <div class="collector-stats">
            <div class="stats-card-glass">
                <div class="stats-header">
                    <div class="stats-title">
                        <h3><i class="fas fa-truck me-2"></i>Today's Collection Stats</h3>
                        <asp:Label ID="lblTodayDate" runat="server" CssClass="stats-date"></asp:Label>
                    </div>
                    <div class="stats-status">
                        <asp:Label ID="lblRouteStatus" runat="server" CssClass="status-badge" Text="Not Started"></asp:Label>
                    </div>
                </div>

                <div class="stats-grid">
                    <div class="stat-item">
                        <div class="stat-icon">
                            <i class="fas fa-map-marker-alt text-primary"></i>
                        </div>
                        <div class="stat-content">
                            <div class="stat-number">
                                <asp:Label ID="lblTotalStops" runat="server" Text="0"></asp:Label>
                            </div>
                            <div class="stat-label">Total Stops</div>
                        </div>
                    </div>

                    <div class="stat-item">
                        <div class="stat-icon">
                            <i class="fas fa-check-circle text-success"></i>
                        </div>
                        <div class="stat-content">
                            <div class="stat-number">
                                <asp:Label ID="lblCompletedStops" runat="server" Text="0"></asp:Label>
                            </div>
                            <div class="stat-label">Completed</div>
                        </div>
                    </div>

                    <div class="stat-item">
                        <div class="stat-icon">
                            <i class="fas fa-clock text-warning"></i>
                        </div>
                        <div class="stat-content">
                            <div class="stat-number">
                                <asp:Label ID="lblPendingStops" runat="server" Text="0"></asp:Label>
                            </div>
                            <div class="stat-label">Pending</div>
                        </div>
                    </div>

                    <div class="stat-item">
                        <div class="stat-icon">
                            <i class="fas fa-weight text-info"></i>
                        </div>
                        <div class="stat-content">
                            <div class="stat-number">
                                <asp:Label ID="lblTotalWeight" runat="server" Text="0"></asp:Label>
                            </div>
                            <div class="stat-label">Est. Weight</div>
                        </div>
                    </div>

                    <div class="stat-item">
                        <div class="stat-icon">
                            <i class="fas fa-route text-danger"></i>
                        </div>
                        <div class="stat-content">
                            <div class="stat-number">
                                <asp:Label ID="lblTotalDistance" runat="server" Text="0"></asp:Label>
                            </div>
                            <div class="stat-label">Total Distance</div>
                        </div>
                    </div>

                    <div class="stat-item">
                        <div class="stat-icon">
                            <i class="fas fa-hourglass-half text-secondary"></i>
                        </div>
                        <div class="stat-content">
                            <div class="stat-number">
                                <asp:Label ID="lblEstTime" runat="server" Text="0"></asp:Label>
                            </div>
                            <div class="stat-label">Est. Time</div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Route Management Section -->
        <div class="route-management-section">
            <div class="row g-4">
                <!-- Left Column: Map -->
                <div class="col-lg-8">
                    <div class="map-container-glass">
                        <div class="map-header">
                            <h4><i class="fas fa-map me-2"></i>Route Map</h4>
                            <div class="map-controls">
                                <button type="button" class="map-control-btn" id="btnZoomIn" title="Zoom In">
                                    <i class="fas fa-plus"></i>
                                </button>
                                <button type="button" class="map-control-btn" id="btnZoomOut" title="Zoom Out">
                                    <i class="fas fa-minus"></i>
                                </button>
                                <button type="button" class="map-control-btn" id="btnCenterMap" title="Center Map">
                                    <i class="fas fa-crosshairs"></i>
                                </button>
                                <button type="button" class="map-control-btn" id="btnToggleTraffic" title="Toggle Traffic">
                                    <i class="fas fa-traffic-light"></i>
                                </button>
                            </div>
                        </div>
                        <div id="routeMap" class="route-map"></div>
                        <div class="map-legend">
                            <div class="legend-item">
                                <span class="legend-color start"></span>
                                <span>Start Point</span>
                            </div>
                            <div class="legend-item">
                                <span class="legend-color stop"></span>
                                <span>Collection Stop</span>
                            </div>
                            <div class="legend-item">
                                <span class="legend-color current"></span>
                                <span>Current Location</span>
                            </div>
                            <div class="legend-item">
                                <span class="legend-color route"></span>
                                <span>Optimized Route</span>
                            </div>
                        </div>
                    </div>

                    <!-- Route Progress -->
                    <div class="route-progress-glass mt-4">
                        <div class="progress-header">
                            <h4>Route Progress</h4>
                            <asp:Label ID="lblRouteProgressPercentage" runat="server" CssClass="progress-percentage" Text="0%"></asp:Label>
                        </div>
                        <div class="progress-glass">
                            <div class="progress-bar-glass" id="routeProgressBar" runat="server" style="width: 0%"></div>
                        </div>
                        <div class="progress-stats">
                            <div class="progress-stat">
                                <i class="fas fa-clock"></i>
                                <span>Time Elapsed: <strong>
                                    <asp:Label ID="lblTimeElapsed" runat="server" Text="00:00"></asp:Label>
                                </strong></span>
                            </div>
                            <div class="progress-stat">
                                <i class="fas fa-road"></i>
                                <span>Distance Covered: <strong>
                                    <asp:Label ID="lblDistanceCovered" runat="server" Text="0 km"></asp:Label>
                                </strong></span>
                            </div>
                            <div class="progress-stat">
                                <i class="fas fa-weight"></i>
                                <span>Weight Collected: <strong>
                                    <asp:Label ID="lblWeightCollected" runat="server" Text="0 kg"></asp:Label>
                                </strong></span>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Right Column: Route Details -->
                <div class="col-lg-4">
                    <!-- Route Controls -->
                    <div class="route-controls-glass">
                        <h4><i class="fas fa-cogs me-2"></i>Route Controls</h4>

                        <div class="control-group">
                            <asp:Label ID="lblRouteType" runat="server" CssClass="control-label" Text="Route Type:"></asp:Label>
                            <asp:DropDownList ID="ddlRouteType" runat="server" CssClass="form-control-glass"
                                AutoPostBack="true" OnSelectedIndexChanged="ddlRouteType_SelectedIndexChanged">
                                <asp:ListItem Value="daily">Daily Route</asp:ListItem>
                                <asp:ListItem Value="scheduled">Scheduled Pickups</asp:ListItem>
                                <asp:ListItem Value="priority">Priority Collections</asp:ListItem>
                                <asp:ListItem Value="emergency">Emergency Cleanup</asp:ListItem>
                            </asp:DropDownList>
                        </div>

                        <div class="control-group">
                            <asp:Label ID="lblVehicle" runat="server" CssClass="control-label" Text="Vehicle:"></asp:Label>
                            <asp:DropDownList ID="ddlVehicle" runat="server" CssClass="form-control-glass"
                                AutoPostBack="true" OnSelectedIndexChanged="ddlVehicle_SelectedIndexChanged">
                            </asp:DropDownList>
                        </div>

                        <div class="control-group">
                            <asp:Label ID="lblStartTime" runat="server" CssClass="control-label" Text="Start Time:"></asp:Label>
                            <asp:TextBox ID="txtStartTime" runat="server" CssClass="form-control-glass"
                                TextMode="Time" Text="08:00">
                            </asp:TextBox>
                        </div>

                        <div class="control-group">
                            <asp:Label ID="lblBreakTime" runat="server" CssClass="control-label" Text="Break Time:"></asp:Label>
                            <asp:TextBox ID="txtBreakTime" runat="server" CssClass="form-control-glass"
                                TextMode="Time" Text="12:00">
                            </asp:TextBox>
                        </div>

                        <div class="control-actions mt-3">
                            <asp:Button ID="btnCalculateRoute" runat="server" CssClass="action-btn secondary w-100"
                                Text="Calculate Route" OnClick="btnCalculateRoute_Click" />
                            <asp:Button ID="btnSaveRoute" runat="server" CssClass="action-btn primary w-100 mt-2"
                                Text="Save Route Plan" OnClick="btnSaveRoute_Click" />
                        </div>
                    </div>

                    <!-- Next Stop -->
                    <div class="next-stop-glass mt-4">
                        <h4><i class="fas fa-arrow-right me-2"></i>Next Stop</h4>
                        <div class="next-stop-details">
                            <div class="stop-info">
                                <div class="stop-header">
                                    <span class="stop-number">#<asp:Label ID="lblNextStopNumber" runat="server" Text="1"></asp:Label></span>
                                    <span class="stop-distance">
                                        <asp:Label ID="lblNextStopDistance" runat="server" Text="0.5 km"></asp:Label>
                                    </span>
                                </div>
                                <h5 class="stop-address">
                                    <asp:Label ID="lblNextStopAddress" runat="server" Text="123 Green Street"></asp:Label>
                                </h5>
                                <div class="stop-meta">
                                    <span class="meta-item">
                                        <i class="fas fa-weight"></i>
                                        <asp:Label ID="lblNextStopWeight" runat="server" Text="15 kg"></asp:Label>
                                    </span>
                                    <span class="meta-item">
                                        <i class="fas fa-trash"></i>
                                        <asp:Label ID="lblNextStopWasteType" runat="server" Text="Plastic"></asp:Label>
                                    </span>
                                    <span class="meta-item">
                                        <i class="fas fa-user"></i>
                                        <asp:Label ID="lblNextStopCitizen" runat="server" Text="John Doe"></asp:Label>
                                    </span>
                                </div>
                                <div class="stop-actions">
                                    <asp:Button ID="btnNavigateToStop" runat="server" CssClass="action-btn primary small"
                                        Text="Navigate" OnClick="btnNavigateToStop_Click" />
                                    <asp:Button ID="btnSkipStop" runat="server" CssClass="action-btn secondary small"
                                        Text="Skip" OnClick="btnSkipStop_Click" />
                                    <asp:Button ID="btnCompleteStop" runat="server" CssClass="action-btn success small"
                                        Text="Complete" OnClick="btnCompleteStop_Click" />
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Route Stops List -->
        <div class="route-stops-section mt-4">
            <div class="section-header-glass">
                <h3><i class="fas fa-list-ol me-2"></i>Route Stops</h3>
                <div class="header-actions">
                    <asp:DropDownList ID="ddlSortStops" runat="server" CssClass="form-control-glass small"
                        AutoPostBack="true" OnSelectedIndexChanged="ddlSortStops_SelectedIndexChanged">
                        <asp:ListItem Value="sequence">By Sequence</asp:ListItem>
                        <asp:ListItem Value="priority">By Priority</asp:ListItem>
                        <asp:ListItem Value="distance">By Distance</asp:ListItem>
                        <asp:ListItem Value="weight">By Weight</asp:ListItem>
                    </asp:DropDownList>
                    <asp:Button ID="btnAddStop" runat="server" CssClass="action-btn secondary"
                        Text="Add Stop" OnClick="btnAddStop_Click" />
                </div>
            </div>

            <div class="stops-table-container">
                <div class="table-header-glass">
                    <div class="table-header-row">
                        <div class="table-col seq-col">#</div>
                        <div class="table-col status-col">Status</div>
                        <div class="table-col address-col">Address</div>
                        <div class="table-col citizen-col">Citizen</div>
                        <div class="table-col type-col">Waste Type</div>
                        <div class="table-col weight-col">Weight</div>
                        <div class="table-col time-col">Est. Time</div>
                        <div class="table-col distance-col">Distance</div>
                        <div class="table-col actions-col">Actions</div>
                    </div>
                </div>

                <div class="table-body-glass">
                    <asp:Repeater ID="rptRouteStops" runat="server"
                        OnItemDataBound="rptRouteStops_ItemDataBound"
                        OnItemCommand="rptRouteStops_ItemCommand">
                        <itemtemplate>
                            <div class='table-row-glass <%# GetStopRowClass(Eval("Status").ToString()) %>'>
                                <div class="table-col seq-col">
                                    <span class="stop-number"><%# Eval("Sequence") %></span>
                                </div>

                                <div class="table-col status-col">
                                    <span class='status-badge <%# GetStatusClass(Eval("Status").ToString()) %>'>
                                        <i class='<%# GetStatusIcon(Eval("Status").ToString()) %>'></i>
                                        <%# Eval("Status") %>
                                    </span>
                                </div>

                                <div class="table-col address-col">
                                    <div class="address-info">
                                        <h6 class="address-title"><%# Eval("Address") %></h6>
                                        <span class="address-subtitle"><%# Eval("Landmark") %></span>
                                    </div>
                                </div>

                                <div class="table-col citizen-col">
                                    <div class="citizen-info">
                                        <div class="citizen-avatar-small">
                                            <img src='<%# GetCitizenAvatar(Eval("CitizenEmail").ToString()) %>'
                                                class="avatar-img-small" alt="Citizen" />
                                        </div>
                                        <div class="citizen-details">
                                            <h6 class="citizen-name"><%# Eval("CitizenName") %></h6>
                                            <span class="citizen-phone"><%# Eval("CitizenPhone") %></span>
                                        </div>
                                    </div>
                                </div>

                                <div class="table-col type-col">
                                    <span class='waste-type-badge <%# GetWasteTypeClass(Eval("WasteType").ToString()) %>'>
                                        <i class='<%# GetWasteTypeIcon(Eval("WasteType").ToString()) %>'></i>
                                        <%# Eval("WasteType") %>
                                    </span>
                                </div>

                                <div class="table-col weight-col">
                                    <span class="weight-value">
                                        <i class="fas fa-weight me-1"></i>
                                        <%# Eval("EstimatedKg", "{0:F1}") %> kg
                                    </span>
                                </div>

                                <div class="table-col time-col">
                                    <span class="time-value">
                                        <i class="fas fa-clock me-1"></i>
                                        <%# Eval("EstimatedTime") %> min
                                    </span>
                                </div>

                                <div class="table-col distance-col">
                                    <span class="distance-value">
                                        <i class="fas fa-route me-1"></i>
                                        <%# Eval("DistanceFromPrev", "{0:F1}") %> km
                                    </span>
                                </div>

                                <div class="table-col actions-col">
                                    <asp:LinkButton ID="btnNavigate" runat="server"
                                        CommandName="Navigate"
                                        CommandArgument='<%# Eval("ReportId") %>'
                                        CssClass="action-btn primary small"
                                        ToolTip="Navigate to Stop">
                                        <i class="fas fa-directions"></i>
                                    </asp:LinkButton>

                                    <asp:LinkButton ID="btnUpdateStatus" runat="server"
                                        CommandName="UpdateStatus"
                                        CommandArgument='<%# Eval("PickupId") %>'
                                        CssClass='<%# GetUpdateButtonClass(Eval("Status").ToString()) %> small'
                                        ToolTip='<%# GetUpdateButtonTooltip(Eval("Status").ToString()) %>'>
                                        <i class='<%# GetUpdateButtonIcon(Eval("Status").ToString()) %>'></i>
                                    </asp:LinkButton>
                                </div>
                            </div>
                        </itemtemplate>
                        <alternatingitemtemplate>
                            <div class='table-row-glass alt <%# GetStopRowClass(Eval("Status").ToString()) %>'>
                                <div class="table-col seq-col">
                                    <span class="stop-number"><%# Eval("Sequence") %></span>
                                </div>

                                <div class="table-col status-col">
                                    <span class='status-badge <%# GetStatusClass(Eval("Status").ToString()) %>'>
                                        <i class='<%# GetStatusIcon(Eval("Status").ToString()) %>'></i>
                                        <%# Eval("Status") %>
                                    </span>
                                </div>

                                <div class="table-col address-col">
                                    <div class="address-info">
                                        <h6 class="address-title"><%# Eval("Address") %></h6>
                                        <span class="address-subtitle"><%# Eval("Landmark") %></span>
                                    </div>
                                </div>

                                <div class="table-col citizen-col">
                                    <div class="citizen-info">
                                        <div class="citizen-avatar-small">
                                            <img src='<%# GetCitizenAvatar(Eval("CitizenEmail").ToString()) %>'
                                                class="avatar-img-small" alt="Citizen" />
                                        </div>
                                        <div class="citizen-details">
                                            <h6 class="citizen-name"><%# Eval("CitizenName") %></h6>
                                            <span class="citizen-phone"><%# Eval("CitizenPhone") %></span>
                                        </div>
                                    </div>
                                </div>

                                <div class="table-col type-col">
                                    <span class='waste-type-badge <%# GetWasteTypeClass(Eval("WasteType").ToString()) %>'>
                                        <i class='<%# GetWasteTypeIcon(Eval("WasteType").ToString()) %>'></i>
                                        <%# Eval("WasteType") %>
                                    </span>
                                </div>

                                <div class="table-col weight-col">
                                    <span class="weight-value">
                                        <i class="fas fa-weight me-1"></i>
                                        <%# Eval("EstimatedKg", "{0:F1}") %> kg
                                    </span>
                                </div>

                                <div class="table-col time-col">
                                    <span class="time-value">
                                        <i class="fas fa-clock me-1"></i>
                                        <%# Eval("EstimatedTime") %> min
                                    </span>
                                </div>

                                <div class="table-col distance-col">
                                    <span class="distance-value">
                                        <i class="fas fa-route me-1"></i>
                                        <%# Eval("DistanceFromPrev", "{0:F1}") %> km
                                    </span>
                                </div>

                                <div class="table-col actions-col">
                                    <asp:LinkButton ID="LinkButton2" runat="server"
                                        CommandName="Navigate"
                                        CommandArgument='<%# Eval("ReportId") %>'
                                        CssClass="action-btn primary small"
                                        ToolTip="Navigate to Stop">
                                        <i class="fas fa-directions"></i>
                                    </asp:LinkButton>

                                    <asp:LinkButton ID="LinkButton3" runat="server"
                                        CommandName="UpdateStatus"
                                        CommandArgument='<%# Eval("PickupId") %>'
                                        CssClass='<%# GetUpdateButtonClass(Eval("Status").ToString()) %> small'
                                        ToolTip='<%# GetUpdateButtonTooltip(Eval("Status").ToString()) %>'>
                                        <i class='<%# GetUpdateButtonIcon(Eval("Status").ToString()) %>'></i>
                                    </asp:LinkButton>
                                </div>
                            </div>
                        </alternatingitemtemplate>
                    </asp:Repeater>
                </div>

                <!-- Empty State -->
                <asp:Panel ID="pnlNoStops" runat="server" CssClass="empty-state-glass" Visible="false">
                    <div class="empty-state-icon">
                        <i class="fas fa-route"></i>
                    </div>
                    <h4 class="empty-state-title">No Stops in Route</h4>
                    <p class="empty-state-message">
                        Add stops to your route to start your collection journey
                    </p>
                    <asp:Button ID="btnFindStops" runat="server" CssClass="action-btn primary"
                        Text="Find Available Stops" OnClick="btnFindStops_Click" />
                </asp:Panel>
            </div>
        </div>

        <!-- Route Summary -->
        <div class="route-summary-section mt-4">
            <div class="row g-4">
                <!-- Route Notes -->
                <div class="col-lg-6">
                    <div class="summary-card-glass">
                        <h4><i class="fas fa-sticky-note me-2"></i>Route Notes</h4>
                        <div class="notes-container">
                            <asp:TextBox ID="txtRouteNotes" runat="server" CssClass="form-control-glass notes-textarea"
                                TextMode="MultiLine" Rows="4" placeholder="Add notes about this route...">
                            </asp:TextBox>
                            <div class="notes-actions mt-2">
                                <asp:Button ID="btnSaveNotes" runat="server" CssClass="action-btn secondary"
                                    Text="Save Notes" OnClick="btnSaveNotes_Click" />
                            </div>
                        </div>
                        <div class="predefined-notes mt-3">
                            <h5>Quick Notes:</h5>
                            <div class="d-flex gap-2 flex-wrap">
                                <asp:LinkButton ID="btnNoteDelay" runat="server" CssClass="note-tag"
                                    OnClick="btnNoteDelay_Click">
                                    Traffic Delay</asp:LinkButton>
                                <asp:LinkButton ID="btnNoteWeather" runat="server" CssClass="note-tag"
                                    OnClick="btnNoteWeather_Click">
                                    Bad Weather</asp:LinkButton>
                                <asp:LinkButton ID="btnNoteVehicle" runat="server" CssClass="note-tag"
                                    OnClick="btnNoteVehicle_Click">
                                    Vehicle Issue</asp:LinkButton>
                                <asp:LinkButton ID="btnNoteFull" runat="server" CssClass="note-tag"
                                    OnClick="btnNoteFull_Click">
                                    Truck Full</asp:LinkButton>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Performance Metrics -->
                <div class="col-lg-6">
                    <div class="summary-card-glass">
                        <h4><i class="fas fa-chart-line me-2"></i>Route Performance</h4>
                        <div class="metrics-grid">
                            <div class="metric-item">
                                <div class="metric-icon">
                                    <i class="fas fa-tachometer-alt"></i>
                                </div>
                                <div class="metric-content">
                                    <div class="metric-value">
                                        <asp:Label ID="lblEfficiencyScore" runat="server" Text="0%"></asp:Label>
                                    </div>
                                    <div class="metric-label">Route Efficiency</div>
                                </div>
                            </div>

                            <div class="metric-item">
                                <div class="metric-icon">
                                    <i class="fas fa-gas-pump"></i>
                                </div>
                                <div class="metric-content">
                                    <div class="metric-value">
                                        <asp:Label ID="lblFuelEstimate" runat="server" Text="0 L"></asp:Label>
                                    </div>
                                    <div class="metric-label">Fuel Estimate</div>
                                </div>
                            </div>

                            <div class="metric-item">
                                <div class="metric-icon">
                                    <i class="fas fa-coins"></i>
                                </div>
                                <div class="metric-content">
                                    <div class="metric-value">
                                        <asp:Label ID="lblCostEstimate" runat="server" Text="$0"></asp:Label>
                                    </div>
                                    <div class="metric-label">Cost Estimate</div>
                                </div>
                            </div>

                            <div class="metric-item">
                                <div class="metric-icon">
                                    <i class="fas fa-leaf"></i>
                                </div>
                                <div class="metric-content">
                                    <div class="metric-value">
                                        <asp:Label ID="lblCo2Saved" runat="server" Text="0 kg"></asp:Label>
                                    </div>
                                    <div class="metric-label">CO₂ Saved</div>
                                </div>
                            </div>
                        </div>

                        <div class="performance-tips mt-3">
                            <h5><i class="fas fa-lightbulb me-2"></i>Optimization Tips:</h5>
                            <ul class="tips-list">
                                <li>
                                    <asp:Label ID="lblTip1" runat="server" Text="Group stops by waste type to reduce sorting time"></asp:Label>
                                </li>
                                <li>
                                    <asp:Label ID="lblTip2" runat="server" Text="Plan routes to avoid peak traffic hours"></asp:Label>
                                </li>
                                <li>
                                    <asp:Label ID="lblTip3" runat="server" Text="Consider vehicle capacity when scheduling stops"></asp:Label>
                                </li>
                            </ul>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Verification Modal -->
    <div class="modal fade" id="verificationModal" tabindex="-1" aria-labelledby="verificationModalLabel" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="verificationModalLabel">Complete Pickup Verification</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <div class="mb-3">
                        <label for="verifyWeight" class="form-label">Verified Weight (kg)</label>
                        <input type="number" class="form-control" id="verifyWeight" step="0.1" min="0" value="0">
                    </div>
                    <div class="mb-3">
                        <label for="verifyWasteType" class="form-label">Material Type</label>
                        <select class="form-control" id="verifyWasteType">
                            <option value="Plastic">Plastic</option>
                            <option value="Paper">Paper</option>
                            <option value="Glass">Glass</option>
                            <option value="Metal">Metal</option>
                            <option value="Organic">Organic</option>
                            <option value="Electronic">Electronic</option>
                        </select>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="button" class="btn btn-primary" id="btnConfirmVerification">Verify & Complete</button>
                </div>
            </div>
        </div>
    </div>

    <!-- Google Maps JavaScript - Optimized Version -->
    <script>
        // Global variables
        var map;
        var markers = [];
        var directionsService;
        var directionsRenderer;
        var trafficLayer;
        var trafficEnabled = false;
        var isMapInitialized = false;
        var mapRetryCount = 0;
        var maxRetries = 3;

        // Optimized Google Maps loading
        function loadGoogleMapsAPI() {
            console.log('Attempting to load Google Maps API...');

            // Prevent duplicate loading
            if (window.google && window.google.maps) {
                console.log('Google Maps already loaded globally');
                if (!isMapInitialized) {
                    initGoogleMap();
                }
                return;
            }

            // Check if script is already being loaded
            var existingScript = document.querySelector('script[src*="maps.googleapis.com/maps/api/js"]');
            if (existingScript) {
                console.log('Google Maps script already in loading process');
                return;
            }

            // Create and configure the script element
            var script = document.createElement('script');

            // YOUR API KEY HERE - Make sure it's enabled and has correct permissions
            var apiKey = 'AIzaSyBESJsZOi_fb-S0YK95_BELsiXGoTLgC_I';

            // Proper async loading with callback
            script.src = 'https://maps.googleapis.com/maps/api/js?key=' + apiKey +
                '&libraries=places,geometry,directions' +
                '&callback=handleGoogleMapsLoaded';

            // Set proper attributes for async loading
            script.async = true;
            script.defer = true;
            script.type = 'text/javascript';

            // Add error handling
            script.onerror = function () {
                console.error('Failed to load Google Maps API');
                handleGoogleMapsError();
            };

            // Add to head
            document.head.appendChild(script);
            console.log('Google Maps script added to page');
        }

        // Handle successful API loading
        function handleGoogleMapsLoaded() {
            console.log('Google Maps API loaded successfully');

            // Wait a bit to ensure everything is ready
            setTimeout(function () {
                if (typeof google !== 'undefined' && typeof google.maps !== 'undefined') {
                    initGoogleMap();
                } else {
                    console.error('Google Maps objects not available after callback');
                    handleGoogleMapsError();
                }
            }, 100);
        }

        // Handle API loading errors
        function handleGoogleMapsError() {
            console.error('Google Maps failed to load');

            if (mapRetryCount < maxRetries) {
                mapRetryCount++;
                console.log('Retrying Google Maps load... Attempt ' + mapRetryCount);

                // Remove any existing script
                var existingScript = document.querySelector('script[src*="maps.googleapis.com"]');
                if (existingScript) {
                    existingScript.remove();
                }

                // Retry after delay
                setTimeout(loadGoogleMapsAPI, 2000 * mapRetryCount);
            } else {
                showMapFallback();
            }
        }

        // Initialize the actual map
        function initGoogleMap() {
            console.log('Initializing Google Map...');

            var mapContainer = document.getElementById('routeMap');
            if (!mapContainer) {
                console.error('Map container #routeMap not found');
                return;
            }

            // Ensure map container has proper dimensions
            if (mapContainer.offsetHeight < 100) {
                console.log('Fixing map container height');
                mapContainer.style.height = '500px';
                mapContainer.style.minHeight = '500px';
            }

            try {
                // Default center (Nairobi coordinates)
                var defaultCenter = { lat: -1.286389, lng: 36.817223 };

                // Map options
                var mapOptions = {
                    center: defaultCenter,
                    zoom: 12,
                    mapTypeId: google.maps.MapTypeId.ROADMAP,
                    mapTypeControl: false,
                    streetViewControl: false,
                    fullscreenControl: true,
                    fullscreenControlOptions: {
                        position: google.maps.ControlPosition.RIGHT_BOTTOM
                    },
                    zoomControl: true,
                    zoomControlOptions: {
                        position: google.maps.ControlPosition.RIGHT_BOTTOM
                    },
                    styles: [
                        {
                            featureType: "poi",
                            elementType: "labels",
                            stylers: [{ visibility: "off" }]
                        },
                        {
                            featureType: "transit",
                            elementType: "labels",
                            stylers: [{ visibility: "off" }]
                        }
                    ],
                    backgroundColor: '#f0f2f5'
                };

                // Create map
                map = new google.maps.Map(mapContainer, mapOptions);

                // Initialize services
                directionsService = new google.maps.DirectionsService();
                directionsRenderer = new google.maps.DirectionsRenderer({
                    map: map,
                    suppressMarkers: false,
                    preserveViewport: false,
                    polylineOptions: {
                        strokeColor: '#10b981',
                        strokeWeight: 5,
                        strokeOpacity: 0.8
                    }
                });

                // Initialize traffic layer (but don't show it initially)
                trafficLayer = new google.maps.TrafficLayer();

                // Add a default marker
                var defaultMarker = new google.maps.Marker({
                    position: defaultCenter,
                    map: map,
                    title: 'Nairobi, Kenya',
                    icon: {
                        url: 'https://maps.google.com/mapfiles/ms/icons/blue-dot.png'
                    },
                    animation: google.maps.Animation.DROP
                });
                markers.push(defaultMarker);

                // Set up map controls
                setupMapControls();

                // Try to get user's current location
                getUserLocation();

                isMapInitialized = true;
                console.log('Google Map initialized successfully');

                // Force resize after initialization
                setTimeout(function () {
                    google.maps.event.trigger(map, 'resize');
                    map.setCenter(defaultCenter); // Re-center after resize
                }, 500);

            } catch (error) {
                console.error('Error initializing Google Map:', error);
                showMapFallback('Error: ' + error.message);
            }
        }

        // Get user's current location
        function getUserLocation() {
            if (navigator.geolocation) {
                navigator.geolocation.getCurrentPosition(
                    function (position) {
                        var userLocation = {
                            lat: position.coords.latitude,
                            lng: position.coords.longitude
                        };

                        if (map) {
                            // Center map on user location
                            map.setCenter(userLocation);
                            map.setZoom(14);

                            // Add user location marker
                            var userMarker = new google.maps.Marker({
                                position: userLocation,
                                map: map,
                                title: 'Your Current Location',
                                icon: {
                                    url: 'https://maps.google.com/mapfiles/ms/icons/green-dot.png',
                                    scaledSize: new google.maps.Size(40, 40)
                                },
                                animation: google.maps.Animation.BOUNCE
                            });
                            markers.push(userMarker);

                            // Add info window
                            var infoWindow = new google.maps.InfoWindow({
                                content: '<div style="padding: 10px;"><strong>Your Location</strong><br>Lat: ' +
                                    position.coords.latitude.toFixed(6) +
                                    '<br>Lng: ' +
                                    position.coords.longitude.toFixed(6) + '</div>'
                            });

                            userMarker.addListener('click', function () {
                                infoWindow.open(map, userMarker);
                            });

                            // Auto-close info window after 5 seconds
                            setTimeout(function () {
                                infoWindow.close();
                            }, 5000);
                        }
                    },
                    function (error) {
                        console.log('Geolocation error:', error.message);
                        // Use default location if geolocation fails
                    },
                    {
                        enableHighAccuracy: true,
                        timeout: 5000,
                        maximumAge: 0
                    }
                );
            }
        }

        // Set up custom map controls
        function setupMapControls() {
            // Zoom In button
            var btnZoomIn = document.getElementById('btnZoomIn');
            if (btnZoomIn) {
                btnZoomIn.addEventListener('click', function () {
                    if (map) {
                        var currentZoom = map.getZoom();
                        map.setZoom(currentZoom + 1);
                    }
                });
            }

            // Zoom Out button
            var btnZoomOut = document.getElementById('btnZoomOut');
            if (btnZoomOut) {
                btnZoomOut.addEventListener('click', function () {
                    if (map) {
                        var currentZoom = map.getZoom();
                        map.setZoom(currentZoom - 1);
                    }
                });
            }

            // Center Map button
            var btnCenterMap = document.getElementById('btnCenterMap');
            if (btnCenterMap) {
                btnCenterMap.addEventListener('click', function () {
                    getUserLocation();
                });
            }

            // Toggle Traffic button
            var btnToggleTraffic = document.getElementById('btnToggleTraffic');
            if (btnToggleTraffic && trafficLayer) {
                btnToggleTraffic.addEventListener('click', function () {
                    if (trafficEnabled) {
                        trafficLayer.setMap(null);
                        this.innerHTML = '<i class="fas fa-traffic-light"></i>';
                        this.classList.remove('active');
                    } else {
                        trafficLayer.setMap(map);
                        this.innerHTML = '<i class="fas fa-traffic-light text-primary"></i>';
                        this.classList.add('active');
                    }
                    trafficEnabled = !trafficEnabled;
                });
            }
        }

        // Show a route on the map
        function showRoute(origin, destination, waypoints) {
            if (!directionsService || !directionsRenderer || !map) {
                console.error('Directions service not ready');
                return false;
            }

            // Clear existing markers
            clearMarkers();

            var request = {
                origin: origin,
                destination: destination,
                waypoints: waypoints || [],
                travelMode: google.maps.TravelMode.DRIVING,
                optimizeWaypoints: true,
                provideRouteAlternatives: false,
                avoidHighways: false,
                avoidTolls: false,
                drivingOptions: {
                    departureTime: new Date(),
                    trafficModel: google.maps.TrafficModel.PESSIMISTIC
                },
                unitSystem: google.maps.UnitSystem.METRIC
            };

            directionsService.route(request, function (result, status) {
                if (status === 'OK') {
                    directionsRenderer.setDirections(result);

                    // Add markers for route points
                    var route = result.routes[0];
                    var legs = route.legs;

                    for (var i = 0; i < legs.length; i++) {
                        // Start point marker
                        addMarker(legs[i].start_location, 'Start: ' + legs[i].start_address, 'green');

                        // End point marker
                        if (i === legs.length - 1) {
                            addMarker(legs[i].end_location, 'End: ' + legs[i].end_address, 'red');
                        }
                    }

                    // Fit map to route bounds
                    var bounds = new google.maps.LatLngBounds();
                    for (var i = 0; i < route.overview_path.length; i++) {
                        bounds.extend(route.overview_path[i]);
                    }
                    map.fitBounds(bounds);

                    return true;
                } else {
                    console.error('Directions request failed:', status);
                    alert('Could not calculate route: ' + status);
                    return false;
                }
            });
        }

        // Add a marker to the map
        function addMarker(position, title, color) {
            if (!map) return null;

            var iconUrl = 'https://maps.google.com/mapfiles/ms/icons/';
            switch (color) {
                case 'red': iconUrl += 'red-dot.png'; break;
                case 'green': iconUrl += 'green-dot.png'; break;
                case 'yellow': iconUrl += 'yellow-dot.png'; break;
                case 'blue': iconUrl += 'blue-dot.png'; break;
                default: iconUrl += 'blue-dot.png';
            }

            var marker = new google.maps.Marker({
                position: position,
                map: map,
                title: title,
                icon: {
                    url: iconUrl,
                    scaledSize: new google.maps.Size(32, 32)
                }
            });

            markers.push(marker);
            return marker;
        }

        // Clear all markers from the map
        function clearMarkers() {
            for (var i = 0; i < markers.length; i++) {
                markers[i].setMap(null);
            }
            markers = [];
        }

        // Show fallback when map fails
        function showMapFallback(message) {
            var mapContainer = document.getElementById('routeMap');
            if (mapContainer) {
                mapContainer.innerHTML =
                    '<div class="map-error-state">' +
                    '<div class="map-error-content">' +
                    '<i class="fas fa-map-marked-alt fa-3x text-muted mb-3"></i>' +
                    '<h4>Map Unavailable</h4>' +
                    '<p>' + (message || 'Google Maps could not be loaded.') + '</p>' +
                    '<div class="mt-3">' +
                    '<button onclick="loadGoogleMapsAPI()" class="action-btn primary me-2">Retry Loading</button>' +
                    '</div>' +
                    '</div>' +
                    '</div>';
            }
        }

        // Initialize verification modal (your existing function)
        function setupVerificationModal() {
            var btnConfirm = document.getElementById('btnConfirmVerification');
            var modalElement = document.getElementById('verificationModal');

            if (btnConfirm && modalElement) {
                btnConfirm.addEventListener('click', function () {
                    var pickupId = document.getElementById('<%= hiddenPickupId.ClientID %>').value;
            var weight = document.getElementById('verifyWeight').value;
            var wasteType = document.getElementById('verifyWasteType').value;

            if (!weight || parseFloat(weight) <= 0) {
                showMessage('error', 'Please enter a valid weight');
                return;
            }

            if (!pickupId) {
                showMessage('error', 'Pickup ID is missing. Please refresh the page.');
                return;
            }

            // Show loading message
            showMessage('info', 'Verifying pickup... Please wait.');

            // Call WebMethod to verify pickup
            SoorGreen.Collectors.MyRoute.VerifyPickup(pickupId, parseFloat(weight), wasteType,
                function (result) {
                    try {
                        var response = JSON.parse(result);
                        if (response.success) {
                            showMessage('success', response.message);

                            // Close modal
                            var modal = bootstrap.Modal.getInstance(modalElement);
                            if (modal) {
                                modal.hide();
                            }

                            // Clear form
                            document.getElementById('verifyWeight').value = '0';

                            // Refresh page after delay
                            setTimeout(function () {
                                location.reload();
                            }, 2000);
                        } else {
                            showMessage('error', response.message || 'Verification failed');
                        }
                    } catch (e) {
                        console.error('Error parsing response:', e);
                        showMessage('error', 'Error processing server response');
                    }
                },
                function (error) {
                    console.error('AJAX error:', error);
                    showMessage('error', 'Error verifying pickup: ' +
                        (error.get_message ? error.get_message() : 'Network error'));
                }
            );
        });
            } else {
                console.warn('Verification modal elements not found');
            }
        }
        // Initialize everything when page loads
        document.addEventListener('DOMContentLoaded', function () {
            console.log('DOM Content Loaded - Initializing route page');

            // Load Google Maps API
            loadGoogleMapsAPI();

            // Setup verification modal
            setupVerificationModal();

            // Handle window resize for map
            window.addEventListener('resize', function () {
                if (map) {
                    setTimeout(function () {
                        google.maps.event.trigger(map, 'resize');
                    }, 100);
                }
            });

            // Add map error CSS if not already present
            if (!document.getElementById('map-error-styles')) {
                var style = document.createElement('style');
                style.id = 'map-error-styles';
                style.textContent = `
                .map-error-state {
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    height: 100%;
                    background: var(--map-bg);
                    border-radius: inherit;
                }
                .map-error-content {
                    text-align: center;
                    padding: 2rem;
                }
                .map-error-content h4 {
                    color: var(--text-primary);
                    margin-bottom: 0.5rem;
                }
                .map-error-content p {
                    color: var(--text-secondary);
                    margin-bottom: 1rem;
                }
            `;
                document.head.appendChild(style);
            }
        });

        // Make functions available globally
        window.showRoute = showRoute;
        window.clearMarkers = clearMarkers;
        window.addMarker = addMarker;
        window.getUserLocation = getUserLocation;
        window.loadGoogleMapsAPI = loadGoogleMapsAPI;

        // Export for ASP.NET if needed
        if (typeof window.SoorGreen === 'undefined') {
            window.SoorGreen = {};
        }
        if (typeof window.SoorGreen.Maps === 'undefined') {
            window.SoorGreen.Maps = {
                showRoute: showRoute,
                clearMarkers: clearMarkers,
                addMarker: addMarker,
                getUserLocation: getUserLocation,
                reloadMap: loadGoogleMapsAPI
            };
        }
    </script>
    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</asp:Content>
