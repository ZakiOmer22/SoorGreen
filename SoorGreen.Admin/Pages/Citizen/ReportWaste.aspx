<%@ Page Title="Report Waste" Language="C#" MasterPageFile="~/Pages/Citizen/Site.Master" 
    AutoEventWireup="true" CodeFile="ReportWaste.aspx.cs" Inherits="SoorGreen.Admin.ReportWaste" %>

<asp:Content ID="Content3" ContentPlaceHolderID="HeadContent" runat="server">
    <link href='<%= ResolveUrl("~/Content/Pages/Citizen/citizenreportwaste.css") %>' rel="stylesheet" />
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
    <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
</asp:Content>

<asp:Content ID="Content4" ContentPlaceHolderID="ScriptsContent" runat="server">
    <script src='<%= ResolveUrl("~/Scripts/Pages/Citizen/citizenreportwaste.js") %>'></script>
</asp:Content>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Report Waste - SoorGreen Citizen
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <br />
    <br />
    <br />
    <div class="report-waste-container">
        <!-- Header with Breadcrumbs -->
        <div class="page-header-wrapper">
            <nav class="breadcrumb">
                <a href="Dashboard.aspx"><i class="fas fa-home"></i> Dashboard</a>
                <i class="fas fa-chevron-right"></i>
                <span class="active">Report Waste</span>
            </nav>
            
            <div class="header-main">
                <div class="header-text">
                    <h1 class="page-title">
                        <i class="fas fa-recycle"></i>
                        Report Waste Collection
                    </h1>
                    <p class="page-subtitle">Submit waste for collection and earn eco-rewards</p>
                </div>
                
                <div class="header-action">
                    <div class="reward-estimate">
                        <div class="reward-badge">
                            <i class="fas fa-trophy"></i>
                            <div class="reward-info">
                                <span class="reward-label">Potential Reward</span>
                                <span class="reward-value" id="potentialReward">0 XP</span>
                            </div>
                        </div>
                        <button class="btn-help" onclick="showHelp()">
                            <i class="fas fa-question-circle"></i>
                        </button>
                    </div>
                </div>
            </div>
        </div>

        <!-- Progress Indicator -->
        <div class="progress-tracker">
            <div class="progress-steps">
                <div class="progress-step active" data-step="1">
                    <div class="step-icon">
                        <i class="fas fa-layer-group"></i>
                    </div>
                    <div class="step-info">
                        <span class="step-label">Waste Type</span>
                        <span class="step-desc">Select Category</span>
                    </div>
                </div>
                
                <div class="progress-line"></div>
                
                <div class="progress-step" data-step="2">
                    <div class="step-icon">
                        <i class="fas fa-info-circle"></i>
                    </div>
                    <div class="step-info">
                        <span class="step-label">Details</span>
                        <span class="step-desc">Weight & Photo</span>
                    </div>
                </div>
                
                <div class="progress-line"></div>
                
                <div class="progress-step" data-step="3">
                    <div class="step-icon">
                        <i class="fas fa-map-marker-alt"></i>
                    </div>
                    <div class="step-info">
                        <span class="step-label">Location</span>
                        <span class="step-desc">Pickup Address</span>
                    </div>
                </div>
                
                <div class="progress-line"></div>
                
                <div class="progress-step" data-step="4">
                    <div class="step-icon">
                        <i class="fas fa-check-circle"></i>
                    </div>
                    <div class="step-info">
                        <span class="step-label">Review</span>
                        <span class="step-desc">Confirm & Submit</span>
                    </div>
                </div>
            </div>
            
            <div class="progress-bar-container">
                <div class="progress-bar">
                    <div class="progress-fill" id="progressFill" style="width: 25%"></div>
                </div>
                <div class="progress-text">Step <span id="currentStep">1</span> of 4</div>
            </div>
        </div>

        <!-- Main Form Content -->
        <div class="form-wrapper">
            <!-- Step 1: Waste Type Selection -->
            <div class="form-step active" id="step1">
                <div class="step-header">
                    <h2><span class="step-number">01</span> Select Waste Category</h2>
                    <p>Choose the type of waste you want to submit for collection</p>
                </div>
                
                <div class="category-grid">
                    <div class="category-card" data-type="plastic" onclick="selectCategory('plastic', 'WT01', 'Plastic', 5)">
                        <div class="category-icon bg-primary">
                            <i class="fas fa-wine-bottle"></i>
                        </div>
                        <div class="category-content">
                            <h4>Plastic Waste</h4>
                            <p>Bottles, containers, packaging materials</p>
                            <div class="category-footer">
                                <span class="reward-rate">5 XP/kg</span>
                                <span class="category-count">Most Common</span>
                            </div>
                        </div>
                        <div class="selection-indicator">
                            <i class="fas fa-check"></i>
                        </div>
                    </div>
                    
                    <div class="category-card" data-type="paper" onclick="selectCategory('paper', 'WT02', 'Paper', 3)">
                        <div class="category-icon bg-warning">
                            <i class="fas fa-newspaper"></i>
                        </div>
                        <div class="category-content">
                            <h4>Paper & Cardboard</h4>
                            <p>Newspapers, magazines, cartons</p>
                            <div class="category-footer">
                                <span class="reward-rate">3 XP/kg</span>
                                <span class="category-count">Biodegradable</span>
                            </div>
                        </div>
                        <div class="selection-indicator">
                            <i class="fas fa-check"></i>
                        </div>
                    </div>
                    
                    <div class="category-card" data-type="glass" onclick="selectCategory('glass', 'WT03', 'Glass', 4)">
                        <div class="category-icon bg-success">
                            <i class="fas fa-glass-whiskey"></i>
                        </div>
                        <div class="category-content">
                            <h4>Glass</h4>
                            <p>Bottles, jars, broken glass</p>
                            <div class="category-footer">
                                <span class="reward-rate">4 XP/kg</span>
                                <span class="category-count">Recyclable</span>
                            </div>
                        </div>
                        <div class="selection-indicator">
                            <i class="fas fa-check"></i>
                        </div>
                    </div>
                    
                    <div class="category-card" data-type="metal" onclick="selectCategory('metal', 'WT04', 'Metal', 6)">
                        <div class="category-icon bg-info">
                            <i class="fas fa-cogs"></i>
                        </div>
                        <div class="category-content">
                            <h4>Metal</h4>
                            <p>Cans, wires, metal scraps</p>
                            <div class="category-footer">
                                <span class="reward-rate">6 XP/kg</span>
                                <span class="category-count">High Value</span>
                            </div>
                        </div>
                        <div class="selection-indicator">
                            <i class="fas fa-check"></i>
                        </div>
                    </div>
                    
                    <div class="category-card" data-type="ewaste" onclick="selectCategory('ewaste', 'WT05', 'E-Waste', 8)">
                        <div class="category-icon bg-danger">
                            <i class="fas fa-laptop"></i>
                        </div>
                        <div class="category-content">
                            <h4>E-Waste</h4>
                            <p>Electronics, batteries, devices</p>
                            <div class="category-footer">
                                <span class="reward-rate">8 XP/kg</span>
                                <span class="category-count">Special Handling</span>
                            </div>
                        </div>
                        <div class="selection-indicator">
                            <i class="fas fa-check"></i>
                        </div>
                    </div>
                    
                    <div class="category-card" data-type="organic" onclick="selectCategory('organic', 'WT06', 'Organic', 2)">
                        <div class="category-icon bg-organic">
                            <i class="fas fa-leaf"></i>
                        </div>
                        <div class="category-content">
                            <h4>Organic Waste</h4>
                            <p>Food scraps, garden waste</p>
                            <div class="category-footer">
                                <span class="reward-rate">2 XP/kg</span>
                                <span class="category-count">Compostable</span>
                            </div>
                        </div>
                        <div class="selection-indicator">
                            <i class="fas fa-check"></i>
                        </div>
                    </div>
                </div>
                
                <asp:HiddenField ID="hdnWasteType" runat="server" />
                <asp:HiddenField ID="hdnWasteTypeId" runat="server" />
                
                <div class="step-navigation">
                    <button type="button" class="btn btn-next" onclick="nextStep(2)">
                        Continue to Details
                        <i class="fas fa-arrow-right"></i>
                    </button>
                </div>
            </div>

            <!-- Step 2: Waste Details -->
            <div class="form-step" id="step2">
                <div class="step-header">
                    <h2><span class="step-number">02</span> Waste Details</h2>
                    <p>Provide information about your waste submission</p>
                </div>
                
                <div class="details-grid">
                    <div class="detail-card">
                        <h3><i class="fas fa-weight-hanging"></i> Weight Estimation</h3>
                        <div class="weight-input-group">
                            <div class="weight-input">
                                <asp:TextBox ID="txtWeight" runat="server" CssClass="form-control" 
                                    placeholder="0.0" TextMode="Number" step="0.1" min="0.1" />
                                <span class="input-unit">kg</span>
                            </div>
                            <div class="weight-examples">
                                <small>Examples: 0.5kg (2 water bottles) • 2kg (newspaper stack) • 5kg (small box)</small>
                            </div>
                        </div>
                        
                        <div class="weight-slider-container">
                            <div class="weight-presets">
                                <button type="button" class="weight-preset" data-weight="0.5">0.5kg</button>
                                <button type="button" class="weight-preset" data-weight="1">1kg</button>
                                <button type="button" class="weight-preset" data-weight="2">2kg</button>
                                <button type="button" class="weight-preset" data-weight="5">5kg</button>
                                <button type="button" class="weight-preset" data-weight="10">10kg</button>
                            </div>
                        </div>
                    </div>
                    
                    <div class="detail-card">
                        <h3><i class="fas fa-align-left"></i> Description (Optional)</h3>
                        <asp:TextBox ID="txtDescription" runat="server" CssClass="form-control" 
                            placeholder="E.g., 'Clear plastic bottles', 'Mixed paper waste', 'Broken glass jars'"
                            TextMode="MultiLine" Rows="4" />
                    </div>
                    
                    <div class="detail-card full-width">
                        <h3><i class="fas fa-camera"></i> Upload Photo (Optional)</h3>
                        <div class="photo-upload-container">
                            <div class="photo-upload-area" onclick="triggerPhotoUpload()">
                                <input type="file" id="filePhoto" runat="server" accept="image/*" style="display: none;" 
                                    onchange="handlePhotoUpload(event)" />
                                <div class="upload-content">
                                    <i class="fas fa-cloud-upload-alt"></i>
                                    <h4>Click to upload waste photo</h4>
                                    <p>JPG, PNG or GIF • Max 5MB</p>
                                    <button type="button" class="btn-upload">
                                        <i class="fas fa-folder-open"></i> Browse Files
                                    </button>
                                </div>
                            </div>
                            
                            <div class="photo-preview" id="photoPreview">
                                <div class="preview-placeholder">
                                    <i class="fas fa-image"></i>
                                    <p>Photo preview will appear here</p>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                
                <div class="step-navigation">
                    <button type="button" class="btn btn-back" onclick="prevStep(1)">
                        <i class="fas fa-arrow-left"></i>
                        Back
                    </button>
                    <button type="button" class="btn btn-next" onclick="nextStep(3)">
                        Continue to Location
                        <i class="fas fa-arrow-right"></i>
                    </button>
                </div>
            </div>

            <!-- Step 3: Location -->
            <div class="form-step" id="step3">
                <div class="step-header">
                    <h2><span class="step-number">03</span> Collection Location</h2>
                    <p>Specify where the waste should be collected from</p>
                </div>
                
                <div class="location-grid">
                    <div class="location-card">
                        <h3><i class="fas fa-map-marked-alt"></i> Address Details</h3>
                        
                        <div class="form-group">
                            <label>Full Address <span class="required">*</span></label>
                            <div class="input-with-icon">
                                <i class="fas fa-home"></i>
                                <asp:TextBox ID="txtAddress" runat="server" CssClass="form-control" 
                                    placeholder="House/Building number, street, area" TextMode="MultiLine" Rows="3" />
                            </div>
                        </div>
                        
                        <div class="form-row">
                            <div class="form-group">
                                <label>Landmark (Optional)</label>
                                <div class="input-with-icon">
                                    <i class="fas fa-map-pin"></i>
                                    <asp:TextBox ID="txtLandmark" runat="server" CssClass="form-control" 
                                        placeholder="Nearby landmark, shop, or building" />
                                </div>
                            </div>
                            
                            <div class="form-group">
                                <label>Contact Person</label>
                                <div class="input-with-icon">
                                    <i class="fas fa-user"></i>
                                    <asp:TextBox ID="txtContactPerson" runat="server" CssClass="form-control" 
                                        placeholder="Name of contact person" />
                                </div>
                            </div>
                        </div>
                        
                        <div class="form-group">
                            <label>Special Instructions (Optional)</label>
                            <asp:TextBox ID="txtInstructions" runat="server" CssClass="form-control" 
                                placeholder="E.g., 'Leave at gate', 'Call before coming', 'Available after 5 PM'" 
                                TextMode="MultiLine" Rows="2" />
                        </div>
                    </div>
                    
                    <div class="location-card">
                        <h3><i class="fas fa-location-crosshairs"></i> Map Location</h3>
                        
                        <div class="map-container" id="mapContainer">
                            <div class="map-placeholder" id="mapPlaceholder">
                                <i class="fas fa-map"></i>
                                <p>Map will load here</p>
                            </div>
                            <div id="map" style="display: none;"></div>
                        </div>
                        
                        <div class="location-actions">
                            <button type="button" class="btn-location" onclick="useCurrentLocation()">
                                <i class="fas fa-location-arrow"></i>
                                Use Current Location
                            </button>
                            <button type="button" class="btn-location secondary" onclick="pickOnMap()">
                                <i class="fas fa-map-pin"></i>
                                Pick on Map
                            </button>
                        </div>
                        
                        <div class="location-coordinates">
                            <div class="coord-input">
                                <label>Latitude</label>
                                <asp:TextBox ID="txtLatitude" runat="server" CssClass="form-control" 
                                    placeholder="Latitude" ReadOnly="true" />
                            </div>
                            <div class="coord-input">
                                <label>Longitude</label>
                                <asp:TextBox ID="txtLongitude" runat="server" CssClass="form-control" 
                                    placeholder="Longitude" ReadOnly="true" />
                            </div>
                        </div>
                    </div>
                </div>
                
                <asp:HiddenField ID="hdnLatitude" runat="server" />
                <asp:HiddenField ID="hdnLongitude" runat="server" />
                
                <div class="step-navigation">
                    <button type="button" class="btn btn-back" onclick="prevStep(2)">
                        <i class="fas fa-arrow-left"></i>
                        Back
                    </button>
                    <button type="button" class="btn btn-next" onclick="nextStep(4)">
                        Review & Submit
                        <i class="fas fa-arrow-right"></i>
                    </button>
                </div>
            </div>

            <!-- Step 4: Review & Submit -->
            <div class="form-step" id="step4">
                <div class="step-header">
                    <h2><span class="step-number">04</span> Review & Submit</h2>
                    <p>Confirm your waste report details before submission</p>
                </div>
                
                <div class="review-container">
                    <div class="review-summary">
                        <div class="review-card">
                            <h3><i class="fas fa-receipt"></i> Report Summary</h3>
                            
                            <div class="summary-grid">
                                <div class="summary-item">
                                    <span class="summary-label">Waste Type</span>
                                    <span class="summary-value" id="reviewWasteType">-</span>
                                </div>
                                <div class="summary-item">
                                    <span class="summary-label">Estimated Weight</span>
                                    <span class="summary-value" id="reviewWeight">- kg</span>
                                </div>
                                <div class="summary-item">
                                    <span class="summary-label">Category ID</span>
                                    <span class="summary-value" id="reviewCategoryId">-</span>
                                </div>
                                <div class="summary-item">
                                    <span class="summary-label">Reward Rate</span>
                                    <span class="summary-value" id="reviewRewardRate">- XP/kg</span>
                                </div>
                                <div class="summary-item full-width">
                                    <span class="summary-label">Description</span>
                                    <span class="summary-value" id="reviewDescription">No description provided</span>
                                </div>
                            </div>
                        </div>
                        
                        <div class="review-card">
                            <h3><i class="fas fa-map-pin"></i> Location Details</h3>
                            
                            <div class="summary-grid">
                                <div class="summary-item full-width">
                                    <span class="summary-label">Address</span>
                                    <span class="summary-value" id="reviewAddress">-</span>
                                </div>
                                <div class="summary-item">
                                    <span class="summary-label">Landmark</span>
                                    <span class="summary-value" id="reviewLandmark">Not specified</span>
                                </div>
                                <div class="summary-item">
                                    <span class="summary-label">Contact</span>
                                    <span class="summary-value" id="reviewContact">-</span>
                                </div>
                                <div class="summary-item full-width">
                                    <span class="summary-label">Instructions</span>
                                    <span class="summary-value" id="reviewInstructions">No special instructions</span>
                                </div>
                                <div class="summary-item">
                                    <span class="summary-label">Coordinates</span>
                                    <span class="summary-value" id="reviewCoordinates">-</span>
                                </div>
                            </div>
                        </div>
                    </div>
                    
                    <div class="review-sidebar">
                        <div class="reward-card">
                            <div class="reward-header">
                                <i class="fas fa-gift"></i>
                                <h3>Estimated Reward</h3>
                            </div>
                            <div class="reward-amount" id="estimatedReward">0 XP</div>
                            <div class="reward-details">
                                <div class="reward-item">
                                    <span>Weight:</span>
                                    <span id="rewardWeight">0 kg</span>
                                </div>
                                <div class="reward-item">
                                    <span>Rate:</span>
                                    <span id="rewardRate">0 XP/kg</span>
                                </div>
                                <div class="reward-item total">
                                    <span>Total:</span>
                                    <span id="rewardTotal">0 XP</span>
                                </div>
                            </div>
                            <div class="reward-note">
                                <i class="fas fa-info-circle"></i>
                                Reward will be awarded after collection verification
                            </div>
                        </div>
                        
                        <div class="confirmation-card">
                            <h4><i class="fas fa-clipboard-check"></i> Final Check</h4>
                            <div class="checkbox-group">
                                <label class="checkbox-label">
                                    <input type="checkbox" id="chkConfirmDetails" />
                                    <span class="checkmark"></span>
                                    I confirm all details are correct
                                </label>
                                <label class="checkbox-label">
                                    <input type="checkbox" id="chkAgreeTerms" />
                                    <span class="checkmark"></span>
                                    I agree to terms and conditions
                                </label>
                                <label class="checkbox-label">
                                    <input type="checkbox" id="chkSchedulePickup" />
                                    <span class="checkmark"></span>
                                    Schedule pickup within 48 hours
                                </label>
                            </div>
                        </div>
                    </div>
                </div>
                
                <div class="step-navigation">
                    <button type="button" class="btn btn-back" onclick="prevStep(3)">
                        <i class="fas fa-arrow-left"></i>
                        Edit Details
                    </button>
                    <asp:Button ID="btnSubmitReport" runat="server" Text="Submit Report" 
                        CssClass="btn btn-submit" OnClick="btnSubmitReport_Click"
                        OnClientClick="return validateSubmission();" />
                </div>
            </div>
        </div>

        <!-- Help Panel -->
        <div class="help-panel" id="helpPanel">
            <div class="help-header">
                <h3><i class="fas fa-question-circle"></i> Need Help?</h3>
                <button class="btn-close-help" onclick="hideHelp()">
                    <i class="fas fa-times"></i>
                </button>
            </div>
            <div class="help-content">
                <div class="help-item">
                    <h4><i class="fas fa-weight-hanging"></i> Weight Guidelines</h4>
                    <ul>
                        <li>Plastic bottles: 0.5kg each</li>
                        <li>Newspaper stack: 2-3kg</li>
                        <li>Cardboard box: 1-5kg</li>
                        <li>Glass bottles: 0.3kg each</li>
                    </ul>
                </div>
                <div class="help-item">
                    <h4><i class="fas fa-clock"></i> Collection Timeline</h4>
                    <p>Collections are typically scheduled within 24-48 hours of submission.</p>
                </div>
                <div class="help-item">
                    <h4><i class="fas fa-coins"></i> Reward Points</h4>
                    <p>XP points are awarded based on verified weight and waste type. Points can be redeemed for rewards.</p>
                </div>
            </div>
        </div>
    </div>
</asp:Content>