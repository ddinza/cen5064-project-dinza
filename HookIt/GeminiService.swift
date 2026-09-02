//
//  GeminiService.swift
//  HookIt
//

import Foundation
import UIKit

enum GeminiServiceError: LocalizedError {
    case missingAPIKey
    case invalidImage
    case invalidURL
    case invalidResponse
    case emptyResponse
    case decodingFailed(String)
    case requestFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "The Gemini API key could not be found."
            
        case .invalidImage:
            return "The selected image could not be prepared for identification."
            
        case .invalidURL:
            return "The Gemini request URL could not be created."
            
        case .invalidResponse:
            return "Gemini returned an invalid response."
            
        case .emptyResponse:
            return "Gemini did not return an identification result."
            
        case .decodingFailed(let message):
            return "The identification result could not be read: \(message)"
            
        case .requestFailed(let message):
            return message
        }
    }
}

struct GeminiService {
    private let modelName = "gemini-3.6-flash"
    
    func identifyFish(
        imageData: Data,
        availableSpecies: [String],
        onRetry: (() async -> Void)? = nil
    ) async throws -> FishIdentificationResult {
        
        do {
            return try await performIdentification(
                imageData: imageData,
                availableSpecies: availableSpecies
            )
        } catch let error as URLError {
            if error.code == .timedOut ||
                error.code == .networkConnectionLost ||
                error.code == .notConnectedToInternet {
                
                await onRetry?()
                
                return try await performIdentification(
                    imageData: imageData,
                    availableSpecies: availableSpecies
                )
            }
            
            throw error
        }
    }

    private func performIdentification(
        imageData: Data,
        availableSpecies: [String]
    ) async throws -> FishIdentificationResult {
        let apiKey = try loadAPIKey()
        
        guard let image = UIImage(data: imageData),
              let jpegData = image.jpegData(
                compressionQuality: 0.75
              ) else {
            throw GeminiServiceError.invalidImage
        }
        
        let endpoint =
            "https://generativelanguage.googleapis.com/v1beta/models/\(modelName):generateContent"
        
        guard let url = URL(string: endpoint) else {
            throw GeminiServiceError.invalidURL
        }
        
        let speciesList = availableSpecies
            .sorted()
            .joined(separator: "\n")
        
        let prompt = """
        Identify the fish visible in this image for the HookIt fishing app.

        HookIt currently contains these species:
        \(speciesList)

        Instructions:
        - Identify the most likely fish species visible in the image.
        - Prefer an exact species from the HookIt catalog only when the visual evidence supports it.
        - Do not force a HookIt catalog match.
        - If the fish is not in the catalog, return its most likely common name.
        - Return no more than two alternative matches.
        - Confidence values must be numbers from 0.0 through 1.0.
        - If no fish is clearly visible, use "Unable to Identify" as the speciesName.
        - Return only JSON with no Markdown or explanation.

        Required JSON format:
        {
          "speciesName": "Great Barracuda",
          "confidence": 0.96,
          "alternativeMatches": [
            {
              "speciesName": "Wahoo",
              "confidence": 0.03
            },
            {
              "speciesName": "King Mackerel",
              "confidence": 0.01
            }
          ]
        }
        """
        
        let requestBody = GeminiRequest(
            contents: [
                GeminiContent(
                    parts: [
                        GeminiPart(
                            text: prompt,
                            inlineData: nil
                        ),
                        GeminiPart(
                            text: nil,
                            inlineData: GeminiInlineData(
                                mimeType: "image/jpeg",
                                data: jpegData.base64EncodedString()
                            )
                        )
                    ]
                )
            ],
            generationConfig: GeminiGenerationConfig(
                responseMimeType: "application/json"
            )
        )
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 60
        
        request.setValue(
            "application/json",
            forHTTPHeaderField: "Content-Type"
        )
        
        request.setValue(
            apiKey,
            forHTTPHeaderField: "x-goog-api-key"
        )
        
        request.httpBody = try JSONEncoder().encode(requestBody)
        
        let (data, response) = try await URLSession.shared.data(
            for: request
        )
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw GeminiServiceError.invalidResponse
        }
        
        guard 200..<300 ~= httpResponse.statusCode else {
            let serverMessage =
                String(data: data, encoding: .utf8)
                ?? "Gemini request failed."
            
            throw GeminiServiceError.requestFailed(
                "Gemini error \(httpResponse.statusCode): \(serverMessage)"
            )
        }
        
        let geminiResponse: GeminiResponse
        
        do {
            geminiResponse = try JSONDecoder().decode(
                GeminiResponse.self,
                from: data
            )
        } catch {
            throw GeminiServiceError.decodingFailed(
                error.localizedDescription
            )
        }
        
        let responseText = geminiResponse.candidates
            .first?
            .content
            .parts
            .compactMap(\.text)
            .joined()
        
        guard let responseText,
              !responseText.isEmpty else {
            throw GeminiServiceError.emptyResponse
        }
        
        guard let resultData = responseText.data(
            using: .utf8
        ) else {
            throw GeminiServiceError.invalidResponse
        }
        
        do {
            return try JSONDecoder().decode(
                FishIdentificationResult.self,
                from: resultData
            )
        } catch {
            print("Raw Gemini result: \(responseText)")
            
            throw GeminiServiceError.decodingFailed(
                error.localizedDescription
            )
        }
    }
    
    private func loadAPIKey() throws -> String {
        guard let url = Bundle.main.url(
            forResource: "Secrets",
            withExtension: "plist"
        ),
        let data = try? Data(contentsOf: url),
        let propertyList =
            try? PropertyListSerialization.propertyList(
                from: data,
                options: [],
                format: nil
            ) as? [String: Any],
        let apiKey =
            propertyList["GEMINI_API_KEY"] as? String else {
            throw GeminiServiceError.missingAPIKey
        }
        
        let trimmedKey = apiKey.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        
        guard !trimmedKey.isEmpty else {
            throw GeminiServiceError.missingAPIKey
        }
        
        return trimmedKey
    }
}

// MARK: - Gemini Request Models

private struct GeminiRequest: Encodable {
    let contents: [GeminiContent]
    let generationConfig: GeminiGenerationConfig
}

private struct GeminiContent: Encodable {
    let parts: [GeminiPart]
}

private struct GeminiPart: Encodable {
    let text: String?
    let inlineData: GeminiInlineData?
}

private struct GeminiInlineData: Encodable {
    let mimeType: String
    let data: String
}

private struct GeminiGenerationConfig: Encodable {
    let responseMimeType: String
}

// MARK: - Gemini Response Models

private struct GeminiResponse: Decodable {
    let candidates: [GeminiCandidate]
}

private struct GeminiCandidate: Decodable {
    let content: GeminiResponseContent
}

private struct GeminiResponseContent: Decodable {
    let parts: [GeminiResponsePart]
}

private struct GeminiResponsePart: Decodable {
    let text: String?
}
