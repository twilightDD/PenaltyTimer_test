//
//  ContentView.swift
//  PenaltyTimer_test
//
//  Created by Peter Hauke on 17.06.25.
//

import SwiftUI
import Combine
import CoreHaptics
import SwiftData
import AVFoundation

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]

    private let playerRows = [
        PlayerRow(role: .jammer),
        PlayerRow(role: .pivot),
        PlayerRow(role: .blocker1),
        PlayerRow(role: .blocker2),
        PlayerRow(role: .blocker3),
    ]
    
    var body: some View {
        NavigationStack {
            ForEach(playerRows, id: \.id) { playerRow in
                playerRow
                    .padding()
            }
            .navigationTitle("Penalty Timer")
        }
    }

}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}


