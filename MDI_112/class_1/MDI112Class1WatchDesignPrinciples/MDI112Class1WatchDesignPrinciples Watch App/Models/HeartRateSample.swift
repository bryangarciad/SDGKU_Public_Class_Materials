//
//  HeartRateSample.swift
//  MDI112Class1WatchDesignPrinciples Watch App
//
//  Model for heart rate data from HealthKit
//  Demonstrates: Simple data models for wearable health data
//

import Foundation

/// Represents a single heart rate measurement from HealthKit
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

