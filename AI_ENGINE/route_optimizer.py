# route_optimizer.py
import numpy as np
import json
from geopy.distance import geodesic
from ortools.constraint_solver import routing_enums_pb2
from ortools.constraint_solver import pywrapcp

class RouteOptimizer:
    def __init__(self, depot_location=(0, 0)):
        self.depot = depot_location
        
    def create_distance_matrix(self, locations):
        """Create distance matrix from locations"""
        n = len(locations)
        matrix = np.zeros((n, n))
        for i in range(n):
            for j in range(n):
                if i != j:
                    matrix[i][j] = geodesic(locations[i], locations[j]).km
        return matrix
    
    def solve_with_ortools(self, distance_matrix, demands, vehicle_capacities, num_vehicles):
        """Solve CVRP using OR-Tools"""
        manager = pywrapcp.RoutingIndexManager(
            len(distance_matrix), num_vehicles, 0
        )
        routing = pywrapcp.RoutingModel(manager)
        
        def distance_callback(from_index, to_index):
            from_node = manager.IndexToNode(from_index)
            to_node = manager.IndexToNode(to_index)
            return distance_matrix[from_node][to_node]
        
        transit_callback_index = routing.RegisterTransitCallback(distance_callback)
        routing.SetArcCostEvaluatorOfAllVehicles(transit_callback_index)
        
        # Add capacity constraint
        def demand_callback(from_index):
            from_node = manager.IndexToNode(from_index)
            return demands[from_node]
        
        demand_callback_index = routing.RegisterUnaryTransitCallback(demand_callback)
        routing.AddDimensionWithVehicleCapacity(
            demand_callback_index,
            0,  # null capacity slack
            vehicle_capacities,  # vehicle maximum capacities
            True,  # start cumul to zero
            'Capacity'
        )
        
        # Solve
        search_parameters = pywrapcp.DefaultRoutingSearchParameters()
        search_parameters.first_solution_strategy = (
            routing_enums_pb2.FirstSolutionStrategy.PATH_CHEAPEST_ARC
        )
        solution = routing.SolveWithParameters(search_parameters)
        
        return self.extract_routes(manager, routing, solution)