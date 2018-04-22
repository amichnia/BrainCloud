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
    struct Application {
        static let AppStoreID: UInt         = 1125706679
        static let RateAtLaunch: Bool       = false
        static let RateAfterDays: Float     = 0 
        static let RateAfterUses: UInt      = 0
        static let RateAfterEvents: UInt    = 5
        static let StudioURL: URL!          = URL(string: "http://www.girappe.com")
    }
    
    struct Cloud {
        static let ExportedDefaultSize:         CGSize      = CGSize(width: 1400, height: 1400)
        static let ThumbnailCaptureSize:        CGSize      = CGSize(width: 350, height: 350)
        static let ThumbnailDefaultSize:        CGSize      = CGSize(width: 140, height: 140)
    }
    struct Skill {
        static let MinimumCroppableSize:        CGFloat     = 640
    }
    // MARK: - Collision Masks
    struct CollisionMask {
        static let None: UInt32             = 0x0       // 0
        static let Default: UInt32          = 0x1 << 0  // 1
        static let Ghost: UInt32            = 0x1 << 1  // 2
        static let GraphNode: UInt32        = 0x1 << 2  // 4
        static let GraphBoundary: UInt32    = CollisionMask.GraphNode | CollisionMask.Default
    }
    
    struct ContactMask {
        static let None: UInt32             = 0x0       // 0
        static let Default: UInt32          = 0x1 << 0  // 1
        static let Ghost: UInt32            = 0x1 << 1  // 2
        static let AreaNode: UInt32         = 0x1 << 2  // 4
        static let GraphNode: UInt32        = ContactMask.AreaNode | ContactMask.Default
        
    }
}
