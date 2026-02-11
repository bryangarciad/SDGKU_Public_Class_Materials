import Foundation
import Combine
import CoreMotion
import WatchKit

class MotionManager: ObservableObject {
    // MARK: - Published Properties
    
    private let motionManager = CMMotionManager()
    
    @Published var x: Double = 0.0
    @Published var y: Double = 0.0
    @Published var z: Double = 0.0
    
    @Published var isRunning: Bool = false
    
    @Published var shakeCount = 0;
    @Published var shakeDetected = false;
    
    // Threshold for shake detection (value above this is count as a shake)
    private let shakeThreshold: Double = 2.0
    private var lastShakeTime: Date = Date.distantPast
    private let shakeCooldown: TimeInterval = 0.5
    
    // MARK: - Computed Properties
    var isAcceloremeterAvailable: Bool {
        motionManager.isAccelerometerAvailable
    }
    
    var magnitude: Double {
        sqrt(x * x + y * y + z * z)
    }
    
    // MARK: - Initialization
    init() {
        motionManager.accelerometerUpdateInterval = 0.1 // 10hz  = 10 readings each second
    }
    
    // MARK: - Public Methods
    func startUpdates() {
        guard isAcceloremeterAvailable else {
            return
        }
        
        guard !isRunning else { return }
        
        motionManager.startAccelerometerUpdates(to: .main) { [weak self] data, error in
            guard let self = self, let data = data, error == nil else { return }
            
            self.x = data.acceleration.x
            self.y = data.acceleration.y
            self.z = data.acceleration.z
        }
        
        isRunning = true
    }
    
    func stopUpdates() {
        motionManager.stopAccelerometerUpdates()
        isRunning = false
    }
    
    func detectShake() {
        let now = Date()
        
        guard now.timeIntervalSince(lastShakeTime) > shakeCooldown else { return }
        
        if magnitude > shakeThreshold {
            shakeCount += 1
            lastShakeTime = now
            
            shakeDetected = true
            WKInterfaceDevice.current().play(.notification)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.shakeDetected = false
            }
        }
    }
    
}
