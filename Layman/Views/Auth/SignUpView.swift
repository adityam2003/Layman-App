//
//  SignUpView.swift
//  Layman
//
//  Dedicated sign-up screen with email, password,
//  confirm password, loading indicator, and error display.
//

import SwiftUI

struct SignUpView: View {
    
    // MARK: - Dependencies
    
    /// Shared auth view model.
    @Bindable var viewModel: AuthViewModel
    
    // MARK: - Local State
    
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    
    /// Used to pop back to SignInView after successful sign-up
    /// (when email confirmation is required).
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            // Theme Background matches WelcomeView
            LinearGradient(
                stops: [
                    .init(color: Color(hex: "E8BCAA"), location: 0.0),
                    .init(color: Color(hex: "FFF4ED"), location: 0.4),
                    .init(color: Color(hex: "F2D2BE"), location: 1.0)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 24) {
                
                Spacer()
                
                // ── Header ───────────────────────────
                Text("Create Account")
                    .font(.largeTitle.bold())
                    .foregroundStyle(Color(UIColor.label))
                
                Text("Sign up to get started")
                    .font(.subheadline)
                    .foregroundStyle(Color(UIColor.secondaryLabel))
                
                // ── Input Fields ─────────────────────
                VStack(spacing: 16) {
                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)
                    
                    SecureField("Password", text: $password)
                        .textContentType(.newPassword)
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)
                    
                    SecureField("Confirm Password", text: $confirmPassword)
                        .textContentType(.newPassword)
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                
                // ── Error Banner ─────────────────────
                if let error = viewModel.errorMessage {
                    Text(error)
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                // ── Sign Up Button ───────────────────
                Button {
                    // Client-side password match check before hitting the API.
                    guard password == confirmPassword else {
                        viewModel.errorMessage = "Passwords do not match."
                        return
                    }
                    
                    Task {
                        await viewModel.signUp(email: email, password: password)
                    }
                } label: {
                    Group {
                        if viewModel.isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Sign Up")
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(hex: "D86D3F")) // Brand orange
                    .foregroundStyle(.white)
                    .cornerRadius(12)
                }
                .disabled(viewModel.isLoading)
                .padding(.horizontal)
                
                Spacer()
                
                // ── Navigate back to Sign In ─────────
                Button {
                    dismiss()
                } label: {
                    HStack(spacing: 4) {
                        Text("Already have an account?")
                            .foregroundStyle(Color(UIColor.secondaryLabel))
                        Text("Sign In")
                            .fontWeight(.bold)
                            .foregroundStyle(Color(hex: "D86D3F"))
                    }
                    .font(.subheadline)
                }
                .padding(.bottom, 24)
            }
            .onAppear {
                viewModel.errorMessage = nil
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}
