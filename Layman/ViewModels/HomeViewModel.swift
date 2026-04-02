//
//  HomeViewModel.swift
//  Layman
//

import Foundation

@Observable
@MainActor
final class HomeViewModel {
    
    var featuredArticles: [Article] = []
    var todaysPicks: [Article] = []
    
    var isLoading = false
    var errorMessage: String?
    
    var hasFetched = false
    
    func fetchArticles() async {
        guard !hasFetched else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let articles = try await NewsService.shared.fetchTopArticles()
            
            // Filter out empty titles or corrupted items
            let validArticles = articles.filter { !$0.title.isEmpty }
            
            // Distribute to the UI: Top 3 as featured carousel, the rest as the vertical list
            if validArticles.count > 3 {
                featuredArticles = Array(validArticles.prefix(3))
                todaysPicks = Array(validArticles.dropFirst(3))
            } else {
                featuredArticles = validArticles
                todaysPicks = []
            }
            
            hasFetched = true
        } catch {
            errorMessage = "Could not fetch the latest news."
            print("Fetch error: \(error)")
        }
        
        isLoading = false
    }
}
