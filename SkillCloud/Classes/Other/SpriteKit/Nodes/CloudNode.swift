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
    lazy var plusNode: SKLabelNode? = {
        return self.childNodeWithName("Number") as? SKLabelNode
    }()
    lazy var numberNode: SKNode? = {
        return self.childNodeWithName("NumberNode")
    }()

    var sortNumber: CGFloat { return self.position.distanceTo(self.scene?.frame.centerOfMass ?? CGPoint.zero) }
    
    // MARK: - Lifecycle

    // MARK: - Configuration
    func configurePhysics() {
        let radius: CGFloat = (self.outlineNode?.size.width ?? self.size.width) / 2
        self.physicsBody = SKPhysicsBody(circleOfRadius: radius)
        self.physicsBody?.linearDamping = 3
        self.physicsBody?.angularDamping = 20
        self.physicsBody?.mass = 0.3
        
        self.constraints = [SKConstraint.zRotation(SKRange(constantValue: 0))]
        
        let joint = SKPhysicsJointSpring.jointWithBodyA(self.physicsBody!, bodyB: self.scene!.physicsBody!, anchorA: self.position, anchorB: self.position)
        joint.damping = 2
        joint.frequency = 1
        
        self.scene?.physicsWorld.addJoint(joint)
    }
    
    func configureWithCloudNumber(cloudNumber: Int?, potential: Bool = false) {
        self.plusNode?.hidden = !potential
        
        if let _ = cloudNumber {
            self.numberNode?.hidden = false
        }
        else {
            self.numberNode?.hidden = true
        }
        
        self.empty = (cloudNumber == nil)
        self.outlineNode?.hidden = self.empty && !potential
        self.associatedCloudNumber = cloudNumber
        self.cloudNode = !self.empty || potential
    }
    
    func configureWithThumbnail(thumbnail: UIImage?) {
        self.childNodeWithName("ThumbnailNode")?.removeFromParent()
        
        guard let thumbnail = thumbnail else {
            return
        }
        
        let texture = SKTexture(image: thumbnail.RBCircleImage())
        let inset = self.size.width * 0.1
        let thumbnailNode = SKSpriteNode(texture: texture, size: CGSizeInset(self.size,inset,inset))
        
        thumbnailNode.zPosition = (self.plusNode?.zPosition ?? (self.zPosition + 0.2)) - 0.1
//        thumbnailNode.alpha = 0.8
        thumbnailNode.name = "ThumbnailNode"
        
        self.addChild(thumbnailNode)
    }
    
    // MARK: - Actions
    
}

extension CloudNode: InteractiveNode {
    
    var interactionNode: SKNode? {
        return self.cloudNode ? self : self.parent?.interactionNode
    }
    
}