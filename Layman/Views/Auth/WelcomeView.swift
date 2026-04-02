//
//  WelcomeView.swift
//  Layman
//

import SwiftUI

struct WelcomeView: View {
    var onGetStarted: () -> Void
    
    var body: some View {
        ZStack {
            // Background Gradient exactly matching the mockup:
            // Top-left is a deeper warm peach, center is bright cream, bottom is soft peach.
            LinearGradient(
                stops: [
                    .init(color: Color(hex: "E8BCAA"), location: 0.0),
                    .init(color: Color(hex: "FFF4ED"), location: 0.4),
                    .init(color: Color(hex: "F2D2BE"), location: 1.0)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack {
                // Top Logo
                Text("Layman")
                    .font(.system(size: 32, weight: .bold, design: .default))
                    // .tracking(-0.5) // Optional: tighter kerning for logo feel
                    .foregroundStyle(Color(UIColor.label))
                    .padding(.top, 60)
                
                Spacer()
                
                // Center Slogan
                VStack(spacing: 8) {
                    Text("Business,\ntech & startups")
                        .font(.system(size: 38, weight: .bold))
                        .foregroundStyle(Color(UIColor.label))
                    
                    Text("made simple")
                        .font(.system(size: 38, weight: .bold))
                        .foregroundStyle(Color(hex: "D86D3F")) // Brand Accent Orange
                }
                .multilineTextAlignment(.center)
                .lineSpacing(0)
                
                Spacer()
                
                // Swipe Action
                SwipeToStartButton(
                    title: "Swipe to get started",
                    onSwipeSuccess: onGetStarted
                )
                .padding(.horizontal, 32)
                .padding(.bottom, 60)
            }
        }
    }
}
