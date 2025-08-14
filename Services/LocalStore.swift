//
//  LocalStore.swift
//  AURZA
//

import Foundation
import SwiftUI

class LocalStore: ObservableObject {
    @Published var tasks: [TaskItem] = []
    @Published var habits: [Habit] = []
    @Published var goals: [Goal] = []
    @Published var tags: [Tag] = []
    @Published var completions: [Completion] = []
    @Published var journalEntries: [JournalEntry] = []
    @Published var notes: [Note] = []
    @Published var achievements: [Achievement] = []
    @Published var xpLevel = XPLevel()
    @Published var streak = Streak()
    @Published var settings = AppSettings()
    @Published var weeklySummaries: [WeeklySummary] = []
    
    private let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    
    init() {
        loadData()
        initializeDefaultTags()
        initializeAchievements()
        checkStreakStatus()
    }
    
    // MARK: - Tasks
    func addTask(_ task: TaskItem) {
        tasks.append(task)
        saveData()
    }
    
    func updateTask(_ task: TaskItem) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
            saveData()
        }
    }
    
    func deleteTask(_ task: TaskItem) {
        tasks.removeAll { $0.id == task.id }
        saveData()
    }
    
    func completeTask(_ task: TaskItem) {
        var updatedTask = task
        updatedTask.isCompleted = true
        updateTask(updatedTask)
        
        let completion = Completion(
            type: .task,
            itemId: task.id,
            itemTitle: task.title,
            tagNames: task.tags.map { $0.name },
            xpEarned: task.isPinned ? 5 : 10
        )
        addCompletion(completion)
    }
    
    func getTasksForDate(_ date: Date) -> [TaskItem] {
        let calendar = Calendar.current
        return tasks.filter { task in
            calendar.isDate(task.date, inSameDayAs: date) && !task.isCompleted
        }
    }
    
    // MARK: - Habits
    func addHabit(_ habit: Habit) {
        habits.append(habit)
        saveData()
    }
    
    func updateHabit(_ habit: Habit) {
        if let index = habits.firstIndex(where: { $0.id == habit.id }) {
            habits[index] = habit
            saveData()
        }
    }
    
    func deleteHabit(_ habit: Habit) {
        habits.removeAll { $0.id == habit.id }
        saveData()
    }
    
    func completeHabit(_ habit: Habit, date: Date = Date()) {
        var updatedHabit = habit
        updatedHabit.completedDates.append(date)
        updateHabit(updatedHabit)
        
        let completion = Completion(
            type: .habit,
            itemId: habit.id,
            itemTitle: habit.title,
            tagNames: habit.tags.map { $0.name },
            xpEarned: 15,
            duration: habit.defaultDuration
        )
        addCompletion(completion)
    }
    
    func getHabitsForDate(_ date: Date) -> [Habit] {
        habits.filter { $0.isScheduledForDate(date) }
    }
    
    // MARK: - Goals
    func addGoal(_ goal: Goal) {
        goals.append(goal)
        saveData()
    }
    
    func updateGoal(_ goal: Goal) {
        if let index = goals.firstIndex(where: { $0.id == goal.id }) {
            goals[index] = goal
            saveData()
        }
    }
    
    func deleteGoal(_ goal: Goal) {
        goals.removeAll { $0.id == goal.id }
        saveData()
    }
    
    func progressGoal(_ goal: Goal, amount: Double) {
        var updatedGoal = goal
        updatedGoal.current = (updatedGoal.current ?? 0) + amount
        if let target = updatedGoal.target, updatedGoal.current ?? 0 >= target {
            updatedGoal.isCompleted = true
        }
        updateGoal(updatedGoal)
        
        let completion = Completion(
            type: .goal,
            itemId: goal.id,
            itemTitle: goal.title,
            tagNames: goal.tags.map { $0.name },
            xpEarned: 20
        )
        addCompletion(completion)
    }
    
    // MARK: - Tags
    func addTag(_ tag: Tag) {
        tags.append(tag)
        saveData()
    }
    
    func updateTag(_ tag: Tag) {
        if let index = tags.firstIndex(where: { $0.id == tag.id }) {
            tags[index] = tag
            saveData()
        }
    }
    
    func deleteTag(_ tag: Tag) {
        tags.removeAll { $0.id == tag.id }
        saveData()
    }
    
    // MARK: - Completions & Stats
    func addCompletion(_ completion: Completion) {
        completions.append(completion)
        xpLevel.addXP(completion.xpEarned)
        streak.updateStreak(completionDate: completion.date)
        updateAchievementProgress(for: completion)
        saveData()
    }
    
    func getCompletionsForPeriod(_ period: Period) -> [Completion] {
        let (start, end) = period.dateRange()
        return completions.filter { completion in
            completion.date >= start && completion.date <= end
        }
    }
    
    func getCompletionRate(for period: Period, type: Completion.CompletionType? = nil) -> Double {
        let periodCompletions = getCompletionsForPeriod(period)
        let filtered = type != nil ? periodCompletions.filter { $0.type == type } : periodCompletions
        
        guard !filtered.isEmpty else { return 0 }
        
        let calendar = Calendar.current
        let (start, end) = period.dateRange()
        let days = calendar.dateComponents([.day], from: start, to: end).day ?? 1
        
        return Double(filtered.count) / Double(max(1, days))
    }
    
    // MARK: - Journal & Notes
    func addJournalEntry(_ entry: JournalEntry) {
        journalEntries.append(entry)
        saveData()
    }
    
    func updateJournalEntry(_ entry: JournalEntry) {
        if let index = journalEntries.firstIndex(where: { $0.id == entry.id }) {
            journalEntries[index] = entry
            saveData()
        }
    }
    
    func deleteJournalEntry(_ entry: JournalEntry) {
        journalEntries.removeAll { $0.id == entry.id }
        saveData()
    }
    
    func addNote(_ note: Note) {
        notes.append(note)
        saveData()
    }
    
    func updateNote(_ note: Note) {
        if let index = notes.firstIndex(where: { $0.id == note.id }) {
            notes[index] = note
            saveData()
        }
    }
    
    func archiveNote(_ note: Note) {
        var updatedNote = note
        updatedNote.isArchived = true
        updateNote(updatedNote)
    }
    
    // MARK: - Achievements
    private func initializeAchievements() {
        if achievements.isEmpty {
            achievements = [
                Achievement(type: .streak, name: NSLocalizedString("achievement_streak", comment: ""), description: NSLocalizedString("achievement_streak_desc", comment: ""), icon: "🔥", target: 7),
                Achievement(type: .taskMaster, name: NSLocalizedString("achievement_taskmaster", comment: ""), description: NSLocalizedString("achievement_taskmaster_desc", comment: ""), icon: "✅", target: 100),
                Achievement(type: .habitBuilder, name: NSLocalizedString("achievement_habitbuilder", comment: ""), description: NSLocalizedString("achievement_habitbuilder_desc", comment: ""), icon: "💪", target: 30),
                Achievement(type: .goalGetter, name: NSLocalizedString("achievement_goalgetter", comment: ""), description: NSLocalizedString("achievement_goalgetter_desc", comment: ""), icon: "🎯", target: 10),
                Achievement(type: .earlyBird, name: NSLocalizedString("achievement_earlybird", comment: ""), description: NSLocalizedString("achievement_earlybird_desc", comment: ""), icon: "🌅", target: 20),
                Achievement(type: .nightOwl, name: NSLocalizedString("achievement_nightowl", comment: ""), description: NSLocalizedString("achievement_nightowl_desc", comment: ""), icon: "🦉", target: 20),
                Achievement(type: .consistent, name: NSLocalizedString("achievement_consistent", comment: ""), description: NSLocalizedString("achievement_consistent_desc", comment: ""), icon: "📅", target: 30),
                Achievement(type: .explorer, name: NSLocalizedString("achievement_explorer", comment: ""), description: NSLocalizedString("achievement_explorer_desc", comment: ""), icon: "🗺", target: 10),
                Achievement(type: .focused, name: NSLocalizedString("achievement_focused", comment: ""), description: NSLocalizedString("achievement_focused_desc", comment: ""), icon: "🎯", target: 50),
                Achievement(type: .balanced, name: NSLocalizedString("achievement_balanced", comment: ""), description: NSLocalizedString("achievement_balanced_desc", comment: ""), icon: "⚖️", target: 4)
            ]
        }
    }
    
    private func updateAchievementProgress(for completion: Completion) {
        // Update relevant achievement progress
        for i in 0..<achievements.count {
            switch achievements[i].type {
            case .streak:
                achievements[i].progress = streak.current
            case .taskMaster:
                if completion.type == .task {
                    achievements[i].progress += 1
                }
            case .habitBuilder:
                if completion.type == .habit {
                    achievements[i].progress += 1
                }
            case .goalGetter:
                if completion.type == .goal {
                    achievements[i].progress += 1
                }
            case .earlyBird:
                let hour = Calendar.current.component(.hour, from: completion.date)
                if hour < 9 {
                    achievements[i].progress += 1
                }
            case .nightOwl:
                let hour = Calendar.current.component(.hour, from: completion.date)
                if hour >= 21 {
                    achievements[i].progress += 1
                }
            case .consistent:
                achievements[i].progress = streak.current
            case .explorer:
                let uniqueTags = Set(completions.flatMap { $0.tagNames })
                achievements[i].progress = uniqueTags.count
            case .focused:
                if completion.tagNames.count == 1 {
                    achievements[i].progress += 1
                }
            case .balanced:
                // Check balance across categories
                break
            }
            
            // Check if achievement unlocked
            if achievements[i].progress >= achievements[i].target && achievements[i].unlockedAt == nil {
                achievements[i].unlockedAt = Date()
            }
        }
        saveData()
    }
    
    // MARK: - Default Data
    private func initializeDefaultTags() {
        if tags.isEmpty {
            tags = [
                Tag(name: NSLocalizedString("tag_work", comment: ""), color: Color.blue.rgbaColor),
                Tag(name: NSLocalizedString("tag_personal", comment: ""), color: Color.green.rgbaColor),
                Tag(name: NSLocalizedString("tag_health", comment: ""), color: Color.red.rgbaColor),
                Tag(name: NSLocalizedString("tag_learning", comment: ""), color: Color.purple.rgbaColor),
                Tag(name: NSLocalizedString("tag_finance", comment: ""), color: Color.orange.rgbaColor)
            ]
        }
    }
    
    func getTaskTemplates() -> [TaskItem] {
        [
            TaskItem(title: NSLocalizedString("template_task_1", comment: ""), emoji: "📧"),
            TaskItem(title: NSLocalizedString("template_task_2", comment: ""), emoji: "📝"),
            TaskItem(title: NSLocalizedString("template_task_3", comment: ""), emoji: "🏃"),
            TaskItem(title: NSLocalizedString("template_task_4", comment: ""), emoji: "📚"),
            TaskItem(title: NSLocalizedString("template_task_5", comment: ""), emoji: "🧹"),
            TaskItem(title: NSLocalizedString("template_task_6", comment: ""), emoji: "🛒"),
            TaskItem(title: NSLocalizedString("template_task_7", comment: ""), emoji: "💼"),
            TaskItem(title: NSLocalizedString("template_task_8", comment: ""), emoji: "📱"),
            TaskItem(title: NSLocalizedString("template_task_9", comment: ""), emoji: "🧘"),
            TaskItem(title: NSLocalizedString("template_task_10", comment: ""), emoji: "💤")
        ]
    }
    
    func getHabitTemplates() -> [Habit] {
        [
            Habit(title: NSLocalizedString("template_habit_1", comment: ""), emoji: "🧘", defaultDuration: 20),
            Habit(title: NSLocalizedString("template_habit_2", comment: ""), emoji: "🏃", defaultDuration: 30),
            Habit(title: NSLocalizedString("template_habit_3", comment: ""), emoji: "📚", defaultDuration: 30),
            Habit(title: NSLocalizedString("template_habit_4", comment: ""), emoji: "💧", defaultDuration: 5),
            Habit(title: NSLocalizedString("template_habit_5", comment: ""), emoji: "✍️", defaultDuration: 15),
            Habit(title: NSLocalizedString("template_habit_6", comment: ""), emoji: "🌱", defaultDuration: 10),
            Habit(title: NSLocalizedString("template_habit_7", comment: ""), emoji: "🎨", defaultDuration: 45),
            Habit(title: NSLocalizedString("template_habit_8", comment: ""), emoji: "🧠", defaultDuration: 25),
            Habit(title: NSLocalizedString("template_habit_9", comment: ""), emoji: "🤝", defaultDuration: 15),
            Habit(title: NSLocalizedString("template_habit_10", comment: ""), emoji: "🎵", defaultDuration: 30)
        ]
    }
    
    func getGoalTemplates() -> [Goal] {
        [
            Goal(title: NSLocalizedString("template_goal_1", comment: ""), emoji: "💰", category: .money, target: 10000, current: 0),
            Goal(title: NSLocalizedString("template_goal_2", comment: ""), emoji: "🏋️", category: .health, target: 20, current: 0),
            Goal(title: NSLocalizedString("template_goal_3", comment: ""), emoji: "📚", category: .growth, target: 12, current: 0),
            Goal(title: NSLocalizedString("template_goal_4", comment: ""), emoji: "🏃", category: .health, target: 100, current: 0),
            Goal(title: NSLocalizedString("template_goal_5", comment: ""), emoji: "👨‍👩‍👧‍👦", category: .family, target: 52, current: 0),
            Goal(title: NSLocalizedString("template_goal_6", comment: ""), emoji: "🎯", category: .growth, target: 5, current: 0),
            Goal(title: NSLocalizedString("template_goal_7", comment: ""), emoji: "💵", category: .money, target: 1000, current: 0),
            Goal(title: NSLocalizedString("template_goal_8", comment: ""), emoji: "🧘", category: .health, target: 30, current: 0),
            Goal(title: NSLocalizedString("template_goal_9", comment: ""), emoji: "🌍", category: .family, target: 1, current: 0),
            Goal(title: NSLocalizedString("template_goal_10", comment: ""), emoji: "💼", category: .growth, target: 3, current: 0)
        ]
    }
    
    // MARK: - Persistence
    private func saveCodable<T: Codable>(_ value: T, key: String, encoder: JSONEncoder) {
        if let encoded = try? encoder.encode(value) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }

    private func loadCodable<T: Codable>(key: String, decoder: JSONDecoder, assign: (T) -> Void) {
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? decoder.decode(T.self, from: data) {
            assign(decoded)
        }
    }

    private func saveData() {
        // Save to UserDefaults for simplicity (in production, use Core Data or Files)
        let encoder = JSONEncoder()
        [
            { self.saveCodable(self.tasks, key: "tasks", encoder: encoder) },
            { self.saveCodable(self.habits, key: "habits", encoder: encoder) },
            { self.saveCodable(self.goals, key: "goals", encoder: encoder) },
            { self.saveCodable(self.tags, key: "tags", encoder: encoder) },
            { self.saveCodable(self.completions, key: "completions", encoder: encoder) },
            { self.saveCodable(self.journalEntries, key: "journalEntries", encoder: encoder) },
            { self.saveCodable(self.notes, key: "notes", encoder: encoder) },
            { self.saveCodable(self.achievements, key: "achievements", encoder: encoder) },
            { self.saveCodable(self.xpLevel, key: "xpLevel", encoder: encoder) },
            { self.saveCodable(self.streak, key: "streak", encoder: encoder) },
            { self.saveCodable(self.settings, key: "settings", encoder: encoder) },
            { self.saveCodable(self.weeklySummaries, key: "weeklySummaries", encoder: encoder) }
        ].forEach { $0() }
    }

    private func loadData() {
        let decoder = JSONDecoder()
        [
            { self.loadCodable(key: "tasks", decoder: decoder) { self.tasks = $0 } },
            { self.loadCodable(key: "habits", decoder: decoder) { self.habits = $0 } },
            { self.loadCodable(key: "goals", decoder: decoder) { self.goals = $0 } },
            { self.loadCodable(key: "tags", decoder: decoder) { self.tags = $0 } },
            { self.loadCodable(key: "completions", decoder: decoder) { self.completions = $0 } },
            { self.loadCodable(key: "journalEntries", decoder: decoder) { self.journalEntries = $0 } },
            { self.loadCodable(key: "notes", decoder: decoder) { self.notes = $0 } },
            { self.loadCodable(key: "achievements", decoder: decoder) { self.achievements = $0 } },
            { self.loadCodable(key: "xpLevel", decoder: decoder) { self.xpLevel = $0 } },
            { self.loadCodable(key: "streak", decoder: decoder) { self.streak = $0 } },
            { self.loadCodable(key: "settings", decoder: decoder) { self.settings = $0 } },
            { self.loadCodable(key: "weeklySummaries", decoder: decoder) { self.weeklySummaries = $0 } }
        ].forEach { $0() }
    }
           
           private func checkStreakStatus() {
               streak.checkStreakStatus()
           }
           
           // MARK: - Heatmap Data
           func getHeatmapData(for period: Period) -> [Date: Int] {
               let completionsInPeriod = getCompletionsForPeriod(period)
               var heatmap: [Date: Int] = [:]
               
               let calendar = Calendar.current
               for completion in completionsInPeriod {
                   let startOfDay = calendar.startOfDay(for: completion.date)
                   heatmap[startOfDay, default: 0] += 1
               }
               
               return heatmap
           }
           
           // MARK: - Tag Analytics
           func getTagAnalytics(for period: Period) -> [(tag: String, count: Int, completionRate: Double)] {
               let completionsInPeriod = getCompletionsForPeriod(period)
               var tagStats: [String: (count: Int, total: Int)] = [:]
               
               for completion in completionsInPeriod {
                   for tagName in completion.tagNames {
                       tagStats[tagName, default: (0, 0)].count += 1
                   }
               }
               
               // Calculate totals for each tag
               for task in tasks {
                   for tag in task.tags {
                       tagStats[tag.name, default: (0, 0)].total += 1
                   }
               }
               
               return tagStats.map { (tag: $0.key, count: $0.value.count, completionRate: Double($0.value.count) / Double(max(1, $0.value.total))) }
                   .sorted { $0.count > $1.count }
           }
        }
