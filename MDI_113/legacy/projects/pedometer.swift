import SwiftUI
import CoreMotion
import Combine

// MARK: - ViewModel
/// Manages pedometer and accelerometer data using Core Motion
class MotionPedometerManager: ObservableObject {
    private let pedometer = CMPedometer() // Tracks steps and distance
    private let motionManager = CMMotionManager() // Tracks acceleration
    private var timer: Timer? // Timer to poll accelerometer data
    private var startTime: Date? // Start time of the session

    // Published properties to update the UI
    @Published var steps: Int = 0
    @Published var distance: Double = 0.0
    @Published var maxAcceleration: Double = 0.0
    @Published var sessionDuration: TimeInterval = 0.0
    @Published var isTracking = false

    /// Starts tracking steps and acceleration
    func startTracking() {
        // Ensure both pedometer and accelerometer are available
        guard CMPedometer.isStepCountingAvailable(), motionManager.isAccelerometerAvailable else { return }

        isTracking = true
        startTime = Date()
        maxAcceleration = 0.0

        // Start pedometer updates
        pedometer.startUpdates(from: Date()) { data, error in
            DispatchQueue.main.async {
                if let data = data {
                    self.steps = data.numberOfSteps.intValue
                    self.distance = data.distance?.doubleValue ?? 0.0
                }
            }
        }

        // Configure and start accelerometer updates
        motionManager.accelerometerUpdateInterval = 0.1
        motionManager.startAccelerometerUpdates()

        // Poll accelerometer data periodically
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            if let data = self.motionManager.accelerometerData {
                // Calculate acceleration magnitude
                let magnitude = sqrt(pow(data.acceleration.x, 2) +
                                     pow(data.acceleration.y, 2) +
                                     pow(data.acceleration.z, 2))
                // Update max acceleration and trigger haptic feedback
                if magnitude > self.maxAcceleration {
                    self.maxAcceleration = magnitude
                    WKInterfaceDevice.current().play(.click) // Haptic feedback
                }
            }
            // Update session duration
            if let start = self.startTime {
                self.sessionDuration = Date().timeIntervalSince(start)
            }
        }
    }

    /// Stops tracking and resets state
    func stopTracking() {
        pedometer.stopUpdates()
        motionManager.stopAccelerometerUpdates()
        timer?.invalidate()
        timer = nil
        isTracking = false
    }
}

// MARK: - View
/// Main view displaying pedometer and motion data
struct PedometerView: View {
    @StateObject var manager = MotionPedometerManager()

    var body: some View {
        VStack(spacing: 20) {
            Text("Step Tracker")
                .font(.title2)
                .bold()

            // Display step count
            Text("Steps: \(manager.steps)")
            // Display distance walked
            Text(String(format: "Distance: %.2f meters", manager.distance))
            // Display maximum acceleration detected
            Text(String(format: "Max Acceleration: %.2f g", manager.maxAcceleration))
            // Display session duration
            Text(String(format: "Duration: %.0f seconds", manager.sessionDuration))

            // Start/Stop tracking button
            Button(manager.isTracking ? "Stop Tracking" : "Start Tracking") {
                manager.isTracking ? manager.stopTracking() : manager.startTracking()
            }
            .padding()
            .background(manager.isTracking ? Color.red : Color.green)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
    }
}

// MARK: - Preview
/// Preview with mock data for UI testing
struct PedometerView_Previews: PreviewProvider {
    static var previews: some View {
        let mockManager = MotionPedometerManager()
        mockManager.steps = 1234
        mockManager.distance = 567.8
        mockManager.maxAcceleration = 2.3
        mockManager.sessionDuration = 120
        return PedometerView(manager: mockManager)
    }
}

// MARK: - App Entry Point
/// Main app entry point
@main
struct PedometerApp: App {
    var body: some Scene {
        WindowGroup {
            PedometerView()
        }
    }
}