//
//  StorageManager.swift
//  MDI112Class1WatchDesignPrinciples Watch App
//
//  Demonstrates: Local storage with UserDefaults
//  Design Principle: Offline-first for wearables (limited connectivity)
//

import Foundation

/// Manages local data persistence using UserDefaults
/// Design Principle: Wearables need reliable offline storage
class StorageManager {
    
    // MARK: - Singleton
    static let shared = StorageManager()
    private init() {}
    
    // MARK: - Keys
    private enum Keys {
        static let userGoals = "user_goals"
        static let diaryEntries = "diary_entries"
    }
    
    // MARK: - UserDefaults
    private let defaults = UserDefaults.standard
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    // MARK: - User Goals
    
    /// Save user goals to local storage
    func saveGoals(_ goals: UserGoals) {
        if let encoded = try? encoder.encode(goals) {
            defaults.set(encoded, forKey: Keys.userGoals)
        }
    }
    
    /// Load user goals from local storage
    func loadGoals() -> UserGoals {
        guard let data = defaults.data(forKey: Keys.userGoals),
              let goals = try? decoder.decode(UserGoals.self, from: data) else {
            return UserGoals.defaultGoals
        }
        return goals
    }
    
    // MARK: - Diary Entries
    
    /// Save diary entries to local storage
    func saveEntries(_ entries: [DiaryEntry]) {
        if let encoded = try? encoder.encode(entries) {
            defaults.set(encoded, forKey: Keys.diaryEntries)
        }
    }
    
    /// Load all diary entries from local storage
    func loadEntries() -> [DiaryEntry] {
        guard let data = defaults.data(forKey: Keys.diaryEntries),
              let entries = try? decoder.decode([DiaryEntry].self, from: data) else {
            return []
        }
        return entries
    }
    
    /// Add a new entry and save
    func addEntry(_ entry: DiaryEntry) {
        var entries = loadEntries()
        entries.append(entry)
        saveEntries(entries)
    }
    
    /// Get today's entries only
    /// Design Principle: Glanceability - show only relevant data
    func getTodayEntries() -> [DiaryEntry] {
        let entries = loadEntries()
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        return entries.filter { entry in
            calendar.isDate(entry.timestamp, inSameDayAs: today)
        }
    }
    
    /// Calculate today's total for a specific type
    func getTodayTotal(for type: EntryType) -> Double {
        getTodayEntries()
            .filter { $0.type == type }
            .reduce(0) { $0 + $1.value }
    }
    
    /// Clear all data (for testing/reset)
    func clearAllData() {
        defaults.removeObject(forKey: Keys.userGoals)
        defaults.removeObject(forKey: Keys.diaryEntries)
    }
}

