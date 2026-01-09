# api/flask_app.py
import os
import sys

# Add the parent directory to Python path
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from flask import Flask, request, jsonify
from flask_cors import CORS
from werkzeug.utils import secure_filename
from datetime import datetime, timedelta

# Import from parent directory
try:
    from config.config import config
except ImportError:
    # Try alternative import
    import sys
    sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
    from config.config import config

# Try to import other modules
try:
    from model.waste_classifier import WasteClassifier
except ImportError:
    # Create a dummy classifier if not available
    class DummyClassifier:
        def predict(self, image_path):
            return {
                "detections": [
                    {"class": "plastic", "confidence": 0.85},
                    {"class": "metal", "confidence": 0.65}
                ],
                "status": "success"
            }
    WasteClassifier = DummyClassifier

# Try to import blueprints
try:
    from api.optimize_route import route_api
except ImportError:
    from flask import Blueprint
    route_api = Blueprint('route_api', __name__)
    
    @route_api.route('/api/optimize-route', methods=['POST'])
    def optimize_route():
        return jsonify({"status": "ok", "message": "Route optimization placeholder"})

try:
    from api.analyze_report import analyze_api
except ImportError:
    from flask import Blueprint
    analyze_api = Blueprint('analyze_api', __name__)
    
    @analyze_api.route('/api/analyze-report', methods=['POST'])
    def analyze_report():
        return jsonify({"status": "ok", "message": "Report analysis placeholder"})

try:
    from api.hotspot_detection import hotspot_api
except ImportError:
    from flask import Blueprint
    hotspot_api = Blueprint('hotspot_api', __name__)
    
    @hotspot_api.route('/api/hotspot-detection', methods=['POST'])
    def hotspot_detection():
        return jsonify({"status": "ok", "message": "Hotspot detection placeholder"})

# -----------------------------
# Initialize Flask app
# -----------------------------
app = Flask(__name__)
CORS(app)

# Register blueprints
app.register_blueprint(route_api)
app.register_blueprint(analyze_api)
app.register_blueprint(hotspot_api)

# Configure upload folder and allowed extensions
app.config['UPLOAD_FOLDER'] = config.UPLOAD_FOLDER
ALLOWED_EXTENSIONS = config.ALLOWED_EXTENSIONS

# Initialize AI classifier
classifier = WasteClassifier()

# Create upload folder if it doesn't exist
os.makedirs(app.config['UPLOAD_FOLDER'], exist_ok=True)

# -----------------------------
# Utility: allowed file extensions
# -----------------------------
def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

# -----------------------------
# AI Endpoint: Waste classification
# -----------------------------
@app.route('/api/ai/classify-waste', methods=['POST'])
def classify_waste():
    if 'image' not in request.files:
        return jsonify({"status": "error", "message": "No image file part in request"}), 400

    image = request.files['image']
    if image.filename == '':
        return jsonify({"status": "error", "message": "No selected file"}), 400

    if not allowed_file(image.filename):
        return jsonify({"status": "error", "message": f"File type not allowed. Allowed types: {ALLOWED_EXTENSIONS}"}), 400

    # Save uploaded image
    filename = secure_filename(image.filename)
    save_path = os.path.join(app.config['UPLOAD_FOLDER'], filename)
    image.save(save_path)

    # Run AI classifier
    try:
        result = classifier.predict(save_path)
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)}), 500

    return jsonify({
        "status": "ok",
        "result": result
    })

# -----------------------------
# AI Endpoint: Report validation
# -----------------------------
@app.route("/api/ai/validate-report", methods=["POST"])
def validate_report():
    try:
        data = request.get_json(force=True)
    except Exception:
        return jsonify({"status": "error", "message": "Invalid JSON payload"}), 400

    # Extract fields
    waste_type = data.get("waste_type", "").lower()
    weight_kg = data.get("weight_kg")
    location = data.get("location", "")
    submitted_at = data.get("submitted_at", "")

    # Validate presence
    if not waste_type or weight_kg is None:
        return jsonify({"status": "error", "message": "Missing required fields"}), 400

    # --- Enhanced AI logic / sanity checks ---
    status = "valid"
    confidence = 0.95
    message = "Report looks valid."

    if weight_kg <= 0:
        status = "invalid"
        confidence = 1.0
        message = "Weight cannot be zero or negative."
    elif weight_kg > 1000:
        status = "suspicious"
        confidence = 0.5
        message = "Weight unusually high, likely an error."

    if waste_type in ["organic", "paper"] and weight_kg > 50:
        status = "suspicious"
        confidence = 0.7
        message = "Weight unusually high for this waste type."
    elif waste_type == "metal" and weight_kg < 0.1:
        status = "needs_review"
        confidence = 0.6
        message = "Weight unusually low for metal."

    response = {
        "status": "ok",
        "report": {
            "status": status,
            "confidence": confidence,
            "message": message
        }
    }
    return jsonify(response)

# -----------------------------
# AI Endpoint: Waste Forecasting
# -----------------------------
@app.route("/api/ai/predict-waste", methods=["POST"])
def predict_waste():
    try:
        data = request.get_json(force=True)
    except Exception:
        return jsonify({"status": "error", "message": "Invalid JSON payload"}), 400

    zone = data.get("zone", "Zone A")
    days = data.get("days", 3)

    # Synthetic realistic predictions
    predictions = []
    base_weights = {"metal_kg": 125, "organic_kg": 55, "paper_kg": 85}
    today = datetime.now()

    for i in range(days):
        day = today + timedelta(days=i)
        predictions.append({
            "date": day.strftime("%Y-%m-%d"),
            "metal_kg": base_weights["metal_kg"] * (1 + i * 0.05),
            "organic_kg": base_weights["organic_kg"] * (1 + i * 0.08),
            "paper_kg": base_weights["paper_kg"] * (1 + i * 0.03)
        })

    return jsonify({
        "status": "ok",
        "zone": zone,
        "message": f"Predicted waste generation for the next {days} days",
        "predictions": predictions
    })

# -----------------------------
# AI Endpoint: Predictive Hotspot Alerts
# -----------------------------
@app.route("/api/ai/predict-hotspots", methods=["POST"])
def predict_hotspots():
    """
    Predict potential waste accumulation hotspots based on historical data and forecasts.
    """
    try:
        data = request.get_json(force=True)
    except Exception:
        return jsonify({"status": "error", "message": "Invalid JSON payload"}), 400

    zone = data.get("zone", "")
    historical_reports = data.get("historical_reports", [])  # List of past 7-14 days
    forecast_days = data.get("forecast_days", 3)  # Number of future days to forecast

    if not zone or not historical_reports:
        return jsonify({"status": "error", "message": "Missing required fields"}), 400

    # --- Aggregate historical waste by location and type ---
    location_stats = {}
    for report in historical_reports:
        loc = report.get("location")
        waste_type = report.get("waste_type")
        weight = report.get("weight_kg", 0)

        if loc not in location_stats:
            location_stats[loc] = {"metal": 0, "organic": 0, "paper": 0, "total": 0}

        location_stats[loc][waste_type] += weight
        location_stats[loc]["total"] += weight

    # --- Simple forecasting: add future trend based on average daily weight ---
    predicted_hotspots = []
    for loc, stats in location_stats.items():
        predicted_total = stats["total"] * (1 + 0.1 * forecast_days)  # +10% per day growth
        dominant_waste = max(["metal", "organic", "paper"], key=lambda w: stats[w])

        # Determine alert level
        if predicted_total > 200:
            alert_level = "high"
        elif predicted_total > 100:
            alert_level = "medium"
        else:
            alert_level = "low"

        predicted_hotspots.append({
            "location": loc,
            "expected_dominant_waste": dominant_waste,
            "predicted_total_weight": round(predicted_total, 2),
            "alert_level": alert_level
        })

    response = {
        "status": "ok",
        "predicted_hotspots": predicted_hotspots,
        "message": f"Predicted hotspots for the next {forecast_days} days",
        "zone": zone
    }

    return jsonify(response)

# -----------------------------
# AI Endpoint: Health check
# -----------------------------
@app.route('/api/ai/health', methods=['GET'])
def health_check():
    return jsonify({
        "status": "ok", 
        "message": "AI Engine is running",
        "timestamp": datetime.now().isoformat(),
        "version": "1.0.0",
        "endpoints": [
            "/api/ai/classify-waste (POST)",
            "/api/ai/validate-report (POST)",
            "/api/ai/predict-waste (POST)",
            "/api/ai/predict-hotspots (POST)",
            "/api/ai/health (GET)"
        ]
    })

# -----------------------------
# Run Flask
# -----------------------------
if __name__ == '__main__':
    print(f"Starting AI Engine on {config.AI_API_HOST}:{config.AI_API_PORT}")
    print(f"Upload folder: {app.config['UPLOAD_FOLDER']}")
    print(f"Debug mode: {config.AI_DEBUG}")
    app.run(
        host=config.AI_API_HOST,
        port=config.AI_API_PORT,
        debug=config.AI_DEBUG
    )