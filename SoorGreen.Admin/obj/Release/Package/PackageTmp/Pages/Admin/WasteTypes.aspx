<%@ Page Title="Waste Types" Language="C#" MasterPageFile="~/Pages/Admin/Site.master" AutoEventWireup="true" Inherits="SoorGreen.Admin.Admin.WasteTypes" Codebehind="WasteTypes.aspx.cs" %>

<asp:Content ID="Content3" ContentPlaceHolderID="HeadContent" runat="server">
    <link href='<%= ResolveUrl("~/Content/Pages/Admin/admincitizens.css") %>' rel="stylesheet" />
</asp:Content>

<asp:Content ID="PageTitle" ContentPlaceHolderID="PageTitle" runat="server">
    <div class="d-flex align-items-center">
        <h1 class="h3 mb-0" style="color: var(--text-primary);">Waste Types Management</h1>
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
    <div class="modal fade" id="wasteTypeModal" tabindex="-1" role="dialog" aria-hidden="true">
        <div class="modal-dialog" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="modalTitle">
                        <i class="fas fa-trash me-2"></i>
                        <asp:Literal ID="litModalTitle" runat="server" Text="Add New Waste Type"></asp:Literal>
                    </h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <asp:HiddenField ID="hdnWasteTypeId" runat="server" />
                    
                    <div class="mb-3">
                        <label class="form-label"><i class="fas fa-tag me-2"></i>Waste Type Name</label>
                        <asp:TextBox ID="txtName" runat="server" CssClass="form-control" 
                            placeholder="e.g., Plastic, Paper, Glass, etc." required></asp:TextBox>
                    </div>
                    
                    <div class="mb-3">
                        <label class="form-label"><i class="fas fa-coins me-2"></i>Credit Per Kg</label>
                        <div class="input-group">
                            <span class="input-group-text">$</span>
                            <asp:TextBox ID="txtCreditPerKg" runat="server" CssClass="form-control" 
                                placeholder="0.00" TextMode="Number" step="0.01" required></asp:TextBox>
                            <span class="input-group-text">per kg</span>
                        </div>
                        <small class="form-text text-muted">Credit amount citizens earn per kg of this waste type</small>
                    </div>
                    
                    <div class="mb-3">
                        <label class="form-label"><i class="fas fa-palette me-2"></i>Color Code</label>
                        <div class="input-group">
                            <asp:TextBox ID="txtColorCode" runat="server" CssClass="form-control" 
                                placeholder="#007bff" MaxLength="7"></asp:TextBox>
                            <span class="input-group-text">
                                <i class="fas fa-eye-dropper"></i>
                            </span>
                        </div>
                        <small class="form-text text-muted">Hex color code for UI representation (optional)</small>
                    </div>
                    
                    <div class="mb-3">
                        <label class="form-label"><i class="fas fa-info-circle me-2"></i>Description</label>
                        <asp:TextBox ID="txtDescription" runat="server" CssClass="form-control" 
                            TextMode="MultiLine" Rows="3" placeholder="Brief description of this waste type..."></asp:TextBox>
                    </div>
                    
                    <div class="mb-3">
                        <label class="form-label"><i class="fas fa-layer-group me-2"></i>Category</label>
                        <asp:DropDownList ID="ddlCategory" runat="server" CssClass="form-control">
                            <asp:ListItem Value="Recyclable">Recyclable</asp:ListItem>
                            <asp:ListItem Value="Organic">Organic</asp:ListItem>
                            <asp:ListItem Value="Hazardous">Hazardous</asp:ListItem>
                            <asp:ListItem Value="Electronic">Electronic</asp:ListItem>
                            <asp:ListItem Value="Other">Other</asp:ListItem>
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <asp:Button ID="btnSaveWasteType" runat="server" CssClass="btn btn-primary" 
                        Text="Save Waste Type" OnClick="btnSaveWasteType_Click" />
                    <asp:Button ID="btnDeleteWasteType" runat="server" CssClass="btn btn-danger" 
                        Text="Delete Waste Type" OnClick="btnDeleteWasteType_Click" Visible="false" 
                        OnClientClick="return confirm('Are you sure you want to delete this waste type?');" />
                </div>
            </div>
        </div>
    </div>

    <div class="users-container">
        <!-- Filter Card -->
        <div class="filter-card">
            <h5 class="mb-4"><i class="fas fa-sliders-h me-2"></i>Filter Options</h5>
            <div class="filter-group">
                <div class="form-group search-box">
                    <label class="form-label"><i class="fas fa-search me-2"></i>Search Waste Types</label>
                    <div class="position-relative">
                        <i class="fas fa-search search-icon"></i>
                        <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control search-input" 
                            placeholder="Search by name, category, description..."></asp:TextBox>
                    </div>
                </div>
                <div class="form-group">
                    <label class="form-label"><i class="fas fa-layer-group me-2"></i>Category</label>
                    <div class="select-with-icon">
                        <asp:DropDownList ID="ddlCategoryFilter" runat="server" CssClass="form-control">
                            <asp:ListItem Value="all">All Categories</asp:ListItem>
                            <asp:ListItem Value="Recyclable">Recyclable</asp:ListItem>
                            <asp:ListItem Value="Organic">Organic</asp:ListItem>
                            <asp:ListItem Value="Hazardous">Hazardous</asp:ListItem>
                            <asp:ListItem Value="Electronic">Electronic</asp:ListItem>
                            <asp:ListItem Value="Other">Other</asp:ListItem>
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
                            <i class="fas fa-plus me-2"></i>Add Waste Type
                        </button>
                    </div>
                </div>
            </div>
        </div>

        <!-- Stats Cards -->
        <div class="d-flex gap-3 mb-4 flex-wrap">
            <div class="stats-card users" style="flex: 1; min-width: 200px;">
                <div class="stats-icon">
                    <i class="fas fa-trash"></i>
                </div>
                <div class="stats-number" id="statTotal" runat="server">0</div>
                <div class="stats-label">Total Waste Types</div>
            </div>
            <div class="stats-card active" style="flex: 1; min-width: 200px;">
                <div class="stats-icon">
                    <i class="fas fa-recycle"></i>
                </div>
                <div class="stats-number text-success" id="statRecyclable" runat="server">0</div>
                <div class="stats-label">Recyclable</div>
            </div>
            <div class="stats-card pickups" style="flex: 1; min-width: 200px;">
                <div class="stats-icon">
                    <i class="fas fa-leaf"></i>
                </div>
                <div class="stats-number text-primary" id="statOrganic" runat="server">0</div>
                <div class="stats-label">Organic</div>
            </div>
            <div class="stats-card waste" style="flex: 1; min-width: 200px;">
                <div class="stats-icon">
                    <i class="fas fa-coins"></i>
                </div>
                <div class="stats-number text-warning" id="statAvgCredit" runat="server">$0.00</div>
                <div class="stats-label">Avg Credit/Kg</div>
            </div>
        </div>

        <!-- View Controls -->
        <div class="view-controls">
            <div class="d-flex align-items-center gap-3 flex-wrap">
                <div class="view-options">
                    <asp:LinkButton ID="btnCardView" runat="server" CssClass="view-btn active" 
                        OnClick="btnCardView_Click" CausesValidation="false">
                        <i class="fas fa-th-large me-2"></i>Card View
                    </asp:LinkButton>
                    <asp:LinkButton ID="btnTableView" runat="server" CssClass="view-btn" 
                        OnClick="btnTableView_Click" CausesValidation="false">
                        <i class="fas fa-table me-2"></i>Table View
                    </asp:LinkButton>
                </div>
                <div class="page-info">
                    <i class="fas fa-trash me-2"></i>
                    Showing <asp:Label ID="lblWasteTypeCount" runat="server" Text="0"></asp:Label> waste types
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

        <!-- Card View -->
        <asp:Panel ID="pnlCardView" runat="server" CssClass="users-grid">
            <asp:Repeater ID="rptWasteTypesGrid" runat="server" 
                OnItemDataBound="rptWasteTypesGrid_ItemDataBound">
                <ItemTemplate>
                    <div class="user-card">
                        <div class="d-flex justify-content-between align-items-start mb-3">
                            <div>
                                <h5>
                                    <i class="fas fa-trash me-2"></i><%# Eval("Name") %>
                                    <span class="badge ms-2" style='background-color: <%# GetColorCode(Eval("ColorCode")) %>'>
                                        <%# Eval("Category") %>
                                    </span>
                                </h5>
                                <div class="text-muted small">
                                    <i class="fas fa-hashtag me-1"></i><%# Eval("WasteTypeId") %>
                                </div>
                            </div>
                            <div class="text-end">
                                <div class="fs-4 fw-bold text-success">$<%# Eval("CreditPerKg", "{0:N2}") %></div>
                                <div class="small text-muted">per kg</div>
                            </div>
                        </div>
                        
                        <p>
                            <span><i class="fas fa-info-circle me-2"></i>Description:</span>
                            <span><%# string.IsNullOrEmpty(Eval("Description").ToString()) ? "No description" : Eval("Description") %></span>
                        </p>
                        
                        <div class="card-stats">
                            <div class="stat-item">
                                <span class="stat-value text-primary"><%# GetReportCount(Eval("WasteTypeId").ToString()) %></span>
                                <span class="stat-label">Reports</span>
                            </div>
                            <div class="stat-item">
                                <span class="stat-value text-warning"><%# GetTotalWeight(Eval("WasteTypeId").ToString()) %> kg</span>
                                <span class="stat-label">Total Weight</span>
                            </div>
                            <div class="stat-item">
                                <span class="stat-value text-success">$<%# GetTotalCredits(Eval("WasteTypeId").ToString()) %></span>
                                <span class="stat-label">Total Credits</span>
                            </div>
                        </div>
                        
                        <div class="action-buttons">
                            <button type="button" class="btn btn-primary" onclick='editWasteType("<%# Eval("WasteTypeId") %>")'>
                                <i class="fas fa-edit me-1"></i>Edit
                            </button>
                            <button type="button" class="btn btn-info" onclick='viewDetails("<%# Eval("WasteTypeId") %>")'>
                                <i class="fas fa-chart-bar me-1"></i>Stats
                            </button>
                            <%# GetDeleteButton(Eval("WasteTypeId").ToString()) %>
                        </div>
                    </div>
                </ItemTemplate>
                <FooterTemplate>
                    <asp:Label ID="lblEmptyGrid" runat="server" Text="No waste types found" 
                        Visible='<%# rptWasteTypesGrid.Items.Count == 0 %>' CssClass="empty-state">
                        <i class="fas fa-trash-slash"></i>
                        <p>No waste types found matching your criteria</p>
                    </asp:Label>
                </FooterTemplate>
            </asp:Repeater>
        </asp:Panel>

        <!-- Table View -->
        <asp:Panel ID="pnlTableView" runat="server" CssClass="table-container" Visible="false">
            <asp:GridView ID="gvWasteTypes" runat="server" AutoGenerateColumns="False" 
                CssClass="users-table" 
                EmptyDataText="No waste types found" ShowHeaderWhenEmpty="true">
                <Columns>
                    <asp:TemplateField HeaderText="ID">
                        <ItemTemplate>
                            <div class="d-flex align-items-center">
                                <div class="role-icon waste-type" style='background-color: <%# GetColorCode(Eval("ColorCode")) %>'>
                                    <i class='fas fa-trash'></i>
                                </div>
                                <strong><%# Eval("WasteTypeId") %></strong>
                            </div>
                        </ItemTemplate>
                    </asp:TemplateField>
                    
                    <asp:TemplateField HeaderText="Waste Type">
                        <ItemTemplate>
                            <div><strong><%# Eval("Name") %></strong></div>
                            <small class="text-muted"><%# Eval("Description") %></small>
                        </ItemTemplate>
                    </asp:TemplateField>
                    
                    <asp:TemplateField HeaderText="Category">
                        <ItemTemplate>
                            <span class="badge" style='background-color: <%# GetCategoryColor(Eval("Category").ToString()) %>'>
                                <%# Eval("Category") %>
                            </span>
                        </ItemTemplate>
                    </asp:TemplateField>
                    
                    <asp:TemplateField HeaderText="Credit Rate">
                        <ItemTemplate>
                            <div class="d-flex align-items-center gap-2">
                                <i class="fas fa-coins text-warning"></i>
                                <div>
                                    <strong>$<%# Eval("CreditPerKg", "{0:N2}") %></strong>
                                    <div class="small text-muted">per kg</div>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:TemplateField>
                    
                    <asp:TemplateField HeaderText="Usage Stats">
                        <ItemTemplate>
                            <small>Reports: <strong><%# GetReportCount(Eval("WasteTypeId").ToString()) %></strong></small><br>
                            <small>Weight: <strong><%# GetTotalWeight(Eval("WasteTypeId").ToString()) %> kg</strong></small>
                        </ItemTemplate>
                    </asp:TemplateField>
                    
                    <asp:TemplateField HeaderText="Actions">
                        <ItemTemplate>
                            <div class="d-flex gap-2">
                                <button type="button" class="btn btn-primary" onclick='editWasteType("<%# Eval("WasteTypeId") %>")'>
                                    <i class="fas fa-edit"></i>
                                </button>
                                <button type="button" class="btn btn-info" onclick='viewDetails("<%# Eval("WasteTypeId") %>")'>
                                    <i class="fas fa-chart-bar"></i>
                                </button>
                                <%# GetDeleteButton(Eval("WasteTypeId").ToString()) %>
                            </div>
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
                <EmptyDataTemplate>
                    <div class="empty-state" style="margin: 2rem;">
                        <i class="fas fa-trash-slash"></i>
                        <p>No waste types found matching your criteria</p>
                    </div>
                </EmptyDataTemplate>
            </asp:GridView>
        </asp:Panel>
    </div>

    <!-- Simple JavaScript functions -->
    <script>
    function showAddModal() {
        // Reset form
        document.getElementById('<%= hdnWasteTypeId.ClientID %>').value = '';
        document.getElementById('<%= litModalTitle.ClientID %>').innerText = 'Add New Waste Type';
        document.getElementById('<%= btnDeleteWasteType.ClientID %>').style.display = 'none';
        
        // Clear form fields
        document.getElementById('<%= txtName.ClientID %>').value = '';
        document.getElementById('<%= txtCreditPerKg.ClientID %>').value = '';
        document.getElementById('<%= txtColorCode.ClientID %>').value = '#007bff';
        document.getElementById('<%= txtDescription.ClientID %>').value = '';
        document.getElementById('<%= ddlCategory.ClientID %>').selectedIndex = 0;
        
        // Show modal
        var modal = new bootstrap.Modal(document.getElementById('wasteTypeModal'));
        modal.show();
    }
    
    function editWasteType(wasteTypeId) {
        // Set the waste type ID
        document.getElementById('<%= hdnWasteTypeId.ClientID %>').value = wasteTypeId;
        document.getElementById('<%= litModalTitle.ClientID %>').innerText = 'Edit Waste Type';
        document.getElementById('<%= btnDeleteWasteType.ClientID %>').style.display = 'inline-block';
        
        // Trigger server-side event to load data
        __doPostBack('ctl00$MainContent$hdnWasteTypeId', 'edit_' + wasteTypeId);
    }
    
    function viewDetails(wasteTypeId) {
        alert('View detailed statistics for waste type: ' + wasteTypeId);
    }
    </script>
</asp:Content>