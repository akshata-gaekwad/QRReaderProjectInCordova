//
//  NavigationService.swift
//  ARKitDemoApp
//
//  Created by Christopher Webb-Orenstein on 8/27/17.
//  Copyright © 2017 Christopher Webb-Orenstein. All rights reserved.
//

import MapKit
import CoreLocation
//import SVProgressHUD

struct NavigationService {
    
    func getDirections(destinationLocation: CLLocationCoordinate2D, request: MKDirections.Request, completion: @escaping ([MKRoute.Step] , _ error:NSError?) -> Void) {
        var steps: [MKRoute.Step] = []
        
        if #available(iOS 10.0, *) {
        let placeMark = MKPlacemark(coordinate: destinationLocation)

        request.destination = MKMapItem.init(placemark: placeMark)
        request.source = MKMapItem.forCurrentLocation()
        request.requestsAlternateRoutes = false
        request.transportType = .any
        } else {
            // Fallback on earlier versions
        }
        let directions = MKDirections(request: request)
        
        directions.calculate { response, error in
            if error != nil {
                print("Error getting directions")
                completion([] , error as NSError?)
            } else {
                guard let response = response else { return }
                for route in response.routes {
                    steps.append(contentsOf: route.steps)
                }
                completion(steps , error as NSError?)
            }
        }
        
    }
    
    func getDirectionsForMap(destinationLocation: CLLocationCoordinate2D, request: MKDirections.Request, completion: @escaping (MKDirections.Response , _ error:NSError?) -> Void) {
        
        if #available(iOS 10.0, *) {
            let placeMark = MKPlacemark(coordinate: destinationLocation)
        request.destination = MKMapItem.init(placemark: placeMark)
        request.source = MKMapItem.forCurrentLocation()
        request.requestsAlternateRoutes = false
        request.transportType = .automobile
        } else {
            // Fallback on earlier versions
        }
        let directions = MKDirections(request: request)
        
        directions.calculate { response, error in
            print(error?.localizedDescription ?? "")
            if error != nil {
                print("Error getting directions")
                completion(response! , error as NSError?)
            } else {
                guard let response = response else { return }
                completion(response , error as NSError?)
            }
        }
    }
}
