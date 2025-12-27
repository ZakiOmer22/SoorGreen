<%@ Page Title="User Profile" Language="C#" MasterPageFile="~/Pages/Citizen/Site.Master" AutoEventWireup="true" Inherits="SoorGreen.Citizen.UserProfile" Codebehind="UserProfile.aspx.cs" %>

<asp:Content ID="Content3" ContentPlaceHolderID="HeadContent" runat="server">
    <link href='<%= ResolveUrl("~/Content/Pages/Citizen/citizenuserprofile.css") %>' rel="stylesheet" />
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/flatpickr/dist/flatpickr.min.css">
</asp:Content>

<asp:Content ID="Content4" ContentPlaceHolderID="ScriptsContent" runat="server">
    <script src='<%= ResolveUrl("~/Scripts/Pages/Citizen/citizenuserprofile.js") %>'></script>
    <script src="https://cdn.jsdelivr.net/npm/flatpickr"></script>
</asp:Content>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    User Profile - SoorGreen Citizen
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    
    <!-- Toaster Container -->
    <div class="toast-container" id="toastContainer"></div>

    <div class="profile-container">
        <br />
        <br />
        <br />
        
        <!-- Profile Header -->
        <div class="profile-card">
            <div class="profile-header">
                <div class="profile-avatar" id="userAvatar" runat="server">SG</div>
                <div class="profile-info">
                    <h1 class="profile-name" id="userName" runat="server">Loading...</h1>
                    <div class="profile-role" id="userRole" runat="server">Citizen</div>
                    <div class="verification-badge" id="verificationBadge" runat="server">
                        <i class="fas fa-check-circle"></i>Verified Account
                    </div>
                </div>
            </div>
            
            <div class="profile-stats">
                <div class="stat-card">
                    <div class="stat-value" id="xpCredits" runat="server">0</div>
                    <div class="stat-label">XP Credits</div>
                </div>
                <div class="stat-card">
                    <div class="stat-value" id="totalReports" runat="server">0</div>
                    <div class="stat-label">Waste Reports</div>
                </div>
                <div class="stat-card">
                    <div class="stat-value" id="totalPickups" runat="server">0</div>
                    <div class="stat-label">Completed Pickups</div>
                </div>
                <div class="stat-card">
                    <div class="stat-value" id="kgRecycled" runat="server">0</div>
                    <div class="stat-label">Kg Recycled</div>
                </div>
            </div>
        </div>

        <div class="form-grid">
            <!-- Personal Information -->
            <div class="profile-card">
                <h3 class="section-title">Personal Information</h3>
                
                <div class="form-group">
                    <label class="form-label">Full Name</label>
                    <asp:TextBox ID="txtFullName" runat="server" CssClass="form-control" MaxLength="150"></asp:TextBox>
                </div>
                
                <div class="form-group">
                    <label class="form-label">Phone Number</label>
                    <asp:TextBox ID="txtPhone" runat="server" CssClass="form-control" MaxLength="20"></asp:TextBox>
                </div>
                
                <div class="form-group">
                    <label class="form-label">Email Address</label>
                    <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control" TextMode="Email" MaxLength="256"></asp:TextBox>
                </div>
                
                <div class="form-group">
                    <label class="form-label">User ID</label>
                    <asp:TextBox ID="txtUserId" runat="server" CssClass="form-control" ReadOnly="true"></asp:TextBox>
                </div>
                
                <div class="form-group">
                    <label class="form-label">Member Since</label>
                    <asp:TextBox ID="txtCreatedAt" runat="server" CssClass="form-control" ReadOnly="true"></asp:TextBox>
                </div>
                
                <div class="form-group">
                    <label class="form-label">Last Login</label>
                    <asp:TextBox ID="txtLastLogin" runat="server" CssClass="form-control" ReadOnly="true"></asp:TextBox>
                </div>
                
                <div class="button-group">
                    <asp:Button ID="btnUpdateProfile" runat="server" Text="Update Profile" CssClass="btn-primary" OnClick="btnUpdateProfile_Click" />
                    <asp:Button ID="btnCancelEdit" runat="server" Text="Cancel" CssClass="btn-outline" OnClick="btnCancelEdit_Click" Visible="false" />
                </div>
            </div>

            <!-- Password Change -->
            <div class="profile-card">
                <h3 class="section-title">Security Settings</h3>
                
                <div class="form-group">
                    <label class="form-label">Current Password</label>
                    <asp:TextBox ID="txtCurrentPassword" runat="server" CssClass="form-control" TextMode="Password"></asp:TextBox>
                </div>
                
                <div class="form-group">
                    <label class="form-label">New Password</label>
                    <asp:TextBox ID="txtNewPassword" runat="server" CssClass="form-control" TextMode="Password"></asp:TextBox>
                </div>
                
                <div class="form-group">
                    <label class="form-label">Confirm New Password</label>
                    <asp:TextBox ID="txtConfirmPassword" runat="server" CssClass="form-control" TextMode="Password"></asp:TextBox>
                </div>
                
                <div class="button-group">
                    <asp:Button ID="btnChangePassword" runat="server" Text="Change Password" CssClass="btn-primary" OnClick="btnChangePassword_Click" />
                </div>
                
                <div style="margin-top: 2rem; padding-top: 1.5rem; border-top: 1px solid rgba(255,255,255,0.1);">
                    <h4 style="color: rgba(255,255,255,0.9); margin-bottom: 1rem;">Account Actions</h4>
                    <div class="button-group">
                        <asp:Button ID="btnExportData" runat="server" Text="Export Data" CssClass="btn-outline" OnClick="btnExportData_Click" />
                        <asp:Button ID="btnDeleteAccount" runat="server" Text="Delete Account" CssClass="btn-outline" 
                            OnClientClick="return confirm('Are you sure you want to delete your account? This action cannot be undone.');" 
                            OnClick="btnDeleteAccount_Click" />
                    </div>
                </div>
            </div>
        </div>

        <!-- Recent Activity -->
        <div class="profile-card">
            <h3 class="section-title">Recent Activity</h3>
            <div id="activityList" runat="server">
                <!-- Activity items will be populated here -->
            </div>
        </div>
    </div>

    
</asp:Content>