<%@ Page Title="Login" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeFile="Login.aspx.cs" Inherits="LoginPage" %>


<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <style>
        .login-section {
            min-height: 100vh;
            display: flex;
            align-items: center;
            position: relative;
            overflow: hidden;
            background: radial-gradient(ellipse at center, rgba(0, 212, 170, 0.1) 0%, transparent 70%);
            padding: 100px 0;
        }

        .login-card {
            background: rgba(255, 255, 255, 0.05);
            border: 1px solid rgba(255, 255, 255, 0.2);
            border-radius: 20px;
            padding: 3rem;
            transition: all 0.3s ease;
            backdrop-filter: blur(10px);
            color: white;
            max-width: 450px;
            margin: 0 auto;
        }

        .login-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.3);
        }

        .form-control {
            background: rgba(255, 255, 255, 0.05);
            border: 1px solid rgba(255, 255, 255, 0.2);
            color: white;
            padding: 1rem;
            border-radius: 10px;
            transition: all 0.3s ease;
        }

        .form-control:focus {
            background: rgba(255, 255, 255, 0.1);
            border-color: #00d4aa;
            color: white;
            box-shadow: 0 0 0 0.2rem rgba(0, 212, 170, 0.25);
        }

        .form-control::placeholder {
            color: rgba(255, 255, 255, 0.5);
        }

        .form-label {
            color: white !important;
            font-weight: 600;
            margin-bottom: 0.5rem;
        }

        .btn-primary {
            background: #00d4aa;
            border: none;
            padding: 1rem 2rem;
            border-radius: 10px;
            font-weight: 600;
            transition: all 0.3s ease;
            color: white;
            width: 100%;
        }

        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 20px rgba(0, 212, 170, 0.3);
        }

        .btn-outline-hero {
            border: 2px solid #00d4aa;
            color: #00d4aa;
            background: transparent;
            padding: 1rem 2rem;
            border-radius: 50px;
            font-weight: 600;
            transition: all 0.3s ease;
            width: 100%;
        }

        .btn-outline-hero:hover {
            background: #00d4aa;
            color: white;
            transform: translateY(-3px);
        }

        .login-icon {
            font-size: 4rem;
            color: #00d4aa;
            margin-bottom: 1.5rem;
        }

        .section-badge {
            background: rgba(0, 212, 170, 0.1);
            border: 1px solid rgba(0, 212, 170, 0.3);
            color: #00d4aa !important;
            backdrop-filter: blur(10px);
        }

        .hero-title {
            font-size: 2.5rem;
            font-weight: 800;
            margin-bottom: 1rem;
            background: linear-gradient(45deg, #ffffff, #00d4aa, #0077b6);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            text-shadow: 0 0 30px rgba(255, 255, 255, 0.1);
        }

        .error-message {
            color: #ef4444 !important;
            font-size: 0.875rem;
            margin-top: 0.25rem;
            display: none;
        }

        .login-links {
            text-align: center;
            margin-top: 2rem;
        }

        .login-links a {
            color: #00d4aa !important;
            text-decoration: none;
            transition: all 0.3s ease;
        }

        .login-links a:hover {
            color: white !important;
            text-decoration: underline;
        }

        .divider {
            display: flex;
            align-items: center;
            margin: 2rem 0;
            color: rgba(255, 255, 255, 0.7) !important;
        }

        .divider::before,
        .divider::after {
            content: '';
            flex: 1;
            border-bottom: 1px solid rgba(255, 255, 255, 0.2);
        }

        .divider span {
            padding: 0 1rem;
        }

        /* Toast Notifications */
        .toast-container {
            position: fixed;
            top: 20px;
            right: 20px;
            z-index: 9999;
        }

        .toast {
            background: rgba(255, 255, 255, 0.95);
            border-radius: 10px;
            padding: 1rem 1.5rem;
            margin-bottom: 1rem;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.3);
            border-left: 4px solid #00d4aa;
            color: #333;
            font-weight: 500;
            max-width: 350px;
            transform: translateX(400px);
            transition: all 0.3s ease;
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

        /* Text visibility fixes */
        .text-muted {
            color: rgba(255, 255, 255, 0.8) !important;
        }

        .form-check-label {
            color: rgba(255, 255, 255, 0.9) !important;
        }

        .stat-item h4 {
            color: white !important;
        }

        .stat-item small {
            color: rgba(255, 255, 255, 0.7) !important;
        }

        /* Features Section */
        .features-section {
            padding: 4rem 0;
            background: rgba(255, 255, 255, 0.02);
        }

        .feature-card {
            background: rgba(255, 255, 255, 0.05);
            border: 1px solid rgba(255, 255, 255, 0.1);
            border-radius: 15px;
            padding: 2rem;
            text-align: center;
            transition: all 0.3s ease;
            height: 100%;
        }

        .feature-card:hover {
            transform: translateY(-5px);
            border-color: #00d4aa;
        }

        .feature-icon {
            font-size: 2.5rem;
            color: #00d4aa;
            margin-bottom: 1rem;
        }

        @media (max-width: 768px) {
            .login-card {
                padding: 2rem 1.5rem;
                margin: 0 1rem;
            }
            
            .hero-title {
                font-size: 2rem;
            }
            
            .toast-container {
                top: 10px;
                right: 10px;
                left: 10px;
            }
            
            .toast {
                max-width: none;
            }
        }
    </style>

    <!-- Toast Container -->
    <div class="toast-container" id="toastContainer"></div>

    <section class="login-section">
        <div class="container">
            <div class="row justify-content-center">
                <div class="col-lg-5 col-md-7">
                    <div class="login-card">
                        <!-- Header -->
                        <div class="text-center mb-5">
                            <div class="login-icon">
                                <i class="fas fa-recycle"></i>
                            </div>
                            <span class="section-badge px-3 py-2 rounded-pill mb-3">Welcome Back</span>
                            <h1 class="hero-title mb-3">Sign In to SoorGreen</h1>
                            <p class="text-muted">Continue your sustainability journey with us. Track your impact, earn rewards, and help create cleaner communities.</p>
                        </div>

                        <!-- Login Form -->
                        <div class="login-form">
                            <div class="row g-3">
                                <div class="col-12">
                                    <label class="form-label">Email Address *</label>
                                    <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control" 
                                        placeholder="Enter your email address" TextMode="Email"></asp:TextBox>
                                    <div id="errorEmail" class="error-message">Valid email address is required</div>
                                </div>

                                <div class="col-12">
                                    <label class="form-label">Password *</label>
                                    <asp:TextBox ID="txtPassword" runat="server" CssClass="form-control" 
                                        placeholder="Enter your password" TextMode="Password"></asp:TextBox>
                                    <div id="errorPassword" class="error-message">Password is required</div>
                                </div>

                                <div class="col-12">
                                    <div class="form-check">
                                        <asp:CheckBox ID="cbRememberMe" runat="server" CssClass="form-check-input" />
                                        <label class="form-check-label" for="<%= cbRememberMe.ClientID %>">
                                            Remember me for 30 days
                                        </label>
                                    </div>
                                </div>

                                <div class="col-12 mt-4">
                                    <asp:Button ID="btnLogin" runat="server" Text="Sign In to Your Account" 
                                        CssClass="btn btn-primary" OnClick="btnLogin_Click" 
                                        OnClientClick="return validateLogin();" />
                                </div>

                                <div class="col-12">
                                    <div class="login-links">
                                        <a href="ForgotPassword.aspx" class="me-3">
                                            <i class="fas fa-key me-1"></i>Forgot your password?
                                        </a>
                                        <a href="Contact.aspx">
                                            <i class="fas fa-headset me-1"></i>Need help?
                                        </a>
                                    </div>
                                </div>

                                <div class="col-12">
                                    <div class="divider">
                                        <span>New to SoorGreen?</span>
                                    </div>
                                </div>

                                <div class="col-12">
                                    <a href="Register.aspx" class="btn btn-outline-hero">
                                        <i class="fas fa-user-plus me-2"></i>Create New Account
                                    </a>
                                </div>
                            </div>
                        </div>

                        <!-- Quick Stats -->
                        <div class="mt-5 pt-4 border-top border-secondary">
                            <div class="row text-center">
                                <div class="col-4">
                                    <div class="stat-item">
                                        <h4 class="fw-bold text-primary mb-1">10K+</h4>
                                        <small class="text-muted">Active Users</small>
                                    </div>
                                </div>
                                <div class="col-4">
                                    <div class="stat-item">
                                        <h4 class="fw-bold text-success mb-1">500+</h4>
                                        <small class="text-muted">Waste Collectors</small>
                                    </div>
                                </div>
                                <div class="col-4">
                                    <div class="stat-item">
                                        <h4 class="fw-bold text-warning mb-1">100K+</h4>
                                        <small class="text-muted">Kg Recycled</small>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Features Section -->
    <section class="features-section">
        <div class="container">
            <div class="row text-center mb-5">
                <div class="col-lg-8 mx-auto">
                    <h2 class="fw-bold text-white mb-3">Why Join SoorGreen?</h2>
                    <p class="text-muted lead">Discover the benefits of being part of our sustainability community</p>
                </div>
            </div>
            <div class="row g-4">
                <div class="col-lg-4 col-md-6">
                    <div class="feature-card">
                        <div class="feature-icon">
                            <i class="fas fa-leaf"></i>
                        </div>
                        <h4 class="text-white mb-3">Environmental Impact</h4>
                        <p class="text-muted">Track your personal contribution to reducing waste and creating sustainable communities. See real-time metrics of your environmental footprint.</p>
                    </div>
                </div>
                <div class="col-lg-4 col-md-6">
                    <div class="feature-card">
                        <div class="feature-icon">
                            <i class="fas fa-award"></i>
                        </div>
                        <h4 class="text-white mb-3">Earn Rewards</h4>
                        <p class="text-muted">Get XP credits for your recycling efforts that can be redeemed for discounts, vouchers, and exclusive partner benefits.</p>
                    </div>
                </div>
                <div class="col-lg-4 col-md-6">
                    <div class="feature-card">
                        <div class="feature-icon">
                            <i class="fas fa-chart-line"></i>
                        </div>
                        <h4 class="text-white mb-3">Track Progress</h4>
                        <p class="text-muted">Monitor your recycling habits, set goals, and see your environmental impact grow over time with detailed analytics.</p>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <script>
        // Toast notification function
        function showToast(message, type = 'info') {
            const toastContainer = document.getElementById('toastContainer');
            const toast = document.createElement('div');
            toast.className = `toast ${type}`;
            toast.innerHTML = `
                <div class="d-flex align-items-center">
                    <i class="fas ${getToastIcon(type)} me-2"></i>
                    <span>${message}</span>
                </div>
            `;

            toastContainer.appendChild(toast);

            // Show toast
            setTimeout(() => toast.classList.add('show'), 100);

            // Remove toast after 5 seconds
            setTimeout(() => {
                toast.classList.remove('show');
                setTimeout(() => toast.remove(), 300);
            }, 5000);
        }

        function getToastIcon(type) {
            switch (type) {
                case 'success': return 'fa-check-circle';
                case 'error': return 'fa-exclamation-circle';
                case 'warning': return 'fa-exclamation-triangle';
                default: return 'fa-info-circle';
            }
        }

        function validateLogin() {
            let isValid = true;

            // Reset errors
            hideAllErrors();

            // Validate Email
            const email = document.getElementById('<%= txtEmail.ClientID %>').value.trim();
            if (!email || !isValidEmail(email)) {
                showError('errorEmail', 'Valid email address is required');
                isValid = false;
            }
            
            // Validate Password
            const password = document.getElementById('<%= txtPassword.ClientID %>').value;
            if (!password) {
                showError('errorPassword', 'Password is required');
                isValid = false;
            }

            if (!isValid) {
                showToast('Please fix the errors above', 'warning');
            }

            return isValid;
        }

        function isValidEmail(email) {
            const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            return emailRegex.test(email);
        }

        function showError(errorId, message) {
            const errorElement = document.getElementById(errorId);
            errorElement.textContent = message;
            errorElement.style.display = 'block';
        }

        function hideAllErrors() {
            document.querySelectorAll('.error-message').forEach(error => {
                error.style.display = 'none';
            });
        }

        // Add some interactive effects
        document.addEventListener('DOMContentLoaded', function () {
            const inputs = document.querySelectorAll('.form-control');
            inputs.forEach(input => {
                input.addEventListener('focus', function () {
                    this.parentElement.classList.add('focused');
                });

                input.addEventListener('blur', function () {
                    if (!this.value) {
                        this.parentElement.classList.remove('focused');
                    }
                });
            });

            // Demo toast on page load
            setTimeout(() => {
                showToast('Welcome back! Sign in to continue your sustainability journey.', 'info');
            }, 1000);
        });
    </script>
</asp:Content>