//
//  FishIdentificationResult.swift
//  HookIt
//

import Foundation

struct FishIdentificationResult: Identifiable, Hashable, Codable {
    let id: UUID
    let speciesName: String
    let confidence: Double
    let alternativeMatches: [FishIdentificationMatch]
    
    init(
        id: UUID = UUID(),
        speciesName: String,
        confidence: Double,
        alternativeMatches: [FishIdentificationMatch]
    ) {
        self.id = id
        self.speciesName = speciesName
        self.confidence = confidence
        self.alternativeMatches = alternativeMatches
    }
    
    enum CodingKeys: String, CodingKey {
        case speciesName
        case confidence
        case alternativeMatches
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(
            keyedBy: CodingKeys.self
        )
        
        id = UUID()
        speciesName = try container.decode(
            String.self,
            forKey: .speciesName
        )
        confidence = try container.decode(
            Double.self,
            forKey: .confidence
        )
        alternativeMatches = try container.decode(
            [FishIdentificationMatch].self,
            forKey: .alternativeMatches
        )
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(
            keyedBy: CodingKeys.self
        )
        
        try container.encode(
            speciesName,
            forKey: .speciesName
        )
        try container.encode(
            confidence,
            forKey: .confidence
        )
        try container.encode(
            alternativeMatches,
            forKey: .alternativeMatches
        )
    }
}

struct FishIdentificationMatch: Identifiable, Hashable, Codable {
    let id: UUID
    let speciesName: String
    let confidence: Double
    
    init(
        id: UUID = UUID(),
        speciesName: String,
        confidence: Double
    ) {
        self.id = id
        self.speciesName = speciesName
        self.confidence = confidence
    }
    
    enum CodingKeys: String, CodingKey {
        case speciesName
        case confidence
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(
            keyedBy: CodingKeys.self
        )
        
        id = UUID()
        speciesName = try container.decode(
            String.self,
            forKey: .speciesName
        )
        confidence = try container.decode(
            Double.self,
            forKey: .confidence
        )
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(
            keyedBy: CodingKeys.self
        )
        
        try container.encode(
            speciesName,
            forKey: .speciesName
        )
        try container.encode(
            confidence,
            forKey: .confidence
        )
    }
}
