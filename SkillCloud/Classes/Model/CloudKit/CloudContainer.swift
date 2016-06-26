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

struct RecordType {
    static let Skill = "Skill"
}

enum DatabaseType {
    case Public
    case Private
}

/// Cloud container class - encapsulates CK promises and CK Deserters
class CloudContainer {
    // MARK: - Properties
    let container: CKContainer
    let publicDatabase: CKDatabase
    let privateDatabase: CKDatabase
    let userInfo: UserInfo
    
    // MARK: - Initializers
    init() {
        self.container = CKContainer.defaultContainer()
        self.publicDatabase = self.container.publicCloudDatabase
        self.privateDatabase = self.container.privateCloudDatabase
        self.userInfo = UserInfo(container: self.container)
    }
    
    // MARK: - Private
    private func database(type: DatabaseType) -> CKDatabase {
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
                let query = CKQuery(recordType: RecordType.Skill, predicate: predicate)
                
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
    
    func promiseAddSkill(skill: Skill) -> Promise<CKRecordID> {
        return self.userInfo.promiseUserID()
        .then { userRecordID -> Promise<CKRecordID> in
            return skill.promiseAddTo(self.privateDatabase, forUser: userRecordID)
        }
    }
    
}

// MARK: - Skill promise with CKRecord
extension Skill {
    
    class func promiseWithRecord(record: CKRecord) -> Promise<Skill> {
        return Promise<Skill>() { fulfill, reject in
            if let skill = Skill(record: record) {
                fulfill(skill)
            }
            else {
                reject(CloudError.NotMatchingRecordData)
            }
        }
    }
    
}

protocol CKRecordConvertible : class {
    init?(record: CKRecord)
}

enum CloudError: ErrorType {
    case NoData
    case NotMatchingRecordData
    case UnknownError
}