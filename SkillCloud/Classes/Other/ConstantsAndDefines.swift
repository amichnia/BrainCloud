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
    }
    
    struct Cloud {
        static let ExportedDefaultSize:         CGSize      = CGSize(width: 1600, height: 1400)
        static let ThumbnailCaptureSize:        CGSize      = CGSize(width: 240, height: 210)
        static let ThumbnailDefaultSize:        CGSize      = CGSize(width: 140, height: 140)
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