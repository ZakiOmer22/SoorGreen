<%@ Page Title="System Settings" Language="C#" MasterPageFile="~/Pages/Admin/Site.master" AutoEventWireup="true" CodeFile="Settings.aspx.cs" Inherits="SoorGreen.Admin.Admin.Settings" %>

<asp:Content ID="PageTitle" ContentPlaceHolderID="PageTitle" runat="server">
    System Settings
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <asp:ScriptManager ID="ScriptManager1" runat="server" EnablePageMethods="true"></asp:ScriptManager>
    
    

    <div class="container-fluid">
        <div class="page-header">
            <h1 class="page-title">System Settings</h1>
            <p class="page-subtitle">Configure and manage your SoorGreen application settings</p>
        </div>

        <div class="settings-container">
            <!-- Loading Spinner -->
            <div class="loading-spinner" id="loadingSpinner">
                <div class="spinner"></div>
                <p style="color: rgba(255, 255, 255, 0.7); margin-top: 1rem;">Loading settings...</p>
            </div>

            <div class="settings-grid">
                <!-- General Settings -->
                <div class="settings-card">
                    <div class="settings-header">
                        <h3 class="settings-title">General Settings</h3>
                        <i class="fas fa-cog settings-icon"></i>
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label">Application Name</label>
                        <input type="text" class="form-control" id="appName" value="SoorGreen">
                        <div class="form-text">The name displayed throughout the application</div>
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label">Support Email</label>
                        <input type="email" class="form-control" id="supportEmail" value="support@soorgreen.com">
                        <div class="form-text">Email address for user support inquiries</div>
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label">Support Phone</label>
                        <input type="text" class="form-control" id="supportPhone" value="+1-555-123-4567">
                        <div class="form-text">Phone number for user support</div>
                    </div>
                    
                    <div class="toggle-group">
                        <div>
                            <div class="toggle-label">Maintenance Mode</div>
                            <div class="toggle-description">Put the application in maintenance mode</div>
                        </div>
                        <label class="switch">
                            <input type="checkbox" id="maintenanceMode">
                            <span class="slider"></span>
                        </label>
                    </div>
                    
                    <div class="settings-actions">
                        <button type="button" class="btn-primary" id="saveGeneralBtn">
                            <i class="fas fa-save me-2"></i>Save General Settings
                        </button>
                    </div>
                </div>

                <!-- Credit System Settings -->
                <div class="settings-card">
                    <div class="settings-header">
                        <h3 class="settings-title">Credit System</h3>
                        <i class="fas fa-coins settings-icon"></i>
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label">Credit Conversion Rate</label>
                        <div class="form-row">
                            <div class="form-half">
                                <input type="number" class="form-control" id="creditToCurrency" value="0.01" step="0.01" min="0">
                                <div class="form-text">1 Credit = $ Value</div>
                            </div>
                            <div class="form-half">
                                <input type="number" class="form-control" id="minRedemption" value="50" step="1" min="0">
                                <div class="form-text">Minimum redemption amount</div>
                            </div>
                        </div>
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label">Credit Rates per Kg</label>
                        <div class="credit-rates-grid">
                            <div class="credit-rate-card">
                                <div class="credit-rate-value" id="plasticRate">2.50</div>
                                <div class="credit-rate-label">Plastic</div>
                            </div>
                            <div class="credit-rate-card">
                                <div class="credit-rate-value" id="paperRate">1.80</div>
                                <div class="credit-rate-label">Paper</div>
                            </div>
                            <div class="credit-rate-card">
                                <div class="credit-rate-value" id="glassRate">1.20</div>
                                <div class="credit-rate-label">Glass</div>
                            </div>
                            <div class="credit-rate-card">
                                <div class="credit-rate-value" id="metalRate">3.00</div>
                                <div class="credit-rate-label">Metal</div>
                            </div>
                        </div>
                    </div>
                    
                    <div class="toggle-group">
                        <div>
                            <div class="toggle-label">Auto Credit Distribution</div>
                            <div class="toggle-description">Automatically distribute credits after pickup verification</div>
                        </div>
                        <label class="switch">
                            <input type="checkbox" id="autoCreditDistribution" checked>
                            <span class="slider"></span>
                        </label>
                    </div>
                    
                    <div class="settings-actions">
                        <button type="button" class="btn-primary" id="saveCreditBtn">
                            <i class="fas fa-save me-2"></i>Save Credit Settings
                        </button>
                    </div>
                </div>

                <!-- Notification Settings -->
                <div class="settings-card">
                    <div class="settings-header">
                        <h3 class="settings-title">Notifications</h3>
                        <i class="fas fa-bell settings-icon"></i>
                    </div>
                    
                    <div class="toggle-group">
                        <div>
                            <div class="toggle-label">Email Notifications</div>
                            <div class="toggle-description">Send email notifications to users</div>
                        </div>
                        <label class="switch">
                            <input type="checkbox" id="emailNotifications" checked>
                            <span class="slider"></span>
                        </label>
                    </div>
                    
                    <div class="toggle-group">
                        <div>
                            <div class="toggle-label">SMS Notifications</div>
                            <div class="toggle-description">Send SMS notifications to users</div>
                        </div>
                        <label class="switch">
                            <input type="checkbox" id="smsNotifications">
                            <span class="slider"></span>
                        </label>
                    </div>
                    
                    <div class="toggle-group">
                        <div>
                            <div class="toggle-label">Push Notifications</div>
                            <div class="toggle-description">Send push notifications to mobile app</div>
                        </div>
                        <label class="switch">
                            <input type="checkbox" id="pushNotifications" checked>
                            <span class="slider"></span>
                        </label>
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label">Notification Schedule</label>
                        <select class="form-control" id="notificationSchedule">
                            <option value="instant">Instant</option>
                            <option value="hourly">Hourly Digest</option>
                            <option value="daily">Daily Digest</option>
                            <option value="weekly">Weekly Digest</option>
                        </select>
                        <div class="form-text">How often to send notification digests</div>
                    </div>
                    
                    <div class="settings-actions">
                        <button type="button" class="btn-primary" id="saveNotificationBtn">
                            <i class="fas fa-save me-2"></i>Save Notification Settings
                        </button>
                    </div>
                </div>

                <!-- Security Settings -->
                <div class="settings-card">
                    <div class="settings-header">
                        <h3 class="settings-title">Security</h3>
                        <i class="fas fa-shield-alt settings-icon"></i>
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label">Session Timeout (minutes)</label>
                        <input type="number" class="form-control" id="sessionTimeout" value="30" min="5" max="480">
                        <div class="form-text">User session timeout in minutes</div>
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label">Max Login Attempts</label>
                        <input type="number" class="form-control" id="maxLoginAttempts" value="5" min="1" max="10">
                        <div class="form-text">Maximum failed login attempts before lockout</div>
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label">Password Expiry (days)</label>
                        <input type="number" class="form-control" id="passwordExpiry" value="90" min="30" max="365">
                        <div class="form-text">Days before password expires</div>
                    </div>
                    
                    <div class="toggle-group">
                        <div>
                            <div class="toggle-label">Two-Factor Authentication</div>
                            <div class="toggle-description">Require 2FA for admin accounts</div>
                        </div>
                        <label class="switch">
                            <input type="checkbox" id="twoFactorAuth">
                            <span class="slider"></span>
                        </label>
                    </div>
                    
                    <div class="toggle-group">
                        <div>
                            <div class="toggle-label">API Rate Limiting</div>
                            <div class="toggle-description">Enable rate limiting for API endpoints</div>
                        </div>
                        <label class="switch">
                            <input type="checkbox" id="apiRateLimiting" checked>
                            <span class="slider"></span>
                        </label>
                    </div>
                    
                    <div class="settings-actions">
                        <button type="button" class="btn-primary" id="saveSecurityBtn">
                            <i class="fas fa-save me-2"></i>Save Security Settings
                        </button>
                    </div>
                </div>

                <!-- System Information -->
                <div class="settings-card">
                    <div class="settings-header">
                        <h3 class="settings-title">System Information</h3>
                        <i class="fas fa-info-circle settings-icon"></i>
                    </div>
                    
                    <div class="system-info-grid">
                        <div class="info-card">
                            <div class="info-value" id="totalUsers">0</div>
                            <div class="info-label">Total Users</div>
                        </div>
                        <div class="info-card">
                            <div class="info-value" id="totalPickups">0</div>
                            <div class="info-label">Total Pickups</div>
                        </div>
                        <div class="info-card">
                            <div class="info-value" id="totalCredits">0</div>
                            <div class="info-label">Credits Distributed</div>
                        </div>
                        <div class="info-card">
                            <div class="info-value" id="appVersion">1.0.0</div>
                            <div class="info-label">App Version</div>
                        </div>
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label">Database Size</label>
                        <input type="text" class="form-control" id="dbSize" value="Loading..." readonly>
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label">Last Backup</label>
                        <input type="text" class="form-control" id="lastBackup" value="Loading..." readonly>
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label">System Uptime</label>
                        <input type="text" class="form-control" id="systemUptime" value="Loading..." readonly>
                    </div>
                    
                    <div class="settings-actions">
                        <button type="button" class="btn-warning" id="refreshSystemInfoBtn">
                            <i class="fas fa-sync-alt me-2"></i>Refresh Info
                        </button>
                        <button type="button" class="btn-success" id="backupNowBtn">
                            <i class="fas fa-database me-2"></i>Backup Now
                        </button>
                    </div>
                </div>

                <!-- Danger Zone -->
                <div class="settings-card danger-zone">
                    <div class="settings-header">
                        <h3 class="settings-title">Danger Zone</h3>
                        <i class="fas fa-exclamation-triangle settings-icon"></i>
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label">Clear All Data</label>
                        <div class="form-text">Permanently delete all user data and transactions</div>
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label">Reset Credit System</label>
                        <div class="form-text">Reset all user credits to zero</div>
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label">Purge Old Records</label>
                        <div class="form-text">Delete records older than specified days</div>
                        <div class="form-row">
                            <div class="form-half">
                                <input type="number" class="form-control" id="purgeDays" value="365" min="30" max="1095">
                            </div>
                            <div class="form-half">
                                <button type="button" class="btn-warning" id="purgeRecordsBtn" style="width: 100%;">
                                    <i class="fas fa-trash me-2"></i>Purge Records
                                </button>
                            </div>
                        </div>
                    </div>
                    
                    <div class="settings-actions">
                        <button type="button" class="btn-danger" id="resetSystemBtn">
                            <i class="fas fa-bomb me-2"></i>Reset System
                        </button>
                        <button type="button" class="btn-danger" id="clearAllDataBtn">
                            <i class="fas fa-skull-crossbones me-2"></i>Clear All Data
                        </button>
                    </div>
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
                        <i class="fas fa-exclamation-triangle fa-3x text-warning mb-3" id="confirmationIcon"></i>
                        <h4 id="confirmationMessage">Are you sure you want to perform this action?</h4>
                        <p class="text-muted" id="confirmationDetails">This action cannot be undone.</p>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn-secondary" id="cancelConfirmBtn" style="flex: 1;">Cancel</button>
                    <button type="button" class="btn-danger" id="confirmActionBtn" style="flex: 1;">Confirm</button>
                </div>
            </div>
        </div>
    </div>

    <asp:Button ID="btnLoadSettings" runat="server" OnClick="btnLoadSettings_Click" Style="display: none;" />
    <asp:HiddenField ID="hfSettingsData" runat="server" />
    <asp:HiddenField ID="hfSystemInfo" runat="server" />
</asp:Content>