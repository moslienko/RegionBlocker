//
//  RemoteService.swift
//
//
//  Created by Pavel Moslienko on 08.02.2024.
//

import Foundation

class RemoteService {
    
    private let apiUrl = "http://ip-api.com/json/?fields=countryCode"
    
    func fetchIpInfo(completion: @escaping (Result<IpInfoResponse, Error>) -> Void) {
        guard let url = URL(string: apiUrl) else {
            completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Incorrect url"])))
            return
        }
        
        let session = URLSession.shared
        session.configuration.timeoutIntervalForRequest = 60

        let task = session.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed request answer"])))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let countryCodeResponse = try decoder.decode(IpInfoResponse.self, from: data)
                completion(.success(countryCodeResponse))
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
}
