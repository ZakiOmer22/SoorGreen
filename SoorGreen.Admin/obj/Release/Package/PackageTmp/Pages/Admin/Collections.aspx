<%@ Page Title="Collections" Language="C#" MasterPageFile="~/Pages/Admin/Site.master" AutoEventWireup="true" Inherits="SoorGreen.Admin.Admin.Collections" Codebehind="Collections.aspx.cs" %>

<asp:Content ID="Content3" ContentPlaceHolderID="HeadContent" runat="server">
    <link href='<%= ResolveUrl("~/Content/Pages/Admin/admincitizens.css") %>' rel="stylesheet" />
</asp:Content>

<asp:Content ID="PageTitle" ContentPlaceHolderID="PageTitle" runat="server">
    <div class="d-flex align-items-center">
        <h1 class="h3 mb-0" style="color: var(--text-primary);">Collections Management</h1>
    </div>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <!-- Message Panel -->
    <asp:Panel ID="pnlMessage" runat="server" CssClass="message-panel" Visible="false">
        <div class='message-alert' id="divMessage" runat="server">
            <i class='fas' id="iconMessage" runat="server"></i>
            <div>
                <strong>
                    <asp:Literal ID="litMessageTitle" runat="server"></asp:Literal></strong>
                <p class="mb-0">
                    <asp:Literal ID="litMessageText" runat="server"></asp:Literal></p>
            </div>
        </div>
    </asp:Panel>

    <!-- Collection Modal -->
    <div class="modal fade" id="collectionModal" tabindex="-1" role="dialog" aria-hidden="true">
        <div class="modal-dialog modal-lg" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="modalTitle">
                        <i class="fas fa-truck-loading me-2"></i>
                        <asp:Literal ID="litModalTitle" runat="server" Text="Collection Details"></asp:Literal>
                    </h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <asp:HiddenField ID="hdnPickupId" runat="server" />
                    <asp:HiddenField ID="hdnVerificationId" runat="server" />

                    <div class="row">
                        <!-- Left Column - Basic Info -->
                        <div class="col-md-6">
                            <h6 class="mb-3 border-bottom pb-2"><i class="fas fa-info-circle me-2"></i>Collection Information</h6>

                            <div class="mb-3">
                                <label class="form-label"><i class="fas fa-hashtag me-2"></i>Pickup ID</label>
                                <asp:TextBox ID="txtPickupId" runat="server" CssClass="form-control" ReadOnly="true"></asp:TextBox>
                            </div>

                            <div class="mb-3">
                                <label class="form-label"><i class="fas fa-trash me-2"></i>Waste Type</label>
                                <asp:TextBox ID="txtWasteType" runat="server" CssClass="form-control" ReadOnly="true"></asp:TextBox>
                            </div>

                            <div class="mb-3">
                                <label class="fas fa-user me-2"></i>Citizen</label>
                                <asp:TextBox ID="txtCitizen" runat="server" CssClass="form-control" ReadOnly="true"></asp:TextBox>
                            </div>

                            <div class="mb-3">
                                <label class="form-label"><i class="fas fa-truck me-2"></i>Collector</label>
                                <asp:DropDownList ID="ddlCollector" runat="server" CssClass="form-control">
                                </asp:DropDownList>
                            </div>

                            <div class="mb-3">
                                <label class="form-label"><i class="fas fa-map-marker-alt me-2"></i>Address</label>
                                <asp:TextBox ID="txtAddress" runat="server" CssClass="form-control" ReadOnly="true" TextMode="MultiLine" Rows="2"></asp:TextBox>
                            </div>
                        </div>

                        <!-- Right Column - Verification -->
                        <div class="col-md-6">
                            <h6 class="mb-3 border-bottom pb-2"><i class="fas fa-check-circle me-2"></i>Verification Details</h6>

                            <div class="row">
                                <div class="col-md-6 mb-3">
                                    <label class="form-label"><i class="fas fa-weight-hanging me-2"></i>Estimated Weight</label>
                                    <div class="input-group">
                                        <asp:TextBox ID="txtEstimatedKg" runat="server" CssClass="form-control" ReadOnly="true"></asp:TextBox>
                                        <span class="input-group-text">kg</span>
                                    </div>
                                </div>

                                <div class="col-md-6 mb-3">
                                    <label class="form-label"><i class="fas fa-weight me-2"></i>Verified Weight</label>
                                    <div class="input-group">
                                        <asp:TextBox ID="txtVerifiedKg" runat="server" CssClass="form-control"
                                            placeholder="Actual weight" required></asp:TextBox>
                                        <span class="input-group-text">kg</span>
                                    </div>
                                </div>
                            </div>

                            <div class="mb-3">
                                <label class="form-label"><i class="fas fa-recycle me-2"></i>Material Type</label>
                                <asp:TextBox ID="txtMaterialType" runat="server" CssClass="form-control"
                                    placeholder="e.g., Plastic Bottles, Cardboard, etc." required></asp:TextBox>
                            </div>

                            <div class="mb-3">
                                <label class="form-label"><i class="fas fa-clipboard-check me-2"></i>Verification Method</label>
                                <asp:DropDownList ID="ddlVerificationMethod" runat="server" CssClass="form-control">
                                    <asp:ListItem Value="Scale">Scale Measurement</asp:ListItem>
                                    <asp:ListItem Value="Visual">Visual Estimation</asp:ListItem>
                                    <asp:ListItem Value="MobileApp">Mobile App</asp:ListItem>
                                    <asp:ListItem Value="Manual">Manual Entry</asp:ListItem>
                                </asp:DropDownList>
                            </div>

                            <div class="mb-3">
                                <label class="form-label"><i class="fas fa-sticky-note me-2"></i>Notes</label>
                                <asp:TextBox ID="txtNotes" runat="server" CssClass="form-control"
                                    TextMode="MultiLine" Rows="3" placeholder="Any additional notes or observations..."></asp:TextBox>
                            </div>

                            <div class="alert alert-info">
                                <i class="fas fa-coins me-2"></i>
                                <strong>Credits Calculation:</strong>
                                <div class="mt-1">
                                    <span id="creditsCalculation" runat="server">Credits will be calculated after verification</span>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <asp:Button ID="btnVerifyCollection" runat="server" CssClass="btn btn-success"
                        Text="Verify Collection" OnClick="btnVerifyCollection_Click" />
                    <asp:Button ID="btnUpdateCollection" runat="server" CssClass="btn btn-primary"
                        Text="Update Verification" OnClick="btnUpdateCollection_Click" Visible="false" />
                    <asp:Button ID="btnCancelPickup" runat="server" CssClass="btn btn-danger"
                        Text="Cancel Pickup" OnClick="btnCancelPickup_Click" Visible="false"
                        OnClientClick="return confirm('Are you sure you want to cancel this pickup?');" />
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
                    <label class="form-label"><i class="fas fa-search me-2"></i>Search Collections</label>
                    <div class="position-relative">
                        <i class="fas fa-search search-icon"></i>
                        <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control search-input"
                            placeholder="Search by ID, citizen, collector, address..."></asp:TextBox>
                    </div>
                </div>
                <div class="form-group">
                    <label class="form-label"><i class="fas fa-info-circle me-2"></i>Status</label>
                    <div class="select-with-icon">
                        <asp:DropDownList ID="ddlStatus" runat="server" CssClass="form-control">
                            <asp:ListItem Value="all">All Status</asp:ListItem>
                            <asp:ListItem Value="Requested">Requested</asp:ListItem>
                            <asp:ListItem Value="Assigned">Assigned</asp:ListItem>
                            <asp:ListItem Value="InProgress">In Progress</asp:ListItem>
                            <asp:ListItem Value="Collected">Collected</asp:ListItem>
                            <asp:ListItem Value="Completed">Completed</asp:ListItem>
                            <asp:ListItem Value="Cancelled">Cancelled</asp:ListItem>
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
                        <asp:Button ID="btnApplyFilters" runat="server" Style="display: none;" OnClick="btnApplyFilters_Click" />
                    </div>
                </div>
            </div>
        </div>

        <!-- Stats Cards -->
        <div class="d-flex gap-3 mb-4 flex-wrap">
            <div class="stats-card users" style="flex: 1; min-width: 200px;">
                <div class="stats-icon">
                    <i class="fas fa-truck"></i>
                </div>
                <div class="stats-number" id="statTotal" runat="server">0</div>
                <div class="stats-label">Total Collections</div>
            </div>
            <div class="stats-card active" style="flex: 1; min-width: 200px;">
                <div class="stats-icon">
                    <i class="fas fa-clock"></i>
                </div>
                <div class="stats-number text-warning" id="statActive" runat="server">0</div>
                <div class="stats-label">Active</div>
            </div>
            <div class="stats-card pickups" style="flex: 1; min-width: 200px;">
                <div class="stats-icon">
                    <i class="fas fa-check-circle"></i>
                </div>
                <div class="stats-number text-success" id="statCompleted" runat="server">0</div>
                <div class="stats-label">Completed</div>
            </div>
            <div class="stats-card waste" style="flex: 1; min-width: 200px;">
                <div class="stats-icon">
                    <i class="fas fa-weight-hanging"></i>
                </div>
                <div class="stats-number text-primary" id="statTotalWeight" runat="server">0 kg</div>
                <div class="stats-label">Total Collected</div>
            </div>
        </div>

        <!-- Quick Actions -->
        <div class="filter-card mb-4">
            <h5 class="mb-4"><i class="fas fa-bolt me-2"></i>Quick Actions</h5>
            <div class="d-flex flex-wrap gap-3">
                <button type="button" class="btn btn-success btn-with-icon" onclick="showPendingCollections()">
                    <i class="fas fa-list me-2"></i>View Pending
                </button>
                <button type="button" class="btn btn-warning btn-with-icon" onclick="showUnassignedCollections()">
                    <i class="fas fa-user-slash me-2"></i>Unassigned
                </button>
                <button type="button" class="btn btn-info btn-with-icon" onclick="showTodayCollections()">
                    <i class="fas fa-calendar-day me-2"></i>Today's Collections
                </button>
                <button type="button" class="btn btn-primary btn-with-icon" onclick="__doPostBack('ctl00$MainContent$btnExportCSV', '')">
                    <i class="fas fa-file-export me-2"></i>Export Report
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
                    <i class="fas fa-truck me-2"></i>
                    Showing
                    <asp:Label ID="lblCollectionCount" runat="server" Text="0"></asp:Label>
                    collections
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
            <asp:Repeater ID="rptCollectionsGrid" runat="server"
                OnItemDataBound="rptCollectionsGrid_ItemDataBound">
                <ItemTemplate>
                    <div class="user-card">
                        <div class="d-flex justify-content-between align-items-start mb-2">
                            <h5>
                                <i class="fas fa-truck me-2"></i>Collection #<%# Eval("PickupId") %>
                            </h5>
                            <span class="badge <%# GetStatusBadgeClass(Eval("Status").ToString()) %>">
                                <%# Eval("Status") %>
                            </span>
                        </div>

                        <div class="mb-3">
                            <span class="text-muted small">
                                <i class="fas fa-calendar me-1"></i>
                                <%# Convert.ToDateTime(Eval("CreatedAt")).ToString("MMM dd, yyyy") %>
                                <%# Eval("ScheduledAt") != DBNull.Value ? " • Scheduled: " + Convert.ToDateTime(Eval("ScheduledAt")).ToString("MMM dd") : "" %>
                            </span>
                        </div>

                        <div class="collection-info">
                            <div class="info-row">
                                <i class="fas fa-user"></i>
                                <div>
                                    <span class="label">Citizen</span>
                                    <span class="value"><%# Eval("CitizenName") %></span>
                                </div>
                            </div>

                            <div class="info-row">
                                <i class="fas fa-truck"></i>
                                <div>
                                    <span class="label">Collector</span>
                                    <span class="value"><%# Eval("CollectorName") != DBNull.Value ? Eval("CollectorName") : "<span class='text-muted'>Not assigned</span>" %></span>
                                </div>
                            </div>

                            <div class="info-row">
                                <i class="fas fa-trash"></i>
                                <div>
                                    <span class="label">Waste Type</span>
                                    <span class="value"><%# Eval("WasteTypeName") %></span>
                                </div>
                            </div>

                            <div class="info-row">
                                <i class="fas fa-weight-hanging"></i>
                                <div>
                                    <span class="label">Weight</span>
                                    <span class="value">
                                        <%# Eval("EstimatedKg") %> kg
                                        <%# Eval("VerifiedKg") != DBNull.Value ? "<small class='text-success ms-2'>✓ " + Eval("VerifiedKg") + " kg verified</small>" : "" %>
                                    </span>
                                </div>
                            </div>

                            <div class="info-row">
                                <i class="fas fa-map-marker-alt"></i>
                                <div>
                                    <span class="label">Address</span>
                                    <span class="value truncate-text"><%# Eval("Address") %></span>
                                </div>
                            </div>
                        </div>

                        <div class="card-stats">
                            <div class="stat-item">
                                <span class="stat-value <%# GetCreditsColor(Eval("CreditsEarned")) %>">
                                    <%# Eval("CreditsEarned") != DBNull.Value ? "$" + Eval("CreditsEarned") : "-" %>
                                </span>
                                <span class="stat-label">Credits</span>
                            </div>
                            <div class="stat-item">
                                <span class="stat-value text-primary">
                                    <%# GetLocationDisplay(Eval("Lat"), Eval("Lng")) %>
                                </span>
                                <span class="stat-label">Location</span>
                            </div>
                            <div class="stat-item">
                                <span class="stat-value <%# GetCompletionTimeClass(Eval("CompletionTime")) %>">
                                    <%# GetCompletionTimeDisplay(Eval("CompletionTime")) %>
                                </span>
                                <span class="stat-label">Time</span>
                            </div>
                        </div>

                        <div class="action-buttons">
                            <button type="button" class="btn btn-primary" onclick='viewCollection("<%# Eval("PickupId") %>")'>
                                <i class="fas fa-eye me-1"></i>View
                            </button>
                            <%# GetActionButton(Eval("Status").ToString(), Eval("PickupId").ToString(), Eval("CollectorId")) %>
                            <button type="button" class="btn btn-info" onclick='showRoute("<%# Eval("PickupId") %>")'>
                                <i class="fas fa-route me-1"></i>Route
                            </button>
                        </div>
                    </div>
                </ItemTemplate>
                <FooterTemplate>
                    <asp:Label ID="lblEmptyGrid" runat="server" Text="No collections found"
                        Visible='<%# rptCollectionsGrid.Items.Count == 0 %>' CssClass="empty-state">
                        <i class="fas fa-truck-slash"></i>
                        <p>No collections found matching your criteria</p>
                    </asp:Label>
                </FooterTemplate>
            </asp:Repeater>
        </asp:Panel>

        <!-- Table View -->
        <asp:Panel ID="pnlTableView" runat="server" CssClass="table-container" Visible="false">
            <asp:GridView ID="gvCollections" runat="server" AutoGenerateColumns="False"
                CssClass="users-table"
                EmptyDataText="No collections found" ShowHeaderWhenEmpty="true">
                <Columns>
                    <asp:TemplateField HeaderText="Collection ID">
                        <ItemTemplate>
                            <div class="d-flex align-items-center">
                                <div class="role-icon collection">
                                    <i class='fas fa-truck'></i>
                                </div>
                                <div>
                                    <strong><%# Eval("PickupId") %></strong><br>
                                    <small class="text-muted"><%# Convert.ToDateTime(Eval("CreatedAt")).ToString("MM/dd/yy") %></small>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="Citizen & Waste">
                        <ItemTemplate>
                            <div><strong><%# Eval("CitizenName") %></strong></div>
                            <small class="text-muted">
                                <i class="fas fa-trash"></i><%# Eval("WasteTypeName") %> • 
                                <%# Eval("EstimatedKg") %> kg
                            </small>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="Collector">
                        <ItemTemplate>
                            <div><%# Eval("CollectorName") != DBNull.Value ? Eval("CollectorName") : "<span class='text-muted'>Not assigned</span>" %></div>
                            <small class="text-muted"><%# Eval("CollectorPhone") %></small>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="Location">
                        <ItemTemplate>
                            <small><i class="fas fa-map-marker-alt"></i><%# Eval("Address") %></small><br>
                            <small><i class="fas fa-clock"></i>
                                <%# Eval("ScheduledAt") != DBNull.Value ? "Scheduled: " + Convert.ToDateTime(Eval("ScheduledAt")).ToString("MM/dd") : "No schedule" %>
                            </small>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="Status">
                        <ItemTemplate>
                            <div class="status-indicator">
                                <span class='status-dot <%# GetStatusClass(Eval("Status").ToString()) %>'></span>
                                <span class='<%# GetStatusColor(Eval("Status").ToString()) %>'>
                                    <%# Eval("Status") %>
                                </span>
                            </div>
                            <small class="text-muted">
                                <%# Eval("VerifiedKg") != DBNull.Value ? Eval("VerifiedKg") + " kg verified" : "Not verified" %>
                            </small>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="Credits">
                        <ItemTemplate>
                            <div class="d-flex align-items-center gap-2">
                                <i class="fas fa-coins text-warning"></i>
                                <div>
                                    <strong><%# Eval("CreditsEarned") != DBNull.Value ? "$" + Eval("CreditsEarned") : "-" %></strong>
                                    <div class="small text-muted">
                                        <%# Eval("CompletionTime") != DBNull.Value ? GetCompletionTimeDisplay(Eval("CompletionTime")) : "" %>
                                    </div>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="Actions">
                        <ItemTemplate>
                            <div class="d-flex gap-2">
                                <button type="button" class="btn btn-primary" onclick='viewCollection("<%# Eval("PickupId") %>")'>
                                    <i class="fas fa-eye"></i>
                                </button>
                                <%# GetActionButton(Eval("Status").ToString(), Eval("PickupId").ToString(), Eval("CollectorId")) %>
                                <button type="button" class="btn btn-info" onclick='showRoute("<%# Eval("PickupId") %>")'>
                                    <i class="fas fa-route"></i>
                                </button>
                            </div>
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
                <EmptyDataTemplate>
                    <div class="empty-state" style="margin: 2rem;">
                        <i class="fas fa-truck-slash"></i>
                        <p>No collections found matching your criteria</p>
                    </div>
                </EmptyDataTemplate>
            </asp:GridView>
        </asp:Panel>
    </div>

    <!-- Simple JavaScript functions -->
    <script>
        function viewCollection(pickupId) {
            // Set the pickup ID
            document.getElementById('<%= hdnPickupId.ClientID %>').value = pickupId;

            // Trigger server-side event to load data
            __doPostBack('ctl00$MainContent$hdnPickupId', 'view_' + pickupId);
        }

        function assignCollector(pickupId) {
            // Set the pickup ID
            document.getElementById('<%= hdnPickupId.ClientID %>').value = pickupId;

            // Trigger server-side event to load data for assignment
            __doPostBack('ctl00$MainContent$hdnPickupId', 'assign_' + pickupId);
        }

        function verifyCollection(pickupId) {
            // Set the pickup ID
            document.getElementById('<%= hdnPickupId.ClientID %>').value = pickupId;

            // Trigger server-side event to load data for verification
            __doPostBack('ctl00$MainContent$hdnPickupId', 'verify_' + pickupId);
        }

        function showRoute(pickupId) {
            alert('Show route for collection: ' + pickupId);
            // In a real application, you would open a map with the route
            // window.open('MapView.aspx?pickupId=' + pickupId, '_blank');
        }

        function showPendingCollections() {
            document.getElementById('<%= ddlStatus.ClientID %>').value = 'Requested';
            __doPostBack('ctl00$MainContent$btnApplyFilters', '');
        }

        function showUnassignedCollections() {
            document.getElementById('<%= ddlStatus.ClientID %>').value = 'Requested';
            // This would need additional filtering for unassigned
            __doPostBack('ctl00$MainContent$btnApplyFilters', '');
        }

        function showTodayCollections() {
            document.getElementById('<%= ddlDateFilter.ClientID %>').value = 'today';
            __doPostBack('ctl00$MainContent$btnApplyFilters', '');
        }

        // Update credits calculation in real-time
        function updateCreditsCalculation() {
            var verifiedKg = document.getElementById('<%= txtVerifiedKg.ClientID %>').value;
        var wasteType = document.getElementById('<%= txtWasteType.ClientID %>').value;
        var creditsSpan = document.getElementById('<%= creditsCalculation.ClientID %>');

            if (verifiedKg && wasteType) {
                creditsSpan.innerHTML = verifiedKg + ' kg × Credit Rate = $' + (parseFloat(verifiedKg) * 0.5).toFixed(2);
            }
        }
    </script>
</asp:Content>
