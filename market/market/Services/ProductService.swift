//
//  ProductService.swift
//  market
//
//  Created by Evelina on 11.02.2025.
//

import Foundation

protocol ProductServiceProtocol {
    func fetchProducts(with filter: Filter?, offset: Int) async throws -> [Product]
    func fetchProduct(with id: Int) async throws -> Product
}

final class ProductService: ProductServiceProtocol {
    
    private let networkManager: NetworkManagerProtocol
    
    init(networkManager: NetworkManagerProtocol) {
        self.networkManager = networkManager
    }
    
    func fetchProducts(with filter: Filter?, offset: Int) async throws -> [Product] {
        if let filter = filter {
            return try await fetchProducts(with: RequestsAPI.searchProductsByOffsetAndTitle(offset: offset,
                                                                                            filter: filter).url,
                                           offset: offset)
        } else {
            return try await fetchProducts(with: RequestsAPI.getProducts(offset: offset).url,
                                           offset: offset)
        }
    }
    
    private func fetchProducts(with url: URL?, offset: Int) async throws -> [Product] {
        guard let url = url else { throw AppError.invalidURL}
        
        let productsData = try await networkManager.makeGetRequest(url)
        let productsDecoded = try JSONDecoder().decode([Product].self, from: productsData)
        return productsDecoded
    }
    
    func fetchProduct(with id: Int) async throws -> Product {
        guard let url = RequestsAPI.getProductDetailsById(id: id).url
        else { throw AppError.invalidURL}
        
        let productData = try await networkManager.makeGetRequest(url)
        let productDecoded = try JSONDecoder().decode(Product.self, from: productData)
        return productDecoded
    }
}
