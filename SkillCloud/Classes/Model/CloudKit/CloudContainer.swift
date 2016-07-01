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
    // TODO: Remove it from there
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
