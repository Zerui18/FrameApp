//
//  CDManager.swift
//  Frame
//
//  Created by Zerui Chen on 20/9/21.
//

import CoreData

/// A custom subclass that stores the database in `rootDocumentsFolder`.
final class MyPersistentContainer: NSPersistentContainer {
    override class func defaultDirectoryURL() -> URL {
        return Paths.rootDocumentsFolder
    }
}

struct CDManager {
            
    static var moc: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    static func perform(_ block: @escaping (NSManagedObjectContext) -> Void) {
        moc.perform {
            block(moc)
        }
    }
    
    static func performAndSave(_ block: @escaping (NSManagedObjectContext) -> Void) {
        moc.perform {
            block(moc)
            try? moc.save()
        }
    }
    
    /// The shared persistent container for Frame.
    static private let persistentContainer: MyPersistentContainer = {
        let container = MyPersistentContainer(name: "Frame")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
          if let error = error as NSError? {
              fatalError("Unresolved error \(error), \(error.userInfo)")
          }
        })
        return container
    }()
    
    static func getFetchResultsController<Result: NSManagedObject>(forRequest fetchRequest: NSFetchRequest<Result>) -> NSFetchedResultsController<Result> {
        NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CDManager.moc, sectionNameKeyPath: nil, cacheName: nil)
    }
    
}
