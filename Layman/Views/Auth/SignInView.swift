//
//  SignInView.swift
//  Layman
//
//  Dedicated sign-in screen with email + password fields,
//  loading indicator, error display, and navigation to sign up.
//

import SwiftUI

struct SignInView: View {
    
    // MARK: - Dependencies
    
    /// Shared auth view model.
    @Bindable var viewModel: AuthViewModel
    
    // MARK: - Local State
    
    @State private var email = ""
    @State private var password = ""
    
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
                
                // ── App Branding ──────────────────────
                Text("Layman")
                    .font(.largeTitle.bold())
                    .foregroundStyle(Color(UIColor.label))
                
                Text("Sign in to your account")
                    .font(.subheadline)
                    .foregroundStyle(Color(UIColor.secondaryLabel))
                
                // ── Input Fields ──────────────────────
                VStack(spacing: 16) {
                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .padding()
                        .background(.ultraThinMaterial) // Frosted glass on gradient
                        .cornerRadius(12)
                    
                    SecureField("Password", text: $password)
                        .textContentType(.password)
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                
                // ── Error Banner ──────────────────────
                if let error = viewModel.errorMessage {
                    Text(error)
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                // ── Sign In Button ────────────────────
                Button {
                    Task {
                        await viewModel.signIn(email: email, password: password)
                    }
                } label: {
                    Group {
                        if viewModel.isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Sign In")
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(hex: "D86D3F")) // Brand Orange
                    .foregroundStyle(.white)
                    .cornerRadius(12)
                }
                .disabled(viewModel.isLoading)
                .padding(.horizontal)
                
                Spacer()
                
                // ── Navigate to Sign Up ───────────────
                NavigationLink {
                    SignUpView(viewModel: viewModel)
                } label: {
                    HStack(spacing: 4) {
                        Text("Don't have an account?")
                            .foregroundStyle(Color(UIColor.secondaryLabel))
                        Text("Sign Up")
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
