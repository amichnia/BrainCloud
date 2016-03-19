//
//  SkillEntity+CoreDataProperties.swift
//  SkillCloud
//
//  Created by Andrzej Michnia on 19.03.2016.
//  Copyright © 2016 amichnia. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData
import UIKit

extension SkillEntity {

    @NSManaged var desc: String?
    @NSManaged var experienceValue: Int16
    @NSManaged var image: UIImage?
    @NSManaged var name: String?
    @NSManaged var originalImage: UIImage?

}
