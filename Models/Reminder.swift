//
//  Reminder.swift
//  AURZA
//

import Foundation

struct Reminder: Identifiable, Codable, Equatable {
    let id: UUID
    var time: Date
    var soundName: String?
    var isEnabled: Bool
    
    init(
        id: UUID = UUID(),
        time: Date,
        soundName: String? = "default",
        isEnabled: Bool = true
    ) {
        self.id = id
        self.time = time
        self.soundName = soundName
        self.isEnabled = isEnabled
    }
    
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: time)
    }
}
