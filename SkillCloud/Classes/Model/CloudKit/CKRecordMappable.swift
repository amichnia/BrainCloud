//
//  CKRecordMappable.swift
//  SkillCloud
//
//  Created by Andrzej Michnia on 30/06/16.
//  Copyright © 2016 amichnia. All rights reserved.
//

import Foundation
import UIKit
import CloudKit
import PromiseKit

// MARK: - CKRecordMappable
/// Class implementing CKRecordMappable protocol is valid, to be initialized with CKRecord instance
protocol CKRecordMappable: class {
    /**
     Returns new instance of CKRecordMappable class, or nil, if could not map
     
     - parameter record: CKRecord instance to initialize with
     
     - returns: Instance or nil
     */
    init?(record: CKRecord)

    func performMappingWith(_ record: CKRecord) -> Self?
}

extension CKRecordMappable {
    typealias T = Self

    func promiseMappingWith(_ record: CKRecord) -> Promise<T> {
        return Promise<T>() { fulfill, reject in
            if let object = self.performMappingWith(record) {
                fulfill(object)
            } else {
                reject(CloudError.notMatchingRecordData)
            }
        }
    }

    static func promiseWithRecord(_ record: CKRecord) -> Promise<T> {
        return Promise<T>() { fulfill, reject in
            if let object = T(record: record) {
                fulfill(object)
            } else {
                reject(CloudError.notMatchingRecordData)
            }
        }
    }
}
