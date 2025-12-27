<%@ Page Title="Register" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" Inherits="RegistrationForm" Codebehind="RegistrationForm.aspx.cs" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <style>
        .registration-section {
            min-height: 100vh;
            display: flex;
            align-items: center;
            position: relative;
            overflow: hidden;
            background: radial-gradient(ellipse at center, rgba(0, 212, 170, 0.1) 0%, transparent 70%);
            padding: 100px 0;
        }

        [data-theme="light"] .registration-section {
            background: radial-gradient(ellipse at center, rgba(0, 212, 170, 0.05) 0%, transparent 70%);
        }

        .registration-card {
            background: var(--card-bg);
            border: 1px solid var(--card-border);
            border-radius: 20px;
            padding: 3rem;
            transition: all 0.3s ease;
            backdrop-filter: blur(10px);
            color: var(--light);
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

        .role-badge {
            background: rgba(0, 212, 170, 0.1) !important;
            border: 1px solid rgba(0, 212, 170, 0.3);
            color: var(--primary) !important;
            backdrop-filter: blur(10px);
        }

        [data-theme="light"] .role-badge {
            background: rgba(0, 212, 170, 0.15) !important;
        }

        .btn-primary {
            background: var(--primary);
            border: none;
            padding: 1rem 2rem;
            border-radius: 10px;
            font-weight: 600;
            transition: all 0.3s ease;
            color: white !important;
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
        }

        .btn-outline-hero:hover {
            background: var(--primary);
            color: white;
            transform: translateY(-3px);
        }

        .step-indicator {
            display: flex;
            justify-content: center;
            margin-bottom: 3rem;
        }

        .step {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            background: var(--card-bg);
            border: 2px solid var(--card-border);
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 10px;
            color: var(--light);
            opacity: 0.5;
            font-weight: 600;
            transition: all 0.3s ease;
        }

        .step.active {
            background: var(--primary);
            border-color: var(--primary);
            color: white;
            opacity: 1;
        }

        .step-line {
            flex: 1;
            height: 2px;
            background: var(--card-border);
            margin: 0 10px;
            align-self: center;
            opacity: 0.5;
        }

        .step-label {
            text-align: center;
            margin-top: 0.5rem;
            font-size: 0.875rem;
            color: var(--light) !important;
            opacity: 0.7;
        }

        .step-container {
            display: none;
        }

        .step-container.active {
            display: block;
        }

        .password-strength {
            height: 4px;
            background: var(--card-border);
            border-radius: 2px;
            margin-top: 0.5rem;
            overflow: hidden;
        }

        .password-strength-bar {
            height: 100%;
            width: 0%;
            transition: all 0.3s ease;
            border-radius: 2px;
        }

        .weak { background: #ef4444; width: 25%; }
        .fair { background: #f59e0b; width: 50%; }
        .good { background: #10b981; width: 75%; }
        .strong { background: var(--primary); width: 100%; }

        .error-message {
            color: #ef4444 !important;
            font-size: 0.875rem;
            margin-top: 0.25rem;
            display: none;
        }

        /* Toast Notifications - FIXED VERSION */
        .toast-container {
            position: fixed;
            top: 20px;
            right: 20px;
            z-index: 9999;
            min-width: 300px;
            max-width: 400px;
        }

        .toast {
            background: var(--card-bg) !important;
            border: 1px solid var(--card-border) !important;
            border-radius: 10px !important;
            padding: 1rem 1.5rem !important;
            margin-bottom: 1rem !important;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.3) !important;
            color: var(--light) !important;
            font-weight: 500 !important;
            transform: translateX(400px) !important;
            transition: all 0.3s ease !important;
            backdrop-filter: blur(10px) !important;
            opacity: 0 !important;
        }

        [data-theme="light"] .toast {
            background: var(--card-bg) !important;
            color: var(--light) !important;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1) !important;
        }

        .toast.show {
            transform: translateX(0) !important;
            opacity: 1 !important;
        }

        .toast.success {
            border-left: 4px solid #10b981 !important;
            background: linear-gradient(90deg, rgba(16, 185, 129, 0.1), var(--card-bg)) !important;
        }

        .toast.error {
            border-left: 4px solid #ef4444 !important;
            background: linear-gradient(90deg, rgba(239, 68, 68, 0.1), var(--card-bg)) !important;
        }

        .toast.warning {
            border-left: 4px solid #f59e0b !important;
            background: linear-gradient(90deg, rgba(245, 158, 11, 0.1), var(--card-bg)) !important;
        }

        .toast.info {
            border-left: 4px solid var(--primary) !important;
            background: linear-gradient(90deg, rgba(0, 212, 170, 0.1), var(--card-bg)) !important;
        }

        .toast i {
            color: inherit !important;
            margin-right: 0.5rem !important;
        }

        .toast span {
            color: var(--light) !important;
            opacity: 1 !important;
        }

        .toast .d-flex {
            display: flex !important;
            align-items: center !important;
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

        .text-primary {
            color: var(--primary) !important;
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

        /* Dropdown Styles */
        .form-select {
            background: rgba(255, 255, 255, 0.05);
            border: 1px solid var(--card-border);
            color: var(--light);
            padding: 1rem;
            border-radius: 10px;
            transition: all 0.3s ease;
        }

        [data-theme="light"] .form-select {
            background: rgba(33, 37, 41, 0.05);
        }

        .form-select:focus {
            background: rgba(255, 255, 255, 0.1);
            border-color: var(--primary);
            color: var(--light);
            box-shadow: 0 0 0 0.2rem rgba(0, 212, 170, 0.25);
        }

        [data-theme="light"] .form-select:focus {
            background: rgba(33, 37, 41, 0.1);
        }

        /* Success Step Styles */
        .success-icon {
            font-size: 4rem;
            color: #10b981;
            margin-bottom: 1.5rem;
        }

        /* Additional Light Mode Specific Styles */
        [data-theme="light"] .registration-card {
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
        }

        [data-theme="light"] .form-control,
        [data-theme="light"] .form-select {
            color: var(--light) !important;
        }

        /* Link styles in form check */
        .form-check-label a {
            color: var(--primary) !important;
            text-decoration: none;
        }

        .form-check-label a:hover {
            text-decoration: underline;
        }

        /* Headings and text */
        h2, h3, h4, h5, h6 {
            color: var(--light) !important;
        }

        p, span {
            color: var(--light) !important;
            opacity: 0.9 !important;
        }

        strong {
            color: var(--light) !important;
            opacity: 1 !important;
        }

        @media (max-width: 768px) {
            .registration-card {
                padding: 2rem 1rem;
            }
            
            .toast-container {
                top: 10px !important;
                right: 10px !important;
                left: 10px !important;
                max-width: calc(100% - 20px) !important;
            }
            
            .toast {
                max-width: 100% !important;
                width: 100% !important;
            }
            
            .step {
                width: 35px;
                height: 35px;
                margin: 0 5px;
            }
            
            .step-line {
                margin: 0 5px;
            }
        }

        /* Password visibility toggle */
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
        }

        .password-toggle:hover {
            opacity: 1;
        }

        .password-input-container {
            position: relative;
        }

        /* Form group spacing */
        .form-group {
            margin-bottom: 1.5rem;
        }

        /* Button container spacing */
        .btn-container {
            margin-top: 2rem;
        }

        /* Role-specific panel styling */
        .role-panel {
            margin-top: 1rem;
            padding: 1.5rem;
            background: var(--card-bg);
            border: 1px solid var(--card-border);
            border-radius: 10px;
        }
    </style>

    <!-- Toast Container -->
    <div class="toast-container" id="toastContainer"></div>

    <section class="registration-section">
        <div class="container">
            <div class="row justify-content-center">
                <div class="col-lg-8">
                    <div class="registration-card">
                        <!-- Step Indicator -->
                        <div class="step-indicator">
                            <div class="step active">1</div>
                            <div class="step-line"></div>
                            <div class="step">2</div>
                            <div class="step-line"></div>
                            <div class="step">3</div>
                        </div>
                        <div class="row text-center mb-4">
                            <div class="col-4">
                                <div class="step-label">Personal Info</div>
                            </div>
                            <div class="col-4">
                                <div class="step-label">Account Details</div>
                            </div>
                            <div class="col-4">
                                <div class="step-label">Complete</div>
                            </div>
                        </div>

                        <!-- Role Badge -->
                        <div class="text-center mb-4">
                            <span class="role-badge px-3 py-2 rounded-pill">
                                <i class="fas fa-user me-2"></i>
                                <asp:Label ID="lblRole" runat="server" Text="Citizen"></asp:Label>
                            </span>
                        </div>

                        <h2 class="text-center mb-4">Create Your Account</h2>
                        <p class="text-center mb-5">Join SoorGreen as a <strong><asp:Label ID="lblRoleName" runat="server" Text="Citizen"></asp:Label></strong> and start your sustainability journey</p>

                        <!-- Step 1: Personal Information -->
                        <div id="step1" class="step-container active">
                            <h4 class="mb-4">Personal Information</h4>
                            
                            <div class="row g-3">
                                <div class="col-md-6">
                                    <label class="form-label">Full Name *</label>
                                    <asp:TextBox ID="txtFullName" runat="server" CssClass="form-control" 
                                        placeholder="Enter your full name"></asp:TextBox>
                                    <div id="errorFullName" class="error-message">Full name is required</div>
                                </div>
                                
                                <div class="col-md-6">
                                    <label class="form-label">Phone Number *</label>
                                    <asp:TextBox ID="txtPhone" runat="server" CssClass="form-control" 
                                        placeholder="Enter your phone number" TextMode="Phone"></asp:TextBox>
                                    <div id="errorPhone" class="error-message">Valid phone number is required</div>
                                </div>

                                <div class="col-12">
                                    <label class="form-label">Email Address *</label>
                                    <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control" 
                                        placeholder="Enter your email address" TextMode="Email"></asp:TextBox>
                                    <div id="errorEmail" class="error-message">Valid email address is required</div>
                                </div>

                                <!-- Citizen Specific Fields -->
                                <asp:Panel ID="pnlCitizenFields" runat="server" Visible="false" CssClass="role-panel">
                                    <h5 class="mb-3">Citizen Information</h5>
                                    <div class="row g-3">
                                        <div class="col-md-6">
                                            <label class="form-label">Address</label>
                                            <asp:TextBox ID="txtAddress" runat="server" CssClass="form-control" 
                                                placeholder="Enter your address" TextMode="MultiLine" Rows="2"></asp:TextBox>
                                        </div>
                                        <div class="col-md-6">
                                            <label class="form-label">Municipality</label>
                                            <asp:DropDownList ID="ddlMunicipality" runat="server" CssClass="form-select">
                                                <asp:ListItem Value="">Select Municipality</asp:ListItem>
                                                <asp:ListItem Value="M001">Central City</asp:ListItem>
                                                <asp:ListItem Value="M002">Green Valley</asp:ListItem>
                                                <asp:ListItem Value="M003">Eco Town</asp:ListItem>
                                                <asp:ListItem Value="M004">Sustainable City</asp:ListItem>
                                            </asp:DropDownList>
                                        </div>
                                    </div>
                                </asp:Panel>

                                <!-- Collector Specific Fields -->
                                <asp:Panel ID="pnlCollectorFields" runat="server" Visible="false" CssClass="role-panel">
                                    <h5 class="mb-3">Collector Information</h5>
                                    <div class="col-12">
                                        <label class="form-label">Company/Organization</label>
                                            <asp:TextBox ID="txtCompany" runat="server" CssClass="form-control" 
                                                placeholder="Enter company name"></asp:TextBox>
                                    </div>
                                </asp:Panel>

                                <div class="col-12 mt-4">
                                    <button type="button" class="btn btn-primary w-100" onclick="validateStep1()">
                                        Continue to Account Details <i class="fas fa-arrow-right ms-2"></i>
                                    </button>
                                </div>
                            </div>
                        </div>

                        <!-- Step 2: Account Details -->
                        <div id="step2" class="step-container">
                            <h4 class="mb-4">Account Security</h4>
                            
                            <div class="row g-3">
                                <div class="col-md-6">
                                    <div class="password-input-container">
                                        <label class="form-label">Password *</label>
                                        <asp:TextBox ID="txtPassword" runat="server" CssClass="form-control" 
                                            placeholder="Create a password" TextMode="Password"></asp:TextBox>
                                        <button type="button" class="password-toggle" onclick="togglePassword('txtPassword')">
                                            <i class="fas fa-eye"></i>
                                        </button>
                                    </div>
                                    <div class="password-strength">
                                        <div id="passwordStrengthBar" class="password-strength-bar"></div>
                                    </div>
                                    <div id="errorPassword" class="error-message">Password must be at least 6 characters</div>
                                </div>

                                <div class="col-md-6">
                                    <div class="password-input-container">
                                        <label class="form-label">Confirm Password *</label>
                                        <asp:TextBox ID="txtConfirmPassword" runat="server" CssClass="form-control" 
                                            placeholder="Confirm your password" TextMode="Password"></asp:TextBox>
                                        <button type="button" class="password-toggle" onclick="togglePassword('txtConfirmPassword')">
                                            <i class="fas fa-eye"></i>
                                        </button>
                                    </div>
                                    <div id="errorConfirmPassword" class="error-message">Passwords do not match</div>
                                </div>

                                <div class="col-12">
                                    <div class="form-check">
                                        <asp:CheckBox ID="cbTerms" runat="server" CssClass="form-check-input" />
                                        <label class="form-check-label" for="<%= cbTerms.ClientID %>">
                                            I agree to the <a href="#" class="text-primary">Terms of Service</a> and <a href="#" class="text-primary">Privacy Policy</a>
                                        </label>
                                        <div id="errorTerms" class="error-message">You must accept the terms and conditions</div>
                                    </div>
                                </div>

                                <div class="col-12">
                                    <div class="form-check">
                                        <asp:CheckBox ID="cbNewsletter" runat="server" CssClass="form-check-input" Checked="true" />
                                        <label class="form-check-label" for="<%= cbNewsletter.ClientID %>">
                                            Send me updates about recycling programs and sustainability tips
                                        </label>
                                    </div>
                                </div>

                                <div class="col-12 mt-4">
                                    <div class="row g-3">
                                        <div class="col-md-6">
                                            <button type="button" class="btn btn-outline-hero w-100" onclick="showStep(1)">
                                                <i class="fas fa-arrow-left me-2"></i> Back
                                            </button>
                                        </div>
                                        <div class="col-md-6">
                                            <asp:Button ID="btnRegister" runat="server" Text="Create Account" 
                                                CssClass="btn btn-primary w-100" OnClick="btnRegister_Click" 
                                                OnClientClick="return validateStep2();" />
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Step 3: Success -->
                        <div id="step3" class="step-container text-center">
                            <div class="mb-4">
                                <i class="fas fa-check-circle success-icon"></i>
                            </div>
                            <h3 class="mb-3">Registration Successful!</h3>
                            <p class="mb-4">Welcome to SoorGreen! Your account has been created successfully.</p>
                            <div class="row g-3">
                                <div class="col-md-6">
                                    <a href="Login.aspx" class="btn btn-outline-hero w-100">
                                        Sign In Now
                                    </a>
                                </div>
                                <div class="col-md-6">
                                    <a href="Default.aspx" class="btn btn-primary w-100">
                                        Go to Dashboard
                                    </a>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <script>
        // Toast notification function - FIXED VERSION
        function showToast(message, type = 'info') {
            const toastContainer = document.getElementById('toastContainer');
            if (!toastContainer) return;

            const toast = document.createElement('div');
            toast.className = `toast ${type}`;

            // Set icon based on type
            let iconClass = 'fa-info-circle';
            switch (type) {
                case 'success': iconClass = 'fa-check-circle'; break;
                case 'error': iconClass = 'fa-exclamation-circle'; break;
                case 'warning': iconClass = 'fa-exclamation-triangle'; break;
                default: iconClass = 'fa-info-circle'; break;
            }

            toast.innerHTML = `
                <div class="d-flex align-items-center">
                    <i class="fas ${iconClass} me-2"></i>
                    <span>${message}</span>
                </div>
            `;

            // Add to container
            toastContainer.appendChild(toast);

            // Show toast with animation
            setTimeout(() => {
                toast.classList.add('show');
            }, 10);

            // Auto-remove after 5 seconds
            setTimeout(() => {
                if (toast.parentNode === toastContainer) {
                    toast.classList.remove('show');
                    setTimeout(() => {
                        if (toast.parentNode === toastContainer) {
                            toastContainer.removeChild(toast);
                        }
                    }, 300);
                }
            }, 5000);

            // Add click to dismiss
            toast.addEventListener('click', function () {
                if (this.parentNode === toastContainer) {
                    this.classList.remove('show');
                    setTimeout(() => {
                        if (this.parentNode === toastContainer) {
                            toastContainer.removeChild(this);
                        }
                    }, 300);
                }
            });
        }

        function getToastIcon(type) {
            switch (type) {
                case 'success': return 'fa-check-circle';
                case 'error': return 'fa-exclamation-circle';
                case 'warning': return 'fa-exclamation-triangle';
                default: return 'fa-info-circle';
            }
        }

        function showStep(stepNumber) {
            // Hide all steps
            document.querySelectorAll('.step-container').forEach(step => {
                step.classList.remove('active');
            });

            // Show selected step
            const stepElement = document.getElementById('step' + stepNumber);
            if (stepElement) {
                stepElement.classList.add('active');
            }

            // Update step indicators
            document.querySelectorAll('.step').forEach((step, index) => {
                if (index < stepNumber) {
                    step.classList.add('active');
                } else {
                    step.classList.remove('active');
                }
            });
        }

        function validateStep1() {
            let isValid = true;

            // Reset errors
            hideAllErrors();

            // Validate Full Name
            const fullName = document.getElementById('<%= txtFullName.ClientID %>');
            if (!fullName || !fullName.value.trim()) {
                showError('errorFullName', 'Full name is required');
                isValid = false;
            }

            // Validate Phone
            const phone = document.getElementById('<%= txtPhone.ClientID %>');
            if (!phone || !phone.value.trim() || !isValidPhone(phone.value.trim())) {
                showError('errorPhone', 'Valid phone number is required');
                isValid = false;
            }

            // Validate Email
            const email = document.getElementById('<%= txtEmail.ClientID %>');
            if (!email || !email.value.trim() || !isValidEmail(email.value.trim())) {
                showError('errorEmail', 'Valid email address is required');
                isValid = false;
            }
            
            if (isValid) {
                showStep(2);
                showToast('Personal information validated!', 'success');
            } else {
                showToast('Please fix the errors above', 'warning');
            }
            
            return false;
        }

        function validateStep2() {
            let isValid = true;
            
            // Reset errors
            hideAllErrors();
            
            // Validate Password
            const password = document.getElementById('<%= txtPassword.ClientID %>');
            if (!password || !password.value || password.value.length < 6) {
                showError('errorPassword', 'Password must be at least 6 characters');
                isValid = false;
            }
            
            // Validate Confirm Password
            const confirmPassword = document.getElementById('<%= txtConfirmPassword.ClientID %>');
            if (password && confirmPassword && password.value !== confirmPassword.value) {
                showError('errorConfirmPassword', 'Passwords do not match');
                isValid = false;
            }
            
            // Validate Terms
            const termsChecked = document.getElementById('<%= cbTerms.ClientID %>');
            if (!termsChecked || !termsChecked.checked) {
                showError('errorTerms', 'You must accept the terms and conditions');
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

        function isValidPhone(phone) {
            const phoneRegex = /^[0-9+\-\s\(\)]{10,}$/;
            return phoneRegex.test(phone);
        }

        function showError(errorId, message) {
            const errorElement = document.getElementById(errorId);
            if (errorElement) {
                errorElement.textContent = message;
                errorElement.style.display = 'block';
            }
        }

        function hideAllErrors() {
            document.querySelectorAll('.error-message').forEach(error => {
                error.style.display = 'none';
            });
        }

        // Password strength indicator
        const passwordField = document.getElementById('<%= txtPassword.ClientID %>');
        if (passwordField) {
            passwordField.addEventListener('input', function () {
                const password = this.value;
                const strengthBar = document.getElementById('passwordStrengthBar');
                if (!strengthBar) return;

                let strength = 0;

                if (password.length >= 8) strength += 25;
                if (/[A-Z]/.test(password)) strength += 25;
                if (/[0-9]/.test(password)) strength += 25;
                if (/[^A-Za-z0-9]/.test(password)) strength += 25;

                strengthBar.className = 'password-strength-bar';
                if (strength <= 25) {
                    strengthBar.classList.add('weak');
                } else if (strength <= 50) {
                    strengthBar.classList.add('fair');
                } else if (strength <= 75) {
                    strengthBar.classList.add('good');
                } else {
                    strengthBar.classList.add('strong');
                }
            });
        }

        // Password visibility toggle
        function togglePassword(fieldId) {
            const field = document.getElementById(fieldId);
            if (!field) return;

            const toggle = field.nextElementSibling;
            if (!toggle) return;

            const icon = toggle.querySelector('i');
            if (!icon) return;

            if (field.type === 'password') {
                field.type = 'text';
                icon.className = 'fas fa-eye-slash';
            } else {
                field.type = 'password';
                icon.className = 'fas fa-eye';
            }
        }

        // Initialize on page load
        document.addEventListener('DOMContentLoaded', function () {
            showStep(1);
            // Show welcome toast
            setTimeout(() => {
                showToast('Welcome! Let\'s create your SoorGreen account.', 'info');
            }, 1000);
        });
    </script>
</asp:Content>