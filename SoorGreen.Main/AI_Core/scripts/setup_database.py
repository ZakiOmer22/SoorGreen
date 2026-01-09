# scripts/setup_database.py
"""
Script to setup AI-related tables in the database
"""
import pyodbc
from config.config import config

def setup_ai_tables():
    """Create AI-related tables if they don't exist"""
    
    create_tables_sql = """
    -- AI Predictions Table
    IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'AI_Predictions')
    BEGIN
        CREATE TABLE AI_Predictions (
            PredictionId BIGINT IDENTITY(1,1) PRIMARY KEY,
            ReportId CHAR(4) NULL,
            ModelId INT NULL,
            PredictedWasteType NVARCHAR(100) NULL,
            Confidence FLOAT NULL,
            Severity INT NULL,
            BoundingBoxes NVARCHAR(MAX) NULL,
            PredictionTimestamp DATETIME DEFAULT GETDATE()
        );
        PRINT 'Created AI_Predictions table';
    END
    ELSE
        PRINT 'AI_Predictions table already exists';
    
    -- AI Model Registry Table
    IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'AI_ModelRegistry')
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
        
        -- Insert default model
        INSERT INTO AI_ModelRegistry (ModelName, Version, Framework, Description, Deployed)
        VALUES ('Waste Classifier CNN', '1.0.0', 'TensorFlow', 'CNN for waste classification', 1);
        
        PRINT 'Created AI_ModelRegistry table';
    END
    ELSE
        PRINT 'AI_ModelRegistry table already exists';
    
    -- Route Optimizations Table (if not exists)
    IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'RouteOptimizations')
    BEGIN
        CREATE TABLE RouteOptimizations (
            OptimizationId INT IDENTITY(1,1) PRIMARY KEY,
            RouteId NVARCHAR(50) NOT NULL,
            OptimizationType NVARCHAR(50) NOT NULL,
            OriginalDistance DECIMAL(10,2) NOT NULL,
            OptimizedDistance DECIMAL(10,2) NOT NULL,
            TimeSaved INT NOT NULL,
            FuelSaved DECIMAL(10,2) NOT NULL,
            OptimizationData NVARCHAR(MAX) NULL,
            CreatedAt DATETIME DEFAULT GETDATE()
        );
        PRINT 'Created RouteOptimizations table';
    END
    ELSE
        PRINT 'RouteOptimizations table already exists';
    
    -- Add AI-related columns to WasteReports if they don't exist
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE name = 'PredictedWasteType' AND object_id = OBJECT_ID('WasteReports'))
    BEGIN
        ALTER TABLE WasteReports ADD PredictedWasteType NVARCHAR(100) NULL;
        PRINT 'Added PredictedWasteType column to WasteReports';
    END
    
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE name = 'AIConfidence' AND object_id = OBJECT_ID('WasteReports'))
    BEGIN
        ALTER TABLE WasteReports ADD AIConfidence FLOAT NULL;
        PRINT 'Added AIConfidence column to WasteReports';
    END
    
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE name = 'AutoAssignedByAI' AND object_id = OBJECT_ID('PickupRequests'))
    BEGIN
        ALTER TABLE PickupRequests ADD AutoAssignedByAI BIT DEFAULT 0;
        PRINT 'Added AutoAssignedByAI column to PickupRequests';
    END
    """
    
    try:
        # Connect to database
        conn = pyodbc.connect(config.SQL_CONNECTION_STRING)
        cursor = conn.cursor()
        
        # Split SQL by GO statements
        sql_statements = create_tables_sql.split('GO')
        
        for sql in sql_statements:
            if sql.strip():
                cursor.execute(sql)
        
        conn.commit()
        cursor.close()
        conn.close()
        
        print("✓ AI database setup completed successfully!")
        return True
        
    except Exception as e:
        print(f"✗ Database setup failed: {e}")
        return False

if __name__ == "__main__":
    print("Setting up AI database tables...")
    setup_ai_tables()