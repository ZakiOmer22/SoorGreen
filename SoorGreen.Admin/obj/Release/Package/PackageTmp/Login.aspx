<%@ Page Title="Login" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" Inherits="LoginPage" Codebehind="Login.aspx.cs" %>

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

        [data-theme="light"] .login-section {
            background: radial-gradient(ellipse at center, rgba(0, 212, 170, 0.05) 0%, transparent 70%);
        }

        .login-card {
            background: var(--card-bg);
            border: 1px solid var(--card-border);
            border-radius: 20px;
            padding: 3rem;
            transition: all 0.3s ease;
            backdrop-filter: blur(10px);
            color: var(--light);
            max-width: 450px;
            margin: 0 auto;
        }

        .login-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.3);
        }

        [data-theme="light"] .login-card:hover {
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.1);
        }

        .form-control {
            background: rgba(255, 255, 255, 0.05);
            border: 1px solid var(--card-border);
            color: var(--light);
            padding: 1rem;
            border-radius: 10px;
            transition: all 0.3s ease;
        }

        [data-theme="light"] .form-control {
            background: rgba(33, 37, 41, 0.05);
            color: var(--light);
        }

        .form-control:focus {
            background: rgba(255, 255, 255, 0.1);
            border-color: var(--primary);
            color: var(--light);
            box-shadow: 0 0 0 0.2rem rgba(0, 212, 170, 0.25);
        }

        [data-theme="light"] .form-control:focus {
            background: rgba(33, 37, 41, 0.1);
        }

        .form-control::placeholder {
            color: rgba(255, 255, 255, 0.5);
        }

        [data-theme="light"] .form-control::placeholder {
            color: rgba(33, 37, 41, 0.5);
        }

        .form-label {
            color: var(--light) !important;
            font-weight: 600;
            margin-bottom: 0.5rem;
        }

        .btn-primary {
            background: var(--primary);
            border: none;
            padding: 1rem 2rem;
            border-radius: 10px;
            font-weight: 600;
            transition: all 0.3s ease;
            color: white !important;
            width: 100%;
        }

        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 20px rgba(0, 212, 170, 0.3);
        }

        .btn-outline-hero {
            border: 2px solid var(--primary);
            color: var(--primary);
            background: transparent;
            padding: 1rem 2rem;
            border-radius: 50px;
            font-weight: 600;
            transition: all 0.3s ease;
            width: 100%;
        }

        .btn-outline-hero:hover {
            background: var(--primary);
            color: white;
            transform: translateY(-3px);
        }

        .login-icon {
            font-size: 4rem;
            color: var(--primary);
            margin-bottom: 1.5rem;
        }

        .section-badge {
            background: rgba(0, 212, 170, 0.1) !important;
            border: 1px solid rgba(0, 212, 170, 0.3);
            color: var(--primary) !important;
            backdrop-filter: blur(10px);
        }

        [data-theme="light"] .section-badge {
            background: rgba(0, 212, 170, 0.15) !important;
        }

        .hero-title {
            font-size: 2.5rem;
            font-weight: 800;
            margin-bottom: 1rem;
            background: linear-gradient(45deg, var(--light), var(--primary), var(--secondary));
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            text-shadow: 0 0 30px rgba(255, 255, 255, 0.1);
        }

        [data-theme="light"] .hero-title {
            text-shadow: 0 0 30px rgba(33, 37, 41, 0.1);
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
            color: var(--primary) !important;
            text-decoration: none;
            transition: all 0.3s ease;
        }

        .login-links a:hover {
            color: var(--light) !important;
            text-decoration: underline;
        }

        .divider {
            display: flex;
            align-items: center;
            margin: 2rem 0;
            color: var(--light) !important;
            opacity: 0.7;
        }

        .divider::before,
        .divider::after {
            content: '';
            flex: 1;
            border-bottom: 1px solid var(--card-border);
        }

        .divider span {
            padding: 0 1rem;
        }

        /* Toast Notifications - Fixed for both themes */
        .toast-container {
            position: fixed;
            top: 20px;
            right: 20px;
            z-index: 9999;
        }

        .toast {
            background: var(--card-bg);
            border: 1px solid var(--card-border);
            border-radius: 12px;
            padding: 1rem 1.5rem;
            margin-bottom: 1rem;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.3);
            border-left: 4px solid var(--primary);
            color: var(--light);
            font-weight: 500;
            max-width: 350px;
            transform: translateX(400px);
            transition: all 0.3s ease;
            backdrop-filter: blur(10px);
            display: flex;
            align-items: center;
            gap: 0.75rem;
        }

        [data-theme="light"] .toast {
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.15);
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

        .toast-icon {
            font-size: 1.25rem;
            flex-shrink: 0;
        }

        .toast.success .toast-icon {
            color: #10b981;
        }

        .toast.error .toast-icon {
            color: #ef4444;
        }

        .toast.warning .toast-icon {
            color: #f59e0b;
        }

        .toast.info .toast-icon {
            color: var(--primary);
        }

        .toast-content {
            flex: 1;
        }

        .toast-close {
            background: none;
            border: none;
            color: var(--light);
            opacity: 0.7;
            cursor: pointer;
            padding: 0.25rem;
            border-radius: 4px;
            transition: all 0.3s ease;
            flex-shrink: 0;
        }

        .toast-close:hover {
            opacity: 1;
            background: rgba(255, 255, 255, 0.1);
        }

        [data-theme="light"] .toast-close:hover {
            background: rgba(33, 37, 41, 0.1);
        }

        /* Text visibility fixes */
        .text-muted {
            color: var(--light) !important;
            opacity: 0.8 !important;
        }

        .form-check-label {
            color: var(--light) !important;
            opacity: 0.9 !important;
        }

        .stat-item h4 {
            color: var(--light) !important;
        }

        .stat-item small {
            color: var(--light) !important;
            opacity: 0.7 !important;
        }

        /* Features Section */
        .features-section {
            padding: 4rem 0;
            background: var(--card-bg);
        }

        .feature-card {
            background: var(--card-bg);
            border: 1px solid var(--card-border);
            border-radius: 15px;
            padding: 2rem;
            text-align: center;
            transition: all 0.3s ease;
            height: 100%;
        }

        .feature-card:hover {
            transform: translateY(-5px);
            border-color: var(--primary);
        }

        [data-theme="light"] .feature-card:hover {
            box-shadow: 0 10px 25px rgba(0, 0, 0, 0.1);
        }

        .feature-icon {
            font-size: 2.5rem;
            color: var(--primary);
            margin-bottom: 1rem;
        }

        /* Form Check Styles */
        .form-check-input {
            background-color: var(--card-bg);
            border: 1px solid var(--card-border);
        }

        .form-check-input:checked {
            background-color: var(--primary);
            border-color: var(--primary);
        }

        /* Stats colors */
        .text-primary { color: var(--primary) !important; }
        .text-success { color: #10b981 !important; }
        .text-warning { color: #f59e0b !important; }

        /* Additional Light Mode Specific Styles */
        [data-theme="light"] .login-card,
        [data-theme="light"] .feature-card {
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
        }

        [data-theme="light"] .form-control,
        [data-theme="light"] .form-select {
            color: var(--light) !important;
        }

        /* Link styles */
        .login-links a {
            color: var(--primary) !important;
        }

        .login-links a:hover {
            color: var(--light) !important;
        }

        /* Headings and text */
        h1, h2, h3, h4, h5, h6 {
            color: var(--light) !important;
        }

        p, span {
            color: var(--light) !important;
            opacity: 0.9 !important;
        }

        /* Password toggle */
        .password-toggle {
            position: absolute;
            right: 1rem;
            top: 50%;
            transform: translateY(-50%);
            background: none;
            border: none;
            color: var(--light);
            opacity: 0.7;
            cursor: pointer;
            z-index: 2;
        }

        .password-toggle:hover {
            opacity: 1;
        }

        .password-input-container {
            position: relative;
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
                margin: 0 10px 1rem 10px;
            }
            
            .login-links {
                display: flex;
                flex-direction: column;
                gap: 1rem;
            }
            
            .login-links a {
                display: block;
            }
        }

        /* Stats border */
        .stats-border {
            border-top: 1px solid var(--card-border);
        }

        /* Feature card text */
        .feature-card h4 {
            margin-bottom: 1rem;
        }

        .feature-card p {
            opacity: 0.8;
        }

        /* Button focus states */
        .btn-primary:focus,
        .btn-outline-hero:focus {
            outline: none;
            box-shadow: 0 0 0 0.2rem rgba(0, 212, 170, 0.25);
        }

        /* Form group spacing */
        .form-group {
            margin-bottom: 1.5rem;
        }

        /* Animation for form elements */
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

        .login-card {
            animation: fadeInUp 0.6s ease-out;
        }

        /* Toast animations */
        @keyframes slideInRight {
            from {
                transform: translateX(400px);
                opacity: 0;
            }
            to {
                transform: translateX(0);
                opacity: 1;
            }
        }

        @keyframes slideOutRight {
            from {
                transform: translateX(0);
                opacity: 1;
            }
            to {
                transform: translateX(400px);
                opacity: 0;
            }
        }

        .toast.show {
            animation: slideInRight 0.3s ease-out;
        }

        .toast.hide {
            animation: slideOutRight 0.3s ease-in;
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
                                    <div class="password-input-container">
                                        <asp:TextBox ID="txtPassword" runat="server" CssClass="form-control" 
                                            placeholder="Enter your password" TextMode="Password"></asp:TextBox>
                                        <button type="button" class="password-toggle" onclick="togglePassword('txtPassword')">
                                            <i class="fas fa-eye"></i>
                                        </button>
                                    </div>
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
                        <div class="mt-5 pt-4 stats-border">
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
                    <h2 class="fw-bold mb-3">Why Join SoorGreen?</h2>
                    <p class="lead">Discover the benefits of being part of our sustainability community</p>
                </div>
            </div>
            <div class="row g-4">
                <div class="col-lg-4 col-md-6">
                    <div class="feature-card">
                        <div class="feature-icon">
                            <i class="fas fa-leaf"></i>
                        </div>
                        <h4 class="mb-3">Environmental Impact</h4>
                        <p>Track your personal contribution to reducing waste and creating sustainable communities. See real-time metrics of your environmental footprint.</p>
                    </div>
                </div>
                <div class="col-lg-4 col-md-6">
                    <div class="feature-card">
                        <div class="feature-icon">
                            <i class="fas fa-award"></i>
                        </div>
                        <h4 class="mb-3">Earn Rewards</h4>
                        <p>Get XP credits for your recycling efforts that can be redeemed for discounts, vouchers, and exclusive partner benefits.</p>
                    </div>
                </div>
                <div class="col-lg-4 col-md-6">
                    <div class="feature-card">
                        <div class="feature-icon">
                            <i class="fas fa-chart-line"></i>
                        </div>
                        <h4 class="mb-3">Track Progress</h4>
                        <p>Monitor your recycling habits, set goals, and see your environmental impact grow over time with detailed analytics.</p>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <script>
        // Toast notification function
        function showToast(message, type = 'info', duration = 5000) {
            const toastContainer = document.getElementById('toastContainer');
            const toast = document.createElement('div');
            toast.className = `toast ${type}`;

            const icons = {
                success: 'fa-check-circle',
                error: 'fa-exclamation-circle',
                warning: 'fa-exclamation-triangle',
                info: 'fa-info-circle'
            };

            toast.innerHTML = `
                <div class="toast-icon">
                    <i class="fas ${icons[type]}"></i>
                </div>
                <div class="toast-content">
                    ${message}
                </div>
                <button class="toast-close" onclick="this.parentElement.remove()">
                    <i class="fas fa-times"></i>
                </button>
            `;

            toastContainer.appendChild(toast);

            // Show toast with animation
            setTimeout(() => toast.classList.add('show'), 100);

            // Auto remove after duration
            if (duration > 0) {
                setTimeout(() => {
                    toast.classList.remove('show');
                    toast.classList.add('hide');
                    setTimeout(() => toast.remove(), 300);
                }, duration);
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
                showToast('Please check the form for errors', 'warning', 4000);
            } else {
                showToast('Signing you in...', 'info', 2000);
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

        // Password visibility toggle
        function togglePassword(fieldId) {
            const field = document.getElementById(fieldId);
            const toggle = field.nextElementSibling;
            const icon = toggle.querySelector('i');

            if (field.type === 'password') {
                field.type = 'text';
                icon.className = 'fas fa-eye-slash';
                showToast('Password is now visible', 'info', 2000);
            } else {
                field.type = 'password';
                icon.className = 'fas fa-eye';
            }
        }

        // Demo toast on page load
        document.addEventListener('DOMContentLoaded', function () {
            setTimeout(() => {
                showToast('Welcome back! Ready to continue your sustainability journey?', 'info', 4000);
            }, 1000);

            // Add focus effects to form inputs
            const inputs = document.querySelectorAll('.form-control');
            inputs.forEach(input => {
                input.addEventListener('focus', function () {
                    this.style.transform = 'scale(1.02)';
                });

                input.addEventListener('blur', function () {
                    this.style.transform = 'scale(1)';
                });
            });
        });

        // Demo function to show different toast types
        function demoToasts() {
            showToast('Login successful! Redirecting to dashboard...', 'success', 3000);
            setTimeout(() => {
                showToast('Invalid email or password', 'error', 4000);
            }, 3500);
            setTimeout(() => {
                showToast('Your session will expire soon', 'warning', 5000);
            }, 8000);
        }
    </script>
</asp:Content>