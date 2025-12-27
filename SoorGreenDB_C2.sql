USE SoorGreenDB;
GO

/**********************************************
  PHASE 2 ENHANCEMENT SCRIPT - SoorGreenDB
  - Add RBAC tables
  - Soft delete + MunicipalityId on business tables
  - AI tables and columns
  - MediaFiles, EventLog, Validation tables
  - Extended AuditLogs
  - RLS predicate functions & policies (SQL Server)
  - Partition function/scheme placeholders
  - Helpful indexes
**********************************************/

-------------------------------------------------------------------
-- 1) RBAC: Permissions, RolePermissions, UserRoles
-------------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'Permissions')
BEGIN
CREATE TABLE Permissions (
    PermissionCode NVARCHAR(100) PRIMARY KEY,
    Description NVARCHAR(300) NULL
);
END

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'RolePermissions')
BEGIN
CREATE TABLE RolePermissions (
    RoleId CHAR(4) NOT NULL,
    PermissionCode NVARCHAR(100) NOT NULL,
    CONSTRAINT FK_RP_Roles FOREIGN KEY (RoleId) REFERENCES Roles(RoleId),
    CONSTRAINT FK_RP_Perms FOREIGN KEY (PermissionCode) REFERENCES Permissions(PermissionCode),
    CONSTRAINT PK_RolePermissions PRIMARY KEY (RoleId, PermissionCode)
);
END

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'UserRoles')
BEGIN
CREATE TABLE UserRoles (
    UserRoleId INT IDENTITY(1,1) PRIMARY KEY,
    UserId CHAR(4) NOT NULL,
    RoleId CHAR(4) NOT NULL,
    AssignedAt DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_UserRoles_Users FOREIGN KEY (UserId) REFERENCES Users(UserId),
    CONSTRAINT FK_UserRoles_Roles FOREIGN KEY (RoleId) REFERENCES Roles(RoleId)
);
END

-- Seed some permissions if they don't exist
IF NOT EXISTS (SELECT 1 FROM Permissions WHERE PermissionCode = 'REPORT_CREATE')
    INSERT INTO Permissions (PermissionCode, Description) VALUES ('REPORT_CREATE','Create a waste report');
IF NOT EXISTS (SELECT 1 FROM Permissions WHERE PermissionCode = 'PICKUP_ASSIGN')
    INSERT INTO Permissions (PermissionCode, Description) VALUES ('PICKUP_ASSIGN','Assign pickup to collector');
IF NOT EXISTS (SELECT 1 FROM Permissions WHERE PermissionCode = 'VIEW_ANALYTICS')
    INSERT INTO Permissions (PermissionCode, Description) VALUES ('VIEW_ANALYTICS','View analytics and dashboards');

-------------------------------------------------------------------
-- 2) Soft delete + MunicipalityId and extra columns for business tables
-- Add columns with IF NOT EXISTS checks so it's safe to re-run
-------------------------------------------------------------------

-- Utility: add column if not exists
CREATE PROCEDURE dbo.__AddColumnIfNotExists
    @SchemaName SYSNAME,
    @TableName SYSNAME,
    @ColumnDDL NVARCHAR(MAX)
AS
BEGIN
    DECLARE @sql NVARCHAR(MAX);
    IF NOT EXISTS (
        SELECT 1
        FROM sys.columns c
        JOIN sys.objects o ON c.object_id = o.object_id
        JOIN sys.schemas s ON o.schema_id = s.schema_id
        WHERE s.name = @SchemaName AND o.name = @TableName AND c.name = PARSENAME(REPLACE(@ColumnDDL,' ','.'),1)
    )
    BEGIN
        SET @sql = N'ALTER TABLE ' + QUOTENAME(@SchemaName) + '.' + QUOTENAME(@TableName) + ' ADD ' + @ColumnDDL;
        EXEC sp_executesql @sql;
    END
END;
GO

-- Add common lifecycle/soft-delete fields to core tables
EXEC dbo.__AddColumnIfNotExists 'dbo','Users','IsDeleted BIT DEFAULT 0';
EXEC dbo.__AddColumnIfNotExists 'dbo','Users','DeletedAt DATETIME NULL';
EXEC dbo.__AddColumnIfNotExists 'dbo','Users','DeletedBy CHAR(4) NULL';
EXEC dbo.__AddColumnIfNotExists 'dbo','Users','DeviceId NVARCHAR(100) NULL';
EXEC dbo.__AddColumnIfNotExists 'dbo','Users','TwoFactorEnabled BIT DEFAULT 0';

EXEC dbo.__AddColumnIfNotExists 'dbo','WasteReports','IsDeleted BIT DEFAULT 0';
EXEC dbo.__AddColumnIfNotExists 'dbo','WasteReports','DeletedAt DATETIME NULL';
EXEC dbo.__AddColumnIfNotExists 'dbo','WasteReports','DeletedBy CHAR(4) NULL';
EXEC dbo.__AddColumnIfNotExists 'dbo','WasteReports','MunicipalityId CHAR(4) NULL';
EXEC dbo.__AddColumnIfNotExists 'dbo','WasteReports','Severity INT NULL';
EXEC dbo.__AddColumnIfNotExists 'dbo','WasteReports','PredictedWasteType NVARCHAR(100) NULL';
EXEC dbo.__AddColumnIfNotExists 'dbo','WasteReports','AIConfidence FLOAT NULL';
EXEC dbo.__AddColumnIfNotExists 'dbo','WasteReports','Metadata NVARCHAR(MAX) NULL'; -- JSON / bounding boxes
EXEC dbo.__AddColumnIfNotExists 'dbo','WasteReports','IsHazardous BIT DEFAULT 0';
EXEC dbo.__AddColumnIfNotExists 'dbo','WasteReports','VerifiedByAdminID CHAR(4) NULL';
EXEC dbo.__AddColumnIfNotExists 'dbo','WasteReports','VerifiedAt DATETIME NULL';
EXEC dbo.__AddColumnIfNotExists 'dbo','WasteReports','StatusUpdatedAt DATETIME NULL';

-- Ensure foreign key to Municipalities (nullable)
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_WasteReports_Municipalities')
BEGIN
    ALTER TABLE dbo.WasteReports
    ADD CONSTRAINT FK_WasteReports_Municipalities FOREIGN KEY (MunicipalityId) REFERENCES Municipalities(MunicipalityId);
END

EXEC dbo.__AddColumnIfNotExists 'dbo','PickupRequests','IsDeleted BIT DEFAULT 0';
EXEC dbo.__AddColumnIfNotExists 'dbo','PickupRequests','DeletedAt DATETIME NULL';
EXEC dbo.__AddColumnIfNotExists 'dbo','PickupRequests','DeletedBy CHAR(4) NULL';
EXEC dbo.__AddColumnIfNotExists 'dbo','PickupRequests','MunicipalityId CHAR(4) NULL';
EXEC dbo.__AddColumnIfNotExists 'dbo','PickupRequests','AutoAssignedByAI BIT DEFAULT 0';
EXEC dbo.__AddColumnIfNotExists 'dbo','PickupRequests','CompletionProofImage NVARCHAR(512) NULL';
EXEC dbo.__AddColumnIfNotExists 'dbo','PickupRequests','CompletionGPSLat DECIMAL(10,6) NULL';
EXEC dbo.__AddColumnIfNotExists 'dbo','PickupRequests','CompletionGPSLong DECIMAL(10,6) NULL';
EXEC dbo.__AddColumnIfNotExists 'dbo','PickupRequests','IsOverdue BIT DEFAULT 0';

-- Add municipality to CollectorRoutes, CollectorLocations, RewardPoints, Notifications, AuditLogs, Feedbacks
EXEC dbo.__AddColumnIfNotExists 'dbo','CollectorRoutes','MunicipalityId CHAR(4) NULL';
EXEC dbo.__AddColumnIfNotExists 'dbo','CollectorLocations','MunicipalityId CHAR(4) NULL';
EXEC dbo.__AddColumnIfNotExists 'dbo','RewardPoints','MunicipalityId CHAR(4) NULL';
EXEC dbo.__AddColumnIfNotExists 'dbo','Notifications','MunicipalityId CHAR(4) NULL';
EXEC dbo.__AddColumnIfNotExists 'dbo','AuditLogs','MunicipalityId CHAR(4) NULL';
EXEC dbo.__AddColumnIfNotExists 'dbo','Feedbacks','MunicipalityId CHAR(4) NULL';

-- Add FK from these tables to Municipalities if not exists (safe because nullable)
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_CollectorRoutes_Municipalities')
BEGIN
    ALTER TABLE dbo.CollectorRoutes
    ADD CONSTRAINT FK_CollectorRoutes_Municipalities FOREIGN KEY (MunicipalityId) REFERENCES Municipalities(MunicipalityId);
END
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_CollectorLocations_Municipalities')
BEGIN
    ALTER TABLE dbo.CollectorLocations
    ADD CONSTRAINT FK_CollectorLocations_Municipalities FOREIGN KEY (MunicipalityId) REFERENCES Municipalities(MunicipalityId);
END
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_RewardPoints_Municipalities')
BEGIN
    ALTER TABLE dbo.RewardPoints
    ADD CONSTRAINT FK_RewardPoints_Municipalities FOREIGN KEY (MunicipalityId) REFERENCES Municipalities(MunicipalityId);
END

-- Add soft-delete & audit fields to other tables that will benefit
EXEC dbo.__AddColumnIfNotExists 'dbo','Vehicles','IsDeleted BIT DEFAULT 0';
EXEC dbo.__AddColumnIfNotExists 'dbo','Vehicles','MunicipalityId CHAR(4) NULL';
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_Vehicles_Municipalities')
BEGIN
    ALTER TABLE dbo.Vehicles
    ADD CONSTRAINT FK_Vehicles_Municipalities FOREIGN KEY (MunicipalityId) REFERENCES Municipalities(MunicipalityId);
END

-- Add IsDeleted to UserActivities and ErrorLogs
EXEC dbo.__AddColumnIfNotExists 'dbo','UserActivities','IsDeleted BIT DEFAULT 0';
EXEC dbo.__AddColumnIfNotExists 'dbo','ErrorLogs','IsDeleted BIT DEFAULT 0';

-------------------------------------------------------------------
-- 3) AI Tables: Raw data, FeatureStore, ModelRegistry, Predictions, Feedback, Insights
-------------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'AI_RawData')
BEGIN
CREATE TABLE AI_RawData (
    DataId BIGINT IDENTITY(1,1) PRIMARY KEY,
    SourceTable NVARCHAR(128),
    SourceId NVARCHAR(128) NULL,
    JsonPayload NVARCHAR(MAX) NULL, -- snapshot for training
    CapturedAt DATETIME DEFAULT GETDATE()
);
END

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'AI_FeatureStore')
BEGIN
CREATE TABLE AI_FeatureStore (
    FeatureId BIGINT IDENTITY(1,1) PRIMARY KEY,
    RelatedEntity NVARCHAR(128) NULL,
    RelatedEntityId NVARCHAR(128) NULL,
    FeatureName NVARCHAR(200),
    FeatureValue NVARCHAR(MAX),
    CreatedAt DATETIME DEFAULT GETDATE()
);
END

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'AI_ModelRegistry')
BEGIN
CREATE TABLE AI_ModelRegistry (
    ModelId INT IDENTITY(1,1) PRIMARY KEY,
    ModelName NVARCHAR(200) NOT NULL,
    Version NVARCHAR(50) NOT NULL,
    Framework NVARCHAR(50) NULL,
    FilePath NVARCHAR(500) NULL,
    Description NVARCHAR(MAX) NULL,
    Deployed BIT DEFAULT 0,
    CreatedAt DATETIME DEFAULT GETDATE()
);
END

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'AI_Predictions')
BEGIN
CREATE TABLE AI_Predictions (
    PredictionId BIGINT IDENTITY(1,1) PRIMARY KEY,
    ReportId CHAR(4) NULL,
    ModelId INT NULL,
    PredictedWasteType NVARCHAR(100) NULL,
    Confidence FLOAT NULL,
    Severity INT NULL,
    BoundingBoxes NVARCHAR(MAX) NULL, -- JSON array of bboxes if any
    PredictionTimestamp DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_AIPreds_Model FOREIGN KEY(ModelId) REFERENCES AI_ModelRegistry(ModelId),
    CONSTRAINT FK_AIPreds_Report FOREIGN KEY(ReportId) REFERENCES WasteReports(ReportId)
);
END

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'AI_FeedbackLoop')
BEGIN
CREATE TABLE AI_FeedbackLoop (
    FeedbackId BIGINT IDENTITY(1,1) PRIMARY KEY,
    PredictionId BIGINT NOT NULL,
    ReviewerId CHAR(4) NULL,
    CorrectLabel NVARCHAR(100) NULL,
    Comments NVARCHAR(MAX) NULL,
    ReviewedAt DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_AIFeed_Pred FOREIGN KEY(PredictionId) REFERENCES AI_Predictions(PredictionId)
);
END

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'AI_Insights')
BEGIN
CREATE TABLE AI_Insights (
    InsightId BIGINT IDENTITY(1,1) PRIMARY KEY,
    Category NVARCHAR(200) NULL,
    Data NVARCHAR(MAX) NULL,
    GeneratedAt DATETIME DEFAULT GETDATE()
);
END

-------------------------------------------------------------------
-- 4) MediaFiles table (store URIs to blob storage) and EventLog
-------------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'MediaFiles')
BEGIN
CREATE TABLE MediaFiles (
    FileId NVARCHAR(100) PRIMARY KEY,
    UserId CHAR(4) NULL,
    EntityType NVARCHAR(100) NULL, -- e.g., 'WasteReport','Pickup','User'
    EntityId NVARCHAR(100) NULL,
    FileUrl NVARCHAR(1000) NOT NULL,
    FileType NVARCHAR(50) NULL,
    SizeBytes BIGINT NULL,
    CreatedAt DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_MediaFiles_Users FOREIGN KEY (UserId) REFERENCES Users(UserId)
);
END

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'EventLog')
BEGIN
CREATE TABLE EventLog (
    EventId BIGINT IDENTITY(1,1) PRIMARY KEY,
    EventType NVARCHAR(200) NOT NULL,
    Payload NVARCHAR(MAX) NULL,
    Source NVARCHAR(200) NULL,
    CreatedAt DATETIME DEFAULT GETDATE()
);
END

-------------------------------------------------------------------
-- 5) Validation Rules & ValidationErrors
-------------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'ValidationRules')
BEGIN
CREATE TABLE ValidationRules (
    RuleId INT IDENTITY(1,1) PRIMARY KEY,
    EntityName NVARCHAR(200) NOT NULL,
    FieldName NVARCHAR(200) NOT NULL,
    RuleType NVARCHAR(50) NOT NULL, -- Regex, Range, Required, Enum
    RuleValue NVARCHAR(1000) NULL,
    CreatedAt DATETIME DEFAULT GETDATE()
);
END

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'ValidationErrors')
BEGIN
CREATE TABLE ValidationErrors (
    ErrorId BIGINT IDENTITY(1,1) PRIMARY KEY,
    EntityName NVARCHAR(200),
    FieldName NVARCHAR(200),
    ErrorMessage NVARCHAR(1000),
    RowSnapshot NVARCHAR(MAX) NULL, -- JSON of the offending row
    CreatedAt DATETIME DEFAULT GETDATE()
);
END

-------------------------------------------------------------------
-- 6) Enhance AuditLogs: add IP, DeviceInfo, ChangedFields JSON, ActionSeverity
-------------------------------------------------------------------
EXEC dbo.__AddColumnIfNotExists 'dbo','AuditLogs','IPAddress NVARCHAR(50) NULL';
EXEC dbo.__AddColumnIfNotExists 'dbo','AuditLogs','DeviceInfo NVARCHAR(500) NULL';
EXEC dbo.__AddColumnIfNotExists 'dbo','AuditLogs','ChangedFields NVARCHAR(MAX) NULL';
EXEC dbo.__AddColumnIfNotExists 'dbo','AuditLogs','ActionSeverity NVARCHAR(20) NULL';

-------------------------------------------------------------------
-- 7) Row-Level Security (RLS) - predicate functions & security policies
-- NOTE: Requires SQL Server Enterprise/Standard features. If your instance
-- doesn't allow creating security policies, you can omit these or run later.
-------------------------------------------------------------------

/* 7.a) Predicate function for Users: allow user to select only their own row (for applications that use EXECUTE AS or application roles) */
IF OBJECT_ID('dbo.fn_securitypredicate_UserAccess','IF') IS NULL
BEGIN
    EXEC('
    CREATE FUNCTION dbo.fn_securitypredicate_UserAccess(@UserId CHAR(4))
    RETURNS TABLE
    WITH SCHEMABINDING
    AS
    RETURN SELECT 1 AS fn_securitypredicate_UserAccessResult WHERE @UserId = SUSER_NAME() OR EXISTS(SELECT 1 FROM dbo.Users u WHERE u.UserId = SUSER_SNAME() AND u.RoleId IN (SELECT RoleId FROM Roles WHERE RoleName = ''Admin'')) 
    ');
END
-- Note: SUSER_NAME / SUSER_SNAME usage above is placeholder. In many setups you map application user context to DB user or use session context. We'll provide a safer, pragmatic policy below that uses SESSION_CONTEXT key.

-- 7.b) Helper: session enforcement function using SESSION_CONTEXT('app_user')
-- This function checks if current row's UserId equals SESSION_CONTEXT('app_user') OR user has admin role.
IF OBJECT_ID('dbo.fn_rls_userpredicate','IF') IS NULL
BEGIN
EXEC('
CREATE FUNCTION dbo.fn_rls_userpredicate(@UserId CHAR(4))
RETURNS TABLE
WITH SCHEMABINDING
AS
RETURN
(
    SELECT 1 AS accessResult
    WHERE
    (
        -- allow if session context app_user matches @UserId
        ISNULL(SESSION_CONTEXT(N''app_user''), N'''') = @UserId
        OR
        -- OR session context app_roles has ADMIN (simple text check)
        CHARINDEX(N''ADMIN'', ISNULL(SESSION_CONTEXT(N''app_roles''), N'''')) > 0
    )
)
');
END

-- 7.c) Create RLS policy for WasteReports (read access)
IF NOT EXISTS (SELECT 1 FROM sys.security_policies WHERE name = 'policy_RLS_WasteReports')
BEGIN
    EXEC('
    CREATE SECURITY POLICY policy_RLS_WasteReports
    ADD FILTER PREDICATE dbo.fn_rls_userpredicate(UserId) ON dbo.WasteReports
    WITH (STATE = ON)
    ');
END

-- 7.d) Create RLS policy for PickupRequests: allow collectors to see assigned, citizens to see own
IF NOT EXISTS (SELECT 1 FROM sys.security_policies WHERE name = 'policy_RLS_PickupRequests')
BEGIN
    EXEC('
    CREATE FUNCTION dbo.fn_rls_pickuppredicate(@CollectorId CHAR(4))
    RETURNS TABLE
    WITH SCHEMABINDING
    AS
    RETURN
    (
        SELECT 1 AS rp
        WHERE
            -- session user equals the collector assigned
            ISNULL(SESSION_CONTEXT(N''app_user''), N'''') = @CollectorId
            OR CHARINDEX(N''ADMIN'', ISNULL(SESSION_CONTEXT(N''app_roles''), N'''')) > 0
    );

    CREATE SECURITY POLICY policy_RLS_PickupRequests
    ADD FILTER PREDICATE dbo.fn_rls_pickuppredicate(CollectorId) ON dbo.PickupRequests
    WITH (STATE = ON)
    ');
END

-- Note: RLS setup above assumes the application will set SESSION_CONTEXT('app_user') and SESSION_CONTEXT('app_roles')
-- Example: EXEC sp_set_session_context 'app_user', 'U002';

-------------------------------------------------------------------
-- 8) Partitioning — placeholders (create function & scheme only if needed)
-- This creates a year-based partition function and scheme. Adjust filegroups manually for production.
-------------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM sys.partition_functions WHERE name = 'pf_WasteReports_ByYear')
BEGIN
    -- boundaries: 2023, 2024, 2025, 2026 ... adjust as required for production
    CREATE PARTITION FUNCTION pf_WasteReports_ByYear (DATETIME)
    AS RANGE RIGHT FOR VALUES ('2023-01-01','2024-01-01','2025-01-01','2026-01-01');
END

IF NOT EXISTS (SELECT 1 FROM sys.partition_schemes WHERE name = 'ps_WasteReports_ByYear')
BEGIN
    -- This will map all partitions to PRIMARY. In production, map to filegroups.
    CREATE PARTITION SCHEME ps_WasteReports_ByYear
    AS PARTITION pf_WasteReports_ByYear ALL TO ([PRIMARY]);
END

-- You can later switch WasteReports to partition scheme using SWITCH or creating a new table with scheme and migrating data.

-------------------------------------------------------------------
-- 9) Useful Indexes for new columns
-------------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_WasteReports_Municipality')
BEGIN
    CREATE INDEX IX_WasteReports_Municipality ON dbo.WasteReports(MunicipalityId);
END
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_WasteReports_PredictedType')
BEGIN
    CREATE INDEX IX_WasteReports_PredictedType ON dbo.WasteReports(PredictedWasteType);
END
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_PickupRequests_Municipality')
BEGIN
    CREATE INDEX IX_PickupRequests_Municipality ON dbo.PickupRequests(MunicipalityId);
END
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_AIPredictions_ReportId')
BEGIN
    CREATE INDEX IX_AIPredictions_ReportId ON dbo.AI_Predictions(ReportId);
END
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_AI_FeatureStore_RelatedEntity')
BEGIN
    CREATE INDEX IX_AI_FeatureStore_RelatedEntity ON dbo.AI_FeatureStore(RelatedEntity, RelatedEntityId);
END
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_MediaFiles_Entity')
BEGIN
    CREATE INDEX IX_MediaFiles_Entity ON dbo.MediaFiles(EntityType, EntityId);
END

-------------------------------------------------------------------
-- 10) Sample stored proc to set session context for RLS (to be called by app after connection)
-------------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'sp_SetSessionUserContext')
BEGIN
EXEC('
CREATE PROCEDURE sp_SetSessionUserContext
    @AppUserId NVARCHAR(50),
    @AppRoles NVARCHAR(500)
AS
BEGIN
    -- set application user and roles for RLS
    EXEC sp_set_session_context ''app_user'', @AppUserId;
    EXEC sp_set_session_context ''app_roles'', @AppRoles;
END
');
END

-------------------------------------------------------------------
-- 12) Sample data safety: ensure existing triggers/procs referencing columns continue to work
-- (We didn't drop or rename existing columns — all additions are additive)
-------------------------------------------------------------------

PRINT 'Phase 2 enhancement script executed. Review messages above for any warnings.';
GO

-- Cleanup helper procedure (optionally drop) - keep it for re-runs
-- To drop helper (uncomment if desired)
-- DROP PROCEDURE dbo.__AddColumnIfNotExists;
