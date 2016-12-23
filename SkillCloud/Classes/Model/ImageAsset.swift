//
//  ImageAsset.swift
//  SkillCloud
//
//  Created by Andrzej Michnia on 28/06/16.
//  Copyright © 2016 amichnia. All rights reserved.
//

import UIKit
import CloudKit
import PromiseKit

class ImageAsset {
    
    var image: UIImage!
    var name: String?
    var offline: Bool = true
    
    var recordChangeTag: String?
    var modified: Date?
    var recordName: String?
    
    // MARK: - Initailizers
    init(image: UIImage, name: String? = nil) {
        self.image = image
        self.name = name
    }
    
    fileprivate init() { }
    
    required convenience init?(record: CKRecord) {
        self.init()
        
        if self.performMappingWith(record) == nil {
            return nil
        }
    }
    
    // MARK: - Static Keys
    fileprivate struct CKKey {
        static let Name = "name"
        static let Image = "image"
    }
    
}

// MARK: - CKRecordMappable
extension ImageAsset: CKRecordMappable {
    
    func performMappingWith(_ record: CKRecord) -> Self? {
        guard let
            imageUrl = (record.object(forKey: CKKey.Image) as? CKAsset)?.fileURL,
            let image = UIImage(contentsOfFile: imageUrl.path)
        else {
            return nil
        }
        
        self.image = image
        self.name = record.object(forKey: CKKey.Name) as? String
        self.recordName = record.recordID.recordName
        self.modified = record.modificationDate
        self.recordChangeTag = record.recordChangeTag
        
        return self
    }
    
}

// MARK: - CKRecordConvertible
extension ImageAsset: CKRecordConvertible {
    
    func recordRepresentation() -> CKRecord? {
        let record = CKRecord(recordConvertible: self)
        
        record.setObject(self.name as CKRecordValue?, forKey: CKKey.Name)
        
        if let image = try? CKAsset.assetWithImage(self.image) {
            record.setObject(image, forKey: CKKey.Image)
        }
        else {
            return nil
        }
        
        return record
    }
    
}
