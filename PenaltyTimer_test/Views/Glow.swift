//
//  Glow.swift
//  PenaltyTimer_test
//
//  Created by Peter Hauke on 23.06.25.
//

import SwiftUI

struct AnimatedGlowEffect: ViewModifier {
    
    @State var animated: Bool
    @State private var throb: Bool = false
    
    func body(content: Content) -> some View {
        ZStack {
            // Glow effect
            
            content
                .blur(radius: throb ? 15 : 5)
                .animation(.easeOut(duration: 0.5).repeatForever(),
                           value: throb)
                .onAppear {
    //                throb.toggle()
                }
            
            content
        }
    }
    
    var radius: CGFloat {
        guard animated else {
            print("radius: 0")
            return 0.0 }
        
        let radius = throb ? 25.0 : 5.0
        print("radius: \(radius)")
        return radius
    }
    
}


extension View {
    
    public func animatedGlow(animated: Bool) -> some View {
        modifier(AnimatedGlowEffect(animated: animated))
    }
    
}
