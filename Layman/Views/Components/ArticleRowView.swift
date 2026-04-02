//
//  ArticleRowView.swift
//  Layman
//

import SwiftUI

struct ArticleRowView: View {
    let article: Article
    @Environment(\.redactionReasons) private var redactions
    
    var body: some View {
        HStack(spacing: 16) {
            // Left Thumbnail
            if let urlString = article.imageUrl, let url = URL(string: urlString) {
                AsyncImage(url: url) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .scaledToFill()
                    } else if phase.error != nil {
                        // Failed to load — show static placeholder
                        Image(systemName: "photo")
                            .foregroundStyle(Color(hex: "D86D3F").opacity(0.5))
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color(hex: "F4EAE2"))
                    } else {
                        // Still loading — show static placeholder (shimmer only during skeleton)
                        Color(hex: "F4EAE2")
                    }
                }
                .frame(width: 80, height: 80)
                .cornerRadius(18)
                .clipped()
            } else {
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color(hex: "D86D3F").opacity(0.6))
                    .frame(width: 80, height: 80)
            }
            
            // Right Text Layout
            VStack(alignment: .leading) {
                Text(article.displayHeadline)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(Color(UIColor.label))
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
                    .lineSpacing(2)
                    .shimmer(isActive: redactions.contains(.placeholder))
            }
            .frame(height: 80)
            
            Spacer(minLength: 0)
        }
        .padding(12)
        .background(Color(hex: "F4EAE2")) // Pill-box standard background color from mockup
        .cornerRadius(28) // Distinctly highly rounded corners
    }
}
