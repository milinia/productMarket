//
//  SearchViewController.swift
//  market
//
//  Created by Evelina on 10.02.2025.
//

import Foundation
import UIKit

protocol SearchViewInput: AnyObject {
    func showLoading()
    func showError()
    func showProducts(products: [Product])
    func showSearchHistory(requests: [Filter])
    func showViewController(_ viewController: UIViewController)
}

class SearchViewController: UIViewController {
    
    enum Constants {
        static let horizontalOffsets = 16.0
        static let verticalOffsets = 8.0
    }
    
    private let output: SearchViewOutput
    private var filter: Filter?
    
    private var isSearchMode: Bool = false
    
    init(output: SearchViewOutput) {
        self.output = output
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.delegate = self
        searchBar.searchTextField.placeholder = StringConstants.Search.search
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.layer.borderColor = UIColor.systemBackground.cgColor
        searchBar.layer.borderWidth = 1
        return searchBar
    }()
    
    private lazy var filterButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "line.3.horizontal.decrease.circle"), for: .normal)
        button.addTarget(self, action: #selector(filterButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .label
        return button
    }()

    @objc func filterButtonTapped() {
        output.viewDidTappedGoToFilter(with: filter)
    }
    
    private lazy var collectionViewLayout: UICollectionViewFlowLayout = {
        let collectionViewLayout = UICollectionViewFlowLayout()
        collectionViewLayout.minimumLineSpacing = 4
        collectionViewLayout.scrollDirection = .vertical
        return collectionViewLayout
    }()
    
    private lazy var collectionView: SearchResultCollectionView = {
        let collectionView = SearchResultCollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegateForCell = output
        collectionView.collectionViewDelegate = self
        return collectionView
    }()
    
    private lazy var errorView: ErrorView = {
        let errorView = ErrorView()
        errorView.translatesAutoresizingMaskIntoConstraints = false
        errorView.isHidden = true
        errorView.delegate = self
        return errorView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        output.viewDidLoad()
    }
    
    private func setupViews() {
        view.backgroundColor = .systemBackground
        setupNavigationBar()
        
        [searchBar, filterButton, collectionView, errorView].forEach({ view.addSubview($0) })
        
        NSLayoutConstraint.activate([
            filterButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.horizontalOffsets),
            filterButton.widthAnchor.constraint(equalToConstant: 40),
            filterButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            filterButton.heightAnchor.constraint(equalTo: searchBar.heightAnchor),
            
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.horizontalOffsets),
            searchBar.trailingAnchor.constraint(equalTo: filterButton.leadingAnchor, constant: -4),
            
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.horizontalOffsets),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.horizontalOffsets),
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: Constants.verticalOffsets),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Constants.verticalOffsets),
            
            errorView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.horizontalOffsets),
            errorView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.horizontalOffsets),
            errorView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: Constants.verticalOffsets),
            errorView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Constants.verticalOffsets),
        ])
    }
    
    private func setupNavigationBar() {
        navigationItem.backButtonTitle = ""
        navigationItem.title = StringConstants.Search.title
        
        let barButton = UIBarButtonItem(image: UIImage(systemName: "cart"),
                                        style: .plain, target: self,
                                        action: #selector(openCart))
        navigationItem.rightBarButtonItem = barButton
    }
    
    @objc private func openCart() {
        output.viewDidTappedGoToCart()
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let text = searchBar.text, !text.isEmpty {
            searchBar.resignFirstResponder()
            let request = Filter(uuid: UUID(), title: text,
                                 category: filter?.category,
                                 price: filter?.price,
                                 priceMin: filter?.priceMin,
                                 priceMax: filter?.priceMax)
            self.filter = request
            output.viewDidSearch(filter: request)
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        if !isSearchMode {
            isSearchMode = true
            output.fetchSearchHistory()
        }
    }
}

extension SearchViewController: SearchViewInput {
    
    func showLoading() {
        showCollectionView()
        collectionView.showLoadingCell()
    }
    
    private func showCollectionView() {
        errorView.isHidden = true
        collectionView.isHidden = false
    }
        
    func showError() {
        errorView.isHidden = false
        collectionView.isHidden = true
    }
        
    func showProducts(products: [Product]) {
        showCollectionView()
        if products.isEmpty && collectionView.status != .product {
            collectionView.showNothingFoundCell()
        } else {
            collectionView.showSearchResults(products: products)
        }
    }
    
    func showSearchHistory(requests: [Filter]) {
        showCollectionView()
        collectionView.showRequestsHistory(requestsHistory: requests)
    }
    
    func showViewController(_ viewController: UIViewController) {
        if let viewController = viewController as? FilterViewController {
            
            viewController.delegate = self
            
            if let sheet = viewController.sheetPresentationController {
                sheet.detents = [.custom(resolver: { context in
                    return viewController.preferredContentSize.height
                })]
            }
            present(viewController, animated: true)
        }
    }
}

extension SearchViewController: SearchResultCollectionViewDelegate {
    func didScrolled() {
        if let filter = filter {
            output.saveSearchRequest(filter: filter)
        }
    }
    
    func didSelectProduct(_ product: Product) {
        output.viewDidTapOnProductCell(product: product)
    }
    
    func didSelectSearchHistory(_ filter: Filter) {
        searchBar.text = filter.title
        output.viewDidSearch(filter: filter)
    }
    
    func didScrolledToBottom() {
        if let filter = filter {
            output.viewDidSearch(filter: filter)
        } else if !isSearchMode {
            output.viewDidScrolledToBottom()
        }
    }
}

extension SearchViewController: FilterViewControllerDelegate {
    func didDismissWithData(_ filter: Filter) {
        self.filter = filter
        
        output.viewDidSearch(filter: filter)
    }
}

extension SearchViewController: ErrorViewDelegate {
    func errorViewDidTapTryAgain() {
        if let filter = filter {
            output.viewDidSearch(filter: filter)
        } else {
            output.viewDidLoad()
        }
    }
}
