//
//  CKRecordConvertible.swift
//  SkillCloud
//
//  Created by Andrzej Michnia on 30/06/16.
//  Copyright © 2016 amichnia. All rights reserved.
//

import Foundation
import UIKit
import CloudKit
import PromiseKit

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
