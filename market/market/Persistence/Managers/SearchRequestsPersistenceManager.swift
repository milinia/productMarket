//
//  SearchRequestsPersistenceManager.swift
//  market
//
//  Created by Evelina on 10.02.2025.
//

import Foundation
import CoreData
import UIKit

protocol SearchRequestsPersistenceManagerProtocol {
    func getSearchRequestHistory(completion: @escaping (Result<[CDFilter], Error>) -> Void)
    func saveSearchRequest(filter: Filter)
}

final class SearchRequestsPersistenceManager: BasePersistenceManager, SearchRequestsPersistenceManagerProtocol {
    
    func getSearchRequestHistory(completion: @escaping (Result<[CDFilter], Error>) -> Void) {
        guard let unwrappedContext = context else {
            completion(.failure(AppError.coreDataError))
            return
        }
        do {
            let requestResult = try unwrappedContext.fetch(CDFilter.fetchRequest())
            let sortedRequestResult = requestResult.sorted(by: {$0.date > $1.date})
            completion(.success(sortedRequestResult))
        } catch {
            completion(.failure(AppError.coreDataError))
        }
    }
    
    func saveSearchRequest(filter: Filter) {
        guard let unwrappedContext = context else {
            return
        }
        do {
            let request = CDFilter.fetchRequest()
            request.predicate = NSPredicate(format: "title == %@", filter.title)
            let requestResult = try unwrappedContext.fetch(request)
            if let searchRequest = requestResult.first {
                searchRequest.date = Date()
                searchRequest.priceMin = NSNumber(value: filter.priceMin ?? 0)
                searchRequest.priceMax = NSNumber(value: filter.priceMax ?? 0)
                searchRequest.categoryId = NSNumber(value: filter.category?.id ?? 0)
                searchRequest.price = NSNumber(value: filter.price ?? 0)
                try unwrappedContext.save()
            } else {
                let newRequest = CDFilter(context: unwrappedContext)
                newRequest.date = Date()
                newRequest.title = filter.title
                
                if let priceMin = filter.priceMin {
                    newRequest.priceMin = NSNumber(value: priceMin)
                }
                if let priceMax = filter.priceMax {
                    newRequest.priceMax = NSNumber(value: priceMax)
                }
                if let price = filter.price {
                    newRequest.price = NSNumber(value: price)
                }
                if let categoryId = filter.category?.id {
                    newRequest.categoryId = NSNumber(value: categoryId)
                }
                try unwrappedContext.save()
                    
                let fetchAllRequests = try unwrappedContext.fetch(CDFilter.fetchRequest())
                let sortedRequests = fetchAllRequests.sorted(by: { $0.date < $1.date })
                if sortedRequests.count > 5 {
                    let objectToDelete = sortedRequests.first
                    if let objectToDelete = objectToDelete {
                        unwrappedContext.delete(objectToDelete)
                        try unwrappedContext.save()
                    }
                }
            }
        } catch {
        }
    }
}
