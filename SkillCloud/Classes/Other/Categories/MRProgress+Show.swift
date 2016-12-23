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
        guard let window = UIApplication.shared.delegate?.window else {
            return
        }
        
        MRProgressOverlayView.showOverlayAdded(to: window, animated: true)
    }
    
    static func hide() {
        guard let window = UIApplication.shared.delegate?.window else {
            return
        }
        
        MRProgressOverlayView.dismissAllOverlays(for: window, animated: true)
    }
    
}
