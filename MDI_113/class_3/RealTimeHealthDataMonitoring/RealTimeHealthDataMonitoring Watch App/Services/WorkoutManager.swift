//
//  WorkoutManager.swift
//  RealTimeHealthDataMonitoring Watch App
//
//  Created for MDI 113 - Class 3
//  Simplified version using HKAnchoredObjectQuery (no workout session)
//

import Foundation
import HealthKit
import WatchKit

/// Simple health data manager - monitors heart rate without workout session
class WorkoutManager: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var heartRate: Double = 0
    @Published var calories: Double = 0
    @Published var distance: Double = 0
    @Published var elapsedTime: TimeInterval = 0
    
    @Published var isWorkoutActive = false
    @Published var isAuthorized = false
    @Published var errorMessage: String?
    
    // Goals
    let calorieGoal: Double = 300
    let distanceGoal: Double = 3000
    
    // MARK: - Private Properties
    
    private var healthStore: HKHealthStore?
    private var heartRateQuery: HKAnchoredObjectQuery?
    private var timer: Timer?
    private var startTime: Date?
    
    // MARK: - Computed Properties
    
    var formattedTime: String {
        let minutes = Int(elapsedTime) / 60
        let seconds = Int(elapsedTime) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var distanceInKm: Double {
        distance / 1000
    }
    
    // MARK: - Initialization
    
    init() {
        if HKHealthStore.isHealthDataAvailable() {
            healthStore = HKHealthStore()
        }
    }
    
    // MARK: - Authorization
    
    func requestAuthorization() async {
        guard let healthStore = healthStore else {
            await MainActor.run {
                errorMessage = "HealthKit not available"
            }
            return
        }
        
        let typesToRead: Set<HKObjectType> = [
            HKQuantityType(.heartRate)
        ]
        
        do {
            try await healthStore.requestAuthorization(toShare: [], read: typesToRead)
            await MainActor.run {
                isAuthorized = true
            }
        } catch {
            await MainActor.run {
                errorMessage = "Authorization failed"
            }
        }
    }
    
    // MARK: - Workout Control
    
    func startWorkout() {
        startTime = Date()
        isWorkoutActive = true
        
        startHeartRateQuery()
        startTimer()
        
        WKInterfaceDevice.current().play(.start)
    }
    
    func endWorkout() {
        stopHeartRateQuery()
        stopTimer()
        
        isWorkoutActive = false
        WKInterfaceDevice.current().play(.stop)
    }
    
    // MARK: - Heart Rate Query
    
    private func startHeartRateQuery() {
        guard let healthStore = healthStore else { return }
        
        let heartRateType = HKQuantityType(.heartRate)
        let predicate = HKQuery.predicateForSamples(
            withStart: Date(),
            end: nil,
            options: .strictStartDate
        )
        
        heartRateQuery = HKAnchoredObjectQuery(
            type: heartRateType,
            predicate: predicate,
            anchor: nil,
            limit: HKObjectQueryNoLimit
        ) { [weak self] query, samples, deletedObjects, anchor, error in
            self?.processHeartRateSamples(samples)
        }
        
        heartRateQuery?.updateHandler = { [weak self] query, samples, deletedObjects, anchor, error in
            self?.processHeartRateSamples(samples)
        }
        
        if let query = heartRateQuery {
            healthStore.execute(query)
        }
    }
    
    private func stopHeartRateQuery() {
        if let query = heartRateQuery, let healthStore = healthStore {
            healthStore.stop(query)
        }
        heartRateQuery = nil
    }
    
    private func processHeartRateSamples(_ samples: [HKSample]?) {
        guard let samples = samples as? [HKQuantitySample],
              let mostRecent = samples.last else { return }
        
        let unit = HKUnit.count().unitDivided(by: .minute())
        let value = mostRecent.quantity.doubleValue(for: unit)
        
        DispatchQueue.main.async {
            self.heartRate = value
            
            // Simulate calories based on heart rate (simplified formula)
            // Real apps would use HKWorkoutSession for accurate data
            if self.isWorkoutActive {
                let caloriesPerSecond = (value / 100.0) * 0.05
                self.calories += caloriesPerSecond
            }
        }
    }
    
    // MARK: - Timer
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.elapsedTime += 1
                
                // Simulate distance (demo purposes)
                // Real apps would use HKWorkoutSession
                if self.heartRate > 80 {
                    self.distance += Double.random(in: 1...3)
                }
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}
