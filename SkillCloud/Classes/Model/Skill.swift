//
//  Skill.swift
//  SkillCloud
//
//  Created by Andrzej Michnia on 17.03.2016.
//  Copyright © 2016 amichnia. All rights reserved.
//

import UIKit

class Skill {
    
    var title : String
    var description : String?
    var image : UIImage // cropped image
    var experience : Experience
    
    // Prepared images
    var circleImage: UIImage?
    lazy var thumbnailImage: UIImage = {
        return self.image.RBSquareImageTo(CGSize(width: 122, height: 122))
    }()
    var thumbnailCircleImage: UIImage?
    
    var checkCount = 0
    
    init(title: String, image: UIImage, experience: Skill.Experience, description: String? = nil) {
        self.title = title
        self.image = image
        self.experience = experience
        self.description = description
    }
    
    enum Experience : Int {
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
            }
        }
    }
    
}

protocol ExperienceConvertible {
    
    var experience : Skill.Experience { get }
    
}

extension Skill : ExperienceConvertible { }

extension Skill : DTOModel { }