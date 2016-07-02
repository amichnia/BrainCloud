//
//  CloudNode.swift
//  SkillCloud
//
//  Created by Andrzej Michnia on 02/07/16.
//  Copyright © 2016 amichnia. All rights reserved.
//

import UIKit
import SpriteKit
import SpriteKit_Spring

class CloudNode: SKSpriteNode {

    // MARK: - Properties
    var cloudNode: Bool = false
    var empty: Bool = true
    var associatedCloudNumber: Int?
    
    lazy var outlineNode: SKSpriteNode? = {
        return self.childNodeWithName("CloudNodeOutline") as? SKSpriteNode
    }()
    lazy var numberNode: SKLabelNode? = {
        return self.childNodeWithName("Number") as? SKLabelNode
    }()

    func sortNumber(){
        if let sceneSize = self.scene?.size {
            let center = CGPoint(x: sceneSize.width/2, y: sceneSize.height/2)
            let offset = center - self.position
            
        }
        else {
            
        }
    }
    
    // MARK: - Lifecycle

    // MARK: - Configuration
    func configureWithCloudNumber(cloudNumber: Int?) {
        self.numberNode?.text = cloudNumber != nil ? "\(cloudNumber)" : "+"
        self.empty = cloudNumber != nil
        
        // Physics
        let radius: CGFloat = self.outlineNode?.size.width ?? self.size.width
        self.physicsBody = SKPhysicsBody(circleOfRadius: radius)
    }
    
    // MARK: - Actions
    
}
