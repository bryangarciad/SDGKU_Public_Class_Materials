//
//  ContentView.swift
//  MDI112Class1WatchDesignPrinciples Watch App
//
//  Main entry point view for the Health Tracker app
//  Demonstrates WatchOS design principles for wearables
//

import SwiftUI

/// Main content view - Navigation container
/// Design Principle: Simple navigation hierarchy
struct ContentView: View {
    
    // MARK: - State
    /// Shared ViewModel across all views
    @StateObject private var viewModel = HealthViewModel()
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            MainDashboardView(viewModel: viewModel)
        }
        .onAppear {
            // Refresh data when app becomes visible
            viewModel.refreshTodayData()
        }
    }
}

// MARK: - Preview
#Preview {
    ContentView()
}
