import os
from ultralytics import YOLO

class WasteClassifier:
    def __init__(self):
        model_path = "models/waste_yolo.pt"

        if not os.path.exists(model_path):
            raise FileNotFoundError(f"Model not found at {model_path}")

        self.model = YOLO(model_path)
        print("✅ Waste classification model loaded")

    def predict(self, image_path: str):
        """
        Runs AI inference on the uploaded image
        """

        if not os.path.exists(image_path):
            return {
                "status": "error",
                "message": "Image file not found"
            }

        # YOLO inference
        results = self.model(image_path)

        predictions = []

        for r in results:
            if r.boxes is None:
                continue

            for box in r.boxes:
                predictions.append({
                    "label": self.model.names[int(box.cls)],
                    "confidence": float(box.conf)
                })

        # No detections fallback
        if not predictions:
            return {
                "status": "ok",
                "detections": [],
                "message": "No waste detected"
            }

        return {
            "status": "ok",
            "detections": predictions
        }


# Singleton instance (IMPORTANT)
classifier = WasteClassifier()
