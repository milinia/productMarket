//
//  DetailViewController.swift
//  market
//
//  Created by Evelina on 13.02.2025.
//

import Foundation
import UIKit

protocol DetailViewInput: AnyObject {
    func updateProduct(product: Product)
    func updateProductQuantity(quantity: Int)
    func showError()
}

class DetailViewController: UIViewController {
    
    enum Constants {
        static let horizontalOffset = 16.0
        static let verticalOffset = 8.0
        static let spacing = 8.0
        static let smallSpacing = 4.0
        static let titlesHeight: CGFloat = 20.0
        static let imagesCollectionViewHeight: CGFloat = UIScreen.main.bounds.height * 0.5
    }
    
    private var product: Product?
    private var productId: Int
    private var output: DetailViewOutput
    
    private var isProductInCart: Bool {
        didSet {
            setCartButtonTitleAndColor()
            checkIsProductInCart()
        }
    }
    
    private var quantity: Int = 0
    
    init(product: Product?, productId: Int, output: DetailViewOutput, quantity: Int) {
        self.product = product
        self.productId = productId
        self.output = output
        self.quantity = quantity
        self.isProductInCart = quantity > 0 ? true : false
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var collectionViewLayout: UICollectionViewFlowLayout = {
        let collectionViewLayout = UICollectionViewFlowLayout()
        collectionViewLayout.minimumLineSpacing = 0
        collectionViewLayout.scrollDirection = .horizontal
        collectionViewLayout.itemSize = CGSize(width: view.frame.width, height: Constants.imagesCollectionViewHeight)
        return collectionViewLayout
    }()
    
    private lazy var collectionView: CarouselImageCollectionView = {
        let collectionView = CarouselImageCollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.delegateForCell = output
        collectionView.delegateForView = self
        return collectionView
    }()
    
    private lazy var priceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textColor = .label
        return label
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var categoryLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var descriptionTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .label
        label.text = StringConstants.Detail.description
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .light)
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var containerView: UIScrollView = {
        let scrollView = UIScrollView(frame: .zero)
        scrollView.showsVerticalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private lazy var productQuantityView: ProductQuantityView = {
        let view = ProductQuantityView(quantity: quantity)
        view.isHidden = !isProductInCart
        view.isZeroReachable = true
        view.delegate = self
        return view
    }()
    
    private lazy var cartButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.buttonSize = .medium
        config.cornerStyle = .medium
        let button = UIButton()
        button.configuration = config
        button.addTarget(self, action: #selector(cartButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var stackViewForButtons: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [productQuantityView, cartButton])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        return stackView
    }()
    
    private lazy var errorView: ErrorView = {
        let errorView = ErrorView()
        errorView.translatesAutoresizingMaskIntoConstraints = false
        errorView.isHidden = true
        errorView.delegate = self
        return errorView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        
        getData()
    }
    
    private func getData() {
        if product != nil {
            setupData(product: product!)
        } else {
            output.loadProduct(with: productId)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        output.viewWillAppear(with: productId)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        containerView.contentSize = calculateContentSize()
        setCartButtonTitleAndColor()
        checkIsProductInCart()
    }
    
    @objc private func cartButtonTapped() {
        if isProductInCart {
            output.viewDidTappedGoToCart()
        } else {
            isProductInCart = true
            if let product = product {
                output.didAddToCart(product: product,
                                    quantity: productQuantityView.quantity,
                                    image: collectionView.currentImageShown)
            }
        }
    }
    
    private func setupView() {
        view.backgroundColor = .systemBackground
        setupNavigationBar()
        
        [errorView, containerView].forEach({ view.addSubview($0) })
        
        [collectionView, priceLabel, titleLabel, stackViewForButtons, categoryLabel,
         descriptionTitleLabel, descriptionLabel].forEach({ containerView.addSubview($0) })
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            errorView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            errorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            errorView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            errorView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        containerView.contentSize = calculateContentSize()
    }
    
    private func setCartButtonTitleAndColor() {
        UIView.animate(withDuration: 0.3) {
            let title = self.isProductInCart ? StringConstants.Detail.goToCart : StringConstants.Detail.addToCart
            self.cartButton.setTitle(title, for: .normal)
        }
    }
    
    private func checkIsProductInCart() {
        if isProductInCart {
            UIView.animate(withDuration: 0.2) {
                self.productQuantityView.isHidden = false
            }
        } else {
            UIView.animate(withDuration: 0.2) {
                self.productQuantityView.isHidden = true
            }
        }
    }
    
    private func setupData(product: Product) {
        collectionView.setImageUrls(product.images)
        priceLabel.text = product.price.formatted() + " $"
        titleLabel.text = product.title
        descriptionLabel.text = product.description
        categoryLabel.attributedText = createCategoryAttributeString(text: product.category.name)
        containerView.contentSize = calculateContentSize()
    }
    
    private func createCategoryAttributeString(text: String) -> NSAttributedString {
        let string =  "\(StringConstants.Detail.category) \(text)"
        let attributedString = NSMutableAttributedString(string: string)
        
        let categoryTitleRange = (string as NSString).range(of: StringConstants.Detail.category)
        attributedString.addAttribute(.foregroundColor, value: UIColor.secondaryLabel, range: categoryTitleRange)
        
        let categoryTextRange = (string as NSString).range(of: text)
        attributedString.addAttribute(.foregroundColor, value: UIColor.label, range: categoryTextRange)
        
        return attributedString
    }
    
    private func calculateContentSize() -> CGSize {
        let width: CGFloat = UIScreen.main.bounds.width
        let widthWithInsets: CGFloat = width - 2 * Constants.horizontalOffset
        
        collectionView.frame = CGRect(x: 0,
                                      y: Constants.verticalOffset,
                                      width: width,
                                      height: Constants.imagesCollectionViewHeight)
        
        let priceLabelHeight = priceLabel.sizeThatFits(CGSize(width: widthWithInsets,
                                                              height: .greatestFiniteMagnitude)).height
        
        priceLabel.frame = CGRect(x: Constants.horizontalOffset,
                                  y: collectionView.frame.maxY + Constants.spacing,
                                  width: widthWithInsets,
                                  height: priceLabelHeight)
        
        let titleLabelHeight = titleLabel.sizeThatFits(CGSize(width: widthWithInsets,
                                                              height: .greatestFiniteMagnitude)).height
        
        titleLabel.frame = CGRect(x: Constants.horizontalOffset,
                                  y: priceLabel.frame.maxY + Constants.spacing,
                                  width: widthWithInsets,
                                  height: titleLabelHeight)
        
        let categoryLabelHeight = categoryLabel.sizeThatFits(CGSize(width: widthWithInsets,
                                                              height: .greatestFiniteMagnitude)).height
        
        categoryLabel.frame = CGRect(x: Constants.horizontalOffset,
                                          y: titleLabel.frame.maxY + Constants.smallSpacing,
                                          width: widthWithInsets,
                                          height: categoryLabelHeight)
        
        stackViewForButtons.frame = CGRect(x: Constants.horizontalOffset,
                                           y: categoryLabel.frame.maxY + 2 * Constants.spacing,
                                           width: widthWithInsets,
                                           height: 50)
        
        descriptionTitleLabel.frame = CGRect(x: Constants.horizontalOffset,
                                             y: stackViewForButtons.frame.maxY + 2 * Constants.spacing,
                                             width: widthWithInsets,
                                             height: Constants.titlesHeight)
        
        let descriptionLabelHeight = descriptionLabel.sizeThatFits(CGSize(width: widthWithInsets,
                                                              height: .greatestFiniteMagnitude)).height
        
        descriptionLabel.frame = CGRect(x: Constants.horizontalOffset,
                                        y: descriptionTitleLabel.frame.maxY + Constants.spacing,
                                        width: widthWithInsets,
                                        height: descriptionLabelHeight)
        
        return CGSize(width: view.bounds.width,
                      height: descriptionLabel.frame.maxY + Constants.verticalOffset)
    }
    
    private func setupNavigationBar() {
        navigationItem.backButtonTitle = ""
        
        let barButton = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up"),
                                        style: .plain, target: self,
                                        action: #selector(shareText))
        navigationItem.rightBarButtonItem = barButton
    }
    
    @objc private func shareText() {
        guard let product = product else { return }
        let items = [output.didTapShareButton(for: product)]
        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
        present(ac, animated: true)
    }
}

extension DetailViewController: CarouselImageCollectionViewDelegate {
    
    func didSelectImage(url: String, image: UIImage?) {
        output.viewDidTappedOnImage(imageURLs: product?.images ?? [])
    }
}

extension DetailViewController: ProductQuantityViewDelegate {
    func quantityDidChange(_ newQuantity: Int) {
        if newQuantity != 0 {
            output.updateProduct(with: newQuantity)
        }
    }
    
    func quantityDidReachedZero() {
        isProductInCart = false
        guard let product = product else { return }
        output.didDeleteFromCart(product: product)
    }
}

extension DetailViewController: DetailViewInput {
    func updateProduct(product: Product) {
        containerView.isHidden = false
        errorView.isHidden = true
        self.product = product
        setupData(product: product)
    }
    
    func updateProductQuantity(quantity: Int) {
       if quantity > 0 {
           self.isProductInCart = true
           self.quantity = quantity
           productQuantityView.quantity = quantity
       } else {
           self.isProductInCart = false
           self.quantity = 0
       }
    }
    
    func showError() {
        containerView.isHidden = true
        errorView.isHidden = false
    }
}

extension DetailViewController: ErrorViewDelegate {
    func errorViewDidTapTryAgain() {
        getData()
    }
}
