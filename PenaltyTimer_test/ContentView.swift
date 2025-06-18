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
            //.frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle("Penalty Timer")
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(timestamp: Date())
            modelContext.insert(newItem)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}


struct PlayerRow: View, Identifiable {
    private let startDuration: TimeInterval = 0
    private let feedbackDuration: TimeInterval = 0.6
    private let standDuration: TimeInterval = 20
    private let goDuration: TimeInterval = 30
    
    let id = UUID()
    
    let role: PlayerRole
    @State var isRunning: Bool = false
    @State private var didPlayFeedback: Bool = false
    @State private var didPlayFeedback2: Bool = false
    
    @State var time: TimeInterval = 0
    var backgroundColor: Color {
        switch time {
            case startDuration: return .white
            case startDuration..<standDuration: return .red
            case standDuration..<goDuration: return .yellow
            default:
                return .green
        }
    }
    @State var startTime: Date = Date()
    
    // Declare an idle timer
    @State private var timer = Timer.publish(every: 0.1, tolerance: 0.01,
                                             on: .main, in: .default)
    
    // A handler to help cancel a timer later
    @State private var timerHandler: Cancellable?
    // A flag to stop timer from repeating itself
    @State private var repeatTimer: Bool = false
    
    @State var hapticEngine: CHHapticEngine?
    
    var body: some View {
        HStack {
            Text("\(role.title)")
                .frame(width: 40)
            
            Spacer()
            
            Text("\(time, specifier: "%.1f")")
                .frame(alignment: .trailing)
            
            Spacer()
            
            Button(time == 0 ? "Start" : "Stop ") {
                time == 0 ? start() : stop()
            }
        }
        
        .onReceive(timer) { timer in
            time = timer.timeIntervalSince(startTime)
            if time >= standDuration - 0.4 && didPlayFeedback == false {
                playCustomHaptic()

                let systemSoundID: SystemSoundID = 1070
                AudioServicesPlaySystemSound(systemSoundID)

                didPlayFeedback = true
            }
            if time >= goDuration - 0.4 && didPlayFeedback2 == false {
                //playCustomHaptic()
                
                let systemSoundID: SystemSoundID = 1013
                AudioServicesPlaySystemSound(systemSoundID)
                
                didPlayFeedback2 = true
            }
            
        }
        .padding()
        .background(backgroundColor)
        .font(Font.system(size: 32, weight: .bold))
        .fontDesign(.monospaced)
        .onAppear {
            prepareHapticEngine()
        }
        
    }
    
    func start() {
        startTime = Date()
        timerHandler?.cancel()
        timer = Timer.publish(every: 0.1,tolerance: 0.01,
                              on: .main, in: .default)
        timerHandler = timer.connect()
    }
    
    func stop() {
        time = 0
        didPlayFeedback = false
        didPlayFeedback2 = false
        timerHandler?.cancel()
    }
    
    private func prepareHapticEngine() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
            return }
        
        do {
            hapticEngine = try CHHapticEngine()
            try hapticEngine?.start()
        } catch {
            print("There was an error starting the haptic engine: \(error.localizedDescription)")
        }
    }
    
    private func playCustomHaptic() {
        // make sure that the device supports haptics
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
            return }
        var events = [CHHapticEvent]()
        var curves = [CHHapticParameterCurve]()
        
        do {
            // create one continuous buzz that fades out
            let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0)
            let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1)
            
            let start = CHHapticParameterCurve.ControlPoint(relativeTime: 0, value: 1)
            let end = CHHapticParameterCurve.ControlPoint(relativeTime: 1.0, value: 1)
            
            let parameter = CHHapticParameterCurve(parameterID: .hapticIntensityControl,
                                                   controlPoints: [start, end],
                                                   relativeTime: 0)
            let event = CHHapticEvent(eventType: .hapticContinuous,
                                      parameters: [sharpness, intensity],
                                      relativeTime: 0, duration: 1.0)
            events.append(event)
            curves.append(parameter)
        }
        
        for _ in 1...16 {
            // make some sparkles
            let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 1)
            let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1)
            let event = CHHapticEvent(eventType: .hapticTransient,
                                      parameters: [sharpness, intensity],
                                      relativeTime: TimeInterval.random(in: 0.1...1))
            events.append(event)
        }
        
        do {
            let pattern = try CHHapticPattern(events: events, parameterCurves: curves)
            
            let player = try hapticEngine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print(error.localizedDescription)
        }
       
    }
}

enum PlayerRole {
    case jammer
    case pivot
    case blocker1
    case blocker2
    case blocker3
    
    var title: String {
        switch self {
            case .jammer: "J"
            case .pivot: "P"
            case .blocker1: "B1"
            case .blocker2: "B2"
            case .blocker3: "B3"
        }
    }
    
    var icon: some View {
        switch self {
            case .jammer: Image(systemName: "star.fill")
            case .pivot: Image(systemName: "")
            case .blocker1: Image(systemName: "circle.fill")
            case .blocker2: Image(systemName: "circle.fill")
            case .blocker3: Image(systemName: "circle.fill")
        }
    }

    
}

