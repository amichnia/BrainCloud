//
//  TouchDownView.swift
//  SkillCloud
//
//  Created by Andrzej Michnia on 26.10.2016.
//  Copyright © 2016 amichnia. All rights reserved.
//

import UIKit

@objc protocol TouchDownViewDelegate: NSObjectProtocol {
    func didTouch(_ down: Bool)
}

class TouchDownView: UIView {
    
    @IBOutlet weak var delegate: TouchDownViewDelegate?
    
    var touchDown: Bool = false {
        didSet {
            delegate?.didTouch(self.touchDown)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        touchDown = true
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        touchDown = false
    }
    
}
