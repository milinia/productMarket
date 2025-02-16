//
//  CartCollectionView.swift
//  market
//
//  Created by Evelina on 14.02.2025.
//

import Foundation
import UIKit

protocol CartCollectionViewDelegate: AnyObject {
    func didTapCartProductCell(product: CartProduct, quantity: Int)
    func didMoveProduct(_ product: CartProduct, _ toIndex: Int)
}

final class CartCollectionView: UICollectionView {
    
    private enum Section {
        case main
    }
    
    private enum CollectionViewStatus {
        case empty
        case loading
        case cart
    }
    
    private let emptyCell = LabelCell()
    private let loadingCell = LoadingCell()
    private let productCell = CartProductCell()
    
    private var status: CollectionViewStatus = .empty
    private var cartProducts: [CartProduct] = []
    
    private var snapshot = NSDiffableDataSourceSnapshot<Section, CartProduct>()
    private var collectionDataSource: UICollectionViewDiffableDataSource<Section, CartProduct>!
    
    var delegateForCell: CartProductCellDelegate?
    var delegateForCollectionView: CartCollectionViewDelegate?
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        
        setupView()
        setupCollectionViewDataSource()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCollectionViewDataSource() {
        collectionDataSource = UICollectionViewDiffableDataSource<Section, CartProduct>(collectionView: self) { collectionView, indexPath, product in
            switch self.status {
                
                case .empty:
                    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: LabelCell.self) ,
                                                                        for: indexPath) as? LabelCell
                    else { return UICollectionViewCell() }
                
                    cell.configure(with: StringConstants.Cart.emptyCart)
                    return cell
                
                case .loading:
                    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: LoadingCell.self) ,
                                                                        for: indexPath) as? LoadingCell
                    else { return UICollectionViewCell() }
                    return cell
                
                case .cart:
                    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: CartProductCell.self) ,
                                                                    for: indexPath) as? CartProductCell
                    else { return UICollectionViewCell() }
                
                    cell.configure(with: product)
                    cell.delegate = self.delegateForCell
                
                    return cell
                }
            }
        
        snapshot.appendSections([.main])
        collectionDataSource.apply(snapshot, animatingDifferences: false)
    }
    
    private func updateSnapshot() {
        snapshot = NSDiffableDataSourceSnapshot<Section, CartProduct>()
        snapshot.appendSections([.main])
            
        switch status {
            case .empty:
                snapshot.appendItems([CartProduct(quantity: -1)])
                
            case .loading:
                snapshot.appendItems([CartProduct(quantity: -2)])
                
            case .cart:
                snapshot.appendItems(cartProducts)
            }
            
        collectionDataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func setupView() {
        delegate = self
        showsVerticalScrollIndicator = false
        dragDelegate = self
        dropDelegate = self
        
        register(LabelCell.self, forCellWithReuseIdentifier: String(describing: LabelCell.self))
        register(CartProductCell.self, forCellWithReuseIdentifier: String(describing: CartProductCell.self))
        register(LoadingCell.self, forCellWithReuseIdentifier: String(describing: LoadingCell.self))
    }
    
    func showLoadingCell() {
        status = .loading
        updateSnapshot()
    }
    
    func showEmptyCell() {
        status = .empty
        updateSnapshot()
    }
    
    func showCartProducts(products: [CartProduct]) {
        status = .cart
        self.cartProducts = products
        updateSnapshot()
    }
    
    func deleteProduct(with product: CartProduct) {
        cartProducts.removeAll(where: { $0.product.id == product.product.id })
        if !cartProducts.isEmpty {
            snapshot.deleteItems([product])
            collectionDataSource.apply(snapshot, animatingDifferences: true)
        } else {
            showEmptyCell()
        }
    }
    
    func moveProduct(movedProduct: CartProduct, toMoveProduct: CartProduct) {
        guard let currentIndex = cartProducts.firstIndex(of: movedProduct),
              let index = cartProducts.firstIndex(of: toMoveProduct) else { return }
        
        cartProducts.remove(at: currentIndex)
        cartProducts.insert(movedProduct, at: index)
        
        delegateForCollectionView?.didMoveProduct(movedProduct, index)
        
        var newSnapshot = snapshot
        newSnapshot.deleteItems([movedProduct])
        if currentIndex > index {
            newSnapshot.insertItems([movedProduct], beforeItem: toMoveProduct)
        } else {
            newSnapshot.insertItems([movedProduct], afterItem: toMoveProduct)
        }
        snapshot = newSnapshot

        collectionDataSource.apply(newSnapshot, animatingDifferences: true)
    }
    
    func deleteAllProducts() {
        cartProducts.removeAll()
        showEmptyCell()
    }
}

extension CartCollectionView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch status {
        case .empty, .loading: break
            
        case .cart:
            if let product = collectionDataSource.itemIdentifier(for: indexPath) {
                if let cell = collectionView.cellForItem(at: indexPath) as? CartProductCell {
                    delegateForCollectionView?.didTapCartProductCell(product: product, quantity: cell.quantity)
                }
            }
        }
    }
}

extension CartCollectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth: CGFloat = bounds.width
        var cellHeight: CGFloat = 0
        switch status {
        case .empty, .loading:
            cellHeight = 50
            
        case .cart:
            cellHeight = 150
        }
        
        return CGSize(width: cellWidth, height: cellHeight)
    }
}

extension CartCollectionView: UICollectionViewDragDelegate {
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: any UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        if status == .cart {
            if let product = collectionDataSource.itemIdentifier(for: indexPath) {
                let itemProvider = NSItemProvider(object: product)
                let dragItem = UIDragItem(itemProvider: itemProvider)
                dragItem.localObject = product
                return [dragItem]
            }
        }
        return []
    }
}

extension CartCollectionView: UICollectionViewDropDelegate {
    
    func collectionView(_ collectionView: UICollectionView,
                        dropSessionDidUpdate session: UIDropSession,
                        withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
    }

    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: any UICollectionViewDropCoordinator) {
        if status == .cart {
            guard let destinationIndexPath = coordinator.destinationIndexPath else { return }
            for item in coordinator.items {
                if (item.sourceIndexPath) != nil {
                    if let product = item.dragItem.localObject as? CartProduct {
                        if let toMoveProduct = collectionDataSource.itemIdentifier(for: destinationIndexPath) {
                            moveProduct(movedProduct: product, toMoveProduct: toMoveProduct)
                        }
                    }
                }
                coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
            }
        }
    }
}

