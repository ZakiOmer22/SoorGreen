<%@ Page Title="Home" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="false" %>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <style>
        /* Light mode specific colors - properly designed for light backgrounds */
        [data-theme="light"] {
            --light-bg: #f8f9fa;
            --light-card: #ffffff;
            --light-border: #e9ecef;
            --light-text: #212529;
            --light-muted: #6c757d;
            --light-shadow: rgba(0, 0, 0, 0.1);
            --light-overlay: rgba(255, 255, 255, 0.8);
        }

        /* Hero Section Light Mode */
        [data-theme="light"] .hero-section {
            background: radial-gradient(ellipse at center, rgba(0, 212, 170, 0.08) 0%, transparent 70%);
        }

        [data-theme="light"] .hero-bg {
            background: radial-gradient(circle at 20% 80%, rgba(0, 212, 170, 0.1) 0%, transparent 50%), 
                        radial-gradient(circle at 80% 20%, rgba(9, 132, 227, 0.1) 0%, transparent 50%);
        }

        [data-theme="light"] .hero-badge .badge {
            background: rgba(255, 255, 255, 0.9) !important;
            backdrop-filter: blur(10px);
            border: 1px solid rgba(0, 212, 170, 0.3);
            color: var(--primary) !important;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
        }

        [data-theme="light"] .hero-title {
            background: linear-gradient(45deg, var(--light-text), var(--primary), var(--secondary));
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            text-shadow: 0 0 30px rgba(0, 212, 170, 0.2);
        }

        [data-theme="light"] .hero-subtitle {
            color: var(--light-muted);
            opacity: 0.9;
        }

        [data-theme="light"] .floating-card {
            background: var(--light-card);
            border: 1px solid var(--light-border);
            color: var(--light-text);
            box-shadow: 0 8px 25px rgba(0, 0, 0, 0.1);
        }

        /* Section Backgrounds Light Mode */
        [data-theme="light"] .stats-section,
        [data-theme="light"] .features-section,
        [data-theme="light"] .how-it-works-section,
        [data-theme="light"] .platform-section,
        [data-theme="light"] .testimonials-section,
        [data-theme="light"] .mobile-app-section,
        [data-theme="light"] .pricing-section,
        [data-theme="light"] .partners-section,
        [data-theme="light"] .faq-section,
        [data-theme="light"] .tech-stack-section,
        [data-theme="light"] .impact-section,
        [data-theme="light"] .case-studies-section,
        [data-theme="light"] .team-section,
        [data-theme="light"] .awards-section,
        [data-theme="light"] .integration-section {
            background: var(--light-bg) !important;
        }

        /* Card Styles Light Mode */
        [data-theme="light"] .stat-card,
        [data-theme="light"] .feature-card,
        [data-theme="light"] .step-card,
        [data-theme="light"] .feature-item,
        [data-theme="light"] .testimonial-card,
        [data-theme="light"] .pricing-card,
        [data-theme="light"] .partner-logo,
        [data-theme="light"] .tech-card,
        [data-theme="light"] .impact-card,
        [data-theme="light"] .case-study-card,
        [data-theme="light"] .team-card,
        [data-theme="light"] .award-card {
            background: var(--light-card) !important;
            border: 1px solid var(--light-border) !important;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.08);
        }

        [data-theme="light"] .stat-card:hover,
        [data-theme="light"] .feature-card:hover,
        [data-theme="light"] .step-card:hover,
        [data-theme="light"] .testimonial-card:hover,
        [data-theme="light"] .pricing-card:hover,
        [data-theme="light"] .tech-card:hover {
            box-shadow: 0 15px 35px rgba(0, 0, 0, 0.15);
            transform: translateY(-5px);
        }

        /* Text Colors Light Mode */
        [data-theme="light"] .text-white {
            color: var(--light-text) !important;
        }

        [data-theme="light"] .text-muted {
            color: var(--light-muted) !important;
        }

        [data-theme="light"] .text-white-50 {
            color: var(--light-muted) !important;
        }

        [data-theme="light"] .text-light {
            color: var(--light-text) !important;
        }

        [data-theme="light"] .lead {
            color: var(--light-muted) !important;
        }

        /* Section Badges Light Mode */
        [data-theme="light"] .section-badge {
            background: rgba(0, 212, 170, 0.15) !important;
            border: 1px solid rgba(0, 212, 170, 0.3);
            color: var(--primary) !important;
            backdrop-filter: blur(10px);
        }

        /* Accordion Light Mode */
        [data-theme="light"] .accordion-item {
            background: var(--light-card) !important;
            border: 1px solid var(--light-border) !important;
        }

        [data-theme="light"] .accordion-button {
            background: var(--light-card) !important;
            color: var(--light-text) !important;
        }

        [data-theme="light"] .accordion-button:not(.collapsed) {
            background: rgba(0, 212, 170, 0.1) !important;
            color: var(--primary) !important;
        }

        [data-theme="light"] .accordion-body {
            color: var(--light-muted);
        }

        /* Buttons Light Mode */
        [data-theme="light"] .btn-light {
            background: rgba(255, 255, 255, 0.9);
            border: 1px solid var(--light-border);
            color: var(--light-text);
            backdrop-filter: blur(10px);
        }

        [data-theme="light"] .btn-light:hover {
            background: var(--light-card);
            color: var(--light-text);
        }

        [data-theme="light"] .btn-dark {
            background: rgba(33, 37, 41, 0.9);
            border: 1px solid rgba(33, 37, 41, 0.2);
            color: white;
        }

        [data-theme="light"] .btn-dark:hover {
            background: rgba(33, 37, 41, 1);
            color: white;
        }

        [data-theme="light"] .btn-outline-light {
            border: 2px solid var(--light-border);
            color: var(--light-text);
        }

        [data-theme="light"] .btn-outline-light:hover {
            background: var(--light-text);
            color: var(--light-bg);
        }

        /* Social Links Light Mode */
        [data-theme="light"] .social-link {
            background: rgba(33, 37, 41, 0.1);
            color: var(--light-text);
        }

        [data-theme="light"] .social-link:hover {
            background: var(--primary);
            color: white;
            transform: translateY(-2px);
        }

        /* App Features Light Mode */
        [data-theme="light"] .app-features .d-flex {
            background: var(--light-card);
            border: 1px solid var(--light-border);
        }

        /* Feature Icon Wrapper Light Mode */
        [data-theme="light"] .feature-icon-wrapper {
            background: rgba(0, 212, 170, 0.15);
        }

        /* Popular Pricing Card Light Mode */
        [data-theme="light"] .popular-pricing-card {
            background: linear-gradient(135deg, var(--primary), var(--secondary)) !important;
            border: none !important;
        }

        /* Grayscale Logos Light Mode */
        [data-theme="light"] .grayscale {
            background: linear-gradient(45deg, #e9ecef, #dee2e6);
            opacity: 0.8;
        }

        /* Floating Cards in Integration Light Mode */
        [data-theme="light"] .floating-api-card,
        [data-theme="light"] .floating-webhook-card {
            background: var(--light-card);
            border: 1px solid var(--light-border);
            color: var(--light-text);
        }

        /* CTA Section Light Mode */
        [data-theme="light"] .cta-section {
            background: linear-gradient(135deg, var(--primary), var(--secondary)) !important;
        }

        /* Badges Light Mode */
        [data-theme="light"] .badge.bg-primary {
            background: rgba(0, 212, 170, 0.15) !important;
            color: var(--primary) !important;
            border: 1px solid rgba(0, 212, 170, 0.3);
        }

        [data-theme="light"] .badge.bg-success {
            background: rgba(40, 167, 69, 0.15) !important;
            color: #28a745 !important;
            border: 1px solid rgba(40, 167, 69, 0.3);
        }

        [data-theme="light"] .badge.bg-warning {
            background: rgba(255, 193, 7, 0.15) !important;
            color: #ffc107 !important;
            border: 1px solid rgba(255, 193, 7, 0.3);
        }

        [data-theme="light"] .badge.bg-info {
            background: rgba(23, 162, 184, 0.15) !important;
            color: #17a2b8 !important;
            border: 1px solid rgba(23, 162, 184, 0.3);
        }

        /* Integration Partners Badges Light Mode */
        [data-theme="light"] .integration-partners .badge {
            background: rgba(0, 212, 170, 0.1) !important;
            border: 1px solid rgba(0, 212, 170, 0.2);
        }

        /* Hero visual elements light mode */
        [data-theme="light"] .hero-image::before {
            background: url('data:image/svg+xml,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100"><circle cx="50" cy="50" r="2" fill="%23000" opacity="0.05"/></svg>') repeat;
        }

        /* Testimonial author light mode */
        [data-theme="light"] .testimonial-author h6 {
            color: var(--light-text) !important;
        }

        [data-theme="light"] .testimonial-author p {
            color: var(--light-muted) !important;
        }

        /* Platform features light mode */
        [data-theme="light"] .platform-features h5 {
            color: var(--light-text) !important;
        }

        [data-theme="light"] .platform-features p {
            color: var(--light-muted) !important;
        }

        /* Results in case studies light mode */
        [data-theme="light"] .results .text-white {
            color: var(--light-text) !important;
        }

        /* Team section light mode */
        [data-theme="light"] .team-card h4 {
            color: var(--light-text) !important;
        }

        [data-theme="light"] .impact-label {
            color: var(--light-text) !important;
        }

        /* Integration features light mode */
        [data-theme="light"] .integration-features h5 {
            color: var(--light-text) !important;
        }

        /* Mobile app features light mode */
        [data-theme="light"] .app-features .text-white {
            color: var(--light-text) !important;
        }

        /* Remove the old minimal light mode adjustments */
        /* All new comprehensive light mode styles above */

        /* Hero Section */
        .hero-section {
            min-height: 100vh;
            display: flex;
            align-items: center;
            position: relative;
            overflow: hidden;
            background: radial-gradient(ellipse at center, rgba(0, 212, 170, 0.1) 0%, transparent 70%);
            padding-top: 80px;
        }

        .hero-bg {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: radial-gradient(circle at 20% 80%, rgba(0, 212, 170, 0.15) 0%, transparent 50%), radial-gradient(circle at 80% 20%, rgba(9, 132, 227, 0.15) 0%, transparent 50%);
            animation: float 8s ease-in-out infinite;
        }

        @keyframes float {
            0%, 100% {
                transform: translateY(0px) rotate(0deg);
            }

            33% {
                transform: translateY(-20px) rotate(1deg);
            }

            66% {
                transform: translateY(10px) rotate(-1deg);
            }
        }

        .hero-badge .badge {
            background: rgba(255, 255, 255, 0.1) !important;
            backdrop-filter: blur(10px);
            border: 1px solid rgba(255, 255, 255, 0.2);
            color: var(--primary) !important;
        }

        .hero-title {
            font-size: 3.5rem;
            font-weight: 800;
            margin-bottom: 1.5rem;
            background: linear-gradient(45deg, var(--light), var(--primary), var(--secondary));
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            text-shadow: 0 0 30px rgba(255, 255, 255, 0.1);
        }

        .hero-subtitle {
            font-size: 1.2rem;
            opacity: 0.9;
            line-height: 1.6;
        }

        .btn-hero {
            background: linear-gradient(45deg, var(--primary), var(--secondary));
            border: none;
            padding: 1rem 2.5rem;
            border-radius: 50px;
            color: white;
            font-weight: 600;
            transition: all 0.3s ease;
        }

            .btn-hero:hover {
                transform: translateY(-3px);
                box-shadow: 0 15px 30px rgba(0, 212, 170, 0.4);
            }

        .btn-outline-hero {
            border: 2px solid var(--primary);
            color: var(--primary);
            background: transparent;
            padding: 1rem 2.5rem;
            border-radius: 50px;
            font-weight: 600;
            transition: all 0.3s ease;
        }

            .btn-outline-hero:hover {
                background: var(--primary);
                color: white;
                transform: translateY(-3px);
            }

        .floating-card {
            position: absolute;
            background: var(--card-bg);
            backdrop-filter: blur(10px);
            border: 1px solid var(--card-border);
            border-radius: 15px;
            padding: 1rem;
            display: flex;
            align-items: center;
            gap: 0.5rem;
            color: white;
            z-index: 2;
            animation: floatCard 6s ease-in-out infinite;
        }

        .card-1 {
            top: 20%;
            left: 10%;
            animation-delay: 0s;
        }

        .card-2 {
            top: 60%;
            right: 10%;
            animation-delay: 2s;
        }

        .card-3 {
            bottom: 20%;
            left: 20%;
            animation-delay: 4s;
        }

        @keyframes floatCard {
            0%, 100% {
                transform: translateY(0px) rotate(0deg);
            }

            50% {
                transform: translateY(-20px) rotate(5deg);
            }
        }

        .hero-image {
            background: linear-gradient(45deg, var(--primary), var(--secondary));
            height: 400px;
            width: 100%;
            border-radius: 20px;
            position: relative;
            overflow: hidden;
        }

            .hero-image::before {
                content: '';
                position: absolute;
                top: 0;
                left: 0;
                right: 0;
                bottom: 0;
                background: url('data:image/svg+xml,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100"><circle cx="50" cy="50" r="2" fill="white" opacity="0.1"/></svg>') repeat;
                animation: sparkle 4s linear infinite;
            }

        /* Stats Section */
        .stats-section {
            background: rgba(255, 255, 255, 0.03) !important;
            backdrop-filter: blur(10px);
        }

        .stat-card {
            background: var(--card-bg);
            border: 1px solid var(--card-border);
            border-radius: 15px;
            padding: 2rem;
            text-align: center;
            transition: all 0.3s ease;
            backdrop-filter: blur(10px);
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
        }

        /* Features Section */
        .features-section {
            background: rgba(255, 255, 255, 0.03) !important;
        }

        .section-badge {
            background: rgba(0, 212, 170, 0.1) !important;
            border: 1px solid rgba(0, 212, 170, 0.3);
            color: var(--primary) !important;
        }

        .feature-card {
            background: var(--card-bg);
            border: 1px solid var(--card-border);
            border-radius: 20px;
            padding: 2.5rem;
            transition: all 0.3s ease;
            backdrop-filter: blur(10px);
            height: 100%;
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

        /* How It Works Section */
        .how-it-works-section {
            background: rgba(255, 255, 255, 0.03) !important;
        }

        .step-card {
            background: var(--card-bg);
            border: 1px solid var(--card-border);
            border-radius: 20px;
            padding: 2rem;
            transition: all 0.3s ease;
            backdrop-filter: blur(10px);
            height: 100%;
        }

            .step-card:hover {
                transform: translateY(-5px);
                border-color: var(--primary);
            }

        .step-number {
            position: absolute;
            top: -20px;
            left: 50%;
            transform: translateX(-50%);
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

        .step-icon {
            font-size: 2.5rem;
            color: var(--primary);
            margin-bottom: 1rem;
        }

        /* Platform Section */
        .platform-section {
            background: rgba(255, 255, 255, 0.03) !important;
        }

        .feature-item {
            background: var(--card-bg);
            border: 1px solid var(--card-border);
            border-radius: 15px;
            padding: 1.5rem;
            transition: all 0.3s ease;
        }

            .feature-item:hover {
                border-color: var(--primary);
                transform: translateX(10px);
            }

        .feature-icon-wrapper {
            width: 50px;
            height: 50px;
            background: rgba(0, 212, 170, 0.1);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .platform-image {
            background: linear-gradient(45deg, var(--primary), var(--secondary));
            height: 400px;
            border-radius: 20px;
            position: relative;
            overflow: hidden;
        }

        /* Testimonials Section */
        .testimonials-section {
            background: rgba(255, 255, 255, 0.03) !important;
        }

        .testimonial-card {
            background: var(--card-bg);
            border: 1px solid var(--card-border);
            border-radius: 20px;
            padding: 2.5rem;
            transition: all 0.3s ease;
            backdrop-filter: blur(10px);
            height: 100%;
            position: relative;
        }

            .testimonial-card:hover {
                transform: translateY(-10px);
                border-color: var(--primary);
                box-shadow: 0 20px 40px rgba(0, 0, 0, 0.3);
            }

        .rating {
            color: var(--primary);
        }

        .author-avatar {
            width: 50px;
            height: 50px;
            background: linear-gradient(45deg, var(--primary), var(--secondary));
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 600;
            color: white;
        }

        /* Mobile App Section */
        .mobile-app-section {
            background: rgba(255, 255, 255, 0.03) !important;
        }

        .mobile-image {
            background: linear-gradient(45deg, var(--primary), var(--secondary));
            height: 500px;
            border-radius: 30px;
            position: relative;
            overflow: hidden;
        }

        .app-features .d-flex {
            background: var(--card-bg);
            border: 1px solid var(--card-border);
            border-radius: 10px;
            padding: 1rem;
            margin-bottom: 0.5rem;
        }

        /* Pricing Section */
        .pricing-section {
            background: rgba(255, 255, 255, 0.03) !important;
        }

        .pricing-card {
            background: var(--card-bg);
            border: 1px solid var(--card-border);
            border-radius: 20px;
            padding: 2.5rem;
            transition: all 0.3s ease;
            backdrop-filter: blur(10px);
            height: 100%;
        }

            .pricing-card:hover {
                transform: translateY(-10px);
                border-color: var(--primary);
            }

        .popular-pricing-card {
            background: linear-gradient(135deg, var(--primary), var(--secondary)) !important;
            border: none !important;
        }

        .popular-badge {
            background: var(--accent) !important;
            color: white !important;
        }

        .price {
            color: var(--primary) !important;
        }

        /* Partners Section */
        .partners-section {
            background: rgba(255, 255, 255, 0.03) !important;
        }

        .partner-logo {
            background: var(--card-bg);
            border: 1px solid var(--card-border);
            border-radius: 15px;
            height: 120px;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: all 0.3s ease;
        }

            .partner-logo:hover {
                transform: translateY(-5px);
                border-color: var(--primary);
            }

        .grayscale {
            background: linear-gradient(45deg, var(--primary), var(--secondary));
            opacity: 0.7;
        }

        /* FAQ Section */
        .faq-section {
            background: rgba(255, 255, 255, 0.03) !important;
        }

        .accordion-item {
            background: var(--card-bg);
            border: 1px solid var(--card-border) !important;
            border-radius: 10px !important;
            margin-bottom: 1rem;
        }

        .accordion-button {
            background: transparent !important;
            color: white !important;
            font-weight: 600;
        }

            .accordion-button:not(.collapsed) {
                background: rgba(0, 212, 170, 0.1) !important;
                color: var(--primary) !important;
            }

        .accordion-body {
            color: rgba(255, 255, 255, 0.8);
        }

        /* CTA Section */
        .cta-section {
            background: linear-gradient(135deg, var(--primary), var(--secondary)) !important;
        }

        /* Text Colors */
        .text-primary {
            color: var(--primary) !important;
        }

        .text-success {
            color: var(--primary) !important;
        }

        .text-warning {
            color: var(--accent) !important;
        }

        .text-info {
            color: var(--secondary) !important;
        }

        .text-muted {
            color: rgba(255, 255, 255, 0.6) !important;
        }

        .text-dark {
            color: white !important;
        }

        .text-white-50 {
            color: rgba(255, 255, 255, 0.7) !important;
        }

        /* Background Colors */
        .bg-white {
            background: var(--card-bg) !important;
        }

        .bg-light {
            background: rgba(255, 255, 255, 0.03) !important;
        }

        .bg-dark {
            background: rgba(255, 255, 255, 0.05) !important;
        }

        /* Button Styles */
        .btn-light {
            background: rgba(255, 255, 255, 0.1);
            border: 1px solid rgba(255, 255, 255, 0.2);
            color: white;
            backdrop-filter: blur(10px);
        }

            .btn-light:hover {
                background: rgba(255, 255, 255, 0.2);
                color: white;
            }

        .btn-outline-light {
            border: 2px solid rgba(255, 255, 255, 0.3);
            color: white;
        }

            .btn-outline-light:hover {
                background: white;
                color: var(--dark);
            }

        .btn-primary {
            background: var(--primary);
            border: none;
        }

        .btn-outline-primary {
            border: 2px solid var(--primary);
            color: var(--primary);
        }

            .btn-outline-primary:hover {
                background: var(--primary);
                color: white;
            }

        .btn-dark {
            background: rgba(255, 255, 255, 0.1);
            border: 1px solid rgba(255, 255, 255, 0.2);
            color: white;
        }

            .btn-dark:hover {
                background: rgba(255, 255, 255, 0.2);
                color: white;
            }

        /* Responsive */
        @media (max-width: 768px) {
            .hero-title {
                font-size: 2.5rem;
            }

            .floating-card {
                position: relative;
                margin: 1rem 0;
            }

            .card-1, .card-2, .card-3 {
                position: relative;
                top: auto;
                left: auto;
                right: auto;
                bottom: auto;
            }
        }

        .tech-card {
            background: var(--card-bg);
            border: 1px solid var(--card-border);
            transition: all 0.3s ease;
            backdrop-filter: blur(10px);
        }

            .tech-card:hover {
                transform: translateY(-10px);
                border-color: var(--primary);
                box-shadow: 0 20px 40px rgba(0, 0, 0, 0.3);
            }

        /* Impact Metrics */
        .impact-card {
            background: var(--card-bg);
            border: 1px solid var(--card-border);
            transition: all 0.3s ease;
            backdrop-filter: blur(10px);
        }

            .impact-card:hover {
                transform: translateY(-5px);
                border-color: var(--primary);
            }

        /* Case Studies */
        .case-study-card {
            background: var(--card-bg);
            border: 1px solid var(--card-border);
            transition: all 0.3s ease;
            backdrop-filter: blur(10px);
        }

            .case-study-card:hover {
                transform: translateY(-5px);
                border-color: var(--primary);
            }

        /* Team Section */
        .team-card {
            background: var(--card-bg);
            border: 1px solid var(--card-border);
            transition: all 0.3s ease;
            backdrop-filter: blur(10px);
        }

            .team-card:hover {
                transform: translateY(-5px);
                border-color: var(--primary);
            }

        .social-link {
            width: 35px;
            height: 35px;
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
                transform: translateY(-2px);
            }

        /* Awards Section */
        .award-card {
            background: var(--card-bg);
            border: 1px solid var(--card-border);
            transition: all 0.3s ease;
            backdrop-filter: blur(10px);
        }

            .award-card:hover {
                transform: translateY(-5px);
                border-color: var(--primary);
            }

        /* Integration Section */
        .integration-dashboard {
            position: relative;
            overflow: hidden;
        }

        .floating-api-card, .floating-webhook-card {
            animation: float 6s ease-in-out infinite;
        }

        @keyframes float {
            0%, 100% {
                transform: translateY(0px);
            }

            50% {
                transform: translateY(-10px);
            }
        }
    </style>

    <!-- Hero Section -->
    <section class="hero-section">
        <div class="hero-bg"></div>
        <div class="container">
            <div class="row align-items-center min-vh-100">
                <div class="col-lg-6">
                    <div class="hero-badge mb-3">
                        <span class="badge bg-white text-primary px-3 py-2 rounded-pill">
                            <i class="fas fa-star me-2"></i>Leading Waste Management Platform
                        </span>
                    </div>
                    <h1 class="hero-title">Smart Waste Management for <span class="text-warning">Sustainable Cities</span></h1>
                    <p class="hero-subtitle mb-4">Transform your community's waste management with our innovative platform that connects citizens, municipalities, and technology for a cleaner, greener future.</p>
                    <div class="d-flex flex-wrap gap-3">
                        <a href="ChooseApp.aspx" class="btn btn-hero">
                            <i class="fas fa-rocket me-2"></i>Launch Platform
                        </a>
                        <a href="About.aspx" class="btn btn-outline-hero">
                            <i class="fas fa-play-circle me-2"></i>Watch Demo
                        </a>
                    </div>
                    <div class="mt-4 d-flex gap-4 text-white-50">
                        <div class="d-flex align-items-center gap-2">
                            <i class="fas fa-check-circle text-success"></i>
                            <span>No Credit Card Required</span>
                        </div>
                        <div class="d-flex align-items-center gap-2">
                            <i class="fas fa-check-circle text-success"></i>
                            <span>Setup in 5 Minutes</span>
                        </div>
                    </div>
                </div>
                <div class="col-lg-6 text-center">
                    <div class="hero-visual position-relative">
                        <div class="floating-card card-1">
                            <i class="fas fa-recycle text-success"></i>
                            <span>Recycling</span>
                        </div>
                        <div class="floating-card card-2">
                            <i class="fas fa-chart-bar text-info"></i>
                            <span>Analytics</span>
                        </div>
                        <div class="floating-card card-3">
                            <i class="fas fa-users text-warning"></i>
                            <span>Community</span>
                        </div>
                        <div class="hero-image img-fluid rounded-3 shadow-lg"></div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Stats Section -->
    <section class="stats-section py-5">
        <div class="container">
            <div class="row g-4 text-center">
                <div class="col-md-3 col-6">
                    <div class="stat-card">
                        <div class="stat-number">2,847</div>
                        <p class="text-muted mb-0 fw-semibold">Active Users</p>
                        <div class="stat-trend text-success small">
                            <i class="fas fa-arrow-up me-1"></i>12% this month
                        </div>
                    </div>
                </div>
                <div class="col-md-3 col-6">
                    <div class="stat-card">
                        <div class="stat-number">1,234</div>
                        <p class="text-muted mb-0 fw-semibold">Pickups Completed</p>
                        <div class="stat-trend text-success small">
                            <i class="fas fa-arrow-up me-1"></i>8% this month
                        </div>
                    </div>
                </div>
                <div class="col-md-3 col-6">
                    <div class="stat-card">
                        <div class="stat-number">45.2T</div>
                        <p class="text-muted mb-0 fw-semibold">Waste Recycled</p>
                        <div class="stat-trend text-success small">
                            <i class="fas fa-arrow-up me-1"></i>15% this month
                        </div>
                    </div>
                </div>
                <div class="col-md-3 col-6">
                    <div class="stat-card">
                        <div class="stat-number">56,789</div>
                        <p class="text-muted mb-0 fw-semibold">Credits Earned</p>
                        <div class="stat-trend text-success small">
                            <i class="fas fa-arrow-up me-1"></i>22% this month
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Features Section -->
    <section class="features-section py-5">
        <div class="container">
            <div class="row text-center mb-5">
                <div class="col-lg-8 mx-auto">
                    <span class="section-badge px-3 py-2 rounded-pill mb-3">Why Choose Us</span>
                    <h2 class="fw-bold display-5 mb-3 text-white">Revolutionizing Waste Management</h2>
                    <p class="lead text-muted fs-6">Our comprehensive platform offers end-to-end solutions for modern waste management challenges with cutting-edge technology.</p>
                </div>
            </div>
            <div class="row g-4">
                <div class="col-lg-4 col-md-6">
                    <div class="feature-card text-center">
                        <div class="feature-icon mx-auto">
                            <i class="fas fa-mobile-alt"></i>
                        </div>
                        <h4 class="fw-bold mb-3 text-white">Mobile First Design</h4>
                        <p class="text-muted mb-3">Access our platform from any device with our responsive design and dedicated mobile applications for iOS and Android.</p>
                        <a href="#" class="btn btn-link text-primary text-decoration-none p-0">Learn More <i class="fas fa-arrow-right ms-1"></i>
                        </a>
                    </div>
                </div>
                <div class="col-lg-4 col-md-6">
                    <div class="feature-card text-center">
                        <div class="feature-icon mx-auto">
                            <i class="fas fa-chart-line"></i>
                        </div>
                        <h4 class="fw-bold mb-3 text-white">Real-time Analytics</h4>
                        <p class="text-muted mb-3">Monitor waste collection metrics, optimize routes, and make data-driven decisions with live insights and comprehensive dashboards.</p>
                        <a href="#" class="btn btn-link text-primary text-decoration-none p-0">Learn More <i class="fas fa-arrow-right ms-1"></i>
                        </a>
                    </div>
                </div>
                <div class="col-lg-4 col-md-6">
                    <div class="feature-card text-center">
                        <div class="feature-icon mx-auto">
                            <i class="fas fa-award"></i>
                        </div>
                        <h4 class="fw-bold mb-3 text-white">Smart Reward System</h4>
                        <p class="text-muted mb-3">Earn credits for sustainable practices and redeem them for discounts, rewards, and exclusive benefits in our partner network.</p>
                        <a href="#" class="btn btn-link text-primary text-decoration-none p-0">Learn More <i class="fas fa-arrow-right ms-1"></i>
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- How It Works Section -->
    <section class="how-it-works-section py-5">
        <div class="container">
            <div class="row text-center mb-5">
                <div class="col-lg-8 mx-auto">
                    <span class="section-badge bg-success bg-opacity-10 text-success px-3 py-2 rounded-pill mb-3">Simple Process</span>
                    <h2 class="fw-bold display-5 mb-3 text-white">How SoorGreen Works</h2>
                    <p class="lead text-muted fs-6">Get started in just four simple steps and transform your waste management experience.</p>
                </div>
            </div>
            <div class="row g-4">
                <div class="col-lg-3 col-md-6">
                    <div class="step-card text-center position-relative">
                        <div class="step-number">01</div>
                        <div class="step-icon mx-auto">
                            <i class="fas fa-user-plus"></i>
                        </div>
                        <h4 class="fw-bold mb-3 text-white">Sign Up</h4>
                        <p class="text-muted">Create your account in seconds and choose your role as a citizen, business, or municipality.</p>
                    </div>
                </div>
                <div class="col-lg-3 col-md-6">
                    <div class="step-card text-center position-relative">
                        <div class="step-number">02</div>
                        <div class="step-icon mx-auto">
                            <i class="fas fa-map-marker-alt"></i>
                        </div>
                        <h4 class="fw-bold mb-3 text-white">Set Location</h4>
                        <p class="text-muted">Add your location and preferences to get personalized waste management solutions.</p>
                    </div>
                </div>
                <div class="col-lg-3 col-md-6">
                    <div class="step-card text-center position-relative">
                        <div class="step-number">03</div>
                        <div class="step-icon mx-auto">
                            <i class="fas fa-calendar-alt"></i>
                        </div>
                        <h4 class="fw-bold mb-3 text-white">Schedule Pickup</h4>
                        <p class="text-muted">Schedule waste pickups at your convenience with our easy-to-use calendar system.</p>
                    </div>
                </div>
                <div class="col-lg-3 col-md-6">
                    <div class="step-card text-center position-relative">
                        <div class="step-number">04</div>
                        <div class="step-icon mx-auto">
                            <i class="fas fa-trophy"></i>
                        </div>
                        <h4 class="fw-bold mb-3 text-white">Earn Rewards</h4>
                        <p class="text-muted">Get rewarded for your eco-friendly practices and track your environmental impact.</p>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Platform Showcase Section -->
    <section class="platform-section py-5">
        <div class="container">
            <div class="row align-items-center">
                <div class="col-lg-6">
                    <span class="section-badge bg-warning bg-opacity-20 text-warning px-3 py-2 rounded-pill mb-3">Our Platform</span>
                    <h2 class="fw-bold display-5 mb-4 text-white">All-in-One Waste Management Solution</h2>
                    <p class="lead mb-4 text-muted">Experience the power of our integrated platform designed for citizens, businesses, and municipalities.</p>

                    <div class="platform-features">
                        <div class="feature-item d-flex align-items-start mb-4">
                            <div class="feature-icon-wrapper me-4">
                                <i class="fas fa-users text-primary"></i>
                            </div>
                            <div>
                                <h5 class="fw-bold text-white">Citizen Portal</h5>
                                <p class="text-light mb-0">Easy waste scheduling and reward tracking for residents.</p>
                            </div>
                        </div>
                        <div class="feature-item d-flex align-items-start mb-4">
                            <div class="feature-icon-wrapper me-4">
                                <i class="fas fa-building text-success"></i>
                            </div>
                            <div>
                                <h5 class="fw-bold text-white">Business Dashboard</h5>
                                <p class="text-light mb-0">Comprehensive waste management for commercial establishments.</p>
                            </div>
                        </div>
                        <div class="feature-item d-flex align-items-start mb-4">
                            <div class="feature-icon-wrapper me-4">
                                <i class="fas fa-city text-info"></i>
                            </div>
                            <div>
                                <h5 class="fw-bold text-white">Municipal Control</h5>
                                <p class="text-light mb-0">Advanced tools for city-wide waste management optimization.</p>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-lg-6 text-center">
                    <div class="platform-showcase position-relative">
                        <div class="platform-image img-fluid rounded-3 shadow"></div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Testimonials Section -->
    <section class="testimonials-section py-5">
        <div class="container">
            <div class="row text-center mb-5">
                <div class="col-lg-8 mx-auto">
                    <span class="section-badge bg-info bg-opacity-10 text-info px-3 py-2 rounded-pill mb-3">Testimonials</span>
                    <h2 class="fw-bold display-5 mb-3 text-white">What Our Users Say</h2>
                    <p class="lead text-muted fs-6">Join thousands of satisfied users who have transformed their waste management experience.</p>
                </div>
            </div>
            <div class="row g-4">
                <div class="col-lg-4 col-md-6">
                    <div class="testimonial-card">
                        <div class="rating mb-3">
                            <i class="fas fa-star"></i>
                            <i class="fas fa-star"></i>
                            <i class="fas fa-star"></i>
                            <i class="fas fa-star"></i>
                            <i class="fas fa-star"></i>
                        </div>
                        <p class="testimonial-text mb-4 text-muted">"SoorGreen has completely transformed how our community handles waste. The reward system keeps everyone motivated!"</p>
                        <div class="testimonial-author d-flex align-items-center">
                            <div class="author-avatar me-3">SJ</div>
                            <div>
                                <h6 class="fw-bold mb-1 text-white">Sarah Johnson</h6>
                                <p class="text-muted mb-0 small">Community Leader</p>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-lg-4 col-md-6">
                    <div class="testimonial-card">
                        <div class="rating mb-3">
                            <i class="fas fa-star"></i>
                            <i class="fas fa-star"></i>
                            <i class="fas fa-star"></i>
                            <i class="fas fa-star"></i>
                            <i class="fas fa-star"></i>
                        </div>
                        <p class="testimonial-text mb-4 text-muted">"As a business owner, the analytics have helped us reduce waste costs by 30%. Incredible platform!"</p>
                        <div class="testimonial-author d-flex align-items-center">
                            <div class="author-avatar me-3">MC</div>
                            <div>
                                <h6 class="fw-bold mb-1 text-white">Mike Chen</h6>
                                <p class="text-muted mb-0 small">Restaurant Owner</p>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-lg-4 col-md-6">
                    <div class="testimonial-card">
                        <div class="rating mb-3">
                            <i class="fas fa-star"></i>
                            <i class="fas fa-star"></i>
                            <i class="fas fa-star"></i>
                            <i class="fas fa-star"></i>
                            <i class="fas fa-star"></i>
                        </div>
                        <p class="testimonial-text mb-4 text-muted">"The municipal dashboard has streamlined our operations and improved service delivery across the city."</p>
                        <div class="testimonial-author d-flex align-items-center">
                            <div class="author-avatar me-3">AH</div>
                            <div>
                                <h6 class="fw-bold mb-1 text-white">Dr. Amina Hassan</h6>
                                <p class="text-muted mb-0 small">City Administrator</p>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Mobile App Section -->
    <section class="mobile-app-section py-5">
        <div class="container">
            <div class="row align-items-center">
                <div class="col-lg-6 text-center">
                    <div class="mobile-showcase position-relative">
                        <div class="mobile-image"></div>
                    </div>
                </div>
                <div class="col-lg-6">
                    <span class="section-badge bg-primary bg-opacity-10 text-primary px-3 py-2 rounded-pill mb-3">Mobile App</span>
                    <h2 class="fw-bold display-5 mb-4 text-white">Manage Waste On The Go</h2>
                    <p class="lead mb-4 text-muted">Download our mobile app for iOS and Android to schedule pickups, track rewards, and stay connected with your waste management needs.</p>

                    <div class="app-features mb-4">
                        <div class="row g-3">
                            <div class="col-6">
                                <div class="d-flex align-items-center">
                                    <i class="fas fa-bell text-success me-3"></i>
                                    <span class="text-white">Smart Notifications</span>
                                </div>
                            </div>
                            <div class="col-6">
                                <div class="d-flex align-items-center">
                                    <i class="fas fa-map text-info me-3"></i>
                                    <span class="text-white">Live Tracking</span>
                                </div>
                            </div>
                            <div class="col-6">
                                <div class="d-flex align-items-center">
                                    <i class="fas fa-qrcode text-warning me-3"></i>
                                    <span class="text-white">QR Code Scanning</span>
                                </div>
                            </div>
                            <div class="col-6">
                                <div class="d-flex align-items-center">
                                    <i class="fas fa-chart-pie text-danger me-3"></i>
                                    <span class="text-white">Progress Tracking</span>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="app-download-buttons d-flex gap-3">
                        <a href="#" class="btn btn-dark btn-lg px-4">
                            <i class="fab fa-apple me-2"></i>App Store
                        </a>
                        <a href="#" class="btn btn-dark btn-lg px-4">
                            <i class="fab fa-google-play me-2"></i>Google Play
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Pricing Section -->
    <section class="pricing-section py-5">
        <div class="container">
            <div class="row text-center mb-5">
                <div class="col-lg-8 mx-auto">
                    <span class="section-badge bg-success bg-opacity-10 text-success px-3 py-2 rounded-pill mb-3">Pricing</span>
                    <h2 class="fw-bold display-5 mb-3 text-white">Simple, Transparent Pricing</h2>
                    <p class="lead text-muted fs-6">Choose the plan that works best for your needs. All plans include core features.</p>
                </div>
            </div>
            <div class="row g-4 justify-content-center">
                <div class="col-lg-4 col-md-6">
                    <div class="pricing-card text-center h-100">
                        <div class="pricing-header mb-4">
                            <h4 class="fw-bold text-primary">Basic</h4>
                            <div class="price display-4 fw-bold">$0</div>
                            <p class="text-muted">Forever free</p>
                        </div>
                        <ul class="list-unstyled mb-4">
                            <li class="mb-2"><i class="fas fa-check text-success me-2"></i>Basic waste scheduling</li>
                            <li class="mb-2"><i class="fas fa-check text-success me-2"></i>Community access</li>
                            <li class="mb-2"><i class="fas fa-check text-success me-2"></i>Email support</li>
                            <li class="mb-2 text-muted"><i class="fas fa-times me-2"></i>Advanced analytics</li>
                            <li class="mb-2 text-muted"><i class="fas fa-times me-2"></i>Priority support</li>
                        </ul>
                        <a href="#" class="btn btn-outline-primary w-100">Get Started</a>
                    </div>
                </div>
                <div class="col-lg-4 col-md-6">
                    <div class="pricing-card popular-pricing-card p-4 rounded-3 shadow-lg position-relative h-100">
                        <div class="popular-badge position-absolute top-0 start-50 translate-middle px-3 py-1 rounded-pill small fw-bold">MOST POPULAR</div>
                        <div class="pricing-header mb-4">
                            <h4 class="fw-bold text-white">Pro</h4>
                            <div class="price display-4 fw-bold text-white">$29</div>
                            <p class="text-white">per month</p>
                        </div>
                        <ul class="list-unstyled mb-4 text-white">
                            <li class="mb-2"><i class="fas fa-check me-2"></i>All Basic features</li>
                            <li class="mb-2"><i class="fas fa-check me-2"></i>Advanced analytics</li>
                            <li class="mb-2"><i class="fas fa-check me-2"></i>Priority support</li>
                            <li class="mb-2"><i class="fas fa-check me-2"></i>Custom reporting</li>
                            <li class="mb-2"><i class="fas fa-check me-2"></i>API access</li>
                        </ul>
                        <a href="#" class="btn btn-light w-100 fw-bold">Get Started</a>
                    </div>
                </div>
                <div class="col-lg-4 col-md-6">
                    <div class="pricing-card text-center h-100">
                        <div class="pricing-header mb-4">
                            <h4 class="fw-bold text-primary">Enterprise</h4>
                            <div class="price display-4 fw-bold">$99</div>
                            <p class="text-muted">per month</p>
                        </div>
                        <ul class="list-unstyled mb-4">
                            <li class="mb-2"><i class="fas fa-check text-success me-2"></i>All Pro features</li>
                            <li class="mb-2"><i class="fas fa-check text-success me-2"></i>White-label solution</li>
                            <li class="mb-2"><i class="fas fa-check text-success me-2"></i>Dedicated account manager</li>
                            <li class="mb-2"><i class="fas fa-check text-success me-2"></i>Custom integrations</li>
                            <li class="mb-2"><i class="fas fa-check text-success me-2"></i>SLA guarantee</li>
                        </ul>
                        <a href="#" class="btn btn-outline-primary w-100">Contact Sales</a>
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
                    <span class="section-badge bg-info bg-opacity-10 text-info px-3 py-2 rounded-pill mb-3">Partners</span>
                    <h2 class="fw-bold display-5 mb-3 text-white">Trusted by Industry Leaders</h2>
                    <p class="lead text-muted fs-6">We partner with leading organizations to deliver the best waste management solutions.</p>
                </div>
            </div>
            <div class="row g-4 align-items-center justify-content-center">
                <div class="col-6 col-md-4 col-lg-2 text-center">
                    <div class="partner-logo grayscale"></div>
                </div>
                <div class="col-6 col-md-4 col-lg-2 text-center">
                    <div class="partner-logo grayscale"></div>
                </div>
                <div class="col-6 col-md-4 col-lg-2 text-center">
                    <div class="partner-logo grayscale"></div>
                </div>
                <div class="col-6 col-md-4 col-lg-2 text-center">
                    <div class="partner-logo grayscale"></div>
                </div>
                <div class="col-6 col-md-4 col-lg-2 text-center">
                    <div class="partner-logo grayscale"></div>
                </div>
                <div class="col-6 col-md-4 col-lg-2 text-center">
                    <div class="partner-logo grayscale"></div>
                </div>
            </div>
        </div>
    </section>

    <!-- FAQ Section -->
    <section class="faq-section py-5">
        <div class="container">
            <div class="row text-center mb-5">
                <div class="col-lg-8 mx-auto">
                    <span class="section-badge bg-warning bg-opacity-10 text-warning px-3 py-2 rounded-pill mb-3">FAQ</span>
                    <h2 class="fw-bold display-5 mb-3 text-white">Frequently Asked Questions</h2>
                    <p class="lead text-muted fs-6">Get answers to common questions about our platform and services.</p>
                </div>
            </div>
            <div class="row justify-content-center">
                <div class="col-lg-8">
                    <div class="accordion" id="faqAccordion">
                        <div class="accordion-item">
                            <h2 class="accordion-header">
                                <button class="accordion-button fw-semibold" type="button" data-bs-toggle="collapse" data-bs-target="#faq1">
                                    How do I schedule a waste pickup?
                                </button>
                            </h2>
                            <div id="faq1" class="accordion-collapse collapse show" data-bs-parent="#faqAccordion">
                                <div class="accordion-body">
                                    Simply log into your account, go to the Schedule Pickup section, choose your preferred date and time, and confirm your request. You'll receive a confirmation notification.
                                </div>
                            </div>
                        </div>
                        <div class="accordion-item">
                            <h2 class="accordion-header">
                                <button class="accordion-button collapsed fw-semibold" type="button" data-bs-toggle="collapse" data-bs-target="#faq2">
                                    How does the reward system work?
                                </button>
                            </h2>
                            <div id="faq2" class="accordion-collapse collapse" data-bs-parent="#faqAccordion">
                                <div class="accordion-body">
                                    You earn credits for every successful waste pickup, recycling activity, and community participation. These credits can be redeemed for discounts, gift cards, and exclusive rewards from our partner network.
                                </div>
                            </div>
                        </div>
                        <div class="accordion-item">
                            <h2 class="accordion-header">
                                <button class="accordion-button collapsed fw-semibold" type="button" data-bs-toggle="collapse" data-bs-target="#faq3">
                                    Is my data secure?
                                </button>
                            </h2>
                            <div id="faq3" class="accordion-collapse collapse" data-bs-parent="#faqAccordion">
                                <div class="accordion-body">
                                    Yes, we use enterprise-grade security measures including encryption, secure servers, and regular security audits to protect your data and privacy.
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Technology Stack Section -->
    <section class="tech-stack-section py-5">
        <div class="container">
            <div class="row text-center mb-5">
                <div class="col-lg-8 mx-auto">
                    <span class="section-badge bg-primary bg-opacity-10 text-primary px-3 py-2 rounded-pill mb-3">Technology</span>
                    <h2 class="fw-bold display-5 mb-3 text-white">Built with Modern Technology</h2>
                    <p class="lead text-muted fs-6">Powered by cutting-edge technologies for performance, security, and scalability.</p>
                </div>
            </div>
            <div class="row g-4">
                <div class="col-lg-3 col-md-6">
                    <div class="tech-card text-center p-4 rounded-3">
                        <div class="tech-icon mb-3">
                            <i class="fab fa-microsoft fa-3x text-primary"></i>
                        </div>
                        <h4 class="fw-bold text-white mb-2">ASP.NET Core</h4>
                        <p class="text-muted mb-0">High-performance web framework for modern applications</p>
                    </div>
                </div>
                <div class="col-lg-3 col-md-6">
                    <div class="tech-card text-center p-4 rounded-3">
                        <div class="tech-icon mb-3">
                            <i class="fas fa-database fa-3x text-success"></i>
                        </div>
                        <h4 class="fw-bold text-white mb-2">SQL Server</h4>
                        <p class="text-muted mb-0">Enterprise-grade database for reliable data storage</p>
                    </div>
                </div>
                <div class="col-lg-3 col-md-6">
                    <div class="tech-card text-center p-4 rounded-3">
                        <div class="tech-icon mb-3">
                            <i class="fab fa-js-square fa-3x text-warning"></i>
                        </div>
                        <h4 class="fw-bold text-white mb-2">JavaScript</h4>
                        <p class="text-muted mb-0">Interactive frontend with modern frameworks</p>
                    </div>
                </div>
                <div class="col-lg-3 col-md-6">
                    <div class="tech-card text-center p-4 rounded-3">
                        <div class="tech-icon mb-3">
                            <i class="fab fa-microsoft fa-3x text-info"></i>
                        </div>
                        <h4 class="fw-bold text-white mb-2">Azure Cloud</h4>
                        <p class="text-muted mb-0">Scalable cloud infrastructure for global reach</p>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Impact Metrics Section -->
    <section class="impact-section py-5">
        <div class="container">
            <div class="row text-center mb-5">
                <div class="col-lg-8 mx-auto">
                    <span class="section-badge bg-success bg-opacity-10 text-success px-3 py-2 rounded-pill mb-3">Environmental Impact</span>
                    <h2 class="fw-bold display-5 mb-3 text-white">Making a Real Difference</h2>
                    <p class="lead text-muted fs-6">See the tangible environmental impact we've created together with our community.</p>
                </div>
            </div>
            <div class="row g-4">
                <div class="col-md-6 col-lg-3">
                    <div class="impact-card text-center p-4 rounded-3">
                        <div class="impact-icon mb-3">
                            <i class="fas fa-tree fa-3x text-success"></i>
                        </div>
                        <h3 class="impact-number text-primary fw-bold display-4">12,847</h3>
                        <p class="impact-label text-white fw-semibold">Trees Saved</p>
                        <p class="text-muted small">Equivalent to 52 acres of forest</p>
                    </div>
                </div>
                <div class="col-md-6 col-lg-3">
                    <div class="impact-card text-center p-4 rounded-3">
                        <div class="impact-icon mb-3">
                            <i class="fas fa-car fa-3x text-warning"></i>
                        </div>
                        <h3 class="impact-number text-primary fw-bold display-4">8,456</h3>
                        <p class="impact-label text-white fw-semibold">Cars Off Road</p>
                        <p class="text-muted small">Carbon emissions reduced</p>
                    </div>
                </div>
                <div class="col-md-6 col-lg-3">
                    <div class="impact-card text-center p-4 rounded-3">
                        <div class="impact-icon mb-3">
                            <i class="fas fa-tint fa-3x text-info"></i>
                        </div>
                        <h3 class="impact-number text-primary fw-bold display-4">2.3M</h3>
                        <p class="impact-label text-white fw-semibold">Liters of Water</p>
                        <p class="text-muted small">Water conservation achieved</p>
                    </div>
                </div>
                <div class="col-md-6 col-lg-3">
                    <div class="impact-card text-center p-4 rounded-3">
                        <div class="impact-icon mb-3">
                            <i class="fas fa-bolt fa-3x text-primary"></i>
                        </div>
                        <h3 class="impact-number text-primary fw-bold display-4">456K</h3>
                        <p class="impact-label text-white fw-semibold">kWh Energy Saved</p>
                        <p class="text-muted small">Powering 400 homes for a month</p>
                    </div>
                </div>
            </div>
        </div>
    </section>
    <!-- Case Studies Section -->
    <section class="case-studies-section py-5">
        <div class="container">
            <div class="row text-center mb-5">
                <div class="col-lg-8 mx-auto">
                    <span class="section-badge bg-info bg-opacity-10 text-info px-3 py-2 rounded-pill mb-3">Success Stories</span>
                    <h2 class="fw-bold display-5 mb-3 text-white">Real World Impact</h2>
                    <p class="lead text-muted fs-6">Discover how cities and communities are transforming their waste management.</p>
                </div>
            </div>
            <div class="row g-4">
                <div class="col-lg-4">
                    <div class="case-study-card rounded-3 overflow-hidden">
                        <div class="case-study-image" style="background: linear-gradient(45deg, var(--primary), var(--secondary)); height: 200px;"></div>
                        <div class="case-study-content p-4">
                            <span class="badge bg-primary mb-2">Municipality</span>
                            <h4 class="fw-bold text-white mb-3">Green City Transformation</h4>
                            <p class="text-muted mb-3">How Green Valley reduced landfill waste by 65% in 12 months using our platform.</p>
                            <div class="results">
                                <div class="result-item d-flex justify-content-between mb-2">
                                    <span class="text-white">Waste Reduction</span>
                                    <span class="text-primary fw-bold">65%</span>
                                </div>
                                <div class="result-item d-flex justify-content-between mb-2">
                                    <span class="text-white">Cost Savings</span>
                                    <span class="text-primary fw-bold">$120K</span>
                                </div>
                                <div class="result-item d-flex justify-content-between">
                                    <span class="text-white">Community Participation</span>
                                    <span class="text-primary fw-bold">89%</span>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="case-study-card rounded-3 overflow-hidden">
                        <div class="case-study-image" style="background: linear-gradient(45deg, var(--success), var(--primary)); height: 200px;"></div>
                        <div class="case-study-content p-4">
                            <span class="badge bg-success mb-2">Business</span>
                            <h4 class="fw-bold text-white mb-3">Restaurant Chain Success</h4>
                            <p class="text-muted mb-3">How FoodCorp achieved 80% recycling rate across 50+ locations.</p>
                            <div class="results">
                                <div class="result-item d-flex justify-content-between mb-2">
                                    <span class="text-white">Recycling Rate</span>
                                    <span class="text-success fw-bold">80%</span>
                                </div>
                                <div class="result-item d-flex justify-content-between mb-2">
                                    <span class="text-white">Operational Savings</span>
                                    <span class="text-success fw-bold">$75K/year</span>
                                </div>
                                <div class="result-item d-flex justify-content-between">
                                    <span class="text-white">Customer Satisfaction</span>
                                    <span class="text-success fw-bold">+25%</span>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="case-study-card rounded-3 overflow-hidden">
                        <div class="case-study-image" style="background: linear-gradient(45deg, var(--warning), var(--accent)); height: 200px;"></div>
                        <div class="case-study-content p-4">
                            <span class="badge bg-warning mb-2">Community</span>
                            <h4 class="fw-bold text-white mb-3">Neighborhood Revolution</h4>
                            <p class="text-muted mb-3">How Riverside Community increased recycling participation from 30% to 85%.</p>
                            <div class="results">
                                <div class="result-item d-flex justify-content-between mb-2">
                                    <span class="text-white">Participation Rate</span>
                                    <span class="text-warning fw-bold">85%</span>
                                </div>
                                <div class="result-item d-flex justify-content-between mb-2">
                                    <span class="text-white">Rewards Distributed</span>
                                    <span class="text-warning fw-bold">$45K</span>
                                </div>
                                <div class="result-item d-flex justify-content-between">
                                    <span class="text-white">Cleanliness Score</span>
                                    <span class="text-warning fw-bold">9.2/10</span>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>
    <!-- Team Section -->
    <section class="team-section py-5">
        <div class="container">
            <div class="row text-center mb-5">
                <div class="col-lg-8 mx-auto">
                    <span class="section-badge bg-warning bg-opacity-10 text-warning px-3 py-2 rounded-pill mb-3">Our Team</span>
                    <h2 class="fw-bold display-5 mb-3 text-white">Meet the Visionaries</h2>
                    <p class="lead text-muted fs-6">Passionate experts dedicated to revolutionizing waste management through technology.</p>
                </div>
            </div>
            <div class="row g-4">

                <!-- Team Member 1 -->
                <div class="col-lg-4 col-md-6">
                    <div class="team-card text-center p-4 rounded-3">
                        <div class="team-avatar mx-auto mb-3">
                            <div class="avatar-placeholder bg-primary rounded-circle d-flex align-items-center justify-content-center text-white fw-bold" style="width: 100px; height: 100px;">ZO</div>
                        </div>
                        <h4 class="fw-bold text-white mb-1">ZACKI ABDULKADIR OMER</h4>
                        <p class="text-primary mb-2">Project Lead</p>
                        <p class="text-muted small mb-3">Innovative strategist passionate about modernizing waste management systems.</p>
                        <div class="social-links d-flex justify-content-center gap-2">
                            <a href="#" class="social-link"><i class="fab fa-linkedin"></i></a>
                            <a href="#" class="social-link"><i class="fas fa-envelope"></i></a>
                        </div>
                    </div>
                </div>

                <!-- Team Member 2 -->
                <div class="col-lg-4 col-md-6">
                    <div class="team-card text-center p-4 rounded-3">
                        <div class="team-avatar mx-auto mb-3">
                            <div class="avatar-placeholder bg-success rounded-circle d-flex align-items-center justify-content-center text-white fw-bold" style="width: 100px; height: 100px;">AO</div>
                        </div>
                        <h4 class="fw-bold text-white mb-1">ARAFAT OSMAN ADEN</h4>
                        <p class="text-primary mb-2">Lead Developer</p>
                        <p class="text-muted small mb-3">Full-stack developer building efficient and scalable smart-waste applications.</p>
                        <div class="social-links d-flex justify-content-center gap-2">
                            <a href="#" class="social-link"><i class="fab fa-linkedin"></i></a>
                            <a href="#" class="social-link"><i class="fab fa-github"></i></a>
                            <a href="#" class="social-link"><i class="fas fa-envelope"></i></a>
                        </div>
                    </div>
                </div>

                <!-- Team Member 3 -->
                <div class="col-lg-4 col-md-6">
                    <div class="team-card text-center p-4 rounded-3">
                        <div class="team-avatar mx-auto mb-3">
                            <div class="avatar-placeholder bg-info rounded-circle d-flex align-items-center justify-content-center text-white fw-bold" style="width: 100px; height: 100px;">AD</div>
                        </div>
                        <h4 class="fw-bold text-white mb-1">ARFAT</h4>
                        <p class="text-primary mb-2">System Engineer</p>
                        <p class="text-muted small mb-3">Focused on IoT and automation solutions that improve data accuracy and efficiency.</p>
                        <div class="social-links d-flex justify-content-center gap-2">
                            <a href="#" class="social-link"><i class="fab fa-linkedin"></i></a>
                            <a href="#" class="social-link"><i class="fas fa-envelope"></i></a>
                        </div>
                    </div>
                </div>

            </div>
        </div>
    </section>

    <!-- Awards Section -->
    <section class="awards-section py-5">
        <div class="container">
            <div class="row text-center mb-5">
                <div class="col-lg-8 mx-auto">
                    <span class="section-badge bg-primary bg-opacity-10 text-primary px-3 py-2 rounded-pill mb-3">Recognition</span>
                    <h2 class="fw-bold display-5 mb-3 text-white">Awards & Recognition</h2>
                    <p class="lead text-muted fs-6">Celebrating our achievements in sustainability and innovation.</p>
                </div>
            </div>
            <div class="row g-4">
                <div class="col-md-6 col-lg-3">
                    <div class="award-card text-center p-4 rounded-3">
                        <div class="award-icon mb-3">
                            <i class="fas fa-trophy fa-3x text-warning"></i>
                        </div>
                        <h4 class="fw-bold text-white mb-2">Green Tech Award 2024</h4>
                        <p class="text-muted mb-0">Best Sustainable Technology Solution</p>
                        <span class="badge bg-primary mt-2">International</span>
                    </div>
                </div>
                <div class="col-md-6 col-lg-3">
                    <div class="award-card text-center p-4 rounded-3">
                        <div class="award-icon mb-3">
                            <i class="fas fa-award fa-3x text-primary"></i>
                        </div>
                        <h4 class="fw-bold text-white mb-2">Innovation Excellence</h4>
                        <p class="text-muted mb-0">Top 10 Most Innovative Startups</p>
                        <span class="badge bg-success mt-2">National</span>
                    </div>
                </div>
                <div class="col-md-6 col-lg-3">
                    <div class="award-card text-center p-4 rounded-3">
                        <div class="award-icon mb-3">
                            <i class="fas fa-medal fa-3x text-info"></i>
                        </div>
                        <h4 class="fw-bold text-white mb-2">Sustainability Leader</h4>
                        <p class="text-muted mb-0">Environmental Impact Award 2023</p>
                        <span class="badge bg-warning mt-2">Regional</span>
                    </div>
                </div>
                <div class="col-md-6 col-lg-3">
                    <div class="award-card text-center p-4 rounded-3">
                        <div class="award-icon mb-3">
                            <i class="fas fa-star fa-3x text-success"></i>
                        </div>
                        <h4 class="fw-bold text-white mb-2">Community Choice</h4>
                        <p class="text-muted mb-0">Best Community Platform 2024</p>
                        <span class="badge bg-info mt-2">People's Choice</span>
                    </div>
                </div>
            </div>
        </div>
    </section>
    <!-- Integration Section -->
    <section class="integration-section py-5">
        <div class="container">
            <div class="row align-items-center">
                <div class="col-lg-6">
                    <span class="section-badge bg-success bg-opacity-10 text-success px-3 py-2 rounded-pill mb-3">Integrations</span>
                    <h2 class="fw-bold display-5 mb-4 text-white">Seamless Integration with Your Systems</h2>
                    <p class="lead mb-4 text-muted">Connect SoorGreen with your existing tools and platforms for a unified waste management experience.</p>

                    <div class="integration-features">
                        <div class="feature-item d-flex align-items-start mb-4">
                            <div class="feature-icon-wrapper me-4">
                                <i class="fas fa-plug text-primary"></i>
                            </div>
                            <div>
                                <h5 class="fw-bold text-white">API First</h5>
                                <p class="text-muted mb-0">RESTful APIs for easy integration with any system</p>
                            </div>
                        </div>
                        <div class="feature-item d-flex align-items-start mb-4">
                            <div class="feature-icon-wrapper me-4">
                                <i class="fas fa-shield-alt text-success"></i>
                            </div>
                            <div>
                                <h5 class="fw-bold text-white">Enterprise Security</h5>
                                <p class="text-muted mb-0">Bank-level security with OAuth2 and SSL encryption</p>
                            </div>
                        </div>
                        <div class="feature-item d-flex align-items-start mb-4">
                            <div class="feature-icon-wrapper me-4">
                                <i class="fas fa-sync text-info"></i>
                            </div>
                            <div>
                                <h5 class="fw-bold text-white">Real-time Sync</h5>
                                <p class="text-muted mb-0">Live data synchronization across all platforms</p>
                            </div>
                        </div>
                    </div>

                    <div class="integration-partners mt-5">
                        <h6 class="text-white fw-semibold mb-3">Compatible with:</h6>
                        <div class="d-flex flex-wrap gap-3">
                            <span class="badge bg-primary bg-opacity-20 text-primary px-3 py-2">Municipal Systems</span>
                            <span class="badge bg-success bg-opacity-20 text-success px-3 py-2">ERP Software</span>
                            <span class="badge bg-info bg-opacity-20 text-info px-3 py-2">Payment Gateways</span>
                            <span class="badge bg-warning bg-opacity-20 text-warning px-3 py-2">CRM Platforms</span>
                        </div>
                    </div>
                </div>
                <div class="col-lg-6 text-center">
                    <div class="integration-visual position-relative">
                        <div class="integration-dashboard rounded-3 shadow-lg" style="background: linear-gradient(135deg, var(--primary), var(--secondary)); height: 400px;"></div>
                        <div class="floating-api-card" style="position: absolute; top: 20%; right: -20px; background: var(--card-bg); border: 1px solid var(--card-border); padding: 1rem; border-radius: 10px; backdrop-filter: blur(10px);">
                            <i class="fas fa-code text-primary me-2"></i>
                            <span>API Endpoints</span>
                        </div>
                        <div class="floating-webhook-card" style="position: absolute; bottom: 30%; left: -20px; background: var(--card-bg); border: 1px solid var(--card-border); padding: 1rem; border-radius: 10px; backdrop-filter: blur(10px);">
                            <i class="fas fa-bell text-success me-2"></i>
                            <span>Webhooks</span>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- CTA Section -->
    <section class="cta-section py-5">
        <div class="container">
            <div class="row align-items-center text-center text-lg-start">
                <div class="col-lg-8">
                    <h2 class="fw-bold display-5 mb-3 text-white">Ready to Transform Your Waste Management?</h2>
                    <p class="lead mb-4 text-white-75">Join thousands of users already making a difference in their communities. Start your journey today!</p>
                </div>
                <div class="col-lg-4 text-lg-end">
                    <a href="ChooseApp.aspx" class="btn btn-light btn-lg px-4 py-3 fw-bold">
                        <i class="fas fa-play me-2"></i>Get Started Today
                    </a>
                </div>
            </div>
        </div>
    </section>

    <script>
        // Add AOS animations
        document.addEventListener('DOMContentLoaded', function () {
            // Initialize AOS if available
            if (typeof AOS !== 'undefined') {
                AOS.init({
                    duration: 1000,
                    once: true
                });
            }

            // Add scroll animations
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

            // Observe all cards and sections
            document.querySelectorAll('.stat-card, .feature-card, .step-card, .testimonial-card, .pricing-card').forEach(el => {
                el.style.opacity = '0';
                el.style.transform = 'translateY(20px)';
                el.style.transition = 'all 0.6s ease';
                observer.observe(el);
            });
        });
    </script>
</asp:Content>
