<%@ Page Language="C#" AutoEventWireup="false" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Page Not Found - SoorGreen</title>
    
    <!-- Bootstrap -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" />
    
    <!-- Font Awesome -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" rel="stylesheet" />
    
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet" />

    <style>
        :root {
            --primary: #00d4aa;
            --primary-dark: #00b894;
            --secondary: #0984e3;
            --accent: #fd79a8;
            --dark: #0a192f;
            --darker: #051122;
            --light: #ffffff;
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
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            line-height: 1.6;
        }

        .error-container {
            text-align: center;
            padding: 3rem;
            max-width: 600px;
            width: 100%;
        }

        .error-icon {
            font-size: 8rem;
            color: var(--primary);
            margin-bottom: 2rem;
            animation: float 3s ease-in-out infinite;
        }

        .error-code {
            font-size: 6rem;
            font-weight: 800;
            background: linear-gradient(45deg, var(--primary), var(--secondary));
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            margin-bottom: 1rem;
            line-height: 1;
        }

        .error-title {
            font-size: 2rem;
            font-weight: 700;
            margin-bottom: 1rem;
            color: var(--light);
        }

        .error-message {
            font-size: 1.1rem;
            color: rgba(255, 255, 255, 0.8);
            margin-bottom: 2rem;
            max-width: 400px;
            margin-left: auto;
            margin-right: auto;
        }

        .action-buttons {
            display: flex;
            gap: 1rem;
            justify-content: center;
            flex-wrap: wrap;
            margin-bottom: 3rem;
        }

        .btn-primary-custom {
            background: linear-gradient(135deg, var(--primary), var(--secondary));
            border: none;
            color: white;
            padding: 0.75rem 2rem;
            border-radius: 50px;
            text-decoration: none;
            font-weight: 600;
            transition: all 0.3s ease;
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
        }

        .btn-primary-custom:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 25px rgba(0, 212, 170, 0.3);
            color: white;
        }

        .btn-outline-custom {
            border: 2px solid var(--primary);
            color: var(--primary);
            background: transparent;
            padding: 0.75rem 2rem;
            border-radius: 50px;
            text-decoration: none;
            font-weight: 600;
            transition: all 0.3s ease;
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
        }

        .btn-outline-custom:hover {
            background: var(--primary);
            color: var(--dark);
            transform: translateY(-2px);
        }

        .btn-report {
            background: linear-gradient(135deg, var(--accent), #e84393);
            border: none;
            color: white;
            padding: 0.75rem 2rem;
            border-radius: 50px;
            text-decoration: none;
            font-weight: 600;
            transition: all 0.3s ease;
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
        }

        .btn-report:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 25px rgba(253, 121, 168, 0.3);
            color: white;
            text-decoration: none;
        }

        .quick-links {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 1rem;
            margin-top: 2rem;
        }

        .quick-link {
            background: rgba(255, 255, 255, 0.05);
            padding: 1.5rem;
            border-radius: 12px;
            text-decoration: none;
            color: var(--light);
            transition: all 0.3s ease;
            border: 1px solid rgba(255, 255, 255, 0.1);
        }

        .quick-link:hover {
            background: rgba(255, 255, 255, 0.1);
            transform: translateY(-3px);
            border-color: var(--primary);
            color: var(--light);
            text-decoration: none;
        }

        .quick-link-icon {
            font-size: 2rem;
            color: var(--primary);
            margin-bottom: 1rem;
        }

        .quick-link-title {
            font-weight: 600;
            margin-bottom: 0.5rem;
        }

        .quick-link-desc {
            font-size: 0.9rem;
            color: rgba(255, 255, 255, 0.7);
        }

        .support-info {
            margin-top: 3rem;
            padding-top: 2rem;
            border-top: 1px solid rgba(255, 255, 255, 0.1);
        }

        .support-contact {
            display: flex;
            justify-content: center;
            gap: 2rem;
            flex-wrap: wrap;
            margin-top: 1rem;
        }

        .contact-item {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            color: rgba(255, 255, 255, 0.7);
            text-decoration: none;
            transition: color 0.3s ease;
        }

        .contact-item:hover {
            color: var(--primary);
            text-decoration: none;
        }

        @keyframes float {
            0%, 100% { transform: translateY(0px); }
            50% { transform: translateY(-20px); }
        }

        @media (max-width: 768px) {
            .error-container {
                padding: 2rem 1rem;
            }
            
            .error-icon {
                font-size: 6rem;
            }
            
            .error-code {
                font-size: 4rem;
            }
            
            .error-title {
                font-size: 1.5rem;
            }
            
            .action-buttons {
                flex-direction: column;
                align-items: center;
            }
            
            .btn-primary-custom,
            .btn-outline-custom,
            .btn-report {
                width: 100%;
                max-width: 250px;
                justify-content: center;
            }
            
            .quick-links {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>
    <div class="error-container">
        <!-- Animated Icon -->
        <div class="error-icon">
            <i class="fas fa-recycle"></i>
        </div>
        
        <!-- Error Code -->
        <div class="error-code">404</div>
        
        <!-- Error Title -->
        <h1 class="error-title">Page Not Found</h1>
        
        <!-- Error Message -->
        <p class="error-message">
            Oops! The page you're looking for seems to have been recycled or doesn't exist. 
            Let's get you back on track!
        </p>

        <!-- Action Buttons -->
        <div class="action-buttons">
            <a href="Default.aspx" class="btn-primary-custom">
                <i class="fas fa-home"></i>
                Back to Home
            </a>
            <a href="Dashboard.aspx" class="btn-outline-custom">
                <i class="fas fa-tachometer-alt"></i>
                Go to Dashboard
            </a>
            <a href="javascript:history.back()" class="btn-outline-custom">
                <i class="fas fa-arrow-left"></i>
                Go Back
            </a>
            <a href="Contact.aspx?subject=404 Error Report" class="btn-report">
                <i class="fas fa-flag"></i>
                Report Issue
            </a>
        </div>

        <!-- Quick Links -->
        <div class="quick-links">
            <a href="SchedulePickup.aspx" class="quick-link">
                <div class="quick-link-icon">
                    <i class="fas fa-calendar-plus"></i>
                </div>
                <div class="quick-link-title">Schedule Pickup</div>
                <div class="quick-link-desc">Request waste collection</div>
            </a>
            
            <a href="MyRewards.aspx" class="quick-link">
                <div class="quick-link-icon">
                    <i class="fas fa-gift"></i>
                </div>
                <div class="quick-link-title">My Rewards</div>
                <div class="quick-link-desc">Redeem your XP points</div>
            </a>
            
            <a href="UserProfile.aspx" class="quick-link">
                <div class="quick-link-icon">
                    <i class="fas fa-user-circle"></i>
                </div>
                <div class="quick-link-title">My Profile</div>
                <div class="quick-link-desc">Update your information</div>
            </a>
            
            <a href="Contact.aspx" class="quick-link">
                <div class="quick-link-icon">
                    <i class="fas fa-headset"></i>
                </div>
                <div class="quick-link-title">Support</div>
                <div class="quick-link-desc">Get help from our team</div>
            </a>
        </div>

        <!-- Support Information -->
        <div class="support-info">
            <p style="color: rgba(255,255,255,0.7); margin-bottom: 1rem;">
                Still can't find what you're looking for? Contact our support team:
            </p>
            <div class="support-contact">
                <a href="mailto:support@soorgreen.com" class="contact-item">
                    <i class="fas fa-envelope"></i>
                    support@soorgreen.com
                </a>
                <a href="tel:+15551234567" class="contact-item">
                    <i class="fas fa-phone"></i>
                    +1 (555) 123-4567
                </a>
                <a href="Help.aspx" class="contact-item">
                    <i class="fas fa-question-circle"></i>
                    Help Center
                </a>
            </div>
        </div>
    </div>

    <script>
        // Add some interactive effects
        document.addEventListener('DOMContentLoaded', function () {
            const quickLinks = document.querySelectorAll('.quick-link');
            quickLinks.forEach(link => {
                link.addEventListener('mouseenter', function () {
                    this.style.transform = 'translateY(-5px) scale(1.02)';
                });
                link.addEventListener('mouseleave', function () {
                    this.style.transform = 'translateY(0) scale(1)';
                });
            });
        });
    </script>
</body>
</html>