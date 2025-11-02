<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="SoorGreen.Main._Default" %>
<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>SoorGreen - Smart Waste Management Platform</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" />
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet" />
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet" />
    <link href="https://unpkg.com/aos@2.3.1/dist/aos.css" rel="stylesheet" />
    <style>
        :root {
            --primary: #00d4aa;
            --primary-dark: #00b894;
            --secondary: #0984e3;
            --accent: #fd79a8;
            --dark: #0a192f;
            --darker: #051122;
            --light: #ffffff;
            --card-bg: rgba(255, 255, 255, 0.08);
            --card-border: rgba(255, 255, 255, 0.12);
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Inter', sans-serif;
            background: linear-gradient(135deg, var(--darker) 0%, var(--dark) 50%, #1e3799 100%);
            color: var(--light);
            overflow-x: hidden;
            line-height: 1.6;
        }

        /* Navigation */
        .navbar {
            background: rgba(10, 25, 47, 0.95);
            backdrop-filter: blur(20px);
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
            padding: 1rem 0;
            position: fixed;
            width: 100%;
            top: 0;
            z-index: 1000;
            transition: all 0.3s ease;
        }

        .navbar-brand {
            font-weight: 700;
            font-size: 1.5rem;
            color: var(--primary) !important;
        }

        .nav-link {
            color: var(--light) !important;
            font-weight: 500;
            margin: 0 0.5rem;
            transition: all 0.3s ease;
        }

        .nav-link:hover {
            color: var(--primary) !important;
            transform: translateY(-2px);
        }

        /* Hero Section */
        .hero-section {
            min-height: 100vh;
            display: flex;
            align-items: center;
            position: relative;
            overflow: hidden;
            background: radial-gradient(ellipse at center, rgba(0, 212, 170, 0.1) 0%, transparent 70%);
        }

        .hero-bg {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: 
                radial-gradient(circle at 20% 80%, rgba(0, 212, 170, 0.15) 0%, transparent 50%),
                radial-gradient(circle at 80% 20%, rgba(9, 132, 227, 0.15) 0%, transparent 50%);
            animation: float 8s ease-in-out infinite;
        }

        @keyframes float {
            0%, 100% { transform: translateY(0px) rotate(0deg); }
            33% { transform: translateY(-20px) rotate(1deg); }
            66% { transform: translateY(10px) rotate(-1deg); }
        }

        .hero-content {
            position: relative;
            z-index: 2;
            text-align: center;
            padding: 0 2rem;
        }

        .hero-logo {
            font-size: 4rem;
            margin-bottom: 1.5rem;
            color: var(--primary);
            animation: bounce 3s ease infinite;
            filter: drop-shadow(0 0 20px rgba(0, 212, 170, 0.4));
        }

        @keyframes bounce {
            0%, 20%, 50%, 80%, 100% { transform: translateY(0) scale(1); }
            40% { transform: translateY(-20px) scale(1.1); }
            60% { transform: translateY(-10px) scale(1.05); }
        }

        .hero-title {
            font-size: 4rem;
            font-weight: 800;
            margin-bottom: 1.5rem;
            background: linear-gradient(45deg, var(--light), var(--primary), var(--secondary));
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            text-shadow: 0 0 30px rgba(255, 255, 255, 0.1);
            animation: titleGlow 3s ease-in-out infinite alternate;
        }

        @keyframes titleGlow {
            from { text-shadow: 0 0 20px rgba(255, 255, 255, 0.1); }
            to { text-shadow: 0 0 30px rgba(255, 255, 255, 0.3), 0 0 40px rgba(0, 212, 170, 0.2); }
        }

        .hero-subtitle {
            font-size: 1.4rem;
            margin-bottom: 3rem;
            opacity: 0.9;
            font-weight: 300;
            max-width: 600px;
            margin-left: auto;
            margin-right: auto;
            line-height: 1.6;
        }

        .btn-hero {
            background: linear-gradient(45deg, var(--primary), var(--secondary));
            border: none;
            padding: 1.2rem 3rem;
            border-radius: 50px;
            color: white;
            font-weight: 600;
            font-size: 1.1rem;
            cursor: pointer;
            transition: all 0.3s ease;
            display: inline-flex;
            align-items: center;
            gap: 0.8rem;
            position: relative;
            overflow: hidden;
        }

        .btn-hero::before {
            content: '';
            position: absolute;
            top: 0;
            left: -100%;
            width: 100%;
            height: 100%;
            background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.2), transparent);
            transition: left 0.5s ease;
        }

        .btn-hero:hover::before {
            left: 100%;
        }

        .btn-hero:hover {
            transform: translateY(-3px);
            box-shadow: 0 15px 30px rgba(0, 212, 170, 0.4);
        }

        /* Stats Section */
        .stats-section {
            padding: 100px 0;
            background: rgba(255, 255, 255, 0.03);
            backdrop-filter: blur(10px);
        }

        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 2rem;
            max-width: 1200px;
            margin: 0 auto;
            padding: 0 2rem;
        }

        .stat-card {
            text-align: center;
            padding: 2.5rem;
            background: var(--card-bg);
            border-radius: 20px;
            border: 1px solid var(--card-border);
            backdrop-filter: blur(10px);
            transition: all 0.3s ease;
        }

        .stat-card:hover {
            transform: translateY(-10px);
            border-color: var(--primary);
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.3);
        }

        .stat-number {
            font-size: 3rem;
            font-weight: 700;
            color: var(--primary);
            display: block;
            margin-bottom: 0.5rem;
        }

        .stat-label {
            font-size: 1rem;
            opacity: 0.8;
            text-transform: uppercase;
            letter-spacing: 1px;
        }

        /* Features Section */
        .features-section {
            padding: 150px 0;
            position: relative;
        }

        .section-title {
            font-size: 3.5rem;
            font-weight: 700;
            text-align: center;
            margin-bottom: 1rem;
            background: linear-gradient(45deg, var(--primary), var(--secondary));
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }

        .section-subtitle {
            font-size: 1.3rem;
            text-align: center;
            margin-bottom: 4rem;
            opacity: 0.8;
            max-width: 600px;
            margin-left: auto;
            margin-right: auto;
        }

        .features-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 2rem;
            max-width: 1200px;
            margin: 0 auto;
            padding: 0 2rem;
        }

        .feature-card {
            background: var(--card-bg);
            border-radius: 20px;
            padding: 3rem;
            border: 1px solid var(--card-border);
            transition: all 0.3s ease;
            text-align: center;
        }

        .feature-card:hover {
            transform: translateY(-10px);
            border-color: var(--primary);
            box-shadow: 0 25px 50px rgba(0, 0, 0, 0.3);
        }

        .feature-icon {
            font-size: 3rem;
            color: var(--primary);
            margin-bottom: 1.5rem;
        }

        .feature-title {
            font-size: 1.5rem;
            font-weight: 600;
            margin-bottom: 1rem;
            color: white;
        }

        .feature-desc {
            opacity: 0.8;
            line-height: 1.6;
        }

        /* Platform Showcase */
        .platform-section {
            padding: 150px 0;
            background: rgba(255, 255, 255, 0.03);
        }

        .platform-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(350px, 1fr));
            gap: 2rem;
            max-width: 1200px;
            margin: 0 auto;
            padding: 0 2rem;
        }

        .platform-card {
            background: var(--card-bg);
            border-radius: 25px;
            padding: 3rem;
            border: 1px solid var(--card-border);
            transition: all 0.4s ease;
            text-align: center;
            position: relative;
            overflow: hidden;
        }

        .platform-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: -100%;
            width: 100%;
            height: 100%;
            background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.05), transparent);
            transition: left 0.6s ease;
        }

        .platform-card:hover::before {
            left: 100%;
        }

        .platform-card:hover {
            transform: translateY(-15px);
            border-color: var(--primary);
            box-shadow: 0 30px 60px rgba(0, 0, 0, 0.4);
        }

        .platform-icon {
            font-size: 4rem;
            color: var(--primary);
            margin-bottom: 1.5rem;
        }

        .platform-title {
            font-size: 1.8rem;
            font-weight: 700;
            margin-bottom: 1rem;
            color: white;
        }

        .platform-desc {
            opacity: 0.8;
            margin-bottom: 2rem;
            line-height: 1.6;
        }

        /* How It Works Section */
        .how-it-works-section {
            padding: 150px 0;
            position: relative;
            background: rgba(255, 255, 255, 0.03);
        }

        .steps-container {
            max-width: 1000px;
            margin: 0 auto;
            padding: 0 2rem;
            position: relative;
        }

        .steps-container::before {
            content: '';
            position: absolute;
            top: 0;
            left: 50%;
            transform: translateX(-50%);
            width: 4px;
            height: 100%;
            background: linear-gradient(to bottom, var(--primary), var(--secondary));
            border-radius: 10px;
        }

        .step {
            display: flex;
            align-items: center;
            margin-bottom: 4rem;
            position: relative;
        }

        .step:nth-child(even) {
            flex-direction: row-reverse;
        }

        .step-content {
            flex: 1;
            padding: 2rem;
            background: var(--card-bg);
            border-radius: 20px;
            border: 1px solid var(--card-border);
            backdrop-filter: blur(10px);
        }

        .step-number {
            width: 60px;
            height: 60px;
            border-radius: 50%;
            background: linear-gradient(45deg, var(--primary), var(--secondary));
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 700;
            font-size: 1.5rem;
            margin: 0 2rem;
            flex-shrink: 0;
            position: relative;
            z-index: 2;
        }

        .step-title {
            font-size: 1.5rem;
            font-weight: 600;
            margin-bottom: 1rem;
            color: white;
        }

        .step-desc {
            opacity: 0.8;
            line-height: 1.6;
        }

        /* Testimonials Section */
        .testimonials-section {
            padding: 150px 0;
            position: relative;
        }

        .testimonials-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 2rem;
            max-width: 1200px;
            margin: 0 auto;
            padding: 0 2rem;
        }

        .testimonial-card {
            background: var(--card-bg);
            border-radius: 20px;
            padding: 2.5rem;
            border: 1px solid var(--card-border);
            transition: all 0.3s ease;
            position: relative;
        }

        .testimonial-card:hover {
            transform: translateY(-10px);
            border-color: var(--primary);
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.3);
        }

        .testimonial-quote {
            font-size: 3rem;
            color: var(--primary);
            opacity: 0.3;
            position: absolute;
            top: 1rem;
            left: 1.5rem;
        }

        .testimonial-text {
            margin-bottom: 1.5rem;
            font-style: italic;
            opacity: 0.9;
            line-height: 1.6;
        }

        .testimonial-author {
            display: flex;
            align-items: center;
        }

        .author-avatar {
            width: 50px;
            height: 50px;
            border-radius: 50%;
            background: linear-gradient(45deg, var(--primary), var(--secondary));
            display: flex;
            align-items: center;
            justify-content: center;
            margin-right: 1rem;
            font-weight: 600;
        }

        .author-info h4 {
            margin-bottom: 0.2rem;
            font-weight: 600;
        }

        .author-info p {
            opacity: 0.7;
            font-size: 0.9rem;
        }

        /* Partners Section */
        .partners-section {
            padding: 100px 0;
            background: rgba(255, 255, 255, 0.03);
        }

        .partners-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
            gap: 2rem;
            max-width: 1000px;
            margin: 0 auto;
            padding: 0 2rem;
        }

        .partner-logo {
            background: var(--card-bg);
            border-radius: 15px;
            padding: 2rem;
            border: 1px solid var(--card-border);
            display: flex;
            align-items: center;
            justify-content: center;
            height: 120px;
            transition: all 0.3s ease;
        }

        .partner-logo:hover {
            transform: translateY(-5px);
            border-color: var(--primary);
            box-shadow: 0 15px 30px rgba(0, 0, 0, 0.2);
        }

        .partner-logo img {
            max-width: 100%;
            max-height: 60px;
            filter: brightness(0) invert(1);
            opacity: 0.7;
            transition: all 0.3s ease;
        }

        .partner-logo:hover img {
            opacity: 1;
        }

        /* FAQ Section */
        .faq-section {
            padding: 150px 0;
            position: relative;
        }

        .faq-container {
            max-width: 800px;
            margin: 0 auto;
            padding: 0 2rem;
        }

        .faq-item {
            background: var(--card-bg);
            border-radius: 15px;
            margin-bottom: 1rem;
            border: 1px solid var(--card-border);
            overflow: hidden;
        }

        .faq-question {
            padding: 1.5rem;
            font-weight: 600;
            cursor: pointer;
            display: flex;
            justify-content: space-between;
            align-items: center;
            transition: all 0.3s ease;
        }

        .faq-question:hover {
            background: rgba(255, 255, 255, 0.05);
        }

        .faq-answer {
            padding: 0 1.5rem;
            max-height: 0;
            overflow: hidden;
            transition: all 0.3s ease;
            opacity: 0.8;
        }

        .faq-item.active .faq-answer {
            padding: 0 1.5rem 1.5rem;
            max-height: 500px;
        }

        .faq-icon {
            transition: transform 0.3s ease;
        }

        .faq-item.active .faq-icon {
            transform: rotate(180deg);
        }

        /* Technology Stack Section */
        .tech-stack-section {
            padding: 150px 0;
            background: rgba(255, 255, 255, 0.03);
        }

        .tech-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 2rem;
            max-width: 1000px;
            margin: 0 auto;
            padding: 0 2rem;
        }

        .tech-card {
            background: var(--card-bg);
            border-radius: 15px;
            padding: 2rem;
            border: 1px solid var(--card-border);
            text-align: center;
            transition: all 0.3s ease;
        }

        .tech-card:hover {
            transform: translateY(-10px);
            border-color: var(--primary);
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.3);
        }

        .tech-icon {
            font-size: 3rem;
            color: var(--primary);
            margin-bottom: 1rem;
        }

        .tech-name {
            font-weight: 600;
            margin-bottom: 0.5rem;
        }

        .tech-desc {
            opacity: 0.7;
            font-size: 0.9rem;
        }

        /* Team Section */
        .team-section {
            padding: 150px 0;
            position: relative;
        }

        .team-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 2rem;
            max-width: 1200px;
            margin: 0 auto;
            padding: 0 2rem;
        }

        .team-card {
            background: var(--card-bg);
            border-radius: 20px;
            padding: 2.5rem;
            border: 1px solid var(--card-border);
            text-align: center;
            transition: all 0.3s ease;
        }

        .team-card:hover {
            transform: translateY(-10px);
            border-color: var(--primary);
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.3);
        }

        .team-avatar {
            width: 120px;
            height: 120px;
            border-radius: 50%;
            background: linear-gradient(45deg, var(--primary), var(--secondary));
            margin: 0 auto 1.5rem;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 2.5rem;
            font-weight: 700;
        }

        .team-name {
            font-size: 1.3rem;
            font-weight: 600;
            margin-bottom: 0.5rem;
        }

        .team-role {
            color: var(--primary);
            margin-bottom: 1rem;
            font-weight: 500;
        }

        .team-desc {
            opacity: 0.8;
            line-height: 1.6;
            margin-bottom: 1.5rem;
        }

        .team-social {
            display: flex;
            justify-content: center;
            gap: 1rem;
        }

        .team-social a {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            background: rgba(255, 255, 255, 0.1);
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            text-decoration: none;
            transition: all 0.3s ease;
        }

        .team-social a:hover {
            background: var(--primary);
            transform: translateY(-3px);
        }

        /* CTA Section */
        .cta-section {
            padding: 150px 0;
            text-align: center;
            position: relative;
        }

        .cta-content {
            max-width: 800px;
            margin: 0 auto;
            padding: 0 2rem;
        }

        .cta-title {
            font-size: 3.5rem;
            font-weight: 700;
            margin-bottom: 1.5rem;
            background: linear-gradient(45deg, var(--primary), var(--accent));
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }

        .cta-subtitle {
            font-size: 1.3rem;
            margin-bottom: 3rem;
            opacity: 0.8;
            line-height: 1.6;
        }

        .btn-cta {
            background: linear-gradient(45deg, var(--primary), var(--accent));
            border: none;
            padding: 1.2rem 3rem;
            border-radius: 50px;
            color: white;
            font-weight: 600;
            font-size: 1.2rem;
            cursor: pointer;
            transition: all 0.3s ease;
            display: inline-flex;
            align-items: center;
            gap: 1rem;
            text-decoration: none;
        }

        .btn-cta:hover {
            transform: translateY(-5px);
            box-shadow: 0 20px 40px rgba(253, 121, 168, 0.4);
            color: white;
        }

        /* Footer */
        .footer {
            background: rgba(5, 17, 34, 0.95);
            padding: 80px 0 40px;
            border-top: 1px solid rgba(255, 255, 255, 0.1);
        }

        .footer-content {
            max-width: 1200px;
            margin: 0 auto;
            padding: 0 2rem;
            text-align: center;
        }

        .footer-logo {
            font-size: 2rem;
            font-weight: 700;
            color: var(--primary);
            margin-bottom: 1rem;
        }

        .footer-text {
            opacity: 0.7;
            margin-bottom: 2rem;
        }

        .social-links {
            display: flex;
            justify-content: center;
            gap: 1.5rem;
            margin-bottom: 2rem;
        }

        .social-link {
            width: 50px;
            height: 50px;
            background: var(--card-bg);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            color: var(--light);
            text-decoration: none;
            transition: all 0.3s ease;
        }

        .social-link:hover {
            background: var(--primary);
            transform: translateY(-3px);
        }

        .copyright {
            opacity: 0.5;
            font-size: 0.9rem;
        }

        /* Floating Elements */
        .floating-elements {
            position: absolute;
            width: 100%;
            height: 100%;
            pointer-events: none;
            top: 0;
            left: 0;
        }

        .floating-element {
            position: absolute;
            font-size: 2rem;
            opacity: 0.1;
            animation: floatElement 20s ease-in-out infinite;
        }

        @keyframes floatElement {
            0%, 100% { transform: translate(0, 0) rotate(0deg) scale(1); }
            25% { transform: translate(100px, -80px) rotate(90deg) scale(1.1); }
            50% { transform: translate(50px, -120px) rotate(180deg) scale(0.9); }
            75% { transform: translate(-80px, -60px) rotate(270deg) scale(1.05); }
        }

        /* Responsive */
        @media (max-width: 768px) {
            .hero-title { font-size: 2.5rem; }
            .section-title { font-size: 2.5rem; }
            .features-grid, .platform-grid { grid-template-columns: 1fr; }
            .stats-grid { grid-template-columns: repeat(2, 1fr); }
            .steps-container::before { display: none; }
            .step { flex-direction: column !important; }
            .step-number { margin: 0 0 1rem 0; }
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <!-- Navigation -->
        <nav class="navbar navbar-expand-lg navbar-dark">
            <div class="container">
                <a class="navbar-brand" href="#">
                    <i class="fas fa-recycle me-2"></i>
                    SoorGreen
                </a>
                <div class="navbar-nav ms-auto">
                    <a class="nav-link" href="#features">Features</a>
                    <a class="nav-link" href="#platform">Platform</a>
                    <a class="nav-link" href="#how-it-works">How It Works</a>
                    <a class="nav-link" href="#stats">Impact</a>
                    <a class="nav-link" href="#testimonials">Testimonials</a>
                    <a class="nav-link" href="#cta">Get Started</a>
                </div>
            </div>
        </nav>

        <!-- Hero Section -->
        <section class="hero-section" id="home">
            <div class="hero-bg"></div>
            <div class="floating-elements">
                <div class="floating-element" style="top: 20%; left: 10%;"><i class="fas fa-leaf"></i></div>
                <div class="floating-element" style="top: 60%; left: 85%;"><i class="fas fa-recycle"></i></div>
                <div class="floating-element" style="top: 80%; left: 15%;"><i class="fas fa-seedling"></i></div>
            </div>
            <div class="container">
                <div class="hero-content">
                    <div class="hero-logo">
                        <i class="fas fa-recycle"></i>
                    </div>
                    <h1 class="hero-title">SoorGreen Initiative</h1>
                    <p class="hero-subtitle">
                        Transforming waste management through technology, community engagement, and sustainable innovation. 
                        Join us in building cleaner, greener cities for future generations.
                    </p>
                    <a href="ChooseApp.aspx" class="btn-hero">
                        <i class="fas fa-rocket"></i>
                        Launch Platform
                    </a>
                </div>
            </div>
        </section>

        <!-- Stats Section -->
        <section class="stats-section" id="stats" data-aos="fade-up">
            <div class="stats-grid">
                <div class="stat-card" data-aos="zoom-in" data-aos-delay="100">
                    <span class="stat-number">2.5K+</span>
                    <span class="stat-label">Active Users</span>
                </div>
                <div class="stat-card" data-aos="zoom-in" data-aos-delay="200">
                    <span class="stat-number">1.2K+</span>
                    <span class="stat-label">Pickups Completed</span>
                </div>
                <div class="stat-card" data-aos="zoom-in" data-aos-delay="300">
                    <span class="stat-number">45K+</span>
                    <span class="stat-label">Credits Earned</span>
                </div>
                <div class="stat-card" data-aos="zoom-in" data-aos-delay="400">
                    <span class="stat-number">85+</span>
                    <span class="stat-label">Tons Recycled</span>
                </div>
            </div>
        </section>

        <!-- Features Section -->
        <section class="features-section" id="features">
            <h2 class="section-title" data-aos="fade-up">Why Choose SoorGreen?</h2>
            <p class="section-subtitle" data-aos="fade-up" data-aos-delay="200">
                Our comprehensive platform offers innovative solutions for modern waste management challenges
            </p>
            <div class="features-grid">
                <div class="feature-card" data-aos="fade-up" data-aos-delay="200">
                    <div class="feature-icon">
                        <i class="fas fa-shield-alt"></i>
                    </div>
                    <h3 class="feature-title">Secure & Reliable</h3>
                    <p class="feature-desc">Enterprise-grade security with encrypted data transmission and secure authentication systems.</p>
                </div>
                <div class="feature-card" data-aos="fade-up" data-aos-delay="400">
                    <div class="feature-icon">
                        <i class="fas fa-rocket"></i>
                    </div>
                    <h3 class="feature-title">High Performance</h3>
                    <p class="feature-desc">Optimized for speed and scalability, handling thousands of concurrent users seamlessly.</p>
                </div>
                <div class="feature-card" data-aos="fade-up" data-aos-delay="600">
                    <div class="feature-icon">
                        <i class="fas fa-mobile-alt"></i>
                    </div>
                    <h3 class="feature-title">Mobile First</h3>
                    <p class="feature-desc">Responsive design that works perfectly on all devices, from desktop to mobile.</p>
                </div>
            </div>
        </section>

        <!-- Platform Showcase -->
        <section class="platform-section" id="platform">
            <h2 class="section-title" data-aos="fade-up">Our Integrated Platform</h2>
            <p class="section-subtitle" data-aos="fade-up" data-aos-delay="200">
                Three powerful applications, one unified mission
            </p>
            <div class="platform-grid">
                <div class="platform-card" data-aos="fade-up" data-aos-delay="200">
                    <div class="platform-icon">
                        <i class="fas fa-tachometer-alt"></i>
                    </div>
                    <h3 class="platform-title">Admin Dashboard</h3>
                    <p class="platform-desc">Complete administrative interface for municipalities and system administrators with real-time analytics and management tools.</p>
                    <div class="tech-tags">
                        <span class="badge bg-primary">ASP.NET WebForms</span>
                        <span class="badge bg-secondary">SQL Server</span>
                    </div>
                </div>
                <div class="platform-card" data-aos="fade-up" data-aos-delay="400">
                    <div class="platform-icon">
                        <i class="fas fa-users"></i>
                    </div>
                    <h3 class="platform-title">Citizen Portal</h3>
                    <p class="platform-desc">Modern web application for citizens to report waste, track pickups, and redeem rewards with interactive features.</p>
                    <div class="tech-tags">
                        <span class="badge bg-primary">ASP.NET Core MVC</span>
                        <span class="badge bg-secondary">Entity Framework</span>
                    </div>
                </div>
                <div class="platform-card" data-aos="fade-up" data-aos-delay="600">
                    <div class="platform-icon">
                        <i class="fas fa-code"></i>
                    </div>
                    <h3 class="platform-title">API Services</h3>
                    <p class="platform-desc">RESTful API backend that powers all applications, enabling mobile apps and third-party integrations.</p>
                    <div class="tech-tags">
                        <span class="badge bg-primary">Web API</span>
                        <span class="badge bg-secondary">JWT Authentication</span>
                    </div>
                </div>
            </div>
        </section>

        <!-- How It Works Section -->
        <section class="how-it-works-section" id="how-it-works">
            <h2 class="section-title" data-aos="fade-up">How It Works</h2>
            <p class="section-subtitle" data-aos="fade-up" data-aos-delay="200">
                Simple steps to transform your waste management experience
            </p>
            <div class="steps-container">
                <div class="step" data-aos="fade-right" data-aos-delay="200">
                    <div class="step-number">1</div>
                    <div class="step-content">
                        <h3 class="step-title">Sign Up & Profile Setup</h3>
                        <p class="step-desc">Create your account and set up your profile. Choose your location and waste management preferences to get personalized service.</p>
                    </div>
                </div>
                <div class="step" data-aos="fade-left" data-aos-delay="400">
                    <div class="step-number">2</div>
                    <div class="step-content">
                        <h3 class="step-title">Schedule Waste Pickup</h3>
                        <p class="step-desc">Use our intuitive interface to schedule waste pickups at your convenience. Select date, time, and type of waste for collection.</p>
                    </div>
                </div>
                <div class="step" data-aos="fade-right" data-aos-delay="600">
                    <div class="step-number">3</div>
                    <div class="step-content">
                        <h3 class="step-title">Track Collection & Earn Credits</h3>
                        <p class="step-desc">Monitor your waste collection in real-time. Earn green credits for every successful pickup that you can redeem for rewards.</p>
                    </div>
                </div>
                <div class="step" data-aos="fade-left" data-aos-delay="800">
                    <div class="step-number">4</div>
                    <div class="step-content">
                        <h3 class="step-title">Redeem Rewards & Track Impact</h3>
                        <p class="step-desc">Use your earned credits to get discounts, vouchers, or donate to environmental causes. Track your personal environmental impact.</p>
                    </div>
                </div>
            </div>
        </section>

        <!-- Testimonials Section -->
        <section class="testimonials-section" id="testimonials">
            <h2 class="section-title" data-aos="fade-up">What Our Users Say</h2>
            <p class="section-subtitle" data-aos="fade-up" data-aos-delay="200">
                Hear from citizens and municipalities who have transformed their waste management
            </p>
            <div class="testimonials-grid">
                <div class="testimonial-card" data-aos="fade-up" data-aos-delay="200">
                    <div class="testimonial-quote">"</div>
                    <p class="testimonial-text">SoorGreen has completely changed how our community handles waste. The reward system motivates everyone to participate, and our neighborhood has never been cleaner!</p>
                    <div class="testimonial-author">
                        <div class="author-avatar">SR</div>
                        <div class="author-info">
                            <h4>Sarah Johnson</h4>
                            <p>Community Leader, Green Valley</p>
                        </div>
                    </div>
                </div>
                <div class="testimonial-card" data-aos="fade-up" data-aos-delay="400">
                    <div class="testimonial-quote">"</div>
                    <p class="testimonial-text">As a municipal administrator, SoorGreen has given us unprecedented visibility into our waste management operations. The analytics help us optimize routes and reduce costs significantly.</p>
                    <div class="testimonial-author">
                        <div class="author-avatar">MR</div>
                        <div class="author-info">
                            <h4>Michael Rodriguez</h4>
                            <p>City Waste Management Director</p>
                        </div>
                    </div>
                </div>
                <div class="testimonial-card" data-aos="fade-up" data-aos-delay="600">
                    <div class="testimonial-quote">"</div>
                    <p class="testimonial-text">I love how easy it is to schedule pickups and track my environmental impact. The reward points I've earned have paid for my grocery discounts multiple times!</p>
                    <div class="testimonial-author">
                        <div class="author-avatar">EP</div>
                        <div class="author-info">
                            <h4>Emma Patel</h4>
                            <p>Resident & Active User</p>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <!-- Partners Section -->
        <section class="partners-section" id="partners">
            <h2 class="section-title" data-aos="fade-up">Our Trusted Partners</h2>
            <p class="section-subtitle" data-aos="fade-up" data-aos-delay="200">
                Collaborating with leading organizations for a sustainable future
            </p>
            <div class="partners-grid">
                <div class="partner-logo" data-aos="zoom-in" data-aos-delay="200">
                    <i class="fas fa-city fa-3x"></i>
                </div>
                <div class="partner-logo" data-aos="zoom-in" data-aos-delay="300">
                    <i class="fas fa-recycle fa-3x"></i>
                </div>
                <div class="partner-logo" data-aos="zoom-in" data-aos-delay="400">
                    <i class="fas fa-leaf fa-3x"></i>
                </div>
                <div class="partner-logo" data-aos="zoom-in" data-aos-delay="500">
                    <i class="fas fa-globe-americas fa-3x"></i>
                </div>
                <div class="partner-logo" data-aos="zoom-in" data-aos-delay="600">
                    <i class="fas fa-hand-holding-heart fa-3x"></i>
                </div>
                <div class="partner-logo" data-aos="zoom-in" data-aos-delay="700">
                    <i class="fas fa-tree fa-3x"></i>
                </div>
            </div>
        </section>

        <!-- FAQ Section -->
        <section class="faq-section" id="faq">
            <h2 class="section-title" data-aos="fade-up">Frequently Asked Questions</h2>
            <p class="section-subtitle" data-aos="fade-up" data-aos-delay="200">
                Find answers to common questions about SoorGreen
            </p>
            <div class="faq-container">
                <div class="faq-item" data-aos="fade-up" data-aos-delay="200">
                    <div class="faq-question">
                        How do I sign up for SoorGreen?
                        <i class="fas fa-chevron-down faq-icon"></i>
                    </div>
                    <div class="faq-answer">
                        Signing up is easy! Simply click on the "Launch Platform" button and select the Citizen Portal. You'll be guided through a quick registration process where you'll provide basic information and set up your profile.
                    </div>
                </div>
                <div class="faq-item" data-aos="fade-up" data-aos-delay="300">
                    <div class="faq-question">
                        What types of waste can I schedule for pickup?
                        <i class="fas fa-chevron-down faq-icon"></i>
                    </div>
                    <div class="faq-answer">
                        We accept a wide range of waste types including recyclables (paper, plastic, glass, metal), organic waste, e-waste, and hazardous materials (with special handling). During scheduling, you'll be able to specify the type and quantity of waste.
                    </div>
                </div>
                <div class="faq-item" data-aos="fade-up" data-aos-delay="400">
                    <div class="faq-question">
                        How are the green credits calculated?
                        <i class="fas fa-chevron-down faq-icon"></i>
                    </div>
                    <div class="faq-answer">
                        Credits are calculated based on the type and quantity of waste you recycle. Recyclable materials earn more credits than regular waste. The exact calculation varies by material type and local recycling market values.
                    </div>
                </div>
                <div class="faq-item" data-aos="fade-up" data-aos-delay="500">
                    <div class="faq-question">
                        Can municipalities integrate with existing systems?
                        <i class="fas fa-chevron-down faq-icon"></i>
                    </div>
                    <div class="faq-answer">
                        Yes! Our platform offers robust API integration capabilities that allow municipalities to connect SoorGreen with their existing waste management systems, CRM, and billing platforms for seamless operations.
                    </div>
                </div>
            </div>
        </section>

        <!-- Technology Stack Section -->
        <section class="tech-stack-section" id="technology">
            <h2 class="section-title" data-aos="fade-up">Our Technology Stack</h2>
            <p class="section-subtitle" data-aos="fade-up" data-aos-delay="200">
                Built with cutting-edge technologies for performance and scalability
            </p>
            <div class="tech-grid">
                <div class="tech-card" data-aos="fade-up" data-aos-delay="200">
                    <div class="tech-icon">
                        <i class="fab fa-microsoft"></i>
                    </div>
                    <h3 class="tech-name">ASP.NET Core</h3>
                    <p class="tech-desc">High-performance web framework for building modern web applications and APIs.</p>
                </div>
                <div class="tech-card" data-aos="fade-up" data-aos-delay="300">
                    <div class="tech-icon">
                        <i class="fas fa-database"></i>
                    </div>
                    <h3 class="tech-name">SQL Server</h3>
                    <p class="tech-desc">Enterprise-grade database system for secure and reliable data storage.</p>
                </div>
                <div class="tech-card" data-aos="fade-up" data-aos-delay="400">
                    <div class="tech-icon">
                        <i class="fab fa-js-square"></i>
                    </div>
                    <h3 class="tech-name">JavaScript/TypeScript</h3>
                    <p class="tech-desc">Modern frontend development for interactive and responsive user interfaces.</p>
                </div>
                <div class="tech-card" data-aos="fade-up" data-aos-delay="500">
                    <div class="tech-icon">
                        <i class="fab fa-microsoft"></i>
                    </div>
                    <h3 class="tech-name">Azure Cloud</h3>
                    <p class="tech-desc">Scalable cloud infrastructure for global availability and performance.</p>
                </div>
            </div>
        </section>

        <!-- Team Section -->
        <section class="team-section" id="team">
            <h2 class="section-title" data-aos="fade-up">Meet Our Team</h2>
            <p class="section-subtitle" data-aos="fade-up" data-aos-delay="200">
                Passionate individuals dedicated to sustainable innovation
            </p>
            <div class="team-grid">
                <div class="team-card" data-aos="fade-up" data-aos-delay="200">
                    <div class="team-avatar">AJ</div>
                    <h3 class="team-name">Alex Johnson</h3>
                    <p class="team-role">CEO & Founder</p>
                    <p class="team-desc">Environmental engineer with 10+ years experience in sustainable technology solutions and urban planning.</p>
                    <div class="team-social">
                        <a href="#"><i class="fab fa-linkedin"></i></a>
                        <a href="#"><i class="fab fa-twitter"></i></a>
                    </div>
                </div>
                <div class="team-card" data-aos="fade-up" data-aos-delay="400">
                    <div class="team-avatar">MS</div>
                    <h3 class="team-name">Maria Sanchez</h3>
                    <p class="team-role">CTO</p>
                    <p class="team-desc">Software architect specializing in scalable cloud systems and IoT integration for smart city solutions.</p>
                    <div class="team-social">
                        <a href="#"><i class="fab fa-linkedin"></i></a>
                        <a href="#"><i class="fab fa-github"></i></a>
                    </div>
                </div>
                <div class="team-card" data-aos="fade-up" data-aos-delay="600">
                    <div class="team-avatar">DW</div>
                    <h3 class="team-name">David Wilson</h3>
                    <p class="team-role">Head of Operations</p>
                    <p class="team-desc">Operations expert with background in municipal waste management and community engagement programs.</p>
                    <div class="team-social">
                        <a href="#"><i class="fab fa-linkedin"></i></a>
                        <a href="#"><i class="fas fa-envelope"></i></a>
                    </div>
                </div>
            </div>
        </section>

        <!-- CTA Section -->
        <section class="cta-section" id="cta">
            <div class="cta-content">
                <h2 class="cta-title" data-aos="fade-up">Ready to Make a Difference?</h2>
                <p class="cta-subtitle" data-aos="fade-up" data-aos-delay="200">
                    Join thousands of users already transforming their communities through smart waste management. 
                    Choose your platform and start your sustainability journey today.
                </p>
                <a href="ChooseApp.aspx" class="btn-cta" data-aos="fade-up" data-aos-delay="400">
                    <i class="fas fa-play"></i>
                    Launch Application Portal
                </a>
            </div>
        </section>

        <!-- Footer -->
        <footer class="footer">
            <div class="footer-content">
                <div class="footer-logo">
                    <i class="fas fa-recycle me-2"></i>
                    SoorGreen
                </div>
                <p class="footer-text">
                    Transforming waste into opportunity through technology and community engagement.
                </p>
                <div class="social-links">
                    <a href="#" class="social-link"><i class="fab fa-twitter"></i></a>
                    <a href="#" class="social-link"><i class="fab fa-linkedin"></i></a>
                    <a href="#" class="social-link"><i class="fab fa-github"></i></a>
                    <a href="#" class="social-link"><i class="fab fa-instagram"></i></a>
                </div>
                <p class="copyright">
                    &copy; 2024 SoorGreen Initiative. All rights reserved. | Built with ❤️ for a sustainable future
                </p>
            </div>
        </footer>
    </form>

    <!-- Scripts -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://unpkg.com/aos@2.3.1/dist/aos.js"></script>
    <script>
        // Initialize AOS
        AOS.init({
            duration: 1000,
            once: true,
            offset: 100
        });

        // Navbar scroll effect
        window.addEventListener('scroll', function () {
            const navbar = document.querySelector('.navbar');
            if (window.scrollY > 100) {
                navbar.style.background = 'rgba(10, 25, 47, 0.98)';
                navbar.style.padding = '0.5rem 0';
            } else {
                navbar.style.background = 'rgba(10, 25, 47, 0.95)';
                navbar.style.padding = '1rem 0';
            }
        });

        // Smooth scrolling for navigation links
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

        // FAQ toggle functionality
        document.querySelectorAll('.faq-question').forEach(question => {
            question.addEventListener('click', () => {
                const item = question.parentElement;
                item.classList.toggle('active');
            });
        });
    </script>
</body>
</html>