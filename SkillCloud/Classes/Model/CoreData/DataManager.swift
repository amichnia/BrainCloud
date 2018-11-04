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
    static var applicationDocumentsDirectory: URL { return DataManager.sharedManager.applicationDocumentsDirectory }
    lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "amichnia.SkillCloud" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()

    static var managedObjectModel: NSManagedObjectModel { return DataManager.sharedManager.managedObjectModel }
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: ProjectMOMDName, withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()

    static var persistentStoreCoordinator: NSPersistentStoreCoordinator { return DataManager.sharedManager.persistentStoreCoordinator }
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?
            
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
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
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

// MARK: - Getting and fetching entities
extension DataManager {
    static func getFirst<T:CoreDataEntity>(_ entity: T.Type, withIdentifier identifier: String, fromContext ctx: NSManagedObjectContext? = nil) throws -> T? {
        let predicate = NSPredicate(format: "\(entity.uniqueIdentifier) = %@", identifier)
        return try self.getAll(entity, withPredicate: predicate, fromContext: ctx).first
    }

    static func getAll<T:CoreDataEntity>(_ entity: T.Type, fromContext ctx: NSManagedObjectContext? = nil) throws -> [T] {
        return try getAll(entity, withPredicate: nil, fromContext: ctx)
    }

    static func getAll<T:CoreDataEntity>(_ entity: T.Type, withPredicate predicate: NSPredicate?, fromContext ctx: NSManagedObjectContext? = nil) throws -> [T] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity.entityName)
        fetchRequest.predicate = predicate
        return try (ctx ?? self.managedObjectContext).fetch(fetchRequest).map{ $0 as! T }
    }

    static func fetchAll<T:CoreDataEntity>(_ entity: T.Type, fromContext ctx: NSManagedObjectContext? = nil) -> Promise<[T]> {
        return self.fetchAll(entity, withPredicate: nil, fromContext: ctx)
    }

    static func fetchAll<T:CoreDataEntity>(_ entity: T.Type, withPredicate predicate: NSPredicate?, fromContext ctx: NSManagedObjectContext? = nil) -> Promise<[T]> {
        return Promise(resolvers: { (fulfill, reject) -> Void in
            let context = ctx ?? DataManager.managedObjectContext
            
            context.perform{
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

    static func fetchFirst<T:CoreDataEntity>(_ entity: T.Type, withPredicate predicate: NSPredicate?, fromContext ctx: NSManagedObjectContext? = nil) -> Promise<T> {
        return self.fetchAll(entity, withPredicate: predicate, fromContext: ctx).then { values -> T in
            guard let result = values.first else {
                throw DataError.entityDoesNotExist
            }
            return result
        }
    }

    static func fetchEntity<T:CoreDataEntity>(_ entity: T.Type, withIdentifier identifier: String, fromContext ctx: NSManagedObjectContext? = nil) -> Promise<T> {
        let predicate = NSPredicate(format: "\(entity.uniqueIdentifier) = %@", identifier)
        return self.fetchFirst(entity, withPredicate: predicate, fromContext: ctx)
    }
}

// MARK: - Inserting entities
extension DataManager {
    static func updateEntity<T:CoreDataEntity>(_ entity: T.Type, model: DTOModel, intoContext ctx: NSManagedObjectContext? = nil) -> T? {
        do {
            if let existingEntity = try DataManager.getFirst(entity, withIdentifier: model.uniqueIdentifierValue, fromContext: ctx) {
                existingEntity.setValuesFromModel(model)
                return existingEntity
            }
            else {
                throw DataError.entityDoesNotExist
            }
        }
        catch {
            if case DataError.entityDoesNotExist = error {
                return T(model: model, inContext: ctx ?? self.managedObjectContext)
            }
            else {
                return nil
            }
        }
    }

    static func insertEntity<T:CoreDataEntity>(_ entity: T.Type, model: DTOModel, intoContext ctx: NSManagedObjectContext? = nil) -> T? {
        return T(model: model, inContext: ctx ?? self.managedObjectContext)
    }

    static func promiseEntity<T:CoreDataEntity>(_ entity: T.Type, model: DTOModel, intoContext ctx: NSManagedObjectContext? = nil) -> Promise<T> {
        return DataManager.fetchEntity(entity, withIdentifier: model.uniqueIdentifierValue, fromContext: ctx)
        .then{ (entity) -> T in
            entity.setValuesFromModel(model)
            return entity
        }
        .recover { (error: Error) -> T in
            if case DataError.entityDoesNotExist = error {
                if let entity = T(model: model, inContext: ctx ?? self.managedObjectContext) {
                    return entity
                }
                else {
                    throw DataError.failedToInsertEntity
                }
            }
            else {
                throw DataError.failedToInsertEntity
            }
        }
        .then{ (entity: T) -> T in
            try DataManager.saveRootContext()
            return entity
        }
    }

    static func promiseUpdateEntity<T:CoreDataEntity>(_ entity: T.Type, model: DTOModel, intoContext ctx: NSManagedObjectContext? = nil) -> Promise<T> {
        return DataManager.fetchEntity(entity, withIdentifier: model.previousUniqueIdentifier ?? model.uniqueIdentifierValue, fromContext: ctx)
        .then{ (entity) -> T in
            entity.setValuesFromModel(model)
            return entity
        }
        .recover { (error: Error) -> T in
            if case DataError.entityDoesNotExist = error {
                if let entity = T(model: model, inContext: ctx ?? self.managedObjectContext) {
                    return entity
                }
                else {
                    throw DataError.failedToInsertEntity
                }
            }
            else {
                throw DataError.failedToInsertEntity
            }
        }
        .then{ (entity: T) -> T in
            try DataManager.saveRootContext()
            return entity
        }
    }

    static func promiseDeleteEntity<T:CoreDataEntity>(_ entity: T.Type, model: DTOModel, fromContext ctx: NSManagedObjectContext? = nil) -> Promise<Void> {
        return Promise<Void>() { (fulfill, reject) in
            do {
                try self.deleteEntity(entity, withIdentifier: model.uniqueIdentifierValue, fromContext: ctx)
                fulfill()
            }
            catch {
                reject(error)
            }
        }
        .then {
            try DataManager.saveRootContext()
        }
    }
}

extension DataManager {
    static func deleteEntity<T:CoreDataEntity>(_ entity: T.Type, withIdentifier identifier: String, fromContext ctx: NSManagedObjectContext? = nil) throws {
        let predicate = NSPredicate(format: "\(entity.uniqueIdentifier) = %@", identifier)
        if let existingEntity = try DataManager.getAll(entity, withPredicate: predicate, fromContext: ctx).first as? NSManagedObject {
            (ctx ?? DataManager.managedObjectContext).delete(existingEntity)
        }
    }

    static func deleteAllEntities<T:CoreDataEntity>(_ entity: T.Type, fromContext ctx: NSManagedObjectContext? = nil) throws {
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: entity.entityName)
        let delete = NSBatchDeleteRequest(fetchRequest: fetch)
        try (ctx ?? DataManager.managedObjectContext).execute(delete)
    }
}

protocol DTOModel {
    var previousUniqueIdentifier: String? { get }
    var uniqueIdentifierValue: String { get }
}

/**
 *  Base CoreDataEntity protocol
 */
protocol CoreDataEntity : class {
    static var entityName : String { get }
    static var uniqueIdentifier : String { get }

    init?(model: DTOModel, inContext ctx: NSManagedObjectContext)

    func setValuesFromModel(_ model: DTOModel)
}

// MARK: - Default implementations for all CoreDataEntities
extension CoreDataEntity {
    static func fetchAll() -> Promise<[Self]>{
        return DataManager.fetchAll(self)
    }

    static func fetchAllWithPredicate(_ predicate: NSPredicate) -> Promise<[Self]>{
        return DataManager.fetchAll(self, withPredicate: predicate)
    }

    static func promiseToInsert(_ model: DTOModel) -> Promise<Self> {
        return DataManager.promiseEntity(self, model: model)
    }

    static func promiseToUpdate(_ model: DTOModel) -> Promise<Self> {
        return DataManager.promiseUpdateEntity(self, model: model)
    }

    static func promiseToDelete(_ model: DTOModel) -> Promise<Void> {
        return DataManager.promiseDeleteEntity(self, model: model)
    }
}

// MARK: - Executing promises
extension NSManagedObject {
    func promisePerform<T>(_ block: @escaping ()->T) -> Promise<T> {
        return Promise<T> { (fulfill, reject) in
            self.managedObjectContext?.perform{
                let result = block()
                fulfill(result)
            }
        }
    }
}

// MARK: - DataError enum
enum DataError : Error {
    case failedToInsertEntity
    case entityDoesNotExist
}
