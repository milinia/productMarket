//
//  LabelCell.swift
//  market
//
//  Created by Evelina on 10.02.2025.
//

import Foundation
import UIKit

class LabelCell: UICollectionViewCell {

    private lazy var label: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = .systemFont(ofSize: 17)
        label.textAlignment = .center
        label.numberOfLines = 1
        label.text = StringConstants.Search.nothingFound
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        addSubview(label)
    
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    func configure(with text: String) {
        label.text = text
    }
}
