//
//  AskLaymanViewModel.swift
//  Layman
//
//  ViewModel for the Ask Layman chatbot sheet.
//  Manages chat messages, communicates with GeminiService,
//  and generates context-aware question suggestions.
//

import Foundation

@Observable
class AskLaymanViewModel {
    
    // MARK: - Public State
    
    var messages: [ChatMessage] = []
    var inputText: String = ""
    var suggestedQuestions: [String] = []
    var isGeneratingSuggestions: Bool = true
    var isLoading: Bool = false
    var showSuggestions: Bool = true
    
    // Speech
    let speechRecognizer = SpeechRecognizer()
    
    // MARK: - Private
    
    private let article: Article
    private let geminiService = GeminiService.shared
    
    // MARK: - Init
    
    init(article: Article) {
        self.article = article
        loadSuggestions()
    }
    
    // MARK: - Article Context
    
    /// Provides the best available text content from the article for the AI context.
    private var articleContext: String {
        // Prefer full content, fall back to description, then title
        if let content = article.content, !content.isEmpty {
            return content
        }
        if let description = article.description, !description.isEmpty {
            return description
        }
        return article.title
    }
    
    // MARK: - Suggestions
    
    private func loadSuggestions() {
        Task { @MainActor in
            do {
                let suggestions = try await geminiService.generateSuggestions(
                    articleTitle: article.title,
                    articleContent: articleContext
                )
                self.suggestedQuestions = suggestions
                self.isGeneratingSuggestions = false
            } catch {
                print("Failed to generate suggestions: \(error)")
                self.suggestedQuestions = [
                    "What is this article about?",
                    "Why does this matter?",
                    "Who is involved in this?"
                ]
                self.isGeneratingSuggestions = false
            }
        }
    }
    
    // MARK: - Send Message
    
    func sendMessage(_ text: String? = nil) {
        let question = (text ?? inputText).trimmingCharacters(in: .whitespacesAndNewlines)
        guard !question.isEmpty else { return }
        
        // Stop speech recognition if active and clear its text
        if speechRecognizer.isListening {
            speechRecognizer.stopListening()
        }
        speechRecognizer.transcribedText = ""
        
        // Clear input & hide suggestions after first interaction
        inputText = ""
        showSuggestions = false
        
        // Add user bubble
        messages.append(.user(question))
        
        // Add typing indicator
        isLoading = true
        messages.append(.typing)
        
        Task { @MainActor in
            do {
                let response = try await geminiService.ask(
                    question: question,
                    articleTitle: article.title,
                    articleContent: articleContext
                )
                
                // Remove typing indicator and add real response
                messages.removeAll { $0.isTypingIndicator }
                messages.append(.bot(response))
            } catch let error as GeminiError where error == .rateLimited {
                messages.removeAll { $0.isTypingIndicator }
                messages.append(.bot("I'm a little overwhelmed right now! Please wait about 30 seconds and try again. 🙏"))
                print("Gemini rate limited: \(error)")
            } catch {
                messages.removeAll { $0.isTypingIndicator }
                messages.append(.bot("Hmm, something went wrong on my end. Please try asking again!"))
                print("Gemini error: \(error)")
            }
            isLoading = false
        }
    }
    
    // MARK: - Speech-to-Text
    
    func toggleSpeechRecognition() {
        if speechRecognizer.isListening {
            speechRecognizer.stopListening()
            // Take the transcribed text and put it in the input field
            if !speechRecognizer.transcribedText.isEmpty {
                inputText = speechRecognizer.transcribedText
            }
        } else {
            speechRecognizer.requestAuthorization { [weak self] authorized in
                guard let self = self, authorized else { return }
                self.speechRecognizer.startListening()
            }
        }
    }
}
