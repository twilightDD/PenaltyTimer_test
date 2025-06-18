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
    
    @State var showHelpSheet: Bool = false
    
    var body: some View {
        NavigationStack {
            PlayerRow(role: .jammer)
                .padding()
            PlayerRow(role: .pivot)
                .padding()
            PlayerRow(role: .blocker1)
                .padding()
            PlayerRow(role: .blocker2)
                .padding()
            PlayerRow(role: .blocker3)
                .padding()
            
                .navigationTitle("Penalty Timer")
                .toolbar {
                    Button(action: {
                        showHelpSheet.toggle()
                    }) {
                        Image(systemName: "questionmark.circle")
                    }
                }
                .sheet(isPresented: $showHelpSheet) {
                    HelpView()
                        .presentationBackground(.thinMaterial)
                        .presentationDetents([.medium])
                }
        }
    }

}

struct HelpView: View {
    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                Text("Instructions")
                    .font(.headline)
                    .fontWeight(.heavy)
                    .padding(.vertical)
                
                HStack {
                    Image(systemName: "arrow.forward")
                    Text("Tap on row to start a timer.")
                }
                .padding(.leading, 8)
                HStack {
                    Image(systemName: "arrow.forward")
                    Text("Double tap on row to stop a timer.")
                }
                .padding(.leading, 8)
            }
            .padding()
            
            Rectangle().frame(height: 1)
                .padding(.horizontal)
            
            VStack(alignment: .leading) {
                Text("Imprint")
                    .font(.headline)
                    .fontWeight(.heavy)
                    .padding(.vertical)
                
                Text("""
                    Peter Hauke / 2sox
                    Friedensstr. 16
                    01097 Dresden
                    peter@2sox.de
                    """)
                .padding(.leading, 8)
            }
            .padding()
        }
        .padding(.vertical, 30)
        .frame(width: .infinity, height: .infinity, alignment: .leading)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}


