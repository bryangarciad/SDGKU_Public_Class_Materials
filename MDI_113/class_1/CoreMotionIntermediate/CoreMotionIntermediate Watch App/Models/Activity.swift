//
//  Activity.swift
//  CoreMotionIntermediate Watch App
//
//  Created for MDI 113 - Class 1
//

import SwiftUI

/// Detected activity types
enum Activity: String, CaseIterable {
    case stationary = "Stationary"
    case walking = "Walking"
    case running = "Running"
    case unknown = "Unknown"
    
    var icon: String {
        switch self {
        case .stationary: return "figure.stand"
        case .walking: return "figure.walk"
        case .running: return "figure.run"
        case .unknown: return "questionmark.circle"
        }
    }
    
    var color: Color {
        switch self {
        case .stationary: return .blue
        case .walking: return .green
        case .running: return .orange
        case .unknown: return .gray
        }
    }
    
    var emoji: String {
        switch self {
        case .stationary: return "🧍"
        case .walking: return "🚶"
        case .running: return "🏃"
        case .unknown: return "❓"
        }
    }
}

/// Record of a detected activity with timestamp
struct ActivityRecord: Identifiable {
    let id = UUID()
    let activity: Activity
    let timestamp: Date
    let confidence: Double
    
    var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        return formatter.string(from: timestamp)
    }
}

