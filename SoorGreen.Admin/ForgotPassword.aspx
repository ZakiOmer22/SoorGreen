<%@ Page Title="Forgot Password" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeFile="ForgotPassword.aspx.cs" Inherits="ForgotPassword" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <style>
        .forgot-password-container {
            min-height: 80vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 100px 0 50px;
        }

        .password-card {
            background: rgba(255, 255, 255, 0.05);
            backdrop-filter: blur(20px);
            border: 1px solid rgba(255, 255, 255, 0.1);
            border-radius: 20px;
            padding: 3rem;
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.3);
            max-width: 500px;
            width: 100%;
            position: relative;
            overflow: hidden;
        }

        .password-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 1px;
            background: linear-gradient(90deg, transparent, #00d4aa, transparent);
        }

        .password-icon {
            font-size: 4rem;
            color: #00d4aa;
            margin-bottom: 1rem;
            text-align: center;
        }

        .password-title {
            font-weight: 900;
            color: white;
            margin-bottom: 0.5rem;
            text-align: center;
            font-size: 2rem;
            background: linear-gradient(135deg, #ffffff, #00d4aa);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            line-height: 1.2;
        }

        .password-subtitle {
            color: rgba(255, 255, 255, 0.7);
            text-align: center;
            margin-bottom: 2rem;
            font-size: 1rem;
            line-height: 1.4;
        }

        .form-group {
            margin-bottom: 1.5rem;
        }

        .form-label {
            color: rgba(255, 255, 255, 0.9);
            font-weight: 600;
            margin-bottom: 0.5rem;
            display: block;
        }

        .form-control {
            background: rgba(255, 255, 255, 0.1);
            border: 1px solid rgba(255, 255, 255, 0.2);
            border-radius: 12px;
            color: white;
            padding: 0.875rem 1rem;
            width: 100%;
            transition: all 0.3s ease;
            font-size: 1rem;
        }

        .form-control:focus {
            outline: none;
            border-color: #00d4aa;
            background: rgba(255, 255, 255, 0.15);
            box-shadow: 0 0 0 0.2rem rgba(0, 212, 170, 0.25);
        }

        .btn-reset {
            background: linear-gradient(135deg, #00d4aa, #0984e3);
            border: none;
            color: white;
            padding: 1rem 2rem;
            border-radius: 12px;
            font-weight: 700;
            font-size: 1.1rem;
            width: 100%;
            transition: all 0.3s ease;
            margin-top: 1rem;
            cursor: pointer;
        }

        .btn-reset:hover {
            background: linear-gradient(135deg, #00b894, #0a7bd6);
            transform: translateY(-2px);
            box-shadow: 0 10px 25px rgba(0, 212, 170, 0.4);
        }

        .alert {
            padding: 1rem 1.5rem;
            border-radius: 12px;
            margin-bottom: 1.5rem;
            border: 1px solid transparent;
            backdrop-filter: blur(10px);
        }

        .alert-success {
            background: rgba(25, 135, 84, 0.1);
            border-color: rgba(25, 135, 84, 0.3);
            color: #75b798;
        }

        .alert-danger {
            background: rgba(220, 53, 69, 0.1);
            border-color: rgba(220, 53, 69, 0.3);
            color: #ea868f;
        }

        .alert-info {
            background: rgba(13, 110, 253, 0.1);
            border-color: rgba(13, 110, 253, 0.3);
            color: #6ea8fe;
        }

        /* FIXED: Steps indicator - no overlap */
        .steps-indicator {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 3rem;
            position: relative;
            padding: 0 10px;
        }

        .step {
            width: 45px;
            height: 45px;
            border-radius: 50%;
            background: rgba(255, 255, 255, 0.1);
            border: 2px solid rgba(255, 255, 255, 0.3);
            display: flex;
            align-items: center;
            justify-content: center;
            color: rgba(255, 255, 255, 0.5);
            font-weight: 700;
            position: relative;
            z-index: 2;
            transition: all 0.3s ease;
            flex-shrink: 0;
        }

        .step.active {
            background: #00d4aa;
            border-color: #00d4aa;
            color: white;
        }

        .step.completed {
            background: #00d4aa;
            border-color: #00d4aa;
            color: white;
        }

        .step-line {
            position: absolute;
            top: 50%;
            left: 60px;
            right: 60px;
            height: 2px;
            background: rgba(255, 255, 255, 0.2);
            transform: translateY(-50%);
            z-index: 1;
        }

        /* FIXED: Step labels - no overlap */
        .step-label {
            position: absolute;
            top: 50px;
            font-size: 0.75rem;
            color: rgba(255, 255, 255, 0.8);
            white-space: nowrap;
            text-align: center;
            width: 90px;
            left: 50%;
            transform: translateX(-50%);
            font-weight: 600;
        }

        .step-1 .step-label { margin-left: -20px; }
        .step-2 .step-label { margin-left: 0px; }
        .step-3 .step-label { margin-left: 20px; }

        .step-content {
            display: none;
        }

        .step-content.active {
            display: block;
        }

        .verification-code {
            display: flex;
            gap: 0.5rem;
            justify-content: center;
            margin: 1.5rem 0;
        }

        .code-input {
            width: 50px;
            height: 60px;
            text-align: center;
            font-size: 1.5rem;
            font-weight: 700;
            background: rgba(255, 255, 255, 0.1);
            border: 2px solid rgba(255, 255, 255, 0.2);
            border-radius: 8px;
            color: white;
        }

        .code-input:focus {
            border-color: #00d4aa;
            background: rgba(255, 255, 255, 0.15);
            outline: none;
        }

        .resend-code {
            text-align: center;
            margin-top: 1rem;
            color: rgba(255, 255, 255, 0.7);
        }

        .resend-link {
            color: #00d4aa;
            text-decoration: none;
            font-weight: 600;
            cursor: pointer;
            background: none;
            border: none;
            padding: 0;
        }

        .resend-link:hover {
            text-decoration: underline;
        }

        .countdown {
            color: #fd79a8;
            font-weight: 700;
        }

        .password-strength {
            margin-top: 0.5rem;
            height: 4px;
            background: rgba(255, 255, 255, 0.1);
            border-radius: 2px;
            overflow: hidden;
        }

        .strength-bar {
            height: 100%;
            width: 0%;
            transition: all 0.3s ease;
            border-radius: 2px;
        }

        .strength-weak { background: #dc3545; width: 33%; }
        .strength-medium { background: #fd7e14; width: 66%; }
        .strength-strong { background: #198754; width: 100%; }

        .password-requirements {
            margin-top: 0.5rem;
            font-size: 0.8rem;
            color: rgba(255, 255, 255, 0.6);
        }

        .requirement {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            margin-bottom: 0.2rem;
        }

        .requirement.met {
            color: #00d4aa;
        }

        .requirement i {
            font-size: 0.6rem;
        }

        .back-to-login {
            text-align: center;
            margin-top: 2rem;
            color: rgba(255, 255, 255, 0.7);
        }

        .back-to-login a {
            color: #00d4aa;
            text-decoration: none;
            font-weight: 600;
        }

        .back-to-login a:hover {
            text-decoration: underline;
        }

        /* ADDED: Field error styling for password validation */
        .field-error {
            border-color: #fd79a8 !important;
            background: rgba(253, 121, 168, 0.1) !important;
            box-shadow: 0 0 0 0.2rem rgba(253, 121, 168, 0.25) !important;
        }

        .validation-error {
            color: #fd79a8;
            font-size: 0.8rem;
            margin-top: 0.25rem;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }

        .validation-error i {
            font-size: 0.7rem;
        }
    </style>

    <div class="forgot-password-container">
        <div class="password-card">
            <div class="steps-indicator">
                <div class="step step-1 active" id="step1">
                    <span>1</span>
                    <div class="step-label">Verify Email</div>
                </div>
                <div class="step-line"></div>
                <div class="step step-2" id="step2">
                    <span>2</span>
                    <div class="step-label">Enter Code</div>
                </div>
                <div class="step-line"></div>
                <div class="step step-3" id="step3">
                    <span>3</span>
                    <div class="step-label">New Password</div>
                </div>
            </div>

            <div class="step-content active" id="stepContent1">
                <div class="password-icon">
                    <i class="fas fa-key"></i>
                </div>
                <h1 class="password-title">Reset Your Password</h1>
                <p class="password-subtitle">Enter your email address and we'll send you a verification code</p>

                <asp:Panel ID="pnlStep1" runat="server">
                    <div class="form-group">
                        <label class="form-label">Email Address</label>
                        <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control" placeholder="Enter your email address" TextMode="Email"></asp:TextBox>
                    </div>
                    <asp:Button ID="btnSendCode" runat="server" Text="Send Verification Code" CssClass="btn-reset" OnClick="btnSendCode_Click" />
                </asp:Panel>
            </div>

            <div class="step-content" id="stepContent2">
                <div class="password-icon">
                    <i class="fas fa-shield-alt"></i>
                </div>
                <h1 class="password-title">Enter Verification Code</h1>
                <p class="password-subtitle">We sent a 6-digit code to <strong id="sentEmail" runat="server"></strong></p>

                <asp:Panel ID="pnlStep2" runat="server" Visible="false">
                    <!-- 6 INDIVIDUAL CODE INPUTS WITH PASTE SUPPORT -->
                    <div class="verification-code">
                        <asp:TextBox ID="txtCode1" runat="server" CssClass="code-input" MaxLength="1" onkeyup="moveToNext(this, '<%= txtCode2.ClientID %>')" onpaste="handlePaste(event)"></asp:TextBox>
                        <asp:TextBox ID="txtCode2" runat="server" CssClass="code-input" MaxLength="1" onkeyup="moveToNext(this, '<%= txtCode3.ClientID %>')" onpaste="handlePaste(event)"></asp:TextBox>
                        <asp:TextBox ID="txtCode3" runat="server" CssClass="code-input" MaxLength="1" onkeyup="moveToNext(this, '<%= txtCode4.ClientID %>')" onpaste="handlePaste(event)"></asp:TextBox>
                        <asp:TextBox ID="txtCode4" runat="server" CssClass="code-input" MaxLength="1" onkeyup="moveToNext(this, '<%= txtCode5.ClientID %>')" onpaste="handlePaste(event)"></asp:TextBox>
                        <asp:TextBox ID="txtCode5" runat="server" CssClass="code-input" MaxLength="1" onkeyup="moveToNext(this, '<%= txtCode6.ClientID %>')" onpaste="handlePaste(event)"></asp:TextBox>
                        <asp:TextBox ID="txtCode6" runat="server" CssClass="code-input" MaxLength="1" onpaste="handlePaste(event)"></asp:TextBox>
                    </div>
                    <div class="resend-code">
                        Didn't receive the code? 
                        <asp:LinkButton ID="btnResendCode" runat="server" CssClass="resend-link" OnClick="btnResendCode_Click">Resend Code</asp:LinkButton>
                        <span id="countdown" class="countdown" style="display: none;">(0:60)</span>
                    </div>
                    <asp:Button ID="btnVerifyCode" runat="server" Text="Verify Code" CssClass="btn-reset" OnClick="btnVerifyCode_Click" />
                </asp:Panel>
            </div>

            <div class="step-content" id="stepContent3">
                <div class="password-icon">
                    <i class="fas fa-lock"></i>
                </div>
                <h1 class="password-title">Create New Password</h1>
                <p class="password-subtitle">Your new password must be different from previous used passwords</p>

                <asp:Panel ID="pnlStep3" runat="server" Visible="false">
                    <div class="form-group">
                        <label class="form-label">New Password</label>
                        <asp:TextBox ID="txtNewPassword" runat="server" CssClass="form-control" placeholder="Enter new password (minimum 8 characters)" TextMode="Password"></asp:TextBox>
                        <div class="password-strength">
                            <div id="strengthBar" class="strength-bar"></div>
                        </div>
                        <!-- SIMPLIFIED: Only show length requirement -->
                        <div class="password-requirements">
                            <div class="requirement" id="reqLength"><i class="fas fa-circle"></i><span>At least 8 characters</span></div>
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="form-label">Confirm New Password</label>
                        <asp:TextBox ID="txtConfirmPassword" runat="server" CssClass="form-control" placeholder="Confirm new password" TextMode="Password"></asp:TextBox>
                    </div>
                    <asp:Button ID="btnResetPassword" runat="server" Text="Reset Password" CssClass="btn-reset" OnClick="btnResetPassword_Click" />
                </asp:Panel>
            </div>

            <asp:Panel ID="pnlSuccess" runat="server" Visible="false">
                <div class="password-icon text-success">
                    <i class="fas fa-check-circle"></i>
                </div>
                <h1 class="password-title">Password Reset Successfully!</h1>
                <p class="password-subtitle">Your password has been reset successfully. You can now login with your new password.</p>
                <div class="text-center">
                    <a href="Login.aspx" class="btn-reset">Go to Login</a>
                </div>
            </asp:Panel>

            <asp:Panel ID="pnlAlert" runat="server" Visible="false">
                <div class="alert" id="alertDiv" runat="server">
                    <asp:Label ID="lblAlert" runat="server" Text=""></asp:Label>
                </div>
            </asp:Panel>

            <div class="back-to-login">
                <a href="Login.aspx"><i class="fas fa-arrow-left me-2"></i>Back to Login</a>
            </div>
        </div>
    </div>

    <script>
        function moveToNext(current, nextFieldId) {
            if (current.value.length >= current.maxLength) {
                document.getElementById(nextFieldId).focus();
            }
        }

        // NEW: Handle paste event for verification code
        function handlePaste(event) {
            event.preventDefault();
            const pasteData = (event.clipboardData || window.clipboardData).getData('text');
            const cleanData = pasteData.replace(/\s/g, '').replace(/\D/g, ''); // Remove spaces and non-digits

            if (cleanData.length === 6) {
                const inputs = document.querySelectorAll('.code-input');
                for (let i = 0; i < 6; i++) {
                    if (inputs[i]) {
                        inputs[i].value = cleanData[i] || '';
                    }
                }
                // Focus the last input after pasting
                if (inputs[5]) {
                    inputs[5].focus();
                }
            }
        }

        // SIMPLIFIED: Only check password length
        function checkPasswordStrength() {
            var password = document.getElementById('<%= txtNewPassword.ClientID %>').value;
            var strengthBar = document.getElementById('strengthBar');
            var requirement = document.getElementById('reqLength');

            if (password.length >= 8) {
                requirement.classList.add('met');
                requirement.querySelector('i').className = 'fas fa-check-circle text-success';
                strengthBar.className = 'strength-bar strength-strong';
            } else {
                requirement.classList.remove('met');
                requirement.querySelector('i').className = 'fas fa-circle';
                strengthBar.className = 'strength-bar';
                strengthBar.style.width = '0%';
            }
        }

        // FIXED: Added null checks to prevent TypeError
        function showStep(step) {
            for (var i = 1; i <= 3; i++) {
                var stepContent = document.getElementById('stepContent' + i);
                var stepElement = document.getElementById('step' + i);

                if (stepContent) stepContent.classList.remove('active');
                if (stepElement) stepElement.classList.remove('active', 'completed');
            }

            for (var i = 1; i <= step; i++) {
                var stepElement = document.getElementById('step' + i);
                var stepContent = document.getElementById('stepContent' + i);

                if (stepElement && stepContent) {
                    if (i < step) {
                        stepElement.classList.add('completed');
                    } else {
                        stepElement.classList.add('active');
                        stepContent.classList.add('active');
                    }
                }
            }
        }

        function startCountdown(seconds) {
            var countdownElement = document.getElementById('countdown');
            var resendButton = document.getElementById('<%= btnResendCode.ClientID %>');
            if (countdownElement && resendButton) {
                countdownElement.style.display = 'inline';
                resendButton.style.display = 'none';
                var countdown = seconds;
                var interval = setInterval(function () {
                    countdownElement.textContent = '(' + Math.floor(countdown / 60) + ':' + (countdown % 60).toString().padStart(2, '0') + ')';
                    countdown--;
                    if (countdown < 0) {
                        clearInterval(interval);
                        countdownElement.style.display = 'none';
                        resendButton.style.display = 'inline';
                    }
                }, 1000);
            }
        }

        // Clear field errors when user starts typing
        function clearFieldErrors() {
            var passwordField = document.getElementById('<%= txtNewPassword.ClientID %>');
            var confirmField = document.getElementById('<%= txtConfirmPassword.ClientID %>');
            
            if (passwordField) {
                passwordField.classList.remove('field-error');
            }
            if (confirmField) {
                confirmField.classList.remove('field-error');
            }
        }

        document.addEventListener('DOMContentLoaded', function () {
            var codeInputs = document.querySelectorAll('.code-input');
            codeInputs.forEach(function (input, index) {
                input.addEventListener('input', function () {
                    if (this.value.length === 1 && index < codeInputs.length - 1) {
                        codeInputs[index + 1].focus();
                    }
                });
                input.addEventListener('keydown', function (e) {
                    if (e.key === 'Backspace' && this.value.length === 0 && index > 0) {
                        codeInputs[index - 1].focus();
                    }
                });
            });

            // Add event listener for password input
            var passwordInput = document.getElementById('<%= txtNewPassword.ClientID %>');
            if (passwordInput) {
                passwordInput.addEventListener('input', checkPasswordStrength);
                passwordInput.addEventListener('input', clearFieldErrors);
            }

            var confirmInput = document.getElementById('<%= txtConfirmPassword.ClientID %>');
            if (confirmInput) {
                confirmInput.addEventListener('input', clearFieldErrors);
            }

            // Clear email field error
            var emailInput = document.getElementById('<%= txtEmail.ClientID %>');
            if (emailInput) {
                emailInput.addEventListener('input', function () {
                    this.classList.remove('field-error');
                });
            }
        });

        // Mobile dropdown handling
        document.addEventListener('DOMContentLoaded', function () {
            const isMobile = window.innerWidth < 992;

            if (isMobile) {
                const dropdownToggles = document.querySelectorAll('.dropdown-toggle');
                dropdownToggles.forEach(toggle => {
                    toggle.setAttribute('data-bs-toggle', 'dropdown');
                });
            } else {
                const dropdownToggles = document.querySelectorAll('.dropdown-toggle');
                dropdownToggles.forEach(toggle => {
                    toggle.removeAttribute('data-bs-toggle');
                });
            }
        });

        // Handle window resize
        window.addEventListener('resize', function () {
            const isMobile = window.innerWidth < 992;
            const dropdownToggles = document.querySelectorAll('.dropdown-toggle');

            dropdownToggles.forEach(toggle => {
                if (isMobile) {
                    toggle.setAttribute('data-bs-toggle', 'dropdown');
                    toggle.classList.add('show');
                    toggle.nextElementSibling.classList.add('show');
                    toggle.setAttribute('aria-expanded', 'true');
                    toggle.nextElementSibling.style.display = 'block';
                } else {
                    toggle.removeAttribute('data-bs-toggle');
                    toggle.classList.remove('show');
                    toggle.nextElementSibling.classList.remove('show');
                    toggle.setAttribute('aria-expanded', 'false');
                    toggle.nextElementSibling.style.display = '';
                }
            });
        });
    </script>
</asp:Content>