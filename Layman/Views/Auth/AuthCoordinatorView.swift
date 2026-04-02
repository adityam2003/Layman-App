//
//  AuthCoordinatorView.swift
//  Layman
//
//  Wraps the authentication flow in a NavigationStack.
//  Routes between SignInView and SignUpView while sharing
//  a single AuthViewModel instance.
//

import SwiftUI

/// Coordinates the auth navigation flow.
/// This is the entry point used by `LaymanApp` when the user is not authenticated.
struct AuthCoordinatorView: View {
    
    /// Shared auth view model — owned by `LaymanApp`, passed in here.
    @Bindable var viewModel: AuthViewModel
    
    // Remember if user has swiped through the welcome screen.
    // This resets to false every time the coordinator mounts (shows every time logged out).
    @State private var hasSeenWelcome = false
    
    var body: some View {
        NavigationStack {
            Group {
                if !hasSeenWelcome {
                    WelcomeView {
                        // Smoothly transition from Welcome to Sign In
                        withAnimation(.easeInOut(duration: 0.5)) {
                            hasSeenWelcome = true
                        }
                    }
                } else {
                    SignInView(viewModel: viewModel)
                }
            }
            .transition(.opacity) // Crossfade effect on root change
        }
    }
}
