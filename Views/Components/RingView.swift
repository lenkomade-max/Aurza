//
//  RingView.swift
//  AURZA
//

import SwiftUI

struct RingView: View {
    let progress: Double
    let color: Color
    let title: String
    let value: String
    var size: CGFloat = 100
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .stroke(color.opacity(0.2), lineWidth: size * 0.1)
                    .frame(width: size, height: size)
                
                Circle()
                    .trim(from: 0, to: min(progress, 1.0))
                    .stroke(
                        AngularGradient(
                            gradient: Gradient(colors: [color.opacity(0.7), color]),
                            center: .center,
                            startAngle: .degrees(-90),
                            endAngle: .degrees(270)
                        ),
                        style: StrokeStyle(lineWidth: size * 0.1, lineCap: .round)
                    )
                    .frame(width: size, height: size)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.5), value: progress)
                
                VStack(spacing: 2) {
                    Text(value)
                        .font(.system(size: size * 0.25, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text("\(Int(progress * 100))%")
                        .font(.system(size: size * 0.12))
                        .foregroundColor(.secondary)
                }
            }
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

struct MultiRingView: View {
    let rings: [(title: String, progress: Double, color: Color)]
    
    var body: some View {
        HStack(spacing: 20) {
            ForEach(rings.indices, id: \.self) { index in
                let ring = rings[index]
                RingView(
                    progress: ring.progress,
                    color: ring.color,
                    title: ring.title,
                    value: "\(Int(ring.progress * 100))",
                    size: 80
                )
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
}
