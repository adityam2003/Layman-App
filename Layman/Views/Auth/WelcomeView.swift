//
//  WelcomeView.swift
//  Layman
//

import SwiftUI

struct WelcomeView: View {
    var onGetStarted: () -> Void
    
    var body: some View {
        ZStack {
            // Warm, peachy gradient matching the refined design
            LinearGradient(
                stops: [
                    .init(color: Color(hex: "F2D7C6"), location: 0.0),
                    .init(color: Color(hex: "FFFDFB"), location: 0.8)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack {
                // Top Logo - Double Layered for consistent branding
                ZStack {
                    Text("Layman")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(Color.gray.opacity(0.15))
                        .offset(x: -2, y: -2)
                    
                    Text("Layman")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(Color(UIColor.label))
                }
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
