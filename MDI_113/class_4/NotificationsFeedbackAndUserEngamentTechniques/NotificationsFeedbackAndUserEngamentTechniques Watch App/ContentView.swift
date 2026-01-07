//
//  ContentView.swift
//  NotificationsFeedbackAndUserEngamentTechniques Watch App
//
//  Created for MDI 113 - Class 4
//

import SwiftUI

/// Main content view with tab navigation
struct ContentView: View {
    @StateObject private var manager = ActivityCoachManager()
    
    var body: some View {
        TabView {
            // Dashboard
            CoachDashboardView(manager: manager)
                .tag(0)
            
            // Settings
            SettingsView(manager: manager)
                .tag(1)
        }
        .tabViewStyle(.verticalPage)
        .task {
            await manager.requestPermissions()
        }
        .onDisappear {
            manager.stopMonitoring()
        }
    }
}

#Preview {
    ContentView()
}
