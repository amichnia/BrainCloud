//
//  CloudSelectScene.swift
//  SkillCloud
//
//  Created by Andrzej Michnia on 02/07/16.
//  Copyright © 2016 amichnia. All rights reserved.
//

import UIKit
import SpriteKit
import SpriteKit_Spring

class CloudSelectScene: SKScene {

    // MARK: - Outlets
    
    // MARK: - Properties
    
    // MARK: - Lifecycle
    override func didMoveToView(view: SKView) {
        super.didMoveToView(view)
        
        self.backgroundColor = view.backgroundColor!
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        self.physicsBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
        
    }
    
    // MARK: - Actions
    
    // MARK: - Navigation
    
}
