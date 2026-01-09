# tests/test_database.py
import sys
import os

# Add parent directory to path
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from services.database import db
from config.config import config

def test_database_connection():
    """Test direct database connection"""
    print("🧪 Testing Database Connection")
    print("="*50)
    
    print(f"Server: {config.DB_SERVER}")
    print(f"Database: {config.DB_NAME}")
    print(f"User: {config.DB_USER}")
    
    # Test connection
    print("\n1. Testing connection...")
    if db.connect():
        print("✅ Database connected successfully!")
    else:
        print("❌ Database connection failed")
        return False
    
    # Test simple query
    print("\n2. Testing simple query...")
    try:
        result = db.execute_query("SELECT @@VERSION as sql_version")
        if result:
            print(f"✅ SQL Server version: {result[0].get('sql_version', 'Unknown')[:100]}...")
        else:
            print("❌ Could not get SQL Server version")
            return False
    except Exception as e:
        print(f"❌ Query error: {e}")
        return False
    
    # Test Users table
    print("\n3. Testing Users table...")
    try:
        result = db.execute_query("SELECT COUNT(*) as user_count FROM Users")
        if result:
            print(f"✅ Found {result[0]['user_count']} users in database")
        else:
            print("⚠ Users table might be empty or doesn't exist")
    except Exception as e:
        print(f"⚠ Users table error: {e}")
    
    # Test WasteReports table
    print("\n4. Testing WasteReports table...")
    try:
        result = db.execute_query("SELECT COUNT(*) as report_count FROM WasteReports")
        if result:
            print(f"✅ Found {result[0]['report_count']} waste reports")
        else:
            print("⚠ WasteReports table might be empty")
    except Exception as e:
        print(f"⚠ WasteReports error: {e}")
    
    # Test pending pickups method
    print("\n5. Testing pending pickups method...")
    try:
        pickups = db.get_pending_pickups()
        if pickups:
            print(f"✅ Found {len(pickups)} pending pickups")
            if len(pickups) > 0:
                print(f"   First pickup: {pickups[0].get('PickupId', 'N/A')} - {pickups[0].get('Address', 'N/A')}")
        else:
            print("⚠ No pending pickups found or error occurred")
    except Exception as e:
        print(f"⚠ Pending pickups error: {e}")
    
    # Test waste types method
    print("\n6. Testing waste types method...")
    try:
        waste_types = db.get_waste_types()
        if waste_types:
            print(f"✅ Found {len(waste_types)} waste types")
            for wt in waste_types[:3]:  # Show first 3
                print(f"   - {wt.get('Name', 'Unknown')}: ${wt.get('CreditPerKg', 0)}/kg")
        else:
            print("⚠ No waste types found or error occurred")
    except Exception as e:
        print(f"⚠ Waste types error: {e}")
    
    print("\n" + "="*50)
    print("✅ Database tests completed!")
    
    # Close connection
    db.close()
    
    return True

def test_save_prediction():
    """Test saving AI prediction"""
    print("\n🧪 Testing Save Prediction")
    print("="*50)
    
    if not db.connect():
        print("❌ Cannot test - database connection failed")
        return False
    
    # Test data
    test_prediction = {
        'predicted_class': 'Plastic',
        'confidence': 0.85,
        'bounding_boxes': [{'x': 10, 'y': 20, 'width': 100, 'height': 150}]
    }
    
    # Try to save prediction
    success = db.save_prediction('WR001', test_prediction)
    
    if success:
        print("✅ Prediction saved successfully!")
    else:
        print("⚠ Prediction save failed (might be due to missing AI_Predictions table)")
    
    db.close()
    return success

if __name__ == "__main__":
    print("DATABASE CONNECTION TESTS")
    print("="*60)
    
    # Run database connection tests
    connection_ok = test_database_connection()
    
    if connection_ok:
        # Run additional tests
        test_save_prediction()
    
    print("\n" + "="*60)
    if connection_ok:
        print("🎉 Database tests completed successfully!")
    else:
        print("❌ Database tests failed!")
    
    sys.exit(0 if connection_ok else 1)