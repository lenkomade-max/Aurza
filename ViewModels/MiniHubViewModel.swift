//
//  MiniHubViewModel.swift
//  AURZA
//

import Foundation
import SwiftUI
import PhotosUI

@MainActor
class MiniHubViewModel: ObservableObject {
    @Published var selectedTab = 0 // 0: Diary, 1: Notes
    @Published var searchText = ""
    @Published var selectedDate = Date()
    @Published var showingEntryForm = false
    @Published var showingNoteForm = false
    @Published var entryToEdit: JournalEntry?
    @Published var noteToEdit: Note?
    @Published var showArchivedNotes = false
    
    private let localStore: LocalStore
    private let purchaseService: PurchaseService
    
    init(localStore: LocalStore, purchaseService: PurchaseService) {
        self.localStore = localStore
        self.purchaseService = purchaseService
    }
    
    var isProRequired: Bool {
        !purchaseService.isPro
    }
    
    var combinedView: Bool {
        localStore.settings.combineDiaryAndNotes
    }
    
    var journalEntries: [JournalEntry] {
        let filtered = localStore.journalEntries.filter { entry in
            if !searchText.isEmpty {
                return entry.text.localizedCaseInsensitiveContains(searchText) ||
                       entry.dailyAnswer?.localizedCaseInsensitiveContains(searchText) == true ||
                       entry.tags.contains { $0.name.localizedCaseInsensitiveContains(searchText) }
            }
            return true
        }
        
        return filtered.sorted { $0.date > $1.date }
    }
    
    var notes: [Note] {
        let filtered = localStore.notes.filter { note in
            if showArchivedNotes {
                if !note.isArchived { return false }
            } else {
                if note.isArchived { return false }
            }
            
            if !searchText.isEmpty {
                return note.title.localizedCaseInsensitiveContains(searchText) ||
                       note.text?.localizedCaseInsensitiveContains(searchText) == true ||
                       note.tags.contains { $0.name.localizedCaseInsensitiveContains(searchText) }
            }
            return true
        }
        
        return filtered.sorted { note1, note2 in
            if note1.isPinned != note2.isPinned {
                return note1.isPinned
            }
            return note1.updatedAt > note2.updatedAt
        }
    }
    
    var diaryStreak: Int {
        let calendar = Calendar.current
        var streak = 0
        var checkDate = Date()
        
        while true {
            if journalEntries.contains(where: { calendar.isDate($0.date, inSameDayAs: checkDate) }) {
                streak += 1
                checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate) ?? checkDate
            } else {
                break
            }
        }
        
        return streak
    }
    
    func addJournalEntry(_ entry: JournalEntry) {
        localStore.addJournalEntry(entry)
    }
    
    func updateJournalEntry(_ entry: JournalEntry) {
        localStore.updateJournalEntry(entry)
    }
    
    func deleteJournalEntry(_ entry: JournalEntry) {
        localStore.deleteJournalEntry(entry)
    }
    
    func addNote(_ note: Note) {
        localStore.addNote(note)
    }
    
    func updateNote(_ note: Note) {
        localStore.updateNote(note)
    }
    
    func archiveNote(_ note: Note) {
        localStore.archiveNote(note)
    }
    
    func toggleNotePin(_ note: Note) {
        var updated = note
        updated.isPinned.toggle()
        updateNote(updated)
    }
    
    func toggleChecklistItem(_ note: Note, item: ChecklistItem) {
        var updated = note
        if let index = updated.checklistItems.firstIndex(where: { $0.id == item.id }) {
            updated.checklistItems[index].isDone.toggle()
            updateNote(updated)
        }
    }
    
    func getDailyQuestion() -> String {
        let questions = [
            NSLocalizedString("daily_question_1", comment: ""),
            NSLocalizedString("daily_question_2", comment: ""),
            NSLocalizedString("daily_question_3", comment: ""),
            NSLocalizedString("daily_question_4", comment: ""),
            NSLocalizedString("daily_question_5", comment: ""),
            NSLocalizedString("daily_question_6", comment: ""),
            NSLocalizedString("daily_question_7", comment: ""),
            NSLocalizedString("daily_question_8", comment: ""),
            NSLocalizedString("daily_question_9", comment: ""),
            NSLocalizedString("daily_question_10", comment: "")
        ]
        
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: selectedDate) ?? 1
        return questions[dayOfYear % questions.count]
    }
}
