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
    
    func promiseAddSkill(skill: Skill) -> Promise<CKRecordID> {
        return self.userInfo.promiseUserID()
        .then { userRecordID -> Promise<CKRecordID> in
            return skill.promiseAddTo(self.privateDatabase, forUser: userRecordID)
        }
    }
    
    func promiseImageAssetsForSkill(skill: Skill, fromDatabase database: DatabaseType) -> Promise<[ImageAsset]> {
        return Promise<[ImageAsset]> { fulfill,reject in
            guard let record = skill.recordRepresentation() else {
                reject(CloudError.FetchError(reason: "No record fetched"))
                return
            }
            
            skill.clearTemporaryData()
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
                let predicate = NSPredicate(format: "skill = %@", record)
                let query = CKQuery(recordType: ImageAsset.recordType, predicate: predicate)
                
                self.database(database).performQuery(query, inZoneWithID: nil) { records, error in
                    if let error = error {
                        reject(error)
                    }
                    else if let records = records {
                        let promises = records.map{ ImageAsset.promiseWithRecord($0) }
                        
                        when(promises).then { assets -> Void in
                            fulfill(assets)
                        }
                    }
                    else {
                        reject(CloudError.NoData)
                    }
                }
            }
        }
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
    case FetchError(reason: String)
}
