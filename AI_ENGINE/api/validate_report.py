# api/validate_report.py
from flask import Blueprint, request, jsonify
from datetime import datetime
import hashlib

validate_api = Blueprint('validate_api', __name__)

# Simple in-memory store to simulate deduplication
reported_hashes = set()

def calculate_confidence(report):
    """
    Assigns confidence based on plausibility of weights and completeness.
    Returns a value between 0 and 1.
    """
    confidence = 1.0
    if not report.get('waste_type') or not report.get('weight_kg') or not report.get('location'):
        confidence -= 0.4  # missing critical data
    if report.get('weight_kg', 0) <= 0 or report.get('weight_kg', 0) > 100:  # unrealistic weight
        confidence -= 0.3
    return max(0.0, confidence)

def humanize_report(report, confidence):
    """
    Converts raw report into human-readable validated report.
    """
    return {
        "waste_type": report.get('waste_type', 'unknown'),
        "weight_kg": report.get('weight_kg', 0),
        "location": report.get('location', 'unknown'),
        "submitted_at": report.get('submitted_at', datetime.utcnow().isoformat()),
        "confidence_score": round(confidence, 2),
        "status": "valid" if confidence >= 0.5 else "suspicious"
    }

@validate_api.route('/api/ai/validate-report', methods=['POST'])
def validate_report():
    data = request.get_json()
    if not data:
        return jsonify({"status": "error", "message": "No JSON payload provided"}), 400

    # Deduplication by hash (location + waste_type + weight)
    report_str = f"{data.get('location')}-{data.get('waste_type')}-{data.get('weight_kg')}"
    report_hash = hashlib.md5(report_str.encode()).hexdigest()
    if report_hash in reported_hashes:
        return jsonify({"status": "ok", "message": "Duplicate report detected", "report": None}), 200
    reported_hashes.add(report_hash)

    # Assign confidence
    confidence = calculate_confidence(data)
    
    # Humanized validated report
    validated_report = humanize_report(data, confidence)

    return jsonify({
        "status": "ok",
        "message": "Report validated",
        "report": validated_report
    })
