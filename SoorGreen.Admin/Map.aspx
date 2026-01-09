<%@ Page Title="Live Waste Intelligence Map" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="True" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <!-- CSS Libraries -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
    <link rel="stylesheet" href="https://unpkg.com/leaflet.markercluster@1.5.3/dist/MarkerCluster.css" />
    <link rel="stylesheet" href="https://unpkg.com/leaflet.markercluster@1.5.3/dist/MarkerCluster.Default.css" />

    <style>
        /* ===== COMPLETE REDESIGN WITH ANALYTICAL VIEWS ===== */
        :root {
            --primary: #10b981;
            --primary-dark: #059669;
            --secondary: #3b82f6;
            --danger: #ef4444;
            --warning: #f59e0b;
            --success: #10b981;
            --dark: #1f2937;
            --light: #f9fafb;
            --gray: #6b7280;
            --gray-light: #e5e7eb;
            --gray-dark: #374151;
            /* Analytical Zone Colors */
            --zone-critical: #dc2626;
            --zone-high: #ea580c;
            --zone-medium: #f59e0b;
            --zone-low: #10b981;
            --zone-clean: #059669;
            /* Heatmap Colors */
            --heat-red: #dc2626;
            --heat-orange: #ea580c;
            --heat-yellow: #f59e0b;
            --heat-green: #10b981;
            --heat-blue: #3b82f6;
            /* Waste type colors */
            --plastic: #3b82f6;
            --organic: #16a34a;
            --medical: #ec4899;
            --hazardous: #dc2626;
            --construction: #f97316;
            --electronics: #8b5cf6;
            --mixed: #6b7280;
            /* Status colors */
            --status-new: #ef4444;
            --status-assigned: #f59e0b;
            --status-inprogress: #3b82f6;
            --status-collected: #10b981;
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
            background: #0f172a;
            color: white;
        }

        /* ===== NEW DARK THEME LAYOUT ===== */
        .dashboard-container {
            display: flex;
            min-height: 100vh;
            background: #0f172a;
        }

        /* ===== SIDEBAR - LEFT ===== */
        .sidebar {
            width: 380px;
            background: #1e293b;
            border-right: 1px solid #334155;
            display: flex;
            flex-direction: column;
            z-index: 50;
            box-shadow: 5px 0 15px rgba(0, 0, 0, 0.3);
        }

        .sidebar-header {
            padding: 24px;
            border-bottom: 1px solid #334155;
            background: linear-gradient(135deg, #1e293b 0%, #0f172a 100%);
        }

        .logo {
            display: flex;
            align-items: center;
            gap: 12px;
            margin-bottom: 24px;
        }

        .logo-icon {
            width: 48px;
            height: 48px;
            background: linear-gradient(135deg, var(--primary) 0%, var(--secondary) 100%);
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 24px;
        }

        .logo-text h1 {
            font-size: 20px;
            font-weight: 700;
            color: white;
            margin-bottom: 4px;
        }

        .logo-text p {
            font-size: 13px;
            color: #94a3b8;
        }

        /* Analytics Dashboard */
        .analytics-dashboard {
            background: rgba(255, 255, 255, 0.05);
            border-radius: 12px;
            padding: 16px;
            margin-top: 16px;
            border: 1px solid #334155;
        }

        .dashboard-title {
            font-size: 14px;
            font-weight: 600;
            color: #94a3b8;
            margin-bottom: 12px;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .analytics-grid {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 12px;
        }

        .analytic-card {
            background: rgba(255, 255, 255, 0.03);
            border-radius: 8px;
            padding: 12px;
            border: 1px solid #334155;
            transition: all 0.3s ease;
        }

            .analytic-card:hover {
                background: rgba(255, 255, 255, 0.07);
                transform: translateY(-2px);
            }

        .analytic-value {
            font-size: 24px;
            font-weight: 700;
            color: white;
            line-height: 1;
        }

        .analytic-label {
            font-size: 12px;
            color: #94a3b8;
            margin-top: 6px;
        }

        .analytic-trend {
            font-size: 11px;
            margin-top: 4px;
            display: flex;
            align-items: center;
            gap: 4px;
        }

        .trend-up {
            color: #10b981;
        }

        .trend-down {
            color: #ef4444;
        }

        /* Search */
        .search-container {
            padding: 20px 24px;
            border-bottom: 1px solid #334155;
            background: #1e293b;
        }

        .search-box {
            position: relative;
        }

        .search-input {
            width: 100%;
            padding: 14px 20px 14px 48px;
            background: #0f172a;
            border: 1px solid #334155;
            border-radius: 10px;
            font-size: 14px;
            color: white;
            transition: all 0.3s ease;
        }

            .search-input:focus {
                outline: none;
                border-color: var(--primary);
                background: #1e293b;
                box-shadow: 0 0 0 3px rgba(16, 185, 129, 0.15);
            }

        .search-icon {
            position: absolute;
            left: 18px;
            top: 50%;
            transform: translateY(-50%);
            color: #64748b;
        }

        /* Filters */
        .filters-section {
            padding: 20px 24px;
            border-bottom: 1px solid #334155;
            flex: 1;
            overflow-y: auto;
            background: #1e293b;
        }

        .filter-group {
            margin-bottom: 28px;
        }

        .filter-title {
            font-size: 14px;
            font-weight: 600;
            color: #e2e8f0;
            margin-bottom: 14px;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }

        .filter-clear {
            background: none;
            border: none;
            color: #64748b;
            font-size: 12px;
            cursor: pointer;
            transition: color 0.3s;
        }

            .filter-clear:hover {
                color: var(--primary);
            }

        .filter-tags {
            display: flex;
            flex-wrap: wrap;
            gap: 10px;
        }

        .filter-tag {
            padding: 10px 16px;
            background: #0f172a;
            border: 1px solid #334155;
            border-radius: 20px;
            font-size: 13px;
            font-weight: 500;
            color: #94a3b8;
            cursor: pointer;
            transition: all 0.3s ease;
            display: flex;
            align-items: center;
            gap: 8px;
        }

            .filter-tag:hover {
                background: #1e293b;
                border-color: #475569;
                transform: translateY(-2px);
            }

            .filter-tag.active {
                background: var(--primary);
                color: white;
                border-color: var(--primary);
                box-shadow: 0 4px 12px rgba(16, 185, 129, 0.3);
            }

        /* View Mode Selector */
        .view-selector {
            background: #0f172a;
            border: 1px solid #334155;
            border-radius: 10px;
            padding: 16px;
            margin-bottom: 24px;
        }

        .view-title {
            font-size: 14px;
            font-weight: 600;
            color: #e2e8f0;
            margin-bottom: 12px;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .view-options {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 10px;
        }

        .view-option {
            padding: 12px;
            background: #1e293b;
            border: 1px solid #334155;
            border-radius: 8px;
            font-size: 12px;
            font-weight: 500;
            color: #94a3b8;
            cursor: pointer;
            transition: all 0.3s ease;
            text-align: center;
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 6px;
        }

            .view-option:hover {
                background: #334155;
                border-color: #475569;
            }

            .view-option.active {
                background: var(--primary);
                color: white;
                border-color: var(--primary);
                box-shadow: 0 4px 12px rgba(16, 185, 129, 0.3);
            }

        .view-icon {
            font-size: 18px;
            margin-bottom: 4px;
        }

        /* Cities Grid */
        .cities-grid {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 12px;
        }

        .city-btn {
            padding: 12px;
            background: #0f172a;
            border: 1px solid #334155;
            border-radius: 8px;
            font-size: 13px;
            font-weight: 500;
            color: #94a3b8;
            cursor: pointer;
            transition: all 0.3s ease;
            text-align: center;
        }

            .city-btn:hover {
                background: #1e293b;
                border-color: #475569;
            }

            .city-btn.active {
                background: var(--primary);
                color: white;
                border-color: var(--primary);
            }

        /* Reports List */
        .reports-section {
            flex: 1;
            display: flex;
            flex-direction: column;
            background: #1e293b;
        }

        .reports-header {
            padding: 20px 24px;
            border-bottom: 1px solid #334155;
            display: flex;
            justify-content: space-between;
            align-items: center;
            background: #1e293b;
        }

            .reports-header h3 {
                font-size: 16px;
                font-weight: 600;
                color: white;
            }

        .reports-count {
            background: rgba(16, 185, 129, 0.1);
            padding: 6px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
            color: var(--primary);
        }

        .reports-list {
            flex: 1;
            overflow-y: auto;
            padding: 0 24px 24px;
            background: #1e293b;
        }

            .reports-list::-webkit-scrollbar {
                width: 8px;
            }

            .reports-list::-webkit-scrollbar-track {
                background: #0f172a;
                border-radius: 4px;
            }

            .reports-list::-webkit-scrollbar-thumb {
                background: #334155;
                border-radius: 4px;
            }

                .reports-list::-webkit-scrollbar-thumb:hover {
                    background: #475569;
                }

        .report-card {
            background: linear-gradient(135deg, #1e293b 0%, #0f172a 100%);
            border: 1px solid #334155;
            border-radius: 12px;
            padding: 20px;
            margin-bottom: 16px;
            cursor: pointer;
            transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
            position: relative;
            overflow: hidden;
        }

            .report-card::before {
                content: '';
                position: absolute;
                left: 0;
                top: 0;
                bottom: 0;
                width: 6px;
            }

            .report-card.critical::before {
                background: var(--zone-critical);
            }

            .report-card.high::before {
                background: var(--zone-high);
            }

            .report-card.medium::before {
                background: var(--zone-medium);
            }

            .report-card.low::before {
                background: var(--zone-low);
            }

            .report-card:hover {
                transform: translateY(-4px) scale(1.01);
                box-shadow: 0 20px 40px rgba(0, 0, 0, 0.4);
                border-color: #475569;
            }

        .report-header {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            margin-bottom: 16px;
        }

        .report-type {
            padding: 6px 12px;
            border-radius: 8px;
            font-size: 12px;
            font-weight: 700;
            color: white;
            display: inline-block;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.2);
        }

            .report-type.plastic {
                background: var(--plastic);
            }

            .report-type.organic {
                background: var(--organic);
            }

            .report-type.medical {
                background: var(--medical);
            }

            .report-type.hazardous {
                background: var(--hazardous);
            }

            .report-type.construction {
                background: var(--construction);
            }

            .report-type.electronics {
                background: var(--electronics);
            }

            .report-type.mixed {
                background: var(--mixed);
            }

        .report-severity {
            padding: 6px 12px;
            border-radius: 8px;
            font-size: 12px;
            font-weight: 700;
            color: white;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.2);
        }

        .severity-critical {
            background: var(--zone-critical);
        }

        .severity-high {
            background: var(--zone-high);
        }

        .severity-medium {
            background: var(--zone-medium);
        }

        .severity-low {
            background: var(--zone-low);
        }

        .report-title {
            font-size: 16px;
            font-weight: 600;
            color: white;
            margin-bottom: 12px;
            line-height: 1.4;
        }

        .report-details {
            font-size: 13px;
            color: #94a3b8;
            margin-bottom: 16px;
        }

            .report-details div {
                display: flex;
                align-items: center;
                gap: 10px;
                margin-bottom: 8px;
            }

            .report-details i {
                width: 20px;
                color: #64748b;
            }

        .report-footer {
            display: flex;
            justify-content: space-between;
            align-items: center;
            font-size: 12px;
            padding-top: 16px;
            border-top: 1px solid #334155;
        }

        .reporter {
            color: #64748b;
            display: flex;
            align-items: center;
            gap: 6px;
        }

        .report-status {
            padding: 6px 12px;
            border-radius: 20px;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .status-new {
            background: rgba(239, 68, 68, 0.15);
            color: var(--status-new);
        }

        .status-assigned {
            background: rgba(245, 158, 11, 0.15);
            color: var(--status-assigned);
        }

        .status-inprogress {
            background: rgba(59, 130, 246, 0.15);
            color: var(--status-inprogress);
        }

        .status-collected {
            background: rgba(16, 185, 129, 0.15);
            color: var(--status-collected);
        }

        /* ===== MAIN CONTENT - RIGHT ===== */
        .main-content {
            flex: 1;
            display: flex;
            flex-direction: column;
            min-height: 100vh;
            background: #0f172a;
        }

        /* Top Bar */
        .top-bar {
            background: linear-gradient(135deg, #1e293b 0%, #0f172a 100%);
            padding: 20px 32px;
            border-bottom: 1px solid #334155;
            display: flex;
            justify-content: space-between;
            align-items: center;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.3);
        }

        .view-mode {
            display: flex;
            gap: 12px;
        }

        .mode-btn {
            padding: 12px 24px;
            background: #1e293b;
            border: 1px solid #334155;
            border-radius: 10px;
            font-size: 14px;
            font-weight: 600;
            color: #94a3b8;
            cursor: pointer;
            transition: all 0.3s ease;
            display: flex;
            align-items: center;
            gap: 10px;
        }

            .mode-btn:hover {
                background: #334155;
                border-color: #475569;
            }

            .mode-btn.active {
                background: var(--primary);
                color: white;
                border-color: var(--primary);
                box-shadow: 0 4px 20px rgba(16, 185, 129, 0.4);
            }

        .user-actions {
            display: flex;
            gap: 16px;
            align-items: center;
        }

        .action-btn {
            padding: 12px 24px;
            border-radius: 10px;
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
            display: flex;
            align-items: center;
            gap: 10px;
            transition: all 0.3s ease;
            border: none;
        }

        .btn-primary {
            background: linear-gradient(135deg, var(--primary) 0%, var(--secondary) 100%);
            color: white;
            box-shadow: 0 4px 20px rgba(16, 185, 129, 0.3);
        }

            .btn-primary:hover {
                transform: translateY(-2px);
                box-shadow: 0 8px 30px rgba(16, 185, 129, 0.4);
            }

        .btn-secondary {
            background: #1e293b;
            color: #94a3b8;
            border: 1px solid #334155;
        }

            .btn-secondary:hover {
                background: #334155;
                border-color: #475569;
                transform: translateY(-2px);
            }

        /* Map Container */
        .map-container {
            flex: 1;
            position: relative;
            background: #0f172a;
        }

        #map {
            width: 100%;
            height: 100%;
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
        }

        /* Zone Overlay Styles */
        .zone-critical {
            background: rgba(220, 38, 38, 0.2);
            border: 2px solid var(--zone-critical);
        }

        .zone-high {
            background: rgba(234, 88, 12, 0.2);
            border: 2px solid var(--zone-high);
        }

        .zone-medium {
            background: rgba(245, 158, 11, 0.2);
            border: 2px solid var(--zone-medium);
        }

        .zone-low {
            background: rgba(16, 185, 129, 0.2);
            border: 2px solid var(--zone-low);
        }

        .zone-clean {
            background: rgba(5, 150, 105, 0.2);
            border: 2px solid var(--zone-clean);
        }

        /* Map Controls */
        .map-controls {
            position: absolute;
            top: 24px;
            right: 24px;
            z-index: 1000;
            display: flex;
            flex-direction: column;
            gap: 16px;
        }

        .control-group {
            background: rgba(30, 41, 59, 0.95);
            backdrop-filter: blur(10px);
            border-radius: 12px;
            padding: 20px;
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.4);
            border: 1px solid #334155;
            min-width: 240px;
        }

        .control-title {
            font-size: 14px;
            font-weight: 600;
            color: white;
            margin-bottom: 16px;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .control-buttons {
            display: flex;
            flex-direction: column;
            gap: 10px;
        }

        .control-btn {
            padding: 12px 16px;
            background: #0f172a;
            border: 1px solid #334155;
            border-radius: 8px;
            font-size: 13px;
            font-weight: 500;
            color: #94a3b8;
            cursor: pointer;
            transition: all 0.3s ease;
            display: flex;
            align-items: center;
            gap: 10px;
        }

            .control-btn:hover {
                background: #1e293b;
                border-color: #475569;
            }

            .control-btn.active {
                background: var(--primary);
                color: white;
                border-color: var(--primary);
                box-shadow: 0 4px 12px rgba(16, 185, 129, 0.3);
            }

        /* Analytics Control Panel */
        .analytics-controls {
            background: rgba(30, 41, 59, 0.95);
            backdrop-filter: blur(10px);
            border-radius: 12px;
            padding: 20px;
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.4);
            border: 1px solid #334155;
            min-width: 280px;
            display: none;
        }

            .analytics-controls.active {
                display: block;
            }

        .analytics-slider {
            margin: 20px 0;
        }

        .slider-label {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 8px;
            color: #94a3b8;
            font-size: 13px;
        }

        .slider {
            width: 100%;
            height: 8px;
            -webkit-appearance: none;
            background: linear-gradient(to right, var(--heat-green), var(--heat-yellow), var(--heat-orange), var(--heat-red));
            border-radius: 4px;
            outline: none;
        }

            .slider::-webkit-slider-thumb {
                -webkit-appearance: none;
                width: 20px;
                height: 20px;
                background: white;
                border-radius: 50%;
                cursor: pointer;
                box-shadow: 0 2px 8px rgba(0, 0, 0, 0.3);
            }

        /* Map Legend */
        .map-legend {
            position: absolute;
            bottom: 24px;
            left: 24px;
            z-index: 1000;
            background: rgba(30, 41, 59, 0.95);
            backdrop-filter: blur(10px);
            border-radius: 12px;
            padding: 20px;
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.4);
            border: 1px solid #334155;
            width: 320px;
            max-height: 400px;
            overflow-y: auto;
        }

        .legend-section {
            margin-bottom: 20px;
        }

            .legend-section:last-child {
                margin-bottom: 0;
            }

        .legend-title {
            font-size: 14px;
            font-weight: 600;
            color: white;
            margin-bottom: 12px;
            display: flex;
            align-items: center;
            gap: 10px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .legend-items {
            display: flex;
            flex-direction: column;
            gap: 12px;
        }

        .legend-item {
            display: flex;
            align-items: center;
            gap: 16px;
            padding: 8px 12px;
            background: rgba(255, 255, 255, 0.03);
            border-radius: 8px;
            border: 1px solid #334155;
            transition: all 0.3s ease;
        }

            .legend-item:hover {
                background: rgba(255, 255, 255, 0.07);
                border-color: #475569;
            }

        .legend-color {
            width: 24px;
            height: 24px;
            border-radius: 6px;
            flex-shrink: 0;
            border: 2px solid rgba(255, 255, 255, 0.2);
        }

        .legend-text {
            font-size: 13px;
            color: #94a3b8;
            flex: 1;
        }

            .legend-text strong {
                color: white;
                font-weight: 600;
            }

        .legend-sublabel {
            font-size: 11px;
            color: #64748b;
            margin-left: 4px;
        }

        /* Loading Overlay */
        .loading-overlay {
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: rgba(15, 23, 42, 0.95);
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            z-index: 9999;
            backdrop-filter: blur(10px);
        }

        .loading-spinner {
            width: 60px;
            height: 60px;
            border: 4px solid rgba(255, 255, 255, 0.1);
            border-top-color: var(--primary);
            border-radius: 50%;
            animation: spin 1s linear infinite;
            margin-bottom: 20px;
        }

        .loading-text {
            color: #94a3b8;
            font-size: 14px;
            font-weight: 500;
        }

        @keyframes spin {
            to {
                transform: rotate(360deg);
            }
        }

        /* Modal */
        .modal {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: rgba(0, 0, 0, 0.8);
            z-index: 10000;
            align-items: center;
            justify-content: center;
            padding: 20px;
            backdrop-filter: blur(10px);
        }

        .modal-content {
            background: linear-gradient(135deg, #1e293b 0%, #0f172a 100%);
            border-radius: 20px;
            width: 100%;
            max-width: 900px;
            max-height: 90vh;
            overflow-y: auto;
            position: relative;
            border: 1px solid #334155;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.6);
        }

        .modal-header {
            padding: 32px;
            border-bottom: 1px solid #334155;
            position: sticky;
            top: 0;
            background: linear-gradient(135deg, #1e293b 0%, #0f172a 100%);
            z-index: 10;
            border-radius: 20px 20px 0 0;
        }

        .modal-body {
            padding: 32px;
        }

        .modal-close {
            position: absolute;
            top: 28px;
            right: 28px;
            background: rgba(255, 255, 255, 0.1);
            border: 1px solid #334155;
            color: #94a3b8;
            width: 44px;
            height: 44px;
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 20px;
            cursor: pointer;
            transition: all 0.3s ease;
        }

            .modal-close:hover {
                background: rgba(239, 68, 68, 0.2);
                color: #ef4444;
                border-color: #ef4444;
                transform: rotate(90deg);
            }

        /* Responsive */
        @media (max-width: 1400px) {
            .sidebar {
                width: 340px;
            }

            .analytics-grid {
                grid-template-columns: 1fr;
            }
        }

        @media (max-width: 1200px) {
            .dashboard-container {
                flex-direction: column;
            }

            .sidebar {
                width: 100%;
                height: 500px;
                border-right: none;
                border-bottom: 1px solid #334155;
            }

            .top-bar {
                flex-direction: column;
                gap: 20px;
                align-items: stretch;
                padding: 20px;
            }

            .view-mode {
                justify-content: center;
            }

            .user-actions {
                justify-content: center;
            }
        }

        @media (max-width: 768px) {
            .view-options {
                grid-template-columns: repeat(2, 1fr);
            }

            .cities-grid {
                grid-template-columns: 1fr;
            }

            .map-controls {
                position: relative;
                top: auto;
                right: auto;
                padding: 20px;
                flex-direction: row;
                flex-wrap: wrap;
                gap: 12px;
            }

            .control-group {
                flex: 1;
                min-width: 200px;
            }

            .map-legend {
                position: relative;
                bottom: auto;
                left: auto;
                width: calc(100% - 40px);
                margin: 20px;
                max-height: none;
            }

            .modal-header,
            .modal-body {
                padding: 24px;
            }
        }

        @media (max-width: 480px) {
            .sidebar-header {
                padding: 20px;
            }

            .search-container,
            .filters-section {
                padding: 16px;
            }

            .filter-tags {
                flex-direction: column;
            }

            .filter-tag {
                width: 100%;
                justify-content: center;
            }

            .view-mode {
                flex-direction: column;
            }

            .mode-btn {
                width: 100%;
                justify-content: center;
            }

            .user-actions {
                flex-direction: column;
            }

            .action-btn {
                width: 100%;
                justify-content: center;
            }
        }

        /* Animations */
        .fade-in {
            animation: fadeIn 0.4s ease;
        }

        @keyframes fadeIn {
            from {
                opacity: 0;
                transform: translateY(20px);
            }

            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        .slide-in {
            animation: slideIn 0.5s cubic-bezier(0.4, 0, 0.2, 1);
        }

        @keyframes slideIn {
            from {
                transform: translateX(100px);
                opacity: 0;
            }

            to {
                transform: translateX(0);
                opacity: 1;
            }
        }

        .pulse {
            animation: pulse 2s infinite;
        }

        @keyframes pulse {
            0% {
                transform: scale(1);
                opacity: 1;
            }

            50% {
                transform: scale(1.05);
                opacity: 0.8;
            }

            100% {
                transform: scale(1);
                opacity: 1;
            }
        }

        .glow {
            animation: glow 2s infinite alternate;
        }

        @keyframes glow {
            from {
                box-shadow: 0 0 10px rgba(16, 185, 129, 0.5);
            }

            to {
                box-shadow: 0 0 20px rgba(16, 185, 129, 0.8);
            }
        }

        /* Custom Leaflet Styles */
        .leaflet-control-zoom {
            border: none !important;
            background: rgba(30, 41, 59, 0.95) !important;
            backdrop-filter: blur(10px);
            border-radius: 10px !important;
            overflow: hidden;
            border: 1px solid #334155 !important;
        }

            .leaflet-control-zoom a {
                background: transparent !important;
                color: #94a3b8 !important;
                border: none !important;
                border-radius: 0 !important;
            }

                .leaflet-control-zoom a:hover {
                    background: #334155 !important;
                    color: white !important;
                }

        .leaflet-control-zoom-in {
            border-bottom: 1px solid #334155 !important;
        }

        .leaflet-popup-content-wrapper {
            background: #1e293b !important;
            color: white !important;
            border: 1px solid #334155 !important;
            border-radius: 12px !important;
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.4) !important;
            backdrop-filter: blur(10px);
        }

        .leaflet-popup-tip {
            background: #1e293b !important;
            border: 1px solid #334155 !important;
        }

        .leaflet-popup-content {
            font-family: 'Inter', sans-serif !important;
            margin: 20px !important;
            font-size: 14px !important;
            min-width: 280px !important;
        }

        .leaflet-popup-close-button {
            color: #94a3b8 !important;
            font-size: 20px !important;
            padding: 8px !important;
            transition: all 0.3s ease !important;
        }

            .leaflet-popup-close-button:hover {
                color: #ef4444 !important;
                background: rgba(239, 68, 68, 0.1) !important;
                border-radius: 6px;
            }
    </style>
    <br />
    <br />
    <br />
    <!-- DASHBOARD CONTAINER -->
    <div class="dashboard-container">
        <!-- LEFT SIDEBAR -->
        <div class="sidebar">
            <!-- Header -->
            <div class="sidebar-header">
                <div class="logo">
                    <div class="logo-icon">
                        <i class="fas fa-analytics"></i>
                    </div>
                    <div class="logo-text">
                        <h1>Waste Intelligence Analytics</h1>
                        <p>Somaliland • Real-time Monitoring & Analysis</p>
                    </div>
                </div>

                <!-- Analytics Dashboard -->
                <div class="analytics-dashboard">
                    <div class="dashboard-title">
                        <i class="fas fa-chart-line"></i>Analytics Dashboard
                    </div>
                    <div class="analytics-grid">
                        <div class="analytic-card">
                            <div class="analytic-value" id="totalReports">0</div>
                            <div class="analytic-label">Total Reports</div>
                            <div class="analytic-trend trend-up">
                                <i class="fas fa-arrow-up"></i>12% this week
                            </div>
                        </div>
                        <div class="analytic-card">
                            <div class="analytic-value" id="criticalZones">0</div>
                            <div class="analytic-label">Critical Zones</div>
                            <div class="analytic-trend trend-up">
                                <i class="fas fa-arrow-up"></i>8% increase
                            </div>
                        </div>
                        <div class="analytic-card">
                            <div class="analytic-value" id="responseRate">0%</div>
                            <div class="analytic-label">Response Rate</div>
                            <div class="analytic-trend trend-down">
                                <i class="fas fa-arrow-down"></i>3% decrease
                            </div>
                        </div>
                        <div class="analytic-card">
                            <div class="analytic-value" id="coverage">0%</div>
                            <div class="analytic-label">Area Coverage</div>
                            <div class="analytic-trend trend-up">
                                <i class="fas fa-arrow-up"></i>15% increase
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Search -->
            <div class="search-container">
                <div class="search-box">
                    <input type="text" class="search-input" id="searchInput" placeholder="Search reports, zones, or locations...">
                    <i class="fas fa-search search-icon"></i>
                </div>
            </div>

            <!-- Filters & View Selector -->
            <div class="filters-section">
                <!-- View Mode Selector -->
                <div class="view-selector">
                    <div class="view-title">
                        <i class="fas fa-eye"></i>View Mode
                    </div>
                    <div class="view-options">
                        <div class="view-option active" onclick="switchMapMode('standard')" data-mode="standard">
                            <i class="fas fa-map-marker-alt view-icon"></i>
                            Standard
                        </div>
                        <div class="view-option" onclick="switchMapMode('heatmap')" data-mode="heatmap">
                            <i class="fas fa-fire view-icon"></i>
                            Heatmap
                        </div>
                        <div class="view-option" onclick="switchMapMode('zones')" data-mode="zones">
                            <i class="fas fa-layer-group view-icon"></i>
                            Zones
                        </div>
                        <div class="view-option" onclick="switchMapMode('predictive')" data-mode="predictive">
                            <i class="fas fa-crystal-ball view-icon"></i>
                            Predictive
                        </div>
                        <div class="view-option" onclick="switchMapMode('analytics')" data-mode="analytics">
                            <i class="fas fa-chart-bar view-icon"></i>
                            Analytics
                        </div>
                        <div class="view-option" onclick="switchMapMode('satellite')" data-mode="satellite">
                            <i class="fas fa-satellite view-icon"></i>
                            Satellite
                        </div>
                    </div>
                </div>

                <!-- Waste Type Filter -->
                <div class="filter-group">
                    <div class="filter-title">
                        <span>Waste Type Analysis</span>
                        <button class="filter-clear" onclick="clearFilter('type')">Clear</button>
                    </div>
                    <div class="filter-tags">
                        <div class="filter-tag active" data-filter="type" data-value="all">
                            <i class="fas fa-chart-pie"></i>All Types
                        </div>
                        <div class="filter-tag" data-filter="type" data-value="plastic">
                            <i class="fas fa-bottle-water"></i>Plastic
                        </div>
                        <div class="filter-tag" data-filter="type" data-value="organic">
                            <i class="fas fa-leaf"></i>Organic
                        </div>
                        <div class="filter-tag" data-filter="type" data-value="medical">
                            <i class="fas fa-biohazard"></i>Medical
                        </div>
                        <div class="filter-tag" data-filter="type" data-value="construction">
                            <i class="fas fa-hard-hat"></i>Construction
                        </div>
                    </div>
                </div>

                <!-- Severity Zones -->
                <div class="filter-group">
                    <div class="filter-title">
                        <span>Severity Zones</span>
                        <button class="filter-clear" onclick="clearFilter('severity')">Clear</button>
                    </div>
                    <div class="filter-tags">
                        <div class="filter-tag active" data-filter="severity" data-value="all">
                            <i class="fas fa-globe"></i>All Zones
                        </div>
                        <div class="filter-tag" data-filter="severity" data-value="critical">
                            <i class="fas fa-exclamation-triangle" style="color: var(--zone-critical);"></i>Critical
                        </div>
                        <div class="filter-tag" data-filter="severity" data-value="high">
                            <i class="fas fa-exclamation" style="color: var(--zone-high);"></i>High Risk
                        </div>
                        <div class="filter-tag" data-filter="severity" data-value="medium">
                            <i class="fas fa-minus-circle" style="color: var(--zone-medium);"></i>Medium
                        </div>
                        <div class="filter-tag" data-filter="severity" data-value="low">
                            <i class="fas fa-check-circle" style="color: var(--zone-low);"></i>Low Risk
                        </div>
                    </div>
                </div>

                <!-- Cities -->
                <div class="filter-group">
                    <div class="filter-title">
                        <span>Cities & Regions</span>
                        <button class="filter-clear" onclick="clearFilter('city')">Clear</button>
                    </div>
                    <div class="cities-grid">
                        <div class="city-btn active" data-filter="city" data-value="all">All Regions</div>
                        <div class="city-btn" data-filter="city" data-value="hargeisa">Hargeisa</div>
                        <div class="city-btn" data-filter="city" data-value="berbera">Berbera</div>
                        <div class="city-btn" data-filter="city" data-value="burao">Burao</div>
                        <div class="city-btn" data-filter="city" data-value="borama">Borama</div>
                        <div class="city-btn" data-filter="city" data-value="erigavo">Erigavo</div>
                    </div>
                </div>
            </div>

            <!-- Reports List -->
            <div class="reports-section">
                <div class="reports-header">
                    <h3>Analytical Reports</h3>
                    <span class="reports-count" id="reportsCount">0 reports</span>
                </div>
                <div class="reports-list" id="reportsList">
                    <!-- Reports will be loaded here -->
                </div>
            </div>
        </div>

        <!-- MAIN CONTENT -->
        <div class="main-content">
            <!-- Top Bar -->
            <div class="top-bar">
                <div class="view-mode">
                    <button class="mode-btn active" onclick="switchViewType('realtime')">
                        <i class="fas fa-bolt"></i>Real-time
                    </button>
                    <button class="mode-btn" onclick="switchViewType('historical')">
                        <i class="fas fa-history"></i>Historical
                    </button>
                    <button class="mode-btn" onclick="switchViewType('predictive')">
                        <i class="fas fa-robot"></i>Predictive AI
                    </button>
                    <button class="mode-btn" onclick="switchViewType('comparison')">
                        <i class="fas fa-exchange-alt"></i>Compare
                    </button>
                </div>

                <div class="user-actions">
                    <button class="action-btn btn-secondary" onclick="refreshData()">
                        <i class="fas fa-sync-alt"></i>Refresh Analytics
                    </button>
                    <button class="action-btn btn-primary" onclick="exportAnalytics()">
                        <i class="fas fa-download"></i>Export Data
                    </button>
                </div>
            </div>

            <!-- Map Container -->
            <div class="map-container">
                <div class="loading-overlay" id="loadingOverlay">
                    <div class="loading-spinner"></div>
                    <div class="loading-text">Loading Analytical Data...</div>
                </div>
                <div id="map"></div>

                <!-- Map Controls -->
                <div class="map-controls">
                    <div class="control-group">
                        <div class="control-title">
                            <i class="fas fa-layer-group"></i>Map Layers
                        </div>
                        <div class="control-buttons">
                            <button class="control-btn active" onclick="toggleLayer('reports')">
                                <i class="fas fa-map-marker-alt"></i>Reports
                            </button>
                            <button class="control-btn" onclick="toggleLayer('heatmap')">
                                <i class="fas fa-fire"></i>Heatmap
                            </button>
                            <button class="control-btn" onclick="toggleLayer('zones')">
                                <i class="fas fa-draw-polygon"></i>Risk Zones
                            </button>
                            <button class="control-btn" onclick="toggleLayer('predictions')">
                                <i class="fas fa-robot"></i>Predictions
                            </button>
                        </div>
                    </div>

                    <div class="analytics-controls" id="analyticsControls">
                        <div class="control-title">
                            <i class="fas fa-sliders-h"></i>Analytics Settings
                        </div>
                        <div class="analytics-slider">
                            <div class="slider-label">
                                <span>Risk Sensitivity</span>
                                <span id="sensitivityValue">70%</span>
                            </div>
                            <input type="range" min="1" max="100" value="70" class="slider" id="riskSensitivity" oninput="updateSensitivity(this.value)">
                        </div>
                        <div class="analytics-slider">
                            <div class="slider-label">
                                <span>Time Range</span>
                                <span id="timeRangeValue">30 days</span>
                            </div>
                            <input type="range" min="1" max="90" value="30" class="slider" id="timeRange" oninput="updateTimeRange(this.value)">
                        </div>
                    </div>
                </div>

                <!-- Map Legend -->
                <div class="map-legend">
                    <div class="legend-section">
                        <div class="legend-title">
                            <i class="fas fa-exclamation-triangle"></i>Risk Zones
                        </div>
                        <div class="legend-items">
                            <div class="legend-item">
                                <div class="legend-color" style="background: var(--zone-critical);"></div>
                                <div class="legend-text">
                                    <strong>Critical Zone</strong>
                                    <span class="legend-sublabel">• Emergency response needed</span>
                                </div>
                            </div>
                            <div class="legend-item">
                                <div class="legend-color" style="background: var(--zone-high);"></div>
                                <div class="legend-text">
                                    <strong>High Risk Zone</strong>
                                    <span class="legend-sublabel">• 24-hour response required</span>
                                </div>
                            </div>
                            <div class="legend-item">
                                <div class="legend-color" style="background: var(--zone-medium);"></div>
                                <div class="legend-text">
                                    <strong>Medium Risk Zone</strong>
                                    <span class="legend-sublabel">• 48-hour response window</span>
                                </div>
                            </div>
                            <div class="legend-item">
                                <div class="legend-color" style="background: var(--zone-low);"></div>
                                <div class="legend-text">
                                    <strong>Low Risk Zone</strong>
                                    <span class="legend-sublabel">• Weekly cleanup schedule</span>
                                </div>
                            </div>
                            <div class="legend-item">
                                <div class="legend-color" style="background: var(--zone-clean);"></div>
                                <div class="legend-text">
                                    <strong>Clean Zone</strong>
                                    <span class="legend-sublabel">• No active issues</span>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="legend-section">
                        <div class="legend-title">
                            <i class="fas fa-chart-line"></i>Analytics
                        </div>
                        <div class="legend-items">
                            <div class="legend-item">
                                <div class="legend-color" style="background: linear-gradient(to right, var(--heat-red), var(--heat-orange), var(--heat-yellow), var(--heat-green));"></div>
                                <div class="legend-text">
                                    <strong>Heatmap Intensity</strong>
                                    <span class="legend-sublabel">• Red = High concentration</span>
                                </div>
                            </div>
                            <div class="legend-item">
                                <div class="legend-color" style="background: repeating-linear-gradient(45deg, #3b82f6, #3b82f6 10px, #60a5fa 10px, #60a5fa 20px);"></div>
                                <div class="legend-text">
                                    <strong>Predictive Zones</strong>
                                    <span class="legend-sublabel">• AI-predicted hotspots</span>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Report Modal -->
    <div class="modal" id="reportModal">
        <div class="modal-content">
            <div class="modal-header">
                <h2 id="modalTitle">Analytical Report Details</h2>
                <button class="modal-close" onclick="closeModal()">&times;</button>
            </div>
            <div class="modal-body" id="modalBody">
                <!-- Content will be loaded here -->
            </div>
        </div>
    </div>

    <!-- JavaScript -->
    <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
    <script src="https://unpkg.com/leaflet.markercluster@1.5.3/dist/leaflet.markercluster.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/leaflet.heat@0.2.0/dist/leaflet-heat.min.js"></script>

    <script>
        // ========== GLOBAL VARIABLES ==========
        let map;
        let markers = L.markerClusterGroup({
            maxClusterRadius: 50,
            spiderfyOnMaxZoom: true,
            showCoverageOnHover: false,
            zoomToBoundsOnClick: true,
            disableClusteringAtZoom: 16,
            iconCreateFunction: function (cluster) {
                const count = cluster.getChildCount();
                const severity = getClusterSeverity(cluster);

                const colors = {
                    critical: '#dc2626',
                    high: '#ea580c',
                    medium: '#f59e0b',
                    low: '#10b981'
                };

                return L.divIcon({
                    html: `<div style="
                    width: 40px;
                    height: 40px;
                    background: ${colors[severity]};
                    border: 3px solid white;
                    border-radius: 50%;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    color: white;
                    font-weight: bold;
                    font-size: 14px;
                    box-shadow: 0 4px 12px rgba(0,0,0,0.3);
                ">${count}</div>`,
                    className: 'cluster-marker',
                    iconSize: [40, 40]
                });
            }
        });

        let heatmapLayer;
        let zoneLayers = [];
        let predictiveLayers = [];
        let allReports = [];
        let filteredReports = [];
        let currentMarkers = [];
        let currentMapMode = 'standard';
        let activeFilters = {
            type: 'all',
            severity: 'all',
            city: 'all'
        };

        // Analytical zones data (red/green zones)
        const analyticalZones = {
            hargeisa: [
                {
                    type: 'critical',
                    coordinates: [[9.55, 44.06], [9.56, 44.065], [9.555, 44.07], [9.55, 44.066]],
                    description: 'Market area - High plastic waste concentration'
                },
                {
                    type: 'high',
                    coordinates: [[9.56, 44.065], [9.565, 44.07], [9.57, 44.068], [9.565, 44.063]],
                    description: 'Commercial district - Mixed waste accumulation'
                },
                {
                    type: 'medium',
                    coordinates: [[9.57, 44.07], [9.575, 44.075], [9.58, 44.072], [9.575, 44.067]],
                    description: 'Residential area - Regular waste collection needed'
                },
                {
                    type: 'low',
                    coordinates: [[9.58, 44.075], [9.585, 44.08], [9.59, 44.078], [9.585, 44.073]],
                    description: 'Suburban area - Controlled waste management'
                },
                {
                    type: 'clean',
                    coordinates: [[9.59, 44.08], [9.595, 44.085], [9.6, 44.083], [9.595, 44.078]],
                    description: 'Industrial zone - Efficient waste processing'
                }
            ],
            berbera: [
                {
                    type: 'critical',
                    coordinates: [[10.43, 45.01], [10.435, 45.015], [10.44, 45.013], [10.435, 45.008]],
                    description: 'Port area - Hazardous waste accumulation'
                },
                {
                    type: 'high',
                    coordinates: [[10.435, 45.015], [10.44, 45.02], [10.445, 45.018], [10.44, 45.013]],
                    description: 'Fish market - Organic waste hotspot'
                }
            ],
            burao: [
                {
                    type: 'high',
                    coordinates: [[9.515, 45.53], [9.525, 45.535], [9.53, 45.538], [9.525, 45.533]],
                    description: 'City center - Mixed waste accumulation'
                },
                {
                    type: 'medium',
                    coordinates: [[9.53, 45.535], [9.535, 45.54], [9.54, 45.538], [9.535, 45.533]],
                    description: 'Residential zone - Regular collection needed'
                }
            ],
            borama: [
                {
                    type: 'medium',
                    coordinates: [[9.93, 43.18], [9.935, 43.185], [9.94, 43.183], [9.935, 43.178]],
                    description: 'University area - Educational zone waste'
                },
                {
                    type: 'low',
                    coordinates: [[9.94, 43.185], [9.945, 43.19], [9.95, 43.188], [9.945, 43.183]],
                    description: 'Suburban area - Well managed'
                }
            ]
        };

        // Heatmap data points with intensity values (0-1)
        const heatmapData = [
            [9.5587, 44.0654, 0.9],  // Kaah Market - high concentration
            [9.5623, 44.0718, 0.8],  // Hospital area
            [9.5534, 44.0589, 0.7],  // Main road
            [9.5678, 44.0623, 0.6],  // Livestock market
            [9.5723, 44.0689, 0.5],  // Residential area
            [10.4315, 45.0137, 0.85], // Berbera beach
            [10.4362, 45.0168, 0.9],  // Fish market
            [10.4389, 45.0192, 0.6],  // Port area
            [9.9364, 43.1842, 0.5],  // University area
            [9.5218, 45.5349, 0.8],  // Burao hospital
            [9.5245, 45.5372, 0.7],  // Burao market
            [8.4767, 47.3601, 0.7],  // Border market
            [10.6185, 47.3689, 0.4],  // Mountain area
            [9.5789, 44.0621, 0.5],  // Industrial zone
            [9.5456, 44.0723, 0.6]   // New Hargeisa
        ];

        // Predictive hotspots
        const predictiveHotspots = [
            {
                location: [9.56, 44.068],
                radius: 500,
                confidence: 0.85,
                description: 'Predicted plastic waste accumulation in 48 hours based on current trends and weather patterns'
            },
            {
                location: [10.433, 45.015],
                radius: 300,
                confidence: 0.9,
                description: 'High probability of organic waste overflow at fish market during peak hours'
            },
            {
                location: [9.525, 45.537],
                radius: 400,
                confidence: 0.75,
                description: 'Potential medical waste disposal issue near hospital area'
            },
            {
                location: [9.578, 44.063],
                radius: 600,
                confidence: 0.65,
                description: 'Industrial waste accumulation predicted in next 72 hours'
            },
            {
                location: [9.538, 44.073],
                radius: 350,
                confidence: 0.8,
                description: 'Residential area likely to require additional waste collection'
            }
        ];

        // ========== INITIALIZATION ==========
        function initApp() {
            initMap();
            loadReports();
            setupEventListeners();
            updateAnalytics();
        }

        function initMap() {
            document.getElementById('loadingOverlay').style.display = 'none';

            map = L.map('map', {
                center: [9.5616, 44.0650],
                zoom: 12,
                minZoom: 8,
                maxZoom: 18,
                zoomControl: false,
                attributionControl: false,
                preferCanvas: true
            });

            // Add custom zoom control
            L.control.zoom({ position: 'topright' }).addTo(map);

            // Initialize base layers
            initializeBaseLayers();

            // Add default tile layer
            map.baseLayers.standard.addTo(map);
            map.currentBaseLayer = 'standard';

            // Add marker cluster group
            map.addLayer(markers);

            // Fit bounds to Somaliland
            const somalilandBounds = [[8.0, 42.5], [11.5, 49.5]];
            map.fitBounds(somalilandBounds);

            // Load initial map mode
            switchMapMode('standard');
        }

        function initializeBaseLayers() {
            // Store base layers for different modes
            map.baseLayers = {
                standard: L.tileLayer('https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png', {
                    attribution: '© OpenStreetMap, © CartoDB',
                    maxZoom: 19,
                    className: 'standard-layer'
                }),
                heatmap: L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
                    attribution: '© OpenStreetMap',
                    maxZoom: 19,
                    className: 'heatmap-layer'
                }),
                zones: L.tileLayer('https://{s}.tile.opentopomap.org/{z}/{x}/{y}.png', {
                    maxZoom: 17,
                    attribution: '© OpenTopoMap',
                    className: 'zones-layer'
                }),
                predictive: L.tileLayer('https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}', {
                    attribution: '© Esri',
                    maxZoom: 18,
                    className: 'predictive-layer'
                }),
                analytics: L.tileLayer('https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png', {
                    attribution: '© OpenStreetMap, © CartoDB',
                    maxZoom: 19,
                    className: 'analytics-layer'
                }),
                satellite: L.tileLayer('https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}', {
                    attribution: '© Esri',
                    maxZoom: 18,
                    className: 'satellite-layer'
                })
            };
        }

        function getClusterSeverity(cluster) {
            const markers = cluster.getAllChildMarkers();
            if (!markers || markers.length === 0) return 'low';

            const severities = markers.map(m => {
                // Check if report exists and has severity
                if (m.report && m.report.severity) {
                    return m.report.severity;
                }
                // Try alternative property access
                if (m.options && m.options.report && m.options.report.severity) {
                    return m.options.report.severity;
                }
                return 'low';
            });

            if (severities.includes('critical')) return 'critical';
            if (severities.includes('high')) return 'high';
            if (severities.includes('medium')) return 'medium';
            return 'low';
        }

        // ========== MAP MODE SWITCHING ==========
        function switchMapMode(mode) {
            currentMapMode = mode;

            // Update UI
            document.querySelectorAll('.view-option').forEach(opt => opt.classList.remove('active'));
            const selectedOption = document.querySelector(`.view-option[data-mode="${mode}"]`);
            if (selectedOption) {
                selectedOption.classList.add('active');
            }

            // Show/hide analytics controls
            const analyticsControls = document.getElementById('analyticsControls');
            if (mode === 'analytics' || mode === 'heatmap') {
                analyticsControls.style.display = 'block';
                analyticsControls.classList.add('active');
            } else {
                analyticsControls.style.display = 'none';
                analyticsControls.classList.remove('active');
            }

            // Clear existing layers
            clearMapLayers();

            // Switch base layer
            switchBaseLayer(mode);

            // Load appropriate map mode
            switch (mode) {
                case 'standard':
                    loadStandardView();
                    break;
                case 'heatmap':
                    loadHeatmapView();
                    break;
                case 'zones':
                    loadZoneView();
                    break;
                case 'predictive':
                    loadPredictiveView();
                    break;
                case 'analytics':
                    loadAnalyticsView();
                    break;
                case 'satellite':
                    loadSatelliteView();
                    break;
            }

            // Update reports list for current mode
            updateReportsList();
        }

        function switchBaseLayer(mode) {
            // Remove current base layer
            if (map.currentBaseLayer && map.baseLayers[map.currentBaseLayer]) {
                map.removeLayer(map.baseLayers[map.currentBaseLayer]);
            }

            // Add new base layer
            const layer = map.baseLayers[mode] || map.baseLayers.standard;
            if (layer) {
                layer.addTo(map);
                map.currentBaseLayer = mode;
            }
        }

        function clearMapLayers() {
            // Clear heatmap
            if (heatmapLayer) {
                map.removeLayer(heatmapLayer);
                heatmapLayer = null;
            }

            // Clear zones
            zoneLayers.forEach(layer => {
                if (layer && map.hasLayer(layer)) {
                    map.removeLayer(layer);
                }
            });
            zoneLayers = [];

            // Clear predictive layers
            predictiveLayers.forEach(layer => {
                if (layer && map.hasLayer(layer)) {
                    map.removeLayer(layer);
                }
            });
            predictiveLayers = [];

            // Clear markers but keep cluster group
            markers.clearLayers();
            currentMarkers = [];
        }

        function loadStandardView() {
            // Switch to dark map
            switchBaseLayer('standard');

            // Add reports
            updateMapMarkers();
        }

        function loadHeatmapView() {
            // Switch to light map for better heatmap visibility
            switchBaseLayer('heatmap');

            // Create heatmap with proper data format
            const heatPoints = heatmapData.map(point => [point[0], point[1], point[2] || 0.5]);

            heatmapLayer = L.heatLayer(heatPoints, {
                radius: 25,
                blur: 15,
                maxZoom: 17,
                gradient: {
                    0.1: 'rgba(59, 130, 246, 0.7)',
                    0.3: 'rgba(0, 255, 255, 0.8)',
                    0.5: 'rgba(0, 255, 0, 0.8)',
                    0.7: 'rgba(255, 255, 0, 0.9)',
                    1.0: 'rgba(255, 0, 0, 1.0)'
                }
            }).addTo(map);

            // Zoom to heatmap area
            const heatmapBounds = L.latLngBounds(heatmapData.map(point => [point[0], point[1]]));
            map.fitBounds(heatmapBounds.pad(0.1));
        }

        function loadZoneView() {
            // Switch to terrain map
            switchBaseLayer('zones');

            // Add analytical zones
            Object.keys(analyticalZones).forEach(city => {
                analyticalZones[city].forEach(zone => {
                    const polygon = L.polygon(zone.coordinates, {
                        className: `zone-${zone.type}`,
                        fillOpacity: 0.3,
                        weight: 2,
                        color: getZoneColor(zone.type),
                        fillColor: getZoneColor(zone.type)
                    }).addTo(map);

                    polygon.bindPopup(`
                    <div style="min-width: 250px;">
                        <h3 style="margin: 0 0 10px 0; color: #1f2937; display: flex; align-items: center; gap: 8px;">
                            <i class="fas fa-${getZoneIcon(zone.type)}" style="color: ${getZoneColor(zone.type)};"></i> 
                            ${zone.type.toUpperCase()} RISK ZONE
                        </h3>
                        <p style="margin: 0 0 12px 0; color: #6b7280; font-size: 14px; line-height: 1.5;">
                            ${zone.description}
                        </p>
                        <div style="display: flex; gap: 8px;">
                            <span style="padding: 4px 8px; background: ${getZoneColor(zone.type)}; 
                                   color: white; border-radius: 4px; font-size: 11px; font-weight: 600;">
                                <i class="fas fa-map-marker-alt"></i> ${capitalize(city)}
                            </span>
                            <span style="padding: 4px 8px; background: #f3f4f6; color: #6b7280; 
                                   border-radius: 4px; font-size: 11px; font-weight: 600;">
                                <i class="fas fa-layer-group"></i> Zone Analysis
                            </span>
                        </div>
                    </div>
                `);

                    zoneLayers.push(polygon);
                });
            });

            // Add reports on top
            updateMapMarkers();
        }

        function loadPredictiveView() {
            // Switch to satellite map
            switchBaseLayer('predictive');

            // Add predictive hotspots
            predictiveHotspots.forEach((hotspot, index) => {
                // Outer prediction zone (faded)
                const outerCircle = L.circle(hotspot.location, {
                    radius: hotspot.radius * 1.5,
                    color: '#3b82f6',
                    fillColor: '#3b82f6',
                    fillOpacity: 0.1,
                    weight: 1,
                    dashArray: '5, 5'
                }).addTo(map);

                // Main prediction zone
                const mainCircle = L.circle(hotspot.location, {
                    radius: hotspot.radius,
                    color: '#3b82f6',
                    fillColor: '#3b82f6',
                    fillOpacity: 0.3,
                    weight: 2,
                    dashArray: '10, 10'
                }).addTo(map);

                // Inner core zone
                const innerCircle = L.circle(hotspot.location, {
                    radius: hotspot.radius * 0.5,
                    color: '#ef4444',
                    fillColor: '#ef4444',
                    fillOpacity: 0.5,
                    weight: 3
                }).addTo(map);

                // Add marker with prediction icon
                const predictionIcon = L.divIcon({
                    html: `
                    <div style="
                        width: 44px;
                        height: 44px;
                        background: linear-gradient(135deg, #3b82f6 0%, #8b5cf6 100%);
                        border: 3px solid white;
                        border-radius: 50%;
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        color: white;
                        font-size: 20px;
                        font-weight: bold;
                        box-shadow: 0 6px 20px rgba(139, 92, 246, 0.5);
                        animation: pulse 2s infinite;
                    ">
                        <i class="fas fa-robot"></i>
                    </div>
                `,
                    className: 'prediction-marker',
                    iconSize: [44, 44],
                    iconAnchor: [22, 22]
                });

                const marker = L.marker(hotspot.location, { icon: predictionIcon }).addTo(map);

                // Combine all layers in a feature group for easier management
                const featureGroup = L.featureGroup([outerCircle, mainCircle, innerCircle, marker]);

                // Add popup to the feature group
                featureGroup.bindPopup(`
                <div style="min-width: 280px;">
                    <h3 style="margin: 0 0 10px 0; color: #1f2937;">
                        <i class="fas fa-robot"></i> AI PREDICTION ZONE
                    </h3>
                    <p style="margin: 0 0 12px 0; color: #6b7280; font-size: 14px; line-height: 1.5;">
                        ${hotspot.description}
                    </p>
                    <div style="display: flex; align-items: center; gap: 8px; flex-wrap: wrap;">
                        <span style="padding: 6px 12px; background: linear-gradient(135deg, #3b82f6 0%, #8b5cf6 100%); 
                               color: white; border-radius: 6px; font-size: 12px; font-weight: 600;">
                            <i class="fas fa-brain"></i> Confidence: ${Math.round(hotspot.confidence * 100)}%
                        </span>
                        <span style="padding: 6px 12px; background: #f3f4f6; color: #6b7280; 
                               border-radius: 6px; font-size: 12px; font-weight: 600;">
                            <i class="fas fa-ruler"></i> Radius: ${hotspot.radius}m
                        </span>
                        <span style="padding: 6px 12px; background: #fef3c7; color: #92400e; 
                               border-radius: 6px; font-size: 12px; font-weight: 600;">
                            <i class="fas fa-clock"></i> Timeframe: 48-72h
                        </span>
                    </div>
                </div>
            `);

                predictiveLayers.push(featureGroup);
            });

            // Also show current reports in predictive view
            updateMapMarkers();
        }

        function loadAnalyticsView() {
            // Switch to analytical map style
            switchBaseLayer('analytics');

            // Create heatmap with analytical gradient
            const heatPoints = heatmapData.map(point => [point[0], point[1], point[2] || 0.5]);

            heatmapLayer = L.heatLayer(heatPoints, {
                radius: 30,
                blur: 20,
                maxZoom: 17,
                gradient: {
                    0.1: 'rgba(16, 185, 129, 0.6)',
                    0.4: 'rgba(245, 158, 11, 0.7)',
                    0.7: 'rgba(234, 88, 12, 0.8)',
                    1.0: 'rgba(220, 38, 38, 0.9)'
                }
            }).addTo(map);

            // Add analytical zones with semi-transparent overlays
            Object.keys(analyticalZones).forEach(city => {
                analyticalZones[city].forEach(zone => {
                    const polygon = L.polygon(zone.coordinates, {
                        className: `zone-${zone.type}`,
                        fillOpacity: 0.4,
                        weight: 3,
                        color: getZoneColor(zone.type),
                        fillColor: getZoneColor(zone.type)
                    }).addTo(map);

                    polygon.bindTooltip(`
                    <div style="font-size: 13px; font-weight: 600; color: white; text-shadow: 1px 1px 2px rgba(0,0,0,0.7);">
                        ${zone.type.toUpperCase()} ZONE
                    </div>
                `, {
                        permanent: false,
                        direction: 'center',
                        className: 'zone-tooltip'
                    });

                    zoneLayers.push(polygon);
                });
            });

            // Add reports with analytical styling
            filteredReports.forEach(report => {
                const marker = createAnalyticalMarker(report);
                markers.addLayer(marker);
                currentMarkers.push(marker);
            });

            // Add cluster group to map
            map.addLayer(markers);
        }

        function loadSatelliteView() {
            // Switch to satellite map
            switchBaseLayer('satellite');

            // Add reports
            updateMapMarkers();
        }

        function getZoneIcon(zoneType) {
            const icons = {
                critical: 'exclamation-triangle',
                high: 'exclamation-circle',
                medium: 'minus-circle',
                low: 'check-circle',
                clean: 'check'
            };
            return icons[zoneType] || 'info-circle';
        }

        function getZoneColor(zoneType) {
            const colors = {
                critical: 'var(--zone-critical)',
                high: 'var(--zone-high)',
                medium: 'var(--zone-medium)',
                low: 'var(--zone-low)',
                clean: 'var(--zone-clean)'
            };
            return colors[zoneType] || '#6b7280';
        }

        // ========== DATA LOADING ==========
        function loadReports() {
            allReports = [
                {
                    id: 1,
                    title: "Plastic Waste Crisis - Market Zone",
                    description: "Critical accumulation of plastic waste creating environmental hazard and blocking drainage systems.",
                    lat: 9.5587,
                    lng: 44.0654,
                    type: "plastic",
                    severity: "critical",
                    status: "new",
                    city: "hargeisa",
                    reporter: "Environmental Agency",
                    timestamp: "Today, 10:30 AM",
                    quantity: "2,500+ kg",
                    priority: "emergency",
                    address: "Kaah Market, Hargeisa",
                    zone: "critical"
                },
                {
                    id: 2,
                    title: "Medical Waste Hazard - Hospital Area",
                    description: "Unsecured medical waste posing severe health risks to public. Immediate containment required.",
                    lat: 9.5623,
                    lng: 44.0718,
                    type: "medical",
                    severity: "critical",
                    status: "inprogress",
                    city: "hargeisa",
                    reporter: "Health Department",
                    timestamp: "Today, 09:15 AM",
                    quantity: "120 kg",
                    priority: "emergency",
                    address: "Edna Adan Hospital",
                    zone: "critical"
                },
                {
                    id: 3,
                    title: "Construction Debris Blockage",
                    description: "Major road blockage due to construction waste accumulation. Traffic disruption reported.",
                    lat: 9.5534,
                    lng: 44.0589,
                    type: "construction",
                    severity: "high",
                    status: "assigned",
                    city: "hargeisa",
                    reporter: "Traffic Management",
                    timestamp: "Yesterday, 3:45 PM",
                    quantity: "800 kg",
                    priority: "high",
                    address: "Hargeisa-Berbera Highway",
                    zone: "high"
                },
                {
                    id: 4,
                    title: "Organic Waste - Livestock Market",
                    description: "Daily organic waste accumulation creating sanitation issues and odor problems.",
                    lat: 9.5678,
                    lng: 44.0623,
                    type: "organic",
                    severity: "high",
                    status: "new",
                    city: "hargeisa",
                    reporter: "Market Committee",
                    timestamp: "2 days ago",
                    quantity: "500+ kg daily",
                    priority: "high",
                    address: "Livestock Market",
                    zone: "high"
                },
                {
                    id: 5,
                    title: "Port Area Plastic Pollution",
                    description: "Marine plastic pollution affecting beach area and threatening marine ecosystem.",
                    lat: 10.4315,
                    lng: 45.0137,
                    type: "plastic",
                    severity: "critical",
                    status: "new",
                    city: "berbera",
                    reporter: "Marine Conservation",
                    timestamp: "Today, 11:00 AM",
                    quantity: "350+ kg",
                    priority: "emergency",
                    address: "Berbera Port Beach",
                    zone: "critical"
                },
                {
                    id: 6,
                    title: "Fish Market Waste Emergency",
                    description: "Severe organic waste accumulation creating health hazards and attracting pests.",
                    lat: 10.4362,
                    lng: 45.0168,
                    type: "organic",
                    severity: "critical",
                    status: "assigned",
                    city: "berbera",
                    reporter: "Public Health",
                    timestamp: "Today, 08:30 AM",
                    quantity: "600 kg",
                    priority: "emergency",
                    address: "Berbera Fish Market",
                    zone: "critical"
                },
                {
                    id: 7,
                    title: "University Area Waste Management",
                    description: "Inefficient waste management system causing accumulation in educational area.",
                    lat: 9.9364,
                    lng: 43.1842,
                    type: "mixed",
                    severity: "medium",
                    status: "inprogress",
                    city: "borama",
                    reporter: "University Admin",
                    timestamp: "3 days ago",
                    quantity: "250 kg daily",
                    priority: "medium",
                    address: "Amoud University",
                    zone: "medium"
                },
                {
                    id: 8,
                    title: "Medical Waste - Regional Hospital",
                    description: "Inadequate medical waste disposal system requiring immediate intervention.",
                    lat: 9.5218,
                    lng: 45.5349,
                    type: "medical",
                    severity: "critical",
                    status: "new",
                    city: "burao",
                    reporter: "Hospital Director",
                    timestamp: "Today, 07:45 AM",
                    quantity: "80 kg",
                    priority: "emergency",
                    address: "Burao Regional Hospital",
                    zone: "critical"
                },
                {
                    id: 9,
                    title: "Border Market Accumulation",
                    description: "Waste accumulation at busy border crossing affecting trade and hygiene.",
                    lat: 8.4767,
                    lng: 47.3601,
                    type: "mixed",
                    severity: "high",
                    status: "new",
                    city: "lasanod",
                    reporter: "Border Control",
                    timestamp: "Yesterday",
                    quantity: "500+ kg",
                    priority: "high",
                    address: "Las Anod Border Market",
                    zone: "high"
                },
                {
                    id: 10,
                    title: "Mountain Community Waste",
                    description: "Limited waste collection services causing accumulation in remote area.",
                    lat: 10.6185,
                    lng: 47.3689,
                    type: "mixed",
                    severity: "low",
                    status: "new",
                    city: "erigavo",
                    reporter: "Community Leader",
                    timestamp: "4 days ago",
                    quantity: "300 kg",
                    priority: "low",
                    address: "Daallo Mountain Community",
                    zone: "low"
                }
            ];

            updateUI();
        }

        // ========== UI UPDATES ==========
        function updateUI() {
            filterReports();
            updateReportsList();
            updateMapMarkers();
            updateAnalytics();
        }

        function filterReports() {
            filteredReports = allReports.filter(report => {
                if (activeFilters.type !== 'all' && report.type !== activeFilters.type) return false;
                if (activeFilters.severity !== 'all' && report.severity !== activeFilters.severity) return false;
                if (activeFilters.city !== 'all' && report.city !== activeFilters.city) return false;
                return true;
            });
        }

        function updateReportsList() {
            const reportsList = document.getElementById('reportsList');
            const reportsCount = document.getElementById('reportsCount');

            reportsCount.textContent = `${filteredReports.length} reports`;

            if (filteredReports.length === 0) {
                reportsList.innerHTML = `
                <div style="text-align: center; padding: 60px 20px; color: #94a3b8;">
                    <i class="fas fa-chart-bar" style="font-size: 48px; margin-bottom: 16px; opacity: 0.5;"></i>
                    <h4 style="margin-bottom: 8px; color: #e2e8f0;">No Data Found</h4>
                    <p style="font-size: 14px; margin-bottom: 20px;">Try adjusting your filters or switch view mode</p>
                    <button onclick="clearAllFilters()" style="
                        padding: 10px 20px;
                        background: linear-gradient(135deg, var(--primary) 0%, var(--secondary) 100%);
                        color: white;
                        border: none;
                        border-radius: 8px;
                        font-size: 14px;
                        font-weight: 600;
                        cursor: pointer;
                        transition: all 0.3s ease;
                    " onmouseover="this.style.transform='translateY(-2px)'" onmouseout="this.style.transform='translateY(0)'">
                        <i class="fas fa-filter"></i> Reset All Filters
                    </button>
                </div>
            `;
                return;
            }

            let html = '';
            filteredReports.forEach(report => {
                const zoneColors = {
                    critical: 'var(--zone-critical)',
                    high: 'var(--zone-high)',
                    medium: 'var(--zone-medium)',
                    low: 'var(--zone-low)'
                };

                html += `
                <div class="report-card ${report.severity}" onclick="showReportDetails(${report.id})">
                    <div class="report-header">
                        <span class="report-type ${report.type}">
                            <i class="fas ${getTypeIcon(report.type)}"></i> ${capitalize(report.type)}
                        </span>
                        <span class="report-severity severity-${report.severity}">
                            ${capitalize(report.severity)}
                        </span>
                    </div>
                    <div class="report-title">${report.title}</div>
                    <div class="report-details">
                        <div>
                            <i class="fas fa-map-marker-alt"></i>
                            <span>${report.address}</span>
                        </div>
                        <div>
                            <i class="fas fa-clock"></i>
                            <span>${report.timestamp}</span>
                        </div>
                        <div>
                            <i class="fas fa-weight-hanging"></i>
                            <span>${report.quantity}</span>
                        </div>
                        <div>
                            <i class="fas fa-layer-group"></i>
                            <span>Zone: <strong style="color: ${zoneColors[report.zone]}">${capitalize(report.zone)}</strong></span>
                        </div>
                    </div>
                    <div class="report-footer">
                        <div class="reporter">
                            <i class="fas fa-user-shield"></i> ${report.reporter}
                        </div>
                        <div class="report-status status-${report.status}">
                            ${capitalize(report.status)}
                        </div>
                    </div>
                </div>
            `;
            });

            reportsList.innerHTML = html;
        }

        function updateMapMarkers() {
            // Clear existing markers
            markers.clearLayers();
            currentMarkers = [];

            filteredReports.forEach(report => {
                const marker = createMarker(report);
                markers.addLayer(marker);
                currentMarkers.push(marker);
            });

            // Add cluster group to map if not already added
            if (!map.hasLayer(markers)) {
                map.addLayer(markers);
            }
        }

        function createMarker(report) {
            const severityColors = {
                critical: '#dc2626',
                high: '#ea580c',
                medium: '#f59e0b',
                low: '#10b981'
            };

            const typeLetters = {
                plastic: 'P',
                organic: 'O',
                medical: 'M',
                hazardous: 'H',
                construction: 'C',
                electronics: 'E',
                mixed: 'W'
            };

            const icon = L.divIcon({
                className: report.severity === 'critical' ? 'pulse' : '',
                html: `
                <div style="
                    width: 36px;
                    height: 36px;
                    background: ${severityColors[report.severity]};
                    border: 3px solid white;
                    border-radius: 50%;
                    box-shadow: 0 4px 12px rgba(0,0,0,0.4);
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    color: white;
                    font-weight: bold;
                    font-size: 16px;
                    cursor: pointer;
                    transition: all 0.3s ease;
                ">
                    ${typeLetters[report.type] || 'W'}
                </div>
            `,
                iconSize: [36, 36],
                iconAnchor: [18, 18]
            });

            const marker = L.marker([report.lat, report.lng], {
                icon: icon,
                report: report
            });

            marker.report = report;
            marker.reportId = report.id;

            // Popup content
            const popupContent = `
            <div style="min-width: 280px; font-family: 'Inter', sans-serif;">
                <div style="display: flex; justify-content: space-between; align-items: start; margin-bottom: 12px;">
                    <h4 style="margin: 0; color: white; font-size: 15px; font-weight: 600; line-height: 1.4;">${report.title}</h4>
                    <span style="
                        background: ${severityColors[report.severity]};
                        color: white;
                        padding: 4px 10px;
                        border-radius: 12px;
                        font-size: 12px;
                        font-weight: 700;
                        text-transform: uppercase;
                    ">
                        ${report.severity}
                    </span>
                </div>
                
                <div style="font-size: 13px; color: #94a3b8; margin-bottom: 16px;">
                    <div style="margin-bottom: 8px; display: flex; align-items: center; gap: 8px;">
                        <span style="
                            background: ${getTypeColor(report.type)};
                            color: white;
                            padding: 4px 8px;
                            border-radius: 6px;
                            font-size: 11px;
                            font-weight: 600;
                        ">
                            <i class="fas ${getTypeIcon(report.type)}"></i> ${capitalize(report.type)}
                        </span>
                        <span><i class="fas fa-weight-hanging"></i> ${report.quantity}</span>
                    </div>
                    
                    <div style="margin-bottom: 6px; display: flex; align-items: center; gap: 8px;">
                        <i class="fas fa-map-marker-alt"></i>
                        <span>${report.address}</span>
                    </div>
                    
                    <div style="margin-bottom: 6px; display: flex; align-items: center; gap: 8px;">
                        <i class="fas fa-clock"></i>
                        <span>${report.timestamp}</span>
                    </div>
                    
                    <div style="display: flex; align-items: center; gap: 8px;">
                        <i class="fas fa-user-shield"></i>
                        <span>${report.reporter}</span>
                    </div>
                </div>
                
                <div style="display: flex; gap: 8px;">
                    <button onclick="event.stopPropagation(); showReportDetails(${report.id})" style="
                        flex: 1;
                        padding: 8px 12px;
                        background: var(--primary);
                        color: white;
                        border: none;
                        border-radius: 8px;
                        font-size: 13px;
                        font-weight: 600;
                        cursor: pointer;
                        transition: all 0.3s ease;
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        gap: 6px;
                    " onmouseover="this.style.background='#059669'" onmouseout="this.style.background='var(--primary)'">
                        <i class="fas fa-chart-bar"></i> Analytics
                    </button>
                    <button onclick="event.stopPropagation(); openGoogleMaps(${report.lat}, ${report.lng})" style="
                        flex: 1;
                        padding: 8px 12px;
                        background: #3b82f6;
                        color: white;
                        border: none;
                        border-radius: 8px;
                        font-size: 13px;
                        font-weight: 600;
                        cursor: pointer;
                        transition: all 0.3s ease;
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        gap: 6px;
                    " onmouseover="this.style.background='#2563eb'" onmouseout="this.style.background='#3b82f6'">
                        <i class="fas fa-external-link-alt"></i> View in Maps
                    </button>
                </div>
            </div>
        `;

            marker.bindPopup(popupContent);

            marker.on('click', function () {
                highlightReport(report.id);
            });

            return marker;
        }

        function createAnalyticalMarker(report) {
            const severityColors = {
                critical: '#dc2626',
                high: '#ea580c',
                medium: '#f59e0b',
                low: '#10b981'
            };

            const icon = L.divIcon({
                html: `
                <div style="
                    width: 40px;
                    height: 40px;
                    background: ${severityColors[report.severity]};
                    border: 3px solid white;
                    border-radius: 50%;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    color: white;
                    font-weight: bold;
                    font-size: 18px;
                    box-shadow: 0 4px 16px rgba(0,0,0,0.3);
                    cursor: pointer;
                    transition: all 0.3s ease;
                    position: relative;
                ">
                    <i class="fas ${getTypeIcon(report.type)}"></i>
                    <div style="
                        position: absolute;
                        top: -5px;
                        right: -5px;
                        width: 20px;
                        height: 20px;
                        background: white;
                        border: 2px solid ${severityColors[report.severity]};
                        border-radius: 50%;
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        font-size: 10px;
                        font-weight: bold;
                        color: ${severityColors[report.severity]};
                    ">
                        ${report.severity.charAt(0).toUpperCase()}
                    </div>
                </div>
            `,
                className: 'analytical-marker',
                iconSize: [40, 40],
                iconAnchor: [20, 20]
            });

            const marker = L.marker([report.lat, report.lng], {
                icon: icon,
                report: report
            });

            marker.report = report;
            marker.reportId = report.id;

            // Enhanced popup for analytics view
            marker.bindPopup(createAnalyticalPopup(report));

            return marker;
        }

        function createAnalyticalPopup(report) {
            const severityColors = {
                critical: '#dc2626',
                high: '#ea580c',
                medium: '#f59e0b',
                low: '#10b981'
            };

            return `
            <div style="min-width: 300px; font-family: 'Inter', sans-serif;">
                <div style="display: flex; justify-content: space-between; align-items: start; margin-bottom: 16px;">
                    <h4 style="margin: 0; color: white; font-size: 16px; font-weight: 600; line-height: 1.4;">${report.title}</h4>
                    <div style="display: flex; flex-direction: column; gap: 4px; align-items: flex-end;">
                        <span style="
                            background: ${severityColors[report.severity]};
                            color: white;
                            padding: 4px 10px;
                            border-radius: 12px;
                            font-size: 12px;
                            font-weight: 700;
                            text-transform: uppercase;
                        ">
                            ${report.severity}
                        </span>
                        <span style="
                            background: ${getTypeColor(report.type)};
                            color: white;
                            padding: 4px 8px;
                            border-radius: 8px;
                            font-size: 11px;
                            font-weight: 600;
                        ">
                            <i class="fas ${getTypeIcon(report.type)}"></i> ${capitalize(report.type)}
                        </span>
                    </div>
                </div>
                
                <div style="font-size: 14px; color: #94a3b8; margin-bottom: 20px; line-height: 1.6;">
                    <p style="margin: 0 0 12px 0;">${report.description}</p>
                </div>
                
                <div style="display: grid; grid-template-columns: repeat(2, 1fr); gap: 12px; margin-bottom: 20px;">
                    <div style="background: rgba(255, 255, 255, 0.05); padding: 12px; border-radius: 8px; border-left: 4px solid ${severityColors[report.severity]};">
                        <div style="font-size: 12px; color: #64748b; margin-bottom: 4px;">Quantity</div>
                        <div style="font-size: 16px; font-weight: 600; color: white;">${report.quantity}</div>
                    </div>
                    <div style="background: rgba(255, 255, 255, 0.05); padding: 12px; border-radius: 8px; border-left: 4px solid ${getTypeColor(report.type)};">
                        <div style="font-size: 12px; color: #64748b; margin-bottom: 4px;">Status</div>
                        <div style="font-size: 16px; font-weight: 600; color: ${report.status === 'new' ? 'var(--status-new)' :
                    report.status === 'assigned' ? 'var(--status-assigned)' :
                        report.status === 'inprogress' ? 'var(--status-inprogress)' : 'var(--status-collected)'}">
                            ${capitalize(report.status)}
                        </div>
                    </div>
                </div>
                
                <div style="display: flex; gap: 8px;">
                    <button onclick="event.stopPropagation(); showReportDetails(${report.id})" style="
                        flex: 1;
                        padding: 10px 16px;
                        background: linear-gradient(135deg, var(--primary) 0%, var(--secondary) 100%);
                        color: white;
                        border: none;
                        border-radius: 8px;
                        font-size: 14px;
                        font-weight: 600;
                        cursor: pointer;
                        transition: all 0.3s ease;
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        gap: 8px;
                    " onmouseover="this.style.transform='translateY(-2px)'; this.style.boxShadow='0 4px 20px rgba(16, 185, 129, 0.4)'" 
                    onmouseout="this.style.transform='translateY(0)'; this.style.boxShadow='none'">
                        <i class="fas fa-chart-bar"></i> Full Analytics
                    </button>
                    <button onclick="event.stopPropagation(); openGoogleMaps(${report.lat}, ${report.lng})" style="
                        flex: 1;
                        padding: 10px 16px;
                        background: #1e293b;
                        color: white;
                        border: 1px solid #334155;
                        border-radius: 8px;
                        font-size: 14px;
                        font-weight: 600;
                        cursor: pointer;
                        transition: all 0.3s ease;
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        gap: 8px;
                    " onmouseover="this.style.transform='translateY(-2px)'; this.style.background='#334155'; this.style.borderColor='#475569'" 
                    onmouseout="this.style.transform='translateY(0)'; this.style.background='#1e293b'; this.style.borderColor='#334155'">
                        <i class="fas fa-external-link-alt"></i> Maps
                    </button>
                </div>
            </div>
        `;
        }

        function updateAnalytics() {
            const total = allReports.length;
            const critical = allReports.filter(r => r.severity === 'critical').length;
            const responseRate = total > 0 ? Math.round((allReports.filter(r => r.status === 'inprogress' || r.status === 'collected').length / total) * 100) : 0;
            const coverage = total > 0 ? Math.round((filteredReports.length / total) * 100) : 0;

            document.getElementById('totalReports').textContent = total;
            document.getElementById('criticalZones').textContent = critical;
            document.getElementById('responseRate').textContent = `${responseRate}%`;
            document.getElementById('coverage').textContent = `${coverage}%`;
        }

        // ========== UTILITY FUNCTIONS ==========
        function getTypeIcon(type) {
            const icons = {
                plastic: 'fa-bottle-water',
                organic: 'fa-leaf',
                medical: 'fa-biohazard',
                hazardous: 'fa-radiation',
                construction: 'fa-hard-hat',
                electronics: 'fa-laptop',
                mixed: 'fa-trash'
            };
            return icons[type] || 'fa-trash-alt';
        }

        function getTypeColor(type) {
            const colors = {
                plastic: 'var(--plastic)',
                organic: 'var(--organic)',
                medical: 'var(--medical)',
                hazardous: 'var(--hazardous)',
                construction: 'var(--construction)',
                electronics: 'var(--electronics)',
                mixed: 'var(--mixed)'
            };
            return colors[type] || '#6b7280';
        }

        function capitalize(str) {
            return str.charAt(0).toUpperCase() + str.slice(1);
        }

        function clearFilter(filterType) {
            activeFilters[filterType] = 'all';
            updateFilterUI(filterType, 'all');
            updateUI();
        }

        function clearAllFilters() {
            activeFilters = {
                type: 'all',
                severity: 'all',
                city: 'all'
            };

            document.querySelectorAll('.filter-tag, .city-btn').forEach(el => el.classList.remove('active'));
            document.querySelectorAll('[data-value="all"]').forEach(el => el.classList.add('active'));
            document.getElementById('searchInput').value = '';

            updateUI();
        }

        function updateFilterUI(filterType, filterValue) {
            document.querySelectorAll(`.filter-tag[data-filter="${filterType}"]`).forEach(tag => {
                tag.classList.remove('active');
            });
            document.querySelectorAll(`.city-btn[data-filter="${filterType}"]`).forEach(btn => {
                btn.classList.remove('active');
            });

            const selected = document.querySelector(`[data-filter="${filterType}"][data-value="${filterValue}"]`);
            if (selected) selected.classList.add('active');
        }

        function updateSensitivity(value) {
            document.getElementById('sensitivityValue').textContent = `${value}%`;
            // Update heatmap intensity based on sensitivity
            if (heatmapLayer) {
                const newIntensity = value / 100;
                heatmapLayer.setOptions({
                    max: newIntensity
                });
            }
        }

        function updateTimeRange(value) {
            const days = value;
            document.getElementById('timeRangeValue').textContent = `${days} days`;
            // In real app, this would filter data by time range
        }

        // ========== EVENT HANDLERS ==========
        function setupEventListeners() {
            // Filter tags
            document.querySelectorAll('.filter-tag').forEach(tag => {
                tag.addEventListener('click', function () {
                    const filterType = this.dataset.filter;
                    const filterValue = this.dataset.value;
                    activeFilters[filterType] = filterValue;
                    updateFilterUI(filterType, filterValue);
                    updateUI();
                });
            });

            // City buttons
            document.querySelectorAll('.city-btn').forEach(btn => {
                btn.addEventListener('click', function () {
                    const filterType = this.dataset.filter;
                    const filterValue = this.dataset.value;
                    activeFilters[filterType] = filterValue;
                    updateFilterUI(filterType, filterValue);
                    updateUI();

                    if (filterValue !== 'all') {
                        zoomToCity(filterValue);
                    }
                });
            });

            // Search
            document.getElementById('searchInput').addEventListener('input', debounce(function (e) {
                filterBySearch(e.target.value);
            }, 300));
        }

        function filterBySearch(term) {
            if (!term.trim()) {
                updateUI();
                return;
            }

            const searchTerm = term.toLowerCase();
            const filtered = allReports.filter(report =>
                report.title.toLowerCase().includes(searchTerm) ||
                report.description.toLowerCase().includes(searchTerm) ||
                report.address.toLowerCase().includes(searchTerm) ||
                report.reporter.toLowerCase().includes(searchTerm) ||
                report.city.toLowerCase().includes(searchTerm) ||
                report.type.toLowerCase().includes(searchTerm) ||
                report.severity.toLowerCase().includes(searchTerm)
            );

            // Temporarily update filtered reports
            const originalFiltered = filteredReports;
            filteredReports = filtered;
            updateReportsList();
            updateMapMarkers();
            filteredReports = originalFiltered;
        }

        function debounce(func, wait) {
            let timeout;
            return function executedFunction(...args) {
                const later = () => {
                    clearTimeout(timeout);
                    func(...args);
                };
                clearTimeout(timeout);
                timeout = setTimeout(later, wait);
            };
        }

        function zoomToCity(city) {
            const cityCenters = {
                hargeisa: [9.5616, 44.0650],
                berbera: [10.4340, 45.0140],
                burao: [9.5221, 45.5350],
                borama: [9.9361, 43.1839],
                erigavo: [10.6180, 47.3680],
                lasanod: [8.4764, 47.3597]
            };

            if (cityCenters[city]) {
                map.setView(cityCenters[city], 13);
            }
        }

        function switchViewType(view) {
            document.querySelectorAll('.mode-btn').forEach(btn => btn.classList.remove('active'));
            event.target.classList.add('active');

            // In real app, this would switch between different analytical views
            console.log('Switching to view:', view);
        }

        function toggleLayer(layer) {
            document.querySelectorAll('.control-btn').forEach(btn => btn.classList.remove('active'));
            event.target.classList.add('active');

            // Layer toggling logic would go here
            console.log('Toggling layer:', layer);
        }

        // ========== REPORT FUNCTIONS ==========
        function showReportDetails(reportId) {
            const report = allReports.find(r => r.id === reportId);
            if (!report) return;

            document.getElementById('modalTitle').textContent = report.title;

            const zoneColors = {
                critical: 'var(--zone-critical)',
                high: 'var(--zone-high)',
                medium: 'var(--zone-medium)',
                low: 'var(--zone-low)'
            };

            document.getElementById('modalBody').innerHTML = `
            <div style="display: grid; gap: 32px;">
                <!-- Header -->
                <div style="display: flex; gap: 16px; flex-wrap: wrap;">
                    <span style="
                        background: ${getTypeColor(report.type)};
                        color: white;
                        padding: 10px 20px;
                        border-radius: 10px;
                        font-size: 15px;
                        font-weight: 700;
                        display: flex;
                        align-items: center;
                        gap: 8px;
                    ">
                        <i class="fas ${getTypeIcon(report.type)}"></i> ${capitalize(report.type)} Waste
                    </span>
                    <span style="
                        background: ${zoneColors[report.severity]};
                        color: white;
                        padding: 10px 20px;
                        border-radius: 10px;
                        font-size: 15px;
                        font-weight: 700;
                        display: flex;
                        align-items: center;
                        gap: 8px;
                    ">
                        <i class="fas fa-exclamation-triangle"></i> ${capitalize(report.severity)} Priority
                    </span>
                    <span style="
                        background: ${report.status === 'new' ? 'var(--status-new)' :
                    report.status === 'assigned' ? 'var(--status-assigned)' :
                        report.status === 'inprogress' ? 'var(--status-inprogress)' : 'var(--status-collected)'};
                        color: white;
                        padding: 10px 20px;
                        border-radius: 10px;
                        font-size: 15px;
                        font-weight: 700;
                        display: flex;
                        align-items: center;
                        gap: 8px;
                    ">
                        <i class="fas fa-${report.status === 'inprogress' ? 'truck-moving' : 'circle'}"></i> 
                        ${capitalize(report.status)}
                    </span>
                </div>
                
                <!-- Description -->
                <div>
                    <h3 style="font-size: 18px; margin-bottom: 16px; color: white; display: flex; align-items: center; gap: 10px;">
                        <i class="fas fa-info-circle"></i> Analytical Overview
                    </h3>
                    <p style="color: #94a3b8; line-height: 1.7; font-size: 16px; background: rgba(255, 255, 255, 0.05); padding: 20px; border-radius: 10px; border-left: 4px solid ${zoneColors[report.severity]}">
                        ${report.description}
                    </p>
                </div>
                
                <!-- Analytics Grid -->
                <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 24px;">
                    <div style="background: rgba(255, 255, 255, 0.03); padding: 24px; border-radius: 12px; border: 1px solid #334155;">
                        <h4 style="font-size: 15px; margin-bottom: 16px; color: white; display: flex; align-items: center; gap: 10px;">
                            <i class="fas fa-map-marker-alt"></i> Location Analytics
                        </h4>
                        <div style="color: #94a3b8; font-size: 15px;">
                            <div style="margin-bottom: 12px;">
                                <strong style="color: white;">Address:</strong><br>
                                <span>${report.address}</span>
                            </div>
                            <div style="margin-bottom: 12px;">
                                <strong style="color: white;">City/Region:</strong><br>
                                <span>${capitalize(report.city)}</span>
                            </div>
                            <div style="margin-bottom: 12px;">
                                <strong style="color: white;">Coordinates:</strong><br>
                                <span>${report.lat.toFixed(6)}, ${report.lng.toFixed(6)}</span>
                            </div>
                            <div>
                                <strong style="color: white;">Risk Zone:</strong><br>
                                <span style="color: ${zoneColors[report.zone]}">${capitalize(report.zone)} Zone</span>
                            </div>
                        </div>
                    </div>
                    
                    <div style="background: rgba(255, 255, 255, 0.03); padding: 24px; border-radius: 12px; border: 1px solid #334155;">
                        <h4 style="font-size: 15px; margin-bottom: 16px; color: white; display: flex; align-items: center; gap: 10px;">
                            <i class="fas fa-chart-bar"></i> Waste Analytics
                        </h4>
                        <div style="color: #94a3b8; font-size: 15px;">
                            <div style="margin-bottom: 12px;">
                                <strong style="color: white;">Quantity:</strong><br>
                                <span>${report.quantity}</span>
                            </div>
                            <div style="margin-bottom: 12px;">
                                <strong style="color: white;">Priority Level:</strong><br>
                                <span style="color: ${zoneColors[report.severity]}">${capitalize(report.priority)}</span>
                            </div>
                            <div style="margin-bottom: 12px;">
                                <strong style="color: white;">Reported Time:</strong><br>
                                <span>${report.timestamp}</span>
                            </div>
                            <div>
                                <strong style="color: white;">Report ID:</strong><br>
                                <span>#${report.id.toString().padStart(4, '0')}</span>
                            </div>
                        </div>
                    </div>
                    
                    <div style="background: rgba(255, 255, 255, 0.03); padding: 24px; border-radius: 12px; border: 1px solid #334155;">
                        <h4 style="font-size: 15px; margin-bottom: 16px; color: white; display: flex; align-items: center; gap: 10px;">
                            <i class="fas fa-user-shield"></i> Reporting Analytics
                        </h4>
                        <div style="color: #94a3b8; font-size: 15px;">
                            <div style="margin-bottom: 12px;">
                                <strong style="color: white;">Reporter:</strong><br>
                                <span>${report.reporter}</span>
                            </div>
                            <div style="margin-bottom: 12px;">
                                <strong style="color: white;">Authority:</strong><br>
                                <span>${getAuthority(report.reporter)}</span>
                            </div>
                            <div style="margin-bottom: 12px;">
                                <strong style="color: white;">Response Time:</strong><br>
                                <span>${getResponseTime(report.status)}</span>
                            </div>
                            <div>
                                <strong style="color: white;">Data Source:</strong><br>
                                <span>${getDataSource(report.type)}</span>
                            </div>
                        </div>
                    </div>
                </div>
                
                <!-- Actions -->
                <div style="display: flex; gap: 16px; margin-top: 24px;">
                    <button onclick="openGoogleMaps(${report.lat}, ${report.lng})" style="
                        flex: 1;
                        padding: 16px;
                        background: linear-gradient(135deg, #3b82f6 0%, #2563eb 100%);
                        color: white;
                        border: none;
                        border-radius: 12px;
                        font-size: 16px;
                        font-weight: 700;
                        cursor: pointer;
                        transition: all 0.3s ease;
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        gap: 12px;
                    " onmouseover="this.style.transform='translateY(-4px)'; this.style.boxShadow='0 8px 30px rgba(37, 99, 235, 0.4)'" 
                    onmouseout="this.style.transform='translateY(0)'; this.style.boxShadow='none'">
                        <i class="fas fa-external-link-alt"></i> View in Google Maps
                    </button>
                    <button onclick="zoomToReport(${report.id})" style="
                        flex: 1;
                        padding: 16px;
                        background: linear-gradient(135deg, #1e293b 0%, #0f172a 100%);
                        color: white;
                        border: 1px solid #334155;
                        border-radius: 12px;
                        font-size: 16px;
                        font-weight: 700;
                        cursor: pointer;
                        transition: all 0.3s ease;
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        gap: 12px;
                    " onmouseover="this.style.transform='translateY(-4px)'; this.style.borderColor='#475569'; this.style.background='#334155'" 
                    onmouseout="this.style.transform='translateY(0)'; this.style.borderColor='#334155'; this.style.background='linear-gradient(135deg, #1e293b 0%, #0f172a 100%)'">
                        <i class="fas fa-map-marker-alt"></i> View on Analytics Map
                    </button>
                </div>
            </div>
        `;

            document.getElementById('reportModal').style.display = 'flex';
            highlightReport(reportId);
        }

        function getAuthority(reporter) {
            const authorities = {
                'Environmental Agency': 'Environmental Protection Department',
                'Health Department': 'Public Health Authority',
                'Traffic Management': 'Traffic Control Center',
                'Market Committee': 'Local Market Administration',
                'Marine Conservation': 'Marine Protection Unit',
                'Public Health': 'Health Ministry',
                'University Admin': 'Educational Institution',
                'Hospital Director': 'Medical Facility Management',
                'Border Control': 'Border Security Agency',
                'Community Leader': 'Local Community Council'
            };
            return authorities[reporter] || 'Local Authority';
        }

        function getResponseTime(status) {
            const times = {
                'new': 'Pending (0-2 hours)',
                'assigned': 'Assigned (2-4 hours)',
                'inprogress': 'In Progress (4-8 hours)',
                'collected': 'Completed (8-24 hours)'
            };
            return times[status] || 'Unknown';
        }

        function getDataSource(type) {
            const sources = {
                'plastic': 'Satellite Imaging + Ground Sensors',
                'organic': 'IoT Sensors + Citizen Reports',
                'medical': 'Healthcare Facility Reporting',
                'hazardous': 'Environmental Monitoring',
                'construction': 'Construction Site Reporting',
                'mixed': 'Multiple Data Sources'
            };
            return sources[type] || 'Automated Data Collection';
        }

        function highlightReport(reportId) {
            const marker = currentMarkers.find(m => m.reportId === reportId);
            if (marker) {
                marker.openPopup();
                map.setView(marker.getLatLng(), 16);

                // Highlight in list
                const listItems = document.querySelectorAll('.report-card');
                listItems.forEach((item, index) => {
                    if (filteredReports[index] && filteredReports[index].id === reportId) {
                        item.style.boxShadow = '0 0 0 3px var(--primary)';
                        item.scrollIntoView({ behavior: 'smooth', block: 'center' });
                    }
                });
            }
        }

        function openGoogleMaps(lat, lng) {
            // Open Google Maps with coordinates
            const url = `https://www.google.com/maps?q=${lat},${lng}`;
            window.open(url, '_blank');
        }

        function zoomToReport(reportId) {
            const report = allReports.find(r => r.id === reportId);
            if (report) {
                map.setView([report.lat, report.lng], 16);
                highlightReport(reportId);
            }
            closeModal();
        }

        function refreshData() {
            document.getElementById('loadingOverlay').style.display = 'flex';
            setTimeout(() => {
                loadReports();
                document.getElementById('loadingOverlay').style.display = 'none';
                alert('Analytical data refreshed! New patterns detected.');
            }, 1500);
        }

        function exportAnalytics() {
            alert('Exporting analytical data... This would download a report with current analytics.');
        }

        function closeModal() {
            document.getElementById('reportModal').style.display = 'none';
        }

        // ========== INITIALIZE ==========
        document.addEventListener('DOMContentLoaded', initApp);

        // Close modal on outside click
        document.addEventListener('click', function (event) {
            if (event.target.classList.contains('modal')) {
                closeModal();
            }
        });

        // Close modal with ESC
        document.addEventListener('keydown', function (event) {
            if (event.key === 'Escape') {
                closeModal();
            }
        });
    </script>
</asp:Content>
