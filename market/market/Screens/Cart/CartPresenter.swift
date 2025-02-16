//
//  CartPresenter.swift
//  market
//
//  Created by Evelina on 14.02.2025.
//

import Foundation
import UIKit

protocol CartViewOutput: CartProductCellDelegate {
    func viewDidLoad()
    func deleteAllProducts()
    func moveProduct(_ product: CartProduct, _ toIndex: Int)
    func viewDidTappedOnProduct(product: CartProduct, quantity: Int)
    func didTapShareButton() -> String
}

final class CartPresenter: CartViewOutput {
    
    private let imageService: ImageServiceProtocol
    private let cartManager: CartManagerProtocol
    
    weak var view: CartViewInput?
    var didTapToOpenDetail: ((Product?, Int, Int) -> Void)?
    
    init(imageService: ImageServiceProtocol, cartManager: CartManagerProtocol) {
        self.imageService = imageService
        self.cartManager = cartManager
    }
    
    func viewDidLoad() {
        view?.showLoading()
        let products = cartManager.getProducts()
        if products.count > 0 {
            view?.showProducts(products: products)
        } else {
            view?.showEmptyCart()
        }
    }
    
    func viewDidTappedOnProduct(product: CartProduct, quantity: Int) {
        didTapToOpenDetail?(nil, product.product.id, quantity)
    }
    
    func deleteAllProducts() {
        cartManager.deleteAllProducts()
        view?.deleteAllProducts()
    }
    
    func moveProduct(_ product: CartProduct, _ toIndex: Int) {
        cartManager.moveProduct(product, to: toIndex)
    }
    
    func loadImage(from url: String) async throws -> UIImage {
        return try await imageService.fetchImage(stringURL: url)
    }
    
    func didTapDeleteButton(for product: CartProduct) {
        cartManager.removeProduct(product)
        view?.deleteProduct(product: product)
    }
    
    func didTapQuantityButton(for product: CartProduct, newQuantity: Int) {
        let newProduct = CartProduct(product: product.product, quantity: newQuantity, image: product.image)
        cartManager.updateProduct(newProduct)
    }
    
    func didTapShareButton() -> String {
        var result: String = "Shopping Cart:\n"
        for product in cartManager.getProducts() {
            result += "\(product.product.title) \(product.product.price)$ - \(product.quantity)x \n"
        }
        return result
    }
}
