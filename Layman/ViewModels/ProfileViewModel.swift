//
//  ProfileViewModel.swift
//  Layman
//

import Foundation
import SwiftData
import SwiftUI

@Observable
class ProfileViewModel {
    var isClearingCache = false
    var showCacheClearedAlert = false
    
    @MainActor
    func clearOfflineCache(context: ModelContext) {
        isClearingCache = true
        
        Task {
            // Delete all LocalSavedArticle records
            let descriptor = FetchDescriptor<LocalSavedArticle>()
            if let existing = try? context.fetch(descriptor) {
                for item in existing {
                    context.delete(item)
                }
            }
            
            try? context.save()
            
            await MainActor.run {
                self.isClearingCache = false
                self.showCacheClearedAlert = true
            }
        }
    }
    
    var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "Version \(version) (\(build))"
    }
}
