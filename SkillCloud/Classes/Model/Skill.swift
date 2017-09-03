//
//  Skill.swift
//  SkillCloud
//
//  Created by Andrzej Michnia on 17.03.2016.
//  Copyright © 2016 amichnia. All rights reserved.
//

import UIKit
import CloudKit
import PromiseKit

// MARK: - Skill class definition
class Skill {
    var title: String!                      // Core Data unique identifier
    var skillDescription: String?
    var experience: Experience!
    var previousUniqueIdentifier: String?   // For Core Data
    var thumbnail: UIImage!
    var image: UIImage!
    var offline: Bool = true
    var toDelete: Bool = false

    // Cloud Kit only
    var createdRecord: CKRecord?
    var recordName: String?
    var modified: Date?
    var recordChangeTag: String?

    var shouldRefetchImage: Bool = false

    // Prepared images
    lazy var circleImage: UIImage? = {
        return self.thumbnail.RBCircleImage()
    }()

    // MARK: - Initializers
    init(title: String, thumbnail: UIImage, experience: Skill.Experience, description: String? = nil) {
        self.title = title
        self.thumbnail = thumbnail
        self.experience = experience
        self.skillDescription = description
    }

    fileprivate init() {
    }

    required convenience init?(record: CKRecord) {
        self.init()

        if self.performMappingWith(record) == nil {
            return nil
        }
    }
}

// MARK: - DTOModel
extension Skill: DTOModel {

    var uniqueIdentifierValue: String {
        return self.title
    }

}
