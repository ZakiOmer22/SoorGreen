<%@ Page Language="C#" AutoEventWireup="True" CodeBehind="Admin Dashboard.aspx.cs" Inherits="SoorGreen.Admin.Admin_Dashboard" %>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <div class="container mt-4">
        <div class="row mb-4">
            <div class="col">
                <h2 class="fw-bold">Welcome to SoorGreen Admin Dashboard</h2>
                <p class="text-muted">Manage your system efficiently using the tools below.</p>
            </div>
        </div>

        <div class="row g-4">
            <!-- Your existing dashboard cards here -->
            <div class="col-md-3">
                <div class="card text-center border-success">
                    <div class="card-body">
                        <i class="bi bi-people fs-1 text-success"></i>
                        <h5 class="card-title mt-3">Users</h5>
                        <p class="card-text text-muted">Manage registered users</p>
                        <a runat="server" href="~/Admin/Users.aspx" class="btn btn-success btn-sm">View</a>
                    </div>
                </div>
            </div>
            <!-- Add other cards... -->
        </div>
    </div>
</asp:Content>