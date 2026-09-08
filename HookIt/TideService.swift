//
//  TideService.swift
//  HookIt
//

import Foundation
import CoreLocation

struct TideInfo {
    let type: String
    let time: String
    let height: Double
    let stationName: String
}

struct TideService {
    func fetchNextTide(for location: CLLocation) async throws -> TideInfo {
        // Brief mock delay to simulate async retrieval
        try await Task.sleep(nanoseconds: 200_000_000)
        
        let stationName = location.coordinate.latitude < 26.0
            ? "Naples Pier Station"
            : "Biscayne Bay Station"
        
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: Date())
        let tideType = (hour % 6 < 3) ? "High" : "Low"
        let height = tideType == "High" ? 2.6 : 0.2
        
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        let futureDate = calendar.date(byAdding: .minute, value: 45, to: Date()) ?? Date()
        
        return TideInfo(
            type: tideType,
            time: formatter.string(from: futureDate),
            height: height,
            stationName: stationName
        )
    }
}

enum TideServiceError: Error {
    case noStation
    case noPredictions
}
