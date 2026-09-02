//
//  HomeView.swift
//  HookIt
//
//  Created by Dionny Dinza on 6/24/26.
//

import SwiftUI
import UIKit
import CoreLocation

struct HomeView: View {
    @EnvironmentObject var catchManager: CatchManager
    @StateObject private var locationManager = LocationManager()

    @State private var currentWeather: CurrentWeather?
    @State private var isLoadingWeather = false

    @State private var currentTide: TideInfo?
    @State private var isLoadingTide = false

    var body: some View {
        ZStack {
            Image("homebackground")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .opacity(0.18)

            ScrollView {
                VStack(spacing: 12) {
                    Image("hookitlogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 92, height: 92)
                        .clipShape(
                            RoundedRectangle(
                                cornerRadius: 24,
                                style: .continuous
                            )
                        )
                        .shadow(radius: 8)
                        .padding(.top, 60)
                        .padding(.bottom, -8)

                    Text("HookIt")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text(
                        "Your personal fishing guide for species, bait, regulations, and catch tracking."
                    )
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)

                    NavigationLink(destination: IdentifyItView()) {
                        FeaturedHomeCard(
                            title: "Identify It",
                            subtitle: "Take or choose a photo to identify and save your catch.",
                            imageName: "identifyit"
                        )
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 4)

                    fishingConditionsCard
                        .padding(.top, 4)
                }
                .padding(.horizontal)
                .padding(.bottom, 24)
            }
        }
        .task(id: locationManager.location?.timestamp) {
            guard locationManager.location != nil else {
                return
            }

            async let weatherTask: Void = loadWeather()
            async let tideTask: Void = loadTide()

            _ = await (weatherTask, tideTask)
        }
    }

    // MARK: - Fishing Conditions

    private var fishingConditionsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label(
                    "Fishing Conditions",
                    systemImage: "water.waves"
                )
                .font(.headline)

                Spacer()

                Image(systemName: "location.fill")
                    .foregroundStyle(.blue)
            }

            switch locationManager.authorizationStatus {

            case .notDetermined:
                Text(
                    "Enable your location to see local weather, tides, and moon conditions."
                )
                .font(.subheadline)
                .foregroundStyle(.secondary)

                Button {
                    locationManager.requestPermission()
                } label: {
                    Label(
                        "Enable Location",
                        systemImage: "location.circle.fill"
                    )
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
                .buttonStyle(.borderedProminent)

            case .authorizedWhenInUse, .authorizedAlways:
                HStack(spacing: 0) {
                    weatherConditionView

                    Divider()
                        .frame(height: 55)

                    tideConditionView

                    Divider()
                        .frame(height: 55)

                    conditionValue(
                        icon: MoonPhaseService.currentPhaseIcon(),
                        title: "Moon",
                        value: MoonPhaseService.currentPhase()
                    )
                }

                Text("Location enabled")
                    .font(.caption)
                    .foregroundStyle(.secondary)

            case .denied, .restricted:
                Text(
                    "Location access is off. Enable it in Settings to view local fishing conditions."
                )
                .font(.subheadline)
                .foregroundStyle(.secondary)

                Button("Open Settings") {
                    guard let settingsURL = URL(
                        string: UIApplication.openSettingsURLString
                    ) else {
                        return
                    }

                    UIApplication.shared.open(settingsURL)
                }

            @unknown default:
                Text("Location status unavailable.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(
            Color.gray.opacity(0.08)
        )
        .clipShape(
            RoundedRectangle(
                cornerRadius: 18,
                style: .continuous
            )
        )
        .shadow(radius: 3)
    }

    // MARK: - Weather

    private var weatherConditionView: some View {
        VStack(spacing: 6) {
            if isLoadingWeather {
                ProgressView()

                Text("Weather")
                    .font(.caption)
                    .fontWeight(.semibold)

                Text("Loading...")
                    .font(.caption2)
                    .foregroundStyle(.secondary)

            } else if let currentWeather {
                Image(systemName: currentWeather.systemImage)
                    .font(.title2)
                    .foregroundStyle(.blue)

                Text("Weather")
                    .font(.caption)
                    .fontWeight(.semibold)

                Text(
                    "\(Int(currentWeather.temperature.rounded()))°F"
                )
                .font(.caption)
                .fontWeight(.semibold)

                Text(currentWeather.condition)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)

            } else {
                Image(systemName: "cloud.sun.fill")
                    .font(.title2)
                    .foregroundStyle(.blue)

                Text("Weather")
                    .font(.caption)
                    .fontWeight(.semibold)

                Text("--")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Tides

    private var tideConditionView: some View {
        VStack(spacing: 6) {
            if isLoadingTide {
                ProgressView()

                Text("Tides")
                    .font(.caption)
                    .fontWeight(.semibold)

                Text("Loading...")
                    .font(.caption2)
                    .foregroundStyle(.secondary)

            } else if let currentTide {
                Image(systemName: "water.waves")
                    .font(.title2)
                    .foregroundStyle(.blue)

                Text("Tides")
                    .font(.caption)
                    .fontWeight(.semibold)

                Text("\(currentTide.type) Tide")
                    .font(.caption)
                    .fontWeight(.semibold)

                Text(currentTide.time)
                    .font(.caption2)
                    .foregroundStyle(.secondary)

                Text(currentTide.stationName)
                    .font(.system(size: 9))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

            } else {
                Image(systemName: "water.waves")
                    .font(.title2)
                    .foregroundStyle(.blue)

                Text("Tides")
                    .font(.caption)
                    .fontWeight(.semibold)

                Text("--")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Moon

    private func conditionValue(
        icon: String,
        title: String,
        value: String
    ) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.blue)

            Text(title)
                .font(.caption)
                .fontWeight(.semibold)

            Text(value)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Data Loading

    @MainActor
    private func loadWeather() async {
        guard let location = locationManager.location else {
            return
        }

        isLoadingWeather = true

        defer {
            isLoadingWeather = false
        }

        do {
            currentWeather = try await WeatherService()
                .fetchCurrentWeather(
                    for: location
                )
        } catch {
            print(
                "Weather Error: \(error.localizedDescription)"
            )

            currentWeather = nil
        }
    }

    @MainActor
    private func loadTide() async {
        guard let location = locationManager.location else {
            return
        }

        isLoadingTide = true

        defer {
            isLoadingTide = false
        }

        do {
            currentTide = try await TideService()
                .fetchNextTide(
                    for: location
                )

            if let currentTide {
                print(
                    "NOAA Tide Station: \(currentTide.stationName)"
                )

                print(
                    "Next Tide: \(currentTide.type) at \(currentTide.time)"
                )
            }

        } catch {
            print(
                "Tide Error: \(error.localizedDescription)"
            )

            currentTide = nil
        }
    }
}

// MARK: - Home Cards

struct FeaturedHomeCard: View {
    let title: String
    let subtitle: String
    let imageName: String

    var body: some View {
        HomeCardLayout(
            title: title,
            subtitle: subtitle,
            imageName: imageName,
            background: AnyShapeStyle(
                Color.blue.opacity(0.08)
            )
        )
    }
}

struct HomeCard: View {
    let title: String
    let subtitle: String
    let imageName: String

    var body: some View {
        HomeCardLayout(
            title: title,
            subtitle: subtitle,
            imageName: imageName,
            background: AnyShapeStyle(
                .ultraThinMaterial
            )
        )
    }
}

private struct HomeCardLayout: View {
    let title: String
    let subtitle: String
    let imageName: String
    let background: AnyShapeStyle

    var body: some View {
        HStack(spacing: 12) {
            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 95, height: 72)
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: 12,
                        style: .continuous
                    )
                )
                .clipped()

            VStack(
                alignment: .leading,
                spacing: 2
            ) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.primary)

                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(background)
        .clipShape(
            RoundedRectangle(
                cornerRadius: 18,
                style: .continuous
            )
        )
        .shadow(radius: 3)
    }
}

#Preview {
    HomeView()
        .environmentObject(CatchManager())
}
