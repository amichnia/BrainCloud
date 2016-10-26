//
//  TouchDownView.swift
//  SkillCloud
//
//  Created by Andrzej Michnia on 26.10.2016.
//  Copyright © 2016 amichnia. All rights reserved.
//

import UIKit

@objc protocol TouchDownViewDelegate: NSObjectProtocol {
    func didTouch(down: Bool)
}

class TouchDownView: UIView {
    
    @IBOutlet weak var delegate: TouchDownViewDelegate?
    
    var touchDown: Bool = false {
        didSet {
            delegate?.didTouch(self.touchDown)
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        touchDown = true
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
        touchDown = false
    }
    
}