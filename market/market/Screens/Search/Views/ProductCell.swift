//
//  ProductCell.swift
//  market
//
//  Created by Evelina on 10.02.2025.
//

import Foundation
import UIKit

protocol LoadImageDelegate: AnyObject {
    func loadImage(from url: String) async throws -> UIImage
}

class ProductCell: UICollectionViewCell {
    
    enum Constants {
        static let horizontalOffset = 16.0
        static let verticalOffset = 8.0
        static let spacing = 8.0
    }
    
    weak var delegate: LoadImageDelegate?
    
    private var downloadTask: Task<Void, Error>?
    
    private var productImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 6
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private var productNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .label
        label.numberOfLines = 2
        return label
    }()
    
    private var productPriceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .bold)
        label.textColor = .label
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        return activityIndicator
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        downloadTask?.cancel()
        productImageView.image = nil
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        [productImageView, productNameLabel, productPriceLabel, activityIndicator].forEach({ addSubview($0) })
    
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupLayoutAndGetHeight()
    }

    func setupLayoutAndGetHeight() {
        let availableWidth: CGFloat = bounds.width
        let imageViewHeight = bounds.height * 0.7
        productImageView.frame = CGRect(x: 0,
                                        y: 0,
                                        width: availableWidth,
                                        height: imageViewHeight)
        
        activityIndicator.frame = CGRect(x: (productImageView.bounds.width - activityIndicator.bounds.width) / 2,
                                         y: (productImageView.bounds.height - activityIndicator.bounds.height) / 2,
                                         width: activityIndicator.bounds.width,
                                         height: activityIndicator.bounds.height)
        
        let productNameLabelHeight: CGFloat = productNameLabel.sizeThatFits(CGSize(width: availableWidth,
                                                                                   height: .greatestFiniteMagnitude)).height
        productNameLabel.frame = CGRect(x: 0,
                                        y: productImageView.frame.maxY + Double(Constants.verticalOffset),
                                        width: availableWidth,
                                        height: productNameLabelHeight)
        
        let productPriceLabelHeight: CGFloat = productPriceLabel.sizeThatFits(CGSize(width: availableWidth,
                                                                                   height: .greatestFiniteMagnitude)).height
        productPriceLabel.frame = CGRect(x: 0,
                                         y: productNameLabel.frame.maxY + Double(Constants.verticalOffset),
                                         width: availableWidth,
                                         height: productPriceLabelHeight)
    }
    
    private func formattedPrice(_ price: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: price)) ?? "$\(price)"
    }
    
    @MainActor
    private func updateImage(image: UIImage) {
        productImageView.image = image
        activityIndicator.stopAnimating()
    }
    
    func configure(with product: Product) {
        productNameLabel.text = product.title
        productPriceLabel.text = formattedPrice(product.price)
        if let firstImageUrl = product.images.first {
            downloadTask = Task {
                do {
                    if let image = try await delegate?.loadImage(from: firstImageUrl) {
                        updateImage(image: image)
                    }
                } catch {
                    productImageView.image = UIImage(named: "noImage")
                    activityIndicator.stopAnimating()
                }
            }
        }
    }
}
