<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Questionnaire.aspx.cs" Inherits="SoorGreen.CustomSolutionPlatform.Questionnaire" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Custom Solution Questionnaire</title>

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

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Inter', sans-serif;
            background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
            color: #333;
            min-height: 100vh;
            padding-top: 20px;
        }

        .questionnaire-container {
            max-width: 1000px;
            margin: 0 auto;
            background: white;
            border-radius: 25px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.1);
            overflow: hidden;
            margin-bottom: 40px;
        }

        .questionnaire-header {
            background: linear-gradient(135deg, var(--darker) 0%, var(--dark) 100%);
            color: white;
            padding: 40px 50px 30px;
        }

        .progress-section {
            padding: 30px 50px 20px;
            background: rgba(0, 212, 170, 0.05);
            border-bottom: 1px solid rgba(0,0,0,0.05);
        }

        .question-section {
            padding: 40px 50px;
        }

        .question-card {
            background: white;
            border-radius: 20px;
            padding: 30px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.08);
            margin-bottom: 30px;
            border-left: 5px solid var(--primary);
            animation: fadeIn 0.5s ease-out;
        }

        .question-number {
            display: inline-block;
            background: var(--primary);
            color: white;
            width: 40px;
            height: 40px;
            border-radius: 50%;
            text-align: center;
            line-height: 40px;
            font-weight: bold;
            margin-right: 15px;
        }

        .question-text {
            font-size: 1.4rem;
            font-weight: 600;
            color: var(--dark);
            margin-bottom: 25px;
            line-height: 1.5;
        }

        .option-card {
            background: #f8f9fa;
            border: 2px solid transparent;
            border-radius: 15px;
            padding: 20px;
            margin-bottom: 15px;
            cursor: pointer;
            transition: all 0.3s ease;
            display: flex;
            align-items: center;
            gap: 15px;
        }

            .option-card:hover {
                background: white;
                border-color: var(--primary);
                transform: translateY(-3px);
                box-shadow: 0 5px 20px rgba(0,0,0,0.1);
            }

            .option-card.selected {
                background: rgba(0, 212, 170, 0.1);
                border-color: var(--primary);
                box-shadow: 0 5px 20px rgba(0, 212, 170, 0.2);
            }

        .option-icon {
            width: 40px;
            height: 40px;
            background: rgba(0, 212, 170, 0.1);
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: var(--primary);
            font-size: 1.2rem;
        }

        .option-text {
            font-weight: 500;
            color: #333;
            flex: 1;
        }

        .navigation-section {
            padding: 30px 50px;
            background: rgba(0,0,0,0.02);
            border-top: 1px solid rgba(0,0,0,0.05);
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .btn-navigation {
            padding: 12px 35px;
            border-radius: 50px;
            font-weight: 600;
            font-size: 1rem;
            transition: all 0.3s ease;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
            border: none;
            cursor: pointer;
        }

        .btn-prev {
            background: #6c757d;
            color: white;
        }

            .btn-prev:hover {
                background: #5a6268;
                color: white;
                transform: translateY(-2px);
            }

        .btn-next {
            background: linear-gradient(135deg, var(--primary), var(--primary-dark));
            color: white;
        }

            .btn-next:hover {
                background: linear-gradient(135deg, var(--primary-dark), #00a085);
                color: white;
                transform: translateY(-2px);
                box-shadow: 0 10px 25px rgba(0, 180, 148, 0.3);
            }

        .btn-generate {
            background: linear-gradient(135deg, var(--secondary), #0077b6);
            color: white;
        }

            .btn-generate:hover {
                background: linear-gradient(135deg, #0077b6, #0056b3);
                color: white;
                transform: translateY(-2px);
                box-shadow: 0 10px 25px rgba(9, 132, 227, 0.3);
            }

        .btn-with-icon {
            display: inline-flex;
            align-items: center;
            gap: 8px;
        }

        .progress-bar-container {
            height: 10px;
            background: #e9ecef;
            border-radius: 5px;
            overflow: hidden;
            margin-top: 10px;
        }

        .progress-bar {
            height: 100%;
            background: linear-gradient(90deg, var(--primary), var(--secondary));
            border-radius: 5px;
            transition: width 0.5s ease;
        }

        .user-type-badge {
            display: inline-block;
            padding: 8px 20px;
            border-radius: 50px;
            font-weight: 600;
            font-size: 0.9rem;
            margin-left: 20px;
        }

        .badge-it {
            background: rgba(0, 212, 170, 0.2);
            color: var(--primary);
            border: 1px solid var(--primary);
        }

        .badge-nonit {
            background: rgba(9, 132, 227, 0.2);
            color: var(--secondary);
            border: 1px solid var(--secondary);
        }

        @keyframes fadeIn {
            from {
                opacity: 0;
                transform: translateY(20px);
            }

            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        @media (max-width: 768px) {
            .questionnaire-container {
                border-radius: 15px;
                margin: 10px;
            }

            .questionnaire-header,
            .progress-section,
            .question-section,
            .navigation-section {
                padding: 25px;
            }

            .question-text {
                font-size: 1.2rem;
            }

            .option-card {
                padding: 15px;
            }
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>

        <div class="questionnaire-container">
            <!-- Header -->
            <div class="questionnaire-header">
                <div class="d-flex justify-content-between align-items-center">
                    <div>
                        <h1 class="h3 fw-bold mb-2">Custom Solution Questionnaire</h1>
                        <p class="text-white-50 mb-0">Answer these questions to get your personalized solution</p>
                    </div>
                    <div>
                        <span class="user-type-badge" id="userTypeBadge" runat="server"></span>
                    </div>
                </div>
            </div>

            <!-- Progress -->
            <div class="progress-section">
                <div class="d-flex justify-content-between align-items-center mb-2">
                    <span class="text-muted" id="progressText" runat="server">Question 1 of 10</span>
                    <span class="fw-bold text-primary" id="progressPercent" runat="server">10%</span>
                </div>
                <div class="progress-bar-container">
                    <div class="progress-bar" id="progressBar" runat="server" style="width: 10%;"></div>
                </div>
            </div>

            <!-- Questions -->
            <div class="question-section">
                <asp:UpdatePanel ID="UpdatePanel1" runat="server">
                    <ContentTemplate>
                        <!-- Current Question -->
                        <div class="question-card" id="questionCard" runat="server">
                            <div class="d-flex align-items-center mb-3">
                                <span class="question-number">
                                    <span id="questionNumberSpan" runat="server">1</span>
                                </span>
                                <h3 class="h5 mb-0 text-muted">Current Question</h3>
                            </div>
                            <div class="question-text">
                                <span id="questionTextSpan" runat="server">What is your primary technical expertise?</span>
                            </div>

                            <!-- Options -->
                            <div id="optionsContainer" runat="server">
                                <!-- Options will be dynamically generated -->
                            </div>

                            <!-- Additional Inputs for specific question types -->
                            <div id="additionalInputs" runat="server" class="mt-4" style="display: none;">
                                <!-- Additional inputs will be shown here -->
                            </div>
                        </div>

                        <!-- Error Message -->
                        <div class="alert alert-danger" id="errorMessage" runat="server" visible="false">
                            <i class="fas fa-exclamation-circle me-2"></i>
                            <asp:Label ID="lblErrorMessage" runat="server" Text=""></asp:Label>
                        </div>
                    </ContentTemplate>
                </asp:UpdatePanel>
            </div>

            <!-- Navigation -->
            <div class="navigation-section">
                <asp:Button ID="btnPrevious" runat="server" CssClass="btn-navigation btn-prev"
                    OnClick="btnPrevious_Click" Visible="false"></asp:Button>

                <div>
                    <asp:Button ID="btnNext" runat="server" CssClass="btn-navigation btn-next"
                        OnClick="btnNext_Click"></asp:Button>

                    <asp:Button ID="btnGenerate" runat="server" CssClass="btn-navigation btn-generate ms-3"
                        OnClick="btnGenerate_Click" Visible="false"></asp:Button>
                </div>
            </div>
        </div>

        <!-- Hidden Fields for State Management -->
        <asp:HiddenField ID="hdnSessionId" runat="server" />
        <asp:HiddenField ID="hdnCurrentQuestionId" runat="server" />
        <asp:HiddenField ID="hdnQuestionType" runat="server" />
        <asp:HiddenField ID="hdnUserType" runat="server" />
        <asp:HiddenField ID="hdnSelectedOptions" runat="server" />
        <asp:HiddenField ID="hdnQuestionCount" runat="server" Value="1" />
        <asp:HiddenField ID="hdnTotalQuestions" runat="server" Value="10" />
    </form>

    <!-- Scripts -->
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

    <script>
        $(document).ready(function () {
            // Option selection
            $(document).on('click', '.option-card', function () {
                var questionType = $('#<%= hdnQuestionType.ClientID %>').val();

                if (questionType === 'SingleSelect') {
                    $('.option-card').removeClass('selected');
                    $(this).addClass('selected');
                } else if (questionType === 'MultipleChoice') {
                    $(this).toggleClass('selected');
                }

                updateSelectedOptions();
            });

            // Update selected options in hidden field
            function updateSelectedOptions() {
                var selected = [];
                $('.option-card.selected').each(function () {
                    var value = $(this).find('.option-value').val() || $(this).data('value');
                    if (value) selected.push(value);
                });
                $('#<%= hdnSelectedOptions.ClientID %>').val(JSON.stringify(selected));
            }

            // Show additional inputs for specific questions
            function showAdditionalInputs(questionId) {
                // This would be expanded based on question requirements
                // For now, just a placeholder
                if (questionId === 'custom_budget') {
                    $('#<%= additionalInputs.ClientID %>').html(`
                        <div class="mb-3">
                            <label class="form-label">Additional Budget Details (Optional)</label>
                            <textarea class="form-control" rows="3" placeholder="Provide any additional budget constraints or considerations..."></textarea>
                        </div>
                    `).show();
                } else {
                    $('#<%= additionalInputs.ClientID %>').hide();
                }
            }

            // Animation for question transitions
            function animateQuestionChange() {
                $('#<%= questionCard.ClientID %>').css({
                    'animation': 'none'
                }).hide().show(0, function () {
                    $(this).css({
                        'animation': 'fadeIn 0.5s ease-out'
                    });
                });
            }

            // Initialize
            updateSelectedOptions();
        });
    </script>
</body>
</html>
