//
//  SavedArticleService.swift
//  Layman
//

import Foundation
import Supabase

/// Handles operations for saving and retrieving articles using Supabase.
actor SavedArticleService {
    static let shared = SavedArticleService()
    
    private var client: Supabase.SupabaseClient {
        SupabaseManager.shared.client
    }
    
    private init() {}
    
    /// Checks if a specific article is saved by the current user.
    func checkIsSaved(articleId: String) async throws -> Bool {
        do {
            let user = try await client.auth.session.user
            
            // Try to fetch exactly one record matching the article ID for this user.
            // Under RLS, the user_id condition is implicitly enforced by the policy,
            // but we add it explicitly to ensure we don't accidentally fetch another user's if RLS is bypassed.
            let response: [SavedArticleRecord] = try await client.from("saved_articles")
                .select()
                .eq("article_id", value: articleId)
                .eq("user_id", value: user.id)
                .limit(1)
                .execute()
                .value
            
            return !response.isEmpty
        } catch {
            print("checkIsSaved error: \(error)")
            // If the table doesn't exist yet, or other network errors, assume not saved.
            return false
        }
    }
    
    /// Saves an article for the current user.
    func saveArticle(_ article: Article) async throws {
        let user = try await client.auth.session.user
        
        let record = SavedArticleRecord(
            id: nil, // Let Supabase handle ID generation
            userId: user.id,
            articleId: article.id,
            articleData: article,
            createdAt: nil
        )
        
        try await client.from("saved_articles")
            .insert(record)
            .execute()
    }
    
    /// Removes an article from the saved list.
    func removeArticle(articleId: String) async throws {
        let user = try await client.auth.session.user
        
        try await client.from("saved_articles")
            .delete()
            .eq("article_id", value: articleId)
            .eq("user_id", value: user.id)
            .execute()
    }
    
    /// Fetches all saved articles for the current user, ordered by most recently saved.
    func fetchSavedArticles() async throws -> [Article] {
        let user = try await client.auth.session.user
        
        let records: [SavedArticleRecord] = try await client.from("saved_articles")
            .select()
            .eq("user_id", value: user.id)
            .order("created_at", ascending: false)
            .execute()
            .value
        
        return records.map { $0.articleData }
    }
}
