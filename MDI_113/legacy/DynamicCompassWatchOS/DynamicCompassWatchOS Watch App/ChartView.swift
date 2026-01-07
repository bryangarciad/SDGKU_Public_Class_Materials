import SwiftUI
import Charts

struct ChartView: View {
    @ObservedObject var logger: DataLogger
    
    var body: some View {
        Chart {
            ForEach(logger.tiltData, id: \ .time) { entry in
                LineMark(
                    x: .value("Time", entry.time),
                    y: .value("Pitch", entry.pitch)
                )
            }
        }
        .frame(height: 150)
        .padding()
    }
}