//
//  SkillEntity+CoreDataProperties.swift
//  SkillCloud
//
//  Created by Andrzej Michnia on 01/07/16.
//  Copyright © 2016 amichnia. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import UIKit
import CoreData

extension SkillEntity {

    @NSManaged var changeTag: String?
    @NSManaged var desc: String?
    @NSManaged var experienceValue: Int16
    @NSManaged var image: UIImage?
    @NSManaged var modified: TimeInterval
    @NSManaged var name: String?
    @NSManaged var offline: Bool
    @NSManaged var recordID: String?
    @NSManaged var thumbnail: UIImage?
    @NSManaged var toDelete: Bool

}
