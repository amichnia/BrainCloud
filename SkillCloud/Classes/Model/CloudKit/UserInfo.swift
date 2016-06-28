//
//  UserInfo.swift
//  SkillCloud
//
//  Created by Andrzej Michnia on 25/06/16.
//  Copyright © 2016 amichnia. All rights reserved.
//

import Foundation
import CloudKit
import PromiseKit

class UserInfo {
    // MARK: - Properties
    private let container : CKContainer
    private var userRecordID : CKRecordID!
    private var contacts = [AnyObject]()
    
    // MARK: - Initializers
    init (container : CKContainer) {
        self.container = container;
    }
    
    // MARK: - Public promises
    // TODO: Move this to Cloud container
    
    func promiseUserID() -> Promise<CKRecordID> {
        guard self.userRecordID == nil else {
            return Promise<CKRecordID>(self.userRecordID)
        }
        
        return Promise<CKRecordID>() { fulfill,reject in
            self.container.fetchUserRecordIDWithCompletionHandler() { recordID, error in
                if let recordID = recordID where error == nil {
                    self.userRecordID = recordID
                    fulfill(recordID)
                }
                else {
                    reject(error ?? CloudError.UnknownError)
                }
            }

        }
    }
    
}

