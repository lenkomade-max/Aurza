//
//  TaskFormView.swift
//  AURZA
//

import SwiftUI

struct TaskFormView: View {
    let task: TaskItem?
    let onSave: (TaskItem) -> Void
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var localStore: LocalStore
    
    @State private var title = ""
    @State private var description = ""
    @State private var emoji = "📝"
    @State private var color = Color.blue
    @State private var date = Date()
    @State private var hasRepeat = false
    @State private var repeatRule = RepeatRule(frequency: .daily)
    @State private var reminders: [Reminder] = []
    @State private var selectedTags: Set<Tag> = []
    @State private var showingEmojiPicker = false
    
    init(task: TaskItem?, onSave: @escaping (TaskItem) -> Void) {
        self.task = task
        self.onSave = onSave
    }
    
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
                        
                        TextField(NSLocalizedString("task_title", comment: ""), text: $title)
                            .font(.headline)
                    }
                    
                    TextField(NSLocalizedString("task_description", comment: ""), text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section {
                    DatePicker(NSLocalizedString("date", comment: ""), selection: $date, displayedComponents: [.date, .hourAndMinute])
                    
                    Toggle(NSLocalizedString("repeat", comment: ""), isOn: $hasRepeat)
                    
                    if hasRepeat {
                        Picker(NSLocalizedString("frequency", comment: ""), selection: $repeatRule.frequency) {
                            ForEach(RepeatRule.Frequency.allCases, id: \.self) { frequency in
                                Text(frequency.localizedName).tag(frequency)
                            }
                        }
                        
                        Stepper(NSLocalizedString("interval", comment: "") + ": \(repeatRule.interval)", value: $repeatRule.interval, in: 1...30)
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
                
                Section {
                    Text(NSLocalizedString("tags", comment: ""))
                        .font(.headline)
                    
                    TagSelectionView(tags: localStore.tags, selectedTags: $selectedTags)
                }
            }
            .navigationTitle(task != nil ? NSLocalizedString("edit_task", comment: "") : NSLocalizedString("new_task", comment: ""))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(NSLocalizedString("cancel", comment: "")) {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(NSLocalizedString("save", comment: "")) {
                        saveTask()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
        .sheet(isPresented: $showingEmojiPicker) {
            EmojiPickerView(selectedEmoji: $emoji)
        }
        .onAppear {
            if let task = task {
                title = task.title
                description = task.description ?? ""
                emoji = task.emoji
                color = Color(task.color)
                date = task.date
                hasRepeat = task.repeatRule != nil
                if let rule = task.repeatRule {
                    repeatRule = rule
                }
                reminders = task.reminders
                selectedTags = Set(task.tags)
            }
        }
    }
    
    private func saveTask() {
        let newTask = TaskItem(
            id: task?.id ?? UUID(),
            title: title,
            description: description.isEmpty ? nil : description,
            emoji: emoji,
            color: color.rgbaColor,
            date: date,
            repeatRule: hasRepeat ? repeatRule : nil,
            reminders: reminders,
            tags: Array(selectedTags),
            isPinned: task?.isPinned ?? false,
            isCompleted: false,
            createdAt: task?.createdAt ?? Date(),
            updatedAt: Date()
        )
        
        onSave(newTask)
        dismiss()
    }
}

// Компонент для выбора тегов
struct TagSelectionView: View {
    let tags: [Tag]
    @Binding var selectedTags: Set<Tag>
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(Array(stride(from: 0, to: tags.count, by: 3)), id: \.self) { index in
                    HStack(spacing: 8) {
                        ForEach(index..<min(index + 3, tags.count), id: \.self) { tagIndex in
                            TagChipView(
                                tag: tags[tagIndex],
                                size: .regular,
                                isSelected: selectedTags.contains(tags[tagIndex]),
                                onTap: {
                                    if selectedTags.contains(tags[tagIndex]) {
                                        selectedTags.remove(tags[tagIndex])
                                    } else {
                                        selectedTags.insert(tags[tagIndex])
                                    }
                                }
                            )
                        }
                        Spacer()
                    }
                }
            }
            .padding(.vertical, 4)
        }
        .frame(maxHeight: 150)
    }
}

struct ReminderListView: View {
    @Binding var reminders: [Reminder]
    @State private var showingAddReminder = false
    
    var body: some View {
        List {
            ForEach(reminders) { reminder in
                HStack {
                    Text(reminder.formattedTime)
                    Spacer()
                    if let sound = reminder.soundName {
                        Text(sound)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .onDelete { indices in
                reminders.remove(atOffsets: indices)
            }
            
            Button(action: { showingAddReminder = true }) {
                Label(NSLocalizedString("add_reminder", comment: ""), systemImage: "plus.circle")
            }
        }
        .navigationTitle(NSLocalizedString("reminders", comment: ""))
        .sheet(isPresented: $showingAddReminder) {
            AddReminderView { reminder in
                reminders.append(reminder)
            }
        }
    }
}

struct AddReminderView: View {
    let onAdd: (Reminder) -> Void
    
    @State private var time = Date()
    @State private var soundName = "default"
    @Environment(\.dismiss) var dismiss
    
    let sounds = ["default", "bell", "chime", "ding", "notification"]
    
    var body: some View {
        NavigationView {
            Form {
                DatePicker(NSLocalizedString("time", comment: ""), selection: $time, displayedComponents: .hourAndMinute)
                
                Picker(NSLocalizedString("sound", comment: ""), selection: $soundName) {
                    ForEach(sounds, id: \.self) { sound in
                        Text(sound).tag(sound)
                    }
                }
            }
            .navigationTitle(NSLocalizedString("new_reminder", comment: ""))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(NSLocalizedString("cancel", comment: "")) {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(NSLocalizedString("add", comment: "")) {
                        let reminder = Reminder(time: time, soundName: soundName)
                        onAdd(reminder)
                        dismiss()
                    }
                }
            }
        }
    }
}

// Полный EmojiPickerView
struct EmojiPickerView: View {
    @Binding var selectedEmoji: String
    @Environment(\.dismiss) var dismiss
    
    let emojis = [
        "📝", "✅", "⭐", "🎯", "💡", "📚", "🏃", "🧹", "🛒", "💼",
        "📱", "🧘", "💤", "🎨", "🎵", "🍎", "☕", "🚀", "💪", "🌟",
        "📧", "🏋️", "🎮", "🎬", "📷", "✈️", "🚗", "🏠", "❤️", "🎉"
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 20) {
                    ForEach(emojis, id: \.self) { emoji in
                        Text(emoji)
                            .font(.largeTitle)
                            .frame(width: 60, height: 60)
                            .background(selectedEmoji == emoji ? Color.accentColor.opacity(0.2) : Color.gray.opacity(0.1))
                            .cornerRadius(10)
                            .onTapGesture {
                                selectedEmoji = emoji
                                dismiss()
                            }
                    }
                }
                .padding()
            }
            .navigationTitle(NSLocalizedString("choose_emoji", comment: ""))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(NSLocalizedString("done", comment: "")) {
                        dismiss()
                    }
                }
            }
        }
    }
}
