//
//  FilterViewController.swift
//  market
//
//  Created by Evelina on 12.02.2025.
//

import Foundation
import UIKit

class FilterViewController: UIViewController {
    
    enum Constants {
        static let horizontalOffset = 16.0
        static let verticalOffset = 8.0
        static let spacing = 8.0
        static let spacingBetweenSections = 24.0
    }
    
    var categories: [String] = ["Music", "Clothes", "Electronics", "Sports", "Books", "Home", "Toys", "Cars"]
    
    private lazy var categoryTitleLabel: UILabel = {
        let label = UILabel()
        label.text = StringConstants.Filter.category
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 24, weight: .medium)
        return label
    }()
    
    private lazy var categoryView: CategoryView = {
        let view = CategoryView(categories: categories)
        return view
    }()
    
    private lazy var priceTitleLabel: UILabel = {
        let label = UILabel()
        label.text = StringConstants.Filter.price
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 24, weight: .medium)
        return label
    }()
    
    private lazy var priceTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.font = .systemFont(ofSize: 17, weight: .regular)
        return textField
    }()
    
    private lazy var priceRangeTitleLabel: UILabel = {
        let label = UILabel()
        label.text = StringConstants.Filter.priceRange
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 24, weight: .medium)
        return label
    }()
    
    private lazy var priceFromTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.placeholder = StringConstants.Filter.from
        textField.font = .systemFont(ofSize: 17, weight: .regular)
        return textField
    }()
    
    private lazy var priceToTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.placeholder = StringConstants.Filter.to
        textField.font = .systemFont(ofSize: 17, weight: .regular)
        return textField
    }()
    
    private lazy var containerView: UIScrollView = {
        let scrollView = UIScrollView(frame: .zero)
        scrollView.showsVerticalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        setupContraints()
    }
    
    private func setupView() {
        view.addSubview(containerView)
        
        [categoryTitleLabel, categoryView, priceTitleLabel, priceTextField,
         priceRangeTitleLabel, priceFromTextField, priceToTextField].forEach({containerView.addSubview($0)})
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: view.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
    }
    
    private func setupContraints() {
        let availableWidth: CGFloat = view.bounds.width - Constants.horizontalOffset * 2
        
        let availableHeight = categoryView.sizeThatFits(CGSize(width: availableWidth,
                                                               height: .greatestFiniteMagnitude)).height
        
        categoryTitleLabel.frame = CGRect(x: Constants.horizontalOffset,
                                          y: Constants.verticalOffset,
                                          width: availableWidth,
                                          height: 25)
        
        categoryView.frame = CGRect(x: Constants.horizontalOffset,
                                    y: categoryTitleLabel.frame.maxY + Constants.spacing,
                                    width: availableWidth,
                                    height: availableHeight)
        
        priceTitleLabel.frame = CGRect(x: Constants.horizontalOffset,
                                       y: categoryView.frame.maxY + Constants.spacingBetweenSections,
                                       width: availableWidth,
                                       height: 25)
        
        priceTextField.frame = CGRect(x: Constants.horizontalOffset,
                                      y: priceTitleLabel.frame.maxY + Constants.spacing,
                                      width: availableWidth,
                                      height: 50)
        
        priceRangeTitleLabel.frame = CGRect(x: Constants.horizontalOffset,
                                            y: priceTextField.frame.maxY + Constants.spacingBetweenSections,
                                            width: availableWidth,
                                            height: 25)
        
        priceFromTextField.frame = CGRect(x: Constants.horizontalOffset,
                                          y: priceRangeTitleLabel.frame.maxY + Constants.spacing,
                                          width: availableWidth / 2 - Constants.spacing,
                                          height: 50)
        
        priceToTextField.frame = CGRect(x: priceFromTextField.frame.maxX + Constants.spacing,
                                        y: priceRangeTitleLabel.frame.maxY + Constants.spacing,
                                        width: availableWidth / 2 - Constants.spacing,
                                        height: 50)
        
        containerView.contentSize = CGSize(width: view.bounds.width,
                                           height: priceToTextField.frame.maxY + Constants.verticalOffset
        )
    }
}
