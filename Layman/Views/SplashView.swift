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
            // Warm, peachy gradient matching the user's provided design exactly
            LinearGradient(
                stops: [
                    .init(color: Color(hex: "F2D7C6"), location: 0.0),
                    .init(color: Color(hex: "FFFDFB"), location: 0.8)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // ── Double Layered Logo Text ───────────────────
            ZStack {
                // Secondary "Shadow" text layer
                Text("Layman")
                    .font(.system(size: 42, weight: .bold))
                    .foregroundColor(Color.gray.opacity(0.15))
                    .offset(x: -3, y: -3) // Reduced offset for smoother look
                
                // Primary Logo text layer
                Text("Layman")
                    .font(.system(size: 42, weight: .bold))
                    .foregroundColor(Color(UIColor.label))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
    }
}
