//
//  Constants.swift
//  AURZA
//

import Foundation
import SwiftUI

struct Constants {
    struct Layout {
        static let defaultPadding: CGFloat = 16
        static let smallPadding: CGFloat = 8
        static let largePadding: CGFloat = 24
        static let cornerRadius: CGFloat = 12
        static let smallCornerRadius: CGFloat = 6
        static let largeCornerRadius: CGFloat = 16
    }
    
    struct Animation {
        static let defaultDuration: Double = 0.3
        static let shortDuration: Double = 0.2
        static let longDuration: Double = 0.5
    }
    
    struct Storage {
        static let tasksKey = "tasks"
        static let habitsKey = "habits"
        static let goalsKey = "goals"
        static let tagsKey = "tags"
        static let completionsKey = "completions"
        static let journalEntriesKey = "journalEntries"
        static let notesKey = "notes"
        static let achievementsKey = "achievements"
        static let xpLevelKey = "xpLevel"
        static let streakKey = "streak"
        static let settingsKey = "settings"
        static let weeklySummariesKey = "weeklySummaries"
    }
    
    struct StoreKit {
        static let monthlyProductId = "com.aurza.pro.monthly"
        static let lifetimeProductId = "com.aurza.pro.lifetime"
    }
    
    struct Notifications {
        static let taskCategory = "TASK"
        static let habitCategory = "HABIT"
        static let goalCategory = "GOAL"
        static let dailyQuestionCategory = "DAILY_QUESTION"
    }
}
