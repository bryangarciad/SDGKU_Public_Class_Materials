//
//  HeartRateComponents.swift
//  MDI112Class1WatchDesignPrinciples Watch App
//
//  Reusable heart rate UI components
//  Demonstrates: Creating animated components for wearables
//

import SwiftUI

// MARK: - Pulsing Heart View

/// An animated heart that pulses based on heart rate
/// Design Principle: Meaningful animation provides real-time feedback
struct PulsingHeartView: View {
    let heartRate: Double
    let zone: HeartRateZone
    
    @State private var isPulsing = false
    
    /// Calculate animation duration based on heart rate
    /// Higher heart rate = faster pulse
    private var pulseDuration: Double {
        guard heartRate > 0 else { return 1.0 }
        // Convert BPM to seconds per beat
        return 60.0 / heartRate
    }
    
    var body: some View {
        Image(systemName: "heart.fill")
            .font(.system(size: 50))
            .foregroundStyle(zone.color)
            .scaleEffect(isPulsing ? 1.15 : 1.0)
            .animation(
                .easeInOut(duration: pulseDuration / 2)
                .repeatForever(autoreverses: true),
                value: isPulsing
            )
            .onAppear {
                isPulsing = true
            }
            .onChange(of: heartRate) { _, _ in
                // Reset animation when heart rate changes
                isPulsing = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isPulsing = true
                }
            }
    }
}

// MARK: - Small Pulsing Heart

/// A smaller pulsing heart for compact displays
struct SmallPulsingHeartView: View {
    let zone: HeartRateZone
    @State private var isPulsing = false
    
    var body: some View {
        Image(systemName: "heart.fill")
            .font(.system(size: 16))
            .foregroundStyle(zone.color)
            .scaleEffect(isPulsing ? 1.1 : 1.0)
            .animation(
                .easeInOut(duration: 0.5)
                .repeatForever(autoreverses: true),
                value: isPulsing
            )
            .onAppear {
                isPulsing = true
            }
    }
}

// MARK: - Zone Badge View

/// A badge showing the current heart rate zone
struct ZoneBadgeView: View {
    let zone: HeartRateZone
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: zone.icon)
                .font(.caption2)
            Text(zone.rawValue)
                .font(.caption2)
                .fontWeight(.semibold)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(zone.color.opacity(0.2))
        .foregroundStyle(zone.color)
        .clipShape(Capsule())
    }
}

// MARK: - Heart Rate Display

/// Compact heart rate display for dashboard
/// Design Principle: Glanceable information at a glance
struct HeartRateDisplayView: View {
    let heartRate: Double
    let zone: HeartRateZone
    let lastUpdated: Date?
    
    var body: some View {
        VStack(spacing: 4) {
            // Pulsing heart icon
            SmallPulsingHeartView(zone: zone)
            
            // BPM value
            if heartRate > 0 {
                Text("\(Int(heartRate))")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(zone.color)
                
                Text("BPM")
                    .font(.system(size: 8))
                    .foregroundColor(.gray)
            } else {
                Text("--")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.gray)
                
                Text("BPM")
                    .font(.system(size: 8))
                    .foregroundColor(.gray)
            }
        }
    }
}

// MARK: - Previews

#Preview("Pulsing Heart") {
    VStack(spacing: 20) {
        PulsingHeartView(heartRate: 72, zone: .rest)
        PulsingHeartView(heartRate: 120, zone: .cardio)
        PulsingHeartView(heartRate: 170, zone: .peak)
    }
}

#Preview("Zone Badges") {
    VStack(spacing: 10) {
        ForEach(HeartRateZone.allCases, id: \.self) { zone in
            ZoneBadgeView(zone: zone)
        }
    }
}

#Preview("Heart Rate Display") {
    HeartRateDisplayView(heartRate: 85, zone: .fatBurn, lastUpdated: Date())
}

