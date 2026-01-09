<%@ Page Title="Report Waste" Language="C#" MasterPageFile="~/Pages/Citizen/Site.Master"
    AutoEventWireup="True" Async="true" Inherits="SoorGreen.Admin.ReportWaste" CodeBehind="ReportWaste.aspx.cs" %>

<asp:Content ID="Content3" ContentPlaceHolderID="HeadContent" runat="server">
    <link href='<%= ResolveUrl("~/Content/Pages/Citizen/citizenreportwaste.css") %>' rel="stylesheet" />
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <asp:ScriptManager ID="smMain" runat="server" EnablePageMethods="true" />

    <!-- Hidden fields for AI data -->
    <asp:HiddenField ID="hfAICategory" runat="server" />
    <asp:HiddenField ID="hfAIWasteType" runat="server" />

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
                            <strong>Tip:</strong> You can also upload a photo in the next step and let AI automatically detect the waste type for you!
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
                    <p class="text-muted mb-4">Provide information about your waste submission. Upload a photo for AI classification or describe it.</p>

                    <div class="row">
                        <div class="col-lg-8">
                            <!-- IMAGE UPLOAD FOR AI -->
                            <div class="form-group-glass mb-4">
                                <label class="form-label"><i class="fas fa-camera me-2"></i>Upload Waste Image (Optional)</label>
                                <div class="input-group-glass">
                                    <asp:FileUpload ID="fuWasteImage" runat="server" CssClass="form-control"
                                        onchange="showImagePreview()" accept=".jpg,.jpeg,.png,.gif,.bmp" />
                                </div>
                                <small class="text-muted">Upload a photo of your waste for AI-assisted classification</small>

                                <!-- Image Preview -->
                                <div id="imagePreviewContainer" class="mt-3" style="display: none;">
                                    <img id="imagePreview" class="img-thumbnail" style="max-height: 150px;" />
                                </div>

                                <!-- AI Classification Button -->
                                <div id="aiClassifySection" class="mt-3" style="display: none;">
                                    <button type="button" class="btn btn-sm btn-primary" onclick="classifyWasteImage()">
                                        <i class="fas fa-robot me-1"></i>Auto-Classify with AI
                                    </button>
                                    <small class="text-muted ms-2">Let AI analyze the waste type from image</small>
                                </div>

                                <!-- AI Results -->
                                <div id="aiResults" class="mt-3" style="display: none;"></div>
                            </div>

                            <div class="form-group-glass mb-4">
                                <label class="form-label"><i class="fas fa-weight-hanging me-2"></i>Estimated Weight (kg) *</label>
                                <div class="input-group-glass">
                                    <asp:TextBox
                                        ID="txtWeight"
                                        runat="server"
                                        CssClass="form-control"
                                        AutoPostBack="true"
                                        OnTextChanged="txtWeight_TextChanged"
                                        placeholder="Enter weight (kg)">
                                    </asp:TextBox>
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
                                    <asp:TextBox
                                        ID="txtDescription"
                                        runat="server"
                                        TextMode="MultiLine"
                                        AutoPostBack="true"
                                        OnTextChanged="txtDescription_TextChanged"
                                        Rows="3"
                                        CssClass="form-control"
                                        placeholder="Describe your waste (e.g., 'plastic bottles', 'newspapers', 'food waste')" />
                                </div>
                                <small class="text-muted">Describe what you're recycling. AI can suggest waste type based on text too.</small>

                                <!-- AI Suggestions from Text -->
                                <asp:UpdatePanel ID="upAI" runat="server" UpdateMode="Conditional">
                                    <ContentTemplate>
                                        <div class="ai-suggestions-glass mb-4" id="textAISection" style="display: none;">
                                            <h5 class="mb-2 text-white"><i class="fas fa-robot me-2"></i>AI Text Analysis</h5>
                                            <div class="mb-2">
                                                <strong>Predicted Waste Type:</strong>
                                                <asp:Label ID="lblAIPredictedType" runat="server" CssClass="fw-bold text-white">-</asp:Label>
                                            </div>
                                            <div class="mb-2">
                                                <strong>Suggested Weight:</strong>
                                                <asp:Label ID="lblAIPredictedWeight" runat="server" CssClass="fw-bold text-success">- kg</asp:Label>
                                            </div>
                                            <div class="mb-2">
                                                <strong>Reward Estimation:</strong>
                                                <asp:Label ID="lblAIEstimatedReward" runat="server" CssClass="fw-bold text-success">- XP</asp:Label>
                                            </div>
                                            <asp:Button ID="btnUseAISuggestion" runat="server" CssClass="btn btn-outline-success btn-sm"
                                                Text="Use AI Suggestion" OnClick="btnUseAISuggestion_Click" />
                                        </div>
                                    </ContentTemplate>
                                    <Triggers>
                                        <asp:AsyncPostBackTrigger ControlID="txtDescription" EventName="TextChanged" />
                                    </Triggers>
                                </asp:UpdatePanel>

                                <!-- AI Validation Status -->
                                <div id="aiValidationStatus" class="mt-2" style="display: none;">
                                    <div class="alert alert-info">
                                        <div class="d-flex align-items-center">
                                            <i class="fas fa-spinner fa-spin me-2"></i>
                                            <div>
                                                <strong>AI Validation in Progress</strong>
                                                <div class="small">Checking report credibility...</div>
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <!-- AI Analysis Results (will be populated by JavaScript) -->
                                <div id="aiAnalysisResults" class="mt-3"></div>
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
                                        <asp:Label ID="lblAIUsed" runat="server" Text="" CssClass="badge bg-info ms-2" Visible="false">
                                            <i class="fas fa-robot me-1"></i>AI Detected
                                        </asp:Label>
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

    <!-- JavaScript for AI Image Classification - UPDATED FOR YOUR API FORMAT -->
    <script type="text/javascript">
        // Show image preview when file is selected
        function showImagePreview() {
            var fileUpload = document.getElementById('<%= fuWasteImage.ClientID %>');
            var previewContainer = document.getElementById('imagePreviewContainer');
            var preview = document.getElementById('imagePreview');
            var aiSection = document.getElementById('aiClassifySection');
            var aiResults = document.getElementById('aiResults');

            if (fileUpload.files && fileUpload.files[0]) {
                // Check file size (max 5MB)
                if (fileUpload.files[0].size > 5 * 1024 * 1024) {
                    alert('Image size should be less than 5MB.');
                    fileUpload.value = '';
                    return;
                }

                // Check file type
                var fileName = fileUpload.files[0].name.toLowerCase();
                if (!fileName.match(/\.(jpg|jpeg|png|gif|bmp)$/)) {
                    alert('Please upload a valid image file (JPG, PNG, GIF, BMP).');
                    fileUpload.value = '';
                    return;
                }

                var reader = new FileReader();
                reader.onload = function (e) {
                    preview.src = e.target.result;
                    previewContainer.style.display = 'block';
                    aiSection.style.display = 'block';

                    // Hide previous results
                    if (aiResults) {
                        aiResults.style.display = 'none';
                        aiResults.innerHTML = '';
                    }
                }
                reader.readAsDataURL(fileUpload.files[0]);
            } else {
                previewContainer.style.display = 'none';
                aiSection.style.display = 'none';
                if (aiResults) {
                    aiResults.style.display = 'none';
                    aiResults.innerHTML = '';
                }
            }
        }

        // AI Image Classification - FOR YOUR API RESPONSE FORMAT
        function classifyWasteImage() {
            var fileUpload = document.getElementById('<%= fuWasteImage.ClientID %>');
            if (!fileUpload.files || !fileUpload.files[0]) {
                alert('Please select an image first.');
                return;
            }

            // Show loading
            var aiResults = document.getElementById('aiResults');
            aiResults.innerHTML = '<div class="alert alert-info ai-loading">' +
                '<div class="text-center p-2">' +
                '   <div class="spinner-border spinner-border-sm me-2"></div>' +
                '   Analyzing waste image with AI...' +
                '</div>' +
                '</div>';
            aiResults.style.display = 'block';

            // Create FormData for Flask API
            var formData = new FormData();
            formData.append('image', fileUpload.files[0]);
            formData.append('filename', fileUpload.files[0].name);

            console.log('Sending request to AI API...');

            // Send to your Flask API
            fetch('http://127.0.0.1:5000/api/ai/classify-waste', {
                method: 'POST',
                body: formData,
                // Don't set Content-Type header for FormData - browser does it automatically
            })
                .then(response => {
                    console.log('Response received:', response.status, response.statusText);
                    if (!response.ok) {
                        return response.text().then(text => {
                            throw new Error(`API Error ${response.status}: ${text}`);
                        });
                    }
                    return response.json();
                })
                .then(data => {
                    console.log('API Response:', data);

                    if (data.status === 'ok' && data.result && data.result.status === 'success') {
                        // Process the detections from your API
                        processDetections(data.result.detections, fileUpload.files[0]);
                    } else {
                        onClassificationError(data.result?.error || 'Invalid response from AI service');
                    }
                })
                .catch(error => {
                    console.error('API Call Error:', error);
                    onClassificationError('Failed to connect to AI service: ' + error.message);
                });
        }

        // Process detections from API response
        function processDetections(detections, file) {
            if (!detections || detections.length === 0) {
                onClassificationError('No waste detected in the image');
                return;
            }

            // Sort detections by confidence (highest first)
            detections.sort((a, b) => b.confidence - a.confidence);

            // Get the top detection
            var topDetection = detections[0];
            var wasteType = mapAIClassToWasteType(topDetection.class);
            var confidence = topDetection.confidence;

            // Calculate estimated weight
            var estimatedWeight = calculateWeightFromDetections(detections, file);

            // Show all detections
            showDetectionResults(detections, wasteType, confidence, estimatedWeight);

            // Store data for later use
            var aiResults = document.getElementById('aiResults');
            aiResults.dataset.estimatedWeight = estimatedWeight;
            aiResults.dataset.wasteType = wasteType;
            aiResults.dataset.allDetections = JSON.stringify(detections);
        }

        // Map AI class names to waste type names
        function mapAIClassToWasteType(aiClass) {
            var mapping = {
                'plastic': 'Plastic',
                'paper': 'Paper',
                'metal': 'Metal',
                'glass': 'Glass',
                'organic': 'Organic',
                'food': 'Organic',
                'electronics': 'Electronics',
                'e-waste': 'Electronics',
                'textile': 'Textiles',
                'cloth': 'Textiles',
                'hazardous': 'Hazardous',
                'medical': 'Hazardous',
                'mixed': 'Mixed',
                'other': 'Mixed'
            };

            // Default to capitalized version if not in mapping
            return mapping[aiClass.toLowerCase()] ||
                aiClass.charAt(0).toUpperCase() + aiClass.slice(1);
        }

        // Calculate weight based on detections
        function calculateWeightFromDetections(detections, file) {
            // Use file size as base weight estimate
            var fileSizeMB = file.size / (1024 * 1024);
            var baseWeight = 1.0;

            if (fileSizeMB < 0.3) baseWeight = 0.5;
            else if (fileSizeMB < 0.6) baseWeight = 1.0;
            else if (fileSizeMB < 1.2) baseWeight = 2.0;
            else if (fileSizeMB < 2.5) baseWeight = 5.0;
            else baseWeight = 10.0;

            // Adjust based on detection confidence
            var topConfidence = detections[0].confidence;
            var adjustedWeight = baseWeight * (0.5 + topConfidence * 0.5);

            return Math.max(0.5, Math.min(20, adjustedWeight)); // Clamp between 0.5-20kg
        }

        // Show detection results
        function showDetectionResults(detections, primaryType, confidence, estimatedWeight) {
            var aiResults = document.getElementById('aiResults');

            // Create HTML for all detections
            var detectionsHTML = '';
            detections.forEach((detection, index) => {
                var wasteType = mapAIClassToWasteType(detection.class);
                var confidencePercent = Math.round(detection.confidence * 100);
                var isPrimary = index === 0;

                detectionsHTML += '<div class="detection-row ' + (isPrimary ? 'primary-detection' : '') + '">' +
                    '<div class="d-flex justify-content-between align-items-center">' +
                    '<span>' + wasteType + '</span>' +
                    '<div class="d-flex align-items-center">' +
                    '<div class="confidence-bar me-2" style="width: 100px;">' +
                    '<div class="confidence-fill" style="width: ' + confidencePercent + '%;"></div>' +
                    '</div>' +
                    '<span class="confidence-value">' + confidencePercent + '%</span>' +
                    '</div>' +
                    '</div>' +
                    '</div>';
            });

            aiResults.innerHTML = '<div class="alert alert-success ai-success">' +
                '<h6><i class="fas fa-robot me-2"></i> AI Waste Detection Results</h6>' +
                '<div class="mt-3">' +
                '<div class="primary-result mb-3 p-3 bg-light rounded">' +
                '<div class="d-flex justify-content-between align-items-center">' +
                '<div>' +
                '<h5 class="mb-1">Primary Detection</h5>' +
                '<div class="d-flex align-items-center">' +
                '<span class="badge bg-primary me-2">' + primaryType + '</span>' +
                '<span class="text-muted">' + Math.round(confidence * 100) + '% confidence</span>' +
                '</div>' +
                '</div>' +
                '<div class="text-end">' +
                '<div class="estimated-weight h4 text-success mb-0">' + estimatedWeight.toFixed(1) + ' kg</div>' +
                '<small class="text-muted">Estimated weight</small>' +
                '</div>' +
                '</div>' +
                '</div>' +

                '<div class="all-detections mt-3">' +
                '<h6 class="mb-2">All Detections:</h6>' +
                '<div class="detections-list">' + detectionsHTML + '</div>' +
                '</div>' +

                '<div class="mt-4">' +
                '<button type="button" class="btn btn-success me-2" onclick="applyAIResultsWithWeight(' + estimatedWeight + ', \'' + primaryType + '\')">' +
                '<i class="fas fa-check me-1"></i> Apply Primary Detection' +
                '</button>' +
                '<button type="button" class="btn btn-outline-secondary me-2" onclick="showAllWasteTypeOptions()">' +
                '<i class="fas fa-list me-1"></i> Choose Different Type' +
                '</button>' +
                '<button type="button" class="btn btn-outline-secondary" onclick="ignoreAIResults()">' +
                '<i class="fas fa-times me-1"></i> Ignore All' +
                '</button>' +
                '</div>' +
                '</div>' +
                '</div>';

            aiResults.classList.add('ai-highlight');
            aiResults.style.display = 'block';
        }

        // Show all waste type options from detections
        function showAllWasteTypeOptions() {
            var aiResults = document.getElementById('aiResults');
            var detections = JSON.parse(aiResults.dataset.allDetections || '[]');
            var estimatedWeight = parseFloat(aiResults.dataset.estimatedWeight) || 1.0;

            if (detections.length === 0) return;

            var optionsHTML = '';
            detections.forEach((detection, index) => {
                var wasteType = mapAIClassToWasteType(detection.class);
                var confidencePercent = Math.round(detection.confidence * 100);

                optionsHTML += '<div class="option-card p-3 mb-2 border rounded">' +
                    '<div class="d-flex justify-content-between align-items-center">' +
                    '<div>' +
                    '<h6 class="mb-1">' + wasteType + '</h6>' +
                    '<small class="text-muted">AI Confidence: ' + confidencePercent + '%</small>' +
                    '</div>' +
                    '<div>' +
                    '<button type="button" class="btn btn-sm btn-outline-primary" ' +
                    'onclick="applyAIResultsWithWeight(' + estimatedWeight + ', \'' + wasteType + '\')">' +
                    'Select' +
                    '</button>' +
                    '</div>' +
                    '</div>' +
                    '</div>';
            });

            aiResults.innerHTML = '<div class="alert alert-info">' +
                '<h6><i class="fas fa-th-list me-2"></i> Select Waste Type</h6>' +
                '<div class="mt-3">' +
                '<p>Choose from AI detections:</p>' +
                '<div class="options-list">' + optionsHTML + '</div>' +
                '<div class="mt-3">' +
                '<button type="button" class="btn btn-sm btn-outline-secondary" onclick="classifyWasteImage()">' +
                '<i class="fas fa-arrow-left me-1"></i> Back to Results' +
                '</button>' +
                '</div>' +
                '</div>' +
                '</div>';
        }

        // Apply AI results WITH WEIGHT
        function applyAIResultsWithWeight(estimatedWeight, wasteType) {
            console.log('Applying AI results:', { weight: estimatedWeight, type: wasteType });

            // 1. Set the weight in the textbox
            var weightInput = document.getElementById('<%= txtWeight.ClientID %>');
            if (weightInput && estimatedWeight) {
                weightInput.value = estimatedWeight.toFixed(1);

                // Trigger ASP.NET TextChanged event
                __doPostBack('<%= txtWeight.ClientID %>', '');
            }

            // 2. Select the waste type
            if (wasteType) {
                selectWasteTypeByAI(wasteType);
            }

            // 3. Update UI feedback
            var aiResults = document.getElementById('aiResults');
            aiResults.innerHTML = '<div class="alert alert-success">' +
                '<div class="d-flex align-items-center">' +
                '<i class="fas fa-check-circle fa-2x text-success me-3"></i>' +
                '<div>' +
                '<h5 class="mb-1">✓ AI Suggestions Applied</h5>' +
                '<p class="mb-0">' +
                'Weight: <strong>' + estimatedWeight.toFixed(1) + ' kg</strong> | ' +
                'Type: <strong>' + wasteType + '</strong>' +
                '</p>' +
                '</div>' +
                '</div>' +
                '</div>';

            // 4. Show success message
            showMessage('✓ AI applied: ' + wasteType + ' (' + estimatedWeight.toFixed(1) + ' kg)', 'success');

            // 5. Mark AI as used in hidden field
            document.getElementById('<%= hfAICategory.ClientID %>').value = 'ai_used_' + wasteType.toLowerCase();

            // 6. Auto-advance to next step after 2 seconds
            setTimeout(function () {
                var nextButton = document.getElementById('<%= btnNextStep2.ClientID %>');
                if (nextButton && !nextButton.disabled) {
                    // Uncomment to auto-advance
                    // nextButton.click();
                }
            }, 2000);
        }

        // Helper function to select waste type by name
        function selectWasteTypeByAI(wasteTypeName) {
            console.log('Selecting waste type:', wasteTypeName);

            var wasteCards = document.querySelectorAll('.waste-type-select');
            var found = false;
            var cleanWasteType = wasteTypeName.toLowerCase().trim();

            // First pass: exact match
            wasteCards.forEach(function (card) {
                var cardText = (card.textContent || card.innerText).toLowerCase();
                if (cardText.includes(cleanWasteType)) {
                    card.click();
                    found = true;
                    highlightCard(card);
                }
            });

            // Second pass: keyword match
            if (!found) {
                wasteCards.forEach(function (card) {
                    var cardText = (card.textContent || card.innerText).toLowerCase();
                    var keywords = {
                        'plastic': ['plastic', 'bottle', 'container'],
                        'paper': ['paper', 'cardboard', 'newspaper'],
                        'metal': ['metal', 'can', 'aluminum'],
                        'glass': ['glass', 'bottle', 'jar'],
                        'organic': ['organic', 'food', 'compost'],
                        'electronics': ['electronic', 'battery', 'e-waste'],
                        'mixed': ['mixed', 'general', 'other']
                    };

                    for (var key in keywords) {
                        if (cleanWasteType.includes(key) ||
                            keywords[key].some(word => cleanWasteType.includes(word))) {
                            if (cardText.includes(key)) {
                                card.click();
                                found = true;
                                highlightCard(card);
                                break;
                            }
                        }
                    }
                });
            }

            return found;
        }

        function highlightCard(card) {
            var cardElement = card.closest('.category-card-glass');
            if (cardElement) {
                cardElement.classList.add('selected');
                cardElement.style.boxShadow = '0 0 20px rgba(40, 167, 69, 0.5)';
                cardElement.style.transform = 'translateY(-5px)';
                setTimeout(function () {
                    cardElement.style.boxShadow = '';
                    cardElement.style.transform = '';
                }, 2000);
            }
        }

        // Test API connection
        function testAIConnection() {
            showMessage('Testing AI API connection...', 'info');

            fetch('http://127.0.0.1:5000/api/health', {
                method: 'GET'
            })
                .then(response => response.json())
                .then(data => {
                    showMessage('✓ AI API is running: ' + (data.status || 'Connected'), 'success');
                })
                .catch(error => {
                    showMessage('✗ Cannot connect to AI API. Make sure Flask is running on port 5000.', 'error');
                });
        }

        // Error callback
        function onClassificationError(error) {
            var aiResults = document.getElementById('aiResults');
            aiResults.innerHTML = '<div class="alert alert-danger ai-error">' +
                '<i class="fas fa-exclamation-triangle me-2"></i> ' + error +
                '<div class="mt-3">' +
                '<button type="button" class="btn btn-sm btn-warning me-2" onclick="testAIConnection()">' +
                '<i class="fas fa-wifi me-1"></i> Test Connection' +
                '</button>' +
                '<button type="button" class="btn btn-sm btn-outline-info" onclick="useMockDetection()">' +
                '<i class="fas fa-magic me-1"></i> Use Mock Detection' +
                '</button>' +
                '</div>' +
                '</div>';
        }

        // Mock detection for testing
        function useMockDetection() {
            var fileUpload = document.getElementById('<%= fuWasteImage.ClientID %>');

            // Mock response matching your API format
            var mockResponse = {
                status: 'ok',
                result: {
                    status: 'success',
                    detections: [
                        { class: 'plastic', confidence: 0.85 },
                        { class: 'metal', confidence: 0.65 },
                        { class: 'paper', confidence: 0.45 }
                    ]
                }
            };

            processDetections(mockResponse.result.detections, fileUpload.files[0]);
        }

        // Ignore AI results
        function ignoreAIResults() {
            var aiResults = document.getElementById('aiResults');
            aiResults.innerHTML = '<div class="alert alert-secondary">' +
                '<i class="fas fa-info-circle me-2"></i> AI suggestions ignored. Please select waste type manually.' +
                '</div>';
        }

        // Show message function
        function showMessage(message, type) {
            var messagePanel = document.querySelector('.message-panel');
            if (messagePanel) {
                var icon = type === 'success' ? 'check-circle' :
                    type === 'error' ? 'exclamation-circle' :
                        type === 'warning' ? 'exclamation-triangle' : 'info-circle';

                messagePanel.innerHTML =
                    '<div class="message-alert ' + type + ' show">' +
                    '    <i class="fas fa-' + icon + '"></i>' +
                    '    <div>' +
                    '        <strong>' + type.toUpperCase() + '</strong>' +
                    '        <p class="mb-0">' + message + '</p>' +
                    '    </div>' +
                    '</div>';
                messagePanel.style.display = 'block';
                setTimeout(function () {
                    messagePanel.style.display = 'none';
                }, 5000);
            }
        }

        // Initialize when page loads
        document.addEventListener('DOMContentLoaded', function () {
            console.log('Waste AI Classification initialized');

            // Attach file upload handler
            var fileUpload = document.getElementById('<%= fuWasteImage.ClientID %>');
            if (fileUpload) {
                fileUpload.onchange = showImagePreview;
            }

            // Add CSS for detection results
            var style = document.createElement('style');
            style.textContent = `
            .ai-loading {
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                color: white;
                border: none;
            }
            .ai-success {
                animation: fadeIn 0.5s ease;
                border-left: 4px solid #28a745;
            }
            .ai-error {
                animation: fadeIn 0.5s ease;
                border-left: 4px solid #dc3545;
            }
            .ai-highlight {
                animation: pulse 2s infinite;
            }
            .detection-row {
                padding: 8px 12px;
                margin-bottom: 8px;
                background: rgba(0,0,0,0.03);
                border-radius: 6px;
                border-left: 3px solid #6c757d;
            }
            .detection-row.primary-detection {
                background: rgba(40, 167, 69, 0.1);
                border-left-color: #28a745;
            }
            .confidence-bar {
                height: 6px;
                background: #e9ecef;
                border-radius: 3px;
                overflow: hidden;
            }
            .confidence-fill {
                height: 100%;
                background: linear-gradient(90deg, #28a745, #20c997);
                transition: width 1s ease;
            }
            .confidence-value {
                font-size: 0.85rem;
                color: #6c757d;
                min-width: 40px;
                text-align: right;
            }
            .primary-result {
                background: linear-gradient(135deg, rgba(40, 167, 69, 0.1), rgba(32, 201, 151, 0.1));
                border: 1px solid rgba(40, 167, 69, 0.2);
            }
            .option-card {
                transition: all 0.3s ease;
            }
            .option-card:hover {
                transform: translateY(-2px);
                box-shadow: 0 5px 15px rgba(0,0,0,0.1);
                border-color: #007bff;
            }
            @keyframes fadeIn {
                from { opacity: 0; transform: translateY(-10px); }
                to { opacity: 1; transform: translateY(0); }
            }
            @keyframes pulse {
                0% { box-shadow: 0 0 0 0 rgba(40, 167, 69, 0.4); }
                70% { box-shadow: 0 0 0 10px rgba(40, 167, 69, 0); }
                100% { box-shadow: 0 0 0 0 rgba(40, 167, 69, 0); }
            }
        `;
            document.head.appendChild(style);

            // Add test button
            var aiSection = document.getElementById('aiClassifySection');
            if (aiSection) {
                var testBtn = document.createElement('button');
                testBtn.type = 'button';
                testBtn.className = 'btn btn-sm btn-outline-info mt-2';
                testBtn.innerHTML = '<i class="fas fa-vial me-1"></i> Test AI Connection';
                testBtn.onclick = testAIConnection;
                aiSection.appendChild(testBtn);
            }
        });
    </script>

    <script>
        addEventListener('DOMContentLoaded', function () {
            const btnAI = document.getElementById('<%= btnUseAISuggestion.ClientID %>');
            if (btnAI) {
                btnAI.addEventListener('mouseover', function () {
                    this.classList.add('btn-glow');
                });
                btnAI.addEventListener('mouseout', function () {
                    this.classList.remove('btn-glow');
                });
            }
        });
        // Ensure global functions exist
        if (typeof showDatabaseConfirmation === 'undefined') {
            window.showDatabaseConfirmation = function () {
                var successCard = document.querySelector('.success-card-glass');
                if (successCard) {
                    successCard.style.animation = 'none';
                    setTimeout(function () {
                        successCard.style.animation = 'pulse 2s infinite';
                    }, 10);
                }
            };
        }

        if (typeof updateProgressSteps === 'undefined') {
            window.updateProgressSteps = function (currentStep) {
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
        window.selectWasteTypeSafe = function (wasteName) {
            try {
                var wasteCards = document.querySelectorAll('.category-card-glass');
                wasteCards.forEach(function (card) {
                    card.classList.remove('selected');
                });

                var selectedCards = document.querySelectorAll('.waste-type-select');
                selectedCards.forEach(function (card) {
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
        document.addEventListener('DOMContentLoaded', function () {
            // Make sure message panel exists
            if (!document.querySelector('.message-panel')) {
                var messagePanel = document.createElement('div');
                messagePanel.className = 'message-panel';
                document.body.appendChild(messagePanel);
            }

            // Add keyboard shortcuts
            document.addEventListener('keydown', function (e) {
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
