//
//  AllArticlesView.swift
//  Layman
//

import SwiftUI

struct AllArticlesView: View {
    let articles: [Article]
    
    var body: some View {
        ZStack {
            // Very light cream background matching mockup
            Color(hex: "FFFDFB").ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 16) {
                    ForEach(articles) { article in
                        // Dummy navigation for now, can be updated later
                        NavigationLink(destination: ArticleDetailView(article: article)) {
                            ArticleRowView(article: article)
                                .padding(.horizontal)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 16)
            }
        }
        .navigationTitle("Today's Picks")
        .navigationBarTitleDisplayMode(.inline)
    }
}
