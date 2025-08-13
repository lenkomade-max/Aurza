//
//  GoalsView.swift
//  AURZA
//

import SwiftUI

struct GoalsView: View {
    @EnvironmentObject var localStore: LocalStore
    @EnvironmentObject var soundService: SoundService
    @EnvironmentObject var hapticsService: HapticsService
    @EnvironmentObject var localizationService: LocalizationService
    @EnvironmentObject var onboardingService: OnboardingService
    
    @StateObject private var viewModel: GoalsViewModel
    @State private var showingAddForm = false
    
    init() {
        _viewModel = StateObject(wrappedValue: GoalsViewModel(
            localStore: LocalStore(),
            soundService: SoundService(),
            hapticsService: HapticsService(),
            localizationService: LocalizationService()
        ))
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Week strip
                WeekStripView(selectedDate: $viewModel.selectedDate)
                    .padding(.bottom, 8)
                
                // Category filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        CategoryButton(
                            category: nil,
                            isSelected: viewModel.selectedCategory == nil,
                            onTap: { viewModel.selectCategory(nil) }
                        )
                        
                        ForEach(Category.allCases, id: \.self) { category in
                            CategoryButton(
                                category: category,
                                isSelected: viewModel.selectedCategory == category,
                                onTap: { viewModel.selectCategory(category) }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 8)
                .overlay(
                    !onboardingService.hasSeenCategoriesHint ?
                    HintOverlay(
                        text: NSLocalizedString("hint_categories", comment: ""),
                        onDismiss: {
                            onboardingService.hasSeenCategoriesHint = true
                        }
                    ) : nil
                )
                
                ScrollView {
                    VStack(spacing: 16) {
                        // Goals list
                        if !viewModel.goals.isEmpty {
                            ForEach(viewModel.goals) { goal in
                                GoalCardView(
                                    goal: goal,
                                    onProgress: {
                                        viewModel.progressGoal(goal)
                                    },
                                    onEdit: {
                                        viewModel.goalToEdit = goal
                                        showingAddForm = true
                                    },
                                    onPin: { viewModel.togglePin(goal) }
                                )
                                .padding(.horizontal)
                            }
                        } else {
                            EmptyStateView(
                                icon: "target",
                                title: NSLocalizedString("no_goals_title", comment: ""),
                                description: NSLocalizedString("no_goals_description", comment: ""),
                                actionTitle: NSLocalizedString("add_goal", comment: ""),
                                action: { showingAddForm = true }
                            )
                            .frame(height: 300)
                        }
                        
                        // Suggested goals
                        VStack(alignment: .leading, spacing: 8) {
                            Text(NSLocalizedString("suggested_goals", comment: ""))
                                .font(.headline)
                                .padding(.horizontal)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(viewModel.goalTemplates.prefix(5)) { template in
                                        Button(action: {
                                            viewModel.createGoalFromTemplate(template)
                                            hapticsService.impact(.light)
                                        }) {
                                            VStack(alignment: .leading, spacing: 4) {
                                                HStack {
                                                    Text(template.emoji)
                                                        .font(.title2)
                                                    Text(template.category.localizedName)
                                                        .font(.caption2)
                                                        .padding(.horizontal, 6)
                                                        .padding(.vertical, 2)
                                                        .background(template.category.color.opacity(0.2))
                                                        .cornerRadius(4)
                                                }
                                                
                                                Text(template.title)
                                                    .font(.caption)
                                                    .foregroundColor(.primary)
                                                    .multilineTextAlignment(.leading)
                                                
                                                if let target = template.target {
                                                    Text("Target: \(Int(target))")
                                                        .font(.caption2)
                                                        .foregroundColor(.secondary)
                                                }
                                            }
                                            .frame(width: 150, height: 100, alignment: .topLeading)
                                            .padding(8)
                                            .background(Color.purple.opacity(0.1))
                                            .cornerRadius(12)
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding(.bottom, 100)
                    }
                }
            }
            .navigationTitle(NSLocalizedString("goals", comment: ""))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddForm = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showingAddForm) {
                GoalFormView(
                    goal: viewModel.goalToEdit,
                    onSave: { goal in
                        if viewModel.goalToEdit != nil {
                            viewModel.updateGoal(goal)
                        } else {
                            viewModel.addGoal(goal)
                        }
                        viewModel.goalToEdit = nil
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
            viewModel.loadGoals()
        }
    }
}

struct CategoryButton: View {
    let category: Category?
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 4) {
                if let category = category {
                    Image(systemName: category.icon)
                        .font(.caption)
                    Text(category.localizedName)
                        .font(.caption)
                } else {
                    Image(systemName: "square.grid.2x2")
                        .font(.caption)
                    Text(NSLocalizedString("all", comment: ""))
                        .font(.caption)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? (category?.color ?? .accentColor) : Color.gray.opacity(0.2))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(8)
        }
    }
}
