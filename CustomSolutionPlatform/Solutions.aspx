<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Solutions.aspx.cs" Inherits="SoorGreen.CustomSolutionPlatform.Solutions" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Your Custom Solution - SoorGreen Platform</title>
    
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" />
    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800;900&display=swap" rel="stylesheet" />
    
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
        
        body {
            font-family: 'Inter', sans-serif;
            background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
            color: #333;
            min-height: 100vh;
            padding-top: 20px;
        }
        
        .solution-container {
            max-width: 1200px;
            margin: 0 auto;
        }
        
        .solution-header {
            background: linear-gradient(135deg, var(--darker) 0%, var(--dark) 100%);
            color: white;
            padding: 40px;
            border-radius: 25px 25px 0 0;
        }
        
        .solution-card {
            background: white;
            border-radius: 25px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.1);
            overflow: hidden;
            margin-bottom: 40px;
        }
        
        .solution-content {
            padding: 40px;
        }
        
        .solution-section {
            margin-bottom: 40px;
            padding-bottom: 30px;
            border-bottom: 1px solid rgba(0,0,0,0.1);
        }
        
        .solution-section:last-child {
            border-bottom: none;
        }
        
        .section-title {
            color: var(--primary);
            font-weight: 700;
            margin-bottom: 25px;
            display: flex;
            align-items: center;
            gap: 15px;
            font-size: 1.5rem;
        }
        
        .section-title i {
            width: 50px;
            height: 50px;
            background: rgba(0, 212, 170, 0.1);
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.2rem;
        }
        
        .feature-badge {
            display: inline-block;
            background: rgba(0, 212, 170, 0.1);
            color: var(--primary);
            padding: 8px 20px;
            border-radius: 50px;
            margin: 5px;
            font-weight: 500;
            border: 1px solid rgba(0, 212, 170, 0.3);
        }
        
        .tech-badge {
            display: inline-block;
            background: rgba(9, 132, 227, 0.1);
            color: var(--secondary);
            padding: 8px 20px;
            border-radius: 50px;
            margin: 5px;
            font-weight: 500;
            border: 1px solid rgba(9, 132, 227, 0.3);
        }
        
        .timeline-item {
            position: relative;
            padding-left: 30px;
            margin-bottom: 30px;
        }
        
        .timeline-item:before {
            content: '';
            position: absolute;
            left: 0;
            top: 0;
            width: 12px;
            height: 12px;
            background: var(--primary);
            border-radius: 50%;
        }
        
        .timeline-item:after {
            content: '';
            position: absolute;
            left: 5px;
            top: 12px;
            width: 2px;
            height: calc(100% + 18px);
            background: rgba(0, 212, 170, 0.3);
        }
        
        .timeline-item:last-child:after {
            display: none;
        }
        
        .action-buttons {
            display: flex;
            gap: 15px;
            flex-wrap: wrap;
            margin-top: 30px;
        }
        
        .btn-action {
            padding: 12px 30px;
            border-radius: 50px;
            font-weight: 600;
            font-size: 1rem;
            transition: all 0.3s ease;
            display: inline-flex;
            align-items: center;
            gap: 10px;
            text-decoration: none;
            border: none;
        }
        
        .btn-primary-action {
            background: linear-gradient(135deg, var(--primary), var(--primary-dark));
            color: white;
        }
        
        .btn-primary-action:hover {
            background: linear-gradient(135deg, var(--primary-dark), #00a085);
            color: white;
            transform: translateY(-3px);
            box-shadow: 0 10px 25px rgba(0, 180, 148, 0.3);
        }
        
        .btn-secondary-action {
            background: rgba(0, 212, 170, 0.1);
            color: var(--primary);
            border: 1px solid var(--primary);
        }
        
        .btn-secondary-action:hover {
            background: var(--primary);
            color: white;
            transform: translateY(-3px);
        }
        
        .complexity-badge {
            display: inline-block;
            padding: 6px 15px;
            border-radius: 50px;
            font-weight: 600;
            font-size: 0.9rem;
        }
        
        .complexity-low {
            background: rgba(46, 204, 113, 0.2);
            color: #27ae60;
        }
        
        .complexity-medium {
            background: rgba(243, 156, 18, 0.2);
            color: #f39c12;
        }
        
        .complexity-high {
            background: rgba(231, 76, 60, 0.2);
            color: #e74c3c;
        }
        
        .cost-badge {
            font-size: 1.5rem;
            font-weight: 800;
            color: var(--primary);
            margin: 10px 0;
        }
        
        @media (max-width: 768px) {
            .solution-header,
            .solution-content {
                padding: 25px;
            }
            
            .action-buttons {
                flex-direction: column;
            }
            
            .btn-action {
                width: 100%;
                justify-content: center;
            }
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="solution-container">
            <div class="solution-card">
                <!-- Header -->
                <div class="solution-header">
                    <div class="row align-items-center">
                        <div class="col-md-8">
                            <h1 class="display-6 fw-bold mb-3" id="solutionTitle" runat="server">Your Custom Solution</h1>
                            <div class="d-flex align-items-center gap-3 flex-wrap mb-3">
                                <span class="complexity-badge" id="complexityBadge" runat="server">Medium Complexity</span>
                                <span class="text-white-50"><i class="fas fa-clock"></i> <span id="estimatedTime" runat="server">200 hours</span></span>
                                <span class="text-white-50"><i class="fas fa-user-tag"></i> <span id="solutionType" runat="server">IT Solution</span></span>
                            </div>
                        </div>
                        <div class="col-md-4 text-md-end">
                            <div class="cost-badge" id="costEstimate" runat="server">$25,000</div>
                            <small class="text-white-50">Estimated Cost</small>
                        </div>
                    </div>
                </div>
                
                <!-- Content -->
                <div class="solution-content">
                    <!-- Problem Statement -->
                    <div class="solution-section" id="problemSection" runat="server" visible="false">
                        <div class="section-title">
                            <i class="fas fa-exclamation-circle"></i>
                            Problem Statement
                        </div>
                        <p class="fs-5" id="problemStatement" runat="server"></p>
                    </div>
                    
                    <!-- Proposed Solution -->
                    <div class="solution-section">
                        <div class="section-title">
                            <i class="fas fa-lightbulb"></i>
                            Proposed Solution
                        </div>
                        <p class="fs-5" id="proposedSolution" runat="server"></p>
                    </div>
                    
                    <!-- Key Features -->
                    <div class="solution-section" id="featuresSection" runat="server" visible="false">
                        <div class="section-title">
                            <i class="fas fa-star"></i>
                            Key Features
                        </div>
                        <div id="featuresContainer" runat="server">
                            <!-- Features will be dynamically added -->
                        </div>
                    </div>
                    
                    <!-- Technology Stack -->
                    <div class="solution-section" id="techSection" runat="server" visible="false">
                        <div class="section-title">
                            <i class="fas fa-code"></i>
                            Technology Stack
                        </div>
                        <div id="techStackContainer" runat="server">
                            <!-- Technologies will be dynamically added -->
                        </div>
                    </div>
                    
                    <!-- Implementation Timeline -->
                    <div class="solution-section" id="timelineSection" runat="server" visible="false">
                        <div class="section-title">
                            <i class="fas fa-calendar-alt"></i>
                            Implementation Timeline
                        </div>
                        <div id="timelineContainer" runat="server">
                            <!-- Timeline will be dynamically added -->
                        </div>
                    </div>
                    
                    <!-- Action Buttons -->
                    <div class="solution-section text-center">
                        <div class="action-buttons justify-content-center">
                            <asp:Button ID="btnDownloadPDF" runat="server" Text="Download PDF" 
                                CssClass="btn-action btn-primary-action" OnClick="btnDownloadPDF_Click">
                                <i class="fas fa-file-pdf"></i> Download PDF
                            </asp:Button>
                            
                            <asp:Button ID="btnSaveSolution" runat="server" Text="Save Solution" 
                                CssClass="btn-action btn-secondary-action" OnClick="btnSaveSolution_Click">
                                <i class="fas fa-save"></i> Save Solution
                            </asp:Button>
                            
                            <a href="Default.aspx" class="btn-action btn-secondary-action">
                                <i class="fas fa-redo"></i> Start New Questionnaire
                            </a>
                            
                            <a href="#" class="btn-action btn-secondary-action" data-bs-toggle="modal" data-bs-target="#feedbackModal">
                                <i class="fas fa-comment"></i> Provide Feedback
                            </a>
                        </div>
                    </div>
                </div>
            </div>
            
            <!-- Success Message -->
            <div class="alert alert-success alert-dismissible fade show" id="successMessage" runat="server" visible="false">
                <i class="fas fa-check-circle me-2"></i>
                <asp:Label ID="lblSuccessMessage" runat="server" Text=""></asp:Label>
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
        </div>
        
        <!-- Feedback Modal -->
        <div class="modal fade" id="feedbackModal" tabindex="-1" aria-hidden="true">
            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title"><i class="fas fa-comment me-2"></i>Provide Feedback</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                        <div class="mb-3">
                            <label class="form-label">Overall Rating</label>
                            <div class="d-flex gap-2 mb-2" id="ratingStars">
                                <i class="fas fa-star text-warning" style="font-size: 1.5rem; cursor: pointer;"></i>
                                <i class="fas fa-star text-warning" style="font-size: 1.5rem; cursor: pointer;"></i>
                                <i class="fas fa-star text-warning" style="font-size: 1.5rem; cursor: pointer;"></i>
                                <i class="fas fa-star text-warning" style="font-size: 1.5rem; cursor: pointer;"></i>
                                <i class="fas fa-star text-warning" style="font-size: 1.5rem; cursor: pointer;"></i>
                            </div>
                            <input type="hidden" id="hdnRating" value="5" />
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Comments</label>
                            <textarea class="form-control" id="txtComments" rows="4" placeholder="What did you think of the solution? Any suggestions for improvement?"></textarea>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                        <asp:Button ID="btnSubmitFeedback" runat="server" Text="Submit Feedback" 
                            CssClass="btn btn-primary" OnClick="btnSubmitFeedback_Click" />
                    </div>
                </div>
            </div>
        </div>
        
        <!-- Hidden Fields -->
        <asp:HiddenField ID="hdnSolutionId" runat="server" />
        <asp:HiddenField ID="hdnSessionId" runat="server" />
    </form>

    <!-- Scripts -->
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    
    <script>
        $(document).ready(function() {
            // Rating stars interaction
            $('#ratingStars i').on('click', function() {
                var rating = $(this).index() + 1;
                $('#ratingStars i').removeClass('fas').addClass('far');
                $('#ratingStars i:lt(' + rating + ')').removeClass('far').addClass('fas');
                $('#hdnRating').val(rating);
            });
            
            // Initialize stars
            $('#ratingStars i').removeClass('fas').addClass('far');
            $('#ratingStars i:lt(5)').removeClass('far').addClass('fas');
            
            // Download PDF confirmation
            $('#<%= btnDownloadPDF.ClientID %>').on('click', function() {
                if (confirm('This will generate and download a PDF version of your solution. Continue?')) {
                    return true;
                }
                return false;
            });
            
            // Save solution confirmation
            $('#<%= btnSaveSolution.ClientID %>').on('click', function() {
                if (confirm('Save this solution to your account for future reference?')) {
                    return true;
                }
                return false;
            });
        });
    </script>
</body>
</html>