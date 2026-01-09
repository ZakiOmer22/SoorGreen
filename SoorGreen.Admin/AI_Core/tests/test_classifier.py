# tests/test_classifier.py
import sys
import os
import io
from PIL import Image, ImageDraw

# Add parent directory to path
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from services.waste_classifier import classifier

def create_test_image_bytes(waste_type="Plastic"):
    """Create test image bytes for different waste types"""
    # Create different images based on waste type
    img = Image.new('RGB', (300, 300), color='white')
    draw = ImageDraw.Draw(img)
    
    if waste_type == "Plastic":
        # Colorful plastic bottle
        img = Image.new('RGB', (300, 300), color='lightblue')
        draw = ImageDraw.Draw(img)
        draw.rectangle([100, 50, 200, 250], fill='red', outline='black')
        draw.ellipse([100, 30, 200, 70], fill='blue')
        draw.text((120, 120), "PET", fill='white')
        
    elif waste_type == "Paper":
        # Brown paper/cardboard
        img = Image.new('RGB', (300, 300), color='#D2B48C')  # tan color
        draw = ImageDraw.Draw(img)
        draw.rectangle([50, 50, 250, 250], fill='#8B4513', outline='black')  # saddle brown
        draw.text((130, 140), "📦", fill='white')
        
    elif waste_type == "Glass":
        # Transparent glass bottle
        img = Image.new('RGB', (300, 300), color='lightgray')
        draw = ImageDraw.Draw(img)
        draw.rectangle([120, 80, 180, 240], fill=(200, 220, 240, 128), outline='darkgray')
        draw.ellipse([120, 60, 180, 100], fill=(180, 200, 220, 128))
        
    elif waste_type == "Metal":
        # Metallic can
        img = Image.new('RGB', (300, 300), color='gray')
        draw = ImageDraw.Draw(img)
        draw.rectangle([100, 100, 200, 200], fill='silver', outline='darkgray')
        draw.text((140, 150), "🥫", fill='black')
        
    elif waste_type == "Hazardous":
        # Hazardous warning
        img = Image.new('RGB', (300, 300), color='yellow')
        draw = ImageDraw.Draw(img)
        draw.polygon([(150, 50), (250, 150), (150, 250), (50, 150)], fill='red')
        draw.text((130, 140), "!", fill='white')
        
    else:
        # Generic waste
        draw.rectangle([50, 50, 250, 250], fill='green', outline='black')
        draw.text((130, 140), "🗑️", fill='white')
    
    # Convert to bytes
    img_bytes = io.BytesIO()
    img.save(img_bytes, format='JPEG')
    return img_bytes.getvalue()

def test_classifier():
    """Test waste classifier with different images"""
    print("🧪 Testing Waste Classifier")
    print("="*50)
    
    test_cases = [
        ("Plastic", 10.0),
        ("Paper", 5.0),
        ("Glass", 8.0),
        ("Metal", 15.0),
        ("Hazardous", 30.0),
        ("Other", 2.0)
    ]
    
    results = []
    
    for waste_type, expected_rate in test_cases:
        print(f"\nTesting: {waste_type}")
        
        # Create test image
        image_bytes = create_test_image_bytes(waste_type)
        
        # Classify
        result = classifier.classify(image_bytes)
        
        if result:
            predicted = result.get('predicted_class', 'Unknown')
            confidence = result.get('confidence', 0)
            
            # Calculate credits
            credits = classifier.calculate_credits(predicted, 2.5)
            
            print(f"  Predicted: {predicted} ({confidence:.1%})")
            print(f"  Credits for 2.5kg: {credits}")
            print(f"  Model: {result.get('model_type', 'Unknown')}")
            
            # Check if prediction is reasonable
            is_reasonable = confidence > 0.3
            symbol = "✅" if is_reasonable else "⚠"
            print(f"  {symbol} Reasonable confidence")
            
            results.append(is_reasonable)
        else:
            print(f"  ❌ Classification failed")
            results.append(False)
    
    # Summary
    print("\n" + "="*50)
    print("📊 CLASSIFIER TEST SUMMARY")
    print("="*50)
    
    passed = sum(results)
    total = len(results)
    
    print(f"Tests: {total}")
    print(f"Passed: {passed}")
    print(f"Failed: {total - passed}")
    
    if passed == total:
        print("🎉 All classifier tests passed!")
    else:
        print(f"⚠ {total - passed} test(s) failed")
    
    return passed == total

def test_credit_calculation():
    """Test credit calculation"""
    print("\n🧪 Testing Credit Calculation")
    print("="*50)
    
    test_cases = [
        ("Plastic", 10.0, 5.0, 50.0),    # 5kg plastic = 50 credits
        ("Paper", 5.0, 10.0, 50.0),      # 10kg paper = 50 credits
        ("Glass", 8.0, 3.0, 24.0),       # 3kg glass = 24 credits
        ("Metal", 15.0, 2.0, 30.0),      # 2kg metal = 30 credits
        ("Electronic", 25.0, 1.0, 25.0), # 1kg electronic = 25 credits
        ("Other", 2.0, 20.0, 40.0)       # 20kg other = 40 credits
    ]
    
    for waste_type, expected_rate, weight, expected_credits in test_cases:
        credits = classifier.calculate_credits(waste_type, weight)
        calculated_rate = credits / weight
        
        # Allow small rounding differences
        success = abs(calculated_rate - expected_rate) < 0.1
        
        symbol = "✅" if success else "❌"
        print(f"{symbol} {waste_type}: {weight}kg = {credits} credits (rate: {calculated_rate:.1f}/kg)")
        
        if not success:
            print(f"   Expected rate: {expected_rate}/kg")

if __name__ == "__main__":
    print("WASTE CLASSIFIER TESTS")
    print("="*60)
    
    # Run classifier tests
    classifier_ok = test_classifier()
    
    # Run credit calculation tests
    test_credit_calculation()
    
    print("\n" + "="*60)
    if classifier_ok:
        print("🎉 Classifier tests completed successfully!")
    else:
        print("⚠ Some classifier tests failed")
    
    sys.exit(0 if classifier_ok else 1)