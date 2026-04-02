//
//  HomeView.swift
//  Layman
//

import SwiftUI

struct HomeView: View {
    @State private var viewModel = HomeViewModel()
    @State private var searchText: String = ""
    @State private var isSearchBarVisible: Bool = false
    
    // Filtered lists based on search
    private var filteredFeatured: [Article] {
        let featured = viewModel.hasFetched ? viewModel.featuredArticles : [Article.placeholder]
        if searchText.isEmpty { return featured }
        return featured.filter { $0.title.localizedCaseInsensitiveContains(searchText) || ($0.description?.localizedCaseInsensitiveContains(searchText) ?? false) }
    }
    
    private var filteredPicks: [Article] {
        let picks = viewModel.hasFetched ? viewModel.todaysPicks : (0..<3).map { _ in Article.placeholder }
        if searchText.isEmpty { return picks }
        return picks.filter { $0.title.localizedCaseInsensitiveContains(searchText) || ($0.description?.localizedCaseInsensitiveContains(searchText) ?? false) }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            
            // ── Header (Logo & Search) ──────────────
            VStack(spacing: 12) {
                HStack {
                    if !isSearchBarVisible {
                        Text("Layman")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundStyle(Color(UIColor.label))
                            .transition(.move(edge: .leading).combined(with: .opacity))
                    }
                    
                    Spacer()
                    
                    if isSearchBarVisible {
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                            
                            TextField("Search articles...", text: $searchText)
                                .textFieldStyle(.plain)
                                .autocorrectionDisabled()
                            
                            Button {
                                withAnimation(.spring()) {
                                    searchText = ""
                                    isSearchBarVisible = false
                                }
                            } label: {
                                Text("Cancel")
                                    .fontWeight(.medium)
                                    .foregroundColor(Color(hex: "D86D3F"))
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color(hex: "F4EAE2"))
                        .cornerRadius(20)
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                    } else {
                        Button {
                            withAnimation(.spring()) {
                                isSearchBarVisible = true
                            }
                        } label: {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 16, weight: .bold))
                                .padding(12)
                                .background(Color(hex: "F4EAE2"))
                                .clipShape(Circle())
                                .foregroundStyle(Color(UIColor.label))
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 16)
            
            // ── Dynamic Content ──────────────────────
            if let error = viewModel.errorMessage {
                Spacer()
                VStack(spacing: 16) {
                    Text(error)
                        .font(.subheadline)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Button {
                        Task {
                            await viewModel.fetchArticles()
                        }
                    } label: {
                        Text("Retry")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 32)
                            .padding(.vertical, 12)
                            .background(Color(hex: "D86D3F"))
                            .cornerRadius(20)
                    }
                }
                Spacer()
            } else {
                
                // ── SINGLE UI LAYOUT (No Jumps) ───────────
                
                // Carousel Section
                if !filteredFeatured.isEmpty {
                    FeaturedCarouselView(articles: filteredFeatured)
                        .redacted(reason: viewModel.hasFetched ? [] : .placeholder)
                }
                
                // Today's Picks Section
                if !filteredPicks.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack(alignment: .bottom) {
                            Text(searchText.isEmpty ? "Today's Picks" : "Search Results")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundStyle(Color(UIColor.label))
                            
                            Spacer()
                            
                            if searchText.isEmpty {
                                NavigationLink {
                                    AllArticlesView(articles: viewModel.todaysPicks)
                                } label: {
                                    Text("View All")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundStyle(Color(hex: "D86D3F"))
                                        .opacity(viewModel.hasFetched ? 1.0 : 0.0) // Hide when loading
                                }
                                .disabled(!viewModel.hasFetched)
                            }
                        }
                        .padding(.horizontal)
                        
                        ScrollView(showsIndicators: false) {
                            LazyVStack(spacing: 16) {
                                ForEach(filteredPicks) { article in
                                    if viewModel.hasFetched {
                                        NavigationLink(destination: ArticleDetailView(article: article)) {
                                            ArticleRowView(article: article)
                                        }
                                        .buttonStyle(.plain)
                                    } else {
                                        ArticleRowView(article: article)
                                            .buttonStyle(.plain)
                                    }
                                }
                                .padding(.horizontal)
                            }
                            .padding(.bottom, 24)
                        }
                        .redacted(reason: viewModel.hasFetched ? [] : .placeholder)
                    }
                } else if !searchText.isEmpty {
                    // Search Empty State
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 48))
                            .foregroundColor(Color(hex: "D86D3F").opacity(0.5))
                        Text("No results for \"\(searchText)\"")
                            .font(.headline)
                        Text("Try searching for a different topic.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color(hex: "FFFDFB").ignoresSafeArea())
        .task {
            await viewModel.fetchArticles()
        }
    }
}
