//
//  StatsView.swift
//  BatteryManagementAndPerformance Watch App
//
//  Created for MDI 112 - Class 4
//

import SwiftUI

/// View showing motion data and update statistics
struct StatsView: View {
    @ObservedObject var manager: PowerAwareMotionManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                // Update counter (key demonstration!)
                UpdateCounterCard(
                    count: manager.updateCount,
                    mode: manager.currentMode,
                    isRunning: manager.isRunning
                )
                
                // Motion data
                if manager.isRunning {
                    MotionDataCard(x: manager.x, y: manager.y, z: manager.z)
                }
                
                // Mode info
                PowerModeInfoCard(mode: manager.currentMode)
            }
            .padding(.horizontal)
        }
        .navigationTitle("Stats")
    }
}

/// Card showing update count - demonstrates frequency difference
struct UpdateCounterCard: View {
    let count: Int
    let mode: PowerMode
    let isRunning: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "number.circle.fill")
                    .foregroundStyle(mode.color)
                Text("Updates Received")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Text("\(count)")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundStyle(mode.color)
                .monospacedDigit()
            
            if isRunning {
                Text("\(mode.updatesPerSecond) per second")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            } else {
                Text("Paused")
                    .font(.caption2)
                    .foregroundStyle(.orange)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(mode.color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

/// Card showing live motion data
struct MotionDataCard: View {
    let x: Double
    let y: Double
    let z: Double
    
    var body: some View {
        VStack(spacing: 8) {
            Text("Accelerometer")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            HStack(spacing: 12) {
                AxisValue(axis: "X", value: x, color: .red)
                AxisValue(axis: "Y", value: y, color: .green)
                AxisValue(axis: "Z", value: z, color: .blue)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

/// Individual axis value display
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
                .font(.caption2)
                .monospacedDigit()
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    StatsView(manager: PowerAwareMotionManager())
}

