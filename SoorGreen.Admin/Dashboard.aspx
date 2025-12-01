<%@ Page Title="Dashboard" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeFile="Dashboard.aspx.cs" Inherits="Dashboard" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <style>
        /* Fix for navbar spacing */
        .content-wrapper {
            padding-top: 120px !important;
        }

        .dashboard-section {
            min-height: calc(100vh - 200px);
            display: flex;
            align-items: center;
            justify-content: center;
            position: relative;
            overflow: hidden;
            background: radial-gradient(ellipse at center, rgba(0, 212, 170, 0.1) 0%, transparent 70%);
            padding: 50px 0;
        }

        [data-theme="light"] .dashboard-section {
            background: radial-gradient(ellipse at center, rgba(0, 212, 170, 0.05) 0%, transparent 70%);
        }

        .loading-card {
            background: var(--card-bg);
            border: 1px solid var(--card-border);
            border-radius: 20px;
            padding: 3rem;
            transition: all 0.3s ease;
            backdrop-filter: blur(10px);
            color: var(--light);
            text-align: center;
            max-width: 500px;
            margin: 0 auto;
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.3);
        }

        [data-theme="light"] .loading-card {
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.1);
        }

        .progress-container {
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 2rem;
        }

        .progress-spinner {
            width: 80px;
            height: 80px;
            border: 4px solid var(--card-border);
            border-left: 4px solid var(--primary);
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
            gap: 1rem;
            padding: 0.75rem 1rem;
            background: var(--card-bg);
            border-radius: 10px;
            border: 1px solid var(--card-border);
            transition: all 0.3s ease;
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
            width: 24px;
            height: 24px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 0.75rem;
            background: var(--card-bg);
            border: 1px solid var(--card-border);
            color: var(--light);
            transition: all 0.3s ease;
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
        }

        .step-text strong {
            color: var(--light) !important;
            display: block;
            margin-bottom: 0.25rem;
        }

        .step-text small {
            color: var(--light) !important;
            opacity: 0.8;
        }

        .user-info {
            background: var(--card-bg);
            border: 1px solid var(--card-border);
            border-radius: 15px;
            padding: 1.5rem;
            margin-bottom: 2rem;
            text-align: center;
        }

        .user-avatar {
            width: 80px;
            height: 80px;
            border-radius: 50%;
            background: linear-gradient(45deg, var(--primary), var(--secondary));
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 2rem;
            font-weight: 600;
            margin: 0 auto 1rem;
            box-shadow: 0 8px 20px rgba(0, 212, 170, 0.3);
        }

        .user-details h4 {
            margin-bottom: 0.5rem;
            color: var(--light) !important;
        }

        .user-role {
            color: var(--primary) !important;
            font-weight: 600;
            margin-bottom: 1rem;
        }

        .user-details .small {
            color: var(--light) !important;
            opacity: 0.8;
        }

        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }

        .pulse {
            animation: pulse 2s infinite;
        }

        @keyframes pulse {
            0% { opacity: 1; }
            50% { opacity: 0.7; }
            100% { opacity: 1; }
        }

        .redirect-info {
            margin-top: 2rem;
            padding: 1rem;
            background: rgba(0, 212, 170, 0.1);
            border: 1px solid rgba(0, 212, 170, 0.3);
            border-radius: 10px;
            color: var(--primary);
        }

        [data-theme="light"] .redirect-info {
            background: rgba(0, 212, 170, 0.15);
        }

        .countdown {
            font-size: 1.5rem;
            font-weight: 600;
            color: var(--primary);
            margin: 0.5rem 0;
        }

        /* Simple Toast Notifications - Fixed */
        .toast-container {
            position: fixed;
            top: 20px;
            right: 20px;
            z-index: 9999;
        }

        .toast {
            background: var(--card-bg);
            border: 1px solid var(--card-border);
            border-radius: 10px;
            padding: 1rem;
            margin-bottom: 0.5rem;
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.3);
            border-left: 4px solid var(--primary);
            color: var(--light);
            font-weight: 500;
            max-width: 300px;
            transform: translateX(400px);
            transition: all 0.3s ease;
            backdrop-filter: blur(10px);
        }

        [data-theme="light"] .toast {
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.15);
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
            .content-wrapper {
                padding-top: 100px !important;
            }

            .dashboard-section {
                padding: 30px 0;
                min-height: calc(100vh - 150px);
            }

            .loading-card {
                padding: 2rem 1.5rem;
                margin: 1rem;
            }
            
            .progress-step {
                padding: 0.5rem;
            }
            
            .progress-spinner {
                width: 60px;
                height: 60px;
            }
            
            .user-avatar {
                width: 60px;
                height: 60px;
                font-size: 1.5rem;
            }

            .toast-container {
                top: 10px;
                right: 10px;
                left: 10px;
            }
            
            .toast {
                max-width: none;
                margin: 0 10px 0.5rem 10px;
            }
        }

        /* Animation for card entrance */
        @keyframes fadeInUp {
            from {
                opacity: 0;
                transform: translateY(30px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        .loading-card {
            animation: fadeInUp 0.6s ease-out;
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
                <div class="col-lg-6">
                    <div class="loading-card">
                        <!-- User Info -->
                        <asp:Panel ID="pnlUserInfo" runat="server" CssClass="user-info">
                            <div class="user-avatar" id="userAvatar" runat="server">
                                <i class="fas fa-user"></i>
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
        // Simple toast notification function - Fixed
        function showToast(message, type = 'info', duration = 3000) {
            const toastContainer = document.getElementById('toastContainer');
            const toast = document.createElement('div');
            toast.className = `toast ${type}`;
            toast.innerHTML = message;

            toastContainer.appendChild(toast);

            // Show toast
            setTimeout(() => toast.classList.add('show'), 100);

            // Auto remove after duration
            setTimeout(() => {
                toast.classList.remove('show');
                setTimeout(() => {
                    if (toast.parentNode) {
                        toast.parentNode.removeChild(toast);
                    }
                }, 300);
            }, duration);
        }

        document.addEventListener('DOMContentLoaded', function () {
            let countdown = 3;
            const countdownElement = document.getElementById('countdown');
            const steps = document.querySelectorAll('.progress-step');

            // Show welcome toast
            setTimeout(() => {
                showToast('Welcome! Preparing your dashboard...', 'info');
            }, 500);

            // Function to update progress steps
            function updateProgress(currentStep) {
                for (let i = 0; i < steps.length; i++) {
                    if (i < currentStep) {
                        steps[i].classList.remove('active');
                        steps[i].classList.add('completed');
                        var stepIcon = steps[i].querySelector('.step-icon');
                        if (stepIcon) {
                            stepIcon.innerHTML = '<i class="fas fa-check"></i>';
                        }
                    } else if (i === currentStep) {
                        steps[i].classList.add('active');
                        steps[i].classList.remove('completed');
                        var stepIcon = steps[i].querySelector('.step-icon');
                        if (stepIcon) {
                            stepIcon.innerHTML = '<i class="fas fa-sync fa-spin"></i>';
                        }
                    } else {
                        steps[i].classList.remove('active', 'completed');
                        var stepIcon = steps[i].querySelector('.step-icon');
                        if (stepIcon) {
                            stepIcon.innerHTML = '<i class="fas fa-clock"></i>';
                        }
                    }
                }
            }

            // Start the progress animation
            let currentStep = 0;
            updateProgress(currentStep);

            // Simulate progress steps
            const progressInterval = setInterval(function () {
                currentStep++;
                updateProgress(currentStep);

                if (currentStep === 1) {
                    showToast('Account verified successfully!', 'success');
                } else if (currentStep === 2) {
                    showToast('Dashboard loaded successfully!', 'success');
                }

                if (currentStep >= steps.length) {
                    clearInterval(progressInterval);
                    startCountdown();
                }
            }, 1500);

            // Countdown function
            function startCountdown() {
                showToast('Redirecting to your dashboard...', 'info');
                const countdownInterval = setInterval(function () {
                    countdown--;
                    if (countdownElement) {
                        countdownElement.textContent = countdown;
                    }

                    if (countdown <= 0) {
                        clearInterval(countdownInterval);
                        // The actual redirect will be handled by server-side
                        showToast('Redirecting now!', 'success');
                    }
                }, 1000);
            }

            // Add pulsing animation to redirect info
            const redirectInfo = document.querySelector('.redirect-info');
            if (redirectInfo) {
                redirectInfo.classList.add('pulse');
            }
        });
    </script>
</asp:Content>