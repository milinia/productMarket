//
//  CarouselImageCollectionView.swift
//  market
//
//  Created by Evelina on 12.02.2025.
//

import Foundation
import UIKit

protocol CarouselImageCollectionViewDelegate: AnyObject {
    func didSelectImage(url: String, image: UIImage?)
    func didScrollImage(imageIndexShown: Int)
}

extension CarouselImageCollectionViewDelegate {
    func didScrollImage(imageIndexShown: Int) {}
    func didSelectImage(url: String, image: UIImage?) {}
}

final class CarouselImageCollectionView: UICollectionView {
    
    private enum Section {
        case main
    }
    
    private var snapshot = NSDiffableDataSourceSnapshot<Section, Int>()
    private var collectionDataSource: UICollectionViewDiffableDataSource<Section, Int>!
    private var urls: [Int: String] = [:]
    
    private var currentImageIndexShown: Int = 0
    
    var currentImageShown: UIImage? {
        guard let cell = cellForItem(at: IndexPath(item: currentImageIndexShown, section: 0)) as? ImageCell
        else { return nil }
        
        return cell.image
    }
    weak var delegateForCell: LoadImageDelegate?
    weak var delegateForView: CarouselImageCollectionViewDelegate?
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        
        setupView()
        setupCollectionViewDataSource()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        delegate = self
        
        register(ImageCell.self, forCellWithReuseIdentifier: String(describing: ImageCell.self))
        
        isPagingEnabled = true
        showsHorizontalScrollIndicator = false
    }
    
    private func setupCollectionViewDataSource() {
        collectionDataSource = UICollectionViewDiffableDataSource<Section, Int>(collectionView: self) { collectionView, indexPath, id in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: ImageCell.self) ,
                                                                for: indexPath) as? ImageCell
            else { return UICollectionViewCell() }
            
            if let url = self.urls[id] {
                cell.configure(with: url)
                cell.delegate = self.delegateForCell
            }
            
            return cell
        }
        
        snapshot.appendSections([.main])
        collectionDataSource.apply(snapshot, animatingDifferences: false)
    }
    
    private func updateSnapshot(with indexes: [Int]) {
        snapshot = NSDiffableDataSourceSnapshot<Section, Int>()
        snapshot.appendSections([.main])
        snapshot.appendItems(indexes)
            
        collectionDataSource.apply(snapshot, animatingDifferences: true)
    }
    
    func setImageUrls(_ imageUrls: [String]) {
        for (index, url) in imageUrls.enumerated() {
            urls[index] = url
        }
        
        updateSnapshot(with: urls.keys.sorted())
    }
}

extension CarouselImageCollectionView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? ImageCell else { return }
        delegateForView?.didSelectImage(url: urls[indexPath.row] ?? "", image: cell.image)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.bounds.width != 0 {
            let index = Int(round(scrollView.contentOffset.x / scrollView.bounds.width))
            
            if scrollView.contentOffset.x.truncatingRemainder(dividingBy: scrollView.bounds.width) != 0 {
                delegateForView?.didScrollImage(imageIndexShown: currentImageIndexShown)
            } else {
                currentImageIndexShown = index + 1
                delegateForView?.didScrollImage(imageIndexShown: currentImageIndexShown)
            }
        }
    }
}
