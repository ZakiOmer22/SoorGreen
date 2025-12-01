<%@ Page Title="Report Waste" Language="C#" MasterPageFile="~/Pages/Citizen/Site.Master" AutoEventWireup="true" CodeFile="ReportWaste.aspx.cs" Inherits="SoorGreen.Admin.ReportWaste" %>
<%@ Import Namespace="System.Web.Optimization" %>
<asp:Content ID="Content3" ContentPlaceHolderID="HeadContent" runat="server">
    <%: Styles.Render("~/Content/citizenreportwaste") %>
</asp:Content>
<asp:Content ID="Content4" ContentPlaceHolderID="ScriptsContent" runat="server">
    <%: Scripts.Render("~/bundles/citizenreportwaste") %>
</asp:Content>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Report Waste - SoorGreen Citizen
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    
    <div class="report-container">
        <br />
        <br />
        <br />

        <!-- Statistics Cards -->
        <div class="stats-cards">
            <div class="stat-card">
                <div class="stat-value" id="totalReports">24</div>
                <div class="stat-label">Total Reports</div>
            </div>
            <div class="stat-card">
                <div class="stat-value" id="totalRewards">380</div>
                <div class="stat-label">Total XP Earned</div>
            </div>
            <div class="stat-card">
                <div class="stat-value" id="avgWeight">15.6</div>
                <div class="stat-label">Avg Weight (kg)</div>
            </div>
            <div class="stat-card">
                <div class="stat-value" id="successRate">100%</div>
                <div class="stat-label">Success Rate</div>
            </div>
        </div>

        <!-- Page Header -->
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h1 style="color: #ffffff !important; margin: 0;">Report Waste</h1>
                <p class="text-muted mb-0">Submit waste for collection and earn XP rewards</p>
            </div>
            <div class="badge bg-primary px-3 py-2 rounded-pill">
                <i class="fas fa-coins me-2"></i>
                Earn up to
                <asp:Literal ID="litMaxReward" runat="server" Text="50" />
                XP
            </div>
        </div>

        <!-- Step Indicator -->
        <div class="step-indicator">
            <div class="step active" id="step1">
                <div class="step-circle">1</div>
                <div class="step-label">Waste Type</div>
            </div>
            <div class="step" id="step2">
                <div class="step-circle">2</div>
                <div class="step-label">Details</div>
            </div>
            <div class="step" id="step3">
                <div class="step-circle">3</div>
                <div class="step-label">Location</div>
            </div>
            <div class="step" id="step4">
                <div class="step-circle">4</div>
                <div class="step-label">Review</div>
            </div>
        </div>

        <!-- Step 1: Waste Type Selection -->
        <div class="form-step active" id="step1Form">
            <div class="form-section">
                <h4 class="fw-bold mb-4 text-light">Select Waste Type</h4>
                <p class="text-muted mb-4">Choose the type of waste you want to report for collection</p>

                <div class="row g-3">
                    <div class="col-md-4">
                        <div class="waste-type-card" data-type="plastic">
                            <div class="waste-icon text-primary">
                                <i class="fas fa-wine-bottle"></i>
                            </div>
                            <h5 class="fw-bold text-light">Plastic</h5>
                            <p class="text-muted small mb-2">Bottles, containers, packaging</p>
                            <div class="badge bg-primary">5 XP/kg</div>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="waste-type-card" data-type="paper">
                            <div class="waste-icon text-warning">
                                <i class="fas fa-newspaper"></i>
                            </div>
                            <h5 class="fw-bold text-light">Paper</h5>
                            <p class="text-muted small mb-2">Newspapers, cardboard, office paper</p>
                            <div class="badge bg-warning">3 XP/kg</div>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="waste-type-card" data-type="glass">
                            <div class="waste-icon text-success">
                                <i class="fas fa-wine-bottle"></i>
                            </div>
                            <h5 class="fw-bold text-light">Glass</h5>
                            <p class="text-muted small mb-2">Bottles, jars, containers</p>
                            <div class="badge bg-success">4 XP/kg</div>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="waste-type-card" data-type="metal">
                            <div class="waste-icon text-info">
                                <i class="fas fa-cube"></i>
                            </div>
                            <h5 class="fw-bold text-light">Metal</h5>
                            <p class="text-muted small mb-2">Cans, foil, containers</p>
                            <div class="badge bg-info">6 XP/kg</div>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="waste-type-card" data-type="ewaste">
                            <div class="waste-icon text-danger">
                                <i class="fas fa-laptop"></i>
                            </div>
                            <h5 class="fw-bold text-light">E-Waste</h5>
                            <p class="text-muted small mb-2">Electronics, batteries, devices</p>
                            <div class="badge bg-danger">8 XP/kg</div>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="waste-type-card" data-type="organic">
                            <div class="waste-icon text-success">
                                <i class="fas fa-leaf"></i>
                            </div>
                            <h5 class="fw-bold text-light">Organic</h5>
                            <p class="text-muted small mb-2">Food waste, garden waste</p>
                            <div class="badge bg-success">2 XP/kg</div>
                        </div>
                    </div>
                </div>

                <asp:HiddenField ID="hdnWasteType" runat="server" />
                <asp:HiddenField ID="hdnWasteTypeId" runat="server" />
            </div>

            <div class="text-end">
                <button type="button" class="btn-navigation" onclick="nextStep(2)">
                    Next <i class="fas fa-arrow-right ms-2"></i>
                </button>
            </div>
        </div>

        <!-- Step 2: Waste Details -->
        <div class="form-step" id="step2Form">
            <div class="form-section">
                <h4 class="fw-bold mb-4 text-light">Waste Details</h4>

                <div class="row g-3">
                    <div class="col-md-6">
                        <div class="form-group">
                            <label class="form-label">Estimated Weight</label>
                            <div class="weight-input">
                                <asp:TextBox ID="txtWeight" runat="server" CssClass="form-control"
                                    placeholder="Enter weight" TextMode="Number" step="0.1" min="0.1" max="1000" />
                                <div class="weight-unit">kg</div>
                            </div>
                            <div class="form-text">
                                Estimated weight in kilograms. Collector will verify actual weight.
                            </div>
                        </div>
                    </div>

                    <div class="col-md-6">
                        <div class="form-group">
                            <label class="form-label">Description</label>
                            <asp:TextBox ID="txtDescription" runat="server" CssClass="form-control"
                                placeholder="Brief description of the waste" TextMode="MultiLine" Rows="3" />
                        </div>
                    </div>

                    <div class="col-12">
                        <div class="form-group">
                            <label class="form-label">Upload Photo (Optional)</label>
                            <div class="photo-upload-area" onclick="document.getElementById('<%= filePhoto.ClientID %>').click()">
                                <i class="fas fa-camera fa-2x text-muted mb-3"></i>
                                <p class="text-muted mb-2">Click to upload waste photo</p>
                                <small class="text-muted">Supports JPG, PNG - Max 5MB</small>
                                <asp:FileUpload ID="filePhoto" runat="server" Style="display: none;" onchange="previewPhoto(this)" />
                            </div>
                            <img id="photoPreview" class="photo-preview mt-3" />
                        </div>
                    </div>
                </div>
            </div>

            <div class="d-flex justify-content-between">
                <button type="button" class="btn-outline-light" onclick="prevStep(1)">
                    <i class="fas fa-arrow-left me-2"></i>Back
                </button>
                <button type="button" class="btn-navigation" onclick="nextStep(3)">
                    Next <i class="fas fa-arrow-right ms-2"></i>
                </button>
            </div>
        </div>

        <!-- Step 3: Location -->
        <div class="form-step" id="step3Form">
            <div class="form-section">
                <h4 class="fw-bold mb-4 text-light">Collection Location</h4>

                <div class="row g-3">
                    <div class="col-12">
                        <div class="form-group">
                            <label class="form-label">Full Address</label>
                            <asp:TextBox ID="txtAddress" runat="server" CssClass="form-control"
                                placeholder="Enter your complete address" TextMode="MultiLine" Rows="2" />
                        </div>
                    </div>

                    <div class="col-md-6">
                        <div class="form-group">
                            <label class="form-label">Landmark (Optional)</label>
                            <asp:TextBox ID="txtLandmark" runat="server" CssClass="form-control"
                                placeholder="Nearby landmark for easy identification" />
                        </div>
                    </div>

                    <div class="col-md-6">
                        <div class="form-group">
                            <label class="form-label">Collection Instructions</label>
                            <asp:TextBox ID="txtInstructions" runat="server" CssClass="form-control"
                                placeholder="Special instructions for collector" />
                        </div>
                    </div>

                    <div class="col-12">
                        <div class="form-check mb-3">
                            <asp:CheckBox ID="chkUseCurrentLocation" runat="server" CssClass="form-check-input" />
                            <label class="form-check-label" for="<%= chkUseCurrentLocation.ClientID %>">
                                Use my current location
                            </label>
                        </div>
                    </div>

                    <div class="col-12">
                        <div class="location-preview">
                            <div class="map-placeholder">
                                <div class="map-placeholder-icon">
                                    <i class="fas fa-map-marked-alt"></i>
                                </div>
                                <h5 class="text-light mb-2">Google Maps Location</h5>
                                <p class="text-muted">Location services will be enabled here</p>
                                <button type="button" class="btn-outline-light mt-2" onclick="simulateLocation()">
                                    <i class="fas fa-location-arrow me-2"></i>Set Current Location
                                </button>
                            </div>
                        </div>
                    </div>

                    <!-- Hidden fields for coordinates -->
                    <asp:HiddenField ID="hdnLatitude" runat="server" Value="" />
                    <asp:HiddenField ID="hdnLongitude" runat="server" Value="" />
                </div>
            </div>

            <div class="d-flex justify-content-between">
                <button type="button" class="btn-outline-light" onclick="prevStep(2)">
                    <i class="fas fa-arrow-left me-2"></i>Back
                </button>
                <button type="button" class="btn-navigation" onclick="nextStep(4)">
                    Next <i class="fas fa-arrow-right ms-2"></i>
                </button>
            </div>
        </div>

        <!-- Step 4: Review & Submit -->
        <div class="form-step" id="step4Form">
            <div class="form-section">
                <h4 class="fw-bold mb-4 text-light">Review & Submit</h4>

                <div class="table-responsive">
                    <table class="review-table">
                        <thead>
                            <tr>
                                <th>Category</th>
                                <th>Details</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr>
                                <td><strong>Waste Type</strong></td>
                                <td id="reviewWasteType">-</td>
                            </tr>
                            <tr>
                                <td><strong>Estimated Weight</strong></td>
                                <td id="reviewWeight">-</td>
                            </tr>
                            <tr>
                                <td><strong>Description</strong></td>
                                <td id="reviewDescription">-</td>
                            </tr>
                            <tr>
                                <td><strong>Address</strong></td>
                                <td id="reviewAddress">-</td>
                            </tr>
                            <tr>
                                <td><strong>Landmark</strong></td>
                                <td id="reviewLandmark">-</td>
                            </tr>
                            <tr>
                                <td><strong>Instructions</strong></td>
                                <td id="reviewInstructions">-</td>
                            </tr>
                            <tr>
                                <td><strong>Location</strong></td>
                                <td id="reviewCoordinates">-</td>
                            </tr>
                        </tbody>
                    </table>
                </div>

                <div class="reward-preview mt-4">
                    <h5 class="fw-bold text-dark mb-2">Estimated Reward</h5>
                    <div class="display-6 fw-bold text-dark" id="estimatedReward">0 XP</div>
                    <p class="text-dark mb-0">Points will be awarded after collection verification</p>
                </div>
            </div>

            <div class="d-flex justify-content-between">
                <button type="button" class="btn-outline-light" onclick="prevStep(3)">
                    <i class="fas fa-arrow-left me-2"></i>Back
                </button>
                <asp:Button ID="btnSubmitReport" runat="server" Text="Submit Report"
                    CssClass="btn-navigation" OnClick="btnSubmitReport_Click"
                    OnClientClick="return validateFinalSubmission();" />
            </div>
        </div>
    </div>

    
</asp:Content>
