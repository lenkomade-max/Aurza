//
//  Completion.swift
//  AURZA
//

import Foundation

struct Completion: Identifiable, Codable, Equatable {
    let id: UUID
    var date: Date
    var type: CompletionType
    var itemId: UUID
    var itemTitle: String
    var tagNames: [String]
    var xpEarned: Int
    var duration: Int? // in minutes, for habits
    
    enum CompletionType: String, Codable {
        case task = "task"
        case habit = "habit"
        case goal = "goal"
    }
    
    init(
        id: UUID = UUID(),
        date: Date = Date(),
        type: CompletionType,
        itemId: UUID,
        itemTitle: String,
        tagNames: [String] = [],
        xpEarned: Int = 10,
        duration: Int? = nil
    ) {
        self.id = id
        self.date = date
        self.type = type
        self.itemId = itemId
        self.itemTitle = itemTitle
        self.tagNames = tagNames
        self.xpEarned = xpEarned
        self.duration = duration
    }
}
