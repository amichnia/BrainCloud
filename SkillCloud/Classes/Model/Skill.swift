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
    var image : UIImage
    var experience : Experience
    
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
    }
    
}

protocol ExperienceConvertible {
    
    var experience : Skill.Experience { get }
    
}

extension Skill : ExperienceConvertible { }

extension Skill : DTOModel { }