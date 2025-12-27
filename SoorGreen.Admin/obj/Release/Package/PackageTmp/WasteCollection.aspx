<%@ Page Title="Waste Collection" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="false" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <style>
        /* Text Visibility Fixes */
        .hero-subtitle {
            color: rgba(255, 255, 255, 0.9) !important;
            font-size: 1.2rem;
            line-height: 1.6;
        }

        .text-muted {
            color: rgba(255, 255, 255, 0.8) !important;
        }

        .text-white-50 {
            color: rgba(255, 255, 255, 0.9) !important;
        }

        .lead.text-muted {
            color: rgba(255, 255, 255, 0.85) !important;
            font-size: 1.1rem;
        }

        .form-label {
            color: rgba(255, 255, 255, 0.95) !important;
            font-weight: 600;
        }

        .text-white {
            color: rgba(255, 255, 255, 0.95) !important;
        }

        /* Simple Animation Styles */
        .animate-on-scroll {
            opacity: 0;
            transform: translateY(30px);
            transition: all 0.6s ease;
        }

        .animate-on-scroll.visible {
            opacity: 1;
            transform: translateY(0);
        }

        .animate-fade-in {
            opacity: 0;
            animation: fadeIn 1s ease forwards;
        }

        .delay-1 { animation-delay: 0.2s; }
        .delay-2 { animation-delay: 0.4s; }
        .delay-3 { animation-delay: 0.6s; }

        @keyframes fadeIn {
            to { opacity: 1; }
        }

        /* Waste Collection Specific Styles */
        .collection-hero-section {
            min-height: 70vh;
            display: flex;
            align-items: center;
            position: relative;
            overflow: hidden;
            background: radial-gradient(ellipse at center, rgba(0, 212, 170, 0.1) 0%, transparent 70%);
            padding-top: 100px;
        }

        .collection-floating-element {
            position: absolute;
            font-size: 2rem;
            opacity: 0.3;
            animation: floatElement 15s ease-in-out infinite;
        }

        .collection-element-1 {
            top: 20%;
            left: 10%;
            animation-delay: 0s;
        }

        .collection-element-2 {
            top: 60%;
            right: 15%;
            animation-delay: 5s;
        }

        .collection-element-3 {
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

        .collection-hero-image {
            background: linear-gradient(45deg, var(--primary), var(--secondary));
            height: 400px;
            width: 100%;
            border-radius: 20px;
            position: relative;
            overflow: hidden;
        }

        .collection-hero-image::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: url('data:image/svg+xml,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100"><circle cx="50" cy="50" r="2" fill="white" opacity="0.1"/></svg>') repeat;
            animation: sparkle 4s linear infinite;
        }

        /* Waste Type Cards */
        .waste-type-card {
            background: var(--card-bg);
            border: 1px solid var(--card-border);
            border-radius: 20px;
            transition: all 0.3s ease;
            backdrop-filter: blur(10px);
            height: 100%;
        }

        .waste-type-card:hover {
            transform: translateY(-10px);
            border-color: var(--primary);
            box-shadow: 0 25px 50px rgba(0, 0, 0, 0.3);
        }

        .waste-icon {
            font-size: 3rem;
            color: var(--primary);
        }

        .credit-badge {
            background: linear-gradient(45deg, var(--primary), var(--secondary));
            color: white;
            padding: 0.5rem 1rem;
            border-radius: 25px;
            font-weight: 600;
        }

        /* Schedule Section */
        .schedule-card {
            background: var(--card-bg);
            border: 1px solid var(--card-border);
            border-radius: 20px;
            transition: all 0.3s ease;
            backdrop-filter: blur(10px);
        }

        .schedule-card:hover {
            transform: translateY(-5px);
            border-color: var(--primary);
        }

        .step-indicator {
            width: 40px;
            height: 40px;
            background: linear-gradient(45deg, var(--primary), var(--secondary));
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 700;
            color: white;
            flex-shrink: 0;
        }

        /* Active Pickups Section */
        .pickup-card {
            background: var(--card-bg);
            border: 1px solid var(--card-border);
            border-radius: 15px;
            transition: all 0.3s ease;
            backdrop-filter: blur(10px);
        }

        .pickup-card:hover {
            transform: translateY(-5px);
            border-color: var(--primary);
        }

        .status-badge {
            padding: 0.5rem 1rem;
            border-radius: 20px;
            font-weight: 600;
            font-size: 0.8rem;
        }

        .status-requested { background: rgba(255, 193, 7, 0.2); color: #ffc107; border: 1px solid rgba(255, 193, 7, 0.3); }
        .status-assigned { background: rgba(0, 123, 255, 0.2); color: #007bff; border: 1px solid rgba(0, 123, 255, 0.3); }
        .status-collected { background: rgba(40, 167, 69, 0.2); color: #28a745; border: 1px solid rgba(40, 167, 69, 0.3); }

        /* Rewards Section */
        .rewards-section {
            background: linear-gradient(135deg, var(--primary), var(--secondary)) !important;
        }

        .reward-stat {
            padding: 2rem 1rem;
        }

        .reward-number {
            text-shadow: 0 0 20px rgba(255, 255, 255, 0.3);
        }

        /* How It Works */
        .process-card {
            background: var(--card-bg);
            border: 1px solid var(--card-border);
            border-radius: 20px;
            transition: all 0.3s ease;
            backdrop-filter: blur(10px);
            height: 100%;
        }

        .process-card:hover {
            transform: translateY(-5px);
            border-color: var(--primary);
        }

        .process-icon {
            font-size: 2.5rem;
            color: var(--primary);
        }

        /* Collection Map */
        .collection-map {
            background: linear-gradient(45deg, var(--primary), var(--secondary));
            height: 400px;
            width: 100%;
            border-radius: 20px;
            position: relative;
            overflow: hidden;
        }

        .map-marker {
            position: absolute;
            width: 20px;
            height: 20px;
            background: var(--accent);
            border-radius: 50%;
            transform: translate(-50%, -50%);
            animation: pulse 2s infinite;
        }

        @keyframes pulse {
            0% { transform: translate(-50%, -50%) scale(1); opacity: 1; }
            50% { transform: translate(-50%, -50%) scale(1.5); opacity: 0.7; }
            100% { transform: translate(-50%, -50%) scale(1); opacity: 1; }
        }

        /* Form Controls */
        .form-control, .form-select {
            background: rgba(255, 255, 255, 0.1) !important;
            border: 1px solid rgba(255, 255, 255, 0.2) !important;
            color: white !important;
        }

        .form-control::placeholder {
            color: rgba(255, 255, 255, 0.6) !important;
        }

        .form-control:focus, .form-select:focus {
            background: rgba(255, 255, 255, 0.15) !important;
            border-color: var(--primary) !important;
            color: white !important;
            box-shadow: 0 0 0 0.2rem rgba(0, 212, 170, 0.25) !important;
        }

        /* Progress Bar */
        .progress {
            background: rgba(255, 255, 255, 0.1) !important;
        }

        .progress-bar {
            background: var(--primary) !important;
        }

        /* Responsive */
        @media (max-width: 768px) {
            .collection-hero-section {
                min-height: auto;
                padding: 100px 0 50px;
            }
            
            .collection-floating-element {
                display: none;
            }
            
            .collection-hero-image {
                height: 300px;
                margin-top: 2rem;
            }
            
            .collection-map {
                height: 300px;
                margin-bottom: 2rem;
            }
        }
    </style>

    <!-- Hero Section -->
    <section class="collection-hero-section">
        <div class="container">
            <div class="row align-items-center">
                <div class="col-lg-6">
                    <span class="section-badge px-3 py-2 rounded-pill mb-3 animate-fade-in">Smart Collection</span>
                    <h1 class="hero-title mb-4 animate-fade-in delay-1">Schedule Waste Pickup & Earn Rewards</h1>
                    <p class="hero-subtitle mb-4 animate-fade-in delay-2">Request waste collection in just a few taps, track pickup status in real-time, and earn credits for your sustainable efforts. Join thousands of users making a difference in their communities.</p>
                    <div class="d-flex flex-wrap gap-3 animate-fade-in delay-3">
                        <a href="#schedule" class="btn btn-hero">
                            <i class="fas fa-calendar-plus me-2"></i>Schedule Pickup
                        </a>
                        <a href="#track" class="btn btn-outline-hero">
                            <i class="fas fa-map-marker-alt me-2"></i>Track Collection
                        </a>
                    </div>
                    <div class="mt-4 d-flex gap-4 text-white-50 animate-fade-in delay-3">
                        <div class="d-flex align-items-center gap-2">
                            <i class="fas fa-check-circle text-success"></i>
                            <span>Instant Scheduling</span>
                        </div>
                        <div class="d-flex align-items-center gap-2">
                            <i class="fas fa-check-circle text-success"></i>
                            <span>Real-time Tracking</span>
                        </div>
                        <div class="d-flex align-items-center gap-2">
                            <i class="fas fa-check-circle text-success"></i>
                            <span>Instant Rewards</span>
                        </div>
                    </div>
                </div>
                <div class="col-lg-6 text-center">
                    <div class="collection-hero-visual position-relative">
                        <div class="collection-floating-element collection-element-1">
                            <i class="fas fa-trash-alt text-success"></i>
                        </div>
                        <div class="collection-floating-element collection-element-2">
                            <i class="fas fa-truck text-primary"></i>
                        </div>
                        <div class="collection-floating-element collection-element-3">
                            <i class="fas fa-coins text-warning"></i>
                        </div>
                        <div class="collection-hero-image rounded-3 shadow-lg animate-fade-in delay-2"></div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Waste Types Section -->
    <section class="waste-types-section py-5">
        <div class="container">
            <div class="row text-center mb-5">
                <div class="col-lg-8 mx-auto">
                    <span class="section-badge bg-success bg-opacity-10 text-success px-3 py-2 rounded-pill mb-3 animate-on-scroll">Accepted Materials</span>
                    <h2 class="fw-bold display-5 mb-3 text-white animate-on-scroll">What We Collect</h2>
                    <p class="lead text-muted fs-6 animate-on-scroll">Earn different credit rates based on material type and recycling value. Every kilogram counts towards a greener planet!</p>
                </div>
            </div>
            <div class="row g-4">
                <div class="col-lg-4 col-md-6">
                    <div class="waste-type-card text-center p-4 animate-on-scroll">
                        <div class="waste-icon mx-auto mb-4">
                            <i class="fas fa-wine-bottle"></i>
                        </div>
                        <h4 class="fw-bold mb-3 text-white">Plastic & Bottles</h4>
                        <p class="text-muted mb-4">PET bottles, HDPE containers, plastic packaging and other recyclable plastics. Help reduce plastic pollution in our oceans.</p>
                        <div class="credit-badge mx-auto">
                            <i class="fas fa-coins me-2"></i>2.5 credits/kg
                        </div>
                    </div>
                </div>
                <div class="col-lg-4 col-md-6">
                    <div class="waste-type-card text-center p-4 animate-on-scroll">
                        <div class="waste-icon mx-auto mb-4">
                            <i class="fas fa-newspaper"></i>
                        </div>
                        <h4 class="fw-bold mb-3 text-white">Paper & Cardboard</h4>
                        <p class="text-muted mb-4">Newspapers, cardboard boxes, office paper, magazines and paper packaging. Save trees with every collection.</p>
                        <div class="credit-badge mx-auto">
                            <i class="fas fa-coins me-2"></i>1.8 credits/kg
                        </div>
                    </div>
                </div>
                <div class="col-lg-4 col-md-6">
                    <div class="waste-type-card text-center p-4 animate-on-scroll">
                        <div class="waste-icon mx-auto mb-4">
                            <i class="fas fa-cube"></i>
                        </div>
                        <h4 class="fw-bold mb-3 text-white">Glass Containers</h4>
                        <p class="text-muted mb-4">Glass bottles, jars, and other glass containers. Please separate by color when possible. Glass is 100% recyclable!</p>
                        <div class="credit-badge mx-auto">
                            <i class="fas fa-coins me-2"></i>1.2 credits/kg
                        </div>
                    </div>
                </div>
                <div class="col-lg-4 col-md-6">
                    <div class="waste-type-card text-center p-4 animate-on-scroll">
                        <div class="waste-icon mx-auto mb-4">
                            <i class="fas fa-microchip"></i>
                        </div>
                        <h4 class="fw-bold mb-3 text-white">E-Waste</h4>
                        <p class="text-muted mb-4">Electronics, batteries, cables, and small electrical appliances. Special handling required. Prevent hazardous waste.</p>
                        <div class="credit-badge mx-auto">
                            <i class="fas fa-coins me-2"></i>5.0 credits/kg
                        </div>
                    </div>
                </div>
                <div class="col-lg-4 col-md-6">
                    <div class="waste-type-card text-center p-4 animate-on-scroll">
                        <div class="waste-icon mx-auto mb-4">
                            <i class="fas fa-utensils"></i>
                        </div>
                        <h4 class="fw-bold mb-3 text-white">Metals</h4>
                        <p class="text-muted mb-4">Aluminum cans, tin cans, metal packaging, and small metal household items. Metals can be recycled infinitely.</p>
                        <div class="credit-badge mx-auto">
                            <i class="fas fa-coins me-2"></i>3.5 credits/kg
                        </div>
                    </div>
                </div>
                <div class="col-lg-4 col-md-6">
                    <div class="waste-type-card text-center p-4 animate-on-scroll">
                        <div class="waste-icon mx-auto mb-4">
                            <i class="fas fa-leaf"></i>
                        </div>
                        <h4 class="fw-bold mb-3 text-white">Organic Waste</h4>
                        <p class="text-muted mb-4">Food scraps, yard waste, and other compostable materials for community composting. Create nutrient-rich soil.</p>
                        <div class="credit-badge mx-auto">
                            <i class="fas fa-coins me-2"></i>0.8 credits/kg
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- How It Works Section -->
    <section class="process-section py-5">
        <div class="container">
            <div class="row text-center mb-5">
                <div class="col-lg-8 mx-auto">
                    <span class="section-badge bg-info bg-opacity-10 text-info px-3 py-2 rounded-pill mb-3 animate-on-scroll">Simple Process</span>
                    <h2 class="fw-bold display-5 mb-3 text-white animate-on-scroll">How Collection Works</h2>
                    <p class="lead text-muted fs-6 animate-on-scroll">Four simple steps to schedule and complete your waste collection. Easy for you, better for the planet!</p>
                </div>
            </div>
            <div class="row g-4">
                <div class="col-lg-3 col-md-6">
                    <div class="process-card text-center p-4 animate-on-scroll">
                        <div class="process-icon mx-auto mb-4">
                            <i class="fas fa-mobile-alt"></i>
                        </div>
                        <h4 class="fw-bold mb-3 text-white">1. Schedule</h4>
                        <p class="text-muted">Use our app or website to schedule a pickup at your convenience. Select waste type and preferred time.</p>
                    </div>
                </div>
                <div class="col-lg-3 col-md-6">
                    <div class="process-card text-center p-4 animate-on-scroll">
                        <div class="process-icon mx-auto mb-4">
                            <i class="fas fa-box-open"></i>
                        </div>
                        <h4 class="fw-bold mb-3 text-white">2. Prepare</h4>
                        <p class="text-muted">Separate your waste by type and place it in the designated area. Ensure it's accessible for collection.</p>
                    </div>
                </div>
                <div class="col-lg-3 col-md-6">
                    <div class="process-card text-center p-4 animate-on-scroll">
                        <div class="process-icon mx-auto mb-4">
                            <i class="fas fa-truck-loading"></i>
                        </div>
                        <h4 class="fw-bold mb-3 text-white">3. Collect</h4>
                        <p class="text-muted">Our verified collector picks up your waste at the scheduled time. Track their arrival in real-time.</p>
                    </div>
                </div>
                <div class="col-lg-3 col-md-6">
                    <div class="process-card text-center p-4 animate-on-scroll">
                        <div class="process-icon mx-auto mb-4">
                            <i class="fas fa-coins"></i>
                        </div>
                        <h4 class="fw-bold mb-3 text-white">4. Earn</h4>
                        <p class="text-muted">Receive credits based on the type and weight of materials collected. Redeem rewards instantly!</p>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Schedule Section -->
    <section id="schedule" class="schedule-section py-5">
        <div class="container">
            <div class="row align-items-center">
                <div class="col-lg-6">
                    <span class="section-badge bg-warning bg-opacity-10 text-warning px-3 py-2 rounded-pill mb-3 animate-on-scroll">Schedule Pickup</span>
                    <h2 class="fw-bold display-5 mb-4 text-white animate-on-scroll">Ready to Schedule Your Pickup?</h2>
                    <p class="text-muted mb-4 animate-on-scroll">Fill out the simple form below to request a waste collection. Our system will match you with the nearest available collector and provide real-time updates.</p>
                    
                    <div class="schedule-steps">
                        <div class="d-flex align-items-start mb-4 animate-on-scroll">
                            <div class="step-indicator me-4">1</div>
                            <div>
                                <h5 class="fw-bold text-white mb-2">Select Waste Type</h5>
                                <p class="text-muted mb-0">Choose from our accepted materials list above. Different materials earn different credit rates.</p>
                            </div>
                        </div>
                        <div class="d-flex align-items-start mb-4 animate-on-scroll">
                            <div class="step-indicator me-4">2</div>
                            <div>
                                <h5 class="fw-bold text-white mb-2">Estimate Quantity</h5>
                                <p class="text-muted mb-0">Provide approximate weight for accurate collection and credit calculation.</p>
                            </div>
                        </div>
                        <div class="d-flex align-items-start mb-4 animate-on-scroll">
                            <div class="step-indicator me-4">3</div>
                            <div>
                                <h5 class="fw-bold text-white mb-2">Choose Time</h5>
                                <p class="text-muted mb-0">Select your preferred pickup date and time. We offer flexible scheduling options.</p>
                            </div>
                        </div>
                        <div class="d-flex align-items-start animate-on-scroll">
                            <div class="step-indicator me-4">4</div>
                            <div>
                                <h5 class="fw-bold text-white mb-2">Confirm & Track</h5>
                                <p class="text-muted mb-0">Get instant confirmation and track your pickup in real-time through our app.</p>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-lg-6">
                    <div class="schedule-card p-5 animate-on-scroll">
                        <h4 class="fw-bold mb-4 text-white text-center">Schedule New Pickup</h4>
                        
                        <div class="mb-4">
                            <label class="form-label text-white fw-semibold">Waste Type</label>
                            <select class="form-select">
                                <option selected>Select waste type...</option>
                                <option value="plastic">Plastic & Bottles (2.5 credits/kg)</option>
                                <option value="paper">Paper & Cardboard (1.8 credits/kg)</option>
                                <option value="glass">Glass Containers (1.2 credits/kg)</option>
                                <option value="ewaste">E-Waste (5.0 credits/kg)</option>
                                <option value="metal">Metals (3.5 credits/kg)</option>
                                <option value="organic">Organic Waste (0.8 credits/kg)</option>
                            </select>
                        </div>
                        
                        <div class="mb-4">
                            <label class="form-label text-white fw-semibold">Estimated Weight (kg)</label>
                            <input type="number" class="form-control" placeholder="Enter approximate weight">
                        </div>
                        
                        <div class="mb-4">
                            <label class="form-label text-white fw-semibold">Pickup Address</label>
                            <textarea class="form-control" rows="3" placeholder="Enter your full address"></textarea>
                        </div>
                        
                        <div class="mb-4">
                            <label class="form-label text-white fw-semibold">Preferred Date & Time</label>
                            <input type="datetime-local" class="form-control">
                        </div>
                        
                        <div class="mb-4">
                            <label class="form-label text-white fw-semibold">Upload Photo (Optional)</label>
                            <input type="file" class="form-control" accept="image/*">
                        </div>
                        
                        <button class="btn btn-hero w-100">
                            <i class="fas fa-calendar-check me-2"></i>Schedule Pickup
                        </button>
                        
                        <div class="text-center mt-3">
                            <small class="text-muted">Estimated credits: <span class="text-warning fw-semibold">12.5 credits</span></small>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Active Pickups Section -->
    <section id="track" class="pickups-section py-5">
        <div class="container">
            <div class="row text-center mb-5">
                <div class="col-lg-8 mx-auto">
                    <span class="section-badge bg-primary bg-opacity-10 text-primary px-3 py-2 rounded-pill mb-3 animate-on-scroll">Live Tracking</span>
                    <h2 class="fw-bold display-5 mb-3 text-white animate-on-scroll">Active Collections</h2>
                    <p class="lead text-muted fs-6 animate-on-scroll">Track your scheduled pickups in real-time and monitor their progress.</p>
                </div>
            </div>
            
            <div class="row mb-5">
                <div class="col-12">
                    <div class="collection-map rounded-3 shadow animate-on-scroll"></div>
                </div>
            </div>
            
            <div class="row g-4">
                <div class="col-lg-6">
                    <div class="pickup-card p-4 animate-on-scroll">
                        <div class="d-flex justify-content-between align-items-start mb-3">
                            <div>
                                <h5 class="fw-bold text-white mb-1">Plastic & Bottles Collection</h5>
                                <p class="text-muted mb-2">123 Green Street, Eco City • Scheduled for today</p>
                            </div>
                            <span class="status-badge status-assigned">Assigned</span>
                        </div>
                        <div class="row text-center">
                            <div class="col-4">
                                <div class="text-muted small">Estimated</div>
                                <div class="fw-bold text-white">5.2 kg</div>
                            </div>
                            <div class="col-4">
                                <div class="text-muted small">Credits</div>
                                <div class="fw-bold text-warning">13.0</div>
                            </div>
                            <div class="col-4">
                                <div class="text-muted small">Scheduled</div>
                                <div class="fw-bold text-white">Today, 2:00 PM</div>
                            </div>
                        </div>
                        <div class="mt-3">
                            <div class="progress" style="height: 8px;">
                                <div class="progress-bar" style="width: 60%"></div>
                            </div>
                            <div class="d-flex justify-content-between mt-1">
                                <small class="text-muted">Scheduled</small>
                                <small class="text-muted">In Progress</small>
                                <small class="text-muted">Completed</small>
                            </div>
                        </div>
                    </div>
                </div>
                
                <div class="col-lg-6">
                    <div class="pickup-card p-4 animate-on-scroll">
                        <div class="d-flex justify-content-between align-items-start mb-3">
                            <div>
                                <h5 class="fw-bold text-white mb-1">E-Waste Collection</h5>
                                <p class="text-muted mb-2">456 Recycling Road, Green Valley • Scheduled for tomorrow</p>
                            </div>
                            <span class="status-badge status-requested">Requested</span>
                        </div>
                        <div class="row text-center">
                            <div class="col-4">
                                <div class="text-muted small">Estimated</div>
                                <div class="fw-bold text-white">3.5 kg</div>
                            </div>
                            <div class="col-4">
                                <div class="text-muted small">Credits</div>
                                <div class="fw-bold text-warning">17.5</div>
                            </div>
                            <div class="col-4">
                                <div class="text-muted small">Scheduled</div>
                                <div class="fw-bold text-white">Tomorrow, 10:00 AM</div>
                            </div>
                        </div>
                        <div class="mt-3">
                            <div class="progress" style="height: 8px;">
                                <div class="progress-bar bg-warning" style="width: 30%"></div>
                            </div>
                            <div class="d-flex justify-content-between mt-1">
                                <small class="text-muted">Scheduled</small>
                                <small class="text-muted">In Progress</small>
                                <small class="text-muted">Completed</small>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Rewards Section -->
    <section class="rewards-section py-5">
        <div class="container">
            <div class="row text-center mb-5">
                <div class="col-lg-8 mx-auto">
                    <span class="section-badge bg-white bg-opacity-20 text-white px-3 py-2 rounded-pill mb-3 animate-on-scroll">Your Rewards</span>
                    <h2 class="fw-bold display-5 mb-3 text-white animate-on-scroll">Earn While You Recycle</h2>
                    <p class="lead opacity-75 fs-6 animate-on-scroll">Track your environmental impact and rewards earned through sustainable practices.</p>
                </div>
            </div>
            <div class="row g-4 text-center">
                <div class="col-md-3 col-6">
                    <div class="reward-stat animate-on-scroll">
                        <div class="reward-number display-4 fw-bold mb-2">156.5</div>
                        <p class="opacity-75 mb-0">Total Credits</p>
                    </div>
                </div>
                <div class="col-md-3 col-6">
                    <div class="reward-stat animate-on-scroll">
                        <div class="reward-number display-4 fw-bold mb-2">24</div>
                        <p class="opacity-75 mb-0">Pickups Completed</p>
                    </div>
                </div>
                <div class="col-md-3 col-6">
                    <div class="reward-stat animate-on-scroll">
                        <div class="reward-number display-4 fw-bold mb-2">89.3</div>
                        <p class="opacity-75 mb-0">Kg Recycled</p>
                    </div>
                </div>
                <div class="col-md-3 col-6">
                    <div class="reward-stat animate-on-scroll">
                        <div class="reward-number display-4 fw-bold mb-2">8</div>
                        <p class="opacity-75 mb-0">Trees Saved</p>
                    </div>
                </div>
            </div>
            
            <div class="row mt-5">
                <div class="col-lg-8 mx-auto text-center">
                    <h4 class="fw-bold text-white mb-3 animate-on-scroll">Redeem Your Credits</h4>
                    <p class="text-white-75 mb-4 animate-on-scroll">Exchange your earned credits for discounts, vouchers, and exclusive rewards from our partner network. Your sustainability pays off!</p>
                    <div class="d-flex flex-wrap gap-3 justify-content-center animate-on-scroll">
                        <a href="#" class="btn btn-light btn-lg">
                            <i class="fas fa-gift me-2"></i>View Rewards
                        </a>
                        <a href="#" class="btn btn-outline-light btn-lg">
                            <i class="fas fa-history me-2"></i>Transaction History
                        </a>
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
                    <h2 class="fw-bold display-5 mb-3 text-white animate-on-scroll">Start Your Recycling Journey Today</h2>
                    <p class="lead text-muted mb-4 animate-on-scroll">Join thousands of users making a difference in their communities while earning rewards. Together, we can create a cleaner, greener future.</p>
                    <div class="d-flex flex-wrap gap-3 justify-content-center animate-on-scroll">
                        <a href="#schedule" class="btn btn-hero">
                            <i class="fas fa-calendar-plus me-2"></i>Schedule First Pickup
                        </a>
                        <a href="ChooseApp.aspx" class="btn btn-outline-hero">
                            <i class="fas fa-mobile-alt me-2"></i>Download App
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <script>
        // Simple scroll animation
        document.addEventListener('DOMContentLoaded', function () {
            const observer = new IntersectionObserver((entries) => {
                entries.forEach(entry => {
                    if (entry.isIntersecting) {
                        entry.target.classList.add('visible');
                    }
                });
            }, {
                threshold: 0.1,
                rootMargin: '0px 0px -50px 0px'
            });

            // Observe all elements with animate-on-scroll class
            document.querySelectorAll('.animate-on-scroll').forEach(el => {
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

            // Dynamic credit calculation
            const weightInput = document.querySelector('input[type="number"]');
            const wasteTypeSelect = document.querySelector('select');
            const creditDisplay = document.querySelector('.text-warning.fw-semibold');

            const creditRates = {
                'plastic': 2.5,
                'paper': 1.8,
                'glass': 1.2,
                'ewaste': 5.0,
                'metal': 3.5,
                'organic': 0.8
            };

            function updateCredits() {
                const weight = parseFloat(weightInput.value) || 0;
                const wasteType = wasteTypeSelect.value;
                const rate = creditRates[wasteType] || 0;
                const credits = (weight * rate).toFixed(1);
                if (creditDisplay) {
                    creditDisplay.textContent = credits + ' credits';
                }
            }

            if (weightInput && wasteTypeSelect && creditDisplay) {
                weightInput.addEventListener('input', updateCredits);
                wasteTypeSelect.addEventListener('change', updateCredits);
            }
        });
    </script>
</asp:Content>