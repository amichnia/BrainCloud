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
    var modified: Date? { get set }
    var offline: Bool { get set }
    
    func clearTemporaryData()
    
}

// MARK: - Sync single records
extension CKRecordSyncable {
    
    typealias T = Self
    
    // Sync record to database
    func promiseInsertTo(_ db: DatabaseType = .private) -> Promise<Self> {
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
    
    fileprivate func promiseInsertTo(_ database: CKDatabase, type: DatabaseType = .private) -> Promise<CKRecord> {
        // Creating record resulted in creating temporary data at generated file url
        return self.promiseRecord()
        .then{ record -> CKRecord in
            if type == .public {
                record.setObject(NSNumber(booleanLiteral: false), forKey: "accepted")
            }
            return record
        }
        .then(execute: database.promiseInsertRecord)
        .always {
            // So assure, that the temporary data will be always cleared
            self.clearTemporaryData()
        }
    }
    
    func promiseSyncTo(_ db: DatabaseType = .private) -> Promise<Self> {
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
    
    fileprivate func promiseSyncTo(_ database: CKDatabase, type: DatabaseType = .private) -> Promise<CKRecord> {
        // Creating record resulted in creating temporary data at generated file url
        return self.promiseRecord()
        .then{ record -> CKRecord in
            if type == .public {
                record.setObject(NSNumber(booleanLiteral: false), forKey: "accepted")
            }
            return record
        }
        .then(execute: database.promiseUpdateRecord)
        .always {
            // So assure, that the temporary data will be always cleared
            self.clearTemporaryData()
        }
    }
    
    func promiseDeleteFrom(_ db: DatabaseType = .private) -> Promise<Self> {
        let container = CloudContainer.sharedContainer
        let database = container.database(db)
        
        return self.promiseDeleteFrom(database).then{ return self }
    }
    
    fileprivate func promiseDeleteFrom(_ database: CKDatabase) -> Promise<Void> {
        guard let recordID = self.recordID else {
            return Promise<Void>(error: CommonError.notEnoughData)
        }
        
        return database.promiseDeleteRecord(recordID)
    }
    
    // Sync record from database
    func promiseSyncFrom(_ db: DatabaseType = .private) -> Promise<Self> {
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
    
    fileprivate func promiseSyncFrom(_ database: CKDatabase) -> Promise<CKRecord> {
        guard let recordID = self.recordID else {
            return Promise<CKRecord>(error: CloudError.notMatchingRecordData)
        }
        
        return database.promiseRecordWithID(recordID)
    }
    
    static func promiseAll(_ db: DatabaseType = .private) -> Promise<[Self]> {
        let container = CloudContainer.sharedContainer
        let database = container.database(db)
        
        return self.promiseAllFrom(database)
    }
    
    fileprivate static func promiseAllFrom(_ database: CKDatabase) -> Promise<[Self]> {
        return database.promiseAllWith()
    }
    
}

// MARK: - Sync multiple records
extension Array where Element: CKRecordSyncable {
    
    typealias T = Element.Type
    
    func promiseRecords() -> Promise<[CKRecord]> {
        return when(fulfilled: self.map { $0.promiseRecord() })
    }
    
    func promiseInsertTo(_ database: CKDatabase) -> Promise<[Element]> {
        // Creating record resulted in creating temporary data at generated file url
        return self.promiseRecords()
        .then(execute: database.promiseInsertRecords)
        .then { savedRecords -> [Element] in
            savedRecords.mapExisting { Element(record: $0) }
        }
        .always {
            // So assure, that the temporary data will be always cleared
            self.forEach{ $0.clearTemporaryData() }
        }

    }
    
    func promiseSyncTo(_ database: CKDatabase) -> Promise<[Element]> {
        // Creating record resulted in creating temporary data at generated file url
        return self.promiseRecords()
        .then(execute: database.promiseUpdateRecords)
        .then { savedRecords -> [Element] in
            savedRecords.mapExisting { Element(record: $0) }
        }
        .always {
            // So assure, that the temporary data will be always cleared
            self.forEach{ $0.clearTemporaryData() }
        }
    }
    
}
