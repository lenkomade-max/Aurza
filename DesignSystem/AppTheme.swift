//
//  AppTheme.swift
//  AURZA
//

import SwiftUI

class AppTheme: ObservableObject {
    @Published var currentTheme: AppSettings.Theme = .system
    @Published var accentColorName: String = "blue"
    @Published var moodTheme: AppSettings.MoodTheme = .fresh
    
    var accentColor: Color {
        switch accentColorName {
        case "blue": return .blue
        case "purple": return .purple
        case "pink": return .pink
        case "red": return .red
        case "orange": return .orange
        case "yellow": return .yellow
        case "green": return .green
        case "teal": return .teal
        default: return .blue
        }
    }
    
    var backgroundColor: Color {
        switch moodTheme {
        case .fresh:
            return Color(UIColor.systemBackground)
        case .deep:
            return Color(UIColor.systemBackground).opacity(0.95)
        case .mono:
            return Color(UIColor.systemGray6)
        }
    }
    
    var cardBackgroundColor: Color {
        switch moodTheme {
        case .fresh:
            return Color(UIColor.secondarySystemGroupedBackground)
        case .deep:
            return Color(UIColor.secondarySystemGroupedBackground).opacity(0.95)
        case .mono:
            return Color(UIColor.systemGray5)
        }
    }
}
