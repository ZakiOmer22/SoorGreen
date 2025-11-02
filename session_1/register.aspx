<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="register.aspx.cs" Inherits="uoh_projects.session_1.register" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>UOH | FIRST SESSION | Business Registration</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" />
</head>
<body class="bg-light">
    <form id="form1" runat="server">
        <div class="container py-5">
            <div class="row justify-content-center">
                <div class="col-md-6">
                    <div class="card shadow-lg">
                        <div class="card-header bg-success text-white text-center">
                            <h4>Register Your Business</h4>
                        </div>
                        <div class="card-body">
                            <asp:Label ID="lblStatus" runat="server" CssClass="text-success"></asp:Label>

                            <div class="mb-3">
                                <label class="form-label">Business Name</label>
                                <asp:TextBox ID="txtBusinessName" runat="server" CssClass="form-control" />
                            </div>
                            <div class="mb-3">
                                <label class="form-label">Owner Name</label>
                                <asp:TextBox ID="txtOwner" runat="server" CssClass="form-control" />
                            </div>
                            <div class="mb-3">
                                <label class="form-label">Email</label>
                                <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control" TextMode="Email" />
                            </div>
                            <div class="mb-3">
                                <label class="form-label">Username</label>
                                <asp:TextBox ID="txtUsername" runat="server" CssClass="form-control" />
                            </div>
                            <div class="mb-3">
                                <label class="form-label">Password</label>
                                <asp:TextBox ID="txtPassword" runat="server" TextMode="Password" CssClass="form-control" />
                            </div>
                            <div class="d-grid">
                                <asp:Button ID="btnRegister" runat="server" Text="Register" CssClass="btn btn-success" onclick="btnRegister_Click" />
                            </div>
                            <hr />
                            <div class="text-center">
                                <asp:HyperLink ID="lnkBackToLogin" runat="server" NavigateUrl="first_page.aspx">Back to Login</asp:HyperLink>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>
