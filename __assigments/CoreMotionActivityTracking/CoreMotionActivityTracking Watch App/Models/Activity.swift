import SwiftUI
import Foundation
import Combine

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
        case .unknown: return "questionmark"
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
}

struct ActivityRecord: Identifiable {
    let id = UUID()
    let activity: Activity
    let timestamp: Date // 2025-10-17T17:00:00
    let confidence: Double // Calculated Number to score the confidence for the activity category
    
    
    // MARK: - Computed Properties
    var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }
    
}
