//
//  StatsDetailView.swift
//  AURZA
//

import SwiftUI

struct StatsDetailView: View {
    let title: String
    let data: [(String, Double)]
    let color: Color
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(data, id: \.0) { item in
                    HStack {
                        Text(item.0)
                            .font(.body)
                        
                        Spacer()
                        
                        Text(String(format: "%.1f", item.1))
                            .font(.headline)
                            .foregroundColor(color)
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .cornerRadius(10)
                }
            }
            .padding()
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
