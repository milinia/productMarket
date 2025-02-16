//
//  FilterViewController.swift
//  market
//
//  Created by Evelina on 12.02.2025.
//

import Foundation
import UIKit

protocol FilterViewInput: AnyObject {
    func didReceiveCategories(_ categories: [Category])
}

protocol FilterViewControllerDelegate: AnyObject {
    func didDismissWithData(_ filter: Filter)
}

class FilterViewController: UIViewController {
    
    enum Constants {
        static let horizontalOffset = 16.0
        static let verticalOffset = 8.0
        static let spacing = 8.0
        static let spacingBetweenSections = 24.0
    }
    
    weak var delegate: FilterViewControllerDelegate?
    
    private var categories: [Category] = []
    private let filter: Filter?
    var output: FilterViewOutput
    
    init(output: FilterViewOutput, filter: Filter?) {
        self.output = output
        self.filter = filter
    
        super.init(nibName: nil, bundle: nil)
        
        setData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
    
    private lazy var applyButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.buttonSize = .medium
        config.cornerStyle = .medium
        let button = UIButton()
        button.configuration = config
        button.setTitle(StringConstants.Filter.apply, for: .normal)
        button.addTarget(self, action: #selector(applyButtonTapped), for: .touchUpInside)
        return button
    }()
    
    @objc private func applyButtonTapped() {
        let title = self.filter?.title == "" ? "" : self.filter?.title ?? ""
        let price = priceTextField.text == "" ? filter?.price : Int(priceTextField.text ?? "0")
        let priceMin = priceFromTextField.text == "" ? filter?.priceMin : Int(priceFromTextField.text ?? "0")
        let priceMax = priceToTextField.text == "" ? filter?.priceMax : Int(priceToTextField.text ?? "0")
        
        let filter = Filter(uuid: UUID(), title: title,
                            category: categoryView.selectedCategory,
                            price: price,
                            priceMin: priceMin,
                            priceMax: priceMax)
        
        delegate?.didDismissWithData(filter)
        dismiss(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        output.getCategories()
        setupView()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        setupContraints()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        preferredContentSize = containerView.contentSize
    }
    
    private func setupView() {
        view.backgroundColor = .systemBackground
        view.addSubview(containerView)
        
        [categoryTitleLabel, categoryView, priceTitleLabel, priceTextField,
         priceRangeTitleLabel, priceFromTextField, priceToTextField, applyButton].forEach({containerView.addSubview($0)})
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: view.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
    }
    
    private func setData() {
        if let filter = filter {
            
            if let price = filter.price {
                priceTextField.text = String(price)
            }
            
            if let priceMin = filter.priceMin {
                priceFromTextField.text = String(priceMin)
            }
            
            if let priceMax = filter.priceMax {
                priceToTextField.text = String(priceMax)
            }
        }
    }
    
    private func setupContraints() {
        let availableWidth: CGFloat = view.bounds.width - Constants.horizontalOffset * 2
        
        let availableHeight = categoryView.sizeThatFits(CGSize(width: availableWidth,
                                                               height: .greatestFiniteMagnitude)).height
        
        categoryTitleLabel.frame = CGRect(x: Constants.horizontalOffset,
                                          y: 2 * Constants.verticalOffset,
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
        
        applyButton.frame = CGRect(x: (view.bounds.width - availableWidth / 2) / 2,
                                   y: priceToTextField.frame.maxY + 2 * Constants.horizontalOffset,
                                   width: availableWidth / 2,
                                   height: 50)
        
        containerView.contentSize = CGSize(width: view.bounds.width,
                                           height: applyButton.frame.maxY + Constants.verticalOffset
        )
    }
}

extension FilterViewController: FilterViewInput {
    func didReceiveCategories(_ categories: [Category]) {
        self.categories = categories
        categoryView.reloadData(with: categories)
        if let category = filter?.category {
            categoryView.setSelectedCategory(category)
        }
        view.setNeedsLayout()
    }
}
