//
//  WeekStripView.swift
//  AURZA
//

import SwiftUI

struct WeekStripView: View {
    @Binding var selectedDate: Date
    @EnvironmentObject var appTheme: AppTheme
    
    private var weekDates: [Date] {
        let calendar = Calendar.current
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: selectedDate)?.start ?? selectedDate
        
        return (0..<7).compactMap { dayOffset in
            calendar.date(byAdding: .day, value: dayOffset, to: startOfWeek)
        }
    }
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(weekDates, id: \.self) { date in
                WeekDayView(
                    date: date,
                    isSelected: Calendar.current.isDate(date, inSameDayAs: selectedDate),
                    onTap: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedDate = date
                        }
                    }
                )
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

struct WeekDayView: View {
    let date: Date
    let isSelected: Bool
    let onTap: () -> Void
    
    private var dayFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }
    
    private var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }
    
    var body: some View {
        VStack(spacing: 4) {
            Text(dayFormatter.string(from: date))
                .font(.caption2)
                .foregroundColor(isSelected ? .white : .secondary)
            
            Text(dateFormatter.string(from: date))
                .font(.system(size: 16, weight: isToday ? .bold : .medium))
                .foregroundColor(isSelected ? .white : (isToday ? .accentColor : .primary))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(isSelected ? Color.accentColor : Color.secondary.opacity(0.1))
        )
        .onTapGesture {
            onTap()
        }
    }
}
