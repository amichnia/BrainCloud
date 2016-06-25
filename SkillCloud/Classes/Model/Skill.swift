//
//  Skill.swift
//  SkillCloud
//
//  Created by Andrzej Michnia on 17.03.2016.
//  Copyright © 2016 amichnia. All rights reserved.
//

import UIKit
import CloudKit

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
        // TODO: Stub implementation - replace
        self.init(title: "", image: UIImage(), experience: Skill.Experience.Beginner, description: nil)
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