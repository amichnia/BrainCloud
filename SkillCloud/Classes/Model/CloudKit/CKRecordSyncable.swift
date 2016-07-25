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
        
        return self.promiseInsertTo(database, type: db)
        .then { (savedRecord) -> Promise<T> in
            return self.promiseMappingWith(savedRecord) // Update values after save - like source tag
        }
        .then { object -> T in
            return object
        }
    }
    
    private func promiseInsertTo(database: CKDatabase, type: DatabaseType = .Private) -> Promise<CKRecord> {
        // Creating record resulted in creating temporary data at generated file url
        return self.promiseRecord()
        .then{ record -> CKRecord in
            if type == .Public {
                record.setObject(0, forKey: "accepted")
            }
            return record
        }
        .then(database.promiseInsertRecord)
        .always {
            // So assure, that the temporary data will be always cleared
            self.clearTemporaryData()
        }
    }
    
    func promiseSyncTo(db: DatabaseType = .Private) -> Promise<Self> {
        let container = CloudContainer.sharedContainer
        let database = container.database(db)
        
        return self.promiseSyncTo(database, type: db)
        .then { (savedRecord) -> Promise<T> in
            return self.promiseMappingWith(savedRecord) // Update values after save - like source tag
        }
        .then { object -> T in
            return object
        }
    }
    
    private func promiseSyncTo(database: CKDatabase, type: DatabaseType = .Private) -> Promise<CKRecord> {
        // Creating record resulted in creating temporary data at generated file url
        return self.promiseRecord()
        .then{ record -> CKRecord in
            if type == .Public {
                record.setObject(0, forKey: "accepted")
            }
            return record
        }
        .then(database.promiseUpdateRecord)
        .always {
            // So assure, that the temporary data will be always cleared
            self.clearTemporaryData()
        }
    }
    
    func promiseDeleteFrom(db: DatabaseType = .Private) -> Promise<Self> {
        let container = CloudContainer.sharedContainer
        let database = container.database(db)
        
        return self.promiseDeleteFrom(database).then{ return self }
    }
    
    private func promiseDeleteFrom(database: CKDatabase) -> Promise<Void> {
        guard let recordID = self.recordID else {
            return Promise<Void>(error: CommonError.NotEnoughData)
        }
        
        return database.promiseDeleteRecord(recordID)
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
            return object
        }
    }
    
    private func promiseSyncFrom(database: CKDatabase) -> Promise<CKRecord> {
        guard let recordID = self.recordID else {
            return Promise<CKRecord>(error: CloudError.NotMatchingRecordData)
        }
        
        return database.promiseRecordWithID(recordID)
    }
    
    static func promiseAll(db: DatabaseType = .Private) -> Promise<[Self]> {
        let container = CloudContainer.sharedContainer
        let database = container.database(db)
        
        return self.promiseAllFrom(database)
    }
    
    private static func promiseAllFrom(database: CKDatabase) -> Promise<[Self]> {
        return database.promiseAllWith()
    }
    
}

// MARK: - Sync multiple records
extension Array where Element: CKRecordSyncable {
    
    typealias T = Element.Type
    
    func promiseRecords() -> Promise<[CKRecord]> {
        return when(self.map { $0.promiseRecord() })
    }
    
    func promiseInsertTo(database: CKDatabase) -> Promise<[Element]> {
        // Creating record resulted in creating temporary data at generated file url
        return self.promiseRecords()
        .then(database.promiseInsertRecords)
        .then { savedRecords -> [Element] in
            savedRecords.mapExisting { Element(record: $0) }
        }
        .always {
            // So assure, that the temporary data will be always cleared
            self.forEach{ $0.clearTemporaryData() }
        }

    }
    
    func promiseSyncTo(database: CKDatabase) -> Promise<[Element]> {
        // Creating record resulted in creating temporary data at generated file url
        return self.promiseRecords()
        .then(database.promiseUpdateRecords)
        .then { savedRecords -> [Element] in
            savedRecords.mapExisting { Element(record: $0) }
        }
        .always {
            // So assure, that the temporary data will be always cleared
            self.forEach{ $0.clearTemporaryData() }
        }
    }
    
}
