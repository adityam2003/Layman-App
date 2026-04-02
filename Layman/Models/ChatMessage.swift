//
//  ChatMessage.swift
//  Layman
//
//  Represents a single message in the Ask Layman chat.
//

import Foundation

struct ChatMessage: Identifiable, Equatable {
    let id = UUID()
    let text: String
    let isUser: Bool
    let isTypingIndicator: Bool
    
    /// Standard user message
    static func user(_ text: String) -> ChatMessage {
        ChatMessage(text: text, isUser: true, isTypingIndicator: false)
    }
    
    /// Standard bot response
    static func bot(_ text: String) -> ChatMessage {
        ChatMessage(text: text, isUser: false, isTypingIndicator: false)
    }
    
    /// Animated typing indicator placeholder
    static var typing: ChatMessage {
        ChatMessage(text: "", isUser: false, isTypingIndicator: true)
    }
}
