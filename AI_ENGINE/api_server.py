# api_server.py
from fastapi import FastAPI, File, UploadFile, HTTPException
from pydantic import BaseModel
import uvicorn
import json
from waste_classifier import WasteClassifier
from route_optimizer import RouteOptimizer

app = FastAPI(title="SoorGreen AI API", version="1.0.0")

classifier = WasteClassifier()
optimizer = RouteOptimizer()

@app.post("/api/ai/classify-waste")
async def classify_waste(file: UploadFile = File(...)):
    """Classify waste from image"""
    try:
        image_bytes = await file.read()
        result = classifier.predict_from_image(image_bytes)
        
        # Log to database
        # db.save_prediction(...)
        
        return {
            "success": True,
            "prediction": result,
            "suggested_credit": self.calculate_credit(result['predicted_class'])
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/api/ai/optimize-routes")
async def optimize_routes(pickups: list):
    """Optimize collection routes"""
    locations = [(p['lat'], p['lng']) for p in pickups]
    demands = [p['weight'] for p in pickups]
    
    distance_matrix = optimizer.create_distance_matrix(locations)
    routes = optimizer.solve_with_ortools(
        distance_matrix, 
        demands, 
        vehicle_capacities=[500, 500], 
        num_vehicles=2
    )
    
    return {
        "optimized_routes": routes,
        "total_distance": sum(r['distance'] for r in routes),
        "vehicle_utilization": self.calculate_utilization(routes, demands)
    }

@app.get("/api/ai/predict-volume")
async def predict_waste_volume(municipality_id: str, date: str):
    """Predict waste volume for planning"""
    # Use time series forecasting (Prophet/ARIMA)
    # Query historical data
    # Return predictions
    
    return {
        "predicted_volume": 1250.5,
        "confidence_interval": [1100, 1400],
        "suggested_vehicles": 3
    }

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)