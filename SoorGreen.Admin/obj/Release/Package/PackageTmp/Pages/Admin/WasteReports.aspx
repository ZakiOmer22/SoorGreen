<%@ Page Title="Waste Reports" Language="C#" MasterPageFile="~/Pages/Admin/Site.master" AutoEventWireup="true" Inherits="SoorGreen.Admin.Admin.WasteReports" Codebehind="WasteReports.aspx.cs" %>

<asp:Content ID="Content3" ContentPlaceHolderID="HeadContent" runat="server">
    <link href='<%= ResolveUrl("~/Content/Pages/Admin/admincitizens.css") %>' rel="stylesheet" />
</asp:Content>

<asp:Content ID="PageTitle" ContentPlaceHolderID="PageTitle" runat="server">
    <div class="d-flex align-items-center">
        <h1 class="h3 mb-0" style="color: var(--text-primary);">Waste Reports Management</h1>
    </div>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <!-- Message Panel -->
    <asp:Panel ID="pnlMessage" runat="server" CssClass="message-panel" Visible="false">
        <div class='message-alert' id="divMessage" runat="server">
            <i class='fas' id="iconMessage" runat="server"></i>
            <div>
                <strong><asp:Literal ID="litMessageTitle" runat="server"></asp:Literal></strong>
                <p class="mb-0"><asp:Literal ID="litMessageText" runat="server"></asp:Literal></p>
            </div>
        </div>
    </asp:Panel>

    <!-- Add/Edit Modal -->
    <div class="modal fade" id="reportModal" tabindex="-1" role="dialog" aria-hidden="true">
        <div class="modal-dialog modal-lg" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="modalTitle">
                        <i class="fas fa-trash-alt me-2"></i>
                        <asp:Literal ID="litModalTitle" runat="server" Text="Add New Waste Report"></asp:Literal>
                    </h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <asp:HiddenField ID="hdnReportId" runat="server" />
                    
                    <div class="row">
                        <div class="col-md-6 mb-3">
                            <label class="form-label"><i class="fas fa-user me-2"></i>Citizen</label>
                            <asp:DropDownList ID="ddlCitizen" runat="server" CssClass="form-control" required>
                            </asp:DropDownList>
                        </div>
                        
                        <div class="col-md-6 mb-3">
                            <label class="form-label"><i class="fas fa-trash me-2"></i>Waste Type</label>
                            <asp:DropDownList ID="ddlWasteType" runat="server" CssClass="form-control" required>
                            </asp:DropDownList>
                        </div>
                        
                        <div class="col-md-6 mb-3">
                            <label class="form-label"><i class="fas fa-weight-hanging me-2"></i>Estimated Weight (kg)</label>
                            <asp:TextBox ID="txtEstimatedKg" runat="server" CssClass="form-control" 
                                placeholder="Enter weight" TextMode="Number" step="0.1" required></asp:TextBox>
                        </div>
                        
                        <div class="col-md-6 mb-3">
                            <label class="form-label"><i class="fas fa-map-marker-alt me-2"></i>Address</label>
                            <asp:TextBox ID="txtAddress" runat="server" CssClass="form-control" 
                                placeholder="Enter address" required></asp:TextBox>
                        </div>
                        
                        <div class="col-md-6 mb-3">
                            <label class="form-label"><i class="fas fa-location-arrow me-2"></i>Latitude</label>
                            <asp:TextBox ID="txtLat" runat="server" CssClass="form-control" 
                                placeholder="Optional" TextMode="Number" step="0.000001"></asp:TextBox>
                        </div>
                        
                        <div class="col-md-6 mb-3">
                            <label class="form-label"><i class="fas fa-location-arrow me-2"></i>Longitude</label>
                            <asp:TextBox ID="txtLng" runat="server" CssClass="form-control" 
                                placeholder="Optional" TextMode="Number" step="0.000001"></asp:TextBox>
                        </div>
                        
                        <div class="col-md-12 mb-3">
                            <label class="form-label"><i class="fas fa-image me-2"></i>Photo URL</label>
                            <asp:TextBox ID="txtPhotoUrl" runat="server" CssClass="form-control" 
                                placeholder="Enter image URL (optional)"></asp:TextBox>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <asp:Button ID="btnSaveReport" runat="server" CssClass="btn btn-primary" 
                        Text="Save Report" OnClick="btnSaveReport_Click" />
                    <asp:Button ID="btnDeleteReport" runat="server" CssClass="btn btn-danger" 
                        Text="Delete Report" OnClick="btnDeleteReport_Click" Visible="false" 
                        OnClientClick="return confirm('Are you sure you want to delete this waste report?');" />
                </div>
            </div>
        </div>
    </div>

    <div class="users-container">
        <!-- Filter Card -->
        <div class="filter-card">
            <h5 class="mb-4"><i class="fas fa-sliders-h me-2"></i>Advanced Filters</h5>
            <div class="filter-group">
                <div class="form-group search-box">
                    <label class="form-label"><i class="fas fa-search me-2"></i>Search Reports</label>
                    <div class="position-relative">
                        <i class="fas fa-search search-icon"></i>
                        <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control search-input" 
                            placeholder="Search by report ID, citizen name, address..."></asp:TextBox>
                    </div>
                </div>
                <div class="form-group">
                    <label class="form-label"><i class="fas fa-trash me-2"></i>Waste Type</label>
                    <div class="select-with-icon">
                        <asp:DropDownList ID="ddlWasteTypeFilter" runat="server" CssClass="form-control">
                            <asp:ListItem Value="all">All Types</asp:ListItem>
                            <asp:ListItem Value="Plastic">Plastic</asp:ListItem>
                            <asp:ListItem Value="Paper">Paper</asp:ListItem>
                            <asp:ListItem Value="Glass">Glass</asp:ListItem>
                            <asp:ListItem Value="Metal">Metal</asp:ListItem>
                            <asp:ListItem Value="Organic">Organic</asp:ListItem>
                        </asp:DropDownList>
                        <i class="fas fa-chevron-down select-arrow"></i>
                    </div>
                </div>
                <div class="form-group">
                    <label class="form-label"><i class="fas fa-calendar-alt me-2"></i>Date Range</label>
                    <div class="select-with-icon">
                        <asp:DropDownList ID="ddlDateFilter" runat="server" CssClass="form-control">
                            <asp:ListItem Value="all">All Time</asp:ListItem>
                            <asp:ListItem Value="today">Today</asp:ListItem>
                            <asp:ListItem Value="week">This Week</asp:ListItem>
                            <asp:ListItem Value="month">This Month</asp:ListItem>
                            <asp:ListItem Value="year">This Year</asp:ListItem>
                        </asp:DropDownList>
                        <i class="fas fa-chevron-down select-arrow"></i>
                    </div>
                </div>
                <div class="form-group">
                    <label class="form-label" style="visibility: hidden;">Action</label>
                    <div class="d-flex gap-2">
                        <button type="button" class="btn btn-primary btn-with-icon" onclick="__doPostBack('ctl00$MainContent$btnApplyFilters', '')">
                            <i class="fas fa-filter me-2"></i>Apply Filters
                        </button>
                        <asp:Button ID="btnApplyFilters" runat="server" style="display:none;" OnClick="btnApplyFilters_Click" />
                        
                        <button type="button" class="btn btn-success btn-with-icon" onclick="showAddModal()">
                            <i class="fas fa-plus me-2"></i>Add Report
                        </button>
                    </div>
                </div>
            </div>
        </div>

        <!-- Stats Cards -->
        <div class="d-flex gap-3 mb-4 flex-wrap">
            <div class="stats-card users" style="flex: 1; min-width: 200px;">
                <div class="stats-icon">
                    <i class="fas fa-file-alt"></i>
                </div>
                <div class="stats-number" id="statTotal" runat="server">0</div>
                <div class="stats-label">Total Reports</div>
            </div>
            <div class="stats-card active" style="flex: 1; min-width: 200px;">
                <div class="stats-icon">
                    <i class="fas fa-clock"></i>
                </div>
                <div class="stats-number text-warning" id="statPending" runat="server">0</div>
                <div class="stats-label">Pending Pickup</div>
            </div>
            <div class="stats-card pickups" style="flex: 1; min-width: 200px;">
                <div class="stats-icon">
                    <i class="fas fa-check-circle"></i>
                </div>
                <div class="stats-number text-success" id="statCollected" runat="server">0</div>
                <div class="stats-label">Collected</div>
            </div>
            <div class="stats-card waste" style="flex: 1; min-width: 200px;">
                <div class="stats-icon">
                    <i class="fas fa-weight-hanging"></i>
                </div>
                <div class="stats-number text-primary" id="statTotalWeight" runat="server">0 kg</div>
                <div class="stats-label">Total Waste</div>
            </div>
        </div>

        <!-- View Controls -->
        <div class="view-controls">
            <div class="d-flex align-items-center gap-3 flex-wrap">
                <div class="view-options">
                    <asp:LinkButton ID="btnGridView" runat="server" CssClass="view-btn active" 
                        OnClick="btnGridView_Click" CausesValidation="false">
                        <i class="fas fa-th-large me-2"></i>Grid View
                    </asp:LinkButton>
                    <asp:LinkButton ID="btnTableView" runat="server" CssClass="view-btn" 
                        OnClick="btnTableView_Click" CausesValidation="false">
                        <i class="fas fa-table me-2"></i>Table View
                    </asp:LinkButton>
                </div>
                <div class="page-info">
                    <i class="fas fa-file-alt me-2"></i>
                    Showing <asp:Label ID="lblReportCount" runat="server" Text="0"></asp:Label> waste reports
                </div>
            </div>
            <div class="d-flex gap-2">
                <button type="button" class="btn btn-secondary btn-with-icon" onclick="__doPostBack('ctl00$MainContent$btnExportCSV', '')">
                    <i class="fas fa-file-export me-2"></i>Export CSV
                </button>
                <asp:Button ID="btnExportCSV" runat="server" style="display:none;" OnClick="btnExportCSV_Click" />
                
                <button type="button" class="btn btn-secondary btn-with-icon" onclick="__doPostBack('ctl00$MainContent$btnRefresh', '')">
                    <i class="fas fa-sync-alt me-2"></i>Refresh
                </button>
                <asp:Button ID="btnRefresh" runat="server" style="display:none;" OnClick="btnRefresh_Click" />
                
                <button type="button" class="btn btn-secondary btn-with-icon" onclick="__doPostBack('ctl00$MainContent$btnClearFilters', '')">
                    <i class="fas fa-times me-2"></i>Clear Filters
                </button>
                <asp:Button ID="btnClearFilters" runat="server" style="display:none;" OnClick="btnClearFilters_Click" />
            </div>
        </div>

        <!-- Grid View -->
        <asp:Panel ID="pnlGridView" runat="server" CssClass="users-grid">
            <asp:Repeater ID="rptReportsGrid" runat="server" 
                OnItemDataBound="rptReportsGrid_ItemDataBound">
                <ItemTemplate>
                    <div class="user-card">
                        <h5>
                            <i class="fas fa-file-alt me-2"></i>Report #<%# Eval("ReportId") %>
                            <span class="user-id">
                                <i class="fas fa-calendar me-1"></i><%# Convert.ToDateTime(Eval("CreatedAt")).ToString("MM/dd") %>
                            </span>
                        </h5>
                        
                        <p>
                            <span><i class="fas fa-user me-2"></i>Citizen:</span>
                            <span><%# Eval("CitizenName") %></span>
                        </p>
                        
                        <p>
                            <span><i class="fas fa-trash me-2"></i>Waste Type:</span>
                            <span class="badge bg-primary"><%# Eval("WasteTypeName") %></span>
                        </p>
                        
                        <p>
                            <span><i class="fas fa-map-marker-alt me-2"></i>Address:</span>
                            <span><%# Eval("Address") %></span>
                        </p>
                        
                        <p>
                            <span><i class="fas fa-weight-hanging me-2"></i>Weight:</span>
                            <span><%# Eval("EstimatedKg") %> kg</span>
                        </p>
                        
                        <p>
                            <span><i class="fas fa-info-circle me-2"></i>Pickup Status:</span>
                            <span class='<%# GetPickupStatusClass(Eval("PickupStatus").ToString()) %>'>
                                <i class='fas fa-circle status-dot <%# GetPickupStatusClass(Eval("PickupStatus").ToString()) %>'></i>
                                <%# string.IsNullOrEmpty(Eval("PickupStatus").ToString()) ? "No Pickup" : Eval("PickupStatus") %>
                            </span>
                        </p>
                        
                        <div class="card-stats">
                            <div class="stat-item">
                                <span class="stat-value"><%# Eval("Credits") %> pts</span>
                                <span class="stat-label">Credits</span>
                            </div>
                            <div class="stat-item">
                                <span class="stat-value"><%# Eval("HasPhoto") != null && Convert.ToBoolean(Eval("HasPhoto")) ? "Yes" : "No" %></span>
                                <span class="stat-label">Photo</span>
                            </div>
                        </div>
                        
                        <div class="action-buttons">
                            <button type="button" class="btn btn-primary" onclick='editReport("<%# Eval("ReportId") %>")'>
                                <i class="fas fa-edit me-1"></i>Edit
                            </button>
                            <button type="button" class="btn btn-info" onclick='viewReport("<%# Eval("ReportId") %>")'>
                                <i class="fas fa-eye me-1"></i>View
                            </button>
                            <%# GetCreatePickupButton(Eval("PickupStatus").ToString(), Eval("ReportId").ToString()) %>
                        </div>
                    </div>
                </ItemTemplate>
                <FooterTemplate>
                    <asp:Label ID="lblEmptyGrid" runat="server" Text="No waste reports found" 
                        Visible='<%# rptReportsGrid.Items.Count == 0 %>' CssClass="empty-state">
                        <i class="fas fa-trash-slash"></i>
                        <p>No waste reports found matching your criteria</p>
                    </asp:Label>
                </FooterTemplate>
            </asp:Repeater>
        </asp:Panel>

        <!-- Table View -->
        <asp:Panel ID="pnlTableView" runat="server" CssClass="table-container" Visible="false">
            <asp:GridView ID="gvReports" runat="server" AutoGenerateColumns="False" 
                CssClass="users-table" 
                EmptyDataText="No waste reports found" ShowHeaderWhenEmpty="true">
                <Columns>
                    <asp:TemplateField HeaderText="Report ID">
                        <ItemTemplate>
                            <div class="d-flex align-items-center">
                                <div class="role-icon waste-report">
                                    <i class='fas fa-file-alt'></i>
                                </div>
                                <strong><%# Eval("ReportId") %></strong>
                            </div>
                        </ItemTemplate>
                    </asp:TemplateField>
                    
                    <asp:TemplateField HeaderText="Citizen">
                        <ItemTemplate>
                            <div><strong><%# Eval("CitizenName") %></strong></div>
                            <small class="text-muted"><%# Eval("CitizenPhone") %></small>
                        </ItemTemplate>
                    </asp:TemplateField>
                    
                    <asp:TemplateField HeaderText="Waste Details">
                        <ItemTemplate>
                            <div class="d-flex align-items-center gap-2">
                                <span class="badge bg-primary"><%# Eval("WasteTypeName") %></span>
                                <strong><%# Eval("EstimatedKg") %> kg</strong>
                            </div>
                            <small><i class="fas fa-map-marker-alt"></i> <%# Eval("Address") %></small>
                        </ItemTemplate>
                    </asp:TemplateField>
                    
                    <asp:TemplateField HeaderText="Credits">
                        <ItemTemplate>
                            <div class="d-flex align-items-center gap-2">
                                <i class="fas fa-coins text-warning"></i>
                                <span><%# Eval("Credits") %> pts</span>
                            </div>
                        </ItemTemplate>
                    </asp:TemplateField>
                    
                    <asp:TemplateField HeaderText="Pickup Status">
                        <ItemTemplate>
                            <div class="status-indicator">
                                <span class='status-dot <%# GetPickupStatusClass(Eval("PickupStatus").ToString()) %>'></span>
                                <span class='<%# GetPickupStatusColor(Eval("PickupStatus").ToString()) %>'>
                                    <%# string.IsNullOrEmpty(Eval("PickupStatus").ToString()) ? "No Pickup" : Eval("PickupStatus") %>
                                </span>
                            </div>
                        </ItemTemplate>
                    </asp:TemplateField>
                    
                    <asp:TemplateField HeaderText="Dates">
                        <ItemTemplate>
                            <small>Reported: <%# Convert.ToDateTime(Eval("CreatedAt")).ToString("MM/dd/yyyy HH:mm") %></small><br>
                            <small>Pickup: <%# Eval("PickupDate") != DBNull.Value ? Convert.ToDateTime(Eval("PickupDate")).ToString("MM/dd") : "-" %></small>
                        </ItemTemplate>
                    </asp:TemplateField>
                    
                    <asp:TemplateField HeaderText="Actions">
                        <ItemTemplate>
                            <div class="d-flex gap-2">
                                <button type="button" class="btn btn-primary" onclick='editReport("<%# Eval("ReportId") %>")'>
                                    <i class="fas fa-edit"></i>
                                </button>
                                <button type="button" class="btn btn-info" onclick='viewReport("<%# Eval("ReportId") %>")'>
                                    <i class="fas fa-eye"></i>
                                </button>
                                <%# GetCreatePickupButton(Eval("PickupStatus").ToString(), Eval("ReportId").ToString()) %>
                            </div>
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
                <EmptyDataTemplate>
                    <div class="empty-state" style="margin: 2rem;">
                        <i class="fas fa-trash-slash"></i>
                        <p>No waste reports found matching your criteria</p>
                    </div>
                </EmptyDataTemplate>
            </asp:GridView>
        </asp:Panel>
    </div>

    <!-- Simple JavaScript functions -->
    <script>
    function showAddModal() {
        // Reset form
        document.getElementById('<%= hdnReportId.ClientID %>').value = '';
        document.getElementById('<%= litModalTitle.ClientID %>').innerText = 'Add New Waste Report';
        document.getElementById('<%= btnDeleteReport.ClientID %>').style.display = 'none';
        
        // Clear form fields
        document.getElementById('<%= ddlCitizen.ClientID %>').selectedIndex = 0;
        document.getElementById('<%= ddlWasteType.ClientID %>').selectedIndex = 0;
        document.getElementById('<%= txtEstimatedKg.ClientID %>').value = '';
        document.getElementById('<%= txtAddress.ClientID %>').value = '';
        document.getElementById('<%= txtLat.ClientID %>').value = '';
        document.getElementById('<%= txtLng.ClientID %>').value = '';
        document.getElementById('<%= txtPhotoUrl.ClientID %>').value = '';
        
        // Show modal
        var modal = new bootstrap.Modal(document.getElementById('reportModal'));
        modal.show();
    }
    
    function editReport(reportId) {
        // Set the report ID
        document.getElementById('<%= hdnReportId.ClientID %>').value = reportId;
        document.getElementById('<%= litModalTitle.ClientID %>').innerText = 'Edit Waste Report';
        document.getElementById('<%= btnDeleteReport.ClientID %>').style.display = 'inline-block';
        
        // Trigger server-side event to load data
        __doPostBack('ctl00$MainContent$hdnReportId', 'edit_' + reportId);
    }
    
    function viewReport(reportId) {
        alert('View waste report details: ' + reportId);
    }
    
    function createPickup(reportId) {
        if (confirm('Create pickup request for report #' + reportId + '?')) {
            __doPostBack('ctl00$MainContent$btnCreatePickup', reportId);
        }
    }
    </script>
</asp:Content>