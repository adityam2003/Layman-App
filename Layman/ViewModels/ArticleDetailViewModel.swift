//
//  ArticleDetailViewModel.swift
//  Layman
//

import Foundation

import SwiftData

@Observable
class ArticleDetailViewModel {
    let article: Article
    var showOriginalArticle: Bool = false
    
    // AI Content
    var simplifiedHeadline: String
    var translatedChunks: [String] = []
    var isTranslating: Bool = true
    
    // Bookmark State
    var isBookmarked: Bool = false
    var isChangingBookmark: Bool = false
    
    // In-memory cache for the current session
    private static var sessionCache: [String: (headline: String, cards: [String])] = [:]
    
    init(article: Article) {
        self.article = article
        // Start with the original title as a placeholder
        self.simplifiedHeadline = article.title
        
        loadAITranslation()
    }
    
    func checkBookmarkState(context: ModelContext) {
        let articleId = article.id
        // Check local DB first for instant offline reading
        let descriptor = FetchDescriptor<LocalSavedArticle>(predicate: #Predicate { $0.id == articleId })
        if let existing = try? context.fetch(descriptor), !existing.isEmpty {
            self.isBookmarked = true
            return
        }
        self.isBookmarked = false
    }
    
    func toggleBookmark(context: ModelContext) {
        guard !isChangingBookmark else { return }
        isChangingBookmark = true
        
        let articleId = article.id
        let newState = !isBookmarked
        
        // Optimistic UI update
        self.isBookmarked = newState
        
        // 1. Instantly update local SwiftData (Offline support)
        if newState {
            // Capture current AI compilation
            var articleToSave = self.article
            if !self.isTranslating {
                articleToSave.aiHeadline = self.simplifiedHeadline
                articleToSave.aiCards = self.translatedChunks
            }
            
            let localArticle = LocalSavedArticle(article: articleToSave)
            context.insert(localArticle)
            
            // Fire off background image byte download
            if let urlString = article.imageUrl, let url = URL(string: urlString) {
                Task {
                    if let data = try? Data(contentsOf: url) {
                        await MainActor.run {
                            localArticle.thumbnailData = data
                            try? context.save()
                        }
                    }
                }
            }
        } else {
            let descriptor = FetchDescriptor<LocalSavedArticle>(predicate: #Predicate { $0.id == articleId })
            if let existing = try? context.fetch(descriptor) {
                for item in existing {
                    context.delete(item)
                }
            }
        }
        
        // Ensure local changes save
        try? context.save()
        
        // 2. Sync to Supabase in the background
        Task {
            do {
                if newState {
                    try await SavedArticleService.shared.saveArticle(article)
                } else {
                    try await SavedArticleService.shared.removeArticle(articleId: article.id)
                }
            } catch {
                print("Failed to sync bookmark with cloud: \(error)")
                // Note: We don't revert the local UI here. The user clicked save, they want it saved locally at least. 
                // A robust app would queue this retry.
            }
            await MainActor.run {
                self.isChangingBookmark = false
            }
        }
    }
    
    private func loadAITranslation() {
        let articleId = article.id
        
        // 0. Check Offline Data (loaded from Saved/SwiftData)
        if let offlineCards = article.aiCards, let offlineHeadline = article.aiHeadline, !offlineCards.isEmpty {
            self.simplifiedHeadline = offlineHeadline
            self.translatedChunks = offlineCards
            self.isTranslating = false
            return
        }
        
        // 1. Check Memory Cache
        if let cached = Self.sessionCache[articleId] {
            self.simplifiedHeadline = cached.headline
            self.translatedChunks = cached.cards
            self.isTranslating = false
            return
        }
        
        // 2. Fetch from AI
        Task {
            do {
                // We use description for the context, fallback to title
                let context = article.content ?? article.description ?? article.title
                
                let result = try await GeminiService.shared.translateArticle(
                    articleTitle: article.title,
                    articleContent: context
                )
                
                await MainActor.run {
                    self.simplifiedHeadline = result.headline
                    self.translatedChunks = result.cards
                    self.isTranslating = false
                    
                    // Store in cache
                    Self.sessionCache[articleId] = result
                }
            } catch {
                print("❌ AI Translation failed: \(error)")
                await MainActor.run {
                    self.isTranslating = false
                    // Fallback to original content if AI fails
                    if self.translatedChunks.isEmpty {
                        self.translatedChunks = [article.description ?? "No summary available."]
                    }
                }
            }
        }
    }
}
