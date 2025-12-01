        let currentStep = 1;
        let selectedWasteType = '';
        let selectedWasteTypeName = '';

        // Waste type selection
        document.querySelectorAll('.waste-type-card').forEach(card => {
            card.addEventListener('click', function () {
                // Remove selected class from all cards
                document.querySelectorAll('.waste-type-card').forEach(c => {
                    c.classList.remove('selected');
                });

                // Add selected class to clicked card
                this.classList.add('selected');

                // Store selected type
                selectedWasteType = this.getAttribute('data-type');
                selectedWasteTypeName = this.querySelector('h5').textContent;

                // Update hidden fields
                document.getElementById('<%= hdnWasteType.ClientID %>').value = selectedWasteType;
                document.getElementById('<%= hdnWasteTypeId.ClientID %>').value = selectedWasteType;
            });
        });

        // Navigation functions
        function nextStep(step) {
            if (validateStep(currentStep)) {
                document.getElementById('step' + currentStep + 'Form').classList.remove('active');
                document.getElementById('step' + currentStep).classList.remove('active');

                currentStep = step;

                document.getElementById('step' + currentStep + 'Form').classList.add('active');
                document.getElementById('step' + currentStep).classList.add('active');

                if (currentStep === 4) {
                    updateReviewSection();
                }
            }
        }

        function prevStep(step) {
            document.getElementById('step' + currentStep + 'Form').classList.remove('active');
            document.getElementById('step' + currentStep).classList.remove('active');

            currentStep = step;

            document.getElementById('step' + currentStep + 'Form').classList.add('active');
            document.getElementById('step' + currentStep).classList.add('active');
        }

        // Step validation
        function validateStep(step) {
            switch (step) {
                case 1:
                    if (!selectedWasteType) {
                        showNotification('Please select a waste type', 'error');
                        return false;
                    }
                    return true;

                case 2:
                    const weight = document.getElementById('<%= txtWeight.ClientID %>').value;
                    if (!weight || weight <= 0) {
                        showNotification('Please enter a valid weight', 'error');
                        return false;
                    }
                    return true;

                case 3:
                    const address = document.getElementById('<%= txtAddress.ClientID %>').value;
                    if (!address) {
                        showNotification('Please enter collection address', 'error');
                        return false;
                    }
                    return true;

                default:
                    return true;
            }
        }

        // Final submission validation
        function validateFinalSubmission() {
            const address = document.getElementById('<%= txtAddress.ClientID %>').value;

            if (!address) {
                showNotification('Please enter collection address', 'error');
                return false;
            }

            return true;
        }

        // Photo preview
        function previewPhoto(input) {
            if (input.files && input.files[0]) {
                const file = input.files[0];

                // Validate file type
                const allowedTypes = ['image/jpeg', 'image/jpg', 'image/png', 'image/gif'];
                if (!allowedTypes.includes(file.type)) {
                    showNotification('Please select a valid image file (JPG, PNG, GIF)', 'error');
                    input.value = '';
                    return;
                }

                // Validate file size (5MB)
                if (file.size > 5 * 1024 * 1024) {
                    showNotification('File size must be less than 5MB', 'error');
                    input.value = '';
                    return;
                }

                const reader = new FileReader();
                reader.onload = function (e) {
                    const preview = document.getElementById('photoPreview');
                    preview.src = e.target.result;
                    preview.style.display = 'block';
                }
                reader.readAsDataURL(file);
            }
        }

        // Simulate location setting
        function simulateLocation() {
            document.getElementById('<%= hdnLatitude.ClientID %>').value = '40.7128';
            document.getElementById('<%= hdnLongitude.ClientID %>').value = '-74.0060';
            document.getElementById('<%= chkUseCurrentLocation.ClientID %>').checked = true;
            document.getElementById('<%= txtAddress.ClientID %>').value = '123 Main Street, New York, NY 10001';

            showNotification('Location set successfully!', 'success');
        }

        // Update review section
        function updateReviewSection() {
            document.getElementById('reviewWasteType').textContent = selectedWasteTypeName;
            document.getElementById('reviewWeight').textContent = document.getElementById('<%= txtWeight.ClientID %>').value + ' kg';
            document.getElementById('reviewDescription').textContent = document.getElementById('<%= txtDescription.ClientID %>').value || 'No description provided';
            document.getElementById('reviewAddress').textContent = document.getElementById('<%= txtAddress.ClientID %>').value;
            document.getElementById('reviewLandmark').textContent = document.getElementById('<%= txtLandmark.ClientID %>').value || 'Not specified';
            document.getElementById('reviewInstructions').textContent = document.getElementById('<%= txtInstructions.ClientID %>').value || 'No special instructions';

            // Show coordinates
            const lat = document.getElementById('<%= hdnLatitude.ClientID %>').value;
            const lng = document.getElementById('<%= hdnLongitude.ClientID %>').value;
            document.getElementById('reviewCoordinates').textContent = lat && lng ?
                'Lat: ' + lat + ', Lng: ' + lng : 'Current location will be used';

            // Calculate estimated reward
            const weight = parseFloat(document.getElementById('<%= txtWeight.ClientID %>').value) || 0;
            const rewardRates = {
                'plastic': 5,
                'paper': 3,
                'glass': 4,
                'metal': 6,
                'ewaste': 8,
                'organic': 2
            };
            const reward = weight * (rewardRates[selectedWasteType] || 0);
            document.getElementById('estimatedReward').textContent = Math.round(reward) + ' XP';
        }

        // Notification function
        function showNotification(message, type) {
            // Remove existing notifications
            const existingNotifications = document.querySelectorAll('.custom-notification');
            existingNotifications.forEach(notif => notif.remove());

            const notification = document.createElement('div');
            notification.className = `custom-notification notification-${type}`;
            notification.innerHTML = `
                <i class="fas ${type === 'success' ? 'fa-check-circle' : type === 'error' ? 'fa-exclamation-circle' : 'fa-info-circle'}"></i>
                <span>${message}</span>
                <button onclick="this.parentElement.remove()">&times;</button>
            `;

            document.body.appendChild(notification);

            // Auto remove after 5 seconds
            setTimeout(() => {
                if (notification.parentElement) {
                    notification.remove();
                }
            }, 5000);
        }