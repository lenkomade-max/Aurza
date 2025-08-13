//
//  ExportImportService.swift
//  AURZA
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

class ExportImportService: ObservableObject {
    
    func exportData(store: LocalStore) -> URL? {
        let exportData = ExportData(
            version: "1.0",
            exportDate: Date(),
            tasks: store.tasks,
            habits: store.habits,
            goals: store.goals,
            tags: store.tags,
            completions: store.completions,
            journalEntries: store.journalEntries,
            notes: store.notes,
            achievements: store.achievements,
            xpLevel: store.xpLevel,
            streak: store.streak,
            settings: store.settings,
            weeklySummaries: store.weeklySummaries
        )
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        encoder.dateEncodingStrategy = .iso8601
        
        do {
            let data = try encoder.encode(exportData)
            let fileName = "AURZA_Export_\(Date().timeIntervalSince1970).json"
            let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
            try data.write(to: url)
            return url
        } catch {
            print("Export failed: \(error)")
            return nil
        }
    }
    
    func importData(from url: URL, into store: LocalStore, mergePolicy: MergePolicy = .replace) -> Bool {
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            let importData = try decoder.decode(ExportData.self, from: data)
            
            switch mergePolicy {
            case .replace:
                store.tasks = importData.tasks
                store.habits = importData.habits
                store.goals = importData.goals
                store.tags = importData.tags
                store.completions = importData.completions
                store.journalEntries = importData.journalEntries
                store.notes = importData.notes
                store.achievements = importData.achievements
                store.xpLevel = importData.xpLevel
                store.streak = importData.streak
                store.settings = importData.settings
                store.weeklySummaries = importData.weeklySummaries
                
            case .merge:
                // Merge logic - combine without duplicates
                mergeData(from: importData, into: store)
            }
            
            return true
        } catch {
            print("Import failed: \(error)")
            return false
        }
    }
    
    private func mergeData(from importData: ExportData, into store: LocalStore) {
        // Merge tasks
        for task in importData.tasks {
            if !store.tasks.contains(where: { $0.id == task.id }) {
                store.tasks.append(task)
            }
        }
        
        // Merge habits
        for habit in importData.habits {
            if !store.habits.contains(where: { $0.id == habit.id }) {
                store.habits.append(habit)
            }
        }
        
        // Merge goals
        for goal in importData.goals {
            if !store.goals.contains(where: { $0.id == goal.id }) {
                store.goals.append(goal)
            }
        }
        
        // Merge tags
        for tag in importData.tags {
            if !store.tags.contains(where: { $0.id == tag.id }) {
                store.tags.append(tag)
            }
        }
        
        // Merge completions
        for completion in importData.completions {
            if !store.completions.contains(where: { $0.id == completion.id }) {
                store.completions.append(completion)
            }
        }
        
        // Merge journal entries
        for entry in importData.journalEntries {
            if !store.journalEntries.contains(where: { $0.id == entry.id }) {
                store.journalEntries.append(entry)
            }
        }
        
        // Merge notes
        for note in importData.notes {
            if !store.notes.contains(where: { $0.id == note.id }) {
                store.notes.append(note)
            }
        }
        
        // Update XP and streak if imported data is newer
        if importData.xpLevel.totalXP > store.xpLevel.totalXP {
            store.xpLevel = importData.xpLevel
        }
        
        if importData.streak.longest > store.streak.longest {
            store.streak = importData.streak
        }
    }
    
    enum MergePolicy {
        case replace
        case merge
    }
    
    struct ExportData: Codable {
        let version: String
        let exportDate: Date
        let tasks: [TaskItem]
        let habits: [Habit]
        let goals: [Goal]
        let tags: [Tag]
        let completions: [Completion]
        let journalEntries: [JournalEntry]
        let notes: [Note]
        let achievements: [Achievement]
        let xpLevel: XPLevel
        let streak: Streak
        let settings: AppSettings
        let weeklySummaries: [WeeklySummary]
    }
}
