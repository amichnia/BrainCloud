//
//  BaseNodeEntity.swift
//  SkillCloud
//
//  Created by Andrzej Michnia on 30/05/16.
//  Copyright © 2016 amichnia. All rights reserved.
//

import UIKit
import CoreData

class BaseNodeEntity: NSManagedObject {

    var relativePositionValue: CGPoint { return self.positionRelative?.CGPointValue() ?? CGPoint.zero }
    
}
