<%@ Page Title="Notifications" Language="C#" MasterPageFile="~/Pages/Citizen/Site.Master" AutoEventWireup="true" CodeFile="Notifications.aspx.cs" Inherits="SoorGreen.Citizen.Notifications" %>
<%@ Import Namespace="System.Web.Optimization" %>
<asp:Content ID="Content3" ContentPlaceHolderID="HeadContent" runat="server">
    <%: Styles.Render("~/Content/citizennotifications") %>
</asp:Content>
<asp:Content ID="Content4" ContentPlaceHolderID="ScriptsContent" runat="server">
    <%: Scripts.Render("~/bundles/citizennotifications") %>
</asp:Content>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Notifications - SoorGreen Citizen
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    

    <!-- Toaster Container -->
    <div class="toast-container" id="toastContainer"></div>

    <div class="notifications-container">
        <br />
        <br />
        <br />
        
        <div class="notifications-card">
            <!-- Header -->
            <div class="notifications-header">
                <h1 class="header-title">Notifications</h1>
                <div class="header-stats">
                    <div class="stat-badge" id="totalNotifications">0 Total</div>
                    <div class="stat-badge unread" id="unreadNotifications">0 Unread</div>
                </div>
                <div class="action-buttons">
                    <asp:Button ID="btnRefresh" runat="server" Text="Refresh" CssClass="btn-outline" OnClick="btnRefresh_Click" />
                    <asp:Button ID="btnMarkAllRead" runat="server" Text="Mark All Read" CssClass="btn-primary" OnClick="btnMarkAllRead_Click" />
                </div>
            </div>

            <!-- Filters -->
            <div class="filters-section">
                <div class="filter-group">
                    <span class="filter-label">Filter:</span>
                    <asp:DropDownList ID="ddlFilter" runat="server" CssClass="filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlFilter_SelectedIndexChanged">
                        <asp:ListItem Value="all">All Notifications</asp:ListItem>
                        <asp:ListItem Value="unread">Unread Only</asp:ListItem>
                        <asp:ListItem Value="read">Read Only</asp:ListItem>
                    </asp:DropDownList>
                </div>
                
                <div class="filter-group">
                    <span class="filter-label">Sort:</span>
                    <asp:DropDownList ID="ddlSort" runat="server" CssClass="filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlSort_SelectedIndexChanged">
                        <asp:ListItem Value="newest">Newest First</asp:ListItem>
                        <asp:ListItem Value="oldest">Oldest First</asp:ListItem>
                    </asp:DropDownList>
                </div>
            </div>

            <!-- Bulk Actions -->
            <div class="bulk-actions hidden" id="bulkActions">
                <div class="select-all">
                    <asp:CheckBox ID="cbSelectAll" runat="server" AutoPostBack="true" OnCheckedChanged="cbSelectAll_CheckedChanged" />
                    <span>Select All</span>
                </div>
                <asp:Button ID="btnBulkRead" runat="server" Text="Mark Selected Read" CssClass="btn-primary" OnClick="btnBulkRead_Click" />
                <asp:Button ID="btnBulkDelete" runat="server" Text="Delete Selected" CssClass="btn-danger" OnClick="btnBulkDelete_Click" />
                <asp:Button ID="btnClearSelection" runat="server" Text="Clear Selection" CssClass="btn-outline" OnClick="btnClearSelection_Click" />
            </div>

            <!-- Notifications List -->
            <div id="notificationsList" runat="server">
                <!-- Notifications will be populated here -->
            </div>

            <!-- Loading State -->
            <div id="loadingState" class="loading-state" style="display: none;">
                <div class="loading-spinner">
                    <i class="fas fa-spinner"></i>
                </div>
                <p>Loading notifications...</p>
            </div>
        </div>
    </div>

</asp:Content>