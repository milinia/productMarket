//
//  Assembly.swift
//  market
//
//  Created by Evelina on 14.02.2025.
//

import Foundation

protocol AssemblyProtocol {
    var productService: ProductServiceProtocol { get }
    var networkManager: NetworkManagerProtocol { get }
    var imageCacheService: ImageCacheServiceProtocol { get }
    var imageService: ImageServiceProtocol { get }
    var cartPersistenceManager: CartPersistenceManagerProtocol { get }
    var searchRequestsPersistenceManager: SearchRequestsPersistenceManagerProtocol { get }
    var cartManager: CartManagerProtocol { get }
}

final class Assembly: AssemblyProtocol {
    lazy var networkManager: NetworkManagerProtocol = NetworkManager()
    lazy var productService: ProductServiceProtocol = ProductService(networkManager: networkManager)
    lazy var imageCacheService: ImageCacheServiceProtocol = ImageCacheService()
    lazy var imageService: ImageServiceProtocol = ImageService(imageCacheService: imageCacheService,
                                                               networkManager: networkManager)
    lazy var cartPersistenceManager: CartPersistenceManagerProtocol = CartPersistenceManager()
    lazy var searchRequestsPersistenceManager: SearchRequestsPersistenceManagerProtocol = SearchRequestsPersistenceManager()
    lazy var cartManager: CartManagerProtocol = CartManager(cartPersistenceManager: cartPersistenceManager)
}
