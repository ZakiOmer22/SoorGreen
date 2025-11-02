<%@ Page Title="About" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="false" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <style>
        /* About Page Specific Styles */
        .about-hero-section {
            min-height: 70vh;
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
            0%, 100% { transform: translate(0, 0) rotate(0deg) scale(1); }
            25% { transform: translate(50px, -40px) rotate(90deg) scale(1.1); }
            50% { transform: translate(25px, -60px) rotate(180deg) scale(0.9); }
            75% { transform: translate(-40px, -30px) rotate(270deg) scale(1.05); }
        }

        .about-hero-image {
            background: linear-gradient(45deg, var(--primary), var(--secondary));
            height: 400px;
            width: 100%;
            border-radius: 20px;
            position: relative;
            overflow: hidden;
        }

        .about-hero-image::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: url('data:image/svg+xml,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100"><circle cx="50" cy="50" r="2" fill="white" opacity="0.1"/></svg>') repeat;
            animation: sparkle 4s linear infinite;
        }

        /* Mission & Vision Cards */
        .mission-card, .vision-card {
            background: var(--card-bg);
            border: 1px solid var(--card-border);
            border-radius: 20px;
            transition: all 0.3s ease;
            backdrop-filter: blur(10px);
        }

        .mission-card:hover, .vision-card:hover {
            transform: translateY(-10px);
            border-color: var(--primary);
            box-shadow: 0 25px 50px rgba(0, 0, 0, 0.3);
        }

        .mission-icon, .vision-icon {
            font-size: 3rem;
            color: var(--primary);
        }

        /* Story Section */
        .story-image {
            background: linear-gradient(45deg, var(--primary), var(--secondary));
            height: 500px;
            width: 100%;
            border-radius: 20px;
            position: relative;
            overflow: hidden;
        }

        .milestone-year {
            width: 60px;
            height: 60px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 700;
            flex-shrink: 0;
        }

        /* Values Section */
        .value-card {
            background: var(--card-bg);
            border: 1px solid var(--card-border);
            border-radius: 20px;
            transition: all 0.3s ease;
            backdrop-filter: blur(10px);
        }

        .value-card:hover {
            transform: translateY(-10px);
            border-color: var(--primary);
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.3);
        }

        .value-icon {
            font-size: 3rem;
            color: var(--primary);
        }

        /* Team Section */
        .team-card {
            background: var(--card-bg);
            border: 1px solid var(--card-border);
            border-radius: 20px;
            transition: all 0.3s ease;
            backdrop-filter: blur(10px);
        }

        .team-card:hover {
            transform: translateY(-10px);
            border-color: var(--primary);
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.3);
        }

        .avatar-image {
            width: 120px;
            height: 120px;
            border-radius: 50%;
            margin: 0 auto;
            background: linear-gradient(45deg, var(--primary), var(--secondary));
        }

        .team-social {
            display: flex;
            justify-content: center;
            gap: 1rem;
        }

        .social-link {
            width: 40px;
            height: 40px;
            background: rgba(255, 255, 255, 0.1);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            text-decoration: none;
            transition: all 0.3s ease;
        }

        .social-link:hover {
            background: var(--primary);
            transform: translateY(-3px);
        }

        /* Impact Section */
        .impact-section {
            background: linear-gradient(135deg, var(--primary), var(--secondary)) !important;
        }

        .impact-stat {
            padding: 2rem 1rem;
        }

        .impact-number {
            text-shadow: 0 0 20px rgba(255, 255, 255, 0.3);
        }

        /* Partners Section */
        .partner-logo {
            background: var(--card-bg);
            border: 1px solid var(--card-border);
            border-radius: 15px;
            height: 120px;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: all 0.3s ease;
            backdrop-filter: blur(10px);
        }

        .partner-logo:hover {
            transform: translateY(-5px);
            border-color: var(--primary);
        }

        .partner-logo i {
            color: var(--primary);
            transition: all 0.3s ease;
        }

        .partner-logo:hover i {
            transform: scale(1.2);
        }

        /* CTA Section */
        .cta-section {
            background: rgba(255, 255, 255, 0.03) !important;
        }

        /* Text Colors */
        .text-primary { color: var(--primary) !important; }
        .text-success { color: var(--primary) !important; }
        .text-warning { color: var(--accent) !important; }
        .text-info { color: var(--secondary) !important; }
        .text-muted { color: rgba(255, 255, 255, 0.6) !important; }
        .text-dark { color: white !important; }
        .text-white-50 { color: rgba(255, 255, 255, 0.7) !important; }

        /* Background Colors */
        .bg-white { background: var(--card-bg) !important; }
        .bg-light { background: rgba(255, 255, 255, 0.03) !important; }
        .bg-primary { background: linear-gradient(135deg, var(--primary), var(--secondary)) !important; }

        /* Button Styles */
        .btn-primary {
            background: var(--primary);
            border: none;
            transition: all 0.3s ease;
        }

        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 20px rgba(0, 212, 170, 0.3);
        }

        .btn-outline-primary {
            border: 2px solid var(--primary);
            color: var(--primary);
            background: transparent;
            transition: all 0.3s ease;
        }

        .btn-outline-primary:hover {
            background: var(--primary);
            color: white;
            transform: translateY(-2px);
        }

        /* Section Badge */
        .section-badge {
            background: rgba(0, 212, 170, 0.1) !important;
            border: 1px solid rgba(0, 212, 170, 0.3);
            color: var(--primary) !important;
            backdrop-filter: blur(10px);
        }

        /* Responsive */
        @media (max-width: 768px) {
            .about-hero-section {
                min-height: auto;
                padding: 100px 0 50px;
            }
            
            .floating-element {
                display: none;
            }
            
            .about-hero-image {
                height: 300px;
                margin-top: 2rem;
            }
            
            .story-image {
                height: 300px;
                margin-bottom: 2rem;
            }
        }
    </style>

    <!-- Hero Section -->
    <section class="about-hero-section">
        <div class="container">
            <div class="row align-items-center">
                <div class="col-lg-6">
                    <span class="section-badge px-3 py-2 rounded-pill mb-3">About SoorGreen</span>
                    <h1 class="hero-title mb-4">Building a Sustainable Future Through Innovation</h1>
                    <p class="hero-subtitle mb-4">We're revolutionizing waste management by connecting communities, technology, and sustainability to create cleaner, greener cities for generations to come.</p>
                    <div class="d-flex flex-wrap gap-3">
                        <a href="#mission" class="btn btn-hero">
                            <i class="fas fa-bullseye me-2"></i>Our Mission
                        </a>
                        <a href="#team" class="btn btn-outline-hero">
                            <i class="fas fa-users me-2"></i>Meet Our Team
                        </a>
                    </div>
                </div>
                <div class="col-lg-6 text-center">
                    <div class="about-hero-visual position-relative">
                        <div class="floating-element element-1">
                            <i class="fas fa-leaf text-success"></i>
                        </div>
                        <div class="floating-element element-2">
                            <i class="fas fa-recycle text-primary"></i>
                        </div>
                        <div class="floating-element element-3">
                            <i class="fas fa-globe text-warning"></i>
                        </div>
                        <div class="about-hero-image rounded-3 shadow-lg"></div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Mission & Vision Section -->
    <section id="mission" class="mission-section py-5">
        <div class="container">
            <div class="row text-center mb-5">
                <div class="col-lg-8 mx-auto">
                    <span class="section-badge px-3 py-2 rounded-pill mb-3">Our Purpose</span>
                    <h2 class="fw-bold display-5 mb-3 text-white">Driving Sustainable Change</h2>
                    <p class="lead text-muted fs-6">We believe in creating technology that serves both people and the planet.</p>
                </div>
            </div>
            <div class="row g-5">
                <div class="col-lg-6">
                    <div class="mission-card p-5 h-100">
                        <div class="mission-icon mb-4">
                            <i class="fas fa-bullseye"></i>
                        </div>
                        <h3 class="fw-bold mb-3 text-white">Our Mission</h3>
                        <p class="text-muted mb-4">To transform waste management through innovative technology that empowers communities, reduces environmental impact, and creates sustainable economic opportunities for all stakeholders.</p>
                        <ul class="list-unstyled">
                            <li class="mb-2"><i class="fas fa-check text-success me-2"></i> Empower communities with smart waste solutions</li>
                            <li class="mb-2"><i class="fas fa-check text-success me-2"></i> Reduce landfill waste by 50% in target cities</li>
                            <li class="mb-2"><i class="fas fa-check text-success me-2"></i> Create green jobs and economic opportunities</li>
                        </ul>
                    </div>
                </div>
                <div class="col-lg-6">
                    <div class="vision-card p-5 h-100">
                        <div class="vision-icon mb-4">
                            <i class="fas fa-eye text-success"></i>
                        </div>
                        <h3 class="fw-bold mb-3 text-white">Our Vision</h3>
                        <p class="text-muted mb-4">To create a world where waste is viewed as a resource, communities are actively engaged in sustainability, and technology bridges the gap between environmental responsibility and economic growth.</p>
                        <ul class="list-unstyled">
                            <li class="mb-2"><i class="fas fa-check text-success me-2"></i> Zero waste cities by 2040</li>
                            <li class="mb-2"><i class="fas fa-check text-success me-2"></i> Global network of sustainable communities</li>
                            <li class="mb-2"><i class="fas fa-check text-success me-2"></i> Technology-driven circular economy</li>
                        </ul>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Story Section -->
    <section class="story-section py-5">
        <div class="container">
            <div class="row align-items-center">
                <div class="col-lg-6">
                    <div class="story-image rounded-3 shadow"></div>
                </div>
                <div class="col-lg-6">
                    <span class="section-badge bg-warning bg-opacity-10 text-warning px-3 py-2 rounded-pill mb-3">Our Story</span>
                    <h2 class="fw-bold display-5 mb-4 text-white">From Idea to Impact</h2>
                    <p class="text-muted mb-4">Founded in 2020, SoorGreen began as a simple observation: our cities were drowning in waste while communities struggled with inefficient collection systems.</p>
                    <p class="text-muted mb-4">What started as a university project has grown into a comprehensive platform serving thousands of users across multiple cities, transforming how communities manage waste and embrace sustainability.</p>
                    
                    <div class="milestones">
                        <div class="milestone-item d-flex align-items-center mb-3">
                            <div class="milestone-year bg-primary text-white rounded-circle me-3">2020</div>
                            <div>
                                <h6 class="fw-bold mb-1 text-white">Founded</h6>
                                <p class="text-muted mb-0 small">Started as a university research project</p>
                            </div>
                        </div>
                        <div class="milestone-item d-flex align-items-center mb-3">
                            <div class="milestone-year bg-success text-white rounded-circle me-3">2021</div>
                            <div>
                                <h6 class="fw-bold mb-1 text-white">First Deployment</h6>
                                <p class="text-muted mb-0 small">Launched in our first pilot community</p>
                            </div>
                        </div>
                        <div class="milestone-item d-flex align-items-center mb-3">
                            <div class="milestone-year bg-info text-white rounded-circle me-3">2023</div>
                            <div>
                                <h6 class="fw-bold mb-1 text-white">City Partnership</h6>
                                <p class="text-muted mb-0 small">Expanded to serve entire municipalities</p>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Values Section -->
    <section class="values-section py-5">
        <div class="container">
            <div class="row text-center mb-5">
                <div class="col-lg-8 mx-auto">
                    <span class="section-badge bg-info bg-opacity-10 text-info px-3 py-2 rounded-pill mb-3">Our Values</span>
                    <h2 class="fw-bold display-5 mb-3 text-white">What Guides Our Work</h2>
                    <p class="lead text-muted fs-6">These core principles shape every decision we make and every feature we build.</p>
                </div>
            </div>
            <div class="row g-4">
                <div class="col-lg-4 col-md-6">
                    <div class="value-card text-center p-4 h-100">
                        <div class="value-icon mx-auto mb-4">
                            <i class="fas fa-handshake"></i>
                        </div>
                        <h4 class="fw-bold mb-3 text-white">Community First</h4>
                        <p class="text-muted">We believe technology should serve people. Every feature is designed with real community needs in mind.</p>
                    </div>
                </div>
                <div class="col-lg-4 col-md-6">
                    <div class="value-card text-center p-4 h-100">
                        <div class="value-icon mx-auto mb-4">
                            <i class="fas fa-shield-alt text-success"></i>
                        </div>
                        <h4 class="fw-bold mb-3 text-white">Environmental Stewardship</h4>
                        <p class="text-muted">We're committed to reducing environmental impact and promoting sustainable practices.</p>
                    </div>
                </div>
                <div class="col-lg-4 col-md-6">
                    <div class="value-card text-center p-4 h-100">
                        <div class="value-icon mx-auto mb-4">
                            <i class="fas fa-lightbulb text-warning"></i>
                        </div>
                        <h4 class="fw-bold mb-3 text-white">Innovation</h4>
                        <p class="text-muted">We constantly push boundaries to create smarter, more efficient waste management solutions.</p>
                    </div>
                </div>
                <div class="col-lg-4 col-md-6">
                    <div class="value-card text-center p-4 h-100">
                        <div class="value-icon mx-auto mb-4">
                            <i class="fas fa-balance-scale text-info"></i>
                        </div>
                        <h4 class="fw-bold mb-3 text-white">Transparency</h4>
                        <p class="text-muted">We believe in open communication and clear reporting about our impact and operations.</p>
                    </div>
                </div>
                <div class="col-lg-4 col-md-6">
                    <div class="value-card text-center p-4 h-100">
                        <div class="value-icon mx-auto mb-4">
                            <i class="fas fa-chart-line text-danger"></i>
                        </div>
                        <h4 class="fw-bold mb-3 text-white">Growth Mindset</h4>
                        <p class="text-muted">We're always learning, improving, and adapting to serve our communities better.</p>
                    </div>
                </div>
                <div class="col-lg-4 col-md-6">
                    <div class="value-card text-center p-4 h-100">
                        <div class="value-icon mx-auto mb-4">
                            <i class="fas fa-heart text-pink"></i>
                        </div>
                        <h4 class="fw-bold mb-3 text-white">Passion</h4>
                        <p class="text-muted">We genuinely care about creating positive environmental and social change.</p>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Team Section -->
    <section id="team" class="team-section py-5">
        <div class="container">
            <div class="row text-center mb-5">
                <div class="col-lg-8 mx-auto">
                    <span class="section-badge px-3 py-2 rounded-pill mb-3">Our Team</span>
                    <h2 class="fw-bold display-5 mb-3 text-white">Meet the Visionaries</h2>
                    <p class="lead text-muted fs-6">A diverse team of passionate individuals united by a common goal: sustainable innovation.</p>
                </div>
            </div>
            <div class="row g-4">
                <div class="col-lg-4 col-md-6">
                    <div class="team-card text-center p-4">
                        <div class="team-avatar mx-auto mb-4">
                            <div class="avatar-image"></div>
                        </div>
                        <h4 class="fw-bold mb-2 text-white">Dr. Sarah Johnson</h4>
                        <p class="text-primary fw-semibold mb-3">CEO & Founder</p>
                        <p class="text-muted mb-3">Environmental scientist with 15+ years experience in sustainable development and community engagement.</p>
                        <div class="team-social">
                            <a href="#" class="social-link"><i class="fab fa-linkedin"></i></a>
                            <a href="#" class="social-link"><i class="fab fa-twitter"></i></a>
                            <a href="#" class="social-link"><i class="fas fa-envelope"></i></a>
                        </div>
                    </div>
                </div>
                <div class="col-lg-4 col-md-6">
                    <div class="team-card text-center p-4">
                        <div class="team-avatar mx-auto mb-4">
                            <div class="avatar-image"></div>
                        </div>
                        <h4 class="fw-bold mb-2 text-white">Mike Chen</h4>
                        <p class="text-primary fw-semibold mb-3">CTO</p>
                        <p class="text-muted mb-3">Tech innovator specializing in IoT and data analytics for environmental applications.</p>
                        <div class="team-social">
                            <a href="#" class="social-link"><i class="fab fa-linkedin"></i></a>
                            <a href="#" class="social-link"><i class="fab fa-github"></i></a>
                            <a href="#" class="social-link"><i class="fas fa-envelope"></i></a>
                        </div>
                    </div>
                </div>
                <div class="col-lg-4 col-md-6">
                    <div class="team-card text-center p-4">
                        <div class="team-avatar mx-auto mb-4">
                            <div class="avatar-image"></div>
                        </div>
                        <h4 class="fw-bold mb-2 text-white">Amina Hassan</h4>
                        <p class="text-primary fw-semibold mb-3">Head of Community</p>
                        <p class="text-muted mb-3">Community organizer passionate about creating inclusive environmental programs.</p>
                        <div class="team-social">
                            <a href="#" class="social-link"><i class="fab fa-linkedin"></i></a>
                            <a href="#" class="social-link"><i class="fab fa-instagram"></i></a>
                            <a href="#" class="social-link"><i class="fas fa-envelope"></i></a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Impact Section -->
    <section class="impact-section py-5">
        <div class="container">
            <div class="row text-center mb-5">
                <div class="col-lg-8 mx-auto">
                    <span class="section-badge bg-white bg-opacity-20 text-white px-3 py-2 rounded-pill mb-3">Our Impact</span>
                    <h2 class="fw-bold display-5 mb-3 text-white">Making a Real Difference</h2>
                    <p class="lead opacity-75 fs-6">See how we're transforming communities and protecting our planet.</p>
                </div>
            </div>
            <div class="row g-4 text-center">
                <div class="col-md-3 col-6">
                    <div class="impact-stat">
                        <div class="impact-number display-4 fw-bold mb-2">45.2T</div>
                        <p class="opacity-75 mb-0">Waste Recycled</p>
                    </div>
                </div>
                <div class="col-md-3 col-6">
                    <div class="impact-stat">
                        <div class="impact-number display-4 fw-bold mb-2">12.5K</div>
                        <p class="opacity-75 mb-0">Trees Saved</p>
                    </div>
                </div>
                <div class="col-md-3 col-6">
                    <div class="impact-stat">
                        <div class="impact-number display-4 fw-bold mb-2">28</div>
                        <p class="opacity-75 mb-0">Communities Served</p>
                    </div>
                </div>
                <div class="col-md-3 col-6">
                    <div class="impact-stat">
                        <div class="impact-number display-4 fw-bold mb-2">156</div>
                        <p class="opacity-75 mb-0">Green Jobs Created</p>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Partners Section -->
    <section class="partners-section py-5">
        <div class="container">
            <div class="row text-center mb-5">
                <div class="col-lg-8 mx-auto">
                    <span class="section-badge bg-success bg-opacity-10 text-success px-3 py-2 rounded-pill mb-3">Partners & Supporters</span>
                    <h2 class="fw-bold display-5 mb-3 text-white">Working Together for Change</h2>
                    <p class="lead text-muted fs-6">We're proud to collaborate with organizations that share our vision for a sustainable future.</p>
                </div>
            </div>
            <div class="row g-4 align-items-center justify-content-center">
                <div class="col-6 col-md-4 col-lg-2 text-center">
                    <div class="partner-logo">
                        <i class="fas fa-university fa-2x"></i>
                    </div>
                </div>
                <div class="col-6 col-md-4 col-lg-2 text-center">
                    <div class="partner-logo">
                        <i class="fas fa-city fa-2x"></i>
                    </div>
                </div>
                <div class="col-6 col-md-4 col-lg-2 text-center">
                    <div class="partner-logo">
                        <i class="fas fa-hands-helping fa-2x"></i>
                    </div>
                </div>
                <div class="col-6 col-md-4 col-lg-2 text-center">
                    <div class="partner-logo">
                        <i class="fas fa-seedling fa-2x"></i>
                    </div>
                </div>
                <div class="col-6 col-md-4 col-lg-2 text-center">
                    <div class="partner-logo">
                        <i class="fas fa-recycle fa-2x"></i>
                    </div>
                </div>
                <div class="col-6 col-md-4 col-lg-2 text-center">
                    <div class="partner-logo">
                        <i class="fas fa-globe-americas fa-2x"></i>
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
                    <h2 class="fw-bold display-5 mb-3 text-white">Join Our Mission</h2>
                    <p class="lead text-muted mb-4">Be part of the movement towards sustainable waste management and community empowerment.</p>
                    <div class="d-flex flex-wrap gap-3 justify-content-center">
                        <a href="Contact.aspx" class="btn btn-hero">
                            <i class="fas fa-handshake me-2"></i>Partner With Us
                        </a>
                        <a href="ChooseApp.aspx" class="btn btn-outline-hero">
                            <i class="fas fa-rocket me-2"></i>Get Started
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <script>
        // Add scroll animations
        document.addEventListener('DOMContentLoaded', function() {
            const observerOptions = {
                threshold: 0.1,
                rootMargin: '0px 0px -50px 0px'
            };

            const observer = new IntersectionObserver((entries) => {
                entries.forEach(entry => {
                    if (entry.isIntersecting) {
                        entry.target.style.opacity = '1';
                        entry.target.style.transform = 'translateY(0)';
                    }
                });
            }, observerOptions);

            // Observe all cards
            document.querySelectorAll('.mission-card, .vision-card, .value-card, .team-card').forEach(el => {
                el.style.opacity = '0';
                el.style.transform = 'translateY(20px)';
                el.style.transition = 'all 0.6s ease';
                observer.observe(el);
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
</asp:Content>