//
//  Tag.swift
//  AURZA
//

import Foundation
import SwiftUI

struct Tag: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    var name: String
    var color: Color.RGBAColor
    
    init(
        id: UUID = UUID(),
        name: String,
        color: Color.RGBAColor = Color.blue.rgbaColor
    ) {
        self.id = id
        self.name = name
        self.color = color
    }
    
    static func == (lhs: Tag, rhs: Tag) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
