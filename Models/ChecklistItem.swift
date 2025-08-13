//
//  ChecklistItem.swift
//  AURZA
//

import Foundation

struct ChecklistItem: Identifiable, Codable, Equatable {
    let id: UUID
    var text: String
    var isDone: Bool
    var order: Int
    
    init(
        id: UUID = UUID(),
        text: String,
        isDone: Bool = false,
        order: Int = 0
    ) {
        self.id = id
        self.text = text
        self.isDone = isDone
        self.order = order
    }
}
