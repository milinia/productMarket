//
//  SearchResultItem.swift
//  market
//
//  Created by Evelina on 16.02.2025.
//

import Foundation

enum SearchResultItem: Hashable {
    case product(Product)
    case empty
    case loading
    case history(Filter)
    
    func hash(into hasher: inout Hasher) {
        switch self {
            case .history(let filter):
                hasher.combine(filter.uuid)
            case .product(let product):
                hasher.combine(product.id)
            case .empty:
                hasher.combine("empty")
            case .loading:
                hasher.combine("loading")
        }
    }
    
    static func == (lhs: SearchResultItem, rhs: SearchResultItem) -> Bool {
        switch (lhs, rhs) {
            case (.history(let lhsFilter), .history(let rhsFilter)):
                return lhsFilter.uuid == rhsFilter.uuid
            case (.product(let lhsProduct), .product(let rhsProduct)):
                return lhsProduct.id == rhsProduct.id
            case (.empty, .empty), (.loading, .loading):
                return true
            default:
                return false
        }
    }
}
