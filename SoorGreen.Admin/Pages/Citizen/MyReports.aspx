<%@ Page Title="My Reports" Language="C#" MasterPageFile="~/Pages/Citizen/Site.Master" 
    AutoEventWireup="true" CodeFile="MyReports.aspx.cs" Inherits="SoorGreen.Admin.MyReports" %>

<asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
    <link href='<%= ResolveUrl("~/Content/Pages/Citizen/citizenmyreports.css") %>' rel="stylesheet" />
    
    <!-- Add Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    
    <!-- Add Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</asp:Content>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    My Waste Reports - SoorGreen Citizen
</asp:Content>
<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <div class="reports-container">
        <!-- Page Header -->
        <div class="page-header-glass">
            <h1 class="page-title-glass">My Reports</h1>
            <p class="page-subtitle-glass">Manage and track your waste disposal reports</p>
            
            <!-- Quick Actions -->
            <div class="d-flex gap-3 mt-4">
                <asp:LinkButton ID="btnNewReport" runat="server" CssClass="action-btn primary"
                    OnClick="btnNewReport_Click">
                    <i class="fas fa-plus-circle me-2"></i> New Report
                </asp:LinkButton>
                
                <asp:LinkButton ID="btnRefresh" runat="server" CssClass="action-btn secondary"
                    OnClick="btnRefresh_Click">
                    <i class="fas fa-sync-alt me-2"></i> Refresh
                </asp:LinkButton>
                
                <asp:LinkButton ID="btnExportReports" runat="server" CssClass="action-btn secondary"
                    OnClick="btnExportReports_Click">
                    <i class="fas fa-file-export me-2"></i> Export
                </asp:LinkButton>
            </div>
        </div>

        <!-- Stats Overview -->
        <div class="stats-overview-grid">
            <div class="stat-card-glass submitted">
                <div class="d-flex align-items-start justify-content-between">
                    <div class="stat-icon-glass">
                        <i class="fas fa-paper-plane"></i>
                    </div>
                    <div class="stat-trend-glass trend-up">
                        <i class="fas fa-arrow-up"></i>
                        <span>15%</span>
                    </div>
                </div>
                <div class="stat-content-glass">
                    <div class="stat-number-glass" id="statSubmitted" runat="server">0</div>
                    <div class="stat-label-glass">Submitted</div>
                </div>
            </div>
            
            <div class="stat-card-glass verified">
                <div class="d-flex align-items-start justify-content-between">
                    <div class="stat-icon-glass">
                        <i class="fas fa-check-circle"></i>
                    </div>
                    <div class="stat-trend-glass trend-up">
                        <i class="fas fa-arrow-up"></i>
                        <span>8%</span>
                    </div>
                </div>
                <div class="stat-content-glass">
                    <div class="stat-number-glass" id="statVerified" runat="server">0</div>
                    <div class="stat-label-glass">Verified</div>
                </div>
            </div>
            
            <div class="stat-card-glass scheduled">
                <div class="d-flex align-items-start justify-content-between">
                    <div class="stat-icon-glass">
                        <i class="fas fa-calendar-alt"></i>
                    </div>
                    <div class="stat-trend-glass trend-up">
                        <i class="fas fa-arrow-up"></i>
                        <span>12%</span>
                    </div>
                </div>
                <div class="stat-content-glass">
                    <div class="stat-number-glass" id="statScheduled" runat="server">0</div>
                    <div class="stat-label-glass">Scheduled</div>
                </div>
            </div>
            
            <div class="stat-card-glass completed">
                <div class="d-flex align-items-start justify-content-between">
                    <div class="stat-icon-glass">
                        <i class="fas fa-check-double"></i>
                    </div>
                    <div class="stat-trend-glass trend-up">
                        <i class="fas fa-arrow-up"></i>
                        <span>20%</span>
                    </div>
                </div>
                <div class="stat-content-glass">
                    <div class="stat-number-glass" id="statCompleted" runat="server">0</div>
                    <div class="stat-label-glass">Completed</div>
                </div>
            </div>
        </div>

        <!-- Quick Actions -->
        <div class="quick-actions-glass">
            <div class="quick-actions-header">
                <h3 class="quick-actions-title">Quick Actions</h3>
                <asp:LinkButton ID="btnViewAll" runat="server" CssClass="action-btn secondary small"
                    OnClick="btnViewAll_Click">
                    View All
                </asp:LinkButton>
            </div>
            
            <div class="quick-actions-grid">
                <div class="quick-action-card" onclick="showNewReportModal()">
                    <i class="fas fa-trash-alt"></i>
                    <h4 class="quick-action-title">Report Waste</h4>
                    <p class="quick-action-desc">Submit a new waste disposal report</p>
                </div>
                
                <div class="quick-action-card" onclick="location.href='SchedulePickup.aspx'">
                    <i class="fas fa-truck"></i>
                    <h4 class="quick-action-title">Schedule Pickup</h4>
                    <p class="quick-action-desc">Schedule waste collection from verified reports</p>
                </div>
                
                <div class="quick-action-card" onclick="showPhotoUploadModal()">
                    <i class="fas fa-camera"></i>
                    <h4 class="quick-action-title">Upload Photos</h4>
                    <p class="quick-action-desc">Add photos to existing waste reports</p>
                </div>
                
                <div class="quick-action-card" onclick="location.href='Rewards.aspx'">
                    <i class="fas fa-trophy"></i>
                    <h4 class="quick-action-title">View Rewards</h4>
                    <p class="quick-action-desc">Check your earned credits and rewards</p>
                </div>
            </div>
        </div>

        <!-- Reports List -->
        <div class="reports-list-container">
            <div class="reports-list-header">
                <h3 class="reports-list-title">Recent Reports</h3>
                <div class="reports-filters-glass">
                    <asp:DropDownList ID="ddlStatusFilter" runat="server" CssClass="filter-select-glass"
                        AutoPostBack="true" OnSelectedIndexChanged="ddlStatusFilter_SelectedIndexChanged">
                        <asp:ListItem Value="all">All Status</asp:ListItem>
                        <asp:ListItem Value="submitted">Submitted</asp:ListItem>
                        <asp:ListItem Value="verified">Verified</asp:ListItem>
                        <asp:ListItem Value="processing">Processing</asp:ListItem>
                        <asp:ListItem Value="scheduled">Scheduled</asp:ListItem>
                        <asp:ListItem Value="completed">Completed</asp:ListItem>
                        <asp:ListItem Value="rejected">Rejected</asp:ListItem>
                    </asp:DropDownList>
                    
                    <asp:DropDownList ID="ddlDateFilter" runat="server" CssClass="filter-select-glass"
                        AutoPostBack="true" OnSelectedIndexChanged="ddlDateFilter_SelectedIndexChanged">
                        <asp:ListItem Value="today">Today</asp:ListItem>
                        <asp:ListItem Value="week">This Week</asp:ListItem>
                        <asp:ListItem Value="month">This Month</asp:ListItem>
                        <asp:ListItem Value="year">This Year</asp:ListItem>
                        <asp:ListItem Value="all">All Time</asp:ListItem>
                    </asp:DropDownList>
                    
                    <asp:DropDownList ID="ddlWasteTypeFilter" runat="server" CssClass="filter-select-glass"
                        AutoPostBack="true" OnSelectedIndexChanged="ddlWasteTypeFilter_SelectedIndexChanged">
                        <asp:ListItem Value="all">All Waste Types</asp:ListItem>
                        <asp:ListItem Value="plastic">Plastic</asp:ListItem>
                        <asp:ListItem Value="paper">Paper</asp:ListItem>
                        <asp:ListItem Value="glass">Glass</asp:ListItem>
                        <asp:ListItem Value="metal">Metal</asp:ListItem>
                        <asp:ListItem Value="organic">Organic</asp:ListItem>
                        <asp:ListItem Value="ewaste">E-Waste</asp:ListItem>
                    </asp:DropDownList>
                    
                    <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control-glass"
                        placeholder="Search reports..." AutoPostBack="true"
                        OnTextChanged="txtSearch_TextChanged"></asp:TextBox>
                </div>
            </div>
            
            <!-- Reports Cards -->
            <asp:Panel ID="pnlReportCards" runat="server" CssClass="reports-cards-grid">
                <asp:Repeater ID="rptReports" runat="server" OnItemCommand="rptReports_ItemCommand">
                    <ItemTemplate>
                        <div class='report-card-glass <%# Eval("StatusDisplay") %>'>
                            <div class="report-card-header">
                                <span class="report-id"><%# Eval("ReportId") %></span>
                                <span class='report-status-badge <%# Eval("StatusDisplay") %>'>
                                    <i class='<%# GetStatusIcon(Eval("StatusDisplay").ToString()) %> me-1'></i>
                                    <%# Eval("StatusDisplay") %>
                                </span>
                            </div>
                            
                            <div class="report-card-body">
                                <div class="report-details-grid">
                                    <div class="detail-item">
                                        <span class="detail-label">Waste Type</span>
                                        <span class="detail-value"><%# Eval("WasteType") %></span>
                                    </div>
                                    <div class="detail-item">
                                        <span class="detail-label">Weight</span>
                                        <span class="detail-value"><%# Eval("Weight") %> kg</span>
                                    </div>
                                    <div class="detail-item">
                                        <span class="detail-label">Estimated Reward</span>
                                        <span class="detail-value text-success"><%# Eval("Reward") %> XP</span>
                                    </div>
                                    <div class="detail-item">
                                        <span class="detail-label">Pickup</span>
                                        <span class="detail-value">
                                            <%# GetPickupStatus(Eval("PickupStatus").ToString()) %>
                                        </span>
                                    </div>
                                </div>
                                
                                <div class="report-location">
                                    <div class="location-label">
                                        <i class="fas fa-map-marker-alt"></i>
                                        Location
                                    </div>
                                    <div class="location-text"><%# Eval("Address") %></div>
                                </div>
                                
                                <asp:Panel ID="pnlPhotoPreview" runat="server" CssClass="report-photo-preview" 
                                    Visible='<%# !string.IsNullOrEmpty(Eval("PhotoUrl").ToString()) %>'>
                                    <img src='<%# Eval("PhotoUrl") %>' alt="Report Photo" 
                                        onclick="showPhotoModal('<%# Eval("PhotoUrl") %>')" />
                                </asp:Panel>
                            </div>
                            
                            <div class="report-card-footer">
                                <div class="report-time">
                                    <i class="fas fa-calendar"></i>
                                    <span><%# Eval("ReportDate", "{0:MMM dd, yyyy}") %></span>
                                </div>
                                
                                <div class="report-actions">
                                    <asp:LinkButton ID="btnViewDetails" runat="server" 
                                        CommandName="ViewDetails" 
                                        CommandArgument='<%# Eval("ReportId") %>'
                                        CssClass="action-btn secondary small" 
                                        ToolTip="View Details">
                                        <i class="fas fa-eye"></i>
                                    </asp:LinkButton>
                                    
                                    <asp:LinkButton ID="btnEditReport" runat="server" 
                                        CommandName="Edit" 
                                        CommandArgument='<%# Eval("ReportId") %>'
                                        CssClass="action-btn primary small" 
                                        ToolTip="Edit Report"
                                        Visible='<%# IsEditable(Eval("StatusDisplay").ToString()) %>'>
                                        <i class="fas fa-edit"></i>
                                    </asp:LinkButton>
                                    
                                    <asp:LinkButton ID="btnSchedulePickup" runat="server" 
                                        CommandName="Schedule" 
                                        CommandArgument='<%# Eval("ReportId") %>'
                                        CssClass="action-btn primary small" 
                                        ToolTip="Schedule Pickup"
                                        Visible='<%# IsSchedulable(Eval("StatusDisplay").ToString(), Eval("PickupStatus").ToString()) %>'>
                                        <i class="fas fa-calendar-plus"></i>
                                    </asp:LinkButton>
                                    
                                    <asp:LinkButton ID="btnDeleteReport" runat="server" 
                                        CommandName="Delete" 
                                        CommandArgument='<%# Eval("ReportId") %>'
                                        CssClass="action-btn danger small" 
                                        ToolTip="Delete Report"
                                        OnClientClick="return confirm('Are you sure you want to delete this report?');"
                                        Visible='<%# IsDeletable(Eval("StatusDisplay").ToString()) %>'>
                                        <i class="fas fa-trash"></i>
                                    </asp:LinkButton>
                                </div>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </asp:Panel>
            
            <!-- Empty State -->
            <asp:Panel ID="pnlEmptyState" runat="server" CssClass="empty-state-glass" Visible="false">
                <div class="empty-state-icon">
                    <i class="fas fa-file-alt"></i>
                </div>
                <h4 class="empty-state-title">No Reports Found</h4>
                <p class="empty-state-message">
                    You haven't submitted any waste reports yet. Start by submitting your first report!
                </p>
                <asp:LinkButton ID="btnCreateFirstReport" runat="server" CssClass="action-btn primary"
                    OnClick="btnNewReport_Click">
                    <i class="fas fa-plus-circle me-2"></i> Create Your First Report
                </asp:LinkButton>
            </asp:Panel>
            
            <!-- Loading State -->
            <asp:Panel ID="pnlLoading" runat="server" CssClass="text-center py-5" Visible="false">
                <div class="loader-glass"></div>
                <p class="text-muted mt-3">Loading reports...</p>
            </asp:Panel>
        </div>
        
        <!-- Pagination -->
        <div class="d-flex justify-content-between align-items-center mt-4">
            <div class="text-muted">
                Showing <asp:Label ID="lblStartCount" runat="server" Text="1"></asp:Label> - 
                <asp:Label ID="lblEndCount" runat="server" Text="10"></asp:Label> of 
                <asp:Label ID="lblTotalCount" runat="server" Text="0"></asp:Label> reports
            </div>
            
            <div class="d-flex gap-2">
                <asp:LinkButton ID="btnPrevPage" runat="server" CssClass="action-btn secondary small"
                    OnClick="btnPrevPage_Click">
                    <i class="fas fa-chevron-left"></i>
                </asp:LinkButton>
                
                <div class="d-flex gap-1">
                    <asp:Repeater ID="rptPageNumbers" runat="server">
                        <ItemTemplate>
                            <asp:LinkButton ID="btnPage" runat="server" 
                                CssClass='<%# Convert.ToInt32(Eval("PageNumber")) == Convert.ToInt32(Eval("CurrentPage")) ? "action-btn primary small" : "action-btn secondary small" %>'
                                CommandArgument='<%# Eval("PageNumber") %>'
                                OnClick="btnPage_Click"
                                Text='<%# Eval("PageNumber") %>'></asp:LinkButton>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
                
                <asp:LinkButton ID="btnNextPage" runat="server" CssClass="action-btn secondary small"
                    OnClick="btnNextPage_Click">
                    <i class="fas fa-chevron-right"></i>
                </asp:LinkButton>
            </div>
        </div>
    </div>
    
    <!-- New Report Modal -->
    <div class="modal fade" id="reportModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered modal-lg">
            <div class="modal-content report-modal-glass">
                <div class="modal-header-glass">
                    <h5 class="modal-title-glass" id="modalTitle" runat="server">New Waste Report</h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body-glass">
                    <div class="row">
                        <div class="col-md-6">
                            <div class="form-group-modal mb-4">
                                <label class="form-label-modal">Waste Type</label>
                                <div class="input-group-modal">
                                    <i class="fas fa-trash input-icon-modal"></i>
                                    <asp:DropDownList ID="ddlWasteType" runat="server" CssClass="form-control-modal">
                                        <asp:ListItem Value="">-- Select Waste Type --</asp:ListItem>
                                        <asp:ListItem Value="plastic">Plastic</asp:ListItem>
                                        <asp:ListItem Value="paper">Paper & Cardboard</asp:ListItem>
                                        <asp:ListItem Value="glass">Glass</asp:ListItem>
                                        <asp:ListItem Value="metal">Metal</asp:ListItem>
                                        <asp:ListItem Value="organic">Organic Waste</asp:ListItem>
                                        <asp:ListItem Value="ewaste">E-Waste</asp:ListItem>
                                        <asp:ListItem Value="hazardous">Hazardous Waste</asp:ListItem>
                                        <asp:ListItem Value="mixed">Mixed Waste</asp:ListItem>
                                    </asp:DropDownList>
                                </div>
                            </div>
                            
                            <div class="form-group-modal mb-4">
                                <label class="form-label-modal">Estimated Weight (kg)</label>
                                <div class="input-group-modal">
                                    <i class="fas fa-weight input-icon-modal"></i>
                                    <asp:TextBox ID="txtWeight" runat="server" CssClass="form-control-modal"
                                        placeholder="e.g., 5.5" TextMode="Number" step="0.1"></asp:TextBox>
                                </div>
                                <small class="text-muted">Enter weight in kilograms</small>
                            </div>
                            
                            <div class="form-group-modal mb-4">
                                <label class="form-label-modal">Collection Address</label>
                                <div class="input-group-modal">
                                    <i class="fas fa-map-marker-alt input-icon-modal"></i>
                                    <asp:TextBox ID="txtAddress" runat="server" CssClass="form-control-modal"
                                        placeholder="Enter your complete address"></asp:TextBox>
                                </div>
                            </div>
                        </div>
                        
                        <div class="col-md-6">
                            <div class="form-group-modal mb-4">
                                <label class="form-label-modal">Upload Photos (Optional)</label>
                                <div class="file-upload-glass" id="fileUploadArea">
                                    <div class="file-upload-icon">
                                        <i class="fas fa-cloud-upload-alt"></i>
                                    </div>
                                    <div class="file-upload-text">
                                        <h5>Drag & Drop Photos</h5>
                                        <p>or click to browse (Max: 5 photos, 5MB each)</p>
                                    </div>
                                    <asp:FileUpload ID="fileUploadPhotos" runat="server" CssClass="d-none" 
                                        AllowMultiple="true" accept="image/*" />
                                </div>
                                <div class="photo-preview-container" id="photoPreviewContainer"></div>
                            </div>
                            
                            <div class="info-box-glass">
                                <h6 class="mb-3"><i class="fas fa-info-circle me-2"></i>Estimated Rewards</h6>
                                <div class="detail-row">
                                    <span class="detail-label">Base Rate:</span>
                                    <span class="detail-value" id="baseRate">0 XP/kg</span>
                                </div>
                                <div class="detail-row">
                                    <span class="detail-label">Estimated Weight:</span>
                                    <span class="detail-value" id="estimatedWeight">0 kg</span>
                                </div>
                                <div class="detail-row">
                                    <span class="detail-label">Total Reward:</span>
                                    <span class="detail-value text-success" id="totalReward">0 XP</span>
                                </div>
                                <div class="detail-row">
                                    <span class="detail-label">Processing Time:</span>
                                    <span class="detail-value">24-48 hours</span>
                                </div>
                            </div>
                        </div>
                    </div>
                    
                    <div class="form-group-modal mb-4">
                        <label class="form-label-modal">Additional Details (Optional)</label>
                        <div class="input-group-modal">
                            <i class="fas fa-clipboard input-icon-modal"></i>
                            <asp:TextBox ID="txtDescription" runat="server" CssClass="form-control-modal"
                                TextMode="MultiLine" Rows="3"
                                placeholder="Provide any additional details about the waste (e.g., condition, packaging, special handling requirements)"></asp:TextBox>
                        </div>
                    </div>
                </div>
                <div class="modal-footer-glass">
                    <button type="button" class="action-btn secondary" data-bs-dismiss="modal">Cancel</button>
                    <asp:Button ID="btnSubmitReport" runat="server" CssClass="action-btn primary"
                        Text="Submit Report" OnClick="btnSubmitReport_Click" />
                </div>
            </div>
        </div>
    </div>
    
    <!-- Photo View Modal -->
    <div class="modal fade" id="photoModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered modal-xl">
            <div class="modal-content report-modal-glass">
                <div class="modal-header-glass">
                    <h5 class="modal-title-glass">Photo Preview</h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body-glass text-center">
                    <img id="modalPhoto" src="" alt="Report Photo" class="img-fluid rounded" style="max-height: 70vh;" />
                </div>
            </div>
        </div>
    </div>
    
        <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    
    <!-- JavaScript -->
    <script type="text/javascript">
        // Global modal variables
        var reportModal = null;
        var photoModal = null;

        // Initialize when page loads
        document.addEventListener('DOMContentLoaded', function () {
            // Initialize Bootstrap modals
            if (typeof bootstrap !== 'undefined') {
                var reportModalEl = document.getElementById('reportModal');
                if (reportModalEl) {
                    reportModal = new bootstrap.Modal(reportModalEl);
                }

                var photoModalEl = document.getElementById('photoModal');
                if (photoModalEl) {
                    photoModal = new bootstrap.Modal(photoModalEl);
                }
            }

            // Initialize file upload functionality
            initializeFileUpload();

            // Initialize reward calculation
            initializeRewardCalculation();
        });

        function initializeFileUpload() {
            const fileUploadArea = document.getElementById('fileUploadArea');
            const fileUploadControl = document.getElementById('<%= fileUploadPhotos.ClientID %>');
            const photoPreviewContainer = document.getElementById('photoPreviewContainer');

            if (fileUploadArea && fileUploadControl) {
                // Click to open file dialog
                fileUploadArea.addEventListener('click', function () {
                    fileUploadControl.click();
                });

                // Drag and drop functionality
                fileUploadArea.addEventListener('dragover', function (e) {
                    e.preventDefault();
                    fileUploadArea.classList.add('dragover');
                });

                fileUploadArea.addEventListener('dragleave', function () {
                    fileUploadArea.classList.remove('dragover');
                });

                fileUploadArea.addEventListener('drop', function (e) {
                    e.preventDefault();
                    fileUploadArea.classList.remove('dragover');

                    if (e.dataTransfer.files.length > 0) {
                        fileUploadControl.files = e.dataTransfer.files;
                        previewPhotos();
                    }
                });

                // File selection change
                fileUploadControl.addEventListener('change', previewPhotos);
            }
        }

        function previewPhotos() {
            const fileUploadControl = document.getElementById('<%= fileUploadPhotos.ClientID %>');
            const photoPreviewContainer = document.getElementById('photoPreviewContainer');

            if (!fileUploadControl || !photoPreviewContainer) return;

            photoPreviewContainer.innerHTML = '';
            const files = fileUploadControl.files;

            if (files.length > 5) {
                alert('Maximum 5 photos allowed. Only the first 5 will be uploaded.');
            }

            for (let i = 0; i < Math.min(files.length, 5); i++) {
                const file = files[i];
                if (file.type.startsWith('image/')) {
                    const reader = new FileReader();
                    reader.onload = function (e) {
                        const previewItem = document.createElement('div');
                        previewItem.className = 'photo-preview-item';

                        const img = document.createElement('img');
                        img.src = e.target.result;
                        img.alt = 'Preview ' + (i + 1);

                        const removeBtn = document.createElement('button');
                        removeBtn.className = 'remove-photo-btn';
                        removeBtn.innerHTML = '×';
                        removeBtn.onclick = function () {
                            previewItem.remove();
                        };

                        previewItem.appendChild(img);
                        previewItem.appendChild(removeBtn);
                        photoPreviewContainer.appendChild(previewItem);
                    };
                    reader.readAsDataURL(file);
                }
            }
        }

        function initializeRewardCalculation() {
            const weightInput = document.getElementById('<%= txtWeight.ClientID %>');
            const wasteTypeSelect = document.getElementById('<%= ddlWasteType.ClientID %>');
            
            if (weightInput && wasteTypeSelect) {
                weightInput.addEventListener('input', calculateReward);
                wasteTypeSelect.addEventListener('change', calculateReward);
            }
        }
        
        function calculateReward() {
            const weightInput = document.getElementById('<%= txtWeight.ClientID %>');
            const wasteTypeSelect = document.getElementById('<%= ddlWasteType.ClientID %>');
            const baseRateElement = document.getElementById('baseRate');
            const estimatedWeightElement = document.getElementById('estimatedWeight');
            const totalRewardElement = document.getElementById('totalReward');

            if (!weightInput || !wasteTypeSelect || !baseRateElement || !estimatedWeightElement || !totalRewardElement) return;

            const weight = parseFloat(weightInput.value) || 0;
            const wasteType = wasteTypeSelect.value;

            // Rate per kg based on waste type
            const rates = {
                'plastic': 10,
                'paper': 8,
                'glass': 5,
                'metal': 12,
                'organic': 3,
                'ewaste': 15,
                'hazardous': 20,
                'mixed': 6
            };

            const rate = rates[wasteType] || 5;
            const totalReward = weight * rate;

            baseRateElement.textContent = rate + ' XP/kg';
            estimatedWeightElement.textContent = weight.toFixed(1) + ' kg';
            totalRewardElement.textContent = totalReward.toFixed(0) + ' XP';
        }

        // Show new report modal
        function showNewReportModal() {
            if (reportModal) {
                reportModal.show();
            } else if (typeof bootstrap !== 'undefined') {
                var modalEl = document.getElementById('reportModal');
                if (modalEl) {
                    reportModal = new bootstrap.Modal(modalEl);
                    reportModal.show();
                }
            }
        }

        // Show photo modal
        function showPhotoModal(photoUrl) {
            const modalPhoto = document.getElementById('modalPhoto');
            if (modalPhoto) {
                modalPhoto.src = photoUrl;
                if (photoModal) {
                    photoModal.show();
                } else if (typeof bootstrap !== 'undefined') {
                    var modalEl = document.getElementById('photoModal');
                    if (modalEl) {
                        photoModal = new bootstrap.Modal(modalEl);
                        photoModal.show();
                    }
                }
            }
        }

        // Show photo upload modal
        function showPhotoUploadModal() {
            alert('Photo upload feature will be available soon!');
        }
    </script>
</asp:Content>