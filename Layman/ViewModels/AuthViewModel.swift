//
//  AuthViewModel.swift
//  Layman
//
//  Handles authentication state and user actions (sign in, sign up, sign out).
//  Publishes `isAuthenticated` so the UI can react to login/logout.
//

import Foundation
import Supabase
import Auth

/// Drives the authentication flow for the app.
/// Uses `@Observable` (Swift 5.9+) so SwiftUI views re-render
/// automatically when any published property changes.
@Observable
@MainActor
final class AuthViewModel {
    
    // MARK: - Published State
    
    /// `true` when a valid, non-expired session exists (user is logged in).
    var isAuthenticated = false
    
    /// `true` once the initial session check on app launch has completed.
    var isSessionChecked = false
    
    /// `true` while an auth request is in-flight (disables buttons, shows spinners).
    var isLoading = false
    
    /// Non-nil when the last auth operation produced an error.
    /// Cleared at the start of the next attempt.
    var errorMessage: String?
    
    // MARK: - Private
    
    /// Convenience accessor for the shared Supabase client.
    private var supabase: SupabaseClient { SupabaseManager.shared.client }
    
    // MARK: - Init
    
    init() {
        // Restore any existing session on launch so the user
        // stays logged in across app restarts.
        checkSession()
    }
    
    // MARK: - Session Check
    
    /// Attempts to restore a persisted session from the Keychain.
    /// Wrapped in a Task because `session` crosses an actor boundary.
    /// Also checks `isExpired` since we use `emitLocalSessionAsInitialSession`.
    func checkSession() {
        Task {
            defer { self.isSessionChecked = true }
            do {
                let session = try await supabase.auth.session
                // With emitLocalSessionAsInitialSession enabled, the SDK
                // returns the cached session even if it's expired.
                // We must check ourselves.
                if !session.isExpired {
                    self.isAuthenticated = true
                }
            } catch {
                // No stored session — user needs to sign in.
                self.isAuthenticated = false
            }
        }
    }
    
    // MARK: - Sign In
    
    /// Signs in with email + password.
    /// On success, flips `isAuthenticated` to `true`.
    func signIn(email: String, password: String) async {
        errorMessage = nil
        isLoading = true
        
        defer { isLoading = false }
        
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter both email and password."
            return
        }
        
        do {
            try await supabase.auth.signIn(
                email: email,
                password: password
            )
            isAuthenticated = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    // MARK: - Sign Up
    
    /// Creates a new account with email + password.
    /// If "Confirm email" is disabled in the Supabase dashboard
    /// the user is logged in immediately; otherwise they need to
    /// verify their email first.
    func signUp(email: String, password: String) async {
        errorMessage = nil
        isLoading = true
        
        defer { isLoading = false }
        
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter both email and password."
            return
        }
        
        guard password.count >= 6 else {
            errorMessage = "Password must be at least 6 characters."
            return
        }
        
        do {
            let response = try await supabase.auth.signUp(
                email: email,
                password: password
            )
            
            // If the project requires email confirmation, `session` is nil.
            if response.session != nil {
                isAuthenticated = true
            } else {
                errorMessage = "Check your email to confirm your account."
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    // MARK: - Sign Out
    
    /// Signs the user out and clears the persisted session.
    func signOut() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await supabase.auth.signOut()
            isAuthenticated = false
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
