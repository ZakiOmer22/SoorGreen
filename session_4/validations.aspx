<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="validations.aspx.cs" Inherits="uoh_projects.session_4.validations" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
     <title>UOH | FOURTH SESSION | ASP.NET VALIDATION CONTROLS DEMO</title>
 <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" />
 <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
</head>
<body>
   <form id="form1" runat="server">
           <div class="container py-5">
                <div class="row justify-content-center">
                    <div class="col-md-12">
                        <div class="card shadow-lg">
                            <div class="card-header bg-success text-white text-center">
                                <h4> VALIDATIONS</h4>
                            </div>
                            <div class="card-body">
                                <asp:Label ID="lblFail" runat="server" CssClass="text-danger"></asp:Label>
                                <asp:Label ID="lblSuccess" runat="server" CssClass="text-success"></asp:Label>

                                <div class="mb-3">
                                <asp:Label ID="Label1" runat="server" CssClass="form-label">Required Field Validator</asp:Label>
                                    <asp:TextBox ID="txtReq" CssClass="form-control" runat="server" ToolTip="Required Field label" ></asp:TextBox>
                                    <asp:RequiredFieldValidator ID="RequriedValidator" runat="server" ErrorMessage="Required Field" Display="Dynamic" ForeColor="Red"  
                                        ControlToValidate="txtReq"></asp:RequiredFieldValidator>
                                </div>
                                <div class="mb-3">
                                <asp:Label ID="Label2" runat="server" CssClass="form-label"> Range Validator</asp:Label>
                                    <asp:TextBox ID="txtRangeValidator" CssClass="form-control" runat="server" ToolTip="Range Validator" ></asp:TextBox>
                                    <asp:RangeValidator ID="RangeValidator1" runat="server" ErrorMessage="Age Must Be Higher Than 18" Display="Dynamic"
                                        MinimumValue="18" MaximumValue="60" ForeColor="Red" ControlToValidate="txtRangeValidator"></asp:RangeValidator>
                                </div>
                                <div class="mb-3">
                                    <asp:Label ID="Label4" runat="server" CssClass="form-label"> Compare Validator</asp:Label>
                                        <asp:TextBox ID="txtComp1" CssClass="form-control" runat="server" ToolTip="Range Validator"></asp:TextBox>
                                        <asp:TextBox ID="txtComp2" CssClass="form-control" runat="server" ToolTip="Range Validator"></asp:TextBox>
                                        <asp:CompareValidator ID="CompareValidator1" runat="server" ErrorMessage="CompareValidator" ControlToCompare="txtComp1" ControlToValidate="txtComp2" ForeColor="Red" ToolTip="Compare Validator"></asp:CompareValidator>                                    
                                 </div>
                                 <div class="mb-3">
                                    <asp:Label ID="Label5" runat="server" CssClass="form-label"> Regex Patterns</asp:Label>
                                        <asp:TextBox ID="TextBox1" CssClass="form-control" runat="server" ToolTip="Range Validator"></asp:TextBox>
                                        <asp:TextBox ID="TextBox2" CssClass="form-control" runat="server" ToolTip="Range Validator"></asp:TextBox>
                                        <asp:CompareValidator ID="CompareValidator2" runat="server" ErrorMessage="CompareValidator" ControlToCompare="txtComp1" ControlToValidate="txtComp2" ForeColor="Red" ToolTip="Compare Validator"></asp:CompareValidator>                                    
                                  </div>
                                 <div class="mb-3">
                                 <asp:Label ID="Label3" runat="server" CssClass="form-label"> Validation Summary</asp:Label>
                                     <asp:ValidationSummary ID="ValidationSummary1" ShowSummary="true" ShowValidationErrors="true" ForeColor="Red" 
                                         runat="server" ShowMessageBox="true" DisplayMode="BulletList" Font-Bold="true" HeaderText="Validation Failed"/>
                                 </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
    </form>
</body>
</html>
