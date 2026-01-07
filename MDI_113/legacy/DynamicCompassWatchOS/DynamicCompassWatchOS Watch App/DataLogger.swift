import Foundation

class DataLogger: ObservableObject {
    @Published var tiltData: [(time: Double, pitch: Double)] = []
    private var startTime: Date?
    
    func startLogging() {
        tiltData.removeAll()
        startTime = Date()
    }
    
    func log(pitch: Double) {
        guard let start = startTime else { return }
        let elapsed = Date().timeIntervalSince(start)
        tiltData.append((time: elapsed, pitch: pitch))
    }
}