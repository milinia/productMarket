//
//  CategoryView.swift
//  market
//
//  Created by Evelina on 16.02.2025.
//

import Foundation
import UIKit

final class CategoryView: UIView {
    
    private var categories: [Category]
    private var labels: [UILabel] = []
    private var selectedCategoryIndex: Int = -1
    
    var selectedCategory: Category {
        return categories[selectedCategoryIndex]
    }
    
    init(categories: [Category]) {
        self.categories = categories
        
        super.init(frame: .zero)
        
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupLayoutAndGetHeight()
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        frame.size.width = size.width
        let height = setupLayoutAndGetHeight()
            
        return CGSize(width: size.width, height: height)
    }
    
    private func setupView() {
        var index = 0
        categories.forEach { category in
            let label = UILabel()
            label.textColor = .label
            label.font = .systemFont(ofSize: 18, weight: .medium)
            label.textAlignment = .center
            label.text = category.name
            label.layer.borderColor = UIColor.systemGray4.cgColor
            label.layer.borderWidth = 1
            label.layer.cornerRadius = 8
            label.clipsToBounds = true
            label.isUserInteractionEnabled = true
            label.tag = index
            index += 1
                        
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
            label.addGestureRecognizer(tapGesture)
            
            labels.append(label)
            
            addSubview(label)
        }
    }
    
    @objc private func handleTap(_ sender: UITapGestureRecognizer) {
        if let label = sender.view as? UILabel {
            let index = label.tag
            if selectedCategoryIndex != -1 {
                labels[selectedCategoryIndex].backgroundColor = .clear
            }
            if selectedCategoryIndex == index {
                selectedCategoryIndex = -1
                return
            }
            selectedCategoryIndex = index
            labels[selectedCategoryIndex].backgroundColor = .link
        }
    }
    
    func reloadData(with categories: [Category]) {
        self.categories = categories
        
        labels.forEach { $0.removeFromSuperview() }
        labels.removeAll()
        
        setupView()
        setNeedsLayout()
    }
    
    func setSelectedCategory(_ category: Category?) {
        if let category = category, let index = categories.firstIndex(where: { $0.id == category.id }) {
            selectedCategoryIndex = index
            labels[index].backgroundColor = .link
        }
    }
    
    @discardableResult
    func setupLayoutAndGetHeight() -> CGFloat {
        var x: CGFloat = 0
        var y: CGFloat = 0
        let height: CGFloat = 40
        let spaceBetweenTags: CGFloat = 8
        let maxWidth: CGFloat = bounds.width
        
        labels.forEach {
            let width = $0.sizeThatFits(CGSize(width: .greatestFiniteMagnitude, height: height)).width + 28
            
            if x + width > maxWidth {
                x = 0
                y += height + spaceBetweenTags
            }
                
            $0.frame = CGRect(x: x, y: y, width: width, height: height)
                
            x += width + spaceBetweenTags
        }
        
        return y + height
    }
}
