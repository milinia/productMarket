//
//  CartViewController.swift
//  market
//
//  Created by Evelina on 14.02.2025.
//

import Foundation
import UIKit

protocol CartViewInput: AnyObject {
    func showLoading()
    func showEmptyCart()
    func showProducts(products: [CartProduct])
    func deleteProduct(product: CartProduct)
    func deleteAllProducts()
}

class CartViewController: UIViewController {
    
    enum Constants {
        static let horizontalOffsets = 16.0
        static let verticalOffsets = 8.0
    }
    
    var output: CartViewOutput
    
    init(output: CartViewOutput) {
        self.output = output
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var collectionViewLayout: UICollectionViewFlowLayout = {
        let collectionViewLayout = UICollectionViewFlowLayout()
        collectionViewLayout.minimumLineSpacing = 4
        collectionViewLayout.scrollDirection = .vertical
        return collectionViewLayout
    }()
    
    private lazy var collectionView: CartCollectionView = {
        let collectionView = CartCollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegateForCell = output
        collectionView.delegateForCollectionView = self
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        
        output.viewDidLoad()
    }
    
    private func setupView() {
        view.backgroundColor = .systemBackground
        setupNavigationBar()
        
        [collectionView].forEach({ view.addSubview($0) })
        
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.horizontalOffsets),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.horizontalOffsets),
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Constants.verticalOffsets)
        ])
    }
    
    private func setupNavigationBar() {
        navigationItem.title = StringConstants.Cart.title
        
        let shareButton = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up"),
                                        style: .plain, target: self,
                                        action: #selector(shareCart))
        
        let deleteButton = UIBarButtonItem(title: StringConstants.Cart.deleteAll,
                                           style: .plain, target: self,
                                           action: #selector(deleteCart))
        
        navigationItem.rightBarButtonItems = [shareButton, deleteButton]
    }
    
    @objc private func deleteCart() {
        output.deleteAllProducts()
    }
    
    @objc private func shareCart() {
        let items = [output.didTapShareButton()]
        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
        present(ac, animated: true)
    }
}

extension CartViewController: CartCollectionViewDelegate {
    func didMoveProduct(_ product: CartProduct, _ toIndex: Int) {
        output.moveProduct(product, toIndex)
    }
    
    func didTapCartProductCell(product: CartProduct, quantity: Int) {
        output.viewDidTappedOnProduct(product: product, quantity: quantity)
    }
}

extension CartViewController: CartViewInput {
    func showLoading() {
        collectionView.showLoadingCell()
    }
    
    func showEmptyCart() {
        collectionView.showEmptyCell()
    }
    
    func showProducts(products: [CartProduct]) {
        collectionView.showCartProducts(products: products)
    }
    
    func deleteProduct(product: CartProduct) {
        collectionView.deleteProduct(with: product)
    }
    
    func deleteAllProducts() {
        collectionView.deleteAllProducts()
    }
}
