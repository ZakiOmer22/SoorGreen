<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="dashboard.aspx.cs" Inherits="uoh_projects.session_1.dashboard" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>UOH | FIRST SESSION |  Business Dashboard</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" />
</head>
<body>
    <form id="form1" runat="server">
        <div class="container mt-5">
            <div class="card shadow-lg">
                <div class="card-header bg-primary text-white">
                    <h4>Welcome to Your Business Dashboard</h4>
                </div>
                <div class="card-body">
                    <asp:Label ID="lblWelcome" runat="server" CssClass="h5"></asp:Label>
                    <hr />
                    <p>This is a placeholder for your business content.</p>

                    <asp:Button ID="btnLogout" runat="server" Text="Logout" CssClass="btn btn-danger" onclick="btnLogout_Click" />
                </div>
            </div>
        </div>
    </form>
</body>
</html>
