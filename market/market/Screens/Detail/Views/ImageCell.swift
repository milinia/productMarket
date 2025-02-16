//
//  ImageCell.swift
//  market
//
//  Created by Evelina on 12.02.2025.
//

import Foundation
import UIKit

final class ImageCell: UICollectionViewCell {
    
    weak var delegate: LoadImageDelegate?
    var image: UIImage?
    
    private var downloadTask: Task<Void, Error>?
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
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
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        downloadTask?.cancel()
    }
    
    func configure(with imageURL: String) {
        downloadTask = Task {
            do {
                if let image = try await delegate?.loadImage(from: imageURL) {
                    updateImage(image: image)
                }
            } catch {
                imageView.image = UIImage(named: "noImage")
                activityIndicator.stopAnimating()
            }
        }
    }
    
    @MainActor
    private func updateImage(image: UIImage) {
        imageView.image = image
        self.image = image
        activityIndicator.stopAnimating()
    }
    
    private func setupView() {
        addSubview(imageView)
        imageView.addSubview(activityIndicator)
        
        imageView.frame = bounds
        activityIndicator.frame = CGRect(x: imageView.frame.width / 2 - 10,
                                         y: imageView.frame.height / 2 - 10,
                                         width: 20,
                                         height: 20)
    }
}
