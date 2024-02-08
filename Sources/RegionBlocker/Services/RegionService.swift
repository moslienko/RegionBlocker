//
//  RegionService.swift
//
//
//  Created by Pavel Moslienko on 08.02.2024.
//

import Foundation
import CoreLocation

final public class RegionService {
    
    static public let shared = RegionService()
    
    public var allowedRegions = ["RU", "BY"]
    public var allowedLanguages = ["ru", "be"]
    
    public var blockedByCustomFlag = false
    public var blockedByRegion = true
    public var blockedByLocation: Bool?
    
    public var isBlocked: Bool {
        print("[RegionService] blockedByCustomFlag - \(blockedByCustomFlag), blockedByLocation - \(blockedByLocation), blockedByRegion - \(blockedByRegion)")
        if blockedByCustomFlag {
            return true
        }
        if blockedByRegion {
            return true
        }
        if let blockedByLocation = blockedByLocation {
            return blockedByLocation
        }
        return blockedByRegion
    }
    
    private init() {}
    
    public func checkRegion(completion: ((Bool) -> Void)?) {
        guard let currentRegion = Locale.current.regionCode,
              let currentLanguage = Locale.current.languageCode else {
            blockedByRegion = true
            completion?(isBlocked)
            return
        }
        
        let isAllowRegAndLang = allowedRegions.contains(currentRegion) && allowedLanguages.contains(currentLanguage)
        self.blockedByRegion = !isAllowRegAndLang
        print("[RegionService] isAllowRegAndLang - \(isAllowRegAndLang)")
        LocationService.shared.fetchLocation { location in
            print("[RegionService] location - \(location)")
            guard let location = location else {
                completion?(self.isBlocked)
                return
            }
            GeocoderService.determineCountry(by: location) { country in
                print("[RegionService] country - \(country)")
                guard let country = country else {
                    completion?(self.isBlocked)
                    return
                }
                let isAllowedCountry = self.allowedRegions.contains(country)
                print("[RegionService] isAllowedCountry - \(isAllowedCountry)")
                self.blockedByLocation = !isAllowedCountry
                print("[RegionService] isBlocked - \(self.isBlocked)")
                completion?(self.isBlocked)
            }
        }
    }
}
