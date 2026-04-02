//
//  SavedArticleRecord.swift
//  Layman
//

import Foundation

/// Represents a row in the Supabase "saved_articles" table.
struct SavedArticleRecord: Codable {
    let id: UUID? // Optional because Supabase generates it on insert
    let userId: UUID
    let articleId: String
    let articleData: Article
    let createdAt: Date? // Optional because Supabase generates it on insert
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case articleId = "article_id"
        case articleData = "article_data"
        case createdAt = "created_at"
    }
}
