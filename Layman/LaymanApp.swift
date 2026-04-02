//
//  LaymanApp.swift
//  Layman
//
//  Root entry point.
//  Decides whether to show the auth flow or the main tab bar
//  based on the user's authentication state.
//

import SwiftUI
import SwiftData

@main
struct LaymanApp: App {
    
    /// Single source of truth for auth state across the app.
    /// Using `@State` keeps the view model alive for the app's lifetime.
    @State private var authViewModel = AuthViewModel()
    
    var body: some Scene {
        WindowGroup {
            Group {
                // Root routing:
                // 1. Show splash while checking session
                // 2. Authenticated users → tabs
                // 3. Unauthenticated → auth flow
                if !authViewModel.isSessionChecked {
                    SplashView()
                } else if authViewModel.isAuthenticated {
                    MainTabView(viewModel: authViewModel)
                } else {
                    AuthCoordinatorView(viewModel: authViewModel)
                }
            }
            .animation(.easeInOut(duration: 0.3), value: authViewModel.isSessionChecked)
            .modelContainer(for: LocalSavedArticle.self)
        }
    }
}
