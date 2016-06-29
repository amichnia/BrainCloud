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

// MARK: - CKRecordSyncable
/// Class implementing CKRecordSyncable can be synced via CloudKit
protocol CKRecordSyncable: CKRecordConvertible, CKRecordMappable {
    
    var recordChangeTag: String? { get set }
    var modified: NSDate? { get set }
    
    func clearTemporaryData()
    
}

// MARK: - Sync single records
extension CKRecordSyncable {
    
    typealias T = Self
    
    // Sync record to database
    func promiseInsertTo(db: DatabaseType = .Private) -> Promise<Self> {
        let container = CloudContainer.sharedContainer
        let database = container.database(db)
        
        return self.promiseInsertTo(database)
        .then { (savedRecord) -> Promise<T> in
            return self.promiseMappingWith(savedRecord) // Update values after save - like source tag
        }
    }
    
    private func promiseInsertTo(database: CKDatabase) -> Promise<CKRecord> {
        // Creating record resulted in creating temporary data at generated file url
        return self.promiseRecord()
        .then(database.promiseSaveRecord)
        .always {
            // So assure, that the temporary data will be always cleared
            self.clearTemporaryData()
        }
    }
    
    func promiseSyncTo(db: DatabaseType = .Private) -> Promise<Self> {
        let container = CloudContainer.sharedContainer
        let database = container.database(db)
        
        return self.promiseSyncTo(database)
            .then { (savedRecord) -> Promise<T> in
                return self.promiseMappingWith(savedRecord) // Update values after save - like source tag
        }
    }
    
    private func promiseSyncTo(database: CKDatabase) -> Promise<CKRecord> {
        // Creating record resulted in creating temporary data at generated file url
        return self.promiseRecord()
        .then(database.promiseUpdateRecord)
        .always {
            // So assure, that the temporary data will be always cleared
            self.clearTemporaryData()
        }
    }

    // Sync record from database
    func promiseSyncFrom(db: DatabaseType = .Private) -> Promise<Self> {
        let container = CloudContainer.sharedContainer
        let database = container.database(db)
        
        return self.promiseSyncFrom(database)
        .then { (savedRecord) -> Promise<T> in
            return self.promiseMappingWith(savedRecord) // Update values with fetched record
        }
    }
    
    private func promiseSyncFrom(database: CKDatabase) -> Promise<CKRecord> {
        guard let recordID = self.recordID else {
            return Promise<CKRecord>(error: CloudError.NotMatchingRecordData)
        }
        
        return database.promiseRecordWithID(recordID)
    }
    
}

// MARK: - CKDatabase extensions
extension CKDatabase {
    
    /**
     Promises to fetch single record. Be aware, that this is low prio operation - use wrappers on CKDatabaseFetchOperation instead
     
     - parameter recordID: ID of record to fetch
     
     - returns: Future CKRecord
     */
    func promiseRecordWithID(recordID: CKRecordID) -> Promise<CKRecord> {
        return Promise<CKRecord> { fulfill,reject in
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
                self.fetchRecordWithID(recordID) { fetchedRecord,error in
                    if let record = fetchedRecord where error == nil {
                        fulfill(record)
                    }
                    else if let error = error {
                        reject(CloudError.FetchError(code: error.code, error: error))
                    }
                    else {
                        reject(CloudError.FetchFailed(reason: "Unknown error occured"))
                    }
                }
            }
        }
    }
    
    /**
     Promises to save single record.
     
     - parameter record: Record to save
     
     - returns: Future saved record
     */
    func promiseSaveRecord(record: CKRecord) -> Promise<CKRecord> {
        return Promise<CKRecord> { fulfill,reject in
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
                self.saveRecord(record) { savedRecord,error in
                    if let savedRecord = savedRecord where error == nil {
                        fulfill(savedRecord)
                    }
                    else if let error = error {
                        reject(CloudError.SaveError(code: error.code, error: error))
                    }
                    else {
                        reject(CloudError.SaveFailed(reason: "Unknown error occured"))
                    }
                }
            }
        }
    }
    
    func promiseUpdateRecord(record: CKRecord) -> Promise<CKRecord> {
        return Promise<CKRecord> { fulfill,reject in
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
                let updateRecordOperation = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
                
                updateRecordOperation.savePolicy = .ChangedKeys
                updateRecordOperation.modifyRecordsCompletionBlock = { savedRecords,_,error in
                    let savedRecord = savedRecords?.first
                    
                    if let savedRecord = savedRecord where error == nil {
                        fulfill(savedRecord)
                    }
                    else if let error = error {
                        reject(CloudError.SaveError(code: error.code, error: error))
                    }
                    else {
                        reject(CloudError.SaveFailed(reason: "Unknown error occured"))
                    }
                }
                
                self.addOperation(updateRecordOperation)
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
    
    func imageForKey(key: String) -> UIImage? {
        if let imageUrl = (self.objectForKey(key) as? CKAsset)?.fileURL, image = UIImage(contentsOfFile: imageUrl.path!) {
            return image
        }
        else {
            return nil
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
