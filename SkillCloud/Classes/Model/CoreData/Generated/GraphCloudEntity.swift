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
            // Basic
            self.cloudId = cloud.cloudIdentifier
            self.date = NSDate().timeIntervalSince1970
            self.name = cloud.name
            self.thumbnail = cloud.thumbnail
            self.slot = Int16(cloud.slot)
            
            self.graphName = cloud.graph.name
            self.graphVersion = cloud.graph.version
            
            // Update skill nodes
            
            self.skillNodes?.forEach { node in
                guard let node = node as? NSManagedObject else { return }

                self.managedObjectContext?.deleteObject(node)
            }
            
            for skillNode in cloud.skillNodes {
                let skillNodeEntity = DataManager.updateEntity(SkillNodeEntity.self, model: skillNode, intoContext: ctx)
                skillNodeEntity?.cloud = self
            }
        }
    }

}
