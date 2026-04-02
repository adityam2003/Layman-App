//
//  SupabaseManager.swift
//  Layman
//
//  Singleton wrapper around the Supabase client.
//  Credentials are read from Info.plist (populated via Secrets.xcconfig).
//

import Foundation
import Supabase

/// Central access point for the Supabase client.
/// Uses a singleton pattern so every layer shares one client instance,
/// which means a single auth session and connection pool.
final class SupabaseManager {
    
    // MARK: - Singleton
    
    static let shared = SupabaseManager()
    
    // MARK: - Client
    
    /// The configured Supabase client.
    /// Session persistence is handled automatically by the SDK's
    /// built-in Keychain storage — tokens survive app restarts.
    let client: SupabaseClient
    
    // MARK: - Init
    
    private init() {
        // Read credentials from Info.plist.
        // These values originate from Config/Secrets.xcconfig → Build Settings → Info.plist.
        guard
            let urlString = Bundle.main.infoDictionary?["SUPABASE_URL"] as? String,
            let url = URL(string: urlString),
            let anonKey = Bundle.main.infoDictionary?["SUPABASE_ANON_KEY"] as? String,
            !anonKey.isEmpty
        else {
            let availableKeys = Bundle.main.infoDictionary?.keys.sorted().joined(separator: ", ") ?? "None"
            print("Available Info.plist keys: \(availableKeys)")
            
            fatalError("""
            ❌ Missing Supabase configuration!
            
            Ensure Config/Secrets.xcconfig exists with valid values for:
              • SUPABASE_URL
              • SUPABASE_ANON_KEY
            
            If the values exist in Secrets.xcconfig, Xcode might be caching the old Info.plist!
            Please press Cmd + Shift + K to Clean Build Folder, then run again.
            """)
        }
        
        client = SupabaseClient(
            supabaseURL: url,
            supabaseKey: anonKey,
            options: SupabaseClientOptions(
                auth: .init(
                    emitLocalSessionAsInitialSession: true
                )
            )
        )
    }
}
