//
//  TodayViewModel.swift
//  AURZA
//

import Foundation
import SwiftUI

class TodayViewModel: ObservableObject {
    @Published var selectedDate = Date()
    @Published var tasks: [TaskItem] = []
    @Published var showingTaskForm = false
    @Published var showingMiniHub = false
    @Published var taskToEdit: TaskItem?
    @Published var showMotivationBanner = false
    @Published var motivationMessage = ""
    @Published var completedTaskId: UUID?
    
    private let localStore: LocalStore
    private let soundService: SoundService
    private let hapticsService: HapticsService
    private let localizationService: LocalizationService
    
    init(localStore: LocalStore, soundService: SoundService, hapticsService: HapticsService, localizationService: LocalizationService) {
        self.localStore = localStore
        self.soundService = soundService
        self.hapticsService = hapticsService
        self.localizationService = localizationService
        loadTasks()
    }
    
    func loadTasks() {
        tasks = localStore.getTasksForDate(selectedDate)
            .sorted { task1, task2 in
                if task1.isPinned != task2.isPinned {
                    return task1.isPinned
                }
                return task1.date < task2.date
            }
    }
    
    var pinnedTasks: [TaskItem] {
        tasks.filter { $0.isPinned }.prefix(3).map { $0 }
    }
    
    var regularTasks: [TaskItem] {
        tasks.filter { !$0.isPinned }
    }
    
    var taskTemplates: [TaskItem] {
        localStore.getTaskTemplates()
    }
    
    func completeTask(_ task: TaskItem) {
        localStore.completeTask(task)
        completedTaskId = task.id
        motivationMessage = localizationService.getMotivationalPhrase()
        showMotivationBanner = true
        soundService.playCompletionSound()
        hapticsService.notification(.success)
        loadTasks()
        
        // Hide banner after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.showMotivationBanner = false
            self.completedTaskId = nil
        }
    }
    
    func togglePin(_ task: TaskItem) {
        var updated = task
        updated.isPinned.toggle()
        localStore.updateTask(updated)
        hapticsService.impact(.light)
        loadTasks()
    }
    
    func deleteTask(_ task: TaskItem) {
        localStore.deleteTask(task)
        loadTasks()
    }
    
    func addTask(_ task: TaskItem) {
        localStore.addTask(task)
        loadTasks()
    }
    
    func updateTask(_ task: TaskItem) {
        localStore.updateTask(task)
        loadTasks()
    }
    
    func createTaskFromTemplate(_ template: TaskItem) {
        var newTask = template
        newTask.id = UUID()
        newTask.date = selectedDate
        newTask.isCompleted = false
        newTask.createdAt = Date()
        newTask.updatedAt = Date()
        addTask(newTask)
    }
}
