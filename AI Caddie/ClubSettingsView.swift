//
//  ClubSettingsView.swift
//  AI Caddie
//
//  Created by GermanRamosGarcia on 23.03.2025.
//

import SwiftUI

struct ClubSettingsView: View {
    @Environment(\.presentationMode) var presentationMode

    @State private var clubDistances: [String: String] = [
        "Driver": "250",
        "3-Wood": "210",
        "5-Hybrid": "180",
        "5-Iron": "160",
        "6-Iron": "150",
        "7-Iron": "140",
        "8-Iron": "130",
        "9-Iron": "120",
        "Pitching Wedge": "110",
        "52 Degrees": "90",
        "56 Degrees": "60"
    ]

    @State private var clubOrder: [String] = [
        "Driver",
        "3-Wood",
        "5-Hybrid",
        "5-Iron",
        "6-Iron",
        "7-Iron",
        "8-Iron",
        "9-Iron",
        "Pitching Wedge",
        "52 Degrees",
        "56 Degrees"
    ]

    @State private var newClubName: String = ""
    @State private var newClubDistance: String = ""

    @AppStorage("clubData") private var savedClubData: String = ""
    @AppStorage("clubOrderData") private var savedClubOrderData: String = ""

    var body: some View {
        VStack {
            Text("Configura tu Bolsa de Palos")
                .font(.title)
                .padding()

            List {
                Section(header: Text("Palos Existentes")) {
                    ForEach(clubOrder, id: \.self) { club in
                        HStack {
                            Text(club)
                            Spacer()
                            TextField("Distancia", text: Binding(
                                get: { clubDistances[club] ?? "" },
                                set: { clubDistances[club] = $0 }
                            ))
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.numberPad)
                            .frame(width: 80)
                            Text("m")
                        }
                    }
                    .onMove(perform: moveClub)
                }

                Section(header: Text("Añadir Nuevo Palo")) {
                    TextField("Nombre del Palo", text: $newClubName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    TextField("Distancia (m)", text: $newClubDistance)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numberPad)

                    Button("Añadir Palo") {
                        addClub()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(newClubName.isEmpty || newClubDistance.isEmpty)
                }
            }
            .listStyle(InsetGroupedListStyle()) // For better section headers
            .environment(\.editMode, .constant(EditMode.active)) // Make list always editable
            .padding()

            Button("Guardar Cambios") {
                            saveClubData()
                presentationMode.wrappedValue.dismiss() // Dismiss the sheet after saving
                        }
                        .buttonStyle(.borderedProminent)
                        .padding()
                    }
                    .onAppear {
                        loadClubData()
                    }
                }

    func moveClub(from source: IndexSet, to destination: Int) {
        clubOrder.move(fromOffsets: source, toOffset: destination)
    }

    func addClub() {
        clubDistances[newClubName] = newClubDistance
        clubOrder.append(newClubName)
        newClubName = ""
        newClubDistance = ""
        saveClubData()
    }

    func saveClubData() {
        // Save club distances
        if let encodedDistances = try? JSONEncoder().encode(clubDistances) {
            savedClubData = String(data: encodedDistances, encoding: .utf8) ?? ""
        }

        // Save club order
        if let encodedOrder = try? JSONEncoder().encode(clubOrder) {
            savedClubOrderData = String(data: encodedOrder, encoding: .utf8) ?? ""
        }
    }

    func loadClubData() {
        // Load club distances
        if let data = savedClubData.data(using: .utf8),
           let decodedDistances = try? JSONDecoder().decode([String: String].self, from: data) {
            clubDistances = decodedDistances
        }

        // Load club order
        if let data = savedClubOrderData.data(using: .utf8),
           let decodedOrder = try? JSONDecoder().decode([String].self, from: data) {
            clubOrder = decodedOrder
        }
    }
}
