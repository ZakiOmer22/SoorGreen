<%@ Page Title="Home" Language="C#" MasterPageFile="~/Pages/Collectors/Site.Master" AutoEventWireup="true" CodeFile="Dashboard.aspx.cs" Inherits="SoorGreen.Dashboard" %>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <style>
        .collector-card {
            background: var(--card-bg);
            border: 1px solid var(--card-border);
            border-radius: 16px;
            padding: 1.5rem;
            transition: all 0.3s ease;
            height: 100%;
            position: relative;
            overflow: hidden;
        }

            .collector-card::before {
                content: '';
                position: absolute;
                top: 0;
                left: 0;
                right: 0;
                height: 4px;
                background: linear-gradient(90deg, var(--primary), var(--secondary));
            }

            .collector-card.highlight {
                border-color: var(--primary);
                box-shadow: 0 5px 20px rgba(var(--primary-rgb), 0.15);
            }

        .task-badge {
            position: absolute;
            top: 1rem;
            right: 1rem;
            padding: 0.25rem 0.75rem;
            border-radius: 20px;
            font-size: 0.75rem;
            font-weight: 600;
        }

        .badge-pending {
            background: rgba(245, 158, 11, 0.1);
            color: var(--warning);
            border: 1px solid rgba(245, 158, 11, 0.3);
        }

        .badge-assigned {
            background: rgba(59, 130, 246, 0.1);
            color: var(--info);
            border: 1px solid rgba(59, 130, 246, 0.3);
        }

        .badge-completed {
            background: rgba(16, 185, 129, 0.1);
            color: var(--success);
            border: 1px solid rgba(16, 185, 129, 0.3);
        }

        .task-actions {
            display: flex;
            gap: 0.5rem;
            margin-top: 1rem;
        }

        .collector-stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 1.5rem;
            margin-bottom: 2rem;
        }

        .stat-card-collector {
            background: var(--card-bg);
            border: 1px solid var(--border-color);
            border-radius: 16px;
            padding: 1.5rem;
            text-align: center;
            transition: transform 0.3s ease;
        }

            .stat-card-collector:hover {
                transform: translateY(-5px);
            }

        .stat-icon-collector {
            width: 70px;
            height: 70px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 1rem;
            font-size: 1.5rem;
        }

        .pickup-map {
            height: 400px;
            border-radius: 16px;
            overflow: hidden;
            border: 1px solid var(--border-color);
        }

        .task-list {
            max-height: 400px;
            overflow-y: auto;
        }

        .task-item {
            display: flex;
            align-items: center;
            padding: 1rem;
            border-bottom: 1px solid var(--border-color);
            transition: background-color 0.3s ease;
        }

            .task-item:hover {
                background: rgba(var(--primary-rgb), 0.05);
            }

            .task-item:last-child {
                border-bottom: none;
            }

        .task-icon {
            width: 40px;
            height: 40px;
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            margin-right: 1rem;
            flex-shrink: 0;
        }

        .task-details {
            flex: 1;
        }

        .task-title {
            font-weight: 600;
            margin-bottom: 0.25rem;
            color: var(--text-primary);
        }

        .task-meta {
            display: flex;
            gap: 1rem;
            font-size: 0.875rem;
            color: var(--text-secondary);
        }

        .task-time {
            color: var(--primary);
            font-weight: 500;
        }

        .action-btn {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            padding: 0.75rem 1.25rem;
            border: none;
            border-radius: 10px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            text-decoration: none;
        }

        .btn-start {
            background: linear-gradient(135deg, var(--primary), var(--secondary));
            color: white;
        }

            .btn-start:hover {
                transform: translateY(-2px);
                box-shadow: 0 5px 15px rgba(var(--primary-rgb), 0.4);
            }

        .btn-view {
            background: var(--bg-card);
            border: 2px solid var(--primary);
            color: var(--primary);
        }

            .btn-view:hover {
                background: rgba(var(--primary-rgb), 0.1);
                transform: translateY(-2px);
            }

        @media (max-width: 768px) {
            .collector-stats-grid {
                grid-template-columns: 1fr;
            }

            .task-meta {
                flex-direction: column;
                gap: 0.25rem;
            }

            .task-actions {
                flex-wrap: wrap;
            }
        }
    </style>
    <div class="container-fluid p-0">
        <!-- Collector Welcome Banner -->
        <div class="row mb-4">
            <div class="col-12">
                <div class="collector-card highlight">
                    <div class="row align-items-center">
                        <div class="col-md-8">
                            <h2 class="mb-3">
                                <i class="fas fa-truck me-2" style="color: var(--primary);"></i>
                                Welcome,
                                <asp:Label ID="lblCollectorName" runat="server" Text="Collector Name"></asp:Label>!
                            </h2>
                            <p class="mb-0 text-muted">
                                You have
                                <asp:Label ID="lblPendingTasks" runat="server" Text="0" CssClass="fw-bold text-warning"></asp:Label>
                                pending pickups and 
                                <asp:Label ID="lblTodayTasks" runat="server" Text="0" CssClass="fw-bold text-primary"></asp:Label>
                                scheduled for today.
                            </p>
                        </div>
                        <div class="col-md-4 text-md-end">
                            <asp:Button ID="btnStartRoute" runat="server" Text="Start Today's Route"
                                CssClass="action-btn btn-start" OnClick="btnStartRoute_Click" />
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Collector Stats Grid -->
        <div class="collector-stats-grid mb-4">
            <div class="stat-card-collector">
                <div class="stat-icon-collector" style="background: rgba(var(--primary-rgb), 0.1); color: var(--primary);">
                    <i class="fas fa-tasks"></i>
                </div>
                <h3 class="stat-number">
                    <asp:Label ID="lblTotalTasks" runat="server" Text="0"></asp:Label></h3>
                <p class="stat-label">Total Assigned Tasks</p>
            </div>

            <div class="stat-card-collector">
                <div class="stat-icon-collector" style="background: rgba(16, 185, 129, 0.1); color: var(--success);">
                    <i class="fas fa-check-circle"></i>
                </div>
                <h3 class="stat-number">
                    <asp:Label ID="lblCompletedTasks" runat="server" Text="0"></asp:Label></h3>
                <p class="stat-label">Completed This Week</p>
            </div>

            <div class="stat-card-collector">
                <div class="stat-icon-collector" style="background: rgba(245, 158, 11, 0.1); color: var(--warning);">
                    <i class="fas fa-clock"></i>
                </div>
                <h3 class="stat-number">
                    <asp:Label ID="lblPendingCount" runat="server" Text="0"></asp:Label></h3>
                <p class="stat-label">Pending Pickups</p>
            </div>

            <div class="stat-card-collector">
                <div class="stat-icon-collector" style="background: rgba(59, 130, 246, 0.1); color: var(--info);">
                    <i class="fas fa-weight-hanging"></i>
                </div>
                <h3 class="stat-number">
                    <asp:Label ID="lblTotalWeight" runat="server" Text="0"></asp:Label>
                    kg</h3>
                <p class="stat-label">Total Waste Collected</p>
            </div>
        </div>

        <!-- Main Content Row -->
        <div class="row g-4">
            <!-- Left Column: Today's Tasks -->
            <div class="col-lg-8">
                <div class="collector-card mb-4">
                    <div class="d-flex justify-content-between align-items-center mb-3">
                        <h4 class="mb-0">
                            <i class="fas fa-calendar-day me-2 text-primary"></i>
                            Today's Pickup Schedule
                        </h4>
                        <asp:DropDownList ID="ddlTaskFilter" runat="server" CssClass="form-select form-select-sm w-auto" AutoPostBack="true" OnSelectedIndexChanged="ddlTaskFilter_SelectedIndexChanged">
                            <asp:ListItem Value="all" Text="All Tasks"></asp:ListItem>
                            <asp:ListItem Value="pending" Text="Pending" Selected="True"></asp:ListItem>
                            <asp:ListItem Value="assigned" Text="Assigned"></asp:ListItem>
                            <asp:ListItem Value="completed" Text="Completed"></asp:ListItem>
                        </asp:DropDownList>
                    </div>

                    <div class="task-list">
                        <asp:Repeater ID="rptTodayTasks" runat="server" OnItemDataBound="rptTodayTasks_ItemDataBound">
                            <ItemTemplate>
                                <div class="task-item">
                                    <div class="task-icon" style='background: <%# GetTaskColor(Container.DataItem) %>; color: white;'>
                                        <i class='<%# GetTaskIcon(Container.DataItem) %>'></i>
                                    </div>
                                    <div class="task-details">
                                        <div class="task-title"><%# Eval("Address") %></div>
                                        <div class="task-meta">
                                            <span><i class="fas fa-weight-hanging me-1"></i><%# Eval("EstimatedKg") %> kg</span>
                                            <span><i class="fas fa-trash me-1"></i><%# Eval("WasteType") %></span>
                                            <span class="task-time"><i class="fas fa-clock me-1"></i><%# Eval("ScheduledTime") %></span>
                                        </div>
                                    </div>
                                    <div class="task-actions">
                                        <asp:Button ID="btnViewDetails" runat="server" Text="Details"
                                            CommandArgument='<%# Eval("PickupId") %>'
                                            CssClass="btn btn-sm btn-outline-primary"
                                            OnClick="btnViewDetails_Click" />
                                        <asp:Button ID="btnStartPickup" runat="server" Text="Start"
                                            CommandArgument='<%# Eval("PickupId") %>'
                                            CssClass="btn btn-sm btn-primary"
                                            OnClick="btnStartPickup_Click"
                                            Visible='<%# Eval("Status").ToString() == "Assigned" %>' />
                                        <asp:Button ID="btnCompletePickup" runat="server" Text="Complete"
                                            CommandArgument='<%# Eval("PickupId") %>'
                                            CssClass="btn btn-sm btn-success"
                                            OnClick="btnCompletePickup_Click"
                                            Visible='<%# Eval("Status").ToString() == "In Progress" %>' />
                                    </div>
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>

                        <asp:Panel ID="pnlNoTasks" runat="server" Visible="false" CssClass="text-center py-5">
                            <i class="fas fa-clipboard-check fa-3x text-muted mb-3"></i>
                            <h5 class="text-muted">No tasks scheduled for today</h5>
                        </asp:Panel>
                    </div>
                </div>

                <!-- Quick Actions -->
                <div class="row g-3">
                    <div class="col-md-4">
                        <div class="collector-card text-center h-100">
                            <div class="task-icon mb-3" style="background: rgba(var(--primary-rgb), 0.1); color: var(--primary); margin: 0 auto;">
                                <i class="fas fa-map-marked-alt"></i>
                            </div>
                            <h5>View Route Map</h5>
                            <asp:Button ID="btnViewRoute" runat="server" Text="View Map"
                                CssClass="action-btn btn-view w-100" OnClick="btnViewRoute_Click" />
                        </div>
                    </div>

                    <div class="col-md-4">
                        <div class="collector-card text-center h-100">
                            <div class="task-icon mb-3" style="background: rgba(16, 185, 129, 0.1); color: var(--success); margin: 0 auto;">
                                <i class="fas fa-clipboard-list"></i>
                            </div>
                            <h5>Daily Report</h5>
                            <asp:Button ID="btnSubmitReport" runat="server" Text="Submit Report"
                                CssClass="action-btn btn-start w-100" OnClick="btnSubmitReport_Click" />
                        </div>
                    </div>

                    <div class="col-md-4">
                        <div class="collector-card text-center h-100">
                            <div class="task-icon mb-3" style="background: rgba(59, 130, 246, 0.1); color: var(--info); margin: 0 auto;">
                                <i class="fas fa-qrcode"></i>
                            </div>
                            <h5>Scan Waste</h5>
                            <asp:Button ID="btnScanWaste" runat="server" Text="Open Scanner"
                                CssClass="action-btn btn-view w-100" OnClick="btnScanWaste_Click" />
                        </div>
                    </div>
                </div>
            </div>

            <!-- Right Column: Upcoming & Performance -->
            <div class="col-lg-4">
                <!-- Upcoming Pickups -->
                <div class="collector-card mb-4">
                    <h4 class="mb-3">
                        <i class="fas fa-calendar-alt me-2 text-info"></i>
                        Upcoming Pickups
                    </h4>

                    <div class="task-list" style="max-height: 300px;">
                        <asp:Repeater ID="rptUpcomingTasks" runat="server">
                            <ItemTemplate>
                                <div class="task-item">
                                    <div class="task-icon" style="background: rgba(59, 130, 246, 0.1); color: var(--info);">
                                        <i class="fas fa-clock"></i>
                                    </div>
                                    <div class="task-details">
                                        <div class="task-title small"><%# Eval("Address") %></div>
                                        <div class="task-meta">
                                            <span class="small"><%# Eval("WasteType") %></span>
                                            <span class="task-time small"><%# Eval("ScheduledDate") %></span>
                                        </div>
                                    </div>
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>

                        <asp:Panel ID="pnlNoUpcoming" runat="server" Visible="false" CssClass="text-center py-3">
                            <i class="fas fa-calendar-plus fa-2x text-muted mb-2"></i>
                            <p class="text-muted small">No upcoming pickups scheduled</p>
                        </asp:Panel>
                    </div>
                </div>

                <!-- Performance Stats -->
                <div class="collector-card">
                    <h4 class="mb-3">
                        <i class="fas fa-chart-line me-2 text-success"></i>
                        This Week's Performance
                    </h4>

                    <div class="row g-3">
                        <div class="col-6">
                            <div class="text-center p-3 rounded" style="background: rgba(16, 185, 129, 0.05);">
                                <div class="stat-number" style="font-size: 1.5rem; color: var(--success);">
                                    <asp:Label ID="lblWeeklyCompletions" runat="server" Text="0"></asp:Label>
                                </div>
                                <div class="stat-label small">Pickups Completed</div>
                            </div>
                        </div>

                        <div class="col-6">
                            <div class="text-center p-3 rounded" style="background: rgba(var(--primary-rgb), 0.05);">
                                <div class="stat-number" style="font-size: 1.5rem; color: var(--primary);">
                                    <asp:Label ID="lblWeeklyWeight" runat="server" Text="0"></asp:Label>
                                    kg
                                </div>
                                <div class="stat-label small">Waste Collected</div>
                            </div>
                        </div>
                    </div>

                    <div class="mt-3">
                        <div class="d-flex justify-content-between align-items-center mb-2">
                            <span class="small">Weekly Target: <strong>20 pickups</strong></span>
                            <span class="small text-success">
                                <asp:Label ID="lblTargetProgress" runat="server" Text="0"></asp:Label>%
                            </span>
                        </div>
                        <div class="progress" style="height: 8px; border-radius: 4px;">
                            <div class="progress-bar bg-success" role="progressbar"
                                style='width: <%# GetTargetProgress() %>%;'>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Map View -->
        <asp:Panel ID="pnlMapView" runat="server" Visible="false" CssClass="mt-4">
            <div class="collector-card">
                <div class="d-flex justify-content-between align-items-center mb-3">
                    <h4 class="mb-0">
                        <i class="fas fa-map me-2 text-primary"></i>
                        Pickup Route Map
                    </h4>
                    <asp:Button ID="btnCloseMap" runat="server" Text="Close Map"
                        CssClass="btn btn-sm btn-outline-secondary" OnClick="btnCloseMap_Click" />
                </div>
                <div class="pickup-map" id="mapContainer">
                    <!-- Map will be loaded here -->
                </div>
            </div>
        </asp:Panel>
    </div>
    <!-- Leaflet for Maps -->
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
    <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>

    <script>
        function initializeMap() {
            const mapContainer = document.getElementById('mapContainer');
            if (!mapContainer) return;

            const map = L.map('mapContainer').setView([51.505, -0.09], 13);

            L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
                attribution: '© OpenStreetMap contributors'
            }).addTo(map);

            // Sample markers
            const markers = [
                { lat: 51.505, lng: -0.09, title: "Task #1", status: "pending" },
                { lat: 51.51, lng: -0.1, title: "Task #2", status: "assigned" },
                { lat: 51.49, lng: -0.08, title: "Task #3", status: "completed" }
            ];

            markers.forEach(marker => {
                const iconColor = marker.status === 'completed' ? 'green' :
                    marker.status === 'assigned' ? 'blue' : 'orange';

                const icon = L.divIcon({
                    html: `<div style="background: ${iconColor}; width: 20px; height: 20px; border-radius: 50%; border: 3px solid white; box-shadow: 0 0 10px rgba(0,0,0,0.3);"></div>`,
                    className: 'custom-marker',
                    iconSize: [20, 20]
                });

                L.marker([marker.lat, marker.lng], { icon: icon })
                    .addTo(map)
                    .bindPopup(`<b>${marker.title}</b><br>Status: ${marker.status}`);
            });

            if (markers.length > 0) {
                const bounds = L.latLngBounds(markers.map(m => [m.lat, m.lng]));
                map.fitBounds(bounds, { padding: [50, 50] });
            }
        }

        // Show notification
        function showNotification(message, type = 'info') {
            const notification = document.createElement('div');
            notification.className = `alert alert-${type} alert-dismissible fade show position-fixed`;
            notification.style.cssText = `
             top: 100px;
             right: 20px;
             z-index: 9999;
             min-width: 300px;
             box-shadow: 0 5px 15px rgba(0,0,0,0.2);
             border: none;
         `;

            notification.innerHTML = `
             <strong>${type === 'success' ? '✓' : type === 'error' ? '✗' : 'ℹ'}</strong> ${message}
             <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
         `;

            document.body.appendChild(notification);

            setTimeout(() => {
                if (notification.parentNode) {
                    notification.remove();
                }
            }, 5000);
        }
    </script>
</asp:Content>