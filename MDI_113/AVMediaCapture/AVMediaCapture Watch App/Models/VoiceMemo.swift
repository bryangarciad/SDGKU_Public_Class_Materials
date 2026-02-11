import Foundation
import Combine

struct VoiceMemo: Identifiable {
    let id = UUID()
    
    let url: URL // URL rgarcia/documents/voicememo/file1.a4c
    let createdAt: Date // 2026-01-14T18:15:56.0403-06:00 ISO6001
    let duration: TimeInterval
    
    // MARK: - Computed Props
    var name: String {
        url.deletingPathExtension().lastPathComponent
    }
    
    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        
        return formatter.string(from: createdAt)
    }
    
    var durationString: String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        
        return String(format: "%d:%02d", minutes, seconds) // 4:04
    }
    
    var fileSize: String {
        let attributes = try? FileManager.default.attributesOfItem(atPath: url.path)
        let size = attributes?[.size] as? Int64 ?? 0
        return "\(size / 1024) KB"
    }
}
