//
//  ArticleDetailViewModel.swift
//  Layman
//

import Foundation

@Observable
class ArticleDetailViewModel {
    let article: Article
    var showOriginalArticle: Bool = false
    
    // AI Content
    var simplifiedHeadline: String
    var translatedChunks: [String] = []
    var isTranslating: Bool = true
    
    // In-memory cache for the current session
    private static var sessionCache: [String: (headline: String, cards: [String])] = [:]
    
    init(article: Article) {
        self.article = article
        // Start with the original title as a placeholder
        self.simplifiedHeadline = article.title
        
        loadAITranslation()
    }
    
    private func loadAITranslation() {
        let articleId = article.id
        
        // 1. Check Cache
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
