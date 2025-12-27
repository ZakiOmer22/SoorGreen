<%@ Page Title="Municipalities" Language="C#" MasterPageFile="~/Pages/Admin/Site.master" AutoEventWireup="true" Inherits="SoorGreen.Admin.Admin.Municipalities" Codebehind="Municipalities.aspx.cs" %>

<asp:Content ID="Content3" ContentPlaceHolderID="HeadContent" runat="server">
    <link href='<%= ResolveUrl("~/Content/Pages/Admin/admincitizens.css") %>' rel="stylesheet" />
</asp:Content>

<asp:Content ID="PageTitle" ContentPlaceHolderID="PageTitle" runat="server">
    <div class="d-flex align-items-center">
        <h1 class="h3 mb-0" style="color: var(--text-primary);">Municipalities Management</h1>
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

    <!-- Add/Edit Municipality Modal -->
    <div class="modal fade" id="municipalityModal" tabindex="-1" role="dialog" aria-hidden="true">
        <div class="modal-dialog modal-lg" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">
                        <i class="fas fa-city me-2"></i>
                        <span id="modalTitle">Add New Municipality</span>
                    </h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <asp:HiddenField ID="hdnMunicipalityId" runat="server" />
                    
                    <div class="row">
                        <div class="col-md-6">
                            <h6 class="mb-3 border-bottom pb-2"><i class="fas fa-info-circle me-2"></i>Basic Information</h6>
                            
                            <div class="mb-3">
                                <label class="form-label"><i class="fas fa-hashtag me-2"></i>Municipality ID</label>
                                <asp:TextBox ID="txtMunicipalityId" runat="server" CssClass="form-control" 
                                    ReadOnly="true" placeholder="Auto-generated"></asp:TextBox>
                            </div>
                            
                            <div class="mb-3">
                                <label class="form-label"><i class="fas fa-city me-2"></i>Municipality Name</label>
                                <asp:TextBox ID="txtMunicipalityName" runat="server" CssClass="form-control" 
                                    placeholder="Enter municipality/city name" MaxLength="100" required="true"></asp:TextBox>
                                <div class="invalid-feedback">Please enter a municipality name.</div>
                            </div>
                            
                            <div class="mb-3">
                                <label class="form-label"><i class="fas fa-map-marker-alt me-2"></i>Region/Zone</label>
                                <asp:TextBox ID="txtRegion" runat="server" CssClass="form-control" 
                                    placeholder="Enter region or zone"></asp:TextBox>
                            </div>
                            
                            <div class="mb-3">
                                <label class="form-label"><i class="fas fa-flag me-2"></i>Status</label>
                                <asp:DropDownList ID="ddlStatus" runat="server" CssClass="form-control">
                                    <asp:ListItem Value="Active" Selected="True">Active</asp:ListItem>
                                    <asp:ListItem Value="Inactive">Inactive</asp:ListItem>
                                    <asp:ListItem Value="Under Maintenance">Under Maintenance</asp:ListItem>
                                </asp:DropDownList>
                            </div>
                        </div>
                        
                        <div class="col-md-6">
                            <h6 class="mb-3 border-bottom pb-2"><i class="fas fa-chart-bar me-2"></i>Statistics & Details</h6>
                            
                            <div class="mb-3">
                                <label class="form-label"><i class="fas fa-users me-2"></i>Estimated Population</label>
                                <div class="input-group">
                                    <asp:TextBox ID="txtPopulation" runat="server" CssClass="form-control" 
                                        placeholder="0" TextMode="Number"></asp:TextBox>
                                    <span class="input-group-text">people</span>
                                </div>
                            </div>
                            
                            <div class="mb-3">
                                <label class="form-label"><i class="fas fa-map-marked-alt me-2"></i>Area (km²)</label>
                                <div class="input-group">
                                    <asp:TextBox ID="txtArea" runat="server" CssClass="form-control" 
                                        placeholder="0.00" TextMode="Number" step="0.01"></asp:TextBox>
                                    <span class="input-group-text">km²</span>
                                </div>
                            </div>
                            
                            <div class="mb-3">
                                <label class="form-label"><i class="fas fa-calendar-alt me-2"></i>Established Date</label>
                                <asp:TextBox ID="txtEstablishedDate" runat="server" CssClass="form-control" 
                                    TextMode="Date"></asp:TextBox>
                            </div>
                            
                            <div class="mb-3">
                                <label class="form-label"><i class="fas fa-user-tie me-2"></i>Contact Person</label>
                                <asp:TextBox ID="txtContactPerson" runat="server" CssClass="form-control" 
                                    placeholder="Name of contact person"></asp:TextBox>
                            </div>
                        </div>
                    </div>
                    
                    <!-- Additional Information -->
                    <div class="mt-4">
                        <h6 class="mb-3 border-bottom pb-2"><i class="fas fa-sticky-note me-2"></i>Additional Information</h6>
                        
                        <div class="mb-3">
                            <label class="form-label"><i class="fas fa-info-circle me-2"></i>Description</label>
                            <asp:TextBox ID="txtDescription" runat="server" CssClass="form-control" 
                                placeholder="Enter description about this municipality..." 
                                TextMode="MultiLine" Rows="3"></asp:TextBox>
                        </div>
                        
                        <div class="mb-3">
                            <label class="form-label"><i class="fas fa-phone me-2"></i>Contact Number</label>
                            <asp:TextBox ID="txtContactNumber" runat="server" CssClass="form-control" 
                                placeholder="Municipality contact number"></asp:TextBox>
                        </div>
                        
                        <div class="mb-3">
                            <label class="form-label"><i class="fas fa-envelope me-2"></i>Email Address</label>
                            <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control" 
                                placeholder="Municipality email address" TextMode="Email"></asp:TextBox>
                        </div>
                        
                        <div class="mb-3">
                            <label class="form-label"><i class="fas fa-map me-2"></i>Address</label>
                            <asp:TextBox ID="txtAddress" runat="server" CssClass="form-control" 
                                placeholder="Municipality office address" TextMode="MultiLine" Rows="2"></asp:TextBox>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <asp:Button ID="btnSaveMunicipality" runat="server" CssClass="btn btn-primary" 
                        Text="Save Municipality" OnClick="btnSaveMunicipality_Click" />
                    <asp:Button ID="btnDeleteMunicipality" runat="server" CssClass="btn btn-danger" 
                        Text="Delete" Visible="false" OnClick="btnDeleteMunicipality_Click"
                        OnClientClick="return confirm('Are you sure you want to delete this municipality? This action cannot be undone.');" />
                </div>
            </div>
        </div>
    </div>

    <div class="users-container">
        <!-- Filter Card -->
        <div class="filter-card">
            <h5 class="mb-4"><i class="fas fa-sliders-h me-2"></i>Filter Municipalities</h5>
            <div class="filter-group">
                <div class="form-group search-box">
                    <label class="form-label"><i class="fas fa-search me-2"></i>Search Municipalities</label>
                    <div class="position-relative">
                        <i class="fas fa-search search-icon"></i>
                        <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control search-input" 
                            placeholder="Search by name, region, contact person..."></asp:TextBox>
                    </div>
                </div>
                <div class="form-group">
                    <label class="form-label"><i class="fas fa-flag me-2"></i>Status</label>
                    <div class="select-with-icon">
                        <asp:DropDownList ID="ddlStatusFilter" runat="server" CssClass="form-control">
                            <asp:ListItem Value="all">All Status</asp:ListItem>
                            <asp:ListItem Value="Active">Active</asp:ListItem>
                            <asp:ListItem Value="Inactive">Inactive</asp:ListItem>
                            <asp:ListItem Value="Under Maintenance">Under Maintenance</asp:ListItem>
                        </asp:DropDownList>
                        <i class="fas fa-chevron-down select-arrow"></i>
                    </div>
                </div>
                <div class="form-group">
                    <label class="form-label"><i class="fas fa-filter me-2"></i>Population Range</label>
                    <div class="row g-2">
                        <div class="col">
                            <asp:TextBox ID="txtPopulationFrom" runat="server" CssClass="form-control" 
                                placeholder="Min" TextMode="Number"></asp:TextBox>
                        </div>
                        <div class="col">
                            <asp:TextBox ID="txtPopulationTo" runat="server" CssClass="form-control" 
                                placeholder="Max" TextMode="Number"></asp:TextBox>
                        </div>
                    </div>
                </div>
                <div class="form-group">
                    <label class="form-label" style="visibility: hidden;">Action</label>
                    <button type="button" class="btn btn-primary btn-with-icon" onclick="__doPostBack('ctl00$MainContent$btnApplyFilters', '')">
                        <i class="fas fa-filter me-2"></i>Apply Filters
                    </button>
                    <asp:Button ID="btnApplyFilters" runat="server" Style="display: none;" OnClick="btnApplyFilters_Click" />
                </div>
            </div>
        </div>

        <!-- Stats Cards -->
        <div class="d-flex gap-3 mb-4 flex-wrap">
            <div class="stats-card users" style="flex: 1; min-width: 200px;">
                <div class="stats-icon">
                    <i class="fas fa-city"></i>
                </div>
                <div class="stats-number" id="statTotalMunicipalities" runat="server">0</div>
                <div class="stats-label">Total Municipalities</div>
            </div>
            <div class="stats-card active" style="flex: 1; min-width: 200px;">
                <div class="stats-icon">
                    <i class="fas fa-check-circle"></i>
                </div>
                <div class="stats-number text-success" id="statActiveMunicipalities" runat="server">0</div>
                <div class="stats-label">Active</div>
            </div>
            <div class="stats-card pickups" style="flex: 1; min-width: 200px;">
                <div class="stats-icon">
                    <i class="fas fa-users"></i>
                </div>
                <div class="stats-number text-primary" id="statTotalPopulation" runat="server">0</div>
                <div class="stats-label">Total Population</div>
            </div>
            <div class="stats-card waste" style="flex: 1; min-width: 200px;">
                <div class="stats-icon">
                    <i class="fas fa-map-marked-alt"></i>
                </div>
                <div class="stats-number text-warning" id="statTotalArea" runat="server">0 km²</div>
                <div class="stats-label">Total Area</div>
            </div>
        </div>

        <!-- Quick Actions -->
        <div class="filter-card mb-4">
            <h5 class="mb-4"><i class="fas fa-bolt me-2"></i>Quick Actions</h5>
            <div class="d-flex flex-wrap gap-3">
                <button type="button" class="btn btn-success btn-with-icon" onclick="showActiveMunicipalities()">
                    <i class="fas fa-check-circle me-2"></i>Active Municipalities
                </button>
                <button type="button" class="btn btn-warning btn-with-icon" onclick="showLargeMunicipalities()">
                    <i class="fas fa-users me-2"></i>Large Population (>100k)
                </button>
                <button type="button" class="btn btn-info btn-with-icon" onclick="showInactiveMunicipalities()">
                    <i class="fas fa-times-circle me-2"></i>Inactive Municipalities
                </button>
                <button type="button" class="btn btn-primary btn-with-icon" onclick="__doPostBack('ctl00$MainContent$btnExportCSV', '')">
                    <i class="fas fa-file-export me-2"></i>Export Report
                </button>
                <button type="button" class="btn btn-secondary btn-with-icon" onclick="openAddMunicipalityModal()">
                    <i class="fas fa-plus-circle me-2"></i>Add New Municipality
                </button>
                <asp:Button ID="btnExportCSV" runat="server" Style="display: none;" OnClick="btnExportCSV_Click" />
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
                    <i class="fas fa-city me-2"></i>
                    Showing <asp:Label ID="lblMunicipalityCount" runat="server" Text="0"></asp:Label> municipalities
                </div>
            </div>
            <div class="d-flex gap-2">
                <button type="button" class="btn btn-secondary btn-with-icon" onclick="__doPostBack('ctl00$MainContent$btnRefresh', '')">
                    <i class="fas fa-sync-alt me-2"></i>Refresh
                </button>
                <asp:Button ID="btnRefresh" runat="server" Style="display: none;" OnClick="btnRefresh_Click" />
                
                <button type="button" class="btn btn-secondary btn-with-icon" onclick="__doPostBack('ctl00$MainContent$btnClearFilters', '')">
                    <i class="fas fa-times me-2"></i>Clear Filters
                </button>
                <asp:Button ID="btnClearFilters" runat="server" Style="display: none;" OnClick="btnClearFilters_Click" />
            </div>
        </div>

        <!-- Grid View -->
        <asp:Panel ID="pnlGridView" runat="server" CssClass="users-grid">
            <asp:Repeater ID="rptMunicipalitiesGrid" runat="server" 
                OnItemDataBound="rptMunicipalitiesGrid_ItemDataBound">
                <ItemTemplate>
                    <div class="user-card municipality-card">
                        <div class="d-flex justify-content-between align-items-start mb-2">
                            <h5>
                                <i class="fas fa-city me-2"></i><%# Eval("Name") %>
                            </h5>
                            <span class="badge status-badge <%# GetStatusBadgeClass(Eval("Status").ToString()) %>">
                                <%# Eval("Status") %>
                            </span>
                        </div>
                        
                        <div class="mb-3">
                            <span class="text-muted small">
                                <i class="fas fa-map-marker-alt me-1"></i><%# Eval("Region") %>
                                <i class="fas fa-hashtag ms-2 me-1"></i>ID: <%# Eval("MunicipalityId") %>
                            </span>
                        </div>
                        
                        <div class="municipality-info">
                            <div class="info-row">
                                <i class="fas fa-users"></i>
                                <div>
                                    <span class="label">Population</span>
                                    <span class="value">
                                        <strong><%# FormatNumber(Eval("Population")) %></strong> people
                                    </span>
                                </div>
                            </div>
                            
                            <div class="info-row">
                                <i class="fas fa-map-marked-alt"></i>
                                <div>
                                    <span class="label">Area</span>
                                    <span class="value">
                                        <strong><%# Eval("Area") %></strong> km²
                                    </span>
                                </div>
                            </div>
                           
                            <div class="info-row">
                                <i class="fas fa-user-tie"></i>
                                <div>
                                    <span class="label">Contact Person</span>
                                    <span class="value">
                                        <%# Eval("ContactPerson") %>
                                    </span>
                                </div>
                            </div>
                            
                            <div class="info-row">
                                <i class="fas fa-phone"></i>
                                <div>
                                    <span class="label">Contact Number</span>
                                    <span class="value">
                                        <%# Eval("ContactNumber") %>
                                    </span>
                                </div>
                            </div>
                        </div>
                        
                        <div class="card-stats">
                            <div class="stat-item">
                                <span class="stat-value">
                                    <%# GetUserCount(Eval("MunicipalityId").ToString()) %>
                                </span>
                                <span class="stat-label">Users</span>
                            </div>
                            <div class="stat-item">
                                <span class="stat-value">
                                    <%# GetWasteReportCount(Eval("MunicipalityId").ToString()) %>
                                </span>
                                <span class="stat-label">Waste Reports</span>
                            </div>
                            <div class="stat-item">
                                <span class="stat-value">
                                    <%# GetEstablishedYear(Eval("EstablishedDate")) %>
                                </span>
                                <span class="stat-label">Established</span>
                            </div>
                        </div>
                        
                        <div class="municipality-meta">
                            <div class="meta-item">
                                <i class="fas fa-calendar-alt"></i>
                                <span>Established: <%# GetFormattedDate(Eval("EstablishedDate")) %></span>
                            </div>
                            <div class="meta-item">
                                <i class="fas fa-envelope"></i>
                                <span><%# Eval("Email") %></span>
                            </div>
                        </div>
                        
                        <div class="action-buttons">
                            <button type="button" class="btn btn-primary" onclick='editMunicipality("<%# Eval("MunicipalityId") %>")'>
                                <i class="fas fa-edit me-1"></i>Edit
                            </button>
                            <button type="button" class="btn btn-info" onclick='viewMunicipalityDetails("<%# Eval("MunicipalityId") %>")'>
                                <i class="fas fa-eye me-1"></i>View Details
                            </button>
                            <button type="button" class="btn btn-secondary" onclick='viewMunicipalityUsers("<%# Eval("MunicipalityId") %>")'>
                                <i class="fas fa-users me-1"></i>View Users
                            </button>
                        </div>
                    </div>
                </ItemTemplate>
                <FooterTemplate>
                    <asp:Label ID="lblEmptyGrid" runat="server" Text="No municipalities found" 
                        Visible='<%# rptMunicipalitiesGrid.Items.Count == 0 %>' CssClass="empty-state">
                        <i class="fas fa-city"></i>
                        <p>No municipalities found matching your criteria</p>
                    </asp:Label>
                </FooterTemplate>
            </asp:Repeater>
        </asp:Panel>

        <!-- Table View -->
        <asp:Panel ID="pnlTableView" runat="server" CssClass="table-container" Visible="false">
            <asp:GridView ID="gvMunicipalities" runat="server" AutoGenerateColumns="False" 
                CssClass="users-table" 
                EmptyDataText="No municipalities found" ShowHeaderWhenEmpty="true">
                <Columns>
                    <asp:TemplateField HeaderText="Municipality Information">
                        <ItemTemplate>
                            <div class="d-flex align-items-center">
                                <div class="municipality-icon">
                                    <i class='fas fa-city'></i>
                                </div>
                                <div>
                                    <strong><%# Eval("Name") %></strong><br>
                                    <small class="text-muted"><%# Eval("Region") %></small><br>
                                    <small class="text-muted">ID: <%# Eval("MunicipalityId") %></small>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:TemplateField>
                    
                    <asp:TemplateField HeaderText="Status & Stats">
                        <ItemTemplate>
                            <span class='badge <%# GetStatusBadgeClass(Eval("Status").ToString()) %>'>
                                <%# Eval("Status") %>
                            </span>
                            <div class="small mt-2">
                                <div><i class="fas fa-users me-1"></i> <%# FormatNumber(Eval("Population")) %> people</div>
                                <div><i class="fas fa-map-marked-alt me-1"></i> <%# Eval("Area") %> km²</div>
                                <div><i class="fas fa-calendar me-1"></i> <%# GetEstablishedYear(Eval("EstablishedDate")) %></div>
                            </div>
                        </ItemTemplate>
                    </asp:TemplateField>
                    
                    <asp:TemplateField HeaderText="Contact Information">
                        <ItemTemplate>
                            <div class="small">
                                <div><strong><%# Eval("ContactPerson") %></strong></div>
                                <div><i class="fas fa-phone"></i> <%# Eval("ContactNumber") %></div>
                                <div><i class="fas fa-envelope"></i> <%# Eval("Email") %></div>
                                <div class="truncate-text" style="max-width: 200px;">
                                    <i class="fas fa-map-marker-alt"></i> <%# Eval("Address") %>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:TemplateField>
                    
                    <asp:TemplateField HeaderText="Activity Stats">
                        <ItemTemplate>
                            <div class="d-flex flex-wrap gap-2">
                                <span class="badge badge-light">
                                    <i class="fas fa-users"></i>
                                    <%# GetUserCount(Eval("MunicipalityId").ToString()) %> users
                                </span>
                                <span class="badge badge-light">
                                    <i class="fas fa-trash"></i>
                                    <%# GetWasteReportCount(Eval("MunicipalityId").ToString()) %> reports
                                </span>
                                <span class="badge badge-light">
                                    <i class="fas fa-home"></i>
                                    <%# GetUserCount(Eval("MunicipalityId").ToString()) %> residents
                                </span>
                            </div>
                        </ItemTemplate>
                    </asp:TemplateField>
                    
                    <asp:TemplateField HeaderText="Actions">
                        <ItemTemplate>
                            <div class="d-flex flex-wrap gap-2">
                                <button type="button" class="btn btn-primary btn-sm" onclick='editMunicipality("<%# Eval("MunicipalityId") %>")'>
                                    <i class="fas fa-edit"></i>
                                </button>
                                <button type="button" class="btn btn-info btn-sm" onclick='viewMunicipalityDetails("<%# Eval("MunicipalityId") %>")'>
                                    <i class="fas fa-eye"></i>
                                </button>
                                <button type="button" class="btn btn-secondary btn-sm" onclick='viewMunicipalityUsers("<%# Eval("MunicipalityId") %>")'>
                                    <i class="fas fa-users"></i>
                                </button>
                                <button type="button" class="btn btn-danger btn-sm" onclick='deleteMunicipality("<%# Eval("MunicipalityId") %>", "<%# Eval("Name") %>")'>
                                    <i class="fas fa-trash"></i>
                                </button>
                            </div>
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
                <EmptyDataTemplate>
                    <div class="empty-state" style="margin: 2rem;">
                        <i class="fas fa-city"></i>
                        <p>No municipalities found matching your criteria</p>
                    </div>
                </EmptyDataTemplate>
            </asp:GridView>
        </asp:Panel>
    </div>

    <!-- JavaScript functions -->
    <script>
    function openAddMunicipalityModal() {
        document.getElementById('<%= hdnMunicipalityId.ClientID %>').value = '';
        document.getElementById('modalTitle').innerText = 'Add New Municipality';
        document.getElementById('<%= btnDeleteMunicipality.ClientID %>').style.display = 'none';
        
        // Clear form fields
        document.getElementById('<%= txtMunicipalityId.ClientID %>').value = 'Auto-generated';
        document.getElementById('<%= txtMunicipalityName.ClientID %>').value = '';
        document.getElementById('<%= txtRegion.ClientID %>').value = '';
        document.getElementById('<%= txtPopulation.ClientID %>').value = '';
        document.getElementById('<%= txtArea.ClientID %>').value = '';
        document.getElementById('<%= txtEstablishedDate.ClientID %>').value = '';
        document.getElementById('<%= txtContactPerson.ClientID %>').value = '';
        document.getElementById('<%= txtDescription.ClientID %>').value = '';
        document.getElementById('<%= txtContactNumber.ClientID %>').value = '';
        document.getElementById('<%= txtEmail.ClientID %>').value = '';
        document.getElementById('<%= txtAddress.ClientID %>').value = '';
        document.getElementById('<%= ddlStatus.ClientID %>').value = 'Active';
        
        var modal = new bootstrap.Modal(document.getElementById('municipalityModal'));
        modal.show();
    }
    
    function editMunicipality(municipalityId) {
        document.getElementById('<%= hdnMunicipalityId.ClientID %>').value = municipalityId;
        document.getElementById('modalTitle').innerText = 'Edit Municipality';
        document.getElementById('<%= btnDeleteMunicipality.ClientID %>').style.display = 'inline-block';
        __doPostBack('ctl00$MainContent$hdnMunicipalityId', 'edit_' + municipalityId);
    }
    
    function viewMunicipalityDetails(municipalityId) {
        document.getElementById('<%= hdnMunicipalityId.ClientID %>').value = municipalityId;
        __doPostBack('ctl00$MainContent$hdnMunicipalityId', 'view_' + municipalityId);
    }
    
    function viewMunicipalityUsers(municipalityId) {
        window.location.href = 'Citizens.aspx?municipalityId=' + municipalityId;
    }
    
    function deleteMunicipality(municipalityId, municipalityName) {
        if (confirm('Are you sure you want to delete the municipality "' + municipalityName + '"? This action cannot be undone.')) {
            document.getElementById('<%= hdnMunicipalityId.ClientID %>').value = municipalityId;
            __doPostBack('ctl00$MainContent$hdnMunicipalityId', 'delete_' + municipalityId);
        }
    }
    
    function showActiveMunicipalities() {
        document.getElementById('<%= ddlStatusFilter.ClientID %>').value = 'Active';
        __doPostBack('ctl00$MainContent$btnApplyFilters', '');
    }
    
    function showLargeMunicipalities() {
        document.getElementById('<%= txtPopulationFrom.ClientID %>').value = '100000';
        __doPostBack('ctl00$MainContent$btnApplyFilters', '');
    }
    
    function showInactiveMunicipalities() {
        document.getElementById('<%= ddlStatusFilter.ClientID %>').value = 'Inactive';
        __doPostBack('ctl00$MainContent$btnApplyFilters', '');
    }
    
    // Run on page load
    document.addEventListener('DOMContentLoaded', function() {
        // Ensure text visibility
        document.querySelectorAll('.municipality-card *').forEach(element => {
            element.style.overflow = 'visible';
            element.style.whiteSpace = 'normal';
            element.style.wordWrap = 'break-word';
        });
        
        document.querySelectorAll('.users-table td, .users-table th').forEach(cell => {
            cell.style.whiteSpace = 'normal';
            cell.style.wordWrap = 'break-word';
            cell.style.maxWidth = 'none';
        });
    });
    </script>
</asp:Content>