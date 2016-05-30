//
//  SkillNodeEntity+CoreDataProperties.swift
//  SkillCloud
//
//  Created by Andrzej Michnia on 30/05/16.
//  Copyright © 2016 amichnia. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import UIKit
import CoreData

extension SkillNodeEntity {

    @NSManaged var skillName: String?
    @NSManaged var skillImage: UIImage?
    @NSManaged var skillExperienceValue: Int16
    @NSManaged var pinnedNodes: NSSet?
    @NSManaged var cloud: GraphCloudEntity?

}
