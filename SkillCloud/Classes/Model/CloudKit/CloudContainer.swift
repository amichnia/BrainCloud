//
//  CloudContainer.swift
//  SkillCloud
//
//  Created by Andrzej Michnia on 25/06/16.
//  Copyright © 2016 amichnia. All rights reserved.
//

import Foundation
import UIKit
import CloudKit
import PromiseKit

let DefaultsLastSyncTimestampKey = "kLastSyncTimestamp"

/// Cloud container class - encapsulates CK promises and CK Deserters
class CloudContainer {
    
    // MARK: - Big bad singleton
    static var sharedContainer: CloudContainer = CloudContainer()
    
    // MARK: - Properties
    let container: CKContainer
    let publicDatabase: CKDatabase
    let privateDatabase: CKDatabase
    
    var lastSyncDate: Date? {
        get {
            return UserDefaults.standard.object(forKey: DefaultsLastSyncTimestampKey) as? Date
        }
        set {
            if newValue == nil {
                UserDefaults.standard.removeObject(forKey: DefaultsLastSyncTimestampKey)
            }
            else {
                UserDefaults.standard.set(newValue!, forKey: DefaultsLastSyncTimestampKey)
            }
            UserDefaults.standard.synchronize()
        }
    }
    
    // MARK: - Private properties
    fileprivate var userRecordID : CKRecordID!
    fileprivate var contacts = [AnyObject]()
    
    // MARK: - Initializers
    init() {
        self.container = CKContainer.default()
        self.publicDatabase = self.container.publicCloudDatabase
        self.privateDatabase = self.container.privateCloudDatabase
    }
    
    // MARK: - Private
    func database(_ type: DatabaseType) -> CKDatabase {
        switch type {
        case .private:
            return self.privateDatabase
        case .public:
            return self.publicDatabase
        }
    }
    
    // MARK: - Public promises
    // TODO: Remove it from there? Refactoring in v1.1
    func promiseAllSkillsFromDatabase(_ database: DatabaseType) -> Promise<[Skill]> {
        return Promise<[Skill]>() { fulfill, reject in
            DispatchQueue.global(qos: .userInitiated).async {
                let predicate = NSPredicate(value: true)
                let query = CKQuery(recordType: Skill.recordType, predicate: predicate)
                
                self.database(database).perform(query, inZoneWith: nil) { records, error in
                    if let error = error {
                        reject(error)
                    }
                    else if let records = records {
                        let skillsPromises = records.map{ Skill.promiseWithRecord($0) }
                        let _ = when(fulfilled: skillsPromises).then { skills -> Void in
                            fulfill(skills)
                        }
                    }
                    else {
                        reject(CloudError.noData)
                    }
                }
            }
        }
    }
    
    func promiseAllSkillsWithPredicate(_ predicate: NSPredicate, fromDatabase database: DatabaseType) -> Promise<[Skill]> {
        return Promise<[Skill]>() { fulfill, reject in
            DispatchQueue.global(qos: .userInitiated).async {
                let query = CKQuery(recordType: Skill.recordType, predicate: predicate)
                
                self.database(database).perform(query, inZoneWith: nil) { records, error in
                    if let error = error {
                        reject(error)
                    }
                    else if let records = records {
                        let skillsPromises = records.map{ Skill.promiseWithRecord($0) }
                        let _ = when(fulfilled: skillsPromises).then { skills -> Void in
                            fulfill(skills)
                        }
                    }
                    else {
                        reject(CloudError.noData)
                    }
                }
            }
        }
    }
    
    
    
    // MARK: - Sync promises
    func promiseUserID() -> Promise<CKRecordID> {
        guard self.userRecordID == nil else {
            return Promise<CKRecordID>(value: self.userRecordID)
        }
        
        return Promise<CKRecordID>() { fulfill,reject in
            self.container.fetchUserRecordID() { recordID, error in
                if let recordID = recordID, error == nil {
                    self.userRecordID = recordID
                    fulfill(recordID)
                }
                else {
                    reject(error ?? CloudError.unknownError)
                }
            }
        }
    }
    
    func promiseUserRecord() -> Promise<CKRecord> {
        return self.promiseUserID().then(execute: self.publicDatabase.promiseRecordWithID)
    }
    
    func promiseSyncInfo() -> Promise<SyncInfo> {
        return self.promiseUserRecord().then { SyncInfo(userRecord: $0) }
    }
    
    func promiseSync() -> Promise<Void> {
        return self.promiseSyncTo().then(execute: self.promiseSyncFrom)
    }
    
    func promiseSyncFrom() -> Promise<Void> {
        let predicate: NSPredicate? = {
            if let lastSyncDate = self.lastSyncDate {
                return NSPredicate(format: "modificationDate >= %@", lastSyncDate as NSDate)
            } else {
                return nil
            }
        }()
        
        let syncDate = Date()
        
        return self.privateDatabase.promiseAllWith(predicate)
        .then(on: DispatchQueue.main) { (skills: [Skill]) -> Promise<[SkillEntity]> in
            return when(fulfilled: skills.map(SkillEntity.promiseToUpdate))
        }
        .then { savedEntities -> Void in
            self.lastSyncDate = syncDate
            print("Saved \(savedEntities.count) entities")
        }
        .asVoid()
    }
    
    func promiseSyncTo() -> Promise<Void> {
        return Skill.fetchAllUnsynced()
        .then { skills -> Promise<[SkillEntity]> in
            return when(fulfilled: skills.map {
                $0.promiseSyncTo().then(execute: SkillEntity.promiseToUpdate)
            })
        }
        .then { savedEntities -> Void in
            print("Uploaded \(savedEntities.count) entities")
        }
        .then(execute: Skill.fetchAllToDelete)
        .then { toDelete -> Promise<Void> in
            return when(fulfilled: toDelete.map{
                $0.promiseDeleteFrom().then(execute: SkillEntity.promiseToDelete)
            })
        }
    }
    
}

class CKPageableResult<T:CKRecordSyncable> {
    
    var limit: Int = 10
    var desiredKeys: [String]?
    
    internal fileprivate(set) var results: [T] = []
    internal fileprivate(set) var hasNextPage: Bool = true
    internal fileprivate(set) var numberOfFailed: Int = 0
    
    fileprivate var cursor: CKQueryCursor?
    fileprivate var container: CKContainer
    fileprivate var database: CKDatabase
    fileprivate var predicate: NSPredicate
    fileprivate var query: CKQuery
    fileprivate var currentPromise: Promise<[T]>?
    fileprivate var delta: [T] = []
    
    // MARK: - Lifecycle
    init(type: T.Type, predicate: NSPredicate, database: DatabaseType, limit: Int = 10) {
        self.container = CKContainer.default()
        self.database = database == .public ? self.container.publicCloudDatabase : self.container.privateCloudDatabase
        self.predicate = predicate
        self.query = CKQuery(recordType: T.self.recordType, predicate: predicate)
    }
    
    convenience init(type: T.Type, skillsPredicate: SkillsPredicate, database: DatabaseType, limit: Int = 10){
        self.init(type: type, predicate: skillsPredicate.predicate(), database: database, limit: limit)
    }
    
    // MARK: - Public
    func reload() {
        self.results = []
        self.delta = []
        self.cursor = nil
        self.currentPromise = nil
        self.hasNextPage = true
        self.numberOfFailed = 0
    }
    
    func promiseNextPage() -> Promise<[T]> {
        guard self.hasNextPage else {
            return Promise<[T]>(error: CloudError.noData)
        }
        
        guard self.currentPromise == nil else {
            return self.currentPromise!
        }
        
        self.delta = []
        
        self.currentPromise = Promise<[T]> { fulfill,reject in
            DispatchQueue.global().async { [weak self] in
                // Query CloudKit
                guard let operation = self?.operation() else {
                    reject(CommonError.operationFailed as Error)
                    return
                }
                
                operation.recordFetchedBlock = { record in
                    if let object = T(record: record) {
                        self?.results.append(object)
                        self?.delta.append(object)
                    }
                    else {
                        self?.numberOfFailed += 1
                    }
                }
                
                operation.queryCompletionBlock = { cursor,error in
                    if let error = error as NSError? {
                        self?.hasNextPage = false
                        
                        DispatchQueue.main.async {
                            reject(CloudError.fetchError(code: error.code, error: error))
                        }
                    }
                    else {
                        if let cursor = cursor {
                            self?.cursor = cursor
                        }
                        else {
                            self?.hasNextPage = false
                        }
                        
                        self?.currentPromise = nil
                        
                        DispatchQueue.main.async {
                            fulfill(self?.delta ?? [])
                        }
                    }
                }
                
                self?.database.add(operation)
            }
        }
        
        return self.currentPromise!
    }
    
    fileprivate func operation() -> CKQueryOperation {
        if let cursor = self.cursor {
            let operation = CKQueryOperation(cursor: cursor)
            operation.resultsLimit = self.limit
            operation.qualityOfService = .userInteractive
            operation.desiredKeys ?= self.desiredKeys
            return operation
        }
        else {
            let operation = CKQueryOperation(query: query)
            operation.resultsLimit = self.limit
            operation.qualityOfService = .userInteractive
            operation.desiredKeys ?= self.desiredKeys
            return operation
        }
    }
    
}

enum SkillsPredicate {
    
    case anySkill
    case accepted
    case nameLike(String)
    case whenAll([SkillsPredicate])
    case whenAny([SkillsPredicate])
    
    func predicate() -> NSPredicate {
        switch self {
        case .anySkill:
            return NSPredicate(format: "TRUEPREDICATE")
        case .accepted:
            return NSPredicate(format: "accepted = %d", 1)
        case .nameLike(let name):
            return NSPredicate(format: "self contains %@", name)
        case .whenAll(let subpredicates):
            let predicates = subpredicates.map{ $0.predicate() }
            return NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        case .whenAny(let subpredicates):
            let predicates = subpredicates.map{ $0.predicate() }
            return NSCompoundPredicate(orPredicateWithSubpredicates: predicates)
        }
    }
    
}

struct SyncInfo {
    let userID: String
    let skillsCount: Int
    let changeTag: String
    
    init(userRecord: CKRecord) {
        self.userID = userRecord.recordID.recordName
        self.skillsCount = (userRecord.object(forKey: "skillsCount") as? Int) ?? 0
        self.changeTag = userRecord.recordChangeTag ?? ""
    }
 
    init(userID: String, skillsCount: Int, changeTag: String) {
        self.userID = userID
        self.skillsCount = skillsCount
        self.changeTag = changeTag
    }
    
}

enum DatabaseType {
    case `public`
    case `private`
}

enum CloudError: Error {
    case noData
    case wrongAsset
    case notMatchingRecordData
    case unknownError
    case fetchFailed(reason: String)
    case fetchError(code: Int, error: NSError)
    case saveFailed(reason: String)
    case saveError(code: Int, error: NSError)
}
