//
//  ConfettiView.swift
//  AURZA
//

import SwiftUI

struct ConfettiView: View {
    @State private var confettiPieces: [ConfettiPiece] = []
    let trigger: Bool
    
    var body: some View {
        ZStack {
            ForEach(confettiPieces) { piece in
                ConfettiPieceView(piece: piece)
            }
        }
        .onChange(of: trigger) { newValue in
            if newValue {
                generateConfetti()
            }
        }
    }
    
    private func generateConfetti() {
        confettiPieces = (0..<50).map { _ in
            ConfettiPiece(
                x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                y: -20,
                color: [Color.red, .blue, .green, .yellow, .purple, .orange].randomElement()!,
                size: CGFloat.random(in: 8...12),
                velocity: CGFloat.random(in: 2...5),
                spin: Double.random(in: -360...360)
            )
        }
        
        withAnimation(.easeOut(duration: 3)) {
            confettiPieces = confettiPieces.map { piece in
                var newPiece = piece
                newPiece.y = UIScreen.main.bounds.height + 100
                return newPiece
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            confettiPieces.removeAll()
        }
    }
}

struct ConfettiPiece: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    let color: Color
    let size: CGFloat
    let velocity: CGFloat
    let spin: Double
}

struct ConfettiPieceView: View {
    let piece: ConfettiPiece
    @State private var rotation: Double = 0
    
    var body: some View {
        Rectangle()
            .fill(piece.color)
            .frame(width: piece.size, height: piece.size)
            .position(x: piece.x, y: piece.y)
            .rotationEffect(.degrees(rotation))
            .onAppear {
                withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                    rotation = piece.spin
                }
            }
    }
}
