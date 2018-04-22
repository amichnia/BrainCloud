//
//  BaseNodeEntity+CoreDataProperties.swift
//  SkillCloud
//
//  Created by Andrzej Michnia on 22/09/16.
//  Copyright © 2016 amichnia. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import UIKit
import CoreData

extension BaseNodeEntity {

    @NSManaged var nodeId: String?
    @NSManaged var positionRelative: NSValue?
    @NSManaged var scale: Float
    @NSManaged var color: UIColor?
    @NSManaged var connected: Array<Int>?

}
