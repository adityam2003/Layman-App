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
                VStack {
                    Text("Saved")
                        .font(.title2.bold())
                    Text("Your saved items will appear here.")
                        .foregroundStyle(.secondary)
                }
                .navigationTitle("Saved")
            }
            .tabItem {
                Label("Saved", systemImage: "bookmark.fill")
            }
            
            // ── Profile Tab ───────────────────────
            NavigationStack {
                VStack(spacing: 24) {
                    Text("Profile")
                        .font(.title2.bold())
                    Text("Manage your account settings.")
                        .foregroundStyle(.secondary)
                    
                    // Sign Out button for testing auth flow.
                    Button(role: .destructive) {
                        Task {
                            await viewModel.signOut()
                        }
                    } label: {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                            Text("Sign Out")
                        }
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    
                    // Show loading state during sign-out.
                    if viewModel.isLoading {
                        ProgressView()
                    }
                    
                    // Show error if sign-out fails.
                    if let error = viewModel.errorMessage {
                        Text(error)
                            .font(.footnote)
                            .foregroundStyle(.red)
                    }
                }
                .navigationTitle("Profile")
            }
            .tabItem {
                Label("Profile", systemImage: "person.fill")
            }
        }
    }
}
