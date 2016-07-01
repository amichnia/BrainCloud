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

// MARK: - Skill class definition
class Skill {
    
    var title: String!                      // Core Data unique identifier
    var skillDescription: String?
    var experience: Experience!
    var previousUniqueIdentifier: String?   // For Core Data
    var thumbnail: UIImage!
    var image: UIImage!
    var offline: Bool = true
    var toDelete: Bool = false
    
    // Cloud Kit only
    var createdRecord: CKRecord?
    var recordName: String?
    var modified: NSDate?
    var recordChangeTag: String?
    
    // Prepared images
    lazy var circleImage: UIImage? = {
        return self.thumbnail.RBCircleImage()
    }()
    
    // MARK: - Initializers
    init(title: String, thumbnail: UIImage, experience: Skill.Experience, description: String? = nil) {
        self.title = title
        self.thumbnail = thumbnail
        self.experience = experience
        self.skillDescription = description
    }
    
    private init() { }
    
    required convenience init?(record: CKRecord) {
        self.init()
        
        if self.performMappingWith(record) == nil {
            return nil
        }
    }
    
    // MARK: - Static Keys
    private struct CKKey {
        static let Name = "name"
        static let Experience = "experienceValue"
        static let Thumbnail = "thumbnail"
        static let Description = "desc"
        static let Image = "image"
    }
    
}

// MARK: - CKRecordMappable
extension Skill: CKRecordMappable {
    
    func performMappingWith(record: CKRecord) -> Self? {
        guard let
            title = record.objectForKey(CKKey.Name) as? String,
            expValue = record.objectForKey(CKKey.Experience) as? Int,
            experience = Skill.Experience(rawValue: expValue),
            thumbnail = record.imageForKey(CKKey.Thumbnail) ?? self.thumbnail
        else {
            return nil
        }
        
        let description = record.objectForKey(CKKey.Description) as? String
        
        self.title = title
        self.thumbnail = thumbnail
        self.experience = experience
        self.skillDescription = description
        self.recordName = record.recordID.recordName
        self.modified = record.modificationDate
        self.recordChangeTag = record.recordChangeTag
        
        self.offline = false
        
        self.image = record.imageForKey(CKKey.Image) ?? self.image
        
        return self
    }
    
}

// MARK: - CKRecordConvertible
extension Skill: CKRecordConvertible {
    
    func recordRepresentation() -> CKRecord? {
        let record = CKRecord(recordConvertible: self)
        
        record.setObject(self.title, forKey: CKKey.Name)
        record.setObject(self.experience.rawValue, forKey: CKKey.Experience)
        record.setObject(self.skillDescription, forKey: CKKey.Description)
        
        if let thumbnail = try? CKAsset.assetWithImage(self.thumbnail) {
            record.setObject(thumbnail, forKey: CKKey.Thumbnail)
        }
        else {
            return nil
        }
        
        if let image = try? CKAsset.assetWithImage(self.image) {
            record.setObject(image, forKey: CKKey.Image)
        }
        else {
            return nil
        }
        
        self.createdRecord = record    // ??? For clearup data
        
        return record
    }
    
}

// MARK: - CKRecordSyncable
extension Skill: CKRecordSyncable {
    
    func clearTemporaryData() {
        (self.createdRecord?.objectForKey(CKKey.Thumbnail) as? CKAsset)?.clearTemporaryData()
        (self.createdRecord?.objectForKey(CKKey.Image) as? CKAsset)?.clearTemporaryData()
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

extension Skill {
    
    class func fetchAllWithPredicate(predicate: NSPredicate) -> Promise<[Skill]> {
        return SkillEntity.fetchAllWithPredicate(predicate).then { entities -> [Skill] in
            return entities.map { $0.skill }
        }
    }
    
    class func fetchAll() -> Promise<[Skill]> {
        return self.fetchAllNotDeleted()
//        return SkillEntity.fetchAll().then { entities -> [Skill] in
//            return entities.map { $0.skill }
//        }
    }
    
    class func fetchAllUnsynced() -> Promise<[Skill]> {
        return SkillEntity.fetchAllUnsynced().then { entities -> [Skill] in
            return entities.map { $0.skill }
        }
    }
    
    class func fetchAllNotDeleted() -> Promise<[Skill]> {
        let predicate = NSPredicate(format: "toDelete == %@", false)
        return self.fetchAllWithPredicate(predicate)
    }
    
    class func fetchAllToDelete() -> Promise<[Skill]> {
        let predicate = NSPredicate(format: "toDelete == %@", true)
        return self.fetchAllWithPredicate(predicate)
    }
    
}