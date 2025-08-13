//
//  JournalEntry.swift
//  AURZA
//

import Foundation

struct JournalEntry: Identifiable, Codable, Equatable {
    let id: UUID
    var date: Date
    var mood: Mood
    var text: String
    var tags: [Tag]
    var photoURLs: [URL]
    var audioURLs: [URL]
    var isPinned: Bool
    var dailyQuestion: String?
    var dailyAnswer: String?
    let createdAt: Date
    var updatedAt: Date
    
    enum Mood: Codable, Equatable {
        case emoji(String)
        case scale(Int) // 1-5
        
        var displayValue: String {
            switch self {
            case .emoji(let emoji):
                return emoji
            case .scale(let value):
                let emojis = ["😢", "😕", "😐", "🙂", "😄"]
                return emojis[min(max(value - 1, 0), 4)]
            }
        }
    }
    
    init(
        id: UUID = UUID(),
        date: Date = Date(),
        mood: Mood = .scale(3),
        text: String = "",
        tags: [Tag] = [],
        photoURLs: [URL] = [],
        audioURLs: [URL] = [],
        isPinned: Bool = false,
        dailyQuestion: String? = nil,
        dailyAnswer: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.date = date
        self.mood = mood
        self.text = text
        self.tags = tags
        self.photoURLs = photoURLs
        self.audioURLs = audioURLs
        self.isPinned = isPinned
        self.dailyQuestion = dailyQuestion
        self.dailyAnswer = dailyAnswer
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
