//
//  HealthViewModel.swift
//  MDI112Class1WatchDesignPrinciples Watch App
//
//  Demonstrates: MVVM architecture for WatchOS
//  Design Principle: Separation of concerns for maintainable code
//

import SwiftUI

/// Main ViewModel for the Health Tracker
/// Design Principle: Single source of truth for UI state
@MainActor
class HealthViewModel: ObservableObject {
    
    // MARK: - Published Properties (UI State)
    
    /// User's goals
    @Published var goals: UserGoals
    
    /// Today's calories consumed
    @Published var todayCalories: Double = 0
    
    /// Today's water consumed (ml)
    @Published var todayWater: Double = 0
    
    /// Current motivational quote
    @Published var currentQuote: MotivationalQuote?
    
    /// Loading state for quote
    @Published var isLoadingQuote: Bool = false
    
    /// Show quote overlay
    @Published var showQuoteOverlay: Bool = false
    
    // MARK: - Services
    private let storage = StorageManager.shared
    private let quoteService = MotivationalQuoteService.shared
    private let haptics = HapticManager.shared
    
    // MARK: - Computed Properties
    
    /// Calories progress (0.0 to 1.0)
    var caloriesProgress: Double {
        min(todayCalories / goals.dailyCaloriesGoal, 1.0)
    }
    
    /// Water progress (0.0 to 1.0)
    var waterProgress: Double {
        min(todayWater / goals.dailyWaterGoal, 1.0)
    }
    
    /// Check if calories goal is met
    var caloriesGoalMet: Bool {
        todayCalories >= goals.dailyCaloriesGoal
    }
    
    /// Check if water goal is met
    var waterGoalMet: Bool {
        todayWater >= goals.dailyWaterGoal
    }
    
    // MARK: - Initialization
    
    init() {
        self.goals = StorageManager.shared.loadGoals()
        refreshTodayData()
    }
    
    // MARK: - Public Methods
    
    /// Refresh today's totals from storage
    func refreshTodayData() {
        todayCalories = storage.getTodayTotal(for: .calories)
        todayWater = storage.getTodayTotal(for: .water)
    }
    
    /// Add calories entry
    /// - Parameter amount: Calories to add
    func addCalories(_ amount: Double) {
        let entry = DiaryEntry(type: .calories, value: amount)
        storage.addEntry(entry)
        
        // Update UI
        todayCalories += amount
        
        // Haptic feedback
        haptics.playDirectionUp()
        
        // Check for goal achievement
        if caloriesGoalMet {
            haptics.playNotification()
        }
        
        // Fetch motivational quote
        fetchQuoteAfterEntry()
    }
    
    /// Add water entry
    /// - Parameter amount: Water in ml to add
    func addWater(_ amount: Double) {
        let entry = DiaryEntry(type: .water, value: amount)
        storage.addEntry(entry)
        
        // Update UI
        todayWater += amount
        
        // Haptic feedback
        haptics.playDirectionUp()
        
        // Check for goal achievement
        if waterGoalMet {
            haptics.playNotification()
        }
        
        // Fetch motivational quote
        fetchQuoteAfterEntry()
    }
    
    /// Update user goals
    func updateGoals(calories: Double, water: Double) {
        goals = UserGoals(dailyCaloriesGoal: calories, dailyWaterGoal: water)
        storage.saveGoals(goals)
        haptics.playSuccess()
    }
    
    /// Fetch a new motivational quote
    func fetchQuoteAfterEntry() {
        isLoadingQuote = true
        showQuoteOverlay = true
        
        Task {
            currentQuote = await quoteService.fetchQuote()
            isLoadingQuote = false
            
            // Auto-dismiss after 3 seconds
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            showQuoteOverlay = false
        }
    }
    
    /// Play a click haptic for button taps
    func playClickHaptic() {
        haptics.playClick()
    }
}
