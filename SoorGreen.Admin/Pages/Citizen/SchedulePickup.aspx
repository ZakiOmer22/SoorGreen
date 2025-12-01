<%@ Page Title="Schedule Pickup" Language="C#" MasterPageFile="~/Pages/Citizen/Site.Master" AutoEventWireup="true" CodeFile="SchedulePickup.aspx.cs" Inherits="SoorGreen.Admin.SchedulePickup" %>
<%@ Import Namespace="System.Web.Optimization" %>
<asp:Content ID="Content3" ContentPlaceHolderID="HeadContent" runat="server">
    <%: Styles.Render("~/Content/citizenschedulepickup") %>
</asp:Content>
<asp:Content ID="Content4" ContentPlaceHolderID="ScriptsContent" runat="server">
    <%: Scripts.Render("~/bundles/citizenschedulepickup") %>
</asp:Content>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Schedule Pickup - SoorGreen Citizen
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <!-- Hidden Fields for Data Storage -->
    <asp:HiddenField ID="hfSelectedWasteId" runat="server" />
    <asp:HiddenField ID="hfSelectedDate" runat="server" />
    <asp:HiddenField ID="hfSelectedTime" runat="server" />
    <asp:HiddenField ID="hfWasteData" runat="server" />
    <asp:HiddenField ID="hfUpcomingPickups" runat="server" />
    <asp:HiddenField ID="hfPickupHistory" runat="server" />
    <asp:HiddenField ID="hfStatsData" runat="server" />
    
    

    <div class="schedule-container">
        <br />
        <br />
        <br />
        
        <div class="stats-cards">
            <div class="stat-card">
                <div class="stat-value" id="totalPickups">0</div>
                <div class="stat-label">Total Pickups</div>
            </div>
            <div class="stat-card">
                <div class="stat-value" id="scheduledPickups">0</div>
                <div class="stat-label">Scheduled</div>
            </div>
            <div class="stat-card">
                <div class="stat-value" id="completedPickups">0</div>
                <div class="stat-label">Completed</div>
            </div>
            <div class="stat-card">
                <div class="stat-value" id="successRate">0%</div>
                <div class="stat-label">Success Rate</div>
            </div>
        </div>

        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h1 style="color: #ffffff !important; margin: 0;">Schedule Pickup</h1>
                <p class="text-muted mb-0">Schedule waste collection and manage your pickups</p>
            </div>
            <div>
                <button type="button" class="btn-primary me-2" id="quickScheduleBtn">
                    <i class="fas fa-bolt me-2"></i>Quick Schedule
                </button>
                <button type="button" class="btn-outline-light" id="viewHistoryBtn">
                    <i class="fas fa-history me-2"></i>View History
                </button>
            </div>
        </div>

        <div class="tabs">
            <button type="button" class="tab active" data-tab="schedule">Schedule New Pickup</button>
            <button type="button" class="tab" data-tab="upcoming">Upcoming Pickups</button>
            <button type="button" class="tab" data-tab="history">Pickup History</button>
        </div>

        <div class="tab-content active" id="scheduleTab">
            <div class="form-section">
                <h4 class="fw-bold mb-4 text-light">Select Waste for Pickup</h4>
                
                <div id="availableWasteList">
                    <div class="text-center text-muted">
                        <i class="fas fa-spinner fa-spin me-2"></i>Loading available waste...
                    </div>
                </div>
                
                <div id="noWasteEmptyState" class="empty-state" style="display: none;">
                    <div class="empty-state-icon">
                        <i class="fas fa-trash-alt"></i>
                    </div>
                    <h3 class="empty-state-title">No Waste Available</h3>
                    <p class="empty-state-description">You don't have any waste reports ready for pickup.</p>
                    <button type="button" class="btn-primary" onclick="window.location.href='ReportWaste.aspx'">
                        <i class="fas fa-plus me-2"></i>Report New Waste
                    </button>
                </div>
            </div>

            <div class="form-section" id="datetimeSection" style="display: none;">
                <h4 class="fw-bold mb-4 text-light">Select Date & Time</h4>
                
                <div class="row">
                    <div class="col-md-6">
                        <div class="form-group">
                            <label class="form-label">Preferred Date</label>
                            <div class="calendar-grid">
                                <div class="weekday-header">Sun</div>
                                <div class="weekday-header">Mon</div>
                                <div class="weekday-header">Tue</div>
                                <div class="weekday-header">Wed</div>
                                <div class="weekday-header">Thu</div>
                                <div class="weekday-header">Fri</div>
                                <div class="weekday-header">Sat</div>
                                
                                <div class="calendar-day disabled">28</div>
                                <div class="calendar-day disabled">29</div>
                                <div class="calendar-day disabled">30</div>
                                <div class="calendar-day">1</div>
                                <div class="calendar-day">2</div>
                                <div class="calendar-day">3</div>
                                <div class="calendar-day">4</div>
                                <div class="calendar-day">5</div>
                                <div class="calendar-day">6</div>
                                <div class="calendar-day selected">7</div>
                                <div class="calendar-day">8</div>
                                <div class="calendar-day">9</div>
                                <div class="calendar-day">10</div>
                                <div class="calendar-day">11</div>
                                <div class="calendar-day">12</div>
                                <div class="calendar-day">13</div>
                                <div class="calendar-day">14</div>
                                <div class="calendar-day">15</div>
                                <div class="calendar-day">16</div>
                                <div class="calendar-day">17</div>
                                <div class="calendar-day">18</div>
                                <div class="calendar-day">19</div>
                                <div class="calendar-day">20</div>
                                <div class="calendar-day">21</div>
                                <div class="calendar-day">22</div>
                                <div class="calendar-day">23</div>
                                <div class="calendar-day">24</div>
                                <div class="calendar-day">25</div>
                                <div class="calendar-day">26</div>
                                <div class="calendar-day">27</div>
                                <div class="calendar-day">28</div>
                                <div class="calendar-day">29</div>
                                <div class="calendar-day">30</div>
                            </div>
                        </div>
                    </div>
                    
                    <div class="col-md-6">
                        <div class="form-group">
                            <label class="form-label">Preferred Time Slot</label>
                            <div class="time-slots-grid">
                                <div class="time-slot">8:00 AM</div>
                                <div class="time-slot">9:00 AM</div>
                                <div class="time-slot">10:00 AM</div>
                                <div class="time-slot selected">11:00 AM</div>
                                <div class="time-slot">12:00 PM</div>
                                <div class="time-slot">1:00 PM</div>
                                <div class="time-slot">2:00 PM</div>
                                <div class="time-slot">3:00 PM</div>
                                <div class="time-slot">4:00 PM</div>
                            </div>
                        </div>
                        
                        <div class="form-group">
                            <label class="form-label">Special Instructions (Optional)</label>
                            <asp:TextBox ID="txtInstructions" runat="server" CssClass="form-control" 
                                       placeholder="Any special instructions for the collector..." TextMode="MultiLine" Rows="3" />
                        </div>
                    </div>
                </div>
                
                <div class="text-end mt-4">
                    <button type="button" class="btn-outline-light me-2" onclick="cancelSchedule()">
                        Cancel
                    </button>
                    <asp:Button ID="btnSchedulePickup" runat="server" Text="Schedule Pickup" 
                              CssClass="btn-primary" OnClick="btnSchedulePickup_Click" />
                </div>
            </div>
        </div>

        <div class="tab-content" id="upcomingTab">
            <div class="form-section">
                <h4 class="fw-bold mb-4 text-light">Upcoming Pickups</h4>
                
                <div class="table-responsive">
                    <table class="schedule-table">
                        <thead>
                            <tr>
                                <th>Pickup ID</th>
                                <th>Waste Type</th>
                                <th>Weight</th>
                                <th>Scheduled Date</th>
                                <th>Time Slot</th>
                                <th>Status</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody id="upcomingTableBody">
                            <tr>
                                <td colspan="7" class="text-center">Loading upcoming pickups...</td>
                            </tr>
                        </tbody>
                    </table>
                </div>
                
                <div id="upcomingEmptyState" class="empty-state" style="display: none;">
                    <div class="empty-state-icon">
                        <i class="fas fa-calendar-check"></i>
                    </div>
                    <h3 class="empty-state-title">No Upcoming Pickups</h3>
                    <p class="empty-state-description">You don't have any scheduled pickups.</p>
                    <button type="button" class="btn-primary" onclick="switchTab('schedule')">
                        <i class="fas fa-plus me-2"></i>Schedule a Pickup
                    </button>
                </div>
            </div>
        </div>

        <div class="tab-content" id="historyTab">
            <div class="form-section">
                <h4 class="fw-bold mb-4 text-light">Pickup History</h4>
                
                <div class="table-responsive">
                    <table class="schedule-table">
                        <thead>
                            <tr>
                                <th>Pickup ID</th>
                                <th>Waste Type</th>
                                <th>Weight</th>
                                <th>Completed Date</th>
                                <th>Collector</th>
                                <th>XP Earned</th>
                                <th>Status</th>
                            </tr>
                        </thead>
                        <tbody id="historyTableBody">
                            <tr>
                                <td colspan="7" class="text-center">Loading pickup history...</td>
                            </tr>
                        </tbody>
                    </table>
                </div>
                
                <div id="historyEmptyState" class="empty-state" style="display: none;">
                    <div class="empty-state-icon">
                        <i class="fas fa-history"></i>
                    </div>
                    <h3 class="empty-state-title">No Pickup History</h3>
                    <p class="empty-state-description">You haven't completed any pickups yet.</p>
                </div>
            </div>
        </div>
    </div>

    
</asp:Content>