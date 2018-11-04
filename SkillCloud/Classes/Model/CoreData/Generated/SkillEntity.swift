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
        guard let entityDescription = NSEntityDescription.entity(forEntityName: SkillEntity.entityName, in: ctx), model is Skill else {
            return nil
        }
        self.init(entity: entityDescription, insertInto: ctx)
        
        self.setValuesFromModel(model)
    }
    
    func setValuesFromModel(_ model: DTOModel) {
        if let skill = model as? Skill {
            // Properties
            self.name               = skill.title
            self.desc               = skill.skillDescription
            self.experienceValue    = Int16(skill.experience.rawValue)
            self.thumbnail          = skill.thumbnail
            self.image              = skill.image
            self.offline            = skill.offline
            self.toDelete           = skill.toDelete
            // CloudKit synced
            self.recordID           = skill.recordName
            self.changeTag          = skill.recordChangeTag
            self.modified           = skill.modified?.timeIntervalSince1970 ?? Date().timeIntervalSince1970
        }
    }
}

// MARK: - DTO model
extension SkillEntity {
    var skill : Skill {
        let skill = Skill(title: self.name!, thumbnail: self.thumbnail!, experience: Skill.Experience(rawValue: Int(self.experienceValue))!, description: self.desc)
        
        skill.image             = self.image
        skill.offline           = self.offline
        skill.toDelete          = self.toDelete
        
        // CloudKit
        skill.recordName        = self.recordID
        skill.recordChangeTag   = self.changeTag
        skill.modified          = Date(timeIntervalSince1970: self.modified)
        
        return skill
    }
}

// MARK: - Fetching unsynced
extension SkillEntity {
    class func fetchAllUnsynced() -> Promise<[SkillEntity]> {
        let predicate = NSPredicate(format: "offline == YES")
        return SkillEntity.fetchAllWithPredicate(predicate)
    }
}
