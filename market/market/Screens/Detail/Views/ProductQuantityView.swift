//
//  ProductQuantityView.swift
//  market
//
//  Created by Evelina on 13.02.2025.
//

import Foundation
import UIKit

protocol ProductQuantityViewDelegate: AnyObject {
    func quantityDidReachedZero()
    func quantityDidChange(_ newQuantity: Int)
}

final class ProductQuantityView: UIView {
    
    var isZeroReachable: Bool = true
    
    weak var delegate: ProductQuantityViewDelegate?
    
    var quantity: Int {
        didSet {
            quantityLabel.text = "\(quantity)"
        }
    }
    
    private lazy var quantityLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .medium)
        label.textColor = .label
        label.text = String(quantity)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var minusButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("-", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(minusButtonTapped), for: .touchUpInside)
        button.tintColor = UIColor.label
        return button
    }()
    
    private lazy var plusButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("+", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(plusButtonTapped), for: .touchUpInside)
        button.tintColor = UIColor.label
        return button
    }()
    
    init(quantity: Int) {
        self.quantity = quantity == 0 ? 1 : quantity
        
        super.init(frame: .zero)
        
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        [minusButton, quantityLabel, plusButton].forEach({ addSubview($0) })
        
        layer.cornerRadius = 10
        backgroundColor = .systemGray5
        
        NSLayoutConstraint.activate([
            minusButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            minusButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            quantityLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            quantityLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            plusButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            plusButton.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
        
    }
    
    @objc private func minusButtonTapped() {
        if quantity == 0 { return }
        
        if quantity != 2 && quantity != 1 {
            if quantity == 100 {
                plusButton.isUserInteractionEnabled = true
                plusButton.tintColor = UIColor.label
            }
            quantity -= 1
            delegate?.quantityDidChange(quantity)
        } else if quantity != 1 {
            quantity -= 1
            delegate?.quantityDidChange(quantity)
            if !isZeroReachable {
                minusButton.tintColor = UIColor.secondaryLabel
                minusButton.isUserInteractionEnabled = false
            }
        } else {
            if isZeroReachable {
                delegate?.quantityDidReachedZero()
            }
        }
    }

    @objc private func plusButtonTapped() {
        if quantity != 99 {
            if quantity == 1 {
                minusButton.tintColor = UIColor.label
                minusButton.isUserInteractionEnabled = true
            }
            quantity += 1
            delegate?.quantityDidChange(quantity)
        } else {
            quantity += 1
            delegate?.quantityDidChange(quantity)
            plusButton.isUserInteractionEnabled = false
            plusButton.tintColor = UIColor.secondaryLabel
        }
    }
}
