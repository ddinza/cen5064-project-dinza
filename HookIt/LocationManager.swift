//
//  LocationManager.swift
//  HookIt
//
//  Created by Dionny Dinza on 8/7/26.
//

import Foundation
import CoreLocation
import Combine

final class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {

    private let manager = CLLocationManager()

    @Published var authorizationStatus: CLAuthorizationStatus
    @Published var location: CLLocation?
    @Published var locationErrorMessage: String?

    override init() {
        authorizationStatus = manager.authorizationStatus

        super.init()

        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }

    func requestLocation() {
        guard authorizationStatus == .authorizedWhenInUse ||
              authorizationStatus == .authorizedAlways else {
            return
        }

        manager.requestLocation()
    }

    func locationManagerDidChangeAuthorization(
        _ manager: CLLocationManager
    ) {
        authorizationStatus = manager.authorizationStatus

        if authorizationStatus == .authorizedWhenInUse ||
            authorizationStatus == .authorizedAlways {
            requestLocation()
        }
    }

    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        location = locations.last
        locationErrorMessage = nil
    }

    func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        locationErrorMessage = error.localizedDescription
    }
}
