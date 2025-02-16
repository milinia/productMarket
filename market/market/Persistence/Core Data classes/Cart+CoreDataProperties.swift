//
//  Cart+CoreDataProperties.swift
//  market
//
//  Created by Evelina on 15.02.2025.
//
//

import Foundation
import CoreData


extension Cart {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Cart> {
        return NSFetchRequest<Cart>(entityName: "Cart")
    }

    @NSManaged public var product: NSOrderedSet?

}

// MARK: Generated accessors for product
extension Cart {

    @objc(insertObject:inProductAtIndex:)
    @NSManaged public func insertIntoProduct(_ value: CDProduct, at idx: Int)

    @objc(removeObjectFromProductAtIndex:)
    @NSManaged public func removeFromProduct(at idx: Int)

    @objc(insertProduct:atIndexes:)
    @NSManaged public func insertIntoProduct(_ values: [CDProduct], at indexes: NSIndexSet)

    @objc(removeProductAtIndexes:)
    @NSManaged public func removeFromProduct(at indexes: NSIndexSet)

    @objc(replaceObjectInProductAtIndex:withObject:)
    @NSManaged public func replaceProduct(at idx: Int, with value: CDProduct)

    @objc(replaceProductAtIndexes:withProduct:)
    @NSManaged public func replaceProduct(at indexes: NSIndexSet, with values: [CDProduct])

    @objc(addProductObject:)
    @NSManaged public func addToProduct(_ value: CDProduct)

    @objc(removeProductObject:)
    @NSManaged public func removeFromProduct(_ value: CDProduct)

    @objc(addProduct:)
    @NSManaged public func addToProduct(_ values: NSOrderedSet)

    @objc(removeProduct:)
    @NSManaged public func removeFromProduct(_ values: NSOrderedSet)

}

extension Cart : Identifiable {

}
