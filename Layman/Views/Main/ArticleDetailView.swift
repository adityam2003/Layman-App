//
//  ArticleDetailView.swift
//  Layman
//

import SwiftUI

struct ArticleDetailView: View {
    @State private var viewModel: ArticleDetailViewModel
    @Environment(\.dismiss) private var dismiss
    
    // Tracks the current page in the layman content translation carousel
    @State private var currentCardIndex: Int = 0
    @State private var showAskLayman: Bool = false
    
    init(article: Article) {
        // Initialize State with the configured ViewModel
        _viewModel = State(initialValue: ArticleDetailViewModel(article: article))
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Screen Background
            Color(hex: "FFFDFB").ignoresSafeArea()
            
            VStack(spacing: 0) {
                // ── Top Custom Navigation Bar ────────────────
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .bold))
                            .frame(width: 44, height: 44)
                            .background(Color(hex: "F4EAE2"))
                            .clipShape(Circle())
                            .foregroundColor(Color(UIColor.label))
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 20) {
                        Button {
                            viewModel.showOriginalArticle = true
                        } label: {
                            Image(systemName: "link")
                                .font(.system(size: 18, weight: .semibold))
                        }
                        
                        Button {
                            print("Bookmark tapped")
                        } label: {
                            Image(systemName: "bookmark")
                                .font(.system(size: 18, weight: .semibold))
                        }
                        
                        Button {
                            print("Share tapped")
                        } label: {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 18, weight: .semibold))
                        }
                    }
                    .foregroundColor(Color.gray) // Neutral icon styling reflecting mockup
                }
                .padding(.horizontal)
                .padding(.top, 16)
                
                // ── Deep Scrollable Content ───────────────────
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        
                        // AI-Simplified Headline
                        Text(viewModel.simplifiedHeadline)
                            .font(.system(size: 26, weight: .bold))
                            .lineLimit(2) // Mockup specifically requires 2 line max
                            .minimumScaleFactor(0.9) // Scales natively if too long, prevents breaking bounds
                            .foregroundColor(Color(UIColor.label))
                            .padding(.horizontal)
                            .padding(.top, 16)
                            .shimmer(isActive: viewModel.isTranslating)
                        
                        // Hero Feature Image
                        if let urlString = viewModel.article.imageUrl, let url = URL(string: urlString) {
                            AsyncImage(url: url) { phase in
                                if let image = phase.image {
                                    image
                                        .resizable()
                                        .scaledToFill()
                                } else if phase.error != nil {
                                    Image(systemName: "photo")
                                        .foregroundColor(Color(hex: "D86D3F").opacity(0.5))
                                        .background(Color(hex: "F4EAE2"))
                                } else {
                                    // Loading state placeholder block
                                    Color(hex: "F4EAE2")
                                }
                            }
                            // Fixed height constraint preserving aspect
                            .frame(width: UIScreen.main.bounds.width - 32, height: 230)
                            .cornerRadius(24) 
                            .clipped()
                            .padding(.horizontal)
                        } else {
                            RoundedRectangle(cornerRadius: 24)
                                .fill(Color(hex: "F4EAE2"))
                                .frame(width: UIScreen.main.bounds.width - 32, height: 230)
                                .padding(.horizontal)
                        }
                        
                        // Layman Sentences Swipeable Carousel
                        VStack(spacing: 16) {
                            if viewModel.isTranslating {
                                // Loading Skeleton
                                RoundedRectangle(cornerRadius: 28)
                                    .fill(Color(hex: "F4EAE2"))
                                    .frame(height: 200)
                                    .padding(.horizontal)
                                    .shimmer()
                            } else {
                                TabView(selection: $currentCardIndex) {
                                    ForEach(Array(viewModel.translatedChunks.enumerated()), id: \.offset) { index, chunk in
                                        Text(chunk)
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(Color(UIColor.label).opacity(0.85))
                                            .lineSpacing(6)
                                            .padding(24) // Creates inner spacing for 6 exact lines
                                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                                            .background(Color(hex: "F4EAE2"))
                                            .cornerRadius(28)
                                            .padding(.horizontal) // Side spacing outside container
                                            .tag(index)
                                    }
                                }
                                .tabViewStyle(.page(indexDisplayMode: .never)) // Kill native dots
                                .frame(height: 200) // Master container ensuring exact uniform fit across swiping pages
                                
                                // Native Layman Paging Indicators
                                HStack(spacing: 6) {
                                    ForEach(0..<viewModel.translatedChunks.count, id: \.self) { index in
                                        Capsule()
                                            .fill(currentCardIndex == index ? Color(hex: "D86D3F") : Color(hex: "D86D3F").opacity(0.3))
                                            .frame(width: currentCardIndex == index ? 24 : 8, height: 6)
                                            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentCardIndex)
                                    }
                                }
                            }
                        }
                        .padding(.top, 8)
                        
                    }
                    .padding(.bottom, 120) // Deep padding allows reading layout easily above bottom CTA
                }
            }
            
            // ── Fixed Bottom CTA ────────────────────────
            Button {
                showAskLayman = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 16, weight: .bold))
                    Text("Ask Layman")
                        .font(.system(size: 17, weight: .bold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(Color(hex: "D86D3F"))
                .cornerRadius(32)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
        }
        // Destroy native layout constraints restricting custom bars
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar) // Hides the bottom navigation tab bar on this screen
        
        // Modal Safari Injector
        .sheet(isPresented: $viewModel.showOriginalArticle) {
            if let url = URL(string: viewModel.article.link) {
                SafariView(url: url)
                    .ignoresSafeArea()
            } else {
                Text("Error: Ensure the article provides a valid link.")
                    .foregroundColor(.secondary)
            }
        }
        
        // Ask Layman Chatbot Sheet
        .sheet(isPresented: $showAskLayman) {
            AskLaymanView(viewModel: AskLaymanViewModel(article: viewModel.article))
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.hidden)
                .presentationCornerRadius(28)
        }
    }
}
