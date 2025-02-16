//
//  SearchPresenter.swift
//  market
//
//  Created by Evelina on 10.02.2025.
//

import Foundation
import UIKit

protocol SearchViewOutput: AnyObject, LoadImageDelegate {
    func viewDidSearch(filter: Filter)
    func viewDidLoad()
    func saveSearchRequest(filter: Filter)
    func viewDidTappedGoToCart()
    func viewDidTappedGoToFilter(with filter: Filter?)
    func viewDidTapOnProductCell(product: Product)
    func fetchSearchHistory()
    func viewDidScrolledToBottom()
}

class SearchPresenter: SearchViewOutput {
    
    private let imageService: ImageServiceProtocol
    private let productService: ProductServiceProtocol
    private let searchResultsPersistenceManager: SearchRequestsPersistenceManagerProtocol
    
    private var offset: Int = 0
    private var filter: Filter?
    
    weak var view: SearchViewInput?
    var didTapToOpenDetail: ((Product, Int, Int) -> Void)?
    var didTapToOpenCart: (() -> Void)?
    var didTapToOpenFilter: ((Filter?) -> UIViewController)?
    
    init(imageService: ImageServiceProtocol,
         productService: ProductServiceProtocol,
         searchResultsPersistenceManager: SearchRequestsPersistenceManagerProtocol) {
        self.imageService = imageService
        self.productService = productService
        self.searchResultsPersistenceManager = searchResultsPersistenceManager
    }
    
    func viewDidSearch(filter: Filter) {
        if filter != self.filter { offset = 0 }
        Task {
            if offset == 0 {
                await viewShouldShowLoading()
            }
            do {
                let products = try await productService.fetchProducts(with: filter, offset: offset)
                offset += products.count + 1
                self.filter = filter
                await viewShouldShowProducts(products: products)
            } catch {
                await viewShouldShowError()
            }
        }
    }
    
    func viewDidScrolledToBottom() {
        Task {
            if offset == 0 {
                await viewShouldShowLoading()
            }
            do {
                let products = try await productService.fetchProducts(with: nil, offset: offset)
                offset += products.count + 1
                await viewShouldShowProducts(products: products)
            } catch {
                await viewShouldShowError()
            }
        }
    }
    
    func saveSearchRequest(filter: Filter) {
        Task {
            searchResultsPersistenceManager.saveSearchRequest(filter: filter)
        }
    }
    
    func viewDidLoad() {
        viewDidScrolledToBottom()
    }
    
    func fetchSearchHistory() {
        view?.showLoading()
        searchResultsPersistenceManager.getSearchRequestHistory { [weak self] result in
            switch result {
            case .failure(_):
                break
            case .success(let savedRequests):
                let requests: [Filter] = savedRequests.map { cdFilter in
                    Filter(uuid: UUID(), title: cdFilter.title,
                           category: cdFilter.categoryId == nil ? nil : Category(id: cdFilter.categoryId?.intValue ?? 0, name: ""),
                           price: cdFilter.price.map { $0.intValue },
                           priceMin: cdFilter.priceMin.map({ $0.intValue }),
                           priceMax: cdFilter.priceMax.map({ $0.intValue }))
                }
                if !requests.isEmpty {
                    Task {
                        await self?.viewShouldShowSearchHistory(requests: requests)
                    }
                }
            }
        }
    }
    
    func viewDidTapOnProductCell(product: Product) {
        didTapToOpenDetail?(product, product.id, 0)
    }
    
    func viewDidTappedGoToCart() {
        didTapToOpenCart?()
    }
    
    func viewDidTappedGoToFilter(with filter: Filter?) {
        if let filterView = didTapToOpenFilter?(filter) {
            view?.showViewController(filterView)
        }
    }
    
    @MainActor
    private func viewShouldShowError() {
        view?.showError()
    }
    
    @MainActor
    private func viewShouldShowLoading() {
        view?.showLoading()
    }
    
    @MainActor
    private func viewShouldShowProducts(products: [Product]) {
        view?.showProducts(products: products)
    }
    
    @MainActor
    private func viewShouldShowSearchHistory(requests: [Filter]) {
        view?.showSearchHistory(requests: requests)
    }
}

extension SearchPresenter: LoadImageDelegate {
    func loadImage(from url: String) async throws -> UIImage {
        return try await imageService.fetchImage(stringURL: url)
    }
}
