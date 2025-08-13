//
//  GoalFormView.swift
//  AURZA
//

import SwiftUI

struct GoalFormView: View {
    let goal: Goal?
    let onSave: (Goal) -> Void
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var localStore: LocalStore
    
    @State private var title = ""
    @State private var details = ""
    @State private var category: Category = .growth
    @State private var emoji = "🎯"
    @State private var color = Color.purple
    @State private var deadline = Date().addingTimeInterval(30 * 24 * 60 * 60)
    @State private var hasTarget = false
    @State private var target: String = "100"
    @State private var current: String = "0"
    @State private var reminders: [Reminder] = []
    @State private var selectedTags: Set<Tag> = []
    @State private var showingEmojiPicker = false
    
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
                        
                        TextField(NSLocalizedString("goal_title", comment: ""), text: $title)
                            .font(.headline)
                    }
                    
                    TextField(NSLocalizedString("goal_details", comment: ""), text: $details, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section {
                    Picker(NSLocalizedString("category", comment: ""), selection: $category) {
                        ForEach(Category.allCases, id: \.self) { cat in
                            Label(cat.localizedName, systemImage: cat.icon)
                                .tag(cat)
                        }
                    }
                    
                    ColorPicker(NSLocalizedString("color", comment: ""), selection: $color)
                    
                    DatePicker(NSLocalizedString("deadline", comment: ""), selection: $deadline, displayedComponents: .date)
                }
                
                Section {
                    Toggle(NSLocalizedString("measurable_goal", comment: ""), isOn: $hasTarget)
                    
                    if hasTarget {
                        HStack {
                            Text(NSLocalizedString("target", comment: ""))
                            TextField("100", text: $target)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                        }
                        
                        HStack {
                            Text(NSLocalizedString("current_progress", comment: ""))
                            TextField("0", text: $current)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                        }
                    }
                }
                
                Section {
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
            .navigationTitle(goal != nil ? NSLocalizedString("edit_goal", comment: "") : NSLocalizedString("new_goal", comment: ""))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(NSLocalizedString("cancel", comment: "")) {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(NSLocalizedString("save", comment: "")) {
                        saveGoal()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
        .sheet(isPresented: $showingEmojiPicker) {
            EmojiPickerView(selectedEmoji: $emoji)
        }
        .onAppear {
            if let goal = goal {
                title = goal.title
                details = goal.details ?? ""
                category = goal.category
                emoji = goal.emoji
                color = Color(goal.color)
                deadline = goal.deadline
                hasTarget = goal.target != nil
                if let t = goal.target {
                    target = String(Int(t))
                }
                if let c = goal.current {
                    current = String(Int(c))
                }
                reminders = goal.reminders
                selectedTags = Set(goal.tags)
            }
        }
    }
    
    private func saveGoal() {
        let newGoal = Goal(
            id: goal?.id ?? UUID(),
            title: title,
            details: details.isEmpty ? nil : details,
            category: category,
            emoji: emoji,
            color: color.rgbaColor,
            deadline: deadline,
            tags: Array(selectedTags),
            reminders: reminders,
            target: hasTarget ? Double(target) : nil,
            current: hasTarget ? Double(current) : nil,
            isPinned: goal?.isPinned ?? false,
            isCompleted: goal?.isCompleted ?? false,
            createdAt: goal?.createdAt ?? Date(),
            updatedAt: Date()
        )
        
        onSave(newGoal)
        dismiss()
    }
}
