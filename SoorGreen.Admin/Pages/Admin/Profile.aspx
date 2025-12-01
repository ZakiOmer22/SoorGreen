<%@ Page Title="My Profile" Language="C#" MasterPageFile="~/Pages/Admin/Site.master" AutoEventWireup="true" CodeFile="Profile.aspx.cs" Inherits="SoorGreen.Admin.Admin.UserProfile" %>
<%@ Import Namespace="System.Web.Optimization" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <%: Styles.Render("~/Content/adminprofile") %>
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="ScriptsContent" runat="server">
    <%: Scripts.Render("~/bundles/adminprofile") %>
</asp:Content>
<asp:Content ID="PageTitle" ContentPlaceHolderID="PageTitle" runat="server">
    My Profile
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <asp:ScriptManager ID="ScriptManager1" runat="server" EnablePageMethods="true"></asp:ScriptManager>

   
    <div class="container-fluid">
        <div class="page-header">
            <h1 class="page-title">My Profile</h1>
            <p class="page-subtitle">Manage your account settings and preferences</p>
        </div>

        <div class="profile-container">
            <!-- Loading Spinner -->
            <div class="loading-spinner" id="loadingSpinner">
                <div class="spinner"></div>
                <p style="color: rgba(255, 255, 255, 0.7); margin-top: 1rem;">Loading profile...</p>
            </div>

            <!-- Profile Header -->
            <div class="profile-header">
                <div class="profile-avatar" id="profileAvatar">A</div>
                <h1 class="profile-name" id="profileName">Admin User</h1>
                <div class="profile-role" id="profileRole">Administrator</div>
                <div class="profile-stats">
                    <div class="stat-card">
                        <div class="stat-value" id="totalLogins">156</div>
                        <div class="stat-label">Total Logins</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-value" id="lastActive">2h</div>
                        <div class="stat-label">Last Active</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-value" id="memberSince">45</div>
                        <div class="stat-label">Days Active</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-value" id="accountStatus">Active</div>
                        <div class="stat-label">Status</div>
                    </div>
                </div>
            </div>

            <!-- Profile Content -->
            <div class="profile-content">
                <!-- Personal Information -->
                <div class="profile-card">
                    <div class="card-header">
                        <h3 class="card-title">Personal Information</h3>
                        <i class="fas fa-user card-icon"></i>
                    </div>

                    <div class="form-group">
                        <label class="form-label">Full Name</label>
                        <input type="text" class="form-control" id="fullName" value="Admin User">
                    </div>

                    <div class="form-group">
                        <label class="form-label">Email Address</label>
                        <input type="email" class="form-control" id="email" value="admin@soorgreen.com">
                    </div>

                    <div class="form-group">
                        <label class="form-label">Phone Number</label>
                        <input type="text" class="form-control" id="phone" value="+1-555-0123">
                    </div>

                    <div class="form-group">
                        <label class="form-label">User ID</label>
                        <input type="text" class="form-control" id="userId" value="U009" disabled>
                        <div class="form-text">Your unique user identifier</div>
                    </div>

                    <div class="form-group">
                        <label class="form-label">Role</label>
                        <input type="text" class="form-control" id="role" value="Administrator" disabled>
                        <div class="form-text">Your system access level</div>
                    </div>

                    <button type="button" class="btn-primary" id="savePersonalBtn" style="width: 100%;">
                        <i class="fas fa-save me-2"></i>Update Personal Information
                    </button>
                </div>

                <!-- Security Settings -->
                <div class="profile-card">
                    <div class="card-header">
                        <h3 class="card-title">Security Settings</h3>
                        <i class="fas fa-shield-alt card-icon"></i>
                    </div>

                    <div class="form-group">
                        <label class="form-label">Current Password</label>
                        <input type="password" class="form-control" id="currentPassword" placeholder="Enter current password">
                    </div>

                    <div class="form-group">
                        <label class="form-label">New Password</label>
                        <input type="password" class="form-control" id="newPassword" placeholder="Enter new password">
                        <div class="form-text">Minimum 8 characters with letters and numbers</div>
                    </div>

                    <div class="form-group">
                        <label class="form-label">Confirm New Password</label>
                        <input type="password" class="form-control" id="confirmPassword" placeholder="Confirm new password">
                    </div>

                    <button type="button" class="btn-primary" id="changePasswordBtn" style="width: 100%;">
                        <i class="fas fa-key me-2"></i>Change Password
                    </button>

                    <div style="margin-top: 2rem; padding-top: 1.5rem; border-top: 1px solid rgba(255, 255, 255, 0.1);">
                        <div class="form-group">
                            <label class="form-label">Two-Factor Authentication</label>
                            <div style="display: flex; justify-content: space-between; align-items: center;">
                                <span style="color: rgba(255, 255, 255, 0.9);">Status: <span id="twoFactorStatus" class="badge badge-warning">Disabled</span></span>
                                <button type="button" class="btn-secondary" id="enable2FABtn">
                                    <i class="fas fa-mobile-alt me-2"></i>Enable 2FA
                                </button>
                            </div>
                            <div class="form-text">Add an extra layer of security to your account</div>
                        </div>
                    </div>
                </div>

                <!-- Recent Activity -->
                <div class="profile-card">
                    <div class="card-header">
                        <h3 class="card-title">Recent Activity</h3>
                        <i class="fas fa-history card-icon"></i>
                    </div>

                    <div class="activity-list" id="activityList">
                        <!-- Activities will be populated by JavaScript -->
                    </div>
                </div>

                <!-- Account Management -->
                <div class="profile-card">
                    <div class="card-header">
                        <h3 class="card-title">Account Management</h3>
                        <i class="fas fa-cog card-icon"></i>
                    </div>

                    <div class="form-group">
                        <label class="form-label">Login Sessions</label>
                        <div style="display: flex; justify-content: space-between; align-items: center; padding: 1rem; background: rgba(255, 255, 255, 0.03); border-radius: 8px;">
                            <span style="color: rgba(255, 255, 255, 0.9);">Active Sessions: <strong id="activeSessions">1</strong></span>
                            <button type="button" class="btn-secondary" id="viewSessionsBtn">
                                <i class="fas fa-desktop me-2"></i>View All
                            </button>
                        </div>
                    </div>

                    <div class="form-group">
                        <label class="form-label">Email Preferences</label>
                        <div style="padding: 1rem; background: rgba(255, 255, 255, 0.03); border-radius: 8px;">
                            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 0.5rem;">
                                <span style="color: rgba(255, 255, 255, 0.9);">System Notifications</span>
                                <label class="switch">
                                    <input type="checkbox" id="systemNotifications" checked>
                                    <span class="slider"></span>
                                </label>
                            </div>
                            <div style="display: flex; justify-content: space-between; align-items: center;">
                                <span style="color: rgba(255, 255, 255, 0.9);">Security Alerts</span>
                                <label class="switch">
                                    <input type="checkbox" id="securityAlerts" checked>
                                    <span class="slider"></span>
                                </label>
                            </div>
                        </div>
                    </div>

                    <div style="margin-top: 2rem; padding-top: 1.5rem; border-top: 1px solid rgba(255, 255, 255, 0.1);">
                        <button type="button" class="btn-secondary" id="exportDataBtn" style="width: 100%; margin-bottom: 1rem;">
                            <i class="fas fa-download me-2"></i>Export My Data
                        </button>
                        <button type="button" class="btn-danger" id="deleteAccountBtn" style="width: 100%;">
                            <i class="fas fa-trash me-2"></i>Delete Account
                        </button>
                    </div>
                </div>
            </div>
        </div>

        <!-- Change Password Modal -->
        <div class="modal-overlay" id="passwordModal">
            <div class="modal-content">
                <div class="modal-header">
                    <h3 class="modal-title">Change Password</h3>
                    <button type="button" class="close-modal">&times;</button>
                </div>
                <div class="modal-body">
                    <div class="form-group">
                        <label class="form-label">Current Password</label>
                        <input type="password" class="form-control" id="modalCurrentPassword">
                    </div>
                    <div class="form-group">
                        <label class="form-label">New Password</label>
                        <input type="password" class="form-control" id="modalNewPassword">
                    </div>
                    <div class="form-group">
                        <label class="form-label">Confirm New Password</label>
                        <input type="password" class="form-control" id="modalConfirmPassword">
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn-secondary" id="cancelPasswordBtn">Cancel</button>
                    <button type="button" class="btn-primary" id="confirmPasswordBtn">Change Password</button>
                </div>
            </div>
        </div>

        <!-- Confirmation Modal -->
        <div class="modal-overlay" id="confirmationModal">
            <div class="modal-content">
                <div class="modal-header">
                    <h3 class="modal-title" id="confirmationTitle">Confirm Action</h3>
                    <button type="button" class="close-modal">&times;</button>
                </div>
                <div class="modal-body">
                    <div class="text-center">
                        <i class="fas fa-exclamation-triangle fa-3x text-warning mb-3"></i>
                        <h4 id="confirmationMessage">Are you sure you want to perform this action?</h4>
                        <p class="text-muted" id="confirmationDetails">This action cannot be undone.</p>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn-secondary" id="cancelConfirmBtn">Cancel</button>
                    <button type="button" class="btn-danger" id="confirmActionBtn">Confirm</button>
                </div>
            </div>
        </div>
    </div>

    <asp:Button ID="btnLoadProfile" runat="server" OnClick="btnLoadProfile_Click" Style="display: none;" />
    <asp:HiddenField ID="hfProfileData" runat="server" />
    <asp:HiddenField ID="hfActivityData" runat="server" />
</asp:Content>