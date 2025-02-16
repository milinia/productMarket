//
//  CDProduct+CoreDataProperties.swift
//  market
//
//  Created by Evelina on 15.02.2025.
//
//

import Foundation
import CoreData


extension CDProduct {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDProduct> {
        return NSFetchRequest<CDProduct>(entityName: "CDProduct")
    }

    @NSManaged public var id: Int32
    @NSManaged public var title: String?
    @NSManaged public var price: Double
    @NSManaged public var quantity: Int16
    @NSManaged public var image: Data?
    @NSManaged public var cart: Cart?

}

extension CDProduct : Identifiable {

}
