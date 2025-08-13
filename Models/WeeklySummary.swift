//
//  WeeklySummary.swift
//  AURZA
//

import Foundation

struct WeeklySummary: Identifiable, Codable {
    let id: UUID
    var startDate: Date
    var endDate: Date
    var metrics: Metrics
    var focuses: [String]
    var savedToDiary: Bool
    
    struct Metrics: Codable {
        var tasksCompleted: Int
        var habitsCompleted: Int
        var goalsProgressed: Int
        var totalXP: Int
        var longestStreak: Int
        var categoryBalance: [Category: Double]
        var topTags: [String]
        var productivityScore: Double
    }
    
    init(
        id: UUID = UUID(),
        startDate: Date,
        endDate: Date,
        metrics: Metrics,
        focuses: [String] = [],
        savedToDiary: Bool = false
    ) {
        self.id = id
        self.startDate = startDate
        self.endDate = endDate
        self.metrics = metrics
        self.focuses = focuses
        self.savedToDiary = savedToDiary
    }
}
