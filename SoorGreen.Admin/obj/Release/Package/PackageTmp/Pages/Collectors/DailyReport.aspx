<%@ Page Title="Daily Collection Report" Language="C#" MasterPageFile="~/Pages/Collectors/Site.Master" 
    AutoEventWireup="true" Inherits="SoorGreen.Collectors.DailyReport" Codebehind="DailyReport.aspx.cs" %>

<asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
    <link href='<%= ResolveUrl("~/Content/Pages/Collectors/collectorsroute.css") %>' rel="stylesheet" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body {
            background: var(--bg-primary);
            min-height: 100vh;
        }

        .report-card {
            background: var(--card-bg);
            border-radius: 20px;
            border: 1px solid var(--card-border);
            padding: 2.5rem;
            margin-bottom: 2rem;
            box-shadow: var(--shadow);
            transition: transform 0.3s ease;
        }

        .report-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 15px 30px rgba(0, 0, 0, 0.1);
        }

        .summary-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
            gap: 1.5rem;
            margin: 2.5rem 0;
        }

        .summary-item {
            text-align: center;
            padding: 2rem 1rem;
            border-radius: 16px;
            background: var(--bg-secondary);
            border: 2px solid transparent;
            transition: all 0.3s ease;
            position: relative;
            overflow: hidden;
        }

        .summary-item:hover {
            border-color: var(--primary);
            transform: translateY(-5px);
        }

        .summary-value {
            font-size: 2.5rem;
            font-weight: 800;
            margin-bottom: 0.5rem;
            background: linear-gradient(135deg, var(--primary), var(--secondary));
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }

        .summary-label {
            font-size: 0.95rem;
            color: var(--text-secondary);
            text-transform: uppercase;
            letter-spacing: 0.5px;
            font-weight: 600;
        }

        .waste-breakdown {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
            gap: 1rem;
            margin: 2rem 0;
        }

        .waste-item {
            padding: 1.5rem;
            border-radius: 14px;
            text-align: center;
            background: var(--card-bg);
            border: 1px solid var(--border-color);
            transition: all 0.3s ease;
            position: relative;
            overflow: hidden;
        }

        .waste-item:hover {
            box-shadow: 0 8px 20px rgba(0, 0, 0, 0.08);
            transform: translateY(-3px);
        }

        .waste-icon {
            font-size: 2rem;
            margin-bottom: 1rem;
            height: 60px;
            width: 60px;
            line-height: 60px;
            border-radius: 50%;
            margin: 0 auto 1rem;
            background: linear-gradient(135deg, rgba(var(--primary-rgb, 0, 212, 170), 0.1), rgba(59, 130, 246, 0.1));
        }

        .waste-type {
            font-weight: 600;
            color: var(--text-primary);
            margin-bottom: 0.5rem;
            font-size: 0.9rem;
        }

        .waste-weight {
            font-size: 1.5rem;
            font-weight: 700;
            margin-bottom: 0.25rem;
            color: var(--text-primary);
        }

        .waste-percentage {
            font-size: 0.85rem;
            color: var(--text-secondary);
            font-weight: 500;
        }

        .signature-container {
            border: 2px dashed var(--border-color);
            border-radius: 12px;
            padding: 1.5rem;
            background: var(--bg-secondary);
            margin: 1.5rem 0;
        }

        #signaturePad {
            width: 100%;
            height: 200px;
            border: 1px solid var(--border-color);
            border-radius: 8px;
            background: var(--bg-primary);
            cursor: crosshair;
        }

        .btn-submit {
            background: linear-gradient(135deg, var(--success), #059669);
            border: none;
            padding: 1rem 2rem;
            font-weight: 600;
            font-size: 1.1rem;
            transition: all 0.3s ease;
            color: white;
        }

        .btn-submit:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 20px rgba(16, 185, 129, 0.3);
        }

        .form-control-custom {
            border: 2px solid var(--border-color);
            border-radius: 10px;
            padding: 0.75rem 1rem;
            transition: all 0.3s ease;
            background: var(--bg-secondary);
            color: var(--text-primary);
        }

        .form-control-custom:focus {
            border-color: var(--primary);
            box-shadow: 0 0 0 3px rgba(var(--primary-rgb, 0, 212, 170), 0.1);
        }

        .checklist-container {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
            gap: 1rem;
            margin: 1.5rem 0;
        }

        .form-check-label {
            display: flex;
            align-items: center;
            gap: 0.75rem;
            padding: 0.75rem;
            border: 2px solid var(--border-color);
            border-radius: 10px;
            cursor: pointer;
            transition: all 0.3s ease;
            background: var(--bg-secondary);
            color: var(--text-primary);
        }

        .form-check-label:hover {
            border-color: var(--primary);
            background: rgba(var(--primary-rgb, 0, 212, 170), 0.05);
        }

        .form-check-input:checked + .form-check-label {
            border-color: var(--primary);
            background: rgba(var(--primary-rgb, 0, 212, 170), 0.1);
        }

        .status-badge {
            padding: 0.5rem 1rem;
            border-radius: 50px;
            font-size: 0.85rem;
            font-weight: 600;
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
        }

        .status-complete {
            background: rgba(var(--primary-rgb, 0, 212, 170), 0.1);
            color: var(--primary);
        }

        .status-pending {
            background: rgba(245, 158, 11, 0.1);
            color: #f59e0b;
        }

        .alert-info {
            background: rgba(59, 130, 246, 0.1);
            border-color: rgba(59, 130, 246, 0.2);
            color: var(--info);
        }

        .alert-success {
            background: rgba(16, 185, 129, 0.1);
            border-color: rgba(16, 185, 129, 0.2);
            color: var(--success);
        }

        .breadcrumb {
            background: var(--bg-secondary) !important;
        }

        .breadcrumb-item a {
            color: var(--text-primary) !important;
        }

        .breadcrumb-item.active {
            color: var(--text-secondary) !important;
        }

        .stats-grid-improved {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
            gap: 1.5rem;
            margin-top: 1.5rem;
        }

        .stat-card {
            background: var(--route-glass-bg);
            backdrop-filter: blur(15px);
            border-radius: 16px;
            padding: 1.5rem;
            border: 1px solid var(--route-glass-border);
            transition: all 0.3s ease;
            text-align: center;
        }

        .stat-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 12px 24px rgba(0, 0, 0, 0.15);
            border-color: var(--primary-color);
        }

        .stat-icon-large {
            font-size: 2.5rem;
            margin-bottom: 1rem;
            opacity: 0.9;
        }

        .stat-number-large {
            font-size: 2rem;
            font-weight: 700;
            color: var(--text-primary);
            margin-bottom: 0.5rem;
        }

        .route-controls-glass {
            background: var(--route-glass-bg);
            backdrop-filter: blur(15px);
            border-radius: 16px;
            border: 1px solid var(--route-glass-border);
            padding: 1.5rem;
            margin-bottom: 2rem;
        }

        .form-control-glass {
            background: rgba(255, 255, 255, 0.1);
            border: 1px solid var(--border-color);
            color: var(--text-primary);
            border-radius: 10px;
            padding: 0.75rem 1rem;
        }

        .form-control-glass:focus {
            background: rgba(255, 255, 255, 0.15);
            border-color: var(--primary);
            color: var(--text-primary);
            box-shadow: 0 0 0 3px rgba(var(--primary-rgb, 0, 212, 170), 0.1);
        }

        .action-btn {
            padding: 0.75rem 1.5rem;
            border-radius: 10px;
            font-weight: 600;
            transition: all 0.3s ease;
            border: none;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            justify-content: center;
        }

        .action-btn.primary {
            background: linear-gradient(135deg, var(--primary), var(--primary-dark));
            color: white;
        }

        .action-btn.success {
            background: linear-gradient(135deg, var(--success), #059669);
            color: white;
        }

        .action-btn.secondary {
            background: linear-gradient(135deg, #6b7280, #4b5563);
            color: white;
        }

        .action-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 20px rgba(0, 0, 0, 0.15);
        }

        .page-header-glass {
            background: var(--route-glass-bg);
            backdrop-filter: blur(15px);
            border-radius: 16px;
            border: 1px solid var(--route-glass-border);
            padding: 2rem;
            margin-bottom: 2rem;
        }

        .page-title-glass {
            font-size: 1.75rem;
            font-weight: 700;
            color: var(--text-primary);
            margin-bottom: 0.5rem;
        }

        .page-subtitle-glass {
            color: var(--text-secondary);
            font-size: 1rem;
        }

        .toast-notification {
            position: fixed;
            top: 20px;
            right: 20px;
            z-index: 9999;
            padding: 1rem 1.5rem;
            border-radius: 10px;
            box-shadow: 0 8px 24px rgba(0, 0, 0, 0.2);
            animation: slideInRight 0.3s ease;
            display: flex;
            align-items: center;
            gap: 1rem;
            max-width: 400px;
            min-width: 300px;
        }

        .toast-success {
            background: linear-gradient(135deg, var(--success), #059669);
            color: white;
        }

        .toast-error {
            background: linear-gradient(135deg, var(--danger), #dc2626);
            color: white;
        }

        .toast-info {
            background: linear-gradient(135deg, var(--info), #1d4ed8);
            color: white;
        }

        .toast-icon {
            font-size: 1.25rem;
        }

        .toast-message {
            flex: 1;
            font-size: 0.95rem;
        }

        .toast-close {
            background: none;
            border: none;
            color: white;
            cursor: pointer;
            opacity: 0.8;
            transition: opacity 0.2s;
            padding: 0.25rem;
        }

        .toast-close:hover {
            opacity: 1;
        }

        @keyframes slideInRight {
            from {
                transform: translateX(100%);
                opacity: 0;
            }
            to {
                transform: translateX(0);
                opacity: 1;
            }
        }

        .loading-spinner {
            display: none;
            text-align: center;
            padding: 2rem;
        }

        .spinner {
            width: 40px;
            height: 40px;
            border: 3px solid rgba(16, 185, 129, 0.1);
            border-top: 3px solid var(--success);
            border-radius: 50%;
            animation: spin 1s linear infinite;
            margin: 0 auto 1rem;
        }

        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }

        @media (max-width: 768px) {
            .summary-grid {
                grid-template-columns: repeat(2, 1fr);
            }
            
            .waste-breakdown {
                grid-template-columns: repeat(2, 1fr);
            }
            
            .checklist-container {
                grid-template-columns: 1fr;
            }
        }
    </style>
</asp:Content>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    <div class="d-flex align-items-center justify-content-between">
        <div>
            <h4 class="mb-0">Daily Report</h4>
            <small class="text-muted">Submit your daily collection report</small>
        </div>
        <div class="d-flex align-items-center gap-2">
            <asp:Label ID="lblCollectorName" runat="server" CssClass="text-muted"></asp:Label>
            <div class="user-avatar-small">
                <i class="fas fa-user-circle"></i>
            </div>
        </div>
    </div>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <!-- Hidden field to store signature -->
    <asp:HiddenField ID="hfSignature" runat="server" />

    <div class="route-container" id="pageContainer">
        <!-- Page Header -->
        <div class="page-header-glass mb-4">
            <div class="d-flex justify-content-between align-items-center">
                <div>
                    <h1 class="page-title-glass mb-2">
                        <i class="fas fa-file-alt me-3 text-primary"></i>Daily Collection Report
                    </h1>
                    <p class="page-subtitle-glass mb-0">Submit your end-of-day report for <%= DateTime.Now.ToString("MMMM dd, yyyy") %></p>
                </div>
                <div class="d-flex gap-2">
                    <asp:LinkButton ID="btnRefreshData" runat="server" CssClass="action-btn primary"
                        OnClick="btnRefreshData_Click" OnClientClick="showLoading()">
                        <i class="fas fa-sync-alt me-2"></i>Refresh Data
                    </asp:LinkButton>
                    <asp:LinkButton ID="btnExportReport" runat="server" CssClass="action-btn secondary">
                        <i class="fas fa-file-export me-2"></i>Export PDF
                    </asp:LinkButton>
                </div>
            </div>
        </div>

        <!-- Daily Report Stats -->
        <div class="stats-grid-improved mb-4">
            <div class="stat-card">
                <div class="stat-icon-large text-warning">
                    <i class="fas fa-truck-loading"></i>
                </div>
                <div class="stat-number-large">
                    <asp:Label ID="lblTotalPickups" runat="server" Text="0"></asp:Label>
                </div>
                <div class="stat-label">Total Pickups</div>
                <small class="text-muted">Completed today</small>
            </div>

            <div class="stat-card">
                <div class="stat-icon-large text-success">
                    <i class="fas fa-weight-hanging"></i>
                </div>
                <div class="stat-number-large">
                    <asp:Label ID="lblTotalWeight" runat="server" Text="0"></asp:Label> kg
                </div>
                <div class="stat-label">Total Weight</div>
                <small class="text-muted">Verified waste collected</small>
            </div>

            <div class="stat-card">
                <div class="stat-icon-large text-info">
                    <i class="fas fa-clock"></i>
                </div>
                <div class="stat-number-large">
                    <asp:Label ID="lblTotalHours" runat="server" Text="0"></asp:Label> hrs
                </div>
                <div class="stat-label">Working Hours</div>
                <small class="text-muted">Time spent on route</small>
            </div>

            <div class="stat-card">
                <div class="stat-icon-large text-danger">
                    <i class="fas fa-gas-pump"></i>
                </div>
                <div class="stat-number-large">
                    <asp:Label ID="lblFuelUsed" runat="server" Text="0"></asp:Label> L
                </div>
                <div class="stat-label">Fuel Used</div>
                <small class="text-muted">Estimated consumption</small>
            </div>

            <div class="stat-card">
                <div class="stat-icon-large text-primary">
                    <i class="fas fa-coins"></i>
                </div>
                <div class="stat-number-large">
                    $<asp:Label ID="lblTotalCredits" runat="server" Text="0"></asp:Label>
                </div>
                <div class="stat-label">Total Credits</div>
                <small class="text-muted">Distributed today</small>
            </div>

            <div class="stat-card">
                <div class="stat-icon-large text-secondary">
                    <i class="fas fa-road"></i>
                </div>
                <div class="stat-number-large">
                    <asp:Label ID="lblTotalDistance" runat="server" Text="0"></asp:Label> km
                </div>
                <div class="stat-label">Distance Covered</div>
                <small class="text-muted">Route length</small>
            </div>
        </div>

        <!-- Auto-filled Data Section -->
        <div class="report-card">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <h3 class="mb-0" style="color: var(--text-primary);">
                    <i class="fas fa-chart-bar me-2" style="color: var(--primary);"></i>Today's Collection Summary
                </h3>
                <span class="status-badge status-complete">
                    <i class="fas fa-check-circle"></i>Auto-filled Data
                </span>
            </div>
            
            <!-- Waste Breakdown -->
            <div class="mt-5">
                <h5 class="mb-4" style="color: var(--text-primary);">
                    <i class="fas fa-trash-alt me-2"></i>Waste Type Breakdown
                </h5>
                
                <asp:Panel ID="pnlNoData" runat="server" CssClass="alert alert-info" Visible="false">
                    <i class="fas fa-info-circle me-2"></i>
                    No collection data available for today. Complete pickups to see breakdown.
                </asp:Panel>
                
                <asp:Repeater ID="rptWasteBreakdown" runat="server">
                    <ItemTemplate>
                        <div class="waste-item">
                            <div class="waste-icon">
                                <i class='<%# GetWasteTypeIcon(Eval("WasteType").ToString()) %> text-white'
                                   style='background: <%# GetWasteTypeColor(Eval("WasteType").ToString()) %>;'></i>
                            </div>
                            <div class="waste-type">
                                <%# Eval("WasteType") %>
                            </div>
                            <div class="waste-weight">
                                <strong><%# Eval("Weight", "{0:F1}") %> kg</strong>
                            </div>
                            <div class="waste-percentage">
                                <%# Eval("Percentage", "{0:F1}") %>%
                            </div>
                            <small style="color: var(--text-secondary);">
                                <%# Eval("PickupCount") %> pickup(s)
                            </small>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
        </div>

        <!-- Manual Input Form -->
        <div class="report-card">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <h3 class="mb-0" style="color: var(--text-primary);">
                    <i class="fas fa-edit me-2" style="color: var(--primary);"></i>Additional Information
                </h3>
                <small class="text-muted">Fill in the details below</small>
            </div>
            
            <!-- Time and Vehicle Information -->
            <div class="route-controls-glass mb-4">
                <h5 class="mb-3"><i class="fas fa-clock me-2"></i>Time & Vehicle Details</h5>
                <div class="row g-3">
                    <div class="col-md-6">
                        <div class="control-group">
                            <label class="control-label mb-2">
                                <i class="fas fa-play me-1"></i> Start Time
                            </label>
                            <asp:TextBox ID="txtStartTime" runat="server" CssClass="form-control-glass" 
                                TextMode="Time"></asp:TextBox>
                        </div>
                    </div>
                    
                    <div class="col-md-6">
                        <div class="control-group">
                            <label class="control-label mb-2">
                                <i class="fas fa-stop me-1"></i> End Time
                            </label>
                            <asp:TextBox ID="txtEndTime" runat="server" CssClass="form-control-glass" 
                                TextMode="Time"></asp:TextBox>
                        </div>
                    </div>
                    
                    <div class="col-md-6">
                        <div class="control-group">
                            <label class="control-label mb-2">
                                <i class="fas fa-tachometer-alt me-1"></i> Odometer Start (km)
                            </label>
                            <asp:TextBox ID="txtOdometerStart" runat="server" CssClass="form-control-glass" 
                                TextMode="Number" step="0.1" placeholder="e.g., 15000.5"></asp:TextBox>
                        </div>
                    </div>
                    
                    <div class="col-md-6">
                        <div class="control-group">
                            <label class="control-label mb-2">
                                <i class="fas fa-tachometer-alt me-1"></i> Odometer End (km)
                            </label>
                            <asp:TextBox ID="txtOdometerEnd" runat="server" CssClass="form-control-glass" 
                                TextMode="Number" step="0.1" placeholder="e.g., 15200.5"></asp:TextBox>
                        </div>
                    </div>
                    
                    <div class="col-md-6">
                        <div class="control-group">
                            <label class="control-label mb-2">
                                <i class="fas fa-gas-pump me-1"></i> Fuel Purchased (Liters)
                            </label>
                            <asp:TextBox ID="txtFuelPurchased" runat="server" CssClass="form-control-glass" 
                                TextMode="Number" step="0.1" placeholder="e.g., 15.5"></asp:TextBox>
                        </div>
                    </div>
                    
                    <div class="col-md-6">
                        <div class="control-group">
                            <label class="control-label mb-2">
                                <i class="fas fa-dollar-sign me-1"></i> Fuel Cost ($)
                            </label>
                            <asp:TextBox ID="txtFuelCost" runat="server" CssClass="form-control-glass" 
                                TextMode="Number" step="0.01" placeholder="e.g., 25.75"></asp:TextBox>
                        </div>
                    </div>
                </div>
            </div>
            
            <!-- Challenges Faced -->
            <div class="route-controls-glass mb-4">
                <h5 class="mb-3"><i class="fas fa-exclamation-triangle me-2"></i>Challenges Faced Today</h5>
                <div class="checklist-container">
                    <div class="form-check">
                        <input type="checkbox" class="form-check-input d-none" id="chkTraffic" value="traffic">
                        <label class="form-check-label" for="chkTraffic">
                            <i class="fas fa-traffic-light" style="color: var(--warning);"></i>
                            Traffic delays
                        </label>
                    </div>
                    <div class="form-check">
                        <input type="checkbox" class="form-check-input d-none" id="chkVehicle" value="vehicle">
                        <label class="form-check-label" for="chkVehicle">
                            <i class="fas fa-car" style="color: var(--danger);"></i>
                            Vehicle issues
                        </label>
                    </div>
                    <div class="form-check">
                        <input type="checkbox" class="form-check-input d-none" id="chkAccess" value="access">
                        <label class="form-check-label" for="chkAccess">
                            <i class="fas fa-door-closed" style="color: var(--text-secondary);"></i>
                            Access problems
                        </label>
                    </div>
                    <div class="form-check">
                        <input type="checkbox" class="form-check-input d-none" id="chkWeather" value="weather">
                        <label class="form-check-label" for="chkWeather">
                            <i class="fas fa-cloud-rain" style="color: var(--info);"></i>
                            Weather conditions
                        </label>
                    </div>
                    <div class="form-check">
                        <input type="checkbox" class="form-check-input d-none" id="chkCitizen" value="citizen">
                        <label class="form-check-label" for="chkCitizen">
                            <i class="fas fa-user-slash" style="color: var(--text-secondary);"></i>
                            Citizen not available
                        </label>
                    </div>
                    <div class="form-check">
                        <input type="checkbox" class="form-check-input d-none" id="chkNotReady" value="notready">
                        <label class="form-check-label" for="chkNotReady">
                            <i class="fas fa-clock" style="color: var(--warning);"></i>
                            Waste not ready
                        </label>
                    </div>
                </div>
            </div>
            
            <!-- Notes -->
            <div class="route-controls-glass mb-4">
                <h5 class="mb-3"><i class="fas fa-sticky-note me-2"></i>Notes & Observations</h5>
                <asp:TextBox ID="txtNotes" runat="server" CssClass="form-control-glass" 
                    TextMode="MultiLine" Rows="4" 
                    placeholder="Any issues, observations, special notes, or feedback for today's route..."></asp:TextBox>
            </div>
            
            <!-- Digital Signature -->
            <div class="signature-container mt-4">
                <h5 class="mb-3" style="color: var(--text-primary);">
                    <i class="fas fa-signature me-1"></i>Digital Signature
                    <small class="ms-2" style="color: var(--text-secondary);">Sign below to certify this report</small>
                </h5>
                
                <canvas id="signaturePad" width="600" height="200"></canvas>
                
                <div class="d-flex gap-2 mt-3">
                    <button type="button" class="action-btn secondary" onclick="clearSignature()">
                        <i class="fas fa-eraser me-1"></i>Clear
                    </button>
                    <button type="button" class="action-btn info" onclick="undoSignature()">
                        <i class="fas fa-undo me-1"></i>Undo
                    </button>
                </div>
                
                <div class="alert alert-info mt-3" role="alert">
                    <i class="fas fa-info-circle me-2"></i>
                    By signing, you certify that all information in this report is accurate to the best of your knowledge.
                </div>
            </div>
            
            <!-- Action Buttons -->
            <div class="d-grid gap-2 d-md-flex justify-content-md-end mt-5">
                <asp:Button ID="btnCancel" runat="server" Text="Cancel" 
                    CssClass="action-btn secondary me-md-2" OnClick="btnCancel_Click" />
                <asp:Button ID="btnSaveDraft" runat="server" Text="Save as Draft" 
                    CssClass="action-btn primary me-md-2" OnClick="btnSaveDraft_Click" />
                <asp:Button ID="btnSubmitReport" runat="server" Text="Submit Daily Report" 
                    CssClass="btn btn-submit" OnClick="btnSubmitReport_Click" 
                    OnClientClick="return validateForm();" />
            </div>
            
            <!-- Submission Status -->
            <asp:Panel ID="pnlSubmissionStatus" runat="server" CssClass="mt-4" Visible="false">
                <div class="alert alert-success alert-dismissible fade show" role="alert">
                    <i class="fas fa-check-circle me-2"></i>
                    <asp:Label ID="lblStatusMessage" runat="server"></asp:Label>
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
            </asp:Panel>
        </div>
    </div>

    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    
    <!-- Signature Pad Library -->
    <script src="https://cdn.jsdelivr.net/npm/signature_pad@4.0.0/dist/signature_pad.umd.min.js"></script>
    
    <script>
        let signaturePad;

        // Initialize when DOM is ready
        document.addEventListener('DOMContentLoaded', function () {
            initializeSignaturePad();
            setDefaultTimes();

            // Custom checkbox styling
            styleCheckboxes();

            // Calculate distance if odometers are filled
            setupOdometerCalculations();

            // Auto-calculate working hours
            setupTimeCalculations();
        });

        function initializeSignaturePad() {
            const canvas = document.getElementById('signaturePad');
            if (canvas) {
                signaturePad = new SignaturePad(canvas, {
                    backgroundColor: getComputedStyle(document.documentElement).getPropertyValue('--bg-secondary').trim(),
                    penColor: getComputedStyle(document.documentElement).getPropertyValue('--text-primary').trim(),
                    minWidth: 1,
                    maxWidth: 3
                });

                // Handle window resize
                function resizeCanvas() {
                    const ratio = Math.max(window.devicePixelRatio || 1, 1);
                    canvas.width = canvas.offsetWidth * ratio;
                    canvas.height = canvas.offsetHeight * ratio;
                    canvas.getContext("2d").scale(ratio, ratio);
                    signaturePad.clear();
                }

                window.addEventListener("resize", resizeCanvas);
                resizeCanvas();
            }
        }

        function setDefaultTimes() {
            const now = new Date();
            const startTime = document.getElementById('<%= txtStartTime.ClientID %>');
            const endTime = document.getElementById('<%= txtEndTime.ClientID %>');

            // Set default start time to 8 AM
            if (startTime && !startTime.value) {
                const defaultStart = new Date(now);
                defaultStart.setHours(8, 0, 0, 0);
                startTime.value = defaultStart.toTimeString().substring(0, 5);
            }

            // Set default end time to current time or 5 PM if earlier
            if (endTime && !endTime.value) {
                const defaultEnd = new Date(now);
                if (defaultEnd.getHours() < 17) {
                    defaultEnd.setHours(17, 0, 0, 0);
                }
                endTime.value = defaultEnd.toTimeString().substring(0, 5);
            }
        }

        function styleCheckboxes() {
            const checkboxes = document.querySelectorAll('.form-check-input');
            const primaryColor = getComputedStyle(document.documentElement).getPropertyValue('--primary').trim();

            checkboxes.forEach(cb => {
                const label = document.querySelector(`label[for="${cb.id}"]`);
                if (label) {
                    cb.addEventListener('change', function () {
                        if (this.checked) {
                            label.style.borderColor = primaryColor;
                            label.style.background = 'rgba(var(--primary-rgb, 0, 212, 170), 0.1)';
                        } else {
                            const borderColor = getComputedStyle(document.documentElement).getPropertyValue('--border-color').trim();
                            const bgColor = getComputedStyle(document.documentElement).getPropertyValue('--bg-secondary').trim();
                            label.style.borderColor = borderColor;
                            label.style.background = bgColor;
                        }
                    });
                }
            });
        }

        function setupOdometerCalculations() {
            const startOdo = document.getElementById('<%= txtOdometerStart.ClientID %>');
            const endOdo = document.getElementById('<%= txtOdometerEnd.ClientID %>');

            if (startOdo && endOdo) {
                startOdo.addEventListener('input', calculateDistance);
                endOdo.addEventListener('input', calculateDistance);
            }
        }

        function calculateDistance() {
            const start = parseFloat(document.getElementById('<%= txtOdometerStart.ClientID %>').value) || 0;
            const end = parseFloat(document.getElementById('<%= txtOdometerEnd.ClientID %>').value) || 0;
            
            if (end > start && start > 0) {
                const distance = end - start;
                console.log('Distance traveled:', distance.toFixed(1), 'km');
            }
        }
        
        function setupTimeCalculations() {
            const startTime = document.getElementById('<%= txtStartTime.ClientID %>');
            const endTime = document.getElementById('<%= txtEndTime.ClientID %>');
            
            if (startTime && endTime) {
                startTime.addEventListener('change', calculateWorkingHours);
                endTime.addEventListener('change', calculateWorkingHours);
            }
        }
        
        function calculateWorkingHours() {
            const startVal = document.getElementById('<%= txtStartTime.ClientID %>').value;
            const endVal = document.getElementById('<%= txtEndTime.ClientID %>').value;
            
            if (startVal && endVal) {
                const [startHour, startMin] = startVal.split(':').map(Number);
                const [endHour, endMin] = endVal.split(':').map(Number);
                
                let startTotal = startHour * 60 + startMin;
                let endTotal = endHour * 60 + endMin;
                
                // Handle overnight (end time is next day)
                if (endTotal < startTotal) {
                    endTotal += 24 * 60;
                }
                
                const diffMinutes = endTotal - startTotal;
                const hours = Math.floor(diffMinutes / 60);
                const minutes = diffMinutes % 60;
                
                console.log('Working hours:', hours, 'hours', minutes, 'minutes');
            }
        }
        
        function clearSignature() {
            if (signaturePad) {
                signaturePad.clear();
                document.getElementById('<%= hfSignature.ClientID %>').value = '';
            }
        }
        
        function undoSignature() {
            if (signaturePad) {
                const data = signaturePad.toData();
                if (data) {
                    data.pop(); // Remove the last dot or line
                    signaturePad.fromData(data);
                }
            }
        }
        
        function saveSignature() {
            if (signaturePad && !signaturePad.isEmpty()) {
                const signatureData = signaturePad.toDataURL('image/png');
                document.getElementById('<%= hfSignature.ClientID %>').value = signatureData;
                return true;
            } else {
                return confirm('No signature provided. Submit report without signature?');
            }
        }
        
        function validateForm() {
            // Save signature
            if (!saveSignature()) {
                return false;
            }
            
            // Validate end time is after start time
            const startVal = document.getElementById('<%= txtStartTime.ClientID %>').value;
            const endVal = document.getElementById('<%= txtEndTime.ClientID %>').value;
            
            if (startVal && endVal) {
                const startDate = new Date('2000-01-01T' + startVal);
                const endDate = new Date('2000-01-01T' + endVal);
                
                if (endDate <= startDate) {
                    alert('End time must be after start time.');
                    return false;
                }
            }
            
            // Validate odometer readings
            const startOdo = parseFloat(document.getElementById('<%= txtOdometerStart.ClientID %>').value) || 0;
            const endOdo = parseFloat(document.getElementById('<%= txtOdometerEnd.ClientID %>').value) || 0;

            if (endOdo > 0 && startOdo > 0 && endOdo <= startOdo) {
                if (!confirm('Odometer end reading should be greater than start reading. Continue anyway?')) {
                    return false;
                }
            }

            return true;
        }

        // Toast notification function
        function showToast(message, type) {
            // Remove existing toasts
            const existingToasts = document.querySelectorAll('.toast-notification');
            existingToasts.forEach(toast => {
                toast.style.animation = 'slideInRight 0.3s ease reverse';
                setTimeout(() => toast.remove(), 300);
            });

            // Create new toast
            const toast = document.createElement('div');
            toast.className = `toast-notification toast-${type}`;
            toast.innerHTML = `
                <div class="toast-icon">
                    <i class="${getToastIcon(type)}"></i>
                </div>
                <div class="toast-message">${message}</div>
                <button class="toast-close" onclick="this.parentElement.remove()">
                    <i class="fas fa-times"></i>
                </button>
            `;

            // Add to body
            document.body.appendChild(toast);

            // Auto remove after 5 seconds
            setTimeout(() => {
                if (toast.parentElement) {
                    toast.style.animation = 'slideInRight 0.3s ease reverse';
                    setTimeout(() => toast.remove(), 300);
                }
            }, 5000);
        }

        function getToastIcon(type) {
            switch (type) {
                case 'success': return 'fas fa-check-circle';
                case 'error': return 'fas fa-exclamation-circle';
                case 'warning': return 'fas fa-exclamation-triangle';
                case 'info': return 'fas fa-info-circle';
                default: return 'fas fa-bell';
            }
        }

        // Loading spinner functions
        function showLoading() {
            const spinner = document.getElementById('loadingSpinner');
            if (spinner) spinner.style.display = 'block';
        }

        function hideLoading() {
            const spinner = document.getElementById('loadingSpinner');
            if (spinner) spinner.style.display = 'none';
        }
    </script>
</asp:Content>