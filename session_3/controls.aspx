<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="controls.aspx.cs" Inherits="uoh_projects.session_3.controls" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>UOH | THIRD SESSION | ASP.NET CONTROLS DEMO</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
    <style>
        :root {
            --primary: #4361ee;
            --secondary: #3f37c9;
            --success: #4cc9f0;
            --info: #4895ef;
            --warning: #f72585;
            --light: #f8f9fa;
            --dark: #212529;
        }
        
        body {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }
        
        .card {
            border: none;
            border-radius: 15px;
            transition: transform 0.3s, box-shadow 0.3s;
            overflow: hidden;
        }
        
        .card:hover {
            transform: translateY(-5px);
            box-shadow: 0 10px 20px rgba(0,0,0,0.1);
        }
        
        .card-header {
            background: linear-gradient(to right, var(--primary), var(--secondary));
            color: white;
            border-bottom: none;
            padding: 15px 20px;
        }
        
        .section-title {
            color: var(--primary);
            border-bottom: 2px solid var(--primary);
            padding-bottom: 10px;
            margin-bottom: 20px;
        }
        
        .btn-custom {
            background: linear-gradient(to right, var(--primary), var(--secondary));
            border: none;
            border-radius: 30px;
            padding: 10px 25px;
            color: white;
            font-weight: 600;
            transition: all 0.3s;
        }
        
        .btn-custom:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(0,0,0,0.2);
            color: white;
        }
        
        .form-control, .form-select {
            border-radius: 10px;
            padding: 12px 15px;
            border: 1px solid #e0e0e0;
        }
        
        .form-control:focus, .form-select:focus {
            border-color: var(--primary);
            box-shadow: 0 0 0 0.25rem rgba(67, 97, 238, 0.25);
        }
        
        .output-panel {
            background-color: #f8f9fa;
            border-radius: 10px;
            padding: 15px;
            min-height: 200px;
            border-left: 4px solid var(--primary);
        }
        
        .gridview-custom {
            border-radius: 10px;
            overflow: hidden;
            box-shadow: 0 0 10px rgba(0,0,0,0.05);
        }
        
        .gridview-custom th {
            background: linear-gradient(to right, var(--primary), var(--secondary));
            color: white;
            border: none;
            padding: 12px 15px;
        }
        
        .gridview-custom td {
            padding: 10px 15px;
            border-bottom: 1px solid #e0e0e0;
        }
        
        .gridview-custom tr:nth-child(even) {
            background-color: #f8f9fa;
        }
        
        .calendar-custom .ajax__calendar_container {
            border-radius: 10px;
            overflow: hidden;
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
        }
        
        .badge-custom {
            background: linear-gradient(to right, var(--primary), var(--secondary));
            border-radius: 30px;
            padding: 8px 15px;
            font-size: 14px;
        }
        
        .tab-content {
            border: 1px solid #dee2e6;
            border-top: none;
            border-radius: 0 0 10px 10px;
            padding: 20px;
        }
        
        .nav-tabs .nav-link {
            border-radius: 10px 10px 0 0;
            padding: 12px 25px;
            font-weight: 600;
        }
        
        .nav-tabs .nav-link.active {
            background: linear-gradient(to right, var(--primary), var(--secondary));
            color: white;
            border: none;
        }
        
        .banner-ad {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            border-radius: 10px;
            padding: 15px;
            color: white;
            text-align: center;
            margin-bottom: 20px;
        }
        
        .ad-container {
            position: relative;
            overflow: hidden;
            border-radius: 10px;
        }
        
        .ad-text {
            padding: 20px;
        }
        
        .ad-rotation {
            animation: colorChange 10s infinite;
        }
        
        @keyframes colorChange {
            0% { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); }
            33% { background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%); }
            66% { background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%); }
            100% { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); }
        }
    </style>
</head>
<body>
    <form id="form1" runat="server" class="container py-5">
        <div class="row justify-content-center mb-4">
            <div class="col-md-10 text-center text-white">
                <h1 class="display-4 fw-bold mb-3"><i class="fas fa-cogs me-3"></i>ASP.NET Controls Showcase</h1>
                <p class="lead">A comprehensive demonstration of all major ASP.NET Web Form controls and their events</p>
                <div class="mt-4">
                    <span class="badge bg-light text-dark me-2 p-2">Web Forms</span>
                    <span class="badge bg-light text-dark me-2 p-2">Server Controls</span>
                    <span class="badge bg-light text-dark me-2 p-2">Event Handling</span>
                    <span class="badge bg-light text-dark p-2">Data Binding</span>
                </div>
            </div>
        </div>

        <div class="row">
            <!-- Left Column - Input Controls -->
            <div class="col-md-6">
                <div class="card mb-4">
                    <div class="card-header">
                        <h4 class="mb-0"><i class="fas fa-keyboard me-2"></i>Input Controls</h4>
                    </div>
                    <div class="card-body">
                        <!-- Text Input -->
                        <div class="mb-3">
                            <label class="form-label">Text Box</label>
                            <asp:TextBox ID="txtName" runat="server" CssClass="form-control" placeholder="Enter your name"></asp:TextBox>
                            <asp:Button ID="btnGreet" runat="server" Text="Greet Me" CssClass="btn btn-custom mt-2" OnClick="btnGreet_Click" />
                        </div>
                        
                        <!-- Dropdown List -->
                        <div class="mb-3">
                            <label class="form-label">DropDown List</label>
                            <asp:DropDownList ID="DrpCalculationType" runat="server" CssClass="form-select" AutoPostBack="true" OnSelectedIndexChanged="DrpCalculationType_SelectedIndexChanged">
                                <asp:ListItem>Choose a symbol</asp:ListItem>
                                <asp:ListItem>Add</asp:ListItem>
                                <asp:ListItem>Subtract</asp:ListItem>
                                <asp:ListItem>Divide</asp:ListItem>
                                <asp:ListItem>Multiply</asp:ListItem>
                            </asp:DropDownList>
                        </div>
                        
                        <!-- Radio Button List -->
                        <div class="mb-3">
                            <label class="form-label">Radio Button List</label>
                            <asp:RadioButtonList ID="rblOptions" runat="server" CssClass="form-check" AutoPostBack="true" OnSelectedIndexChanged="rblOptions_SelectedIndexChanged">
                                <asp:ListItem Text="Option 1" Value="1" Selected="True"></asp:ListItem>
                                <asp:ListItem Text="Option 2" Value="2"></asp:ListItem>
                                <asp:ListItem Text="Option 3" Value="3"></asp:ListItem>
                            </asp:RadioButtonList>
                        </div>
                        
                        <!-- Checkbox List -->
                        <div class="mb-3">
                            <label class="form-label">Checkbox List</label>
                            <asp:CheckBoxList ID="cblInterests" runat="server" CssClass="form-check" AutoPostBack="true" OnSelectedIndexChanged="cblInterests_SelectedIndexChanged">
                                <asp:ListItem Text="Web Development" Value="web"></asp:ListItem>
                                <asp:ListItem Text="Mobile Development" Value="mobile"></asp:ListItem>
                                <asp:ListItem Text="Data Science" Value="data"></asp:ListItem>
                                <asp:ListItem Text="Cloud Computing" Value="cloud"></asp:ListItem>
                            </asp:CheckBoxList>
                        </div>
                        
                        <!-- File Upload -->
                        <div class="mb-3">
                            <label class="form-label">File Upload</label>
                            <asp:FileUpload ID="fileUpload" runat="server" CssClass="form-control" />
                            <asp:Button ID="btnUpload" runat="server" Text="Upload File" CssClass="btn btn-custom mt-2" OnClick="btnUpload_Click" />
                        </div>
                    </div>
                </div>
                
                <!-- Data Controls -->
                <div class="card mb-4">
                    <div class="card-header">
                        <h4 class="mb-0"><i class="fas fa-table me-2"></i>Data Controls</h4>
                    </div>
                    <div class="card-body">
                        <!-- GridView -->
                        <div class="mb-3">
                            <label class="form-label">GridView</label>
                            <asp:GridView ID="GridView1" runat="server" CssClass="table table-striped gridview-custom" 
                                AutoGenerateColumns="true" AllowPaging="true" PageSize="3" OnPageIndexChanging="GridView1_PageIndexChanging">
                            </asp:GridView>
                        </div>
                        
                        <!-- Repeater -->
                        <div class="mb-3">
                            <label class="form-label">Repeater</label>
                            <asp:Repeater ID="Repeater1" runat="server">
                                <HeaderTemplate>
                                    <ul class="list-group">
                                </HeaderTemplate>
                                <ItemTemplate>
                                    <li class="list-group-item d-flex justify-content-between align-items-center">
                                        Item <%# Container.ItemIndex + 1 %>
                                        <span class="badge badge-custom"><%# Container.ItemIndex + 1 %></span>
                                    </li>
                                </ItemTemplate>
                                <FooterTemplate>
                                    </ul>
                                </FooterTemplate>
                            </asp:Repeater>
                        </div>
                    </div>
                </div>
            </div>
            
            <!-- Right Column - Display and Interactive Controls -->
            <div class="col-md-6">
                <!-- Banner Ad Replacement -->
                <div class="ad-container mb-4">
                    <div class="banner-ad ad-rotation">
                        <div class="ad-text">
                            <h5><i class="fas fa-ad me-2"></i>ASP.NET Web Forms Demo</h5>
                            <p class="mb-0">Experience the power of server controls and event-driven programming</p>
                        </div>
                    </div>
                </div>
                
                <div class="card mb-4">
                    <div class="card-header">
                        <h4 class="mb-0"><i class="fas fa-desktop me-2"></i>Display & Interactive Controls</h4>
                    </div>
                    <div class="card-body">
                        <!-- Tabs -->
                        <ul class="nav nav-tabs" id="myTab" role="tablist">
                            <li class="nav-item" role="presentation">
                                <button class="nav-link active" id="home-tab" data-bs-toggle="tab" data-bs-target="#home" type="button" role="tab">Details</button>
                            </li>
                            <li class="nav-item" role="presentation">
                                <button class="nav-link" id="profile-tab" data-bs-toggle="tab" data-bs-target="#profile" type="button" role="tab">Settings</button>
                            </li>
                            <li class="nav-item" role="presentation">
                                <button class="nav-link" id="contact-tab" data-bs-toggle="tab" data-bs-target="#contact" type="button" role="tab">Help</button>
                            </li>
                        </ul>
                        <div class="tab-content" id="myTabContent">
                            <div class="tab-pane fade show active" id="home" role="tabpanel">
                                <p>This is a demonstration of tab controls in ASP.NET. You can implement similar functionality using MultiView control.</p>
                                <asp:MultiView ID="MultiView1" runat="server" ActiveViewIndex="0" OnActiveViewChanged="MultiView1_ActiveViewChanged">
                                    <asp:View ID="View1" runat="server">
                                        <div class="alert alert-info">This is View 1 content</div>
                                        <asp:Button ID="btnNextView" runat="server" Text="Go to View 2" CssClass="btn btn-custom" OnClick="btnNextView_Click" />
                                    </asp:View>
                                    <asp:View ID="View2" runat="server">
                                        <div class="alert alert-warning">This is View 2 content</div>
                                        <asp:Button ID="btnPrevView" runat="server" Text="Back to View 1" CssClass="btn btn-custom" OnClick="btnPrevView_Click" />
                                    </asp:View>
                                </asp:MultiView>
                            </div>
                            <div class="tab-pane fade" id="profile" role="tabpanel">
                                <p>Settings panel would go here with various configuration options.</p>
                                <div class="form-check">
                                    <asp:CheckBox ID="chkSetting1" runat="server" CssClass="form-check-input" Text="Enable notifications" AutoPostBack="true" OnCheckedChanged="chkSetting1_CheckedChanged" />
                                </div>
                            </div>
                            <div class="tab-pane fade" id="contact" role="tabpanel">
                                <p>Help and documentation would be displayed in this section.</p>
                                <asp:Button ID="btnShowHelp" runat="server" Text="Show Help Message" CssClass="btn btn-custom" OnClick="btnShowHelp_Click" />
                            </div>
                        </div>
                        
                        <!-- Calendar -->
                        <div class="mb-3 mt-4">
                            <label class="form-label">Calendar Control</label>
                            <asp:Calendar ID="Calendar1" runat="server" CssClass="calendar-custom w-100" 
                                OnSelectionChanged="Calendar1_SelectionChanged"
                                DayNameFormat="Short" NextPrevFormat="ShortMonth"
                                SelectionMode="DayWeekMonth" SelectWeekText="Select Week">
                                <TitleStyle BackColor="#4361ee" ForeColor="White" Height="30px" />
                                <SelectedDayStyle BackColor="#3f37c9" ForeColor="White" />
                                <SelectorStyle BackColor="#4cc9f0" />
                                <WeekendDayStyle BackColor="#f8f9fa" />
                                <OtherMonthDayStyle ForeColor="#cccccc" />
                            </asp:Calendar>
                        </div>
                    </div>
                </div>
                
                <!-- Validation & Output -->
                <div class="card mb-4">
                    <div class="card-header">
                        <h4 class="mb-0"><i class="fas fa-check-circle me-2"></i>Validation & Output</h4>
                    </div>
                    <div class="card-body">
                        <!-- Validation Controls -->
                        <div class="mb-3">
                            <label class="form-label">Email Validation</label>
                            <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control" placeholder="Enter email" AutoPostBack="true" OnTextChanged="txtEmail_TextChanged"></asp:TextBox>
                            <asp:RegularExpressionValidator ID="regexEmail" runat="server" 
                                ControlToValidate="txtEmail" 
                                ValidationExpression="\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*" 
                                ErrorMessage="Invalid email format" 
                                CssClass="text-danger small" Display="Dynamic"></asp:RegularExpressionValidator>
                            <asp:RequiredFieldValidator ID="reqEmail" runat="server" 
                                ControlToValidate="txtEmail" 
                                ErrorMessage="Email is required" 
                                CssClass="text-danger small" Display="Dynamic"></asp:RequiredFieldValidator>
                        </div>
                        
                        <!-- Output Panel -->
                        <div class="mb-3">
                            <label class="form-label">Control Events Output</label>
                            <div class="output-panel">
                                <asp:Label ID="lblOutput" runat="server" Text="Events and actions will be displayed here..."></asp:Label>
                                <asp:BulletedList ID="BulletedList1" runat="server" BulletStyle="Circle" CssClass="mt-2">
                                </asp:BulletedList>
                            </div>
                        </div>
                        
                        <!-- Progress Bar -->
                        <div class="mb-3">
                            <label class="form-label">Progress Bar Simulation</label>
                            <div class="progress" style="height: 25px; border-radius: 10px;">
                                <asp:Panel ID="progressBar" runat="server" CssClass="progress-bar progress-bar-striped progress-bar-animated" 
                                    role="progressbar" style="width: 0%; border-radius: 10px;" 
                                    aria-valuenow="0" aria-valuemin="0" aria-valuemax="100">
                                    0%
                                </asp:Panel>
                            </div>
                            <asp:Button ID="btnStartProgress" runat="server" Text="Start Progress" 
                                CssClass="btn btn-custom mt-2" OnClick="btnStartProgress_Click" />
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <!-- In the MultiView section -->
        <asp:MultiView ID="MultiView2" runat="server" ActiveViewIndex="0" OnActiveViewChanged="MultiView1_ActiveViewChanged">
            <asp:View ID="View3" runat="server">
                <div class="alert alert-info">This is View 1 content</div>
                <asp:Button ID="Button1" runat="server" Text="Go to View 2" CssClass="btn btn-custom" OnClick="btnNextView_Click" />
            </asp:View>
            <asp:View ID="View4" runat="server">
                <div class="alert alert-warning">This is View 2 content</div>
                <asp:Button ID="Button2" runat="server" Text="Back to View 1" CssClass="btn btn-custom" OnClick="btnPrevView_Click" />
            </asp:View>
        </asp:MultiView>

        <!-- In the Settings tab -->
        <div class="form-check">
            <asp:CheckBox ID="CheckBox1" runat="server" CssClass="form-check-input" Text="Enable notifications" 
                AutoPostBack="true" OnCheckedChanged="chkSetting1_CheckedChanged" />
        </div>

        <!-- In the Help tab -->
        <asp:Button ID="Button3" runat="server" Text="Show Help Message" CssClass="btn btn-custom" OnClick="btnShowHelp_Click" />

        <!-- Footer -->
        <div class="row mt-4">
            <div class="col-12 text-center text-white">
                <p class="mb-0">University of Hobbies - ASP.NET Web Forms Controls Demo</p>
                <p class="small">All controls and events demonstrated in a single page</p>
            </div>
        </div>
    </form>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>