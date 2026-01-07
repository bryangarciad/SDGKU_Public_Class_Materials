import Foundation
import SwiftUI

enum HeartRateZone: String, CaseIterable {
    case rest = "Rest"
    case fatBurn = "Fat Burn"
    case cardio = "Cardio"
    case peak = "Peak"
    
    // Computed Property
    var color: Color {
        switch self {
            case .rest:
                return .blue
            case .fatBurn:
                return .yellow
            case .cardio:
                return .green
            case .peak:
                return .red
        }
    }
    
    var icon: String  {
        switch self {
            case .rest:
                return "figure.stand"
            case .fatBurn:
                return "flame"
            case .cardio:
                return "figure.run"
            case .peak:
                return "bolt.heart.fill"
        }
    }
    
    var description: String {
        switch self {
            case .rest:
                return "Recovery Zone"
            case .fatBurn:
                return "Ligh Excersize"
            case .cardio:
                return "Moderate Excersize"
            case .peak:
                return "Maximum Effort"
        }
    }
    
    var percentageRange: String  {
        switch self {
            case .rest:
                return "50-60%"
            case .fatBurn:
                return "60-70%"
            case .cardio:
                return "70-85%"
            case .peak:
                return "85-100%"
        }
    }
    
    static func zone(for bpm: Double, maxHeartRate: Double = 200) -> HeartRateZone {
        let percentage = bpm / maxHeartRate * 100
        
        switch percentage {
            case 0..<80:
                return .rest
            case 80..<95:
                return .fatBurn
            case 95..<110:
                return .cardio
            default:
                return .peak
        }
    }
}
