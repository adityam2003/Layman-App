//
//  SavedView.swift
//  Layman
//

import SwiftUI
import SwiftData

struct SavedView: View {
    // Automatically queries the local SwiftData store.
    // Syncs live, loads instantly, relies on 0 network conditions.
    @Query(sort: \LocalSavedArticle.savedAt, order: .reverse) private var savedArticles: [LocalSavedArticle]
    
    @Environment(\.modelContext) private var modelContext
    @State private var isSyncing = false
    @State private var searchText = ""
    @State private var isSearchBarVisible = false
    
    // Filtered list based on search
    private var filteredSavedArticles: [LocalSavedArticle] {
        if searchText.isEmpty { return savedArticles }
        return savedArticles.filter { 
            $0.title.localizedCaseInsensitiveContains(searchText) || 
            ($0.articleDescription?.localizedCaseInsensitiveContains(searchText) ?? false) 
        }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            
            // ── Header (Title & Search) ──────────────
            HStack {
                if !isSearchBarVisible {
                    Text("Saved")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(Color(UIColor.label))
                        .transition(.move(edge: .leading).combined(with: .opacity))
                }
                
                Spacer()
                
                if isSyncing && !isSearchBarVisible {
                    ProgressView()
                        .padding(.trailing, 8)
                }
                
                if isSearchBarVisible {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        
                        TextField("Search saved...", text: $searchText)
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
            .padding(.horizontal)
            .padding(.top, 16)
            
            // ── Dynamic Content ──────────────────────
            if savedArticles.isEmpty {
                // Empty State (No bookmarks at all)
                Spacer()
                VStack(spacing: 12) {
                    Image(systemName: "bookmark")
                        .font(.system(size: 48))
                        .foregroundColor(Color(hex: "D86D3F").opacity(0.5))
                    Text("No saved articles yet")
                        .font(.title3.bold())
                    Text("When you bookmark articles, they'll appear here.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                Spacer()
            } else if filteredSavedArticles.isEmpty && !searchText.isEmpty {
                // Search Empty State
                Spacer()
                VStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 48))
                        .foregroundColor(Color(hex: "D86D3F").opacity(0.5))
                    Text("No results for \"\(searchText)\"")
                        .font(.headline)
                    Text("Try searching for a different bookmark.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
            } else {
                // Article List
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 16) {
                        ForEach(filteredSavedArticles) { localArticle in
                            let article = localArticle.toArticle
                            NavigationLink(destination: ArticleDetailView(article: article)) {
                                ArticleRowView(article: article)
                            }
                            .buttonStyle(.plain)
                            .contextMenu {
                                Button(role: .destructive) {
                                    deleteLocally(localArticle)
                                } label: {
                                    Label("Remove Bookmark", systemImage: "trash")
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 24)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color(hex: "FFFDFB").ignoresSafeArea())
        .task {
            // Background sync when the view appears to ensure we match Supabase
            await syncWithCloud()
        }
    }
    
    // Quick local deletion wrapper
    private func deleteLocally(_ article: LocalSavedArticle) {
        let articleId = article.id
        modelContext.delete(article)
        
        // Also sync the deletion to cloud
        Task {
            try? await SavedArticleService.shared.removeArticle(articleId: articleId)
        }
    }
    
    // Background Sync implementation
    private func syncWithCloud() async {
        guard !isSyncing else { return }
        isSyncing = true
        
        do {
            // Fetch source of truth from Cloud
            let cloudArticles = try await SavedArticleService.shared.fetchSavedArticles()
            let cloudIds = Set(cloudArticles.map { $0.id })
            
            // Local set
            let localIds = Set(savedArticles.map { $0.id })
            
            // 1. Insert missing items into Local DB from Cloud
            for cloudArticle in cloudArticles {
                if !localIds.contains(cloudArticle.id) {
                    let newLocal = LocalSavedArticle(article: cloudArticle)
                    modelContext.insert(newLocal)
                }
            }
            
            // 2. Remove stale local items that no longer exist in the Cloud
            for localArticle in savedArticles {
                if !cloudIds.contains(localArticle.id) {
                    modelContext.delete(localArticle)
                }
            }
            
            try? modelContext.save()
            
        } catch {
            print("Failed to sync bookmarks with cloud: \(error)")
        }
        
        isSyncing = false
    }
}
