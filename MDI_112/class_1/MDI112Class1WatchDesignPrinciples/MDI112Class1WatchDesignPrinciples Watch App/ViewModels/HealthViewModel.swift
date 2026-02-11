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
    
    // MARK: - Heart Rate Properties
    
    /// Current heart rate in BPM
    @Published var currentHeartRate: Double = 0
    
    /// Current heart rate zone
    @Published var currentZone: HeartRateZone = .rest
    
    /// Whether we're currently monitoring heart rate
    @Published var isMonitoringHeartRate: Bool = false
    
    /// Whether HealthKit authorization was granted
    @Published var isHealthKitAuthorized: Bool = false
    
    /// Whether HealthKit is available on this device
    @Published var isHealthKitAvailable: Bool = false
    
    /// Heart rate error message
    @Published var heartRateError: String?
    
    /// Last heart rate update timestamp
    @Published var lastHeartRateUpdate: Date?
    
    /// User's max heart rate (220 - age, default ~30 years old)
    @Published var maxHeartRate: Double = 190
    
    // MARK: - Services
    private let storage = StorageManager.shared
    private let quoteService = MotivationalQuoteService.shared
    private let haptics = HapticManager.shared
    private let healthKit = HealthKitManager.shared
    
    /// Previous heart rate zone for tracking zone changes
    private var previousZone: HeartRateZone?
    
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
    
    /// Formatted heart rate as string
    var formattedHeartRate: String {
        "\(Int(currentHeartRate))"
    }
    
    // MARK: - Initialization
    
    init() {
        self.goals = StorageManager.shared.loadGoals()
        self.isHealthKitAvailable = healthKit.isHealthKitAvailable
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
    
    // MARK: - Heart Rate Methods
    
    /// Request HealthKit authorization
    func requestHealthKitAuthorization() async {
        guard isHealthKitAvailable else {
            heartRateError = "HealthKit is not available"
            return
        }
        
        do {
            try await healthKit.requestAuthorization()
            isHealthKitAuthorized = true
            haptics.playSuccess()
        } catch {
            heartRateError = "Authorization failed: \(error.localizedDescription)"
            isHealthKitAuthorized = false
        }
    }
    
    /// Start heart rate monitoring
    func startHeartRateMonitoring() {
        guard isHealthKitAvailable else {
            heartRateError = "HealthKit is not available"
            return
        }
        
        previousZone = nil
        heartRateError = nil
        isMonitoringHeartRate = true
        haptics.playStart()
        
        healthKit.startHeartRateMonitoring { [weak self] samples in
            Task { @MainActor in
                self?.handleHeartRateSamples(samples)
            }
        }
    }
    
    /// Stop heart rate monitoring
    func stopHeartRateMonitoring() {
        healthKit.stopHeartRateMonitoring()
        isMonitoringHeartRate = false
        haptics.playStop()
    }
    
    /// Toggle heart rate monitoring
    func toggleHeartRateMonitoring() {
        if isMonitoringHeartRate {
            stopHeartRateMonitoring()
        } else {
            startHeartRateMonitoring()
        }
    }
    
    /// Fetch the latest heart rate (one-time fetch)
    func fetchLatestHeartRate() async {
        do {
            if let sample = try await healthKit.fetchLatestHeartRate() {
                currentHeartRate = sample.bpm
                lastHeartRateUpdate = sample.timestamp
                updateHeartRateZone()
            }
        } catch {
            heartRateError = "Failed to fetch: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Private Heart Rate Methods
    
    /// Handle new heart rate samples
    private func handleHeartRateSamples(_ samples: [HeartRateSample]) {
        if let latestSample = samples.first {
            currentHeartRate = latestSample.bpm
            lastHeartRateUpdate = latestSample.timestamp
            updateHeartRateZone()
        }
    }
    
    /// Update the current heart rate zone
    private func updateHeartRateZone() {
        let newZone = HeartRateZone.zone(for: currentHeartRate, maxHeartRate: maxHeartRate)
        
        // Check if zone changed and provide haptic feedback
        if let previousZone = previousZone, previousZone != newZone {
            haptics.playZoneChanged(from: previousZone, to: newZone)
            
            // Extra warning for peak zone
            if newZone == .peak {
                haptics.playWarning()
            }
        }
        
        previousZone = currentZone
        currentZone = newZone
    }
}

