//
//  GoalsSettingsView.swift
//  MDI112Class1WatchDesignPrinciples Watch App
//
//  Demonstrates: Settings/preferences for wearables
//  Design Principle: Personalization adds value
//

import SwiftUI

/// View for setting daily goals
/// Design Principle: Simple configuration with sensible defaults
struct GoalsSettingsView: View {
    
    // MARK: - Properties
    @ObservedObject var viewModel: HealthViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var caloriesGoal: Double
    @State private var waterGoal: Double
    
    // MARK: - Preset Options
    /// Design Principle: Quick selection reduces effort
    private let caloriesPresets: [Double] = [1500, 2000, 2500, 3000]
    private let waterPresets: [Double] = [1500, 2000, 2500, 3000]
    
    // MARK: - Initialization
    init(viewModel: HealthViewModel) {
        self.viewModel = viewModel
        _caloriesGoal = State(initialValue: viewModel.goals.dailyCaloriesGoal)
        _waterGoal = State(initialValue: viewModel.goals.dailyWaterGoal)
    }
    
    // MARK: - Body
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Calories Goal Section
                VStack(spacing: 10) {
                    HStack {
                        Image(systemName: "flame.fill")
                            .foregroundColor(.orange)
                        Text("Calories Goal")
                            .font(.system(size: 13, weight: .medium))
                        Spacer()
                    }
                    
                    Text("\(Int(caloriesGoal)) kcal")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.orange)
                    
                    // Preset buttons
                    // Design Principle: One-tap selections
                    HStack(spacing: 6) {
                        ForEach(caloriesPresets, id: \.self) { preset in
                            Button {
                                viewModel.playClickHaptic()
                                caloriesGoal = preset
                            } label: {
                                Text("\(Int(preset/1000))k")
                                    .font(.system(size: 11, weight: .medium))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 6)
                                    .background(
                                        caloriesGoal == preset
                                            ? Color.orange
                                            : Color.orange.opacity(0.2)
                                    )
                                    .foregroundColor(caloriesGoal == preset ? .black : .orange)
                                    .cornerRadius(8)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                
                Divider()
                    .background(Color.gray.opacity(0.3))
                
                // Water Goal Section
                VStack(spacing: 10) {
                    HStack {
                        Image(systemName: "drop.fill")
                            .foregroundColor(.cyan)
                        Text("Water Goal")
                            .font(.system(size: 13, weight: .medium))
                        Spacer()
                    }
                    
                    Text("\(Int(waterGoal)) ml")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.cyan)
                    
                    // Preset buttons
                    HStack(spacing: 6) {
                        ForEach(waterPresets, id: \.self) { preset in
                            Button {
                                viewModel.playClickHaptic()
                                waterGoal = preset
                            } label: {
                                Text("\(Int(preset/1000))L")
                                    .font(.system(size: 11, weight: .medium))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 6)
                                    .background(
                                        waterGoal == preset
                                            ? Color.cyan
                                            : Color.cyan.opacity(0.2)
                                    )
                                    .foregroundColor(waterGoal == preset ? .black : .cyan)
                                    .cornerRadius(8)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                
                // Save Button
                Button {
                    viewModel.updateGoals(calories: caloriesGoal, water: waterGoal)
                    dismiss()
                } label: {
                    Text("Save Goals")
                        .font(.system(size: 14, weight: .bold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.green)
                        .foregroundColor(.black)
                        .cornerRadius(12)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.top, 8)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 8)
        }
        .navigationTitle("Goals")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        GoalsSettingsView(viewModel: HealthViewModel())
    }
}

