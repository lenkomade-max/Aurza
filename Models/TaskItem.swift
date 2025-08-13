//
//  TaskItem.swift
//  AURZA
//

import Foundation
import SwiftUI

struct TaskItem: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var description: String?
    var emoji: String
    var color: Color.RGBAColor
    var date: Date
    var repeatRule: RepeatRule?
    var reminders: [Reminder]
    var tags: [Tag]
    var isPinned: Bool
    var isCompleted: Bool
    let createdAt: Date
    var updatedAt: Date
    
    init(
        id: UUID = UUID(),
        title: String,
        description: String? = nil,
        emoji: String = "📝",
        color: Color.RGBAColor = Color.blue.rgbaColor,
        date: Date = Date(),
        repeatRule: RepeatRule? = nil,
        reminders: [Reminder] = [],
        tags: [Tag] = [],
        isPinned: Bool = false,
        isCompleted: Bool = false,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.emoji = emoji
        self.color = color
        self.date = date
        self.repeatRule = repeatRule
        self.reminders = reminders
        self.tags = tags
        self.isPinned = isPinned
        self.isCompleted = isCompleted
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

struct RepeatRule: Codable, Equatable {
    enum Frequency: String, Codable, CaseIterable {
        case daily = "daily"
        case weekly = "weekly"
        case monthly = "monthly"
        case yearly = "yearly"
        
        var localizedName: String {
            switch self {
            case .daily: return NSLocalizedString("repeat_daily", comment: "")
            case .weekly: return NSLocalizedString("repeat_weekly", comment: "")
            case .monthly: return NSLocalizedString("repeat_monthly", comment: "")
            case .yearly: return NSLocalizedString("repeat_yearly", comment: "")
            }
        }
    }
    
    var frequency: Frequency
    var interval: Int
    var endDate: Date?
    var daysOfWeek: [Int]? // For weekly: 1=Sunday, 7=Saturday
    var dayOfMonth: Int? // For monthly
    
    init(frequency: Frequency, interval: Int = 1, endDate: Date? = nil, daysOfWeek: [Int]? = nil, dayOfMonth: Int? = nil) {
        self.frequency = frequency
        self.interval = interval
        self.endDate = endDate
        self.daysOfWeek = daysOfWeek
        self.dayOfMonth = dayOfMonth
    }
}

extension Color {
    struct RGBAColor: Codable, Equatable {
        var red: Double
        var green: Double
        var blue: Double
        var alpha: Double
        
        init(red: Double, green: Double, blue: Double, alpha: Double = 1.0) {
            self.red = red
            self.green = green
            self.blue = blue
            self.alpha = alpha
        }
    }
    
    var rgbaColor: RGBAColor {
        let uiColor = UIColor(self)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return RGBAColor(red: Double(red), green: Double(green), blue: Double(blue), alpha: Double(alpha))
    }
    
    init(rgbaColor: RGBAColor) {
        self = Color(red: rgbaColor.red, green: rgbaColor.green, blue: rgbaColor.blue, opacity: rgbaColor.alpha)
    }
}
