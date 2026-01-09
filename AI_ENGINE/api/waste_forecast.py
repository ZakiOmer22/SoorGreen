# api/waste_forecast.py
from flask import Blueprint, request, jsonify
from datetime import datetime, timedelta
from collections import defaultdict

forecast_api = Blueprint("forecast_api", __name__, url_prefix="/api/ai")

@forecast_api.route("/forecast-waste", methods=["POST"])
def forecast_waste():
    try:
        data = request.get_json(force=True)
    except Exception:
        return jsonify({"status": "error", "message": "Invalid JSON payload"}), 400

    zone = data.get("zone", "")
    historical_data = data.get("historical_data", [])
    predict_days = data.get("predict_days", 3)

    if not zone or not historical_data:
        return jsonify({"status": "error", "message": "Missing required fields"}), 400

    # --- Aggregate historical data per waste type ---
    waste_totals = defaultdict(list)
    for entry in historical_data:
        try:
            waste_type = entry["waste_type"].lower()
            weight = float(entry["weight_kg"])
            waste_totals[waste_type].append(weight)
        except KeyError:
            return jsonify({"status": "error", "message": f"Invalid entry {entry}"}), 400

    # --- Compute simple average per waste type ---
    averages = {}
    for wtype, weights in waste_totals.items():
        averages[wtype] = sum(weights) / len(weights) if weights else 0

    # --- Generate future predictions ---
    last_date_str = max(entry["date"] for entry in historical_data)
    last_date = datetime.strptime(last_date_str, "%Y-%m-%d")
    predictions = []

    for i in range(1, predict_days + 1):
        future_date = last_date + timedelta(days=i)
        pred_entry = {"date": future_date.strftime("%Y-%m-%d")}
        for wtype in ["metal", "organic", "paper"]:
            pred_entry[f"{wtype}_kg"] = round(averages.get(wtype, 0), 2)
        predictions.append(pred_entry)

    response = {
        "status": "ok",
        "zone": zone,
        "predictions": predictions,
        "message": f"Predicted waste generation for the next {predict_days} days"
    }

    return jsonify(response)
