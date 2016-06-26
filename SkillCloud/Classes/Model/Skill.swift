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

class Skill: CKRecordConvertible {
    
    var title : String
    var description : String?
    var image : UIImage // cropped image
    var experience : Experience
    var previousUniqueIdentifier: String?
    
    // Prepared images
    lazy var circleImage: UIImage? = {
        return self.thumbnailImage.RBCircleImage()
    }()
    lazy var thumbnailImage: UIImage = {
        return self.image.RBSquareImageTo(CGSize(width: 122, height: 122))
    }()
    var thumbnailCircleImage: UIImage?
    
    var checkCount = 0
    
    // MARK: - Initializers
    init(title: String, image: UIImage, experience: Skill.Experience, description: String? = nil) {
        self.title = title
        self.image = image
        self.experience = experience
        self.description = description
    }
    
    required convenience init?(record: CKRecord) {
        guard let
            title = record.objectForKey(CKKey.Name) as? String,
            expValue = record.objectForKey(CKKey.Experience) as? Int,
            experience = Skill.Experience(rawValue: expValue),
            imageUrl = (record.objectForKey(CKKey.Image) as? CKAsset)?.fileURL,
            image = UIImage(contentsOfFile: imageUrl.path!)
        else {
            return nil
        }
        
        let description = record.objectForKey(CKKey.Description) as? String
        
        self.init(title: title, image: image, experience: experience, description: description)
    }
    
    // MARK: - Public promises
    func promiseAddTo(database: CKDatabase, forUser userRecordId: CKRecordID) -> Promise<CKRecordID> {
        return Promise<CKRecordID> { fulfill,reject in
            let record = CKRecord(recordType: RecordType.Skill)
            record.setObject(self.title, forKey: CKKey.Name)
            record.setObject(self.experience.rawValue, forKey: CKKey.Experience)
            
            var fileUrl: NSURL?
            if let imageData = UIImageJPEGRepresentation(self.image, 0.9) {
                fileUrl = self.generateFileURL()
                try! imageData.writeToURL(fileUrl!, options: .AtomicWrite)
                let imageAsset = CKAsset(fileURL: fileUrl!)
                record.setObject(imageAsset, forKey: CKKey.Image)
            }
            
            database.saveRecord(record) { savedRecord,error in
                // Clear data
                if let temporaryUrl = fileUrl {
                    try! NSFileManager.defaultManager().removeItemAtURL(temporaryUrl)
                }
                
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
        static let Image = "image"
        static let Description = "desc"
    }
    
}

extension Skill {
    
    func generateFileURL() -> NSURL {
        let fileManager = NSFileManager.defaultManager()
        let fileArray: NSArray = fileManager.URLsForDirectory(.CachesDirectory, inDomains: .UserDomainMask)
        let fileURL = fileArray.lastObject?.URLByAppendingPathComponent(NSUUID().UUIDString).URLByAppendingPathExtension("jpg")
        
        if let filePath = (fileArray.lastObject as? NSURL)?.path {
            if !fileManager.fileExistsAtPath(filePath) {
                try! fileManager.createDirectoryAtPath(filePath, withIntermediateDirectories: true, attributes: nil)
            }
        }
        
        return fileURL!
    }
    
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

protocol ExperienceConvertible {
    
    var experience : Skill.Experience { get }
    
}

extension Skill : ExperienceConvertible { }

extension Skill : DTOModel {

    var uniqueIdentifierValue: String { return self.title }
    
}