<%@ Page Title="Pickup Verification" Language="C#" MasterPageFile="~/Pages/Collectors/Site.Master"
    AutoEventWireup="true" Inherits="SoorGreen.Collectors.PickupVerification" Codebehind="PickupVerification.aspx.cs" %>

<asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
    <link href='<%= ResolveUrl("~/Content/Pages/Collectors/collectorsroute.css") %>' rel="stylesheet" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</asp:Content>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Pickup Verification - SoorGreen Collector
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <!-- Hidden fields -->
    <asp:HiddenField ID="hdnPickupId" runat="server" />
    <asp:HiddenField ID="hdnReportId" runat="server" />
    <asp:HiddenField ID="hdnWasteTypeId" runat="server" />

    <!-- Main File Upload Control (hidden) -->
    <asp:FileUpload ID="fileUpload" runat="server" Style="display: none;" />

    <div class="route-container" id="pageContainer">
        <!-- Page Header -->
        <div class="page-header-glass">
            <h1 class="page-title-glass">Pickup Verification</h1>
            <p class="page-subtitle-glass">Verify waste collection details and complete pickup</p>
            <!-- Navigation -->
            <div class="d-flex gap-3 mt-4">
                <asp:LinkButton ID="btnBackToPickups" runat="server" CssClass="action-btn secondary"
                    OnClick="btnBackToPickups_Click">
                    <i class="fas fa-arrow-left me-2"></i>Back to Active Pickups
                </asp:LinkButton>

                <asp:LinkButton ID="btnSkipVerification" runat="server" CssClass="action-btn warning"
                    OnClick="btnSkipVerification_Click">
                    <i class="fas fa-forward me-2"></i>Skip for Now
                </asp:LinkButton>
            </div>
        </div>

        <!-- Pickup Details Card -->
        <div class="collector-stats">
            <div class="stats-card-glass">
                <div class="stats-header">
                    <div class="stats-title">
                        <h3><i class="fas fa-clipboard-check me-2"></i>Pickup Verification Details</h3>
                        <asp:Label ID="lblPickupId" runat="server" CssClass="stats-date"></asp:Label>
                    </div>
                    <div class="stats-status">
                        <asp:Label ID="lblVerificationStatus" runat="server" CssClass="status-badge" Text="In Progress"></asp:Label>
                    </div>
                </div>

                <div class="row mt-4">
                    <!-- Left Column: Citizen & Location Details -->
                    <div class="col-md-6">
                        <div class="detail-card">
                            <h5><i class="fas fa-user me-2"></i>Citizen Information</h5>
                            <div class="citizen-details">
                                <div class="citizen-avatar-large mb-3">
                                    <img id="imgCitizenAvatar" runat="server" src="https://ui-avatars.com/api/?name=John+Doe&background=10b981&color=fff&size=100"
                                        class="avatar-img-large" alt="Citizen" />
                                </div>
                                <h4 id="lblCitizenName" runat="server">John Doe</h4>
                                <div class="citizen-contact">
                                    <p><i class="fas fa-phone me-2"></i><span id="lblCitizenPhone" runat="server">+254 712 345 678</span></p>
                                    <p><i class="fas fa-envelope me-2"></i><span id="lblCitizenEmail" runat="server">john.doe@example.com</span></p>
                                </div>
                            </div>

                            <div class="detail-section mt-4">
                                <h5><i class="fas fa-map-marker-alt me-2"></i>Location Details</h5>
                                <div class="location-details">
                                    <p><strong>Address:</strong> <span id="lblAddress" runat="server">123 Green Street, Nairobi</span></p>
                                    <p><strong>Landmark:</strong> <span id="lblLandmark" runat="server">Near Green Mall</span></p>
                                    <p><strong>Coordinates:</strong> <span id="lblCoordinates" runat="server">-1.286389, 36.817223</span></p>
                                    <div class="mt-3">
                                        <asp:Button ID="btnOpenMaps" runat="server" CssClass="action-btn primary small"
                                            Text="Open in Maps" OnClick="btnOpenMaps_Click" />
                                        <asp:Button ID="btnGetDirections" runat="server" CssClass="action-btn secondary small"
                                            Text="Get Directions" OnClick="btnGetDirections_Click" />
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Right Column: Waste & Verification Details -->
                    <div class="col-md-6">
                        <div class="detail-card">
                            <h5><i class="fas fa-trash me-2"></i>Waste Details</h5>
                            <div class="waste-details">
                                <div class="waste-type-display mb-3">
                                    <span id="wasteTypeBadge" runat="server" class="waste-type-badge-large plastic">
                                        <i class="fas fa-bottle-water"></i><span id="lblWasteType" runat="server">Plastic</span>
                                    </span>
                                </div>

                                <div class="row mb-3">
                                    <div class="col-md-6">
                                        <div class="info-box">
                                            <div class="info-label">Estimated Weight</div>
                                            <div class="info-value"><span id="lblEstimatedWeight" runat="server">15.5</span> kg</div>
                                        </div>
                                    </div>
                                    <div class="col-md-6">
                                        <div class="info-box">
                                            <div class="info-label">Credit Value</div>
                                            <div class="info-value"><span id="lblCreditValue" runat="server">31.0</span> credits</div>
                                        </div>
                                    </div>
                                </div>

                                <div class="waste-photo-section">
                                    <h6><i class="fas fa-image me-2"></i>Waste Photo</h6>
                                    <div class="text-center">
                                        <img id="imgWastePhoto" runat="server" src="" alt="Waste Photo"
                                            class="waste-photo-large img-fluid rounded" onerror="this.style.display='none';" />
                                        <asp:Label ID="lblNoPhoto" runat="server" CssClass="text-muted" Text="No photo available" Visible="true"></asp:Label>
                                    </div>
                                </div>
                            </div>

                            <div class="detail-section mt-4">
                                <h5><i class="fas fa-check-circle me-2"></i>Verification Details</h5>

                                <!-- Verification Form -->
                                <div class="verification-form">
                                    <div class="form-group mb-3">
                                        <label for="txtVerifiedWeight" class="form-label">
                                            <i class="fas fa-weight me-2"></i>Actual Weight (kg)
                                        </label>
                                        <div class="input-group">
                                            <asp:TextBox ID="txtVerifiedWeight" runat="server" CssClass="form-control-glass"
                                                TextMode="Number" step="0.1" min="0" Text="15.5" AutoPostBack="true"
                                                OnTextChanged="txtVerifiedWeight_TextChanged"></asp:TextBox>
                                            <span class="input-group-text">kg</span>
                                        </div>
                                        <small class="text-muted">Enter the actual weight collected</small>
                                    </div>

                                    <div class="form-group mb-3">
                                        <label for="ddlMaterialType" class="form-label">
                                            <i class="fas fa-recycle me-2"></i>Material Type
                                        </label>
                                        <asp:DropDownList ID="ddlMaterialType" runat="server" CssClass="form-control-glass"
                                            AutoPostBack="true" OnSelectedIndexChanged="ddlMaterialType_SelectedIndexChanged">
                                            <asp:ListItem Value="Plastic" Selected="True">Plastic</asp:ListItem>
                                            <asp:ListItem Value="Paper">Paper</asp:ListItem>
                                            <asp:ListItem Value="Glass">Glass</asp:ListItem>
                                            <asp:ListItem Value="Metal">Metal</asp:ListItem>
                                            <asp:ListItem Value="Organic">Organic</asp:ListItem>
                                            <asp:ListItem Value="Electronic">Electronic</asp:ListItem>
                                            <asp:ListItem Value="Textile">Textile</asp:ListItem>
                                        </asp:DropDownList>
                                    </div>

                                    <div class="form-group mb-3">
                                        <label for="ddlVerificationMethod" class="form-label">
                                            <i class="fas fa-tools me-2"></i>Verification Method
                                        </label>
                                        <asp:DropDownList ID="ddlVerificationMethod" runat="server" CssClass="form-control-glass"
                                            AutoPostBack="true" OnSelectedIndexChanged="ddlVerificationMethod_SelectedIndexChanged">
                                            <asp:ListItem Value="Manual">Manual Measurement</asp:ListItem>
                                            <asp:ListItem Value="Scale">Digital Scale</asp:ListItem>
                                            <asp:ListItem Value="Estimate">Visual Estimate</asp:ListItem>
                                        </asp:DropDownList>
                                    </div>

                                    <div class="form-group mb-3">
                                        <label for="txtNotes" class="form-label">
                                            <i class="fas fa-sticky-note me-2"></i>Notes
                                        </label>
                                        <asp:TextBox ID="txtNotes" runat="server" CssClass="form-control-glass"
                                            TextMode="MultiLine" Rows="3" placeholder="Add any notes about this pickup..."
                                            AutoPostBack="true" OnTextChanged="txtNotes_TextChanged"></asp:TextBox>
                                    </div>

                                    <!-- Quick Actions -->
                                    <div class="quick-actions mb-3">
                                        <h6><i class="fas fa-bolt me-2"></i>Quick Weight</h6>
                                        <div class="d-flex gap-2 flex-wrap">
                                            <asp:LinkButton ID="btnWeight5kg" runat="server" CssClass="action-btn secondary small"
                                                OnClick="btnWeight5kg_Click">5 kg</asp:LinkButton>
                                            <asp:LinkButton ID="btnWeight10kg" runat="server" CssClass="action-btn secondary small"
                                                OnClick="btnWeight10kg_Click">10 kg</asp:LinkButton>
                                            <asp:LinkButton ID="btnWeight15kg" runat="server" CssClass="action-btn secondary small"
                                                OnClick="btnWeight15kg_Click">15 kg</asp:LinkButton>
                                            <asp:LinkButton ID="btnWeight20kg" runat="server" CssClass="action-btn secondary small"
                                                OnClick="btnWeight20kg_Click">20 kg</asp:LinkButton>
                                        </div>
                                    </div>

                                    <!-- Verification Actions -->
                                    <div class="verification-actions">
                                        <div class="d-grid gap-2">
                                            <asp:Button ID="btnCompleteVerification" runat="server"
                                                CssClass="action-btn success btn-lg" Text="Complete Verification"
                                                OnClick="btnCompleteVerification_Click" />
                                            <asp:Button ID="btnSaveDraft" runat="server"
                                                CssClass="action-btn secondary" Text="Save as Draft"
                                                OnClick="btnSaveDraft_Click" />
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Photo Capture Section -->
        <div class="route-controls-glass mt-4">
            <h4><i class="fas fa-camera me-2"></i>Capture Verification Photos</h4>
            <div class="row g-3">
                <div class="col-md-4">
                    <div class="photo-capture-card text-center">
                        <div class="photo-preview-container mb-2">
                            <img id="imgBeforePreview" runat="server" src="" alt="Before Photo Preview"
                                class="photo-preview-img img-fluid rounded" style="display: none; max-height: 150px;" />
                            <div id="beforePlaceholder" class="photo-placeholder" style="display: block;">
                                <i class="fas fa-camera fa-3x text-muted"></i>
                                <p class="mt-2">Waste Before</p>
                            </div>
                        </div>
                        <asp:Button ID="btnCaptureBefore" runat="server" CssClass="action-btn secondary mt-2"
                            Text="Upload Before Photo" OnClick="btnCaptureBefore_Click" />
                        <asp:Button ID="btnRemoveBefore" runat="server" CssClass="action-btn danger small mt-2"
                            Text="Remove" OnClick="btnRemoveBefore_Click" Visible="false" />
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="photo-capture-card text-center">
                        <div class="photo-preview-container mb-2">
                            <img id="imgProcessPreview" runat="server" src="" alt="Process Photo Preview"
                                class="photo-preview-img img-fluid rounded" style="display: none; max-height: 150px;" />
                            <div id="processPlaceholder" class="photo-placeholder" style="display: block;">
                                <i class="fas fa-camera fa-3x text-muted"></i>
                                <p class="mt-2">Collection Process</p>
                            </div>
                        </div>
                        <asp:Button ID="btnCaptureProcess" runat="server" CssClass="action-btn secondary mt-2"
                            Text="Upload Process Photo" OnClick="btnCaptureProcess_Click" />
                        <asp:Button ID="btnRemoveProcess" runat="server" CssClass="action-btn danger small mt-2"
                            Text="Remove" OnClick="btnRemoveProcess_Click" Visible="false" />
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="photo-capture-card text-center">
                        <div class="photo-preview-container mb-2">
                            <img id="imgAfterPreview" runat="server" src="" alt="After Photo Preview"
                                class="photo-preview-img img-fluid rounded" style="display: none; max-height: 150px;" />
                            <div id="afterPlaceholder" class="photo-placeholder" style="display: block;">
                                <i class="fas fa-camera fa-3x text-muted"></i>
                                <p class="mt-2">After Cleanup</p>
                            </div>
                        </div>
                        <asp:Button ID="btnCaptureAfter" runat="server" CssClass="action-btn secondary mt-2"
                            Text="Upload After Photo" OnClick="btnCaptureAfter_Click" />
                        <asp:Button ID="btnRemoveAfter" runat="server" CssClass="action-btn danger small mt-2"
                            Text="Remove" OnClick="btnRemoveAfter_Click" Visible="false" />
                    </div>
                </div>
            </div>
        </div>

        <!-- Verification History -->
        <div class="route-stops-section mt-4">
            <div class="section-header-glass">
                <h3><i class="fas fa-history me-2"></i>Verification History</h3>
            </div>
            <div class="stops-table-container">
                <div class="table-header-glass">
                    <div class="table-header-row">
                        <div class="table-col date-col">Date & Time</div>
                        <div class="table-col weight-col">Weight</div>
                        <div class="table-col type-col">Material Type</div>
                        <div class="table-col method-col">Method</div>
                        <div class="table-col collector-col">Verified By</div>
                        <div class="table-col status-col">Status</div>
                    </div>
                </div>
                <div class="table-body-glass">
                    <asp:Repeater ID="rptVerificationHistory" runat="server"
                        OnItemDataBound="rptVerificationHistory_ItemDataBound">
                        <ItemTemplate>
                            <div class='table-row-glass'>
                                <div class="table-col date-col">
                                    <asp:Label ID="lblVerifiedAt" runat="server"
                                        Text='<%# BindVerifiedAt(Eval("VerifiedAt")) %>'></asp:Label>
                                </div>
                                <div class="table-col weight-col">
                                    <span class="weight-value">
                                        <i class="fas fa-weight me-1"></i>
                                        <asp:Label ID="lblVerifiedKg" runat="server"
                                            Text='<%# Eval("VerifiedKg", "{0:F1}") %>'></asp:Label>
                                        kg
                                    </span>
                                </div>
                                <div class="table-col type-col">
                                    <span class='waste-type-badge'>
                                        <i class='fas fa-trash'></i>
                                        <asp:Label ID="lblMaterialType" runat="server"
                                            Text='<%# Eval("MaterialType") %>'></asp:Label>
                                    </span>
                                </div>
                                <div class="table-col method-col">
                                    <asp:Label ID="lblVerificationMethod" runat="server"
                                        Text='<%# Eval("VerificationMethod") %>'></asp:Label>
                                </div>
                                <div class="table-col collector-col">
                                    <asp:Label ID="lblCollectorName" runat="server"
                                        Text='<%# Eval("CollectorName") %>'></asp:Label>
                                </div>
                                <div class="table-col status-col">
                                    <span class='status-badge completed'>
                                        <i class='fas fa-check-circle'></i>
                                        Verified
                                    </span>
                                </div>
                            </div>
                        </ItemTemplate>
                        <AlternatingItemTemplate>
                            <div class='table-row-glass alt'>
                                <div class="table-col date-col">
                                    <asp:Label ID="lblVerifiedAt" runat="server"
                                        Text='<%# BindVerifiedAt(Eval("VerifiedAt")) %>'></asp:Label>
                                </div>
                                <div class="table-col weight-col">
                                    <span class="weight-value">
                                        <i class="fas fa-weight me-1"></i>
                                        <asp:Label ID="lblVerifiedKg" runat="server"
                                            Text='<%# Eval("VerifiedKg", "{0:F1}") %>'></asp:Label>
                                        kg
                                    </span>
                                </div>
                                <div class="table-col type-col">
                                    <span class='waste-type-badge'>
                                        <i class='fas fa-trash'></i>
                                        <asp:Label ID="lblMaterialType" runat="server"
                                            Text='<%# Eval("MaterialType") %>'></asp:Label>
                                    </span>
                                </div>
                                <div class="table-col method-col">
                                    <asp:Label ID="lblVerificationMethod" runat="server"
                                        Text='<%# Eval("VerificationMethod") %>'></asp:Label>
                                </div>
                                <div class="table-col collector-col">
                                    <asp:Label ID="lblCollectorName" runat="server"
                                        Text='<%# Eval("CollectorName") %>'></asp:Label>
                                </div>
                                <div class="table-col status-col">
                                    <span class='status-badge completed'>
                                        <i class='fas fa-check-circle'></i>
                                        Verified
                                    </span>
                                </div>
                            </div>
                        </AlternatingItemTemplate>
                    </asp:Repeater>

                    <!-- Empty State -->
                    <asp:Panel ID="pnlNoHistory" runat="server" CssClass="text-center py-4" Visible="true">
                        <i class="fas fa-history fa-3x text-muted mb-3"></i>
                        <h5 class="text-muted">No verification history available</h5>
                        <p class="text-muted">This is the first verification for this pickup</p>
                    </asp:Panel>
                </div>
            </div>
        </div>
    </div>

    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

    <script>
        // Store control IDs for JavaScript access
        var controlIds = {
            fileUpload: '<%= fileUpload.ClientID %>',
            btnCaptureBefore: '<%= btnCaptureBefore.ClientID %>',
            btnCaptureProcess: '<%= btnCaptureProcess.ClientID %>',
            btnCaptureAfter: '<%= btnCaptureAfter.ClientID %>',
            btnRemoveBefore: '<%= btnRemoveBefore.ClientID %>',
            btnRemoveProcess: '<%= btnRemoveProcess.ClientID %>',
            btnRemoveAfter: '<%= btnRemoveAfter.ClientID %>',
            txtVerifiedWeight: '<%= txtVerifiedWeight.ClientID %>',
            ddlMaterialType: '<%= ddlMaterialType.ClientID %>',
            lblCreditValue: '<%= lblCreditValue.ClientID %>'
        };

        // File upload trigger
        document.addEventListener('DOMContentLoaded', function () {
            setupFileUploadTriggers();
            setupEventListeners();
        });

        function setupFileUploadTriggers() {
            // Get the hidden file upload control
            var fileUpload = document.getElementById(controlIds.fileUpload);

            // Add click handlers to all photo upload buttons
            var uploadButtons = [
                document.getElementById(controlIds.btnCaptureBefore),
                document.getElementById(controlIds.btnCaptureProcess),
                document.getElementById(controlIds.btnCaptureAfter)
            ];

            uploadButtons.forEach(function (button, index) {
                if (button) {
                    button.addEventListener('click', function (e) {
                        // Store which photo type is being uploaded
                        var photoType = ['Before', 'Process', 'After'][index];
                        sessionStorage.setItem('currentPhotoType', photoType);

                        // Trigger file selection
                        fileUpload.click();
                        e.preventDefault();
                    });
                }
            });

            // Handle file selection
            if (fileUpload) {
                fileUpload.addEventListener('change', function () {
                    if (this.files.length > 0) {
                        var photoType = sessionStorage.getItem('currentPhotoType') || 'Before';
                        var buttonId = '';

                        // Determine which button to click based on photo type
                        switch (photoType) {
                            case 'Before':
                                buttonId = controlIds.btnCaptureBefore;
                                break;
                            case 'Process':
                                buttonId = controlIds.btnCaptureProcess;
                                break;
                            case 'After':
                                buttonId = controlIds.btnCaptureAfter;
                                break;
                        }

                        // Trigger the server-side click event
                        __doPostBack(buttonId, '');
                    }
                });
            }
        }

        function setupEventListeners() {
            // Auto-calculate credits
            const weightInput = document.getElementById(controlIds.txtVerifiedWeight);
            const materialSelect = document.getElementById(controlIds.ddlMaterialType);

            if (weightInput) {
                weightInput.addEventListener('input', calculateCredits);
            }
            if (materialSelect) {
                materialSelect.addEventListener('change', calculateCredits);
            }
        }

        // Calculate credit value
        function calculateCredits() {
            const weightInput = document.getElementById(controlIds.txtVerifiedWeight);
            const materialSelect = document.getElementById(controlIds.ddlMaterialType);

            if (!weightInput || !materialSelect) return;

            const weight = parseFloat(weightInput.value) || 0;
            const materialType = materialSelect.value;

            // Credit rates
            const creditRates = {
                'Plastic': 2.0,
                'Paper': 1.5,
                'Glass': 1.8,
                'Metal': 2.2,
                'Organic': 1.0,
                'Electronic': 3.0,
                'Textile': 1.3,
                'Mixed': 1.5
            };

            const rate = creditRates[materialType] || 1.5;
            const credits = weight * rate;

            // Update display
            const creditValueElement = document.getElementById(controlIds.lblCreditValue);
            if (creditValueElement) {
                creditValueElement.textContent = credits.toFixed(1);
            }
        }

        // Notification function
        function showNotification(type, message) {
            // Remove any existing notifications
            var existingNotifications = document.querySelectorAll('.notification');
            existingNotifications.forEach(function (notification) {
                notification.parentNode.removeChild(notification);
            });

            // Create notification element
            var notification = document.createElement('div');
            notification.className = 'notification notification-' + type;
            notification.textContent = message;

            // Add styles
            notification.style.position = 'fixed';
            notification.style.top = '20px';
            notification.style.right = '20px';
            notification.style.padding = '15px 20px';
            notification.style.borderRadius = '4px';
            notification.style.color = 'white';
            notification.style.fontWeight = 'bold';
            notification.style.zIndex = '10000';
            notification.style.display = 'none';
            notification.style.boxShadow = '0 4px 12px rgba(0,0,0,0.15)';

            if (type === 'success') {
                notification.style.backgroundColor = '#10b981';
                notification.style.borderLeft = '5px solid #059669';
            } else if (type === 'error') {
                notification.style.backgroundColor = '#ef4444';
                notification.style.borderLeft = '5px solid #dc2626';
            } else {
                notification.style.backgroundColor = '#3b82f6';
                notification.style.borderLeft = '5px solid #2563eb';
            }

            // Add to page
            document.body.appendChild(notification);

            // Show with animation
            notification.style.display = 'block';

            // Auto-remove after 5 seconds
            setTimeout(function () {
                notification.style.display = 'none';
                setTimeout(function () {
                    if (notification.parentNode) {
                        notification.parentNode.removeChild(notification);
                    }
                }, 300);
            }, 5000);
        }

        // Toggle photo preview visibility
        function togglePhotoPreview(photoType, show, imageUrl) {
            var previewImg = document.getElementById('img' + photoType + 'Preview');
            var placeholder = document.getElementById(photoType.toLowerCase() + 'Placeholder');
            var removeBtn = null;

            // Get the correct remove button based on photo type
            if (photoType === 'Before') {
                removeBtn = document.getElementById(controlIds.btnRemoveBefore);
            } else if (photoType === 'Process') {
                removeBtn = document.getElementById(controlIds.btnRemoveProcess);
            } else if (photoType === 'After') {
                removeBtn = document.getElementById(controlIds.btnRemoveAfter);
            }

            if (previewImg && placeholder) {
                if (show) {
                    previewImg.src = imageUrl;
                    previewImg.style.display = 'block';
                    placeholder.style.display = 'none';
                    if (removeBtn) removeBtn.style.display = 'inline-block';
                } else {
                    previewImg.style.display = 'none';
                    placeholder.style.display = 'block';
                    if (removeBtn) removeBtn.style.display = 'none';
                }
            }
        }
    </script>

    <style>
        /* Photo Preview Styles */
        .photo-preview-container {
            position: relative;
            min-height: 150px;
            border: 2px dashed #ddd;
            border-radius: 10px;
            padding: 10px;
            background: #f8f9fa;
        }

        .photo-preview-img {
            max-width: 100%;
            max-height: 150px;
            object-fit: cover;
            border-radius: 8px;
        }

        .photo-placeholder {
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            height: 100%;
            color: #6c757d;
        }

        /* Action Button Styles */
        .action-btn {
            padding: 8px 16px;
            border-radius: 8px;
            border: none;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            justify-content: center;
        }

            .action-btn.primary {
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                color: white;
            }

            .action-btn.secondary {
                background: #6c757d;
                color: white;
            }

            .action-btn.success {
                background: linear-gradient(135deg, #10b981 0%, #059669 100%);
                color: white;
            }

            .action-btn.danger {
                background: linear-gradient(135deg, #ef4444 0%, #dc2626 100%);
                color: white;
            }

            .action-btn.warning {
                background: linear-gradient(135deg, #f59e0b 0%, #d97706 100%);
                color: white;
            }

            .action-btn.small {
                padding: 4px 12px;
                font-size: 0.875rem;
            }

            .action-btn:hover {
                transform: translateY(-2px);
                box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
            }

        /* Form Control Styles */
        .form-control-glass {
            background: rgba(255, 255, 255, 0.1);
            backdrop-filter: blur(10px);
            border: 1px solid rgba(255, 255, 255, 0.2);
            border-radius: 8px;
            color: #333;
            padding: 10px 15px;
            transition: all 0.3s ease;
        }

            .form-control-glass:focus {
                background: rgba(255, 255, 255, 0.15);
                border-color: #667eea;
                box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
                outline: none;
            }

        /* Waste Type Badges */
        .waste-type-badge-large {
            display: inline-flex;
            align-items: center;
            gap: 10px;
            padding: 12px 24px;
            border-radius: 50px;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 1px;
            color: white;
        }

            .waste-type-badge-large.plastic {
                background: linear-gradient(135deg, #ef4444 0%, #dc2626 100%);
            }

            .waste-type-badge-large.paper {
                background: linear-gradient(135deg, #4ECDC4 0%, #45B7D1 100%);
            }

            .waste-type-badge-large.glass {
                background: linear-gradient(135deg, #3b82f6 0%, #1d4ed8 100%);
            }

            .waste-type-badge-large.metal {
                background: linear-gradient(135deg, #96CEB4 0%, #4CAF50 100%);
            }

            .waste-type-badge-large.organic {
                background: linear-gradient(135deg, #FFEAA7 0%, #f59e0b 100%);
            }

            .waste-type-badge-large.electronic {
                background: linear-gradient(135deg, #DDA0DD 0%, #9333ea 100%);
            }

            .waste-type-badge-large.textile {
                background: linear-gradient(135deg, #98D8C8 0%, #0d9488 100%);
            }

            .waste-type-badge-large.mixed {
                background: linear-gradient(135deg, #94a3b8 0%, #64748b 100%);
            }

        /* Status Badges */
        .status-badge {
            display: inline-flex;
            align-items: center;
            gap: 5px;
            padding: 6px 12px;
            border-radius: 20px;
            font-size: 0.875rem;
            font-weight: 600;
            text-transform: uppercase;
        }

            .status-badge.completed {
                background: rgba(16, 185, 129, 0.1);
                color: #10b981;
                border: 1px solid rgba(16, 185, 129, 0.3);
            }

            .status-badge.in-progress {
                background: rgba(59, 130, 246, 0.1);
                color: #3b82f6;
                border: 1px solid rgba(59, 130, 246, 0.3);
            }

            .status-badge.pending {
                background: rgba(245, 158, 11, 0.1);
                color: #f59e0b;
                border: 1px solid rgba(245, 158, 11, 0.3);
            }

        /* Responsive adjustments */
        @media (max-width: 768px) {
            .photo-capture-card {
                margin-bottom: 20px;
            }

            .action-btn {
                width: 100%;
                margin-bottom: 10px;
            }

            .verification-actions .d-grid {
                grid-template-columns: 1fr;
            }
        }
    </style>
</asp:Content>
