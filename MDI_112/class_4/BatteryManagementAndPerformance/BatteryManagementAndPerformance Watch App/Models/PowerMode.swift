//
//  PowerMode.swift
//  BatteryManagementAndPerformance Watch App
//
//  Created for MDI 112 - Class 4
//

import SwiftUI

/// Represents different power consumption modes
enum PowerMode: String, CaseIterable, Identifiable {
    case eco = "Eco"
    case balanced = "Balanced"
    case performance = "Performance"
    
    var id: String { rawValue }
    
    /// Update interval in seconds for this mode
    var updateInterval: TimeInterval {
        switch self {
        case .eco:
            return 1.0        // 1 Hz - Maximum battery saving
        case .balanced:
            return 0.2        // 5 Hz - Good balance
        case .performance:
            return 0.05       // 20 Hz - Smooth but power hungry
        }
    }
    
    /// Updates per second for display
    var updatesPerSecond: Int {
        switch self {
        case .eco: return 1
        case .balanced: return 5
        case .performance: return 20
        }
    }
    
    /// Color representing this mode
    var color: Color {
        switch self {
        case .eco:
            return .green
        case .balanced:
            return .yellow
        case .performance:
            return .red
        }
    }
    
    /// Icon for this mode
    var icon: String {
        switch self {
        case .eco:
            return "leaf.fill"
        case .balanced:
            return "scale.3d"
        case .performance:
            return "bolt.fill"
        }
    }
    
    /// Battery drain multiplier (relative to eco)
    var batteryDrainMultiplier: Double {
        switch self {
        case .eco:
            return 1.0
        case .balanced:
            return 3.0
        case .performance:
            return 10.0
        }
    }
    
    /// Description of the mode
    var description: String {
        switch self {
        case .eco:
            return "Maximum battery life"
        case .balanced:
            return "Balance of power & performance"
        case .performance:
            return "Smooth updates, higher drain"
        }
    }
    
    /// Estimated battery life description
    var batteryLifeEstimate: String {
        switch self {
        case .eco:
            return "~18 hours"
        case .balanced:
            return "~8 hours"
        case .performance:
            return "~3 hours"
        }
    }
}

