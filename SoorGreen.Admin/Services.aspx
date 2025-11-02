<%@ Page Title="Services" Language="C#" MasterPageFile="~/Site.Master" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <style>
        /* Services Page Specific Styles */
        .services-hero-section {
            min-height: 60vh;
            display: flex;
            align-items: center;
            position: relative;
            overflow: hidden;
            background: radial-gradient(ellipse at center, rgba(0, 212, 170, 0.1) 0%, transparent 70%);
            padding-top: 100px;
        }

        .service-card {
            background: var(--card-bg);
            border: 1px solid var(--card-border);
            border-radius: 20px;
            padding: 3rem 2rem;
            transition: all 0.3s ease;
            backdrop-filter: blur(10px);
            height: 100%;
            text-align: center;
            opacity: 1 !important;
            transform: translateY(0) !important;
        }

        .service-card:hover {
            transform: translateY(-10px);
            border-color: var(--primary);
            box-shadow: 0 25px 50px rgba(0, 0, 0, 0.3);
        }

        .service-icon {
            font-size: 4rem;
            color: var(--primary);
            margin-bottom: 1.5rem;
        }

        .service-features {
            list-style: none;
            padding: 0;
            margin: 1.5rem 0;
        }

        .service-features li {
            padding: 0.5rem 0;
            color: rgba(255, 255, 255, 0.8);
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
        }

        .service-features li:last-child {
            border-bottom: none;
        }

        .service-features li i {
            color: var(--primary);
            margin-right: 0.5rem;
        }

        /* Process Steps */
        .process-step {
            position: relative;
            padding: 2rem;
            background: var(--card-bg);
            border: 1px solid var(--card-border);
            border-radius: 15px;
            margin-bottom: 2rem;
            backdrop-filter: blur(10px);
            opacity: 1 !important;
            transform: translateY(0) !important;
        }

        .step-number {
            position: absolute;
            top: -20px;
            left: 20px;
            width: 40px;
            height: 40px;
            background: linear-gradient(45deg, var(--primary), var(--secondary));
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 700;
            color: white;
        }

        /* Service Categories */
        .category-card {
            background: var(--card-bg);
            border: 1px solid var(--card-border);
            border-radius: 15px;
            padding: 2rem;
            transition: all 0.3s ease;
            backdrop-filter: blur(10px);
            text-align: center;
            opacity: 1 !important;
            transform: translateY(0) !important;
        }

        .category-card:hover {
            transform: translateY(-5px);
            border-color: var(--primary);
        }

        .category-icon {
            font-size: 3rem;
            color: var(--primary);
            margin-bottom: 1rem;
        }

        /* Benefits Grid */
        .benefit-item {
            background: var(--card-bg);
            border: 1px solid var(--card-border);
            border-radius: 15px;
            padding: 2rem;
            transition: all 0.3s ease;
            backdrop-filter: blur(10px);
            opacity: 1 !important;
            transform: translateY(0) !important;
        }

        .benefit-item:hover {
            transform: translateY(-5px);
            border-color: var(--primary);
        }

        .benefit-icon {
            font-size: 2.5rem;
            color: var(--primary);
            margin-bottom: 1rem;
        }

        /* Coverage Map */
        .coverage-map {
            background: linear-gradient(45deg, var(--primary), var(--secondary));
            height: 400px;
            border-radius: 20px;
            position: relative;
            overflow: hidden;
        }

        .map-marker {
            position: absolute;
            width: 20px;
            height: 20px;
            background: var(--accent);
            border-radius: 50%;
            transform: translate(-50%, -50%);
            animation: pulse 2s infinite;
        }

        @keyframes pulse {
            0% { transform: translate(-50%, -50%) scale(1); opacity: 1; }
            50% { transform: translate(-50%, -50%) scale(1.5); opacity: 0.7; }
            100% { transform: translate(-50%, -50%) scale(1); opacity: 1; }
        }

        /* Service Comparison */
        .comparison-table {
            background: var(--card-bg);
            border: 1px solid var(--card-border);
            border-radius: 15px;
            overflow: hidden;
            backdrop-filter: blur(10px);
        }

        .comparison-header {
            background: rgba(0, 212, 170, 0.1);
            padding: 1.5rem;
            border-bottom: 1px solid var(--card-border);
        }

        .comparison-row {
            display: flex;
            border-bottom: 1px solid var(--card-border);
        }

        .comparison-row:last-child {
            border-bottom: none;
        }

        .comparison-feature {
            flex: 1;
            padding: 1rem 1.5rem;
            border-right: 1px solid var(--card-border);
            display: flex;
            align-items: center;
        }

        .comparison-feature:last-child {
            border-right: none;
        }

        .feature-check {
            color: var(--primary);
            margin-right: 0.5rem;
        }

        .feature-cross {
            color: var(--accent);
            margin-right: 0.5rem;
        }

        /* Text Visibility Fixes */
        .text-muted {
            color: rgba(255, 255, 255, 0.7) !important;
            opacity: 1 !important;
        }

        .hero-title, .hero-subtitle {
            opacity: 1 !important;
            transform: translateY(0) !important;
        }

        /* Ensure all text elements are visible */
        .service-card h3,
        .service-card p,
        .benefit-item h5,
        .benefit-item p,
        .category-card h5,
        .category-card p,
        .process-step h4,
        .process-step p,
        .comparison-feature span,
        .comparison-feature strong {
            opacity: 1 !important;
            visibility: visible !important;
        }

        /* Responsive */
        @media (max-width: 768px) {
            .service-card {
                padding: 2rem 1rem;
            }
            
            .comparison-row {
                flex-direction: column;
            }
            
            .comparison-feature {
                border-right: none;
                border-bottom: 1px solid var(--card-border);
            }
            
            .comparison-feature:last-child {
                border-bottom: none;
            }
        }
    </style>

    <!-- Hero Section -->
    <section class="services-hero-section">
        <div class="container">
            <div class="row align-items-center">
                <div class="col-lg-6">
                    <span class="section-badge px-3 py-2 rounded-pill mb-3">Our Services</span>
                    <h1 class="hero-title mb-4">Comprehensive Waste Management Solutions</h1>
                    <p class="hero-subtitle mb-4">From smart collection to recycling innovation, we provide end-to-end waste management services that benefit citizens, businesses, and municipalities.</p>
                    <div class="d-flex flex-wrap gap-3">
                        <a href="#services" class="btn btn-hero">
                            <i class="fas fa-list me-2"></i>Explore Services
                        </a>
                        <a href="#process" class="btn btn-outline-hero">
                            <i class="fas fa-play-circle me-2"></i>How It Works
                        </a>
                    </div>
                </div>
                <div class="col-lg-6 text-center">
                    <div class="services-hero-visual">
                        <div class="services-hero-image rounded-3 shadow-lg"></div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Main Services Section -->
    <section id="services" class="services-main-section py-5">
        <div class="container">
            <div class="row text-center mb-5">
                <div class="col-lg-8 mx-auto">
                    <span class="section-badge bg-success bg-opacity-10 text-success px-3 py-2 rounded-pill mb-3">Core Services</span>
                    <h2 class="fw-bold display-5 mb-3 text-white">Smart Waste Management Solutions</h2>
                    <p class="lead text-muted fs-6">Comprehensive services designed for modern cities and environmentally conscious communities.</p>
                </div>
            </div>
            <div class="row g-4">
                <!-- Smart Waste Collection -->
                <div class="col-lg-4 col-md-6">
                    <div class="service-card">
                        <div class="service-icon">
                            <i class="fas fa-trash-alt"></i>
                        </div>
                        <h3 class="fw-bold mb-3 text-white">Smart Waste Collection</h3>
                        <p class="text-muted mb-4">AI-powered scheduling and route optimization for efficient waste pickup with real-time tracking.</p>
                        <ul class="service-features">
                            <li><i class="fas fa-check"></i> On-demand pickup scheduling</li>
                            <li><i class="fas fa-check"></i> Route optimization</li>
                            <li><i class="fas fa-check"></i> Real-time tracking</li>
                            <li><i class="fas fa-check"></i> Smart bin monitoring</li>
                        </ul>
                        <a href="WasteCollection.aspx" class="btn btn-outline-primary w-100">
                            <i class="fas fa-arrow-right me-2"></i>Learn More
                        </a>
                    </div>
                </div>

                <!-- Recycling Solutions -->
                <div class="col-lg-4 col-md-6">
                    <div class="service-card">
                        <div class="service-icon">
                            <i class="fas fa-recycle"></i>
                        </div>
                        <h3 class="fw-bold mb-3 text-white">Advanced Recycling</h3>
                        <p class="text-muted mb-4">Comprehensive recycling programs with material sorting and processing for maximum environmental impact.</p>
                        <ul class="service-features">
                            <li><i class="fas fa-check"></i> Material sorting facilities</li>
                            <li><i class="fas fa-check"></i> E-waste processing</li>
                            <li><i class="fas fa-check"></i> Organic waste conversion</li>
                            <li><i class="fas fa-check"></i> Recycling education</li>
                        </ul>
                        <a href="Recycling.aspx" class="btn btn-outline-primary w-100">
                            <i class="fas fa-arrow-right me-2"></i>Learn More
                        </a>
                    </div>
                </div>

                <!-- Reward System -->
                <div class="col-lg-4 col-md-6">
                    <div class="service-card">
                        <div class="service-icon">
                            <i class="fas fa-award"></i>
                        </div>
                        <h3 class="fw-bold mb-3 text-white">Green Rewards Program</h3>
                        <p class="text-muted mb-4">Earn credits for sustainable practices and redeem them for discounts, vouchers, and exclusive benefits.</p>
                        <ul class="service-features">
                            <li><i class="fas fa-check"></i> Credit earning system</li>
                            <li><i class="fas fa-check"></i> Partner discounts</li>
                            <li><i class="fas fa-check"></i> Charity donations</li>
                            <li><i class="fas fa-check"></i> Achievement badges</li>
                        </ul>
                        <a href="Rewards.aspx" class="btn btn-outline-primary w-100">
                            <i class="fas fa-arrow-right me-2"></i>Learn More
                        </a>
                    </div>
                </div>

                <!-- Municipal Dashboard -->
                <div class="col-lg-4 col-md-6">
                    <div class="service-card">
                        <div class="service-icon">
                            <i class="fas fa-chart-line"></i>
                        </div>
                        <h3 class="fw-bold mb-3 text-white">Municipal Analytics</h3>
                        <p class="text-muted mb-4">Comprehensive dashboards and analytics for cities to optimize waste management operations and reduce costs.</p>
                        <ul class="service-features">
                            <li><i class="fas fa-check"></i> Real-time analytics</li>
                            <li><i class="fas fa-check"></i> Cost optimization</li>
                            <li><i class="fas fa-check"></i> Compliance reporting</li>
                            <li><i class="fas fa-check"></i> Predictive modeling</li>
                        </ul>
                        <a href="MunicipalDashboard.aspx" class="btn btn-outline-primary w-100">
                            <i class="fas fa-arrow-right me-2"></i>Learn More
                        </a>
                    </div>
                </div>

                <!-- Business Solutions -->
                <div class="col-lg-4 col-md-6">
                    <div class="service-card">
                        <div class="service-icon">
                            <i class="fas fa-building"></i>
                        </div>
                        <h3 class="fw-bold mb-3 text-white">Business Waste Management</h3>
                        <p class="text-muted mb-4">Tailored solutions for commercial establishments to manage waste efficiently and meet sustainability goals.</p>
                        <ul class="service-features">
                            <li><i class="fas fa-check"></i> Commercial recycling</li>
                            <li><i class="fas fa-check"></i> Waste auditing</li>
                            <li><i class="fas fa-check"></i> Sustainability reporting</li>
                            <li><i class="fas fa-check"></i> Compliance management</li>
                        </ul>
                        <a href="BusinessSolutions.aspx" class="btn btn-outline-primary w-100">
                            <i class="fas fa-arrow-right me-2"></i>Learn More
                        </a>
                    </div>
                </div>

                <!-- API Integration -->
                <div class="col-lg-4 col-md-6">
                    <div class="service-card">
                        <div class="service-icon">
                            <i class="fas fa-code"></i>
                        </div>
                        <h3 class="fw-bold mb-3 text-white">API & Integration</h3>
                        <p class="text-muted mb-4">Robust APIs and integration services to connect SoorGreen with existing municipal and business systems.</p>
                        <ul class="service-features">
                            <li><i class="fas fa-check"></i> RESTful APIs</li>
                            <li><i class="fas fa-check"></i> Webhook support</li>
                            <li><i class="fas fa-check"></i> Custom integration</li>
                            <li><i class="fas fa-check"></i> Technical support</li>
                        </ul>
                        <a href="API.aspx" class="btn btn-outline-primary w-100">
                            <i class="fas fa-arrow-right me-2"></i>Learn More
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- How It Works Section -->
    <section id="process" class="process-section py-5">
        <div class="container">
            <div class="row text-center mb-5">
                <div class="col-lg-8 mx-auto">
                    <span class="section-badge bg-info bg-opacity-10 text-info px-3 py-2 rounded-pill mb-3">Process</span>
                    <h2 class="fw-bold display-5 mb-3 text-white">How Our Services Work</h2>
                    <p class="lead text-muted fs-6">Simple, efficient process from waste reporting to reward redemption.</p>
                </div>
            </div>
            <div class="row">
                <div class="col-lg-10 mx-auto">
                    <div class="process-step">
                        <div class="step-number">1</div>
                        <div class="row align-items-center">
                            <div class="col-md-2 text-center">
                                <i class="fas fa-mobile-alt fa-3x text-primary mb-3"></i>
                            </div>
                            <div class="col-md-10">
                                <h4 class="fw-bold text-white mb-3">Report Waste</h4>
                                <p class="text-muted mb-0">Citizens use our mobile app or web portal to report waste, providing details about type, quantity, and location. The system automatically schedules the most efficient pickup route.</p>
                            </div>
                        </div>
                    </div>

                    <div class="process-step">
                        <div class="step-number">2</div>
                        <div class="row align-items-center">
                            <div class="col-md-2 text-center">
                                <i class="fas fa-truck fa-3x text-success mb-3"></i>
                            </div>
                            <div class="col-md-10">
                                <h4 class="fw-bold text-white mb-3">Smart Collection</h4>
                                <p class="text-muted mb-0">Our AI-optimized routing system assigns collectors and creates the most efficient pickup routes. Real-time tracking ensures timely collection and updates.</p>
                            </div>
                        </div>
                    </div>

                    <div class="process-step">
                        <div class="step-number">3</div>
                        <div class="row align-items-center">
                            <div class="col-md-2 text-center">
                                <i class="fas fa-recycle fa-3x text-warning mb-3"></i>
                            </div>
                            <div class="col-md-10">
                                <h4 class="fw-bold text-white mb-3">Processing & Recycling</h4>
                                <p class="text-muted mb-0">Collected waste is sorted at our facilities. Recyclable materials are processed, while non-recyclables are disposed of responsibly. All activities are tracked and reported.</p>
                            </div>
                        </div>
                    </div>

                    <div class="process-step">
                        <div class="step-number">4</div>
                        <div class="row align-items-center">
                            <div class="col-md-2 text-center">
                                <i class="fas fa-gift fa-3x text-primary mb-3"></i>
                            </div>
                            <div class="col-md-10">
                                <h4 class="fw-bold text-white mb-3">Earn Rewards</h4>
                                <p class="text-muted mb-0">Citizens earn green credits based on the type and quantity of waste recycled. Credits can be redeemed for discounts, vouchers, or donated to environmental causes.</p>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Service Categories -->
    <section class="categories-section py-5">
        <div class="container">
            <div class="row text-center mb-5">
                <div class="col-lg-8 mx-auto">
                    <span class="section-badge bg-warning bg-opacity-10 text-warning px-3 py-2 rounded-pill mb-3">Categories</span>
                    <h2 class="fw-bold display-5 mb-3 text-white">Waste Types We Handle</h2>
                    <p class="lead text-muted fs-6">Comprehensive handling of various waste streams with specialized processing for each category.</p>
                </div>
            </div>
            <div class="row g-4">
                <div class="col-lg-3 col-md-6">
                    <div class="category-card">
                        <div class="category-icon">
                            <i class="fas fa-newspaper"></i>
                        </div>
                        <h5 class="fw-bold text-white mb-2">Paper & Cardboard</h5>
                        <p class="text-muted small">Newspapers, magazines, cardboard boxes, office paper</p>
                        <span class="badge bg-primary">2 credits/kg</span>
                    </div>
                </div>
                <div class="col-lg-3 col-md-6">
                    <div class="category-card">
                        <div class="category-icon">
                            <i class="fas fa-wine-bottle"></i>
                        </div>
                        <h5 class="fw-bold text-white mb-2">Plastic</h5>
                        <p class="text-muted small">Bottles, containers, packaging materials</p>
                        <span class="badge bg-success">3 credits/kg</span>
                    </div>
                </div>
                <div class="col-lg-3 col-md-6">
                    <div class="category-card">
                        <div class="category-icon">
                            <i class="fas fa-glass-whiskey"></i>
                        </div>
                        <h5 class="fw-bold text-white mb-2">Glass</h5>
                        <p class="text-muted small">Bottles, jars, glass containers</p>
                        <span class="badge bg-info">2 credits/kg</span>
                    </div>
                </div>
                <div class="col-lg-3 col-md-6">
                    <div class="category-card">
                        <div class="category-icon">
                            <i class="fas fa-cube"></i>
                        </div>
                        <h5 class="fw-bold text-white mb-2">Metal</h5>
                        <p class="text-muted small">Aluminum cans, tin containers, scrap metal</p>
                        <span class="badge bg-warning">4 credits/kg</span>
                    </div>
                </div>
                <div class="col-lg-3 col-md-6">
                    <div class="category-card">
                        <div class="category-icon">
                            <i class="fas fa-leaf"></i>
                        </div>
                        <h5 class="fw-bold text-white mb-2">Organic Waste</h5>
                        <p class="text-muted small">Food scraps, garden waste, compostables</p>
                        <span class="badge bg-success">1 credit/kg</span>
                    </div>
                </div>
                <div class="col-lg-3 col-md-6">
                    <div class="category-card">
                        <div class="category-icon">
                            <i class="fas fa-laptop"></i>
                        </div>
                        <h5 class="fw-bold text-white mb-2">E-Waste</h5>
                        <p class="text-muted small">Electronics, batteries, electrical equipment</p>
                        <span class="badge bg-danger">5 credits/kg</span>
                    </div>
                </div>
                <div class="col-lg-3 col-md-6">
                    <div class="category-card">
                        <div class="category-icon">
                            <i class="fas fa-exclamation-triangle"></i>
                        </div>
                        <h5 class="fw-bold text-white mb-2">Hazardous Waste</h5>
                        <p class="text-muted small">Chemicals, paints, medical waste (special handling)</p>
                        <span class="badge bg-dark">Special</span>
                    </div>
                </div>
                <div class="col-lg-3 col-md-6">
                    <div class="category-card">
                        <div class="category-icon">
                            <i class="fas fa-tshirt"></i>
                        </div>
                        <h5 class="fw-bold text-white mb-2">Textiles</h5>
                        <p class="text-muted small">Clothing, fabrics, shoes</p>
                        <span class="badge bg-info">2 credits/kg</span>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Benefits Section -->
    <section class="benefits-section py-5">
        <div class="container">
            <div class="row text-center mb-5">
                <div class="col-lg-8 mx-auto">
                    <span class="section-badge bg-primary bg-opacity-10 text-primary px-3 py-2 rounded-pill mb-3">Benefits</span>
                    <h2 class="fw-bold display-5 mb-3 text-white">Why Choose SoorGreen Services</h2>
                    <p class="lead text-muted fs-6">Comprehensive benefits for citizens, businesses, and municipalities.</p>
                </div>
            </div>
            <div class="row g-4">
                <div class="col-lg-4 col-md-6">
                    <div class="benefit-item">
                        <div class="benefit-icon">
                            <i class="fas fa-money-bill-wave"></i>
                        </div>
                        <h5 class="fw-bold text-white mb-3">Cost Savings</h5>
                        <p class="text-muted">Reduce waste management costs by up to 40% through optimized routes and efficient operations.</p>
                    </div>
                </div>
                <div class="col-lg-4 col-md-6">
                    <div class="benefit-item">
                        <div class="benefit-icon">
                            <i class="fas fa-chart-line"></i>
                        </div>
                        <h5 class="fw-bold text-white mb-3">Real-time Analytics</h5>
                        <p class="text-muted">Comprehensive dashboards and reporting for data-driven decision making and performance tracking.</p>
                    </div>
                </div>
                <div class="col-lg-4 col-md-6">
                    <div class="benefit-item">
                        <div class="benefit-icon">
                            <i class="fas fa-shield-alt"></i>
                        </div>
                        <h5 class="fw-bold text-white mb-3">Environmental Compliance</h5>
                        <p class="text-muted">Stay compliant with environmental regulations and sustainability standards with automated reporting.</p>
                    </div>
                </div>
                <div class="col-lg-4 col-md-6">
                    <div class="benefit-item">
                        <div class="benefit-icon">
                            <i class="fas fa-users"></i>
                        </div>
                        <h5 class="fw-bold text-white mb-3">Community Engagement</h5>
                        <p class="text-muted">Increase citizen participation in waste management through our reward system and educational programs.</p>
                    </div>
                </div>
                <div class="col-lg-4 col-md-6">
                    <div class="benefit-item">
                        <div class="benefit-icon">
                            <i class="fas fa-bolt"></i>
                        </div>
                        <h5 class="fw-bold text-white mb-3">Operational Efficiency</h5>
                        <p class="text-muted">Streamline operations with AI-powered routing, automated scheduling, and real-time monitoring.</p>
                    </div>
                </div>
                <div class="col-lg-4 col-md-6">
                    <div class="benefit-item">
                        <div class="benefit-icon">
                            <i class="fas fa-trophy"></i>
                        </div>
                        <h5 class="fw-bold text-white mb-3">Brand Enhancement</h5>
                        <p class="text-muted">Enhance your brand image through demonstrated commitment to sustainability and community welfare.</p>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Service Comparison -->
    <section class="comparison-section py-5">
        <div class="container">
            <div class="row text-center mb-5">
                <div class="col-lg-8 mx-auto">
                    <span class="section-badge bg-success bg-opacity-10 text-success px-3 py-2 rounded-pill mb-3">Comparison</span>
                    <h2 class="fw-bold display-5 mb-3 text-white">Service Tiers</h2>
                    <p class="lead text-muted fs-6">Choose the plan that fits your needs - from individual citizens to entire municipalities.</p>
                </div>
            </div>
            <div class="row justify-content-center">
                <div class="col-lg-10">
                    <div class="comparison-table">
                        <div class="comparison-header text-center">
                            <h4 class="fw-bold text-white mb-0">Feature Comparison</h4>
                        </div>
                        <div class="comparison-row">
                            <div class="comparison-feature">
                                <strong class="text-white">Service Features</strong>
                            </div>
                            <div class="comparison-feature text-center">
                                <strong class="text-primary">Citizen</strong>
                            </div>
                            <div class="comparison-feature text-center">
                                <strong class="text-success">Business</strong>
                            </div>
                            <div class="comparison-feature text-center">
                                <strong class="text-warning">Municipality</strong>
                            </div>
                        </div>
                        <div class="comparison-row">
                            <div class="comparison-feature">
                                <span class="text-white">Waste Reporting</span>
                            </div>
                            <div class="comparison-feature text-center">
                                <i class="fas fa-check feature-check"></i>
                            </div>
                            <div class="comparison-feature text-center">
                                <i class="fas fa-check feature-check"></i>
                            </div>
                            <div class="comparison-feature text-center">
                                <i class="fas fa-check feature-check"></i>
                            </div>
                        </div>
                        <div class="comparison-row">
                            <div class="comparison-feature">
                                <span class="text-white">Reward System</span>
                            </div>
                            <div class="comparison-feature text-center">
                                <i class="fas fa-check feature-check"></i>
                            </div>
                            <div class="comparison-feature text-center">
                                <i class="fas fa-check feature-check"></i>
                            </div>
                            <div class="comparison-feature text-center">
                                <i class="fas fa-check feature-check"></i>
                            </div>
                        </div>
                        <div class="comparison-row">
                            <div class="comparison-feature">
                                <span class="text-white">Advanced Analytics</span>
                            </div>
                            <div class="comparison-feature text-center">
                                <i class="fas fa-times feature-cross"></i>
                            </div>
                            <div class="comparison-feature text-center">
                                <i class="fas fa-check feature-check"></i>
                            </div>
                            <div class="comparison-feature text-center">
                                <i class="fas fa-check feature-check"></i>
                            </div>
                        </div>
                        <div class="comparison-row">
                            <div class="comparison-feature">
                                <span class="text-white">Custom Reporting</span>
                            </div>
                            <div class="comparison-feature text-center">
                                <i class="fas fa-times feature-cross"></i>
                            </div>
                            <div class="comparison-feature text-center">
                                <i class="fas fa-check feature-check"></i>
                            </div>
                            <div class="comparison-feature text-center">
                                <i class="fas fa-check feature-check"></i>
                            </div>
                        </div>
                        <div class="comparison-row">
                            <div class="comparison-feature">
                                <span class="text-white">API Access</span>
                            </div>
                            <div class="comparison-feature text-center">
                                <i class="fas fa-times feature-cross"></i>
                            </div>
                            <div class="comparison-feature text-center">
                                <i class="fas fa-check feature-check"></i>
                            </div>
                            <div class="comparison-feature text-center">
                                <i class="fas fa-check feature-check"></i>
                            </div>
                        </div>
                        <div class="comparison-row">
                            <div class="comparison-feature">
                                <span class="text-white">Dedicated Support</span>
                            </div>
                            <div class="comparison-feature text-center">
                                <i class="fas fa-times feature-cross"></i>
                            </div>
                            <div class="comparison-feature text-center">
                                <i class="fas fa-check feature-check"></i>
                            </div>
                            <div class="comparison-feature text-center">
                                <i class="fas fa-check feature-check"></i>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- CTA Section -->
    <section class="cta-section py-5">
        <div class="container">
            <div class="row align-items-center text-center">
                <div class="col-lg-8 mx-auto">
                    <h2 class="fw-bold display-5 mb-3 text-white">Ready to Transform Your Waste Management?</h2>
                    <p class="lead text-muted mb-4">Join thousands of satisfied users and experience the future of sustainable waste management.</p>
                    <div class="d-flex flex-wrap gap-3 justify-content-center">
                        <a href="ChooseApp.aspx" class="btn btn-hero">
                            <i class="fas fa-rocket me-2"></i>Get Started Today
                        </a>
                        <a href="Contact.aspx" class="btn btn-outline-hero">
                            <i class="fas fa-phone me-2"></i>Contact Sales
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <script>
        // Smooth scrolling for anchor links only
        document.addEventListener('DOMContentLoaded', function () {
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