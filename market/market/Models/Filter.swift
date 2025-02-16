//
//  Filter.swift
//  market
//
//  Created by Evelina on 10.02.2025.
//

import Foundation

struct Filter: Decodable, Hashable {
    let uuid: UUID
    let title: String
    let category: Category?
    let price: Int?
    let priceMin: Int?
    let priceMax: Int?
}
