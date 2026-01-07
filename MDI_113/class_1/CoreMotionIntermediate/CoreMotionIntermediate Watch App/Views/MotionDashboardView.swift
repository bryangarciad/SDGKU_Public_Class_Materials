//
//  MotionDashboardView.swift
//  CoreMotionIntermediate Watch App
//
//  Created for MDI 113 - Class 1
//

import SwiftUI

/// Dashboard showing all motion data
struct MotionDashboardView: View {
    @ObservedObject var manager: AdvancedMotionManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                // User Acceleration
                MotionDataCard(
                    title: "User Acceleration",
                    icon: "arrow.up.arrow.down",
                    color: .orange,
                    x: manager.userAcceleration.x,
                    y: manager.userAcceleration.y,
                    z: manager.userAcceleration.z
                )
                
                // Gravity
                MotionDataCard(
                    title: "Gravity",
                    icon: "arrow.down.circle",
                    color: .blue,
                    x: manager.gravity.x,
                    y: manager.gravity.y,
                    z: manager.gravity.z
                )
                
                // Attitude
                AttitudeCard(
                    pitch: manager.attitude.pitch,
                    roll: manager.attitude.roll,
                    yaw: manager.attitude.yaw
                )
                
                // Rotation Rate
                MotionDataCard(
                    title: "Rotation Rate",
                    icon: "rotate.3d",
                    color: .purple,
                    x: manager.rotationRate.x,
                    y: manager.rotationRate.y,
                    z: manager.rotationRate.z
                )
            }
            .padding(.horizontal)
        }
        .navigationTitle("Motion Data")
    }
}

/// Card displaying X, Y, Z motion values
struct MotionDataCard: View {
    let title: String
    let icon: String
    let color: Color
    let x: Double
    let y: Double
    let z: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(color)
                Text(title)
                    .font(.caption)
                    .fontWeight(.semibold)
            }
            
            HStack(spacing: 12) {
                AxisValue(axis: "X", value: x, color: .red)
                AxisValue(axis: "Y", value: y, color: .green)
                AxisValue(axis: "Z", value: z, color: .blue)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

/// Single axis value display
struct AxisValue: View {
    let axis: String
    let value: Double
    let color: Color
    
    var body: some View {
        VStack(spacing: 2) {
            Text(axis)
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundStyle(color)
            Text(String(format: "%.2f", value))
                .font(.system(size: 11))
                .monospacedDigit()
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

/// Attitude card with pitch, roll, yaw
struct AttitudeCard: View {
    let pitch: Double
    let roll: Double
    let yaw: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "gyroscope")
                    .foregroundStyle(.cyan)
                Text("Attitude (degrees)")
                    .font(.caption)
                    .fontWeight(.semibold)
            }
            
            HStack(spacing: 8) {
                AttitudeValue(name: "Pitch", value: pitch, icon: "↕️")
                AttitudeValue(name: "Roll", value: roll, icon: "↔️")
                AttitudeValue(name: "Yaw", value: yaw, icon: "🔄")
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.cyan.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct AttitudeValue: View {
    let name: String
    let value: Double
    let icon: String
    
    var body: some View {
        VStack(spacing: 2) {
            Text(icon)
                .font(.caption)
            Text(String(format: "%.0f°", value))
                .font(.system(size: 11))
                .monospacedDigit()
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    MotionDashboardView(manager: AdvancedMotionManager())
}

