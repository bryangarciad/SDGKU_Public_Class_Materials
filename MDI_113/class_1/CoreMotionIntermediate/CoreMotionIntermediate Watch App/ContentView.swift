//
//  ContentView.swift
//  CoreMotionIntermediate Watch App
//
//  Created for MDI 113 - Class 1
//

import SwiftUI

/// Main content view with tab navigation
struct ContentView: View {
    @StateObject private var manager = AdvancedMotionManager()
    @State private var selectedTab = 0
    
    var body: some View {
        VStack(spacing: 5) {
            TabView(selection: $selectedTab) {
                // Activity Classification
                ActivityView(manager: manager)
                    .tag(0)
                
                // Motion Dashboard
                MotionDashboardView(manager: manager)
                    .tag(1)
                
                // Activity History
                ActivityHistoryView(manager: manager)
                    .tag(2)
            }
            .tabViewStyle(.verticalPage)
            
            // Start/Stop Button
            ControlButton(manager: manager)
                .padding(.horizontal)
        }
        .onDisappear {
            manager.stop()
        }
    }
}

/// Start/Stop control button
struct ControlButton: View {
    @ObservedObject var manager: AdvancedMotionManager
    
    var body: some View {
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
            .font(.caption)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .tint(manager.isRunning ? .red : .green)
    }
}

#Preview {
    ContentView()
}
