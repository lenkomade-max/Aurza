//
//  HeatmapView.swift
//  AURZA
//

import SwiftUI

struct HeatmapView: View {
    let data: [Date: Int]
    let period: Period
    @State private var selectedDate: Date?
    
    private var calendar: Calendar {
        Calendar.current
    }
    
    private var weeks: [[Date?]] {
        let (startDate, endDate) = period.dateRange()
        var weeks: [[Date?]] = []
        var currentWeek: [Date?] = []
        
        var date = startDate
        
        // Fill initial week with nil for empty days
        let weekday = calendar.component(.weekday, from: date) - 1
        for _ in 0..<weekday {
            currentWeek.append(nil)
        }
        
        while date <= endDate {
            currentWeek.append(date)
            
            if currentWeek.count == 7 {
                weeks.append(currentWeek)
                currentWeek = []
            }
            
            date = calendar.date(byAdding: .day, value: 1, to: date) ?? date
        }
        
        // Add remaining days
        if !currentWeek.isEmpty {
            while currentWeek.count < 7 {
                currentWeek.append(nil)
            }
            weeks.append(currentWeek)
        }
        
        return weeks
    }
    
    private func colorForCount(_ count: Int) -> Color {
        switch count {
        case 0: return Color.gray.opacity(0.1)
        case 1: return Color.green.opacity(0.3)
        case 2: return Color.green.opacity(0.5)
        case 3: return Color.green.opacity(0.7)
        default: return Color.green
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(NSLocalizedString("activity_heatmap", comment: ""))
                .font(.headline)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 2) {
                    // Weekday labels
                    HStack(spacing: 2) {
                        Text("")
                            .frame(width: 20, height: 15)
                        
                        ForEach(["S", "M", "T", "W", "T", "F", "S"], id: \.self) { day in
                            Text(day)
                                .font(.caption2)
                                .frame(width: 15, height: 15)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // Heatmap grid
                    HStack(spacing: 2) {
                        // Month labels
                        VStack(alignment: .trailing, spacing: 2) {
                            ForEach(0..<min(weeks.count, 12), id: \.self) { weekIndex in
                                if weekIndex % 4 == 0 {
                                    if let firstDate = weeks[weekIndex].compactMap({ $0 }).first {
                                        Text(monthLabel(for: firstDate))
                                            .font(.caption2)
                                            .frame(width: 20, height: 15)
                                            .foregroundColor(.secondary)
                                    } else {
                                        Text("")
                                            .frame(width: 20, height: 15)
                                    }
                                } else {
                                    Text("")
                                        .frame(width: 20, height: 15)
                                }
                            }
                        }
                        
                        // Days grid
                        ForEach(weeks.indices, id: \.self) { weekIndex in
                            VStack(spacing: 2) {
                                ForEach(0..<7, id: \.self) { dayIndex in
                                    if let date = weeks[weekIndex][dayIndex] {
                                        let count = data[calendar.startOfDay(for: date)] ?? 0
                                        
                                        RoundedRectangle(cornerRadius: 2)
                                            .fill(colorForCount(count))
                                            .frame(width: 15, height: 15)
                                            .onTapGesture {
                                                selectedDate = date
                                            }
                                    } else {
                                        Color.clear
                                            .frame(width: 15, height: 15)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding()
            }
            
            // Legend
            HStack(spacing: 12) {
                Text(NSLocalizedString("less", comment: ""))
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                ForEach(0...4, id: \.self) { level in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(colorForCount(level))
                        .frame(width: 12, height: 12)
                }
                
                Text(NSLocalizedString("more", comment: ""))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            
            if let selected = selectedDate, let count = data[calendar.startOfDay(for: selected)] {
                HStack {
                    Text(selected, style: .date)
                        .font(.caption)
                    
                    Spacer()
                    
                    Text("\(count) " + NSLocalizedString("completions", comment: ""))
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color(UIColor.tertiarySystemGroupedBackground))
                .cornerRadius(8)
                .padding(.horizontal)
            }
        }
        .padding(.vertical)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
    
    private func monthLabel(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        return formatter.string(from: date)
    }
}
