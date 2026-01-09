# waste_classifier.py
import cv2
import numpy as np
from tensorflow import keras
from PIL import Image
import io
import json
from sqlalchemy import create_engine
import pyodbc

class WasteClassifier:
    def __init__(self, model_path='models/waste_classifier.h5'):
        self.model = keras.models.load_model(model_path)
        self.classes = ['Plastic', 'Paper', 'Glass', 'Metal', 'Organic', 'Electronic', 'Hazardous']
        
    def predict_from_image(self, image_bytes):
        # Process image
        image = Image.open(io.BytesIO(image_bytes))
        image = image.resize((224, 224))
        img_array = np.array(image) / 255.0
        img_array = np.expand_dims(img_array, axis=0)
        
        # Make prediction
        predictions = self.model.predict(img_array)
        predicted_class = self.classes[np.argmax(predictions[0])]
        confidence = float(np.max(predictions[0]))
        
        return {
            'predicted_class': predicted_class,
            'confidence': confidence,
            'all_predictions': dict(zip(self.classes, predictions[0].tolist()))
        }

class DatabaseConnector:
    def __init__(self, connection_string):
        self.engine = create_engine(connection_string)
    
    def save_prediction(self, report_id, prediction_data):
        query = """
        INSERT INTO AI_Predictions (ReportId, ModelId, PredictedWasteType, 
        Confidence, BoundingBoxes, PredictionTimestamp)
        VALUES (?, ?, ?, ?, ?, GETDATE())
        """
        # Execute query...