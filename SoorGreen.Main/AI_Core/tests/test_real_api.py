# tests/test_real_api.py
import requests
import json
import time
import os
import sys

# Add parent directory to path to import config
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from config.config import config

BASE_URL = f"http://{config.AI_API_HOST}:{config.AI_API_PORT}"

def print_test_result(name, success, message=""):
    """Helper to print test results"""
    symbol = "✅" if success else "❌"
    print(f"{symbol} {name}")
    if message:
        print(f"   {message}")

def wait_for_server(timeout=30):
    """Wait for server to be ready"""
    print("⏳ Waiting for server to start...")
    start_time = time.time()
    
    while time.time() - start_time < timeout:
        try:
            response = requests.get(f"{BASE_URL}/", timeout=2)
            if response.status_code == 200:
                print("✅ Server is ready!")
                return True
        except:
            pass
        
        print(".", end="", flush=True)
        time.sleep(1)
    
    print(f"\n❌ Server not ready after {timeout} seconds")
    return False

def test_home_endpoint():
    """Test the home endpoint"""
    print("\n📋 Test 1: Home Endpoint")
    try:
        response = requests.get(f"{BASE_URL}/", timeout=10)
        data = response.json()
        
        success = response.status_code == 200
        message = f"Status: {response.status_code}, Version: {data.get('version', 'N/A')}"
        print_test_result("GET /", success, message)
        
        return success
    except Exception as e:
        print_test_result("GET /", False, f"Error: {e}")
        return False

def test_health_endpoint():
    """Test the health endpoint"""
    print("\n📋 Test 2: Health Endpoint")
    try:
        response = requests.get(f"{BASE_URL}/api/ai/health", timeout=10)
        data = response.json()
        
        success = response.status_code == 200 and data.get('status') == 'healthy'
        message = f"Status: {data.get('status', 'N/A')}, Database: {data.get('database', 'N/A')}"
        print_test_result("GET /api/ai/health", success, message)
        
        return success
    except Exception as e:
        print_test_result("GET /api/ai/health", False, f"Error: {e}")
        return False

def test_database_test_endpoint():
    """Test database connectivity endpoint"""
    print("\n📋 Test 3: Database Test Endpoint")
    try:
        response = requests.get(f"{BASE_URL}/api/ai/database-test", timeout=15)
        data = response.json()
        
        success = response.status_code == 200 and data.get('success') == True
        message = f"Success: {data.get('success', False)}, Tests: {len(data.get('tests', []))}"
        print_test_result("GET /api/ai/database-test", success, message)
        
        if data.get('tests'):
            for test in data.get('tests', []):
                status_icon = "✓" if test['status'] == 'passed' else "✗" if test['status'] == 'failed' else "ℹ"
                print(f"   {status_icon} {test['test']}: {test['message']}")
        
        return success
    except Exception as e:
        print_test_result("GET /api/ai/database-test", False, f"Error: {e}")
        return False

def test_pending_pickups_endpoint():
    """Test pending pickups endpoint"""
    print("\n📋 Test 4: Pending Pickups Endpoint")
    try:
        response = requests.get(f"{BASE_URL}/api/ai/pending-pickups", timeout=10)
        data = response.json()
        
        success = response.status_code == 200 and data.get('success') == True
        count = data.get('count', 0)
        message = f"Found {count} pending pickups"
        print_test_result("GET /api/ai/pending-pickups", success, message)
        
        return success
    except Exception as e:
        print_test_result("GET /api/ai/pending-pickups", False, f"Error: {e}")
        return False

def test_waste_types_endpoint():
    """Test waste types endpoint"""
    print("\n📋 Test 5: Waste Types Endpoint")
    try:
        response = requests.get(f"{BASE_URL}/api/ai/waste-types", timeout=10)
        data = response.json()
        
        success = response.status_code == 200 and data.get('success') == True
        count = data.get('count', 0)
        message = f"Found {count} waste types"
        print_test_result("GET /api/ai/waste-types", success, message)
        
        if success and count > 0:
            waste_types = data.get('waste_types', [])[:3]
            for wt in waste_types:
                print(f"   - {wt.get('Name', 'Unknown')}: ${wt.get('CreditPerKg', 0)}/kg")
        
        return success
    except Exception as e:
        print_test_result("GET /api/ai/waste-types", False, f"Error: {e}")
        return False

def test_route_optimization():
    """Test route optimization endpoint"""
    print("\n📋 Test 6: Route Optimization Endpoint")
    try:
        sample_data = {
            "pickups": [
                {
                    "id": "PK001",
                    "lat": 40.7128,
                    "lng": -74.0060,
                    "weight": 15.5,
                    "address": "Manhattan, NY"
                },
                {
                    "id": "PK002",
                    "lat": 40.6782,
                    "lng": -73.9442,
                    "weight": 8.2,
                    "address": "Brooklyn, NY"
                },
                {
                    "id": "PK003",
                    "lat": 40.7282,
                    "lng": -73.7949,
                    "weight": 12.8,
                    "address": "Queens, NY"
                }
            ],
            "vehicle_capacities": [500.0],
            "num_vehicles": 1,
            "depot_location": [40.7306, -73.9352]
        }
        
        response = requests.post(
            f"{BASE_URL}/api/ai/optimize-routes",
            json=sample_data,
            headers={"Content-Type": "application/json"},
            timeout=15
        )
        
        data = response.json()
        success = response.status_code == 200 and data.get('success') == True
        
        if success:
            message = f"Optimized {len(sample_data['pickups'])} pickups, Distance: {data.get('total_distance_km', 0)}km"
            print_test_result("POST /api/ai/optimize-routes", success, message)
            
            # Show savings if available
            savings = data.get('savings', {})
            if savings:
                print(f"   💰 Estimated savings: ${savings.get('total_savings', 0):.2f}")
        else:
            error_msg = data.get('error', 'Unknown error')
            print_test_result("POST /api/ai/optimize-routes", False, f"Error: {error_msg}")
        
        return success
    except Exception as e:
        print_test_result("POST /api/ai/optimize-routes", False, f"Error: {e}")
        return False

def test_classification_with_image():
    """Test waste classification with an image"""
    print("\n📋 Test 7: Waste Classification (with test image)")
    
    # Check if test image exists
    test_image_path = "data/images/test_waste.jpg"
    
    if not os.path.exists(test_image_path):
        print("⚠  No test image found. Creating one...")
        create_test_image()
    
    if os.path.exists(test_image_path):
        try:
            with open(test_image_path, 'rb') as f:
                files = {'file': ('test_waste.jpg', f, 'image/jpeg')}
                data = {'weight_kg': '2.5', 'report_id': 'WR001'}
                
                response = requests.post(
                    f"{BASE_URL}/api/ai/classify-waste",
                    files=files,
                    data=data,
                    timeout=15
                )
            
            data = response.json()
            success = response.status_code == 200 and data.get('success') == True
            
            if success:
                prediction = data.get('prediction', {})
                waste_type = prediction.get('predicted_class', 'Unknown')
                confidence = prediction.get('confidence', 0)
                credits = data.get('suggested_credits', 0)
                
                message = f"Predicted: {waste_type} ({confidence:.1%}), Credits: {credits}"
                print_test_result("POST /api/ai/classify-waste", success, message)
            else:
                error_msg = data.get('error', 'Unknown error')
                print_test_result("POST /api/ai/classify-waste", False, f"Error: {error_msg}")
            
            return success
        except Exception as e:
            print_test_result("POST /api/ai/classify-waste", False, f"Error: {e}")
            return False
    else:
        print("⚠  Skipping image classification test (no test image)")
        return True  # Skip, not fail

def create_test_image():
    """Create a test image if it doesn't exist"""
    try:
        from PIL import Image, ImageDraw, ImageFont
        import os
        
        # Create directory if it doesn't exist
        os.makedirs("data/images", exist_ok=True)
        
        # Create a simple test image
        img = Image.new('RGB', (300, 300), color='lightblue')
        draw = ImageDraw.Draw(img)
        
        # Draw some shapes
        draw.rectangle([50, 50, 150, 150], fill='white', outline='black')
        draw.ellipse([180, 100, 280, 200], fill='green', outline='black')
        
        # Add text
        try:
            font = ImageFont.truetype("arial.ttf", 20)
        except:
            font = ImageFont.load_default()
        
        draw.text((80, 20), "Test Waste Image", fill='black', font=font)
        draw.text((90, 250), "SoorGreen AI", fill='darkgreen', font=font)
        
        # Save
        img.save("data/images/test_waste.jpg")
        print("✅ Created test_waste.jpg")
        
    except Exception as e:
        print(f"⚠  Could not create test image: {e}")

def run_all_tests():
    """Run all API tests"""
    print("="*60)
    print("🧪 SOORGREEN AI ENGINE - API TEST SUITE")
    print("="*60)
    
    # First, wait for server
    if not wait_for_server():
        print("\n❌ Cannot run tests - server not available")
        return False
    
    # Run all tests
    tests = [
        test_home_endpoint,
        test_health_endpoint,
        test_database_test_endpoint,
        test_pending_pickups_endpoint,
        test_waste_types_endpoint,
        test_route_optimization,
        test_classification_with_image
    ]
    
    results = []
    for test in tests:
        results.append(test())
        time.sleep(1)  # Small delay between tests
    
    # Summary
    print("\n" + "="*60)
    print("📊 TEST SUMMARY")
    print("="*60)
    
    passed = sum(results)
    total = len(results)
    
    print(f"Total Tests: {total}")
    print(f"Passed: {passed}")
    print(f"Failed: {total - passed}")
    print(f"Success Rate: {(passed/total*100):.1f}%")
    
    if passed == total:
        print("\n🎉 ALL TESTS PASSED!")
    else:
        print(f"\n⚠  {total - passed} test(s) failed")
    
    return passed == total

if __name__ == "__main__":
    # Check if server is specified
    if len(sys.argv) > 1:
        BASE_URL = sys.argv[1]
        print(f"Using custom base URL: {BASE_URL}")
    
    success = run_all_tests()
    sys.exit(0 if success else 1)