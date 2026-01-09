# api/main.py
from fastapi import FastAPI, File, UploadFile, HTTPException, Depends
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
import uvicorn
from typing import List
import json
from datetime import datetime

from config.config import config
from services.database import db
from services.waste_classifier import classifier
from services.route_optimizer import RouteOptimizer, PickupLocation
from pydantic import BaseModel

# Pydantic models
class WasteClassificationRequest(BaseModel):
    image_base64: str = None

class RouteOptimizationRequest(BaseModel):
    pickups: List[dict]
    vehicle_capacities: List[float] = [500.0]
    num_vehicles: int = 1
    time_limit_minutes: int = 480

class PredictionResult(BaseModel):
    predicted_class: str
    confidence: float
    all_predictions: dict
    suggested_credits: float = None
    model_type: str

class OptimizationResult(BaseModel):
    routes: List[dict]
    total_distance_km: float
    total_weight_kg: float
    estimated_time_min: float
    savings: dict = None

# Initialize FastAPI app
app = FastAPI(
    title="SoorGreen AI Engine API",
    description="AI Services for SoorGreen Waste Management System",
    version="1.0.0"
)

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, specify exact origins
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Initialize services
route_optimizer = RouteOptimizer()

# Health check endpoint
@app.get("/")
async def root():
    return {
        "message": "SoorGreen AI Engine API",
        "version": "1.0.0",
        "status": "online",
        "timestamp": datetime.now().isoformat()
    }

@app.get("/health")
async def health_check():
    """Health check endpoint"""
    db_status = "connected" if db.connect() else "disconnected"
    
    return {
        "status": "healthy",
        "database": db_status,
        "timestamp": datetime.now().isoformat()
    }

# Waste classification endpoint
@app.post("/api/ai/classify-waste", response_model=PredictionResult)
async def classify_waste(file: UploadFile = File(...), weight_kg: float = 1.0):
    """
    Classify waste type from uploaded image
    """
    try:
        # Check file type
        if not file.filename.lower().endswith(('.png', '.jpg', '.jpeg', '.gif')):
            raise HTTPException(status_code=400, detail="Invalid file type")
        
        # Read image
        image_bytes = await file.read()
        
        if len(image_bytes) == 0:
            raise HTTPException(status_code=400, detail="Empty file")
        
        # Classify waste
        result = classifier.classify(image_bytes)
        
        # Calculate suggested credits
        suggested_credits = classifier.calculate_credits(
            result['predicted_class'], 
            weight_kg
        )
        
        return PredictionResult(
            predicted_class=result['predicted_class'],
            confidence=result['confidence'],
            all_predictions=result.get('all_predictions', {}),
            suggested_credits=suggested_credits,
            model_type=result.get('model_type', 'unknown')
        )
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# Route optimization endpoint
@app.post("/api/ai/optimize-routes", response_model=OptimizationResult)
async def optimize_routes(request: RouteOptimizationRequest):
    """
    Optimize waste collection routes
    """
    try:
        # Convert pickups to PickupLocation objects
        pickup_locations = []
        for pickup in request.pickups:
            pickup_locations.append(PickupLocation(
                id=pickup.get('id', str(hash(str(pickup)))),
                lat=pickup['lat'],
                lng=pickup['lng'],
                weight=pickup.get('weight', 1.0),
                address=pickup.get('address', 'Unknown'),
                priority=pickup.get('priority', 1)
            ))
        
        # Optimize routes
        optimized_routes = route_optimizer.optimize_routes(
            pickups=pickup_locations,
            vehicle_capacities=request.vehicle_capacities,
            num_vehicles=request.num_vehicles,
            time_limit_seconds=request.time_limit_minutes * 60
        )
        
        # Calculate total metrics
        total_distance = sum(route.distance_km for route in optimized_routes)
        total_weight = sum(route.total_weight for route in optimized_routes)
        total_time = sum(route.estimated_time_min for route in optimized_routes)
        
        # Calculate baseline for comparison (naive approach)
        baseline_optimizer = RouteOptimizer()
        baseline_routes = baseline_optimizer._get_fallback_routes(
            pickup_locations, request.num_vehicles
        )
        baseline_distance = sum(route.distance_km for route in baseline_routes)
        
        # Calculate savings
        savings = route_optimizer.calculate_savings(
            baseline_distance, total_distance
        )
        
        # Convert routes to dict
        routes_dict = []
        for route in optimized_routes:
            routes_dict.append({
                'vehicle_id': route.vehicle_id,
                'route': route.route,
                'distance_km': round(route.distance_km, 2),
                'total_weight_kg': round(route.total_weight, 2),
                'estimated_time_min': round(route.estimated_time_min, 2),
                'waypoints': route.waypoints
            })
        
        return OptimizationResult(
            routes=routes_dict,
            total_distance_km=round(total_distance, 2),
            total_weight_kg=round(total_weight, 2),
            estimated_time_min=round(total_time, 2),
            savings=savings
        )
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# Database integration endpoints
@app.get("/api/ai/pending-pickups")
async def get_pending_pickups(municipality_id: str = None):
    """Get pending pickups for a municipality"""
    try:
        pickups = db.get_pending_pickups(municipality_id)
        return {
            "count": len(pickups) if pickups else 0,
            "pickups": pickups or []
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/api/ai/save-prediction")
async def save_prediction(report_id: str, prediction_data: dict):
    """Save AI prediction to database"""
    try:
        result = db.save_prediction(report_id, prediction_data)
        return {
            "success": result is not None,
            "message": "Prediction saved successfully" if result else "Failed to save prediction"
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# Run the application
if __name__ == "__main__":
    uvicorn.run(
        "main:app",
        host=config.AI_API_HOST,
        port=config.AI_API_PORT,
        reload=config.AI_DEBUG
    )