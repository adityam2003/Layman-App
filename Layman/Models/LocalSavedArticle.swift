//
//  LocalSavedArticle.swift
//  Layman
//

import Foundation
import SwiftData

@Model
final class LocalSavedArticle {
    @Attribute(.unique) var id: String
    var link: String
    var title: String
    var articleDescription: String?
    var content: String?
    var pubDate: String
    var imageUrl: String?
    var sourceId: String?
    var sourceName: String?
    
    // Metadata for tracking
    var savedAt: Date
    
    // Offline / Cached Data
    var aiHeadline: String?
    var aiCards: [String]?
    @Attribute(.externalStorage) var thumbnailData: Data? // External storage optimized for binary
    
    init(article: Article, savedAt: Date = Date(), thumbnailData: Data? = nil) {
        self.id = article.id
        self.link = article.link
        self.title = article.title
        self.articleDescription = article.description
        self.content = article.content
        self.pubDate = article.pubDate
        self.imageUrl = article.imageUrl
        self.sourceId = article.sourceId
        self.sourceName = article.sourceName
        self.savedAt = savedAt
        self.aiHeadline = article.aiHeadline
        self.aiCards = article.aiCards
        self.thumbnailData = thumbnailData ?? article.localImageData
    }
    
    // Helper to convert back to standard Article struct for UI components
    var toArticle: Article {
        var article = Article(
            id: id,
            link: link,
            title: title,
            description: articleDescription,
            content: content,
            pubDate: pubDate,
            imageUrl: imageUrl,
            sourceId: sourceId,
            sourceName: sourceName
        )
        article.aiHeadline = aiHeadline
        article.aiCards = aiCards
        article.localImageData = thumbnailData
        return article
    }
}
