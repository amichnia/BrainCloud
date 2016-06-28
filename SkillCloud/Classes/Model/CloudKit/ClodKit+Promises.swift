//
//  ClodKit+Promises.swift
//  SkillCloud
//
//  Created by Andrzej Michnia on 28/06/16.
//  Copyright © 2016 amichnia. All rights reserved.
//

import Foundation
import UIKit
import CloudKit
import PromiseKit

// MARK: - Cloud Kit Protocols
/// Class implementing CKRecordMappable protocol is valid, to be initialized with CKRecord instance
protocol CKRecordMappable: class {
    
    /**
     Returns new instance of CKRecordMappable class, or nil, if could not map
     
     - parameter record: CKRecord instance to initialize with
     
     - returns: Instance or nil
     */
    init?(record: CKRecord)
    
    func performMappingWith(record: CKRecord) -> Self?
    
}

extension CKRecordMappable {
    
    typealias T = Self
    
    func promiseMappingWith(record: CKRecord) -> Promise<T> {
        return Promise<T>() { fulfill, reject in
            if let object = self.performMappingWith(record) {
                fulfill(object)
            }
            else {
                reject(CloudError.NotMatchingRecordData)
            }
        }
    }
    
    static func promiseWithRecord(record: CKRecord) -> Promise<T> {
        return Promise<T>() { fulfill, reject in
            if let object = T(record: record) {
                fulfill(object)
            }
            else {
                reject(CloudError.NotMatchingRecordData)
            }
        }
    }
    
}

// MARK: - CKRecordConvertible
/// Class implementing CKRecordConvertible protocol has means to be used to initialize new CKRecord instance
protocol CKRecordConvertible: class {
    
    var recordName: String? { get set }
    
    var recordID: CKRecordID? { get }
    static var recordType: String { get }
    
    func recordRepresentation() -> CKRecord?
    
}

extension CKRecordConvertible {
    
    var recordID: CKRecordID? {
        return self.recordName == nil ? nil : CKRecordID(recordName: self.recordName!)
    }
    
    var recordType: String {
        return Self.recordType
    }
    
    static var recordType: String {
        return String(Self)
    }
    
    func promiseRecord() -> Promise<CKRecord> {
        return Promise<CKRecord> { fulfill,reject in
            if let record = self.recordRepresentation() {
                fulfill(record)
            }
            else {
                reject(CloudError.NotMatchingRecordData)
            }
        }
    }
    
}

// MARK: - CKRecord extensions
extension CKRecord {
    
    convenience init(recordConvertible: CKRecordConvertible){
        if let recordID = recordConvertible.recordID {
            self.init(recordType: recordConvertible.recordType, recordID: recordID)
        }
        else {
            self.init(recordType: recordConvertible.recordType)
        }
    }
    
    static func promise(recordConvertible: CKRecordConvertible) -> Promise<CKRecord> {
        return Promise<CKRecord>() { fulfill,reject in
            fulfill(CKRecord(recordConvertible: recordConvertible))
        }
    }
    
}

// MARK: - CKAsset extensions
extension CKAsset {
    
    /**
     Initializes new CKAsset with given UIImage, as jpg
     
     - parameter image: UIImage instance
     
     - throws: CloudError.WrongAsset if could not create JPG representation, or NSGileManager errors regarding writing to generated url
     
     - returns: Initialized image asset
     */
    static func assetWithImage(image: UIImage) throws -> CKAsset {
        guard let imageData = UIImageJPEGRepresentation(image, 0.9) else {
            throw CloudError.WrongAsset
        }

        let fileUrl = generateFileURL("jpg")
        try imageData.writeToURL(fileUrl, options: .AtomicWrite)
        let imageAsset = CKAsset(fileURL: fileUrl)
        
        return imageAsset
    }
    
    /**
     Potentially unsafe - call ONLY on self made assets for upload purposes
     */
    func clearTemporaryData() {
        do {
            try NSFileManager.defaultManager().removeItemAtURL(self.fileURL)
        }
        catch {
            DDLogError("Couldn't clear data after performed upload! Error: \(error)")
        }
    }
    
}

// MARK: - CKRecordSyncable
/// Class implementing CKRecordSyncable can be synced via CloudKit
protocol CKRecordSyncable: CKRecordConvertible, CKRecordMappable {
    
    var recordChangeTag: String? { get set }
    var modified: NSDate? { get set }
    
    func clearTemporaryData()
    
}

extension CKRecordSyncable {
    
    typealias T = Self
    
    // Sync record to
    func promiseSyncTo(db: DatabaseType) -> Promise<Self> {
        let container = CloudContainer()
        let database = container.database(db)
        
        return container.userInfo.promiseUserID()
        .then { userRecordID -> Promise<CKRecord> in
            return self.promiseSyncTo(database, forUser: userRecordID)  // sync to cloud kit
        }
        .then { (savedRecord) -> Promise<T> in
            return self.promiseMappingWith(savedRecord) // Gather source tag
        }
    }
    
    private func promiseSyncTo(database: CKDatabase, forUser userRecordId: CKRecordID) -> Promise<CKRecord> {
        return Promise<CKRecord> { fulfill,reject in
            guard let record = self.recordRepresentation() else {
                reject(CloudError.NotMatchingRecordData)
                return
            }
            
            database.saveRecord(record) { savedRecord,error in
                // Clear temporary data
                self.clearTemporaryData()
                
                // Process success
                if let savedRecord = savedRecord where error == nil {
                    fulfill(savedRecord)
                }
                // Process failure
                else {
                    reject(error ?? CloudError.UnknownError)
                }
            }
            
        }
    }

    // Sync record from
    private func promiseSyncFrom(database: CKDatabase) -> Promise<CKRecord> {
        return Promise<CKRecord> { fulfill,reject in
            guard let recordID = self.recordID else {
                reject(CloudError.NotMatchingRecordData)
                return
            }
            
//            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
//                let predicate = NSPredicate(value: true)
//                let query = CKQuery(recordType: Skill.recordType, predicate: predicate)
//                
//                self.database(database).performQuery(query, inZoneWithID: nil) { records, error in
//                    if let error = error {
//                        reject(error)
//                    }
//                    else if let records = records {
//                        let skillsPromises = records.map{ Skill.promiseWithRecord($0) }
//                        
//                        when(skillsPromises).then { skills -> Void in
//                            fulfill(skills)
//                        }
//                    }
//                    else {
//                        reject(CloudError.NoData)
//                    }
//                }
//            }
        }
    }
    
    
    // Helpers
    
}