//
//  ContentView.swift
//  BatteryManagementAndPerformance Watch App
//
//  Created for MDI 112 - Class 4
//

import SwiftUI
/// Main view demonstrating power-efficient patterns
struct ContentView: View {
    @StateObject private var manager = PowerAwareMotionManager()
    @State private var selectedMode: PowerMode = .balanced
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some View {
        TabView {
            // Main control view
            MainControlView(manager: manager, selectedMode: $selectedMode)
            
            // Stats view
            StatsView(manager: manager)
        }
        .tabViewStyle(.verticalPage)
        // IMPORTANT: Stop updates when app goes to background (battery optimization!)
        .onChange(of: scenePhase) { _, newPhase in
            switch newPhase {
            case .active:
                // Optionally resume if was running
                break
            case .inactive, .background:
                // Stop to save battery when not visible
                if manager.isRunning {
                    manager.stop()
                }
            @unknown default:
                break
            }
        }
    }
}

/// Main control interface
struct MainControlView: View {
    @ObservedObject var manager: PowerAwareMotionManager
    @Binding var selectedMode: PowerMode
    
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                // Battery indicator
                BatteryIndicatorView(
                    level: manager.simulatedBattery,
                    mode: manager.currentMode
                )
                .padding(.horizontal)
                
                // Power mode selector
                PowerModeSelectorView(
                    selectedMode: $selectedMode,
                    onModeChange: { mode in
                        manager.switchMode(to: mode)
                    }
                )
                .padding(.horizontal)
                
                // Control buttons
                HStack(spacing: 12) {
                    // Start/Stop button
                    Button(action: {
                        if manager.isRunning {
                            manager.stop()
                        } else {
                            manager.start()
                        }
                    }) {
                        HStack {
                            Image(systemName: manager.isRunning ? "stop.fill" : "play.fill")
                            Text(manager.isRunning ? "Stop" : "Start")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(manager.isRunning ? .red : .green)
                    
                    // Reset button
                    Button(action: {
                        manager.reset()
                    }) {
                        Image(systemName: "arrow.counterclockwise")
                    }
                    .buttonStyle(.bordered)
                    .tint(.gray)
                }
                .padding(.horizontal)
                
                // Status indicator
                StatusIndicator(manager: manager)
            }
            .padding(.vertical)
        }
        .navigationTitle("Power Demo")
    }
}

/// Status indicator showing current state
struct StatusIndicator: View {
    @ObservedObject var manager: PowerAwareMotionManager
    
    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(manager.isRunning ? manager.currentMode.color : .gray)
                .frame(width: 8, height: 8)
            
            if manager.isRunning {
                Text("Running at \(manager.currentMode.updatesPerSecond) Hz")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            } else {
                Text("Stopped - Saving battery")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.gray.opacity(0.1))
        .clipShape(Capsule())
    }
}

#Preview {
    ContentView()
}
