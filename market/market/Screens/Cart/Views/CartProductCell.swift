//
//  CartProductCell.swift
//  market
//
//  Created by Evelina on 14.02.2025.
//

import Foundation
import UIKit

protocol CartProductCellDelegate: LoadImageDelegate {
    func didTapDeleteButton(for product: CartProduct)
    func didTapQuantityButton(for product: CartProduct, newQuantity: Int)
}

final class CartProductCell: UICollectionViewCell {
    
    enum Constants {
        static let horizontalOffset = 16.0
        static let verticalOffset = 8.0
        static let spacing = 8.0
        static let deleteButtonSize: CGFloat = 20.0
        static let productQuantityHeight: CGFloat = 50.0
        static let imageSize: CGFloat = UIScreen.main.bounds.width / 4
    }
    
    weak var delegate: CartProductCellDelegate?
    private var downloadTask: Task<Void, Error>?
    private var cartProduct: CartProduct?
    
    var quantity: Int {
        return productQuantityView.quantity
    }
    
    private lazy var productImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private var productNameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var productPriceLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 13, weight: .bold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var productQuantityView: ProductQuantityView = {
        let view = ProductQuantityView(quantity: 1)
        view.isZeroReachable = false
        return view
    }()
    
    private var deleteButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "trash"), for: .normal)
        button.tintColor = .label
        button.imageView?.contentMode = .scaleAspectFit
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    @objc private func deleteButtonTapped() {
        if let cartProduct = cartProduct {
            delegate?.didTapDeleteButton(for: cartProduct)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        downloadTask?.cancel()
        downloadTask = nil
        cartProduct = nil
        productImageView.image = nil
    }
    
    private func setupView() {
        productQuantityView.delegate = self
        
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        let vStackView = UIStackView(arrangedSubviews: [productPriceLabel, productNameLabel, productQuantityView])
        vStackView.axis = .vertical
        vStackView.spacing = Constants.spacing
        vStackView.distribution = .fill
        vStackView.translatesAutoresizingMaskIntoConstraints = false
        
        [productImageView, vStackView, deleteButton].forEach({ addSubview($0)})
        
        productQuantityView.setContentHuggingPriority(.required, for: .vertical)
        productQuantityView.setContentCompressionResistancePriority(.required, for: .vertical)
        
        productNameLabel.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        productPriceLabel.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        
        NSLayoutConstraint.activate([
            productImageView.topAnchor.constraint(equalTo: topAnchor, constant: Constants.verticalOffset),
            productImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.horizontalOffset),
            productImageView.widthAnchor.constraint(equalToConstant: Constants.imageSize),
            productImageView.heightAnchor.constraint(equalToConstant: Constants.imageSize),

            deleteButton.widthAnchor.constraint(equalToConstant: Constants.deleteButtonSize),
            deleteButton.heightAnchor.constraint(equalToConstant: Constants.deleteButtonSize),
            deleteButton.topAnchor.constraint(equalTo: productImageView.centerYAnchor, constant: -Constants.deleteButtonSize / 2),
            deleteButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.horizontalOffset),
                
            vStackView.leadingAnchor.constraint(equalTo: productImageView.trailingAnchor, constant: Constants.spacing),
            vStackView.trailingAnchor.constraint(equalTo: deleteButton.leadingAnchor, constant: -Constants.spacing),
            vStackView.topAnchor.constraint(equalTo: topAnchor, constant: Constants.verticalOffset),
            vStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Constants.verticalOffset),
//                
//            productQuantityView.widthAnchor.constraint(equalTo: vStackView.widthAnchor, multiplier: 0.5),
//            productQuantityView.heightAnchor.constraint(equalToConstant: Constants.productQuantityHeight)
        ])
        
    }
    
    @MainActor
    private func updateImage(image: UIImage) {
        productImageView.image = image
    }
    
    func configure(with product: CartProduct) {
        self.cartProduct = product
        productNameLabel.text = product.product.title
        productPriceLabel.text = "\(product.product.price) $"
        productQuantityView.quantity = product.quantity
        if let image = product.image {
            productImageView.image = UIImage(data: image)
        } else {
            if let firstImageUrl = product.product.images.first {
                downloadTask = Task {
                    do {
                        if let image = try await delegate?.loadImage(from: firstImageUrl) {
                            updateImage(image: image)
                        }
                    } catch {
                        productImageView.image = UIImage(named: "noImage")
                    }
                }
            }
        }
    }
}

extension CartProductCell: ProductQuantityViewDelegate {
    func quantityDidChange(_ newQuantity: Int) {
        if let cartProduct = cartProduct {
            delegate?.didTapQuantityButton(for: cartProduct, newQuantity: newQuantity)
        }
    }
    
    func quantityDidReachedZero() {}
}
