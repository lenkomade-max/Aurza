//
//  Category.swift
//  AURZA
//

import Foundation
import SwiftUI

enum Category: String, Codable, CaseIterable {
    case health = "health"
    case money = "money"
    case family = "family"
    case growth = "growth"
    
    var localizedName: String {
        switch self {
        case .health: return NSLocalizedString("category_health", comment: "")
        case .money: return NSLocalizedString("category_money", comment: "")
        case .family: return NSLocalizedString("category_family", comment: "")
        case .growth: return NSLocalizedString("category_growth", comment: "")
        }
    }
    
    var icon: String {
        switch self {
        case .health: return "heart.fill"
        case .money: return "dollarsign.circle.fill"
        case .family: return "person.2.fill"
        case .growth: return "chart.line.uptrend.xyaxis"
        }
    }
    
    var color: Color {
        switch self {
        case .health: return .red
        case .money: return .green
        case .family: return .blue
        case .growth: return .purple
        }
    }
}
