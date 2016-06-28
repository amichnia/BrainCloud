//
//  Skill.swift
//  SkillCloud
//
//  Created by Andrzej Michnia on 17.03.2016.
//  Copyright © 2016 amichnia. All rights reserved.
//

import UIKit
import CloudKit
import PromiseKit

class Skill {
    
    var title: String!
    var description: String?
    var experience: Experience!
    var previousUniqueIdentifier: String?
    var imageAsset: ImageAsset?
    var thumbnail: UIImage!
    
    // Cloud Kit only
    var record: CKRecord?
    var recordName: String?
    var modified: NSDate?
    var recordChangeTag: String?
    
    // Prepared images
    lazy var circleImage: UIImage? = {
        return self.thumbnail.RBCircleImage()
    }()
    
    var image: UIImage! {
        get {
            return self.thumbnail // TODO: Change to evaluate from propmise of image asset
        }
        set {
            // TODO: Valid setter
        }
    }
    
    var checkCount = 0
    
    // MARK: - Initializers
    init(title: String, thumbnail: UIImage, experience: Skill.Experience, description: String? = nil) {
        self.title = title
        self.thumbnail = thumbnail
        self.experience = experience
        self.description = description
    }
    
    private init() { }
    
    required convenience init?(record: CKRecord) {
        self.init()
        
        if self.performMappingWith(record) == nil {
            return nil
        }
    }
    
    // MARK: - Public CK promises
    func promiseAddTo(database: CKDatabase, forUser userRecordId: CKRecordID) -> Promise<CKRecordID> {
        return Promise<CKRecordID> { fulfill,reject in
            guard let record = self.recordRepresentation() else {
                reject(CloudError.NotMatchingRecordData)
                return
            }
            
            database.saveRecord(record) { savedRecord,error in
                // Clear data
                (record.objectForKey(CKKey.Thumbnail) as? CKAsset)?.clearTemporaryData()
                
                // Process success
                if let savedRecord = savedRecord where error == nil {
                    fulfill(savedRecord.recordID)
                }
                // Process failure
                else {
                    reject(error ?? CloudError.UnknownError)
                }
            }
            
        }
    }
    
    // MARK: - Static Keys
    private struct CKKey {
        static let Name = "name"
        static let Experience = "experienceValue"
        static let Thumbnail = "thumbnail"
        static let Description = "desc"
    }
    
}

// MARK: - CKRecordMappable
extension Skill: CKRecordMappable {
    
    func performMappingWith(record: CKRecord) -> Self? {
        guard let
            title = record.objectForKey(CKKey.Name) as? String,
            expValue = record.objectForKey(CKKey.Experience) as? Int,
            experience = Skill.Experience(rawValue: expValue),
            imageUrl = (record.objectForKey(CKKey.Thumbnail) as? CKAsset)?.fileURL,
            image = UIImage(contentsOfFile: imageUrl.path!)
        else {
            return nil
        }
        
        let description = record.objectForKey(CKKey.Description) as? String
        
        self.title = title
        self.thumbnail = image
        self.experience = experience
        self.description = description
        self.recordName = record.recordID.recordName
        self.modified = record.modificationDate
        self.recordChangeTag = record.recordChangeTag
        self.record = record
        
        return self
    }
    
}

// MARK: - CKRecordConvertible
extension Skill: CKRecordConvertible {
    
    func recordRepresentation() -> CKRecord? {
        let record = CKRecord(recordConvertible: self)
        
        record.setObject(self.title, forKey: CKKey.Name)
        record.setObject(self.experience.rawValue, forKey: CKKey.Experience)
        record.setObject(self.description, forKey: CKKey.Description)
        
        if let image = try? CKAsset.assetWithImage(self.thumbnail) {
            record.setObject(image, forKey: CKKey.Thumbnail)
        }
        else {
            return nil
        }
        
        return record
    }
    
}

// MARK: - DTOModel
extension Skill : DTOModel {

    var uniqueIdentifierValue: String { return self.title }
    
}

// MARK: - Experience
extension Skill {
    
    enum Experience : Int {
        case Any = -1
        case Beginner = 0
        case Intermediate
        case Professional
        case Expert
        
        var image: UIImage? {
            switch self {
            case .Beginner:
                return UIImage(named: "icon-skill-beginner")
            case .Intermediate:
                return UIImage(named: "icon-skill-intermediate")
            case .Professional:
                return UIImage(named: "icon-skill-professional")
            case .Expert:
                return UIImage(named: "icon-skill-expert")
            default:
                return nil
            }
        }
        
        var radius: CGFloat {
            switch self {
            case .Beginner:
                return 10
            case .Intermediate:
                return 15
            case .Professional:
                return 20
            case .Expert:
                return 25
            default:
                return 0
            }
        }
    }
}

