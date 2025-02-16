//
//  ProductImageViewController.swift
//  market
//
//  Created by Evelina on 11.02.2025.
//

import Foundation
import UIKit

final class ProductImageViewController: UIViewController {
    
    private var output: LoadImageDelegate
    private var images: [UIImage] = []
    private let imagesURLs: [String]
    
    private lazy var collectionViewLayout: UICollectionViewFlowLayout = {
        let collectionViewLayout = UICollectionViewFlowLayout()
        collectionViewLayout.minimumLineSpacing = 0
        collectionViewLayout.scrollDirection = .horizontal
        collectionViewLayout.itemSize = CGSize(width: view.frame.width, height: view.frame.height)
        return collectionViewLayout
    }()
    
    private lazy var collectionView: CarouselImageCollectionView = {
        let collectionView = CarouselImageCollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.delegateForCell = output
        collectionView.delegateForView = self
        return collectionView
    }()
    
    init(imagesURLs: [String], output: LoadImageDelegate) {
        self.imagesURLs = imagesURLs
        self.output = output
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        collectionView.setImageUrls(imagesURLs)
        updateNavigationBarTitle(with: 1)
    }
    
    private func setupView() {
        view.addSubview(collectionView)
        
        collectionView.frame = view.bounds
    }
    
    private func updateNavigationBarTitle(with index: Int) {
        navigationItem.title = "\(index) \(StringConstants.Detail.of) \(imagesURLs.count)"
    }
}

extension ProductImageViewController: CarouselImageCollectionViewDelegate {
    func didScrollImage(imageIndexShown: Int) {
        updateNavigationBarTitle(with: imageIndexShown)
    }
}
