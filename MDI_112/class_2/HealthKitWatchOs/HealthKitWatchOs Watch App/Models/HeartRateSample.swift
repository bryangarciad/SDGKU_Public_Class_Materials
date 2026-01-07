import Foundation

struct HeartRateSample: Identifiable {
    let id: UUID = UUID()
    let bpm: Double
    let timestamp: Date // ISO 6601 2026-01-05T20:07:45.00000Z
    
    var formattedBPM: String {
        "\(Int(bpm))"
    }
    
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        return formatter.string(from: timestamp)
    }
}
