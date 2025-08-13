//
//  HabitFormView.swift
//  AURZA
//

import SwiftUI

struct HabitFormView: View {
    let habit: Habit?
    let onSave: (Habit) -> Void
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var localStore: LocalStore
    
    @State private var title = ""
    @State private var emoji = "⭐"
    @State private var color = Color.green
    @State private var schedule: Set<Int> = Set(1...7)
    @State private var defaultDuration = 30
    @State private var reminders: [Reminder] = []
    @State private var selectedTags: Set<Tag> = []
    @State private var showingEmojiPicker = false
    
    let weekdays = [
        (1, "S", NSLocalizedString("sunday", comment: "")),
        (2, "M", NSLocalizedString("monday", comment: "")),
        (3, "T", NSLocalizedString("tuesday", comment: "")),
        (4, "W", NSLocalizedString("wednesday", comment: "")),
        (5, "T", NSLocalizedString("thursday", comment: "")),
        (6, "F", NSLocalizedString("friday", comment: "")),
        (7, "S", NSLocalizedString("saturday", comment: ""))
    ]
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    HStack {
                        Button(action: { showingEmojiPicker = true }) {
                            Text(emoji)
                                .font(.title)
                                .frame(width: 50, height: 50)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(10)
                        }
                        
                        TextField(NSLocalizedString("habit_title", comment: ""), text: $title)
                            .font(.headline)
                    }
                }
                
                Section(header: Text(NSLocalizedString("schedule", comment: ""))) {
                    HStack(spacing: 4) {
                        ForEach(weekdays, id: \.0) { day in
                            Button(action: {
                                if schedule.contains(day.0) {
                                    schedule.remove(day.0)
                                } else {
                                    schedule.insert(day.0)
                                }
                            }) {
                                Text(day.1)
                                    .font(.system(size: 14, weight: .medium))
                                    .frame(width: 40, height: 40)
                                    .background(schedule.contains(day.0) ? color : Color.gray.opacity(0.2))
                                    .foregroundColor(schedule.contains(day.0) ? .white : .primary)
                                    .clipShape(Circle())
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    
                    Stepper(value: $defaultDuration, in: 5...120, step: 5) {
                        HStack {
                            Text(NSLocalizedString("default_duration", comment: ""))
                            Spacer()
                            Text("\(defaultDuration) " + NSLocalizedString("minutes", comment: ""))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Section {
                    ColorPicker(NSLocalizedString("color", comment: ""), selection: $color)
                    
                    NavigationLink(destination: ReminderListView(reminders: $reminders)) {
                        HStack {
                            Text(NSLocalizedString("reminders", comment: ""))
                            Spacer()
                            if !reminders.isEmpty {
                                Text("\(reminders.count)")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                
                Section(header: Text(NSLocalizedString("tags", comment: ""))) {
                    FlowLayout(spacing: 8) {
                        ForEach(localStore.tags) { tag in
                            TagChipView(
                                tag: tag,
                                size: .regular,
                                isSelected: selectedTags.contains(tag),
                                onTap: {
                                    if selectedTags.contains(tag) {
                                        selectedTags.remove(tag)
                                    } else {
                                        selectedTags.insert(tag)
                                    }
                                }
                            )
                        }
                    }
                }
            }
            .navigationTitle(habit != nil ? NSLocalizedString("edit_habit", comment: "") : NSLocalizedString("new_habit", comment: ""))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(NSLocalizedString("cancel", comment: "")) {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(NSLocalizedString("save", comment: "")) {
                        saveHabit()
                    }
                    .disabled(title.isEmpty || schedule.isEmpty)
                }
            }
        }
        .sheet(isPresented: $showingEmojiPicker) {
            EmojiPickerView(selectedEmoji: $emoji)
        }
        .onAppear {
            if let habit = habit {
                title = habit.title
                emoji = habit.emoji
                color = Color(habit.color)
                schedule = Set(habit.schedule)
                defaultDuration = habit.defaultDuration
                reminders = habit.reminders
                selectedTags = Set(habit.tags)
            }
        }
    }
    
    private func saveHabit() {
        let newHabit = Habit(
            id: habit?.id ?? UUID(),
            title: title,
            emoji: emoji,
            color: color.rgbaColor,
            schedule: Array(schedule).sorted(),
            defaultDuration: defaultDuration,
            reminders: reminders,
            tags: Array(selectedTags),
            isPinned: habit?.isPinned ?? false,
            completedDates: habit?.completedDates ?? [],
            createdAt: habit?.createdAt ?? Date(),
            updatedAt: Date()
        )
        
        onSave(newHabit)
        dismiss()
    }
}
