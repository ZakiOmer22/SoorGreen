from flask import Blueprint, request, jsonify

route_api = Blueprint("route_api", __name__, url_prefix="/api/ai")

def suggest_truck(total_weight_kg):
    """Suggest truck type based on total weight"""
    if total_weight_kg <= 500:
        return "Small pickup"
    elif total_weight_kg <= 2000:
        return "Medium truck"
    else:
        return "Large truck"

@route_api.route("/optimize-route", methods=["POST"])
def optimize_route():
    try:
        data = request.get_json(force=True)
    except Exception:
        return jsonify({"status": "error", "message": "Invalid JSON payload"}), 400

    # --- Input extraction ---
    zone = data.get("zone", "")
    truck_capacity = data.get("truck_capacity_kg")
    waste_points = data.get("waste_points", [])

    # --- Input validation ---
    if not zone or truck_capacity is None or not waste_points:
        return jsonify({"status": "error", "message": "Missing required fields"}), 400
    if truck_capacity <= 0:
        return jsonify({"status": "error", "message": "Truck capacity must be > 0"}), 400

    for point in waste_points:
        if "weight_kg" not in point or point["weight_kg"] <= 0:
            return jsonify({"status": "error", "message": f"Invalid weight for point {point.get('location', 'unknown')}"}), 400

    # --- Sort points by weight descending to prioritize big pickups ---
    sorted_points = sorted(waste_points, key=lambda x: x["weight_kg"], reverse=True)

    trips = []
    current_trip = []
    current_weight = 0
    total_weight = 0
    trip_number = 1

    for point in sorted_points:
        if current_weight + point["weight_kg"] > truck_capacity:
            # Save current trip and start a new one
            trips.append({
                "trip_number": trip_number,
                "stops": current_trip,
                "collected_weight": current_weight
            })
            trip_number += 1
            current_trip = [point["location"]]
            current_weight = point["weight_kg"]
        else:
            current_trip.append(point["location"])
            current_weight += point["weight_kg"]
        total_weight += point["weight_kg"]

    # Append last trip
    if current_trip:
        trips.append({
            "trip_number": trip_number,
            "stops": current_trip,
            "collected_weight": current_weight
        })

    # Build route plan: preserve waste type per stop
    route_plan = [
        {
            "stop": p["location"],
            "waste_type": p.get("waste_type", "unknown"),
            "collected_weight": p["weight_kg"]
        } for p in sorted_points
    ]

    # Suggest truck type
    truck_type = suggest_truck(total_weight)

    response = {
        "status": "ok",
        "zone": zone,
        "truck_capacity_kg": truck_capacity,
        "total_weight": total_weight,
        "trips_needed": len(trips),
        "trips": trips,
        "route_plan": route_plan,
        "suggested_truck": truck_type,
        "message": "Route optimized based on truck capacity and waste volume."
    }

    return jsonify(response)
