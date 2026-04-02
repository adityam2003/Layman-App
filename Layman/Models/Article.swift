//
//  Article.swift
//  Layman
//

import Foundation

struct NewsResponse: Codable {
    let status: String
    let totalResults: Int
    let results: [Article]
}

struct Article: Codable, Identifiable, Hashable {
    let id: String
    let link: String
    let title: String
    let description: String?
    let content: String?
    let pubDate: String
    let imageUrl: String?
    let sourceId: String?
    let sourceName: String?
    
    // Conformance to Identifiable uses the article_id mapping
    enum CodingKeys: String, CodingKey {
        case id = "article_id"
        case link
        case title
        case description
        case content
        case pubDate
        case imageUrl = "image_url"
        case sourceId = "source_id"
        case sourceName = "source_name"
    }
    
    /// Derived property ensuring the title fits within the 52 char maximum
    /// requested by the UX design rules. Maintains a casual format.
    var displayHeadline: String {
        if title.count > 52 {
            let index = title.index(title.startIndex, offsetBy: 49)
            return title[..<index] + "..."
        }
        return title
    }
}

extension Article {
    static var placeholder: Article {
        Article(
            id: UUID().uuidString,
            link: "",
            title: "Placeholder headline structural block designed to precisely simulate three long lines of text",
            description: nil,
            content: nil,
            pubDate: "",
            imageUrl: nil,
            sourceId: nil,
            sourceName: nil
        )
    }
}
