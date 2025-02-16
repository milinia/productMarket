//
//  CategoryService.swift
//  market
//
//  Created by Evelina on 16.02.2025.
//

import Foundation

protocol CategoryServiceProtocol {
    func fetchCategories() async throws -> [Category]
}

final class CategoryService: CategoryServiceProtocol {
    
    private let networkManager: NetworkManagerProtocol
    
    init(networkManager: NetworkManagerProtocol) {
        self.networkManager = networkManager
    }
    
    func fetchCategories() async throws -> [Category] {
        guard let url = RequestsAPI.getAllCategories.url else { throw AppError.invalidURL}
        
        let categoryData = try await networkManager.makeGetRequest(url)
        let categoryDecoded = try JSONDecoder().decode([Category].self, from: categoryData)
        return categoryDecoded
    }
}
