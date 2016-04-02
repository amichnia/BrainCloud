//
//  DataManager.swift
//  SkillCloud
//
//  Created by Andrzej Michnia on 19.03.2016.
//  Copyright © 2016 amichnia. All rights reserved.
//

import UIKit
import CoreData
import PromiseKit

let ProjectMOMDName = "SkillCloud"

class DataManager: NSObject {
    
    // MARK: - Singleton
    static var sharedManager : DataManager = DataManager()
    
    // MARK: - Core Data stack properties
    static var applicationDocumentsDirectory: NSURL { return DataManager.sharedManager.applicationDocumentsDirectory }
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "amichnia.SkillCloud" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()
    
    static var managedObjectModel: NSManagedObjectModel { return DataManager.sharedManager.managedObjectModel }
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource(ProjectMOMDName, withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
    
    static var persistentStoreCoordinator: NSPersistentStoreCoordinator { return DataManager.sharedManager.persistentStoreCoordinator }
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()
    
    static var managedObjectContext: NSManagedObjectContext { return DataManager.sharedManager.managedObjectContext }
    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    // MARK: - Core Data Saving support
    
    static func saveRootContext() throws {
        if managedObjectContext.hasChanges {
            try managedObjectContext.save()
        }
    }

}

extension DataManager {
    
    static func getAll<T:CoreDataEntity>(entity: T.Type, fromContext ctx: NSManagedObjectContext? = nil) throws -> [T] {
        return try getAll(entity, withPredicate: nil, fromContext: ctx)
    }
    
    static func getAll<T:CoreDataEntity>(entity: T.Type, withPredicate predicate: NSPredicate?, fromContext ctx: NSManagedObjectContext? = nil) throws -> [T] {
        let fetchRequest = NSFetchRequest(entityName: entity.entityName)
        fetchRequest.predicate = predicate
        return try (ctx ?? self.managedObjectContext).executeFetchRequest(fetchRequest).map{ $0 as! T }
    }

    static func fetchAll<T:CoreDataEntity>(entity: T.Type, fromContext ctx: NSManagedObjectContext? = nil) -> Promise<[T]> {
        return self.fetchAll(entity, withPredicate: nil, fromContext: ctx)
    }
    
    static func fetchAll<T:CoreDataEntity>(entity: T.Type, withPredicate predicate: NSPredicate?, fromContext ctx: NSManagedObjectContext? = nil) -> Promise<[T]> {
        return Promise(resolvers: { (fulfill, reject) -> Void in
            let context = ctx ?? DataManager.managedObjectContext
            
            context.performBlock{
                do {
                    let result = try DataManager.getAll(entity, withPredicate: predicate, fromContext: context)
                    fulfill(result)
                }
                catch {
                    reject(error)
                }
            }
        })
    }

}

extension DataManager {
    
    static func insertEntity<T:CoreDataEntity>(entity: T.Type, model: DTOModel, intoContext ctx: NSManagedObjectContext? = nil) -> T? {
        return T(model: model, inContext: ctx ?? self.managedObjectContext)
    }
    
    static func promiseEntity<T:CoreDataEntity>(entity: T.Type, model: DTOModel, intoContext ctx: NSManagedObjectContext? = nil) -> Promise<T> {
        return Promise(resolvers: { (fulfill, reject) -> Void in
            if let entity = T(model: model, inContext: ctx ?? self.managedObjectContext) {
                fulfill(entity)
            }
            else {
                reject(DataError.FailedToInsertEntity)
            }
        }).then({ (entity: T) -> T in
            try DataManager.saveRootContext()
            return entity
        })
    }
    
}

/**
 *  Base CoreDataEntity protocol
 */
protocol CoreDataEntity {
    
    static var entityName : String { get }
    
    init?(model: DTOModel, inContext ctx: NSManagedObjectContext)
    
}

// MARK: - Default implementations for all CoreDataEntities
extension CoreDataEntity {
    
    static func fetchAll() -> Promise<[Self]>{
        return DataManager.fetchAll(self)
    }
    
    static func promiseToInsert(model: DTOModel) -> Promise<Self> {
        return DataManager.promiseEntity(self, model: model)
    }
    
}

// MARK: - DataError enum

enum DataError : ErrorType {
    case FailedToInsertEntity
}
