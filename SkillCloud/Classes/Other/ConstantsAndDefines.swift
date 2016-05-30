//
//  ConstantsAndDefines.swift
//  SkillCloud
//
//  Created by Andrzej Michnia on 29.05.2016.
//  Copyright © 2016 amichnia. All rights reserved.
//

import UIKit

// MARK: - Global Constants defines

struct Key {
    
}
struct Defined {
    struct Cloud {
        static let ExportedDefaultSize:         CGSize      = CGSize(width: 1600, height: 1400)
        
    }
    struct Skill {
        static let MinimumCroppableSize:        CGFloat     = 640
    }
    // MARK: - Collision Masks
    struct CollisionMask {
        static let None: UInt32 = 0x0
        static let Default: UInt32 = 0x1 << 0
        static let Ghost: UInt32 = 0x1 << 1
    }
}