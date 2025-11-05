//
//  Habit.swift
//  AURZA
//

import Foundation
import SwiftUI

struct Habit: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var emoji: String
    var color: Color.RGBAColor
    var schedule: [Int] // Days of week: 1=Sunday, 7=Saturday
    var defaultDuration: Int // in minutes
    var reminders: [Reminder]
    var tags: [Tag]
    var isPinned: Bool
    var completedDates: [Date]
    let createdAt: Date
    var updatedAt: Date
    
    init(
        id: UUID = UUID(),
        title: String,
        emoji: String = "⭐",
        color: Color.RGBAColor = Color.green.rgbaColor,
        schedule: [Int] = [1, 2, 3, 4, 5, 6, 7],
        defaultDuration: Int = 30,
        reminders: [Reminder] = [],
        tags: [Tag] = [],
        isPinned: Bool = false,
        completedDates: [Date] = [],
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.emoji = emoji
        self.color = color
        self.schedule = schedule
        self.defaultDuration = defaultDuration
        self.reminders = reminders
        self.tags = tags
        self.isPinned = isPinned
        self.completedDates = completedDates
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    func isScheduledForDate(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)
        return schedule.contains(weekday)
    }
    
    func isCompletedOnDate(_ date: Date) -> Bool {
        let calendar = Calendar.current
        return completedDates.contains { completedDate in
            calendar.isDate(completedDate, inSameDayAs: date)
        }
    }
    
    var currentStreak: Int {
        guard !completedDates.isEmpty else { return 0 }
        
        let calendar = Calendar.current
        let sortedDates = completedDates.sorted(by: >)
        var streak = 0
        var checkDate = Date()
        
        for date in sortedDates {
            if calendar.isDate(date, inSameDayAs: checkDate) {
                streak += 1
                checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate) ?? checkDate
            } else {
                break
            }
        }
        
        return streak
    }
}
