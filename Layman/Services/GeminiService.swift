//
//  GeminiService.swift
//  Layman
//
//  Lightweight service that communicates with the Google Gemini REST API.
//  Reads the API key from Info.plist (fed by Secrets.xcconfig).
//  Does NOT use any third-party SDK — pure URLSession.
//

import Foundation

actor GeminiService {
    static let shared = GeminiService()
    
    // MARK: - Configuration
    
    private let apiKey: String = {
        guard
            let key = Bundle.main.infoDictionary?["GEMINI_API_KEY"] as? String,
            !key.isEmpty
        else {
            fatalError("""
            ❌ Missing GEMINI_API_KEY in Info.plist!
            
            Ensure Config/Secrets.xcconfig contains:
              GEMINI_API_KEY = your_key_here
            
            And Config/Info.plist maps it with:
              <key>GEMINI_API_KEY</key>
              <string>$(GEMINI_API_KEY)</string>
            
            Then clean build (Cmd+Shift+K) and run again.
            """)
        }
        return key
    }()
    
    /// Using gemini-2.0-flash-lite — lighter model with its own separate free-tier quota.
    /// gemini-2.0-flash quota was exhausted on the free plan.
    private var baseURL: String {
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-3.1-flash-lite-preview:generateContent?key=\(apiKey)"
    }
    
    /// Maximum number of automatic retries on rate-limit (429) errors.
    private let maxRetries = 2
    
    // MARK: - Public API
    
    /// Sends a user question plus article context to Gemini and returns a 1–2 sentence answer.
    /// If the question is out of context, Gemini is instructed to politely decline.
    func ask(question: String, articleTitle: String, articleContent: String) async throws -> String {
        
        let systemInstruction = """
        You are "Layman", a friendly AI assistant inside a news reader app.
        
        EXCLUSIVE CONTEXT (SOURCE OF TRUTH):
        Article Title: \(articleTitle)
        Article Content: \(articleContent)
        
        CORE RULES:
        1. You MUST answer every question that is related to the article provided above. 
        2. Even if the question is broad (like "What is this about?" or "Who is mentioned?"), you must answer using ONLY the context provided.
        3. Your answer must be 1–2 sentences maximum.
        4. Write specifically for a non-technical audience. Use very simple, everyday language.
        5. Never use jargon, technical terms, or complex vocabulary (e.g., instead of "infrastructure," use "the basic setup").
        6. Out-of-Context Rule: IF AND ONLY IF the user asks about something completely unrelated (like "What is the weather?" or "How do I bake a cake?"), respond with: "Great question! However, I'm here to help you understand this specific article — feel free to ask me anything about it."
        7. No markdown, no bullet points, no numbered lists.
        """
        
        let requestBody: [String: Any] = [
            "system_instruction": [
                "parts": [
                    ["text": systemInstruction]
                ]
            ],
            "contents": [
                [
                    "parts": [
                        ["text": question]
                    ]
                ]
            ],
            "generationConfig": [
                "temperature": 0.4,
                "maxOutputTokens": 150
            ]
        ]
        
        guard let url = URL(string: baseURL) else {
            throw GeminiError.invalidURL
        }
        
        let jsonData = try JSONSerialization.data(withJSONObject: requestBody)
        
        // Retry loop for rate-limit (429) errors
        for attempt in 0...maxRetries {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = jsonData
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw GeminiError.badResponse
            }
            
            // Rate limited — wait and retry
            if httpResponse.statusCode == 429 {
                if attempt < maxRetries {
                    let delay = Double(attempt + 1) * 5.0 // 5s, 10s
                    print("⏳ Rate limited. Retrying in \(delay)s (attempt \(attempt + 1)/\(maxRetries))...")
                    try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                    continue
                } else {
                    throw GeminiError.rateLimited
                }
            }
            
            guard httpResponse.statusCode == 200 else {
                let body = String(data: data, encoding: .utf8) ?? "No body"
                print("Gemini API Error (\(httpResponse.statusCode)): \(body)")
                throw GeminiError.apiError(statusCode: httpResponse.statusCode, message: body)
            }
            
            // Parse response
            guard
                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                let candidates = json["candidates"] as? [[String: Any]],
                let firstCandidate = candidates.first,
                let content = firstCandidate["content"] as? [String: Any],
                let parts = content["parts"] as? [[String: Any]],
                let text = parts.first?["text"] as? String
            else {
                throw GeminiError.parsingFailed
            }
            
            return text.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        throw GeminiError.rateLimited
    }
    
    /// Rewrites the headline and generates 3 summary cards for the article.
    func translateArticle(articleTitle: String, articleContent: String) async throws -> (headline: String, cards: [String]) {
        
        let systemInstruction = """
        You are "Layman", a professional AI translator for a news app. 
        Your goal is to simplify complex news into easy-to-read "Layman's terms".
        
        TASKS:
        1. HEADLINE: Rewrite the article headline to be catchy, simple, and under 10 words. 
        2. SUMMARY CARDS: Generate exactly 3 cards summarizing the article.
           - Each card: Exactly 2 sentences.
           - Each card: 28 to 35 words (CRITICAL for layout).
           - Language: Casual, simple, no technical jargon.
        
        OUTPUT FORMAT (Use these exact delimiters):
        [HEADLINE] ...
        [CARD_1] ...
        [CARD_2] ...
        [CARD_3] ...
        """
        
        let requestBody: [String: Any] = [
            "system_instruction": [
                "parts": [
                    ["text": systemInstruction]
                ]
            ],
            "contents": [
                [
                    "parts": [
                        ["text": "Simplify this article:\nTitle: \(articleTitle)\nContent: \(articleContent)"]
                    ]
                ]
            ],
            "generationConfig": [
                "temperature": 0.5,
                "maxOutputTokens": 600
            ]
        ]
        
        guard let url = URL(string: baseURL) else {
            throw GeminiError.invalidURL
        }
        
        let jsonData = try JSONSerialization.data(withJSONObject: requestBody)
        
        for attempt in 0...maxRetries {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = jsonData
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 429 {
                if attempt < maxRetries {
                    let delay = Double(attempt + 1) * 5.0
                    try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                    continue
                } else {
                    throw GeminiError.rateLimited
                }
            }
            
            guard
                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                let candidates = json["candidates"] as? [[String: Any]],
                let firstCandidate = candidates.first,
                let content = firstCandidate["content"] as? [String: Any],
                let parts = content["parts"] as? [[String: Any]],
                let text = parts.first?["text"] as? String
            else {
                throw GeminiError.parsingFailed
            }
            
            // Parsing
            let headline = text.components(separatedBy: "[HEADLINE]").last?.components(separatedBy: "[CARD_1]").first?.trimmingCharacters(in: .whitespacesAndNewlines) ?? articleTitle
            let card1 = text.components(separatedBy: "[CARD_1]").last?.components(separatedBy: "[CARD_2]").first?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let card2 = text.components(separatedBy: "[CARD_2]").last?.components(separatedBy: "[CARD_3]").first?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let card3 = text.components(separatedBy: "[CARD_3]").last?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            
            let cards = [card1, card2, card3].filter { !$0.isEmpty }
            
            if cards.count == 3 {
                return (headline, cards)
            }
        }
        
        throw GeminiError.parsingFailed
    }
    
    /// Generates 3 suggested questions based on the article context.
    func generateSuggestions(articleTitle: String, articleContent: String) async throws -> [String] {
        
        let systemInstruction = """
        You are "Layman", operating inside a news reader app.
        Given the article below, generate exactly 3 short, curious questions that a reader might ask.
        Each question must be about the article content.
        Return ONLY the 3 questions, each on a new line, without numbering or bullet points.
        Keep each question under 45 characters.
        
        ARTICLE TITLE: \(articleTitle)
        
        ARTICLE CONTENT: \(articleContent)
        """
        
        let requestBody: [String: Any] = [
            "system_instruction": [
                "parts": [
                    ["text": systemInstruction]
                ]
            ],
            "contents": [
                [
                    "parts": [
                        ["text": "Generate 3 questions about this article."]
                    ]
                ]
            ],
            "generationConfig": [
                "temperature": 0.7,
                "maxOutputTokens": 200
            ]
        ]
        
        guard let url = URL(string: baseURL) else {
            return Self.fallbackSuggestions(title: articleTitle)
        }
        
        let jsonData = try JSONSerialization.data(withJSONObject: requestBody)
        
        // Retry loop for rate-limit (429) errors
        for attempt in 0...maxRetries {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = jsonData
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 429 {
                if attempt < maxRetries {
                    let delay = Double(attempt + 1) * 5.0
                    print("⏳ Suggestions rate limited. Retrying in \(delay)s...")
                    try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                    continue
                } else {
                    return Self.fallbackSuggestions(title: articleTitle)
                }
            }
            
            guard
                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                let candidates = json["candidates"] as? [[String: Any]],
                let firstCandidate = candidates.first,
                let content = firstCandidate["content"] as? [String: Any],
                let parts = content["parts"] as? [[String: Any]],
                let text = parts.first?["text"] as? String
            else {
                return Self.fallbackSuggestions(title: articleTitle)
            }
        
        let questions = text
            .components(separatedBy: "\n")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .prefix(3)
        
            return questions.count >= 3
                ? Array(questions)
                : Self.fallbackSuggestions(title: articleTitle)
        }
        
        return Self.fallbackSuggestions(title: articleTitle)
    }
    
    // MARK: - Fallback
    
    private static func fallbackSuggestions(title: String) -> [String] {
        [
            "What is this article about?",
            "Why does this matter?",
            "Who is involved in this?"
        ]
    }
}

// MARK: - Errors

enum GeminiError: LocalizedError, Equatable {
    case invalidURL
    case badResponse
    case apiError(statusCode: Int, message: String)
    case parsingFailed
    case rateLimited
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid Gemini API URL."
        case .badResponse:
            return "Unexpected response from Gemini."
        case .apiError(let code, let msg):
            return "Gemini API error \(code): \(msg)"
        case .parsingFailed:
            return "Could not parse Gemini's response."
        case .rateLimited:
            return "AI is temporarily busy. Please wait a moment and try again."
        }
    }
}
