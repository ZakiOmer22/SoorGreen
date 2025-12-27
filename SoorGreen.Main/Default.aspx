<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="SoorGreen.Main._Default" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>SoorGreen - Sustainable Waste Management</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" />
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet" />
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700;800&family=Montserrat:wght@400;500;600;700&display=swap" rel="stylesheet" />
    <style>
        :root {
            --green: #10b981;
            --teal: #0d9488;
            --blue: #3b82f6;
            --dark: #111827;
            --darker: #0f172a;
            --light: #f8fafc;
            --accent: #f59e0b;
            --purple: #8b5cf6;
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        html {
            scroll-behavior: smooth;
        }

        body {
            font-family: 'Poppins', sans-serif;
            background: linear-gradient(135deg, #0f172a 0%, #1e293b 100%);
            color: var(--light);
            overflow-x: hidden;
        }

        /* === FULL WIDTH NAVBAR === */
        .nav-container {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            z-index: 1000;
            padding: 1rem 0;
            background: rgba(15, 23, 42, 0.95);
            backdrop-filter: blur(20px);
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
        }

        .nav-wrapper {
            display: flex;
            justify-content: space-between;
            align-items: center;
            max-width: 1900px;
            margin: 0 auto;
            padding: 0 2rem;
        }

        .logo {
            font-family: 'Montserrat', sans-serif;
            font-size: 2.2rem;
            font-weight: 700;
            color: var(--green);
            text-decoration: none;
            display: flex;
            align-items: center;
            gap: 12px;
        }

            .logo i {
                font-size: 2.5rem;
            }

        .nav-links {
            display: flex;
            gap: 2.5rem;
            align-items: center;
        }

        .nav-link {
            color: var(--light);
            text-decoration: none;
            font-weight: 500;
            font-size: 1.1rem;
            position: relative;
            padding: 0.5rem 0;
            transition: all 0.3s ease;
        }

            .nav-link::after {
                content: '';
                position: absolute;
                bottom: 0;
                left: 0;
                width: 0;
                height: 3px;
                background: var(--green);
                transition: width 0.3s ease;
                border-radius: 3px;
            }

            .nav-link:hover::after,
            .nav-link.active::after {
                width: 100%;
            }

            .nav-link:hover {
                color: var(--green);
            }

        .cta-btn {
            background: linear-gradient(135deg, var(--green), var(--teal));
            color: white;
            padding: 12px 30px;
            border-radius: 50px;
            font-weight: 600;
            text-decoration: none;
            transition: all 0.3s ease;
            display: flex;
            align-items: center;
            gap: 10px;
            border: none;
            cursor: pointer;
        }

            .cta-btn:hover {
                transform: translateY(-3px);
                box-shadow: 0 15px 30px rgba(16, 185, 129, 0.4);
            }

        /* === HERO SECTION === */
        .hero-section {
            min-height: 100vh;
            display: flex;
            align-items: center;
            padding: 120px 2rem 2rem;
            position: relative;
            overflow: hidden;
        }

        .hero-bg {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: radial-gradient(circle at 15% 30%, rgba(16, 185, 129, 0.15) 0%, transparent 40%), radial-gradient(circle at 85% 70%, rgba(59, 130, 246, 0.15) 0%, transparent 40%);
            animation: pulse 8s ease-in-out infinite;
        }

        @keyframes pulse {
            0%, 100% {
                opacity: 0.7;
                transform: scale(1);
            }

            50% {
                opacity: 0.9;
                transform: scale(1.02);
            }
        }

        .hero-content {
            max-width: 1200px;
            margin: 0 auto;
            text-align: center;
            position: relative;
            z-index: 2;
        }

        .hero-title {
            font-size: 4.5rem;
            font-weight: 800;
            margin-bottom: 1.5rem;
            background: linear-gradient(135deg, var(--green), var(--blue));
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            line-height: 1.1;
        }

        .hero-subtitle {
            font-size: 1.4rem;
            max-width: 800px;
            margin: 0 auto 3rem;
            opacity: 0.9;
            line-height: 1.6;
        }

        /* === SECTION STYLES === */
        .section {
            padding: 100px 2rem;
            position: relative;
        }

        .section-title {
            text-align: center;
            font-size: 3rem;
            font-weight: 700;
            margin-bottom: 1rem;
            color: var(--light);
        }

        .section-subtitle {
            text-align: center;
            font-size: 1.2rem;
            max-width: 700px;
            margin: 0 auto 3rem;
            opacity: 0.8;
        }

        .accent-title {
            background: linear-gradient(135deg, var(--green), var(--accent));
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }

        .accent-purple {
            background: linear-gradient(135deg, var(--purple), var(--blue));
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }

        /* === GRID LAYOUTS === */
        .grid-3 {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 2rem;
            max-width: 1200px;
            margin: 0 auto;
        }

        .grid-4 {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 2rem;
            max-width: 1200px;
            margin: 0 auto;
        }

        .grid-2 {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 2rem;
            max-width: 1200px;
            margin: 0 auto;
            align-items: center;
        }

        /* === GLASS CARDS === */
        .glass-card {
            background: rgba(255, 255, 255, 0.08);
            backdrop-filter: blur(15px);
            border: 1px solid rgba(255, 255, 255, 0.1);
            border-radius: 24px;
        }

        /* === IMPROVED TEAM SECTION === */
        .team-section {
            padding: 120px 2rem;
            background: linear-gradient(135deg, rgba(16, 185, 129, 0.03), rgba(59, 130, 246, 0.03));
            position: relative;
            overflow: hidden;
        }

            .team-section::before {
                content: '';
                position: absolute;
                top: 0;
                left: 0;
                right: 0;
                height: 1px;
                background: linear-gradient(90deg, transparent, var(--green), transparent);
            }

        .team-container {
            max-width: 1400px;
            margin: 0 auto;
            position: relative;
        }

        .team-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
            gap: 30px;
            margin-top: 50px;
        }

        .team-card-wrapper {
            position: relative;
            perspective: 1000px;
        }

        .team-card {
            position: relative;
            border-radius: 20px;
            overflow: hidden;
            height: 590px;
            background: linear-gradient(145deg, rgba(255,255,255,0.05), rgba(255,255,255,0.02));
            border: 1px solid rgba(255, 255, 255, 0.1);
            transition: all 0.6s cubic-bezier(0.4, 0, 0.2, 1);
            transform-style: preserve-3d;
            cursor: pointer;
        }

            .team-card:hover {
                transform: translateY(-20px) rotateX(5deg);
                box-shadow: 0 30px 60px rgba(16, 185, 129, 0.3), 0 0 100px rgba(16, 185, 129, 0.1);
                border-color: var(--green);
            }

        .team-img-container {
            position: relative;
            height: 230px;
            overflow: hidden;
        }

        .team-img {
            width: 100%;
            height: 100%;
            object-fit: cover;
            transition: transform 0.8s cubic-bezier(0.4, 0, 0.2, 1);
            filter: grayscale(20%);
        }

        .team-card:hover .team-img {
            transform: scale(1.15);
            filter: grayscale(0%);
        }

        .team-gradient-overlay {
            position: absolute;
            bottom: 0;
            left: 0;
            right: 0;
            height: 100px;
            background: linear-gradient(to top, rgba(15, 23, 42, 0.9), transparent);
        }

        .team-content {
            padding: 25px;
            position: relative;
            z-index: 2;
        }

        .team-name {
            font-size: 1.6rem;
            font-weight: 700;
            margin-bottom: 8px;
            color: white;
            line-height: 1.3;
        }

        .team-role {
            color: var(--green);
            font-weight: 600;
            font-size: 1.1rem;
            margin-bottom: 15px;
            display: flex;
            align-items: center;
            gap: 8px;
        }

            .team-role i {
                font-size: 0.9rem;
            }

        .team-desc {
            font-size: 0.95rem;
            opacity: 0.8;
            line-height: 1.6;
            margin-bottom: 20px;
            min-height: 80px;
        }

        .team-skills {
            display: flex;
            flex-wrap: wrap;
            gap: 8px;
            margin-bottom: 20px;
        }

        .skill-tag {
            background: rgba(16, 185, 129, 0.1);
            color: var(--green);
            padding: 6px 14px;
            border-radius: 20px;
            font-size: 0.85rem;
            font-weight: 500;
            border: 1px solid rgba(16, 185, 129, 0.2);
            transition: all 0.3s ease;
        }

        .team-card:hover .skill-tag {
            background: rgba(16, 185, 129, 0.2);
            transform: translateY(-2px);
        }

        .team-social {
            display: flex;
            gap: 12px;
            margin-top: 15px;
            opacity: 0;
            transform: translateY(20px);
            transition: all 0.4s ease;
        }

        .team-card:hover .team-social {
            opacity: 1;
            transform: translateY(0);
        }

        .team-social-link {
            width: 40px;
            height: 40px;
            background: rgba(255, 255, 255, 0.05);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            text-decoration: none;
            transition: all 0.3s ease;
            border: 1px solid rgba(255, 255, 255, 0.1);
        }

            .team-social-link:hover {
                background: var(--green);
                transform: translateY(-3px) scale(1.1);
                box-shadow: 0 5px 15px rgba(16, 185, 129, 0.4);
            }

        .team-stats {
            position: absolute;
            top: 20px;
            right: 20px;
            background: rgba(16, 185, 129, 0.2);
            backdrop-filter: blur(10px);
            padding: 8px 15px;
            border-radius: 20px;
            font-size: 0.9rem;
            font-weight: 600;
            color: var(--green);
            border: 1px solid rgba(16, 185, 129, 0.3);
            z-index: 3;
        }

        /* Team Section Header */
        .team-header {
            text-align: center;
            max-width: 800px;
            margin: 0 auto 60px;
            position: relative;
        }

        .team-badge {
            display: inline-block;
            background: linear-gradient(135deg, var(--green), var(--teal));
            color: white;
            padding: 10px 25px;
            border-radius: 30px;
            font-weight: 600;
            font-size: 1.1rem;
            margin-bottom: 20px;
            box-shadow: 0 10px 20px rgba(16, 185, 129, 0.2);
        }

        /* === FEATURE CARDS === */
        .feature-card {
            background: linear-gradient(145deg, rgba(255,255,255,0.05), rgba(255,255,255,0.02));
            border-radius: 20px;
            padding: 2.5rem;
            border: 1px solid rgba(255, 255, 255, 0.1);
            transition: all 0.4s ease;
            height: 100%;
        }

            .feature-card:hover {
                transform: translateY(-10px);
                border-color: var(--green);
                box-shadow: 0 20px 40px rgba(16, 185, 129, 0.2);
            }

        .feature-icon {
            font-size: 3rem;
            color: var(--green);
            margin-bottom: 1.5rem;
            background: rgba(16, 185, 129, 0.1);
            width: 70px;
            height: 70px;
            border-radius: 15px;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        /* === STATS CARDS === */
        .stat-card {
            text-align: center;
            padding: 2.5rem;
        }

        .stat-value {
            font-size: 3.5rem;
            font-weight: 800;
            color: var(--green);
            margin-bottom: 0.5rem;
            font-family: 'Montserrat', sans-serif;
        }

        .stat-label {
            font-size: 1.1rem;
            opacity: 0.8;
            text-transform: uppercase;
            letter-spacing: 1px;
        }

        /* === CASE STUDIES === */
        .case-studies {
            background: rgba(16, 185, 129, 0.05);
        }

        .case-card {
            background: rgba(255, 255, 255, 0.05);
            border-radius: 20px;
            padding: 2.5rem;
            border: 1px solid rgba(255, 255, 255, 0.1);
            transition: all 0.4s ease;
            height: 100%;
        }

            .case-card:hover {
                transform: translateY(-10px);
                border-color: var(--green);
                box-shadow: 0 20px 40px rgba(16, 185, 129, 0.2);
            }

        /* === RESEARCH SECTION === */
        .research-section {
            background: rgba(59, 130, 246, 0.05);
        }

        .research-card {
            background: rgba(255, 255, 255, 0.05);
            border-radius: 20px;
            padding: 2.5rem;
            border: 1px solid rgba(255, 255, 255, 0.1);
            transition: all 0.4s ease;
            height: 100%;
        }

            .research-card:hover {
                transform: translateY(-10px);
                border-color: var(--blue);
            }

        /* === GALLERY === */
        .gallery-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 1.5rem;
            max-width: 1200px;
            margin: 0 auto;
        }

        .gallery-item {
            border-radius: 15px;
            overflow: hidden;
            height: 300px;
            cursor: pointer;
        }

            .gallery-item img {
                width: 100%;
                height: 100%;
                object-fit: cover;
                transition: transform 0.5s ease;
            }

            .gallery-item:hover img {
                transform: scale(1.1);
            }

        /* === TECHNOLOGY CARDS === */
        .tech-card {
            text-align: center;
            padding: 2rem;
        }

        .tech-icon {
            font-size: 3rem;
            color: var(--green);
            margin-bottom: 1rem;
        }

        /* === FORM STYLES === */
        .form-input {
            width: 100%;
            padding: 1rem 1.5rem;
            background: rgba(255, 255, 255, 0.05);
            border: 2px solid rgba(255, 255, 255, 0.1);
            border-radius: 12px;
            color: white;
            font-size: 1rem;
            transition: all 0.3s ease;
        }

            .form-input:focus {
                outline: none;
                border-color: var(--green);
                background: rgba(255, 255, 255, 0.08);
            }

        /* === IMPROVED FOOTER === */
        .footer {
            background: linear-gradient(135deg, #0a0f1a 0%, #0d1423 100%);
            padding: 100px 2rem 40px;
            position: relative;
            overflow: hidden;
            border-top: 1px solid rgba(255, 255, 255, 0.1);
        }

            .footer::before {
                content: '';
                position: absolute;
                top: 0;
                left: 0;
                right: 0;
                height: 1px;
                background: linear-gradient(90deg, transparent, var(--green), transparent);
            }

        .footer-bg {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            opacity: 0.03;
            background: radial-gradient(circle at 20% 30%, var(--green) 0%, transparent 50%), radial-gradient(circle at 80% 70%, var(--blue) 0%, transparent 50%);
        }

        .footer-container {
            max-width: 1400px;
            margin: 0 auto;
            position: relative;
            z-index: 2;
        }

        .footer-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 50px;
            margin-bottom: 60px;
        }

        .footer-brand {
            max-width: 350px;
        }

        .footer-logo {
            font-family: 'Montserrat', sans-serif;
            font-size: 2.5rem;
            font-weight: 700;
            color: var(--green);
            text-decoration: none;
            display: flex;
            align-items: center;
            gap: 15px;
            margin-bottom: 25px;
        }

            .footer-logo i {
                font-size: 2.8rem;
                background: linear-gradient(135deg, var(--green), var(--teal));
                -webkit-background-clip: text;
                -webkit-text-fill-color: transparent;
            }

        .footer-description {
            color: rgba(255, 255, 255, 0.7);
            line-height: 1.8;
            margin-bottom: 30px;
            font-size: 1.05rem;
        }

        .footer-newsletter {
            background: rgba(255, 255, 255, 0.03);
            border-radius: 15px;
            padding: 25px;
            border: 1px solid rgba(255, 255, 255, 0.1);
        }

            .footer-newsletter h3 {
                color: white;
                font-size: 1.3rem;
                margin-bottom: 15px;
            }

        .newsletter-form {
            display: flex;
            gap: 10px;
            margin-top: 20px;
        }

        .newsletter-input {
            flex: 1;
            padding: 14px 20px;
            background: rgba(255, 255, 255, 0.05);
            border: 1px solid rgba(255, 255, 255, 0.1);
            border-radius: 10px;
            color: white;
            font-size: 1rem;
            transition: all 0.3s ease;
        }

            .newsletter-input:focus {
                outline: none;
                border-color: var(--green);
                background: rgba(255, 255, 255, 0.08);
            }

        .newsletter-btn {
            background: linear-gradient(135deg, var(--green), var(--teal));
            color: white;
            border: none;
            padding: 0 25px;
            border-radius: 10px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            display: flex;
            align-items: center;
            gap: 8px;
        }

            .newsletter-btn:hover {
                transform: translateY(-2px);
                box-shadow: 0 10px 20px rgba(16, 185, 129, 0.3);
            }

        .footer-links-section h3 {
            color: white;
            font-size: 1.3rem;
            margin-bottom: 25px;
            position: relative;
            padding-bottom: 10px;
        }

            .footer-links-section h3::after {
                content: '';
                position: absolute;
                bottom: 0;
                left: 0;
                width: 40px;
                height: 3px;
                background: linear-gradient(90deg, var(--green), transparent);
                border-radius: 2px;
            }

        .footer-links {
            list-style: none;
            padding: 0;
        }

            .footer-links li {
                margin-bottom: 15px;
            }

        .footer-link {
            color: rgba(255, 255, 255, 0.7);
            text-decoration: none;
            font-size: 1.05rem;
            transition: all 0.3s ease;
            display: flex;
            align-items: center;
            gap: 10px;
        }

            .footer-link:hover {
                color: var(--green);
                transform: translateX(5px);
            }

            .footer-link i {
                font-size: 0.9rem;
                width: 20px;
            }

        .footer-contact {
            display: flex;
            flex-direction: column;
            gap: 20px;
        }

        .contact-item {
            display: flex;
            align-items: flex-start;
            gap: 15px;
        }

        .contact-icon {
            width: 45px;
            height: 45px;
            background: rgba(16, 185, 129, 0.1);
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: var(--green);
            font-size: 1.2rem;
            flex-shrink: 0;
        }

        .contact-info {
            flex: 1;
        }

            .contact-info strong {
                color: white;
                font-size: 1.1rem;
                display: block;
                margin-bottom: 5px;
            }

            .contact-info p {
                color: rgba(255, 255, 255, 0.7);
                font-size: 1rem;
                line-height: 1.5;
            }

        .footer-social-section {
            margin-top: 40px;
        }

        .footer-social-title {
            color: white;
            font-size: 1.2rem;
            margin-bottom: 20px;
        }

        .footer-social-links {
            display: flex;
            gap: 15px;
        }

        .footer-social-link {
            width: 50px;
            height: 50px;
            background: rgba(255, 255, 255, 0.05);
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            text-decoration: none;
            font-size: 1.3rem;
            transition: all 0.3s ease;
            border: 1px solid rgba(255, 255, 255, 0.1);
        }

            .footer-social-link:hover {
                background: var(--green);
                transform: translateY(-5px) rotate(5deg);
                box-shadow: 0 10px 20px rgba(16, 185, 129, 0.3);
            }

        .footer-bottom {
            padding-top: 40px;
            border-top: 1px solid rgba(255, 255, 255, 0.1);
            margin-top: 60px;
        }

        .footer-bottom-content {
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 20px;
        }

        .copyright {
            color: rgba(255, 255, 255, 0.5);
            font-size: 1rem;
        }

        .footer-bottom-links {
            display: flex;
            gap: 25px;
        }

        .footer-bottom-link {
            color: rgba(255, 255, 255, 0.5);
            text-decoration: none;
            font-size: 0.95rem;
            transition: all 0.3s ease;
        }

            .footer-bottom-link:hover {
                color: var(--green);
            }

        /* === RESPONSIVE === */
        @media (max-width: 1024px) {
            .grid-3, .grid-4 {
                grid-template-columns: repeat(2, 1fr);
            }

            .team-grid {
                grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
                gap: 25px;
            }

            .footer-grid {
                grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
                gap: 40px;
            }
        }

        @media (max-width: 768px) {
            .hero-title {
                font-size: 2.5rem;
            }

            .nav-links {
                display: none;
            }

            .grid-3, .grid-4, .grid-2 {
                grid-template-columns: 1fr;
            }

            .section-title {
                font-size: 2.5rem;
            }

            .nav-wrapper {
                padding: 0 1rem;
            }

            .team-section {
                padding: 80px 1.5rem;
            }

            .team-card {
                height: 380px;
            }

            .team-grid {
                grid-template-columns: 1fr;
                max-width: 400px;
                margin: 40px auto 0;
            }

            .footer {
                padding: 70px 1.5rem 30px;
            }

            .footer-bottom-content {
                flex-direction: column;
                text-align: center;
            }

            .footer-bottom-links {
                justify-content: center;
                flex-wrap: wrap;
            }

            .newsletter-form {
                flex-direction: column;
            }
        }

        @media (max-width: 480px) {
            .team-card {
                height: 360px;
            }

            .team-content {
                padding: 20px;
            }

            .footer-links-section {
                text-align: center;
            }

                .footer-links-section h3::after {
                    left: 50%;
                    transform: translateX(-50%);
                }
        }

        .gallery-tabs {
            display: flex;
            justify-content: center;
            gap: 1rem;
            margin-bottom: 3rem;
            flex-wrap: wrap;
        }

        .gallery-tab {
            padding: 0.8rem 2rem;
            background: rgba(255, 255, 255, 0.05);
            border: 1px solid rgba(255, 255, 255, 0.1);
            border-radius: 50px;
            color: white;
            cursor: pointer;
            transition: all 0.3s ease;
            font-weight: 500;
            border: none;
            font-size: 1rem;
        }

            .gallery-tab:hover,
            .gallery-tab.active {
                background: linear-gradient(135deg, var(--green), var(--teal));
                border-color: transparent;
                transform: translateY(-2px);
                box-shadow: 0 10px 20px rgba(16, 185, 129, 0.3);
            }

        .gallery-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
            gap: 1.5rem;
            max-width: 1200px;
            margin: 0 auto;
        }

        .gallery-item {
            position: relative;
            border-radius: 15px;
            overflow: hidden;
            height: 280px;
            cursor: pointer;
            background: rgba(255, 255, 255, 0.05);
            border: 1px solid rgba(255, 255, 255, 0.1);
            transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
        }

            .gallery-item:hover {
                transform: translateY(-10px) scale(1.02);
                box-shadow: 0 20px 40px rgba(16, 185, 129, 0.2);
                border-color: var(--green);
            }

            .gallery-item img {
                width: 100%;
                height: 100%;
                object-fit: cover;
                transition: transform 0.6s ease;
            }

            .gallery-item:hover img {
                transform: scale(1.1);
            }

        .gallery-overlay {
            position: absolute;
            bottom: 0;
            left: 0;
            right: 0;
            background: linear-gradient(to top, rgba(15, 23, 42, 0.95), transparent);
            padding: 1.5rem;
            color: white;
            transform: translateY(100%);
            transition: transform 0.3s ease;
        }

        .gallery-item:hover .gallery-overlay {
            transform: translateY(0);
        }

        .gallery-category {
            display: inline-block;
            background: rgba(16, 185, 129, 0.2);
            color: var(--green);
            padding: 0.3rem 0.8rem;
            border-radius: 20px;
            font-size: 0.8rem;
            font-weight: 600;
            margin-bottom: 0.8rem;
        }

        .gallery-title {
            font-size: 1.2rem;
            font-weight: 600;
            margin-bottom: 0.5rem;
            color: white;
        }

        .gallery-description {
            font-size: 0.9rem;
            opacity: 0.8;
            line-height: 1.4;
        }

        /* Lightbox Styles */
        .gallery-lightbox {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(15, 23, 42, 0.95);
            backdrop-filter: blur(10px);
            z-index: 9999;
            display: none;
            align-items: center;
            justify-content: center;
            opacity: 0;
            transition: opacity 0.3s ease;
        }

            .gallery-lightbox.active {
                display: flex;
                opacity: 1;
            }

        .lightbox-content {
            width: 90%;
            max-width: 1000px;
            background: rgba(255, 255, 255, 0.08);
            backdrop-filter: blur(20px);
            border-radius: 20px;
            border: 1px solid rgba(255, 255, 255, 0.1);
            overflow: hidden;
            position: relative;
            animation: lightboxSlide 0.4s ease;
        }

        @keyframes lightboxSlide {
            from {
                opacity: 0;
                transform: translateY(20px);
            }

            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        .lightbox-close {
            position: absolute;
            top: 20px;
            right: 20px;
            width: 40px;
            height: 40px;
            background: rgba(255, 255, 255, 0.1);
            border: 1px solid rgba(255, 255, 255, 0.2);
            border-radius: 50%;
            color: white;
            cursor: pointer;
            z-index: 10;
            transition: all 0.3s ease;
            display: flex;
            align-items: center;
            justify-content: center;
        }

            .lightbox-close:hover {
                background: var(--green);
                transform: rotate(90deg);
            }

        .lightbox-image-container {
            position: relative;
            height: 500px;
            overflow: hidden;
        }

        #lightboxImage {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }

        .lightbox-nav {
            position: absolute;
            top: 50%;
            left: 0;
            right: 0;
            transform: translateY(-50%);
            display: flex;
            justify-content: space-between;
            padding: 0 20px;
        }

        .lightbox-nav-btn {
            width: 50px;
            height: 50px;
            background: rgba(255, 255, 255, 0.1);
            border: 1px solid rgba(255, 255, 255, 0.2);
            border-radius: 50%;
            color: white;
            cursor: pointer;
            transition: all 0.3s ease;
            display: flex;
            align-items: center;
            justify-content: center;
        }

            .lightbox-nav-btn:hover {
                background: var(--green);
                transform: scale(1.1);
            }

        .lightbox-info {
            padding: 2rem;
        }

            .lightbox-info h3 {
                font-size: 1.8rem;
                color: white;
                margin-bottom: 1rem;
            }

            .lightbox-info p {
                opacity: 0.8;
                line-height: 1.6;
                margin-bottom: 1.5rem;
            }

        .lightbox-meta {
            display: flex;
            gap: 2rem;
            flex-wrap: wrap;
        }

            .lightbox-meta span {
                display: flex;
                align-items: center;
                gap: 0.5rem;
                color: var(--green);
                font-weight: 500;
            }

            .lightbox-meta i {
                font-size: 1.1rem;
            }

        /* Loading Animation */
        .gallery-loading {
            display: flex;
            justify-content: center;
            align-items: center;
            height: 200px;
        }

        .loader {
            width: 50px;
            height: 50px;
            border: 3px solid rgba(255, 255, 255, 0.1);
            border-top-color: var(--green);
            border-radius: 50%;
            animation: spin 1s linear infinite;
        }

        @keyframes spin {
            to {
                transform: rotate(360deg);
            }
        }

        /* Responsive */
        @media (max-width: 768px) {
            .gallery-grid {
                grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
            }

            .gallery-tabs {
                gap: 0.5rem;
            }

            .gallery-tab {
                padding: 0.6rem 1.2rem;
                font-size: 0.9rem;
            }

            .lightbox-image-container {
                height: 300px;
            }

            .lightbox-info {
                padding: 1.5rem;
            }

                .lightbox-info h3 {
                    font-size: 1.4rem;
                }

            .lightbox-meta {
                gap: 1rem;
            }
        }
        /* Video Library Styles */
        .video-library-section {
            position: relative;
            overflow: hidden;
        }

        .section-header {
            position: relative;
            margin-bottom: 3rem;
        }

        .section-badge {
            display: inline-block;
            background: linear-gradient(135deg, var(--green), var(--teal));
            color: white;
            padding: 10px 25px;
            border-radius: 30px;
            font-weight: 600;
            font-size: 1.1rem;
            margin-bottom: 1.5rem;
            box-shadow: 0 10px 20px rgba(16, 185, 129, 0.2);
        }

        /* Category Tabs */
        .category-tabs {
            display: flex;
            justify-content: center;
            gap: 1rem;
            margin-bottom: 3rem;
            flex-wrap: wrap;
        }

        .category-tab {
            padding: 12px 25px;
            background: rgba(255, 255, 255, 0.05);
            border: 1px solid rgba(255, 255, 255, 0.1);
            border-radius: 50px;
            color: white;
            cursor: pointer;
            transition: all 0.3s ease;
            font-weight: 500;
            display: flex;
            align-items: center;
            gap: 8px;
            font-size: 1rem;
            border: none;
        }

            .category-tab:hover,
            .category-tab.active {
                background: linear-gradient(135deg, var(--green), var(--teal));
                border-color: transparent;
                transform: translateY(-3px);
                box-shadow: 0 10px 20px rgba(16, 185, 129, 0.3);
            }

        /* Featured Video */
        .featured-video-card {
            background: rgba(255, 255, 255, 0.05);
            border-radius: 20px;
            overflow: hidden;
            border: 1px solid rgba(255, 255, 255, 0.1);
            transition: all 0.4s ease;
        }

            .featured-video-card:hover {
                transform: translateY(-5px);
                box-shadow: 0 20px 40px rgba(16, 185, 129, 0.2);
                border-color: var(--green);
            }

        .video-player-wrapper {
            position: relative;
            padding-top: 56.25%; /* 16:9 Aspect Ratio */
            cursor: pointer;
        }

        .video-placeholder {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: #000;
            border-radius: 15px 15px 0 0;
            overflow: hidden;
        }

        .video-thumbnail {
            width: 100%;
            height: 100%;
            object-fit: cover;
            transition: transform 0.5s ease;
        }

        .video-player-wrapper:hover .video-thumbnail {
            transform: scale(1.05);
        }

        .play-overlay {
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            width: 80px;
            height: 80px;
            background: rgba(16, 185, 129, 0.9);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 2rem;
            transition: all 0.3s ease;
            z-index: 2;
        }

        .video-player-wrapper:hover .play-overlay {
            background: var(--green);
            transform: translate(-50%, -50%) scale(1.1);
        }

        .video-details {
            padding: 2rem;
        }

        .video-badge {
            display: inline-block;
            background: linear-gradient(135deg, var(--accent), #f97316);
            color: white;
            padding: 5px 15px;
            border-radius: 20px;
            font-size: 0.9rem;
            font-weight: 600;
            margin-bottom: 1rem;
        }

            .video-badge.featured {
                background: linear-gradient(135deg, #f59e0b, #d97706);
            }

        .video-title {
            font-size: 1.8rem;
            color: white;
            margin-bottom: 1rem;
            line-height: 1.3;
        }

        .video-description {
            color: rgba(255, 255, 255, 0.8);
            line-height: 1.6;
            margin-bottom: 1.5rem;
        }

        .video-meta {
            display: flex;
            gap: 2rem;
            color: rgba(255, 255, 255, 0.6);
            font-size: 0.95rem;
        }

            .video-meta i {
                margin-right: 5px;
                color: var(--green);
            }

        /* Video Grid */
        .video-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
            gap: 2rem;
        }

        .video-card {
            background: rgba(255, 255, 255, 0.05);
            border-radius: 15px;
            overflow: hidden;
            border: 1px solid rgba(255, 255, 255, 0.1);
            transition: all 0.4s ease;
            cursor: pointer;
        }

            .video-card:hover {
                transform: translateY(-10px);
                box-shadow: 0 20px 40px rgba(16, 185, 129, 0.2);
                border-color: var(--green);
            }

        .video-thumb-container {
            position: relative;
            padding-top: 56.25%; /* 16:9 Aspect Ratio */
            overflow: hidden;
        }

            .video-thumb-container img {
                position: absolute;
                top: 0;
                left: 0;
                width: 100%;
                height: 100%;
                object-fit: cover;
            }

        .video-card-overlay {
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: rgba(0, 0, 0, 0.5);
            display: flex;
            align-items: center;
            justify-content: center;
            opacity: 0;
            transition: opacity 0.3s ease;
        }

        .video-card:hover .video-card-overlay {
            opacity: 1;
        }

        .play-icon-small {
            width: 50px;
            height: 50px;
            background: rgba(16, 185, 129, 0.9);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 1.5rem;
            transform: scale(0.8);
            transition: all 0.3s ease;
        }

        .video-card:hover .play-icon-small {
            transform: scale(1);
        }

        .video-duration {
            position: absolute;
            bottom: 10px;
            right: 10px;
            background: rgba(0, 0, 0, 0.8);
            color: white;
            padding: 3px 8px;
            border-radius: 4px;
            font-size: 0.8rem;
            font-weight: 500;
        }

        .video-card-content {
            padding: 1.5rem;
        }

        .video-card-title {
            font-size: 1.2rem;
            color: white;
            margin-bottom: 0.8rem;
            line-height: 1.4;
        }

        .video-card-description {
            color: rgba(255, 255, 255, 0.7);
            font-size: 0.95rem;
            line-height: 1.5;
            margin-bottom: 1rem;
        }

        .video-card-meta {
            display: flex;
            justify-content: space-between;
            color: rgba(255, 255, 255, 0.6);
            font-size: 0.9rem;
        }

        .video-card-category {
            background: rgba(16, 185, 129, 0.1);
            color: var(--green);
            padding: 3px 10px;
            border-radius: 15px;
            font-size: 0.8rem;
            font-weight: 500;
        }

        /* Playlist */
        .playlist-title {
            color: white;
            font-size: 1.5rem;
            margin-bottom: 2rem;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .playlist-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
            gap: 2rem;
        }

        .playlist-card {
            background: rgba(255, 255, 255, 0.05);
            border-radius: 15px;
            overflow: hidden;
            border: 1px solid rgba(255, 255, 255, 0.1);
            transition: all 0.3s ease;
            cursor: pointer;
        }

            .playlist-card:hover {
                transform: translateY(-5px);
                border-color: var(--green);
            }

        .playlist-thumbnail {
            position: relative;
            padding-top: 56.25%;
            overflow: hidden;
        }

            .playlist-thumbnail img {
                position: absolute;
                top: 0;
                left: 0;
                width: 100%;
                height: 100%;
                object-fit: cover;
            }

        .playlist-count {
            position: absolute;
            bottom: 10px;
            right: 10px;
            background: rgba(16, 185, 129, 0.9);
            color: white;
            padding: 5px 10px;
            border-radius: 15px;
            font-size: 0.9rem;
            font-weight: 500;
        }

        .playlist-info {
            padding: 1.5rem;
        }

            .playlist-info h4 {
                color: white;
                margin-bottom: 0.5rem;
                font-size: 1.2rem;
            }

            .playlist-info p {
                color: rgba(255, 255, 255, 0.7);
                font-size: 0.95rem;
            }

        /* Video Modal */
        .video-modal {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            z-index: 9999;
        }

            .video-modal.active {
                display: block;
            }

        .modal-overlay {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(15, 23, 42, 0.95);
            backdrop-filter: blur(10px);
        }

        .modal-content {
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            width: 90%;
            max-width: 1000px;
            background: rgba(255, 255, 255, 0.08);
            backdrop-filter: blur(20px);
            border-radius: 20px;
            border: 1px solid rgba(255, 255, 255, 0.1);
            overflow: hidden;
            animation: modalSlide 0.4s ease;
        }

        @keyframes modalSlide {
            from {
                opacity: 0;
                transform: translate(-50%, -40%);
            }

            to {
                opacity: 1;
                transform: translate(-50%, -50%);
            }
        }

        .modal-close {
            position: absolute;
            top: 20px;
            right: 20px;
            width: 40px;
            height: 40px;
            background: rgba(255, 255, 255, 0.1);
            border: 1px solid rgba(255, 255, 255, 0.2);
            border-radius: 50%;
            color: white;
            cursor: pointer;
            z-index: 10;
            transition: all 0.3s ease;
            display: flex;
            align-items: center;
            justify-content: center;
        }

            .modal-close:hover {
                background: var(--green);
                transform: rotate(90deg);
            }

        .modal-video-container {
            display: grid;
            grid-template-columns: 2fr 1fr;
            gap: 0;
            height: 600px;
        }

        .video-wrapper {
            background: #000;
            position: relative;
            overflow: hidden;
        }

            .video-wrapper iframe {
                width: 100%;
                height: 100%;
                border: none;
            }

        .video-info {
            padding: 2rem;
            overflow-y: auto;
        }

            .video-info h3 {
                color: white;
                font-size: 1.5rem;
                margin-bottom: 1rem;
                line-height: 1.3;
            }

        .video-stats {
            display: flex;
            gap: 1.5rem;
            color: rgba(255, 255, 255, 0.6);
            font-size: 0.95rem;
            margin-bottom: 1.5rem;
        }

        .video-info p {
            color: rgba(255, 255, 255, 0.8);
            line-height: 1.6;
            margin-bottom: 2rem;
        }

        .video-actions {
            display: flex;
            gap: 1rem;
            flex-wrap: wrap;
        }

        .action-btn {
            padding: 8px 20px;
            background: rgba(255, 255, 255, 0.05);
            border: 1px solid rgba(255, 255, 255, 0.1);
            border-radius: 20px;
            color: white;
            cursor: pointer;
            transition: all 0.3s ease;
            display: flex;
            align-items: center;
            gap: 8px;
            font-size: 0.95rem;
        }

            .action-btn:hover {
                background: var(--green);
                transform: translateY(-2px);
            }

        /* Responsive */
        @media (max-width: 1024px) {
            .modal-video-container {
                grid-template-columns: 1fr;
                height: auto;
            }

            .video-wrapper {
                height: 400px;
            }
        }

        @media (max-width: 768px) {
            .category-tabs {
                gap: 0.5rem;
            }

            .category-tab {
                padding: 10px 15px;
                font-size: 0.9rem;
            }

            .video-grid {
                grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
            }

            .video-title {
                font-size: 1.5rem;
            }

            .playlist-grid {
                grid-template-columns: 1fr;
            }

            .modal-content {
                width: 95%;
            }

            .video-wrapper {
                height: 300px;
            }
        }

        @media (max-width: 480px) {
            .video-meta {
                flex-direction: column;
                gap: 0.5rem;
            }

            .video-card-meta {
                flex-direction: column;
                gap: 0.5rem;
            }

            .modal-content {
                width: 100%;
                height: 100%;
                border-radius: 0;
            }

            .modal-video-container {
                height: 100vh;
            }
        }
    </style>
</head>
<body>
    <!-- Main Content -->
    <div class="main-content" id="mainContent">
        <form id="form1" runat="server">
            <!-- Navigation -->
            <div class="nav-container">
                <div class="nav-wrapper">
                    <a href="#" class="logo">
                        <image src="favicon.ico" class="w-25 h-25" />
                        SoorGreen
                    </a>
                    <div class="nav-links">
                        <a href="#home" class="nav-link active">Home</a>
                        <a href="#features" class="nav-link">Features</a>
                        <a href="#impact" class="nav-link">Impact</a>
                        <a href="#team" class="nav-link">Team</a>
                        <a href="#case-studies" class="nav-link">Case Studies</a>
                        <a href="#research" class="nav-link">Research</a>
                        <a href="#gallery" class="nav-link">Gallery</a>
                        <a href="#technology" class="nav-link">Technology</a>
                        <a href="ChooseApp.aspx" class="cta-btn">
                            <i class="fas fa-rocket"></i>
                            Launch App
                        </a>
                    </div>
                </div>
            </div>

            <!-- 1. HERO SECTION -->
            <section class="hero-section" id="home">
                <div class="hero-bg"></div>
                <div class="hero-content">
                    <h1 class="hero-title">Revolutionizing Waste<br>
                        <span class="accent-title">Management</span> with AI
                    </h1>
                    <p class="hero-subtitle">
                        SoorGreen leverages cutting-edge technology to transform how cities handle waste. 
                        Our smart solutions optimize collection, increase recycling rates, and build sustainable communities.
                    </p>
                    <div style="display: flex; gap: 1.5rem; justify-content: center; flex-wrap: wrap;">
                        <a href="ChooseApp.aspx" class="cta-btn" style="padding: 1.2rem 2.5rem;">
                            <i class="fas fa-rocket"></i>
                            Launch Platform
                        </a>
                    </div>
                </div>
            </section>

            <!-- 2. FEATURES SECTION -->
            <section class="section" id="features">
                <div class="container">
                    <h2 class="section-title">
                        <span class="accent-title">Smart</span> Features
                    </h2>
                    <p class="section-subtitle">
                        Our comprehensive suite of AI-powered tools designed for modern cities
                    </p>

                    <div class="grid-3">
                        <div class="feature-card glass-card">
                            <div class="feature-icon">
                                <i class="fas fa-robot"></i>
                            </div>
                            <h3 style="font-size: 1.5rem; margin-bottom: 1rem; color: white;">AI-Powered Sorting</h3>
                            <p style="opacity: 0.8; line-height: 1.6;">
                                Computer vision and machine learning algorithms that automatically identify and sort waste materials with 98% accuracy.
                            </p>
                        </div>

                        <div class="feature-card glass-card">
                            <div class="feature-icon">
                                <i class="fas fa-route"></i>
                            </div>
                            <h3 style="font-size: 1.5rem; margin-bottom: 1rem; color: white;">Smart Routing</h3>
                            <p style="opacity: 0.8; line-height: 1.6;">
                                Optimized collection routes that reduce fuel consumption by 30% and improve efficiency by 40%.
                            </p>
                        </div>

                        <div class="feature-card glass-card">
                            <div class="feature-icon">
                                <i class="fas fa-chart-line"></i>
                            </div>
                            <h3 style="font-size: 1.5rem; margin-bottom: 1rem; color: white;">Predictive Analytics</h3>
                            <p style="opacity: 0.8; line-height: 1.6;">
                                Advanced algorithms predict waste generation patterns, helping cities plan and allocate resources efficiently.
                            </p>
                        </div>
                    </div>
                </div>
            </section>

            <!-- 3. IMPACT METRICS -->
            <section class="section" id="impact" style="background: rgba(16, 185, 129, 0.05);">
                <div class="container">
                    <h2 class="section-title">Our <span class="accent-title">Impact</span> in Numbers
                    </h2>
                    <p class="section-subtitle">
                        Real results from cities transformed by our technology
                    </p>

                    <div class="grid-4">
                        <div class="stat-card glass-card">
                            <div class="stat-value" data-count="85">85</div>
                            <div class="stat-label">Recycling Rate Increase</div>
                        </div>

                        <div class="stat-card glass-card">
                            <div class="stat-value" data-count="40">40</div>
                            <div class="stat-label">Cost Reduction</div>
                        </div>

                        <div class="stat-card glass-card">
                            <div class="stat-value" data-count="150">150</div>
                            <div class="stat-label">Cities Served</div>
                        </div>

                        <div class="stat-card glass-card">
                            <div class="stat-value" data-count="95">95</div>
                            <div class="stat-label">User Satisfaction</div>
                        </div>
                    </div>
                </div>
            </section>

            <!-- 4. IMPROVED TEAM SECTION -->
            <section class="team-section" id="team">
                <div class="team-container">
                    <div class="team-header">
                        <span class="team-badge">
                            <i class="fas fa-users"></i>Meet The Dream Team
                        </span>
                        <h2 class="section-title">Our <span class="accent-title">Brilliant</span> Minds
                        </h2>
                        <p class="section-subtitle">
                            The innovative thinkers and problem solvers driving SoorGreen's mission forward.
                            Each member brings unique expertise to transform waste management globally.
                        </p>
                    </div>

                    <div class="team-grid">
                        <!-- Zacki Abdulkadir Omer -->
                        <div class="team-card-wrapper">
                            <div class="team-card glass-card">
                                <span class="team-stats">
                                    <i class="fas fa-code"></i>Lead Dev
                                </span>
                                <div class="team-img-container">
                                    <img src="Images/Team/zacki.jpg" alt="Zacki Abdulkadir Omer" class="team-img">
                                    <div class="team-gradient-overlay"></div>
                                </div>
                                <div class="team-content">
                                    <h3 class="team-name">Zacki Abdulkadir Omer</h3>
                                    <div class="team-role">
                                        <i class="fas fa-microchip"></i>
                                        Lead Software & AI Engineer
                                    </div>
                                    <p class="team-desc">
                                        Full-stack wizard and AI visionary. Architect of our intelligent systems, 
                                        specializing in scalable solutions and cutting-edge machine learning.
                                    </p>
                                    <div class="team-skills">
                                        <span class="skill-tag">Python</span>
                                        <span class="skill-tag">TensorFlow</span>
                                        <span class="skill-tag">Computer Vision</span>
                                        <span class="skill-tag">AWS</span>
                                    </div>
                                    <div class="team-social">
                                        <a href="#" class="team-social-link" title="GitHub">
                                            <i class="fab fa-github"></i>
                                        </a>
                                        <a href="#" class="team-social-link" title="LinkedIn">
                                            <i class="fab fa-linkedin-in"></i>
                                        </a>
                                        <a href="#" class="team-social-link" title="Twitter">
                                            <i class="fab fa-twitter"></i>
                                        </a>
                                        <a href="#" class="team-social-link" title="Portfolio">
                                            <i class="fas fa-globe"></i>
                                        </a>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Abdirxeem Khadar Cabdirahman -->
                        <div class="team-card-wrapper">
                            <div class="team-card glass-card">
                                <span class="team-stats">
                                    <i class="fas fa-flask"></i>Research & Backend Unit
                                </span>
                                <div class="team-img-container">
                                    <img src="Images/Team/abdirxeem.jpg" alt="Abdirxeem Khadar Cabdirahman" class="team-img">
                                    <div class="team-gradient-overlay"></div>
                                </div>
                                <div class="team-content">
                                    <h3 class="team-name">Abdirxeem Khadar Cabdirahman</h3>
                                    <div class="team-role">
                                        <i class="fas fa-graduation-cap"></i>
                                        Lead Research Unit
                                    </div>
                                    <p class="team-desc">
                                        Leads groundbreaking research in waste 
                                        management technology and sustainable innovation. Published & analyzed 5+ resreach papers.
                                    </p>
                                    <div class="team-skills">
                                        <span class="skill-tag">Research</span>
                                        <span class="skill-tag">ML Algorithms</span>
                                        <span class="skill-tag">Data Analysis</span>
                                        <span class="skill-tag">Sustainability</span>
                                    </div>
                                    <div class="team-social">
                                        <a href="#" class="team-social-link" title="ResearchGate">
                                            <i class="fab fa-researchgate"></i>
                                        </a>
                                        <a href="#" class="team-social-link" title="Google Scholar">
                                            <i class="fas fa-graduation-cap"></i>
                                        </a>
                                        <a href="#" class="team-social-link" title="LinkedIn">
                                            <i class="fab fa-linkedin-in"></i>
                                        </a>
                                        <a href="#" class="team-social-link" title="Papers">
                                            <i class="fas fa-file-alt"></i>
                                        </a>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Arafat Osman Aden -->
                        <div class="team-card-wrapper">
                            <div class="team-card glass-card">
                                <span class="team-stats">
                                    <i class="fas fa-bullhorn"></i>Marketing Lead
                                </span>
                                <div class="team-img-container">
                                    <img src="Images/Team/arafat.jpg" alt="Arafat Osman Aden" class="team-img">
                                    <div class="team-gradient-overlay"></div>
                                </div>
                                <div class="team-content">
                                    <h3 class="team-name">Arafat Osman Aden</h3>
                                    <div class="team-role">
                                        <i class="fas fa-chart-line"></i>
                                        Lead Marketing Unit
                                    </div>
                                    <p class="team-desc">
                                        10+ years in green tech marketing. Expert in brand strategy, community 
                                        building, and driving sustainable business growth through innovation.
                                    </p>
                                    <div class="team-skills">
                                        <span class="skill-tag">Strategy</span>
                                        <span class="skill-tag">Branding</span>
                                        <span class="skill-tag">Growth</span>
                                        <span class="skill-tag">Partnerships</span>
                                    </div>
                                    <div class="team-social">
                                        <a href="#" class="team-social-link" title="Twitter">
                                            <i class="fab fa-twitter"></i>
                                        </a>
                                        <a href="#" class="team-social-link" title="LinkedIn">
                                            <i class="fab fa-linkedin-in"></i>
                                        </a>
                                        <a href="#" class="team-social-link" title="Instagram">
                                            <i class="fab fa-instagram"></i>
                                        </a>
                                        <a href="#" class="team-social-link" title="YouTube">
                                            <i class="fab fa-youtube"></i>
                                        </a>
                                    </div>
                                </div>
                            </div>
                        </div>

                    </div>
                </div>
            </section>

            <!-- 5. CASE STUDIES SECTION -->
            <section class="section case-studies" id="case-studies">
                <div class="container">
                    <h2 class="section-title">Success <span class="accent-title">Stories</span>
                    </h2>
                    <p class="section-subtitle">
                        Real-world implementations that transformed cities
                    </p>

                    <div class="grid-3">
                        <div class="case-card">
                            <div class="feature-icon" style="background: rgba(16, 185, 129, 0.1);">
                                <i class="fas fa-city"></i>
                            </div>
                            <h3 style="font-size: 1.5rem; margin-bottom: 1rem; color: white;">Green City Initiative</h3>
                            <p style="opacity: 0.8; line-height: 1.6; margin-bottom: 1.5rem;">
                                Reduced landfill waste by 75% and increased recycling rates by 60% in just 6 months.
                            </p>
                            <div style="display: flex; align-items: center; gap: 1rem;">
                                <div style="font-size: 2.5rem; font-weight: 700; color: var(--green);">75%</div>
                                <div style="opacity: 0.7; font-size: 0.9rem;">Waste Reduction</div>
                            </div>
                        </div>

                        <div class="case-card">
                            <div class="feature-icon" style="background: rgba(16, 185, 129, 0.1);">
                                <i class="fas fa-truck"></i>
                            </div>
                            <h3 style="font-size: 1.5rem; margin-bottom: 1rem; color: white;">Smart Metro Project</h3>
                            <p style="opacity: 0.8; line-height: 1.6; margin-bottom: 1.5rem;">
                                Optimized collection routes saving 40% in fuel costs and reducing carbon emissions.
                            </p>
                            <div style="display: flex; align-items: center; gap: 1rem;">
                                <div style="font-size: 2.5rem; font-weight: 700; color: var(--green);">40%</div>
                                <div style="opacity: 0.7; font-size: 0.9rem;">Cost Savings</div>
                            </div>
                        </div>

                        <div class="case-card">
                            <div class="feature-icon" style="background: rgba(16, 185, 129, 0.1);">
                                <i class="fas fa-water"></i>
                            </div>
                            <h3 style="font-size: 1.5rem; margin-bottom: 1rem; color: white;">Coastal Cleanup Program</h3>
                            <p style="opacity: 0.8; line-height: 1.6; margin-bottom: 1.5rem;">
                                Removed 50 tons of plastic waste from coastal areas using AI-guided collection.
                            </p>
                            <div style="display: flex; align-items: center; gap: 1rem;">
                                <div style="font-size: 2.5rem; font-weight: 700; color: var(--green);">50T</div>
                                <div style="opacity: 0.7; font-size: 0.9rem;">Plastic Removed</div>
                            </div>
                        </div>
                    </div>
                </div>
            </section>

            <!-- 6. RESEARCH SECTION -->
            <section class="section research-section" id="research">
                <div class="container">
                    <h2 class="section-title">Research & <span class="accent-purple">Innovation</span>
                    </h2>
                    <p class="section-subtitle">
                        Pushing the boundaries of waste management technology
                    </p>

                    <div class="grid-3">
                        <div class="research-card">
                            <div class="feature-icon" style="background: rgba(59, 130, 246, 0.1); color: var(--blue);">
                                <i class="fas fa-brain"></i>
                            </div>
                            <h3 style="font-size: 1.5rem; margin-bottom: 1rem; color: white;">AI Waste Recognition</h3>
                            <p style="opacity: 0.8; line-height: 1.6;">
                                Developing advanced computer vision models for precise material identification and contamination detection.
                            </p>
                            <div style="display: flex; gap: 0.5rem; margin-top: 1.5rem; flex-wrap: wrap;">
                                <span style="background: rgba(59, 130, 246, 0.2); color: var(--blue); padding: 0.3rem 0.8rem; border-radius: 20px; font-size: 0.9rem;">Machine Learning</span>
                                <span style="background: rgba(59, 130, 246, 0.2); color: var(--blue); padding: 0.3rem 0.8rem; border-radius: 20px; font-size: 0.9rem;">Computer Vision</span>
                            </div>
                        </div>

                        <div class="research-card">
                            <div class="feature-icon" style="background: rgba(59, 130, 246, 0.1); color: var(--blue);">
                                <i class="fas fa-recycle"></i>
                            </div>
                            <h3 style="font-size: 1.5rem; margin-bottom: 1rem; color: white;">Circular Economy Models</h3>
                            <p style="opacity: 0.8; line-height: 1.6;">
                                Researching sustainable waste-to-resource conversion methods and closed-loop recycling systems.
                            </p>
                            <div style="display: flex; gap: 0.5rem; margin-top: 1.5rem; flex-wrap: wrap;">
                                <span style="background: rgba(59, 130, 246, 0.2); color: var(--blue); padding: 0.3rem 0.8rem; border-radius: 20px; font-size: 0.9rem;">Sustainability</span>
                                <span style="background: rgba(59, 130, 246, 0.2); color: var(--blue); padding: 0.3rem 0.8rem; border-radius: 20px; font-size: 0.9rem;">Circular Economy</span>
                            </div>
                        </div>

                        <div class="research-card">
                            <div class="feature-icon" style="background: rgba(59, 130, 246, 0.1); color: var(--blue);">
                                <i class="fas fa-flask"></i>
                            </div>
                            <h3 style="font-size: 1.5rem; margin-bottom: 1rem; color: white;">Smart Material Recovery</h3>
                            <p style="opacity: 0.8; line-height: 1.6;">
                                Advanced techniques for recovering valuable materials from mixed waste streams using AI-guided processes.
                            </p>
                            <div style="display: flex; gap: 0.5rem; margin-top: 1.5rem; flex-wrap: wrap;">
                                <span style="background: rgba(59, 130, 246, 0.2); color: var(--blue); padding: 0.3rem 0.8rem; border-radius: 20px; font-size: 0.9rem;">Material Science</span>
                                <span style="background: rgba(59, 130, 246, 0.2); color: var(--blue); padding: 0.3rem 0.8rem; border-radius: 20px; font-size: 0.9rem;">AI Processing</span>
                            </div>
                        </div>
                    </div>
                </div>
            </section>

            <!-- 8. VIDEO LIBRARY SECTION -->
            <section class="section video-library-section" id="video-library" style="background: rgba(16, 185, 129, 0.03);">
                <div class="container">
                    <div class="section-header text-center mb-5">
                        <span class="section-badge">
                            <i class="fas fa-play-circle"></i>Video Library
                        </span>
                        <h2 class="section-title">Learn Through <span class="accent-title">Visual Stories</span>
                        </h2>
                        <p class="section-subtitle">
                            Watch our technology in action with demos, tutorials, and success stories
                        </p>
                    </div>

                    <!-- Video Categories -->
                    <div class="video-categories">
                        <div class="category-tabs">
                            <button class="category-tab active" data-category="all">
                                <i class="fas fa-globe"></i>All Videos
                            </button>
                            <button class="category-tab" data-category="demos">
                                <i class="fas fa-play"></i>Product Demos
                            </button>
                            <button class="category-tab" data-category="tutorials">
                                <i class="fas fa-graduation-cap"></i>Tutorials
                            </button>
                            <button class="category-tab" data-category="case-studies">
                                <i class="fas fa-chart-bar"></i>Case Studies
                            </button>
                            <button class="category-tab" data-category="interviews">
                                <i class="fas fa-microphone"></i>Interviews
                            </button>
                        </div>
                    </div>

                    <!-- Featured Video -->
                    <div class="featured-video-container mb-5">
                        <div class="featured-video-card">
                            <div class="video-player-wrapper">
                                <div class="video-player" id="featuredVideoPlayer">
                                    <div class="video-placeholder">
                                        <div class="play-overlay">
                                            <i class="fas fa-play"></i>
                                        </div>
                                        <img src="https://images.unsplash.com/photo-1558618666-fcd25c85cd64?ixlib=rb-4.0.3&auto=format&fit=crop&w=1200&q=80"
                                            alt="Featured Video" class="video-thumbnail">
                                    </div>
                                    <div class="video-details">
                                        <span class="video-badge featured">Featured</span>
                                        <h3 class="video-title">Full Product Walkthrough: AI Waste Management System</h3>
                                        <p class="video-description">Complete demonstration of our AI-powered waste sorting and routing system in action</p>
                                        <div class="video-meta">
                                            <span><i class="fas fa-clock"></i>15:30</span>
                                            <span><i class="fas fa-eye"></i>25,489 views</span>
                                            <span><i class="fas fa-calendar"></i>2 weeks ago</span>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Video Grid -->
                    <div class="video-grid-container">
                        <div class="video-grid" id="videoGrid">
                            <!-- Videos will be loaded here -->
                        </div>
                    </div>

                    <!-- Video Playlist -->
                    <div class="video-playlist mt-5">
                        <h3 class="playlist-title">
                            <i class="fas fa-list"></i>Recommended Playlists
                        </h3>
                        <div class="playlist-grid">
                            <div class="playlist-card">
                                <div class="playlist-thumbnail">
                                    <img src="https://images.unsplash.com/photo-1581094794329-c8112a89af12?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&q=80"
                                        alt="Getting Started">
                                    <div class="playlist-count">
                                        <i class="fas fa-play"></i>8 videos
                                    </div>
                                </div>
                                <div class="playlist-info">
                                    <h4>Getting Started</h4>
                                    <p>Learn the basics of SoorGreen platform</p>
                                </div>
                            </div>

                            <div class="playlist-card">
                                <div class="playlist-thumbnail">
                                    <img src="https://images.unsplash.com/photo-1551288049-bebda4e38f71?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&q=80"
                                        alt="Advanced Features">
                                    <div class="playlist-count">
                                        <i class="fas fa-play"></i>12 videos
                                    </div>
                                </div>
                                <div class="playlist-info">
                                    <h4>Advanced Features</h4>
                                    <p>Master advanced AI and IoT features</p>
                                </div>
                            </div>

                            <div class="playlist-card">
                                <div class="playlist-thumbnail">
                                    <img src="https://images.unsplash.com/photo-1523240795612-9a054b0db644?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&q=80"
                                        alt="Success Stories">
                                    <div class="playlist-count">
                                        <i class="fas fa-play"></i>6 videos
                                    </div>
                                </div>
                                <div class="playlist-info">
                                    <h4>Success Stories</h4>
                                    <p>Real-world implementations</p>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Video Modal -->
                    <div class="video-modal" id="videoModal">
                        <div class="modal-overlay"></div>
                        <div class="modal-content">
                            <button class="modal-close" id="closeModal">
                                <i class="fas fa-times"></i>
                            </button>
                            <div class="modal-video-container">
                                <div class="video-wrapper" id="modalVideoPlayer">
                                    <!-- Video will be loaded here -->
                                </div>
                                <div class="video-info">
                                    <h3 id="modalVideoTitle">Video Title</h3>
                                    <div class="video-stats">
                                        <span id="modalVideoViews">0 views</span>
                                        <span id="modalVideoDate">Date</span>
                                    </div>
                                    <p id="modalVideoDescription">Video description</p>
                                    <div class="video-actions">
                                        <button class="action-btn like-btn">
                                            <i class="fas fa-thumbs-up"></i>Like
                                        </button>
                                        <button class="action-btn share-btn">
                                            <i class="fas fa-share"></i>Share
                                        </button>
                                        <button class="action-btn save-btn">
                                            <i class="fas fa-bookmark"></i>Save
                                        </button>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </section>
            <!-- 7. ENHANCED GALLERY SECTION -->
            <section class="section" id="gallery" style="background: rgba(255, 255, 255, 0.02);">
                <div class="container">
                    <h2 class="section-title">Project <span class="accent-title">Gallery</span>
                    </h2>
                    <p class="section-subtitle">
                        Visual showcase of our technology in action around the world
                    </p>

                    <!-- Gallery Filter Tabs -->
                    <div class="gallery-tabs">
                        <button class="gallery-tab active" data-filter="all">All Projects</button>
                        <button class="gallery-tab" data-filter="smart-bins">Smart Bins</button>
                        <button class="gallery-tab" data-filter="ai-sorting">AI Sorting</button>
                        <button class="gallery-tab" data-filter="iot">IoT Systems</button>
                        <button class="gallery-tab" data-filter="community">Community Projects</button>
                    </div>

                    <!-- Gallery Grid -->
                    <div class="gallery-grid" id="galleryGrid">
                        <!-- Images will be loaded dynamically -->
                    </div>

                    <!-- View More Button -->
                    <div class="text-center mt-5">
                        <button class="cta-btn" id="loadMoreBtn">
                            <i class="fas fa-plus"></i>Load More Projects
                        </button>
                    </div>
                </div>
            </section>

            <!-- Lightbox Modal -->
            <div class="gallery-lightbox" id="lightbox">
                <div class="lightbox-content">
                    <button class="lightbox-close" id="closeLightbox">
                        <i class="fas fa-times"></i>
                    </button>
                    <div class="lightbox-image-container">
                        <img id="lightboxImage" src="" alt="">
                        <div class="lightbox-nav">
                            <button class="lightbox-nav-btn prev" id="prevBtn">
                                <i class="fas fa-chevron-left"></i>
                            </button>
                            <button class="lightbox-nav-btn next" id="nextBtn">
                                <i class="fas fa-chevron-right"></i>
                            </button>
                        </div>
                    </div>
                    <div class="lightbox-info">
                        <h3 id="lightboxTitle">Project Title</h3>
                        <p id="lightboxDescription">Project description will appear here</p>
                        <div class="lightbox-meta">
                            <span><i class="fas fa-map-marker-alt"></i><span id="lightboxLocation">Location</span></span>
                            <span><i class="fas fa-calendar"></i><span id="lightboxDate">2024</span></span>
                            <span><i class="fas fa-tag"></i><span id="lightboxCategory">Category</span></span>
                        </div>
                    </div>
                </div>
            </div>

            <!-- 8. TECHNOLOGY SECTION -->
            <section class="section" id="technology">
                <div class="container">
                    <h2 class="section-title">Our <span class="accent-title">Technology</span> Stack
                    </h2>
                    <p class="section-subtitle">
                        Built with cutting-edge technologies for maximum performance
                    </p>

                    <div class="grid-4">
                        <div class="feature-card">
                            <div class="feature-icon">
                                <i class="fab fa-python"></i>
                            </div>
                            <h3 style="font-size: 1.3rem; margin-bottom: 1rem; color: white;">Python & TensorFlow</h3>
                            <p style="opacity: 0.8;">AI/ML algorithms and data processing</p>
                        </div>

                        <div class="feature-card">
                            <div class="feature-icon">
                                <i class="fab fa-js"></i>
                            </div>
                            <h3 style="font-size: 1.3rem; margin-bottom: 1rem; color: white;">React & Node.js, ASP.NET</h3>
                            <p style="opacity: 0.8;">Frontend and backend development</p>
                        </div>

                        <div class="feature-card">
                            <div class="feature-icon">
                                <i class="fas fa-database"></i>
                            </div>
                            <h3 style="font-size: 1.3rem; margin-bottom: 1rem; color: white;">PostgreSQL, SQL SERVER & MongoDB</h3>
                            <p style="opacity: 0.8;">Relational and NoSQL databases</p>
                        </div>

                        <div class="feature-card">
                            <div class="feature-icon">
                                <i class="fab fa-aws"></i>
                            </div>
                            <h3 style="font-size: 1.3rem; margin-bottom: 1rem; color: white;">AWS Cloud</h3>
                            <p style="opacity: 0.8;">Scalable cloud infrastructure</p>
                        </div>
                    </div>
                </div>
            </section>

            <!-- 9. CONTACT SECTION -->
            <section class="section" id="contact" style="background: rgba(16, 185, 129, 0.05);">
                <div class="container">
                    <h2 class="section-title">Get in <span class="accent-title">Touch</span>
                    </h2>
                    <p class="section-subtitle">
                        Contact our team for a personalized demo
                    </p>

                    <div class="grid-2">
                        <div>
                            <div class="feature-card" style="height: 100%;">
                                <h3 style="font-size: 1.5rem; margin-bottom: 1.5rem; color: white;">Contact Information</h3>

                                <div style="margin-bottom: 2rem;">
                                    <div style="display: flex; align-items: center; gap: 1rem; margin-bottom: 1.5rem;">
                                        <div style="width: 50px; height: 50px; background: rgba(16, 185, 129, 0.1); border-radius: 10px; display: flex; align-items: center; justify-content: center;">
                                            <i class="fas fa-map-marker-alt" style="color: var(--green);"></i>
                                        </div>
                                        <div>
                                            <strong>Headquarters</strong>
                                            <p style="opacity: 0.8; margin: 0;">Innovation Center, Tech District</p>
                                        </div>
                                    </div>

                                    <div style="display: flex; align-items: center; gap: 1rem; margin-bottom: 1.5rem;">
                                        <div style="width: 50px; height: 50px; background: rgba(16, 185, 129, 0.1); border-radius: 10px; display: flex; align-items: center; justify-content: center;">
                                            <i class="fas fa-phone" style="color: var(--green);"></i>
                                        </div>
                                        <div>
                                            <strong>Phone</strong>
                                            <p style="opacity: 0.8; margin: 0;">+1 (555) 123-4567</p>
                                        </div>
                                    </div>

                                    <div style="display: flex; align-items: center; gap: 1rem;">
                                        <div style="width: 50px; height: 50px; background: rgba(16, 185, 129, 0.1); border-radius: 10px; display: flex; align-items: center; justify-content: center;">
                                            <i class="fas fa-envelope" style="color: var(--green);"></i>
                                        </div>
                                        <div>
                                            <strong>Email</strong>
                                            <p style="opacity: 0.8; margin: 0;">info@soorgreen.com</p>
                                        </div>
                                    </div>
                                </div>

                                <div class="social-links" style="margin-top: 2rem;">
                                    <a href="#" class="social-link"><i class="fab fa-twitter"></i></a>
                                    <a href="#" class="social-link"><i class="fab fa-linkedin"></i></a>
                                    <a href="#" class="social-link"><i class="fab fa-github"></i></a>
                                    <a href="#" class="social-link"><i class="fab fa-youtube"></i></a>
                                </div>
                            </div>
                        </div>

                        <div>
                            <div class="feature-card">
                                <h3 style="font-size: 1.5rem; margin-bottom: 1.5rem; color: white;">Send Message</h3>

                                <div style="margin-bottom: 1.5rem;">
                                    <input type="text" class="form-input" placeholder="Your Name" id="contactName">
                                </div>

                                <div style="margin-bottom: 1.5rem;">
                                    <input type="email" class="form-input" placeholder="Email Address" id="contactEmail">
                                </div>

                                <div style="margin-bottom: 1.5rem;">
                                    <input type="text" class="form-input" placeholder="Organization" id="contactOrg">
                                </div>

                                <div style="margin-bottom: 2rem;">
                                    <textarea class="form-input" rows="4" placeholder="Your Message" id="contactMessage"></textarea>
                                </div>

                                <button type="button" class="cta-btn" style="width: 100%;" onclick="submitContactForm()">
                                    <i class="fas fa-paper-plane"></i>Send Message
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
            </section>

            <!-- IMPROVED FOOTER -->
            <footer class="footer" id="footer">
                <div class="footer-bg"></div>
                <div class="footer-container">
                    <div class="footer-grid">
                        <!-- Brand Column -->
                        <div class="footer-brand">
                            <a href="#" class="footer-logo">
                                <%--<image src="favicon.ico" class="w-15 h-15" />--%>
                                SoorGreen
                            </a>
                            <p class="footer-description">
                                We're revolutionizing waste management through AI-powered solutions. 
                                Our mission is to create cleaner, smarter cities for future generations.
                            </p>

                            <div class="footer-newsletter">
                                <h3>Stay Updated</h3>
                                <p style="color: rgba(255,255,255,0.6); font-size: 0.95rem; margin-bottom: 15px;">
                                    Subscribe to our newsletter for the latest in sustainable tech.
                                </p>
                                <form class="newsletter-form" id="newsletterForm">
                                    <input type="email" class="newsletter-input" placeholder="Your email address" required>
                                    <button type="submit" class="newsletter-btn">
                                        <i class="fas fa-paper-plane"></i>
                                    </button>
                                </form>
                            </div>
                        </div>

                        <!-- Quick Links -->
                        <div class="footer-links-section">
                            <h3>Quick Links</h3>
                            <ul class="footer-links">
                                <li><a href="#home" class="footer-link"><i class="fas fa-home"></i>Home</a></li>
                                <li><a href="#features" class="footer-link"><i class="fas fa-star"></i>Features</a></li>
                                <li><a href="#team" class="footer-link"><i class="fas fa-users"></i>Our Team</a></li>
                                <li><a href="#case-studies" class="footer-link"><i class="fas fa-chart-bar"></i>Case Studies</a></li>
                                <li><a href="#research" class="footer-link"><i class="fas fa-flask"></i>Research</a></li>
                                <li><a href="ChooseApp.aspx" class="footer-link"><i class="fas fa-rocket"></i>Launch App</a></li>
                            </ul>
                        </div>

                        <!-- Solutions -->
                        <div class="footer-links-section">
                            <h3>Solutions</h3>
                            <ul class="footer-links">
                                <li><a href="#" class="footer-link"><i class="fas fa-robot"></i>AI Sorting</a></li>
                                <li><a href="#" class="footer-link"><i class="fas fa-route"></i>Smart Routing</a></li>
                                <li><a href="#" class="footer-link"><i class="fas fa-satellite-dish"></i>IoT Monitoring</a></li>
                                <li><a href="#" class="footer-link"><i class="fas fa-chart-line"></i>Analytics Dashboard</a></li>
                                <li><a href="#" class="footer-link"><i class="fas fa-mobile-alt"></i>Mobile Apps</a></li>
                                <li><a href="#" class="footer-link"><i class="fas fa-cloud"></i>Cloud Platform</a></li>
                            </ul>
                        </div>

                        <!-- Contact Info -->
                        <div class="footer-links-section">
                            <h3>Contact Us</h3>
                            <div class="footer-contact">
                                <div class="contact-item">
                                    <div class="contact-icon">
                                        <i class="fas fa-map-marker-alt"></i>
                                    </div>
                                    <div class="contact-info">
                                        <strong>Headquarters</strong>
                                        <p>
                                            Innovation District<br>
                                            Tech City, TC 10001
                                        </p>
                                    </div>
                                </div>
                                <div class="contact-item">
                                    <div class="contact-icon">
                                        <i class="fas fa-phone"></i>
                                    </div>
                                    <div class="contact-info">
                                        <strong>Phone Number</strong>
                                        <p>
                                            +1 (555) 123-4567<br>
                                            Mon-Fri, 9AM-6PM EST
                                        </p>
                                    </div>
                                </div>
                                <div class="contact-item">
                                    <div class="contact-icon">
                                        <i class="fas fa-envelope"></i>
                                    </div>
                                    <div class="contact-info">
                                        <strong>Email Address</strong>
                                        <p>
                                            info@soorgreen.com<br>
                                            support@soorgreen.com
                                        </p>
                                    </div>
                                </div>
                            </div>

                            <div class="footer-social-section">
                                <h4 class="footer-social-title">Follow Us</h4>
                                <div class="footer-social-links">
                                    <a href="#" class="footer-social-link" title="Twitter">
                                        <i class="fab fa-twitter"></i>
                                    </a>
                                    <a href="#" class="footer-social-link" title="LinkedIn">
                                        <i class="fab fa-linkedin-in"></i>
                                    </a>
                                    <a href="#" class="footer-social-link" title="GitHub">
                                        <i class="fab fa-github"></i>
                                    </a>
                                    <a href="#" class="footer-social-link" title="YouTube">
                                        <i class="fab fa-youtube"></i>
                                    </a>
                                    <a href="#" class="footer-social-link" title="Instagram">
                                        <i class="fab fa-instagram"></i>
                                    </a>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="footer-bottom">
                        <div class="footer-bottom-content">
                            <div class="copyright">
                                &copy; 2024 SoorGreen Technologies. All rights reserved.
                            </div>
                            <div class="footer-bottom-links">
                                <a href="#" class="footer-bottom-link">Privacy Policy</a>
                                <a href="#" class="footer-bottom-link">Terms of Service</a>
                                <a href="#" class="footer-bottom-link">Cookie Policy</a>
                                <a href="#" class="footer-bottom-link">Sitemap</a>
                            </div>
                        </div>
                        <div style="text-align: center; margin-top: 30px; color: rgba(255,255,255,0.3); font-size: 0.9rem;">
                            <p>Built with ❤️ by the SoorGreen Team: Zacki (AI), Abdirxeem (Research), Arafat (Marketing), Soe (Systems)</p>
                        </div>
                    </div>
                </div>
            </footer>
        </form>
    </div>

    <script>
        // Team Card Hover Effects
        function initTeamCards() {
            const teamCards = document.querySelectorAll('.team-card-wrapper');

            teamCards.forEach(card => {
                const teamCard = card.querySelector('.team-card');

                card.addEventListener('mouseenter', () => {
                    teamCard.style.transform = 'translateY(-20px) rotateX(5deg)';
                    teamCard.style.boxShadow = '0 30px 60px rgba(16, 185, 129, 0.3), 0 0 100px rgba(16, 185, 129, 0.1)';

                    // Add ripple effect
                    const ripple = document.createElement('div');
                    ripple.style.position = 'absolute';
                    ripple.style.top = '50%';
                    ripple.style.left = '50%';
                    ripple.style.width = '0';
                    ripple.style.height = '0';
                    ripple.style.borderRadius = '50%';
                    ripple.style.background = 'radial-gradient(circle, rgba(16, 185, 129, 0.2), transparent)';
                    ripple.style.transform = 'translate(-50%, -50%)';
                    ripple.style.transition = 'all 0.6s ease';
                    ripple.style.zIndex = '1';
                    card.appendChild(ripple);

                    setTimeout(() => {
                        ripple.style.width = '400px';
                        ripple.style.height = '400px';
                        ripple.style.opacity = '0';
                    }, 10);

                    setTimeout(() => {
                        if (ripple.parentNode === card) {
                            card.removeChild(ripple);
                        }
                    }, 600);
                });

                card.addEventListener('mouseleave', () => {
                    teamCard.style.transform = 'translateY(0) rotateX(0)';
                    teamCard.style.boxShadow = 'none';
                });
            });
        }

        // Newsletter Form
        document.getElementById('newsletterForm')?.addEventListener('submit', function (e) {
            e.preventDefault();
            const email = this.querySelector('input[type="email"]').value;

            // Show success message
            const button = this.querySelector('button');
            const originalText = button.innerHTML;
            button.innerHTML = '<i class="fas fa-check"></i>';
            button.style.background = 'linear-gradient(135deg, #10b981, #0d9488)';

            setTimeout(() => {
                button.innerHTML = originalText;
                this.reset();
                alert(`Thank you! You've been subscribed with: ${email}`);
            }, 1500);
        });

        // Contact Form Submission
        function submitContactForm() {
            const name = document.getElementById('contactName').value;
            const email = document.getElementById('contactEmail').value;
            const org = document.getElementById('contactOrg').value;
            const message = document.getElementById('contactMessage').value;

            if (!name || !email || !message) {
                alert('Please fill in all required fields.');
                return;
            }

            alert(`Thank you ${name}! Your message has been sent. We'll contact you at ${email} soon.`);

            // Reset form
            document.getElementById('contactName').value = '';
            document.getElementById('contactEmail').value = '';
            document.getElementById('contactOrg').value = '';
            document.getElementById('contactMessage').value = '';
        }

        // Smooth Scrolling
        document.querySelectorAll('a[href^="#"]').forEach(anchor => {
            anchor.addEventListener('click', function (e) {
                e.preventDefault();
                const targetId = this.getAttribute('href');
                if (targetId === '#') return;

                const targetElement = document.querySelector(targetId);
                if (targetElement) {
                    window.scrollTo({
                        top: targetElement.offsetTop - 80,
                        behavior: 'smooth'
                    });
                }
            });
        });

        // Navigation Scroll Effect
        window.addEventListener('scroll', function () {
            const nav = document.querySelector('.nav-container');
            const navLinks = document.querySelectorAll('.nav-link');

            if (window.scrollY > 100) {
                nav.style.background = 'rgba(15, 23, 42, 0.98)';
            } else {
                nav.style.background = 'rgba(15, 23, 42, 0.95)';
            }

            // Update active nav link
            const sections = document.querySelectorAll('section');
            let current = '';

            sections.forEach(section => {
                const sectionTop = section.offsetTop - 100;
                if (window.scrollY >= sectionTop) {
                    current = section.getAttribute('id');
                }
            });

            navLinks.forEach(link => {
                link.classList.remove('active');
                if (link.getAttribute('href') === `#${current}`) {
                    link.classList.add('active');
                }
            });
        });

        // Initialize everything when page loads
        document.addEventListener('DOMContentLoaded', function () {
            initTeamCards();

            // Add floating animation to team cards
            const teamCards = document.querySelectorAll('.team-card-wrapper');
            teamCards.forEach((card, index) => {
                card.style.animationDelay = `${index * 0.1}s`;
                card.classList.add('float-animation');
            });
        });

        // Add CSS for float animation and social link colors
        const style = document.createElement('style');
        style.textContent = `
            .float-animation {
                animation: float 6s ease-in-out infinite;
            }
            
            @keyframes float {
                0%, 100% { transform: translateY(0); }
                50% { transform: translateY(-10px); }
            }
            
            .team-card-wrapper:nth-child(2) { animation-delay: 0.2s; }
            .team-card-wrapper:nth-child(3) { animation-delay: 0.4s; }
            .team-card-wrapper:nth-child(4) { animation-delay: 0.6s; }
            
            .footer-social-link:nth-child(1):hover { background: #1DA1F2 !important; }
            .footer-social-link:nth-child(2):hover { background: #0077B5 !important; }
            .footer-social-link:nth-child(3):hover { background: #333 !important; }
            .footer-social-link:nth-child(4):hover { background: #FF0000 !important; }
            .footer-social-link:nth-child(5):hover { background: #E4405F !important; }
            
            .social-links {
                display: flex;
                gap: 1rem;
            }
            
            .social-link {
                width: 45px;
                height: 45px;
                background: rgba(255, 255, 255, 0.05);
                border-radius: 50%;
                display: flex;
                align-items: center;
                justify-content: center;
                color: white;
                text-decoration: none;
                transition: all 0.3s ease;
            }
            
            .social-link:hover {
                background: var(--green);
                transform: translateY(-3px);
            }
        `;
        document.head.appendChild(style);

        // Gallery data with random images from Unsplash (using specific tech/waste management related images)
        const galleryData = [
            {
                id: 1,
                title: "Smart Waste Bin Deployment",
                description: "IoT-enabled smart bins deployed in urban areas for real-time monitoring of waste levels.",
                image: "https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?ixlib=rb-4.0.3&auto=format&fit=crop&w=1200&q=80",
                category: "smart-bins",
                location: "Singapore",
                date: "2024"
            },
            {
                id: 2,
                title: "AI Sorting Facility",
                description: "Our advanced AI sorting system processing 5 tons of waste per hour with 98% accuracy.",
                image: "https://images.unsplash.com/photo-1558618666-fcd25c85cd64?ixlib=rb-4.0.3&auto=format&fit=crop&w=1200&q=80",
                category: "ai-sorting",
                location: "Amsterdam",
                date: "2023"
            },
            {
                id: 3,
                title: "Recycling Center Automation",
                description: "Fully automated recycling plant with robotic arms and conveyor systems.",
                image: "https://images.unsplash.com/photo-1581094794329-c8112a89af12?ixlib=rb-4.0.3&auto=format&fit=crop&w=1200&q=80",
                category: "ai-sorting",
                location: "Tokyo",
                date: "2024"
            },
            {
                id: 4,
                title: "IoT Monitoring Dashboard",
                description: "Real-time monitoring dashboard showing waste collection routes and bin status.",
                image: "https://images.unsplash.com/photo-1551288049-bebda4e38f71?ixlib=rb-4.0.3&auto=format&fit=crop&w=1200&q=80",
                category: "iot",
                location: "San Francisco",
                date: "2024"
            },
            {
                id: 5,
                title: "Community Cleanup Program",
                description: "Local community participating in our plastic waste cleanup initiative.",
                image: "https://images.unsplash.com/photo-1604187351574-c75ca79f5807?ixlib=rb-4.0.3&auto=format&fit=crop&w=1200&q=80",
                category: "community",
                location: "Mumbai",
                date: "2023"
            },
            {
                id: 6,
                title: "Smart City Integration",
                description: "Integration with city infrastructure for seamless waste management operations.",
                image: "https://images.unsplash.com/photo-1480714378408-67cf0d13bc1b?ixlib=rb-4.0.3&auto=format&fit=crop&w=1200&q=80",
                category: "smart-bins",
                location: "Dubai",
                date: "2024"
            },
            {
                id: 7,
                title: "E-Waste Processing",
                description: "Specialized facility for electronic waste recycling and material recovery.",
                image: "https://images.unsplash.com/photo-1581094794329-c8112a89af12?ixlib=rb-4.0.3&auto=format&fit=crop&w=1200&q=80",
                category: "ai-sorting",
                location: "Berlin",
                date: "2023"
            },
            {
                id: 8,
                title: "Mobile Waste Collection",
                description: "Smart routing system optimizing collection routes for mobile waste collection units.",
                image: "https://images.unsplash.com/photo-1532996122724-e3c354a0b15b?ixlib=rb-4.0.3&auto=format&fit=crop&w=1200&q=80",
                category: "iot",
                location: "London",
                date: "2024"
            },
            {
                id: 9,
                title: "Educational Workshop",
                description: "Community education program on sustainable waste management practices.",
                image: "https://images.unsplash.com/photo-1523240795612-9a054b0db644?ixlib=rb-4.0.3&auto=format&fit=crop&w=1200&q=80",
                category: "community",
                location: "Toronto",
                date: "2023"
            },
            {
                id: 10,
                title: "Plastic Recycling Plant",
                description: "Advanced plastic recycling facility transforming waste into reusable materials.",
                image: "https://images.unsplash.com/photo-1581094794329-c8112a89af12?ixlib=rb-4.0.3&auto=format&fit=crop&w=1200&q=80",
                category: "ai-sorting",
                location: "Seoul",
                date: "2024"
            },
            {
                id: 11,
                title: "Smart Bin Network",
                description: "Network of interconnected smart bins providing city-wide coverage.",
                image: "https://images.unsplash.com/photo-1519003722824-194d4455a60e?ixlib=rb-4.0.3&auto=format&fit=crop&w=1200&q=80",
                category: "smart-bins",
                location: "New York",
                date: "2024"
            },
            {
                id: 12,
                title: "Data Analytics Center",
                description: "Our data analytics team monitoring waste patterns and optimizing operations.",
                image: "https://images.unsplash.com/photo-1551288049-bebda4e38f71?ixlib=rb-4.0.3&auto=format&fit=crop&w=1200&q=80",
                category: "iot",
                location: "Austin",
                date: "2023"
            }
        ];

        let currentItems = 6;
        let currentFilter = 'all';
        let currentLightboxIndex = 0;

        // Initialize gallery
        function initGallery() {
            renderGallery();
            setupEventListeners();
        }

        // Render gallery items
        function renderGallery() {
            const galleryGrid = document.getElementById('galleryGrid');
            galleryGrid.innerHTML = '';

            const filteredData = currentFilter === 'all'
                ? galleryData.slice(0, currentItems)
                : galleryData.filter(item => item.category === currentFilter).slice(0, currentItems);

            if (filteredData.length === 0) {
                galleryGrid.innerHTML = `
                <div class="text-center" style="grid-column: 1 / -1; padding: 3rem; color: rgba(255,255,255,0.5);">
                    <i class="fas fa-images" style="font-size: 3rem; margin-bottom: 1rem;"></i>
                    <h3>No projects found in this category</h3>
                </div>
            `;
                return;
            }

            filteredData.forEach((item, index) => {
                const galleryItem = document.createElement('div');
                galleryItem.className = 'gallery-item';
                galleryItem.setAttribute('data-category', item.category);
                galleryItem.setAttribute('data-index', index);

                galleryItem.innerHTML = `
                <img src="${item.image}" alt="${item.title}" loading="lazy">
                <div class="gallery-overlay">
                    <span class="gallery-category">${getCategoryLabel(item.category)}</span>
                    <h3 class="gallery-title">${item.title}</h3>
                    <p class="gallery-description">${item.description}</p>
                </div>
            `;

                galleryItem.addEventListener('click', () => openLightbox(item, index));
                galleryGrid.appendChild(galleryItem);
            });
        }

        // Get category label
        function getCategoryLabel(category) {
            const labels = {
                'smart-bins': 'Smart Bins',
                'ai-sorting': 'AI Sorting',
                'iot': 'IoT Systems',
                'community': 'Community'
            };
            return labels[category] || category;
        }

        // Setup event listeners
        function setupEventListeners() {
            // Tab filters
            document.querySelectorAll('.gallery-tab').forEach(tab => {
                tab.addEventListener('click', () => {
                    document.querySelectorAll('.gallery-tab').forEach(t => t.classList.remove('active'));
                    tab.classList.add('active');
                    currentFilter = tab.getAttribute('data-filter');
                    currentItems = 6;
                    renderGallery();
                });
            });

            // Load more button
            const loadMoreBtn = document.getElementById('loadMoreBtn');
            if (loadMoreBtn) {
                loadMoreBtn.addEventListener('click', () => {
                    currentItems += 6;
                    renderGallery();

                    // Hide button if all items are loaded
                    const totalItems = currentFilter === 'all'
                        ? galleryData.length
                        : galleryData.filter(item => item.category === currentFilter).length;

                    if (currentItems >= totalItems) {
                        loadMoreBtn.style.display = 'none';
                    }
                });
            }

            // Lightbox controls
            const lightbox = document.getElementById('lightbox');
            const closeBtn = document.getElementById('closeLightbox');
            const prevBtn = document.getElementById('prevBtn');
            const nextBtn = document.getElementById('nextBtn');

            closeBtn.addEventListener('click', closeLightbox);
            prevBtn.addEventListener('click', showPrevImage);
            nextBtn.addEventListener('click', showNextImage);

            // Close lightbox on ESC key
            document.addEventListener('keydown', (e) => {
                if (e.key === 'Escape') closeLightbox();
                if (e.key === 'ArrowLeft') showPrevImage();
                if (e.key === 'ArrowRight') showNextImage();
            });

            // Close lightbox on background click
            lightbox.addEventListener('click', (e) => {
                if (e.target === lightbox) closeLightbox();
            });
        }

        // Open lightbox
        function openLightbox(item, index) {
            const lightbox = document.getElementById('lightbox');
            const lightboxImage = document.getElementById('lightboxImage');
            const lightboxTitle = document.getElementById('lightboxTitle');
            const lightboxDescription = document.getElementById('lightboxDescription');
            const lightboxLocation = document.getElementById('lightboxLocation');
            const lightboxDate = document.getElementById('lightboxDate');
            const lightboxCategory = document.getElementById('lightboxCategory');

            currentLightboxIndex = galleryData.findIndex(i => i.id === item.id);

            lightboxImage.src = item.image;
            lightboxImage.alt = item.title;
            lightboxTitle.textContent = item.title;
            lightboxDescription.textContent = item.description;
            lightboxLocation.textContent = item.location;
            lightboxDate.textContent = item.date;
            lightboxCategory.textContent = getCategoryLabel(item.category);

            lightbox.classList.add('active');
            document.body.style.overflow = 'hidden';
        }

        // Close lightbox
        function closeLightbox() {
            const lightbox = document.getElementById('lightbox');
            lightbox.classList.remove('active');
            document.body.style.overflow = '';
        }

        // Show previous image
        function showPrevImage() {
            currentLightboxIndex = (currentLightboxIndex - 1 + galleryData.length) % galleryData.length;
            const item = galleryData[currentLightboxIndex];
            openLightbox(item, currentLightboxIndex);
        }

        // Show next image
        function showNextImage() {
            currentLightboxIndex = (currentLightboxIndex + 1) % galleryData.length;
            const item = galleryData[currentLightboxIndex];
            openLightbox(item, currentLightboxIndex);
        }

        // Initialize on page load
        document.addEventListener('DOMContentLoaded', initGallery);

        // Video Library Data
        const videoLibrary = {
            videos: [
                {
                    id: 1,
                    title: "AI Waste Sorting System Demo",
                    description: "See our AI-powered waste sorting system in action with real-time processing.",
                    thumbnail: "https://images.unsplash.com/photo-1558618666-fcd25c85cd64?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80",
                    videoId: "dQw4w9WgXcQ", // YouTube video ID
                    duration: "8:45",
                    views: "12,584",
                    date: "1 week ago",
                    category: "demos",
                    featured: true
                },
                {
                    id: 2,
                    title: "Smart Bin Installation Tutorial",
                    description: "Step-by-step guide to installing and configuring IoT smart bins.",
                    thumbnail: "https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80",
                    videoId: "9bZkp7q19f0",
                    duration: "12:30",
                    views: "8,956",
                    date: "2 weeks ago",
                    category: "tutorials"
                },
                {
                    id: 3,
                    title: "City of Tokyo Case Study",
                    description: "How Tokyo reduced waste by 40% using our intelligent routing system.",
                    thumbnail: "https://images.unsplash.com/photo-1540959733332-eab4deabeeaf?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80",
                    videoId: "CevxZvSJLk8",
                    duration: "15:20",
                    views: "23,145",
                    date: "3 weeks ago",
                    category: "case-studies"
                },
                {
                    id: 4,
                    title: "CEO Interview on Sustainability",
                    description: "Our CEO discusses the future of sustainable waste management.",
                    thumbnail: "https://images.unsplash.com/photo-1582213782179-e0d53f98f2ca?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80",
                    videoId: "L_jWHffIx5E",
                    duration: "22:10",
                    views: "15,789",
                    date: "1 month ago",
                    category: "interviews"
                },
                {
                    id: 5,
                    title: "Mobile App Walkthrough",
                    description: "Complete guide to using our mobile application for waste management.",
                    thumbnail: "https://images.unsplash.com/photo-1558618666-fcd25c85cd64?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80",
                    videoId: "dQw4w9WgXcQ",
                    duration: "10:15",
                    views: "7,845",
                    date: "5 days ago",
                    category: "tutorials"
                },
                {
                    id: 6,
                    title: "Smart Routing Algorithm Explained",
                    description: "Deep dive into our intelligent routing algorithms for waste collection.",
                    thumbnail: "https://images.unsplash.com/photo-1551288049-bebda4e38f71?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80",
                    videoId: "9bZkp7q19f0",
                    duration: "18:45",
                    views: "9,123",
                    date: "2 months ago",
                    category: "demos"
                },
                {
                    id: 7,
                    title: "Community Engagement Program",
                    description: "How we're working with communities to promote recycling.",
                    thumbnail: "https://images.unsplash.com/photo-1523240795612-9a054b0db644?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80",
                    videoId: "CevxZvSJLk8",
                    duration: "14:20",
                    views: "11,456",
                    date: "3 weeks ago",
                    category: "case-studies"
                },
                {
                    id: 8,
                    title: "Technical Support Q&A",
                    description: "Live Q&A session with our technical support team.",
                    thumbnail: "https://images.unsplash.com/photo-1551288049-bebda4e38f71?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80",
                    videoId: "L_jWHffIx5E",
                    duration: "45:30",
                    views: "6,789",
                    date: "1 week ago",
                    category: "tutorials"
                }
            ],
            playlists: [
                {
                    id: 1,
                    title: "Getting Started",
                    description: "Learn the basics of SoorGreen platform",
                    thumbnail: "https://images.unsplash.com/photo-1581094794329-c8112a89af12?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&q=80",
                    videoCount: 8
                },
                {
                    id: 2,
                    title: "Advanced Features",
                    description: "Master advanced AI and IoT features",
                    thumbnail: "https://images.unsplash.com/photo-1551288049-bebda4e38f71?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&q=80",
                    videoCount: 12
                },
                {
                    id: 3,
                    title: "Success Stories",
                    description: "Real-world implementations and case studies",
                    thumbnail: "https://images.unsplash.com/photo-1523240795612-9a054b0db644?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&q=80",
                    videoCount: 6
                }
            ]
        };

        let currentVideoCategory = 'all';
        let currentPlayingVideo = null;

        // Initialize Video Library
        function initVideoLibrary() {
            renderFeaturedVideo();
            renderVideoGrid();
            setupVideoEventListeners();
        }

        // Render Featured Video
        function renderFeaturedVideo() {
            const featuredVideo = videoLibrary.videos.find(video => video.featured);
            if (featuredVideo) {
                const featuredVideoPlayer = document.getElementById('featuredVideoPlayer');
                featuredVideoPlayer.setAttribute('data-video-id', featuredVideo.id);

                // Update video details
                const videoTitle = featuredVideoPlayer.querySelector('.video-title');
                const videoDescription = featuredVideoPlayer.querySelector('.video-description');
                const videoMeta = featuredVideoPlayer.querySelector('.video-meta');

                videoTitle.textContent = featuredVideo.title;
                videoDescription.textContent = featuredVideo.description;
                videoMeta.innerHTML = `
                <span><i class="fas fa-clock"></i> ${featuredVideo.duration}</span>
                <span><i class="fas fa-eye"></i> ${featuredVideo.views} views</span>
                <span><i class="fas fa-calendar"></i> ${featuredVideo.date}</span>
            `;
            }
        }

        // Render Video Grid
        function renderVideoGrid() {
            const videoGrid = document.getElementById('videoGrid');
            videoGrid.innerHTML = '';

            const filteredVideos = currentVideoCategory === 'all'
                ? videoLibrary.videos.filter(video => !video.featured)
                : videoLibrary.videos.filter(video => video.category === currentVideoCategory && !video.featured);

            if (filteredVideos.length === 0) {
                videoGrid.innerHTML = `
                <div class="no-videos" style="grid-column: 1 / -1; text-align: center; padding: 3rem; color: rgba(255,255,255,0.5);">
                    <i class="fas fa-video-slash" style="font-size: 3rem; margin-bottom: 1rem;"></i>
                    <h3>No videos found in this category</h3>
                    <p>Check back soon for new content!</p>
                </div>
            `;
                return;
            }

            filteredVideos.forEach(video => {
                const videoCard = document.createElement('div');
                videoCard.className = 'video-card';
                videoCard.setAttribute('data-video-id', video.id);

                videoCard.innerHTML = `
                <div class="video-thumb-container">
                    <img src="${video.thumbnail}" alt="${video.title}" loading="lazy">
                    <div class="video-card-overlay">
                        <div class="play-icon-small">
                            <i class="fas fa-play"></i>
                        </div>
                    </div>
                    <span class="video-duration">${video.duration}</span>
                </div>
                <div class="video-card-content">
                    <h3 class="video-card-title">${video.title}</h3>
                    <p class="video-card-description">${video.description}</p>
                    <div class="video-card-meta">
                        <span><i class="fas fa-eye"></i> ${video.views} views</span>
                        <span class="video-card-category">${getCategoryLabel(video.category)}</span>
                    </div>
                </div>
            `;

                videoCard.addEventListener('click', () => playVideo(video));
                videoGrid.appendChild(videoCard);
            });
        }

        // Get category label
        function getCategoryLabel(category) {
            const labels = {
                'demos': 'Demo',
                'tutorials': 'Tutorial',
                'case-studies': 'Case Study',
                'interviews': 'Interview'
            };
            return labels[category] || category;
        }

        // Setup event listeners
        function setupVideoEventListeners() {
            // Category tabs
            document.querySelectorAll('.category-tab').forEach(tab => {
                tab.addEventListener('click', () => {
                    document.querySelectorAll('.category-tab').forEach(t => t.classList.remove('active'));
                    tab.classList.add('active');
                    currentVideoCategory = tab.getAttribute('data-category');
                    renderVideoGrid();
                });
            });

            // Featured video click
            const featuredVideoPlayer = document.getElementById('featuredVideoPlayer');
            featuredVideoPlayer.addEventListener('click', () => {
                const videoId = featuredVideoPlayer.getAttribute('data-video-id');
                const video = videoLibrary.videos.find(v => v.id == videoId);
                if (video) playVideo(video);
            });

            // Modal close button
            const closeModalBtn = document.getElementById('closeModal');
            closeModalBtn.addEventListener('click', closeVideoModal);

            // Close modal on overlay click
            const modalOverlay = document.querySelector('.modal-overlay');
            modalOverlay.addEventListener('click', closeVideoModal);

            // Close modal on ESC key
            document.addEventListener('keydown', (e) => {
                if (e.key === 'Escape') closeVideoModal();
            });

            // Playlist cards
            document.querySelectorAll('.playlist-card').forEach((card, index) => {
                card.addEventListener('click', () => {
                    const playlist = videoLibrary.playlists[index];
                    alert(`Opening playlist: ${playlist.title}\nThis would load ${playlist.videoCount} videos.`);
                });
            });
        }

        // Play video in modal
        function playVideo(video) {
            const modal = document.getElementById('videoModal');
            const videoPlayer = document.getElementById('modalVideoPlayer');
            const videoTitle = document.getElementById('modalVideoTitle');
            const videoDescription = document.getElementById('modalVideoDescription');
            const videoViews = document.getElementById('modalVideoViews');
            const videoDate = document.getElementById('modalVideoDate');

            // Load YouTube iframe
            videoPlayer.innerHTML = `
            <iframe src="https://www.youtube.com/embed/${video.videoId}?autoplay=1&rel=0&modestbranding=1"
                    frameborder="0"
                    allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
                    allowfullscreen>
            </iframe>
        `;

            // Update video info
            videoTitle.textContent = video.title;
            videoDescription.textContent = video.description;
            videoViews.textContent = `${video.views} views`;
            videoDate.textContent = video.date;

            // Store current playing video
            currentPlayingVideo = video;

            // Show modal
            modal.classList.add('active');
            document.body.style.overflow = 'hidden';
        }

        // Close video modal
        function closeVideoModal() {
            const modal = document.getElementById('videoModal');
            const videoPlayer = document.getElementById('modalVideoPlayer');

            // Stop video
            videoPlayer.innerHTML = '';

            // Hide modal
            modal.classList.remove('active');
            document.body.style.overflow = '';

            currentPlayingVideo = null;
        }

        // Initialize on page load
        document.addEventListener('DOMContentLoaded', initVideoLibrary);
    </script>
</body>
</html>
