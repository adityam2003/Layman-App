//
//  HomeView.swift
//  Layman
//

import SwiftUI

struct HomeView: View {
    @State private var viewModel = HomeViewModel()
    
    // Serve placeholders when loading, actual real data when finished
    private var currentFeatured: [Article] {
        return viewModel.hasFetched ? viewModel.featuredArticles : [Article.placeholder]
    }
    
    private var currentPicks: [Article] {
        return viewModel.hasFetched ? viewModel.todaysPicks : (0..<3).map { _ in Article.placeholder }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            
            // ── Header (Logo & Search) ──────────────
            HStack {
                Text("Layman")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(Color(UIColor.label))
                
                Spacer()
                
                Button {
                    // Search Action (stubbed)
                } label: {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 16, weight: .bold))
                        .padding(12)
                        .background(Color(hex: "F4EAE2"))
                        .clipShape(Circle())
                        .foregroundStyle(Color(UIColor.label))
                }
            }
            .padding(.horizontal)
            
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
                if !currentFeatured.isEmpty {
                    FeaturedCarouselView(articles: currentFeatured)
                        .redacted(reason: viewModel.hasFetched ? [] : .placeholder)
                }
                
                // Today's Picks Section
                if !currentPicks.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack(alignment: .bottom) {
                            Text("Today's Picks")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundStyle(Color(UIColor.label))
                            
                            Spacer()
                            
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
                        .padding(.horizontal)
                        
                        ScrollView(showsIndicators: false) {
                            LazyVStack(spacing: 16) {
                                ForEach(currentPicks) { article in
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
