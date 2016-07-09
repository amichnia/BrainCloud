//
//  GraphCloudEntity.swift
//  SkillCloud
//
//  Created by Andrzej Michnia on 30/05/16.
//  Copyright © 2016 amichnia. All rights reserved.
//

import Foundation
import CoreData


class GraphCloudEntity: NSManagedObject, CoreDataEntity {
    
    static var entityName = "GraphCloudEntity"
    static var uniqueIdentifier = "cloudId"
    
    convenience required init?(model: DTOModel, inContext ctx: NSManagedObjectContext) {
        guard let entityDescription = NSEntityDescription.entityForName(GraphCloudEntity.entityName, inManagedObjectContext: ctx) where model is CloudGraphScene else {
            return nil
        }
        self.init(entity: entityDescription, insertIntoManagedObjectContext: ctx)
        
        // Set values
        self.setValuesFromModel(model)
    }
    
    func setValuesFromModel(model: DTOModel) {
        if let cloud = model as? CloudGraphScene, ctx = self.managedObjectContext {
            
            self.cloudId = cloud.cloudIdentifier
            self.date = NSDate().timeIntervalSince1970
            self.name = cloud.name
            self.thumbnail = cloud.thumbnail
            
            // Update skill nodes
            for skillNode in cloud.skillNodes {
                let skillNodeEntity = DataManager.updateEntity(SkillNodeEntity.self, model: skillNode, intoContext: ctx)
                DDLogInfo("SN: \(skillNodeEntity?.nodeId ?? "-")")
                skillNodeEntity?.cloud = self
            }
            
            // Update brain nodes
            for brainNode in cloud.allNodes {
                let brainNodeEntity = DataManager.updateEntity(BrainNodeEntity.self, model: brainNode, intoContext: ctx)
                DDLogInfo("BN: \(brainNodeEntity?.nodeId ?? "-")")
                brainNodeEntity?.cloud = self
            }
        }
    }

}
