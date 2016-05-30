//
//  SkillNode.swift
//  SkillCloud
//
//  Created by Andrzej Michnia on 30/05/16.
//  Copyright © 2016 amichnia. All rights reserved.
//

import UIKit
import SpriteKit

class SkillNode: SKNode {
    
    static func nodeWithSkill(skill: Skill, andLocation location: CGPoint) -> SkillNode {
        // Whole skill node container
        let skillNode = SkillNode();
        skillNode.zPosition = 1028;
        skillNode.name = "skill"
        skillNode.position = location
        
        // Physics
        skillNode.physicsBody = SKPhysicsBody(circleOfRadius: CloudGraphScene.colliderRadius + (1.5 / Node.scaleFactor))
        skillNode.physicsBody?.categoryBitMask      = Defined.CollisionMask.Default
        skillNode.physicsBody?.collisionBitMask     = Defined.CollisionMask.Default
        skillNode.physicsBody?.contactTestBitMask   = Defined.CollisionMask.Default
        
        // Physics Constraints
        skillNode.constraints = [SKConstraint.zRotation(SKRange(value: 0, variance: 0))];
        
        // Initial scale
        skillNode.xScale = 0
        skillNode.yScale = 0
        
        // Mask shape - circular mask for skill image
        let maskShapeNode = SKShapeNode(circleOfRadius: CloudGraphScene.radius - 1 / Node.scaleFactor)
        maskShapeNode.strokeColor = Node.color
        maskShapeNode.fillColor = Node.color
        maskShapeNode.position = CGPointZero
        maskShapeNode.zPosition = skillNode.zPosition + 1
        
        // Skill image sprite node
        let skillImageTexture = SKTexture(image: skill.thumbnailImage)
        let skillImageSize = CGSize(width: CloudGraphScene.radius * 2 - 2 / Node.scaleFactor, height: CloudGraphScene.radius * 2 - 2 / Node.scaleFactor)
        let skillImageNode = SKSpriteNode(texture: skillImageTexture, size: skillImageSize)
        skillImageNode.position = CGPointZero
        skillImageNode.zPosition = skillNode.zPosition + 2
        
        // Foreground bordered circle - placed on top of image to provide "antialiasing"
        let foregroundShapeNode = SKShapeNode(circleOfRadius: CloudGraphScene.radius - 1 / Node.scaleFactor)
        foregroundShapeNode.strokeColor = Node.color
        foregroundShapeNode.lineWidth = 3 / Node.scaleFactor
        foregroundShapeNode.fillColor = UIColor.clearColor()
        foregroundShapeNode.position = CGPointZero
        foregroundShapeNode.zPosition = skillNode.zPosition + 3
        
        // Cropping skill image to circle shape
        let cropNode = SKCropNode()
        cropNode.maskNode = maskShapeNode
        cropNode.position = CGPointZero
        
        // Nodes hierarchy in container
        skillNode.addChild(cropNode)
        cropNode.addChild(skillImageNode)
        skillNode.addChild(foregroundShapeNode)
        
        return skillNode
    }
    
}