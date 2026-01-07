//
//  PowerAwareMotionManager.swift
//  BatteryManagementAndPerformance Watch App
//
//  Created for MDI 112 - Class 4
//

import Foundation
import CoreMotion
import WatchKit

/// A motion manager that demonstrates power-aware update intervals
class PowerAwareMotionManager: ObservableObject {
    
    // MARK: - Published Properties
    
    /// Current accelerometer X value
    @Published var x: Double = 0
    
    /// Current accelerometer Y value
    @Published var y: Double = 0
    
    /// Current accelerometer Z value
    @Published var z: Double = 0
    
    /// Currently selected power mode
    @Published var currentMode: PowerMode = .balanced {
        didSet {
            if isRunning {
                // Restart with new interval when mode changes
                restartWithNewInterval()
            }
        }
    }
    
    /// Whether motion updates are running
    @Published var isRunning: Bool = false
    
    /// Total number of updates received (to demonstrate frequency difference)
    @Published var updateCount: Int = 0
    
    /// Simulated battery level (for demonstration)
    @Published var simulatedBattery: Double = 100.0
    
    // MARK: - Private Properties
    
    private let motionManager = CMMotionManager()
    private var batteryDrainTimer: Timer?
    
    // MARK: - Computed Properties
    
    /// Whether accelerometer is available
    var isAvailable: Bool {
        motionManager.isAccelerometerAvailable
    }
    
    /// Current update interval
    var currentInterval: TimeInterval {
        currentMode.updateInterval
    }
    
    // MARK: - Public Methods
    
    /// Start motion updates with current mode's interval
    func start() {
        guard isAvailable else {
            print("Accelerometer not available")
            return
        }
        
        guard !isRunning else { return }
        
        // Reset counters
        updateCount = 0
        
        // Set interval based on current mode
        motionManager.accelerometerUpdateInterval = currentMode.updateInterval
        
        // Start accelerometer updates
        motionManager.startAccelerometerUpdates(to: .main) { [weak self] data, error in
            guard let self = self, let data = data, error == nil else { return }
            
            self.x = data.acceleration.x
            self.y = data.acceleration.y
            self.z = data.acceleration.z
            self.updateCount += 1
        }
        
        // Start battery drain simulation
        startBatterySimulation()
        
        isRunning = true
        playHaptic(.start)
    }
    
    /// Stop motion updates (saves battery!)
    func stop() {
        motionManager.stopAccelerometerUpdates()
        stopBatterySimulation()
        isRunning = false
        playHaptic(.stop)
    }
    
    /// Switch to a different power mode
    func switchMode(to mode: PowerMode) {
        guard mode != currentMode else { return }
        currentMode = mode
        playHaptic(.click)
    }
    
    /// Reset the demo (battery and counter)
    func reset() {
        updateCount = 0
        simulatedBattery = 100.0
        playHaptic(.click)
    }
    
    // MARK: - Private Methods
    
    /// Restart updates with new interval (when mode changes)
    private func restartWithNewInterval() {
        motionManager.stopAccelerometerUpdates()
        motionManager.accelerometerUpdateInterval = currentMode.updateInterval
        
        motionManager.startAccelerometerUpdates(to: .main) { [weak self] data, error in
            guard let self = self, let data = data, error == nil else { return }
            
            self.x = data.acceleration.x
            self.y = data.acceleration.y
            self.z = data.acceleration.z
            self.updateCount += 1
        }
        
        // Restart battery simulation with new drain rate
        stopBatterySimulation()
        startBatterySimulation()
    }
    
    /// Start simulated battery drain based on mode
    private func startBatterySimulation() {
        // Drain rate: eco = slow, performance = fast
        let drainPerSecond = 0.1 * currentMode.batteryDrainMultiplier
        
        batteryDrainTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            self.simulatedBattery = max(0, self.simulatedBattery - drainPerSecond)
            
            // Warning haptic at low battery
            if self.simulatedBattery == 20 || self.simulatedBattery == 10 {
                self.playHaptic(.notification)
            }
        }
    }
    
    /// Stop battery simulation
    private func stopBatterySimulation() {
        batteryDrainTimer?.invalidate()
        batteryDrainTimer = nil
    }
    
    /// Play haptic feedback
    private func playHaptic(_ type: WKHapticType) {
        WKInterfaceDevice.current().play(type)
    }
}

