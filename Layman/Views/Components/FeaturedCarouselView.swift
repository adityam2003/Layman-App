//
//  FeaturedCarouselView.swift
//  Layman
//

import SwiftUI

struct FeaturedCarouselView: View {
    let articles: [Article]
    @State private var currentIndex = 0
    
    var body: some View {
        VStack(spacing: 16) {
            TabView(selection: $currentIndex) {
                ForEach(Array(articles.enumerated()), id: \.element.id) { index, article in
                    FeaturedCardView(article: article)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 280) // Prominent card size
            
            // Custom Paging Indicators
            HStack(spacing: 6) {
                ForEach(0..<articles.count, id: \.self) { index in
                    Capsule()
                        .fill(currentIndex == index ? Color(hex: "D86D3F") : Color(hex: "D86D3F").opacity(0.3))
                        .frame(width: currentIndex == index ? 24 : 8, height: 6)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentIndex)
                }
            }
        }
    }
}

struct FeaturedCardView: View {
    let article: Article
    @Environment(\.redactionReasons) private var redactions
    
    var body: some View {
        GeometryReader { proxy in
            NavigationLink(destination: ArticleDetailView(article: article)) {
                ZStack(alignment: .bottom) {
                    // Background Image
                    if let urlString = article.imageUrl, let url = URL(string: urlString) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                Color(hex: "F4EAE2") // Static placeholder while loading
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                            case .failure:
                                Color(hex: "D86D3F").opacity(0.8)
                            @unknown default:
                                Color(hex: "D86D3F").opacity(0.8)
                            }
                        }
                        .frame(width: proxy.size.width, height: proxy.size.height)
                        // The clipping mask ensures corners are respected in `.scaledToFill`
                        .contentShape(Rectangle()) 
                        .clipped()
                    } else {
                        // Fallback to solid color for articles without images
                        Color(hex: "D86D3F").opacity(0.8)
                    }
                    
                    // Bottom Dark Gradient to ensure text is ALWAYS readable
                    LinearGradient(
                        colors: [.clear, .black.opacity(0.6), .black.opacity(0.9)],
                        startPoint: .center,
                        endPoint: .bottom
                    )
                    
                    // Article Headline
                    Text(article.displayHeadline)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                        .lineSpacing(2)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .shimmer(isActive: redactions.contains(.placeholder))
                }
                .cornerRadius(24) // Soft rounded edges matching the mockup
            }
            .buttonStyle(.plain)
            .disabled(redactions.contains(.placeholder))
        }
        .padding(.horizontal)
    }
}
