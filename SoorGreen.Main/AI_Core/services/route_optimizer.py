# services/route_optimizer.py
import math
import random
from typing import List, Dict

class RouteOptimizer:
    def __init__(self, depot_location: tuple = None):
        self.depot = depot_location or (0, 0)
        self.avg_speed_kmh = 30
        self.service_time_min = 10
    
    def calculate_distance(self, lat1, lng1, lat2, lng2):
        """Calculate approximate distance using Haversine formula"""
        from math import radians, sin, cos, sqrt, atan2
        
        # Convert to radians
        lat1, lng1, lat2, lng2 = map(radians, [lat1, lng1, lat2, lng2])
        
        # Haversine formula
        dlat = lat2 - lat1
        dlng = lng2 - lng1
        a = sin(dlat/2)**2 + cos(lat1) * cos(lat2) * sin(dlng/2)**2
        c = 2 * atan2(sqrt(a), sqrt(1-a))
        
        # Earth radius in km
        radius = 6371
        return radius * c
    
    def optimize_routes(self, pickups: List[Dict], 
                       vehicle_capacities: List[float] = [500.0],
                       num_vehicles: int = 1):
        """Optimize routes (mock implementation)"""
        
        if not pickups:
            return []
        
        routes = []
        pickups_per_vehicle = math.ceil(len(pickups) / num_vehicles)
        
        for i in range(num_vehicles):
            start_idx = i * pickups_per_vehicle
            end_idx = min(start_idx + pickups_per_vehicle, len(pickups))
            
            if start_idx >= len(pickups):
                break
            
            vehicle_pickups = pickups[start_idx:end_idx]
            
            # Calculate total distance
            total_distance = 0
            prev_lat, prev_lng = self.depot
            
            for pickup in vehicle_pickups:
                distance = self.calculate_distance(
                    prev_lat, prev_lng, 
                    pickup['lat'], pickup['lng']
                )
                total_distance += distance
                prev_lat, prev_lng = pickup['lat'], pickup['lng']
            
            # Return to depot
            total_distance += self.calculate_distance(
                prev_lat, prev_lng, 
                self.depot[0], self.depot[1]
            )
            
            # Calculate total weight
            total_weight = sum(p.get('weight', 1.0) for p in vehicle_pickups)
            
            # Calculate estimated time
            travel_time = (total_distance / self.avg_speed_kmh) * 60
            service_time = len(vehicle_pickups) * self.service_time_min
            estimated_time = travel_time + service_time
            
            # Create route
            route = {
                'vehicle_id': i,
                'route': [p['id'] for p in vehicle_pickups],
                'distance_km': round(total_distance, 2),
                'total_weight_kg': round(total_weight, 2),
                'estimated_time_min': round(estimated_time, 2),
                'waypoints': vehicle_pickups
            }
            
            routes.append(route)
        
        return routes
    
    def calculate_savings(self, original_distance, optimized_distance):
        """Calculate savings"""
        distance_saved = max(0, original_distance - optimized_distance)
        fuel_saved = distance_saved * 0.12  # 12L per 100km
        fuel_cost_saved = fuel_saved * 1.5  # $1.5 per liter
        time_saved = distance_saved / self.avg_speed_kmh
        time_cost_saved = time_saved * 20  # $20 per hour
        
        return {
            'distance_saved_km': round(distance_saved, 2),
            'fuel_saved_liters': round(fuel_saved, 2),
            'fuel_cost_saved': round(fuel_cost_saved, 2),
            'time_saved_hours': round(time_saved, 2),
            'time_cost_saved': round(time_cost_saved, 2),
            'total_savings': round(fuel_cost_saved + time_cost_saved, 2)
        }

# Global optimizer instance
route_optimizer = RouteOptimizer()