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
    func promiseUserID() -> Promise<CKRecordID> {
        return Promise<CKRecordID>() { fulfill,reject in
            guard self.userRecordID == nil else {
                fulfill(self.userRecordID)
                return
            }
            
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
    
    // MARK: - Private
    private func loggedInToICloud(completion : (accountStatus : CKAccountStatus, error : NSError!) -> ()) {
        //replace this stub
        completion(accountStatus: .CouldNotDetermine, error: nil)
    }
    
    private func userInfo(recordID: CKRecordID!, completion:(userInfo: CKDiscoveredUserInfo!, error: NSError!)->()) {
        //replace this stub
        completion(userInfo: nil, error: nil)
    }
    
    // TODO: Implement
    private func requestDiscoverability(completion: (discoverable: Bool) -> ()) {
        //replace this stub
        completion(discoverable: false)
    }
    // TODO: Implement
    private func userInfo(completion: (userInfo: CKDiscoveredUserInfo!, error: NSError!)->()) {
        self.requestDiscoverability() { discoverable in
//            self.userID() { recordID, error in
//                if error != nil {
//                    completion(userInfo: nil, error: error)
//                } else {
//                    self.userInfo(recordID, completion: completion)
//                }
//            }
        }
    }
    // TODO: Implement
    private func findContacts(completion: (userInfos:[AnyObject]!, error: NSError!)->()) {
        completion(userInfos: [CKRecordID](), error: nil)
    }
    
}

