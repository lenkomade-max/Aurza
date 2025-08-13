//
//  Streak.swift
//  AURZA
//

import Foundation

struct Streak: Codable {
    var current: Int
    var longest: Int
    var lastCompletionDate: Date?
    var startDate: Date?
    
    init(current: Int = 0, longest: Int = 0, lastCompletionDate: Date? = nil, startDate: Date? = nil) {
        self.current = current
        self.longest = longest
        self.lastCompletionDate = lastCompletionDate
        self.startDate = startDate
    }
    
    mutating func updateStreak(completionDate: Date) {
        let calendar = Calendar.current
        
        if let lastDate = lastCompletionDate {
            if calendar.isDate(completionDate, inSameDayAs: lastDate) {
                // Same day, no change
                return
            } else if let dayAfter = calendar.date(byAdding: .day, value: 1, to: lastDate),
                      calendar.isDate(completionDate, inSameDayAs: dayAfter) {
                // Next day, increment streak
                current += 1
                if startDate == nil {
                    startDate = lastDate
                }
            } else {
                // Streak broken
                current = 1
                startDate = completionDate
            }
        } else {
            // First completion
            current = 1
            startDate = completionDate
        }
        
        lastCompletionDate = completionDate
        longest = max(longest, current)
    }
    
    mutating func checkStreakStatus() {
        guard let lastDate = lastCompletionDate else {
            current = 0
            startDate = nil
            return
        }
        
        let calendar = Calendar.current
        let today = Date()
        
        if !calendar.isDate(lastDate, inSameDayAs: today) {
            if let yesterday = calendar.date(byAdding: .day, value: -1, to: today),
               !calendar.isDate(lastDate, inSameDayAs: yesterday) {
                // Streak broken
                current = 0
                startDate = nil
            }
        }
    }
}
