//
//  CartProduct.swift
//  market
//
//  Created by Evelina on 10.02.2025.
//

import Foundation
import UniformTypeIdentifiers

class CartProduct: NSObject, NSItemProviderWriting, NSItemProviderReading, Codable {
    
    let product: Product
    var quantity: Int
    let image: Data?
    
    init(product: Product, quantity: Int, image: Data?) {
        self.product = product
        self.quantity = quantity
        self.image = image
    }
    
    init(quantity: Int) {
        self.product = Product(id: 0, title: "", price: 0, description: "",
                               category: Category(id: 0, name: ""), images: [])
        self.quantity = quantity
        self.image = nil
    }
    
    static var writableTypeIdentifiersForItemProvider: [String] {
        return [UTType.data.identifier]
    }

    func loadData(withTypeIdentifier typeIdentifier: String, forItemProviderCompletionHandler completionHandler: @escaping (Data?, Error?) -> Void) -> Progress? {
        do {
            let data = try JSONEncoder().encode(self)
            completionHandler(data, nil)
        } catch {
            completionHandler(nil, error)
        }
        return nil
    }
    
    static var readableTypeIdentifiersForItemProvider: [String] {
        return [UTType.data.identifier]
    }
    
    static func object(withItemProviderData data: Data, typeIdentifier: String) throws -> Self {
        return try JSONDecoder().decode(Self.self, from: data)
    }
}
