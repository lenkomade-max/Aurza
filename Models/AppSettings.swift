//
//  AppSettings.swift
//  AURZA
//

import Foundation
import SwiftUI

struct AppSettings: Codable {
    var theme: Theme
    var accentColorName: String
    var language: String
    var soundsEnabled: Bool
    var hapticsEnabled: Bool
    var notificationsEnabled: Bool
    var dailyQuestionEnabled: Bool
    var dailyQuestionTime: Date
    var combineDiaryAndNotes: Bool
    var appLockEnabled: Bool
    var showProductivityPulse: Bool
    var selectedMoodTheme: MoodTheme
    
    enum Theme: String, Codable, CaseIterable {
        case light = "light"
        case dark = "dark"
        case system = "system"
        
        var localizedName: String {
            switch self {
            case .light: return NSLocalizedString("theme_light", comment: "")
            case .dark: return NSLocalizedString("theme_dark", comment: "")
            case .system: return NSLocalizedString("theme_system", comment: "")
            }
        }
        
        var colorScheme: ColorScheme? {
            switch self {
            case .light: return .light
            case .dark: return .dark
            case .system: return nil
            }
        }
    }
    
    enum MoodTheme: String, Codable, CaseIterable {
        case fresh = "fresh"
        case deep = "deep"
        case mono = "mono"
        
        var localizedName: String {
            switch self {
            case .fresh: return NSLocalizedString("mood_fresh", comment: "")
            case .deep: return NSLocalizedString("mood_deep", comment: "")
            case .mono: return NSLocalizedString("mood_mono", comment: "")
            }
        }
    }
    
    init() {
        self.theme = .system
        self.accentColorName = "blue"
        self.language = Locale.current.language.languageCode?.identifier ?? "en"
        self.soundsEnabled = true
        self.hapticsEnabled = true
        self.notificationsEnabled = true
        self.dailyQuestionEnabled = false
        self.dailyQuestionTime = Calendar.current.date(from: DateComponents(hour: 20, minute: 0)) ?? Date()
        self.combineDiaryAndNotes = false
        self.appLockEnabled = false
        self.showProductivityPulse = true
        self.selectedMoodTheme = .fresh
    }
}
