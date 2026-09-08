//
//  WeatherService.swift
//  HookIt
//

import Foundation
import CoreLocation

struct CurrentWeather {
    let temperature: Double
    let condition: String
    let systemImage: String
}

struct WeatherService {
    func fetchCurrentWeather(for location: CLLocation) async throws -> CurrentWeather {
        // Brief mock delay to simulate async retrieval
        try await Task.sleep(nanoseconds: 200_000_000)
        
        let isWarm = location.coordinate.latitude < 30.0
        let temp: Double = isWarm ? 82.0 : 72.0
        
        return CurrentWeather(
            temperature: temp,
            condition: "Partly Cloudy",
            systemImage: "cloud.sun.fill"
        )
    }
}

enum WeatherServiceError: Error {
    case invalidURL
    case invalidResponse
}
