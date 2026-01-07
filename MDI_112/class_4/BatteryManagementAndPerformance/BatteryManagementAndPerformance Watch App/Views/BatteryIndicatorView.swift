//
//  BatteryIndicatorView.swift
//  BatteryManagementAndPerformance Watch App
//
//  Created for MDI 112 - Class 4
//

import SwiftUI

/// Visual battery level indicator
struct BatteryIndicatorView: View {
    let level: Double
    let mode: PowerMode
    
    /// Battery color based on level
    private var batteryColor: Color {
        if level > 50 {
            return .green
        } else if level > 20 {
            return .yellow
        } else {
            return .red
        }
    }
    
    /// Battery icon based on level
    private var batteryIcon: String {
        if level > 75 {
            return "battery.100"
        } else if level > 50 {
            return "battery.75"
        } else if level > 25 {
            return "battery.50"
        } else if level > 0 {
            return "battery.25"
        } else {
            return "battery.0"
        }
    }
    
    var body: some View {
        VStack(spacing: 8) {
            // Battery icon and percentage
            HStack(spacing: 8) {
                Image(systemName: batteryIcon)
                    .font(.title2)
                    .foregroundStyle(batteryColor)
                
                Text("\(Int(level))%")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(batteryColor)
                    .monospacedDigit()
            }
            
            // Battery bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.gray.opacity(0.3))
                    
                    // Fill
                    RoundedRectangle(cornerRadius: 6)
                        .fill(batteryColor)
                        .frame(width: geometry.size.width * (level / 100))
                        .animation(.easeInOut(duration: 0.3), value: level)
                }
            }
            .frame(height: 12)
            
            // Estimated life for current mode
            Text("Est. life: \(mode.batteryLifeEstimate)")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}

/// Compact battery badge for headers
struct BatteryBadge: View {
    let level: Double
    
    private var color: Color {
        if level > 50 { return .green }
        else if level > 20 { return .yellow }
        else { return .red }
    }
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "battery.50")
                .font(.caption2)
            Text("\(Int(level))%")
                .font(.caption2)
                .monospacedDigit()
        }
        .foregroundStyle(color)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(color.opacity(0.2))
        .clipShape(Capsule())
    }
}

#Preview {
    VStack(spacing: 20) {
        BatteryIndicatorView(level: 85, mode: .eco)
        BatteryIndicatorView(level: 45, mode: .balanced)
        BatteryIndicatorView(level: 15, mode: .performance)
        BatteryBadge(level: 65)
    }
    .padding()
}

