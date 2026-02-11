import SwiftUI

struct ShakeCounterView: View {
    @ObservedObject var motionManager: MotionManager
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Shake Counter")
                .font(.headline)
            
            Image(systemName: "iphone.radiowaves.left.and.right")
                .font(.system(size: 40))
                .foregroundStyle(motionManager.shakeDetected ? .orange : .gray)
                .scaleEffect(motionManager.shakeDetected ? 1.3 : 1.0)
                .animation(.spring(response: 0.2, dampingFraction: 0.5), value: motionManager.shakeDetected)
            
            VStack(spacing: 4) {
                Text("\(motionManager.shakeCount)")
                    .font(.system(size: 40))
                    .foregroundStyle(.orange)
                    .scaleEffect(motionManager.shakeDetected ? 1.1 : 1.0)
                    .animation(.spring(response: 0.2, dampingFraction: 0.5), value: motionManager.shakeDetected)
                
                Text("shakes")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            MagnitudeMeter(magnitude: motionManager.magnitude)
            
            if !motionManager.isRunning {
                Text("Tap To Start")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            } else {
                Text("Shake your wrist")
                    .font(.caption2)
                    .foregroundStyle(.orange)
            }
        }.padding(.horizontal)
    }
}

struct MagnitudeMeter: View {
    let magnitude: Double
    
    private var normalizedMagnitude: Double {
        min(magnitude / 3.0, 1.0) // 3.0 = max expected magnitude
    }
    
    private var meterColor: Color {
        if magnitude > 2.0 {
            return .orange
        } else if magnitude > 1.5 {
            return .yellow
        } else {
            return .green
        }
    }
    
    var body: some View {
        VStack(spacing: 4) {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.3))
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(meterColor)
                        .frame(width: geometry.size.width * normalizedMagnitude)
                        .animation(.easeOut(duration: 0.2), value: normalizedMagnitude)
                }
            }
        }.frame(height: 8)
        
        HStack {
            Text("Magnitude")
                .font(.caption)
                .foregroundStyle(.secondary)
            Spacer()
            Text(String(format: "%.1f", magnitude))
                .font(.caption2)
                .monospacedDigit()
                .foregroundStyle(meterColor)
        }
        .padding(.horizontal)
    }
}

#Preview {
    ShakeCounterView(motionManager: MotionManager())
}
