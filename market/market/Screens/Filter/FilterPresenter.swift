//
//  FilterPresenter.swift
//  market
//
//  Created by Evelina on 16.02.2025.
//

import Foundation

protocol FilterViewOutput: AnyObject {
    func getCategories()
}

final class FilterPresenter: FilterViewOutput {
    private let categoryService: CategoryServiceProtocol
    
    weak var view: FilterViewInput?
    
    init(categoryService: CategoryServiceProtocol) {
        self.categoryService = categoryService
    }
    
    func getCategories() {
        Task {
            do {
                let categories = try await self.categoryService.fetchCategories()
                await updateView(with: categories)
            } catch {
                
            }
        }
    }
    
    @MainActor
    private func updateView(with categories: [Category]) {
        view?.didReceiveCategories(categories)
    }
}
