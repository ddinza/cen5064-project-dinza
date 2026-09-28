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
    
    // 1. Inject the new decoder you just built!
    private let decoder = NOAAResponseDecoder()

    func fetchNextTide(for location: CLLocation) async throws -> TideInfo {
        // Fetch nearest station
        let station = try await nearestTideStation(to: location)

        // Build URL
        let endpoint = "https://api.tidesandcurrents.noaa.gov/api/prod/datagetter" +
            "?date=today&station=\(station.id)&product=predictions&datum=MLLW" +
            "&time_zone=lst_ldt&interval=hilo&units=english&application=HookIt&format=json"

        guard let url = URL(string: endpoint) else {
            throw TideServiceError.invalidURL
        }

        // Fetch network data
        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
            throw TideServiceError.invalidResponse
        }

        // 2. Use your robust decoder to safely parse the JSON array
        let allTides = try decoder.decodeTides(from: data, stationName: station.name)

        // 3. Filter for the next upcoming tide
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        formatter.locale = Locale(identifier: "en_US_POSIX")

        let now = Date()

        let upcoming = allTides.compactMap { tide -> (TideInfo, Date)? in
            guard let date = formatter.date(from: tide.time) else { return nil }
            return (tide, date)
        }
        .filter { $0.1 >= now }
        .sorted { $0.1 < $1.1 }

        guard let next = upcoming.first else {
            throw TideServiceError.noPredictions
        }

        // 4. Format the time for the UI
        let displayFormatter = DateFormatter()
        displayFormatter.dateFormat = "h:mm a"

        return TideInfo(
            type: next.0.type,
            time: displayFormatter.string(from: next.1),
            height: next.0.height,
            stationName: station.name
        )
    }

    private func nearestTideStation(to location: CLLocation) async throws -> NOAAStation {
        let endpoint = "https://api.tidesandcurrents.noaa.gov/mdapi/prod/webapi/stations.json?type=tidepredictions"

        guard let url = URL(string: endpoint) else {
            throw TideServiceError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
            throw TideServiceError.invalidResponse
        }

        let stationResponse = try JSONDecoder().decode(NOAAStationResponse.self, from: data)

        guard let closest = stationResponse.stations.min(by: { first, second in
            let firstLocation = CLLocation(latitude: first.lat, longitude: first.lng)
            let secondLocation = CLLocation(latitude: second.lat, longitude: second.lng)
            return firstLocation.distance(from: location) < secondLocation.distance(from: location)
        }) else {
            throw TideServiceError.noStation
        }

        return closest
    }
}

enum TideServiceError: Error {
    case invalidURL
    case invalidResponse
    case noStation
    case noPredictions
}

// MARK: - NOAA Station Models

private struct NOAAStationResponse: Decodable {
    let stations: [NOAAStation]
}

private struct NOAAStation: Decodable {
    let id: String
    let name: String
    let lat: Double
    let lng: Double
}

// Notice that NOAATideResponse and NOAATidePrediction are GONE!
// The NOAAResponseDecoder file handles them entirely now.
