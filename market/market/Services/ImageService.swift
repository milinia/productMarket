//
//  ImageService.swift
//  market
//
//  Created by Evelina on 11.02.2025.
//

import Foundation
import UIKit

protocol ImageServiceProtocol {
    func fetchImage(stringURL: String) async throws -> UIImage
}

final class ImageService: ImageServiceProtocol {
    
    private let imageCacheService: ImageCacheServiceProtocol
    private let networkManager: NetworkManagerProtocol
    
    init(imageCacheService: ImageCacheServiceProtocol, networkManager: NetworkManagerProtocol) {
        self.imageCacheService = imageCacheService
        self.networkManager = networkManager
    }
    
    func fetchImage(stringURL: String) async throws -> UIImage {
        if let cachedImage = imageCacheService.image(forKey: stringURL) {
            return cachedImage
        } else {
            guard let url = URL(string: stringURL) else {
                throw AppError.invalidURL
            }
            let data = try await networkManager.makeGetRequest(url)
            let image = try convertDataToImage(data)
            imageCacheService.cacheImage(image, forKey: stringURL)
            return image
        }
    }
    
    private func convertDataToImage(_ data: Data) throws -> UIImage {
        guard let image = UIImage(data: data) else {
            throw AppError.decodingError
        }
        return image
    }
}
