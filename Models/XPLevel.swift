//
//  XPLevel.swift
//  AURZA
//

import Foundation

struct XPLevel: Codable {
    var currentXP: Int
    var totalXP: Int
    var level: Int
    
    init(currentXP: Int = 0, totalXP: Int = 0, level: Int = 1) {
        self.currentXP = currentXP
        self.totalXP = totalXP
        self.level = level
    }
    
    var xpForNextLevel: Int {
        100 * (level + 1)
    }
    
    var xpProgress: Double {
        guard xpForNextLevel > 0 else { return 0 }
        return Double(currentXP) / Double(xpForNextLevel)
    }
    
    mutating func addXP(_ amount: Int) {
        totalXP += amount
        currentXP += amount

        while currentXP >= xpForNextLevel {
            let xpNeeded = xpForNextLevel
            currentXP -= xpNeeded
            level += 1
        }
    }
    
    var levelTitle: String {
        switch level {
        case 1...5: return NSLocalizedString("level_beginner", comment: "")
        case 6...10: return NSLocalizedString("level_apprentice", comment: "")
        case 11...20: return NSLocalizedString("level_expert", comment: "")
        case 21...30: return NSLocalizedString("level_master", comment: "")
        case 31...50: return NSLocalizedString("level_grandmaster", comment: "")
        default: return NSLocalizedString("level_legend", comment: "")
        }
    }
}
