//
//  ShimmerEffect.swift
//  Layman
//

import SwiftUI

struct ShimmerEffect: ViewModifier {
    @State private var isInitialState = true
    
    func body(content: Content) -> some View {
        content
            .mask(
                LinearGradient(
                    gradient: Gradient(colors: [.black.opacity(0.4), .black, .black.opacity(0.4)]),
                    startPoint: (isInitialState ? .init(x: -0.3, y: -0.3) : .init(x: 1, y: 1)),
                    endPoint: (isInitialState ? .init(x: 0, y: 0) : .init(x: 1.3, y: 1.3))
                )
            )
            .animation(
                .linear(duration: 1.5).delay(0.2).repeatForever(autoreverses: false),
                value: isInitialState
            )
            .onAppear {
                isInitialState = false
            }
    }
}

extension View {
    /// Applies a smooth diagonal shimmer animation masking the view.
    func shimmer(isActive: Bool = true) -> some View {
        Group {
            if isActive {
                self.modifier(ShimmerEffect())
            } else {
                self
            }
        }
    }
}
