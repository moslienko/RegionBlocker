//
//  LocationService.swift
//
//
//  Created by Pavel Moslienko on 08.02.2024.
//

import CoreLocation

final class LocationService: NSObject {
    
    static let shared = LocationService()
    
    // MARK: - Callbacks
    private let locationManager = CLLocationManager()
    private var completionHandler: ((CLLocation?) -> Void)?
    
    // MARK: - Initialization
    private override init() {
        super.init()
        locationManager.delegate = self
    }
    
    func fetchLocation(completion: @escaping (CLLocation?) -> Void) {
        DispatchQueue.global(qos: .utility).async {
            guard CLLocationManager.locationServicesEnabled() else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            self.completionHandler = completion
            
            switch CLLocationManager.authorizationStatus() {
            case .authorizedWhenInUse, .authorizedAlways:
                self.startUpdatingLocation()
            case .notDetermined:
                DispatchQueue.main.async {
                    self.requestAuthorization()
                }
            case .restricted, .denied:
                DispatchQueue.main.async {
                    completion(nil)
                }
            @unknown default:
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }
}

// MARK: - Module methods
private extension LocationService {
    
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
        completionHandler = nil
    }
    
    func requestAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationService: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        completionHandler?(locations.first)
        stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        completionHandler?(nil)
        stopUpdatingLocation()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = CLLocationManager.authorizationStatus()
        guard status == .authorizedWhenInUse || status == .authorizedAlways else {
            completionHandler?(nil)
            return
        }
        
        startUpdatingLocation()
    }
}
