//
//  BasePersistenceManager.swift
//  market
//
//  Created by Evelina on 11.02.2025.
//

import Foundation
import UIKit
import CoreData

class BasePersistenceManager {
    
    let context: NSManagedObjectContext? = {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return nil}
        return appDelegate.persistentContainer.viewContext
    }()
}
