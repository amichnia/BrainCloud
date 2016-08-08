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
    
    var lastSyncDate: NSDate? {
        get {
            return NSUserDefaults.standardUserDefaults().objectForKey(DefaultsLastSyncTimestampKey) as? NSDate
        }
        set {
            if newValue == nil {
                NSUserDefaults.standardUserDefaults().removeObjectForKey(DefaultsLastSyncTimestampKey)
            }
            else {
                NSUserDefaults.standardUserDefaults().setObject(newValue!, forKey: DefaultsLastSyncTimestampKey)
            }
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    // MARK: - Private properties
    private var userRecordID : CKRecordID!
    private var contacts = [AnyObject]()
    
    // MARK: - Initializers
    init() {
        self.container = CKContainer.defaultContainer()
        self.publicDatabase = self.container.publicCloudDatabase
        self.privateDatabase = self.container.privateCloudDatabase
    }
    
    // MARK: - Private
    func database(type: DatabaseType) -> CKDatabase {
        switch type {
        case .Private:
            return self.privateDatabase
        case .Public:
            return self.publicDatabase
        }
    }
    
    // MARK: - Public promises
    // TODO: Remove it from there? Refactoring in v1.1
    func promiseAllSkillsFromDatabase(database: DatabaseType) -> Promise<[Skill]> {
        return Promise<[Skill]>() { fulfill, reject in
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
                let predicate = NSPredicate(value: true)
                let query = CKQuery(recordType: Skill.recordType, predicate: predicate)
                
                self.database(database).performQuery(query, inZoneWithID: nil) { records, error in
                    if let error = error {
                        reject(error)
                    }
                    else if let records = records {
                        let skillsPromises = records.map{ Skill.promiseWithRecord($0) }
                        
                        when(skillsPromises).then { skills -> Void in
                            fulfill(skills)
                        }
                    }
                    else {
                        reject(CloudError.NoData)
                    }
                }
            }
        }
    }
    
    func promiseAllSkillsWithPredicate(predicate: NSPredicate, fromDatabase database: DatabaseType) -> Promise<[Skill]> {
        return Promise<[Skill]>() { fulfill, reject in
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
                let query = CKQuery(recordType: Skill.recordType, predicate: predicate)
                
                self.database(database).performQuery(query, inZoneWithID: nil) { records, error in
                    if let error = error {
                        reject(error)
                    }
                    else if let records = records {
                        let skillsPromises = records.map{ Skill.promiseWithRecord($0) }
                        
                        when(skillsPromises).then { skills -> Void in
                            fulfill(skills)
                        }
                    }
                    else {
                        reject(CloudError.NoData)
                    }
                }
            }
        }
    }
    
    
    
    // MARK: - Sync promises
    func promiseUserID() -> Promise<CKRecordID> {
        guard self.userRecordID == nil else {
            return Promise<CKRecordID>(self.userRecordID)
        }
        
        return Promise<CKRecordID>() { fulfill,reject in
            self.container.fetchUserRecordIDWithCompletionHandler() { recordID, error in
                if let recordID = recordID where error == nil {
                    self.userRecordID = recordID
                    fulfill(recordID)
                }
                else {
                    reject(error ?? CloudError.UnknownError)
                }
            }
        }
    }
    
    func promiseUserRecord() -> Promise<CKRecord> {
        return self.promiseUserID().then(self.publicDatabase.promiseRecordWithID)
    }
    
    func promiseSyncInfo() -> Promise<SyncInfo> {
        return self.promiseUserRecord().then { SyncInfo(userRecord: $0) }
    }
    
    func promiseSync() -> Promise<Void> {
        return self.promiseSyncTo().then(self.promiseSyncFrom)
    }
    
    func promiseSyncFrom() -> Promise<Void> {
        let predicate: NSPredicate? = {
            if let lastSyncDate = self.lastSyncDate {
                return NSPredicate(format: "modificationDate >= %@", lastSyncDate)
            }
            else {
                return nil
            }
        }()
        
        let syncDate = NSDate()
        
        return self.privateDatabase.promiseAllWith(predicate)
        .then(on: dispatch_get_main_queue()) { (skills: [Skill]) -> Promise<[SkillEntity]> in
            return when(skills.map(SkillEntity.promiseToUpdate))
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
            return when(skills.map{
                $0.promiseSyncTo().then(SkillEntity.promiseToUpdate)
            })
        }
        .then { savedEntities -> Void in
            print("Uploaded \(savedEntities.count) entities")
        }
        .then(Skill.fetchAllToDelete)
        .then { toDelete -> Promise<Void> in
            return when(toDelete.map{
                $0.promiseDeleteFrom().then(SkillEntity.promiseToDelete)
            })
        }
    }
    
}

class CKPageableResult<T:CKRecordSyncable> {
    
    var limit: Int = 10
    var desiredKeys: [String]?
    
    internal private(set) var results: [T] = []
    internal private(set) var hasNextPage: Bool = true
    internal private(set) var numberOfFailed: Int = 0
    
    private var cursor: CKQueryCursor?
    private var container: CKContainer
    private var database: CKDatabase
    private var predicate: NSPredicate
    private var query: CKQuery
    private var currentPromise: Promise<[T]>?
    private var delta: [T] = []
    
    // MARK: - Lifecycle
    init(type: T.Type, predicate: NSPredicate, database: DatabaseType, limit: Int = 10) {
        self.container = CKContainer.defaultContainer()
        self.database = database == .Public ? self.container.publicCloudDatabase : self.container.privateCloudDatabase
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
            return Promise<[T]>(error: CloudError.NoData)
        }
        
        guard self.currentPromise == nil else {
            return self.currentPromise!
        }
        
        self.delta = []
        
        self.currentPromise = Promise<[T]> { fulfill,reject in
            let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
            dispatch_async(dispatch_get_global_queue(priority, 0)) { [weak self] in
                // Query CloudKit
                guard let operation = self?.operation() else {
                    reject(CommonError.OperationFailed)
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
                    if let error = error {
                        self?.hasNextPage = false
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            reject(CloudError.FetchError(code: error.code, error: error))
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
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            fulfill(self?.delta ?? [])
                        }
                    }
                }
                
                self?.database.addOperation(operation)
            }
        }
        
        return self.currentPromise!
    }
    
    private func operation() -> CKQueryOperation {
        if let cursor = self.cursor {
            let operation = CKQueryOperation(cursor: cursor)
            operation.resultsLimit = self.limit
            operation.desiredKeys ?= self.desiredKeys
            return operation
        }
        else {
            let operation = CKQueryOperation(query: query)
            operation.resultsLimit = self.limit
            operation.desiredKeys ?= self.desiredKeys
            return operation
        }
    }
    
}

enum SkillsPredicate {
    
    case AnySkill
    case Accepted
    case NameLike(String)
    case WhenAll([SkillsPredicate])
    case WhenAny([SkillsPredicate])
    
    func predicate() -> NSPredicate {
        switch self {
        case .AnySkill:
            return NSPredicate(format: "TRUEPREDICATE")
        case .Accepted:
            return NSPredicate(format: "accepted = %d", 1)
        case .NameLike(let name):
            return NSPredicate(format: "self contains %@", name)
        case .WhenAll(let subpredicates):
            let predicates = subpredicates.map{ $0.predicate() }
            return NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        case .WhenAny(let subpredicates):
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
        self.skillsCount = (userRecord.objectForKey("skillsCount") as? Int) ?? 0
        self.changeTag = userRecord.recordChangeTag ?? ""
    }
 
    init(userID: String, skillsCount: Int, changeTag: String) {
        self.userID = userID
        self.skillsCount = skillsCount
        self.changeTag = changeTag
    }
    
}

enum DatabaseType {
    case Public
    case Private
}

enum CloudError: ErrorType {
    case NoData
    case WrongAsset
    case NotMatchingRecordData
    case UnknownError
    case FetchFailed(reason: String)
    case FetchError(code: Int, error: NSError)
    case SaveFailed(reason: String)
    case SaveError(code: Int, error: NSError)
}
