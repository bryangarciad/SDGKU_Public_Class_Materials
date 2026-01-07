//
//  PowerModeSelectorView.swift
//  BatteryManagementAndPerformance Watch App
//
//  Created for MDI 112 - Class 4
//

import SwiftUI

/// View for selecting power mode
struct PowerModeSelectorView: View {
    @Binding var selectedMode: PowerMode
    let onModeChange: (PowerMode) -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            Text("Power Mode")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            HStack(spacing: 8) {
                ForEach(PowerMode.allCases) { mode in
                    PowerModeButton(
                        mode: mode,
                        isSelected: selectedMode == mode,
                        onTap: {
                            selectedMode = mode
                            onModeChange(mode)
                        }
                    )
                }
            }
        }
    }
}

/// Individual power mode button
struct PowerModeButton: View {
    let mode: PowerMode
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                Image(systemName: mode.icon)
                    .font(.system(size: 16))
                Text(mode.rawValue)
                    .font(.system(size: 9))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(isSelected ? mode.color.opacity(0.3) : Color.gray.opacity(0.2))
            .foregroundStyle(isSelected ? mode.color : .gray)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? mode.color : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

/// Detailed mode info card
struct PowerModeInfoCard: View {
    let mode: PowerMode
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: mode.icon)
                    .font(.title3)
                    .foregroundStyle(mode.color)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(mode.rawValue)
                        .font(.headline)
                        .foregroundStyle(mode.color)
                    Text(mode.description)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            
            Divider()
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Update Rate")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text("\(mode.updatesPerSecond) Hz")
                        .font(.caption)
                        .fontWeight(.semibold)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("Battery Est.")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text(mode.batteryLifeEstimate)
                        .font(.caption)
                        .fontWeight(.semibold)
                }
            }
        }
        .padding()
        .background(mode.color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(mode.color.opacity(0.3), lineWidth: 1)
        )
    }
}

#Preview {
    VStack(spacing: 20) {
        PowerModeSelectorView(
            selectedMode: .constant(.balanced),
            onModeChange: { _ in }
        )
        
        PowerModeInfoCard(mode: .balanced)
    }
    .padding()
}

