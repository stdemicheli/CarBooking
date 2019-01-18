//
//  CoreDataStack.swift
//  CarBooking
//
//  Created by De MicheliStefano on 18.01.19.
//  Copyright © 2019 De MicheliStefano. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    
    static let shared = CoreDataStack()
    
    func save(context: NSManagedObjectContext) throws {
        var error: Error?
        
        context.performAndWait {
            do {
                try context.save()
            } catch let saveError {
                NSLog("Error while saving to persistent store: \(saveError)")
                error = saveError
            }
        }
        
        if let error = error { throw error }
    }
    
    lazy var container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Vehicle")
        container.loadPersistentStores  { (_, error) in
            if let error = error {
                fatalError("Failed to load persistent store: \(error)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()
    
    var mainContext: NSManagedObjectContext {
        return container.viewContext
    }
    
}

