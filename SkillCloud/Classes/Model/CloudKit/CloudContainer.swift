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

/// Cloud container class - encapsulates CK promises and CK Deserters
class CloudContainer {
    
    // MARK: - Big bad singleton
    static var sharedContainer: CloudContainer = CloudContainer()
    
    // MARK: - Properties
    let container: CKContainer
    let publicDatabase: CKDatabase
    let privateDatabase: CKDatabase
    
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
    
    func promiseSelfSkills() -> Promise<[Skill]> {
        return self.promiseAllSkillsFromDatabase(.Private)
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
