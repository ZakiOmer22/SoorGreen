<%-- CompletePickup.aspx --%>
<%@ Page Title="Complete Pickup" Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true" CodeFile="CompletePickup.aspx.cs" Inherits="SoorGreen.CompletePickup" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .verification-card {
            background: var(--card-bg);
            border-radius: 16px;
            border: 1px solid var(--border-color);
            padding: 2rem;
            max-width: 600px;
            margin: 0 auto;
        }
        
        .verification-step {
            display: flex;
            align-items: center;
            margin-bottom: 1.5rem;
            padding: 1rem;
            border-radius: 12px;
            background: var(--bg-primary);
        }
        
        .step-icon {
            width: 50px;
            height: 50px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin-right: 1rem;
            font-size: 1.25rem;
            flex-shrink: 0;
        }
        
        .step-content {
            flex: 1;
        }
        
        .step-title {
            font-weight: 600;
            margin-bottom: 0.25rem;
            color: var(--text-primary);
        }
        
        .step-description {
            color: var(--text-secondary);
            font-size: 0.875rem;
        }
        
        .verification-form {
            background: var(--bg-primary);
            padding: 1.5rem;
            border-radius: 12px;
            margin: 2rem 0;
        }
        
        .qr-scanner {
            width: 100%;
            height: 300px;
            border: 2px dashed var(--border-color);
            border-radius: 12px;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            margin: 1rem 0;
            background: var(--bg-card);
        }
        
        .weight-input {
            font-size: 2rem;
            text-align: center;
            border: none;
            background: transparent;
            color: var(--text-primary);
            width: 100%;
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
                        <li class="breadcrumb-item active">Complete Pickup</li>
                    </ol>
                </nav>
                <h2>Complete Pickup Verification</h2>
            </div>
        </div>
        
        <div class="verification-card">
            <div class="text-center mb-4">
                <div class="step-icon" style="background: rgba(var(--primary-rgb), 0.1); color: var(--primary);">
                    <i class="fas fa-check-circle"></i>
                </div>
                <h3>Pickup Completion</h3>
                <p class="text-muted">Verify and complete the pickup process</p>
            </div>
            
            <!-- Current Pickup Info -->
            <div class="verification-step">
                <div class="step-icon" style="background: rgba(59, 130, 246, 0.1); color: var(--info);">
                    <i class="fas fa-info-circle"></i>
                </div>
                <div class="step-content">
                    <div class="step-title">Pickup Information</div>
                    <div class="step-description">
                        ID: <asp:Label ID="lblPickupId" runat="server" CssClass="fw-bold"></asp:Label> | 
                        Address: <asp:Label ID="lblAddress" runat="server" CssClass="fw-bold"></asp:Label>
                    </div>
                </div>
            </div>
            
            <!-- Verification Form -->
            <div class="verification-form">
                <h5 class="mb-3">Verification Details</h5>
                
                <!-- Actual Weight -->
                <div class="mb-3">
                    <label class="form-label">Actual Weight Collected (kg)</label>
                    <div class="input-group">
                        <asp:TextBox ID="txtActualWeight" runat="server" CssClass="form-control weight-input" 
                            TextMode="Number" step="0.1" min="0" placeholder="0.0"></asp:TextBox>
                        <span class="input-group-text">kg</span>
                    </div>
                    <div class="form-text">
                        Estimated: <asp:Label ID="lblEstimatedWeight" runat="server" CssClass="fw-bold"></asp:Label> kg
                    </div>
                </div>
                
                <!-- Waste Type Confirmation -->
                <div class="mb-3">
                    <label class="form-label">Waste Type Confirmation</label>
                    <asp:DropDownList ID="ddlWasteType" runat="server" CssClass="form-select">
                    </asp:DropDownList>
                </div>
                
                <!-- Condition Notes -->
                <div class="mb-3">
                    <label class="form-label">Condition Notes</label>
                    <asp:TextBox ID="txtConditionNotes" runat="server" CssClass="form-control" 
                        TextMode="MultiLine" Rows="3" 
                        placeholder="Any notes about the waste condition..."></asp:TextBox>
                </div>
                
                <!-- Photo Upload -->
                <div class="mb-3">
                    <label class="form-label">Upload Verification Photo</label>
                    <asp:FileUpload ID="fileVerificationPhoto" runat="server" CssClass="form-control" 
                        accept="image/*" />
                    <div class="form-text">Take a photo of the collected waste</div>
                </div>
                
                <!-- QR Code Scan -->
                <div class="mb-3">
                    <label class="form-label">QR Code Verification</label>
                    <div class="qr-scanner" id="qrScanner">
                        <i class="fas fa-qrcode fa-3x text-muted mb-3"></i>
                        <p class="text-muted">Scan QR code for verification</p>
                        <asp:Button ID="btnScanQR" runat="server" Text="Start Scanner" 
                            CssClass="btn btn-outline-primary" OnClick="btnScanQR_Click" />
                    </div>
                    <div class="form-text">Or manually enter QR code below</div>
                    <asp:TextBox ID="txtQRCode" runat="server" CssClass="form-control mt-2" 
                        placeholder="Enter QR code manually"></asp:TextBox>
                </div>
            </div>
            
            <!-- Action Buttons -->
            <div class="d-grid gap-2">
                <asp:Button ID="btnComplete" runat="server" Text="Complete & Submit" 
                    CssClass="btn btn-success btn-lg" OnClick="btnComplete_Click" />
                <asp:Button ID="btnCancel" runat="server" Text="Cancel" 
                    CssClass="btn btn-outline-secondary" OnClick="btnCancel_Click" />
            </div>
        </div>
    </div>
</asp:Content>