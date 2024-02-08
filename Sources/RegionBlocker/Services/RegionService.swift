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
    
    public var checkMethods: [RegionBlockerMethod] = RegionBlockerMethod.allCases {
        didSet {
            if checkMethods.isEmpty {
                checkMethods = RegionBlockerMethod.allCases
            }
        }
    }
    public var allowedRegions = ["RU", "BY"]
    public var allowedLanguages = ["ru", "be"]
    
    public var blockedByCustomFlag = false
    
    public var isAllowed: Bool = false
    
    private init() {}
    
    public func checkRegion(completion: ((Bool) -> Void)?) {
        let group = DispatchGroup()
        
        var allowedByRegion = false
        var allowedByLang = false
        var allowedByLocation: Bool?
        var allowedByIp: Bool?
        
        checkMethods.forEach { method in
            group.enter()
            switch method {
            case .byLanguage:
                checkIsAllowedLang { flag in
                    allowedByLang = flag
                    group.leave()
                }
            case .byRegion:
                checkIsAllowedRegion { flag in
                    allowedByRegion = flag
                    group.leave()
                }
            case .byLocation:
                checkIsAllowedLocation { flag in
                    allowedByLocation = flag
                    group.leave()
                }
            case .byIp:
                checkIsAllowedRegionInIp { flag in
                    allowedByIp = flag
                    group.leave()
                }
            }
        }
        
        group.notify(queue: .main) {
            print("allowedByRegion - \(allowedByRegion), allowedByLang - \(allowedByLang), allowedByLocation - \(allowedByLocation), allowedByIp \(allowedByIp)")
            var isAllowed: Bool {
                var flags: [Bool] = []
                if self.checkMethods.contains(.byRegion) {
                    flags += [allowedByRegion]
                }
                if self.checkMethods.contains(.byLanguage) {
                    flags += [allowedByLang]
                }
                if self.checkMethods.contains(.byLocation) {
                    flags += [allowedByLocation ?? false]
                }
                if self.checkMethods.contains(.byIp) {
                    flags += [allowedByIp ?? false]
                }
                print("flags - \(flags)")
                return flags.allSatisfy({ $0 })
            }
            self.isAllowed = isAllowed
            print("isAllowed - \(isAllowed)")
            
            completion?(isAllowed)
        }
    }
}

// MARK: - Module methods
private extension RegionService {
    
    func checkIsAllowedRegion(completion: ((Bool) -> Void)?) {
        guard let currentRegion = Locale.current.regionCode else {
            completion?(false)
            return
        }
        completion?(allowedRegions.contains(currentRegion))
    }
    
    func checkIsAllowedLang(completion: ((Bool) -> Void)?) {
        guard let currentLanguage = Locale.current.languageCode else {
            completion?(false)
            return
        }
        completion?(allowedLanguages.contains(currentLanguage))
    }
    
    func checkIsAllowedLocation(completion: ((Bool) -> Void)?) {
        LocationService.shared.fetchLocation { location in
            guard let location = location else {
                completion?(false)
                return
            }
            GeocoderService.determineCountry(by: location) { country in
                guard let country = country else {
                    completion?(false)
                    return
                }
                let isAllowedCountry = self.allowedRegions.contains(country)
                completion?(isAllowedCountry)
            }
        }
    }
    
    func checkIsAllowedRegionInIp(completion: @escaping ((Bool) -> Void)) {
        RemoteService().fetchIpInfo { result in
            switch result {
            case .success(let infoModel):
                print("Country code: \(infoModel.countryCode)")
                completion(self.allowedRegions.contains(infoModel.countryCode))
            case .failure(let error):
                print("Error: \(error)")
                completion(false)
            }
        }
    }
}
