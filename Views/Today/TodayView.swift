//
//  TodayView.swift
//  AURZA
//

import SwiftUI

struct TodayView: View {
    @EnvironmentObject var localStore: LocalStore
    @EnvironmentObject var soundService: SoundService
    @EnvironmentObject var hapticsService: HapticsService
    @EnvironmentObject var localizationService: LocalizationService
    @EnvironmentObject var onboardingService: OnboardingService
    
    @State private var selectedDate = Date()
    @State private var showingAddForm = false
    @State private var taskToEdit: TaskItem?
    @State private var showMotivationBanner = false
    @State private var motivationMessage = ""
    @State private var completedTaskId: UUID?
    @State private var showingMiniHub = false
    
    private var tasksForSelectedDate: [TaskItem] {
        localStore.getTasksForDate(selectedDate)
            .sorted { task1, task2 in
                if task1.isPinned != task2.isPinned {
                    return task1.isPinned
                }
                return task1.date < task2.date
            }
    }
    
    private var pinnedTasks: [TaskItem] {
        tasksForSelectedDate.filter { $0.isPinned }.prefix(3).map { $0 }
    }
    
    private var regularTasks: [TaskItem] {
        tasksForSelectedDate.filter { !$0.isPinned }
    }
    
    private var taskTemplates: [TaskItem] {
        localStore.getTaskTemplates()
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                ScrollView {
                    VStack(spacing: 16) {
                        // AURZA Title - только на Today
                        Text("AURZA")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                        
                        // Week strip
                        WeekStripView(selectedDate: $selectedDate)
                            .overlay(
                                onboardingService.hasSeenWeekStripHint ? nil :
                                HintOverlay(
                                    text: NSLocalizedString("hint_week_strip", comment: ""),
                                    onDismiss: {
                                        onboardingService.hasSeenWeekStripHint = true
                                    }
                                )
                            )
                        
                        // Pinned tasks (max 3, -50% XP)
                        if !pinnedTasks.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(NSLocalizedString("pinned_tasks", comment: ""))
                                    .font(.headline)
                                    .padding(.horizontal)
                                
                                ForEach(pinnedTasks) { task in
                                    TaskCardView(
                                        task: task,
                                        onComplete: { completeTask(task) },
                                        onEdit: {
                                            taskToEdit = task
                                            showingAddForm = true
                                        },
                                        onPin: { togglePin(task) },
                                        isPinned: true
                                    )
                                    .padding(.horizontal)
                                }
                            }
                        }
                        
                        // Regular tasks
                        if !regularTasks.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(NSLocalizedString("tasks", comment: ""))
                                    .font(.headline)
                                    .padding(.horizontal)
                                
                                ForEach(regularTasks) { task in
                                    TaskCardView(
                                        task: task,
                                        onComplete: { completeTask(task) },
                                        onEdit: {
                                            taskToEdit = task
                                            showingAddForm = true
                                        },
                                        onPin: { togglePin(task) },
                                        isPinned: false
                                    )
                                    .padding(.horizontal)
                                }
                            }
                        } else if pinnedTasks.isEmpty {
                            EmptyStateView(
                                icon: "checklist",
                                title: NSLocalizedString("no_tasks_title", comment: ""),
                                description: NSLocalizedString("no_tasks_description", comment: ""),
                                actionTitle: NSLocalizedString("add_task", comment: ""),
                                action: { showingAddForm = true }
                            )
                            .frame(height: 300)
                        }
                        
                        // Task templates (10 предложенных)
                        VStack(alignment: .leading, spacing: 8) {
                            Text(NSLocalizedString("suggested_tasks", comment: ""))
                                .font(.headline)
                                .padding(.horizontal)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(taskTemplates) { template in
                                        Button(action: {
                                            createTaskFromTemplate(template)
                                            hapticsService.impact(.light)
                                        }) {
                                            HStack {
                                                Text(template.emoji)
                                                Text(template.title)
                                                    .font(.caption)
                                            }
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 8)
                                            .background(Color.accentColor.opacity(0.1))
                                            .cornerRadius(8)
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding(.bottom, 100)
                    }
                }
                
                // Motivation banner
                MotivationBanner(
                    message: motivationMessage,
                    isShowing: $showMotivationBanner
                )
                
                // Mini Hub swipe indicator (правый край)
                HStack {
                    Spacer()
                    
                    Rectangle()
                        .fill(Color.accentColor.opacity(0.3))
                        .frame(width: 20)
                        .overlay(
                            Text("📓")
                                .font(.title2)
                        )
                        .onTapGesture {
                            withAnimation(.spring()) {
                                showingMiniHub = true
                            }
                        }
                }
                .edgesIgnoringSafeArea(.horizontal)
                .overlay(
                    !onboardingService.hasSeenMiniHubHint ?
                    HintOverlay(
                        text: NSLocalizedString("hint_minihub", comment: ""),
                        onDismiss: {
                            onboardingService.hasSeenMiniHubHint = true
                        }
                    )
                    .offset(x: -100)
                    : nil
                )
            }
            .navigationBarHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddForm = true
                        if !onboardingService.hasSeenAddButtonHint {
                            onboardingService.hasSeenAddButtonHint = true
                        }
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showingAddForm) {
                TaskFormView(
                    task: taskToEdit,
                    onSave: { task in
                        if taskToEdit != nil {
                            localStore.updateTask(task)
                        } else {
                            localStore.addTask(task)
                        }
                        taskToEdit = nil
                    }
                )
                .environmentObject(localStore)
            }
            .sheet(isPresented: $showingMiniHub) {
                MiniHubView()
                    .environmentObject(localStore)
                    .environmentObject(purchaseService)
            }
            .gesture(
                DragGesture()
                    .onChanged { value in
                        if value.translation.width < -50 {
                            withAnimation(.spring()) {
                                showingMiniHub = true
                            }
                        }
                    }
            )
        }
    }
    
    private func completeTask(_ task: TaskItem) {
        localStore.completeTask(task)
        completedTaskId = task.id
        motivationMessage = localizationService.getMotivationalPhrase()
        showMotivationBanner = true
        soundService.playCompletionSound()
        hapticsService.notification(.success)
        
        // Hide banner after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            showMotivationBanner = false
            completedTaskId = nil
        }
    }
    
    private func togglePin(_ task: TaskItem) {
        var updated = task
        updated.isPinned.toggle()
        localStore.updateTask(updated)
        hapticsService.impact(.light)
    }
    
    private func createTaskFromTemplate(_ template: TaskItem) {
        var newTask = template
        newTask.id = UUID()
        newTask.date = selectedDate
        newTask.createdAt = Date()
        newTask.updatedAt = Date()
        localStore.addTask(newTask)
    }
}

struct HintOverlay: View {
    let text: String
    let onDismiss: () -> Void
    
    var body: some View {
        VStack {
            Text(text)
                .font(.caption)
                .foregroundColor(.white)
                .padding(8)
                .background(Color.black.opacity(0.8))
                .cornerRadius(8)
            
            Image(systemName: "arrowtriangle.up.fill")
                .font(.caption)
                .foregroundColor(.black.opacity(0.8))
                .offset(y: -4)
        }
        .onTapGesture {
            onDismiss()
        }
    }
}
