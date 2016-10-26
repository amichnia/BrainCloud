//
//  SkillNodeEntity.swift
//  SkillCloud
//
//  Created by Andrzej Michnia on 30/05/16.
//  Copyright © 2016 amichnia. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class SkillNodeEntity: BaseNodeEntity, CoreDataEntity {

    static var entityName = "SkillNodeEntity"
    static var uniqueIdentifier = "nodeId"
    
    convenience required init?(model: DTOModel, inContext ctx: NSManagedObjectContext) {
        guard let entityDescription = NSEntityDescription.entityForName(SkillNodeEntity.entityName, inManagedObjectContext: ctx) where model is SkillNode else {
            return nil
        }
        self.init(entity: entityDescription, insertIntoManagedObjectContext: ctx)
        
        self.setValuesFromModel(model)
    }
    
    func setValuesFromModel(model: DTOModel) {
        if let node = model as? SkillNode {
            // Base data
            self.nodeId = node.uniqueIdentifierValue
            self.positionRelative = NSValue(CGPoint: node.graphNode?.position ?? CGPoint.zero )
            self.scale = Float(node.graphNode?.xScale ?? 1) // Custom scale setting
//            self.color = node.color
            self.connected = node.pinnedNodes.map { return $0 }
            
            // Skill data
            self.skillName = node.skill.title
            self.skillImage = node.skill.image
            self.skillExperienceValue = Int16(node.skill.experience.rawValue)
        }
    }

}
