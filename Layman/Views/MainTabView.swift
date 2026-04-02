//
//  MainTabView.swift
//  Layman
//
//  The primary tab bar shown after login.
//  Contains three tabs: Home, Saved, Profile.
//  Profile tab includes a sign-out button for testing.
//

import SwiftUI

struct MainTabView: View {
    
    /// Shared auth view model so we can trigger sign-out.
    @Bindable var viewModel: AuthViewModel
    
    var body: some View {
        TabView {
            // ── Home Tab ──────────────────────────
            NavigationStack {
                HomeView()
                    .navigationTitle("")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbarBackground(.hidden, for: .navigationBar)
            }
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }
            
            // ── Saved Tab ─────────────────────────
            NavigationStack {
                SavedView()
                    .navigationTitle("")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbarBackground(.hidden, for: .navigationBar)
            }
            .tabItem {
                Label("Saved", systemImage: "bookmark.fill")
            }
            
            // ── Profile Tab ───────────────────────
            NavigationStack {
                ProfileView(authViewModel: viewModel)
                    .navigationTitle("Profile")
                    .navigationBarTitleDisplayMode(.inline)
            }
            .tabItem {
                Label("Profile", systemImage: "person.fill")
            }
        }
        .tint(Color(hex: "D86D3F")) // Changes active tab icon color to brand brown
    }
}
