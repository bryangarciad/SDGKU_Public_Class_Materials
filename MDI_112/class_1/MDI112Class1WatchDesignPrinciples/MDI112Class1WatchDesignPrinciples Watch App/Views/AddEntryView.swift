//
//  AddEntryView.swift
//  MDI112Class1WatchDesignPrinciples Watch App
//
//  Demonstrates: Data entry for wearables
//  Design Principle: Simple input, quick interactions
//

import SwiftUI

/// View for adding calories or water entries
/// Design Principle: No big swipes or complex interactions required
struct AddEntryView: View {
    
    // MARK: - Properties
    @ObservedObject var viewModel: HealthViewModel
    let entryType: EntryType
    
    @State private var selectedAmount: Double = 0
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Quick Add Options
    /// Design Principle: Pre-defined options reduce input effort
    private var quickAddOptions: [Double] {
        switch entryType {
        case .calories:
            return [100, 200, 300, 500]
        case .water:
            return [100, 200, 250, 500]
        }
    }
    
    // MARK: - Body
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Header with icon
                // Design Principle: Clear visual context
                Image(systemName: entryType.icon)
                    .font(.system(size: 28))
                    .foregroundColor(entryType == .calories ? .orange : .cyan)
                
                Text("Add \(entryType == .calories ? "Calories" : "Water")")
                    .font(.system(size: 14, weight: .medium))
                
                // Current selection display
                // Design Principle: Clear feedback on current state
                Text("\(Int(selectedAmount)) \(entryType.unit)")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(entryType == .calories ? .orange : .cyan)
                
                // Quick add buttons grid
                // Design Principle: One-tap interactions for speed
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 10) {
                    ForEach(quickAddOptions, id: \.self) { amount in
                        Button {
                            viewModel.playClickHaptic()
                            selectedAmount = amount
                        } label: {
                            Text("+\(Int(amount))")
                                .font(.system(size: 14, weight: .semibold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(
                                    selectedAmount == amount
                                        ? (entryType == .calories ? Color.orange : Color.cyan)
                                        : Color.gray.opacity(0.3)
                                )
                                .foregroundColor(
                                    selectedAmount == amount ? .black : .white
                                )
                                .cornerRadius(10)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                
                // Custom amount with stepper
                // Design Principle: Fine control when needed
                HStack {
                    Button {
                        viewModel.playClickHaptic()
                        selectedAmount = max(0, selectedAmount - 50)
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.gray)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Spacer()
                    
                    Text("Adjust")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    Button {
                        viewModel.playClickHaptic()
                        selectedAmount += 50
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.gray)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal, 8)
                
                // Add button
                // Design Principle: Clear primary action
                Button {
                    if selectedAmount > 0 {
                        if entryType == .calories {
                            viewModel.addCalories(selectedAmount)
                        } else {
                            viewModel.addWater(selectedAmount)
                        }
                        dismiss()
                    }
                } label: {
                    Text("Add")
                        .font(.system(size: 16, weight: .bold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            selectedAmount > 0
                                ? (entryType == .calories ? Color.orange : Color.cyan)
                                : Color.gray.opacity(0.3)
                        )
                        .foregroundColor(selectedAmount > 0 ? .black : .gray)
                        .cornerRadius(12)
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(selectedAmount == 0)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 8)
        }
        .navigationTitle(entryType == .calories ? "Calories" : "Water")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        AddEntryView(viewModel: HealthViewModel(), entryType: .calories)
    }
}

