//
//  UserInfo.swift
//  SkillCloud
//
//  Created by Andrzej Michnia on 25/06/16.
//  Copyright © 2016 amichnia. All rights reserved.
//

import Foundation
import CloudKit

class UserInfo {
    
    let container : CKContainer
    var userRecordID : CKRecordID!
    var contacts = [AnyObject]()
    
    init (container : CKContainer) {
        self.container = container;
    }
    
    func loggedInToICloud(completion : (accountStatus : CKAccountStatus, error : NSError!) -> ()) {
        //replace this stub
        completion(accountStatus: .CouldNotDetermine, error: nil)
    }
    
    func userID(completion: (userRecordID: CKRecordID!, error: NSError!)->()) {
        if self.userRecordID != nil {
            completion(userRecordID: self.userRecordID, error: nil)
        }
        else {
            self.container.fetchUserRecordIDWithCompletionHandler() {
                recordID, error in
                if recordID != nil {
                    self.userRecordID = recordID
                }
                completion(userRecordID: recordID, error: error)
            }
        }
    }
    
    func userInfo(recordID: CKRecordID!, completion:(userInfo: CKDiscoveredUserInfo!, error: NSError!)->()) {
        //replace this stub
        completion(userInfo: nil, error: nil)
    }
    
    func requestDiscoverability(completion: (discoverable: Bool) -> ()) {
        //replace this stub
        completion(discoverable: false)
    }
    
    func userInfo(completion: (userInfo: CKDiscoveredUserInfo!, error: NSError!)->()) {
        self.requestDiscoverability() { discoverable in
            self.userID() { recordID, error in
                if error != nil {
                    completion(userInfo: nil, error: error)
                } else {
                    self.userInfo(recordID, completion: completion)
                }
            }
        }
    }
    
    func findContacts(completion: (userInfos:[AnyObject]!, error: NSError!)->()) {
        completion(userInfos: [CKRecordID](), error: nil)
    }
}

