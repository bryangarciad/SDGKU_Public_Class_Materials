//
//  HeartRateSample.swift
//  HealthKitOnSwiftUI Watch App
//
//  Created for MDI 112 - Class 2
//

import Foundation

/// Represents a single heart rate measurement
struct HeartRateSample: Identifiable {
    let id = UUID()
    let bpm: Double
    let timestamp: Date
    
    /// Formatted BPM as integer string
    var formattedBPM: String {
        "\(Int(bpm))"
    }
    
    /// Formatted timestamp
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        return formatter.string(from: timestamp)
    }
}

