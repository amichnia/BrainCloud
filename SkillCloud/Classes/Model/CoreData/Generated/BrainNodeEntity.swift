//
//  BrainNodeEntity.swift
//  SkillCloud
//
//  Created by Andrzej Michnia on 30/05/16.
//  Copyright © 2016 amichnia. All rights reserved.
//

import Foundation
import CoreData


class BrainNodeEntity: BaseNodeEntity, CoreDataEntity {

    static var entityName = "BrainNodeEntity"
    static var uniqueIdentifier = "nodeId"
    
    convenience required init?(model: DTOModel, inContext ctx: NSManagedObjectContext) {
        guard let entityDescription = NSEntityDescription.entityForName(BrainNodeEntity.entityName, inManagedObjectContext: ctx) where model is BrainNode else {
            return nil
        }
        self.init(entity: entityDescription, insertIntoManagedObjectContext: DataManager.managedObjectContext)
        
        self.setValuesFromModel(model)
    }
    
    func setValuesFromModel(model: DTOModel) {
        if let node = model as? BrainNode {
            self.nodeId = node.uniqueIdentifierValue
            self.scale = Int16(node.node.scale)
            self.isConvex = node.node.convex
            self.positionRelative = NSValue(CGPoint: node.node.point )
            
            if let skillNode = node.pinnedSkillNode {
                // TODO: Connect with skill node
            }
        }
    }

}
