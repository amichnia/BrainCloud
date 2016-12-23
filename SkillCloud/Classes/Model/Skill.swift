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
    var modified: Date?
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
        static let Experience = "experienceValue"
        static let Thumbnail = "thumbnail"
        static let Description = "desc"
        static let Image = "image"
    }
    
}

// MARK: - CKRecordMappable
extension Skill: CKRecordMappable {
    
    func performMappingWith(_ record: CKRecord) -> Self? {
        guard let
            title = record.object(forKey: CKKey.Name) as? String,
            let expValue = record.object(forKey: CKKey.Experience) as? Int,
            let experience = Skill.Experience(rawValue: expValue),
            let thumbnail = record.imageForKey(CKKey.Thumbnail) ?? self.thumbnail
        else {
            return nil
        }
        
        let description = record.object(forKey: CKKey.Description) as? String
        
        self.title = title
        self.thumbnail = thumbnail
        self.experience = experience
        self.skillDescription = description
        self.recordName = record.recordID.recordName
        self.modified = record.modificationDate
        self.recordChangeTag = record.recordChangeTag
        
        self.offline = false
        
        self.image = record.imageForKey(CKKey.Image) ?? self.image ?? thumbnail
        
        return self
    }
    
}

// MARK: - CKRecordConvertible
extension Skill: CKRecordConvertible {
    
    func recordRepresentation() -> CKRecord? {
        let record = CKRecord(recordConvertible: self)
        
        record.setObject(self.title as CKRecordValue?, forKey: CKKey.Name)
        record.setObject(self.experience.rawValue as CKRecordValue?, forKey: CKKey.Experience)
        record.setObject(self.skillDescription as CKRecordValue?, forKey: CKKey.Description)
        
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
        (self.createdRecord?.object(forKey: CKKey.Thumbnail) as? CKAsset)?.clearTemporaryData()
        (self.createdRecord?.object(forKey: CKKey.Image) as? CKAsset)?.clearTemporaryData()
    }
    
}

// MARK: - DTOModel
extension Skill : DTOModel {

    var uniqueIdentifierValue: String { return self.title }
    
}

// MARK: - Experience
extension Skill {
    
    enum Experience : Int {
        case any = -1
        case beginner = 0
        case intermediate
        case professional
        case expert
        
        var image: UIImage? {
            switch self {
            case .beginner:
                return UIImage(named: "icon-skill-beginner")
            case .intermediate:
                return UIImage(named: "icon-skill-intermediate")
            case .professional:
                return UIImage(named: "icon-skill-professional")
            case .expert:
                return UIImage(named: "icon-skill-expert")
            default:
                return nil
            }
        }
        
        var radius: CGFloat {
            switch self {
            case .beginner:
                return 10
            case .intermediate:
                return 15
            case .professional:
                return 20
            case .expert:
                return 25
            default:
                return 0
            }
        }
        
        var name: String {
            switch self {
            case .any:
                return "Any"
            case .beginner:
                return "Beginner"
            case .intermediate:
                return "Intermediate"
            case .professional:
                return "Professional"
            case .expert:
                return "Expert"
            }
        }
    }
}

extension Skill {
    
    class func fetchAllWithPredicate(_ predicate: NSPredicate) -> Promise<[Skill]> {
        return SkillEntity.fetchAllWithPredicate(predicate).then { entities -> [Skill] in
            return entities.map { $0.skill }
        }
    }
    
    class func fetchAll() -> Promise<[Skill]> {
        return self.fetchAllNotDeleted()
    }
    
    class func fetchAllUnsynced() -> Promise<[Skill]> {
        return SkillEntity.fetchAllUnsynced().then { entities -> [Skill] in
            return entities.map { $0.skill }
        }
    }
    
    class func fetchAllNotDeleted() -> Promise<[Skill]> {
        let predicate = NSPredicate(format: "toDelete == %@", false as CVarArg)
        return self.fetchAllWithPredicate(predicate)
    }
    
    class func fetchAllToDelete() -> Promise<[Skill]> {
        let predicate = NSPredicate(format: "toDelete == %@", true as CVarArg)
        return self.fetchAllWithPredicate(predicate)
    }
    
}
