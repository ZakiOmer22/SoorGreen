// Questionnaire dynamic functionality
class QuestionnaireManager {
    constructor() {
        this.currentQuestion = 1;
        this.totalQuestions = 10;
        this.responses = {};
        this.userType = this.getUserType();
    }

    getUserType() {
        const urlParams = new URLSearchParams(window.location.search);
        return urlParams.get('type') || 'IT';
    }

    loadQuestion(questionNumber) {
        // Simulate API call to get question
        const questions = this.getQuestionsByType();
        const question = questions[questionNumber - 1];

        if (!question) {
            this.showCompletion();
            return;
        }

        this.updateProgress(questionNumber);
        this.renderQuestion(question);
        this.updateNavigation(questionNumber);
    }

    getQuestionsByType() {
        if (this.userType === 'IT') {
            return [
                {
                    id: 1,
                    text: "What is your primary technical expertise?",
                    type: "MultipleChoice",
                    options: [
                        "Web Development",
                        "Mobile Development",
                        "Database Administration",
                        "Cloud Computing",
                        "IoT Development",
                        "Data Science/AI",
                        "DevOps",
                        "Security"
                    ]
                },
                {
                    id: 2,
                    text: "What is your preferred technology stack?",
                    type: "MultipleChoice",
                    options: [
                        ".NET (C#/ASP.NET)",
                        "Java/Spring",
                        "Python/Django/Flask",
                        "JavaScript/Node.js",
                        "PHP/Laravel",
                        "Ruby/Rails",
                        "Mobile (React Native/Flutter)",
                        "Other"
                    ]
                }
            ];
        } else {
            return [
                {
                    id: 1,
                    text: "What is your primary business challenge?",
                    type: "MultipleChoice",
                    options: [
                        "Manual processes are time-consuming",
                        "Lack of data visibility",
                        "Difficulty tracking waste collection",
                        "Citizen engagement is low",
                        "Compliance reporting is difficult",
                        "Cost management",
                        "Other"
                    ]
                },
                {
                    id: 2,
                    text: "What is your organization size?",
                    type: "SingleSelect",
                    options: [
                        "Small (1-10 employees)",
                        "Medium (11-50 employees)",
                        "Large (51-250 employees)",
                        "Enterprise (250+ employees)",
                        "Government/Municipality"
                    ]
                }
            ];
        }
    }

    renderQuestion(question) {
        const container = document.getElementById('questionCard');
        if (!container) return;

        let optionsHtml = '';
        question.options.forEach((option, index) => {
            const icon = this.getOptionIcon(index);
            optionsHtml += `
                <div class="option-card" data-value="${index + 1}" onclick="questionnaire.selectOption(this)">
                    <div class="option-icon">
                        <i class="${icon}"></i>
                    </div>
                    <div class="option-text">${option}</div>
                    <input type="hidden" class="option-value" value="${index + 1}" />
                </div>
            `;
        });

        container.innerHTML = `
            <div class="d-flex align-items-center mb-3">
                <span class="question-number">${question.id}</span>
                <h3 class="h5 mb-0 text-muted">${this.userType === 'IT' ? 'Technical Question' : 'Business Question'}</h3>
            </div>
            <div class="question-text">${question.text}</div>
            <div id="optionsContainer">${optionsHtml}</div>
        `;

        // Restore previous selection if any
        this.restoreSelection(question.id);
    }

    getOptionIcon(index) {
        const icons = [
            'fas fa-star',
            'fas fa-chart-line',
            'fas fa-cogs',
            'fas fa-bolt',
            'fas fa-users',
            'fas fa-shield-alt',
            'fas fa-cloud',
            'fas fa-mobile-alt'
        ];
        return icons[index] || 'fas fa-circle';
    }

    selectOption(element) {
        const questionId = this.currentQuestion;
        const questionType = this.getQuestionsByType()[questionId - 1]?.type;

        if (questionType === 'SingleSelect') {
            // Deselect all other options
            document.querySelectorAll('.option-card').forEach(card => {
                card.classList.remove('selected');
            });
            element.classList.add('selected');
        } else if (questionType === 'MultipleChoice') {
            element.classList.toggle('selected');
        }

        this.saveResponse(questionId);
    }

    saveResponse(questionId) {
        const selectedOptions = [];
        document.querySelectorAll('.option-card.selected').forEach(card => {
            const value = card.querySelector('.option-value')?.value;
            if (value) selectedOptions.push(value);
        });

        this.responses[questionId] = selectedOptions;
        localStorage.setItem('questionnaire_responses', JSON.stringify(this.responses));
    }

    restoreSelection(questionId) {
        const savedResponses = JSON.parse(localStorage.getItem('questionnaire_responses') || '{}');
        const savedSelection = savedResponses[questionId];

        if (savedSelection && savedSelection.length > 0) {
            savedSelection.forEach(value => {
                const optionCard = document.querySelector(`.option-card[data-value="${value}"]`);
                if (optionCard) {
                    optionCard.classList.add('selected');
                }
            });
        }
    }

    updateProgress(questionNumber) {
        const percent = (questionNumber * 100) / this.totalQuestions;
        document.getElementById('progressText').textContent = `Question ${questionNumber} of ${this.totalQuestions}`;
        document.getElementById('progressPercent').textContent = `${percent}%`;
        document.getElementById('progressBar').style.width = `${percent}%`;
    }

    updateNavigation(questionNumber) {
        document.getElementById('btnPrevious').style.display = questionNumber > 1 ? 'block' : 'none';
        document.getElementById('btnNext').style.display = questionNumber < this.totalQuestions ? 'block' : 'none';
        document.getElementById('btnGenerate').style.display = questionNumber >= this.totalQuestions ? 'block' : 'none';
    }

    nextQuestion() {
        if (this.currentQuestion < this.totalQuestions) {
            this.currentQuestion++;
            this.loadQuestion(this.currentQuestion);
        }
    }

    previousQuestion() {
        if (this.currentQuestion > 1) {
            this.currentQuestion--;
            this.loadQuestion(this.currentQuestion);
        }
    }

    showCompletion() {
        const container = document.getElementById('questionCard');
        container.innerHTML = `
            <div class="text-center py-5">
                <div class="mb-4">
                    <i class="fas fa-check-circle text-success" style="font-size: 4rem;"></i>
                </div>
                <h3 class="mb-3">Questionnaire Complete!</h3>
                <p class="text-muted mb-4">All questions have been answered. Ready to generate your custom solution?</p>
                <button class="btn btn-primary btn-lg" onclick="questionnaire.generateSolution()">
                    <i class="fas fa-magic me-2"></i>Generate Solution
                </button>
            </div>
        `;

        document.getElementById('btnNext').style.display = 'none';
        document.getElementById('btnGenerate').style.display = 'block';
    }

    generateSolution() {
        // Collect all responses
        const allResponses = this.responses;

        // Show loading
        const container = document.getElementById('questionCard');
        container.innerHTML = `
            <div class="text-center py-5">
                <div class="spinner-border text-primary mb-4" style="width: 3rem; height: 3rem;" role="status">
                    <span class="visually-hidden">Loading...</span>
                </div>
                <h3 class="mb-3">Generating Your Solution</h3>
                <p class="text-muted mb-4">Analyzing your responses and creating a customized solution...</p>
                <div class="progress mb-4">
                    <div class="progress-bar progress-bar-striped progress-bar-animated" style="width: 100%"></div>
                </div>
            </div>
        `;

        // Simulate API call
        setTimeout(() => {
            // Redirect to solutions page
            window.location.href = `Solutions.aspx?type=${this.userType}&responses=${encodeURIComponent(JSON.stringify(allResponses))}`;
        }, 2000);
    }

    validateCurrentQuestion() {
        const selectedOptions = document.querySelectorAll('.option-card.selected');
        if (selectedOptions.length === 0) {
            this.showError('Please select at least one option to continue.');
            return false;
        }
        this.hideError();
        return true;
    }

    showError(message) {
        let errorDiv = document.getElementById('errorMessage');
        if (!errorDiv) {
            errorDiv = document.createElement('div');
            errorDiv.id = 'errorMessage';
            errorDiv.className = 'alert alert-danger mt-3';
            errorDiv.innerHTML = `<i class="fas fa-exclamation-circle me-2"></i>${message}`;
            document.getElementById('questionCard').appendChild(errorDiv);
        } else {
            errorDiv.innerHTML = `<i class="fas fa-exclamation-circle me-2"></i>${message}`;
            errorDiv.style.display = 'block';
        }
    }

    hideError() {
        const errorDiv = document.getElementById('errorMessage');
        if (errorDiv) {
            errorDiv.style.display = 'none';
        }
    }
}

// Initialize questionnaire
const questionnaire = new QuestionnaireManager();

// Global functions for onclick events
window.selectOption = function (element) {
    questionnaire.selectOption(element);
};

window.nextQuestion = function () {
    if (questionnaire.validateCurrentQuestion()) {
        questionnaire.nextQuestion();
    }
};

window.previousQuestion = function () {
    questionnaire.previousQuestion();
};

window.generateSolution = function () {
    questionnaire.generateSolution();
};

// Initialize on page load
document.addEventListener('DOMContentLoaded', function () {
    questionnaire.loadQuestion(1);
});