import random

class WasteClassifier:
    """
    Dummy Waste Classifier.
    Replace predict() with your real ML model later.
    """

    def __init__(self):
        self.waste_types = ["plastic", "metal", "glass", "organic", "paper"]

    def predict(self, image_path):
        # Randomly simulate detections for testing
        num_items = random.randint(0, 3)
        detections = []

        for _ in range(num_items):
            waste_type = random.choice(self.waste_types)
            weight = round(random.uniform(0.1, 2.5), 2)  # in kg
            confidence = round(random.uniform(0.5, 0.99), 2)
            detections.append({
                "waste_type": waste_type,
                "estimated_weight_kg": weight,
                "confidence": confidence
            })

        if not detections:
            return {
                "detections": [],
                "message": "No waste detected",
                "status": "ok"
            }

        return {
            "detections": detections,
            "message": "Waste detected",
            "status": "ok"
        }
