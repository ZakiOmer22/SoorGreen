<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ChooseApp.aspx.cs" Inherits="SoorGreen.Main.ChooseApp1" %>

<!DOCTYPE html>
<html lang="en" data-theme="dark">
<head runat="server">
    <title>SoorGreen - Smart Waste Management Platform</title>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta name="description" content="SoorGreen: Smart sustainability app rewarding citizens for recycling and helping cities manage waste efficiently." />
    <meta name="keywords" content="waste management, recycling, sustainability, .NET, MVC, WinForms, SQL Server, full-stack development" />
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" />
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet" />
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet" />
    <link href="https://unpkg.com/aos@2.3.1/dist/aos.css" rel="stylesheet" />
    <link href="ChooseApp.css" rel="stylesheet" />
</head>
<body>
    <form id="form1" runat="server">
        <!-- Theme Toggle Button -->
        <button type="button" class="theme-toggle" id="themeToggle" title="Toggle Dark/Light Mode">
            <i class="fas fa-moon"></i>
            <i class="fas fa-sun"></i>
        </button>

        <!-- Particle Background -->
        <div class="particles" id="particles"></div>

        <!-- Back Button -->
        <a href="Default.aspx" class="back-button">
            <i class="fas fa-arrow-left"></i>
            Back to Home
        </a>

        <!-- Header Section -->
        <section class="header-section">
            <div class="header-bg"></div>

            <!-- Floating Elements -->
            <div class="floating-elements">
                <div class="floating-element element-1"><i class="fas fa-recycle"></i></div>
                <div class="floating-element element-2"><i class="fas fa-leaf"></i></div>
                <div class="floating-element element-3"><i class="fas fa-database"></i></div>
                <div class="floating-element element-4"><i class="fas fa-code"></i></div>
            </div>

            <div class="header-content">
                <div class="logo">
                    <i class="fas fa-recycle"></i>
                </div>
                <h1 class="header-title">SoorGreen Platform</h1>
                <p class="header-subtitle">
                    <strong>Project Codename: SOONGREEN</strong><br />
                    A comprehensive smart waste management ecosystem developed by a full-stack team 
                    featuring four specialized applications built with modern .NET technologies.
                </p>
                <div class="header-tags">
                    <span class="header-tag"><i class="fas fa-code"></i>Full-Stack Development</span>
                    <span class="header-tag"><i class="fas fa-database"></i>SQL Server Architecture</span>
                    <span class="header-tag"><i class="fas fa-mobile-alt"></i>Multi-Platform</span>
                    <span class="header-tag"><i class="fas fa-cloud"></i>Cloud-Ready</span>
                </div>
            </div>
        </section>

        <!-- Project Overview Section -->
        <section class="project-section" id="project" data-aos="fade-up">
            <div class="container">
                <h2 class="section-title">Project Overview</h2>
                <p class="section-subtitle">
                    Smart sustainability app rewarding citizens for recycling and helping cities manage waste efficiently.
                </p>

                <div class="project-highlights">
                    <div class="highlight-card" data-aos="fade-up" data-aos-delay="200">
                        <div class="highlight-icon">
                            <i class="fas fa-bullseye"></i>
                        </div>
                        <h3>Project Mission</h3>
                        <p>Transform waste management through technology, incentivize recycling, and create sustainable communities through citizen engagement.</p>
                    </div>

                    <div class="highlight-card" data-aos="fade-up" data-aos-delay="400">
                        <div class="highlight-icon">
                            <i class="fas fa-cogs"></i>
                        </div>
                        <h3>Core Technology</h3>
                        <p>Built on Microsoft .NET ecosystem with SQL Server backend, featuring scalable architecture and enterprise-grade security.</p>
                    </div>

                    <div class="highlight-card" data-aos="fade-up" data-aos-delay="600">
                        <div class="highlight-icon">
                            <i class="fas fa-users"></i>
                        </div>
                        <h3>Target Users</h3>
                        <p>Citizens, Municipalities, Waste Collectors, Environmental Agencies, and System Administrators across multiple platforms.</p>
                    </div>
                </div>
            </div>
        </section>

        <!-- Database Architecture Section -->
        <section class="database-section" id="database" data-aos="fade-up">
            <div class="container">
                <h2 class="section-title">Database Architecture</h2>
                <p class="section-subtitle">
                    Robust SQL Server database designed for scalability, performance, and real-time waste management operations.
                </p>

                <div class="database-schema" data-aos="zoom-in">
                    <div class="schema-diagram">
                        <div class="schema-table" data-table="Users">
                            <h4><i class="fas fa-user"></i>Users</h4>
                            <ul>
                                <li>UserId (PK)</li>
                                <li>FullName</li>
                                <li>Phone</li>
                                <li>Email</li>
                                <li>RoleId (FK)</li>
                                <li>XP_Credits</li>
                            </ul>
                        </div>

                        <div class="schema-table" data-table="WasteReports">
                            <h4><i class="fas fa-trash-alt"></i>WasteReports</h4>
                            <ul>
                                <li>ReportId (PK)</li>
                                <li>UserId (FK)</li>
                                <li>WasteTypeId (FK)</li>
                                <li>EstimatedKg</li>
                                <li>Address</li>
                                <li>GPS Location</li>
                            </ul>
                        </div>

                        <div class="schema-table" data-table="PickupRequests">
                            <h4><i class="fas fa-truck"></i>PickupRequests</h4>
                            <ul>
                                <li>PickupId (PK)</li>
                                <li>ReportId (FK)</li>
                                <li>CollectorId (FK)</li>
                                <li>Status</li>
                                <li>Timestamps</li>
                            </ul>
                        </div>

                        <div class="schema-table" data-table="RewardPoints">
                            <h4><i class="fas fa-coins"></i>RewardPoints</h4>
                            <ul>
                                <li>RewardId (PK)</li>
                                <li>UserId (FK)</li>
                                <li>Amount</li>
                                <li>Type</li>
                                <li>Reference</li>
                            </ul>
                        </div>
                    </div>

                    <div class="database-features">
                        <div class="feature" data-aos="fade-right" data-aos-delay="200">
                            <i class="fas fa-shield-alt"></i>
                            <h4>Security First</h4>
                            <p>Role-based access control with encrypted data transmission</p>
                        </div>

                        <div class="feature" data-aos="fade-right" data-aos-delay="400">
                            <i class="fas fa-bolt"></i>
                            <h4>High Performance</h4>
                            <p>Optimized indexes and stored procedures for real-time operations</p>
                        </div>

                        <div class="feature" data-aos="fade-right" data-aos-delay="600">
                            <i class="fas fa-chart-line"></i>
                            <h4>Analytics Ready</h4>
                            <p>Comprehensive views and reporting capabilities</p>
                        </div>

                        <div class="feature" data-aos="fade-right" data-aos-delay="800">
                            <i class="fas fa-sync-alt"></i>
                            <h4>Real-time Sync</h4>
                            <p>Activity tracking and notification systems</p>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <!-- Full-Stack Team Section -->
        <section class="team-section" id="team">
            <div class="container">
                <h2 class="section-title">Full-Stack Development Team</h2>
                <p class="section-subtitle" data-aos="fade-up" data-aos-delay="200">
                    Our unified team collaboratively built the entire SoorGreen ecosystem from database to frontend.
                </p>

                <div class="team-grid">
                    <div class="team-card" data-aos="fade-up" data-aos-delay="200">
                        <div class="team-avatar">ZA</div>
                        <h3 class="team-name">ZACKI ABDULKADIR OMER</h3>
                        <p class="team-role">Full-Stack .NET Developer</p>
                        <div class="tech-tags">
                            <span class="tech-tag">WinForms</span>
                            <span class="tech-tag">ADO.NET</span>
                            <span class="tech-tag">SQL Server</span>
                            <span class="tech-tag">Backend APIs</span>
                        </div>
                        <p class="team-bio">
                            <strong>Full-Stack Contribution:</strong> Led Web Forms application development while 
                            collaborating on database design, API development, and frontend architecture across all platforms.
                        </p>
                        <div class="team-contributions">
                            <h4>Cross-Platform Contributions:</h4>
                            <ul>
                                <li>Database schema design and optimization</li>
                                <li>WinForms desktop application (lead)</li>
                                <li>Web API development and integration</li>
                                <li>Business logic across all platforms</li>
                            </ul>
                        </div>
                    </div>

                    <div class="team-card" data-aos="fade-up" data-aos-delay="400">
                        <div class="team-avatar">AO</div>
                        <h3 class="team-name">ARAFAT OSMAN ADEN</h3>
                        <p class="team-role">Full-Stack Web Developer</p>
                        <div class="tech-tags">
                            <span class="tech-tag">ASP.NET Core MVC</span>
                            <span class="tech-tag">Entity Framework</span>
                            <span class="tech-tag">Web APIs</span>
                            <span class="tech-tag">Database Design</span>
                        </div>
                        <p class="team-bio">
                            <strong>Full-Stack Contribution:</strong> Architected the MVC web portal while 
                            contributing to database development, API design, and Web Forms integration across the entire ecosystem.
                        </p>
                        <div class="team-contributions">
                            <h4>Cross-Platform Contributions:</h4>
                            <ul>
                                <li>MVC web portal architecture (lead)</li>
                                <li>Database stored procedures and views</li>
                                <li>RESTful API development</li>
                                <li>Cross-platform authentication system</li>
                            </ul>
                        </div>
                    </div>

                    <div class="team-card" data-aos="fade-up" data-aos-delay="600">
                        <div class="team-avatar">AK</div>
                        <h3 class="team-name">ABDRIXEEM KHADAR CABDIRAXMAN</h3>
                        <p class="team-role">Full-Stack Solutions Architect</p>
                        <div class="tech-tags">
                            <span class="tech-tag">System Architecture</span>
                            <span class="tech-tag">Database Optimization</span>
                            <span class="tech-tag">API Integration</span>
                            <span class="tech-tag">Custom Solutions</span>
                        </div>
                        <p class="team-bio">
                            <strong>Full-Stack Contribution:</strong> Engineered the complete system architecture 
                            while collaborating on database design, API development, and custom solutions across all applications.
                        </p>
                        <div class="team-contributions">
                            <h4>Cross-Platform Contributions:</h4>
                            <ul>
                                <li>Complete system architecture design</li>
                                <li>Database performance optimization</li>
                                <li>Custom solution development</li>
                                <li>Cross-platform integration patterns</li>
                            </ul>
                        </div>
                    </div>
                </div>

                <div class="team-collaboration" data-aos="fade-up" data-aos-delay="800">
                    <h3>True Full-Stack Collaboration</h3>
                    <p>
                        Our team worked together on <strong>every layer</strong> of the application stack:
                    </p>
                    <div class="collaboration-grid">
                        <div class="collab-item">
                            <i class="fas fa-database"></i>
                            <h4>Database Layer (ALL)</h4>
                            <p><strong>All team members</strong> designed schema, wrote stored procedures, and optimized queries together</p>
                        </div>
                        <div class="collab-item">
                            <i class="fas fa-server"></i>
                            <h4>Business Logic (ALL)</h4>
                            <p><strong>All team members</strong> collaborated on business rules, validation, and application logic</p>
                        </div>
                        <div class="collab-item">
                            <i class="fas fa-code"></i>
                            <h4>API Layer (ALL)</h4>
                            <p><strong>All team members</strong> built RESTful services, authentication, and integration endpoints</p>
                        </div>
                        <div class="collab-item">
                            <i class="fas fa-desktop"></i>
                            <h4>Presentation Layer (ALL)</h4>
                            <p><strong>All team members</strong> contributed to UI design and user experience across all platforms</p>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <!-- Technical Stack Section -->
        <section class="tech-stack-section" id="techstack" data-aos="fade-up">
            <div class="container">
                <h2 class="section-title">Complete Technology Stack</h2>
                <p class="section-subtitle">
                    Comprehensive .NET ecosystem spanning multiple platforms and architectures
                </p>

                <div class="tech-stack-grid">
                    <div class="tech-stack-category">
                        <h3><i class="fas fa-database"></i>Database Layer</h3>
                        <div class="tech-items">
                            <span class="tech-item">Microsoft SQL Server 2022</span>
                            <span class="tech-item">ADO.NET Data Provider</span>
                            <span class="tech-item">Entity Framework Core</span>
                            <span class="tech-item">Stored Procedures</span>
                            <span class="tech-item">Database Triggers</span>
                            <span class="tech-item">Index Optimization</span>
                            <span class="tech-item">Backup & Recovery</span>
                            <span class="tech-item">Replication</span>
                        </div>
                    </div>

                    <div class="tech-stack-category">
                        <h3><i class="fas fa-server"></i>Backend Layer</h3>
                        <div class="tech-items">
                            <span class="tech-item">.NET Framework 4.8</span>
                            <span class="tech-item">ASP.NET Core 7</span>
                            <span class="tech-item">C# Programming</span>
                            <span class="tech-item">LINQ & Lambda</span>
                            <span class="tech-item">Dependency Injection</span>
                            <span class="tech-item">JWT Authentication</span>
                            <span class="tech-item">SignalR Real-time</span>
                            <span class="tech-item">Background Services</span>
                        </div>
                    </div>

                    <div class="tech-stack-category">
                        <h3><i class="fas fa-desktop"></i>Frontend Layer</h3>
                        <div class="tech-items">
                            <span class="tech-item">Web Forms</span>
                            <span class="tech-item">ASP.NET Core MVC</span>
                            <span class="tech-item">Razor Pages</span>
                            <span class="tech-item">JavaScript/TypeScript</span>
                            <span class="tech-item">Bootstrap 5</span>
                            <span class="tech-item">AOS Animations</span>
                            <span class="tech-item">Chart.js</span>
                            <span class="tech-item">Google Maps API</span>
                        </div>
                    </div>

                    <div class="tech-stack-category">
                        <h3><i class="fas fa-cloud"></i>Infrastructure</h3>
                        <div class="tech-items">
                            <span class="tech-item">IIS Web Server</span>
                            <span class="tech-item">Windows Services</span>
                            <span class="tech-item">Docker Containers</span>
                            <span class="tech-item">Azure Cloud</span>
                            <span class="tech-item">Redis Cache</span>
                            <span class="tech-item">SMTP Email</span>
                            <span class="tech-item">Push Notifications</span>
                            <span class="tech-item">Load Balancing</span>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <!-- Stats Section -->
        <section class="stats-section" data-aos="fade-up">
            <div class="container">
                <div class="stats-grid">
                    <div class="stat-card" data-aos="zoom-in" data-aos-delay="100">
                        <span class="stat-number" id="statUsers">2.5K+</span>
                        <span class="stat-label">Active Users</span>
                        <div class="stat-detail">Across 4 applications</div>
                    </div>
                    <div class="stat-card" data-aos="zoom-in" data-aos-delay="200">
                        <span class="stat-number" id="statPickups">1.2K+</span>
                        <span class="stat-label">Pickups Completed</span>
                        <div class="stat-detail">Real-time tracking</div>
                    </div>
                    <div class="stat-card" data-aos="zoom-in" data-aos-delay="300">
                        <span class="stat-number" id="statCredits">45K+</span>
                        <span class="stat-label">Credits Earned</span>
                        <div class="stat-detail">Citizen rewards</div>
                    </div>
                    <div class="stat-card" data-aos="zoom-in" data-aos-delay="400">
                        <span class="stat-number" id="statTons">85+</span>
                        <span class="stat-label">Tons Recycled</span>
                        <div class="stat-detail">Environmental impact</div>
                    </div>
                </div>
            </div>
        </section>

        <!-- Apps Section -->
        <section class="apps-section" id="applications">
            <div class="container">
                <h2 class="section-title" data-aos="fade-up">Complete Application Suite</h2>
                <p class="section-subtitle" data-aos="fade-up" data-aos-delay="200">
                    Four specialized platforms built on shared database architecture with consistent business logic
                </p>

                <div class="apps-grid">
                    <!-- WebForms  Application -->
                    <div class="app-card card-webform" data-aos="fade-up" data-aos-delay="200" data-bs-toggle="modal" data-bs-target="#winformsModal">
                        <div class="user-role">Database-First Desktop Solution</div>
                        <div class="app-icon">
                            <i class="fas fa-desktop"></i>
                        </div>
                        <h3 class="app-title">Web Forms Desktop Application</h3>
                        <p class="app-subtitle">
                            High-performance desktop application with direct SQL Server connectivity using ADO.NET. 
                            Optimized for municipality administrators requiring offline capabilities and bulk operations.
                        </p>
                        <ul class="app-features">
                            <li><i class="fas fa-check"></i>Direct ADO.NET database access</li>
                            <li><i class="fas fa-check"></i>Offline data synchronization</li>
                            <li><i class="fas fa-check"></i>Advanced reporting with Crystal Reports</li>
                            <li><i class="fas fa-check"></i>Bulk import/export operations</li>
                            <li><i class="fas fa-check"></i>Windows Services integration</li>
                        </ul>
                        <div class="tech-tags">
                            <span class="tech-tag">WinForms</span>
                            <span class="tech-tag">ADO.NET</span>
                            <span class="tech-tag">SQL Client</span>
                            <span class="tech-tag">.NET 4.8</span>
                            <span class="tech-tag">Bootstrap</span>
                        </div>
                        <asp:Button ID="btnWebForms" runat="server" Text="Launch Web Forms App"
                            CssClass="app-button" OnClick="btnWebForms_Click" />
                    </div>

                    <!-- MVC Advanced Application -->
                    <div class="app-card card-mvc" data-aos="fade-up" data-aos-delay="300" data-bs-toggle="modal" data-bs-target="#mvcModal">
                        <div class="user-role">Modern Web Portal</div>
                        <div class="app-icon">
                            <i class="fas fa-globe"></i>
                        </div>
                        <h3 class="app-title">Advanced MVC Web Portal</h3>
                        <p class="app-subtitle">
                            Responsive web application built with ASP.NET Core MVC and Entity Framework. 
                            Features real-time updates, progressive web app capabilities, and advanced analytics.
                        </p>
                        <ul class="app-features">
                            <li><i class="fas fa-check"></i>MVC/MVVM architecture patterns</li>
                            <li><i class="fas fa-check"></i>Entity Framework Core ORM</li>
                            <li><i class="fas fa-check"></i>Real-time SignalR communication</li>
                            <li><i class="fas fa-check"></i>Progressive Web App (PWA)</li>
                            <li><i class="fas fa-check"></i>Advanced dashboard analytics</li>
                        </ul>
                        <div class="tech-tags">
                            <span class="tech-tag">ASP.NET Core MVC</span>
                            <span class="tech-tag">Entity Framework</span>
                            <span class="tech-tag">MVVM Pattern</span>
                            <span class="tech-tag">TypeScript</span>
                            <span class="tech-tag">SignalR</span>
                        </div>
                        <asp:Button ID="btnMVC" runat="server" Text="Open MVC Portal"
                            CssClass="app-button" OnClick="btnMVC_Click" />
                    </div>

                    <!-- Web API Service -->
                    <div class="app-card card-api" data-aos="fade-up" data-aos-delay="400" data-bs-toggle="modal" data-bs-target="#apiModal">
                        <div class="user-role">Backend Integration Hub</div>
                        <div class="app-icon">
                            <i class="fas fa-code"></i>
                        </div>
                        <h3 class="app-title">Web API Service</h3>
                        <p class="app-subtitle">
                            RESTful API backend providing secure endpoints for mobile apps, third-party integrations, 
                            and microservices architecture with comprehensive Swagger documentation.
                        </p>
                        <ul class="app-features">
                            <li><i class="fas fa-check"></i>RESTful API design</li>
                            <li><i class="fas fa-check"></i>JWT authentication/authorization</li>
                            <li><i class="fas fa-check"></i>Swagger/OpenAPI documentation</li>
                            <li><i class="fas fa-check"></i>Mobile app support</li>
                            <li><i class="fas fa-check"></i>Rate limiting & caching</li>
                        </ul>
                        <div class="tech-tags">
                            <span class="tech-tag">ASP.NET Web API</span>
                            <span class="tech-tag">JWT Tokens</span>
                            <span class="tech-tag">REST</span>
                            <span class="tech-tag">Swagger</span>
                            <span class="tech-tag">Docker</span>
                        </div>
                        <asp:Button ID="btnAPI" runat="server" Text="Explore API"
                            CssClass="app-button" OnClick="btnAPI_Click" />
                    </div>

                    <!-- Custom Application -->
                    <div class="app-card card-custom" data-aos="fade-up" data-aos-delay="500" data-bs-toggle="modal" data-bs-target="#customModal">
                        <div class="user-role">Specialized Municipal Solution</div>
                        <div class="app-icon">
                            <i class="fas fa-cogs"></i>
                        </div>
                        <h3 class="app-title">Custom Solution Platform</h3>
                        <p class="app-subtitle">
                            Tailored application suite for unique municipal requirements, legacy system integration, 
                            and specialized workflow scenarios requiring custom technology stacks.
                        </p>
                        <ul class="app-features">
                            <li><i class="fas fa-check"></i>Custom .NET components</li>
                            <li><i class="fas fa-check"></i>Legacy system bridges</li>
                            <li><i class="fas fa-check"></i>Specialized municipal protocols</li>
                            <li><i class="fas fa-check"></i>Hardware integration</li>
                            <li><i class="fas fa-check"></i>Proprietary security systems</li>
                        </ul>
                        <div class="tech-tags">
                            <span class="tech-tag">Custom Stack</span>
                            <span class="tech-tag">Legacy Integration</span>
                            <span class="tech-tag">Specialized APIs</span>
                            <span class="tech-tag">Municipal Protocols</span>
                            <span class="tech-tag">Hardware Integration</span>
                        </div>
                        <asp:Button ID="btnCustom" runat="server" Text="Open Custom App"
                            CssClass="app-button" OnClick="btnCustom_Click" />
                    </div>
                </div>
            </div>
        </section>

        <!-- Process Section -->
        <section class="process-section" id="process">
            <div class="container">
                <h2 class="section-title" data-aos="fade-up">How It Works</h2>
                <p class="section-subtitle" data-aos="fade-up" data-aos-delay="200">
                    Simple steps to transform your waste management experience
                </p>

                <div class="process-steps">
                    <div class="process-step" data-aos="fade-up" data-aos-delay="200">
                        <div class="step-number">1</div>
                        <h3 class="step-title">Sign Up & Setup</h3>
                        <p class="step-desc">Create your account and configure your preferences in minutes</p>
                    </div>
                    <div class="process-step" data-aos="fade-up" data-aos-delay="400">
                        <div class="step-number">2</div>
                        <h3 class="step-title">Report Waste</h3>
                        <p class="step-desc">Use our app to report waste with photos and location data</p>
                    </div>
                    <div class="process-step" data-aos="fade-up" data-aos-delay="600">
                        <div class="step-number">3</div>
                        <h3 class="step-title">Track Pickup</h3>
                        <p class="step-desc">Monitor real-time pickup status and collector location</p>
                    </div>
                    <div class="process-step" data-aos="fade-up" data-aos-delay="800">
                        <div class="step-number">4</div>
                        <h3 class="step-title">Earn Rewards</h3>
                        <p class="step-desc">Get credits for every successful pickup and redeem rewards</p>
                    </div>
                </div>
            </div>
        </section>

        <!-- Features Section -->
        <section class="features-section" data-aos="fade-up">
            <div class="container">
                <h2 class="section-title">Why Choose SoorGreen?</h2>
                <p class="section-subtitle">
                    Our platform offers comprehensive solutions for modern waste management challenges
                </p>

                <div class="features-grid">
                    <div class="feature-item" data-aos="fade-up" data-aos-delay="200">
                        <div class="feature-icon">
                            <i class="fas fa-shield-alt"></i>
                        </div>
                        <h3 class="feature-title">Secure & Reliable</h3>
                        <p class="feature-desc">Enterprise-grade security with encrypted data transmission and secure authentication systems.</p>
                    </div>

                    <div class="feature-item" data-aos="fade-up" data-aos-delay="400">
                        <div class="feature-icon">
                            <i class="fas fa-rocket"></i>
                        </div>
                        <h3 class="feature-title">High Performance</h3>
                        <p class="feature-desc">Optimized for speed and scalability, handling thousands of concurrent users seamlessly.</p>
                    </div>

                    <div class="feature-item" data-aos="fade-up" data-aos-delay="600">
                        <div class="feature-icon">
                            <i class="fas fa-mobile-alt"></i>
                        </div>
                        <h3 class="feature-title">Mobile First</h3>
                        <p class="feature-desc">Responsive design that works perfectly on all devices, from desktop to mobile.</p>
                    </div>

                    <div class="feature-item" data-aos="fade-up" data-aos-delay="800">
                        <div class="feature-icon">
                            <i class="fas fa-chart-line"></i>
                        </div>
                        <h3 class="feature-title">Real-time Analytics</h3>
                        <p class="feature-desc">Live data visualization and reporting tools for informed decision making.</p>
                    </div>
                </div>
            </div>
        </section>

        <!-- CTA Section -->
        <section class="cta-section" data-aos="fade-up">
            <div class="container">
                <div class="cta-content">
                    <h2 class="cta-title">Ready to Experience Full-Stack Excellence?</h2>
                    <p class="cta-subtitle">
                        Discover the power of our complete .NET ecosystem built by expert full-stack developers. 
                        Choose your platform and see database-driven applications in action.
                    </p>
                    <div class="cta-buttons">
                        <a href="#applications" class="cta-button cta-primary">
                            <i class="fas fa-play"></i>
                            Launch Application
                        </a>
                        <a href="#database" class="cta-button cta-secondary">
                            <i class="fas fa-database"></i>
                            View Database Schema
                        </a>
                        <a href="#team" class="cta-button cta-secondary">
                            <i class="fas fa-users"></i>
                            Meet The Team
                        </a>
                    </div>
                </div>
            </div>
        </section>

        <!-- Updated WINFORMS Modal - Showing Full Team Collaboration -->
        <div class="modal fade" id="winformsModal" tabindex="-1" aria-hidden="true">
            <div class="modal-dialog modal-lg">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title">
                            <i class="fas fa-desktop me-2"></i>
                            Web Forms Desktop Application - Complete Details
                        </h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                        <div class="detail-section">
                            <h5><i class="fas fa-users"></i>Team Collaboration</h5>
                            <div class="team-collaboration-badge">
                                <div class="collaborator">
                                    <span class="avatar-small">ZA</span>
                                    <span class="collaborator-name">ZACKI ABDULKADIR OMER</span>
                                    <span class="collaborator-role">Lead Developer</span>
                                </div>
                                <div class="collaborator">
                                    <span class="avatar-small">AO</span>
                                    <span class="collaborator-name">ARAFAT OSMAN ADEN</span>
                                    <span class="collaborator-role">API & Database</span>
                                </div>
                                <div class="collaborator">
                                    <span class="avatar-small">AK</span>
                                    <span class="collaborator-name">ABDRIXEEM KHADAR CABDIRAXMAN</span>
                                    <span class="collaborator-role">Architecture & Optimization</span>
                                </div>
                            </div>
                            <p><strong>Full-Stack Development:</strong> All team members contributed to this application's database design, business logic, and API integration.</p>
                        </div>

                        <div class="detail-section">
                            <h5><i class="fas fa-info-circle"></i>Overview</h5>
                            <p>High-performance desktop application built with Web Forms technology, designed for municipality administrators. This application represents our team's collaborative approach to full-stack development.</p>
                        </div>

                        <div class="detail-section">
                            <h5><i class="fas fa-star"></i>Key Features</h5>
                            <ul class="feature-list">
                                <li><i class="fas fa-database"></i>Direct SQL Server connectivity using ADO.NET (Team: ZA, AO, AK)</li>
                                <li><i class="fas fa-desktop"></i>Desktop-optimized Web Forms interface (Team: ZA, AO)</li>
                                <li><i class="fas fa-sync-alt"></i>Offline data synchronization capabilities (Team: ZA, AK)</li>
                                <li><i class="fas fa-file-export"></i>Advanced bulk data import/export features (Team: ALL)</li>
                                <li><i class="fas fa-chart-pie"></i>Comprehensive reporting with Crystal Reports (Team: ZA, AO)</li>
                                <li><i class="fas fa-network-wired"></i>Direct municipal system integration (Team: AK, ZA)</li>
                                <li><i class="fas fa-print"></i>Built-in printing and document generation (Team: AO, ZA)</li>
                                <li><i class="fas fa-cogs"></i>System configuration and maintenance tools (Team: ALL)</li>
                            </ul>
                        </div>

                        <div class="detail-section">
                            <h5><i class="fas fa-code"></i>Technical Stack (Team Collaboration)</h5>
                            <div class="modal-tech-tags">
                                <span class="modal-tech-tag">Web Forms (ZA Lead)</span>
                                <span class="modal-tech-tag">ADO.NET (ALL)</span>
                                <span class="modal-tech-tag">.NET Framework 4.8 (ALL)</span>
                                <span class="modal-tech-tag">SQL Server Client (AO, AK)</span>
                                <span class="modal-tech-tag">Bootstrap (ZA, AO)</span>
                                <span class="modal-tech-tag">Crystal Reports (ZA)</span>
                                <span class="modal-tech-tag">Windows Services (AK)</span>
                            </div>
                        </div>

                        <div class="detail-section">
                            <h5><i class="fas fa-rocket"></i>Launch Application</h5>
                            <p>Experience our team's collaborative desktop solution. Click below to launch the Web Forms application.</p>
                            <asp:Button ID="btnWinFormsModal" runat="server" Text="Launch Web Forms App"
                                CssClass="app-button mt-3" OnClick="btnWebFormsModal_Click" />
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Updated MVC Modal - Showing Full Team Collaboration -->
        <div class="modal fade" id="mvcModal" tabindex="-1" aria-hidden="true">
            <div class="modal-dialog modal-lg">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title">
                            <i class="fas fa-globe me-2"></i>
                            Advanced MVC Web Portal - Complete Details
                        </h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                        <div class="detail-section">
                            <h5><i class="fas fa-users"></i>Team Collaboration</h5>
                            <div class="team-collaboration-badge">
                                <div class="collaborator">
                                    <span class="avatar-small">AO</span>
                                    <span class="collaborator-name">ARAFAT OSMAN ADEN</span>
                                    <span class="collaborator-role">Lead Developer</span>
                                </div>
                                <div class="collaborator">
                                    <span class="avatar-small">ZA</span>
                                    <span class="collaborator-name">ZACKI ABDULKADIR OMER</span>
                                    <span class="collaborator-role">Database & APIs</span>
                                </div>
                                <div class="collaborator">
                                    <span class="avatar-small">AK</span>
                                    <span class="collaborator-name">ABDRIXEEM KHADAR CABDIRAXMAN</span>
                                    <span class="collaborator-role">Architecture & Security</span>
                                </div>
                            </div>
                            <p><strong>Full-Stack Development:</strong> All team members contributed to this web portal's database integration, API development, and frontend architecture.</p>
                        </div>

                        <div class="detail-section">
                            <h5><i class="fas fa-info-circle"></i>Overview</h5>
                            <p>Modern web application built with ASP.NET Core MVC featuring advanced architecture patterns. This represents our team's unified approach to web development.</p>
                        </div>

                        <div class="detail-section">
                            <h5><i class="fas fa-star"></i>Key Features</h5>
                            <ul class="feature-list">
                                <li><i class="fas fa-sitemap"></i>Clean MVC/MVVM architecture separation (Team: AO, AK)</li>
                                <li><i class="fas fa-database"></i>Entity Framework Core with advanced data modeling (Team: AO, ZA)</li>
                                <li><i class="fas fa-bolt"></i>Real-time SignalR communication (Team: AO, AK)</li>
                                <li><i class="fas fa-mobile-alt"></i>Progressive Web App (PWA) capabilities (Team: AO, ZA)</li>
                                <li><i class="fas fa-chart-line"></i>Advanced analytics dashboard (Team: ALL)</li>
                                <li><i class="fas fa-cogs"></i>Dependency Injection and IoC container (Team: AK, AO)</li>
                                <li><i class="fas fa-shield-alt"></i>Advanced security with role-based authorization (Team: AK, ZA)</li>
                                <li><i class="fas fa-sync"></i>Background job processing with Hangfire (Team: AO, AK)</li>
                            </ul>
                        </div>

                        <div class="detail-section">
                            <h5><i class="fas fa-code"></i>Technical Stack (Team Collaboration)</h5>
                            <div class="modal-tech-tags">
                                <span class="modal-tech-tag">ASP.NET Core 7+ (AO Lead)</span>
                                <span class="modal-tech-tag">MVC Architecture (AO, AK)</span>
                                <span class="modal-tech-tag">MVVM Pattern (AO)</span>
                                <span class="modal-tech-tag">Entity Framework Core (AO, ZA)</span>
                                <span class="modal-tech-tag">Razor Pages (AO)</span>
                                <span class="modal-tech-tag">TypeScript (AO, ZA)</span>
                                <span class="modal-tech-tag">SignalR (AO, AK)</span>
                                <span class="modal-tech-tag">Azure Integration (AK)</span>
                            </div>
                        </div>

                        <div class="detail-section">
                            <h5><i class="fas fa-rocket"></i>Launch Application</h5>
                            <p>Experience our team's collaborative web solution. Click below to launch the MVC Web Portal.</p>
                            <asp:Button ID="btnMVCModal" runat="server" Text="Launch MVC Portal"
                                CssClass="app-button mt-3" OnClick="btnMVCModal_Click" />
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Updated API Modal - Showing Full Team Collaboration -->
        <div class="modal fade" id="apiModal" tabindex="-1" aria-hidden="true">
            <div class="modal-dialog modal-lg">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title">
                            <i class="fas fa-code me-2"></i>
                            Web API Service - Complete Details
                        </h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                        <div class="detail-section">
                            <h5><i class="fas fa-users"></i>Team Collaboration</h5>
                            <div class="team-collaboration-badge">
                                <div class="collaborator">
                                    <span class="avatar-small">ALL</span>
                                    <span class="collaborator-name">FULL TEAM</span>
                                    <span class="collaborator-role">Joint Development</span>
                                </div>
                            </div>
                            <p><strong>Full Team Development:</strong> Every team member contributed equally to designing, developing, and testing this comprehensive API service.</p>
                        </div>

                        <div class="detail-section">
                            <h5><i class="fas fa-info-circle"></i>Overview</h5>
                            <p>RESTful API backend that powers all SoorGreen applications. This service represents our team's unified approach to backend development and system integration.</p>
                        </div>

                        <div class="detail-section">
                            <h5><i class="fas fa-star"></i>Key Features (Team Contributions)</h5>
                            <ul class="feature-list">
                                <li><i class="fas fa-shield-alt"></i>Secure JWT-based authentication (Team: AK, ZA)</li>
                                <li><i class="fas fa-mobile"></i>Mobile-optimized endpoints (Team: AO, ZA)</li>
                                <li><i class="fas fa-plug"></i>Third-party integration capabilities (Team: AK, AO)</li>
                                <li><i class="fas fa-book"></i>Comprehensive Swagger/OpenAPI documentation (Team: AO)</li>
                                <li><i class="fas fa-bolt"></i>High-performance optimized endpoints (Team: ALL)</li>
                                <li><i class="fas fa-cloud"></i>Cloud-ready microservices architecture (Team: AK)</li>
                                <li><i class="fas fa-database"></i>Real-time data synchronization (Team: ZA, AO)</li>
                                <li><i class="fas fa-chart-bar"></i>API analytics and monitoring (Team: ALL)</li>
                            </ul>
                        </div>

                        <div class="detail-section">
                            <h5><i class="fas fa-code"></i>Technical Stack (Team Collaboration)</h5>
                            <div class="modal-tech-tags">
                                <span class="modal-tech-tag">ASP.NET Web API (ALL)</span>
                                <span class="modal-tech-tag">JWT Authentication (AK, ZA)</span>
                                <span class="modal-tech-tag">Entity Framework (AO, ZA)</span>
                                <span class="modal-tech-tag">REST Principles (ALL)</span>
                                <span class="modal-tech-tag">Swagger/OpenAPI (AO)</span>
                                <span class="modal-tech-tag">Azure Ready (AK)</span>
                                <span class="modal-tech-tag">Docker Containers (AK, AO)</span>
                                <span class="modal-tech-tag">Redis Cache (ZA, AK)</span>
                            </div>
                        </div>

                        <div class="detail-section">
                            <h5><i class="fas fa-rocket"></i>Explore API</h5>
                            <p>Discover our team's collaborative API development. Click below to access the interactive API documentation.</p>
                            <asp:Button ID="btnAPIModal" runat="server" Text="Explore Web API"
                                CssClass="app-button mt-3" />
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Updated Custom Modal - Showing Full Team Collaboration -->
         <div class="modal fade" id="customModal" tabindex="-1" aria-hidden="true">
            <div class="modal-dialog modal-lg">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title">
                            <i class="fas fa-cogs me-2"></i>
                            Custom Solution Platform - Complete Details
                        </h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                        <div class="detail-section">
                            <h5><i class="fas fa-users"></i>Team Collaboration</h5>
                            <div class="team-collaboration-badge">
                                <div class="collaborator">
                                    <span class="avatar-small">AK</span>
                                    <span class="collaborator-name">ABDRIXEEM KHADAR CABDIRAXMAN</span>
                                    <span class="collaborator-role">Lead Architect</span>
                                </div>
                                <div class="collaborator">
                                    <span class="avatar-small">ZA</span>
                                    <span class="collaborator-name">ZACKI ABDULKADIR OMER</span>
                                    <span class="collaborator-role">Database & Integration</span>
                                </div>
                                <div class="collaborator">
                                    <span class="avatar-small">AO</span>
                                    <span class="collaborator-name">ARAFAT OSMAN ADEN</span>
                                    <span class="collaborator-role">APIs & Frontend</span>
                                </div>
                            </div>
                            <p><strong>Full-Stack Development:</strong> All team members collaborated on designing and implementing these specialized solutions.</p>
                        </div>

                        <div class="detail-section">
                            <h5><i class="fas fa-info-circle"></i>Overview</h5>
                            <p>Specialized application suite for unique municipal requirements. This represents our team's ability to work together on complex, custom solutions.</p>
                        </div>

                        <div class="detail-section">
                            <h5><i class="fas fa-star"></i>Key Features</h5>
                            <ul class="feature-list">
                                <li><i class="fas fa-puzzle-piece"></i>Custom-built technology stack (Team: AK, ALL)</li>
                                <li><i class="fas fa-exchange-alt"></i>Legacy system integration bridge (Team: AK, ZA)</li>
                                <li><i class="fas fa-project-diagram"></i>Specialized workflow automation (Team: ALL)</li>
                                <li><i class="fas fa-file-contract"></i>Custom reporting and compliance tools (Team: ZA, AO)</li>
                                <li><i class="fas fa-hdd"></i>Proprietary data storage solutions (Team: AK, ZA)</li>
                                <li><i class="fas fa-shield-alt"></i>Enhanced security protocols (Team: AK, ALL)</li>
                                <li><i class="fas fa-broadcast-tower"></i>Municipal network optimization (Team: AK)</li>
                                <li><i class="fas fa-tools"></i>Custom administrative tools (Team: ALL)</li>
                            </ul>
                        </div>

                        <div class="detail-section">
                            <h5><i class="fas fa-code"></i>Technical Stack (Team Collaboration)</h5>
                            <div class="modal-tech-tags">
                                <span class="modal-tech-tag">Custom .NET Components (AK Lead)</span>
                                <span class="modal-tech-tag">Proprietary Libraries (ALL)</span>
                                <span class="modal-tech-tag">Legacy Integration (AK, ZA)</span>
                                <span class="modal-tech-tag">Specialized APIs (AO, AK)</span>
                                <span class="modal-tech-tag">Custom Database Schema (ZA, AK)</span>
                                <span class="modal-tech-tag">Municipal Protocols (ALL)</span>
                                <span class="modal-tech-tag">Hardware Integration (AK)</span>
                                <span class="modal-tech-tag">Custom Security (AK, ZA)</span>
                            </div>
                        </div>

                        <div class="detail-section">
                            <h5><i class="fas fa-rocket"></i>Launch Application</h5>
                            <p>Experience our team's collaborative custom solution. Click below to launch the Custom Application Platform.</p>
                            <asp:Button ID="btnCustomModal" runat="server" Text="Launch Custom App"
                                CssClass="app-button mt-3" OnClick="btnCustomModal_Click" />
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </form>

    <!-- Scripts -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://unpkg.com/aos@2.3.1/dist/aos.js"></script>
    <script src="ChooseApp.js"></script>
</body>
</html>
