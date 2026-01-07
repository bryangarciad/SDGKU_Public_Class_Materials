import Foundation
import HealthKit

class HealthKitManager {
    let healthStore = HKHealthStore()
    
    let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
    let heartRateUnit = HKUnit(from: "count/min")
    
    static let shared = HealthKitManager()
    private init() {}
    
    func requestAuthorization() async throws {
        let typeToRead: Set<HKObjectType> = [heartRateType]
        let typesToWrite: Set<HKSampleType> = []
        
        try await healthStore.requestAuthorization(
            toShare: typesToWrite,
            read: typeToRead
        )
    }
    
    func checkAuthorizationStatus() -> HKAuthorizationStatus {
        return healthStore.authorizationStatus(for: heartRateType)
    }
    
    // MARK: - Fetch Data
    func fetchLatestHeartRate() async throws -> HeartRateSample? {
        return try await withCheckedThrowingContinuation {
            continuation in
            
            let sortDescription = NSSortDescriptor(
                key: HKSampleSortIdentifierStartDate,
                ascending: false
            )
            
            let query = HKSampleQuery(
                sampleType: heartRateType,
                predicate: nil,
                limit: 1,
                sortDescriptors: [sortDescription]
            ) { _, samples, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let sample = samples?.first as? HKQuantitySample else {
                    continuation.resume(returning: nil)
                    return
                }
                
                let bpm = sample.quantity.doubleValue(for: self.heartRateUnit)
                
                let heartRateSample = HeartRateSample(
                    bpm: bpm,
                    timestamp: sample.startDate
                )
            }
            
            healthStore.execute(query)
        }
    }
    
    func fetchRecentHearthRates(hours: Int = 1) async throws -> [HeartRateSample] {
        return try await withCheckedThrowingContinuation {
            continuation in
            
            let startDate = Calendar.current.date(
                byAdding: .hour,
                value: -hours,
                to: Date()
            )!
            
            let predicate = HKQuery.predicateForSamples(
                withStart: startDate,
                end: Date(),
                options: .strictStartDate
            )
            
            let sortDescription = NSSortDescriptor(
                key: HKSampleSortIdentifierStartDate,
                ascending: false
            )
            
            let query = HKSampleQuery(
                sampleType: heartRateType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [sortDescription]
            ) { _, samples, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                let heartRateSamples = (samples as? [HKQuantitySample])?.map { sample in
                    HeartRateSample(
                        bpm: sample.quantity.doubleValue(for: self.heartRateUnit),
                        timestamp: sample.startDate
                    )
                } ?? []
                
                continuation.resume(returning: heartRateSamples)
            }
            
            healthStore.execute(query)
        }
    }
    
    // MARK: - Monitoring Functions
    func startHRMonitoring(onUpdate: @escaping ([HeartRateSample]) -> Void) {
        let query = HKAnchoredObjectQuery(
            type: heartRateType,
            predicate: nil,
            anchor: nil,
            limit: HKObjectQueryNoLimit
        ) { [weak self] query, samples, deletedObjects, anchor, error in
            guard let self = self else { return }
            self.processHeartRateSamples(
                samples,
                onUpdate: onUpdate
            )
        }
        
        healthStore.execute(query)
    }
    
    func processHeartRateSamples(
        _ samples: [HKSample]?,
        onUpdate: @escaping ([HeartRateSample]) -> Void
    ) {
        guard let quantitySamples = samples as? [HKQuantitySample], !quantitySamples.isEmpty else { return }
        
        let heartRateSamples = quantitySamples.map { sample in
            HeartRateSample(
                bpm: sample.quantity.doubleValue(for: self.heartRateUnit),
                timestamp: sample.startDate
            )
        }
        
        DispatchQueue.main.async {
            onUpdate(heartRateSamples)
        }
    }
}
