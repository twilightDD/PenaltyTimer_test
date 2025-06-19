//
//  PlayerRow.swift
//  PenaltyTimer_test
//
//  Created by Peter Hauke on 18.06.25.
//

import SwiftUI
import Combine
import AVFoundation
import CoreHaptics


//MARK: - PlayerRow
struct PlayerRow: View, Identifiable {
    
    //MARK: - Enviroment
    @Environment(\.colorScheme) var colorScheme
    
    //MARK: Constants
    private let startDuration: TimeInterval = 0
    private let feedbackDuration: TimeInterval = 0.3
    private let standDuration: TimeInterval = 20
    private let goDuration: TimeInterval = 30
    //    private let standDuration: TimeInterval = 5 // debug
    //    private let goDuration: TimeInterval = 10 // debug
    
    
    //MARK: - Lets and Vars
    let id = UUID()
    let role: PlayerRole
    
    var jamBreak: Bool
    @State var timeBreak: Bool = false
    
    //MARK: - States
    @State private var didPlayFeedback: Bool = false
    @State private var didPlayFeedback2: Bool = false
    
    @State private var time: TimeInterval = 0
    
    // Timer
    @State private var timer = Timer.publish(every: 0.1, tolerance: 0.01,
                                             on: .main, in: .default)
    @State private var timerHandler: Cancellable?
    @State private var repeatTimer: Bool = false
    
    // Feedback
    @State private var hapticEngine: CHHapticEngine?
    
    // StartStop Tapping
    @State private var lastTapTime: Date = Date()
    
    //MARK: - Body
    var body: some View {
        HStack(spacing: 15) {
            Text("\(role.title)")
                .frame(width: 40)
            
            role.icon(colorScheme: colorScheme)
                .frame(width: 40)
            
            penaltyStatusView()
                .frame(height: 30)
            
            
            penaltyBreakView()
                .frame(height: 30)
            
            Spacer()
            
            Text("\(time, specifier: "%.1f") s")
                .frame(alignment: .trailing)
        }
        
        .onReceive(timer) { timer in
            guard jamBreak == false else {
                return }
            
            guard timeBreak == false else {
                return }
            
            time += 0.1
            
            if didPlayFeedback == false && time >= standDuration - feedbackDuration {
                playCustomHaptic()
                //
                //                let systemSoundID: SystemSoundID = 1070
                //                AudioServicesPlaySystemSound(systemSoundID)
                
                didPlayFeedback = true
            }
            if didPlayFeedback2 == false && time >= goDuration - feedbackDuration {
                //playCustomHaptic()
                
                let systemSoundID: SystemSoundID = 1013
                AudioServicesPlaySystemSound(systemSoundID)
                
                didPlayFeedback2 = true
            }
        }
        .font(Font.system(size: 32, weight: .bold))
        .fontDesign(.monospaced)
        .padding()
        .background(penaltyColor)
        .onAppear {
            prepareHapticEngine()
        }
        .onTapGesture {
            withAnimation {
                tappedToStartStop()
            }
        }
    }
    
    
    //MARK: -
    //MARK: Timing
    func start() {
        timerHandler?.cancel()
        timer = Timer.publish(every: 0.1,tolerance: 0.05,
                              on: .main, in: .default)
        timerHandler = timer.connect()
    }
    
    func stop() {
        time = 0
        timeBreak = false
        didPlayFeedback = false
        didPlayFeedback2 = false
        timerHandler?.cancel()
    }
    
    //MARK: Penalty status
    var penaltyColor: Color {
        switch time {
            case startDuration: return jamBreak ? .gray.opacity(0.25) : .blue.opacity(0.2)
            case startDuration..<standDuration: return .red.opacity(jamBreak ? 0.25 : 1)
            case standDuration..<goDuration: return .yellow.opacity(jamBreak ? 0.25 : 1)
            default:
                return .green.opacity(jamBreak ? 0.25 : 1)
        }
    }
    
    func penaltyStatusView()
    -> Image? {
        switch time {
            case startDuration: nil
            case startDuration..<standDuration:  Image(systemName: "figure.seated.seatbelt")
            case standDuration..<goDuration:  Image(systemName: "chevron.up.2")
            default:
                Image(systemName: "figure.run")
        }
    }
    
    func penaltyBreakView()
    -> Image? {
        timeBreak ? Image(systemName: "pause") : nil
    }
    
    //MARK: Gesture handling
    func tappedToStartStop() {
        
        guard jamBreak == false else {
            return }

        if time == 0 {
            start()
            self.lastTapTime = Date()
        }
        else if Date().timeIntervalSince(lastTapTime) < 0.25 {
            stop()
        }
        else if time > 0 && time < goDuration {
            timeBreak.toggle()
            self.lastTapTime = Date()
            
        }
        else {
            self.lastTapTime = Date()
        }
    }
    
    
    //MARK: Haptic feedback
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

//MARK: -
//MARK: - PlayerRole
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
    
    @ViewBuilder
    func icon(colorScheme: ColorScheme)
    -> some View {
        switch self {
            case .jammer: Image(systemName: "star.fill")
            case .pivot: Rectangle().fill(colorScheme == .dark ? .white : .black).frame(width: 15, height: 35, alignment: .center)
            case .blocker1: Image(systemName: "shield.fill")
            case .blocker2: Image(systemName: "shield.fill")
            case .blocker3: Image(systemName: "shield.fill")
        }
    }
    
}


#Preview {
    PlayerRow( role: .pivot, jamBreak: false)
}
