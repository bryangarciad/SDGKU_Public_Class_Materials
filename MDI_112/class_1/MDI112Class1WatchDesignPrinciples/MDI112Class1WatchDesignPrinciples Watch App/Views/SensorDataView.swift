//
//  SensorDataView.swift
//  MDI112Class1WatchDesignPrinciples Watch App
//
//  Displays raw sensor data from CoreMotion
//  Demonstrates: Accessing accelerometer, gyroscope, and activity data
//

import SwiftUI

/// View displaying raw sensor data from CoreMotion
/// Design Principle: Educational display of available sensor data
struct SensorDataView: View {
    @StateObject private var motionManager = MotionManager.shared
    
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                // Status indicator
                statusIndicator
                
                // Accelerometer section
                SensorCard(
                    title: "Accelerometer",
                    icon: "arrow.up.and.down.and.arrow.left.and.right",
                    color: .blue,
                    isAvailable: motionManager.isAccelerometerAvailable
                ) {
                    AxisDataRow(label: "X", value: motionManager.accelerometerData.x, color: .red)
                    AxisDataRow(label: "Y", value: motionManager.accelerometerData.y, color: .green)
                    AxisDataRow(label: "Z", value: motionManager.accelerometerData.z, color: .blue)
                }
                
                // Gyroscope section
                SensorCard(
                    title: "Gyroscope",
                    icon: "gyroscope",
                    color: .purple,
                    isAvailable: motionManager.isGyroscopeAvailable
                ) {
                    AxisDataRow(label: "X", value: motionManager.gyroscopeData.x, color: .red)
                    AxisDataRow(label: "Y", value: motionManager.gyroscopeData.y, color: .green)
                    AxisDataRow(label: "Z", value: motionManager.gyroscopeData.z, color: .blue)
                }
                
                // Activity section
                SensorCard(
                    title: "Activity",
                    icon: "figure.walk.motion",
                    color: .orange,
                    isAvailable: motionManager.isActivityAvailable
                ) {
                    HStack {
                        Image(systemName: motionManager.currentActivity.icon)
                            .font(.title3)
                        Text(motionManager.currentActivity.rawValue)
                            .font(.system(.body, design: .rounded))
                            .fontWeight(.medium)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 4)
                }
                
                // Start/Stop button
                Button(action: {
                    if motionManager.isActive {
                        motionManager.stopUpdates()
                    } else {
                        motionManager.startUpdates()
                    }
                }) {
                    HStack {
                        Image(systemName: motionManager.isActive ? "stop.fill" : "play.fill")
                        Text(motionManager.isActive ? "Stop" : "Start")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(motionManager.isActive ? .red : .green)
                
                // Error message
                if let error = motionManager.errorMessage {
                    Text(error)
                        .font(.caption2)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                }
            }
            .padding()
        }
        .navigationTitle("Sensors")
        .onDisappear {
            // Stop updates when leaving to save battery
            motionManager.stopUpdates()
        }
    }
    
    // MARK: - Status Indicator
    
    private var statusIndicator: some View {
        HStack {
            Circle()
                .fill(motionManager.isActive ? .green : .gray)
                .frame(width: 8, height: 8)
            Text(motionManager.isActive ? "Active" : "Inactive")
                .font(.caption)
                .foregroundStyle(.secondary)
            Spacer()
        }
    }
}

// MARK: - Sensor Card

/// Card component for displaying sensor data
struct SensorCard<Content: View>: View {
    let title: String
    let icon: String
    let color: Color
    let isAvailable: Bool
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(color)
                Text(title)
                    .font(.caption)
                    .fontWeight(.semibold)
                Spacer()
                if !isAvailable {
                    Text("N/A")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            
            // Content
            if isAvailable {
                content
            } else {
                Text("Not available on this device")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(10)
        .background(color.opacity(0.1))
        .cornerRadius(10)
    }
}

// MARK: - Axis Data Row

/// Row displaying a single axis value
struct AxisDataRow: View {
    let label: String
    let value: Double
    let color: Color
    
    var body: some View {
        HStack {
            Text(label)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundStyle(color)
                .frame(width: 16)
            
            // Value bar visualization
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 4)
                    
                    // Value indicator (centered, extends left or right based on value)
                    Rectangle()
                        .fill(color)
                        .frame(width: abs(value) * geometry.size.width / 2, height: 4)
                        .offset(x: value >= 0 ? geometry.size.width / 2 : geometry.size.width / 2 - abs(value) * geometry.size.width / 2)
                }
            }
            .frame(height: 4)
            
            // Numeric value
            Text(String(format: "%+.2f", value))
                .font(.system(size: 11, design: .monospaced))
                .frame(width: 50, alignment: .trailing)
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        SensorDataView()
    }
}

