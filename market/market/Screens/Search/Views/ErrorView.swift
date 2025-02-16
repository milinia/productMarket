//
//  ErrorView.swift
//  market
//
//  Created by Evelina on 16.02.2025.
//

import Foundation
import UIKit

protocol ErrorViewDelegate: AnyObject {
    func errorViewDidTapTryAgain()
}

final class ErrorView: UIView {
    
    enum Constants {
        static let spacing = 20.0
    }
    
    weak var delegate: ErrorViewDelegate?
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = .systemFont(ofSize: 17)
        label.textAlignment = .center
        label.numberOfLines = 1
        label.text = StringConstants.Search.error
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var tryAgainButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.buttonSize = .medium
        config.cornerStyle = .medium
        let button = UIButton()
        button.configuration = config
        button.setTitle(StringConstants.Search.tryAgain, for: .normal)
        button.addTarget(self, action: #selector(tryAgainButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    @objc private func tryAgainButtonTapped() {
        delegate?.errorViewDidTapTryAgain()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        [label, tryAgainButton].forEach { addSubview($0) }
        
        NSLayoutConstraint.activate([
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            tryAgainButton.topAnchor.constraint(equalTo: label.bottomAnchor, constant: Constants.spacing),
            tryAgainButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            tryAgainButton.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.5)
        ])
    }
}
