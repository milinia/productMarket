//
//  CartManager.swift
//  market
//
//  Created by Evelina on 14.02.2025.
//

import Foundation

protocol CartManagerProtocol {
    func getProducts() -> [CartProduct]
    func addProduct(_ product: CartProduct)
    func removeProduct(_ product: CartProduct)
    func deleteAllProducts()
    func moveProduct(_ product: CartProduct, to index: Int)
    func updateProduct(_ product: CartProduct)
    func getProductQuantity(productId: Int) -> Int
}

final class CartManager: CartManagerProtocol {
    
    private let cartPersistenceManager: CartPersistenceManagerProtocol
    
    private var products: [CartProduct] = []
    
    init (cartPersistenceManager: CartPersistenceManagerProtocol) {
        self.cartPersistenceManager = cartPersistenceManager
        createCart()
        Task(priority: .userInitiated) {
            cartPersistenceManager.getCartProducts(completion: { [weak self] result in
                switch result {
                case .success(let persistedProducts):
                    self?.products = persistedProducts.map { product in
                        CartProduct(product: Product(id: Int(product.id),
                                                     title: product.title ?? "",
                                                     price: Double(product.price),
                                                     description: product.description,
                                                     category: Category(id: 0, name: ""),
                                                     images: []),
                                    quantity: Int(product.quantity),
                                    image: product.image)
                        
                    }
                case .failure(_): break
                }
            })
        }
    }
    
    private func createCart() {
        cartPersistenceManager.createCart()
    }
    
    func addProduct(_ product: CartProduct) {
        products.append(product)
        
        Task(priority: .background) {
            cartPersistenceManager.saveCartProduct(product: product)
        }
    }
    
    func getProductQuantity(productId: Int) -> Int {
        if let index = products.firstIndex(where: { $0.product.id == productId }) {
            return products[index].quantity
        }
        return 0
    }
    
    func removeProduct(_ product: CartProduct) {
        products.removeAll { $0.product.id == product.product.id }
        
        Task(priority: .background) {
            cartPersistenceManager.removeCartProduct(product: product)
        }
    }
    
    func deleteAllProducts() {
        if products.isEmpty { return }
        products.removeAll()
        
        Task(priority: .background) {
            cartPersistenceManager.clearCart()
        }
    }
    
    func updateProduct(_ product: CartProduct) {
        if let index = products.firstIndex(where: { $0.product.id == product.product.id }) {
            products[index].quantity = product.quantity
        }
        
        Task(priority: .background) {
            cartPersistenceManager.editCartProduct(product: product)
        }
    }
    
    func moveProduct(_ product: CartProduct, to index: Int) {
        if let currentIndex = products.firstIndex(where: { $0.product.id == product.product.id }){
            products.remove(at: currentIndex)
            products.insert(product, at: index)
        }
        
        Task(priority: .background) {
            cartPersistenceManager.moveProduct(product: product, to: index)
        }
    }
    
    func getProducts() -> [CartProduct] {
        return products
    }
}
