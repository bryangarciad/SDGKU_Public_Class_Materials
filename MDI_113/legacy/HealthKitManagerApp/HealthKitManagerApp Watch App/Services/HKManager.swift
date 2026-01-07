import Foundation
import Combine
import HealthKit

class HKManager: ObservableObject {
    private let healthStore = HKHealthStore()
    
    @Published var heartRate: [HKQuantitySample] = []
    
    init() {
        requestHKAuthorization()
    }
    
    private func requestHKAuthorization() {
        let typesToShare: Set = [
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!
        ]
        
        let typesToRead: Set  = [
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!
        ]
        
        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { success, error in
            if success {
                self.startTrackingHKData()
            }
        }
    }
    
    func startTrackingHKData() {
        guard let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate) else { return }
        
        let startDate = Calendar.current.startOfDay(for: Date())
        
        let timePredicate = HKQuery.predicateForSamples(withStart: startDate, end: Date())
        
        let query = HKSampleQuery(
            sampleType: heartRateType,
            predicate: timePredicate,
            limit: 100,
            sortDescriptors: [
                NSSortDescriptor(key: "startDate", ascending: true)
            ]
        ) { _, sample, _ in
            DispatchQueue.main.async {
                self.heartRate = (sample as? [HKQuantitySample]) ?? []
            }
        }
        
        healthStore.execute(query)
    }
    
    func addHeartRate(_ bpm: Double) { // int (198) bpm beat or value / minutes
        guard let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate) else { return }
        
        let hkQuantity = HKQuantity(
            unit: HKUnit.count().unitDivided(by: .minute()),
            doubleValue: bpm
        )
        
        let now = Date()
        
        let sample = HKQuantitySample(
            type: heartRateType,
            quantity: hkQuantity,
            start: now,
            end: now
        )
        
        healthStore.save(sample) { succes, _ in
            if succes {
                self.startTrackingHKData()
            }
        }
            
    }
}
