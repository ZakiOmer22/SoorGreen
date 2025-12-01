<%@ Page Title="About" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="false" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    

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
                            <li class="mb-2"><i class="fas fa-check text-success me-2"></i>Empower communities with smart waste solutions</li>
                            <li class="mb-2"><i class="fas fa-check text-success me-2"></i>Reduce landfill waste by 50% in target cities</li>
                            <li class="mb-2"><i class="fas fa-check text-success me-2"></i>Create green jobs and economic opportunities</li>
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
                            <li class="mb-2"><i class="fas fa-check text-success me-2"></i>Zero waste cities by 2040</li>
                            <li class="mb-2"><i class="fas fa-check text-success me-2"></i>Global network of sustainable communities</li>
                            <li class="mb-2"><i class="fas fa-check text-success me-2"></i>Technology-driven circular economy</li>
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

                <!-- Member 1 -->
                <div class="col-lg-4 col-md-6">
                    <div class="team-card text-center p-4">
                        <div class="team-avatar mx-auto mb-4">
                            <div class="avatar-image"></div>
                        </div>
                        <h4 class="fw-bold mb-2 text-white">ZACKI ABDULKADIR OMER</h4>
                        <p class="text-primary fw-semibold mb-3">Project Lead</p>
                        <p class="text-muted mb-3">Innovative problem-solver focused on smart waste systems and sustainable technology integration.</p>
                        <div class="team-social">
                            <a href="#" class="social-link"><i class="fab fa-linkedin"></i></a>
                            <a href="#" class="social-link"><i class="fas fa-envelope"></i></a>
                        </div>
                    </div>
                </div>

                <!-- Member 2 -->
                <div class="col-lg-4 col-md-6">
                    <div class="team-card text-center p-4">
                        <div class="team-avatar mx-auto mb-4">
                            <div class="avatar-image"></div>
                        </div>
                        <h4 class="fw-bold mb-2 text-white">ARAFAT OSMAN ADEN</h4>
                        <p class="text-primary fw-semibold mb-3">Lead Developer</p>
                        <p class="text-muted mb-3">Full-stack developer committed to building reliable, user-centered, and scalable green-tech systems.</p>
                        <div class="team-social">
                            <a href="#" class="social-link"><i class="fab fa-linkedin"></i></a>
                            <a href="#" class="social-link"><i class="fab fa-github"></i></a>
                            <a href="#" class="social-link"><i class="fas fa-envelope"></i></a>
                        </div>
                    </div>
                </div>

                <!-- Member 3 -->
                <div class="col-lg-4 col-md-6">
                    <div class="team-card text-center p-4">
                        <div class="team-avatar mx-auto mb-4">
                            <div class="avatar-image"></div>
                        </div>
                        <h4 class="fw-bold mb-2 text-white">ARFAT</h4>
                        <p class="text-primary fw-semibold mb-3">System Engineer</p>
                        <p class="text-muted mb-3">Specialist in IoT infrastructure and data-driven solutions for environmental applications.</p>
                        <div class="team-social">
                            <a href="#" class="social-link"><i class="fab fa-linkedin"></i></a>
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

</asp:Content>