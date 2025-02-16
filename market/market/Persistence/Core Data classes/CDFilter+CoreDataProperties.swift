//
//  CDFilter+CoreDataProperties.swift
//  market
//
//  Created by Evelina on 10.02.2025.
//
//

import Foundation
import CoreData


extension CDFilter {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDFilter> {
        return NSFetchRequest<CDFilter>(entityName: "CDFilter")
    }

    @NSManaged public var title: String
    @NSManaged public var price: NSNumber?
    @NSManaged public var priceMin: NSNumber?
    @NSManaged public var priceMax: NSNumber?
    @NSManaged public var categoryId: NSNumber?
    @NSManaged public var date: Date

}

extension CDFilter : Identifiable {

}
