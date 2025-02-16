//
//  Coordinator.swift
//  market
//
//  Created by Evelina on 14.02.2025.
//

import Foundation
import UIKit

final class Coordinator {
    
    // MARK: - Private properties
    private let navigationController: UINavigationController
    private let assembly: AssemblyProtocol
        
    // MARK: - Init
    init(navigationController: UINavigationController, assembly: AssemblyProtocol) {
        self.navigationController = navigationController
        self.assembly = assembly
    }
    
    // MARK: - Public functions
    func start() {
        let presenter = SearchPresenter(imageService: assembly.imageService,
                                        productService: assembly.productService,
                                        searchResultsPersistenceManager: assembly.searchRequestsPersistenceManager)
        let view = SearchViewController(output: presenter)
        presenter.view = view
        presenter.didTapToOpenDetail = openDetail
        presenter.didTapToOpenCart = openCart
        navigationController.viewControllers = [view]
    }
    
    func openDetail(product: Product?, productId: Int, quantity: Int = 0) {
        let presenter = DetailPresenter(imageService: assembly.imageService,
                                        cartManager: assembly.cartManager,
                                        productService: assembly.productService)
        let view = DetailViewController(product: product,
                                        productId: productId,
                                        output: presenter,
                                        quantity: quantity)
        presenter.didTapToOpenCart = openCart
        presenter.didTapToOpenImages = openProductImages
        presenter.view = view
        navigationController.pushViewController(view, animated: true)
    }
    
    func openCart() {
        let presenter = CartPresenter(imageService: assembly.imageService, cartManager: assembly.cartManager)
        let view = CartViewController(output: presenter)
        presenter.didTapToOpenDetail = openDetail
        presenter.view = view
        navigationController.pushViewController(view, animated: true)
    }
    
    func openProductImages(imageURLs: [String], loader: LoadImageDelegate) {
        let view = ProductImageViewController(imagesURLs: imageURLs,
                                              output: loader)
        navigationController.pushViewController(view, animated: true)
    }
    
    func openFilter() {
        
    }
}
