//
//  ContentView.swift
//  AI Caddie
//
//  Created by GermanRamosGarcia on 23.03.2025.
//

import SwiftUI
import MapKit

struct ContentView: View {
    var selectedCourse: GolfCourse
    var selectedTee: String
    @State private var currentHoleIndex = 0
    @State private var shots: [CGPoint] = []
    @State private var showCourseSelection = false
    @State private var showClubSettings = false // New state to show "Mi Bolsa"
    
    var body: some View {
        VStack {
            let holes = selectedCourse.holes
            var currentHole = holes[currentHoleIndex]
            let holeLocation = currentHole.holeLocation
            let startingPosition = currentHole.teePositions[selectedTee] ?? holeLocation
            
            // If first shot, set tee position as first shot
            if currentHole.shots.isEmpty {
                currentHole.shots.append(startingPosition)
            }
            
            
            Text("\(selectedCourse.name)")
                .font(.title)
                .bold()
                .padding()
            
            Text("Hoyo \(currentHole.number)")
                .font(.largeTitle)
                .bold()
            
            Text("Par: \(currentHole.par)")
                .font(.title2)
                .padding(.bottom, 5)
            
            Text("Distancia: \(currentHole.distance) metros")
                .font(.title3)
                .foregroundColor(.gray)
            
            // 📍 Hole Image (Tap to Register Shot)
            ZStack {
                GeometryReader { geo in
                    Image("hole\(currentHole.number)")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 300)
                        .overlay(
                            ForEach(shots.indices, id: \.self) { index in
                                let shot = shots[index]
                                Circle()
                                    .fill(index == 0 ? Color.red : Color.blue)
                                    .frame(width: 10, height: 10)
                                    .position(x: shot.x * geo.size.width, y: shot.y * geo.size.height)
                            }
                        )
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onEnded { value in
                                    let tapLocation = value.location
                                    let relativeLocation = CGPoint(
                                        x: tapLocation.x / geo.size.width,
                                        y: tapLocation.y / geo.size.height
                                    )
                                   // registerShot(at: relativeLocation, in: currentHole, holeLocation: holeLocation)
                                }
                        )
                }
            }
            
            // 🎯 Shot Distance and Club Recommendation
            if currentHole.shots.count > 1 {
                let lastShot = currentHole.shots.last!
                let distanceToHole = calculateDistance(from: lastShot, to: holeLocation, hole: currentHole)
                let club = suggestClub(for: distanceToHole)
                
                Text("Distancia al hoyo: \(String(format: "%.2f", distanceToHole)) metros")
                    .font(.headline)
                    .foregroundColor(.blue)
                
                Text("Palo recomendado: \(club)")
                    .font(.subheadline)
                    .foregroundColor(.green)
            }
            
            // ⬅️ Previous & Next Hole Buttons
            HStack {
                Button(action: {
                    if currentHoleIndex > 0 {
                        currentHoleIndex -= 1
                    }
                }) {
                    Image(systemName: "arrow.left.circle.fill")
                        .font(.largeTitle)
                        .foregroundColor(currentHoleIndex > 0 ? .blue : .gray)
                }
                .disabled(currentHoleIndex == 0)
                .padding()
                
                Spacer()
                
                Button(action: {
                    if currentHoleIndex < holes.count - 1 {
                        currentHoleIndex += 1
                    }
                }) {
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.largeTitle)
                        .foregroundColor(currentHoleIndex < holes.count - 1 ? .blue : .gray)
                }
                .disabled(currentHoleIndex == holes.count - 1)
                .padding()
            }
            
            // 🔙 Buttons for Course Selection & "Mi Bolsa"
            HStack {
                Button("Seleccion de Campo") {
                    showCourseSelection = true
                }
                .buttonStyle(.bordered)
                .padding()
                .fullScreenCover(isPresented: $showCourseSelection) {
                    CourseSelectionView()
                }
                
                Spacer()
                
                Button("Mi Bolsa") {
                    showClubSettings = true
                }
                .buttonStyle(.bordered)
                .padding()
                .fullScreenCover(isPresented: $showClubSettings) {
                    ClubSettingsView()
                }
            }
        }
    }
    
    
    // 📍 Register Shot on Hole Image
    func registerShot(at location: CGPoint) {
        shots.append(location) // Add new shot
    }
    
    // 📏 Calculate Distance Between Two Shots
    func calculateDistance(from: CGPoint, to: CGPoint, hole: Hole) -> Double {
        let imageWidth: Double = 300 // Assume the hole image width in meters
        let dx = (to.x - from.x) * imageWidth
        let dy = (to.y - from.y) * imageWidth
        return sqrt(dx * dx + dy * dy)
    }
    
    // 🏌️ Suggest a Club Based on Distance
    func suggestClub(for distance: Double) -> String {
        // Load saved club distances from AppStorage
        guard let clubData = UserDefaults.standard.string(forKey: "clubData"),
              let decodedData = clubData.data(using: .utf8),
              let clubDistances = try? JSONDecoder().decode([String: String].self, from: decodedData) else {
            return "Club data not available"
        }
        
        // Convert user-defined distances to a sorted array
        let sortedClubs = clubDistances.compactMap { key, value -> (String, Double)? in
            if let dist = Double(value) {
                return (key, dist)
            }
            return nil
        }
            .sorted { $0.1 > $1.1 } // Sort clubs from longest to shortest distance
        
        // Find the best club for the given distance
        for (club, clubDistance) in sortedClubs {
            if distance >= clubDistance {
                return club
            }
        }
        
        return sortedClubs.last?.0 ?? "Driver" // Default to longest club if nothing matches
    }
}
