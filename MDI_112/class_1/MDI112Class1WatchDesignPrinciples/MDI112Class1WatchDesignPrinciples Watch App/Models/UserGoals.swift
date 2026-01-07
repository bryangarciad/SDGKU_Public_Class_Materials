//
//  UserGoals.swift
//  MDI112Class1WatchDesignPrinciples Watch App
//
//  Demonstrates: User preferences and goals storage
//  Design Principle: Personalization for wearables
//

import Foundation

/// User's daily health goals
/// Design Principle: Providing value - personalized goals give purpose
struct UserGoals: Codable {
    var dailyCaloriesGoal: Double
    var dailyWaterGoal: Double // in ml
    
    /// Default goals based on general health recommendations
    static let defaultGoals = UserGoals(
        dailyCaloriesGoal: 2000,
        dailyWaterGoal: 2000 // 2 liters
    )
}

