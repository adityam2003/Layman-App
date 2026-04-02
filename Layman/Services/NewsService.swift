//
//  NewsService.swift
//  Layman
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case badResponse
    case decodingError
}

actor NewsService {
    static let shared = NewsService()
    
    // Given dynamically by the user
    private let apiKey = "pub_542133497cd349d5b9740ad13787fb2a"
    
    func fetchTopArticles() async throws -> [Article] {
        // We use technology & business categories to match the "Tech & Startups" theme
        guard let url = URL(string: "https://newsdata.io/api/1/news?apikey=\(apiKey)&language=en&category=technology,business") else {
            throw NetworkError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NetworkError.badResponse
        }
        
        do {
            let newsResponse = try JSONDecoder().decode(NewsResponse.self, from: data)
            return newsResponse.results
        } catch {
            print("NewsData.io Decoding Error: \(error)")
            // Fallback in case the API structure matches the raw array provided
            if let rawArray = try? JSONDecoder().decode([Article].self, from: data) {
                return rawArray
            }
            throw NetworkError.decodingError
        }
    }
}
