//
//  AskLaymanView.swift
//  Layman
//
//  The "Ask Layman" chatbot sheet.
//  Displays a contextual AI chat interface with suggested questions,
//  chat bubbles, and a bottom input bar with speech-to-text.
//

import SwiftUI

struct AskLaymanView: View {
    @State var viewModel: AskLaymanViewModel
    @Environment(\.dismiss) private var dismiss
    
    // Auto-scroll anchor
    @Namespace private var bottomAnchor
    
    var body: some View {
        VStack(spacing: 0) {
            
            // ── Drag Handle ──────────────────────────
            Capsule()
                .fill(Color.gray.opacity(0.4))
                .frame(width: 40, height: 5)
                .padding(.top, 10)
                .padding(.bottom, 6)
            
            // ── Chat Content ─────────────────────────
            ScrollViewReader { proxy in
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        
                        // Welcome message
                        welcomeBubble
                        
                        // Suggested Questions (only before first interaction)
                        if viewModel.showSuggestions {
                            suggestionsSection
                        }
                        
                        // Chat messages
                        ForEach(viewModel.messages) { message in
                            if message.isTypingIndicator {
                                typingIndicatorBubble
                            } else if message.isUser {
                                userBubble(message.text)
                            } else {
                                botBubble(message.text)
                            }
                        }
                        
                        // Invisible anchor for auto-scroll
                        Color.clear
                            .frame(height: 1)
                            .id("bottom")
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 16)
                }
                .onChange(of: viewModel.messages.count) {
                    withAnimation(.easeOut(duration: 0.3)) {
                        proxy.scrollTo("bottom", anchor: .bottom)
                    }
                }
            }
            
            // ── Input Bar ────────────────────────────
            inputBar
        }
        .background(Color(hex: "FFFDFB"))
    }
    
    // MARK: - Welcome Bubble
    
    private var welcomeBubble: some View {
        HStack(alignment: .top, spacing: 10) {
            // Layman bot icon
            Circle()
                .fill(Color(hex: "D86D3F"))
                .frame(width: 36, height: 36)
                .overlay(
                    Image(systemName: "sparkles")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Hi, I'm Layman!")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color(UIColor.label))
                Text("What can I answer for you?")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(Color(UIColor.label).opacity(0.75))
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(Color(hex: "F4EAE2"))
            .cornerRadius(20)
            .cornerRadius(20, corners: [.topLeft, .bottomLeft, .bottomRight])
            
            Spacer()
        }
    }
    
    // MARK: - Suggestions
    
    private var suggestionsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Question Suggestions:")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Color(UIColor.secondaryLabel))
                .padding(.leading, 4)
            
            VStack(alignment: .leading, spacing: 8) {
                if viewModel.isGeneratingSuggestions {
                    HStack(spacing: 8) {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("Generating questions...")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color(UIColor.secondaryLabel))
                            .shimmer() // Subtle animation to signify "thinking"
                    }
                    .padding(.vertical, 8)
                } else {
                    ForEach(viewModel.suggestedQuestions, id: \.self) { question in
                        Button {
                            viewModel.sendMessage(question)
                        } label: {
                            Text(question)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(
                                    Capsule()
                                        .fill(Color(hex: "D86D3F"))
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding(.leading, 46) // Align under the welcome bubble text
        .transition(.opacity.combined(with: .move(edge: .top)))
    }
    
    // MARK: - User Bubble
    
    private func userBubble(_ text: String) -> some View {
        HStack {
            Spacer()
            
            HStack(alignment: .top, spacing: 10) {
                Text(text)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(Color(UIColor.label))
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .background(Color(hex: "F4EAE2").opacity(0.6))
                    .cornerRadius(20)
                
                // User avatar
                Circle()
                    .fill(Color(hex: "D86D3F").opacity(0.7))
                    .frame(width: 32, height: 32)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                    )
            }
        }
    }
    
    // MARK: - Bot Bubble
    
    private func botBubble(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            // Bot icon
            Circle()
                .fill(Color(hex: "D86D3F"))
                .frame(width: 32, height: 32)
                .overlay(
                    Image(systemName: "sparkles")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                )
            
            Text(text)
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(Color(UIColor.label))
                .lineSpacing(4)
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                .background(Color(hex: "F4EAE2"))
                .cornerRadius(20)
            
            Spacer()
        }
    }
    
    // MARK: - Typing Indicator
    
    private var typingIndicatorBubble: some View {
        HStack(alignment: .top, spacing: 10) {
            Circle()
                .fill(Color(hex: "D86D3F"))
                .frame(width: 32, height: 32)
                .overlay(
                    Image(systemName: "sparkles")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                )
            
            HStack(spacing: 6) {
                TypingDot(delay: 0.0)
                TypingDot(delay: 0.2)
                TypingDot(delay: 0.4)
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
            .background(Color(hex: "F4EAE2"))
            .cornerRadius(20)
            
            Spacer()
        }
    }
    
    // MARK: - Input Bar
    
    private var inputBar: some View {
        HStack(spacing: 12) {
            // Text field
            TextField("Type your question...", text: $viewModel.inputText)
                .font(.system(size: 15))
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color(hex: "F4EAE2").opacity(0.5))
                        .stroke(Color(hex: "D86D3F").opacity(0.2), lineWidth: 1)
                )
                .submitLabel(.send)
                .onSubmit {
                    viewModel.sendMessage()
                }
            
            // Microphone button
            Button {
                viewModel.toggleSpeechRecognition()
            } label: {
                Image(systemName: viewModel.speechRecognizer.isListening ? "mic.fill" : "mic")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(
                        viewModel.speechRecognizer.isListening
                            ? Color(hex: "D86D3F")
                            : Color(UIColor.secondaryLabel)
                    )
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(
                                viewModel.speechRecognizer.isListening
                                    ? Color(hex: "D86D3F").opacity(0.15)
                                    : Color.clear
                            )
                    )
                    .animation(.easeInOut(duration: 0.2), value: viewModel.speechRecognizer.isListening)
            }
            
            // Send button
            Button {
                viewModel.sendMessage()
            } label: {
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(Color(hex: "D86D3F"))
                    )
            }
            .disabled(viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !viewModel.speechRecognizer.isListening)
            .opacity(viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1.0)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            Color(hex: "FFFDFB")
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: -4)
        )
        .disabled(viewModel.isGeneratingSuggestions)
        .opacity(viewModel.isGeneratingSuggestions ? 0.6 : 1.0)
        .animation(.easeInOut, value: viewModel.isGeneratingSuggestions)
        // Live speech transcription preview
        .onChange(of: viewModel.speechRecognizer.transcribedText) { _, newValue in
            if viewModel.speechRecognizer.isListening {
                viewModel.inputText = newValue
            }
        }
    }
}

// MARK: - Typing Dot Animation

private struct TypingDot: View {
    let delay: Double
    @State private var isAnimating = false
    
    var body: some View {
        Circle()
            .fill(Color(hex: "D86D3F").opacity(0.6))
            .frame(width: 8, height: 8)
            .offset(y: isAnimating ? -4 : 4)
            .animation(
                .easeInOut(duration: 0.5)
                .repeatForever(autoreverses: true)
                .delay(delay),
                value: isAnimating
            )
            .onAppear {
                isAnimating = true
            }
    }
}

// MARK: - RoundedCorner Helper

private struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

private extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}
