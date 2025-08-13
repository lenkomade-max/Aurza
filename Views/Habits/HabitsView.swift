//
//  HabitsView.swift
//  AURZA
//

import SwiftUI

struct HabitsView: View {
    @EnvironmentObject var localStore: LocalStore
    @EnvironmentObject var soundService: SoundService
    @EnvironmentObject var hapticsService: HapticsService
    @EnvironmentObject var localizationService: LocalizationService
    
    @StateObject private var viewModel: HabitsViewModel
    @State private var showingAddForm = false
    
    init() {
        _viewModel = StateObject(wrappedValue: HabitsViewModel(
            localStore: LocalStore(),
            soundService: SoundService(),
            hapticsService: HapticsService(),
            localizationService: LocalizationService()
        ))
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    // Week strip
                    WeekStripView(selectedDate: $viewModel.selectedDate)
                        .onChange(of: viewModel.selectedDate) { _ in
                            viewModel.loadHabits()
                        }
                    
                    // Suggested habits
                    if viewModel.habits.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(NSLocalizedString("suggested_habits", comment: ""))
                                .font(.headline)
                                .padding(.horizontal)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(viewModel.habitTemplates.prefix(5)) { template in
                                        Button(action: {
                                            viewModel.createHabitFromTemplate(template)
                                            hapticsService.impact(.light)
                                        }) {
                                            VStack(spacing: 4) {
                                                Text(template.emoji)
                                                    .font(.title2)
                                                Text(template.title)
                                                    .font(.caption)
                                                    .multilineTextAlignment(.center)
                                                Text("\(template.defaultDuration) min")
                                                    .font(.caption2)
                                                    .foregroundColor(.secondary)
                                            }
                                            .frame(width: 100, height: 100)
                                            .background(Color.accentColor.opacity(0.1))
                                            .cornerRadius(12)
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    
                    // Habits list
                    if !viewModel.habits.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(NSLocalizedString("your_habits", comment: ""))
                                .font(.headline)
                                .padding(.horizontal)
                            
                            ForEach(viewModel.habits) { habit in
                                HabitCardView(
                                    habit: habit,
                                    isCompletedToday: habit.isCompletedOnDate(viewModel.selectedDate),
                                    onComplete: { viewModel.completeHabit(habit) },
                                    onEdit: {
                                        viewModel.habitToEdit = habit
                                        showingAddForm = true
                                    },
                                    onPin: { viewModel.togglePin(habit) }
                                )
                                .padding(.horizontal)
                            }
                        }
                    } else {
                        EmptyStateView(
                            icon: "repeat",
                            title: NSLocalizedString("no_habits_title", comment: ""),
                            description: NSLocalizedString("no_habits_description", comment: ""),
                            actionTitle: NSLocalizedString("add_habit", comment: ""),
                            action: { showingAddForm = true }
                        )
                        .frame(height: 300)
                    }
                    
                    // More suggested habits
                    if !viewModel.habits.isEmpty && viewModel.habitTemplates.count > 5 {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(NSLocalizedString("more_habits", comment: ""))
                                .font(.headline)
                                .padding(.horizontal)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(viewModel.habitTemplates.suffix(5)) { template in
                                        Button(action: {
                                            viewModel.createHabitFromTemplate(template)
                                            hapticsService.impact(.light)
                                        }) {
                                            HStack {
                                                Text(template.emoji)
                                                Text(template.title)
                                                    .font(.caption)
                                            }
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 8)
                                            .background(Color.green.opacity(0.1))
                                            .cornerRadius(8)
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                }
                .padding(.bottom, 100)
            }
            .navigationTitle(NSLocalizedString("habits", comment: ""))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddForm = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showingAddForm) {
                HabitFormView(
                    habit: viewModel.habitToEdit,
                    onSave: { habit in
                        if viewModel.habitToEdit != nil {
                            viewModel.updateHabit(habit)
                        } else {
                            viewModel.addHabit(habit)
                        }
                        viewModel.habitToEdit = nil
                    }
                )
                .environmentObject(localStore)
            }
            .overlay(
                MotivationBanner(
                    message: viewModel.motivationMessage,
                    isShowing: $viewModel.showMotivationBanner
                )
            )
        }
        .onAppear {
            viewModel.loadHabits()
        }
    }
}
