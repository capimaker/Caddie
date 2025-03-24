//
//  CoreLocation.swift
//  AI Caddie
//
//  Created by GermanRamosGarcia on 24.03.2025.
//

import Foundation
import CoreLocation
import SwiftUI

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private var locationManager = CLLocationManager()
    @Published var userLocation: CLLocationCoordinate2D?
    @Published var shots: [Shot] = []
    @Published var lastDistance: Double = 0.0
    @Published var suggestedClub: String = ""
    
    override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        DispatchQueue.main.async {
            self.userLocation = location.coordinate
        }
    }
    
    func registerShot() {
        guard let currentLocation = userLocation else { return }
        if let lastShot = shots.last {
            let distance = calculateDistance(from: lastShot.coordinate, to: currentLocation)
            lastDistance = distance
            suggestedClub = suggestClub(for: distance)
        }
        shots.append(Shot(coordinate: currentLocation))
    }
    
    func calculateDistance(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> Double {
        let fromLocation = CLLocation(latitude: from.latitude, longitude: from.longitude)
        let toLocation = CLLocation(latitude: to.latitude, longitude: to.longitude)
        return fromLocation.distance(from: toLocation)
    }
    
    func suggestClub(for distance: Double) -> String {
        switch distance {
        case ..<50: return "Sand Wedge"
        case ..<100: return "Pitching Wedge"
        case ..<150: return "8-Iron"
        case ..<200: return "5-Iron"
        case ..<250: return "3-Iron"
        default: return "Driver"
        }
    }
}

struct Shot: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}
