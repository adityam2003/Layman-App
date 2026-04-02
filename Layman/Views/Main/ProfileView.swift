//
//  ProfileView.swift
//  Layman
//

import SwiftUI
import SwiftData

struct ProfileView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var authViewModel: AuthViewModel
    @State private var profileViewModel = ProfileViewModel()
    
    var body: some View {
        ZStack {
            // Background
            Color(hex: "FFFDFB").ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    
                    // ── User Identity Section ───────────────────
                    VStack(spacing: 12) {
                        // User Initials Circle
                        ZStack {
                            Circle()
                                .fill(Color(hex: "D86D3F"))
                                .frame(width: 80, height: 80)
                            
                            Text(String(authViewModel.userName.prefix(1)))
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.white)
                        }
                        
                        VStack(spacing: 4) {
                            Text(authViewModel.userName)
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(Color(UIColor.label))
                            
                            Text(authViewModel.userEmail)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color.gray)
                        }
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 10)
                    
                    // ── Settings Sections ───────────────────────
                    VStack(spacing: 16) {
                        // Account
                        VStack(alignment: .leading, spacing: 10) {
                            VStack {
                                settingRow(
                                    icon: "rectangle.portrait.and.arrow.right",
                                    iconColor: .gray,
                                    title: "Sign Out",
                                    subtitle: "Securely log out of your account",
                                    isDestructive: true
                                ) {
                                    Task {
                                        await authViewModel.signOut()
                                    }
                                }
                            }
                            .background(Color(hex: "F4EAE2"))
                            .cornerRadius(24)
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
            }
        }
        .alert("Cache Cleared", isPresented: $profileViewModel.showCacheClearedAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("All offline articles have been removed from this device.")
        }
    }
    
    // MARK: - Components
    
    private func profileSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title.uppercased())
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.gray)
                .padding(.leading, 10)
            
            VStack {
                content()
            }
            .background(Color(hex: "F4EAE2"))
            .cornerRadius(24)
        }
    }
    
    private func settingRow(
        icon: String,
        iconColor: Color,
        title: String,
        subtitle: String?,
        isDestructive: Bool = false,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(iconColor.opacity(0.1))
                    
                    Image(systemName: icon)
                        .foregroundColor(iconColor)
                        .font(.system(size: 16, weight: .semibold))
                }
                .frame(width: 36, height: 36)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(isDestructive ? .red : Color(UIColor.label))
                    
                    if let sub = subtitle {
                        Text(sub)
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color.gray.opacity(0.5))
            }
            .padding(16)
        }
    }
}
