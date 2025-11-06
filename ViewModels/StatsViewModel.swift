//
//  StatsViewModel.swift
//  AURZA
//

import Foundation
import SwiftUI

@MainActor
class StatsViewModel: ObservableObject {
    @Published var selectedPeriod: Period = .week
    @Published var customStartDate = Date()
    @Published var customEndDate = Date()
    @Published var selectedType: Completion.CompletionType? = nil
    @Published var selectedTags: Set<Tag> = []
    @Published var selectedCategories: Set<Category> = []
    @Published var showingWeeklyReview = false
    
    private let localStore: LocalStore
    private let purchaseService: PurchaseService
    
    init(localStore: LocalStore, purchaseService: PurchaseService) {
        self.localStore = localStore
        self.purchaseService = purchaseService
    }
    
    var isProRequired: Bool {
        !purchaseService.isPro
    }
    
    var completions: [Completion] {
        var filtered = localStore.getCompletionsForPeriod(selectedPeriod)
        
        if let type = selectedType {
            filtered = filtered.filter { $0.type == type }
        }
        
        if !selectedTags.isEmpty {
            let tagNames = selectedTags.map { $0.name }
            filtered = filtered.filter { completion in
                !Set(completion.tagNames).isDisjoint(with: tagNames)
            }
        }
        
        return filtered
    }
    
    var completionRate: Double {
        localStore.getCompletionRate(for: selectedPeriod, type: selectedType)
    }
    
    var categoryBalance: [Category: Double] {
        var balance: [Category: Int] = [:]
        let goalsInPeriod = localStore.goals
        
        for goal in goalsInPeriod {
            balance[goal.category, default: 0] += goal.isCompleted ? 1 : 0
        }
        
        let total = balance.values.reduce(0, +)
        guard total > 0 else { return [:] }
        
        return balance.mapValues { Double($0) / Double(total) }
    }
    
    var heatmapData: [Date: Int] {
        localStore.getHeatmapData(for: selectedPeriod)
    }
    
    var tagAnalytics: [(tag: String, count: Int, completionRate: Double)] {
        localStore.getTagAnalytics(for: selectedPeriod)
    }
    
    var currentStreak: Int {
        localStore.streak.current
    }
    
    var longestStreak: Int {
        localStore.streak.longest
    }
    
    var xpLevel: XPLevel {
        localStore.xpLevel
    }
    
    var achievements: [Achievement] {
        localStore.achievements
    }
    
    var unlockedAchievements: [Achievement] {
        achievements.filter { $0.isUnlocked }
    }
    
    var lockedAchievements: [Achievement] {
        achievements.filter { !$0.isUnlocked }
    }
    
    func selectPeriod(_ period: Period) {
        selectedPeriod = period
    }
    
    func toggleTypeFilter(_ type: Completion.CompletionType?) {
        if selectedType == type {
            selectedType = nil
        } else {
            selectedType = type
        }
    }
    
    func toggleTag(_ tag: Tag) {
        if selectedTags.contains(tag) {
            selectedTags.remove(tag)
        } else {
            selectedTags.insert(tag)
        }
    }
    
    func toggleCategory(_ category: Category) {
        if selectedCategories.contains(category) {
            selectedCategories.remove(category)
        } else {
            selectedCategories.insert(category)
        }
    }
    
    func clearFilters() {
        selectedType = nil
        selectedTags.removeAll()
        selectedCategories.removeAll()
    }
}
