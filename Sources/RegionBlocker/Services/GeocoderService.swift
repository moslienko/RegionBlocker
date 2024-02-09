//
//  GeocoderService.swift
//
//
//  Created by Pavel Moslienko on 08.02.2024.
//

import CoreLocation

final class GeocoderService {
    
    private static let geocoder = CLGeocoder()
    
    static func determineCountry(by location: CLLocation, completion: @escaping (String?) -> Void) {
        GeocoderService.geocoder.reverseGeocodeLocation(location) { placemarks, error in
            guard error == nil,
                  let placemark = placemarks?.first,
                  let country = placemark.isoCountryCode else {
                completion(nil)
                return
            }
            completion(country)
        }
    }
    
    @available(iOS 13.0, *)
    static func determineCountry(by location: CLLocation) async -> String? {
        await withCheckedContinuation { continuation in
            determineCountry(by: location) { result in
                continuation.resume(returning: result)
            }
        }
    }
}
