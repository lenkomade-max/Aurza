//
//  GoalCardView.swift
//  AURZA
//

import SwiftUI

struct GoalCardView: View {
    let goal: Goal
    let onProgress: () -> Void
    let onEdit: () -> Void
    let onPin: () -> Void
    
    @State private var showingProgressSheet = false
    @State private var progressAmount: String = "1"
    @EnvironmentObject var hapticsService: HapticsService
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                // D-N Badge
                Text("D-\(goal.daysUntilDeadline)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(goal.daysUntilDeadline <= 7 ? Color.red : Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(6)
                
                Text(goal.emoji)
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(goal.title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                    
                    Text(goal.motivationalMessage)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .italic()
                }
                
                Spacer()
                
                if goal.isPinned {
                    Image(systemName: "pin.fill")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
                
                Menu {
                    Button(action: onEdit) {
                        Label(NSLocalizedString("edit", comment: ""), systemImage: "pencil")
                    }
                    
                    Button(action: onPin) {
                        Label(
                            goal.isPinned ? NSLocalizedString("unpin", comment: "") : NSLocalizedString("pin", comment: ""),
                            systemImage: goal.isPinned ? "pin.slash" : "pin"
                        )
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .frame(width: 30, height: 30)
                }
            }
            
            // Progress bar
            if let target = goal.target, let current = goal.current {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("\(Int(current))")
                            .font(.caption)
                            .fontWeight(.medium)
                        
                        Spacer()
                        
                        Text("\(goal.progressPercentage)%")
                            .font(.caption)
                            .fontWeight(.medium)
                        
                        Spacer()
                        
                        Text("\(Int(target))")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 8)
                            
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color(rgbaColor: goal.color))
                                .frame(width: geometry.size.width * goal.progress, height: 8)
                        }
                    }
                    .frame(height: 8)
                }
            }
            
            HStack {
                // Category
                Label(goal.category.localizedName, systemImage: goal.category.icon)
                    .font(.caption)
                    .foregroundColor(goal.category.color)
                
                // Tags
                ForEach(goal.tags.prefix(2)) { tag in
                    TagChipView(tag: tag, size: .small)
                }
                
                Spacer()
                
                // Reminders button
                if !goal.reminders.isEmpty {
                    Button(action: {}) {
                        Image(systemName: "bell.fill")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
                
                // Progress button
                if goal.target != nil && !goal.isCompleted {
                    Button(action: {
                        showingProgressSheet = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                            .foregroundColor(Color(rgbaColor: goal.color))
                    }
                }
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(12)
        .sheet(isPresented: $showingProgressSheet) {
            NavigationView {
                VStack(spacing: 20) {
                    Text(NSLocalizedString("add_progress", comment: ""))
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    TextField(NSLocalizedString("amount", comment: ""), text: $progressAmount)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    
                    Button(action: {
                        if let amount = Double(progressAmount) {
                            showingProgressSheet = false
                            onProgress()
                            hapticsService.notification(.success)
                        }
                    }) {
                        Text(NSLocalizedString("add", comment: ""))
                            .fontWeight(.medium)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .padding()
                .navigationBarItems(
                    leading: Button(NSLocalizedString("cancel", comment: "")) {
                        showingProgressSheet = false
                    }
                )
            }
        }
    }
}
