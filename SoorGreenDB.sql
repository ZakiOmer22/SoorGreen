
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
    Name NVARCHAR(100) NOT NULL
);

-- WASTE TYPES: Categories of waste
CREATE TABLE WasteTypes (
    WasteTypeId CHAR(4) PRIMARY KEY,
    Name NVARCHAR(50) NOT NULL,
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
    Message NVARCHAR(1000),
    CreatedAt DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Feedbacks_User FOREIGN KEY(UserId) REFERENCES Users(UserId)
);

CREATE TABLE PickupVerifications (
    VerificationId CHAR(4) PRIMARY KEY,
    PickupId CHAR(4) NOT NULL,
    VerifiedKg DECIMAL(6,2) NOT NULL,
    MaterialType NVARCHAR(50),
    VerificationMethod NVARCHAR(50),
    VerifiedAt DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_PickupVerifications_Pickup FOREIGN KEY(PickupId) REFERENCES PickupRequests(PickupId)
);

-- ========================================
-- 3. INDEXES
-- ========================================
CREATE INDEX IX_Users_Email ON Users(Email);
CREATE INDEX IX_WasteReports_Date ON WasteReports(CreatedAt);
CREATE INDEX IX_PickupRequests_Status ON PickupRequests(Status);
CREATE INDEX IX_RewardPoints_UserId ON RewardPoints(UserId);
CREATE INDEX IX_Notifications_IsRead ON Notifications(IsRead);

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
-- 7. SEED DATA (SEED FILE)
-- ========================================
