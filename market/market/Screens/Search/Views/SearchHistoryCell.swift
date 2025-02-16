//
//  SearchHistoryCell.swift
//  market
//
//  Created by Evelina on 10.02.2025.
//

import Foundation
import UIKit

protocol SearchHistoryCellDelegate: AnyObject {
    func searchHistoryCellDidTapDeleteButton(cellIndexPath: IndexPath?)
}

class SearchHistoryCell: UICollectionViewCell {
    
    private enum Constants {
        static let horizontalOffsets = 12.0
        static let verticalOffsets = 8.0
        static let spacing = 8.0
    }
    
    var searchRequest: Filter?
    weak var delegate: SearchHistoryCellDelegate?
    
    private var indexPath: IndexPath?
    
    private lazy var clockImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "clock.fill"))
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .gray
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var searchRequestLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .label
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var deleteButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .gray
        button.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func deleteButtonTapped() {
        delegate?.searchHistoryCellDidTapDeleteButton(cellIndexPath: indexPath)
    }
    
    private func setupView() {
        [clockImageView, searchRequestLabel, deleteButton].forEach({ addSubview($0) })
        
        let avaliableHeight: CGFloat = frame.height - 2 * Constants.verticalOffsets
        
        NSLayoutConstraint.activate([
            clockImageView.widthAnchor.constraint(equalToConstant: avaliableHeight * 0.6),
            clockImageView.heightAnchor.constraint(equalToConstant: avaliableHeight * 0.6),
            clockImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.horizontalOffsets),
            clockImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            deleteButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.horizontalOffsets),
            deleteButton.topAnchor.constraint(equalTo: topAnchor, constant: Constants.verticalOffsets),
            deleteButton.widthAnchor.constraint(equalToConstant: avaliableHeight),
            deleteButton.heightAnchor.constraint(equalToConstant: avaliableHeight),
            
            searchRequestLabel.leadingAnchor.constraint(equalTo: clockImageView.trailingAnchor, constant: Constants.spacing),
            searchRequestLabel.trailingAnchor.constraint(equalTo: deleteButton.leadingAnchor, constant: -Constants.spacing),
            searchRequestLabel.topAnchor.constraint(equalTo: topAnchor, constant: Constants.verticalOffsets),
            searchRequestLabel.heightAnchor.constraint(equalToConstant: avaliableHeight)
        ])
    }
    
    func configure(with searchRequest: Filter, indexPath: IndexPath) {
        self.searchRequest = searchRequest
        self.indexPath = indexPath
        searchRequestLabel.text = searchRequest.title
    }
}
