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
    
    func fetchCurrentWeather(
        for location: CLLocation
    ) async throws -> CurrentWeather {
        
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        
        let endpoint =
            "https://api.open-meteo.com/v1/forecast" +
            "?latitude=\(latitude)" +
            "&longitude=\(longitude)" +
            "&current=temperature_2m,weather_code" +
            "&temperature_unit=fahrenheit"
        
        guard let url = URL(string: endpoint) else {
            throw WeatherServiceError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(
            from: url
        )
        
        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode else {
            throw WeatherServiceError.invalidResponse
        }
        
        let weatherResponse = try JSONDecoder().decode(
            OpenMeteoResponse.self,
            from: data
        )
        
        return CurrentWeather(
            temperature: weatherResponse.current.temperature2m,
            condition: conditionName(
                for: weatherResponse.current.weatherCode
            ),
            systemImage: conditionIcon(
                for: weatherResponse.current.weatherCode
            )
        )
    }
    
    private func conditionName(
        for code: Int
    ) -> String {
        switch code {
        case 0:
            return "Clear"
            
        case 1, 2:
            return "Partly Cloudy"
            
        case 3:
            return "Cloudy"
            
        case 45, 48:
            return "Fog"
            
        case 51, 53, 55, 56, 57:
            return "Drizzle"
            
        case 61, 63, 65, 66, 67:
            return "Rain"
            
        case 71, 73, 75, 77:
            return "Snow"
            
        case 80, 81, 82:
            return "Showers"
            
        case 85, 86:
            return "Snow Showers"
            
        case 95, 96, 99:
            return "Thunderstorms"
            
        default:
            return "Weather"
        }
    }
    
    private func conditionIcon(
        for code: Int
    ) -> String {
        switch code {
        case 0:
            return "sun.max.fill"
            
        case 1, 2:
            return "cloud.sun.fill"
            
        case 3:
            return "cloud.fill"
            
        case 45, 48:
            return "cloud.fog.fill"
            
        case 51, 53, 55, 56, 57:
            return "cloud.drizzle.fill"
            
        case 61, 63, 65, 66, 67:
            return "cloud.rain.fill"
            
        case 71, 73, 75, 77, 85, 86:
            return "cloud.snow.fill"
            
        case 80, 81, 82:
            return "cloud.heavyrain.fill"
            
        case 95, 96, 99:
            return "cloud.bolt.rain.fill"
            
        default:
            return "cloud.sun.fill"
        }
    }
}

enum WeatherServiceError: Error {
    case invalidURL
    case invalidResponse
}

private struct OpenMeteoResponse: Decodable {
    let current: OpenMeteoCurrentWeather
}

private struct OpenMeteoCurrentWeather: Decodable {
    let temperature2m: Double
    let weatherCode: Int
    
    enum CodingKeys: String, CodingKey {
        case temperature2m = "temperature_2m"
        case weatherCode = "weather_code"
    }
}
