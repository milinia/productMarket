//
//  RequestsAPI.swift
//  market
//
//  Created by Evelina on 10.02.2025.
//

import Foundation

enum RequestsAPI {
    case searchProductsByOffsetAndTitle(offset: Int, filter: Filter)
    case getProductDetailsById(id: Int)
    case getAllCategories
    case getProducts(offset: Int)
    
    var baseURL: String {
        return "https://api.escuelajs.co/api/v1/"
    }
    
    var limit: Int {
        return 15
    }
    
    var endpoint: String {
        switch self {
        case .searchProductsByOffsetAndTitle, .getProductDetailsById:
            return "products/"
        case .getAllCategories:
            return "categories"
        case .getProducts:
            return "products"
        }
    }
    
    var url: URL? {
        switch self {
        case .searchProductsByOffsetAndTitle(offset: let offset, filter: let filter):
            var components = URLComponents(string: baseURL + endpoint)
            
            components?.queryItems = [
                URLQueryItem(name: "offset", value: String(offset)),
                URLQueryItem(name: "limit", value: String(limit)),
                URLQueryItem(name: "title", value: filter.title)
            ]
            
            if let category = filter.category, category.id != 0 {
                components?.queryItems?.append(URLQueryItem(name: "categoryId", value: String(category.id)))
            }
            if let price = filter.price, price != 0 {
                components?.queryItems?.append(URLQueryItem(name: "price", value: String(price)))
            }
            if let minPrice = filter.priceMin, minPrice != 0 {
                components?.queryItems?.append(URLQueryItem(name: "price_min", value: String(minPrice)))
            }
            if let maxPrice = filter.priceMax, maxPrice != 0 {
                components?.queryItems?.append(URLQueryItem(name: "price_max", value: String(maxPrice)))
            }
                        
            return components?.url
            
        case .getProductDetailsById(id: let id):
            return URL(string: "\(baseURL)\(endpoint)\(id)")
        
        case .getAllCategories:
            return URL(string: "\(baseURL)\(endpoint)")
        
        case .getProducts(offset: let offset):
            var components = URLComponents(string: baseURL + endpoint)
            
            components?.queryItems = [
                URLQueryItem(name: "offset", value: String(offset)),
                URLQueryItem(name: "limit", value: String(limit))
            ]

            return components?.url
        }
    }
}
