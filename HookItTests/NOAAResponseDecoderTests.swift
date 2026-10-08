//
//  NOAAResponseDecoderTests.swift
//  HookItTests
//
//  Created by Dionny Dinza on 9/28/26.
//

import XCTest
@testable import HookIt

final class NOAAResponseDecoderTests: XCTestCase {
    
    let decoder = NOAAResponseDecoder()
    let stationName = "Miami Beach Station"
    
    func testDecodeHappyPath() throws {
        let jsonString = """
        {
            "predictions": [
                {"t": "2026-10-01 08:00", "v": "2.4", "type": "H"},
                {"t": "2026-10-01 14:00", "v": "0.1", "type": "L"}
            ]
        }
        """
        let data = jsonString.data(using: .utf8)!
        
        // Added 'try' because our function now safely throws errors
        let result = try decoder.decodeTides(from: data, stationName: stationName)
        
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result[0].type, "High")
        XCTAssertEqual(result[0].height, 2.4)
        XCTAssertEqual(result[1].time, "2026-10-01 14:00")
    }
    
    func testDecodeMalformedJSONThrowsError() {
        // Missing the "predictions" key entirely
        let jsonString = """
        {
            "error": "No data found"
        }
        """
        let data = jsonString.data(using: .utf8)!
        
        // Now properly asserts that an error is thrown instead of returning []
        XCTAssertThrowsError(try decoder.decodeTides(from: data, stationName: stationName))
    }
    
    func testDecodeSkipsMalformedEntries() throws {
        // One valid entry, one entry missing the 'v' (height) value
        let jsonString = """
        {
            "predictions": [
                {"t": "2026-10-01 08:00", "v": "2.4", "type": "H"},
                {"t": "2026-10-01 14:00", "type": "L"} 
            ]
        }
        """
        let data = jsonString.data(using: .utf8)!
        let result = try decoder.decodeTides(from: data, stationName: stationName)
        
        // Should use compactMap to skip the bad one and only return the 1 valid entry
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0].height, 2.4)
    }
}
