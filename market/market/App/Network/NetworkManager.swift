//
//  NetworkManager.swift
//  market
//
//  Created by Evelina on 10.02.2025.
//

import Foundation

protocol NetworkManagerProtocol {
    func makeGetRequest(_ url: URL?) async throws -> Data
}

final class NetworkManager: NetworkManagerProtocol {
    
    func makeGetRequest(_ url: URL?) async throws -> Data {
        guard let url = url else { throw AppError.invalidURL }
        let urlRequest = URLRequest(url: url)
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else { throw AppError.networkError}
        return data
    }
}
