<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ChooseApp.aspx.cs" Inherits="SoorGreen.Main.ChooseApp1" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <title>Choose Your SoorGreen Experience</title>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" />
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet" />
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet" />
    <link href="https://unpkg.com/aos@2.3.1/dist/aos.css" rel="stylesheet" />
    <style>
        /* Your existing CSS remains exactly the same */
        :root {
            --primary: #2563eb;
            --primary-dark: #1d4ed8;
            --secondary: #7c3aed;
            --accent: #f59e0b;
            --success: #10b981;
            --dark: #0f172a;
            --darker: #020617;
            --light: #f8fafc;
            --card-bg: rgba(30, 41, 59, 0.8);
            --card-border: rgba(255, 255, 255, 0.1);
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Inter', sans-serif;
            background: linear-gradient(135deg, var(--darker) 0%, var(--dark) 50%, #1e293b 100%);
            min-height: 100vh;
            color: var(--light);
            overflow-x: hidden;
        }

        /* All your existing CSS styles remain exactly the same */
        .header-section {
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 2rem;
            position: relative;
        }

        .header-bg {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: 
                radial-gradient(circle at 20% 80%, rgba(37, 99, 235, 0.15) 0%, transparent 50%),
                radial-gradient(circle at 80% 20%, rgba(124, 58, 237, 0.15) 0%, transparent 50%),
                radial-gradient(circle at 40% 40%, rgba(245, 158, 11, 0.1) 0%, transparent 50%);
            animation: float 8s ease-in-out infinite;
        }

        @keyframes float {
            0%, 100% { transform: translateY(0px) rotate(0deg); }
            33% { transform: translateY(-20px) rotate(1deg); }
            66% { transform: translateY(10px) rotate(-1deg); }
        }

        .header-content {
            position: relative;
            z-index: 2;
            text-align: center;
            max-width: 1200px;
            width: 100%;
        }

        .logo {
            font-size: 5rem;
            margin-bottom: 1.5rem;
            color: var(--accent);
            animation: bounce 3s ease infinite;
            text-shadow: 0 0 30px rgba(245, 158, 11, 0.3);
            filter: drop-shadow(0 0 20px rgba(245, 158, 11, 0.4));
        }

        @keyframes bounce {
            0%, 20%, 50%, 80%, 100% { transform: translateY(0) scale(1); }
            40% { transform: translateY(-20px) scale(1.1); }
            60% { transform: translateY(-10px) scale(1.05); }
        }

        .header-title {
            font-size: 4rem;
            font-weight: 800;
            margin-bottom: 1.5rem;
            background: linear-gradient(45deg, var(--light), #cbd5e1, var(--accent));
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            text-shadow: 0 0 30px rgba(255, 255, 255, 0.1);
            animation: titleGlow 3s ease-in-out infinite alternate;
        }

        @keyframes titleGlow {
            from { text-shadow: 0 0 20px rgba(255, 255, 255, 0.1); }
            to { text-shadow: 0 0 30px rgba(255, 255, 255, 0.3), 0 0 40px rgba(37, 99, 235, 0.2); }
        }

        .header-subtitle {
            font-size: 1.4rem;
            margin-bottom: 3rem;
            opacity: 0.9;
            font-weight: 300;
            max-width: 600px;
            margin-left: auto;
            margin-right: auto;
            line-height: 1.6;
            animation: fadeInUp 1s ease-out;
        }

        @keyframes fadeInUp {
            from {
                opacity: 0;
                transform: translateY(30px);
            }
            to {
                opacity: 0.9;
                transform: translateY(0);
            }
        }

        /* Stats Section */
        .stats-section {
            padding: 80px 0;
            background: rgba(15, 23, 42, 0.5);
            backdrop-filter: blur(20px);
            position: relative;
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
            padding: 2rem;
            background: var(--card-bg);
            border-radius: 20px;
            border: 1px solid var(--card-border);
            backdrop-filter: blur(10px);
            transition: all 0.3s ease;
            position: relative;
            overflow: hidden;
        }

        .stat-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: -100%;
            width: 100%;
            height: 100%;
            background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.05), transparent);
            transition: left 0.5s ease;
        }

        .stat-card:hover::before {
            left: 100%;
        }

        .stat-card:hover {
            transform: translateY(-10px) scale(1.05);
            border-color: rgba(37, 99, 235, 0.3);
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.4);
        }

        .stat-number {
            font-size: 3rem;
            font-weight: 700;
            color: var(--accent);
            display: block;
            margin-bottom: 0.5rem;
            text-shadow: 0 0 20px rgba(245, 158, 11, 0.3);
        }

        .stat-label {
            font-size: 1rem;
            opacity: 0.8;
            text-transform: uppercase;
            letter-spacing: 1px;
        }

        /* Apps Section */
        .apps-section {
            padding: 100px 0;
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
            animation: titlePulse 2s ease-in-out infinite;
        }

        @keyframes titlePulse {
            0%, 100% { transform: scale(1); }
            50% { transform: scale(1.02); }
        }

        .section-subtitle {
            font-size: 1.3rem;
            text-align: center;
            margin-bottom: 4rem;
            opacity: 0.8;
            max-width: 600px;
            margin-left: auto;
            margin-right: auto;
            line-height: 1.6;
        }

        .apps-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(400px, 1fr));
            gap: 2rem;
            max-width: 1400px;
            margin: 0 auto;
            padding: 0 2rem;
        }

        .app-card {
            background: var(--card-bg);
            border-radius: 25px;
            padding: 2.5rem;
            backdrop-filter: blur(15px);
            border: 1px solid var(--card-border);
            transition: all 0.4s ease;
            cursor: pointer;
            position: relative;
            overflow: hidden;
            text-align: left;
        }

        .app-card::after {
            content: '';
            position: absolute;
            top: -50%;
            left: -50%;
            width: 200%;
            height: 200%;
            background: linear-gradient(45deg, transparent, rgba(255, 255, 255, 0.03), transparent);
            transform: rotate(45deg);
            transition: all 0.6s ease;
        }

        .app-card:hover::after {
            transform: rotate(45deg) translate(20px, 20px);
        }

        .app-card:hover {
            transform: translateY(-15px) scale(1.02);
            border-color: rgba(37, 99, 235, 0.3);
            box-shadow: 0 25px 50px rgba(0, 0, 0, 0.4);
        }

        .app-icon {
            font-size: 3.5rem;
            margin-bottom: 1.5rem;
            color: var(--accent);
            background: rgba(255, 255, 255, 0.05);
            width: 90px;
            height: 90px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            border: 2px solid rgba(245, 158, 11, 0.2);
            transition: all 0.3s ease;
            animation: iconFloat 3s ease-in-out infinite;
        }

        @keyframes iconFloat {
            0%, 100% { transform: translateY(0px) rotate(0deg); }
            50% { transform: translateY(-10px) rotate(5deg); }
        }

        .app-card:hover .app-icon {
            transform: scale(1.1) rotate(10deg);
            background: rgba(245, 158, 11, 0.1);
            border-color: rgba(245, 158, 11, 0.4);
        }

        .app-title {
            font-size: 1.8rem;
            font-weight: 700;
            margin-bottom: 1rem;
            color: white;
            transition: all 0.3s ease;
        }

        .app-card:hover .app-title {
            color: var(--accent);
            text-shadow: 0 0 20px rgba(245, 158, 11, 0.3);
        }

        .app-subtitle {
            font-size: 1.1rem;
            opacity: 0.8;
            margin-bottom: 1.5rem;
            line-height: 1.6;
            transition: all 0.3s ease;
        }

        .app-card:hover .app-subtitle {
            opacity: 1;
        }

        .app-features {
            list-style: none;
            margin-bottom: 2rem;
        }

        .app-features li {
            padding: 0.6rem 0;
            opacity: 0.8;
            display: flex;
            align-items: center;
            gap: 0.8rem;
            transition: all 0.3s ease;
            transform: translateX(0);
        }

        .app-features li:hover {
            opacity: 1;
            transform: translateX(10px);
            color: var(--accent);
        }

        .app-features li i {
            color: var(--success);
            font-size: 1rem;
            transition: all 0.3s ease;
        }

        .app-features li:hover i {
            transform: scale(1.2);
            color: var(--accent);
        }

        .app-button {
            background: linear-gradient(45deg, var(--primary), var(--secondary));
            border: none;
            padding: 1.2rem 2.5rem;
            border-radius: 50px;
            color: white;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            width: 100%;
            font-size: 1.1rem;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 0.8rem;
            position: relative;
            overflow: hidden;
        }

        .app-button::before {
            content: '';
            position: absolute;
            top: 0;
            left: -100%;
            width: 100%;
            height: 100%;
            background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.2), transparent);
            transition: left 0.5s ease;
        }

        .app-button:hover::before {
            left: 100%;
        }

        .app-button:hover {
            transform: translateY(-3px);
            box-shadow: 0 15px 30px rgba(37, 99, 235, 0.4);
            background: linear-gradient(45deg, var(--primary-dark), var(--secondary));
        }

        .tech-tags {
            display: flex;
            flex-wrap: wrap;
            gap: 0.5rem;
            margin-top: 1.5rem;
        }

        .tech-tag {
            background: rgba(255, 255, 255, 0.08);
            padding: 0.4rem 1rem;
            border-radius: 20px;
            font-size: 0.8rem;
            opacity: 0.8;
            border: 1px solid rgba(255, 255, 255, 0.1);
            transition: all 0.3s ease;
            animation: tagPulse 2s ease-in-out infinite;
        }

        @keyframes tagPulse {
            0%, 100% { transform: scale(1); }
            50% { transform: scale(1.05); }
        }

        .tech-tag:hover {
            opacity: 1;
            background: rgba(37, 99, 235, 0.2);
            border-color: var(--primary);
            transform: translateY(-2px);
        }

        .card-webform {
            border-top: 5px solid #e44d26;
        }

        .card-mvc {
            border-top: 5px solid #512bd4;
        }

        .card-api {
            border-top: 5px solid #ff6b35;
        }

        .user-role {
            display: inline-block;
            background: var(--accent);
            color: var(--darker);
            padding: 0.4rem 1.2rem;
            border-radius: 25px;
            font-size: 0.8rem;
            font-weight: 700;
            margin-bottom: 1rem;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            animation: roleBounce 2s ease-in-out infinite;
        }

        @keyframes roleBounce {
            0%, 20%, 50%, 80%, 100% { transform: translateY(0); }
            40% { transform: translateY(-5px); }
            60% { transform: translateY(-3px); }
        }

        /* Features Section */
        .features-section {
            padding: 100px 0;
            background: rgba(15, 23, 42, 0.3);
        }

        .features-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 2rem;
            max-width: 1200px;
            margin: 0 auto;
            padding: 0 2rem;
        }

        .feature-item {
            text-align: center;
            padding: 2.5rem;
            background: var(--card-bg);
            border-radius: 20px;
            border: 1px solid var(--card-border);
            transition: all 0.3s ease;
            position: relative;
            overflow: hidden;
        }

        .feature-item::before {
            content: '';
            position: absolute;
            top: 0;
            left: -100%;
            width: 100%;
            height: 100%;
            background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.03), transparent);
            transition: left 0.5s ease;
        }

        .feature-item:hover::before {
            left: 100%;
        }

        .feature-item:hover {
            transform: translateY(-10px) scale(1.02);
            border-color: var(--primary);
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.3);
        }

        .feature-icon {
            font-size: 3rem;
            color: var(--accent);
            margin-bottom: 1.5rem;
            animation: iconSpin 4s linear infinite;
        }

        @keyframes iconSpin {
            0% { transform: rotate(0deg) scale(1); }
            50% { transform: rotate(180deg) scale(1.1); }
            100% { transform: rotate(360deg) scale(1); }
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

        /* CTA Section */
        .cta-section {
            padding: 100px 0;
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
            background: linear-gradient(45deg, var(--accent), var(--primary));
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            animation: ctaGlow 2s ease-in-out infinite alternate;
        }

        @keyframes ctaGlow {
            from { text-shadow: 0 0 20px rgba(245, 158, 11, 0.3); }
            to { text-shadow: 0 0 30px rgba(245, 158, 11, 0.6), 0 0 40px rgba(37, 99, 235, 0.4); }
        }

        .cta-subtitle {
            font-size: 1.3rem;
            margin-bottom: 3rem;
            opacity: 0.8;
            line-height: 1.6;
        }

        .cta-buttons {
            display: flex;
            gap: 1.5rem;
            justify-content: center;
            flex-wrap: wrap;
        }

        .cta-button {
            padding: 1.2rem 2.5rem;
            border-radius: 50px;
            font-weight: 600;
            text-decoration: none;
            transition: all 0.3s ease;
            display: flex;
            align-items: center;
            gap: 0.8rem;
            position: relative;
            overflow: hidden;
        }

        .cta-button::before {
            content: '';
            position: absolute;
            top: 0;
            left: -100%;
            width: 100%;
            height: 100%;
            background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.2), transparent);
            transition: left 0.5s ease;
        }

        .cta-button:hover::before {
            left: 100%;
        }

        .cta-primary {
            background: linear-gradient(45deg, var(--primary), var(--secondary));
            color: white;
            border: none;
            animation: buttonPulse 2s ease-in-out infinite;
        }

        @keyframes buttonPulse {
            0%, 100% { transform: scale(1); }
            50% { transform: scale(1.05); }
        }

        .cta-secondary {
            background: transparent;
            color: white;
            border: 2px solid var(--primary);
        }

        .cta-button:hover {
            transform: translateY(-5px) scale(1.05);
            box-shadow: 0 20px 40px rgba(37, 99, 235, 0.4);
            color: white;
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
            font-size: 2.5rem;
            opacity: 0.1;
            animation: floatElement 20s ease-in-out infinite;
            filter: drop-shadow(0 0 10px rgba(255, 255, 255, 0.2));
        }

        @keyframes floatElement {
            0%, 100% { transform: translate(0, 0) rotate(0deg) scale(1); }
            25% { transform: translate(100px, -80px) rotate(90deg) scale(1.1); }
            50% { transform: translate(50px, -120px) rotate(180deg) scale(0.9); }
            75% { transform: translate(-80px, -60px) rotate(270deg) scale(1.05); }
        }

        .element-1 { top: 10%; left: 5%; animation-delay: 0s; color: var(--primary); }
        .element-2 { top: 20%; left: 90%; animation-delay: -5s; color: var(--secondary); }
        .element-3 { top: 60%; left: 10%; animation-delay: -10s; color: var(--accent); }
        .element-4 { top: 80%; left: 85%; animation-delay: -15s; color: var(--success); }

        /* Modal Styles */
        .modal-content {
            background: rgba(15, 23, 42, 0.95);
            backdrop-filter: blur(25px);
            border: 1px solid rgba(255, 255, 255, 0.15);
            border-radius: 25px;
            color: white;
            animation: modalSlideIn 0.5s ease-out;
        }

        @keyframes modalSlideIn {
            from {
                opacity: 0;
                transform: translateY(-50px) scale(0.9);
            }
            to {
                opacity: 1;
                transform: translateY(0) scale(1);
            }
        }

        .modal-header {
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
            padding: 2.5rem;
            background: rgba(255, 255, 255, 0.05);
        }

        .modal-body {
            padding: 2.5rem;
        }

        .modal-title {
            font-size: 2rem;
            font-weight: 700;
            background: linear-gradient(45deg, var(--accent), var(--primary));
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }

        .detail-section {
            margin-bottom: 2.5rem;
            animation: fadeInUp 0.6s ease-out;
        }

        .detail-section h5 {
            color: var(--accent);
            margin-bottom: 1.2rem;
            font-weight: 600;
            font-size: 1.3rem;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }

        .feature-list {
            list-style: none;
            padding: 0;
        }

        .feature-list li {
            padding: 0.8rem 0;
            display: flex;
            align-items: center;
            gap: 1rem;
            border-bottom: 1px solid rgba(255, 255, 255, 0.05);
            transition: all 0.3s ease;
        }

        .feature-list li:hover {
            background: rgba(255, 255, 255, 0.05);
            padding-left: 1rem;
            border-radius: 10px;
        }

        .feature-list li i {
            color: var(--success);
            font-size: 1.1rem;
            transition: all 0.3s ease;
        }

        .feature-list li:hover i {
            transform: scale(1.2);
            color: var(--accent);
        }

        .modal-tech-tags {
            display: flex;
            flex-wrap: wrap;
            gap: 0.5rem;
            margin-top: 1rem;
        }

        .modal-tech-tag {
            background: rgba(37, 99, 235, 0.2);
            padding: 0.5rem 1rem;
            border-radius: 20px;
            font-size: 0.8rem;
            border: 1px solid rgba(37, 99, 235, 0.3);
            transition: all 0.3s ease;
        }

        .modal-tech-tag:hover {
            background: rgba(37, 99, 235, 0.3);
            transform: translateY(-2px);
        }

        /* Navigation */
        .back-button {
            position: fixed;
            top: 2rem;
            left: 2rem;
            background: rgba(255, 255, 255, 0.08);
            border: 1px solid rgba(255, 255, 255, 0.15);
            color: white;
            padding: 0.8rem 1.5rem;
            border-radius: 50px;
            text-decoration: none;
            display: flex;
            align-items: center;
            gap: 0.8rem;
            transition: all 0.3s ease;
            backdrop-filter: blur(15px);
            z-index: 1000;
            animation: slideInLeft 0.8s ease-out;
        }

        @keyframes slideInLeft {
            from {
                opacity: 0;
                transform: translateX(-50px);
            }
            to {
                opacity: 1;
                transform: translateX(0);
            }
        }

        .back-button:hover {
            background: rgba(255, 255, 255, 0.15);
            color: white;
            transform: translateX(-5px);
            box-shadow: 0 10px 25px rgba(0, 0, 0, 0.2);
        }

        /* Particle Background */
        .particles {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            pointer-events: none;
            z-index: -1;
        }

        .particle {
            position: absolute;
            background: rgba(255, 255, 255, 0.1);
            border-radius: 50%;
            animation: particleFloat 20s linear infinite;
        }

        @keyframes particleFloat {
            0% {
                transform: translateY(100vh) rotate(0deg);
                opacity: 0;
            }
            10% {
                opacity: 1;
            }
            90% {
                opacity: 1;
            }
            100% {
                transform: translateY(-100px) rotate(360deg);
                opacity: 0;
            }
        }

        /* NEW SECTIONS STYLES */

        /* How It Works Section */
        .process-section {
            padding: 100px 0;
            background: rgba(15, 23, 42, 0.4);
        }

        .process-steps {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            max-width: 1200px;
            margin: 0 auto;
            padding: 0 2rem;
            position: relative;
        }

        .process-steps::before {
            content: '';
            position: absolute;
            top: 60px;
            left: 10%;
            right: 10%;
            height: 3px;
            background: linear-gradient(90deg, var(--primary), var(--secondary));
            z-index: 1;
        }

        .process-step {
            text-align: center;
            position: relative;
            z-index: 2;
            flex: 1;
            padding: 0 1rem;
        }

        .step-number {
            width: 60px;
            height: 60px;
            background: linear-gradient(45deg, var(--primary), var(--secondary));
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 700;
            font-size: 1.5rem;
            margin: 0 auto 1.5rem;
            border: 4px solid var(--dark);
        }

        .step-title {
            font-size: 1.3rem;
            font-weight: 600;
            margin-bottom: 1rem;
            color: var(--accent);
        }

        .step-desc {
            opacity: 0.8;
            line-height: 1.6;
        }

        /* Testimonials Section */
        .testimonials-section {
            padding: 100px 0;
        }

        .testimonials-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(350px, 1fr));
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
        }

        .testimonial-quote {
            font-size: 3rem;
            color: var(--accent);
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

        /* Integration Section */
        .integration-section {
            padding: 100px 0;
            background: rgba(15, 23, 42, 0.4);
        }

        .integration-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 2rem;
            max-width: 1000px;
            margin: 0 auto;
            padding: 0 2rem;
        }

        .integration-item {
            text-align: center;
            padding: 2rem;
            background: var(--card-bg);
            border-radius: 15px;
            border: 1px solid var(--card-border);
            transition: all 0.3s ease;
        }

        .integration-item:hover {
            transform: translateY(-5px);
            border-color: var(--primary);
        }

        .integration-icon {
            font-size: 2.5rem;
            color: var(--accent);
            margin-bottom: 1rem;
        }

        .integration-title {
            font-size: 1.2rem;
            font-weight: 600;
            margin-bottom: 0.5rem;
        }

        /* Security Section */
        .security-section {
            padding: 100px 0;
        }

        .security-features {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 2rem;
            max-width: 1200px;
            margin: 0 auto;
            padding: 0 2rem;
        }

        .security-item {
            background: var(--card-bg);
            border-radius: 15px;
            padding: 2rem;
            border: 1px solid var(--card-border);
            text-align: center;
        }

        .security-icon {
            font-size: 2.5rem;
            color: var(--success);
            margin-bottom: 1rem;
        }

        /* Pricing Section */
        .pricing-section {
            padding: 100px 0;
            background: rgba(15, 23, 42, 0.4);
        }

        .pricing-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 2rem;
            max-width: 1200px;
            margin: 0 auto;
            padding: 0 2rem;
        }

        .pricing-card {
            background: var(--card-bg);
            border-radius: 20px;
            padding: 2.5rem;
            border: 1px solid var(--card-border);
            text-align: center;
            transition: all 0.3s ease;
        }

        .pricing-card.featured {
            border-color: var(--accent);
            transform: scale(1.05);
        }

        .pricing-header {
            margin-bottom: 2rem;
        }

        .pricing-title {
            font-size: 1.5rem;
            font-weight: 600;
            margin-bottom: 1rem;
        }

        .pricing-price {
            font-size: 3rem;
            font-weight: 700;
            color: var(--accent);
        }

        .pricing-features {
            list-style: none;
            margin-bottom: 2rem;
        }

        .pricing-features li {
            padding: 0.5rem 0;
            opacity: 0.8;
        }

        /* FAQ Section */
        .faq-section {
            padding: 100px 0;
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

        /* Team Section */
        .team-section {
            padding: 100px 0;
            background: rgba(15, 23, 42, 0.4);
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
            padding: 2rem;
            text-align: center;
            border: 1px solid var(--card-border);
            transition: all 0.3s ease;
        }

        .team-card:hover {
            transform: translateY(-10px);
            border-color: var(--primary);
        }

        .team-avatar {
            width: 100px;
            height: 100px;
            border-radius: 50%;
            background: linear-gradient(45deg, var(--primary), var(--secondary));
            margin: 0 auto 1rem;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 2rem;
            font-weight: 700;
        }

        .team-name {
            font-size: 1.3rem;
            font-weight: 600;
            margin-bottom: 0.5rem;
        }

        .team-role {
            color: var(--accent);
            margin-bottom: 1rem;
        }

        /* Partners Section */
        .partners-section {
            padding: 80px 0;
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
        }

        /* Support Section */
        .support-section {
            padding: 100px 0;
            background: rgba(15, 23, 42, 0.4);
        }

        .support-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 2rem;
            max-width: 1000px;
            margin: 0 auto;
            padding: 0 2rem;
        }

        .support-item {
            text-align: center;
            padding: 2rem;
            background: var(--card-bg);
            border-radius: 15px;
            border: 1px solid var(--card-border);
        }

        .support-icon {
            font-size: 2.5rem;
            color: var(--accent);
            margin-bottom: 1rem;
        }

        /* Responsive Design */
        @media (max-width: 768px) {
            .header-title { font-size: 2.5rem; }
            .header-subtitle { font-size: 1.1rem; }
            .section-title { font-size: 2.5rem; }
            .section-subtitle { font-size: 1.1rem; }
            .apps-grid { grid-template-columns: 1fr; }
            .app-card { padding: 2rem; }
            .app-title { font-size: 1.5rem; }
            .stats-grid { grid-template-columns: repeat(2, 1fr); }
            .cta-buttons { flex-direction: column; align-items: center; }
            .cta-button { width: 100%; max-width: 300px; }
            .process-steps { flex-direction: column; gap: 3rem; }
            .process-steps::before { display: none; }
        }

        /* Loading state for ASP.NET buttons */
        .app-button.loading {
            pointer-events: none;
            opacity: 0.8;
        }

        .app-button.loading::after {
            content: '';
            position: absolute;
            top: 50%;
            left: 50%;
            width: 20px;
            height: 20px;
            margin: -10px 0 0 -10px;
            border: 2px solid transparent;
            border-top: 2px solid #ffffff;
            border-radius: 50%;
            animation: buttonSpin 1s linear infinite;
        }

        @keyframes buttonSpin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
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
                <div class="floating-element element-3"><i class="fas fa-mobile-alt"></i></div>
                <div class="floating-element element-4"><i class="fas fa-server"></i></div>
            </div>

            <div class="header-content">
                <div class="logo">
                    <i class="fas fa-recycle"></i>
                </div>
                <h1 class="header-title">Choose Your Experience</h1>
                <p class="header-subtitle">
                    Discover the complete SoorGreen ecosystem. Each application is designed with specific users in mind, 
                    offering tailored experiences for administrators, citizens, and developers.
                </p>
            </div>
        </section>

        <!-- Stats Section -->
        <section class="stats-section" data-aos="fade-up">
            <div class="stats-grid">
                <div class="stat-card" data-aos="zoom-in" data-aos-delay="100">
                    <span class="stat-number" id="statUsers">2.5K+</span>
                    <span class="stat-label">Active Users</span>
                </div>
                <div class="stat-card" data-aos="zoom-in" data-aos-delay="200">
                    <span class="stat-number" id="statPickups">1.2K+</span>
                    <span class="stat-label">Pickups Completed</span>
                </div>
                <div class="stat-card" data-aos="zoom-in" data-aos-delay="300">
                    <span class="stat-number" id="statCredits">45K+</span>
                    <span class="stat-label">Credits Earned</span>
                </div>
                <div class="stat-card" data-aos="zoom-in" data-aos-delay="400">
                    <span class="stat-number" id="statTons">85+</span>
                    <span class="stat-label">Tons Recycled</span>
                </div>
            </div>
        </section>

        <!-- NEW: How It Works Section -->
        <section class="process-section" id="process">
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
        </section>

        <!-- Apps Section -->
        <section class="apps-section" id="applications">
            <h2 class="section-title" data-aos="fade-up">Explore Our Applications</h2>
            <p class="section-subtitle" data-aos="fade-up" data-aos-delay="200">
                Three powerful platforms, one unified mission. Choose the experience that fits your role.
            </p>

            <div class="apps-grid">
                <!-- WebForms Admin Card -->
                <div class="app-card card-webform" data-aos="fade-up" data-aos-delay="200" data-bs-toggle="modal" data-bs-target="#webformModal">
                    <div class="user-role">For Administrators</div>
                    <div class="app-icon">
                        <i class="fas fa-tachometer-alt"></i>
                    </div>
                    <h3 class="app-title">WebForms Admin Panel</h3>
                    <p class="app-subtitle">
                        Complete administrative dashboard for municipalities and system administrators. 
                        Manage users, track pickups, and generate comprehensive reports with real-time analytics.
                    </p>
                    <ul class="app-features">
                        <li><i class="fas fa-check"></i> Real-time dashboard analytics</li>
                        <li><i class="fas fa-check"></i> User management system</li>
                        <li><i class="fas fa-check"></i> Pickup scheduling & tracking</li>
                        <li><i class="fas fa-check"></i> Advanced reporting tools</li>
                        <li><i class="fas fa-check"></i> System configuration</li>
                    </ul>
                    <div class="tech-tags">
                        <span class="tech-tag">ASP.NET WebForms</span>
                        <span class="tech-tag">SQL Server</span>
                        <span class="tech-tag">Bootstrap</span>
                        <span class="tech-tag">jQuery</span>
                    </div>
                    <asp:Button ID="btnWebForm" runat="server" Text="Launch Admin Panel" 
                        CssClass="app-button" OnClick="btnWebForm_Click" />
                </div>

                <!-- MVC Portal Card -->
                <div class="app-card card-mvc" data-aos="fade-up" data-aos-delay="400" data-bs-toggle="modal" data-bs-target="#mvcModal">
                    <div class="user-role">For Citizens & Collectors</div>
                    <div class="app-icon">
                        <i class="fas fa-users"></i>
                    </div>
                    <h3 class="app-title">MVC Citizen Portal</h3>
                    <p class="app-subtitle">
                        Modern web application for citizens to report waste, track pickups, 
                        and redeem rewards. Clean, responsive design optimized for mobile use.
                    </p>
                    <ul class="app-features">
                        <li><i class="fas fa-check"></i> Waste reporting with photos</li>
                        <li><i class="fas fa-check"></i> Real-time pickup tracking</li>
                        <li><i class="fas fa-check"></i> Reward points dashboard</li>
                        <li><i class="fas fa-check"></i> Interactive maps</li>
                        <li><i class="fas fa-check"></i> Mobile-responsive design</li>
                    </ul>
                    <div class="tech-tags">
                        <span class="tech-tag">ASP.NET Core MVC</span>
                        <span class="tech-tag">Entity Framework</span>
                        <span class="tech-tag">Razor Pages</span>
                        <span class="tech-tag">JavaScript</span>
                    </div>
                    <asp:Button ID="btnMVC" runat="server" Text="Open Citizen Portal" 
                        CssClass="app-button" OnClick="btnMVC_Click" />
                </div>

                <!-- Web API Card -->
                <div class="app-card card-api" data-aos="fade-up" data-aos-delay="600" data-bs-toggle="modal" data-bs-target="#apiModal">
                    <div class="user-role">For Developers & Integration</div>
                    <div class="app-icon">
                        <i class="fas fa-code"></i>
                    </div>
                    <h3 class="app-title">Web API Service</h3>
                    <p class="app-subtitle">
                        RESTful API backend that powers all SoorGreen applications. 
                        Provides secure endpoints for mobile apps and third-party integrations.
                    </p>
                    <ul class="app-features">
                        <li><i class="fas fa-check"></i> RESTful API endpoints</li>
                        <li><i class="fas fa-check"></i> JWT authentication</li>
                        <li><i class="fas fa-check"></i> Mobile app support</li>
                        <li><i class="fas fa-check"></i> Third-party integration</li>
                        <li><i class="fas fa-check"></i> Swagger documentation</li>
                    </ul>
                    <div class="tech-tags">
                        <span class="tech-tag">ASP.NET Web API</span>
                        <span class="tech-tag">JWT Tokens</span>
                        <span class="tech-tag">REST</span>
                        <span class="tech-tag">Swagger</span>
                    </div>
                    <asp:Button ID="btnAPI" runat="server" Text="Explore API" 
                        CssClass="app-button" />
                </div>
            </div>
        </section>

        <!-- NEW: Testimonials Section -->
        <section class="testimonials-section" id="testimonials">
            <h2 class="section-title" data-aos="fade-up">What Our Users Say</h2>
            <p class="section-subtitle" data-aos="fade-up" data-aos-delay="200">
                Hear from municipalities, citizens, and partners using SoorGreen
            </p>
            
            <div class="testimonials-grid">
                <div class="testimonial-card" data-aos="fade-up" data-aos-delay="200">
                    <div class="testimonial-quote">"</div>
                    <p class="testimonial-text">SoorGreen has revolutionized our city's waste management. The admin dashboard gives us real-time insights we never had before.</p>
                    <div class="testimonial-author">
                        <div class="author-avatar">MJ</div>
                        <div class="author-info">
                            <h4>Maria Johnson</h4>
                            <p>City Waste Manager</p>
                        </div>
                    </div>
                </div>
                <div class="testimonial-card" data-aos="fade-up" data-aos-delay="400">
                    <div class="testimonial-quote">"</div>
                    <p class="testimonial-text">As a citizen, I love how easy it is to report waste and track pickups. The reward system is a great incentive!</p>
                    <div class="testimonial-author">
                        <div class="author-avatar">DS</div>
                        <div class="author-info">
                            <h4>David Smith</h4>
                            <p>Community Member</p>
                        </div>
                    </div>
                </div>
                <div class="testimonial-card" data-aos="fade-up" data-aos-delay="600">
                    <div class="testimonial-quote">"</div>
                    <p class="testimonial-text">The API integration was seamless. We connected our mobile app in days, not weeks. Excellent documentation!</p>
                    <div class="testimonial-author">
                        <div class="author-avatar">TP</div>
                        <div class="author-info">
                            <h4>Taylor Park</h4>
                            <p>Developer, EcoTech</p>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <!-- NEW: Integration Section -->
        <section class="integration-section" id="integrations">
            <h2 class="section-title" data-aos="fade-up">Seamless Integrations</h2>
            <p class="section-subtitle" data-aos="fade-up" data-aos-delay="200">
                Connect with your favorite tools and platforms
            </p>
            
            <div class="integration-grid">
                <div class="integration-item" data-aos="fade-up" data-aos-delay="200">
                    <div class="integration-icon">
                        <i class="fas fa-mobile-alt"></i>
                    </div>
                    <h3 class="integration-title">Mobile Apps</h3>
                    <p>Native iOS and Android applications</p>
                </div>
                <div class="integration-item" data-aos="fade-up" data-aos-delay="400">
                    <div class="integration-icon">
                        <i class="fas fa-map-marked-alt"></i>
                    </div>
                    <h3 class="integration-title">GIS Systems</h3>
                    <p>Geographic information systems</p>
                </div>
                <div class="integration-item" data-aos="fade-up" data-aos-delay="600">
                    <div class="integration-icon">
                        <i class="fas fa-chart-bar"></i>
                    </div>
                    <h3 class="integration-title">Analytics</h3>
                    <p>Business intelligence tools</p>
                </div>
                <div class="integration-item" data-aos="fade-up" data-aos-delay="800">
                    <div class="integration-icon">
                        <i class="fas fa-cogs"></i>
                    </div>
                    <h3 class="integration-title">Municipal Systems</h3>
                    <p>Government and city platforms</p>
                </div>
            </div>
        </section>

        <!-- NEW: Security Section -->
        <section class="security-section" id="security">
            <h2 class="section-title" data-aos="fade-up">Enterprise-Grade Security</h2>
            <p class="section-subtitle" data-aos="fade-up" data-aos-delay="200">
                Your data is protected with industry-leading security measures
            </p>
            
            <div class="security-features">
                <div class="security-item" data-aos="fade-up" data-aos-delay="200">
                    <div class="security-icon">
                        <i class="fas fa-shield-alt"></i>
                    </div>
                    <h3>Data Encryption</h3>
                    <p>End-to-end encryption for all data transmissions</p>
                </div>
                <div class="security-item" data-aos="fade-up" data-aos-delay="400">
                    <div class="security-icon">
                        <i class="fas fa-user-shield"></i>
                    </div>
                    <h3>Access Control</h3>
                    <p>Role-based permissions and authentication</p>
                </div>
                <div class="security-item" data-aos="fade-up" data-aos-delay="600">
                    <div class="security-icon">
                        <i class="fas fa-database"></i>
                    </div>
                    <h3>Secure Storage</h3>
                    <p>Encrypted database with regular backups</p>
                </div>
            </div>
        </section>

        <!-- Features Section -->
        <section class="features-section" data-aos="fade-up">
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
        </section>

        <!-- NEW: Pricing Section -->
        <section class="pricing-section" id="pricing">
            <h2 class="section-title" data-aos="fade-up">Flexible Pricing</h2>
            <p class="section-subtitle" data-aos="fade-up" data-aos-delay="200">
                Choose the plan that works for your community
            </p>
            
            <div class="pricing-grid">
                <div class="pricing-card" data-aos="fade-up" data-aos-delay="200">
                    <div class="pricing-header">
                        <h3 class="pricing-title">Starter</h3>
                        <div class="pricing-price">$99<span>/month</span></div>
                    </div>
                    <ul class="pricing-features">
                        <li>Up to 1,000 citizens</li>
                        <li>Basic reporting</li>
                        <li>Email support</li>
                        <li>Mobile app access</li>
                    </ul>
                    <button class="app-button">Get Started</button>
                </div>
                <div class="pricing-card featured" data-aos="fade-up" data-aos-delay="400">
                    <div class="pricing-header">
                        <h3 class="pricing-title">Professional</h3>
                        <div class="pricing-price">$299<span>/month</span></div>
                    </div>
                    <ul class="pricing-features">
                        <li>Up to 10,000 citizens</li>
                        <li>Advanced analytics</li>
                        <li>Priority support</li>
                        <li>API access</li>
                        <li>Custom branding</li>
                    </ul>
                    <button class="app-button">Get Started</button>
                </div>
                <div class="pricing-card" data-aos="fade-up" data-aos-delay="600">
                    <div class="pricing-header">
                        <h3 class="pricing-title">Enterprise</h3>
                        <div class="pricing-price">Custom</div>
                    </div>
                    <ul class="pricing-features">
                        <li>Unlimited citizens</li>
                        <li>Full feature access</li>
                        <li>24/7 dedicated support</li>
                        <li>White-label solution</li>
                        <li>On-premise deployment</li>
                    </ul>
                    <button class="app-button">Contact Sales</button>
                </div>
            </div>
        </section>

        <!-- NEW: FAQ Section -->
        <section class="faq-section" id="faq">
            <h2 class="section-title" data-aos="fade-up">Frequently Asked Questions</h2>
            <p class="section-subtitle" data-aos="fade-up" data-aos-delay="200">
                Find answers to common questions about SoorGreen
            </p>
            
            <div class="faq-container">
                <div class="faq-item" data-aos="fade-up" data-aos-delay="200">
                    <div class="faq-question">
                        How do I get started with SoorGreen?
                        <i class="fas fa-chevron-down faq-icon"></i>
                    </div>
                    <div class="faq-answer">
                        Getting started is easy! Simply choose your application above, create an account, and follow the setup wizard. Our team is available to help with implementation.
                    </div>
                </div>
                <div class="faq-item" data-aos="fade-up" data-aos-delay="300">
                    <div class="faq-question">
                        Can I integrate with existing municipal systems?
                        <i class="fas fa-chevron-down faq-icon"></i>
                    </div>
                    <div class="faq-answer">
                        Yes! Our API provides comprehensive integration capabilities with most municipal systems, GIS platforms, and third-party applications.
                    </div>
                </div>
                <div class="faq-item" data-aos="fade-up" data-aos-delay="400">
                    <div class="faq-question">
                        Is my data secure and private?
                        <i class="fas fa-chevron-down faq-icon"></i>
                    </div>
                    <div class="faq-answer">
                        Absolutely. We employ enterprise-grade security measures including encryption, secure authentication, and regular security audits to protect your data.
                    </div>
                </div>
            </div>
        </section>

        <!-- NEW: Team Section -->
        <section class="team-section" id="team">
            <h2 class="section-title" data-aos="fade-up">Meet Our Team</h2>
            <p class="section-subtitle" data-aos="fade-up" data-aos-delay="200">
                The passionate people behind SoorGreen
            </p>
            
            <div class="team-grid">
                <div class="team-card" data-aos="fade-up" data-aos-delay="200">
                    <div class="team-avatar">SJ</div>
                    <h3 class="team-name">Sarah Johnson</h3>
                    <p class="team-role">CEO & Founder</p>
                    <p>Environmental engineer with 10+ years in sustainable tech</p>
                </div>
                <div class="team-card" data-aos="fade-up" data-aos-delay="400">
                    <div class="team-avatar">MR</div>
                    <h3 class="team-name">Mike Rodriguez</h3>
                    <p class="team-role">CTO</p>
                    <p>Software architect specializing in scalable systems</p>
                </div>
                <div class="team-card" data-aos="fade-up" data-aos-delay="600">
                    <div class="team-avatar">EP</div>
                    <h3 class="team-name">Emma Patel</h3>
                    <p class="team-role">Head of Product</p>
                    <p>UX expert focused on citizen engagement</p>
                </div>
                <div class="team-card" data-aos="fade-up" data-aos-delay="800">
                    <div class="team-avatar">DW</div>
                    <h3 class="team-name">David Wilson</h3>
                    <p class="team-role">Operations Director</p>
                    <p>Municipal waste management specialist</p>
                </div>
            </div>
        </section>

        <!-- NEW: Partners Section -->
        <section class="partners-section" id="partners">
            <h2 class="section-title" data-aos="fade-up">Our Partners</h2>
            <p class="section-subtitle" data-aos="fade-up" data-aos-delay="200">
                Trusted by leading organizations worldwide
            </p>
            
            <div class="partners-grid">
                <div class="partner-logo" data-aos="zoom-in" data-aos-delay="200">
                    <i class="fas fa-city fa-2x"></i>
                </div>
                <div class="partner-logo" data-aos="zoom-in" data-aos-delay="300">
                    <i class="fas fa-recycle fa-2x"></i>
                </div>
                <div class="partner-logo" data-aos="zoom-in" data-aos-delay="400">
                    <i class="fas fa-leaf fa-2x"></i>
                </div>
                <div class="partner-logo" data-aos="zoom-in" data-aos-delay="500">
                    <i class="fas fa-globe-americas fa-2x"></i>
                </div>
                <div class="partner-logo" data-aos="zoom-in" data-aos-delay="600">
                    <i class="fas fa-hand-holding-heart fa-2x"></i>
                </div>
                <div class="partner-logo" data-aos="zoom-in" data-aos-delay="700">
                    <i class="fas fa-tree fa-2x"></i>
                </div>
            </div>
        </section>

        <!-- NEW: Support Section -->
        <section class="support-section" id="support">
            <h2 class="section-title" data-aos="fade-up">Get Support</h2>
            <p class="section-subtitle" data-aos="fade-up" data-aos-delay="200">
                We're here to help you succeed
            </p>
            
            <div class="support-grid">
                <div class="support-item" data-aos="fade-up" data-aos-delay="200">
                    <div class="support-icon">
                        <i class="fas fa-book"></i>
                    </div>
                    <h3>Documentation</h3>
                    <p>Comprehensive guides and API references</p>
                </div>
                <div class="support-item" data-aos="fade-up" data-aos-delay="400">
                    <div class="support-icon">
                        <i class="fas fa-comments"></i>
                    </div>
                    <h3>Community</h3>
                    <p>Join our active user community</p>
                </div>
                <div class="support-item" data-aos="fade-up" data-aos-delay="600">
                    <div class="support-icon">
                        <i class="fas fa-headset"></i>
                    </div>
                    <h3>Live Support</h3>
                    <p>24/7 technical support available</p>
                </div>
                <div class="support-item" data-aos="fade-up" data-aos-delay="800">
                    <div class="support-icon">
                        <i class="fas fa-calendar-alt"></i>
                    </div>
                    <h3>Training</h3>
                    <p>Weekly webinars and training sessions</p>
                </div>
            </div>
        </section>

        <!-- CTA Section -->
        <section class="cta-section" data-aos="fade-up">
            <div class="cta-content">
                <h2 class="cta-title">Ready to Get Started?</h2>
                <p class="cta-subtitle">
                    Join the growing community of municipalities and citizens transforming waste management. 
                    Choose your platform and start making a difference today.
                </p>
                <div class="cta-buttons">
                    <a href="#applications" class="cta-button cta-primary">
                        <i class="fas fa-play"></i>
                        Launch Application
                    </a>
                    <a href="#" class="cta-button cta-secondary">
                        <i class="fas fa-book"></i>
                        View Documentation
                    </a>
                </div>
            </div>
        </section>

        <!-- ALL YOUR EXISTING MODALS REMAIN EXACTLY THE SAME -->
        <!-- WebForms Modal -->
        <div class="modal fade" id="webformModal" tabindex="-1" aria-hidden="true">
            <div class="modal-dialog modal-lg">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title">
                            <i class="fas fa-tachometer-alt me-2"></i>
                            WebForms Admin Panel - Complete Details
                        </h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                        <div class="detail-section">
                            <h5><i class="fas fa-info-circle"></i> Overview</h5>
                            <p>Complete administrative interface built with ASP.NET WebForms, designed for municipalities and system administrators to manage the entire SoorGreen ecosystem with powerful tools and real-time insights.</p>
                        </div>
                        
                        <div class="detail-section">
                            <h5><i class="fas fa-star"></i> Key Features</h5>
                            <ul class="feature-list">
                                <li><i class="fas fa-chart-bar"></i> Real-time analytics dashboard with interactive charts and performance metrics</li>
                                <li><i class="fas fa-users-cog"></i> Comprehensive user management system with role-based access control</li>
                                <li><i class="fas fa-truck-loading"></i> Smart pickup request management and automatic collector assignment</li>
                                <li><i class="fas fa-file-invoice-dollar"></i> Advanced reporting with financial tracking and export capabilities</li>
                                <li><i class="fas fa-cog"></i> System configuration with environment settings and application parameters</li>
                                <li><i class="fas fa-bell"></i> Real-time notification system for administrators and users</li>
                                <li><i class="fas fa-map-marked-alt"></i> Geographic visualization of waste reports and collection routes</li>
                                <li><i class="fas fa-database"></i> Data management with backup and restore functionality</li>
                            </ul>
                        </div>

                        <div class="detail-section">
                            <h5><i class="fas fa-code"></i> Technical Stack</h5>
                            <div class="modal-tech-tags">
                                <span class="modal-tech-tag">ASP.NET WebForms</span>
                                <span class="modal-tech-tag">C# .NET Framework</span>
                                <span class="modal-tech-tag">SQL Server 2022</span>
                                <span class="modal-tech-tag">Bootstrap 5</span>
                                <span class="modal-tech-tag">jQuery 3.6</span>
                                <span class="modal-tech-tag">Chart.js</span>
                                <span class="modal-tech-tag">Entity Framework</span>
                                <span class="modal-tech-tag">SignalR</span>
                            </div>
                        </div>

                        <div class="detail-section">
                            <h5><i class="fas fa-users"></i> Target Users</h5>
                            <p>Municipality staff, system administrators, waste management companies, environmental agencies, and government officials responsible for urban planning and sustainability initiatives.</p>
                        </div>

                        <div class="detail-section">
                            <h5><i class="fas fa-rocket"></i> Launch Application</h5>
                            <p>Ready to explore the administrative capabilities? Click below to launch the WebForms Admin Panel and experience comprehensive waste management system control.</p>
                            <asp:Button ID="btnWebFormModal" runat="server" Text="Launch WebForms Admin Panel" 
                                CssClass="app-button mt-3" OnClick="btnWebFormModal_Click" />
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- MVC Modal -->
        <div class="modal fade" id="mvcModal" tabindex="-1" aria-hidden="true">
            <div class="modal-dialog modal-lg">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title">
                            <i class="fas fa-users me-2"></i>
                            MVC Citizen Portal - Complete Details
                        </h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                        <div class="detail-section">
                            <h5><i class="fas fa-info-circle"></i> Overview</h5>
                            <p>Modern, responsive web application built with ASP.NET Core MVC that serves as the primary interface for citizens and waste collectors, featuring intuitive design and powerful functionality.</p>
                        </div>
                        
                        <div class="detail-section">
                            <h5><i class="fas fa-star"></i> Key Features</h5>
                            <ul class="feature-list">
                                <li><i class="fas fa-camera"></i> Waste reporting with photo upload, GPS location, and AI-based categorization</li>
                                <li><i class="fas fa-map-marked-alt"></i> Interactive map for real-time waste location tracking and route optimization</li>
                                <li><i class="fas fa-coins"></i> Comprehensive reward points system with multiple redemption options</li>
                                <li><i class="fas fa-mobile-alt"></i> Fully responsive mobile-first design with PWA capabilities</li>
                                <li><i class="fas fa-bell"></i> Real-time notifications and status updates for pickups</li>
                                <li><i class="fas fa-history"></i> Complete pickup history with detailed status tracking</li>
                                <li><i class="fas fa-user-circle"></i> User profiles with achievement badges and level progression</li>
                                <li><i class="fas fa-share-alt"></i> Social sharing and community engagement features</li>
                            </ul>
                        </div>

                        <div class="detail-section">
                            <h5><i class="fas fa-code"></i> Technical Stack</h5>
                            <div class="modal-tech-tags">
                                <span class="modal-tech-tag">ASP.NET Core MVC</span>
                                <span class="modal-tech-tag">Entity Framework Core</span>
                                <span class="modal-tech-tag">Razor Pages</span>
                                <span class="modal-tech-tag">JavaScript/TypeScript</span>
                                <span class="modal-tech-tag">Bootstrap 5</span>
                                <span class="modal-tech-tag">Leaflet Maps</span>
                                <span class="modal-tech-tag">SignalR</span>
                                <span class="modal-tech-tag">Azure Blob Storage</span>
                            </div>
                        </div>

                        <div class="detail-section">
                            <h5><i class="fas fa-users"></i> Target Users</h5>
                            <p>Citizens, waste collectors, community organizations, environmental activists, schools, businesses, and anyone interested in participating in sustainable waste management practices.</p>
                        </div>

                        <div class="detail-section">
                            <h5><i class="fas fa-rocket"></i> Launch Application</h5>
                            <p>Experience the citizen-focused interface designed for easy waste reporting and reward tracking. Click below to explore the MVC Citizen Portal.</p>
                            <asp:Button ID="btnMVCModal" runat="server" Text="Launch MVC Citizen Portal" 
                                CssClass="app-button mt-3" OnClick="btnMVCModal_Click" />
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- API Modal -->
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
                            <h5><i class="fas fa-info-circle"></i> Overview</h5>
                            <p>Robust RESTful API backend that provides the core functionality for all SoorGreen applications, enabling seamless integration with mobile apps, third-party services, and external systems.</p>
                        </div>
                        
                        <div class="detail-section">
                            <h5><i class="fas fa-star"></i> Key Features</h5>
                            <ul class="feature-list">
                                <li><i class="fas fa-shield-alt"></i> Secure JWT-based authentication with role-based authorization</li>
                                <li><i class="fas fa-mobile"></i> Mobile-optimized endpoints with push notification support</li>
                                <li><i class="fas fa-plug"></i> Third-party integration capabilities with webhook support</li>
                                <li><i class="fas fa-book"></i> Comprehensive Swagger/OpenAPI documentation</li>
                                <li><i class="fas fa-bolt"></i> High-performance optimized endpoints with caching</li>
                                <li><i class="fas fa-cloud"></i> Cloud-ready and scalable microservices architecture</li>
                                <li><i class="fas fa-database"></i> Real-time data synchronization across all platforms</li>
                                <li><i class="fas fa-chart-bar"></i> API analytics and usage monitoring dashboard</li>
                            </ul>
                        </div>

                        <div class="detail-section">
                            <h5><i class="fas fa-code"></i> Technical Stack</h5>
                            <div class="modal-tech-tags">
                                <span class="modal-tech-tag">ASP.NET Web API</span>
                                <span class="modal-tech-tag">JWT Authentication</span>
                                <span class="modal-tech-tag">Entity Framework</span>
                                <span class="modal-tech-tag">REST Principles</span>
                                <span class="modal-tech-tag">Swagger/OpenAPI</span>
                                <span class="modal-tech-tag">Azure Ready</span>
                                <span class="modal-tech-tag">Docker Containers</span>
                                <span class="modal-tech-tag">Redis Cache</span>
                            </div>
                        </div>

                        <div class="detail-section">
                            <h5><i class="fas fa-users"></i> Target Users</h5>
                            <p>Mobile app developers, third-party service providers, system integrators, technical teams, IoT device manufacturers, and anyone extending the SoorGreen platform through custom integrations.</p>
                        </div>

                        <div class="detail-section">
                            <h5><i class="fas fa-rocket"></i> Explore API</h5>
                            <p>Discover the powerful API endpoints and integration capabilities. Click below to access the interactive API documentation and testing interface.</p>
                            <asp:Button ID="btnAPIModal" runat="server" Text="Explore Web API" 
                                CssClass="app-button mt-3" />
                        </div>
                    </div>
                </div>
            </div>
        </div>
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

        // Create particle background
        function createParticles() {
            const particlesContainer = document.getElementById('particles');
            const particleCount = 50;

            for (let i = 0; i < particleCount; i++) {
                const particle = document.createElement('div');
                particle.className = 'particle';

                // Random properties
                const size = Math.random() * 5 + 1;
                const left = Math.random() * 100;
                const animationDuration = Math.random() * 20 + 10;
                const animationDelay = Math.random() * 20;

                particle.style.width = `${size}px`;
                particle.style.height = `${size}px`;
                particle.style.left = `${left}%`;
                particle.style.animationDuration = `${animationDuration}s`;
                particle.style.animationDelay = `${animationDelay}s`;
                particle.style.background = `rgba(${Math.random() * 255}, ${Math.random() * 255}, ${Math.random() * 255}, 0.1)`;

                particlesContainer.appendChild(particle);
            }
        }

        // Add click handlers for card clicks to open modals
        document.addEventListener('DOMContentLoaded', function () {
            createParticles();

            const cards = document.querySelectorAll('.app-card');
            cards.forEach(card => {
                card.addEventListener('click', function (e) {
                    if (!e.target.closest('.app-button')) {
                        const targetModal = this.getAttribute('data-bs-target');
                        const modal = new bootstrap.Modal(document.querySelector(targetModal));
                        modal.show();
                    }
                });
            });

            // FAQ functionality
            const faqItems = document.querySelectorAll('.faq-item');
            faqItems.forEach(item => {
                const question = item.querySelector('.faq-question');
                question.addEventListener('click', () => {
                    // Close all other items
                    faqItems.forEach(otherItem => {
                        if (otherItem !== item) {
                            otherItem.classList.remove('active');
                        }
                    });
                    // Toggle current item
                    item.classList.toggle('active');
                });
            });

            // Add loading states to ASP.NET buttons
            const aspNetButtons = document.querySelectorAll('input[type="submit"].app-button');
            aspNetButtons.forEach(button => {
                button.addEventListener('click', function (e) {
                    // Add loading class
                    this.classList.add('loading');

                    // Store original value
                    const originalValue = this.value;
                    this.value = 'Loading...';

                    // Revert after 5 seconds if still on page
                    setTimeout(() => {
                        if (this.classList.contains('loading')) {
                            this.classList.remove('loading');
                            this.value = originalValue;
                        }
                    }, 5000);
                });
            });

            // Animate stats
            function animateStats() {
                const stats = document.querySelectorAll('.stat-number');
                stats.forEach(stat => {
                    const finalValue = stat.textContent;
                    let current = 0;
                    const increment = parseInt(finalValue) / 50;
                    const timer = setInterval(() => {
                        current += increment;
                        if (current >= parseInt(finalValue)) {
                            stat.textContent = finalValue;
                            clearInterval(timer);
                        } else {
                            stat.textContent = Math.floor(current) + '+';
                        }
                    }, 50);
                });
            }

            // Trigger stats animation when in view
            const observer = new IntersectionObserver((entries) => {
                entries.forEach(entry => {
                    if (entry.isIntersecting) {
                        animateStats();
                        observer.unobserve(entry.target);
                    }
                });
            });

            observer.observe(document.querySelector('.stats-section'));

            // Smooth scrolling for navigation
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
</body>
</html>     