//
//  ImageCacheService.swift
//  market
//
//  Created by Evelina on 11.02.2025.
//

import Foundation
import UIKit

protocol ImageCacheServiceProtocol {
    func cacheImage(_ image: UIImage, forKey key: String)
    func image(forKey key: String) -> UIImage?
    func removeImage(forKey key: String)
}

final class ImageCacheService: ImageCacheServiceProtocol {
    
    private let cache: NSCache<NSString, UIImage> = NSCache<NSString, UIImage>()
    
    func cacheImage(_ image: UIImage, forKey key: String) {
        cache.setObject(image, forKey: key as NSString)
    }
    
    func image(forKey key: String) -> UIImage? {
        return cache.object(forKey: key as NSString)
    }
    
    func removeImage(forKey key: String) {
        cache.removeObject(forKey: key as NSString)
    }
}
