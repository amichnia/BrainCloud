//
//  GraphCloudEntity+CoreDataProperties.swift
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

extension GraphCloudEntity {

    @NSManaged var cloudId: String?
    @NSManaged var date: NSTimeInterval
    @NSManaged var name: String?
    @NSManaged var slot: Int16
    @NSManaged var thumbnail: UIImage?
    @NSManaged var graphVersion: String?
    @NSManaged var graphName: String?
    @NSManaged var skillNodes: NSSet?

}
