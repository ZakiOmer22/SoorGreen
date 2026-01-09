from flask import Blueprint, request, jsonify
from datetime import datetime, timedelta

# Blueprint for this AI module
analyze_api = Blueprint("analyze_api", __name__, url_prefix="/api/ai")

# In-memory store to simulate previous reports for duplicate detection
# In production, this would be a database
previous_reports = []

@analyze_api.route("/analyze-report", methods=["POST"])
def analyze_report():
    try:
        data = request.get_json(force=True)
    except Exception:
        return jsonify({"status": "error", "message": "Invalid JSON payload"}), 400

    # Extract fields
    user_id = data.get("user_id", "")
    waste_type = data.get("waste_type", "").lower()
    weight_kg = data.get("weight_kg")
    location = data.get("location", "")
    submitted_at_str = data.get("submitted_at", "")
    
    # Validate required fields
    if not user_id or not waste_type or weight_kg is None or not location or not submitted_at_str:
        return jsonify({"status": "error", "message": "Missing required fields"}), 400
    
    try:
        submitted_at = datetime.fromisoformat(submitted_at_str.replace("Z", "+00:00"))
    except Exception:
        return jsonify({"status": "error", "message": "Invalid date format"}), 400

    # --- AI logic ---
    status = "valid"
    confidence = 0.95
    messages = []

    # --- Weight sanity checks ---
    if weight_kg <= 0:
        status = "invalid"
        confidence = 1.0
        messages.append("Weight cannot be zero or negative.")
    elif weight_kg > 1000:
        status = "suspicious"
        confidence = 0.5
        messages.append("Weight unusually high, likely an error.")

    # Waste type-specific checks
    if waste_type in ["organic", "paper"] and weight_kg > 50:
        status = "suspicious"
        confidence = min(confidence, 0.7)
        messages.append("Weight unusually high for this waste type.")
    elif waste_type == "metal" and weight_kg < 0.1:
        status = "needs_review"
        confidence = min(confidence, 0.6)
        messages.append("Weight unusually low for metal.")

    # --- Duplicate detection (simple in-memory) ---
    duplicate_found = False
    time_threshold = timedelta(minutes=30)  # consider reports in last 30 mins as duplicates

    for prev in previous_reports:
        if (
            prev["user_id"] == user_id and
            prev["waste_type"] == waste_type and
            prev["location"] == location and
            abs((submitted_at - prev["submitted_at"]).total_seconds()) < time_threshold.total_seconds()
        ):
            duplicate_found = True
            break

    if duplicate_found:
        status = "duplicate"
        confidence = min(confidence, 0.5)
        messages.append("Duplicate report detected from this user in the last 30 minutes.")

    # Save this report for future duplicate checks
    previous_reports.append({
        "user_id": user_id,
        "waste_type": waste_type,
        "weight_kg": weight_kg,
        "location": location,
        "submitted_at": submitted_at
    })

    response = {
        "status": "ok",
        "report": {
            "status": status,
            "confidence": confidence,
            "message": " ".join(messages) if messages else "Report looks valid."
        }
    }

    return jsonify(response)
