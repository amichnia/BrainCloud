//
//  SkillEntity.swift
//  SkillCloud
//
//  Created by Andrzej Michnia on 19.03.2016.
//  Copyright © 2016 amichnia. All rights reserved.
//

import Foundation
import CoreData
import PromiseKit

class SkillEntity: NSManagedObject, CoreDataEntity {

    static var entityName = "SkillEntity"
    static var uniqueIdentifier = "name"
    
    convenience required init?(model: DTOModel, inContext ctx: NSManagedObjectContext) {
        guard let entityDescription = NSEntityDescription.entityForName(SkillEntity.entityName, inManagedObjectContext: ctx) where model is Skill else {
            return nil
        }
        self.init(entity: entityDescription, insertIntoManagedObjectContext: ctx)
        
        self.setValuesFromModel(model)
    }
    
    func setValuesFromModel(model: DTOModel) {
        if let skill = model as? Skill {
            self.name = skill.title
            self.desc = skill.description
            self.image = skill.image
            self.experienceValue = Int16(skill.experience.rawValue)
        }
    }
    
}

// MARK: - DTO model
extension SkillEntity {
    
    var skill : Skill {
        return Skill(title: self.name!, image: self.image!, experience: Skill.Experience(rawValue: Int(self.experienceValue))!, description: self.description)
    }
    
}