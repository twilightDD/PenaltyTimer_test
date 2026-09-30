import SwiftUI

// MARK: - Animated Glow ViewModifier
struct AnimatedGlowModifier: ViewModifier {
    let isActive: Bool
    let color: Color
    let duration: Double
    
    @State private var glowIntensity: Double = 1.0
    
    init(isActive: Bool, color: Color = .green, duration: Double = 1.0) {
        self.isActive = isActive
        self.color = color
        self.duration = duration
    }
    
    func body(content: Content) -> some View {
        content
            .shadow(
                color: isActive ? color.opacity(glowIntensity) : .clear,
                radius: isActive ? 15 + (glowIntensity * 10) : 0,
                x: 0,
                y: 0
            )
            .shadow(
                color: isActive ? color.opacity(glowIntensity * 0.5) : .clear,
                radius: isActive ? 25 + (glowIntensity * 15) : 0,
                x: 0,
                y: 0
            )
            .scaleEffect(isActive ? 1.05 : 1.0)
            .onChange(of: isActive) { _, newValue in
                if newValue {
                    startGlowAnimation()
                } else {
                    stopGlowAnimation()
                }
            }
    }
    
    private func startGlowAnimation() {
        withAnimation(.easeInOut(duration: duration).repeatForever(autoreverses: true)) {
            glowIntensity = 0.2
        }
    }
    
    private func stopGlowAnimation() {
        withAnimation(.easeInOut(duration: 0.3)) {
            glowIntensity = 1.0
        }
    }
}

// MARK: - View Extension
extension View {
    func animatedGlow(isActive: Bool, color: Color = .green, duration: Double = 1.0) -> some View {
        self.modifier(AnimatedGlowModifier(isActive: isActive, color: color, duration: duration))
    }
}

struct AnimatedTextFieldView: View {
    @State private var isGlowing = false
    
    var body: some View {
        VStack(spacing: 30) {
            // Textfeld mit animiertem Hintergrund
            Text("Hallo")
                .font(.title2)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isGlowing ? Color.green : Color.blue)
                )
                .animatedGlow(isActive: isGlowing, color: .green, duration: 1.0)
                .animation(.easeInOut(duration: 0.3), value: isGlowing)
            
            // Grüner Button
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isGlowing.toggle()
                }
            }) {
                Text("Toggle Glow")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.green)
                    )
            }
            
            Text("Hallo 2")
                .background(.yellow)
                .animatedGlow(isActive: isGlowing, color: .green, duration: 1.0)
                .animation(.easeInOut(duration: 0.3), value: isGlowing)
        }
        .padding(20)
    }
}

#Preview {
    AnimatedTextFieldView()
}
