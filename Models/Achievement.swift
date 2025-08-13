//
//  Achievement.swift
//  AURZA
//

import Foundation

struct Achievement: Identifiable, Codable {
    let id: UUID
    var type: AchievementType
    var name: String
    var description: String
    var icon: String
    var unlockedAt: Date?
    var progress: Int
    var target: Int
    
    enum AchievementType: String, Codable, CaseIterable {
        case streak = "streak"
        case taskMaster = "task_master"
        case habitBuilder = "habit_builder"
        case goalGetter = "goal_getter"
        case earlyBird = "early_bird"
        case nightOwl = "night_owl"
        case consistent = "consistent"
        case explorer = "explorer"
        case focused = "focused"
        case balanced = "balanced"
    }
    
    init(
        id: UUID = UUID(),
        type: AchievementType,
        name: String,
        description: String,
        icon: String,
        unlockedAt: Date? = nil,
        progress: Int = 0,
        target: Int = 100
    ) {
        self.id = id
        self.type = type
        self.name = name
        self.description = description
        self.icon = icon
        self.unlockedAt = unlockedAt
        self.progress = progress
        self.target = target
    }
    
    var isUnlocked: Bool {
        unlockedAt != nil
    }
    
    var progressPercentage: Double {
        guard target > 0 else { return 0 }
        return min(1.0, Double(progress) / Double(target))
    }
}
