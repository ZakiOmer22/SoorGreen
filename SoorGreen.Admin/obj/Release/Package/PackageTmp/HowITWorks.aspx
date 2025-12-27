<%@ Page Title="How It Works" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="false" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <style>
        /* How It Works - Modern UI */
        .process-hero {
            background: linear-gradient(135deg, #0f172a 0%, #1e293b 100%);
            min-height: 80vh;
            display: flex;
            align-items: center;
            position: relative;
            overflow: hidden;
        }

        .hero-graphic {
            position: relative;
            height: 500px;
            background: linear-gradient(45deg, var(--primary), var(--secondary));
            border-radius: 20px;
            overflow: hidden;
            box-shadow: 0 20px 40px rgba(0,0,0,0.3);
        }

        .floating-shapes {
            position: absolute;
            width: 100%;
            height: 100%;
        }

        .shape {
            position: absolute;
            border-radius: 50%;
            background: rgba(255,255,255,0.1);
            animation: float 6s ease-in-out infinite;
        }

        .shape-1 { width: 80px; height: 80px; top: 20%; left: 10%; animation-delay: 0s; }
        .shape-2 { width: 120px; height: 120px; top: 60%; right: 15%; animation-delay: 2s; }
        .shape-3 { width: 60px; height: 60px; bottom: 20%; left: 20%; animation-delay: 4s; }

        @keyframes float {
            0%, 100% { transform: translateY(0px) rotate(0deg); }
            50% { transform: translateY(-20px) rotate(180deg); }
        }

        /* Process Timeline */
        .process-timeline {
            position: relative;
            padding: 100px 0;
        }

        .timeline-line {
            position: absolute;
            left: 50%;
            top: 0;
            bottom: 0;
            width: 3px;
            background: linear-gradient(180deg, var(--primary), var(--secondary));
            transform: translateX(-50%);
        }

        .timeline-item {
            display: flex;
            align-items: center;
            margin-bottom: 80px;
            position: relative;
        }

        .timeline-item:nth-child(even) {
            flex-direction: row-reverse;
        }

        .timeline-content {
            flex: 1;
            background: var(--card-bg);
            border: 1px solid var(--card-border);
            border-radius: 20px;
            padding: 40px;
            margin: 0 40px;
            backdrop-filter: blur(10px);
            transition: all 0.3s ease;
        }

        .timeline-content:hover {
            transform: translateY(-10px);
            border-color: var(--primary);
            box-shadow: 0 20px 40px rgba(0,0,0,0.3);
        }

        .timeline-marker {
            width: 60px;
            height: 60px;
            background: linear-gradient(135deg, var(--primary), var(--secondary));
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-weight: bold;
            font-size: 1.5rem;
            position: relative;
            z-index: 2;
            border: 4px solid var(--dark);
        }

        /* Feature Cards */
        .feature-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 30px;
            padding: 80px 0;
        }

        .feature-card {
            background: var(--card-bg);
            border: 1px solid var(--card-border);
            border-radius: 20px;
            padding: 40px;
            text-align: center;
            transition: all 0.3s ease;
            position: relative;
            overflow: hidden;
        }

        .feature-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: -100%;
            width: 100%;
            height: 100%;
            background: linear-gradient(90deg, transparent, rgba(255,255,255,0.05), transparent);
            transition: left 0.6s ease;
        }

        .feature-card:hover::before {
            left: 100%;
        }

        .feature-card:hover {
            transform: translateY(-10px);
            border-color: var(--primary);
        }

        .feature-icon {
            width: 80px;
            height: 80px;
            background: linear-gradient(135deg, var(--primary), var(--secondary));
            border-radius: 20px;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 20px;
            font-size: 2rem;
            color: white;
        }

        /* Stats Section */
        .stats-section {
            background: linear-gradient(135deg, var(--primary), var(--secondary));
            padding: 100px 0;
            position: relative;
            overflow: hidden;
        }

        .stat-card {
            text-align: center;
            padding: 40px 20px;
            color: white;
            position: relative;
            z-index: 2;
        }

        .stat-number {
            font-size: 3.5rem;
            font-weight: 800;
            margin-bottom: 10px;
            text-shadow: 0 0 20px rgba(0,0,0,0.3);
        }

        .stat-label {
            font-size: 1.1rem;
            opacity: 0.9;
        }

        /* Apps Showcase */
        .apps-showcase {
            padding: 100px 0;
            background: rgba(255,255,255,0.02);
        }

        .app-platform {
            background: var(--card-bg);
            border: 1px solid var(--card-border);
            border-radius: 25px;
            padding: 50px;
            text-align: center;
            transition: all 0.3s ease;
        }

        .app-platform:hover {
            transform: translateY(-10px);
            border-color: var(--primary);
        }

        .platform-icon {
            width: 100px;
            height: 100px;
            background: linear-gradient(135deg, var(--primary), var(--secondary));
            border-radius: 25px;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 30px;
            font-size: 3rem;
            color: white;
        }

        .store-buttons {
            display: flex;
            gap: 15px;
            justify-content: center;
            margin-top: 25px;
        }

        .store-btn {
            padding: 12px 25px;
            background: rgba(255,255,255,0.1);
            border: 1px solid rgba(255,255,255,0.2);
            border-radius: 12px;
            color: white;
            text-decoration: none;
            transition: all 0.3s ease;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .store-btn:hover {
            background: var(--primary);
            transform: translateY(-2px);
        }

        /* CTA Section */
        .cta-process {
            padding: 100px 0;
            text-align: center;
        }

        .cta-content {
            max-width: 600px;
            margin: 0 auto;
        }

        .btn-group {
            display: flex;
            gap: 20px;
            justify-content: center;
            margin-top: 40px;
            flex-wrap: wrap;
        }

        .btn-primary-custom {
            background: linear-gradient(135deg, var(--primary), var(--secondary));
            color: white;
            padding: 15px 35px;
            border-radius: 25px;
            text-decoration: none;
            font-weight: 600;
            transition: all 0.3s ease;
            border: none;
        }

        .btn-primary-custom:hover {
            transform: translateY(-3px);
            box-shadow: 0 10px 25px rgba(0,212,170,0.4);
        }

        .btn-outline-custom {
            background: transparent;
            color: var(--light);
            padding: 15px 35px;
            border-radius: 25px;
            text-decoration: none;
            font-weight: 600;
            transition: all 0.3s ease;
            border: 2px solid var(--primary);
        }

        .btn-outline-custom:hover {
            background: var(--primary);
            transform: translateY(-3px);
        }

        /* Responsive */
        @media (max-width: 768px) {
            .timeline-line {
                left: 30px;
            }

            .timeline-item {
                flex-direction: row !important;
                margin-left: 60px;
            }

            .timeline-content {
                margin: 0;
                margin-left: 30px;
            }

            .hero-graphic {
                height: 300px;
                margin-top: 40px;
            }

            .btn-group {
                flex-direction: column;
                align-items: center;
            }

            .store-buttons {
                flex-direction: column;
            }
        }
    </style>

    <!-- Hero Section -->
    <section class="process-hero">
        <div class="container">
            <div class="row align-items-center">
                <div class="col-lg-6">
                    <h1 class="display-3 fw-bold text-white mb-4">How SoorGreen Works</h1>
                    <p class="lead text-light mb-4">Transform your waste management experience with our intuitive 3-step process. Simple, efficient, and environmentally conscious.</p>
                    <div class="d-flex flex-wrap gap-3">
                        <a href="#process" class="btn-primary-custom">
                            <i class="fas fa-play-circle me-2"></i>Start Journey
                        </a>
                        <a href="#features" class="btn-outline-custom">
                            <i class="fas fa-star me-2"></i>View Features
                        </a>
                    </div>
                </div>
                <div class="col-lg-6">
                    <div class="hero-graphic">
                        <div class="floating-shapes">
                            <div class="shape shape-1"></div>
                            <div class="shape shape-2"></div>
                            <div class="shape shape-3"></div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Process Timeline -->
    <section id="process" class="process-timeline">
        <div class="container">
            <div class="timeline-line"></div>
            
            <!-- Step 1 -->
            <div class="timeline-item">
                <div class="timeline-content">
                    <div class="feature-icon">
                        <i class="fas fa-mobile-alt"></i>
                    </div>
                    <h3 class="text-white mb-3">1. Request Pickup</h3>
                    <p class="text-light mb-4">Use our mobile app or website to schedule waste collection in under 2 minutes. Select your waste type, preferred pickup time, and location with just a few taps.</p>
                    <div class="row text-center">
                        <div class="col-md-4">
                            <i class="fas fa-clock text-primary mb-2"></i>
                            <p class="text-light small">2-Minute Setup</p>
                        </div>
                        <div class="col-md-4">
                            <i class="fas fa-list text-primary mb-2"></i>
                            <p class="text-light small">Multiple Categories</p>
                        </div>
                        <div class="col-md-4">
                            <i class="fas fa-dollar-sign text-primary mb-2"></i>
                            <p class="text-light small">Real-Time Pricing</p>
                        </div>
                    </div>
                </div>
                <div class="timeline-marker">1</div>
            </div>

            <!-- Step 2 -->
            <div class="timeline-item">
                <div class="timeline-content">
                    <div class="feature-icon">
                        <i class="fas fa-truck"></i>
                    </div>
                    <h3 class="text-white mb-3">2. Smart Collection</h3>
                    <p class="text-light mb-4">Our AI-powered system dispatches the nearest available driver using optimized routes. Track your collection in real-time with live GPS updates and notifications.</p>
                    <div class="row text-center">
                        <div class="col-md-4">
                            <i class="fas fa-robot text-primary mb-2"></i>
                            <p class="text-light small">AI Optimization</p>
                        </div>
                        <div class="col-md-4">
                            <i class="fas fa-map-marker-alt text-primary mb-2"></i>
                            <p class="text-light small">Live Tracking</p>
                        </div>
                        <div class="col-md-4">
                            <i class="fas fa-leaf text-primary mb-2"></i>
                            <p class="text-light small">Eco-Friendly</p>
                        </div>
                    </div>
                </div>
                <div class="timeline-marker">2</div>
            </div>

            <!-- Step 3 -->
            <div class="timeline-item">
                <div class="timeline-content">
                    <div class="feature-icon">
                        <i class="fas fa-recycle"></i>
                    </div>
                    <h3 class="text-white mb-3">3. Sustainable Processing</h3>
                    <p class="text-light mb-4">Collected waste is transported to certified recycling facilities where it's processed, sorted, and transformed into valuable resources for a circular economy.</p>
                    <div class="row text-center">
                        <div class="col-md-4">
                            <i class="fas fa-certificate text-primary mb-2"></i>
                            <p class="text-light small">Certified Partners</p>
                        </div>
                        <div class="col-md-4">
                            <i class="fas fa-sync-alt text-primary mb-2"></i>
                            <p class="text-light small">Circular Economy</p>
                        </div>
                        <div class="col-md-4">
                            <i class="fas fa-chart-line text-primary mb-2"></i>
                            <p class="text-light small">Impact Reports</p>
                        </div>
                    </div>
                </div>
                <div class="timeline-marker">3</div>
            </div>
        </div>
    </section>

    <!-- Features Section -->
    <section id="features" class="feature-section">
        <div class="container">
            <div class="row text-center mb-5">
                <div class="col-lg-8 mx-auto">
                    <h2 class="display-4 fw-bold text-white mb-3">Smart Features</h2>
                    <p class="lead text-light">Powered by cutting-edge technology for a seamless waste management experience</p>
                </div>
            </div>
            <div class="feature-grid">
                <div class="feature-card">
                    <div class="feature-icon">
                        <i class="fas fa-robot"></i>
                    </div>
                    <h4 class="text-white mb-3">AI Route Optimization</h4>
                    <p class="text-light">Smart algorithms calculate the most efficient collection routes, reducing fuel consumption and environmental impact.</p>
                </div>
                <div class="feature-card">
                    <div class="feature-icon">
                        <i class="fas fa-map-marked-alt"></i>
                    </div>
                    <h4 class="text-white mb-3">Real-Time Tracking</h4>
                    <p class="text-light">Monitor your waste collection with live GPS tracking, arrival estimates, and driver updates.</p>
                </div>
                <div class="feature-card">
                    <div class="feature-icon">
                        <i class="fas fa-chart-pie"></i>
                    </div>
                    <h4 class="text-white mb-3">Smart Analytics</h4>
                    <p class="text-light">Comprehensive waste analytics and insights to help you understand and improve your recycling habits.</p>
                </div>
                <div class="feature-card">
                    <div class="feature-icon">
                        <i class="fas fa-bell"></i>
                    </div>
                    <h4 class="text-white mb-3">Smart Notifications</h4>
                    <p class="text-light">Automated reminders, collection alerts, and service updates to keep you informed.</p>
                </div>
                <div class="feature-card">
                    <div class="feature-icon">
                        <i class="fas fa-wallet"></i>
                    </div>
                    <h4 class="text-white mb-3">Digital Payments</h4>
                    <p class="text-light">Secure, cashless transactions with multiple payment options and transparent pricing.</p>
                </div>
                <div class="feature-card">
                    <div class="feature-icon">
                        <i class="fas fa-leaf"></i>
                    </div>
                    <h4 class="text-white mb-3">Impact Dashboard</h4>
                    <p class="text-light">Track your environmental impact with detailed metrics on CO2 reduction and resources saved.</p>
                </div>
            </div>
        </div>
    </section>

    <!-- Stats Section -->
    <section class="stats-section">
        <div class="container">
            <div class="row text-center">
                <div class="col-md-3 col-6">
                    <div class="stat-card">
                        <div class="stat-number">5min</div>
                        <div class="stat-label">Average Setup</div>
                    </div>
                </div>
                <div class="col-md-3 col-6">
                    <div class="stat-card">
                        <div class="stat-number">24/7</div>
                        <div class="stat-label">Service Available</div>
                    </div>
                </div>
                <div class="col-md-3 col-6">
                    <div class="stat-card">
                        <div class="stat-number">98%</div>
                        <div class="stat-label">On-Time Rate</div>
                    </div>
                </div>
                <div class="col-md-3 col-6">
                    <div class="stat-card">
                        <div class="stat-number">4.9★</div>
                        <div class="stat-label">User Rating</div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Apps Section -->
    <section class="apps-showcase">
        <div class="container">
            <div class="row g-5">
                <div class="col-lg-6">
                    <div class="app-platform">
                        <div class="platform-icon">
                            <i class="fab fa-apple"></i>
                        </div>
                        <h3 class="text-white mb-3">iOS App</h3>
                        <p class="text-light mb-4">Experience seamless waste management with our native iOS application. Optimized for iPhone and iPad with intuitive touch controls.</p>
                        <div class="store-buttons">
                            <a href="#" class="store-btn">
                                <i class="fab fa-apple me-2"></i>App Store
                            </a>
                        </div>
                    </div>
                </div>
                <div class="col-lg-6">
                    <div class="app-platform">
                        <div class="platform-icon">
                            <i class="fab fa-android"></i>
                        </div>
                        <h3 class="text-white mb-3">Android App</h3>
                        <p class="text-light mb-4">Full functionality on your Android device. Works seamlessly across all versions with optimized performance and battery efficiency.</p>
                        <div class="store-buttons">
                            <a href="#" class="store-btn">
                                <i class="fab fa-google-play me-2"></i>Play Store
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- CTA Section -->
    <section class="cta-process">
        <div class="container">
            <div class="cta-content">
                <h2 class="display-4 fw-bold text-white mb-4">Ready to Get Started?</h2>
                <p class="lead text-light mb-5">Join thousands of users who are transforming their waste management experience with SoorGreen.</p>
                <div class="btn-group">
                    <a href="SignUp.aspx" class="btn-primary-custom">
                        <i class="fas fa-rocket me-2"></i>Start Free Trial
                    </a>
                    <a href="Contact.aspx" class="btn-outline-custom">
                        <i class="fas fa-question-circle me-2"></i>Learn More
                    </a>
                </div>
            </div>
        </div>
    </section>

    <script>
        // Animation for timeline items
        document.addEventListener('DOMContentLoaded', function () {
            const observer = new IntersectionObserver((entries) => {
                entries.forEach(entry => {
                    if (entry.isIntersecting) {
                        entry.target.style.opacity = '1';
                        entry.target.style.transform = 'translateX(0)';
                    }
                });
            }, { threshold: 0.1 });

            // Animate timeline items from respective sides
            document.querySelectorAll('.timeline-item:nth-child(odd) .timeline-content').forEach(el => {
                el.style.opacity = '0';
                el.style.transform = 'translateX(-50px)';
                el.style.transition = 'all 0.6s ease';
                observer.observe(el);
            });

            document.querySelectorAll('.timeline-item:nth-child(even) .timeline-content').forEach(el => {
                el.style.opacity = '0';
                el.style.transform = 'translateX(50px)';
                el.style.transition = 'all 0.6s ease';
                observer.observe(el);
            });

            // Smooth scrolling
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
</asp:Content>