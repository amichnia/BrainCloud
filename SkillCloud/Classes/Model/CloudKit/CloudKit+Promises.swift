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

// MARK: - CKDatabase extensions
extension CKDatabase {
    
    // Single
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
     Promises to insert single record.
     
     - parameter record: Record to insert
     
     - returns: Future saved record
     */
    func promiseInsertRecord(record: CKRecord) -> Promise<CKRecord> {
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
    
    /**
     Promises to update single existing record.
     
     - parameter record: Record to update
     
     - returns: Future saved record
     */
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
    
    /**
     Promises to delete record by ID
     
     - parameter recordID: id of record to delete
     
     - returns: Future without that record
     */
    func promiseDeleteRecord(recordID: CKRecordID) -> Promise<Void> {
        return Promise<Void> { fulfill,reject in
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
                self.deleteRecordWithID(recordID) { deletedID,error in
                    if error == nil {
                        fulfill()
                    }
                    else {
                        reject(error ?? CommonError.UnknownError)
                    }
                }
            }
        }
    }
    
}


extension CKDatabase {
    
    // Multiple
    /**
     Promises to insert several records
     
     - parameter records: Records to insert
     
     - returns: Future saved records
     */
    func promiseInsertRecords(records: [CKRecord]) -> Promise<[CKRecord]> {
        guard records.count > 0 else {
            return Promise<[CKRecord]>([])
        }
        
        return Promise<[CKRecord]> { fulfill,reject in
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
                let insertRecordsOperation = CKModifyRecordsOperation(recordsToSave: records, recordIDsToDelete: nil)
                
                insertRecordsOperation.savePolicy = .IfServerRecordUnchanged // Only save non existing
                insertRecordsOperation.modifyRecordsCompletionBlock = { savedRecords,_,error in
                    if let savedRecords = savedRecords where error == nil {
                        fulfill(savedRecords)
                    }
                    else if let error = error {
                        reject(CloudError.SaveError(code: error.code, error: error))
                    }
                    else {
                        reject(CloudError.SaveFailed(reason: "Unknown error occured"))
                    }
                }
                
                self.addOperation(insertRecordsOperation)
            }
        }
    }
    
    /**
     Promisese to update several records. Will insert new records as well.
     
     - parameter records: Records to update
     
     - returns: Future saved records
     */
    func promiseUpdateRecords(records: [CKRecord]) -> Promise<[CKRecord]> {
        guard records.count > 0 else {
            return Promise<[CKRecord]>([])
        }
        
        return Promise<[CKRecord]> { fulfill,reject in
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
                let updateRecordsOperation = CKModifyRecordsOperation(recordsToSave: records, recordIDsToDelete: nil)
                
                updateRecordsOperation.savePolicy = .AllKeys // Update all keys
                updateRecordsOperation.modifyRecordsCompletionBlock = { savedRecords,_,error in
                    if let savedRecords = savedRecords where error == nil {
                        fulfill(savedRecords)
                    }
                    else if let error = error {
                        reject(CloudError.SaveError(code: error.code, error: error))
                    }
                    else {
                        reject(CloudError.SaveFailed(reason: "Unknown error occured"))
                    }
                }
                
                self.addOperation(updateRecordsOperation)
            }
        }
    }
    
    // Fetching
    
    /**
     Promises to fetch new versions of provided records
     
     - parameter records: Records to refetch
     
     - returns: Future of records
     */
    func promiseFetchRecords(records: [CKRecord]) -> Promise<[CKRecord]> {
        guard records.count > 0 else {
            return Promise<[CKRecord]>([])
        }
        
        return self.promiseFetchRecordsWithIDS(records.map{ $0.recordID })
    }
    
    /**
     Promise to fetch records with given ID's
     
     - parameter recordIDS: ID's of records to fetch
     
     - returns: Future of records
     */
    func promiseFetchRecordsWithIDS(recordIDS: [CKRecordID]) -> Promise<[CKRecord]> {
        return Promise<[CKRecord]> { fulfill,reject in
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
                let fetchOperation = CKFetchRecordsOperation()
                fetchOperation.recordIDs = recordIDS
                
                // TODO: Report progress by NSProgress
                fetchOperation.fetchRecordsCompletionBlock = { recorsByID,error in
                    if let savedRecords = recorsByID?.values where error == nil {
                        fulfill(savedRecords.map({ $0 }))
                    }
                    else if let error = error {
                        reject(CloudError.FetchError(code: error.code, error: error))
                    }
                    else {
                        reject(CloudError.FetchFailed(reason: "Unknown error occured"))
                    }
                }
                
                self.addOperation(fetchOperation)
            }
        }
    }
    
    // Querying
    
    /**
     Promises all records, with given record type and matching predicate
     
     - parameter type:         Record type
     - parameter andPredicate: Predicate to match
     
     - returns: Future of records
     */
    func promiseAllRecordsWith(type: String, andPredicate: NSPredicate? = nil) -> Promise<[CKRecord]> {
        return Promise<[CKRecord]>() { fulfill, reject in
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
                let predicate = andPredicate ?? NSPredicate(value: true)
                let query = CKQuery(recordType: type, predicate: predicate)
                
                self.performQuery(query, inZoneWithID: nil) { records, error in
                    if let savedRecords = records where error == nil {
                        fulfill(savedRecords)
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
     Promise all records into syncable instances, that matches given predicate
     
     - parameter predicate: Predicate (of any)
     
     - returns: Future of syncable instances
     */
    func promiseAllWith<T:CKRecordSyncable>(predicate: NSPredicate? = nil) -> Promise<[T]> {
        return self.promiseAllRecordsWith(T.recordType, andPredicate: predicate)
        .then { records -> [T] in
            return records.mapExisting{ T(record: $0) }
        }
    }
    
}

// MARK: - Records batch
// TODO: Batching results

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
