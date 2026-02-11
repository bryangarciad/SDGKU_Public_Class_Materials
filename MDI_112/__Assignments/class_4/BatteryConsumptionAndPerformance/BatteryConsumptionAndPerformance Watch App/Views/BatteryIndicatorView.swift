import SwiftUI

struct BatteryIndicatorView: View {
    let level: Double
    let mode: PowerMode
    
    private var batteryColor: Color {
        if level > 50 {
            return .green
        } else {
            return .yellow
        }
    }
    
    private var batteryIcon: String {
        if level > 75 {
            return "battery.100"
        } else if level > 50 {
            return "battery.75"
        } else if level > 25 {
            return "battery.50"
        } else {
            return "battery.0"
        }
    }
    
    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: batteryIcon)
                    .font(.title2)
                    .foregroundStyle(batteryColor)
                
                Text("\(Int(level))%")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(batteryColor)
                    .monospacedDigit()
            }
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
            
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.gray.opacity(0.3))
                    
                    RoundedRectangle(cornerRadius: 6)
                        .fill(batteryColor)
                        .frame(width: geo.size.width * (level / 100))
                        
                }
            }.frame(height: 12)
            
            Text("Est. life \(mode.batteryLifeEstimate)")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}
