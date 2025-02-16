//
//  Product.swift
//  market
//
//  Created by Evelina on 10.02.2025.
//

import Foundation

struct Product: Codable, Hashable {
    let id: Int
    let title: String
    let price: Double
    let description: String
    let category: Category
    let images: [String]
}
