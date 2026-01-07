//
//  TiltBallView.swift
//  MotionDetectionAndActivityTracking Watch App
//
//  Created for MDI 112 - Class 3
//

import SwiftUI

/// A view with a ball that moves based on device tilt
struct TiltBallView<Manager: MotionManagerProtocol>: View {
    @ObservedObject var motionManager: Manager
    
    /// Maximum offset for the ball (pixels from center)
    private let maxOffset: CGFloat = 50
    
    /// Ball size
    private let ballSize: CGFloat = 30
    
    /// Calculate X offset from accelerometer
    private var xOffset: CGFloat {
        // X axis: positive when tilting right
        CGFloat(motionManager.x) * maxOffset
    }
    
    /// Calculate Y offset from accelerometer
    private var yOffset: CGFloat {
        // Y axis: positive when tilting up, but we want ball to roll down
        CGFloat(motionManager.y) * maxOffset
    }
    
    var body: some View {
        VStack(spacing: 8) {
            // Title
            Text("Tilt Ball")
                .font(.headline)
            
            // Ball container
            ZStack {
                // Background circle (the "bowl")
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                    .frame(width: maxOffset * 2 + ballSize, height: maxOffset * 2 + ballSize)
                
                // Center crosshair
                Group {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 1, height: maxOffset * 2)
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: maxOffset * 2, height: 1)
                }
                
                // The ball
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [.cyan, .blue],
                            center: .topLeading,
                            startRadius: 0,
                            endRadius: ballSize
                        )
                    )
                    .frame(width: ballSize, height: ballSize)
                    .shadow(color: .cyan.opacity(0.5), radius: 5)
                    .offset(x: xOffset, y: yOffset)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: xOffset)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: yOffset)
            }
            .frame(height: maxOffset * 2 + ballSize + 20)
            
            // Accelerometer values
            VStack(spacing: 2) {
                HStack(spacing: 12) {
                    AccelerometerValue(axis: "X", value: motionManager.x, color: .red)
                    AccelerometerValue(axis: "Y", value: motionManager.y, color: .green)
                }
                AccelerometerValue(axis: "Z", value: motionManager.z, color: .blue)
            }
            
            // Status
            if !motionManager.isRunning {
                Text("Tap Start to begin")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal)
    }
}

/// Small component to display an accelerometer value
struct AccelerometerValue: View {
    let axis: String
    let value: Double
    let color: Color
    
    var body: some View {
        HStack(spacing: 4) {
            Text(axis)
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundStyle(color)
            Text(String(format: "%.2f", value))
                .font(.caption2)
                .monospacedDigit()
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    TiltBallView(motionManager: MotionManager())
}

