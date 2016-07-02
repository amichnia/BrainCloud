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

    var sortNumber: CGFloat { return self.position.distanceTo(self.scene?.frame.centerOfMass ?? CGPoint.zero) }
    
    // MARK: - Lifecycle

    // MARK: - Configuration
    func configureWithCloudNumber(cloudNumber: Int?, potential: Bool = false) {
        self.numberNode?.text = cloudNumber != nil ? "\(cloudNumber)" : (potential ? "+" : " ")
        self.empty = cloudNumber != nil
        self.outlineNode?.hidden = self.empty
        
        // Physics
        let radius: CGFloat = (self.outlineNode?.size.width ?? self.size.width) / 2
        self.physicsBody = SKPhysicsBody(circleOfRadius: radius)
        self.physicsBody?.linearDamping = 3
        self.physicsBody?.angularDamping = 20
        
        self.constraints = [SKConstraint.zRotation(SKRange(constantValue: 0))]
        
        let joint = SKPhysicsJointSpring.jointWithBodyA(self.physicsBody!, bodyB: self.scene!.physicsBody!, anchorA: self.position, anchorB: self.position)
        joint.damping = 2
        joint.frequency = 1
        
        self.scene?.physicsWorld.addJoint(joint)
    }
    
    // MARK: - Actions
    
}
