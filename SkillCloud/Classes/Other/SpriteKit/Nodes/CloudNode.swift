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
    var slot: Int = 0
    var cloudNode: Bool = false
    
    lazy var outlineNode: SKSpriteNode = {
        return (self.childNodeWithName("CloudNodeOutline") as? SKSpriteNode) ?? SKSpriteNode()
    }()
    lazy var backgroundNode: SKShapeNode = {
        let bgr = SKShapeNode(circleOfRadius: self.size.width / 2 - 2)
        bgr.fillColor = UIColor(white: 0.9, alpha: 0.15)
        bgr.zPosition = (self.plusNode?.zPosition ?? (self.zPosition + 0.2)) - 0.15
        bgr.blendMode = SKBlendMode.Screen
        self.addChild(bgr)
        return bgr
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
        let radius: CGFloat = self.size.width / 2
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
    
    func configureWithCloud(cloud: GraphCloudEntity?) {
        self.childNodeWithName("ThumbnailNode")?.removeFromParent()
        self.numberNode?.hidden = true
        
        guard let cloud = cloud else {
            self.plusNode?.hidden = false
            self.outlineNode.hidden = true
            self.backgroundNode.hidden = true
            return
        }
        
        self.plusNode?.hidden = true
        self.outlineNode.hidden = false
        self.backgroundNode.hidden = false
        
        if let thumbnail = cloud.thumbnail {
            let texture = SKTexture(image: thumbnail.RBCircleImage())
            let inset = self.size.width * 0.1
            let thumbnailNode = SKSpriteNode(texture: texture, size: CGSizeInset(self.size,inset,inset))
            thumbnailNode.zPosition = (self.plusNode?.zPosition ?? (self.zPosition + 0.2)) - 0.1
            thumbnailNode.name = "ThumbnailNode"
            
            self.addChild(thumbnailNode)
        }
    }
    
    // MARK: - Actions
    
}

extension CloudNode: InteractiveNode {
    
    var interactionNode: SKNode? {
        return self.cloudNode ? self : self.parent?.interactionNode
    }
    
}