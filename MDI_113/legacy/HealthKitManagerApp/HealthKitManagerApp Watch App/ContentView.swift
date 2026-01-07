import SwiftUI
import HealthKit
import Charts

struct ContentView: View {
    @State private var hrValue: Double  = 80.0
    @StateObject private var hkManager = HKManager()
    
    var body: some View {
        VStack (spacing: 12) {
                Text("Heart Rate")
                    .font(.headline)
                Chart(hkManager.heartRate, id: \.startDate) {
                    LineMark(
                        x: .value("Time", $0.startDate),
                        y: .value("Rate", $0.quantity.doubleValue(
                            for: HKUnit.count().unitDivided(by: HKUnit.minute())
                        ))
                    )
                    .foregroundStyle(.red)
                }
            
            Text("Heart Rate: \(Int(hrValue)) BPM")
                .focusable()
                .digitalCrownRotation(
                    $hrValue,
                    from: 40,
                    through: 200,
                    by: 1,
                    sensitivity: .medium,
                    isHapticFeedbackEnabled: true
                )
            Button("Add Heart Rate") {
                hkManager.addHeartRate(hrValue)
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
