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
    @State var jamBreak: Bool = false
    
    var body: some View {
        NavigationStack {
            Button(action: {
                jamBreak.toggle()
                
            }, label: {
                Text(jamBreak ? "Resume all" : "Break")
                    .fontWeight(.bold)
                    .frame(width: 300, height: 50)
                    .background {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(jamBreak ? .green.opacity(0.75) : .gray.opacity(0.25) )
                    }
            })
            
            VStack {
                PlayerRow(role: .jammer, jamBreak: jamBreak)
                    .padding(.vertical)
                PlayerRow(role: .pivot, jamBreak: jamBreak)
                    .padding(.vertical)
                PlayerRow(role: .blocker1, jamBreak: jamBreak)
                    .padding(.vertical)
                PlayerRow(role: .blocker2, jamBreak: jamBreak)
                    .padding(.vertical)
                PlayerRow(role: .blocker3, jamBreak: jamBreak)
                    .padding(.vertical)
            }
            
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
                    .presentationDetents([.height(450)])
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
                HStack(alignment: .firstTextBaseline) {
                    Image(systemName: "arrow.forward")
                    Text("Tap Break to halt all timers, i.e. after a jam ended.")
                        .fixedSize(horizontal: false, vertical: true)
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
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}


