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
        static let horizontalOffsets = 16.0
        static let verticalOffsets = 8.0
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
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [clockImageView, searchRequestLabel, deleteButton])
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
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
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: Constants.verticalOffsets),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.horizontalOffsets),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.horizontalOffsets),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Constants.verticalOffsets)
        ])
    }
    
    func configure(with searchRequest: Filter, indexPath: IndexPath) {
        self.searchRequest = searchRequest
        self.indexPath = indexPath
        searchRequestLabel.text = searchRequest.title
    }
}
