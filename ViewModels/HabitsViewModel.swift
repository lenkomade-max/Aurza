//
//  HabitsViewModel.swift
//  AURZA
//

import Foundation
import SwiftUI

class HabitsViewModel: ObservableObject {
    @Published var selectedDate = Date()
    @Published var habits: [Habit] = []
    @Published var showingHabitForm = false
    @Published var habitToEdit: Habit?
    @Published var showMotivationBanner = false
    @Published var motivationMessage = ""
    
    private let localStore: LocalStore
    private let soundService: SoundService
    private let hapticsService: HapticsService
    private let localizationService: LocalizationService
    
    init(localStore: LocalStore, soundService: SoundService, hapticsService: HapticsService, localizationService: LocalizationService) {
        self.localStore = localStore
        self.soundService = soundService
        self.hapticsService = hapticsService
        self.localizationService = localizationService
        loadHabits()
    }
    
    func loadHabits() {
        habits = localStore.getHabitsForDate(selectedDate)
            .sorted { habit1, habit2 in
                if habit1.isPinned != habit2.isPinned {
                    return habit1.isPinned
                }
                return habit1.title < habit2.title
            }
    }
    
    var habitTemplates: [Habit] {
        localStore.getHabitTemplates()
    }
    
    func completeHabit(_ habit: Habit) {
        if !habit.isCompletedOnDate(selectedDate) {
            localStore.completeHabit(habit, date: selectedDate)
            motivationMessage = localizationService.getMotivationalPhrase()
            showMotivationBanner = true
            soundService.playCompletionSound()
            hapticsService.notification(.success)
            loadHabits()
            
            // Hide banner after 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.showMotivationBanner = false
            }
        }
    }
    
    func togglePin(_ habit: Habit) {
        var updated = habit
        updated.isPinned.toggle()
        localStore.updateHabit(updated)
        hapticsService.impact(.light)
        loadHabits()
    }
    
    func deleteHabit(_ habit: Habit) {
        localStore.deleteHabit(habit)
        loadHabits()
    }
    
    func addHabit(_ habit: Habit) {
        localStore.addHabit(habit)
        loadHabits()
    }
    
    func updateHabit(_ habit: Habit) {
        localStore.updateHabit(habit)
        loadHabits()
    }
    
    func createHabitFromTemplate(_ template: Habit) {
        var newHabit = template
        newHabit.id = UUID()
        newHabit.createdAt = Date()
        newHabit.updatedAt = Date()
        addHabit(newHabit)
    }
}
