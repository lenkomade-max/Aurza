//
//  Goal.swift
//  AURZA
//

import Foundation
import SwiftUI

struct Goal: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var details: String?
    var category: Category
    var emoji: String
    var color: Color.RGBAColor
    var deadline: Date
    var tags: [Tag]
    var reminders: [Reminder]
    var target: Double?
    var current: Double?
    var isPinned: Bool
    var isCompleted: Bool
    let createdAt: Date
    var updatedAt: Date
    
    init(
        id: UUID = UUID(),
        title: String,
        details: String? = nil,
        category: Category = .growth,
        emoji: String = "🎯",
        color: Color.RGBAColor = Color.purple.rgbaColor,
        deadline: Date = Date().addingTimeInterval(30 * 24 * 60 * 60),
        tags: [Tag] = [],
        reminders: [Reminder] = [],
        target: Double? = nil,
        current: Double? = nil,
        isPinned: Bool = false,
        isCompleted: Bool = false,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.details = details
        self.category = category
        self.emoji = emoji
        self.color = color
        self.deadline = deadline
        self.tags = tags
        self.reminders = reminders
        self.target = target
        self.current = current
        self.isPinned = isPinned
        self.isCompleted = isCompleted
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    var daysUntilDeadline: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date(), to: deadline)
        return max(0, components.day ?? 0)
    }
    
    var progress: Double {
        guard let target = target, let current = current, target > 0 else { return 0 }
        return min(1.0, max(0, current / target))
    }
    
    var progressPercentage: Int {
        Int(progress * 100)
    }
    
    var motivationalMessage: String {
        let messages = [
            NSLocalizedString("goal_motivation_1", comment: ""),
            NSLocalizedString("goal_motivation_2", comment: ""),
            NSLocalizedString("goal_motivation_3", comment: ""),
            NSLocalizedString("goal_motivation_4", comment: ""),
            NSLocalizedString("goal_motivation_5", comment: "")
        ]
        return messages.randomElement() ?? messages[0]
    }
}
