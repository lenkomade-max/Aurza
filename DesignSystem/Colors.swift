//
//  Colors.swift
//  AURZA
//

import SwiftUI

extension Color {
    // Brand colors
    static let aurzaPrimary = Color("AurzaPrimary", bundle: .main)
    static let aurzaSecondary = Color("AurzaSecondary", bundle: .main)
    
    // Semantic colors
    static let success = Color.green
    static let warning = Color.orange
    static let error = Color.red
    static let info = Color.blue
    
    // Category colors
    static let healthColor = Color.red
    static let moneyColor = Color.green
    static let familyColor = Color.blue
    static let growthColor = Color.purple
    
    // Mood theme colors
    static func moodColor(for theme: AppSettings.MoodTheme) -> Color {
        switch theme {
        case .fresh:
            return .mint
        case .deep:
            return .indigo
        case .mono:
            return .gray
        }
    }
}
