//
//  ShakeCounterView.swift
//  MotionDetectionAndActivityTracking Watch App
//
//  Created for MDI 112 - Class 3
//

import SwiftUI

/// A view that counts shakes and shows magnitude
struct ShakeCounterView<Manager: MotionManagerProtocol>: View {
    @ObservedObject var motionManager: Manager
    
    var body: some View {
        VStack(spacing: 12) {
            // Title
            Text("Shake Counter")
                .font(.headline)
            
            // Shake icon with animation
            Image(systemName: "iphone.radiowaves.left.and.right")
                .font(.system(size: 40))
                .foregroundStyle(motionManager.shakeDetected ? .orange : .gray)
                .scaleEffect(motionManager.shakeDetected ? 1.3 : 1.0)
                .animation(.spring(response: 0.2, dampingFraction: 0.5), value: motionManager.shakeDetected)
            
            // Shake count display
            VStack(spacing: 4) {
                Text("\(motionManager.shakeCount)")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(.orange)
                    .scaleEffect(motionManager.shakeDetected ? 1.1 : 1.0)
                    .animation(.spring(response: 0.2), value: motionManager.shakeDetected)
                
                Text("shakes")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            // Magnitude meter
            MagnitudeMeter(magnitude: motionManager.magnitude)
            
            // Reset button
            Button(action: {
                motionManager.resetShakeCount()
            }) {
                HStack {
                    Image(systemName: "arrow.counterclockwise")
                    Text("Reset")
                }
                .font(.caption)
            }
            .buttonStyle(.bordered)
            .tint(.gray)
            
            // Instructions
            if !motionManager.isRunning {
                Text("Tap Start to begin")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            } else {
                Text("Shake your wrist!")
                    .font(.caption2)
                    .foregroundStyle(.orange)
            }
        }
        .padding(.horizontal)
    }
}

/// Visual magnitude meter
struct MagnitudeMeter: View {
    let magnitude: Double
    
    /// Normalized magnitude (0-1 range for display)
    private var normalizedMagnitude: Double {
        min(magnitude / 3.0, 1.0) // 3.0 = max expected magnitude
    }
    
    /// Color based on magnitude
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
            // Meter bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.3))
                    
                    // Fill
                    RoundedRectangle(cornerRadius: 4)
                        .fill(meterColor)
                        .frame(width: geometry.size.width * normalizedMagnitude)
                        .animation(.easeOut(duration: 0.1), value: normalizedMagnitude)
                }
            }
            .frame(height: 8)
            
            // Label
            HStack {
                Text("Magnitude")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Spacer()
                Text(String(format: "%.2f", magnitude))
                    .font(.caption2)
                    .monospacedDigit()
                    .foregroundStyle(meterColor)
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    ShakeCounterView(motionManager: MotionManager())
}

