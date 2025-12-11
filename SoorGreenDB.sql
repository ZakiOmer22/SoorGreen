
-- ========================================
-- SoorGreenDB Setup Script
-- Project Codename: DIBUCELIN
-- Description: Smart sustainability app rewarding citizens 
-- for recycling and helping cities manage waste efficiently.
-- ========================================

-- 1. Create Database
CREATE DATABASE SoorGreenDB;
GO

USE SoorGreenDB;
GO

-- ========================================
-- 2. TABLES
-- ========================================

-- ROLES: Defines system access roles
CREATE TABLE Roles (
    RoleId CHAR(4) PRIMARY KEY,
    RoleName NVARCHAR(50) NOT NULL
);

-- USERS: Registered accounts (citizens, collectors, admins, companies)
CREATE TABLE Users (
    UserId CHAR(4) PRIMARY KEY,
    FullName NVARCHAR(150) NOT NULL,
    Phone NVARCHAR(20) UNIQUE NOT NULL,
    Email NVARCHAR(256),
	Password NVARCHAR(100) NULL,
    RoleId CHAR(4) NOT NULL,
    XP_Credits DECIMAL(10,2) DEFAULT 0,
    CreatedAt DATETIME DEFAULT GETDATE(),
    LastLogin DATETIME NULL,
    IsVerified BIT DEFAULT 0,
    CONSTRAINT FK_Users_Roles FOREIGN KEY(RoleId) REFERENCES Roles(RoleId)
);

-- MUNICIPALITIES: Defines city or zone
CREATE TABLE Municipalities (
    MunicipalityId CHAR(4) PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL,
	Region NVARCHAR(100) NULL,
    Status NVARCHAR(20) DEFAULT 'Active',
    Population BIGINT DEFAULT 0,
    Area DECIMAL(10,2) DEFAULT 0,
    ContactPerson NVARCHAR(100) NULL,
    ContactNumber NVARCHAR(20) NULL,
    Email NVARCHAR(100) NULL,
    Address NVARCHAR(300) NULL,
    EstablishedDate DATETIME NULL,
    Description NVARCHAR(500) NULL
);

-- WASTE TYPES: Categories of waste
CREATE TABLE WasteTypes (
    WasteTypeId CHAR(4) PRIMARY KEY,
    Name NVARCHAR(50) NOT NULL,
	ColorCode NVARCHAR(7) NULL,
    Description NVARCHAR(500) NULL,
    Category NVARCHAR(50) DEFAULT 'Other',
    CreditPerKg DECIMAL(5,2) NOT NULL
);

-- WASTE REPORTS: Citizen submits report of waste to collect
CREATE TABLE WasteReports (
    ReportId CHAR(4) PRIMARY KEY,
    UserId CHAR(4) NOT NULL,
    WasteTypeId CHAR(4) NOT NULL,
    EstimatedKg DECIMAL(6,2) NOT NULL,
    Address NVARCHAR(300) NOT NULL,
    Lat DECIMAL(10,6),
    Lng DECIMAL(10,6),
    Landmark NVARCHAR(200) NULL,
    PhotoUrl NVARCHAR(512),
    CreatedAt DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_WasteReports_Users FOREIGN KEY(UserId) REFERENCES Users(UserId),
    CONSTRAINT FK_WasteReports_WasteTypes FOREIGN KEY(WasteTypeId) REFERENCES WasteTypes(WasteTypeId)
);

-- PICKUP REQUESTS: Links collectors to reports
CREATE TABLE PickupRequests (
    PickupId CHAR(4) PRIMARY KEY,
    ReportId CHAR(4) NOT NULL,
    CollectorId CHAR(4) NULL,
    Status NVARCHAR(20) DEFAULT 'Requested',
    ScheduledAt DATETIME NULL,
    CompletedAt DATETIME NULL,
    CONSTRAINT FK_PickupRequests_Reports FOREIGN KEY(ReportId) REFERENCES WasteReports(ReportId),
    CONSTRAINT FK_PickupRequests_Collector FOREIGN KEY(CollectorId) REFERENCES Users(UserId)
);

-- REWARD POINTS: XP/credit transactions for users
CREATE TABLE RewardPoints (
    RewardId CHAR(4) PRIMARY KEY,
    UserId CHAR(4) NOT NULL,
    Amount DECIMAL(10,2) NOT NULL,
    Type NVARCHAR(50),
    Reference NVARCHAR(100),
    CreatedAt DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_RewardPoints_User FOREIGN KEY(UserId) REFERENCES Users(UserId)
);

-- REDEMPTION REQUESTS: Users cash out credits
CREATE TABLE RedemptionRequests (
    RedemptionId CHAR(4) PRIMARY KEY,
    UserId CHAR(4) NOT NULL,
    Amount DECIMAL(10,2) NOT NULL,
    Method NVARCHAR(50),
    Status NVARCHAR(20) DEFAULT 'Pending',
    RequestedAt DATETIME DEFAULT GETDATE(),
    ProcessedAt DATETIME NULL,
    CONSTRAINT FK_RedemptionRequests_User FOREIGN KEY(UserId) REFERENCES Users(UserId)
);

-- NOTIFICATIONS: User alerts
CREATE TABLE Notifications (
    NotificationId CHAR(4) PRIMARY KEY,
    UserId CHAR(4) NOT NULL,
    Title NVARCHAR(200),
    Message NVARCHAR(1000),
    IsRead BIT DEFAULT 0,
    CreatedAt DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Notifications_User FOREIGN KEY(UserId) REFERENCES Users(UserId)
);

-- AUDIT LOGS: Logs key system actions
CREATE TABLE AuditLogs (
    AuditId CHAR(4) PRIMARY KEY,
    UserId CHAR(4) NULL,
    Action NVARCHAR(100),
    Details NVARCHAR(MAX),
    Timestamp DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_AuditLogs_User FOREIGN KEY(UserId) REFERENCES Users(UserId)
);

-- FEEDBACKS: Citizen suggestions
CREATE TABLE Feedbacks (
    FeedbackId CHAR(4) PRIMARY KEY,
    UserId CHAR(4) NOT NULL,
	Category NVARCHAR(50) DEFAULT 'General',
	Priority NVARCHAR(20) DEFAULT 'Medium',
	Subject NVARCHAR(200),
	Rating INT DEFAULT 0,
	FollowUp BIT DEFAULT 0;
    Message NVARCHAR(1000),
    CreatedAt DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Feedbacks_User FOREIGN KEY(UserId) REFERENCES Users(UserId)
);
WHERE Category IS NULL;
CREATE TABLE PickupVerifications (
    VerificationId CHAR(4) PRIMARY KEY,
    PickupId CHAR(4) NOT NULL,
    VerifiedKg DECIMAL(6,2) NOT NULL,
    MaterialType NVARCHAR(50),
    VerificationMethod NVARCHAR(50),
    VerifiedAt DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_PickupVerifications_Pickup FOREIGN KEY(PickupId) REFERENCES PickupRequests(PickupId)
);

-- Create UserActivities table for recent activity feed
CREATE TABLE UserActivities (
    ActivityId INT IDENTITY(1,1) PRIMARY KEY,
    UserId CHAR(4) NOT NULL,
    ActivityType NVARCHAR(50) NOT NULL,
    Description NVARCHAR(255) NOT NULL,
    Points DECIMAL(10,2) DEFAULT 0,
    Timestamp DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_UserActivities_Users FOREIGN KEY(UserId) REFERENCES Users(UserId)
);

-- Error Log for analytics
CREATE TABLE ErrorLogs (
    ErrorId INT IDENTITY(1,1) PRIMARY KEY,
    ErrorType NVARCHAR(50) NOT NULL,
    Url NVARCHAR(500) NOT NULL,
    UserIP NVARCHAR(50),
    UserAgent NVARCHAR(500),
    Referrer NVARCHAR(500),
    CreatedAt DATETIME DEFAULT GETDATE()
);

-- Support Tickets for User Related Issues
CREATE TABLE SupportTickets (
    TicketId NVARCHAR(50) PRIMARY KEY,
    UserId NVARCHAR(50) NULL,
    FullName NVARCHAR(100) NOT NULL,
    Email NVARCHAR(100) NOT NULL,
    IssueType NVARCHAR(50) NOT NULL,
    Priority NVARCHAR(20) NOT NULL,
    Description NVARCHAR(MAX) NOT NULL,
    AttachScreenshot BIT NOT NULL DEFAULT 0,
    Status NVARCHAR(20) NOT NULL DEFAULT 'Open',
    CreatedDate DATETIME NOT NULL DEFAULT GETDATE(),
    ResolvedDate DATETIME NULL
);

-- Collector Routes table
CREATE TABLE CollectorRoutes (
    RouteId NVARCHAR(50) PRIMARY KEY,
    CollectorId CHAR(4) NOT NULL,
    RouteDate DATETIME NOT NULL,
    VehicleId NVARCHAR(50) NULL,
    RouteType NVARCHAR(50) DEFAULT 'daily',
    StartTime DATETIME NULL,
    BreakTime DATETIME NULL,
    EndTime DATETIME NULL,
    TotalDistance DECIMAL(10,2) DEFAULT 0,
    TotalWeight DECIMAL(10,2) DEFAULT 0,
    Notes NVARCHAR(MAX) NULL,
    Status NVARCHAR(20) DEFAULT 'Planned',
    CreatedAt DATETIME DEFAULT GETDATE(),
    LastUpdated DATETIME NULL,
    CONSTRAINT FK_CollectorRoutes_Collector FOREIGN KEY(CollectorId) REFERENCES Users(UserId)
);

-- Collector Locations for real-time tracking
CREATE TABLE CollectorLocations (
    LocationId INT IDENTITY(1,1) PRIMARY KEY,
    CollectorId CHAR(4) NOT NULL,
    Lat DECIMAL(10,6) NOT NULL,
    Lng DECIMAL(10,6) NOT NULL,
    Timestamp DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_CollectorLocations_Collector FOREIGN KEY(CollectorId) REFERENCES Users(UserId)
);

-- Vehicles table
CREATE TABLE Vehicles (
    VehicleId NVARCHAR(50) PRIMARY KEY,
    VehicleType NVARCHAR(50) NOT NULL,
    LicensePlate NVARCHAR(20) UNIQUE NOT NULL,
    Capacity DECIMAL(10,2) NOT NULL, -- in kg
    FuelType NVARCHAR(20) DEFAULT 'Diesel',
    Status NVARCHAR(20) DEFAULT 'Active',
    AssignedTo CHAR(4) NULL,
    LastMaintenance DATE NULL,
    NextMaintenance DATE NULL,
    CreatedAt DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Vehicles_Collector FOREIGN KEY(AssignedTo) REFERENCES Users(UserId)
);

-- Route Optimizations table
CREATE TABLE RouteOptimizations (
    OptimizationId INT IDENTITY(1,1) PRIMARY KEY,
    RouteId NVARCHAR(50) NOT NULL,
    OptimizationType NVARCHAR(50) NOT NULL,
    OriginalDistance DECIMAL(10,2) NOT NULL,
    OptimizedDistance DECIMAL(10,2) NOT NULL,
    TimeSaved INT NOT NULL, -- in minutes
    FuelSaved DECIMAL(10,2) NOT NULL, -- in liters
    OptimizationData NVARCHAR(MAX) NULL,
    CreatedAt DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_RouteOptimizations_Route FOREIGN KEY(RouteId) REFERENCES CollectorRoutes(RouteId)
);


-- ========================================
-- 3. INDEXES
-- ========================================
CREATE INDEX IX_Users_Email ON Users(Email);
CREATE INDEX IX_WasteReports_Date ON WasteReports(CreatedAt);
CREATE INDEX IX_PickupRequests_Status ON PickupRequests(Status);
CREATE INDEX IX_RewardPoints_UserId ON RewardPoints(UserId);
CREATE INDEX IX_Notifications_IsRead ON Notifications(IsRead);
CREATE INDEX IX_ErrorLogs_CreatedAt ON ErrorLogs(CreatedAt);
CREATE INDEX IX_ErrorLogs_ErrorType ON ErrorLogs(ErrorType);
CREATE INDEX IX_CollectorRoutes_CollectorDate ON CollectorRoutes(CollectorId, RouteDate);
CREATE INDEX IX_PickupRequests_CollectorStatus ON PickupRequests(CollectorId, Status);
CREATE INDEX IX_PickupRequests_ScheduledDate ON PickupRequests(ScheduledAt);
-- ========================================
-- 4. VIEWS
-- ========================================

-- vw_ActivePickups: Displays all pickups that are pending or assigned
CREATE VIEW vw_ActivePickups AS
SELECT p.PickupId, w.Address, w.PhotoUrl, u.FullName AS CitizenName,
       c.FullName AS CollectorName, p.Status
FROM PickupRequests p
JOIN WasteReports w ON p.ReportId = w.ReportId
JOIN Users u ON w.UserId = u.UserId
LEFT JOIN Users c ON p.CollectorId = c.UserId
WHERE p.Status IN ('Requested','Assigned');

-- vw_UserRewardSummary: Summarizes total reward points per user
CREATE VIEW vw_UserRewardSummary AS
SELECT u.FullName, u.Phone, SUM(r.Amount) AS TotalCredits
FROM Users u
LEFT JOIN RewardPoints r ON u.UserId = r.UserId
GROUP BY u.FullName, u.Phone;

-- ========================================
-- 5. STORED PROCEDURES
-- ========================================

ALTER PROCEDURE sp_AddWasteReport
    @UserId CHAR(4),
    @WasteTypeId CHAR(4),
    @EstimatedKg DECIMAL(6,2),
    @Address NVARCHAR(300),
    @Lat DECIMAL(10,6) = NULL,
    @Lng DECIMAL(10,6) = NULL,
    @PhotoUrl NVARCHAR(512) = NULL
AS
BEGIN
    INSERT INTO WasteReports(UserId, WasteTypeId, EstimatedKg, Address, Lat, Lng, PhotoUrl)
    VALUES(@UserId, @WasteTypeId, @EstimatedKg, @Address, @Lat, @Lng, @PhotoUrl);
END
GO
-- sp_AddWasteReport: Inserts a new citizen waste report
CREATE PROCEDURE sp_AddWasteReport
    @UserId UNIQUEIDENTIFIER,
    @WasteTypeId INT,
    @EstimatedKg DECIMAL(6,2),
    @Address NVARCHAR(300),
    @Lat DECIMAL(10,6) = NULL,
    @Lng DECIMAL(10,6) = NULL,
    @PhotoUrl NVARCHAR(512) = NULL
AS
BEGIN
    INSERT INTO WasteReports(UserId, WasteTypeId, EstimatedKg, Address, Lat, Lng, PhotoUrl)
    VALUES(@UserId, @WasteTypeId, @EstimatedKg, @Address, @Lat, @Lng, @PhotoUrl);
END
GO

-- sp_AssignPickup: Assigns a collector to a pending pickup request
CREATE PROCEDURE sp_AssignPickup
    @PickupId UNIQUEIDENTIFIER,
    @CollectorId UNIQUEIDENTIFIER
AS
BEGIN
    UPDATE PickupRequests
    SET CollectorId = @CollectorId,
        Status = 'Assigned'
    WHERE PickupId = @PickupId;
END
GO

-- sp_CompletePickup: Verifies a pickup, adds reward points and logs completion
CREATE PROCEDURE sp_CompletePickup
    @PickupId UNIQUEIDENTIFIER,
    @VerifiedKg DECIMAL(6,2),
    @MaterialType NVARCHAR(50)
AS
BEGIN
    INSERT INTO PickupVerifications(PickupId, VerifiedKg, MaterialType, VerificationMethod)
    VALUES(@PickupId, @VerifiedKg, @MaterialType, 'Manual');

    DECLARE @UserId UNIQUEIDENTIFIER = (SELECT w.UserId FROM WasteReports w
                                        JOIN PickupRequests p ON w.ReportId = p.ReportId
                                        WHERE p.PickupId = @PickupId);

    DECLARE @CreditRate DECIMAL(5,2) = (SELECT CreditPerKg FROM WasteTypes WHERE Name = @MaterialType);

    INSERT INTO RewardPoints(UserId, Amount, Type, Reference)
    VALUES(@UserId, @VerifiedKg * @CreditRate, 'Credit', 'Pickup ' + CAST(@PickupId AS NVARCHAR(36)));

    UPDATE PickupRequests
    SET Status = 'Collected',
        CompletedAt = GETDATE()
    WHERE PickupId = @PickupId;
END
GO

-- ========================================
-- 6. TRIGGERS
-- ========================================

-- trg_LogWasteReport: Logs every new waste report for auditing
CREATE TRIGGER trg_LogWasteReport
ON WasteReports
AFTER INSERT
AS
BEGIN
    DECLARE @NextAuditId INT;
    
    -- Get the next AuditId
    SELECT @NextAuditId = ISNULL(MAX(CAST(SUBSTRING(AuditId, 3, LEN(AuditId)) AS INT)), 0) + 1 
    FROM AuditLogs 
    WHERE AuditId LIKE 'AL%';
    
    -- Insert with generated AuditId
    INSERT INTO AuditLogs (AuditId, UserId, Action, Details, Timestamp)
    SELECT 
        'AL' + RIGHT('00' + CAST(@NextAuditId + ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1 AS VARCHAR(2)), 2),
        UserId, 
        'New Waste Report', 
        'ReportId: ' + CAST(ReportId AS NVARCHAR(10)),
        GETDATE()
    FROM inserted;
END
GO

-- ========================================
-- 7. ADDITIONAL TRIGGERS FOR USER ACTIVITIES
-- ========================================

-- Trigger for new waste reports
IF NOT EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_AfterWasteReport')
BEGIN
    EXEC('CREATE TRIGGER trg_AfterWasteReport
    ON WasteReports
    AFTER INSERT
    AS
    BEGIN
        DECLARE @UserId CHAR(4), @ReportId CHAR(4), @WasteType NVARCHAR(50)
        
        SELECT @UserId = UserId, @ReportId = ReportId FROM inserted
        SELECT @WasteType = Name FROM WasteTypes wt 
        JOIN inserted i ON wt.WasteTypeId = i.WasteTypeId
        
        INSERT INTO UserActivities (UserId, ActivityType, Description, Points, Timestamp)
        VALUES (@UserId, ''WasteReport'', 
                ''Reported '' + @WasteType + '' for collection'', 
                5, GETDATE())
    END')
END
GO

-- Trigger for completed pickups
IF NOT EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_AfterPickupComplete')
BEGIN
    EXEC('CREATE TRIGGER trg_AfterPickupComplete
    ON PickupRequests
    AFTER UPDATE
    AS
    BEGIN
        IF UPDATE(Status) AND EXISTS(SELECT 1 FROM inserted WHERE Status = ''Collected'')
        BEGIN
            DECLARE @UserId CHAR(4), @PickupId CHAR(4), @Points DECIMAL(10,2)
            
            SELECT @PickupId = PickupId FROM inserted
            SELECT @UserId = wr.UserId, @Points = pv.VerifiedKg * wt.CreditPerKg
            FROM PickupRequests pr
            JOIN WasteReports wr ON pr.ReportId = wr.ReportId
            JOIN PickupVerifications pv ON pr.PickupId = pv.PickupId
            JOIN WasteTypes wt ON wr.WasteTypeId = wt.WasteTypeId
            WHERE pr.PickupId = @PickupId
            
            INSERT INTO UserActivities (UserId, ActivityType, Description, Points, Timestamp)
            VALUES (@UserId, ''PickupComplete'', 
                    ''Pickup completed - '' + CAST(@Points AS NVARCHAR(10)) + '' credits earned'', 
                    @Points, GETDATE())
        END
    END')
END
GO

-- Trigger for reward points
IF NOT EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_AfterRewardPoints')
BEGIN
    EXEC('CREATE TRIGGER trg_AfterRewardPoints
    ON RewardPoints
    AFTER INSERT
    AS
    BEGIN
        DECLARE @UserId CHAR(4), @Amount DECIMAL(10,2), @Type NVARCHAR(50)
        
        SELECT @UserId = UserId, @Amount = Amount, @Type = Type FROM inserted
        
        UPDATE Users 
        SET XP_Credits = XP_Credits + @Amount 
        WHERE UserId = @UserId
    END')
END
GO

-- ========================================
-- ADDITIONAL STORED PROCEDURES FOR CITIZEN ACTIVITIES
-- ========================================

-- Procedure to get citizen dashboard data
IF NOT EXISTS (SELECT * FROM sys.procedures WHERE name = 'sp_GetCitizenDashboard')
BEGIN
    EXEC('CREATE PROCEDURE sp_GetCitizenDashboard
        @UserId CHAR(4)
    AS
    BEGIN
        -- Total credits
        SELECT ISNULL(SUM(Amount), 0) AS TotalCredits 
        FROM RewardPoints 
        WHERE UserId = @UserId
        
        -- Recent activities
        SELECT TOP 5 ActivityType, Description, Points, Timestamp
        FROM UserActivities 
        WHERE UserId = @UserId 
        ORDER BY Timestamp DESC
        
        -- Pending pickups
        SELECT COUNT(*) AS PendingPickups
        FROM PickupRequests pr
        JOIN WasteReports wr ON pr.ReportId = wr.ReportId
        WHERE wr.UserId = @UserId AND pr.Status IN (''Requested'', ''Assigned'')
        
        -- Monthly stats
        SELECT 
            DATENAME(MONTH, CreatedAt) AS MonthName,
            COUNT(*) AS ReportsCount,
            ISNULL(SUM(EstimatedKg), 0) AS TotalKg
        FROM WasteReports 
        WHERE UserId = @UserId AND YEAR(CreatedAt) = YEAR(GETDATE())
        GROUP BY DATENAME(MONTH, CreatedAt), MONTH(CreatedAt)
        ORDER BY MONTH(CreatedAt)
    END')
END
GO

-- Procedure for waste reporting with activity tracking
IF NOT EXISTS (SELECT * FROM sys.procedures WHERE name = 'sp_SubmitWasteReport')
BEGIN
    EXEC('CREATE PROCEDURE sp_SubmitWasteReport
        @UserId CHAR(4),
        @WasteTypeId CHAR(4),
        @EstimatedKg DECIMAL(6,2),
        @Address NVARCHAR(300),
        @Lat DECIMAL(10,6) = NULL,
        @Lng DECIMAL(10,6) = NULL,
        @PhotoUrl NVARCHAR(512) = NULL
    AS
    BEGIN
        DECLARE @ReportId CHAR(4)
        
        -- Generate ReportId
        SELECT @ReportId = ''WR'' + RIGHT(''00'' + CAST(ISNULL(MAX(CAST(SUBSTRING(ReportId, 3, 2) AS INT)), 0) + 1 AS VARCHAR(2)), 2)
        FROM WasteReports
        
        -- Insert waste report
        INSERT INTO WasteReports (ReportId, UserId, WasteTypeId, EstimatedKg, Address, Lat, Lng, PhotoUrl)
        VALUES (@ReportId, @UserId, @WasteTypeId, @EstimatedKg, @Address, @Lat, @Lng, @PhotoUrl)
        
        -- Create pickup request
        DECLARE @PickupId CHAR(4)
        SELECT @PickupId = ''PK'' + RIGHT(''00'' + CAST(ISNULL(MAX(CAST(SUBSTRING(PickupId, 3, 2) AS INT)), 0) + 1 AS VARCHAR(2)), 2)
        FROM PickupRequests
        
        INSERT INTO PickupRequests (PickupId, ReportId, Status)
        VALUES (@PickupId, @ReportId, ''Requested'')
    END')
END
GO

-- ========================================
-- ADDITIONAL INDEXES FOR PERFORMANCE
-- ========================================

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_UserActivities_UserId')
BEGIN
    CREATE INDEX IX_UserActivities_UserId ON UserActivities(UserId);
END

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_UserActivities_Timestamp')
BEGIN
    CREATE INDEX IX_UserActivities_Timestamp ON UserActivities(Timestamp DESC);
END

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_PickupVerifications_PickupId')
BEGIN
    CREATE INDEX IX_PickupVerifications_PickupId ON PickupVerifications(PickupId);
END

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_RewardPoints_CreatedAt')
BEGIN
    CREATE INDEX IX_RewardPoints_CreatedAt ON RewardPoints(CreatedAt DESC);
END
GO

-- ========================================
-- ADDITIONAL VIEWS FOR REPORTING
-- ========================================

IF NOT EXISTS (SELECT * FROM sys.views WHERE name = 'vw_CitizenActivitySummary')
BEGIN
    EXEC('CREATE VIEW vw_CitizenActivitySummary AS
    SELECT 
        u.UserId,
        u.FullName,
        u.Phone,
        ISNULL(SUM(rp.Amount), 0) AS TotalCredits,
        COUNT(DISTINCT wr.ReportId) AS TotalReports,
        COUNT(DISTINCT pr.PickupId) AS TotalPickups,
        ISNULL(SUM(pv.VerifiedKg), 0) AS TotalKgRecycled,
        MAX(ua.Timestamp) AS LastActivity
    FROM Users u
    LEFT JOIN WasteReports wr ON u.UserId = wr.UserId
    LEFT JOIN PickupRequests pr ON wr.ReportId = pr.ReportId
    LEFT JOIN PickupVerifications pv ON pr.PickupId = pv.PickupId
    LEFT JOIN RewardPoints rp ON u.UserId = rp.UserId
    LEFT JOIN UserActivities ua ON u.UserId = ua.UserId
    WHERE u.RoleId IN (''CITZ'', ''R001'')
    GROUP BY u.UserId, u.FullName, u.Phone')
END
GO

IF NOT EXISTS (SELECT * FROM sys.views WHERE name = 'vw_RecentUserActivities')
BEGIN
    EXEC('CREATE VIEW vw_RecentUserActivities AS
    SELECT 
        ua.ActivityId,
        ua.UserId,
        u.FullName,
        ua.ActivityType,
        ua.Description,
        ua.Points,
        ua.Timestamp
    FROM UserActivities ua
    JOIN Users u ON ua.UserId = u.UserId
    WHERE ua.Timestamp >= DATEADD(DAY, -30, GETDATE())')
END
GO

-- ========================================
-- 8. SEED DATA (SEED FILE)
-- ========================================