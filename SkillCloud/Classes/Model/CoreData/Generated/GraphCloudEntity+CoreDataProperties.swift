//
//  GraphCloudEntity+CoreDataProperties.swift
//  SkillCloud
//
//  Created by Andrzej Michnia on 09/07/16.
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
    @NSManaged var thumbnail: UIImage?
    @NSManaged var brainNodes: NSSet?
    @NSManaged var skillNodes: NSSet?

}
