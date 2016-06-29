//
//  CKRecordSyncable.swift
//  SkillCloud
//
//  Created by Andrzej Michnia on 30/06/16.
//  Copyright © 2016 amichnia. All rights reserved.
//

import Foundation
import UIKit
import CloudKit
import PromiseKit

// MARK: - CKRecordSyncable
/// Class implementing CKRecordSyncable can be synced via CloudKit
protocol CKRecordSyncable: CKRecordConvertible, CKRecordMappable {
    
    var recordChangeTag: String? { get set }
    var modified: NSDate? { get set }
    var offline: Bool { get set }
    
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
            .then { object -> T in
                object.offline = false
                return object
        }
    }
    
    private func promiseInsertTo(database: CKDatabase) -> Promise<CKRecord> {
        // Creating record resulted in creating temporary data at generated file url
        return self.promiseRecord()
            .then(database.promiseInsertRecord)
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
            .then { object -> T in
                object.offline = false
                return object
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
            .then { object -> T in
                object.offline = false
                return object
        }
    }
    
    private func promiseSyncFrom(database: CKDatabase) -> Promise<CKRecord> {
        guard let recordID = self.recordID else {
            return Promise<CKRecord>(error: CloudError.NotMatchingRecordData)
        }
        
        return database.promiseRecordWithID(recordID)
    }
    
}

// MARK: - Sync multiple records
extension Array where Element: CKRecordSyncable {
    
    typealias T = Element.Type
    
    func promiseRecords() -> Promise<[CKRecord]> {
        return when(self.map { $0.promiseRecord() })
    }
    
    private func promiseInsertTo(database: CKDatabase) -> Promise<[CKRecord]> {
        // Creating record resulted in creating temporary data at generated file url
        return self.promiseRecords()
            .then(database.promiseInsertRecords)
            .always {
                // So assure, that the temporary data will be always cleared
                self.forEach{ $0.clearTemporaryData() }
        }
    }
    
    private func promiseSyncTo(database: CKDatabase) -> Promise<[CKRecord]> {
        // Creating record resulted in creating temporary data at generated file url
        return self.promiseRecords()
            .then(database.promiseUpdateRecords)
            .always {
                // So assure, that the temporary data will be always cleared
                self.forEach{ $0.clearTemporaryData() }
        }
    }
    
}
