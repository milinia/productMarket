//
//  CartPersistenceManager.swift
//  market
//
//  Created by Evelina on 11.02.2025.
//

import Foundation
import CoreData
import UIKit

protocol CartPersistenceManagerProtocol {
    func getCartProducts(completion: @escaping (Result<[CDProduct], Error>) -> Void)
    func saveCartProduct(product: CartProduct)
    func removeCartProduct(product: CartProduct)
    func editCartProduct(product: CartProduct)
    func clearCart()
    func moveProduct(product: CartProduct, to index: Int)
    func createCart()
}

final class CartPersistenceManager: BasePersistenceManager, CartPersistenceManagerProtocol {
    
    func getCartProducts(completion: @escaping (Result<[CDProduct], Error>) -> Void) {
        guard let unwrappedContext = context else {
            completion(.failure(AppError.coreDataError))
            return
        }
        do {
            let requestResult = try unwrappedContext.fetch(Cart.fetchRequest())
            let products: [CDProduct] = requestResult[0].product?.array as? [CDProduct] ?? []
            completion(.success(products))
        } catch {
            completion(.failure(AppError.coreDataError))
        }
    }
    
    func saveCartProduct(product: CartProduct) {
        guard let unwrappedContext = context else { return }
        do {
            let cart = try unwrappedContext.fetch(Cart.fetchRequest())[0]
            
            let newRequest = CDProduct(context: unwrappedContext)
            newRequest.id = Int32(product.product.id)
            newRequest.title = product.product.title
            newRequest.price = product.product.price
            newRequest.quantity = Int16(product.quantity)
            newRequest.image = product.image
            
            cart.addToProduct(newRequest)
            
            try unwrappedContext.save()
        } catch {
            
        }
    }
    
    func removeCartProduct(product: CartProduct) {
        guard let unwrappedContext = context else { return }
        let request = CDProduct.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", product.product.id)
        do {
            guard let productToDelete = try unwrappedContext.fetch(request).first else { return }
            let cart = try unwrappedContext.fetch(Cart.fetchRequest())[0]
            
            cart.removeFromProduct(productToDelete)
            unwrappedContext.delete(productToDelete)
            
            try unwrappedContext.save()
        } catch {
            
        }
    }
    
    func editCartProduct(product: CartProduct) {
        guard let unwrappedContext = context else { return }
        let request = CDProduct.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", product.product.id)
        do {
            guard let productToEdit = try unwrappedContext.fetch(request).first else { return }
            productToEdit.quantity = Int16(product.quantity)
            
            try unwrappedContext.save()
        } catch {
            
        }
    }
    
    func moveProduct(product: CartProduct, to index: Int) {
        guard let unwrappedContext = context else { return }
        let request = CDProduct.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", product.product.id)
        
        do {
            guard let productToMove = try unwrappedContext.fetch(request).first else { return }
           
            guard let cart = try unwrappedContext.fetch(Cart.fetchRequest()).first,
                  let products = cart.product?.mutableCopy() as? NSMutableOrderedSet else { return }
            
            let currentIndex = products.index(of: productToMove)
            guard currentIndex != NSNotFound else { return }

            products.removeObject(at: currentIndex)
                    
            let clampedIndex = max(0, min(index, products.count))
            products.insert(productToMove, at: clampedIndex)

            cart.product = products

            try unwrappedContext.save()
        } catch {
            
        }
    }
    
    func clearCart() {
        guard let unwrappedContext = context else { return }
        do {
            let cart = try unwrappedContext.fetch(Cart.fetchRequest())[0]
            
            if let products = cart.product?.array as? [CDProduct] {
                for product in products {
                    cart.removeFromProduct(product)
                }
                
                try unwrappedContext.save()
            }
            
            clearCartProducts()
            
        } catch {
            
        }
    }
    
    private func clearCartProducts() {
        guard let unwrappedContext = context else { return }
        do {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: CDProduct.self))
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            try unwrappedContext.execute(deleteRequest)
            try unwrappedContext.save()
        } catch {
           
        }
    }
    
    func createCart() {
        guard let unwrappedContext = context else { return }
        do {
            let carts = try unwrappedContext.fetch(Cart.fetchRequest())
            if carts.isEmpty {
                _ = Cart(context: unwrappedContext)
                try unwrappedContext.save()
            }
        } catch {
            
        }
    }
}
