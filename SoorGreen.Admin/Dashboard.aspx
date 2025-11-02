<%@ Page Title="Dashboard" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeFile="Dashboard.aspx.cs" Inherits="Dashboard" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <style>
        .dashboard-section {
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            position: relative;
            overflow: hidden;
            background: radial-gradient(ellipse at center, rgba(0, 212, 170, 0.1) 0%, transparent 70%);
            padding: 100px 0;
        }

        .loading-card {
            background: rgba(255, 255, 255, 0.05);
            border: 1px solid rgba(255, 255, 255, 0.2);
            border-radius: 20px;
            padding: 3rem;
            transition: all 0.3s ease;
            backdrop-filter: blur(10px);
            color: white;
            text-align: center;
            max-width: 500px;
            margin: 0 auto;
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
            border: 4px solid rgba(255, 255, 255, 0.1);
            border-left: 4px solid #00d4aa;
            border-radius: 50%;
            animation: spin 1s linear infinite;
        }

        .progress-text {
            display: flex;
            flex-direction: column;
            gap: 0.5rem;
        }

        .progress-step {
            display: flex;
            align-items: center;
            gap: 1rem;
            padding: 0.75rem 1rem;
            background: rgba(255, 255, 255, 0.05);
            border-radius: 10px;
            border: 1px solid rgba(255, 255, 255, 0.1);
            transition: all 0.3s ease;
        }

        .progress-step.active {
            border-color: #00d4aa;
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
            background: rgba(255, 255, 255, 0.1);
            border: 1px solid rgba(255, 255, 255, 0.2);
        }

        .progress-step.active .step-icon {
            background: #00d4aa;
            border-color: #00d4aa;
        }

        .progress-step.completed .step-icon {
            background: #10b981;
            border-color: #10b981;
        }

        .step-text {
            flex: 1;
            text-align: left;
        }

        .user-info {
            background: rgba(255, 255, 255, 0.05);
            border: 1px solid rgba(255, 255, 255, 0.2);
            border-radius: 15px;
            padding: 1.5rem;
            margin-bottom: 2rem;
            text-align: center;
        }

        .user-avatar {
            width: 80px;
            height: 80px;
            border-radius: 50%;
            background: linear-gradient(45deg, #00d4aa, #0077b6);
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 2rem;
            font-weight: 600;
            margin: 0 auto 1rem;
        }

        .user-details h4 {
            margin-bottom: 0.5rem;
            color: white !important;
        }

        .user-role {
            color: #00d4aa !important;
            font-weight: 600;
            margin-bottom: 1rem;
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
            50% { opacity: 0.5; }
            100% { opacity: 1; }
        }

        .redirect-info {
            margin-top: 2rem;
            padding: 1rem;
            background: rgba(0, 212, 170, 0.1);
            border: 1px solid rgba(0, 212, 170, 0.3);
            border-radius: 10px;
            color: #00d4aa;
        }

        .countdown {
            font-size: 1.5rem;
            font-weight: 600;
            color: #00d4aa;
            margin: 0.5rem 0;
        }

        @media (max-width: 768px) {
            .loading-card {
                padding: 2rem 1.5rem;
                margin: 1rem;
            }
            
            .progress-step {
                padding: 0.5rem;
            }
        }
    </style>

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
        document.addEventListener('DOMContentLoaded', function () {
            let countdown = 3;
            const countdownElement = document.getElementById('countdown');
            const steps = document.querySelectorAll('.progress-step');

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

                if (currentStep >= steps.length) {
                    clearInterval(progressInterval);
                    startCountdown();
                }
            }, 1500);

            // Countdown function
            function startCountdown() {
                const countdownInterval = setInterval(function () {
                    countdown--;
                    if (countdownElement) {
                        countdownElement.textContent = countdown;
                    }

                    if (countdown <= 0) {
                        clearInterval(countdownInterval);
                        // The actual redirect will be handled by server-side
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