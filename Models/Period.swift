//
//  Period.swift
//  AURZA
//

import Foundation

enum Period: String, CaseIterable {
    case week = "week"
    case month = "month"
    case quarter = "quarter"
    case year = "year"
    case custom = "custom"
    
    var localizedName: String {
        switch self {
        case .week: return NSLocalizedString("period_week", comment: "")
        case .month: return NSLocalizedString("period_month", comment: "")
        case .quarter: return NSLocalizedString("period_90days", comment: "")
        case .year: return NSLocalizedString("period_year", comment: "")
        case .custom: return NSLocalizedString("period_custom", comment: "")
        }
    }
    
    func dateRange(from date: Date = Date()) -> (start: Date, end: Date) {
        let calendar = Calendar.current
        
        switch self {
        case .week:
            let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: date)?.start ?? date
            let endOfWeek = calendar.date(byAdding: .day, value: 6, to: startOfWeek) ?? date
            return (startOfWeek, endOfWeek)
            
        case .month:
            let startOfMonth = calendar.dateInterval(of: .month, for: date)?.start ?? date
            let endOfMonth = calendar.dateInterval(of: .month, for: date)?.end ?? date
            return (startOfMonth, endOfMonth)
            
        case .quarter:
            let start = calendar.date(byAdding: .day, value: -90, to: date) ?? date
            return (start, date)
            
        case .year:
            let startOfYear = calendar.dateInterval(of: .year, for: date)?.start ?? date
            let endOfYear = calendar.dateInterval(of: .year, for: date)?.end ?? date
            return (startOfYear, endOfYear)
            
        case .custom:
            return (date, date)
        }
    }
}
