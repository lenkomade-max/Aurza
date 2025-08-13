//
//  StatsView.swift
//  AURZA
//

import SwiftUI

struct StatsView: View {
    @EnvironmentObject var localStore: LocalStore
    @EnvironmentObject var purchaseService: PurchaseService
    
    @StateObject private var viewModel: StatsViewModel
    @State private var showingPaywall = false
    @State private var showConfetti = false
    
    init() {
        _viewModel = StateObject(wrappedValue: StatsViewModel(
            localStore: LocalStore(),
            purchaseService: PurchaseService()
        ))
    }
    
    var body: some View {
        NavigationView {
            if viewModel.isProRequired {
                VStack(spacing: 20) {
                    Image(systemName: "chart.xyaxis.line")
                        .font(.system(size: 60))
                        .foregroundColor(.secondary)
                    
                    Text(NSLocalizedString("stats_pro_title", comment: ""))
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text(NSLocalizedString("stats_pro_description", comment: ""))
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    
                    Button(action: { showingPaywall = true }) {
                        Text(NSLocalizedString("unlock_pro", comment: ""))
                            .fontWeight(.medium)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal, 40)
                }
                .navigationTitle(NSLocalizedString("stats", comment: ""))
                .sheet(isPresented: $showingPaywall) {
                    PaywallView(isPresented: $showingPaywall)
                        .environmentObject(purchaseService)
                }
            } else {
                ScrollView {
                    VStack(spacing: 16) {
                        // Period selector
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(Period.allCases, id: \.self) { period in
                                    Button(action: { viewModel.selectPeriod(period) }) {
                                        Text(period.localizedName)
                                            .font(.caption)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(viewModel.selectedPeriod == period ? Color.accentColor : Color.gray.opacity(0.2))
                                            .foregroundColor(viewModel.selectedPeriod == period ? .white : .primary)
                                            .cornerRadius(8)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        // Filters
                        VStack(alignment: .leading, spacing: 8) {
                            Text(NSLocalizedString("filters", comment: ""))
                                .font(.headline)
                                .padding(.horizontal)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    // Type filters
                                    ForEach([Completion.CompletionType.task, .habit, .goal], id: \.self) { type in
                                        Button(action: { viewModel.toggleTypeFilter(type) }) {
                                            Text(type.rawValue.capitalized)
                                                .font(.caption)
                                                .padding(.horizontal, 10)
                                                .padding(.vertical, 4)
                                                .background(viewModel.selectedType == type ? Color.blue : Color.gray.opacity(0.2))
                                                .foregroundColor(viewModel.selectedType == type ? .white : .primary)
                                                .cornerRadius(6)
                                        }
                                    }
                                    
                                    Divider()
                                        .frame(height: 20)
                                    
                                    // Tag filters
                                    ForEach(localStore.tags) { tag in
                                        TagChipView(
                                            tag: tag,
                                            size: .small,
                                            isSelected: viewModel.selectedTags.contains(tag),
                                            onTap: { viewModel.toggleTag(tag) }
                                        )
                                    }
                                    
                                    if viewModel.selectedType != nil || !viewModel.selectedTags.isEmpty {
                                        Button(action: { viewModel.clearFilters() }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        
                        // Rings
                        MultiRingView(rings: [
                            (NSLocalizedString("tasks", comment: ""), viewModel.completionRate, .blue),
                            (NSLocalizedString("habits", comment: ""), Double(viewModel.currentStreak)
                             / 30.0, .green),
                                                         (NSLocalizedString("goals", comment: ""), Double(viewModel.achievements.filter { $0.isUnlocked }.count) / Double(max(1, viewModel.achievements.count)), .purple)
                                                     ])
                                                     .padding(.horizontal)
                                                     
                                                     // Trend Graph
                                                     TrendGraphView(
                                                         data: viewModel.heatmapData,
                                                         period: viewModel.selectedPeriod,
                                                         color: .accentColor
                                                     )
                                                     .padding(.horizontal)
                                                     
                                                     // Heatmap
                                                     HeatmapView(
                                                         data: viewModel.heatmapData,
                                                         period: viewModel.selectedPeriod
                                                     )
                                                     .padding(.horizontal)
                                                     
                                                     // Streaks & Achievements
                                                     VStack(alignment: .leading, spacing: 12) {
                                                         Text(NSLocalizedString("streaks_achievements", comment: ""))
                                                             .font(.headline)
                                                             .padding(.horizontal)
                                                         
                                                         HStack(spacing: 20) {
                                                             VStack {
                                                                 Image(systemName: "flame.fill")
                                                                     .font(.title)
                                                                     .foregroundColor(.orange)
                                                                 Text("\(viewModel.currentStreak)")
                                                                     .font(.title2)
                                                                     .fontWeight(.bold)
                                                                 Text(NSLocalizedString("current_streak", comment: ""))
                                                                     .font(.caption)
                                                                     .foregroundColor(.secondary)
                                                             }
                                                             .frame(maxWidth: .infinity)
                                                             
                                                             VStack {
                                                                 Image(systemName: "crown.fill")
                                                                     .font(.title)
                                                                     .foregroundColor(.yellow)
                                                                 Text("\(viewModel.longestStreak)")
                                                                     .font(.title2)
                                                                     .fontWeight(.bold)
                                                                 Text(NSLocalizedString("longest_streak", comment: ""))
                                                                     .font(.caption)
                                                                     .foregroundColor(.secondary)
                                                             }
                                                             .frame(maxWidth: .infinity)
                                                         }
                                                         .padding()
                                                         .background(Color(UIColor.secondarySystemGroupedBackground))
                                                         .cornerRadius(12)
                                                         .padding(.horizontal)
                                                         
                                                         // Achievements grid
                                                         LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                                                             ForEach(viewModel.achievements) { achievement in
                                                                 AchievementBadge(achievement: achievement)
                                                                     .onTapGesture {
                                                                         if achievement.isUnlocked && !showConfetti {
                                                                             showConfetti = true
                                                                             DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                                                                 showConfetti = false
                                                                             }
                                                                         }
                                                                     }
                                                             }
                                                         }
                                                         .padding(.horizontal)
                                                     }
                                                     
                                                     // XP Level
                                                     VStack(alignment: .leading, spacing: 12) {
                                                         Text(NSLocalizedString("xp_level", comment: ""))
                                                             .font(.headline)
                                                             .padding(.horizontal)
                                                         
                                                         VStack(spacing: 8) {
                                                             HStack {
                                                                 Text(viewModel.xpLevel.levelTitle)
                                                                     .font(.caption)
                                                                     .foregroundColor(.secondary)
                                                                 Spacer()
                                                                 Text("Level \(viewModel.xpLevel.level)")
                                                                     .font(.headline)
                                                             }
                                                             
                                                             ProgressView(value: viewModel.xpLevel.xpProgress)
                                                                 .progressViewStyle(LinearProgressViewStyle())
                                                                 .accentColor(.purple)
                                                             
                                                             HStack {
                                                                 Text("\(viewModel.xpLevel.currentXP) XP")
                                                                     .font(.caption)
                                                                 Spacer()
                                                                 Text("\(viewModel.xpLevel.xpForNextLevel) XP")
                                                                     .font(.caption)
                                                             }
                                                             .foregroundColor(.secondary)
                                                         }
                                                         .padding()
                                                         .background(Color(UIColor.secondarySystemGroupedBackground))
                                                         .cornerRadius(12)
                                                         .padding(.horizontal)
                                                     }
                                                     
                                                     // Tag Analytics
                                                     VStack(alignment: .leading, spacing: 12) {
                                                         Text(NSLocalizedString("tag_analytics", comment: ""))
                                                             .font(.headline)
                                                             .padding(.horizontal)
                                                         
                                                         ForEach(viewModel.tagAnalytics.prefix(5), id: \.tag) { item in
                                                             HStack {
                                                                 if let tag = localStore.tags.first(where: { $0.name == item.tag }) {
                                                                     TagChipView(tag: tag, size: .regular)
                                                                 } else {
                                                                     Text(item.tag)
                                                                         .font(.caption)
                                                                 }
                                                                 
                                                                 Spacer()
                                                                 
                                                                 VStack(alignment: .trailing) {
                                                                     Text("\(item.count) " + NSLocalizedString("completions", comment: ""))
                                                                         .font(.caption)
                                                                     Text("\(Int(item.completionRate * 100))%")
                                                                         .font(.caption2)
                                                                         .foregroundColor(.secondary)
                                                                 }
                                                             }
                                                             .padding(.horizontal)
                                                             .padding(.vertical, 4)
                                                         }
                                                         .padding(.vertical, 8)
                                                         .background(Color(UIColor.secondarySystemGroupedBackground))
                                                         .cornerRadius(12)
                                                         .padding(.horizontal)
                                                     }
                                                     
                                                     // Weekly Review button
                                                     Button(action: { viewModel.showingWeeklyReview = true }) {
                                                         HStack {
                                                             Image(systemName: "calendar.badge.clock")
                                                             Text(NSLocalizedString("weekly_review", comment: ""))
                                                                 .fontWeight(.medium)
                                                         }
                                                         .frame(maxWidth: .infinity)
                                                         .padding()
                                                         .background(Color.accentColor.opacity(0.1))
                                                         .foregroundColor(.accentColor)
                                                         .cornerRadius(10)
                                                     }
                                                     .padding(.horizontal)
                                                     .padding(.bottom, 100)
                                                 }
                                             }
                                             .navigationTitle(NSLocalizedString("stats", comment: ""))
                                             .overlay(
                                                 ZStack {
                                                     if showConfetti {
                                                         ConfettiView(trigger: showConfetti)
                                                     }
                                                 }
                                             )
                                         }
                                     }
                                     .onAppear {
                                         viewModel.objectWillChange.send()
                                     }
                                 }
                             }

                             struct AchievementBadge: View {
                                 let achievement: Achievement
                                 
                                 var body: some View {
                                     VStack(spacing: 4) {
                                         ZStack {
                                             Circle()
                                                 .fill(achievement.isUnlocked ? Color.yellow.opacity(0.2) : Color.gray.opacity(0.1))
                                                 .frame(width: 60, height: 60)
                                             
                                             Text(achievement.icon)
                                                 .font(.title2)
                                                 .opacity(achievement.isUnlocked ? 1 : 0.3)
                                             
                                             if !achievement.isUnlocked {
                                                 Circle()
                                                     .trim(from: 0, to: achievement.progressPercentage)
                                                     .stroke(Color.accentColor, lineWidth: 3)
                                                     .rotationEffect(.degrees(-90))
                                                     .frame(width: 60, height: 60)
                                             }
                                         }
                                         
                                         Text(achievement.name)
                                             .font(.caption2)
                                             .lineLimit(2)
                                             .multilineTextAlignment(.center)
                                     }
                                 }
                             }
