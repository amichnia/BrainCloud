//
//  MRProgress+Show.swift
//  SkillCloud
//
//  Created by Andrzej Michnia on 09/07/16.
//  Copyright © 2016 amichnia. All rights reserved.
//

import Foundation
import MRProgress


extension MRProgressOverlayView {
    
    static func show() {
        guard let window = UIApplication.sharedApplication().delegate?.window else {
            return
        }
        
        MRProgressOverlayView.showOverlayAddedTo(window, animated: true)
    }
    
    static func hide() {
        guard let window = UIApplication.sharedApplication().delegate?.window else {
            return
        }
        
        MRProgressOverlayView.dismissAllOverlaysForView(window, animated: true)
    }
    
}