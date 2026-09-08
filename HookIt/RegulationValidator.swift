//
//  RegulationValidator.swift
//  HookIt
//  Sept 7 2026
// Created by Dionny Dinza

import Foundation

public enum ComplianceStatus: Equatable {
    case legal
    case undersized(min: Double, recorded: Double)
    case oversized(max: Double, recorded: Double)
    case seasonClosed(season: String)
    case unregulated
    
    public var warningTitle: String {
        switch self {
        case .legal:
            return "Compliant Catch"
        case .undersized:
            return "Undersized Catch Warning"
        case .oversized:
            return "Oversized Catch Warning"
        case .seasonClosed:
            return "Closed Season Warning"
        case .unregulated:
            return "General Bag Limits Apply"
        }
    }
    
    public var warningMessage: String {
        switch self {
        case .legal:
            return "This catch meets legal size requirements."
        case .undersized(let min, let recorded):
            return "Legal minimum is \(String(format: "%.1f", min)) inches. Recorded: \(String(format: "%.1f", recorded)) inches. Must be released immediately."
        case .oversized(let max, let recorded):
            return "Legal maximum is \(String(format: "%.1f", max)) inches. Recorded: \(String(format: "%.1f", recorded)) inches. Exceeds harvest slot limit."
        case .seasonClosed(let season):
            return "Harvest is currently prohibited. Open season: \(season)."
        case .unregulated:
            return "No specific slot size restrictions documented for this species."
        }
    }
    
    public var isViolation: Bool {
        switch self {
        case .undersized, .oversized, .seasonClosed:
            return true
        default:
            return false
        }
    }
}

public struct RegulationValidator {
    
    /// Evaluates catch compliance against static Florida fishing regulations
    public static func validate(speciesName: String, lengthInches: Double, date: Date = Date()) -> ComplianceStatus {
        guard let reg = RegulationData.findRegulation(named: speciesName) else {
            return .unregulated
        }
        
        // 1. Check Slot / Size Limits
        if let limits = parseSlotLimit(from: reg.legalSize) {
            if let minSize = limits.min, lengthInches < minSize {
                return .undersized(min: minSize, recorded: lengthInches)
            }
            if let maxSize = limits.max, lengthInches > maxSize {
                return .oversized(max: maxSize, recorded: lengthInches)
            }
        }
        
        // 2. Check Season Closure
        let seasonText = reg.season.lowercased()
        if seasonText.contains("closed") && !seasonText.contains("open year-round") {
            return .seasonClosed(season: reg.season)
        }
        
        return .legal
    }
    
    /// Parses numerical min and max thresholds from strings like '28"–32"' or 'Min 14"'
    private static func parseSlotLimit(from rawString: String) -> (min: Double?, max: Double?)? {
        let clean = rawString.replacingOccurrences(of: "\"", with: "").trimmingCharacters(in: .whitespaces)
        
        // Check for range (e.g. 28-32 or 28–32)
        let separators = CharacterSet(charactersIn: "-–")
        let components = clean.components(separatedBy: separators)
        
        if components.count == 2,
           let minVal = Double(components[0].trimmingCharacters(in: .whitespaces)),
           let maxVal = Double(components[1].trimmingCharacters(in: .whitespaces)) {
            return (min: minVal, max: maxVal)
        }
        
        // Check for minimums (e.g. "Min 14" or "14" min")
        let numbers = clean.components(separatedBy: CharacterSet.decimalDigits.inverted)
            .compactMap { Double($0) }
        
        if let first = numbers.first {
            return (min: first, max: nil)
        }
        
        return nil
    }
}
