# api/hotspot_detection.py
from flask import Blueprint, request, jsonify
from collections import defaultdict, Counter

hotspot_api = Blueprint("hotspot_api", __name__, url_prefix="/api/ai")

@hotspot_api.route("/hotspots", methods=["POST"])
def detect_hotspots():
    try:
        data = request.get_json(force=True)
    except Exception:
        return jsonify({"status": "error", "message": "Invalid JSON payload"}), 400

    zone = data.get("zone", "")
    time_frame_days = data.get("time_frame_days", 7)
    waste_reports = data.get("waste_reports", [])

    if not zone or not waste_reports:
        return jsonify({"status": "error", "message": "Missing required fields"}), 400

    # Aggregate total weight per location
    location_totals = defaultdict(lambda: {"total_weight": 0, "waste_counts": Counter()})

    for report in waste_reports:
        loc = report.get("location", "unknown")
        weight = report.get("weight_kg", 0)
        wtype = report.get("waste_type", "unknown")

        if weight <= 0:
            continue  # ignore invalid weights

        location_totals[loc]["total_weight"] += weight
        location_totals[loc]["waste_counts"][wtype] += weight

    # Build hotspot list sorted by total_weight descending
    hotspots = []
    for loc, data_point in location_totals.items():
        dominant_waste = data_point["waste_counts"].most_common(1)[0][0] if data_point["waste_counts"] else "unknown"
        hotspots.append({
            "location": loc,
            "total_weight": data_point["total_weight"],
            "dominant_waste": dominant_waste
        })

    hotspots = sorted(hotspots, key=lambda x: x["total_weight"], reverse=True)

    response = {
        "status": "ok",
        "zone": zone,
        "hotspots": hotspots,
        "message": f"Hotspots identified over the last {time_frame_days} days based on waste volume"
    }

    return jsonify(response)
