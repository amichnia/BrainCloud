//
// Copyright (c) 2017 amichnia. All rights reserved.
//

import UIKit
import CloudKit
import PromiseKit

// MARK: - DTOModel
extension Skill: DTOModel {
    var uniqueIdentifierValue: String {
        return self.title
    }
}

extension Skill {
    class func fetchAllWithPredicate(_ predicate: NSPredicate) -> Promise<[Skill]> {
        return SkillEntity.fetchAllWithPredicate(predicate).then { entities -> [Skill] in
            return entities.map { $0.skill }
        }
    }

    class func fetchAll() -> Promise<[Skill]> {
        return self.fetchAllNotDeleted()
    }

    class func fetchAllUnsynced() -> Promise<[Skill]> {
        return SkillEntity.fetchAllUnsynced().then { entities -> [Skill] in
            return entities.map { $0.skill }
        }
    }

    class func fetchAllNotDeleted() -> Promise<[Skill]> {
        let predicate = NSPredicate(format: "toDelete == %@", NSNumber(booleanLiteral: false))
        return self.fetchAllWithPredicate(predicate)
    }

    class func fetchAllToDelete() -> Promise<[Skill]> {
        let predicate = NSPredicate(format: "toDelete == %@", NSNumber(booleanLiteral: true))
        return self.fetchAllWithPredicate(predicate)
    }
}
