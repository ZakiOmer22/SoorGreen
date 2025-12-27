<%@ Page Title="Register" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" Inherits="Register" Codebehind="Register.aspx.cs" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <style>
        /* Register Page Specific Styles */
        .register-hero-section {
            min-height: 60vh;
            display: flex;
            align-items: center;
            position: relative;
            overflow: hidden;
            background: radial-gradient(ellipse at center, rgba(0, 212, 170, 0.1) 0%, transparent 70%);
            padding-top: 100px;
        }

        [data-theme="light"] .register-hero-section {
            background: radial-gradient(ellipse at center, rgba(0, 212, 170, 0.05) 0%, transparent 70%);
        }

        .role-card {
            background: var(--card-bg);
            border: 1px solid var(--card-border);
            border-radius: 20px;
            padding: 3rem 2rem;
            transition: all 0.3s ease;
            backdrop-filter: blur(10px);
            height: 100%;
            text-align: center;
            cursor: pointer;
            position: relative;
            overflow: hidden;
            color: var(--light);
        }

        .role-card:hover {
            transform: translateY(-10px);
            border-color: var(--primary);
            box-shadow: 0 25px 50px rgba(0, 0, 0, 0.3);
        }

        [data-theme="light"] .role-card:hover {
            box-shadow: 0 25px 50px rgba(0, 0, 0, 0.1);
        }

        .role-card.selected {
            border-color: var(--primary);
            box-shadow: 0 15px 30px rgba(0, 212, 170, 0.2);
            transform: translateY(-5px);
        }

        [data-theme="light"] .role-card.selected {
            box-shadow: 0 15px 30px rgba(0, 212, 170, 0.15);
        }

        .role-icon {
            font-size: 3rem;
            margin-bottom: 1.5rem;
        }

        .selected-indicator {
            position: absolute;
            top: 1rem;
            right: 1rem;
            width: 24px;
            height: 24px;
            border: 2px solid var(--card-border);
            border-radius: 50%;
            background: transparent;
            transition: all 0.3s ease;
        }

        .role-card.selected .selected-indicator {
            background: var(--primary);
            border-color: var(--primary);
        }

        .role-card.selected .selected-indicator::after {
            content: '✓';
            color: white;
            font-size: 14px;
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
        }

        .benefit-item {
            display: flex;
            align-items: flex-start;
            margin-bottom: 1.5rem;
            padding: 1.5rem;
            background: var(--card-bg);
            border: 1px solid var(--card-border);
            border-radius: 15px;
            transition: all 0.3s ease;
            backdrop-filter: blur(10px);
            color: var(--light);
        }

        .benefit-item:hover {
            transform: translateX(10px);
            border-color: var(--primary);
        }

        .benefit-icon {
            font-size: 1.5rem;
            color: var(--primary);
            margin-right: 1rem;
            margin-top: 0.25rem;
            flex-shrink: 0;
        }

        /* Button Styles */
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
            color: white !important;
        }

        .btn-primary:disabled {
            background: var(--card-border);
            transform: none;
            box-shadow: none;
            cursor: not-allowed;
        }

        [data-theme="light"] .btn-primary:disabled {
            background: rgba(33, 37, 41, 0.3);
        }

        .btn-hero {
            background: var(--primary);
            border: none;
            padding: 1rem 2rem;
            border-radius: 50px;
            font-weight: 600;
            transition: all 0.3s ease;
            color: white;
        }

        .btn-hero:hover {
            transform: translateY(-3px);
            box-shadow: 0 15px 30px rgba(0, 212, 170, 0.4);
            color: white;
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

        /* Section Badge */
        .section-badge {
            background: rgba(0, 212, 170, 0.1) !important;
            border: 1px solid rgba(0, 212, 170, 0.3);
            color: var(--primary) !important;
            backdrop-filter: blur(10px);
        }

        [data-theme="light"] .section-badge {
            background: rgba(0, 212, 170, 0.15) !important;
        }

        /* Hero Text Styles */
        .hero-title {
            font-size: 3.5rem;
            font-weight: 800;
            margin-bottom: 1.5rem;
            background: linear-gradient(45deg, var(--light), var(--primary), var(--secondary));
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            text-shadow: 0 0 30px rgba(255, 255, 255, 0.1);
        }

        [data-theme="light"] .hero-title {
            text-shadow: 0 0 30px rgba(33, 37, 41, 0.1);
        }

        /* Text visibility fixes */
        .hero-subtitle, .lead {
            color: var(--light) !important;
            opacity: 0.9 !important;
        }

        h1, h2, h3, h4, h5, h6, .fw-bold {
            color: var(--light) !important;
        }

        .role-card h3, .role-card p, .benefit-item h5, .benefit-item p {
            color: var(--light) !important;
        }

        .role-features .small, .role-features span {
            color: var(--light) !important;
            opacity: 0.8 !important;
        }

        .text-primary { color: var(--primary) !important; }
        .text-success { color: #10b981 !important; }
        .text-warning { color: #f59e0b !important; }
        .text-info { color: var(--secondary) !important; }

        /* Stats Section */
        .stat-card {
            padding: 2rem;
            text-align: center;
        }

        .stat-card h3 {
            font-size: 3rem;
            margin-bottom: 0.5rem;
        }

        .stat-card p {
            color: var(--light) !important;
            opacity: 0.8 !important;
            margin: 0;
        }

        /* Register Hero Visual */
        .register-hero-visual {
            position: relative;
        }

        .register-hero-image {
            background: linear-gradient(45deg, var(--primary), var(--secondary));
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.3);
        }

        [data-theme="light"] .register-hero-image {
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.1);
        }

        /* Additional Light Mode Specific Styles */
        [data-theme="light"] .role-card,
        [data-theme="light"] .benefit-item {
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);
        }

        [data-theme="light"] .role-card:hover,
        [data-theme="light"] .benefit-item:hover {
            box-shadow: 0 8px 25px rgba(0, 0, 0, 0.1);
        }

        /* Role-specific icon colors */
        .role-card[data-role="CITZ"] .role-icon {
            color: var(--primary) !important;
        }

        .role-card[data-role="COLL"] .role-icon {
            color: #10b981 !important;
        }

        .role-card[data-role="ADMN"] .role-icon {
            color: #f59e0b !important;
        }

        /* Feature check colors */
        .role-card[data-role="CITZ"] .fa-check {
            color: var(--primary) !important;
        }

        .role-card[data-role="COLL"] .fa-check {
            color: #10b981 !important;
        }

        .role-card[data-role="ADMN"] .fa-check {
            color: #f59e0b !important;
        }

        @media (max-width: 768px) {
            .register-form {
                padding: 2rem 1rem;
            }
            
            .role-card {
                padding: 2rem 1rem;
            }
            
            .benefit-item {
                padding: 1rem;
            }
            
            .hero-title {
                font-size: 2.5rem;
            }
            
            .stat-card h3 {
                font-size: 2.5rem;
            }
        }

        /* Instruction text */
        .instruction-text {
            color: var(--light) !important;
            opacity: 0.7 !important;
        }

        /* Role features container */
        .role-features {
            margin-top: 1.5rem;
        }

        /* Ensure proper spacing */
        .role-selection-section,
        .benefits-section,
        .stats-section {
            padding: 4rem 0;
        }

        /* Button container spacing */
        .btn-container {
            margin-top: 2rem;
        }
    </style>

    <!-- Hero Section -->
    <section class="register-hero-section">
        <div class="container">
            <div class="row align-items-center">
                <div class="col-lg-6">
                    <span class="section-badge px-3 py-2 rounded-pill mb-3">Join SoorGreen</span>
                    <h1 class="hero-title mb-4">Start Your Sustainability Journey</h1>
                    <p class="hero-subtitle mb-4">Join thousands of citizens, collectors, and administrators working together to create cleaner, greener communities through smart waste management.</p>
                    <div class="d-flex flex-wrap gap-3">
                        <a href="#role-selection" class="btn btn-hero">
                            <i class="fas fa-user-plus me-2"></i>Get Started
                        </a>
                        <a href="#benefits" class="btn btn-outline-hero">
                            <i class="fas fa-star me-2"></i>Learn Benefits
                        </a>
                    </div>
                </div>
                <div class="col-lg-6 text-center">
                    <div class="register-hero-visual">
                        <div class="register-hero-image rounded-3 shadow-lg" style="height: 400px; width: 100%;"></div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Role Selection Section -->
    <section id="role-selection" class="role-selection-section py-5">
        <div class="container">
            <div class="row text-center mb-5">
                <div class="col-lg-8 mx-auto">
                    <span class="section-badge px-3 py-2 rounded-pill mb-3">Choose Your Role</span>
                    <h2 class="fw-bold display-5 mb-3">How Do You Want to Contribute?</h2>
                    <p class="lead fs-6">Select the role that best fits how you want to participate in our sustainability ecosystem.</p>
                </div>
            </div>

            <div class="row g-4">
                <!-- Citizen Role -->
                <div class="col-lg-4 col-md-6">
                    <div class="role-card" data-role="CITZ">
                        <div class="selected-indicator"></div>
                        <div class="role-icon">
                            <i class="fas fa-user"></i>
                        </div>
                        <h3 class="fw-bold mb-3">Citizen</h3>
                        <p class="mb-4">Report waste, schedule pickups, and earn XP credits for your recycling efforts.</p>
                        <div class="role-features text-start">
                            <div class="d-flex align-items-center mb-2">
                                <i class="fas fa-check me-2 small"></i>
                                <span class="small">Earn rewards for recycling</span>
                            </div>
                            <div class="d-flex align-items-center mb-2">
                                <i class="fas fa-check me-2 small"></i>
                                <span class="small">Schedule waste pickups</span>
                            </div>
                            <div class="d-flex align-items-center">
                                <i class="fas fa-check me-2 small"></i>
                                <span class="small">Track environmental impact</span>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Collector Role -->
                <div class="col-lg-4 col-md-6">
                    <div class="role-card" data-role="COLL">
                        <div class="selected-indicator"></div>
                        <div class="role-icon">
                            <i class="fas fa-truck-loading"></i>
                        </div>
                        <h3 class="fw-bold mb-3">Waste Collector</h3>
                        <p class="mb-4">Manage collection routes, verify pickups, and help citizens get rewarded for recycling.</p>
                        <div class="role-features text-start">
                            <div class="d-flex align-items-center mb-2">
                                <i class="fas fa-check me-2 small"></i>
                                <span class="small">Manage collection routes</span>
                            </div>
                            <div class="d-flex align-items-center mb-2">
                                <i class="fas fa-check me-2 small"></i>
                                <span class="small">Verify waste pickups</span>
                            </div>
                            <div class="d-flex align-items-center">
                                <i class="fas fa-check me-2 small"></i>
                                <span class="small">Professional waste management</span>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Admin Role -->
                <div class="col-lg-4 col-md-6">
                    <div class="role-card" data-role="ADMN">
                        <div class="selected-indicator"></div>
                        <div class="role-icon">
                            <i class="fas fa-shield-alt"></i>
                        </div>
                        <h3 class="fw-bold mb-3">Administrator</h3>
                        <p class="mb-4">Manage platform operations, user accounts, and oversee the entire recycling ecosystem.</p>
                        <div class="role-features text-start">
                            <div class="d-flex align-items-center mb-2">
                                <i class="fas fa-check me-2 small"></i>
                                <span class="small">Platform management</span>
                            </div>
                            <div class="d-flex align-items-center mb-2">
                                <i class="fas fa-check me-2 small"></i>
                                <span class="small">User account oversight</span>
                            </div>
                            <div class="d-flex align-items-center">
                                <i class="fas fa-check me-2 small"></i>
                                <span class="small">System analytics</span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Continue Button -->
            <div class="row mt-5">
                <div class="col-lg-6 mx-auto text-center">
                    <asp:Button ID="btnContinue" runat="server" Text="Continue to Registration" 
                        CssClass="btn btn-primary btn-lg w-100" OnClick="btnContinue_Click" 
                        Enabled="false" />
                    <p class="instruction-text small mt-3">Select a role above to continue with registration</p>
                </div>
            </div>
        </div>
    </section>

    <!-- Benefits Section -->
    <section id="benefits" class="benefits-section py-5">
        <div class="container">
            <div class="row text-center mb-5">
                <div class="col-lg-8 mx-auto">
                    <span class="section-badge px-3 py-2 rounded-pill mb-3">Why Join?</span>
                    <h2 class="fw-bold display-5 mb-3">Benefits of Joining SoorGreen</h2>
                    <p class="lead fs-6">Discover how you can make a difference while enjoying exclusive benefits.</p>
                </div>
            </div>

            <div class="row g-4">
                <div class="col-lg-6">
                    <div class="benefit-item">
                        <div class="benefit-icon">
                            <i class="fas fa-leaf"></i>
                        </div>
                        <div>
                            <h5 class="fw-bold mb-2">Environmental Impact</h5>
                            <p class="mb-0">Track your personal contribution to reducing waste and creating sustainable communities.</p>
                        </div>
                    </div>

                    <div class="benefit-item">
                        <div class="benefit-icon">
                            <i class="fas fa-award"></i>
                        </div>
                        <div>
                            <h5 class="fw-bold mb-2">Earn Rewards</h5>
                            <p class="mb-0">Get XP credits for your recycling efforts that can be redeemed for various benefits.</p>
                        </div>
                    </div>

                    <div class="benefit-item">
                        <div class="benefit-icon">
                            <i class="fas fa-chart-line"></i>
                        </div>
                        <div>
                            <h5 class="fw-bold mb-2">Track Progress</h5>
                            <p class="mb-0">Monitor your recycling habits and see your environmental impact over time.</p>
                        </div>
                    </div>
                </div>

                <div class="col-lg-6">
                    <div class="benefit-item">
                        <div class="benefit-icon">
                            <i class="fas fa-users"></i>
                        </div>
                        <div>
                            <h5 class="fw-bold mb-2">Community</h5>
                            <p class="mb-0">Join a growing community of environmentally conscious citizens and professionals.</p>
                        </div>
                    </div>

                    <div class="benefit-item">
                        <div class="benefit-icon">
                            <i class="fas fa-mobile-alt"></i>
                        </div>
                        <div>
                            <h5 class="fw-bold mb-2">Easy to Use</h5>
                            <p class="mb-0">Simple and intuitive platform designed for everyone, regardless of technical skill.</p>
                        </div>
                    </div>

                    <div class="benefit-item">
                        <div class="benefit-icon">
                            <i class="fas fa-shield-alt"></i>
                        </div>
                        <div>
                            <h5 class="fw-bold mb-2">Secure & Reliable</h5>
                            <p class="mb-0">Your data and privacy are protected with enterprise-grade security measures.</p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Registration Stats -->
    <section class="stats-section py-5">
        <div class="container">
            <div class="row text-center">
                <div class="col-lg-3 col-md-6 mb-4">
                    <div class="stat-card">
                        <h3 class="display-4 fw-bold text-primary mb-2">10K+</h3>
                        <p>Active Citizens</p>
                    </div>
                </div>
                <div class="col-lg-3 col-md-6 mb-4">
                    <div class="stat-card">
                        <h3 class="display-4 fw-bold text-success mb-2">500+</h3>
                        <p>Waste Collectors</p>
                    </div>
                </div>
                <div class="col-lg-3 col-md-6 mb-4">
                    <div class="stat-card">
                        <h3 class="display-4 fw-bold text-warning mb-2">50+</h3>
                        <p>Municipalities</p>
                    </div>
                </div>
                <div class="col-lg-3 col-md-6 mb-4">
                    <div class="stat-card">
                        <h3 class="display-4 fw-bold text-info mb-2">100K+</h3>
                        <p>Kg Waste Recycled</p>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <script>
        document.addEventListener('DOMContentLoaded', function () {
            // Role selection functionality
            const roleCards = document.querySelectorAll('.role-card');
            const continueButton = document.getElementById('<%= btnContinue.ClientID %>');
            let selectedRole = '';

            roleCards.forEach(card => {
                card.addEventListener('click', function () {
                    // Remove selected class from all cards
                    roleCards.forEach(c => c.classList.remove('selected'));
                    
                    // Add selected class to clicked card
                    this.classList.add('selected');
                    
                    // Get the selected role
                    selectedRole = this.getAttribute('data-role');
                    
                    // Enable continue button
                    continueButton.disabled = false;
                    
                    // Store selected role in hidden field
                    document.getElementById('<%= selectedRole.ClientID %>').value = selectedRole;
                });
            });

            // Smooth scrolling for anchor links
            document.querySelectorAll('a[href^="#"]').forEach(anchor => {
                anchor.addEventListener('click', function (e) {
                    e.preventDefault();
                    const target = document.querySelector(this.getAttribute('href'));
                    if (target) {
                        target.scrollIntoView({
                            behavior: 'smooth',
                            block: 'start'
                        });
                    }
                });
            });
        });
    </script>

    <!-- Hidden field to store selected role -->
    <asp:HiddenField ID="selectedRole" runat="server" />
</asp:Content>