e<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="processing_page.aspx.cs" Inherits="uoh_projects.session_two.processing_page" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>UOH | SECOUND SESSION | PROCCESING PAGE</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" />
</head>
<body>
    <form id="form1" runat="server">
           <div class="container py-5">
                <div class="row justify-content-center">
                    <div class="col-md-6">
                        <div class="card shadow-lg">
                            <div class="card-header bg-success text-white text-center">
                                <h4> Page Proccesing Numbers</h4>
                            </div>
                            <div class="card-body">
                                <asp:Label ID="lblFail" runat="server" CssClass="text-danger"></asp:Label>
                                <asp:Label ID="lblSuccess" runat="server" CssClass="text-success"></asp:Label>

                                <div class="mb-3">
                                    <label class="form-label">Number One:</label>
                                    <asp:TextBox ID="txtNumberOne" runat="server" CssClass="form-control" />
                                </div>
                                <div class="mb-3">
                                    <label class="form-label">Number Two:</label>
                                    <asp:TextBox ID="txtNumberTwo" runat="server" CssClass="form-control" />
                                </div>
                                <div class="mb-3">
                                    <label class="form-label">Choose Symbol</label>
                                    <asp:DropDownList ID="DrpCalculationType" runat="server" class="form-control" ToolTip="Choose The Type of Calculation">
                                        <asp:ListItem>Choose a symbol</asp:ListItem>
                                        <asp:ListItem>Add</asp:ListItem>
                                        <asp:ListItem>Subtract</asp:ListItem>
                                        <asp:ListItem>Divide</asp:ListItem>
                                        <asp:ListItem>Multiply</asp:ListItem>
                                    </asp:DropDownList>
                                </div class="text-center text-info">
                                     <div class="mb-3">
                                     <asp:Label ID="lblResult" runat="server" CssClass="form-label text-info">Result:</asp:Label>
                                </div>
                                <div class="text-center">
                                    <asp:Button ID="btnCalculate" runat="server" Text="Calculate" CssClass="bg-success rounded-2 text-white p-3 border-2" OnClick="btnCalculate_Click" />
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
    </form>
</body>
</html>
