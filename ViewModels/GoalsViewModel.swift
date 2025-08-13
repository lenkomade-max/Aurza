//
//  GoalsViewModel.swift
//  AURZA
//

import Foundation
import SwiftUI

class GoalsViewModel: ObservableObject {
    @Published var selectedDate = Date()
    @Published var selectedCategory: Category? = nil
    @Published var goals: [Goal] = []
    @Published var showingGoalForm = false
    @Published var goalToEdit: Goal?
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
        loadGoals()
    }
    
    func loadGoals() {
        var filteredGoals = localStore.goals
        
        if let category = selectedCategory {
            filteredGoals = filteredGoals.filter { $0.category == category }
        }
        
        goals = filteredGoals.sorted { goal1, goal2 in
            if goal1.isPinned != goal2.isPinned {
                return goal1.isPinned
            }
            return goal1.daysUntilDeadline < goal2.daysUntilDeadline
        }
    }
    
    var goalTemplates: [Goal] {
        localStore.getGoalTemplates()
    }
    
    func progressGoal(_ goal: Goal, amount: Double? = nil) {
        let progressAmount = amount ?? 1.0
        localStore.progressGoal(goal, amount: progressAmount)
        
        if goal.isCompleted {
            motivationMessage = goal.motivationalMessage
            showMotivationBanner = true
            soundService.playAchievementSound()
            hapticsService.notification(.success)
        } else {
            soundService.playCompletionSound()
            hapticsService.impact(.medium)
        }
        
        loadGoals()
        
        if showMotivationBanner {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.showMotivationBanner = false
            }
        }
    }
    
    func togglePin(_ goal: Goal) {
        var updated = goal
        updated.isPinned.toggle()
        localStore.updateGoal(updated)
        hapticsService.impact(.light)
        loadGoals()
    }
    
    func deleteGoal(_ goal: Goal) {
        localStore.deleteGoal(goal)
        loadGoals()
    }
    
    func addGoal(_ goal: Goal) {
        localStore.addGoal(goal)
        loadGoals()
    }
    
    func updateGoal(_ goal: Goal) {
        localStore.updateGoal(goal)
        loadGoals()
    }
    
    func createGoalFromTemplate(_ template: Goal) {
        var newGoal = template
        newGoal.id = UUID()
        newGoal.createdAt = Date()
        newGoal.updatedAt = Date()
        newGoal.deadline = Date().addingTimeInterval(30 * 24 * 60 * 60)
        addGoal(newGoal)
    }
    
    func selectCategory(_ category: Category?) {
        selectedCategory = category
        loadGoals()
    }
}
