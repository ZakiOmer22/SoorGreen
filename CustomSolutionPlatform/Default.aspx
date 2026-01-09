<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="CustomSolutionPlatform._Default" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>SoorGreen - Custom Solution Platform</title>
    
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" />
    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet" />
    <!-- Animate CSS -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/animate.css/4.1.1/animate.min.css" />
    <!-- Glightbox for modals -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/glightbox/dist/css/glightbox.min.css" />
    
    <style>
        :root {
            --primary: #10B981;
            --primary-dark: #059669;
            --primary-light: #D1FAE5;
            --secondary: #3B82F6;
            --accent: #8B5CF6;
            --accent-pink: #EC4899;
            --dark: #0F172A;
            --dark-card: #1E293B;
            --light: #FFFFFF;
            --light-gray: #F8FAFC;
            --gray: #64748B;
            --gradient-primary: linear-gradient(135deg, #10B981 0%, #3B82F6 100%);
            --gradient-accent: linear-gradient(135deg, #8B5CF6 0%, #EC4899 100%);
            --gradient-dark: linear-gradient(135deg, #0F172A 0%, #1E293B 100%);
            --gradient-light: linear-gradient(135deg, #F8FAFC 0%, #E2E8F0 100%);
            --shadow-sm: 0 2px 4px rgba(0, 0, 0, 0.05);
            --shadow-md: 0 4px 20px rgba(0, 0, 0, 0.08);
            --shadow-lg: 0 10px 40px rgba(0, 0, 0, 0.12);
            --shadow-xl: 0 20px 60px rgba(0, 0, 0, 0.15);
            --radius-sm: 8px;
            --radius-md: 16px;
            --radius-lg: 24px;
            --radius-xl: 32px;
        }
        
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Inter', sans-serif;
            background-color: var(--light-gray);
            color: var(--dark);
            overflow-x: hidden;
            line-height: 1.6;
        }
        
        h1, h2, h3, h4, h5, h6 {
            font-family: 'Poppins', sans-serif;
            font-weight: 700;
            line-height: 1.2;
        }
        
        /* Modern Navigation */
        .navbar {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            padding: 1.2rem 0;
            position: fixed;
            top: 0;
            width: 100%;
            z-index: 1000;
            box-shadow: var(--shadow-sm);
            border-bottom: 1px solid rgba(0, 0, 0, 0.05);
        }
        
        .navbar-brand {
            font-weight: 800;
            font-size: 1.5rem;
            color: var(--dark);
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .navbar-brand i {
            background: var(--gradient-primary);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }
        
        .nav-link {
            font-weight: 500;
            padding: 0.5rem 1.2rem !important;
            border-radius: var(--radius-sm);
            transition: all 0.3s ease;
        }
        
        .nav-link:hover {
            background: var(--primary-light);
            color: var(--primary-dark);
        }
        
        .nav-btn {
            background: var(--gradient-primary);
            color: white !important;
            padding: 0.6rem 1.8rem !important;
            border-radius: var(--radius-md);
            font-weight: 600;
            box-shadow: var(--shadow-md);
        }
        
        .nav-btn:hover {
            transform: translateY(-2px);
            box-shadow: var(--shadow-lg);
        }
        
        /* Hero Section */
        .hero-section {
            padding: 180px 0 100px;
            background: linear-gradient(135deg, #F8FAFC 0%, #F1F5F9 100%);
            position: relative;
            overflow: hidden;
        }
        
        .hero-section::before {
            content: '';
            position: absolute;
            top: -50%;
            right: -20%;
            width: 70%;
            height: 200%;
            background: linear-gradient(135deg, rgba(16, 185, 129, 0.05) 0%, rgba(59, 130, 246, 0.05) 100%);
            transform: rotate(12deg);
            border-radius: 40px;
        }
        
        .hero-title {
            font-size: 3.5rem;
            font-weight: 800;
            line-height: 1.1;
            margin-bottom: 1.5rem;
            background: linear-gradient(135deg, var(--primary) 0%, var(--secondary) 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }
        
        .hero-subtitle {
            font-size: 1.25rem;
            color: var(--gray);
            margin-bottom: 2.5rem;
            max-width: 600px;
        }
        
        .hero-stats {
            display: flex;
            gap: 3rem;
            margin-top: 3rem;
        }
        
        .stat-item {
            text-align: center;
        }
        
        .stat-number {
            font-size: 2.5rem;
            font-weight: 800;
            background: var(--gradient-primary);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
            line-height: 1;
        }
        
        .stat-label {
            font-size: 0.9rem;
            color: var(--gray);
            text-transform: uppercase;
            letter-spacing: 1px;
            margin-top: 0.5rem;
        }
        
        /* User Cards - Modern Design */
        .user-cards-section {
            padding: 100px 0;
            background: white;
        }
        
        .section-title {
            text-align: center;
            font-size: 2.5rem;
            margin-bottom: 1rem;
            color: var(--dark);
        }
        
        .section-subtitle {
            text-align: center;
            color: var(--gray);
            font-size: 1.1rem;
            max-width: 600px;
            margin: 0 auto 4rem;
        }
        
        .user-card {
            background: white;
            border-radius: var(--radius-lg);
            padding: 3rem 2.5rem;
            height: 100%;
            position: relative;
            overflow: hidden;
            border: 1px solid rgba(0, 0, 0, 0.05);
            transition: all 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275);
            box-shadow: var(--shadow-md);
        }
        
        .user-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 6px;
            background: var(--gradient-primary);
            border-radius: var(--radius-lg) var(--radius-lg) 0 0;
        }
        
        .user-card.featured::before {
            background: var(--gradient-accent);
        }
        
        .user-card:hover {
            transform: translateY(-15px);
            box-shadow: var(--shadow-xl);
        }
        
        .card-badge {
            position: absolute;
            top: 20px;
            right: 20px;
            background: var(--gradient-primary);
            color: white;
            padding: 0.5rem 1.2rem;
            border-radius: 50px;
            font-size: 0.8rem;
            font-weight: 600;
            letter-spacing: 0.5px;
        }
        
        .featured .card-badge {
            background: var(--gradient-accent);
        }
        
        .card-icon {
            width: 80px;
            height: 80px;
            background: linear-gradient(135deg, rgba(16, 185, 129, 0.1) 0%, rgba(59, 130, 246, 0.1) 100%);
            border-radius: 20px;
            display: flex;
            align-items: center;
            justify-content: center;
            margin-bottom: 2rem;
            font-size: 2rem;
            color: var(--primary);
        }
        
        .featured .card-icon {
            background: linear-gradient(135deg, rgba(139, 92, 246, 0.1) 0%, rgba(236, 72, 153, 0.1) 100%);
            color: var(--accent);
        }
        
        .card-title {
            font-size: 1.8rem;
            margin-bottom: 1rem;
            color: var(--dark);
        }
        
        .card-description {
            color: var(--gray);
            margin-bottom: 2rem;
            font-size: 1rem;
        }
        
        .feature-list {
            list-style: none;
            padding: 0;
            margin-bottom: 2.5rem;
        }
        
        .feature-list li {
            padding: 0.5rem 0;
            color: var(--dark);
            position: relative;
            padding-left: 30px;
        }
        
        .feature-list li::before {
            content: '✓';
            position: absolute;
            left: 0;
            color: var(--primary);
            font-weight: bold;
            width: 20px;
            height: 20px;
            background: var(--primary-light);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 0.8rem;
        }
        
        .featured .feature-list li::before {
            background: rgba(139, 92, 246, 0.1);
            color: var(--accent);
        }
        
        .btn-card {
            width: 100%;
            padding: 1rem 2rem;
            border-radius: var(--radius-md);
            font-weight: 600;
            font-size: 1rem;
            border: none;
            cursor: pointer;
            transition: all 0.3s ease;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
            position: relative;
            overflow: hidden;
        }
        
        .btn-card::after {
            content: '';
            position: absolute;
            top: 50%;
            left: 50%;
            width: 0;
            height: 0;
            border-radius: 50%;
            background: rgba(255, 255, 255, 0.2);
            transform: translate(-50%, -50%);
            transition: width 0.6s, height 0.6s;
        }
        
        .btn-card:hover::after {
            width: 300px;
            height: 300px;
        }
        
        .btn-primary-card {
            background: var(--gradient-primary);
            color: white;
            box-shadow: var(--shadow-md);
        }
        
        .btn-primary-card:hover {
            transform: translateY(-3px);
            box-shadow: var(--shadow-lg);
        }
        
        .btn-accent-card {
            background: var(--gradient-accent);
            color: white;
            box-shadow: var(--shadow-md);
        }
        
        .btn-accent-card:hover {
            transform: translateY(-3px);
            box-shadow: var(--shadow-lg);
        }
        
        /* Process Steps */
        .process-section {
            padding: 100px 0;
            background: var(--dark);
            position: relative;
            overflow: hidden;
        }
        
        .process-section::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: url('data:image/svg+xml,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1200 120" preserveAspectRatio="none"><path d="M321.39,56.44c58-10.79,114.16-30.13,172-41.86,82.39-16.72,168.19-17.73,250.45-.39C823.78,31,906.67,72,985.66,92.83c70.05,18.48,146.53,26.09,214.34,3V0H0V27.35A600.21,600.21,0,0,0,321.39,56.44Z" fill="%231E293B"/></svg>');
            background-size: cover;
            background-position: bottom;
            opacity: 0.5;
        }
        
        .process-step {
            text-align: center;
            padding: 2rem;
            position: relative;
            z-index: 2;
        }
        
        .step-number {
            width: 60px;
            height: 60px;
            background: var(--gradient-primary);
            color: white;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.5rem;
            font-weight: 700;
            margin: 0 auto 1.5rem;
            box-shadow: var(--shadow-lg);
        }
        
        .step-title {
            color: white;
            font-size: 1.3rem;
            margin-bottom: 1rem;
        }
        
        .step-description {
            color: rgba(255, 255, 255, 0.7);
            font-size: 0.95rem;
        }
        
        /* Features Grid */
        .features-grid {
            padding: 100px 0;
            background: white;
        }
        
        .feature-grid-item {
            padding: 2.5rem;
            border-radius: var(--radius-lg);
            background: white;
            border: 1px solid rgba(0, 0, 0, 0.05);
            transition: all 0.3s ease;
            height: 100%;
        }
        
        .feature-grid-item:hover {
            transform: translateY(-10px);
            box-shadow: var(--shadow-xl);
            border-color: transparent;
        }
        
        .feature-grid-icon {
            width: 60px;
            height: 60px;
            background: var(--gradient-primary);
            border-radius: var(--radius-md);
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 1.5rem;
            margin-bottom: 1.5rem;
        }
        
        /* Team Section */
        .team-section {
            padding: 100px 0;
            background: var(--light-gray);
        }
        
        .team-card {
            background: white;
            border-radius: var(--radius-lg);
            padding: 2rem;
            text-align: center;
            transition: all 0.3s ease;
            border: 1px solid rgba(0, 0, 0, 0.05);
        }
        
        .team-card:hover {
            transform: translateY(-10px);
            box-shadow: var(--shadow-xl);
        }
        
        .team-avatar {
            width: 100px;
            height: 100px;
            background: var(--gradient-primary);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 2rem;
            font-weight: 700;
            margin: 0 auto 1.5rem;
        }
        
        /* CTA Section */
        .cta-section {
            padding: 120px 0;
            background: var(--gradient-dark);
            color: white;
            position: relative;
            overflow: hidden;
        }
        
        .cta-section::before {
            content: '';
            position: absolute;
            top: -50%;
            left: -50%;
            width: 200%;
            height: 200%;
            background: radial-gradient(circle, rgba(255,255,255,0.1) 0%, transparent 70%);
        }
        
        .cta-title {
            font-size: 3rem;
            margin-bottom: 1.5rem;
        }
        
        .cta-subtitle {
            font-size: 1.2rem;
            color: rgba(255, 255, 255, 0.8);
            margin-bottom: 2.5rem;
            max-width: 600px;
        }
        
        .btn-cta {
            background: var(--gradient-primary);
            color: white;
            padding: 1.2rem 3rem;
            border-radius: var(--radius-md);
            font-weight: 600;
            font-size: 1.1rem;
            border: none;
            box-shadow: var(--shadow-lg);
            transition: all 0.3s ease;
        }
        
        .btn-cta:hover {
            transform: translateY(-5px) scale(1.05);
            box-shadow: var(--shadow-xl);
        }
        
        /* Footer */
        .footer {
            background: var(--dark);
            color: white;
            padding: 80px 0 40px;
            position: relative;
        }
        
        .footer::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 1px;
            background: linear-gradient(90deg, transparent, rgba(255,255,255,0.2), transparent);
        }
        
        .footer-links a {
            color: rgba(255, 255, 255, 0.7);
            text-decoration: none;
            transition: all 0.3s ease;
            display: block;
            padding: 0.3rem 0;
        }
        
        .footer-links a:hover {
            color: white;
            transform: translateX(5px);
        }
        
        /* Floating Elements */
        .floating-element {
            position: absolute;
            border-radius: 50%;
            background: rgba(255, 255, 255, 0.1);
            animation: float 6s ease-in-out infinite;
            z-index: 1;
        }
        
        @keyframes float {
            0%, 100% { transform: translateY(0) rotate(0deg); }
            50% { transform: translateY(-20px) rotate(180deg); }
        }
        
        /* Responsive Design */
        @media (max-width: 992px) {
            .hero-title {
                font-size: 2.8rem;
            }
            
            .section-title {
                font-size: 2rem;
            }
            
            .user-card {
                padding: 2.5rem 2rem;
            }
        }
        
        @media (max-width: 768px) {
            .hero-title {
                font-size: 2.2rem;
            }
            
            .hero-section {
                padding: 150px 0 80px;
            }
            
            .section-title {
                font-size: 1.8rem;
            }
            
            .stat-number {
                font-size: 2rem;
            }
            
            .hero-stats {
                flex-direction: column;
                gap: 1.5rem;
            }
        }
        
        /* Custom Scrollbar */
        ::-webkit-scrollbar {
            width: 10px;
        }
        
        ::-webkit-scrollbar-track {
            background: var(--light-gray);
        }
        
        ::-webkit-scrollbar-thumb {
            background: var(--primary);
            border-radius: 5px;
        }
        
        ::-webkit-scrollbar-thumb:hover {
            background: var(--primary-dark);
        }
    </style>
</head>
<body>
    <!-- Navigation -->
    <nav class="navbar navbar-expand-lg">
        <div class="container">
            <a class="navbar-brand" href="#">
                <i class="fas fa-cube"></i>
                SoorGreen
            </a>
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
                <i class="fas fa-bars"></i>
            </button>
            <div class="collapse navbar-collapse" id="navbarNav">
                <ul class="navbar-nav ms-auto align-items-center">
                    <li class="nav-item">
                        <a class="nav-link" href="#features">Features</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="#process">Process</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="#team">Team</a>
                    </li>
                    <li class="nav-item ms-3">
                        <a class="nav-link nav-btn" href="#start">
                            <i class="fas fa-rocket me-2"></i>Get Started
                        </a>
                    </li>
                </ul>
            </div>
        </div>
    </nav>

    <!-- Hero Section -->
    <section class="hero-section">
        <div class="floating-element" style="width: 100px; height: 100px; top: 20%; left: 5%;"></div>
        <div class="floating-element" style="width: 150px; height: 150px; top: 60%; right: 10%;"></div>
        
        <div class="container">
            <div class="row align-items-center">
                <div class="col-lg-6">
                    <h1 class="hero-title animate__animated animate__fadeInUp">
                        Custom Solutions<br>
                        <span style="color: var(--dark);">Tailored Just For You</span>
                    </h1>
                    <p class="hero-subtitle animate__animated animate__fadeInUp animate__delay-1s">
                        Our intelligent platform creates personalized solution blueprints based on your specific needs. 
                        Whether you're technical or non-technical, get the perfect roadmap for success.
                    </p>
                    <div class="animate__animated animate__fadeInUp animate__delay-2s">
                        <a href="#userCards" class="btn-cta me-3">
                            <i class="fas fa-play-circle me-2"></i>Start Now
                        </a>
                        <a href="#process" class="btn" style="background: white; color: var(--dark); padding: 1.2rem 2.5rem; border-radius: var(--radius-md);">
                            <i class="fas fa-info-circle me-2"></i>Learn More
                        </a>
                    </div>
                    
                    <div class="hero-stats animate__animated animate__fadeInUp animate__delay-3s">
                        <div class="stat-item">
                            <div class="stat-number">500+</div>
                            <div class="stat-label">Solutions Generated</div>
                        </div>
                        <div class="stat-item">
                            <div class="stat-number">98%</div>
                            <div class="stat-label">Satisfaction Rate</div>
                        </div>
                        <div class="stat-item">
                            <div class="stat-number">24/7</div>
                            <div class="stat-label">Support</div>
                        </div>
                    </div>
                </div>
                <div class="col-lg-6">
                    <div class="position-relative">
                        <!-- Hero visual placeholder - would be replaced with actual graphic -->
                        <div style="background: var(--gradient-primary); border-radius: var(--radius-xl); height: 400px; position: relative; overflow: hidden;">
                            <div style="position: absolute; top: 50%; left: 50%; transform: translate(-50%, -50%); text-align: center; color: white; padding: 2rem;">
                                <i class="fas fa-cogs" style="font-size: 6rem; margin-bottom: 2rem;"></i>
                                <h3 style="font-size: 2rem;">Custom Solution Platform</h3>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- User Cards Section -->
    <section class="user-cards-section" id="userCards">
        <div class="container">
            <h2 class="section-title animate__animated animate__fadeIn">Choose Your Path</h2>
            <p class="section-subtitle animate__animated animate__fadeIn animate__delay-1s">
                Select your profile to get a personalized questionnaire experience
            </p>
            
            <div class="row g-4">
                <!-- IT Professional Card -->
                <div class="col-lg-6 animate__animated animate__fadeInLeft">
                    <div class="user-card">
                        <span class="card-badge">Most Popular</span>
                        <div class="card-icon">
                            <i class="fas fa-laptop-code"></i>
                        </div>
                        <h3 class="card-title">IT Professional / Developer</h3>
                        <p class="card-description">
                            Get detailed technical specifications, API documentation, and implementation roadmaps 
                            tailored to your technology stack and expertise level.
                        </p>
                        <ul class="feature-list">
                            <li>Detailed technical specifications</li>
                            <li>API documentation & integration guides</li>
                            <li>Technology stack recommendations</li>
                            <li>Code snippets & architecture diagrams</li>
                            <li>Implementation roadmaps</li>
                        </ul>
                        <a href="Questionnaire.aspx?type=IT" class="btn-card btn-primary-card">
                            <i class="fas fa-rocket"></i>
                            Start Technical Questionnaire
                        </a>
                    </div>
                </div>
                
                <!-- Non-IT Business User Card -->
                <div class="col-lg-6 animate__animated animate__fadeInRight">
                    <div class="user-card featured">
                        <span class="card-badge">Recommended</span>
                        <div class="card-icon">
                            <i class="fas fa-user-tie"></i>
                        </div>
                        <h3 class="card-title">Business Professional</h3>
                        <p class="card-description">
                            Receive business-focused solutions with clear ROI analysis, user-friendly interfaces, 
                            and implementation support options designed for non-technical users.
                        </p>
                        <ul class="feature-list">
                            <li>Business process solutions</li>
                            <li>Cost-benefit analysis</li>
                            <li>User-friendly interface designs</li>
                            <li>Implementation support options</li>
                            <li>Training & documentation</li>
                        </ul>
                        <a href="Questionnaire.aspx?type=NonIT" class="btn-card btn-accent-card">
                            <i class="fas fa-chart-line"></i>
                            Start Business Questionnaire
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Process Section -->
    <section class="process-section" id="process">
        <div class="container">
            <h2 class="section-title text-white mb-5">How It Works</h2>
            
            <div class="row g-4">
                <div class="col-md-4">
                    <div class="process-step">
                        <div class="step-number">1</div>
                        <h3 class="step-title">Select Your Profile</h3>
                        <p class="step-description">
                            Choose between IT Professional or Business User to get a tailored questionnaire experience.
                        </p>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="process-step">
                        <div class="step-number">2</div>
                        <h3 class="step-title">Answer Questions</h3>
                        <p class="step-description">
                            Our adaptive questionnaire adjusts based on your responses to gather precise requirements.
                        </p>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="process-step">
                        <div class="step-number">3</div>
                        <h3 class="step-title">Get Your Solution</h3>
                        <p class="step-description">
                            Receive a comprehensive solution blueprint with timelines, costs, and implementation steps.
                        </p>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Features Grid -->
    <section class="features-grid" id="features">
        <div class="container">
            <h2 class="section-title mb-5">Why Choose Our Platform</h2>
            
            <div class="row g-4">
                <div class="col-md-4">
                    <div class="feature-grid-item">
                        <div class="feature-grid-icon">
                            <i class="fas fa-brain"></i>
                        </div>
                        <h4>AI-Powered Analysis</h4>
                        <p class="text-muted mt-2">
                            Our intelligent system analyzes your requirements to generate the most appropriate solution.
                        </p>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="feature-grid-item">
                        <div class="feature-grid-icon">
                            <i class="fas fa-bolt"></i>
                        </div>
                        <h4>Adaptive Questionnaire</h4>
                        <p class="text-muted mt-2">
                            Questions dynamically adjust based on your previous answers for maximum relevance.
                        </p>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="feature-grid-item">
                        <div class="feature-grid-icon">
                            <i class="fas fa-file-alt"></i>
                        </div>
                        <h4>Detailed Blueprints</h4>
                        <p class="text-muted mt-2">
                            Get comprehensive solution documents with implementation steps and timelines.
                        </p>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Team Section -->
    <section class="team-section" id="team">
        <div class="container">
            <h2 class="section-title mb-5">Development Team</h2>
            
            <div class="row g-4 justify-content-center">
                <div class="col-md-4">
                    <div class="team-card">
                        <div class="team-avatar">ZA</div>
                        <h5 class="mb-1">ZACKI ABDULKADIR OMER</h5>
                        <p class="text-primary mb-2">Lead Developer & Database</p>
                        <small class="text-muted d-block">Port: 44306 | Project Lead</small>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="team-card">
                        <div class="team-avatar">AK</div>
                        <h5 class="mb-1">ABDIRAXEEM KHADAR ABDIRAXMAN</h5>
                        <p class="text-primary mb-2">Solution Architect & AI</p>
                        <small class="text-muted d-block">Backend & Algorithm Design</small>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="team-card">
                        <div class="team-avatar">AO</div>
                        <h5 class="mb-1">ARAFAT OSMAN ADEN</h5>
                        <p class="text-primary mb-2">Frontend & APIs</p>
                        <small class="text-muted d-block">UI/UX & Integration</small>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- CTA Section -->
    <section class="cta-section" id="start">
        <div class="container text-center">
            <h2 class="cta-title">Ready to Get Your Custom Solution?</h2>
            <p class="cta-subtitle">
                Join hundreds of satisfied users who have found their perfect solution through our platform.
                Start your journey today!
            </p>
            <a href="#userCards" class="btn-cta">
                <i class="fas fa-play-circle me-2"></i>Get Started Free
            </a>
        </div>
    </section>

    <!-- Footer -->
    <footer class="footer">
        <div class="container">
            <div class="row">
                <div class="col-lg-6 mb-4">
                    <h4 class="mb-3">
                        <i class="fas fa-cube me-2"></i>SoorGreen Solutions
                    </h4>
                    <p class="text-muted mb-4">
                        A dynamic platform generating tailored solutions for IT and non-IT users through intelligent questionnaires.
                    </p>
                </div>
                <div class="col-lg-6">
                    <div class="row">
                        <div class="col-md-6 mb-4">
                            <h5 class="mb-3">Quick Links</h5>
                            <div class="footer-links">
                                <a href="#features">Features</a>
                                <a href="#process">How It Works</a>
                                <a href="#team">Our Team</a>
                                <a href="#start">Get Started</a>
                            </div>
                        </div>
                        <div class="col-md-6 mb-4">
                            <h5 class="mb-3">Support</h5>
                            <div class="footer-links">
                                <a href="#">Help Center</a>
                                <a href="#">Contact Us</a>
                                <a href="#">Privacy Policy</a>
                                <a href="#">Terms of Service</a>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="text-center pt-4 mt-4 border-top border-dark">
                <p class="text-muted mb-0">&copy; 2024 SoorGreen Solutions. All rights reserved.</p>
            </div>
        </div>
    </footer>

    <!-- Scripts -->
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdn.jsdelivr.net/gh/mcstudios/glightbox/dist/js/glightbox.min.js"></script>
    
    <script>
        $(document).ready(function () {
            // Initialize GLightbox
            GLightbox();

            // Smooth scrolling for navigation links
            $('a[href^="#"]').on('click', function (e) {
                e.preventDefault();
                var target = $(this.getAttribute('href'));
                if (target.length) {
                    $('html, body').stop().animate({
                        scrollTop: target.offset().top - 80
                    }, 1000);
                }
            });

            // Animate elements on scroll
            function animateOnScroll() {
                $('.animate__animated').each(function () {
                    var element = $(this);
                    var position = element.offset().top;
                    var scrollPosition = $(window).scrollTop() + $(window).height();

                    if (position < scrollPosition - 100) {
                        element.addClass(element.data('animation'));
                    }
                });
            }

            // Set animation data
            $('.user-card:first-child').data('animation', 'animate__fadeInLeft');
            $('.user-card:last-child').data('animation', 'animate__fadeInRight');
            $('.process-step').each(function (index) {
                $(this).data('animation', 'animate__fadeInUp');
            });

            // Initial animation check
            animateOnScroll();

            // Check on scroll
            $(window).on('scroll', function () {
                animateOnScroll();
            });

            // Card hover effects
            $('.user-card').hover(
                function () {
                    $(this).addClass('shadow-xl');
                },
                function () {
                    $(this).removeClass('shadow-xl');
                }
            );

            // Button click animations
            $('.btn-card, .btn-cta').on('click', function (e) {
                var $btn = $(this);

                // Add ripple effect
                $btn.addClass('animate__animated animate__pulse');

                setTimeout(function () {
                    $btn.removeClass('animate__animated animate__pulse');
                }, 300);

                // If it's a questionnaire button, show loading
                if ($btn.attr('href').includes('Questionnaire.aspx')) {
                    e.preventDefault();

                    // Show loading overlay
                    $('body').append(`
                        <div class="loading-overlay" style="position:fixed;top:0;left:0;width:100%;height:100%;background:rgba(255,255,255,0.9);display:flex;align-items:center;justify-content:center;z-index:9999;">
                            <div class="text-center">
                                <div class="spinner-border text-primary" style="width:3rem;height:3rem;margin-bottom:1rem;" role="status">
                                    <span class="visually-hidden">Loading...</span>
                                </div>
                                <h4>Preparing your questionnaire...</h4>
                            </div>
                        </div>
                    `);

                    // Simulate loading, then redirect
                    setTimeout(function () {
                        window.location.href = $btn.attr('href');
                    }, 1500);
                }
            });

            // Navbar scroll effect
            $(window).scroll(function () {
                if ($(window).scrollTop() > 50) {
                    $('.navbar').addClass('navbar-scrolled');
                } else {
                    $('.navbar').removeClass('navbar-scrolled');
                }
            });
        });
    </script>
</body>
</html>