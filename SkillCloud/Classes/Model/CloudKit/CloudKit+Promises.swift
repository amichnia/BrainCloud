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
    func promiseRecordWithID(_ recordID: CKRecordID) -> Promise<CKRecord> {
        return Promise<CKRecord> { fulfill,reject in
            DispatchQueue.global().async {
                self.fetch(withRecordID: recordID) { fetchedRecord,error in
                    if let record = fetchedRecord, error == nil {
                        fulfill(record)
                    }
                    else if let error = error as NSError? {
                        reject(CloudError.fetchError(code: error.code, error: error))
                    }
                    else {
                        reject(CloudError.fetchFailed(reason: "Unknown error occured"))
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
    func promiseInsertRecord(_ record: CKRecord) -> Promise<CKRecord> {
        return Promise<CKRecord> { fulfill,reject in
            DispatchQueue.global().async {
                self.save(record) { savedRecord,error in
                    if let savedRecord = savedRecord, error == nil {
                        fulfill(savedRecord)
                    }
                    else if let error = error as NSError? {
                        reject(CloudError.saveError(code: error.code, error: error))
                    }
                    else {
                        reject(CloudError.saveFailed(reason: "Unknown error occured"))
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
    func promiseUpdateRecord(_ record: CKRecord) -> Promise<CKRecord> {
        return Promise<CKRecord> { fulfill,reject in
            DispatchQueue.global().async {
                let updateRecordOperation = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
                
                updateRecordOperation.savePolicy = .changedKeys
                updateRecordOperation.modifyRecordsCompletionBlock = { savedRecords,_,error in
                    let savedRecord = savedRecords?.first
                    
                    if let savedRecord = savedRecord, error == nil {
                        fulfill(savedRecord)
                    }
                    else if let error = error as NSError? {
                        reject(CloudError.saveError(code: error.code, error: error))
                    }
                    else {
                        reject(CloudError.saveFailed(reason: "Unknown error occured"))
                    }
                }
                
                self.add(updateRecordOperation)
            }
        }
    }
    
    /**
     Promises to delete record by ID
     
     - parameter recordID: id of record to delete
     
     - returns: Future without that record
     */
    func promiseDeleteRecord(_ recordID: CKRecordID) -> Promise<Void> {
        return Promise<Void> { fulfill,reject in
            DispatchQueue.global().async {
                self.delete(withRecordID: recordID) { deletedID,error in
                    if error == nil {
                        fulfill()
                    }
                    else {
                        reject(error ?? CommonError.unknownError)
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
    func promiseInsertRecords(_ records: [CKRecord]) -> Promise<[CKRecord]> {
        guard records.count > 0 else {
            return Promise<[CKRecord]>(value: [])
        }
        
        return Promise<[CKRecord]> { fulfill,reject in
            DispatchQueue.global().async {
                let insertRecordsOperation = CKModifyRecordsOperation(recordsToSave: records, recordIDsToDelete: nil)
                
                insertRecordsOperation.savePolicy = .ifServerRecordUnchanged // Only save non existing
                insertRecordsOperation.modifyRecordsCompletionBlock = { savedRecords,_,error in
                    if let savedRecords = savedRecords, error == nil {
                        fulfill(savedRecords)
                    }
                    else if let error = error as NSError? {
                        reject(CloudError.saveError(code: error.code, error: error))
                    }
                    else {
                        reject(CloudError.saveFailed(reason: "Unknown error occured"))
                    }
                }
                
                self.add(insertRecordsOperation)
            }
        }
    }
    
    /**
     Promisese to update several records. Will insert new records as well.
     
     - parameter records: Records to update
     
     - returns: Future saved records
     */
    func promiseUpdateRecords(_ records: [CKRecord]) -> Promise<[CKRecord]> {
        guard records.count > 0 else {
            return Promise<[CKRecord]>(value: [])
        }
        
        return Promise<[CKRecord]> { fulfill,reject in
            DispatchQueue.global().async {
                let updateRecordsOperation = CKModifyRecordsOperation(recordsToSave: records, recordIDsToDelete: nil)
                
                updateRecordsOperation.savePolicy = .allKeys // Update all keys
                updateRecordsOperation.modifyRecordsCompletionBlock = { savedRecords,_,error in
                    if let savedRecords = savedRecords, error == nil {
                        fulfill(savedRecords)
                    }
                    else if let error = error as NSError? {
                        reject(CloudError.saveError(code: error.code, error: error))
                    }
                    else {
                        reject(CloudError.saveFailed(reason: "Unknown error occured"))
                    }
                }
                
                self.add(updateRecordsOperation)
            }
        }
    }
    
    // Fetching
    
    /**
     Promises to fetch new versions of provided records
     
     - parameter records: Records to refetch
     
     - returns: Future of records
     */
    func promiseFetchRecords(_ records: [CKRecord]) -> Promise<[CKRecord]> {
        guard records.count > 0 else {
            return Promise<[CKRecord]>(value: [])
        }
        
        return self.promiseFetchRecordsWithIDS(records.map{ $0.recordID })
    }
    
    /**
     Promise to fetch records with given ID's
     
     - parameter recordIDS: ID's of records to fetch
     
     - returns: Future of records
     */
    func promiseFetchRecordsWithIDS(_ recordIDS: [CKRecordID]) -> Promise<[CKRecord]> {
        return Promise<[CKRecord]> { fulfill,reject in
            DispatchQueue.global().async {
                let fetchOperation = CKFetchRecordsOperation()
                fetchOperation.recordIDs = recordIDS
                
                // TODO: Report progress by NSProgress
                fetchOperation.fetchRecordsCompletionBlock = { recorsByID,error in
                    if let savedRecords = recorsByID?.values, error == nil {
                        fulfill(savedRecords.map({ $0 }))
                    }
                    else if let error = error as NSError? {
                        reject(CloudError.fetchError(code: error.code, error: error))
                    }
                    else {
                        reject(CloudError.fetchFailed(reason: "Unknown error occured"))
                    }
                }
                
                self.add(fetchOperation)
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
    func promiseAllRecordsWith(_ type: String, andPredicate: NSPredicate? = nil) -> Promise<[CKRecord]> {
        return Promise<[CKRecord]>() { fulfill, reject in
            DispatchQueue.global().async {
                let predicate = andPredicate ?? NSPredicate(value: true)
                let query = CKQuery(recordType: type, predicate: predicate)
                
                self.perform(query, inZoneWith: nil) { records, error in
                    if let savedRecords = records, error == nil {
                        fulfill(savedRecords)
                    }
                    else if let error = error as NSError? {
                        reject(CloudError.fetchError(code: error.code, error: error))
                    }
                    else {
                        reject(CloudError.fetchFailed(reason: "Unknown error occured"))
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
    func promiseAllWith<T:CKRecordSyncable>(_ predicate: NSPredicate? = nil) -> Promise<[T]> {
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
    
    static func promise(_ recordConvertible: CKRecordConvertible) -> Promise<CKRecord> {
        return Promise<CKRecord>() { fulfill,reject in
            fulfill(CKRecord(recordConvertible: recordConvertible))
        }
    }
    
    func imageForKey(_ key: String) -> UIImage? {
        if let imageUrl = (self.object(forKey: key) as? CKAsset)?.fileURL, let image = UIImage(contentsOfFile: imageUrl.path) {
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
    static func assetWithImage(_ image: UIImage) throws -> CKAsset {
        guard let imageData = UIImageJPEGRepresentation(image, 0.9) else {
            throw CloudError.wrongAsset
        }
        
        let fileUrl = FileManager.generateFileURL("jpg")
        try imageData.write(to: fileUrl, options: .atomicWrite)
        let imageAsset = CKAsset(fileURL: fileUrl)
        
        return imageAsset
    }
    
    /**
     Potentially unsafe - call ONLY on self made assets for upload purposes
     */
    func clearTemporaryData() {
        do {
            try FileManager.default.removeItem(at: self.fileURL)
        }
        catch {
            DDLogError("Couldn't clear data after performed upload! Error: \(error)")
        }
    }
    
}
