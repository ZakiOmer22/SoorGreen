<%-- DailyReport.aspx --%>
<%@ Page Title="Daily Report" Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true" CodeFile="DailyReport.aspx.cs" Inherits="SoorGreen.DailyReport" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .report-card {
            background: var(--card-bg);
            border-radius: 16px;
            border: 1px solid var(--border-color);
            padding: 2rem;
            margin-bottom: 2rem;
        }
        
        .summary-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 1rem;
            margin: 2rem 0;
        }
        
        .summary-item {
            text-align: center;
            padding: 1.5rem;
            border-radius: 12px;
            background: var(--bg-primary);
        }
        
        .summary-value {
            font-size: 2rem;
            font-weight: 700;
            margin-bottom: 0.5rem;
        }
        
        .waste-breakdown {
            display: flex;
            gap: 1rem;
            margin: 1rem 0;
            flex-wrap: wrap;
        }
        
        .waste-item {
            flex: 1;
            min-width: 150px;
            padding: 1rem;
            border-radius: 10px;
            text-align: center;
            background: var(--bg-primary);
        }
        
        .waste-icon {
            font-size: 1.5rem;
            margin-bottom: 0.5rem;
        }
        
        .signature-pad {
            width: 100%;
            height: 200px;
            border: 2px dashed var(--border-color);
            border-radius: 12px;
            background: white;
            margin: 1rem 0;
            cursor: crosshair;
        }
    </style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <div class="container">
        <div class="row mb-4">
            <div class="col-12">
                <nav aria-label="breadcrumb">
                    <ol class="breadcrumb">
                        <li class="breadcrumb-item"><a href="CollectorDashboard.aspx">Dashboard</a></li>
                        <li class="breadcrumb-item active">Daily Report</li>
                    </ol>
                </nav>
                <h2>Daily Collection Report</h2>
                <p class="text-muted">Submit your end-of-day report for <%= DateTime.Now.ToString("MMMM dd, yyyy") %></p>
            </div>
        </div>
        
        <div class="report-card">
            <h3 class="mb-4">Collection Summary</h3>
            
            <!-- Auto-filled Summary -->
            <div class="summary-grid">
                <div class="summary-item">
                    <div class="summary-value" style="color: var(--primary);">
                        <asp:Label ID="lblTotalPickups" runat="server" Text="0"></asp:Label>
                    </div>
                    <div class="summary-label">Total Pickups</div>
                </div>
                
                <div class="summary-item">
                    <div class="summary-value" style="color: var(--success);">
                        <asp:Label ID="lblTotalWeight" runat="server" Text="0"></asp:Label> kg
                    </div>
                    <div class="summary-label">Total Weight</div>
                </div>
                
                <div class="summary-item">
                    <div class="summary-value" style="color: var(--info);">
                        <asp:Label ID="lblTotalHours" runat="server" Text="0"></asp:Label> hrs
                    </div>
                    <div class="summary-label">Working Hours</div>
                </div>
                
                <div class="summary-item">
                    <div class="summary-value" style="color: var(--warning);">
                        <asp:Label ID="lblFuelUsed" runat="server" Text="0"></asp:Label> L
                    </div>
                    <div class="summary-label">Fuel Used</div>
                </div>
            </div>
            
            <!-- Waste Breakdown -->
            <h5 class="mt-4 mb-3">Waste Type Breakdown</h5>
            <div class="waste-breakdown">
                <asp:Repeater ID="rptWasteBreakdown" runat="server">
                    <ItemTemplate>
                        <div class="waste-item">
                            <div class="waste-icon">
                                <i class='<%# GetWasteIcon(Container.DataItem) %>'></i>
                            </div>
                            <div class="waste-type">
                                <%# Eval("WasteType") %>
                            </div>
                            <div class="waste-weight">
                                <strong><%# Eval("Weight") %> kg</strong>
                            </div>
                            <div class="waste-percentage">
                                <%# Eval("Percentage") %>%
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
        </div>
        
        <!-- Manual Input Form -->
        <div class="report-card">
            <h3 class="mb-4">Additional Information</h3>
            
            <div class="row">
                <div class="col-md-6">
                    <div class="mb-3">
                        <label class="form-label">Start Time</label>
                        <asp:TextBox ID="txtStartTime" runat="server" CssClass="form-control" 
                            TextMode="Time"></asp:TextBox>
                    </div>
                </div>
                
                <div class="col-md-6">
                    <div class="mb-3">
                        <label class="form-label">End Time</label>
                        <asp:TextBox ID="txtEndTime" runat="server" CssClass="form-control" 
                            TextMode="Time"></asp:TextBox>
                    </div>
                </div>
            </div>
            
            <div class="mb-3">
                <label class="form-label">Odometer Start (km)</label>
                <asp:TextBox ID="txtOdometerStart" runat="server" CssClass="form-control" 
                    TextMode="Number" step="0.1"></asp:TextBox>
            </div>
            
            <div class="mb-3">
                <label class="form-label">Odometer End (km)</label>
                <asp:TextBox ID="txtOdometerEnd" runat="server" CssClass="form-control" 
                    TextMode="Number" step="0.1"></asp:TextBox>
            </div>
            
            <div class="mb-3">
                <label class="form-label">Fuel Purchased (Liters)</label>
                <asp:TextBox ID="txtFuelPurchased" runat="server" CssClass="form-control" 
                    TextMode="Number" step="0.1"></asp:TextBox>
            </div>
            
            <div class="mb-3">
                <label class="form-label">Notes & Observations</label>
                <asp:TextBox ID="txtNotes" runat="server" CssClass="form-control" 
                    TextMode="MultiLine" Rows="4" 
                    placeholder="Any issues, observations, or special notes..."></asp:TextBox>
            </div>
            
            <div class="mb-3">
                <label class="form-label">Challenges Faced Today</label>
                <asp:CheckBoxList ID="cblChallenges" runat="server" CssClass="form-check">
                    <asp:ListItem Text="Traffic delays" Value="traffic"></asp:ListItem>
                    <asp:ListItem Text="Vehicle issues" Value="vehicle"></asp:ListItem>
                    <asp:ListItem Text="Access problems" Value="access"></asp:ListItem>
                    <asp:ListItem Text="Weather conditions" Value="weather"></asp:ListItem>
                    <asp:ListItem Text="Citizen not available" Value="citizen"></asp:ListItem>
                    <asp:ListItem Text="Waste not ready" Value="notready"></asp:ListItem>
                </asp:CheckBoxList>
            </div>
            
            <!-- Signature -->
            <div class="mb-3">
                <label class="form-label">Digital Signature</label>
                <div class="signature-pad" id="signaturePad"></div>
                <div class="d-flex gap-2 mt-2">
                    <button type="button" class="btn btn-outline-secondary" onclick="clearSignature()">Clear</button>
                    <asp:HiddenField ID="hfSignature" runat="server" />
                </div>
            </div>
            
            <!-- Submit -->
            <div class="d-grid gap-2 mt-4">
                <asp:Button ID="btnSubmitReport" runat="server" Text="Submit Daily Report" 
                    CssClass="btn btn-success btn-lg" OnClick="btnSubmitReport_Click" />
                <asp:Button ID="btnSaveDraft" runat="server" Text="Save as Draft" 
                    CssClass="btn btn-outline-primary" OnClick="btnSaveDraft_Click" />
                <asp:Button ID="btnCancel" runat="server" Text="Cancel" 
                    CssClass="btn btn-outline-secondary" OnClick="btnCancel_Click" />
            </div>
        </div>
    </div>
</asp:Content>

<asp:Content ID="ScriptsContent" ContentPlaceHolderID="ScriptsContent" runat="server">
    <!-- Signature Pad Library -->
    <script src="https://cdn.jsdelivr.net/npm/signature_pad@4.0.0/dist/signature_pad.umd.min.js"></script>
    
    <script>
        let signaturePad;
        
        document.addEventListener('DOMContentLoaded', function() {
            // Initialize signature pad
            const canvas = document.getElementById('signaturePad');
            if (canvas) {
                signaturePad = new SignaturePad(canvas);
                
                // Adjust canvas size
                function resizeCanvas() {
                    const ratio = Math.max(window.devicePixelRatio || 1, 1);
                    canvas.width = canvas.offsetWidth * ratio;
                    canvas.height = canvas.offsetHeight * ratio;
                    canvas.getContext("2d").scale(ratio, ratio);
                    signaturePad.clear();
                }
                
                window.addEventListener("resize", resizeCanvas);
                resizeCanvas();
            }
            
            // Auto-fill current time
            const now = new Date();
            const startTime = document.getElementById('<%= txtStartTime.ClientID %>');
            const endTime = document.getElementById('<%= txtEndTime.ClientID %>');
            
            if (startTime && !startTime.value) {
                // Default start time: 8 AM
                const defaultStart = new Date(now);
                defaultStart.setHours(8, 0, 0, 0);
                startTime.value = defaultStart.toTimeString().substring(0, 5);
            }
            
            if (endTime && !endTime.value) {
                // Default end time: current time or 5 PM if earlier
                const defaultEnd = new Date(now);
                if (defaultEnd.getHours() < 17) {
                    defaultEnd.setHours(17, 0, 0, 0);
                }
                endTime.value = defaultEnd.toTimeString().substring(0, 5);
            }
        });
        
        function clearSignature() {
            if (signaturePad) {
                signaturePad.clear();
                document.getElementById('<%= hfSignature.ClientID %>').value = '';
            }
        }
        
        // Save signature before submit
        function saveSignature() {
            if (signaturePad && !signaturePad.isEmpty()) {
                const signatureData = signaturePad.toDataURL();
                document.getElementById('<%= hfSignature.ClientID %>').value = signatureData;
                return true;
            }
            return true; // Allow submission even without signature
        }
    </script>
</asp:Content>