//
//  RegionService.swift
//
//
//  Created by Pavel Moslienko on 08.02.2024.
//

import Foundation
import CoreLocation

public protocol RegionServiceProtocol {
    var checkMethods: [RegionBlockerMethod] { get set }
    var allowedRegions: [String] { get set }
    var allowedLanguages: [String] { get set }
    var isAllowed: Bool { get set }
    
    func checkRegion(completion: ((Bool) -> Void)?)
    
    @available(iOS 13.0, *)
    func checkRegion(location: CLLocation?) async -> Bool
}

final public class RegionService: RegionServiceProtocol {
    
    static public let shared = RegionService()
    
    public var checkMethods: [RegionBlockerMethod] = RegionBlockerMethod.allCases {
        didSet {
            if checkMethods.isEmpty {
                checkMethods = RegionBlockerMethod.allCases
            }
        }
    }
    public var allowedRegions: [String] = []
    public var allowedLanguages: [String] = []
    public var isAllowed: Bool = false
    
    private init() {}
    
    /// Check the user's current region to set a availability status
    /// - Parameter completion: actual availability status
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
                allowedByLang = checkIsAllowedLang()
                group.leave()
            case .byRegion:
                allowedByRegion = checkIsAllowedRegion()
                group.leave()
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
            let isAllowed = self.calculateAllowFlag(
                allowedByRegion: allowedByRegion,
                allowedByLang: allowedByLang,
                allowedByLocation: allowedByLocation,
                allowedByIp: allowedByIp
            )
            self.isAllowed = isAllowed
            
            completion?(isAllowed)
        }
    }
    
    @available(iOS 13.0, *)
    public func checkRegion(location: CLLocation? = nil) async -> Bool {
        let allowedByRegion = self.checkMethods.contains(.byRegion) ? self.checkIsAllowedRegion() : false
        let allowedByLang = self.checkMethods.contains(.byLanguage) ? self.checkIsAllowedLang() : false
        let allowedByIp = self.checkMethods.contains(.byIp) ? await self.checkIsAllowedRegionInIp() : nil
        var allowedByLocation: Bool?
        
        if let location = location,
           self.checkMethods.contains(.byLocation) {
            allowedByLocation = await self.checkIsAllowedLocation(location)
        }
        
        
        let isAllowed = self.calculateAllowFlag(
            allowedByRegion: allowedByRegion,
            allowedByLang: allowedByLang,
            allowedByLocation: allowedByLocation,
            allowedByIp: allowedByIp
        )
        self.isAllowed = isAllowed
        
        return isAllowed
    }
}

// MARK: - Module methods
private extension RegionService {
    
    /// Calculate the availability status of the region using the result of the checks
    /// - Parameters:
    ///   - allowedByRegion: availability of the region by region (in settings)
    ///   - allowedByLang: availability of the region by language (in settings)
    ///   - allowedByLocation: availability of the region by location coordinated
    ///   - allowedByIp: availability of the region by IP country
    /// - Returns: allowed status
    func calculateAllowFlag(allowedByRegion: Bool, allowedByLang: Bool, allowedByLocation: Bool?, allowedByIp: Bool?) -> Bool {
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
            return flags.allSatisfy({ $0 })
        }
        
        return isAllowed
    }
    
    func checkIsAllowedRegion() -> Bool {
        guard let currentRegion = Locale.current.regionCode else {
            return false
        }
        return allowedRegions.contains(currentRegion)
    }
    
    func checkIsAllowedLang() -> Bool {
        guard let currentLanguage = Locale.current.languageCode else {
            return false
        }
        return allowedLanguages.contains(currentLanguage)
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
            case let .success(infoModel):
                completion(self.allowedRegions.contains(infoModel.countryCode))
            case .failure:
                completion(false)
            }
        }
    }
}

// MARK: - Async/await wrappers
private extension RegionService {
    
    @available(iOS 13.0, *)
    func checkIsAllowedRegionInIp() async -> Bool {
        await withCheckedContinuation { continuation in
            checkIsAllowedRegionInIp() { result in
                continuation.resume(returning: result)
            }
        }
    }
    
    @available(iOS 13.0, *)
    func checkIsAllowedLocation(_ location: CLLocation) async -> Bool {
        guard let country = await GeocoderService.determineCountry(by: location) else {
            return false
        }
        let isAllowedCountry = self.allowedRegions.contains(country)
        return isAllowedCountry
    }
}
