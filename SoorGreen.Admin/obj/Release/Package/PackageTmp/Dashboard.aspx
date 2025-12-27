<%@ Page Title="Dashboard" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" Inherits="Dashboard" Codebehind="Dashboard.aspx.cs" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <style>
        /* FIXED: Navbar spacing solution */
        body {
            padding-top: 60px !important; /* Reduced from 120px */
        }

        /* Remove the content-wrapper override if it exists */
        .content-wrapper {
            padding-top: 0 !important;
        }

        .dashboard-section {
            min-height: calc(100vh - 150px); /* Reduced height */
            display: flex;
            align-items: center;
            justify-content: center;
            position: relative;
            overflow: hidden;
            background: radial-gradient(ellipse at center, rgba(0, 212, 170, 0.1) 0%, transparent 70%);
            padding: 30px 0; /* Reduced padding */
        }

        [data-theme="light"] .dashboard-section {
            background: radial-gradient(ellipse at center, rgba(0, 212, 170, 0.05) 0%, transparent 70%);
        }

        .loading-card {
            background: var(--card-bg);
            border: 1px solid var(--card-border);
            border-radius: 15px; /* Reduced radius */
            padding: 2rem; /* Reduced padding */
            transition: all 0.3s ease;
            backdrop-filter: blur(10px);
            color: var(--light);
            text-align: center;
            max-width: 500px;
            margin: 0 auto;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.2); /* Reduced shadow */
        }

        [data-theme="light"] .loading-card {
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
        }

        .progress-container {
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 1.5rem; /* Reduced gap */
        }

        .progress-spinner {
            width: 60px; /* Reduced size */
            height: 60px;
            border: 3px solid var(--card-border);
            border-left: 3px solid var(--primary);
            border-radius: 50%;
            animation: spin 1s linear infinite;
        }

        .progress-text {
            display: flex;
            flex-direction: column;
            gap: 0.5rem;
            width: 100%;
        }

        .progress-step {
            display: flex;
            align-items: center;
            gap: 0.75rem; /* Reduced gap */
            padding: 0.5rem 0.75rem; /* Reduced padding */
            background: var(--card-bg);
            border-radius: 8px; /* Reduced radius */
            border: 1px solid var(--card-border);
            transition: all 0.3s ease;
            font-size: 0.9rem; /* Smaller font */
        }

            .progress-step.active {
                border-color: var(--primary);
                background: rgba(0, 212, 170, 0.1);
            }

            .progress-step.completed {
                border-color: #10b981;
                background: rgba(16, 185, 129, 0.1);
            }

        .step-icon {
            width: 20px; /* Reduced size */
            height: 20px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 0.7rem; /* Smaller font */
            background: var(--card-bg);
            border: 1px solid var(--card-border);
            color: var(--light);
            transition: all 0.3s ease;
            flex-shrink: 0; /* Prevent shrinking */
        }

        .progress-step.active .step-icon {
            background: var(--primary);
            border-color: var(--primary);
            color: white;
        }

        .progress-step.completed .step-icon {
            background: #10b981;
            border-color: #10b981;
            color: white;
        }

        .step-text {
            flex: 1;
            text-align: left;
            min-width: 0; /* Allow text to wrap */
        }

            .step-text strong {
                color: var(--light) !important;
                display: block;
                margin-bottom: 0.125rem; /* Reduced margin */
                font-size: 0.85rem; /* Smaller font */
            }

            .step-text small {
                color: var(--light) !important;
                opacity: 0.8;
                font-size: 0.75rem; /* Smaller font */
            }

        .user-info {
            background: var(--card-bg);
            border: 1px solid var(--card-border);
            border-radius: 10px; /* Reduced radius */
            padding: 1rem; /* Reduced padding */
            margin-bottom: 1.5rem; /* Reduced margin */
            text-align: center;
        }

        .user-avatar {
            width: 60px; /* Reduced size */
            height: 60px;
            border-radius: 50%;
            background: linear-gradient(45deg, var(--primary), var(--secondary));
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 1.5rem; /* Smaller font */
            font-weight: 600;
            margin: 0 auto 0.75rem; /* Reduced margin */
            box-shadow: 0 4px 15px rgba(0, 212, 170, 0.3); /* Reduced shadow */
        }

        .user-details h4 {
            margin-bottom: 0.25rem; /* Reduced margin */
            color: var(--light) !important;
            font-size: 1.1rem; /* Smaller font */
        }

        .user-role {
            color: var(--primary) !important;
            font-weight: 600;
            margin-bottom: 0.5rem; /* Reduced margin */
            font-size: 0.9rem; /* Smaller font */
        }

        .user-details .small {
            color: var(--light) !important;
            opacity: 0.8;
            font-size: 0.8rem; /* Smaller font */
        }

        @keyframes spin {
            0% {
                transform: rotate(0deg);
            }

            100% {
                transform: rotate(360deg);
            }
        }

        .pulse {
            animation: pulse 2s infinite;
        }

        @keyframes pulse {
            0% {
                opacity: 1;
            }

            50% {
                opacity: 0.7;
            }

            100% {
                opacity: 1;
            }
        }

        .redirect-info {
            margin-top: 1.5rem; /* Reduced margin */
            padding: 0.75rem; /* Reduced padding */
            background: rgba(0, 212, 170, 0.1);
            border: 1px solid rgba(0, 212, 170, 0.3);
            border-radius: 8px; /* Reduced radius */
            color: var(--primary);
            font-size: 0.9rem; /* Smaller font */
        }

        [data-theme="light"] .redirect-info {
            background: rgba(0, 212, 170, 0.15);
        }

        .countdown {
            font-size: 1.25rem; /* Smaller font */
            font-weight: 600;
            color: var(--primary);
            margin: 0.25rem 0; /* Reduced margin */
        }

        /* Simple Toast Notifications */
        .toast-container {
            position: fixed;
            top: 70px; /* Lower to account for navbar */
            right: 20px;
            z-index: 9999;
        }

        .toast {
            background: var(--card-bg);
            border: 1px solid var(--card-border);
            border-radius: 8px; /* Reduced radius */
            padding: 0.75rem; /* Reduced padding */
            margin-bottom: 0.5rem;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.2); /* Reduced shadow */
            border-left: 4px solid var(--primary);
            color: var(--light);
            font-weight: 500;
            max-width: 280px; /* Smaller width */
            transform: translateX(400px);
            transition: all 0.3s ease;
            backdrop-filter: blur(10px);
            font-size: 0.85rem; /* Smaller font */
        }

        [data-theme="light"] .toast {
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
        }

        .toast.show {
            transform: translateX(0);
        }

        .toast.success {
            border-left-color: #10b981;
        }

        .toast.error {
            border-left-color: #ef4444;
        }

        .toast.warning {
            border-left-color: #f59e0b;
        }

        .toast.info {
            border-left-color: var(--primary);
        }

        @media (max-width: 768px) {
            body {
                padding-top: 50px !important; /* Even smaller on mobile */
            }

            .dashboard-section {
                padding: 20px 0;
                min-height: calc(100vh - 120px);
            }

            .loading-card {
                padding: 1.5rem 1rem;
                margin: 0.5rem;
            }

            .progress-step {
                padding: 0.4rem;
                font-size: 0.8rem;
            }

            .progress-spinner {
                width: 50px;
                height: 50px;
            }

            .user-avatar {
                width: 50px;
                height: 50px;
                font-size: 1.25rem;
            }

            .toast-container {
                top: 60px; /* Adjust for mobile navbar */
                right: 10px;
                left: 10px;
            }

            .toast {
                max-width: none;
                margin: 0 10px 0.5rem 10px;
                font-size: 0.8rem;
            }
        }

        /* Animation for card entrance */
        @keyframes fadeInUp {
            from {
                opacity: 0;
                transform: translateY(20px);
            }

            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        .loading-card {
            animation: fadeInUp 0.4s ease-out;
        }

        /* Ensure proper text colors */
        h1, h2, h3, h4, h5, h6 {
            color: var(--light) !important;
        }

        p, span, small {
            color: var(--light) !important;
        }

        .text-muted {
            color: var(--light) !important;
            opacity: 0.8 !important;
        }
    </style>

    <!-- Toast Container -->
    <div class="toast-container" id="toastContainer"></div>

    <section class="dashboard-section">
        <div class="container">
            <div class="row justify-content-center">
                <div class="col-lg-6 col-md-8 col-sm-10">
                    <div class="loading-card">
                        <!-- User Info -->
                        <asp:Panel ID="pnlUserInfo" runat="server" CssClass="user-info">
                            <div class="user-avatar" id="userAvatar" runat="server">
                                <!-- Initials will be set by code-behind -->
                            </div>
                            <div class="user-details">
                                <h4 id="userName" runat="server">Loading...</h4>
                                <div class="user-role" id="userRole" runat="server">Checking account...</div>
                                <div class="small text-muted" id="userEmail" runat="server">Loading user information...</div>
                            </div>
                        </asp:Panel>

                        <!-- Progress Container -->
                        <div class="progress-container">
                            <div class="progress-spinner"></div>

                            <div class="progress-text">
                                <div class="progress-step active" id="step1">
                                    <div class="step-icon">
                                        <i class="fas fa-sync fa-spin"></i>
                                    </div>
                                    <div class="step-text">
                                        <strong>Checking Account</strong>
                                        <small>Verifying your credentials and role...</small>
                                    </div>
                                </div>

                                <div class="progress-step" id="step2">
                                    <div class="step-icon">
                                        <i class="fas fa-clock"></i>
                                    </div>
                                    <div class="step-text">
                                        <strong>Loading Dashboard</strong>
                                        <small>Preparing your personalized interface...</small>
                                    </div>
                                </div>

                                <div class="progress-step" id="step3">
                                    <div class="step-icon">
                                        <i class="fas fa-rocket"></i>
                                    </div>
                                    <div class="step-text">
                                        <strong>Redirecting</strong>
                                        <small>Taking you to your dashboard...</small>
                                    </div>
                                </div>
                            </div>

                            <!-- Redirect Info -->
                            <div class="redirect-info">
                                <i class="fas fa-info-circle me-2"></i>
                                <strong>Automatic Redirect</strong>
                                <div class="countdown" id="countdown">3</div>
                                <small>You will be automatically redirected to your dashboard</small>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <script>
        // Simple toast notification function
        function showToast(message, type = 'info', duration = 5000) {
            const toastContainer = document.getElementById('toastContainer');
            if (!toastContainer) return;

            const toast = document.createElement('div');
            toast.className = 'toast ' + type;

            // Set icon based on type
            let icon = 'fa-info-circle';
            if (type === 'success') icon = 'fa-check-circle';
            if (type === 'error') icon = 'fa-exclamation-circle';
            if (type === 'warning') icon = 'fa-exclamation-triangle';

            toast.innerHTML =
                '<div class="d-flex align-items-center">' +
                '<i class="fas ' + icon + ' me-2"></i>' +
                '<span>' + message + '</span>' +
                '</div>';

            toastContainer.appendChild(toast);

            // Show toast
            setTimeout(function () {
                toast.classList.add('show');
            }, 100);

            // Auto remove after duration
            setTimeout(function () {
                toast.classList.remove('show');
                setTimeout(function () {
                    if (toast.parentNode === toastContainer) {
                        toastContainer.removeChild(toast);
                    }
                }, 300);
            }, duration);

            // Click to dismiss
            toast.addEventListener('click', function () {
                toast.classList.remove('show');
                setTimeout(function () {
                    if (toast.parentNode === toastContainer) {
                        toastContainer.removeChild(toast);
                    }
                }, 300);
            });
        }

        // Initial welcome message
        document.addEventListener('DOMContentLoaded', function () {
            setTimeout(function () {
                showToast('Welcome! Setting up your dashboard experience...', 'info', 10000);
            }, 1000);
        });
    </script>
</asp:Content>
