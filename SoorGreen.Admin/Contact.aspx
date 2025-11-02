<%@ Page Title="Contact" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <style>
        /* Contact Page Specific Styles */
        .contact-hero-section {
            min-height: 50vh;
            display: flex;
            align-items: center;
            position: relative;
            overflow: hidden;
            background: radial-gradient(ellipse at center, rgba(0, 212, 170, 0.1) 0%, transparent 70%);
            padding-top: 100px;
        }

        .contact-card {
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

        .contact-card:hover {
            transform: translateY(-10px);
            border-color: var(--primary);
            box-shadow: 0 25px 50px rgba(0, 0, 0, 0.3);
        }

        .contact-icon {
            font-size: 3rem;
            color: var(--primary);
            margin-bottom: 1.5rem;
        }

        .contact-form {
            background: var(--card-bg);
            border: 1px solid var(--card-border);
            border-radius: 20px;
            padding: 3rem;
            backdrop-filter: blur(10px);
        }

        .form-control {
            background: rgba(255, 255, 255, 0.05);
            border: 1px solid var(--card-border);
            color: white;
            padding: 1rem;
            border-radius: 10px;
            transition: all 0.3s ease;
        }

        .form-control:focus {
            background: rgba(255, 255, 255, 0.1);
            border-color: var(--primary);
            color: white;
            box-shadow: 0 0 0 0.2rem rgba(0, 212, 170, 0.25);
        }

        .form-control::placeholder {
            color: rgba(255, 255, 255, 0.5);
        }

        .form-label {
            color: white;
            font-weight: 600;
            margin-bottom: 0.5rem;
        }

        .contact-info-item {
            display: flex;
            align-items: flex-start;
            margin-bottom: 2rem;
            padding: 1.5rem;
            background: var(--card-bg);
            border: 1px solid var(--card-border);
            border-radius: 15px;
            transition: all 0.3s ease;
            backdrop-filter: blur(10px);
        }

        .contact-info-item:hover {
            transform: translateX(10px);
            border-color: var(--primary);
        }

        .contact-info-icon {
            font-size: 1.5rem;
            color: var(--primary);
            margin-right: 1rem;
            margin-top: 0.25rem;
            flex-shrink: 0;
        }

        .office-card {
            background: var(--card-bg);
            border: 1px solid var(--card-border);
            border-radius: 15px;
            padding: 2rem;
            transition: all 0.3s ease;
            backdrop-filter: blur(10px);
            height: 100%;
        }

        .office-card:hover {
            transform: translateY(-5px);
            border-color: var(--primary);
        }

        .map-container {
            background: linear-gradient(45deg, var(--primary), var(--secondary));
            height: 400px;
            border-radius: 15px;
            overflow: hidden;
            position: relative;
        }

        .team-contact {
            background: var(--card-bg);
            border: 1px solid var(--card-border);
            border-radius: 15px;
            padding: 2rem;
            text-align: center;
            transition: all 0.3s ease;
            backdrop-filter: blur(10px);
        }

        .team-contact:hover {
            transform: translateY(-5px);
            border-color: var(--primary);
        }

        .team-avatar {
            width: 80px;
            height: 80px;
            border-radius: 50%;
            background: linear-gradient(45deg, var(--primary), var(--secondary));
            margin: 0 auto 1rem;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 700;
            color: white;
            font-size: 1.5rem;
        }

        .social-links {
            display: flex;
            justify-content: center;
            gap: 0.5rem;
            margin-top: 1rem;
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

        .faq-item {
            background: var(--card-bg);
            border: 1px solid var(--card-border);
            border-radius: 10px;
            margin-bottom: 1rem;
            overflow: hidden;
            backdrop-filter: blur(10px);
        }

        .faq-question {
            padding: 1.5rem;
            font-weight: 600;
            color: white;
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
            color: rgba(255, 255, 255, 0.9);
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

        /* Text Visibility Fixes */
        .text-muted {
            color: rgba(255, 255, 255, 0.8) !important;
            opacity: 1 !important;
        }

        .hero-title, .hero-subtitle {
            opacity: 1 !important;
            transform: translateY(0) !important;
        }

        /* Ensure all text elements are visible */
        .contact-card h3,
        .contact-card p,
        .contact-info-item h5,
        .contact-info-item p,
        .office-card h4,
        .office-card p,
        .team-contact h5,
        .team-contact p,
        .faq-question,
        .faq-answer,
        .form-label,
        .form-check-label,
        .lead,
        .small {
            opacity: 1 !important;
            visibility: visible !important;
            color: rgba(255, 255, 255, 0.9) !important;
        }

        /* Specific text color fixes */
        .contact-details h4,
        .text-primary {
            color: var(--primary) !important;
        }

        .contact-details .small,
        .contact-info-item p,
        .office-card p,
        .team-contact .small {
            color: rgba(255, 255, 255, 0.8) !important;
        }

        /* Button Styles */
        .btn-primary {
            background: var(--primary);
            border: none;
            padding: 1rem 2rem;
            border-radius: 10px;
            font-weight: 600;
            transition: all 0.3s ease;
            color: white !important;
        }

        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 20px rgba(0, 212, 170, 0.3);
            color: white !important;
        }

        .btn-outline-primary {
            border: 2px solid var(--primary);
            color: var(--primary);
            background: transparent;
            padding: 1rem 2rem;
            border-radius: 10px;
            font-weight: 600;
            transition: all 0.3s ease;
        }

        .btn-outline-primary:hover {
            background: var(--primary);
            color: white !important;
            transform: translateY(-2px);
        }

        .btn-hero {
            background: var(--primary);
            border: none;
            padding: 1rem 2rem;
            border-radius: 50px;
            color: white;
            font-weight: 600;
            transition: all 0.3s ease;
        }

        .btn-hero:hover {
            transform: translateY(-3px);
            box-shadow: 0 15px 30px rgba(0, 212, 170, 0.4);
            color: white;
        }

        .btn-outline-hero {
            border: 2px solid var(--primary);
            color: var(--primary);
            background: transparent;
            padding: 1rem 2rem;
            border-radius: 50px;
            font-weight: 600;
            transition: all 0.3s ease;
        }

        .btn-outline-hero:hover {
            background: var(--primary);
            color: white;
            transform: translateY(-3px);
        }

        /* Section Badge */
        .section-badge {
            background: rgba(0, 212, 170, 0.1) !important;
            border: 1px solid rgba(0, 212, 170, 0.3);
            color: var(--primary) !important;
            backdrop-filter: blur(10px);
        }

        /* Hero Text Styles */
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
            color: rgba(255, 255, 255, 0.9) !important;
            line-height: 1.6;
        }

        /* Responsive */
        @media (max-width: 768px) {
            .contact-form {
                padding: 2rem 1rem;
            }
            
            .contact-card {
                padding: 2rem 1rem;
            }
            
            .contact-info-item {
                padding: 1rem;
            }
            
            .hero-title {
                font-size: 2.5rem;
            }
        }
    </style>

    <!-- Hero Section -->
    <section class="contact-hero-section">
        <div class="container">
            <div class="row align-items-center">
                <div class="col-lg-6">
                    <span class="section-badge px-3 py-2 rounded-pill mb-3">Contact Us</span>
                    <h1 class="hero-title mb-4">Get In Touch With SoorGreen</h1>
                    <p class="hero-subtitle mb-4">Have questions about our waste management solutions? Ready to transform your community's sustainability efforts? We're here to help.</p>
                    <div class="d-flex flex-wrap gap-3">
                        <a href="#contact-form" class="btn btn-hero">
                            <i class="fas fa-envelope me-2"></i>Send Message
                        </a>
                        <a href="#locations" class="btn btn-outline-hero">
                            <i class="fas fa-map-marker-alt me-2"></i>Our Locations
                        </a>
                    </div>
                </div>
                <div class="col-lg-6 text-center">
                    <div class="contact-hero-visual">
                        <div class="contact-hero-image rounded-3 shadow-lg" style="background: linear-gradient(45deg, var(--primary), var(--secondary)); height: 400px; width: 100%;"></div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Contact Methods Section -->
    <section class="contact-methods-section py-5">
        <div class="container">
            <div class="row text-center mb-5">
                <div class="col-lg-8 mx-auto">
                    <span class="section-badge bg-primary bg-opacity-10 text-primary px-3 py-2 rounded-pill mb-3">Get In Touch</span>
                    <h2 class="fw-bold display-5 mb-3 text-white">Multiple Ways to Connect</h2>
                    <p class="lead text-muted fs-6">Choose the communication method that works best for you.</p>
                </div>
            </div>
            <div class="row g-4">
                <div class="col-lg-4 col-md-6">
                    <div class="contact-card">
                        <div class="contact-icon">
                            <i class="fas fa-phone"></i>
                        </div>
                        <h3 class="fw-bold mb-3 text-white">Phone Support</h3>
                        <p class="text-muted mb-4">Speak directly with our support team for immediate assistance.</p>
                        <div class="contact-details">
                            <h4 class="text-primary fw-bold">+1 (555) 123-4567</h4>
                            <p class="text-muted small">Mon-Fri: 8AM-6PM EST</p>
                        </div>
                        <a href="tel:+15551234567" class="btn btn-outline-primary w-100 mt-3">
                            <i class="fas fa-phone me-2"></i>Call Now
                        </a>
                    </div>
                </div>

                <div class="col-lg-4 col-md-6">
                    <div class="contact-card">
                        <div class="contact-icon">
                            <i class="fas fa-envelope"></i>
                        </div>
                        <h3 class="fw-bold mb-3 text-white">Email Support</h3>
                        <p class="text-muted mb-4">Send us a detailed message and we'll respond within 24 hours.</p>
                        <div class="contact-details">
                            <h4 class="text-primary fw-bold">support@soorgreen.com</h4>
                            <p class="text-muted small">Average response: 4 hours</p>
                        </div>
                        <a href="mailto:support@soorgreen.com" class="btn btn-outline-primary w-100 mt-3">
                            <i class="fas fa-envelope me-2"></i>Send Email
                        </a>
                    </div>
                </div>

                <div class="col-lg-4 col-md-6">
                    <div class="contact-card">
                        <div class="contact-icon">
                            <i class="fas fa-comments"></i>
                        </div>
                        <h3 class="fw-bold mb-3 text-white">Live Chat</h3>
                        <p class="text-muted mb-4">Get instant answers from our AI assistant or connect with a human agent.</p>
                        <div class="contact-details">
                            <h4 class="text-primary fw-bold">24/7 Available</h4>
                            <p class="text-muted small">Instant connection</p>
                        </div>
                        <button class="btn btn-outline-primary w-100 mt-3" onclick="openChat()">
                            <i class="fas fa-comment me-2"></i>Start Chat
                        </button>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Contact Form & Info Section -->
    <section id="contact-form" class="contact-form-section py-5">
        <div class="container">
            <div class="row g-5">
                <!-- Contact Form -->
                <div class="col-lg-8">
                    <div class="contact-form">
                        <h3 class="fw-bold mb-4 text-white">Send Us a Message</h3>
                        <p class="text-muted mb-4">Fill out the form below and our team will get back to you as soon as possible.</p>
                        
                        <div class="row g-3">
                            <div class="col-md-6">
                                <label class="form-label">Full Name *</label>
                                <input type="text" class="form-control" placeholder="Enter your full name" required>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Email Address *</label>
                                <input type="email" class="form-control" placeholder="Enter your email" required>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Phone Number</label>
                                <input type="tel" class="form-control" placeholder="Enter your phone number">
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Subject *</label>
                                <select class="form-control" required>
                                    <option value="">Select a subject</option>
                                    <option value="general">General Inquiry</option>
                                    <option value="support">Technical Support</option>
                                    <option value="partnership">Partnership</option>
                                    <option value="municipality">Municipal Services</option>
                                    <option value="business">Business Solutions</option>
                                    <option value="other">Other</option>
                                </select>
                            </div>
                            <div class="col-12">
                                <label class="form-label">Message *</label>
                                <textarea class="form-control" rows="6" placeholder="Tell us about your inquiry..." required></textarea>
                            </div>
                            <div class="col-12">
                                <div class="form-check">
                                    <input class="form-check-input" type="checkbox" id="newsletter">
                                    <label class="form-check-label text-muted" for="newsletter">
                                        Subscribe to our newsletter for updates and sustainability tips
                                    </label>
                                </div>
                            </div>
                            <div class="col-12">
                                <button type="submit" class="btn btn-primary w-100">
                                    <i class="fas fa-paper-plane me-2"></i>Send Message
                                </button>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Contact Information -->
                <div class="col-lg-4">
                    <h3 class="fw-bold mb-4 text-white">Contact Information</h3>
                    
                    <div class="contact-info-item">
                        <div class="contact-info-icon">
                            <i class="fas fa-map-marker-alt"></i>
                        </div>
                        <div>
                            <h5 class="fw-bold text-white mb-2">Headquarters</h5>
                            <p class="text-muted mb-0">123 Green Street<br>Eco City, EC 12345<br>United States</p>
                        </div>
                    </div>

                    <div class="contact-info-item">
                        <div class="contact-info-icon">
                            <i class="fas fa-clock"></i>
                        </div>
                        <div>
                            <h5 class="fw-bold text-white mb-2">Business Hours</h5>
                            <p class="text-muted mb-0">
                                Monday - Friday: 8:00 AM - 6:00 PM<br>
                                Saturday: 9:00 AM - 2:00 PM<br>
                                Sunday: Closed
                            </p>
                        </div>
                    </div>

                    <div class="contact-info-item">
                        <div class="contact-info-icon">
                            <i class="fas fa-phone"></i>
                        </div>
                        <div>
                            <h5 class="fw-bold text-white mb-2">Phone Numbers</h5>
                            <p class="text-muted mb-0">
                                General: +1 (555) 123-4567<br>
                                Support: +1 (555) 123-4568<br>
                                Sales: +1 (555) 123-4569
                            </p>
                        </div>
                    </div>

                    <div class="contact-info-item">
                        <div class="contact-info-icon">
                            <i class="fas fa-envelope"></i>
                        </div>
                        <div>
                            <h5 class="fw-bold text-white mb-2">Email Addresses</h5>
                            <p class="text-muted mb-0">
                                General: info@soorgreen.com<br>
                                Support: support@soorgreen.com<br>
                                Sales: sales@soorgreen.com
                            </p>
                        </div>
                    </div>

                    <div class="mt-4">
                        <h5 class="fw-bold text-white mb-3">Follow Us</h5>
                        <div class="social-links">
                            <a href="#" class="social-link"><i class="fab fa-facebook-f"></i></a>
                            <a href="#" class="social-link"><i class="fab fa-twitter"></i></a>
                            <a href="#" class="social-link"><i class="fab fa-linkedin-in"></i></a>
                            <a href="#" class="social-link"><i class="fab fa-instagram"></i></a>
                            <a href="#" class="social-link"><i class="fab fa-youtube"></i></a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Rest of your content remains exactly the same -->
    <!-- [Include all the remaining sections from your original code] -->

    <script>
        // FAQ Toggle Functionality
        document.addEventListener('DOMContentLoaded', function () {
            // FAQ functionality
            document.querySelectorAll('.faq-question').forEach(question => {
                question.addEventListener('click', () => {
                    const item = question.parentElement;
                    item.classList.toggle('active');
                });
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

            // Form submission handling
            const contactForm = document.querySelector('.contact-form form');
            if (contactForm) {
                contactForm.addEventListener('submit', function (e) {
                    e.preventDefault();
                    // Here you would typically handle form submission
                    alert('Thank you for your message! We will get back to you soon.');
                    this.reset();
                });
            }
        });

        // Live chat simulation
        function openChat() {
            alert('Live chat would open here! In a real implementation, this would connect to your chat service.');
        }
    </script>
</asp:Content>