//
//  TrendGraphView.swift
//  AURZA
//

import SwiftUI

struct TrendGraphView: View {
    let data: [Date: Int]
    let period: Period
    let color: Color
    
    private var sortedData: [(date: Date, value: Int)] {
        data.map { ($0.key, $0.value) }
            .sorted { $0.date < $1.date }
    }
    
    private var maxValue: Int {
        sortedData.map { $0.value }.max() ?? 1
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(NSLocalizedString("trend_graph", comment: ""))
                .font(.headline)
                .padding(.horizontal)
            
            if sortedData.isEmpty {
                Text(NSLocalizedString("no_data", comment: ""))
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, minHeight: 150)
            } else {
                GeometryReader { geometry in
                    ZStack {
                        // Grid lines
                        VStack(spacing: geometry.size.height / 4) {
                            ForEach(0..<5) { _ in
                                Rectangle()
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(height: 1)
                            }
                        }
                        
                        // Line graph
                        Path { path in
                            guard !sortedData.isEmpty else { return }
                            
                            let xStep = geometry.size.width / CGFloat(max(1, sortedData.count - 1))
                            let yScale = geometry.size.height / CGFloat(maxValue)
                            
                            for (index, item) in sortedData.enumerated() {
                                let x = CGFloat(index) * xStep
                                let y = geometry.size.height - (CGFloat(item.value) * yScale)
                                
                                if index == 0 {
                                    path.move(to: CGPoint(x: x, y: y))
                                } else {
                                    path.addLine(to: CGPoint(x: x, y: y))
                                }
                            }
                        }
                        .stroke(color, lineWidth: 2)
                        
                        // Points
                        ForEach(sortedData.indices, id: \.self) { index in
                            let xStep = geometry.size.width / CGFloat(max(1, sortedData.count - 1))
                            let yScale = geometry.size.height / CGFloat(maxValue)
                            let x = CGFloat(index) * xStep
                            let y = geometry.size.height - (CGFloat(sortedData[index].value) * yScale)
                            
                            Circle()
                                .fill(color)
                                .frame(width: 6, height: 6)
                                .position(x: x, y: y)
                        }
                    }
                }
                .frame(height: 150)
                .padding(.horizontal)
            }
            
            // Date labels
            HStack {
                if let first = sortedData.first {
                    Text(first.date, style: .date)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if let last = sortedData.last {
                    Text(last.date, style: .date)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
}
