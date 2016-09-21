//
//  BrainNodeEntity+CoreDataProperties.swift
//  SkillCloud
//
//  Created by Andrzej Michnia on 30/05/16.
//  Copyright © 2016 amichnia. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension BrainNodeEntity {

    @NSManaged var isConvex: Bool
    @NSManaged var nodeNodeId: Int32
    @NSManaged var connectedTo: Array<Int>?
    @NSManaged var pinnedSkillNode: SkillNodeEntity?
    @NSManaged var cloud: GraphCloudEntity?

}
