//
//  TagChipView.swift
//  AURZA
//

import SwiftUI

struct TagChipView: View {
    let tag: Tag
    var size: Size = .regular
    var isSelected: Bool = false
    var onTap: (() -> Void)? = nil
    
    enum Size {
        case small, regular, large
        
        var fontSize: Font {
            switch self {
            case .small: return .caption2
            case .regular: return .caption
            case .large: return .footnote
            }
        }
        
        var padding: EdgeInsets {
            switch self {
            case .small: return EdgeInsets(top: 2, leading: 6, bottom: 2, trailing: 6)
            case .regular: return EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8)
            case .large: return EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12)
            }
        }
    }
    
    var body: some View {
        Text(tag.name)
            .font(size.fontSize)
            .foregroundColor(isSelected ? .white : Color(rgbaColor: tag.color))
            .padding(size.padding)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(isSelected ? Color(rgbaColor: tag.color) : Color(rgbaColor: tag.color).opacity(0.15))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .strokeBorder(Color(rgbaColor: tag.color), lineWidth: isSelected ? 0 : 1)
            )
            .onTapGesture {
                onTap?()
            }
    }
}
