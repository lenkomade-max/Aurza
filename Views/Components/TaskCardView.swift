//
//  TaskCardView.swift
//  AURZA
//

import SwiftUI

struct TaskCardView: View {
    let task: TaskItem
    let onComplete: () -> Void
    let onEdit: () -> Void
    let onPin: () -> Void
    let isPinned: Bool
    
    @State private var isCompleted = false
    @EnvironmentObject var hapticsService: HapticsService
    
    var body: some View {
        HStack(spacing: 12) {
            // Completion button
            Button(action: {
                withAnimation(.spring()) {
                    isCompleted = true
                    hapticsService.impact(.light)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        onComplete()
                    }
                }
            }) {
                Circle()
                    .strokeBorder(Color(rgbaColor: task.color), lineWidth: 2)
                    .background(
                        Circle()
                            .fill(isCompleted ? Color(rgbaColor: task.color) : Color.clear)
                    )
                    .overlay(
                        Image(systemName: "checkmark")
                            .font(.caption)
                            .foregroundColor(.white)
                            .opacity(isCompleted ? 1 : 0)
                    )
                    .frame(width: 24, height: 24)
            }
            
            // Task content
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(task.emoji)
                        .font(.title3)
                    
                    Text(task.title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                        .strikethrough(isCompleted)
                    
                    if isPinned {
                        Text("-50%")
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(4)
                    }
                    
                    Spacer()
                }
                
                if let description = task.description {
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                HStack(spacing: 4) {
                    if !task.reminders.isEmpty {
                        Image(systemName: "bell.fill")
                            .font(.caption2)
                            .foregroundColor(.orange)
                    }
                    
                    if task.repeatRule != nil {
                        Image(systemName: "repeat")
                            .font(.caption2)
                            .foregroundColor(.blue)
                    }
                    
                    ForEach(task.tags.prefix(3)) { tag in
                        TagChipView(tag: tag, size: .small)
                    }
                    
                    Spacer()
                    
                    Text(task.date, style: .time)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Actions
            Menu {
                Button(action: onEdit) {
                    Label(NSLocalizedString("edit", comment: ""), systemImage: "pencil")
                }
                
                Button(action: onPin) {
                    Label(
                        isPinned ? NSLocalizedString("unpin", comment: "") : NSLocalizedString("pin", comment: ""),
                        systemImage: isPinned ? "pin.slash" : "pin"
                    )
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .frame(width: 30, height: 30)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
}
