//
//  HabitCardView.swift
//  AURZA
//

import SwiftUI

struct HabitCardView: View {
    let habit: Habit
    let isCompletedToday: Bool
    let onComplete: () -> Void
    let onEdit: () -> Void
    let onPin: () -> Void
    
    @State private var showingTimer = false
    @EnvironmentObject var hapticsService: HapticsService
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(habit.emoji)
                    .font(.title2)
                
                Text(habit.title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                
                Spacer()
                
                if habit.isPinned {
                    Image(systemName: "pin.fill")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
                
                Menu {
                    Button(action: onEdit) {
                        Label(NSLocalizedString("edit", comment: ""), systemImage: "pencil")
                    }
                    
                    Button(action: onPin) {
                        Label(
                            habit.isPinned ? NSLocalizedString("unpin", comment: "") : NSLocalizedString("pin", comment: ""),
                            systemImage: habit.isPinned ? "pin.slash" : "pin"
                        )
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .frame(width: 30, height: 30)
                }
            }
            
            HStack {
                // Schedule days
                HStack(spacing: 2) {
                    ForEach(1...7, id: \.self) { day in
                        Circle()
                            .fill(habit.schedule.contains(day) ? Color(rgbaColor: habit.color) : Color.gray.opacity(0.2))
                            .frame(width: 6, height: 6)
                    }
                }
                
                Spacer()
                
                // Duration
                Label("\(habit.defaultDuration) min", systemImage: "timer")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                // Streak
                if habit.currentStreak > 0 {
                    Label("\(habit.currentStreak)", systemImage: "flame.fill")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }
            
            HStack(spacing: 8) {
                ForEach(habit.tags.prefix(3)) { tag in
                    TagChipView(tag: tag, size: .small)
                }
                
                Spacer()
                
                Button(action: {
                    if isCompletedToday {
                        hapticsService.impact(.light)
                    } else {
                        showingTimer = true
                    }
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: isCompletedToday ? "checkmark.circle.fill" : "play.circle.fill")
                        Text(isCompletedToday ? NSLocalizedString("completed", comment: "") : NSLocalizedString("start", comment: ""))
                            .font(.caption)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(isCompletedToday ? Color.green : Color(rgbaColor: habit.color))
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .disabled(isCompletedToday)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(12)
        .sheet(isPresented: $showingTimer) {
            HabitTimerView(
                habit: habit,
                onComplete: {
                    showingTimer = false
                    onComplete()
                }
            )
        }
    }
}

struct HabitTimerView: View {
    let habit: Habit
    let onComplete: () -> Void
    
    @State private var timeRemaining: Int
    @State private var timer: Timer?
    @State private var isPaused = false
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var soundService: SoundService
    
    init(habit: Habit, onComplete: @escaping () -> Void) {
        self.habit = habit
        self.onComplete = onComplete
        self._timeRemaining = State(initialValue: habit.defaultDuration * 60)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 40) {
                Spacer()
                
                Text(habit.emoji)
                    .font(.system(size: 80))
                
                Text(habit.title)
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text(String(format: "%02d:%02d", timeRemaining / 60, timeRemaining % 60))
                    .font(.system(size: 60, weight: .light, design: .monospaced))
                    .foregroundColor(.primary)
                
                HStack(spacing: 40) {
                    Button(action: {
                        isPaused.toggle()
                        if isPaused {
                            timer?.invalidate()
                        } else {
                            startTimer()
                        }
                    }) {
                        Image(systemName: isPaused ? "play.circle.fill" : "pause.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(Color(rgbaColor: habit.color))
                    }
                    
                    Button(action: {
                        timer?.invalidate()
                        soundService.playCompletionSound()
                        onComplete()
                    }) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.green)
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationBarItems(
                leading: Button(NSLocalizedString("cancel", comment: "")) {
                    timer?.invalidate()
                    dismiss()
                }
            )
        }
        .onAppear {
            startTimer()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                timer?.invalidate()
                soundService.playCompletionSound()
                onComplete()
            }
        }
    }
}
