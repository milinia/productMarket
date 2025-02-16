//
//  SearchResultCollectionView.swift
//  market
//
//  Created by Evelina on 10.02.2025.
//

import Foundation
import UIKit

protocol SearchResultCollectionViewDelegate: AnyObject {
    func didSelectProduct(_ product: Product)
    func didSelectSearchHistory(_ filter: Filter)
    func didScrolledToBottom()
    func didScrolled()
}

final class SearchResultCollectionView: UICollectionView {
    
    enum Section: Int, CaseIterable {
        case history
        case product
        case empty
        case loading
    }
    
    enum SearchResultCollectionViewStatus {
        case history
        case product
        case empty
        case loading
    }
    
    var status: SearchResultCollectionViewStatus = .empty
    
    private var didScroll = false
    
    private var products: [Product] = []
    private var searchesHistory: [Filter] = []
    
    private var snapshot = NSDiffableDataSourceSnapshot<Section, SearchResultItem>()
    private var collectionDataSource: UICollectionViewDiffableDataSource<Section, SearchResultItem>!
    
    weak var delegateForCell: LoadImageDelegate?
    weak var collectionViewDelegate: SearchResultCollectionViewDelegate?
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        
        setupView()
        setupCollectionViewDataSource()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCollectionViewDataSource() {
        collectionDataSource = UICollectionViewDiffableDataSource<Section, SearchResultItem>(collectionView: self) { collectionView, indexPath, item in
            switch item {
                
                case .empty:
                    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: LabelCell.self) ,
                                                                        for: indexPath) as? LabelCell
                    else { return UICollectionViewCell() }
                
                    cell.configure(with: StringConstants.Search.nothingFound)
                    return cell
                
                case .history(let filter):
                    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: SearchHistoryCell.self) ,
                                                                    for: indexPath) as? SearchHistoryCell
                    else { return UICollectionViewCell() }
                
                    cell.configure(with: filter, indexPath: indexPath)
                
                    return cell
                
                case .loading:
                    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: LoadingCell.self) ,
                                                                        for: indexPath) as? LoadingCell
                    else { return UICollectionViewCell() }
                    return cell
                
                case .product(let product):
                    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: ProductCell.self) ,
                                                                    for: indexPath) as? ProductCell
                    else { return UICollectionViewCell() }
                
                    cell.configure(with: product)
                    cell.delegate = self.delegateForCell
                
                    return cell
                }
            }
        collectionDataSource.apply(snapshot, animatingDifferences: false)
    }
    
    private func updateSnapshot(with status: SearchResultCollectionViewStatus) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, SearchResultItem>()
            
        switch status {
            case .empty:
                snapshot.appendSections([.empty])
                snapshot.appendItems([.empty], toSection: .empty)
                
            case .loading:
                snapshot.appendSections([.loading])
                snapshot.appendItems([.loading], toSection: .loading)
                
            case .history:
                let searchesHistory = searchesHistory.map { SearchResultItem.history($0) }
                snapshot.appendSections([.history])
                snapshot.appendItems(searchesHistory, toSection: .history)
                
            case .product:
                snapshot.appendSections([.product])
                let productItems = products.map { SearchResultItem.product($0) }
                snapshot.appendItems(productItems, toSection: .product)
            }
            
        collectionDataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func setupView() {
        delegate = self
        showsVerticalScrollIndicator = false
        
        register(LabelCell.self, forCellWithReuseIdentifier: String(describing: LabelCell.self))
        register(SearchHistoryCell.self, forCellWithReuseIdentifier: String(describing: SearchHistoryCell.self))
        register(ProductCell.self, forCellWithReuseIdentifier: String(describing: ProductCell.self))
        register(LoadingCell.self, forCellWithReuseIdentifier: String(describing: LoadingCell.self))
    }
    
    func showLoadingCell() {
        status = .loading
        updateSnapshot(with: .loading)
    }
    
    func showNothingFoundCell() {
        status = .empty
        updateSnapshot(with: .empty)
    }
    
    func showRequestsHistory(requestsHistory: [Filter]) {
        status = .history
        self.searchesHistory = requestsHistory
        updateSnapshot(with: .history)
    }
    
    func showSearchResults(products: [Product]) {
        if status != .product {
            status = .product
            self.products = products
            updateSnapshot(with: .product)
        } else {
            var snapshot = collectionDataSource.snapshot()
            
            products.forEach { product in
                self.products.append(product)
                snapshot.appendItems([SearchResultItem.product(product)])
            }
            collectionDataSource.apply(snapshot, animatingDifferences: true)
        }
    }
}

extension SearchResultCollectionView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == products.count - 1 && status == .product {
            collectionViewDelegate?.didScrolledToBottom()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch status {
        case .empty, .loading: break
        case .history:
            collectionViewDelegate?.didSelectSearchHistory(searchesHistory[indexPath.row])
        case .product:
            collectionViewDelegate?.didSelectProduct(products[indexPath.row])
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !didScroll && status == .product {
            didScroll = true
            collectionViewDelegate?.didScrolled()
        }
    }
}

extension SearchResultCollectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {        
        var cellWidth: CGFloat = bounds.width
        var cellHeight: CGFloat = 0
        switch status {
        case .empty, .loading:
            cellHeight = 50
            
        case .history:
            cellHeight = 50
            
        case .product:
            let spacing: CGFloat = (collectionViewLayout as? UICollectionViewFlowLayout)?.minimumInteritemSpacing ?? 10
            cellWidth = (bounds.width - spacing) / 2
            cellHeight = bounds.height / 2.5
        }
        
        return CGSize(width: cellWidth, height: cellHeight)
    }
}
