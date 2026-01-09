<%@ Page Title="Dashboard" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" Inherits="Dashboard" Codebehind="Dashboard.aspx.cs" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <style>
        /* Light mode specific colors for Dashboard */
        [data-theme="light"] {
            --light-bg: #f8f9fa;
            --light-card: #ffffff;
            --light-border: #e9ecef;
            --light-text: #212529;
            --light-muted: #6c757d;
            --light-shadow: rgba(0, 0, 0, 0.1);
            --light-overlay: rgba(255, 255, 255, 0.8);
        }

        /* Dashboard Loading Section Light Mode */
        [data-theme="light"] .dashboard-loading-section {
            background: radial-gradient(ellipse at center, rgba(0, 212, 170, 0.08) 0%, transparent 70%);
        }

        [data-theme="light"] .floating-element {
            opacity: 0.2;
        }

        [data-theme="light"] .dashboard-visual::before {
            background: url('data:image/svg+xml,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100"><circle cx="50" cy="50" r="2" fill="%23000" opacity="0.05"/></svg>') repeat;
        }

        /* Loading Cards Light Mode */
        [data-theme="light"] .loading-container,
        [data-theme="light"] .progress-step-card,
        [data-theme="light"] .user-loading-card {
            background: var(--light-card) !important;
            border: 1px solid var(--light-border) !important;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.08);
        }

        /* Text Colors Light Mode */
        [data-theme="light"] .hero-title {
            background: linear-gradient(45deg, var(--light-text), var(--primary), var(--secondary));
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            text-shadow: 0 0 30px rgba(0, 212, 170, 0.2);
        }

        [data-theme="light"] .hero-subtitle,
        [data-theme="light"] .text-muted,
        [data-theme="light"] .text-white-50 {
            color: var(--light-muted) !important;
        }

        /* Dashboard Loading Specific Styles */
        .dashboard-loading-section {
            min-height: 100vh;
            display: flex;
            align-items: center;
            position: relative;
            overflow: hidden;
            background: radial-gradient(ellipse at center, rgba(0, 212, 170, 0.1) 0%, transparent 70%);
            padding-top: 100px;
        }

        .floating-element {
            position: absolute;
            font-size: 2rem;
            opacity: 0.3;
            animation: floatElement 15s ease-in-out infinite;
        }

        .element-1 {
            top: 20%;
            left: 10%;
            animation-delay: 0s;
        }

        .element-2 {
            top: 60%;
            right: 15%;
            animation-delay: 5s;
        }

        .element-3 {
            bottom: 20%;
            left: 20%;
            animation-delay: 10s;
        }

        @keyframes floatElement {
            0%, 100% {
                transform: translate(0, 0) rotate(0deg) scale(1);
            }
            25% {
                transform: translate(50px, -40px) rotate(90deg) scale(1.1);
            }
            50% {
                transform: translate(25px, -60px) rotate(180deg) scale(0.9);
            }
            75% {
                transform: translate(-40px, -30px) rotate(270deg) scale(1.05);
            }
        }

        .dashboard-visual {
            background: linear-gradient(45deg, var(--primary), var(--secondary));
            height: 400px;
            width: 100%;
            border-radius: 20px;
            position: relative;
            overflow: hidden;
            opacity: 0.8;
        }

            .dashboard-visual::before {
                content: '';
                position: absolute;
                top: 0;
                left: 0;
                right: 0;
                bottom: 0;
                background: url('data:image/svg+xml,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100"><circle cx="50" cy="50" r="2" fill="white" opacity="0.1"/></svg>') repeat;
                animation: sparkle 4s linear infinite;
            }

        @keyframes sparkle {
            0% { background-position: 0 0; }
            100% { background-position: 100px 100px; }
        }

        /* Loading Container */
        .loading-container {
            background: var(--card-bg);
            border: 1px solid var(--card-border);
            border-radius: 20px;
            backdrop-filter: blur(10px);
            position: relative;
            overflow: hidden;
        }

        .loading-badge {
            background: rgba(0, 212, 170, 0.1) !important;
            border: 1px solid rgba(0, 212, 170, 0.3);
            color: var(--primary) !important;
            backdrop-filter: blur(10px);
        }

        /* Progress Steps */
        .progress-step-card {
            background: var(--card-bg);
            border: 1px solid var(--card-border);
            border-radius: 15px;
            transition: all 0.3s ease;
            backdrop-filter: blur(10px);
            opacity: 0.7;
            position: relative;
        }

            .progress-step-card.active {
                opacity: 1;
                border-color: var(--primary);
                background: rgba(0, 212, 170, 0.05);
            }

            .progress-step-card.completed {
                opacity: 1;
                border-color: #10b981;
                background: rgba(16, 185, 129, 0.05);
            }

        .step-icon {
            width: 50px;
            height: 50px;
            background: rgba(0, 212, 170, 0.1);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            color: var(--primary);
            font-size: 1.25rem;
            flex-shrink: 0;
        }

        .progress-step-card.active .step-icon {
            background: var(--primary);
            color: white;
            animation: pulse 2s infinite;
        }

        .progress-step-card.completed .step-icon {
            background: #10b981;
            color: white;
        }

        @keyframes pulse {
            0% { transform: scale(1); }
            50% { transform: scale(1.05); }
            100% { transform: scale(1); }
        }

        /* Loading Animation */
        .loading-spinner {
            width: 80px;
            height: 80px;
            border: 4px solid transparent;
            border-top: 4px solid var(--primary);
            border-right: 4px solid var(--primary);
            border-radius: 50%;
            animation: spin 1s linear infinite;
        }

        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }

        /* Skeleton Loading */
        .skeleton {
            background: linear-gradient(90deg, 
                rgba(255, 255, 255, 0.05) 25%, 
                rgba(255, 255, 255, 0.1) 50%, 
                rgba(255, 255, 255, 0.05) 75%);
            background-size: 200% 100%;
            animation: skeletonLoading 1.5s ease-in-out infinite;
            border-radius: 4px;
        }

        .skeleton-text {
            height: 12px;
            margin-bottom: 8px;
        }

        .skeleton-title {
            height: 24px;
            width: 60%;
            margin-bottom: 16px;
        }

        .skeleton-avatar {
            width: 80px;
            height: 80px;
            border-radius: 50%;
        }

        @keyframes skeletonLoading {
            0% { background-position: -200% 0; }
            100% { background-position: 200% 0; }
        }

        /* User Loading Card */
        .user-loading-card {
            background: var(--card-bg);
            border: 1px solid var(--card-border);
            border-radius: 20px;
            backdrop-filter: blur(10px);
        }

        .user-avatar-loading {
            width: 100px;
            height: 100px;
            background: linear-gradient(45deg, var(--primary), var(--secondary));
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 2rem;
            font-weight: 600;
            margin: 0 auto;
            opacity: 0.7;
        }

        /* Countdown Display */
        .countdown-display {
            background: rgba(0, 212, 170, 0.1);
            border: 1px solid rgba(0, 212, 170, 0.3);
            border-radius: 15px;
            padding: 1.5rem;
        }

        .countdown-number {
            font-size: 3rem;
            font-weight: 700;
            color: var(--primary);
            text-shadow: 0 0 20px rgba(0, 212, 170, 0.3);
        }

        /* Progress Bar */
        .progress-bar-container {
            width: 100%;
            height: 6px;
            background: rgba(255, 255, 255, 0.1);
            border-radius: 3px;
            overflow: hidden;
            margin: 1rem 0;
        }

        .progress-bar-fill {
            height: 100%;
            background: linear-gradient(45deg, var(--primary), var(--secondary));
            border-radius: 3px;
            width: 0%;
            transition: width 0.5s ease;
        }

        /* Text Colors */
        .text-primary {
            color: var(--primary) !important;
        }

        .text-muted {
            color: rgba(255, 255, 255, 0.6) !important;
        }

        /* Responsive */
        @media (max-width: 768px) {
            .dashboard-loading-section {
                min-height: auto;
                padding: 100px 0 50px;
            }

            .floating-element {
                display: none;
            }

            .dashboard-visual {
                height: 300px;
                margin-top: 2rem;
            }

            .loading-spinner {
                width: 60px;
                height: 60px;
            }

            .step-icon {
                width: 40px;
                height: 40px;
                font-size: 1rem;
            }

            .countdown-number {
                font-size: 2.5rem;
            }
        }
    </style>

    <!-- Loading Section -->
    <section class="dashboard-loading-section">
        <div class="container">
            <div class="row align-items-center">
                <div class="col-lg-6">
                    <span class="loading-badge px-3 py-2 rounded-pill mb-3">Loading Dashboard</span>
                    <h1 class="hero-title mb-3">Almost There...</h1>
                    <p class="hero-subtitle mb-4">We're preparing your personalized dashboard experience. This will only take a moment.</p>
                    
                    <!-- Progress Bar -->
                    <div class="progress-bar-container">
                        <div class="progress-bar-fill" id="globalProgress"></div>
                    </div>
                    <small class="text-muted" id="progressText">Initializing dashboard components...</small>
                </div>
                <div class="col-lg-6 text-center">
                    <div class="dashboard-loading-visual position-relative">
                        <div class="floating-element element-1">
                            <i class="fas fa-cog fa-spin text-primary"></i>
                        </div>
                        <div class="floating-element element-2">
                            <i class="fas fa-sync fa-spin text-success"></i>
                        </div>
                        <div class="floating-element element-3">
                            <i class="fas fa-spinner fa-spin text-warning"></i>
                        </div>
                        <div class="dashboard-visual rounded-3 shadow-lg mt-4">
                            <div class="position-absolute top-50 start-50 translate-middle">
                                <div class="loading-spinner"></div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Loading Progress Container -->
            <div class="loading-container mt-5 p-4">
                <div class="row g-4">
                    <!-- Progress Steps -->
                    <div class="col-lg-8">
                        <div class="mb-4">
                            <h4 class="fw-bold mb-3 text-white">Setting Up Your Dashboard</h4>
                            <p class="text-muted">We're loading all your personalized content and settings.</p>
                        </div>

                        <!-- Step 1 -->
                        <div class="progress-step-card active p-4 mb-3" id="step1">
                            <div class="d-flex align-items-center gap-4">
                                <div class="step-icon">
                                    <i class="fas fa-user-check"></i>
                                </div>
                                <div class="flex-grow-1">
                                    <h5 class="fw-bold mb-1 text-white">Verifying Your Account</h5>
                                    <p class="text-muted mb-0">Checking permissions and loading profile data...</p>
                                </div>
                                <div class="text-end">
                                    <span class="badge bg-primary">Active</span>
                                </div>
                            </div>
                        </div>

                        <!-- Step 2 -->
                        <div class="progress-step-card p-4 mb-3" id="step2">
                            <div class="d-flex align-items-center gap-4">
                                <div class="step-icon">
                                    <i class="fas fa-chart-line"></i>
                                </div>
                                <div class="flex-grow-1">
                                    <h5 class="fw-bold mb-1 text-white">Loading Statistics</h5>
                                    <p class="text-muted mb-0">Fetching your environmental impact data...</p>
                                </div>
                                <div class="text-end">
                                    <span class="badge bg-secondary">Pending</span>
                                </div>
                            </div>
                        </div>

                        <!-- Step 3 -->
                        <div class="progress-step-card p-4 mb-3" id="step3">
                            <div class="d-flex align-items-center gap-4">
                                <div class="step-icon">
                                    <i class="fas fa-bolt"></i>
                                </div>
                                <div class="flex-grow-1">
                                    <h5 class="fw-bold mb-1 text-white">Preparing Interface</h5>
                                    <p class="text-muted mb-0">Loading widgets and dashboard components...</p>
                                </div>
                                <div class="text-end">
                                    <span class="badge bg-secondary">Pending</span>
                                </div>
                            </div>
                        </div>

                        <!-- Step 4 -->
                        <div class="progress-step-card p-4" id="step4">
                            <div class="d-flex align-items-center gap-4">
                                <div class="step-icon">
                                    <i class="fas fa-rocket"></i>
                                </div>
                                <div class="flex-grow-1">
                                    <h5 class="fw-bold mb-1 text-white">Finalizing Setup</h5>
                                    <p class="text-muted mb-0">Almost ready! Preparing for redirection...</p>
                                </div>
                                <div class="text-end">
                                    <span class="badge bg-secondary">Pending</span>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- User Info & Countdown -->
                    <div class="col-lg-4">
                        <!-- User Loading Card -->
                        <div class="user-loading-card p-4 mb-4">
                            <div class="text-center">
                                <div class="user-avatar-loading mb-3" id="userAvatar">
                                    <!-- Initials will be set by code-behind -->
                                </div>
                                <div class="skeleton skeleton-title mx-auto mb-2"></div>
                                <div class="skeleton skeleton-text mx-auto w-50 mb-3"></div>
                                <div class="d-flex flex-column gap-2">
                                    <div class="skeleton skeleton-text"></div>
                                    <div class="skeleton skeleton-text w-75"></div>
                                    <div class="skeleton skeleton-text w-50"></div>
                                </div>
                            </div>
                        </div>

                        <!-- Countdown Display -->
                        <div class="countdown-display text-center">
                            <h5 class="fw-bold mb-3 text-white">Auto Redirect In</h5>
                            <div class="countdown-number mb-2" id="countdown">5</div>
                            <p class="text-muted small">You'll be automatically redirected to your dashboard</p>
                            <div class="mt-3">
                                <button class="btn btn-outline-primary btn-sm" onclick="cancelRedirect()">
                                    <i class="fas fa-times me-2"></i>Cancel Redirect
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Loading Status -->
            <div class="row mt-4">
                <div class="col-12">
                    <div class="text-center">
                        <p class="text-muted mb-2">
                            <i class="fas fa-info-circle me-2"></i>
                            Loading your personalized dashboard content...
                        </p>
                        <div class="d-flex justify-content-center align-items-center gap-3">
                            <div class="spinner-border spinner-border-sm text-primary" role="status">
                                <span class="visually-hidden">Loading...</span>
                            </div>
                            <small class="text-muted" id="statusMessage">Fetching user data...</small>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <script>
        // Dashboard loading simulation
        document.addEventListener('DOMContentLoaded', function () {
            const steps = [
                { id: 'step1', duration: 1000, message: 'Verifying account credentials...' },
                { id: 'step2', duration: 1500, message: 'Loading environmental statistics...' },
                { id: 'step3', duration: 2000, message: 'Preparing dashboard interface...' },
                { id: 'step4', duration: 1000, message: 'Finalizing setup...' }
            ];

            let currentStep = 0;
            const progressBar = document.getElementById('globalProgress');
            const progressText = document.getElementById('progressText');
            const statusMessage = document.getElementById('statusMessage');
            const countdownElement = document.getElementById('countdown');

            // Initialize progress
            progressBar.style.width = '0%';

            // Start the loading sequence
            function startLoadingSequence() {
                if (currentStep < steps.length) {
                    const step = steps[currentStep];
                    const stepElement = document.getElementById(step.id);

                    // Update UI for current step
                    stepElement.classList.add('active');
                    statusMessage.textContent = step.message;

                    // Calculate progress
                    const progress = ((currentStep + 1) / steps.length) * 200;
                    progressBar.style.width = progress + '%';

                    // Update progress text
                    progressText.textContent = `Step ${currentStep + 1} of ${steps.length}: ${step.message}`;

                    // Simulate step completion
                    setTimeout(() => {
                        stepElement.classList.remove('active');
                        stepElement.classList.add('completed');
                        stepElement.querySelector('.badge').className = 'badge bg-success';
                        stepElement.querySelector('.badge').textContent = 'Completed';

                        currentStep++;
                        startLoadingSequence();
                    }, step.duration);
                } else {
                    // All steps completed
                    progressBar.style.width = '100%';
                    progressText.textContent = 'Dashboard ready! Redirecting...';
                    statusMessage.textContent = 'Dashboard loaded successfully!';

                    // Start countdown
                    startCountdown();
                }
            }

            // Start countdown for redirect
            function startCountdown() {
                let countdown = 5;
                countdownElement.textContent = countdown;

                const countdownInterval = setInterval(() => {
                    countdown--;
                    countdownElement.textContent = countdown;

                    if (countdown <= 0) {
                        clearInterval(countdownInterval);
                        performRedirect();
                    }
                }, 5000);
            }

            // Perform the redirect
            function performRedirect() {
                // Show final message
                statusMessage.textContent = 'Redirecting to your dashboard...';

                // In real implementation, this would redirect to the actual dashboard
                // window.location.href = '/Dashboard/Home';

                // For demo, show completion message
                setTimeout(() => {
                    showToast('Dashboard loaded successfully!', 'success');
                    progressText.textContent = 'Click "Go to Dashboard" below to continue';

                    // Show manual redirect option
                    document.querySelector('.countdown-display').innerHTML = `
                        <h5 class="fw-bold mb-3 text-white">Ready to Go!</h5>
                        <div class="mb-3">
                            <i class="fas fa-check-circle text-success fa-3x"></i>
                        </div>
                        <p class="text-muted">Your dashboard is ready to use</p>
                        <button class="btn btn-primary" onclick="goToDashboard()">
                            <i class="fas fa-rocket me-2"></i>Go to Dashboard
                        </button>
                    `;
                }, 8000);
            }

            // Simulate user data loading
            setTimeout(() => {
                // This would normally come from code-behind
                const userName = '<%= Session["UserName"] ?? "User" %>';
                const userInitials = getUserInitials(userName);

                const avatar = document.getElementById('userAvatar');
                if (avatar && userInitials !== '??') {
                    avatar.innerHTML = userInitials;
                    avatar.style.opacity = '1';
                }
            }, 500);

            // Start the loading process
            setTimeout(startLoadingSequence, 1000);
        });

        function getUserInitials(name) {
            if (!name || name === 'User') return '??';
            return name.split(' ').map(n => n[0]).join('').toUpperCase().substring(0, 2);
        }

        function cancelRedirect() {
            if (confirm('Cancel auto-redirect and stay on this page?')) {
                showToast('Redirect cancelled. You can continue manually.', 'warning');
                document.querySelector('.countdown-display').innerHTML = `
                    <h5 class="fw-bold mb-3 text-white">Redirect Cancelled</h5>
                    <p class="text-muted">You can proceed to your dashboard manually</p>
                    <button class="btn btn-primary" onclick="goToDashboard()">
                        <i class="fas fa-arrow-right me-2"></i>Continue to Dashboard
                    </button>
                `;
            }
        }

        function goToDashboard() {
            showToast('Navigating to dashboard...', 'info');
            setTimeout(() => {
                document.querySelector('.progress-text').textContent = 'Redirecting...';
                document.querySelector('.loading-container').style.opacity = '0.7';
            }, 8000);
        }

        function showToast(message, type = 'info') {
            // Create toast element
            const toast = document.createElement('div');
            toast.className = `position-fixed top-0 end-0 m-3 p-3 rounded shadow-lg ${type === 'success' ? 'bg-success' : type === 'warning' ? 'bg-warning' : 'bg-primary'}`;
            toast.style.zIndex = '9999';
            toast.innerHTML = `
                <div class="d-flex align-items-center text-white">
                    <i class="fas fa-${type === 'success' ? 'check-circle' : type === 'warning' ? 'exclamation-triangle' : 'info-circle'} me-3"></i>
                    <span>${message}</span>
                    <button class="btn-close btn-close-white ms-3" onclick="this.parentElement.parentElement.remove()"></button>
                </div>
            `;

            document.body.appendChild(toast);

            setTimeout(() => {
                if (toast.parentNode) {
                    toast.remove();
                }
            }, 3000);
        }
    </script>
</asp:Content>