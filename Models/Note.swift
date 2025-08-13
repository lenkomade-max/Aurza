//
//  Note.swift
//  AURZA
//

import Foundation

struct Note: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var text: String?
    var isChecklist: Bool
    var checklistItems: [ChecklistItem]
    var tags: [Tag]
    var photoURLs: [URL]
    var audioURLs: [URL]
    var isPinned: Bool
    var isArchived: Bool
    let createdAt: Date
    var updatedAt: Date
    
    init(
        id: UUID = UUID(),
        title: String,
        text: String? = nil,
        isChecklist: Bool = false,
        checklistItems: [ChecklistItem] = [],
        tags: [Tag] = [],
        photoURLs: [URL] = [],
        audioURLs: [URL] = [],
        isPinned: Bool = false,
        isArchived: Bool = false,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.text = text
        self.isChecklist = isChecklist
        self.checklistItems = checklistItems
        self.tags = tags
        self.photoURLs = photoURLs
        self.audioURLs = audioURLs
        self.isPinned = isPinned
        self.isArchived = isArchived
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    var completedChecklistCount: Int {
        checklistItems.filter { $0.isDone }.count
    }
    
    var checklistProgress: Double {
        guard !checklistItems.isEmpty else { return 0 }
        return Double(completedChecklistCount) / Double(checklistItems.count)
    }
}
