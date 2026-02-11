import SwiftUI
import Foundation
import Combine
import CoreMotion
import WatchKit

enum PowerMode: String, CaseIterable, Identifiable {
    case eco = "Echo"
    case balanced = "Balanced"
    case performance = "Performance"
    
    var id: String { self.rawValue }
    
    // 0.1 = 10 -- 0.1 / 2 = 0.05 (10 * 2 = 20Hz)
    // 0.2 -- 0.1 * 2 = 0.2 (10 / 2 = 5)
    var updateInterval: TimeInterval {
        switch self {
        case .eco:
            return 1.0 // 1 Hz (One Data Req Per Second) - Maximum Battery Saving
        case .balanced:
            return 0.2 // 5 Hz (5 Data Req Per Second)
        case .performance:
            return 0.05 // 20 Hz
        }
    }
    
    var batteryDrainMultiplier: Double {
        switch self {
        case .eco:
            return 1.0 
        case .balanced:
            return 2.0
        case .performance:
            return 3.0
        }
    }
    
    var batteryLifeEstimate: String {
        switch self {
        case .eco:
            return "~18 hours"
        case .balanced:
            return "~9 hours"
        case .performance:
            return "~3 hours"
        }
    }
    
    
}

class PowerAwareMotionManagerService: ObservableObject {
    
    // Core Motion Data
    @Published var x: Double = 0
    @Published var y: Double = 0
    @Published var z: Double = 0
    
    @Published var currentMode: PowerMode = .balanced {
        didSet {
            if isRunning {
                restartWithNewInterval()
            }
        }
    }
    
    @Published var isRunning: Bool = false
    @Published var updateCount: Int = 0
    
    @Published var simulatedBattery: Double = 100.0
    
    private var motionManager: CMMotionManager = CMMotionManager()
    private var batteryDrainTimer: Timer?
    
    //MARK: - Computed Properties
    
    var isAvailable: Bool {
        motionManager.isAccelerometerAvailable
    }
    
    var currentInterval: TimeInterval {
        currentMode.updateInterval
    }
    
    func start() {
        guard isAvailable else {
            print("Accelerometer is not available")
            return
        }
        
        guard !isRunning else { return }
        
        // Restart update counter
        updateCount = 0
        
        motionManager.accelerometerUpdateInterval = currentMode.updateInterval
        
        // Start the accelerometer readings
        motionManager.startAccelerometerUpdates(to: .main) {
            [weak self] data, error in
            
            guard let self = self, let data = data, error == nil else { return }
            
            self.x = data.acceleration.x
            self.y = data.acceleration.y
            self.z = data.acceleration.z
            
            self.updateCount += 1
        }
        
        isRunning = true
        WKInterfaceDevice.current().play(.start)
    }
    
    func stop() {
        motionManager.stopAccelerometerUpdates()
        isRunning = false
        WKInterfaceDevice.current().play(.stop)
    }
    
    func switchMode(to mode: PowerMode) {
        guard mode != currentMode else { return }
        
        currentMode = mode
        WKInterfaceDevice.current().play(.click)
    }
    
    func reset() {
        updateCount = 0
        simulatedBattery = 100.0
        WKInterfaceDevice.current().play(.click)
    }
    
    private func restartWithNewInterval() {
        motionManager.stopAccelerometerUpdates()
        motionManager.accelerometerUpdateInterval = currentMode.updateInterval
        
        motionManager.startAccelerometerUpdates(to: .main) {
            [weak self] data, error in
            
            guard let self = self, let data = data, error == nil else { return }
            
            self.x = data.acceleration.x
            self.y = data.acceleration.y
            self.z = data.acceleration.z
            
            self.updateCount += 1
        }
    }
    
    private func startBatterySimulation() {
        let drainPerSecond = 0.1 * currentMode.batteryDrainMultiplier
        
        batteryDrainTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) {
            [weak self] _ in
            
            guard let self = self else { return }
            
            self.simulatedBattery = max(0, self.simulatedBattery - drainPerSecond)
            
            if self.simulatedBattery == 20 || self.simulatedBattery == 10 {
                WKInterfaceDevice.current().play(.notification)
            }
        }
    }
    
    private func stopBatterySimulation() {
        batteryDrainTimer?.invalidate()
        batteryDrainTimer = nil
    }
}
