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
    static var recordType: String { get }

    var recordName: String? { get set }
    var recordID: CKRecordID? { get }

    func recordRepresentation() -> CKRecord?
}

extension CKRecordConvertible {
    static var recordType: String {
        return String(describing: Self.self)
    }

    var recordID: CKRecordID? {
        return self.recordName == nil ? nil : CKRecordID(recordName: self.recordName!)
    }

    var recordType: String {
        return Self.recordType
    }

    func promiseRecord() -> Promise<CKRecord> {
        return Promise<CKRecord> { fulfill, reject in
            if let record = self.recordRepresentation() {
                fulfill(record)
            } else {
                reject(CloudError.notMatchingRecordData)
            }
        }
    }
}
