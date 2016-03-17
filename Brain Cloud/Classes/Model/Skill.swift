//
//  Skill.swift
//  Brain Cloud
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
    
    // MARK: - Develop // FIXME: Remove after develop finished
    
    static var skill : Skill { return Skill(title: "Empty skill", image: UIImage(named: "skill_obj")!, experience: Skill.Experience.Intermediate) }
    
}