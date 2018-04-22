//
//  GraphCloudEntity+CoreDataProperties.swift
//  SkillCloud
//
//  Created by Andrzej Michnia on 05.09.2017.
//  Copyright © 2017 amichnia. All rights reserved.
//

import UIKit
import CoreData

extension GraphCloudEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<GraphCloudEntity> {
        return NSFetchRequest<GraphCloudEntity>(entityName: "GraphCloudEntity")
    }

    @NSManaged public var cloudId: String?
    @NSManaged public var date: TimeInterval
    @NSManaged public var graphName: String?
    @NSManaged public var graphVersion: String?
    @NSManaged public var name: String?
    @NSManaged public var paletteId: String
    @NSManaged public var slot: Int16
    @NSManaged public var thumbnail: UIImage?
    @NSManaged public var skillNodes: NSSet?

}

// MARK: Generated accessors for skillNodes
extension GraphCloudEntity {

    @objc(addSkillNodesObject:)
    @NSManaged public func addToSkillNodes(_ value: SkillNodeEntity)

    @objc(removeSkillNodesObject:)
    @NSManaged public func removeFromSkillNodes(_ value: SkillNodeEntity)

    @objc(addSkillNodes:)
    @NSManaged public func addToSkillNodes(_ values: NSSet)

    @objc(removeSkillNodes:)
    @NSManaged public func removeFromSkillNodes(_ values: NSSet)

}
