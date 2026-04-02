//
//  SplashView.swift
//  Layman
//
//  Matches the native LaunchScreen.storyboard exactly so
//  the transition from iOS launch screen → SwiftUI is seamless.
//  Stays visible while the session check completes.
//

import SwiftUI

struct SplashView: View {
    var body: some View {
        ZStack {
            // Theme Background matches WelcomeView
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
            
            // Match the storyboard: centered bold title
            Text("Layman")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(Color(UIColor.label))
        }
    }
}
