//
//  DetailPresenter.swift
//  market
//
//  Created by Evelina on 13.02.2025.
//

import Foundation
import UIKit

protocol DetailViewOutput: LoadImageDelegate {
    func didTapShareButton(for product: Product) -> String
    func didAddToCart(product: Product, quantity: Int, image: UIImage?)
    func viewDidTappedGoToCart()
    func viewDidTappedOnImage(imageURLs: [String])
    func didDeleteFromCart(product: Product)
    func loadProduct(with productId: Int)
    func viewWillAppear(with productId: Int)
    func updateProduct(with quantity: Int)
}

final class DetailPresenter: DetailViewOutput {
    
    private let imageService: ImageServiceProtocol
    private let cartManager: CartManagerProtocol
    private let productService: ProductServiceProtocol
    
    private var cartProduct: CartProduct?
    
    weak var view: DetailViewInput?
    var didTapToOpenCart: (() -> Void)?
    var didTapToOpenImages: (([String], LoadImageDelegate) -> Void)?

    init(imageService: ImageServiceProtocol, cartManager: CartManagerProtocol, productService: ProductServiceProtocol) {
        self.imageService = imageService
        self.cartManager = cartManager
        self.productService = productService
    }
    
    func didTapShareButton(for product: Product) -> String {
        var textToShare = "\(product.title), \(product.price) $"
        textToShare += "\nCategory: \(product.category.name)"
        textToShare += "\n\n\(product.description)"
        
        return textToShare
    }
    
    func viewWillAppear(with productId: Int) {
        let quantityInCart = cartManager.getProductQuantity(productId: productId)
        view?.updateProductQuantity(quantity: quantityInCart)
    }
    
    
    func loadImage(from url: String) async throws -> UIImage {
        return try await imageService.fetchImage(stringURL: url)
    }
    
    func didAddToCart(product: Product, quantity: Int, image: UIImage?) {
        let cartProduct = CartProduct(product: product, quantity: quantity, image: image?.pngData())
        self.cartProduct = cartProduct
        cartManager.addProduct(cartProduct)
    }
    
    func didDeleteFromCart(product: Product) {
        cartManager.removeProduct(CartProduct(product: product, quantity: 0, image: nil))
    }
    
    func updateProduct(with quantity: Int) {
        guard let cartProduct = cartProduct else { return }
        cartProduct.quantity = quantity
        cartManager.updateProduct(cartProduct)
    }
    
    func loadProduct(with productId: Int) {
        Task {
            let product = try await productService.fetchProduct(with: productId)
            await updateView(product: product)
        }
    }
    
    func viewDidTappedGoToCart() {
        didTapToOpenCart?()
    }
    
    func viewDidTappedOnImage(imageURLs: [String]) {
        didTapToOpenImages?(imageURLs, self)
    }
    
    @MainActor
    private func updateView(product: Product) {
        view?.updateProduct(product: product)
    }
}
