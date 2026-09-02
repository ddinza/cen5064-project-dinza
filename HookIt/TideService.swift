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

    func fetchNextTide(
        for location: CLLocation
    ) async throws -> TideInfo {

        let station = try await nearestTideStation(
            to: location
        )

        let endpoint =
            "https://api.tidesandcurrents.noaa.gov/api/prod/datagetter" +
            "?date=today" +
            "&station=\(station.id)" +
            "&product=predictions" +
            "&datum=MLLW" +
            "&time_zone=lst_ldt" +
            "&interval=hilo" +
            "&units=english" +
            "&application=HookIt" +
            "&format=json"

        guard let url = URL(string: endpoint) else {
            throw TideServiceError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(
            from: url
        )

        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode else {
            throw TideServiceError.invalidResponse
        }

        let tideResponse = try JSONDecoder().decode(
            NOAATideResponse.self,
            from: data
        )

        guard !tideResponse.predictions.isEmpty else {
            throw TideServiceError.noPredictions
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        formatter.locale = Locale(identifier: "en_US_POSIX")

        let now = Date()

        let upcoming = tideResponse.predictions
            .compactMap { prediction -> (NOAATidePrediction, Date)? in
                guard let date = formatter.date(
                    from: prediction.time
                ) else {
                    return nil
                }

                return (prediction, date)
            }
            .filter { $0.1 >= now }
            .sorted { $0.1 < $1.1 }

        guard let next = upcoming.first else {
            throw TideServiceError.noPredictions
        }

        let displayFormatter = DateFormatter()
        displayFormatter.dateFormat = "h:mm a"

        let tideType: String

        switch next.0.type {
        case "H":
            tideType = "High"
        case "L":
            tideType = "Low"
        default:
            tideType = "Tide"
        }

        return TideInfo(
            type: tideType,
            time: displayFormatter.string(from: next.1),
            height: Double(next.0.value) ?? 0,
            stationName: station.name
        )
    }

    private func nearestTideStation(
        to location: CLLocation
    ) async throws -> NOAAStation {

        let endpoint =
            "https://api.tidesandcurrents.noaa.gov/mdapi/prod/webapi/stations.json?type=tidepredictions"

        guard let url = URL(string: endpoint) else {
            throw TideServiceError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(
            from: url
        )

        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode else {
            throw TideServiceError.invalidResponse
        }

        let stationResponse = try JSONDecoder().decode(
            NOAAStationResponse.self,
            from: data
        )

        guard let closest = stationResponse.stations.min(
            by: { first, second in

                let firstLocation = CLLocation(
                    latitude: first.lat,
                    longitude: first.lng
                )

                let secondLocation = CLLocation(
                    latitude: second.lat,
                    longitude: second.lng
                )

                return firstLocation.distance(from: location)
                    < secondLocation.distance(from: location)
            }
        ) else {
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

// MARK: - NOAA Tide Models

private struct NOAATideResponse: Decodable {
    let predictions: [NOAATidePrediction]
}

private struct NOAATidePrediction: Decodable {
    let time: String
    let value: String
    let type: String

    enum CodingKeys: String, CodingKey {
        case time = "t"
        case value = "v"
        case type
    }
}
