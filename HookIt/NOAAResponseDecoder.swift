//
//  NOAAResponseDecoder.swift
//  HookIt
//
//  Created by Dionny Dinza on 9/28/26.
//

import Foundation

enum DecoderError: Error {
    case invalidData
}

class NOAAResponseDecoder {
    
    private struct NOAAResponse: Decodable {
        let predictions: [NOAAPrediction]
    }
    
    private struct NOAAPrediction: Decodable {
        let t: String?
        let v: String?
        let type: String?
    }
    
    func decodeTides(from jsonData: Data, stationName: String) throws -> [TideInfo] {
        let decoder = JSONDecoder()
        
        // Throws an error instead of silently returning []
        let response = try decoder.decode(NOAAResponse.self, from: jsonData)
        
        // compactMap safely skips any entries that are missing data or can't be converted
        return response.predictions.compactMap { prediction in
            guard let typeStr = prediction.type,
                  let timeStr = prediction.t,
                  let heightStr = prediction.v,
                  let heightDouble = Double(heightStr) else {
                return nil // Safely skip malformed entries without crashing
            }
            
            return TideInfo(
                type: typeStr == "H" ? "High" : "Low",
                time: timeStr,
                height: heightDouble,
                stationName: stationName
            )
        }
    }
}
