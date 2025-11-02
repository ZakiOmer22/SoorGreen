<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="first_page.aspx.cs" Inherits="uoh_projects.session_1.first_page" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>UOH | FIRST SESSION | Business Portal - Login / Register</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" />
</head>
<body class="bg-light">
    <form id="form1" runat="server">
        <div class="container py-5">
            <div class="row justify-content-center">
                <div class="col-md-6">
                    <div class="card shadow-lg">
                        <div class="card-header text-center bg-primary text-white">
                            <h4>Business Portal Login</h4>
                        </div>
                        <div class="card-body">
                            <asp:Label ID="lblMessage" runat="server" CssClass="text-danger"></asp:Label>

                            <div class="mb-3">
                                <label for="txtUsername" class="form-label">Username</label>
                                <asp:TextBox ID="txtUsername" runat="server" CssClass="form-control" />
                            </div>
                            <div class="mb-3">
                                <label for="txtPassword" class="form-label">Password</label>
                                <asp:TextBox ID="txtPassword" runat="server" TextMode="Password" CssClass="form-control" />
                            </div>
                            <div class="d-grid">
                                <asp:Button ID="btnLogin" runat="server" Text="Login" CssClass="btn btn-primary" onclick="btnLogin_Click" />
                            </div>
                            <hr />
                            <div class="text-center">
                                <p class="mb-1">Don't have an account?</p>
                                <asp:Button ID="btnRegisterRedirect" runat="server" Text="Register Your Business" CssClass="btn btn-outline-secondary" onclick="btnRegisterRedirect_Click" />
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>
