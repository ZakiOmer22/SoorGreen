// Global variables
let currentStep = 1;
let selectedWasteType = '';
let selectedWasteTypeName = '';
let selectedWasteRate = 0;
let selectedWasteTypeId = '';
let map = null;
let marker = null;

// Initialize when page loads
document.addEventListener('DOMContentLoaded', function () {
    initializePage();
});

function initializePage() {
    // Initialize step navigation
    initializeStepNavigation();

    // Initialize waste category selection
    initializeCategorySelection();

    // Initialize weight presets
    initializeWeightPresets();

    // Initialize form validation
    initializeFormValidation();

    // Update progress
    updateProgress();

    // Initialize help panel
    initializeHelpPanel();

    // Initialize photo upload
    initializePhotoUpload();

    // Initialize location buttons
    initializeLocationButtons();
}

// Step Navigation Functions
function nextStep(step) {
    if (validateCurrentStep()) {
        goToStep(step);
    }
}

function prevStep(step) {
    goToStep(step);
}

function goToStep(step) {
    if (step < 1 || step > 4) return;

    // Hide all steps
    document.querySelectorAll('.form-step').forEach(formStep => {
        formStep.classList.remove('active');
    });

    // Show target step
    const targetStepElement = document.getElementById(`step${step}`);
    if (targetStepElement) {
        targetStepElement.classList.add('active');
    }

    // Update progress tracker
    document.querySelectorAll('.progress-step').forEach(stepEl => {
        stepEl.classList.remove('active');
        if (parseInt(stepEl.getAttribute('data-step')) <= step) {
            stepEl.classList.add('active');
        }
    });

    currentStep = step;
    updateProgress();

    // Initialize map if moving to step 3
    if (step === 3) {
        setTimeout(initializeMap, 100);
    }

    // Update review if moving to step 4
    if (step === 4) {
        updateReviewSection();
    }

    // Scroll to top of form
    const formWrapper = document.querySelector('.form-wrapper');
    if (formWrapper) {
        formWrapper.scrollIntoView({ behavior: 'smooth', block: 'start' });
    }
}

function validateCurrentStep() {
    switch (currentStep) {
        case 1:
            if (!selectedWasteType) {
                showNotification('Please select a waste type', 'error');
                return false;
            }
            return true;

        case 2:
            const weight = document.getElementById('<%= txtWeight.ClientID %>');
            if (!weight || !weight.value || parseFloat(weight.value) <= 0) {
                showNotification('Please enter a valid weight', 'error');
                return false;
            }
            return true;

        case 3:
            const address = document.getElementById('<%= txtAddress.ClientID %>');
            if (!address || !address.value || address.value.trim() === '') {
                showNotification('Please enter collection address', 'error');
                return false;
            }
            return true;

        default:
            return true;
    }
}

function initializeStepNavigation() {
    // Step click handlers
    document.querySelectorAll('.progress-step').forEach(step => {
        step.addEventListener('click', function () {
            const stepNumber = parseInt(this.getAttribute('data-step'));
            if (stepNumber < currentStep) {
                goToStep(stepNumber);
            }
        });
    });

    // Also add event listeners to navigation buttons (alternative to onclick)
    document.querySelectorAll('[onclick*="nextStep"]').forEach(button => {
        const onclick = button.getAttribute('onclick');
        const match = onclick.match(/nextStep\((\d+)\)/);
        if (match) {
            const targetStep = parseInt(match[1]);
            button.addEventListener('click', function (e) {
                e.preventDefault();
                nextStep(targetStep);
            });
        }
    });

    document.querySelectorAll('[onclick*="prevStep"]').forEach(button => {
        const onclick = button.getAttribute('onclick');
        const match = onclick.match(/prevStep\((\d+)\)/);
        if (match) {
            const targetStep = parseInt(match[1]);
            button.addEventListener('click', function (e) {
                e.preventDefault();
                prevStep(targetStep);
            });
        }
    });
}

function updateProgress() {
    const progress = (currentStep / 4) * 100;
    const progressFill = document.getElementById('progressFill');
    const currentStepElement = document.getElementById('currentStep');

    if (progressFill) {
        progressFill.style.width = `${progress}%`;
    }

    if (currentStepElement) {
        currentStepElement.textContent = currentStep;
    }
}

// Category Selection Functions
function selectCategory(type, typeId, name, rate) {
    // Remove selection from all cards
    document.querySelectorAll('.category-card').forEach(card => {
        card.classList.remove('selected');
    });

    // Add selection to clicked card
    const clickedCard = document.querySelector(`.category-card[data-type="${type}"]`);
    if (clickedCard) {
        clickedCard.classList.add('selected');

        // Update global variables
        selectedWasteType = type;
        selectedWasteTypeId = typeId;
        selectedWasteTypeName = name;
        selectedWasteRate = rate;

        // Update hidden fields
        const hdnWasteType = document.getElementById('<%= hdnWasteType.ClientID %>');
        const hdnWasteTypeId = document.getElementById('<%= hdnWasteTypeId.ClientID %>');

        if (hdnWasteType) hdnWasteType.value = type;
        if (hdnWasteTypeId) hdnWasteTypeId.value = typeId;

        // Update potential reward
        calculateReward();
    }
}

function initializeCategorySelection() {
    // Add click handlers to category cards
    document.querySelectorAll('.category-card').forEach(card => {
        card.addEventListener('click', function () {
            const type = this.getAttribute('data-type');
            const typeId = this.getAttribute('data-typeid');
            const name = this.querySelector('h4').textContent;
            const rateText = this.querySelector('.reward-rate').textContent;
            const rate = parseInt(rateText);

            selectCategory(type, typeId, name, rate);
        });
    });
}

// Weight Functions
function initializeWeightPresets() {
    document.querySelectorAll('.weight-preset').forEach(preset => {
        preset.addEventListener('click', function () {
            const weight = this.getAttribute('data-weight');
            const weightInput = document.getElementById('<%= txtWeight.ClientID %>');

            if (weightInput) {
                weightInput.value = weight;
                calculateReward();

                // Highlight selected preset
                document.querySelectorAll('.weight-preset').forEach(p => {
                    p.classList.remove('active');
                });
                this.classList.add('active');
            }
        });
    });

    // Add input event listener to weight field
    const weightInput = document.getElementById('<%= txtWeight.ClientID %>');
    if (weightInput) {
        weightInput.addEventListener('input', calculateReward);
    }
}

function calculateReward() {
    const weightInput = document.getElementById('<%= txtWeight.ClientID %>');
    const estimatedReward = document.getElementById('estimatedReward');
    const rewardWeight = document.getElementById('rewardWeight');
    const rewardRate = document.getElementById('rewardRate');
    const rewardTotal = document.getElementById('rewardTotal');
    const potentialReward = document.getElementById('potentialReward');

    if (!weightInput || !estimatedReward) return;

    const weight = parseFloat(weightInput.value) || 0;
    const rate = selectedWasteRate || 0;
    const totalReward = weight * rate;

    // Update review section if on step 4
    if (currentStep === 4) {
        estimatedReward.textContent = totalReward.toFixed(0) + ' XP';
        if (rewardWeight) rewardWeight.textContent = weight.toFixed(1) + ' kg';
        if (rewardRate) rewardRate.textContent = rate + ' XP/kg';
        if (rewardTotal) rewardTotal.textContent = totalReward.toFixed(0) + ' XP';
    }

    // Update potential reward in header
    if (potentialReward) {
        potentialReward.textContent = totalReward.toFixed(0) + ' XP';
    }
}

// Photo Upload Functions
function initializePhotoUpload() {
    const photoUploadArea = document.querySelector('.photo-upload-area');
    const fileInput = document.getElementById('filePhoto');

    if (photoUploadArea && fileInput) {
        photoUploadArea.addEventListener('click', function () {
            fileInput.click();
        });
    }
}

function triggerPhotoUpload() {
    const fileInput = document.getElementById('filePhoto');
    if (fileInput) {
        fileInput.click();
    }
}

function handlePhotoUpload(event) {
    const fileInput = event.target;
    const photoPreview = document.getElementById('photoPreview');

    if (!fileInput.files || !fileInput.files[0] || !photoPreview) return;

    const file = fileInput.files[0];
    const allowedTypes = ['image/jpeg', 'image/jpg', 'image/png', 'image/gif'];

    if (!allowedTypes.includes(file.type)) {
        showNotification('Please select a valid image file (JPG, PNG, GIF)', 'error');
        fileInput.value = '';
        return;
    }

    if (file.size > 5 * 1024 * 1024) {
        showNotification('File size must be less than 5MB', 'error');
        fileInput.value = '';
        return;
    }

    const reader = new FileReader();
    reader.onload = function (e) {
        // Clear placeholder
        photoPreview.innerHTML = '';

        // Create image element
        const img = document.createElement('img');
        img.src = e.target.result;
        img.style.width = '100%';
        img.style.height = '100%';
        img.style.objectFit = 'cover';
        img.style.borderRadius = '8px';

        // Add close button
        const closeBtn = document.createElement('button');
        closeBtn.innerHTML = '<i class="fas fa-times"></i>';
        closeBtn.style.position = 'absolute';
        closeBtn.style.top = '10px';
        closeBtn.style.right = '10px';
        closeBtn.style.background = 'rgba(0,0,0,0.7)';
        closeBtn.style.color = 'white';
        closeBtn.style.border = 'none';
        closeBtn.style.borderRadius = '50%';
        closeBtn.style.width = '30px';
        closeBtn.style.height = '30px';
        closeBtn.style.cursor = 'pointer';
        closeBtn.style.display = 'flex';
        closeBtn.style.alignItems = 'center';
        closeBtn.style.justifyContent = 'center';
        closeBtn.onclick = function (e) {
            e.stopPropagation();
            photoPreview.innerHTML = '';
            fileInput.value = '';
            showPhotoPreviewPlaceholder();
        };

        photoPreview.appendChild(img);
        photoPreview.appendChild(closeBtn);
        photoPreview.style.position = 'relative';
    };
    reader.readAsDataURL(file);
}

function showPhotoPreviewPlaceholder() {
    const photoPreview = document.getElementById('photoPreview');
    if (!photoPreview) return;

    photoPreview.innerHTML = `
        <div class="preview-placeholder">
            <i class="fas fa-image"></i>
            <p>Photo preview will appear here</p>
        </div>
    `;
}

// Location Functions
function initializeLocationButtons() {
    // Add event listeners to location buttons
    const useLocationBtn = document.querySelector('.btn-location:not(.secondary)');
    const pickOnMapBtn = document.querySelector('.btn-location.secondary');

    if (useLocationBtn) {
        useLocationBtn.addEventListener('click', function (e) {
            e.preventDefault();
            useCurrentLocation();
        });
    }

    if (pickOnMapBtn) {
        pickOnMapBtn.addEventListener('click', function (e) {
            e.preventDefault();
            pickOnMap();
        });
    }
}

function initializeMap() {
    const mapContainer = document.getElementById('map');
    const mapPlaceholder = document.getElementById('mapPlaceholder');

    if (!mapContainer || !mapPlaceholder) return;

    // Show map, hide placeholder
    mapPlaceholder.style.display = 'none';
    mapContainer.style.display = 'block';

    // Initialize map with default location
    map = L.map('map').setView([3.1390, 101.6869], 13); // Default to Kuala Lumpur

    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
    }).addTo(map);

    // Add click handler to map
    map.on('click', function (e) {
        setMapLocation(e.latlng.lat, e.latlng.lng);
    });

    // Try to get user's current location
    if (navigator.geolocation) {
        navigator.geolocation.getCurrentPosition(
            function (position) {
                const lat = position.coords.latitude;
                const lng = position.coords.longitude;
                setMapLocation(lat, lng);
            },
            function (error) {
                console.log('Geolocation error:', error);
                // Use default location
                setMapLocation(3.1390, 101.6869);
            }
        );
    } else {
        setMapLocation(3.1390, 101.6869);
    }
}

function setMapLocation(lat, lng) {
    if (!map) return;

    // Update map view
    map.setView([lat, lng], 15);

    // Remove existing marker
    if (marker) {
        map.removeLayer(marker);
    }

    // Add new marker
    marker = L.marker([lat, lng]).addTo(map);

    // Update form fields
    const txtLatitude = document.getElementById('<%= txtLatitude.ClientID %>');
    const txtLongitude = document.getElementById('<%= txtLongitude.ClientID %>');
    const hdnLatitude = document.getElementById('<%= hdnLatitude.ClientID %>');
    const hdnLongitude = document.getElementById('<%= hdnLongitude.ClientID %>');

    if (txtLatitude) txtLatitude.value = lat.toFixed(6);
    if (txtLongitude) txtLongitude.value = lng.toFixed(6);
    if (hdnLatitude) hdnLatitude.value = lat.toFixed(6);
    if (hdnLongitude) hdnLongitude.value = lng.toFixed(6);
}

function useCurrentLocation() {
    if (navigator.geolocation) {
        showNotification('Getting your location...', 'info');

        navigator.geolocation.getCurrentPosition(
            function (position) {
                const lat = position.coords.latitude;
                const lng = position.coords.longitude;
                setMapLocation(lat, lng);

                // Try to reverse geocode to get address
                reverseGeocode(lat, lng);
                showNotification('Location set successfully!', 'success');
            },
            function (error) {
                console.log('Geolocation error:', error);
                showNotification('Could not get your location. Please enable location services.', 'error');
            }
        );
    } else {
        showNotification('Geolocation is not supported by your browser', 'error');
    }
}

function pickOnMap() {
    showNotification('Click on the map to select a location', 'info');
}

function reverseGeocode(lat, lng) {
    // Simple reverse geocoding using OpenStreetMap Nominatim
    fetch(`https://nominatim.openstreetmap.org/reverse?format=json&lat=${lat}&lon=${lng}`)
        .then(response => response.json())
        .then(data => {
            if (data.address) {
                const address = [];
                if (data.address.road) address.push(data.address.road);
                if (data.address.suburb) address.push(data.address.suburb);
                if (data.address.city) address.push(data.address.city);
                if (data.address.state) address.push(data.address.state);
                if (data.address.country) address.push(data.address.country);

                const txtAddress = document.getElementById('<%= txtAddress.ClientID %>');
                if (txtAddress && address.length > 0) {
                    txtAddress.value = address.join(', ');
                }
            }
        })
        .catch(error => console.log('Reverse geocoding error:', error));
}

// Review Functions
function updateReviewSection() {
    // Update waste type info
    const reviewWasteType = document.getElementById('reviewWasteType');
    const reviewCategoryId = document.getElementById('reviewCategoryId');
    const reviewRewardRate = document.getElementById('reviewRewardRate');

    if (reviewWasteType) reviewWasteType.textContent = selectedWasteTypeName || '-';
    if (reviewCategoryId) reviewCategoryId.textContent = selectedWasteTypeId || '-';
    if (reviewRewardRate) reviewRewardRate.textContent = selectedWasteRate + ' XP/kg';

    // Update weight
    const weightInput = document.getElementById('<%= txtWeight.ClientID %>');
    const reviewWeight = document.getElementById('reviewWeight');
    if (weightInput && reviewWeight) {
        reviewWeight.textContent = (weightInput.value || '0') + ' kg';
    }

    // Update description
    const txtDescription = document.getElementById('<%= txtDescription.ClientID %>');
    const reviewDescription = document.getElementById('reviewDescription');
    if (txtDescription && reviewDescription) {
        reviewDescription.textContent = txtDescription.value || 'No description provided';
    }

    // Update location info
    const txtAddress = document.getElementById('<%= txtAddress.ClientID %>');
    const txtLandmark = document.getElementById('<%= txtLandmark.ClientID %>');
    const txtContactPerson = document.getElementById('<%= txtContactPerson.ClientID %>');
    const txtInstructions = document.getElementById('<%= txtInstructions.ClientID %>');
    const txtLatitude = document.getElementById('<%= txtLatitude.ClientID %>');
    const txtLongitude = document.getElementById('<%= txtLongitude.ClientID %>');

    const reviewAddress = document.getElementById('reviewAddress');
    const reviewLandmark = document.getElementById('reviewLandmark');
    const reviewContact = document.getElementById('reviewContact');
    const reviewInstructions = document.getElementById('reviewInstructions');
    const reviewCoordinates = document.getElementById('reviewCoordinates');

    if (txtAddress && reviewAddress) reviewAddress.textContent = txtAddress.value || '-';
    if (txtLandmark && reviewLandmark) reviewLandmark.textContent = txtLandmark.value || 'Not specified';
    if (txtContactPerson && reviewContact) reviewContact.textContent = txtContactPerson.value || '-';
    if (txtInstructions && reviewInstructions) reviewInstructions.textContent = txtInstructions.value || 'No special instructions';

    // Update coordinates
    if (txtLatitude && txtLongitude && reviewCoordinates) {
        if (txtLatitude.value && txtLongitude.value) {
            reviewCoordinates.textContent = `Lat: ${txtLatitude.value}, Lng: ${txtLongitude.value}`;
        } else {
            reviewCoordinates.textContent = 'Coordinates not set';
        }
    }

    // Update reward calculation
    calculateReward();
}

// Help Panel Functions
function initializeHelpPanel() {
    const helpBtn = document.querySelector('.btn-help');
    const closeHelpBtn = document.querySelector('.btn-close-help');
    const helpPanel = document.getElementById('helpPanel');

    if (helpBtn) {
        helpBtn.addEventListener('click', showHelp);
    }

    if (closeHelpBtn) {
        closeHelpBtn.addEventListener('click', hideHelp);
    }

    // Close help panel when clicking outside
    if (helpPanel) {
        document.addEventListener('click', function (event) {
            if (helpPanel.classList.contains('active') &&
                !helpPanel.contains(event.target) &&
                event.target !== helpBtn) {
                hideHelp();
            }
        });
    }
}

function showHelp() {
    const helpPanel = document.getElementById('helpPanel');
    if (helpPanel) {
        helpPanel.classList.add('active');
    }
}

function hideHelp() {
    const helpPanel = document.getElementById('helpPanel');
    if (helpPanel) {
        helpPanel.classList.remove('active');
    }
}

// Form Validation
function initializeFormValidation() {
    // Add required field validation
    const requiredFields = document.querySelectorAll('[required]');
    requiredFields.forEach(field => {
        field.addEventListener('blur', function () {
            validateField(this);
        });
    });
}

function validateField(field) {
    if (!field.value.trim()) {
        field.style.borderColor = '#ef4444';
        return false;
    } else {
        field.style.borderColor = '#e2e8f0';
        return true;
    }
}

// Form Submission Validation
function validateSubmission() {
    // Validate all steps
    if (!selectedWasteType) {
        showNotification('Please select a waste type', 'error');
        goToStep(1);
        return false;
    }

    const weight = document.getElementById('<%= txtWeight.ClientID %>');
    if (!weight || !weight.value || parseFloat(weight.value) <= 0) {
        showNotification('Please enter a valid weight', 'error');
        goToStep(2);
        return false;
    }

    const address = document.getElementById('<%= txtAddress.ClientID %>');
    if (!address || !address.value || address.value.trim() === '') {
        showNotification('Please enter collection address', 'error');
        goToStep(3);
        return false;
    }

    // Validate checkboxes
    const confirmDetails = document.getElementById('chkConfirmDetails');
    const agreeTerms = document.getElementById('chkAgreeTerms');

    if (!confirmDetails || !agreeTerms) {
        showNotification('Please confirm details and agree to terms', 'error');
        return false;
    }

    if (!confirmDetails.checked || !agreeTerms.checked) {
        showNotification('Please confirm details and agree to terms', 'error');
        return false;
    }

    return true;
}

// Notification System
function showNotification(message, type) {
    // Remove existing notifications
    const existingNotifications = document.querySelectorAll('.notification');
    existingNotifications.forEach(notif => notif.remove());

    // Create notification element
    const notification = document.createElement('div');
    notification.className = `notification ${type}`;
    notification.innerHTML = `
        <div class="notification-content">
            <i class="fas ${type === 'success' ? 'fa-check-circle' :
            type === 'error' ? 'fa-exclamation-circle' :
                type === 'warning' ? 'fa-exclamation-triangle' :
                    'fa-info-circle'}"></i>
            <span>${message}</span>
        </div>
        <button class="notification-close" onclick="this.parentElement.remove()">
            <i class="fas fa-times"></i>
        </button>
    `;

    // Add styles
    notification.style.cssText = `
        position: fixed;
        top: 20px;
        right: 20px;
        padding: 16px;
        background: ${type === 'success' ? '#10b981' :
            type === 'error' ? '#ef4444' :
                type === 'warning' ? '#f59e0b' :
                    '#3b82f6'};
        color: white;
        border-radius: 8px;
        box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
        display: flex;
        align-items: center;
        gap: 12px;
        z-index: 10000;
        animation: slideIn 0.3s ease;
        max-width: 400px;
    `;

    // Add to document
    document.body.appendChild(notification);

    // Auto-remove after 5 seconds
    setTimeout(() => {
        if (notification.parentElement) {
            notification.remove();
        }
    }, 5000);
}

// Add CSS for slide-in animation
const style = document.createElement('style');
style.textContent = `
    @keyframes slideIn {
        from {
            transform: translateX(100%);
            opacity: 0;
        }
        to {
            transform: translateX(0);
            opacity: 1;
        }
    }
    
    .notification-close {
        background: none;
        border: none;
        color: white;
        cursor: pointer;
        padding: 0;
        margin-left: 8px;
    }
    
    .notification-content {
        display: flex;
        align-items: center;
        gap: 8px;
        flex: 1;
    }
`;
document.head.appendChild(style);

// Keyboard shortcuts
document.addEventListener('keydown', function (e) {
    // Escape to close help panel
    if (e.key === 'Escape') {
        hideHelp();
    }

    // Ctrl+Enter to submit form (when on step 4)
    if (e.ctrlKey && e.key === 'Enter' && currentStep === 4) {
        const submitBtn = document.querySelector('.btn-submit');
        if (submitBtn) {
            submitBtn.click();
        }
    }
});

// Theme toggle (if you have one)
function toggleTheme() {
    const html = document.documentElement;
    const currentTheme = html.getAttribute('data-theme');
    const newTheme = currentTheme === 'dark' ? 'light' : 'dark';
    html.setAttribute('data-theme', newTheme);

    // Save preference
    localStorage.setItem('theme', newTheme);

    // Update toggle button icon
    const themeToggle = document.getElementById('themeToggleBtn');
    if (themeToggle) {
        const icon = themeToggle.querySelector('i');
        if (icon) {
            icon.className = newTheme === 'dark' ? 'fas fa-sun' : 'fas fa-moon';
        }
    }
}

// Load saved theme
function loadTheme() {
    const savedTheme = localStorage.getItem('theme') || 'light';
    document.documentElement.setAttribute('data-theme', savedTheme);

    // Update toggle button
    const themeToggle = document.getElementById('themeToggleBtn');
    if (themeToggle) {
        const icon = themeToggle.querySelector('i');
        if (icon) {
            icon.className = savedTheme === 'dark' ? 'fas fa-sun' : 'fas fa-moon';
        }
    }
}

// Initialize theme
loadTheme();

// Make functions globally available for onclick handlers
window.nextStep = nextStep;
window.prevStep = prevStep;
window.selectCategory = selectCategory;
window.triggerPhotoUpload = triggerPhotoUpload;
window.handlePhotoUpload = handlePhotoUpload;
window.useCurrentLocation = useCurrentLocation;
window.pickOnMap = pickOnMap;
window.showHelp = showHelp;
window.hideHelp = hideHelp;
window.toggleTheme = toggleTheme;
window.validateSubmission = validateSubmission;