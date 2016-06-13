//
//  BaseNodeEntity+CoreDataProperties.swift
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

extension BaseNodeEntity {

    @NSManaged var positionRelative: NSValue?
    @NSManaged var nodeId: String?
    @NSManaged var scale: Int16

}
