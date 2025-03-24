//
//  GolfCourse.swift
//  AI Caddie
//
//  Created by GermanRamosGarcia on 24.03.2025.
//

import SwiftUI
import MapKit
import Foundation
import CoreGraphics

struct GolfCourse: Identifiable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
    let holes: [Hole] // Each course has a list of holes
}

struct Hole: Identifiable {
    let id = UUID()
    let number: Int
    let par: Int
    let distance: Int // Distance in meters
    let holeLocation: CGPoint // Where the hole is on the image
    //var teePositions: [String: CGPoint] // Different tee locations
    var shots: [CGPoint] = [] // Stores shot locations on the hole image
}

struct CourseSelectionView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var golfCourses: [GolfCourse] = [
        GolfCourse(
            name: "Pebble Beach",
            coordinate: CLLocationCoordinate2D(latitude: 36.5678, longitude: -121.9500),
            holes: [
                Hole(
                    number: 1,
                    par: 4,
                    distance: 350,
                    holeLocation: CGPoint(x: 0.9, y: 0.2) // Flag position on the hole image
                   /* teePositions: [
                        "White": CGPoint(x: 0.1, y: 0.8),
                        "Blue": CGPoint(x: 0.15, y: 0.75),
                        "Red": CGPoint(x: 0.2, y: 0.7)
                    ]*/
                ),
                
                Hole(
                    number: 2,
                    par: 5,
                    distance: 480,
                    holeLocation: CGPoint(x: 0.85, y: 0.15)
                   /* teePositions: [
                        "White": CGPoint(x: 0.05, y: 0.85),
                        "Blue": CGPoint(x: 0.1, y: 0.8),
                        "Red": CGPoint(x: 0.15, y: 0.75)
                    ]*/
                ),
                
                Hole(
                    number: 3,
                    par: 3,
                    distance: 150,
                    holeLocation: CGPoint(x: 0.92, y: 0.18)
                    /*teePositions: [
                        "White": CGPoint(x: 0.2, y: 0.9),
                        "Blue": CGPoint(x: 0.25, y: 0.85),
                        "Red": CGPoint(x: 0.3, y: 0.8)
                    ]*/
                ),
                
                // Add remaining 15 holes...
            ]
        ),
        
        GolfCourse(
            name: "Augusta National",
            coordinate: CLLocationCoordinate2D(latitude: 33.5020, longitude: -82.0220),
            holes: [
                Hole(
                    number: 1,
                    par: 4,
                    distance: 350,
                    holeLocation: CGPoint(x: 0.9, y: 0.2) // Flag position on the hole image
                    /*teePositions: [
                        "White": CGPoint(x: 0.1, y: 0.8),
                        "Blue": CGPoint(x: 0.15, y: 0.75),
                        "Red": CGPoint(x: 0.2, y: 0.7)
                    ]*/
                ),
                
                Hole(
                    number: 2,
                    par: 5,
                    distance: 480,
                    holeLocation: CGPoint(x: 0.85, y: 0.15)
                    /*teePositions: [
                        "White": CGPoint(x: 0.05, y: 0.85),
                        "Blue": CGPoint(x: 0.1, y: 0.8),
                        "Red": CGPoint(x: 0.15, y: 0.75)
                    ]*/
                ),
                
                Hole(
                    number: 3,
                    par: 3,
                    distance: 150,
                    holeLocation: CGPoint(x: 0.92, y: 0.18)
                    /*teePositions: [
                        "White": CGPoint(x: 0.2, y: 0.9),
                        "Blue": CGPoint(x: 0.25, y: 0.85),
                        "Red": CGPoint(x: 0.3, y: 0.8)
                    ]*/
                ),
                
                // Add remaining 15 holes...
            ]
            ),
        ]
    
        
    @State private var userLocation: CLLocationCoordinate2D? = nil
    @State private var selectedCourse: GolfCourse? = nil
    @State private var navigateToMap = false

    var body: some View {
        NavigationView {
            VStack {
                Text("Selecciona un Campo de Golf")
                    .font(.largeTitle)
                    .padding()
                
                List(sortedCourses()) { course in
                    Button(action: {
                        selectedCourse = course
                        navigateToMap = true
                    }) {
                        HStack {
                            Text(course.name)
                                .font(.headline)
                            Spacer()
                            if let userLocation = userLocation {
                                let distance = calculateDistance(from: userLocation, to: course.coordinate)
                                Text("\(String(format: "%.1f", distance)) km")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
                
                NavigationLink(
                    destination: selectedCourse.map { ContentView(selectedCourse: $0) },
                    isActive: $navigateToMap
                ) {
                    EmptyView()
                }
                .hidden()
            }
            .onAppear {
                if let location = locationManager.userLocation {
                    userLocation = location
                }
            }
        }
    }

    func sortedCourses() -> [GolfCourse] {
        guard let userLocation = userLocation else { return golfCourses }
        return golfCourses.sorted {
            calculateDistance(from: userLocation, to: $0.coordinate) < calculateDistance(from: userLocation, to: $1.coordinate)
        }
    }

    func calculateDistance(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> Double {
        let fromLocation = CLLocation(latitude: from.latitude, longitude: from.longitude)
        let toLocation = CLLocation(latitude: to.latitude, longitude: to.longitude)
        return fromLocation.distance(from: toLocation) / 1000.0
    }
}

@main
struct AI_CaddieApp: App {
    var body: some Scene {
        WindowGroup {
            CourseSelectionView() // Start with the course selection page
        }
    }
}
