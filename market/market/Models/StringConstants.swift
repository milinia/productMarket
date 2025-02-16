//
//  StringConstants.swift
//  market
//
//  Created by Evelina on 10.02.2025.
//

import Foundation

enum StringConstants {
    enum Search {
        static let nothingFound = "Nothing found"
        static let search = "Search"
        static let title = "Products"
    }
    
    enum Detail {
        static let of = "of"
        static let description = "Description"
        static let category = "Category:"
        static let addToCart = "Add to Cart"
        static let goToCart = "Go to Cart"
    }
    
    enum Cart {
        static let emptyCart = "No products yet"
        static let title = "Cart"
        static let deleteAll = "Delete all"
    }
    
    enum Filter {
        static let category = "Category"
        static let title = "Filter"
        static let price = "Price"
        static let priceRange = "Price range"
        static let from = "from"
        static let to = "to"
        static let apply = "Apply"
    }
}
