<%@ Page Title="Report Waste" Language="C#" MasterPageFile="~/Pages/Citizen/Site.Master"
    AutoEventWireup="true" CodeFile="ReportWaste.aspx.cs" Inherits="SoorGreen.Admin.ReportWaste" %>

<asp:Content ID="Content3" ContentPlaceHolderID="HeadContent" runat="server">
    <link href='<%= ResolveUrl("~/Content/Pages/Citizen/citizenreportwaste.css") %>' rel="stylesheet" />
    <style>
        /* FIX: Scrollbar for main container */
        .report-container {
            position: relative;
            min-height: calc(100vh - 150px);
            overflow-y: auto;
            padding-right: 10px;
        }
        
        /* Custom scrollbar that works with both themes */
        .report-container::-webkit-scrollbar {
            width: 10px;
        }
        
        .report-container::-webkit-scrollbar-track {
            background: rgba(255, 255, 255, 0.1);
            border-radius: 10px;
            margin: 5px 0;
        }
        
        .report-container::-webkit-scrollbar-thumb {
            background: rgba(16, 185, 129, 0.6);
            border-radius: 10px;
            border: 2px solid transparent;
            background-clip: content-box;
        }
        
        .report-container::-webkit-scrollbar-thumb:hover {
            background: rgba(16, 185, 129, 0.8);
        }
        
        [data-theme="dark"] .report-container::-webkit-scrollbar-track {
            background: rgba(0, 0, 0, 0.2);
        }
        
        [data-theme="dark"] .report-container::-webkit-scrollbar-thumb {
            background: rgba(16, 185, 129, 0.4);
        }
        
        [data-theme="dark"] .report-container::-webkit-scrollbar-thumb:hover {
            background: rgba(16, 185, 129, 0.6);
        }
        
        /* Fix for message panel visibility */
        .message-panel {
            position: fixed;
            top: 80px;
            right: 20px;
            width: 350px;
            z-index: 9999;
            display: block;
            visibility: visible;
        }
        
        .message-alert {
            padding: 15px;
            margin-bottom: 10px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            animation: slideIn 0.3s ease;
            box-shadow: 0 8px 25px rgba(0,0,0,0.2);
            visibility: visible !important;
            opacity: 1 !important;
            transform: none !important;
        }
        
        .message-alert.show {
            display: flex !important;
            visibility: visible !important;
            opacity: 1 !important;
        }
        
        .message-alert.success {
            background: linear-gradient(135deg, #10B981, #059669);
            color: white;
            border-left: 4px solid #047857;
        }
        
        .message-alert.error {
            background: linear-gradient(135deg, #EF4444, #DC2626);
            color: white;
            border-left: 4px solid #B91C1C;
        }
        
        .message-alert.warning {
            background: linear-gradient(135deg, #F59E0B, #D97706);
            color: white;
            border-left: 4px solid #B45309;
        }
        
        .message-alert i {
            font-size: 24px;
            margin-right: 15px;
        }
        
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
        
        /* Fix: Ensure selected waste type is visible in both themes */
        .category-card-glass.selected {
            border: 2px solid #22c55e !important;
            background: rgba(34, 197, 94, 0.1) !important;
            box-shadow: 0 0 0 3px rgba(34, 197, 94, 0.2) !important;
            transform: translateY(-2px);
            transition: all 0.3s ease;
        }
        
        .category-card-glass.selected .category-icon-glass {
            background: linear-gradient(135deg, #22c55e, #16a34a) !important;
            color: white !important;
        }
        
        /* Fix: Ensure text is visible in both themes */
        .card-header-glass h4,
        .card-header-glass i {
            color: white !important;
            text-shadow: 0 2px 4px rgba(0, 0, 0, 0.3) !important;
        }
        
        /* Fix: Ensure form labels are visible */
        .form-label {
            color: white !important;
            text-shadow: 0 1px 2px rgba(0, 0, 0, 0.3) !important;
        }
        
        /* Fix: Ensure text-muted is visible in dark mode */
        [data-theme="dark"] .text-muted {
            color: rgba(255, 255, 255, 0.7) !important;
        }
        
        /* Fix: Ensure preview text is visible */
        .preview-details .text-muted,
        .detail-row .text-muted {
            color: rgba(255, 255, 255, 0.8) !important;
        }
        
        /* Fix: Ensure placeholders are visible */
        .form-control-glass::placeholder {
            color: rgba(255, 255, 255, 0.6) !important;
        }
        
        /* Fix: Ensure form check labels are visible */
        .form-check-label {
            color: white !important;
            text-shadow: 0 1px 2px rgba(0, 0, 0, 0.2) !important;
        }
        
        /* Fix: Ensure stats cards text is visible */
        .stats-card .stats-number,
        .stats-card .stats-label {
            color: white !important;
            text-shadow: 0 1px 2px rgba(0, 0, 0, 0.3) !important;
        }
        
        /* Fix: Ensure step labels are visible */
        .step-label-glass {
            color: rgba(255, 255, 255, 0.9) !important;
        }
        
        /* Fix: Remove inline conflicting styles */
        .card-glass {
            background: transparent !important;
            backdrop-filter: blur(20px) !important;
            border: 1px solid rgba(255, 255, 255, 0.2) !important;
        }
        
        .stats-card {
            background: rgba(255, 255, 255, 0.1) !important;
            backdrop-filter: blur(20px) !important;
        }
        
        /* Fix: Ensure button text is visible */
        .btn {
            color: white !important;
            text-shadow: 0 1px 1px rgba(0, 0, 0, 0.3) !important;
        }
    </style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <!-- Message Panel -->
    <div class="message-panel" style="display: none;"></div>

    <div class="report-container">
        <div class="d-flex align-items-center mb-4">
            <h1 class="h3 mb-0 text-white">Report Waste Collection</h1>
        </div>
        
        <!-- Stats Cards -->
        <div class="d-flex gap-3 mb-4 flex-wrap">
            <div class="stats-card rewards" style="flex: 1; min-width: 200px;">
                <div class="stats-icon">
                    <i class="fas fa-coins"></i>
                </div>
                <div class="stats-number" id="statCredits" runat="server">0.00</div>
                <div class="stats-label">Your Credits</div>
            </div>
            <div class="stats-card reports" style="flex: 1; min-width: 200px;">
                <div class="stats-icon">
                    <i class="fas fa-file-alt"></i>
                </div>
                <div class="stats-number" id="statReports" runat="server">0</div>
                <div class="stats-label">Your Reports</div>
            </div>
            <div class="stats-card weight" style="flex: 1; min-width: 200px;">
                <div class="stats-icon">
                    <i class="fas fa-weight-hanging"></i>
                </div>
                <div class="stats-number" id="statWeight" runat="server">0.0 kg</div>
                <div class="stats-label">Recycled</div>
            </div>
            <div class="stats-card potential" style="flex: 1; min-width: 200px;">
                <div class="stats-icon">
                    <i class="fas fa-gift"></i>
                </div>
                <div class="stats-number" id="statPotential" runat="server">0 XP</div>
                <div class="stats-label">Potential</div>
            </div>
        </div>

        <!-- Progress Steps -->
        <div class="progress-steps-glass mb-5">
            <div class="d-flex align-items-center justify-content-between">
                <div class="d-flex flex-column align-items-center position-relative">
                    <div class="step-number-glass active" id="step1">1</div>
                    <div class="step-line-glass" id="line1"></div>
                    <div class="step-label-glass mt-2">Waste Type</div>
                </div>
                <div class="step-line-glass" id="line2"></div>
                <div class="d-flex flex-column align-items-center position-relative">
                    <div class="step-number-glass" id="step2">2</div>
                    <div class="step-label-glass mt-2">Details</div>
                </div>
                <div class="step-line-glass" id="line3"></div>
                <div class="d-flex flex-column align-items-center position-relative">
                    <div class="step-number-glass" id="step3">3</div>
                    <div class="step-label-glass mt-2">Location</div>
                </div>
                <div class="step-line-glass" id="line4"></div>
                <div class="d-flex flex-column align-items-center position-relative">
                    <div class="step-number-glass" id="step4">4</div>
                    <div class="step-label-glass mt-2">Review</div>
                </div>
            </div>
        </div>

        <!-- Step 1: Waste Type Selection -->
        <asp:Panel ID="pnlStep1" runat="server" CssClass="form-step">
            <div class="card-glass">
                <div class="card-header-glass">
                    <h4 class="mb-0"><i class="fas fa-layer-group me-2"></i>Select Waste Category</h4>
                    <span class="badge-glass">Step 1 of 4</span>
                </div>
                <div class="card-body">
                    <p class="text-muted mb-4">Choose the type of waste you want to submit for collection. Select one to continue.</p>

                    <div class="waste-type-grid-glass">
                        <asp:Repeater ID="rptWasteTypes" runat="server" OnItemCommand="rptWasteTypes_ItemCommand">
                            <ItemTemplate>
                                <div class="category-card-glass">
                                    <asp:LinkButton ID="btnSelectType" runat="server" CommandName="SelectType"
                                        CommandArgument='<%# Eval("WasteTypeId") + "|" + Eval("CreditPerKg") + "|" + Eval("Name") %>'
                                        CssClass="d-block text-decoration-none waste-type-select">
                                        <div class="p-4">
                                            <div class="d-flex align-items-center">
                                                <div class="category-icon-glass me-3">
                                                    <i class="fas <%# GetWasteTypeIcon(Eval("Name").ToString()) %>"></i>
                                                </div>
                                                <div class="flex-grow-1">
                                                    <h5 class="mb-1 text-white"><%# Eval("Name") %></h5>
                                                    <p class="text-muted small mb-2"><%# Eval("Description") %></p>
                                                    <div class="d-flex justify-content-between align-items-center">
                                                        <span class="badge bg-success"><i class="fas fa-coins me-1"></i><%# Eval("CreditPerKg", "{0:N2}") %> XP/kg</span>
                                                        <small class="text-muted"><%# Eval("Category") %></small>
                                                    </div>
                                                </div>
                                                <i class="fas fa-chevron-right text-muted"></i>
                                            </div>
                                        </div>
                                    </asp:LinkButton>
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>

                    <div class="info-box-glass mt-4">
                        <i class="fas fa-lightbulb"></i>
                        <div class="text-white">
                            <strong>Tip:</strong> Select the waste type that best matches your materials. 
                            Different types earn different reward rates based on their recycling value.
                        </div>
                    </div>

                    <div class="d-flex justify-content-end mt-4">
                        <asp:Button ID="btnNextStep1" runat="server" CssClass="btn btn-primary btn-with-icon"
                            Text="Continue to Details" OnClick="btnNextStep1_Click" Enabled="false" />
                    </div>
                </div>
            </div>
        </asp:Panel>

        <!-- Step 2: Waste Details -->
        <asp:Panel ID="pnlStep2" runat="server" CssClass="form-step" Visible="false">
            <div class="card-glass">
                <div class="card-header-glass">
                    <h4 class="mb-0"><i class="fas fa-info-circle me-2"></i>Waste Details</h4>
                    <span class="badge-glass">Step 2 of 4</span>
                </div>
                <div class="card-body">
                    <p class="text-muted mb-4">Provide information about your waste submission. Accurate details help with proper collection.</p>

                    <div class="row">
                        <div class="col-lg-8">
                            <div class="form-group-glass mb-4">
                                <label class="form-label"><i class="fas fa-weight-hanging me-2"></i>Estimated Weight (kg) *</label>
                                <div class="input-group-glass">
                                    <i class="fas fa-weight-hanging input-icon"></i>
                                    <asp:TextBox ID="txtWeight" runat="server" CssClass="form-control-glass"
                                        TextMode="Number" step="0.1" min="0.1" placeholder="0.0"
                                        OnTextChanged="txtWeight_TextChanged" AutoPostBack="true" />
                                </div>
                                <small class="text-muted">Enter estimated weight in kilograms. More accurate = better rewards!</small>

                                <div class="quick-weight-buttons mt-4">
                                    <label class="form-label"><i class="fas fa-bolt me-2"></i>Quick Selection</label>
                                    <div class="d-flex gap-2 flex-wrap">
                                        <asp:Button ID="btnWeight0_5" runat="server" Text="0.5 kg" CssClass="btn btn-outline-primary btn-sm" OnClick="btnWeight0_5_Click" />
                                        <asp:Button ID="btnWeight1" runat="server" Text="1 kg" CssClass="btn btn-outline-primary btn-sm" OnClick="btnWeight1_Click" />
                                        <asp:Button ID="btnWeight2" runat="server" Text="2 kg" CssClass="btn btn-outline-primary btn-sm" OnClick="btnWeight2_Click" />
                                        <asp:Button ID="btnWeight5" runat="server" Text="5 kg" CssClass="btn btn-outline-primary btn-sm" OnClick="btnWeight5_Click" />
                                        <asp:Button ID="btnWeight10" runat="server" Text="10 kg" CssClass="btn btn-outline-primary btn-sm" OnClick="btnWeight10_Click" />
                                    </div>
                                </div>
                            </div>

                            <div class="form-group-glass mb-4">
                                <label class="form-label"><i class="fas fa-align-left me-2"></i>Description (Optional)</label>
                                <div class="input-group-glass">
                                    <i class="fas fa-align-left input-icon"></i>
                                    <asp:TextBox ID="txtDescription" runat="server" CssClass="form-control-glass"
                                        TextMode="MultiLine" Rows="4"
                                        placeholder="E.g., 'Clear plastic bottles', 'Mixed paper waste', 'Broken glass jars', 'Aluminum cans, etc.'" />
                                </div>
                                <small class="text-muted">Add specific details about your waste materials</small>
                            </div>
                        </div>

                        <div class="col-lg-4">
                            <div class="reward-preview-glass">
                                <div class="text-center mb-4">
                                    <div class="weight-preview-circle-glass mb-3">
                                        <div class="display-6 fw-bold text-white">
                                            <asp:Label ID="lblWeightPreview" runat="server" Text="0"></asp:Label>
                                        </div>
                                        <small class="text-white">kilograms</small>
                                    </div>
                                    <h5 class="mb-3 text-white"><i class="fas fa-calculator me-2"></i>Reward Estimation</h5>
                                </div>

                                <div class="preview-details">
                                    <div class="detail-row">
                                        <span class="text-muted">Waste Type:</span>
                                        <asp:Label ID="lblSelectedWaste" runat="server" Text="None" CssClass="fw-bold text-white"></asp:Label>
                                    </div>
                                    <div class="detail-row">
                                        <span class="text-muted">Reward Rate:</span>
                                        <asp:Label ID="lblRatePreview" runat="server" Text="0 XP/kg" CssClass="fw-bold text-white"></asp:Label>
                                    </div>
                                    <div class="detail-row">
                                        <span class="text-muted">Weight:</span>
                                        <asp:Label ID="lblWeightDisplay" runat="server" Text="0 kg" CssClass="fw-bold text-white"></asp:Label>
                                    </div>
                                </div>

                                <div class="border-top pt-4">
                                    <div class="text-center">
                                        <div class="text-muted small mb-2">Estimated Reward</div>
                                        <div class="display-4 text-success fw-bold">
                                            <asp:Label ID="lblEstimatedReward" runat="server" Text="0"></asp:Label>
                                            <span class="fs-6">XP</span>
                                        </div>
                                        <div class="reward-badge-glass mt-3">
                                            <i class="fas fa-gift me-2"></i>Potential Reward
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="d-flex justify-content-between mt-4">
                        <asp:Button ID="btnBackStep2" runat="server" CssClass="btn btn-outline-secondary btn-with-icon"
                            Text="Back to Waste Type" OnClick="btnBackStep2_Click" />
                        <asp:Button ID="btnNextStep2" runat="server" CssClass="btn btn-primary btn-with-icon"
                            Text="Continue to Location" OnClick="btnNextStep2_Click" />
                    </div>
                </div>
            </div>
        </asp:Panel>

        <!-- Step 3: Location Details -->
        <asp:Panel ID="pnlStep3" runat="server" CssClass="form-step" Visible="false">
            <div class="card-glass">
                <div class="card-header-glass">
                    <h4 class="mb-0"><i class="fas fa-map-marker-alt me-2"></i>Collection Location</h4>
                    <span class="badge-glass">Step 3 of 4</span>
                </div>
                <div class="card-body">
                    <p class="text-muted mb-4">Specify where the waste should be collected from. Accurate location ensures smooth pickup.</p>

                    <div class="row">
                        <div class="col-lg-8">
                            <div class="form-group-glass mb-4">
                                <label class="form-label"><i class="fas fa-home me-2"></i>Full Address *</label>
                                <div class="input-group-glass">
                                    <i class="fas fa-home input-icon"></i>
                                    <asp:TextBox ID="txtAddress" runat="server" CssClass="form-control-glass"
                                        TextMode="MultiLine" Rows="3"
                                        placeholder="House/Building number, street, area, city, postal code" />
                                </div>
                                <asp:RequiredFieldValidator ID="rfvAddress" runat="server" ControlToValidate="txtAddress"
                                    ErrorMessage="Please enter collection address" CssClass="text-danger small" Display="Dynamic" />
                                <small class="text-muted">Where should the collector come to pick up the waste?</small>
                            </div>

                            <div class="row mb-4">
                                <div class="col-md-6">
                                    <div class="form-group-glass">
                                        <label class="form-label"><i class="fas fa-landmark me-2"></i>Landmark (Optional)</label>
                                        <div class="input-group-glass">
                                            <i class="fas fa-landmark input-icon"></i>
                                            <asp:TextBox ID="txtLandmark" runat="server" CssClass="form-control-glass"
                                                placeholder="Nearby landmark, shop, or building" />
                                        </div>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="form-group-glass">
                                        <label class="form-label"><i class="fas fa-user me-2"></i>Contact Person</label>
                                        <div class="input-group-glass">
                                            <i class="fas fa-user input-icon"></i>
                                            <asp:TextBox ID="txtContactPerson" runat="server" CssClass="form-control-glass"
                                                placeholder="Name of contact person" />
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <div class="form-group-glass mb-4">
                                <label class="form-label"><i class="fas fa-clipboard me-2"></i>Special Instructions (Optional)</label>
                                <div class="input-group-glass">
                                    <i class="fas fa-clipboard input-icon"></i>
                                    <asp:TextBox ID="txtInstructions" runat="server" CssClass="form-control-glass"
                                        TextMode="MultiLine" Rows="3"
                                        placeholder="E.g., 'Leave at gate', 'Call before coming', 'Available after 5 PM', 'Gate code: 1234'" />
                                </div>
                                <small class="text-muted">Any specific instructions for the collector</small>
                            </div>
                        </div>

                        <div class="col-lg-4">
                            <div class="location-preview-glass">
                                <div class="text-center mb-4">
                                    <div class="map-preview-glass">
                                        <i class="fas fa-map-marked-alt fa-3x mb-3 text-white"></i>
                                        <div class="text-white">Location Preview</div>
                                    </div>
                                    <h5 class="mb-3 text-white"><i class="fas fa-location-dot me-2"></i>Coordinates (Optional)</h5>
                                </div>

                                <div class="coordinates-group">
                                    <div class="form-group-glass mb-3">
                                        <div class="input-group-glass">
                                            <i class="fas fa-globe-americas input-icon"></i>
                                            <asp:TextBox ID="txtLatitude" runat="server" CssClass="form-control-glass"
                                                placeholder="Latitude" />
                                        </div>
                                    </div>
                                    <div class="form-group-glass mb-4">
                                        <div class="input-group-glass">
                                            <i class="fas fa-globe-americas input-icon"></i>
                                            <asp:TextBox ID="txtLongitude" runat="server" CssClass="form-control-glass"
                                                placeholder="Longitude" />
                                        </div>
                                    </div>
                                    <asp:Button ID="btnGetLocation" runat="server" Text="Use Current Location" 
                                        CssClass="btn btn-outline-info btn-sm btn-with-icon w-100" 
                                        OnClick="btnGetLocation_Click" />
                                </div>

                                <div class="info-box-glass mt-4">
                                    <i class="fas fa-info-circle"></i>
                                    <div class="text-white">
                                        <strong>Location Tips:</strong> Provide complete address with postal code for faster pickup.
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="d-flex justify-content-between mt-4">
                        <asp:Button ID="btnBackStep3" runat="server" CssClass="btn btn-outline-secondary btn-with-icon"
                            Text="Back to Details" OnClick="btnBackStep3_Click" />
                        <asp:Button ID="btnNextStep3" runat="server" CssClass="btn btn-primary btn-with-icon"
                            Text="Review & Submit" OnClick="btnNextStep3_Click" />
                    </div>
                </div>
            </div>
        </asp:Panel>

        <!-- Step 4: Review & Submit -->
        <asp:Panel ID="pnlStep4" runat="server" CssClass="form-step" Visible="false">
            <div class="card-glass">
                <div class="card-header-glass">
                    <h4 class="mb-0"><i class="fas fa-clipboard-check me-2"></i>Review & Submit</h4>
                    <span class="badge-glass">Step 4 of 4</span>
                </div>
                <div class="card-body">
                    <p class="text-muted mb-4">Confirm your waste report details before final submission. Review carefully!</p>

                    <div class="row">
                        <div class="col-lg-8">
                            <div class="summary-card-glass mb-4">
                                <h5 class="mb-3 text-white"><i class="fas fa-receipt me-2"></i>Report Summary</h5>
                                <div class="summary-details">
                                    <div class="detail-row">
                                        <span class="text-muted">Waste Type:</span>
                                        <asp:Label ID="lblReviewWasteType" runat="server" Text="Not selected" CssClass="fw-bold text-white"></asp:Label>
                                    </div>
                                    <div class="detail-row">
                                        <span class="text-muted">Estimated Weight:</span>
                                        <asp:Label ID="lblReviewWeight" runat="server" Text="0 kg" CssClass="fw-bold text-white"></asp:Label>
                                    </div>
                                    <div class="detail-row">
                                        <span class="text-muted">Reward Rate:</span>
                                        <asp:Label ID="lblReviewRate" runat="server" Text="0 XP/kg" CssClass="fw-bold text-white"></asp:Label>
                                    </div>
                                    <div class="detail-row">
                                        <span class="text-muted">Contact Person:</span>
                                        <asp:Label ID="lblReviewContact" runat="server" Text="-" CssClass="fw-bold text-white"></asp:Label>
                                    </div>
                                    <div class="detail-row">
                                        <span class="text-muted">Collection Address:</span>
                                        <asp:Label ID="lblReviewAddress" runat="server" Text="Not provided" CssClass="fw-bold text-white"></asp:Label>
                                    </div>
                                    <div class="detail-row">
                                        <span class="text-muted">Description:</span>
                                        <div class="text-muted">
                                            <asp:Label ID="lblReviewDescription" runat="server" Text="No description provided"></asp:Label>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <div class="confirmation-card-glass">
                                <h5 class="mb-3 text-white"><i class="fas fa-check-circle me-2"></i>Confirmation & Terms</h5>
                                <div class="form-check-glass mb-4">
                                    <asp:CheckBox ID="chkConfirmDetails" runat="server" CssClass="form-check-input" />
                                    <label class="form-check-label fw-bold text-white" for="<%= chkConfirmDetails.ClientID %>">
                                        <i class="fas fa-check text-success me-2"></i>I confirm all details are correct and accurate
                                    </label>
                                </div>
                                <div class="form-check-glass mb-4">
                                    <asp:CheckBox ID="chkAgreeTerms" runat="server" CssClass="form-check-input" />
                                    <label class="form-check-label fw-bold text-white" for="<%= chkAgreeTerms.ClientID %>">
                                        <i class="fas fa-file-contract text-info me-2"></i>I agree to terms and conditions of waste collection
                                    </label>
                                </div>
                                <div class="form-check-glass">
                                    <asp:CheckBox ID="chkSchedulePickup" runat="server" CssClass="form-check-input" Checked="true" />
                                    <label class="form-check-label fw-bold text-white" for="<%= chkSchedulePickup.ClientID %>">
                                        <i class="fas fa-clock text-warning me-2"></i>Schedule pickup within 48 hours (recommended)
                                    </label>
                                </div>
                            </div>
                        </div>

                        <div class="col-lg-4">
                            <div class="final-reward-glass">
                                <div class="text-center mb-4">
                                    <div class="reward-icon-glass mx-auto mb-3">
                                        <i class="fas fa-gift text-white"></i>
                                    </div>
                                    <h4 class="text-white">Final Reward Summary</h4>
                                </div>

                                <div class="text-center mb-4">
                                    <div class="display-3 text-success mb-2 fw-bold">
                                        <asp:Label ID="lblFinalReward" runat="server" Text="0"></asp:Label>
                                    </div>
                                    <div class="h4 text-muted mb-4">XP Points</div>
                                    <div class="eco-badge-glass">
                                        <i class="fas fa-leaf me-1"></i>Eco-Friendly Contribution
                                    </div>
                                </div>

                                <div class="reward-breakdown">
                                    <div class="detail-row">
                                        <span class="text-muted">Weight:</span>
                                        <span class="fw-bold text-white">
                                            <asp:Label ID="lblFinalWeight" runat="server" Text="0 kg"></asp:Label></span>
                                    </div>
                                    <div class="detail-row">
                                        <span class="text-muted">Rate:</span>
                                        <span class="fw-bold text-white">
                                            <asp:Label ID="lblFinalRate" runat="server" Text="0 XP/kg"></asp:Label></span>
                                    </div>
                                    <div class="detail-row">
                                        <span class="text-muted">Collection:</span>
                                        <span class="fw-bold text-info">Within 48h</span>
                                    </div>
                                    <div class="detail-row total-row">
                                        <span class="h5 mb-0 text-white">Total Reward:</span>
                                        <span class="h5 mb-0 text-success">
                                            <asp:Label ID="lblFinalTotal" runat="server" Text="0 XP"></asp:Label></span>
                                    </div>
                                </div>

                                <div class="reward-note">
                                    <i class="fas fa-info-circle me-2"></i>
                                    Reward will be awarded after collection verification. You'll receive notification when processed.
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="d-flex justify-content-between mt-4">
                        <asp:Button ID="btnBackStep4" runat="server" CssClass="btn btn-outline-secondary btn-with-icon"
                            Text="Edit Details" OnClick="btnBackStep4_Click" />
                        <asp:Button ID="btnSubmitReport" runat="server" CssClass="btn btn-success btn-lg btn-with-icon"
                            Text="Submit Report" OnClick="btnSubmitReport_Click" />
                    </div>
                </div>
            </div>
        </asp:Panel>

        <!-- Success Message -->
        <asp:Panel ID="pnlSuccess" runat="server" Visible="false" CssClass="form-step">
            <div class="success-card-glass">
                <div class="card-body text-center py-5">
                    <div class="mb-4">
                        <i class="fas fa-check-circle text-success success-icon"></i>
                    </div>

                    <h3 class="mb-3 text-white">Report Submitted Successfully!</h3>
                    <p class="text-muted mb-4">
                        Your waste report has been submitted and saved to the database.
                    </p>

                    <div class="db-confirmation-glass">
                        <h5 class="mb-3 text-white"><i class="fas fa-database me-2"></i>Database Confirmation</h5>
                        <div class="detail-row">
                            <span class="text-muted">Report ID:</span>
                            <asp:Label ID="lblSuccessReportId" runat="server" Text="" CssClass="fw-bold text-info"></asp:Label>
                        </div>
                        <div class="detail-row">
                            <span class="text-muted">Pickup ID:</span>
                            <asp:Label ID="lblSuccessPickupId" runat="server" Text="" CssClass="fw-bold text-info"></asp:Label>
                        </div>
                        <div class="detail-row">
                            <span class="text-muted">Reward Points:</span>
                            <asp:Label ID="lblSuccessReward" runat="server" Text="" CssClass="fw-bold text-success"></asp:Label>
                        </div>
                        <div class="detail-row">
                            <span class="text-muted">Submission Time:</span>
                            <asp:Label ID="lblSuccessTime" runat="server" Text="" CssClass="fw-bold text-white"></asp:Label>
                        </div>
                        <div class="detail-row">
                            <span class="text-muted">Status:</span>
                            <span class="badge bg-success">Saved to Database</span>
                        </div>
                    </div>

                    <div class="d-flex gap-3 justify-content-center mt-4">
                        <asp:HyperLink ID="lnkGoDashboard" runat="server" NavigateUrl="Dashboard.aspx"
                            CssClass="btn btn-primary btn-with-icon">
                            <i class="fas fa-tachometer-alt me-2"></i>Go to Dashboard
                        </asp:HyperLink>
                        <asp:Button ID="btnSubmitAnother" runat="server" Text="Submit Another" 
                            CssClass="btn btn-outline-primary btn-with-icon" OnClick="btnSubmitAnother_Click" />
                    </div>
                </div>
            </div>
        </asp:Panel>
    </div>
    
    <!-- JavaScript to ensure functions exist -->
    <script type="text/javascript">
        // Ensure global functions exist
        if (typeof showDatabaseConfirmation === 'undefined') {
            window.showDatabaseConfirmation = function() {
                var successCard = document.querySelector('.success-card-glass');
                if (successCard) {
                    successCard.style.animation = 'none';
                    setTimeout(function() {
                        successCard.style.animation = 'pulse 2s infinite';
                    }, 10);
                }
            };
        }
        
        if (typeof updateProgressSteps === 'undefined') {
            window.updateProgressSteps = function(currentStep) {
                for (var i = 1; i <= 4; i++) {
                    var stepElement = document.getElementById('step' + i);
                    var lineElement = document.getElementById('line' + i);
                    if (stepElement) stepElement.classList.remove('active');
                    if (lineElement) lineElement.classList.remove('active');
                }

                for (var i = 1; i <= currentStep; i++) {
                    var stepElement = document.getElementById('step' + i);
                    var lineElement = document.getElementById('line' + i);
                    if (stepElement) stepElement.classList.add('active');
                    if (lineElement && i < currentStep) lineElement.classList.add('active');
                }
            };
        }
        
        // Function to handle waste type selection (safe version)
        window.selectWasteTypeSafe = function(wasteName) {
            try {
                var wasteCards = document.querySelectorAll('.category-card-glass');
                wasteCards.forEach(function(card) {
                    card.classList.remove('selected');
                });
                
                var selectedCards = document.querySelectorAll('.waste-type-select');
                selectedCards.forEach(function(card) {
                    if (card.textContent.indexOf(wasteName) > -1) {
                        var parent = card.closest('.category-card-glass');
                        if (parent) {
                            parent.classList.add('selected');
                        }
                    }
                });
            } catch (e) {
                console.log('Error selecting waste type:', e);
            }
        };
        
        // Initialize on page load
        document.addEventListener('DOMContentLoaded', function() {
            // Make sure message panel exists
            if (!document.querySelector('.message-panel')) {
                var messagePanel = document.createElement('div');
                messagePanel.className = 'message-panel';
                document.body.appendChild(messagePanel);
            }
            
            // Add keyboard shortcuts
            document.addEventListener('keydown', function(e) {
                if (e.ctrlKey && e.key === 'Enter') {
                    var submitBtn = document.getElementById('<%= btnSubmitReport.ClientID %>');
                    if (submitBtn && submitBtn.offsetParent !== null) {
                        submitBtn.click();
                    }
                }
            });

            // Force scrollbar to be visible
            var reportContainer = document.querySelector('.report-container');
            if (reportContainer) {
                reportContainer.style.overflowY = 'auto';
                reportContainer.style.overflowX = 'hidden';
            }
        });

        // Scrollbar fix for non-webkit browsers
        function initializeScrollbar() {
            var container = document.querySelector('.report-container');
            if (container && container.scrollHeight > container.clientHeight) {
                container.style.paddingRight = '10px';
            }
        }

        window.addEventListener('load', initializeScrollbar);
        window.addEventListener('resize', initializeScrollbar);
    </script>
</asp:Content>